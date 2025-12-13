//===- CalPassesInsertRCForState.cpp --------------------------*- C++ -*-===//
// This file is licensed under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//===----------------------------------------------------------------------===//
//
// This pass inserts reference counting operations for state variables that
// contain recursive algebraic types. Reference counting ensures proper memory
// management for values that persist across action firings.
//
//===----------------------------------------------------------------------===//

#include "Dialect/Cal/CalDialect.h"
#include "Dialect/Cal/CalOps.h"
#include "Dialect/Cal/CalPasses.h"
#include "Dialect/Cal/CalTypes.h"
#include "mlir/IR/Builders.h"
#include "mlir/IR/BuiltinOps.h"
#include "mlir/IR/IRMapping.h"
#include "mlir/IR/PatternMatch.h"
#include "mlir/Transforms/GreedyPatternRewriteDriver.h"
#include "llvm/ADT/SmallVector.h"

namespace mlir::cal {
#define GEN_PASS_DEF_INSERTRCFORSTATE
#include "Dialect/Cal/CalPasses.h.inc"

namespace {

//===----------------------------------------------------------------------===//
// Helper Functions
//===----------------------------------------------------------------------===//

/// Check if an operation creates a state variable with a recursive type.
static bool isRecursiveStateVar(CreateStateVarOp createOp) {
  return createOp->hasAttr("cal.recursive_type");
}

/// Check if a type is a recursive algebraic type based on attributes.
/// In practice, the detect-recursive-types pass would mark these.
static bool isRecursiveType(Type type) {
  // For now, we rely on the operation being marked rather than checking the type
  // A full implementation would inspect VariantType/ProductType for recursive fields
  return false;
}

/// Get all state variable references in an actor that need RC management.
static SmallVector<CreateStateVarOp> getRecursiveStateVars(ActorOp actor) {
  SmallVector<CreateStateVarOp> result;
  actor.getBody().walk([&](CreateStateVarOp createOp) {
    if (isRecursiveStateVar(createOp)) {
      result.push_back(createOp);
    }
  });
  return result;
}

/// Find all get operations for a given state variable.
static SmallVector<StateGetOp> getOpsForState(Value stateRef) {
  SmallVector<StateGetOp> result;
  for (auto user : stateRef.getUsers()) {
    if (auto getOp = dyn_cast<StateGetOp>(user)) {
      result.push_back(getOp);
    }
  }
  return result;
}

/// Find all set operations for a given state variable.
static SmallVector<StateSetOp> setOpsForState(Value stateRef) {
  SmallVector<StateSetOp> result;
  for (auto user : stateRef.getUsers()) {
    if (auto setOp = dyn_cast<StateSetOp>(user)) {
      result.push_back(setOp);
    }
  }
  return result;
}

//===----------------------------------------------------------------------===//
// Pass Implementation
//===----------------------------------------------------------------------===//

class InsertRCForStatePass : public impl::InsertRCForStateBase<InsertRCForStatePass> {
public:
  void runOnOperation() override {
    Operation *module = getOperation();

    // Process each actor
    module->walk([&](ActorOp actor) {
      processActor(actor);
    });
  }

private:
  /// Process a single actor, inserting RC ops for recursive state variables.
  void processActor(ActorOp actor) {
    // Get all state variables that need RC management
    SmallVector<CreateStateVarOp> recursiveStates = getRecursiveStateVars(actor);
    
    if (recursiveStates.empty())
      return;

    OpBuilder builder(actor.getContext());

    // Process each recursive state variable
    for (CreateStateVarOp createOp : recursiveStates) {
      processStateVariable(createOp, builder);
    }
  }

  /// Process a single state variable, marking its operations for RC management.
  void processStateVariable(CreateStateVarOp createOp, OpBuilder &builder) {
    Value stateRef = createOp.getStateVarRef();
    
    // Mark the state variable as RC-managed
    createOp->setAttr("cal.rc_managed", UnitAttr::get(createOp.getContext()));
    
    // Process all get operations
    for (StateGetOp getOp : getOpsForState(stateRef)) {
      processGetOp(getOp, builder);
    }
    
    // Process all set operations
    for (StateSetOp setOp : setOpsForState(stateRef)) {
      processSetOp(setOp, stateRef, builder);
    }
  }

  /// Process a cal.get operation on an RC-managed state variable.
  /// The returned value is a borrow - no retain needed for read-only use.
  void processGetOp(StateGetOp getOp, OpBuilder &builder) {
    // Mark as borrowed (no ownership transfer)
    getOp->setAttr("cal.rc_borrowed", UnitAttr::get(getOp.getContext()));
    
    // Note: If escape analysis determines this value escapes (e.g., pushed to FIFO
    // or stored in another state variable), a retain would be needed.
    // For now, we just mark it and let later passes handle the actual RC ops.
  }

  /// Process a cal.set operation on an RC-managed state variable.
  /// We need to release the old value and potentially retain/alloc the new value.
  void processSetOp(StateSetOp setOp, Value stateRef, OpBuilder &builder) {
    Location loc = setOp.getLoc();
    
    // Mark as needing RC update
    setOp->setAttr("cal.rc_updated", UnitAttr::get(setOp.getContext()));
    
    // The actual RC operations (release old, retain/alloc new) will be inserted
    // during LLVM lowering. Here we just annotate with the necessary info.
    
    // Check if the new value comes from an arena-allocated source
    Value newValue = setOp.getStateValue();
    if (Operation *definingOp = newValue.getDefiningOp()) {
      if (definingOp->hasAttr("cal.arena_allocated")) {
        // New value comes from arena - will need rc.alloc to transfer to heap
        setOp->setAttr("cal.rc_needs_alloc", UnitAttr::get(setOp.getContext()));
      } else if (definingOp->hasAttr("cal.rc_borrowed")) {
        // New value is borrowed from another RC - will need rc.retain
        setOp->setAttr("cal.rc_needs_retain", UnitAttr::get(setOp.getContext()));
      }
    }
    
    // Mark that the old value needs release
    // This info is used by LLVM lowering to generate the rc.release call
    setOp->setAttr("cal.rc_release_old", UnitAttr::get(setOp.getContext()));
  }
};

} // namespace

std::unique_ptr<Pass> insertRCForState() {
  return std::make_unique<InsertRCForStatePass>();
}

} // namespace mlir::cal
