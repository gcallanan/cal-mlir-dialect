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
#include "mlir/ExecutionEngine/ExecutionEngine.h"
#include "mlir/Target/LLVMIR/Dialect/Builtin/BuiltinToLLVMIRTranslation.h"
#include "mlir/Target/LLVMIR/Dialect/LLVMIR/LLVMToLLVMIRTranslation.h"
#include "mlir/Conversion/FuncToLLVM/ConvertFuncToLLVM.h"
#include "mlir/Conversion/SCFToControlFlow/SCFToControlFlow.h"
#include "llvm/ADT/APFloat.h"
#include <optional>
#include <cstdint>
#include <string>
#include <unordered_map>

namespace mlir {

namespace {
/// Thin wrapper pass while we extract a dedicated always-JIT constant resolver.
#include <optional>
#include <string>
#include <unordered_map>
#include <set>

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
                    cal::CalDialect, ub::UBDialect>();
  }

  void runOnOperation() override {
    ModuleOp module = getOperation();
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
      for (Operation &op : f.getBody().front()) {
        if (!isSupportedOp(&op)) { ok = false; break; }
        if (auto mem = dyn_cast<MemoryEffectOpInterface>(&op)) {
          // Be permissive for func.call; purity of callee will be checked when visited.
          if (!isa<func::CallOp>(op) && !mem.hasNoEffect()) { ok = false; break; }
        }
        if (auto call = dyn_cast<func::CallOp>(&op)) if (call.getCallee() == f.getSymName()) selfRec = true;
      }
      pureFuncs[f.getSymName()] = {f, selfRec, ok};
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
  if (enableExecEngine)
  for (IsolationUnit &IU : isolationUnits) {
      ModuleOp iso = IU.isolated;
      // Build a lowering pipeline. Use explicit pass manager instead of textual
      // pipeline to get compile-time coverage and clearer failures.
      PassManager lowerPM(iso.getContext());
      // Canonicalize before conversions.
      lowerPM.addPass(createCanonicalizerPass());
      // Convert SCF to CF so later LLVM conversion can proceed.
      lowerPM.addPass(createConvertSCFToCFPass());
      // (Optional) Expand complex arithmetic; currently not needed but safe.
      // lowerPM.addPass(createMathToFuncsPass()); // If math functions present.
      // Perform another canonicalize+CSE to clean up.
      lowerPM.addPass(createCanonicalizerPass());
      lowerPM.addPass(createCSEPass());
      // Attempt common conversions if available (best-effort across toolchains).
      (void)parsePassPipeline("convert-arith-to-llvm", lowerPM);
      (void)parsePassPipeline("convert-math-to-llvm", lowerPM);
      (void)parsePassPipeline("convert-memref-to-llvm", lowerPM);
      // Attempt textual pipeline to lower func to llvm if available.
      if (failed(parsePassPipeline("convert-func-to-llvm", lowerPM))) {
        IU.root->setAttr("jit.lower_to_llvm.pipeline_parse_failed", UnitAttr::get(iso.getContext()));
      }
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
    // Register dialect translations (once).
    registerBuiltinDialectTranslation(*ctx);
  registerLLVMDialectTranslation(*ctx);
  if (enableExecEngine)
  for (IsolationUnit &IU : isolationUnits) {
      if (!IU.root->hasAttr("jit.lower_to_llvm.ok")) continue; // Skip failed lowers
      // Create engine.
      auto expectedEngine = ExecutionEngine::create(IU.isolated);
      if (!expectedEngine) {
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
      if (depth > maxRecDepthOpt) return std::nullopt; auto itInfo = pureFuncs.find(fn.getSymName()); if (itInfo == pureFuncs.end() || !itInfo->second.supported) return std::nullopt;
      std::string key = fn.getSymName().str(); key.push_back('|');
      for (size_t i=0;i<args.size();++i){ key.append(std::to_string(args[i])); if (i+1<args.size()) key.push_back(','); }
      if (auto it = memo.find(key); it != memo.end()) return it->second;
      Block &block = fn.getBody().front(); if ((int)block.getNumArguments() != (int)args.size()) return std::nullopt;
      llvm::DenseMap<Value,int64_t> env; for (auto [v,a] : llvm::zip(block.getArguments(), args)) env[v]=a;
      int64_t retValue = 0;
      for (Operation &op : block) {
        if (auto ret = dyn_cast<func::ReturnOp>(&op)) { Value rv = ret.getOperand(0); if (!env.count(rv)) return std::nullopt; retValue = env[rv]; break; }
        else if (auto cst = dyn_cast<arith::ConstantOp>(&op)) { if (auto iattr = dyn_cast<IntegerAttr>(cst.getValue())) env[cst.getResult()] = iattr.getInt(); else return std::nullopt; }
        else if (auto addi = dyn_cast<arith::AddIOp>(&op)) { if (!env.count(addi.getLhs())||!env.count(addi.getRhs())) return std::nullopt; env[addi.getResult()] = env[addi.getLhs()]+env[addi.getRhs()]; }
        else if (auto subi = dyn_cast<arith::SubIOp>(&op)) { if (!env.count(subi.getLhs())||!env.count(subi.getRhs())) return std::nullopt; env[subi.getResult()] = env[subi.getLhs()]-env[subi.getRhs()]; }
        else if (auto muli = dyn_cast<arith::MulIOp>(&op)) { if (!env.count(muli.getLhs())||!env.count(muli.getRhs())) return std::nullopt; env[muli.getResult()] = env[muli.getLhs()]*env[muli.getRhs()]; }
  else if (auto cmp = dyn_cast<arith::CmpIOp>(&op)) { if (!env.count(cmp.getLhs())||!env.count(cmp.getRhs())) return std::nullopt; int64_t lhs=env[cmp.getLhs()], rhs=env[cmp.getRhs()]; bool res=false; switch(cmp.getPredicate()){case arith::CmpIPredicate::eq:res=lhs==rhs;break;case arith::CmpIPredicate::ne:res=lhs!=rhs;break;case arith::CmpIPredicate::slt:res=lhs<rhs;break;case arith::CmpIPredicate::sle:res=lhs<=rhs;break;case arith::CmpIPredicate::sgt:res=lhs>rhs;break;case arith::CmpIPredicate::sge:res=lhs>=rhs;break;default:return std::nullopt;} env[cmp.getResult()] = res?1:0; }
  else if (auto sel = dyn_cast<arith::SelectOp>(&op)) { Value cond = sel.getCondition(); if(!env.count(cond)) return std::nullopt; bool takeTrue = env[cond] != 0; Value chosen = takeTrue? sel.getTrueValue() : sel.getFalseValue(); if(!env.count(chosen)) return std::nullopt; env[sel.getResult()] = env[chosen]; }
        else if (auto ifOp = dyn_cast<scf::IfOp>(&op)) { Value cond = ifOp.getCondition(); if (!env.count(cond)) return std::nullopt; bool takeThen = env[cond]!=0; Region &chosen = takeThen? ifOp.getThenRegion(): ifOp.getElseRegion(); if (!chosen.hasOneBlock()) return std::nullopt; Block &cb = chosen.front(); scf::YieldOp yld; for (Operation &inner : cb){ if (auto c = dyn_cast<arith::ConstantOp>(&inner)) { if (auto iattr = dyn_cast<IntegerAttr>(c.getValue())) env[c.getResult()]=iattr.getInt(); else return std::nullopt; } else if (auto y = dyn_cast<scf::YieldOp>(&inner)) { yld = y; break; } else if (auto ai = dyn_cast<arith::AddIOp>(&inner)) { if (!env.count(ai.getLhs())||!env.count(ai.getRhs())) return std::nullopt; env[ai.getResult()] = env[ai.getLhs()]+env[ai.getRhs()]; } else if (auto si = dyn_cast<arith::SubIOp>(&inner)) { if (!env.count(si.getLhs())||!env.count(si.getRhs())) return std::nullopt; env[si.getResult()] = env[si.getLhs()]-env[si.getRhs()]; } else if (auto mi = dyn_cast<arith::MulIOp>(&inner)) { if (!env.count(mi.getLhs())||!env.count(mi.getRhs())) return std::nullopt; env[mi.getResult()] = env[mi.getLhs()]*env[mi.getRhs()]; } }
          if (!yld) return std::nullopt; Value yielded = yld.getOperand(0); if (!env.count(yielded)) return std::nullopt; env[ifOp.getResult(0)] = env[yielded]; }
        else if (auto call = dyn_cast<func::CallOp>(&op)) { SmallVector<int64_t> argVals; bool allConst=true; for (Value v : call.getOperands()){ if(!env.count(v)){ allConst=false; break;} argVals.push_back(env[v]); } if(!allConst) return std::nullopt; func::FuncOp callee = module.lookupSymbol<func::FuncOp>(call.getCallee()); if(!callee) return std::nullopt; auto subRes = eval(callee, argVals, depth+1); if(!subRes) return std::nullopt; env[call.getResult(0)] = *subRes; }
        else if (isa<scf::YieldOp>(op)) { /* handled */ }
        else return std::nullopt;
      }
      memo[key] = retValue; return retValue;
    };
    if (enableInterpreterFallback) {
      OpBuilder builder(module.getContext());
      module.walk([&](func::CallOp call){ func::FuncOp callee = module.lookupSymbol<func::FuncOp>(call.getCallee()); if(!callee) return; auto itInfo=pureFuncs.find(call.getCallee()); if(itInfo==pureFuncs.end()||!itInfo->second.supported) return; SmallVector<int64_t> argVals; for(Value opnd: call.getOperands()){ if(auto cst=opnd.getDefiningOp<arith::ConstantOp>()) { if(auto iattr=dyn_cast<IntegerAttr>(cst.getValue())) { argVals.push_back(iattr.getInt()); continue; } } return; } if(argVals.size()!=callee.getFunctionType().getNumInputs()) return; auto valueOpt = eval(callee, argVals, 0); if(!valueOpt) return; builder.setInsertionPoint(call); auto folded = builder.create<arith::ConstantIntOp>(call.getLoc(), *valueOpt, 32); if (call.getNumResults()==1) call.getResult(0).replaceAllUsesWith(folded.getResult()); call.erase(); });
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
