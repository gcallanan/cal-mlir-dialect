//===- CalPassesInsertArenas.cpp ------------------------------*- C++ -*-===//
// This file is licensed under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//===----------------------------------------------------------------------===//
//
// This pass inserts arena allocation/deallocation operations around action
// bodies to manage memory for recursive algebraic types. Arenas provide
// efficient bump-pointer allocation for temporary values within an action.
//
//===----------------------------------------------------------------------===//

#include "Dialect/Cal/CalDialect.h"
#include "Dialect/Cal/CalOps.h"
#include "Dialect/Cal/CalPasses.h"
#include "Dialect/Cal/CalTypes.h"
#include "Dialect/Fifo/FifoDialect.h"
#include "Dialect/Fifo/FifoOps.h"
#include "mlir/IR/Builders.h"
#include "mlir/IR/BuiltinOps.h"
#include "mlir/IR/IRMapping.h"
#include "mlir/IR/PatternMatch.h"
#include "mlir/Transforms/GreedyPatternRewriteDriver.h"
#include "llvm/ADT/SmallVector.h"

namespace mlir::cal {
#define GEN_PASS_DEF_INSERTARENAS
#include "Dialect/Cal/CalPasses.h.inc"

namespace {

//===----------------------------------------------------------------------===//
// Helper Functions
//===----------------------------------------------------------------------===//

/// Check if an operation needs arena allocation (has cal.recursive_type attr).
static bool needsArenaAllocation(Operation *op) {
  return op->hasAttr("cal.recursive_type");
}

/// Check if a FIFO operation transfers recursive types (has cal.recursive_token attr).
static bool transfersRecursiveType(Operation *op) {
  return op->hasAttr("cal.recursive_token");
}

/// Check if an execution body contains any operations that need arena management.
static bool executionBodyNeedsArena(ExecutionBody execBody) {
  bool needsArena = false;
  execBody.getBody().walk([&](Operation *op) {
    if (needsArenaAllocation(op) || transfersRecursiveType(op)) {
      needsArena = true;
      return WalkResult::interrupt();
    }
    return WalkResult::advance();
  });
  return needsArena;
}

//===----------------------------------------------------------------------===//
// Pass Implementation
//===----------------------------------------------------------------------===//

class InsertArenasPass : public impl::InsertArenasBase<InsertArenasPass> {
public:
  void runOnOperation() override {
    Operation *module = getOperation();

    // Process each actor's execution body
    module->walk([&](ActorOp actor) {
      actor.getBody().walk([&](ExecutionBody execBody) {
        processExecutionBody(execBody);
      });
    });
  }

private:
  /// Process a single execution body, inserting arena ops if needed.
  void processExecutionBody(ExecutionBody execBody) {
    // Check if this execution body needs arena management
    if (!executionBodyNeedsArena(execBody))
      return;

    Region &body = execBody.getBody();
    if (body.empty())
      return;

    Block &entryBlock = body.front();
    if (entryBlock.empty())
      return;

    Location loc = execBody.getLoc();
    OpBuilder builder(execBody.getContext());

    // 1. Insert arena.create at the beginning of the execution body
    builder.setInsertionPointToStart(&entryBlock);
    // ArenaCreateOp takes optional initial_size IntegerAttr; pass nullptr for default
    auto arenaCreate = builder.create<ArenaCreateOp>(loc, /*initial_size=*/nullptr);
    Value arena = arenaCreate.getArena();

    // 2. Find all action_done terminators and insert arena.destroy before them
    SmallVector<ActionDoneOp> terminators;
    entryBlock.walk([&](ActionDoneOp done) {
      terminators.push_back(done);
    });

    for (ActionDoneOp done : terminators) {
      builder.setInsertionPoint(done);
      builder.create<ArenaDestroyOp>(loc, arena);
    }

    // 3. Transform operations that need arena allocation
    // For now, we just add the arena as an attribute marker.
    // The actual lowering will use this info to allocate from arena.
    entryBlock.walk([&](Operation *op) {
      if (needsArenaAllocation(op)) {
        // Mark that this op should use the arena
        // In the future, we may want to change the op itself to accept
        // an arena operand, but for now we just annotate it
        op->setAttr("cal.arena_allocated", UnitAttr::get(op->getContext()));
      }
    });

    // 4. Transform FIFO operations that transfer recursive types
    transformFifoOperations(entryBlock, arena, builder);
  }

  /// Transform FIFO push/pop operations to use token wrapping.
  void transformFifoOperations(Block &block, Value arena, OpBuilder &builder) {
    // Collect operations to transform (we can't modify while iterating)
    SmallVector<fifo::Push> pushOps;
    SmallVector<fifo::Pop> popOps;

    block.walk([&](Operation *op) {
      if (auto push = dyn_cast<fifo::Push>(op)) {
        if (transfersRecursiveType(push))
          pushOps.push_back(push);
      }
      if (auto pop = dyn_cast<fifo::Pop>(op)) {
        if (transfersRecursiveType(pop))
          popOps.push_back(pop);
      }
    });

    // Transform push operations: wrap value into token before pushing
    for (fifo::Push push : pushOps) {
      // Mark the push as having been transformed
      push->setAttr("cal.token_wrapped", UnitAttr::get(builder.getContext()));
      
      // Note: We don't actually change the push operand here because
      // the FIFO type system would need to change. Instead, we mark
      // the operations for later lowering passes to handle.
      // The actual FIFO operations will be transformed during LLVM lowering
      // when the token type is resolved to a pointer.
    }

    // Transform pop operations: unwrap token after popping
    for (fifo::Pop pop : popOps) {
      // Mark the pop as needing unwrapping
      pop->setAttr("cal.needs_token_unwrap", UnitAttr::get(builder.getContext()));

      // Note: Similar to push, we mark for later lowering.
      // The actual unwrap will happen when the token type is resolved.
    }
    
    // Suppress unused parameter warning for arena (will be used in future)
    (void)arena;
  }
};

} // namespace

std::unique_ptr<Pass> insertArenas() {
  return std::make_unique<InsertArenasPass>();
}

} // namespace mlir::cal
