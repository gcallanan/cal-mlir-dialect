#include "Transforms/Passes.h"
#include "Dialect/Cal/CalDialect.h"
#include "mlir/Dialect/Arith/IR/Arith.h"
#include "mlir/Dialect/Func/IR/FuncOps.h"
#include "mlir/Dialect/SCF/IR/SCF.h"
#include "mlir/Dialect/UB/IR/UBOps.h"
#include "mlir/IR/BuiltinOps.h"
#include "mlir/Pass/Pass.h"
#include "mlir/Pass/PassManager.h"
#include "mlir/Transforms/Passes.h"
#include "mlir/IR/Visitors.h"
#include "mlir/ExecutionEngine/ExecutionEngine.h"
#include "mlir/Target/LLVMIR/Dialect/Builtin/BuiltinToLLVMIRTranslation.h"
#include "mlir/Target/LLVMIR/Dialect/LLVMIR/LLVMToLLVMIRTranslation.h"
#include "mlir/Target/LLVMIR/Export.h"
#include "mlir/Conversion/FuncToLLVM/ConvertFuncToLLVM.h"
#include "mlir/Conversion/SCFToControlFlow/SCFToControlFlow.h"
#include "mlir/Conversion/ControlFlowToLLVM/ControlFlowToLLVM.h"
#include "mlir/Conversion/ArithToLLVM/ArithToLLVM.h"
#include "mlir/Conversion/MathToLLVM/MathToLLVM.h"
#include "mlir/Conversion/MemRefToLLVM/MemRefToLLVM.h"
#include "mlir/Conversion/ReconcileUnrealizedCasts/ReconcileUnrealizedCasts.h"
#include "mlir/Conversion/Passes.h"
#include "mlir/Dialect/ControlFlow/IR/ControlFlow.h"
#include "mlir/Dialect/LLVMIR/LLVMDialect.h"
#include "llvm/ExecutionEngine/Orc/JITTargetMachineBuilder.h"
#include "llvm/ADT/APFloat.h"
#include "llvm/Support/TargetSelect.h"
#include <optional>
#include <cstdint>
#include <string>
#include <unordered_map>

namespace mlir {

namespace {
/// Thin wrapper pass while we extract a dedicated always-JIT constant resolver.

/// For now, delegate to CalConstEval with default options and follow with a
/// canonicalizer to propagate constants.
struct ConstJITResolvePass
    : public PassWrapper<ConstJITResolvePass, OperationPass<ModuleOp>> {
  MLIR_DEFINE_EXPLICIT_INTERNAL_INLINE_TYPE_ID(ConstJITResolvePass)

  ConstJITResolvePass() = default;
  ConstJITResolvePass(const ConstJITResolvePass &other) {}

  StringRef getArgument() const final { return "const-jit-resolve"; }
  StringRef getDescription() const final {
    return "Resolve pure helpers via JIT and fold constants (wrapper).";
  }

  // CLI options
  Option<bool> enableExecEngine{*this, "enable-exec-engine",
                                llvm::cl::desc("Enable MLIR ExecutionEngine JIT folding"),
                                llvm::cl::init(true)};
  Option<int> eeOptLevel{*this, "ee-opt-level",
                         llvm::cl::desc("JIT optimization level (0..3, advisory)"),
                         llvm::cl::init(2)};
  Option<int> eeTimeoutMs{*this, "ee-timeout-ms",
                          llvm::cl::desc("Timeout in ms per JIT call (0=disabled)"),
                          llvm::cl::init(0)};
  Option<int> maxRecDepthOpt{*this, "max-rec-depth",
                             llvm::cl::desc("Max recursion depth for interpreter fallback"),
                             llvm::cl::init(100)};
  Option<bool> enableInterpreterFallback{*this, "enable-interpreter-fallback",
                                         llvm::cl::desc("Allow interpreter fallback when JIT unavailable"),
                                         llvm::cl::init(true)};
  Option<int> jitMaxArity{*this, "jit-max-arity",
                          llvm::cl::desc("Max homogeneous scalar args for JIT folding"),
                          llvm::cl::init(6)};

  void getDependentDialects(DialectRegistry &registry) const override {
    registry.insert<arith::ArithDialect, func::FuncDialect, scf::SCFDialect,
                    cf::ControlFlowDialect, LLVM::LLVMDialect, cal::CalDialect, ub::UBDialect>();
  }

  void runOnOperation() override {
    ModuleOp module = getOperation();
    
    // Decide whether to use the ExecutionEngine (JIT).
    bool useExecEngine = enableExecEngine;
    std::string hostTripleStr;
    if (useExecEngine) {
      if (auto jtmbOrErr = llvm::orc::JITTargetMachineBuilder::detectHost())
        hostTripleStr = jtmbOrErr->getTargetTriple().getTriple();
    }

    // Initialize LLVM native target for JIT execution (required for ExecutionEngine)
    if (useExecEngine) {
      llvm::InitializeNativeTarget();
      llvm::InitializeNativeTargetAsmPrinter();
      llvm::InitializeNativeTargetAsmParser();
      llvm::InitializeNativeTargetDisassembler();
    }
    
  // Build a small inner pass manager and parse a textual pipeline that
  // forces JIT-only const eval while disabling inliner, network inlining,
  // and pruning.
    PassManager pm(module.getContext());
    std::string pipeline =
    "cal-const-eval{enable-jit-const-eval=true enable-global-inliner=false "
        "enable-network-inline=false prune-unused=false},canonicalize";
    if (failed(parsePassPipeline(pipeline, pm))) {
      module.emitError("Failed to parse ConstJITResolve inner pipeline");
      signalPassFailure();
      return;
    }
    if (failed(pm.run(module)))
      signalPassFailure();

    // --- Generic self-recursive pure helper folding ----------------------
    // Lightweight interpreter for pure self-recursive functions (and calls to
    // other pure helpers) over integer arguments. Depth limited to 100.
    struct PureFuncInfo { func::FuncOp func; bool selfRecursive = false; bool supported = false; };
    llvm::DenseMap<StringRef, PureFuncInfo> pureFuncs;
    auto isSupportedOp = [&](Operation *op) -> bool {
      // Arithmetic + control ops we interpret. Add select so pow2-like helpers qualify.
      if (isa<arith::ConstantOp, arith::AddIOp, arith::SubIOp, arith::MulIOp,
              arith::CmpIOp, arith::SelectOp, scf::IfOp, scf::YieldOp,
              func::ReturnOp>(op))
        return true;
      // Function calls (including self recursion) are allowed if the callee is pure.
      if (isa<func::CallOp>(op)) return true;
      return false;
    };
    for (auto f : module.getOps<func::FuncOp>()) {
      auto type = f.getFunctionType();
      if (f.empty() || !f.getBody().hasOneBlock()) continue;
      if (type.getNumResults() != 1 || !type.getResult(0).isInteger(32)) continue;
      bool ok = true; bool selfRec = false;
      f.walk([&](Operation *op) -> WalkResult {
        if (op == f)
          return WalkResult::advance();
        if (!isSupportedOp(op)) {
          ok = false;
          return WalkResult::interrupt();
        }
        if (auto mem = dyn_cast<MemoryEffectOpInterface>(op)) {
          // Be permissive for func.call; purity of callee will be checked when visited.
          if (!isa<func::CallOp>(op) && !mem.hasNoEffect()) {
            ok = false;
            return WalkResult::interrupt();
          }
        }
        if (auto call = dyn_cast<func::CallOp>(op))
          if (call.getCallee() == f.getSymName())
            selfRec = true;
        return WalkResult::advance();
      });
      pureFuncs[f.getSymName()] = {f, selfRec, ok};
      if (ok) {
        f.emitRemark() << "Detected as pure function (selfRec=" << selfRec << ")";
      }
    }
    // --- Task 39: Function Isolation Module ------------------------------
    // Build an in-memory temporary ModuleOp per pure function containing
    // the root and transitive closure of reachable pure callees. This will
    // be consumed later by the ExecutionEngine lowering path. For now we
    // only construct and annotate; modules are discarded at end of pass.
    struct IsolationUnit { func::FuncOp root; ModuleOp isolated; SmallVector<func::FuncOp,4> cloned; };
    SmallVector<IsolationUnit, 16> isolationUnits;
    SymbolTableCollection symbolTables;
    auto isPureSupported = [&](func::FuncOp fn)->bool {
      auto it = pureFuncs.find(fn.getSymName());
      return it != pureFuncs.end() && it->second.supported && !fn.isExternal();
    };
    std::function<void(func::FuncOp, llvm::DenseSet<StringRef>&, SmallVector<func::FuncOp,8>&)> dfs;
    dfs = [&](func::FuncOp fn, llvm::DenseSet<StringRef> &vis, SmallVector<func::FuncOp,8> &acc){
      if (!vis.insert(fn.getSymName()).second) return; acc.push_back(fn);
      fn.walk([&](func::CallOp call){ if (auto callee = module.lookupSymbol<func::FuncOp>(call.getCallee())) if (isPureSupported(callee)) dfs(callee, vis, acc); });
    };
    for (auto &kv : pureFuncs) {
      if (!kv.second.supported) continue;
      func::FuncOp root = kv.second.func;
      if (root.isExternal()) continue;
      llvm::DenseSet<StringRef> visited;
      SmallVector<func::FuncOp,8> reachable;
      dfs(root, visited, reachable);
      // Create temporary module and deep-clone reachable pure functions.
      ModuleOp isoMod = ModuleOp::create(root.getLoc());
      // Stamp host target triple and data layout for reliable JIT on non-x86 (e.g., AArch64).
      if (enableExecEngine) {
        auto expectedJtmb = llvm::orc::JITTargetMachineBuilder::detectHost();
        if (expectedJtmb) {
          auto jtmb = std::move(*expectedJtmb);
          auto expectedDL = jtmb.getDefaultDataLayoutForTarget();
          if (expectedDL) {
            auto dl = std::move(*expectedDL);
            auto tripleStr = jtmb.getTargetTriple().getTriple();
            MLIRContext *ctx = isoMod.getContext();
            isoMod->setAttr(LLVM::LLVMDialect::getTargetTripleAttrName(), StringAttr::get(ctx, tripleStr));
            isoMod->setAttr(LLVM::LLVMDialect::getDataLayoutAttrName(), StringAttr::get(ctx, dl.getStringRepresentation()));
          }
        }
      }
      for (func::FuncOp rf : reachable) {
        Operation *cloned = rf.clone();
        isoMod.push_back(cloned);
      }
  OpBuilder localBuilder(root.getContext());
  root->setAttr("jit.isolation_built", localBuilder.getUnitAttr());
  root->setAttr("jit.isolation_func_count", localBuilder.getI32IntegerAttr((int)reachable.size()));
  IsolationUnit iu; iu.root = root; iu.isolated = isoMod; for (auto rfReach : reachable) iu.cloned.push_back(rfReach); isolationUnits.push_back(iu);
    }
    // NOTE: isolationUnits currently unused beyond annotation; future steps will
    // lower 'isolated' modules to LLVM and JIT evaluate them.

    // --- Task 40: Lower isolation modules to LLVM dialect -----------------
  if (useExecEngine)
  for (IsolationUnit &IU : isolationUnits) {
      ModuleOp iso = IU.isolated;
      // Build a lowering pipeline. Use explicit pass creation instead of textual
      // pipeline to ensure all passes are available at compile time.
      PassManager lowerPM(iso.getContext());
      // Canonicalize before conversions.
      lowerPM.addPass(createCanonicalizerPass());
      // Convert SCF to CF so later LLVM conversion can proceed.
      lowerPM.addPass(createConvertSCFToCFPass());
      // Perform another canonicalize+CSE to clean up.
      lowerPM.addPass(createCanonicalizerPass());
      lowerPM.addPass(createCSEPass());
      // Convert all dialects to LLVM using proper pass creation functions
  lowerPM.addPass(createArithToLLVMConversionPass());
  lowerPM.addPass(createConvertMathToLLVMPass());
  lowerPM.addPass(createConvertControlFlowToLLVMPass());
  lowerPM.addPass(createFinalizeMemRefToLLVMConversionPass());
  lowerPM.addPass(createConvertFuncToLLVMPass());
      // Reconcile unrealized casts that may be left over
      lowerPM.addPass(createReconcileUnrealizedCastsPass());
      // One more canonicalize to fold trivial patterns post-conversion.
      lowerPM.addPass(createCanonicalizerPass());
      if (failed(lowerPM.run(iso))) {
        IU.root->setAttr("jit.lower_to_llvm.failed", UnitAttr::get(iso.getContext()));
        continue;
      }
      IU.root->setAttr("jit.lower_to_llvm.ok", UnitAttr::get(iso.getContext()));
      // Record number of LLVM funcs as a sanity metric.
      int llvmFuncCount = 0;
  iso.walk([&](Operation *op){ if (op->getName().getStringRef().starts_with("llvm.func")) ++llvmFuncCount; });
      IU.root->setAttr("jit.lower_to_llvm.funcs", IntegerAttr::get(IntegerType::get(iso.getContext(),32), llvmFuncCount));
      // For now we do not serialize or JIT; ExecutionEngine setup comes later.
    }

    // --- Task 41: ExecutionEngine setup & caching -------------------------
    // We instantiate one ExecutionEngine per successfully lowered isolation unit.
    struct JITEntry { std::unique_ptr<ExecutionEngine> engine; void *fnPtr = nullptr; };
    DenseMap<StringRef, JITEntry> jitCache;
  MLIRContext *ctx = module.getContext();
  if (useExecEngine)
  for (IsolationUnit &IU : isolationUnits) {
      if (!IU.root->hasAttr("jit.lower_to_llvm.ok")) continue; // Skip failed lowers
      
      // Create ExecutionEngine - the translation interfaces should already be
      // registered in the main context (from cal-opt main.cpp)
      ExecutionEngineOptions eeOpts;
      // Let the engine pick host triple/CPU. Using options path for better portability.
      auto expectedEngine = ExecutionEngine::create(IU.isolated, eeOpts);
      if (!expectedEngine) {
        // If this fails, the translation interfaces might not be registered
        IU.root->setAttr("jit.engine_create_failed", UnitAttr::get(ctx));
        continue;
      }
      std::unique_ptr<ExecutionEngine> engine = std::move(*expectedEngine);
      // Lookup root symbol.
      auto sym = engine->lookup(IU.root.getSymName());
      if (!sym) {
        IU.root->setAttr("jit.lookup_failed", UnitAttr::get(ctx));
        continue;
      }
      void *addr = (void *)(*sym);
      JITEntry entry; entry.engine = std::move(engine); entry.fnPtr = addr;
      jitCache.insert({IU.root.getSymName(), std::move(entry)});
      IU.root->setAttr("jit.engine_ready", UnitAttr::get(ctx));
    }

    // --- Task 42: JIT invocation wrapper & IR rewrite ---------------------
    // Fold calls to JITed pure functions with all-constant operands.
    // Supports i32/i1/f32/f64 homogeneous signatures up to jitMaxArity.
    OpBuilder foldBuilder(module.getContext());
    module.walk([&](func::CallOp call) {
      if (!enableExecEngine) return;
      auto calleeName = call.getCallee();
      auto it = jitCache.find(calleeName);
      if (it == jitCache.end()) return;
      func::FuncOp callee = module.lookupSymbol<func::FuncOp>(calleeName);
      if (!callee) return;
      // Avoid JIT-folding for self-recursive helpers; prefer interpreter path.
      if (auto itInfo = pureFuncs.find(calleeName); itInfo != pureFuncs.end())
        if (itInfo->second.selfRecursive)
          return;
      auto fType = callee.getFunctionType();
      if (fType.getNumResults() != 1) return;
      if (call.getNumOperands() != fType.getNumInputs()) return;
      if ((int)call.getNumOperands() > jitMaxArity) return;
      Type resTy = fType.getResult(0);
      void *rawPtr = it->second.fnPtr; if (!rawPtr) return;
      auto allOperandsMatchTypes = [&]() -> bool {
        for (auto itPair : llvm::enumerate(call.getOperands()))
          if (itPair.value().getType() != fType.getInput(itPair.index()))
            return false;
        return true;
      };
      if (!allOperandsMatchTypes()) return;
      foldBuilder.setInsertionPoint(call);
      // i32 return and inputs
      if (resTy.isInteger(32)) {
        SmallVector<int32_t, 8> args;
        for (Value v : call.getOperands()) {
          auto cOp = v.getDefiningOp<arith::ConstantOp>(); if (!cOp) return;
          auto iAttr = dyn_cast<IntegerAttr>(cOp.getValue()); if (!iAttr || !iAttr.getType().isInteger(32)) return;
          args.push_back((int32_t)iAttr.getInt());
        }
        int32_t result = 0;
        switch (args.size()) {
        case 0: result = (reinterpret_cast<int32_t(*)()>(rawPtr))(); break;
        case 1: result = (reinterpret_cast<int32_t(*)(int32_t)>(rawPtr))(args[0]); break;
        case 2: result = (reinterpret_cast<int32_t(*)(int32_t,int32_t)>(rawPtr))(args[0],args[1]); break;
        case 3: result = (reinterpret_cast<int32_t(*)(int32_t,int32_t,int32_t)>(rawPtr))(args[0],args[1],args[2]); break;
        case 4: result = (reinterpret_cast<int32_t(*)(int32_t,int32_t,int32_t,int32_t)>(rawPtr))(args[0],args[1],args[2],args[3]); break;
        case 5: result = (reinterpret_cast<int32_t(*)(int32_t,int32_t,int32_t,int32_t,int32_t)>(rawPtr))(args[0],args[1],args[2],args[3],args[4]); break;
        case 6: result = (reinterpret_cast<int32_t(*)(int32_t,int32_t,int32_t,int32_t,int32_t,int32_t)>(rawPtr))(args[0],args[1],args[2],args[3],args[4],args[5]); break;
        default: return;
        }
        auto c = foldBuilder.create<arith::ConstantIntOp>(call.getLoc(), (int64_t)result, 32);
        call.getResult(0).replaceAllUsesWith(c.getResult()); call.erase(); return;
      }
      // i1 return and inputs
      if (resTy.isInteger(1)) {
        SmallVector<uint8_t, 8> args;
        for (Value v : call.getOperands()) {
          auto cOp = v.getDefiningOp<arith::ConstantOp>(); if (!cOp) return;
          auto iAttr = dyn_cast<IntegerAttr>(cOp.getValue()); if (!iAttr || !iAttr.getType().isInteger(1)) return;
          args.push_back((uint8_t)(iAttr.getInt() != 0));
        }
        uint8_t result = 0;
        switch (args.size()) {
        case 0: result = (reinterpret_cast<uint8_t(*)()>(rawPtr))(); break;
        case 1: result = (reinterpret_cast<uint8_t(*)(uint8_t)>(rawPtr))(args[0]); break;
        case 2: result = (reinterpret_cast<uint8_t(*)(uint8_t,uint8_t)>(rawPtr))(args[0],args[1]); break;
        case 3: result = (reinterpret_cast<uint8_t(*)(uint8_t,uint8_t,uint8_t)>(rawPtr))(args[0],args[1],args[2]); break;
        case 4: result = (reinterpret_cast<uint8_t(*)(uint8_t,uint8_t,uint8_t,uint8_t)>(rawPtr))(args[0],args[1],args[2],args[3]); break;
        case 5: result = (reinterpret_cast<uint8_t(*)(uint8_t,uint8_t,uint8_t,uint8_t,uint8_t)>(rawPtr))(args[0],args[1],args[2],args[3],args[4]); break;
        case 6: result = (reinterpret_cast<uint8_t(*)(uint8_t,uint8_t,uint8_t,uint8_t,uint8_t,uint8_t)>(rawPtr))(args[0],args[1],args[2],args[3],args[4],args[5]); break;
        default: return;
        }
        auto c = foldBuilder.create<arith::ConstantIntOp>(call.getLoc(), (int64_t)(result ? 1 : 0), 1);
        call.getResult(0).replaceAllUsesWith(c.getResult()); call.erase(); return;
      }
      // f32 return and inputs
      if (resTy.isF32()) {
        SmallVector<float, 8> args;
        for (Value v : call.getOperands()) {
          auto cOp = v.getDefiningOp<arith::ConstantOp>(); if (!cOp) return;
          auto fAttr = dyn_cast<FloatAttr>(cOp.getValue()); if (!fAttr || !fAttr.getType().isF32()) return;
          args.push_back((float)fAttr.getValueAsDouble());
        }
        float result = 0.0f;
        switch (args.size()) {
        case 0: result = (reinterpret_cast<float(*)()>(rawPtr))(); break;
        case 1: result = (reinterpret_cast<float(*)(float)>(rawPtr))(args[0]); break;
        case 2: result = (reinterpret_cast<float(*)(float,float)>(rawPtr))(args[0],args[1]); break;
        case 3: result = (reinterpret_cast<float(*)(float,float,float)>(rawPtr))(args[0],args[1],args[2]); break;
        case 4: result = (reinterpret_cast<float(*)(float,float,float,float)>(rawPtr))(args[0],args[1],args[2],args[3]); break;
        case 5: result = (reinterpret_cast<float(*)(float,float,float,float,float)>(rawPtr))(args[0],args[1],args[2],args[3],args[4]); break;
        case 6: result = (reinterpret_cast<float(*)(float,float,float,float,float,float)>(rawPtr))(args[0],args[1],args[2],args[3],args[4],args[5]); break;
        default: return;
        }
        auto c = foldBuilder.create<arith::ConstantOp>(call.getLoc(), FloatAttr::get(resTy, llvm::APFloat(result)));
        call.getResult(0).replaceAllUsesWith(c.getResult()); call.erase(); return;
      }
      // f64 return and inputs
      if (resTy.isF64()) {
        SmallVector<double, 8> args;
        for (Value v : call.getOperands()) {
          auto cOp = v.getDefiningOp<arith::ConstantOp>(); if (!cOp) return;
          auto fAttr = dyn_cast<FloatAttr>(cOp.getValue()); if (!fAttr || !fAttr.getType().isF64()) return;
          args.push_back(fAttr.getValueAsDouble());
        }
        double result = 0.0;
        switch (args.size()) {
        case 0: result = (reinterpret_cast<double(*)()>(rawPtr))(); break;
        case 1: result = (reinterpret_cast<double(*)(double)>(rawPtr))(args[0]); break;
        case 2: result = (reinterpret_cast<double(*)(double,double)>(rawPtr))(args[0],args[1]); break;
        case 3: result = (reinterpret_cast<double(*)(double,double,double)>(rawPtr))(args[0],args[1],args[2]); break;
        case 4: result = (reinterpret_cast<double(*)(double,double,double,double)>(rawPtr))(args[0],args[1],args[2],args[3]); break;
        case 5: result = (reinterpret_cast<double(*)(double,double,double,double,double)>(rawPtr))(args[0],args[1],args[2],args[3],args[4]); break;
        case 6: result = (reinterpret_cast<double(*)(double,double,double,double,double,double)>(rawPtr))(args[0],args[1],args[2],args[3],args[4],args[5]); break;
        default: return;
        }
        auto c = foldBuilder.create<arith::ConstantOp>(call.getLoc(), FloatAttr::get(resTy, llvm::APFloat(result)));
        call.getResult(0).replaceAllUsesWith(c.getResult()); call.erase(); return;
      }
    });
  std::unordered_map<std::string, int64_t> memo; // key: funcName|arg0,arg1,...
    std::function<std::optional<int64_t>(func::FuncOp, SmallVector<int64_t>&, int)> eval;
    eval = [&](func::FuncOp fn, SmallVector<int64_t> &args, int depth) -> std::optional<int64_t> {
      if (depth > maxRecDepthOpt) {
        fn.emitRemark() << "Recursion depth exceeded at depth=" << depth;
        return std::nullopt;
      }
      auto itInfo = pureFuncs.find(fn.getSymName()); 
      if (itInfo == pureFuncs.end() || !itInfo->second.supported) {
        fn.emitRemark() << "Function not pure or supported";
        return std::nullopt;
      }
      std::string key = fn.getSymName().str(); key.push_back('|');
      for (size_t i=0;i<args.size();++i){ key.append(std::to_string(args[i])); if (i+1<args.size()) key.push_back(','); }
      if (auto it = memo.find(key); it != memo.end()) return it->second;
      Block &block = fn.getBody().front(); 
      if ((int)block.getNumArguments() != (int)args.size()) {
        fn.emitRemark() << "Arg count mismatch in eval";
        return std::nullopt;
      }
      llvm::DenseMap<Value,int64_t> env; 
      for (auto [v,a] : llvm::zip(block.getArguments(), args)) env[v]=a;
      
      // Demand-driven evaluation: recursively compute a value only when needed
      std::function<std::optional<int64_t>(Value)> evalValue;
      evalValue = [&](Value v) -> std::optional<int64_t> {
        if (env.count(v)) return env[v];
        Operation *defOp = v.getDefiningOp();
        if (!defOp) return std::nullopt;
        
        if (auto cst = dyn_cast<arith::ConstantOp>(defOp)) {
          if (auto iattr = dyn_cast<IntegerAttr>(cst.getValue())) {
            int64_t val = iattr.getInt();
            env[v] = val;
            return val;
          }
          return std::nullopt;
        }
        else if (auto addi = dyn_cast<arith::AddIOp>(defOp)) {
          auto lhs = evalValue(addi.getLhs()); if (!lhs) return std::nullopt;
          auto rhs = evalValue(addi.getRhs()); if (!rhs) return std::nullopt;
          int64_t val = *lhs + *rhs;
          env[v] = val;
          return val;
        }
        else if (auto subi = dyn_cast<arith::SubIOp>(defOp)) {
          auto lhs = evalValue(subi.getLhs()); if (!lhs) return std::nullopt;
          auto rhs = evalValue(subi.getRhs()); if (!rhs) return std::nullopt;
          int64_t val = *lhs - *rhs;
          env[v] = val;
          return val;
        }
        else if (auto muli = dyn_cast<arith::MulIOp>(defOp)) {
          auto lhs = evalValue(muli.getLhs()); if (!lhs) return std::nullopt;
          auto rhs = evalValue(muli.getRhs()); if (!rhs) return std::nullopt;
          int64_t val = *lhs * *rhs;
          env[v] = val;
          return val;
        }
        else if (auto cmp = dyn_cast<arith::CmpIOp>(defOp)) {
          auto lhs = evalValue(cmp.getLhs()); if (!lhs) return std::nullopt;
          auto rhs = evalValue(cmp.getRhs()); if (!rhs) return std::nullopt;
          bool res = false;
          switch(cmp.getPredicate()){
            case arith::CmpIPredicate::eq: res = *lhs == *rhs; break;
            case arith::CmpIPredicate::ne: res = *lhs != *rhs; break;
            case arith::CmpIPredicate::slt: res = *lhs < *rhs; break;
            case arith::CmpIPredicate::sle: res = *lhs <= *rhs; break;
            case arith::CmpIPredicate::sgt: res = *lhs > *rhs; break;
            case arith::CmpIPredicate::sge: res = *lhs >= *rhs; break;
            default: return std::nullopt;
          }
          int64_t val = res ? 1 : 0;
          env[v] = val;
          return val;
        }
        else if (auto sel = dyn_cast<arith::SelectOp>(defOp)) {
          auto cond = evalValue(sel.getCondition()); if (!cond) return std::nullopt;
          // Short-circuit: only evaluate the chosen branch
          Value chosen = (*cond != 0) ? sel.getTrueValue() : sel.getFalseValue();
          auto val = evalValue(chosen); if (!val) return std::nullopt;
          env[v] = *val;
          return val;
        }
        else if (auto ifOp = dyn_cast<scf::IfOp>(defOp)) {
          // Evaluate the condition, then traverse only the chosen region and
          // evaluate the yielded value.
          auto condVal = evalValue(ifOp.getCondition());
          if (!condVal) return std::nullopt;
          Region &chosen = (*condVal != 0) ? ifOp.getThenRegion() : ifOp.getElseRegion();
          if (chosen.empty()) return std::nullopt;
          Block &b = chosen.front();
          scf::YieldOp yld = nullptr;
          for (Operation &rop : b) {
            if (auto y = dyn_cast<scf::YieldOp>(&rop)) { yld = y; break; }
          }
          if (!yld || yld.getNumOperands() != 1) return std::nullopt;
          auto inner = evalValue(yld.getOperand(0));
          if (!inner) return std::nullopt;
          env[v] = *inner;
          return inner;
        }
        else if (auto call = dyn_cast<func::CallOp>(defOp)) {
          SmallVector<int64_t> argVals;
          for (Value opnd : call.getOperands()) {
            auto argVal = evalValue(opnd); if (!argVal) return std::nullopt;
            argVals.push_back(*argVal);
          }
          func::FuncOp callee = module.lookupSymbol<func::FuncOp>(call.getCallee());
          if (!callee) return std::nullopt;
          auto subRes = eval(callee, argVals, depth+1);
          if (!subRes) return std::nullopt;
          env[v] = *subRes;
          return subRes;
        }
        // Add other ops as needed (scf.if, etc.)
        return std::nullopt;
      };
      
      // Find the return op and evaluate its operand
      func::ReturnOp retOp = nullptr;
      for (Operation &op : block) {
        if (auto ret = dyn_cast<func::ReturnOp>(&op)) {
          retOp = ret;
          break;
        }
      }
      if (!retOp) return std::nullopt;
      
      auto retVal = evalValue(retOp.getOperand(0));
      if (!retVal) return std::nullopt;
      
      memo[key] = *retVal;
      return *retVal;
    };
    if (enableInterpreterFallback) {
      OpBuilder builder(module.getContext());
      int foldCount = 0;
      module.walk([&](func::CallOp call){ 
        func::FuncOp callee = module.lookupSymbol<func::FuncOp>(call.getCallee()); 
        if(!callee) {
          call.emitRemark() << "Callee not found: " << call.getCallee();
          return;
        }
        auto itInfo=pureFuncs.find(call.getCallee()); 
        if(itInfo==pureFuncs.end()) {
          call.emitRemark() << "Callee not in pureFuncs map: " << call.getCallee();
          return;
        }
        if(!itInfo->second.supported) {
          call.emitRemark() << "Callee not supported: " << call.getCallee();
          return;
        }
        SmallVector<int64_t> argVals; 
        for(Value opnd: call.getOperands()){ 
          if(auto cst=opnd.getDefiningOp<arith::ConstantOp>()) { 
            if(auto iattr=dyn_cast<IntegerAttr>(cst.getValue())) { 
              argVals.push_back(iattr.getInt()); 
              continue; 
            } 
          } 
          call.emitRemark() << "Non-constant operand in call to " << call.getCallee();
          return; 
        } 
        if(argVals.size()!=callee.getFunctionType().getNumInputs()) {
          call.emitRemark() << "Arg count mismatch for " << call.getCallee();
          return;
        }
        call.emitRemark() << "Attempting to evaluate " << call.getCallee() << " with args";
        auto valueOpt = eval(callee, argVals, 0); 
        if(!valueOpt) {
          call.emitRemark() << "Eval returned nullopt for " << call.getCallee();
          return;
        }
        call.emitRemark() << "Folded " << call.getCallee() << " -> " << *valueOpt;
        builder.setInsertionPoint(call); 
        auto folded = builder.create<arith::ConstantIntOp>(call.getLoc(), *valueOpt, 32); 
        if (call.getNumResults()==1) call.getResult(0).replaceAllUsesWith(folded.getResult()); 
        call.erase();
        foldCount++;
      });
      if (foldCount > 0) {
        module.emitRemark() << "Interpreter folded " << foldCount << " calls";
      }
    }
    // Final cleanup to propagate newly folded constants.
    {
      PassManager cleanupPM(module.getContext());
      cleanupPM.addPass(createCanonicalizerPass());
      cleanupPM.addPass(createCSEPass());
      (void)cleanupPM.run(module);
    }
  }
};
} // end anonymous namespace

std::unique_ptr<Pass> createConstJITResolvePass() {
  return std::make_unique<ConstJITResolvePass>();
}

} // namespace mlir
