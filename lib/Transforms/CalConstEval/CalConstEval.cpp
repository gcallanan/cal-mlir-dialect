//===- CalConstEval.cpp - Const-eval helper funcs for CAL nets ---------===//
// A lightweight skeleton pass that will later inline and fold constexpr-like
// helpers so structural conditions and trip counts become constants.
// For now, it performs no transformation, serving as a registered placeholder.
//===----------------------------------------------------------------------===//

#include "mlir/Pass/Pass.h"
// Dependent dialects referenced in the generated registration for this pass.
#include "mlir/Dialect/Arith/IR/Arith.h"
#include "mlir/Dialect/Func/IR/FuncOps.h"
#include "mlir/Dialect/SCF/IR/SCF.h"
// LLVM dialect for lowering target
#include "mlir/Dialect/LLVMIR/LLVMDialect.h"
// UB dialect header is needed because the generated pass registration
// refers to mlir::ub::UBDialect. Note: we do NOT load UB into the JIT
// scratch context to sidestep ConvertToLLVM extension requirements.
#include "mlir/Dialect/UB/IR/UBOps.h"
// ExecutionEngine and lowering scaffolding (JIT const-eval prep)
#include "mlir/ExecutionEngine/ExecutionEngine.h"
#include "mlir/Conversion/Passes.h" // createConvertToLLVMPass indirect dep (keep guarded)
#include "mlir/Conversion/FuncToLLVM/ConvertFuncToLLVM.h"
#include "mlir/Conversion/ArithToLLVM/ArithToLLVM.h"
#include "mlir/Conversion/SCFToControlFlow/SCFToControlFlow.h"
#include "mlir/Conversion/ControlFlowToLLVM/ControlFlowToLLVM.h"
#include "mlir/Conversion/ReconcileUnrealizedCasts/ReconcileUnrealizedCasts.h"
#include "mlir/Dialect/ControlFlow/IR/ControlFlow.h"
#include "mlir/IR/BuiltinOps.h"
#include "mlir/IR/IRMapping.h"
#include "mlir/IR/Builders.h"
#include "mlir/IR/SymbolTable.h"
#include "mlir/Pass/PassManager.h"
#include "mlir/Transforms/Passes.h"
// For DialectInlinerInterface detection (guarded inliner usage)
#include "mlir/Transforms/InliningUtils.h"
// Generic constant matcher
#include "mlir/IR/Matchers.h"
// LLVM translation interfaces for ExecutionEngine JIT
#include "mlir/Target/LLVMIR/Dialect/Builtin/BuiltinToLLVMIRTranslation.h"
#include "mlir/Target/LLVMIR/Dialect/LLVMIR/LLVMToLLVMIRTranslation.h"
// Env var check
#include <cstdlib>
// Time watchdog
#include <chrono>
// Bit utilities for float bitcasts
#include <cstring>
// APInt for safe constant evaluation
#include "llvm/ADT/APInt.h"
// DenseMap / SmallVector / String
#include "llvm/ADT/DenseMap.h"
#include "llvm/ADT/SmallVector.h"
#include "llvm/ADT/SmallString.h"
// Pattern helpers for constant folding checks
#include "mlir/IR/PatternMatch.h"
// CAL ops to scope work under cal.network
#include "Dialect/Cal/CalOps.h"
#include "Transforms/Passes.h"
// For identifying FIFO port-typed block arguments when computing param counts.
#include "Dialect/Fifo/FifoTypes.h"

using namespace mlir;

namespace mlir {
#define GEN_PASS_DECL_CALCONSTEVALPASS
#define GEN_PASS_DEF_CALCONSTEVALPASS
#include "Transforms/Passes.h.inc"

namespace {
struct CalConstEvalPass : public impl::CalConstEvalPassBase<CalConstEvalPass> {
  // Cache to deduplicate specializations in one pass run.
  // Key format: symName + '|' + per-param ("-" for dynamic or attribute dump).
  llvm::StringMap<FlatSymbolRefAttr> specCache;

  // Experimental: cache for JIT const-eval results (callee+args).
  // Keyed by callee symbol plus comma-joined signed argument values.
  llvm::StringMap<llvm::APInt> jitConstMemo;

  // Stub for upcoming JIT-based const evaluation. Returns nullopt until
  // fully implemented. The interface is stable: takes a pure helper callee
  // and its constant integer/index arguments, and returns a folded APInt
  // or nullopt if not supported/fails. Budget limits compile/exec effort.
  std::optional<llvm::APInt>
  tryJitConstEval(func::FuncOp callee,
                  ArrayRef<llvm::APInt> args,
                  unsigned budget);

  void runOnOperation() override {
    // Run a tiny inner pipeline: prefer MLIR's inliner when available,
    // otherwise fall back to a simple local inliner, then canonicalize.
    Operation *op = getOperation();

    bool ranGlobalInliner = false;
    // Prefer pass option; keep env var as a secondary dev toggle.
    bool useGlobalInliner = this->enableGlobalInliner ||
                            (std::getenv("CAL_ENABLE_GLOBAL_INLINER") != nullptr);
    if (useGlobalInliner) {
      if (auto *ctx = op->getContext()) {
        PassManager pm(ctx);
        pm.enableVerifier(false);
        pm.addPass(mlir::createInlinerPass());
        pm.addPass(mlir::createCanonicalizerPass());
        if (succeeded(pm.run(op))) {
          ranGlobalInliner = true;
        }
      }
    }

    if (!ranGlobalInliner) {
      // Small, local inliner for pure, single-block helper functions with constant
      // arguments. This avoids relying on the global inliner interface.
      if (auto module = dyn_cast<ModuleOp>(op)) {
        SymbolTable symTable(module);
        SmallVector<func::CallOp, 8> calls;
        module.walk([&](func::CallOp call) {
          // Broaden scope: allow const-eval anywhere in the module (actors, networks, helpers).
          // This helps fold helpers inside functions called by networks as well.
          calls.push_back(call);
        });
        for (func::CallOp call : calls) {
          // Only handle single-result calls for now.
          if (call.getNumResults() != 1)
            continue;
          // Callee must be resolvable.
          auto callee = symTable.lookup<func::FuncOp>(call.getCallee());
          if (!callee)
            continue;
          // Callee must be a simple, single-block function with a single return.
          if (!callee.getBody().hasOneBlock())
            continue;
          Block &body = callee.getBody().front();
          // Require same number of args as operands.
          if (callee.getFunctionType().getNumInputs() != call.getNumOperands())
            continue;
          // Conservatively skip functions with nested regions or ops outside arith/func.return.
          bool simple = true;
          for (Operation &inner : body) {
            if (isa<func::ReturnOp>(&inner))
              continue;
            // Allow only arith dialect ops and constants.
            if (!(inner.getName().getDialectNamespace() == "arith")) {
              simple = false;
              break;
            }
          }
          if (!simple)
            continue;
          // Inline by cloning body ops at call site.
          OpBuilder rewriter(module.getContext());
          rewriter.setInsertionPoint(call);
          IRMapping map;
          // Map callee block arguments to call operands.
          for (auto [arg, operand] : llvm::zip(body.getArguments(), call.getOperands()))
            map.map(arg, operand);
          Value retValue;
          for (Operation &inner : body) {
            if (auto ret = dyn_cast<func::ReturnOp>(&inner)) {
              if (ret.getNumOperands() == 1)
                retValue = map.lookupOrNull(ret.getOperand(0));
              break;
            }
            Operation *cloned = rewriter.clone(inner, map);
            for (auto [oldRes, newRes] : llvm::zip(inner.getResults(), cloned->getResults()))
              map.map(oldRes, newRes);
          }
          if (retValue) {
            call.getResult(0).replaceAllUsesWith(retValue);
            call.erase();
          }
        }
      }
      // Canonicalize after local inlining.
      PassManager pm2(op->getContext());
      pm2.enableVerifier(false);
      pm2.addPass(mlir::createCanonicalizerPass());
      if (failed(pm2.run(op))) {
        signalPassFailure();
      }
    }

    // Phase 2: (removed) specialization extracted to cal-param-specialize pass.

    // Phase 2b: (optional) Inline networks when explicitly enabled.
    // Keep disabled by default to prefer symbolic specialization in Stage 1.
  bool useNetworkInline = this->enableNetworkInline ||
              (std::getenv("CAL_ENABLE_NETWORK_INLINE") != nullptr);
    if (useNetworkInline) {
      if (auto module = dyn_cast<ModuleOp>(op)) {
        SymbolTable symTable(module);
        bool changed = true;
        unsigned guard = 0, guardMax = 4;
        while (changed && guard++ < guardMax) {
          changed = false;
          SmallVector<cal::InstantiateOp, 16> insts;
          module.walk([&](cal::InstantiateOp inst) {
            if (!inst->getParentOfType<cal::NetworkOp>()) return;
            bool allConst = llvm::all_of(inst.getOperands(), [](Value v){
              return v.getDefiningOp<arith::ConstantOp>() != nullptr;
            });
            if (!allConst) return;
            auto target = symTable.lookupNearestSymbolFrom<cal::NetworkOp>(inst, inst.getActorRefAttr());
            if (!target) return;
            insts.push_back(inst);
          });
          for (cal::InstantiateOp inst : insts) {
            auto target = symTable.lookupNearestSymbolFrom<cal::NetworkOp>(inst, inst.getActorRefAttr());
            if (!target) continue;
            IRMapping map;
            auto formalArgs = target.getBody().getArguments();
            auto actuals = inst.getOperands();
            if (formalArgs.size() != actuals.size()) continue;
            for (auto it : llvm::zip(formalArgs, actuals))
              map.map(std::get<0>(it), std::get<1>(it));
            Block &body = target.getBody().front();
            IRRewriter rewriter(module.getContext());
            rewriter.setInsertionPoint(inst);
            for (Operation &inner : body.getOperations()) {
              if (isa<cal::NetworkOp>(&inner) || isa<cal::ActorOp>(&inner)) continue;
              Operation *cloned = rewriter.clone(inner, map);
              for (auto [oldRes, newRes] : llvm::zip(inner.getResults(), cloned->getResults()))
                map.map(oldRes, newRes);
            }
            inst.erase();
            changed = true;
          }
          if (changed) {
            PassManager pm3(op->getContext());
            pm3.enableVerifier(false);
            pm3.addPass(mlir::createCanonicalizerPass());
            (void)pm3.run(op);
          }
        }
      }
    }


    // Phase 3b: JIT-only const-eval. Replace the prior interpreter with a
    // single, guarded JIT attempt for helper calls with constant operands.
    // Memoized per (callee, signed args) to avoid duplicate work.
    {
      if (auto module = dyn_cast<ModuleOp>(op)) {
        SymbolTable symTable(module);
        auto getBitWidth = [&](Type ty) -> unsigned {
          if (auto it = dyn_cast<IntegerType>(ty)) return it.getWidth();
          if (auto idx = dyn_cast<IndexType>(ty)) return 64; // default to host index width
          return 64;
        };
        // Scan for calls anywhere in the module with all constant operands; fold via JIT when possible.
  SmallVector<func::CallOp, 16> calls;
  module.walk([&](func::CallOp call){ calls.push_back(call); });
        for (func::CallOp call : calls) {
          // Only fold when the call's operands can be reduced to constants now.
          SmallVector<llvm::APInt, 4> cargs;
          cargs.reserve(call.getNumOperands());
          bool allConst = true;
          for (Value a : call.getArgOperands()) {
            llvm::APInt av;
            if (auto c = a.getDefiningOp<arith::ConstantOp>()) {
              if (auto ia = dyn_cast<IntegerAttr>(c.getValue())) {
                av = ia.getValue();
              } else {
                allConst = false; break;
              }
            } else if (a.getDefiningOp()) {
              // Try quick local evaluator used earlier for pow2 folding.
              // Reuse a minimal subset: constant/select/cmpi/addi/subi/muli/index_cast.
              std::function<std::optional<int64_t>(Value)> quick;
              quick = [&](Value v) -> std::optional<int64_t> {
                if (auto kc = v.getDefiningOp<arith::ConstantOp>())
                  if (auto ia = dyn_cast<IntegerAttr>(kc.getValue())) return ia.getInt();
                if (auto ic = v.getDefiningOp<arith::IndexCastOp>()) { auto x = quick(ic.getIn()); if (x) return *x; }
                if (auto ai = v.getDefiningOp<arith::AddIOp>()) { auto A = quick(ai.getLhs()); auto B = quick(ai.getRhs()); if (A && B) return *A + *B; }
                if (auto si = v.getDefiningOp<arith::SubIOp>()) { auto A = quick(si.getLhs()); auto B = quick(si.getRhs()); if (A && B) return *A - *B; }
                if (auto mi = v.getDefiningOp<arith::MulIOp>()) { auto A = quick(mi.getLhs()); auto B = quick(mi.getRhs()); if (A && B) return (*A) * (*B); }
                if (auto cmp = v.getDefiningOp<arith::CmpIOp>()) { auto A = quick(cmp.getLhs()); auto B = quick(cmp.getRhs()); if (A && B) return arith::CmpIPredicate::eq == cmp.getPredicate() ? (*A == *B) : 0; }
                if (auto sel = v.getDefiningOp<arith::SelectOp>()) {
                  auto C = quick(sel.getCondition()); if (!C) return std::nullopt; return *C ? quick(sel.getTrueValue()) : quick(sel.getFalseValue());
                }
                return std::nullopt;
              };
              auto vOpt = quick(a);
              if (!vOpt) { allConst = false; break; }
              unsigned bw = getBitWidth(a.getType());
              av = llvm::APInt(bw, *vOpt, true);
            } else {
              allConst = false; break;
            }
            cargs.push_back(av);
          }
          if (!allConst) continue;

          func::FuncOp callee = symTable.lookup<func::FuncOp>(call.getCallee());
          if (!callee) continue;
          // JIT evaluate always (memoized), replacing the prior interpreter.
          std::optional<llvm::APInt> res;
          llvm::SmallString<128> key;
          key += callee.getSymName(); key += '#';
          for (auto &a : cargs) { key += llvm::Twine(a.getSExtValue()).str(); key += ','; }
          auto itMemo = this->jitConstMemo.find(key.str());
          if (itMemo != this->jitConstMemo.end()) {
            res = itMemo->second;
          } else {
            auto j = this->tryJitConstEval(callee, cargs, /*budget*/ 1000);
            if (j) { this->jitConstMemo.try_emplace(key.str(), *j); res = j; }
          }
          if (!res) continue;

          // Replace call with a constant of the correct result type.
          OpBuilder rewriter(module.getContext());
          rewriter.setInsertionPoint(call);
          Type rt = call.getResult(0).getType();
          if (auto ft = dyn_cast<FloatType>(rt)) {
            // Build APFloat from raw APInt bits returned by JIT.
            unsigned fbits = ft.getWidth();
            llvm::APInt bits = res->sextOrTrunc(fbits);
            const llvm::fltSemantics &sem = (fbits == 32)
                                              ? llvm::APFloat::IEEEsingle()
                                              : (fbits == 64 ? llvm::APFloat::IEEEdouble()
                                                             : llvm::APFloat::IEEEsingle()); // default guard
            llvm::APFloat fp(sem, bits);
            auto attr = FloatAttr::get(rt, fp);
            auto cst = rewriter.create<arith::ConstantOp>(call.getLoc(), attr);
            call.getResult(0).replaceAllUsesWith(cst.getResult());
          } else {
            unsigned bw = getBitWidth(rt);
            auto cst = rewriter.create<arith::ConstantIntOp>(call.getLoc(), res->sextOrTrunc(bw).getSExtValue(), bw);
            call.getResult(0).replaceAllUsesWith(cst.getResult());
          }
          call.erase();
        }
      }
    }


    // Phase 4: Lightweight pruning of unreachable CAL symbols. Identify a
    // single top cal.network (explicit via option `top`, or auto-detected as
    // the only network not referenced by any instantiate). If multiple tops
    // exist and no explicit top is provided, emit a diagnostic and fail. When
    // a top is known, drop any cal.network or cal.actor not reachable from it
    // by following cal.instantiate edges (only network->network edges are
    // traversed for reachability; actors are retained iff referenced by any
    // reachable network).
    if (this->enablePruneUnused) {
      if (auto module = dyn_cast<ModuleOp>(op)) {
        SymbolTable symTable(module);
        // Gather all networks and track which are referenced by instantiate.
        llvm::SmallVector<cal::NetworkOp, 16> allNets;
        llvm::DenseSet<StringAttr> referencedNetNames;
        module.walk([&](cal::NetworkOp net){ allNets.push_back(net); });
        module.walk([&](cal::InstantiateOp inst){
          if (auto net = symTable.lookupNearestSymbolFrom<cal::NetworkOp>(inst, inst.getActorRefAttr()))
            referencedNetNames.insert(net.getSymNameAttr());
        });

        // Pick top.
        cal::NetworkOp topNet;
        if (!this->topNetwork.empty()) {
          auto nameAttr = StringAttr::get(module.getContext(), this->topNetwork);
          if (auto sym = symTable.lookup<cal::NetworkOp>(nameAttr)) {
            topNet = sym;
          } else {
            module.emitError() << "cal-const-eval: --top='" << this->topNetwork
                               << "' not found (no such cal.network symbol).";
            signalPassFailure();
            return;
          }
        } else {
          // Auto-detect: networks not present in referencedNetNames are candidates.
          llvm::SmallVector<cal::NetworkOp, 8> candidates;
          for (auto net : allNets) {
            if (!referencedNetNames.contains(net.getSymNameAttr()))
              candidates.push_back(net);
          }
          if (candidates.size() == 1) {
            topNet = candidates.front();
          } else {
            // If zero or multiple candidates, print a helpful diagnostic and bail.
            llvm::SmallVector<StringRef, 8> names;
            if (candidates.empty()) {
              for (auto net : allNets) names.push_back(net.getSymName());
            } else {
              for (auto net : candidates) names.push_back(net.getSymName());
            }
            llvm::SmallString<256> msg;
            llvm::raw_svector_ostream os(msg);
            os << "cal-const-eval: unable to auto-detect a unique top cal.network. ";
            if (candidates.empty())
              os << "(no unreferenced network found)";
            else
              os << candidates.size() << " candidates";
            os << "; please pass --cal-const-eval='top=<symbolName>'. Candidates: ";
            for (size_t i = 0; i < names.size(); ++i) {
              os << names[i]; if (i + 1 < names.size()) os << ", ";
            }
            module.emitError(os.str());
            signalPassFailure();
            return;
          }
        }

        if (!topNet)
          return; // nothing to prune

        // Compute reachable networks by DFS from top via instantiate->network edges.
        llvm::DenseSet<StringAttr> reachableNetNames;
        llvm::SmallVector<cal::NetworkOp, 16> worklist;
        worklist.push_back(topNet);
        reachableNetNames.insert(topNet.getSymNameAttr());
        while (!worklist.empty()) {
          cal::NetworkOp cur = worklist.back(); worklist.pop_back();
          cur.walk([&](cal::InstantiateOp inst){
            if (auto n = symTable.lookupNearestSymbolFrom<cal::NetworkOp>(inst, inst.getActorRefAttr())) {
              if (reachableNetNames.insert(n.getSymNameAttr()).second)
                worklist.push_back(n);
            }
          });
        }

        // Compute actors referenced by reachable networks.
        // Consider both symbolic cal.instantiate (pre-elaboration) and
        // concrete cal.create_instance (post-elaboration) users.
        llvm::DenseSet<StringAttr> reachableActorNames;
        for (auto net : allNets) {
          if (!reachableNetNames.contains(net.getSymNameAttr())) continue;
          // Symbolic instantiation (handles arrays, ND before elaboration).
          net.walk([&](cal::InstantiateOp inst){
            if (auto a = symTable.lookupNearestSymbolFrom<cal::ActorOp>(inst, inst.getActorRefAttr()))
              reachableActorNames.insert(a.getSymNameAttr());
          });
          // Concrete instantiation after connect lowering / elaboration.
          net.walk([&](cal::CreateInstanceOp ci){
            if (auto a = symTable.lookupNearestSymbolFrom<cal::ActorOp>(ci, ci.getActorRefAttr()))
              reachableActorNames.insert(a.getSymNameAttr());
          });
        }

        // Erase unreachable networks.
        llvm::SmallVector<Operation*, 16> eraseList;
        for (auto net : allNets) {
          if (!reachableNetNames.contains(net.getSymNameAttr()))
            eraseList.push_back(net);
        }
        // Also collect unreachable actors.
        module.walk([&](cal::ActorOp act){
          if (!reachableActorNames.contains(act.getSymNameAttr()))
            eraseList.push_back(act);
        });
        for (Operation *dead : eraseList)
          dead->erase();
      }
    }

    // Phase 5: Late function DCE for unused helper functions (e.g., pow2).
    // Build a call graph among func.func and mark functions as 'kept' if they
    // are referenced by any call site outside of their own body (e.g., calls
    // made from cal.network regions or from other functions). Self-recursive
    // functions with no external callers are removed. Reachability from any
    // externally referenced function is also retained.
    if (auto module2 = dyn_cast<ModuleOp>(op)) {
      // Map function symbols to ops.
      llvm::DenseMap<StringAttr, func::FuncOp> funcs;
      module2.walk([&](func::FuncOp f) { funcs.insert({f.getSymNameAttr(), f}); });

      // Build call edges and collect external roots (calls from outside any func.func).
      llvm::DenseMap<StringAttr, llvm::SmallVector<StringAttr, 4>> edges;
      llvm::DenseSet<StringAttr> keep; // roots and reachable callees
      module2.walk([&](func::CallOp call) {
        auto calleeAttr = call.getCalleeAttr();
        if (!calleeAttr)
          return;
        auto callerFn = call->getParentOfType<func::FuncOp>();
        if (!callerFn) {
          // Called from a non-function context (e.g., cal.network) => external root
          keep.insert(calleeAttr.getAttr());
        } else {
          // Record edge caller -> callee
          edges[callerFn.getSymNameAttr()].push_back(calleeAttr.getAttr());
        }
      });

      // Propagate reachability through the call graph.
      llvm::SmallVector<StringAttr, 16> worklist;
      for (auto k : keep)
        worklist.push_back(k);
      while (!worklist.empty()) {
        StringAttr cur = worklist.back();
        worklist.pop_back();
        auto it = edges.find(cur);
        if (it == edges.end())
          continue;
        for (StringAttr callee : it->second) {
          if (keep.insert(callee).second)
            worklist.push_back(callee);
        }
      }

      // Erase any function not reachable from external roots.
      llvm::SmallVector<func::FuncOp, 16> toErase;
      for (auto &kv : funcs) {
        StringAttr name = kv.first;
        func::FuncOp f = kv.second;
        if (!keep.contains(name))
          toErase.push_back(f);
      }
      for (func::FuncOp f : toErase)
        f.erase();
    }
  }
};

// JIT const-eval scaffold implementation: currently returns nullopt.
// Future implementation will:
//  1. Create a scratch ModuleOp with a cloned version of `callee` where
//     arguments are replaced by constants.
//  2. Run a small pipeline: SCFToControlFlow, ArithToLLVM, FuncToLLVM,
//     Canonicalize, and finalize to LLVM dialect.
//  3. Create an ExecutionEngine and invoke the lowered function to obtain
//     the integer result, honoring `budget` for early bailout.
//  4. Return llvm::APInt of the computed value or nullopt on failure.
std::optional<llvm::APInt> CalConstEvalPass::tryJitConstEval(
    func::FuncOp callee, ArrayRef<llvm::APInt> args, unsigned budget) {
  using Clock = std::chrono::steady_clock;
  const auto t0 = Clock::now();
  auto getAllowedMillis = [&]() -> uint64_t {
    if (const char *env = std::getenv("CAL_JIT_TIME_MS")) {
      char *end = nullptr;
      long v = std::strtol(env, &end, 10);
      if (end != env && v > 0)
        return static_cast<uint64_t>(v);
    }
    // Default time limit; small to avoid long stalls in optimization pipeline.
    return 100ULL; // 100ms
  };
  const uint64_t timeLimitMs = getAllowedMillis();
  auto expired = [&]() -> bool {
    auto dt = std::chrono::duration_cast<std::chrono::milliseconds>(Clock::now() - t0);
    return static_cast<uint64_t>(dt.count()) > timeLimitMs;
  };

  // Basic guards.
  if (!callee || !callee.getBody().hasOneBlock()) return std::nullopt;
  auto fTy = callee.getFunctionType();
  if (fTy.getNumResults() != 1) return std::nullopt;
  Type resTy = fTy.getResult(0);
  auto resIntTy = dyn_cast<IntegerType>(resTy);
  auto resFltTy = dyn_cast<FloatType>(resTy);
  bool isFloatResult = static_cast<bool>(resFltTy);
  if (!resIntTy && !isFloatResult) return std::nullopt; // support only int/index and float scalars for now
  if (fTy.getNumInputs() != args.size()) return std::nullopt;
  // Simple budget guards: bound args and ops.
  if (args.size() > 8) return std::nullopt;
  // Operation budget: count operations recursively in the callee.
  unsigned opBudget = budget ? budget : 1000;
  unsigned opCount = 0;
  callee.walk([&](Operation *op){ ++opCount; return opCount > opBudget ? WalkResult::interrupt() : WalkResult::advance(); });
  if (opCount > opBudget) return std::nullopt;
  if (expired()) return std::nullopt;

  // Recursion guard for JIT path: bail out on self-recursive functions unless explicitly allowed.
  bool selfRecursive = false;
  callee.walk([&](func::CallOp c){ if (c.getCallee() == callee.getSymName()) { selfRecursive = true; return WalkResult::interrupt(); } return WalkResult::advance(); });
  if (selfRecursive && std::getenv("CAL_JIT_ALLOW_RECURSION") == nullptr) return std::nullopt;

  // Dialect whitelist: only arith, func, scf, cf, builtin.
  {
  // Use a SmallVector of StringRef for whitelist; simple linear search is fine (tiny set).
  llvm::SmallVector<StringRef, 8> allowed = {
    "arith", "func", "scf", "cf", "builtin"};
    bool bad = false;
    callee.walk([&](Operation *op) {
      Dialect *d = op->getDialect();
      StringRef ns = d ? d->getNamespace() : StringRef("builtin");
  bool ok = llvm::any_of(allowed, [&](StringRef a){ return a == ns; });
  if (!ok) {
        bad = true;
        return WalkResult::interrupt();
      }
      return WalkResult::advance();
    });
    if (bad)
      return std::nullopt;
  }

  // Build a separate single-threaded context with a minimal registry of
  // required dialects to avoid loading during the pass pipeline.
  DialectRegistry reg;
  reg.insert<arith::ArithDialect, func::FuncDialect, scf::SCFDialect,
             cf::ControlFlowDialect, mlir::LLVM::LLVMDialect>();
  // Register LLVM translation interfaces so ExecutionEngine can translate to LLVM IR.
  registerBuiltinDialectTranslation(reg);
  registerLLVMDialectTranslation(reg);
  auto jitCtx = std::make_unique<MLIRContext>(reg);
  jitCtx->disableMultithreading();
  MLIRContext *ctx = jitCtx.get();
  // Eagerly load the required dialects into this context.
  (void)ctx->loadDialect<func::FuncDialect>();
  (void)ctx->loadDialect<arith::ArithDialect>();
  (void)ctx->loadDialect<scf::SCFDialect>();
  (void)ctx->loadDialect<cf::ControlFlowDialect>();
  (void)ctx->loadDialect<mlir::LLVM::LLVMDialect>();
  OpBuilder ob(ctx);
  auto scratch = ModuleOp::create(UnknownLoc::get(ctx));

  // Clone the callee into scratch as-is.
  IRMapping map;
  auto cloned = cast<func::FuncOp>(ob.clone(*callee, map));
  scratch.push_back(cloned);
  // Make it private to avoid symbol collisions.
  // Make symbol private if API available; fallback to setting visibility attr manually.
  cloned->setAttr("sym_visibility", StringAttr::get(ctx, "private"));

  // Create wrapper:
  //  - Integer path: func @__jit_entry() -> i64 { %c = call @cloned(...); %r64 = ext/trunc to i64; return %r64 }
  //  - Float path:   func @__jit_entry() -> f32|f64 { %c = call @cloned(...); return %c }
  auto i64Ty = ob.getI64Type();
  Type wrapRetTy = isFloatResult ? Type(resFltTy) : Type(i64Ty);
  auto wrapTy = FunctionType::get(ctx, {}, {wrapRetTy});
  auto wrap = func::FuncOp::create(UnknownLoc::get(ctx), "__jit_entry", wrapTy);
  scratch.push_back(wrap);
  Block *entry = wrap.addEntryBlock();
  ob.setInsertionPointToStart(entry);
  SmallVector<Value, 8> callArgs;
  callArgs.reserve(args.size());
  for (auto it : llvm::enumerate(fTy.getInputs())) {
    Type at = it.value();
    const llvm::APInt &av = args[it.index()];
    if (auto itInt = dyn_cast<IntegerType>(at)) {
      // Create integer constant with the callee's bitwidth.
      auto c = ob.create<arith::ConstantIntOp>(wrap.getLoc(), av.sextOrTrunc(itInt.getWidth()).getSExtValue(), itInt.getWidth());
      callArgs.push_back(c.getResult());
    } else if (isa<IndexType>(at)) {
      // Index constant.
      auto c = ob.create<arith::ConstantIndexOp>(wrap.getLoc(), av.getSExtValue());
      callArgs.push_back(c.getResult());
    } else {
      return std::nullopt; // unsupported arg type
    }
  }
  auto calleeRef = FlatSymbolRefAttr::get(cloned.getSymNameAttr());
  // Build the call with the original result type.
  auto call = ob.create<func::CallOp>(wrap.getLoc(), calleeRef, TypeRange{resTy}, callArgs);
  Value resV = call.getResult(0);
  if (isFloatResult) {
    // Float path: return value directly.
    ob.create<func::ReturnOp>(wrap.getLoc(), ValueRange{resV});
  } else {
    // Integer path: extend/truncate to i64 for a simple C ABI to call from the JIT.
    Value res64;
    if (resIntTy.getWidth() == 64) {
      res64 = resV;
    } else if (resIntTy.getWidth() < 64) {
      res64 = ob.create<arith::ExtSIOp>(wrap.getLoc(), i64Ty, resV);
    } else {
      res64 = ob.create<arith::TruncIOp>(wrap.getLoc(), i64Ty, resV);
    }
    ob.create<func::ReturnOp>(wrap.getLoc(), ValueRange{res64});
  }

  // Pre-lowering size watchdog on the scratch module (wrapper + cloned callee).
  unsigned scratchOps = 0;
  scratch.walk([&](Operation *op){ ++scratchOps; });
  if (scratchOps > opBudget * 4u) return std::nullopt;
  if (expired()) return std::nullopt;

  // Lower to LLVM dialect.
  PassManager pm(ctx);
  pm.enableVerifier(false);
  // Canonicalize before conversions.
  pm.addPass(createCanonicalizerPass());
  // Convert SCF to CF so later LLVM conversion can proceed.
  pm.addPass(createConvertSCFToCFPass());
  // Perform another canonicalize+CSE to clean up.
  pm.addPass(createCanonicalizerPass());
  pm.addPass(createCSEPass());
  // Convert all dialects to LLVM using proper pass creation functions
  pm.addPass(createArithToLLVMConversionPass());
  pm.addPass(createConvertControlFlowToLLVMPass());
  // Convert Func to LLVM (explicit instead of generic ConvertToLLVM to avoid
  // relying on dialect extension interfaces).
  pm.addPass(createConvertFuncToLLVMPass());
  // Reconcile unrealized casts that may be left over
  pm.addPass(createReconcileUnrealizedCastsPass());
  // One more canonicalize to fold trivial patterns post-conversion.
  pm.addPass(createCanonicalizerPass());
  if (failed(pm.run(scratch))) return std::nullopt;

  // Post-lowering size watchdog; LLVM form may expand IR.
  unsigned loweredOps = 0;
  scratch.walk([&](Operation *op){ ++loweredOps; });
  if (loweredOps > opBudget * 16u) return std::nullopt;
  if (expired()) return std::nullopt;

  // JIT compile and invoke.
  // Create ExecutionEngine bound to the JIT context. Avoid symbol registry
  // mutations in the main process context.
  ExecutionEngineOptions eeOpts;
  eeOpts.transformer = nullptr; // default
  auto expectedEngine = ExecutionEngine::create(scratch, eeOpts);
  if (!expectedEngine) {
    // Consume the error to avoid assertion failure.
    llvm::consumeError(expectedEngine.takeError());
    return std::nullopt;
  }
  std::unique_ptr<ExecutionEngine> engine = std::move(*expectedEngine);
  auto symOr = engine->lookup("__jit_entry");
  if (!symOr) {
    llvm::consumeError(symOr.takeError());
    return std::nullopt;
  }
  void *addr = *symOr; // llvm::Expected unwrap
  // Invoke with a type-appropriate function pointer and convert to APInt bits.
  if (isFloatResult) {
    unsigned fbits = resFltTy.getWidth();
    if (fbits == 32) {
      using EntryFnF32 = float (*)();
      auto fn = reinterpret_cast<EntryFnF32>(addr);
      if (!fn) return std::nullopt;
      float rv = fn();
      uint32_t bits;
      std::memcpy(&bits, &rv, sizeof(bits));
      return llvm::APInt(32, static_cast<uint64_t>(bits));
    } else if (fbits == 64) {
      using EntryFnF64 = double (*)();
      auto fn = reinterpret_cast<EntryFnF64>(addr);
      if (!fn) return std::nullopt;
      double rv = fn();
      uint64_t bits;
      std::memcpy(&bits, &rv, sizeof(bits));
      return llvm::APInt(64, bits);
    } else {
      // Unsupported float width in this minimal implementation (e.g., f16/bf16/f80)
      return std::nullopt;
    }
  } else {
    using EntryFnI64 = int64_t (*)();
    auto fn = reinterpret_cast<EntryFnI64>(addr);
    if (!fn) return std::nullopt;
    // TODO: In future, enforce wall-clock timeout using a watchdog if needed.
    int64_t rv = fn();
    // Convert back to original result bitwidth.
    unsigned bw = resIntTy.getWidth();
    llvm::APInt ap(64, static_cast<uint64_t>(rv), true);
    return ap.sextOrTrunc(bw);
  }
}
} // namespace

} // namespace mlir

std::unique_ptr<mlir::Pass> mlir::createCalConstEvalPass() {
  return std::make_unique<mlir::CalConstEvalPass>();
}
