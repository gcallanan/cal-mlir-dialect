//===- CalPassesMaterializeRCOps.cpp --------------------------*- C++ -*-===//
// This file is licensed under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//===----------------------------------------------------------------------===//
//
// This pass materializes reference counting operations from attributes set by
// the `cal-insert-rc-for-state` pass. It transforms state variable operations
// that are marked with RC attributes into actual cal.rc.* operations.
//
// The transformation changes:
// 1. State variable type from !cal.state_ref<T> to !cal.state_ref<!cal.rc<T>>
// 2. cal.set operations to include rc.alloc (or rc.retain) and rc.release
// 3. cal.get operations to use rc.load to extract the actual value
//
// This pass must run AFTER:
// - cal-detect-recursive-types (marks recursive types)
// - cal-insert-rc-for-state (marks operations with RC attributes)
//
// This pass must run BEFORE:
// - lower-cal-state-to-memref (which would lose the RC semantic info)
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
#include "llvm/ADT/DenseMap.h"
#include "llvm/ADT/SmallVector.h"

namespace mlir::cal {
#define GEN_PASS_DEF_MATERIALIZERCOPS
#include "Dialect/Cal/CalPasses.h.inc"

namespace {

//===----------------------------------------------------------------------===//
// Helper Functions
//===----------------------------------------------------------------------===//

/// Check if a create_state_var op is marked as RC-managed.
static bool isRCManaged(CreateStateVarOp op) {
  return op->hasAttr("cal.rc_managed");
}

/// Check if a state_set op needs to release the old value.
static bool needsReleaseOld(StateSetOp op) {
  return op->hasAttr("cal.rc_release_old");
}

/// Check if a state_set op needs to alloc the new value (arena -> RC).
static bool needsAlloc(StateSetOp op) {
  return op->hasAttr("cal.rc_needs_alloc");
}

/// Check if a state_set op needs to retain the new value (RC -> RC).
static bool needsRetain(StateSetOp op) {
  return op->hasAttr("cal.rc_needs_retain");
}

/// Check if a state_get op is on an RC-managed state.
static bool isBorrowed(StateGetOp op) {
  return op->hasAttr("cal.rc_borrowed");
}

//===----------------------------------------------------------------------===//
// Pass Implementation
//===----------------------------------------------------------------------===//

class MaterializeRCOpsPass : public impl::MaterializeRCOpsBase<MaterializeRCOpsPass> {
public:
  void runOnOperation() override {
    Operation *module = getOperation();
    
    // Track mapping from old state refs (T) to new state refs (!cal.rc<T>)
    DenseMap<Value, Value> oldToNewStateRef;
    
    // Track the element type for each RC-managed state
    DenseMap<Value, Type> stateToElemType;
    
    // First pass: transform CreateStateVarOps - change type to store !cal.rc<T>
    SmallVector<CreateStateVarOp> rcManagedStates;
    module->walk([&](CreateStateVarOp createOp) {
      if (isRCManaged(createOp)) {
        rcManagedStates.push_back(createOp);
      }
    });
    
    if (rcManagedStates.empty()) {
      // No RC-managed state, nothing to do
      return;
    }

    OpBuilder builder(module->getContext());

    // Transform each RC-managed state variable
    for (CreateStateVarOp createOp : rcManagedStates) {
      Location loc = createOp.getLoc();
      Type elemType = createOp.getStateType();
      Type rcType = RCType::get(createOp.getContext(), elemType);
      Type newStateRefType = StateVarRefType::get(createOp.getContext(), rcType);
      
      builder.setInsertionPoint(createOp);
      
      // Create new state var with RC-wrapped type
      auto newCreateOp = builder.create<CreateStateVarOp>(
          loc, newStateRefType, createOp.getSizes(), 
          TypeAttr::get(rcType));
      
      // Copy over non-RC attributes
      for (auto attr : createOp->getAttrs()) {
        if (attr.getName() != "cal.rc_managed" && 
            attr.getName() != "cal.recursive_type" &&
            attr.getName() != "stateType") {
          newCreateOp->setAttr(attr.getName(), attr.getValue());
        }
      }
      
      // Record the mapping
      oldToNewStateRef[createOp.getStateVarRef()] = newCreateOp.getStateVarRef();
      stateToElemType[createOp.getStateVarRef()] = elemType;
    }

    // Second pass: transform all uses of the old state refs
    // Process actors one by one
    module->walk([&](ActorOp actor) {
      processActor(actor, oldToNewStateRef, stateToElemType, builder);
    });

    // Third pass: erase old CreateStateVarOps
    for (CreateStateVarOp createOp : rcManagedStates) {
      if (createOp.getStateVarRef().use_empty()) {
        createOp.erase();
      }
    }
  }

private:
  /// Process a single actor, transforming RC-marked operations.
  void processActor(ActorOp actor, 
                    DenseMap<Value, Value> &oldToNewStateRef,
                    DenseMap<Value, Type> &stateToElemType,
                    OpBuilder &builder) {
    
    // Collect operations to transform (don't modify while walking)
    SmallVector<StateSetOp> setsToTransform;
    SmallVector<StateGetOp> getsToTransform;
    
    actor.getBody().walk([&](Operation *op) {
      if (auto setOp = dyn_cast<StateSetOp>(op)) {
        Value oldRef = setOp.getStateRef();
        if (oldToNewStateRef.count(oldRef)) {
          setsToTransform.push_back(setOp);
        }
      } else if (auto getOp = dyn_cast<StateGetOp>(op)) {
        Value oldRef = getOp.getStateRef();
        if (oldToNewStateRef.count(oldRef)) {
          getsToTransform.push_back(getOp);
        }
      }
    });

    // Transform get operations - need to extract value from RC
    for (StateGetOp getOp : getsToTransform) {
      transformGetOp(getOp, oldToNewStateRef, stateToElemType, builder);
    }
    
    // Transform set operations - need to wrap value in RC
    for (StateSetOp setOp : setsToTransform) {
      transformSetOp(setOp, oldToNewStateRef, stateToElemType, builder);
    }
  }

  /// Transform a cal.get operation on an RC-managed state.
  /// We need to load the RC and then extract the value with rc.load.
  void transformGetOp(StateGetOp getOp,
                      DenseMap<Value, Value> &oldToNewStateRef,
                      DenseMap<Value, Type> &stateToElemType,
                      OpBuilder &builder) {
    Location loc = getOp.getLoc();
    Value oldRef = getOp.getStateRef();
    Value newRef = oldToNewStateRef[oldRef];
    Type elemType = stateToElemType[oldRef];
    Type rcType = RCType::get(getOp.getContext(), elemType);
    
    builder.setInsertionPoint(getOp);
    
    // Get the RC value from state
    auto rcGet = builder.create<StateGetOp>(loc, rcType, newRef);
    
    // Extract the actual value from the RC container
    auto loadedValue = builder.create<RCLoadOp>(loc, elemType, rcGet.getStateValue());
    
    // Replace all uses of the old get result with the loaded value
    getOp.getStateValue().replaceAllUsesWith(loadedValue.getValue());
    
    // Erase the old get op
    getOp.erase();
  }

  /// Transform a cal.set operation on an RC-managed state.
  /// We need to release the old value and wrap the new value in RC.
  void transformSetOp(StateSetOp setOp, 
                      DenseMap<Value, Value> &oldToNewStateRef,
                      DenseMap<Value, Type> &stateToElemType,
                      OpBuilder &builder) {
    Location loc = setOp.getLoc();
    Value oldRef = setOp.getStateRef();
    Value newRef = oldToNewStateRef[oldRef];
    Value newValue = setOp.getStateValue();
    Type elemType = stateToElemType[oldRef];
    Type rcType = RCType::get(setOp.getContext(), elemType);
    
    builder.setInsertionPoint(setOp);
    
    // 1. If marked for releasing old value, get and release it
    if (needsReleaseOld(setOp)) {
      // Get the current (old) RC value from state
      auto oldRcGet = builder.create<StateGetOp>(loc, rcType, newRef);
      
      // Release the old RC value
      builder.create<RCReleaseOp>(loc, oldRcGet.getStateValue());
    }
    
    // 2. Wrap the new value in RC
    Value rcValueToStore;
    
    if (needsAlloc(setOp)) {
      // New value comes from arena - allocate new RC container
      auto rcAlloc = builder.create<RCAllocOp>(loc, rcType, newValue);
      rcValueToStore = rcAlloc.getResult();
    } else if (needsRetain(setOp)) {
      // New value is borrowed from another RC - retain it
      // First we need to get the RC container that holds the borrowed value
      // This is complex - for now, just allocate a new RC
      // (Full implementation would track where the borrowed value came from)
      auto rcAlloc = builder.create<RCAllocOp>(loc, rcType, newValue);
      rcValueToStore = rcAlloc.getResult();
    } else {
      // No specific marking - allocate new RC by default
      auto rcAlloc = builder.create<RCAllocOp>(loc, rcType, newValue);
      rcValueToStore = rcAlloc.getResult();
    }
    
    // 3. Store the RC value to state
    builder.create<StateSetOp>(loc, rcValueToStore, newRef);
    
    // Erase the old set op
    setOp.erase();
  }
};

} // namespace

std::unique_ptr<Pass> materializeRCOps() {
  return std::make_unique<MaterializeRCOpsPass>();
}

} // namespace mlir::cal
