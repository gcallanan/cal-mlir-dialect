#include <memory>

#include "Dialect/Cal/CalDialect.h"
#include "Dialect/Cal/CalOps.h"
#include "Dialect/Cal/CalPasses.h"
#include "Dialect/Fifo/FifoDialect.h"
#include "mlir/Dialect/Arith/IR/Arith.h"
#include "mlir/Dialect/Func/IR/FuncOps.h"
#include "mlir/Dialect/SCF/IR/SCF.h"
#include "mlir/IR/IRMapping.h"
#include "mlir/IR/PatternMatch.h"
#include "mlir/Pass/Pass.h"

namespace mlir {
namespace cal {

#define GEN_PASS_DEF_LOWERCALFSMTOEXECUTIONBODY
#include "Dialect/Cal/CalPasses.h.inc"

// Minimal skeleton: detect actors with cal.fsm and create a placeholder
// cal.execution_body that currently yields false (no action fired). This is a
// scaffolding step; full lowering will follow by selecting transitions and
// inlining the referenced cal.action bodies.
class LowerCalFsmToExecutionBodyPass
    : public impl::LowerCalFsmToExecutionBodyBase<LowerCalFsmToExecutionBodyPass> {
public:
  void runOnOperation() final {
    Operation *op = getOperation();
    bool changed = false;

    op->walk([&](cal::ActorOp actor) {
      // Find an FSM within this actor.
      cal::FsmOp fsm = nullptr;
      for (Operation &inner : actor.getBody().front()) {
        if (auto st = dyn_cast<cal::FsmOp>(&inner)) {
          fsm = st;
          break;
        }
      }
      if (!fsm)
        return WalkResult::advance();

      // Enforce mutual exclusivity at this stage: no existing execution_body.
      for (Operation &inner : actor.getBody().front()) {
        if (isa<cal::ExecutionBody>(inner)) {
          actor.emitError("actor contains both cal.fsm and cal.execution_body; invalid combination");
          signalPassFailure();
          return WalkResult::interrupt();
        }
      }

      IRRewriter rewriter(actor.getContext());
      Location loc = actor.getLoc();

      // Build maps:
      //  - actionName -> cal.action op
      //  - actionName -> priority (int, default 0)
      llvm::StringMap<cal::ActionOp> actionsByName;
      llvm::StringMap<int> priorityByName;
      for (Operation &inner : actor.getBody().front()) {
        if (auto action = dyn_cast<cal::ActionOp>(&inner)) {
          if (auto nameAttr = action.getActionNameAttr()) {
            auto name = nameAttr.getValue();
            actionsByName.try_emplace(name, action);
            // Read priority robustly via the generated accessor; defaults to 0.
            int pri = 0;
            if (auto p = action.getPriority()) pri = static_cast<int>(*p);
            priorityByName[name] = pri;
          } else {
            action.emitError("cal.action used by FSM must have an explicit name");
            signalPassFailure();
            return WalkResult::interrupt();
          }
        }
      }

      // Collect states in textual order, assign indices, and find the initial state.
      SmallVector<cal::StateOp> states;
      int64_t initialIndex = -1;
      for (Operation &inner : fsm.getBody().front()) {
        if (auto st = dyn_cast<cal::StateOp>(&inner)) {
          int64_t idx = static_cast<int64_t>(states.size());
          if (st.getInitial().has_value())
            initialIndex = idx;
          states.push_back(st);
        }
      }
      if (states.empty()) {
        fsm.emitError("cal.fsm must contain at least one cal.state");
        signalPassFailure();
        return WalkResult::interrupt();
      }
      if (initialIndex < 0) {
        fsm.emitError("cal.fsm must have exactly one initial cal.state");
        signalPassFailure();
        return WalkResult::interrupt();
      }

  // Create an i32 state variable to hold the current FSM state.
  rewriter.setInsertionPoint(fsm);
  auto i32Ty = rewriter.getI32Type();
  auto stateRefTy = cal::StateVarRefType::get(i32Ty.getContext(), i32Ty);
  auto stateVar = rewriter.create<cal::CreateStateVarOp>(loc, stateRefTy, TypeAttr::get(i32Ty));
  // Initialize it to the initial state index.
  auto initIdx = rewriter.create<arith::ConstantIntOp>(loc, initialIndex, 32);
  auto initSet = rewriter.create<cal::StateSetOp>(loc, initIdx.getResult(), stateVar.getResult());

  // Create the execution body after the initializer (to preserve dominance
  // and enable hoisting passes to lift both decl and init together).
  rewriter.setInsertionPointAfter(initSet);
      auto exec = rewriter.create<cal::ExecutionBody>(loc);
      auto *eb = new Block();
      exec.getBody().push_back(eb);
      rewriter.setInsertionPointToStart(eb);

      // Load current state.
  auto curState = rewriter.create<cal::StateGetOp>(loc, i32Ty, stateVar.getResult());

      // Accumulate whether any action fired.
      Value anyFired = rewriter.create<arith::ConstantOp>(loc, rewriter.getBoolAttr(false));
      Value nextStateVal = curState.getResult(); // default: remain in same state

      // Helper lambdas to build constants and compare state.
      auto constI32 = [&](int64_t v) {
        return rewriter.create<arith::ConstantIntOp>(loc, v, 32).getResult();
      };

      // For each state, generate an if-then chain guarded by curState == idx.
      for (int64_t sIdx = 0; sIdx < (int64_t)states.size(); ++sIdx) {
        auto cmp = rewriter.create<arith::CmpIOp>(loc, arith::CmpIPredicate::eq, curState.getResult(), constI32(sIdx));
        // Body of this state's block.
        auto stateIf = rewriter.create<scf::IfOp>(loc, TypeRange{rewriter.getI1Type(), i32Ty}, cmp, /*withElseRegion=*/true);
        // then block
        {
          OpBuilder::InsertionGuard g(rewriter);
          rewriter.setInsertionPointToStart(stateIf.thenBlock());

          // Track if one transition was taken in this state (to enforce priority order).
          Value taken = rewriter.create<arith::ConstantOp>(loc, rewriter.getBoolAttr(false));
          Value localNext = constI32(sIdx);

          // Collect transitions and sort by action priority (desc), breaking ties by textual order.
          SmallVector<cal::TransitionOp> transitions;
          if (!states[sIdx].getBody().empty()) {
            for (Operation &opTr : states[sIdx].getBody().front()) {
              if (auto tr = dyn_cast<cal::TransitionOp>(&opTr))
                transitions.push_back(tr);
            }
          }
          // Stable sort keeps textual order within equal priorities.
          std::stable_sort(transitions.begin(), transitions.end(), [&](cal::TransitionOp a, cal::TransitionOp b) {
            // Missing action names will be diagnosed later; treat their priority as 0.
            int pa = 0, pb = 0;
            if (auto itA = priorityByName.find(a.getActionName()); itA != priorityByName.end())
              pa = itA->second;
            if (auto itB = priorityByName.find(b.getActionName()); itB != priorityByName.end())
              pb = itB->second;
            return pa > pb; // higher first
          });

          for (cal::TransitionOp tr : transitions) {

            // Lookup action
            StringRef actName = tr.getActionName();
            auto it = actionsByName.find(actName);
            if (it == actionsByName.end()) {
              tr.emitError("transition references unknown action '") << actName << "'";
              signalPassFailure();
              return WalkResult::interrupt();
            }
            cal::ActionOp action = it->second;

            // Compute the predicate: AND over each cal.predicate's result; default true if none.
            Value predValue = nullptr;
            for (Operation &inner : action.getBody().front()) {
              if (auto pred = dyn_cast<cal::Predicate>(&inner)) {
                // Clone predicate region ops here.
                IRMapping map; // no args to map; actor block args are not used inside predicate typically
                // Clone all ops inside predicate's region and capture the predicate_result value.
                Value localRes = nullptr;
                for (Operation &pOp : pred.getBody().front()) {
                  if (auto res = dyn_cast<cal::PredicateResultOp>(&pOp)) {
                    // Map lookup or default: the operand should be cloned earlier if it was defined here
                    Value v = map.lookupOrNull(res.getEvaluationResult());
                    if (!v)
                      v = res.getEvaluationResult();
                    localRes = v;
                  } else {
                    Operation *cl = rewriter.clone(pOp, map);
                    for (auto [orig, neu] : llvm::zip(pOp.getResults(), cl->getResults()))
                      map.map(orig, neu);
                  }
                }
                if (!localRes) {
                  pred.emitError("predicate region missing cal.predicate_result");
                  signalPassFailure();
                  return WalkResult::interrupt();
                }
                if (!predValue)
                  predValue = localRes;
                else
                  predValue = rewriter.create<arith::AndIOp>(loc, predValue, localRes).getResult();
              }
            }
            if (!predValue)
              predValue = rewriter.create<arith::ConstantOp>(loc, rewriter.getBoolAttr(true)).getResult();

            // Guard with !taken && predicate
            auto notTaken = rewriter.create<arith::XOrIOp>(loc, taken, rewriter.create<arith::ConstantOp>(loc, rewriter.getBoolAttr(true)));
            auto guard = rewriter.create<arith::AndIOp>(loc, notTaken, predValue);

            // If guard true, inline action body (excluding cal.predicate) and set taken=true, localNext=target
            auto ifDo = rewriter.create<scf::IfOp>(loc, TypeRange{rewriter.getI1Type(), i32Ty}, guard, /*withElseRegion=*/true);
            // then:
            {
              OpBuilder::InsertionGuard g2(rewriter);
              rewriter.setInsertionPointToStart(ifDo.thenBlock());
              IRMapping mapAct;
              for (Operation &aOp : action.getBody().front()) {
                if (isa<cal::Predicate>(aOp))
                  continue; // already handled as predicates
                if (isa<cal::ActionDoneOp>(aOp))
                  continue;
                Operation *cl = rewriter.clone(aOp, mapAct);
                for (auto [orig, neu] : llvm::zip(aOp.getResults(), cl->getResults()))
                  mapAct.map(orig, neu);
              }
              // Update taken and localNext
              auto tTrue = rewriter.create<arith::ConstantOp>(loc, rewriter.getBoolAttr(true));
              // Find target state index
              int64_t tgtIdx = -1;
              // Resolve target symbol position among states
              for (int64_t j = 0; j < (int64_t)states.size(); ++j) {
                StringRef targetName;
                if (auto sref = tr.getTargetAttr()) targetName = sref.getValue();
                else targetName = tr.getTarget();
                if (states[j].getSymName() == targetName) { tgtIdx = j; break; }
              }
              if (tgtIdx < 0) {
                tr.emitError("failed to resolve target state index");
                signalPassFailure();
                return WalkResult::interrupt();
              }
              Value outTaken = tTrue.getResult();
              Value outNext = constI32(tgtIdx);
              rewriter.create<scf::YieldOp>(loc, ValueRange{outTaken, outNext});
            }
            // else: yield existing taken/localNext
            {
              OpBuilder::InsertionGuard g2(rewriter);
              rewriter.setInsertionPointToStart(ifDo.elseBlock());
              rewriter.create<scf::YieldOp>(loc, ValueRange{taken, localNext});
            }

            // Update taken/localNext from if results
            taken = ifDo.getResult(0);
            localNext = ifDo.getResult(1);
          }

          // Yield results to stateIf: fired? and next state index.
          rewriter.create<scf::YieldOp>(loc, ValueRange{taken, localNext});
        }
        // else block: propagate anyFired/nextState untouched
        {
          OpBuilder::InsertionGuard g(rewriter);
          rewriter.setInsertionPointToStart(stateIf.elseBlock());
          rewriter.create<scf::YieldOp>(loc, ValueRange{anyFired, nextStateVal});
        }

        // Update accumulators with stateIf results.
        anyFired = stateIf.getResult(0);
        nextStateVal = stateIf.getResult(1);
      }

      // Commit next state and finish execution body.
  rewriter.create<cal::StateSetOp>(loc, nextStateVal, stateVar.getResult());
      rewriter.create<cal::ActionDoneOp>(loc, anyFired);

      // Remove the FSM and any remaining cal.action ops.
      rewriter.eraseOp(fsm);
      SmallVector<Operation*> toErase;
      for (Operation &inner : llvm::make_early_inc_range(actor.getBody().front())) {
        if (isa<cal::ActionOp>(inner)) toErase.push_back(&inner);
      }
      for (Operation *e : toErase) rewriter.eraseOp(e);

      changed = true;
      return WalkResult::advance();
    });

    if (!changed) {
      // Nothing to lower in this operation.
      return;
    }
  }
};

} // namespace cal
} // namespace mlir

std::unique_ptr<mlir::Pass> mlir::cal::lowerCalFsmToExecutionBody() {
  return std::make_unique<mlir::cal::LowerCalFsmToExecutionBodyPass>();
}
