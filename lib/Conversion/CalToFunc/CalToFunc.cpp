//===- CalPasses.cpp - Cal passes -----------------*- C++ -*-===//
//
// This file is licensed under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
#include "Dialect/Cal/CalDialect.h"
#include "Dialect/Cal/CalOps.h"
#include "Dialect/Cal/CalPasses.h"
#include "Dialect/Cal/CalTypes.h"
#include "mlir/Dialect/Arith/IR/Arith.h"
#include "mlir/Dialect/Async/IR/Async.h"
#include "mlir/Dialect/Func/IR/FuncOps.h"
#include "mlir/Dialect/Func/Transforms/FuncConversions.h"
#include "mlir/Dialect/Index/IR/IndexDialect.h"
#include "mlir/Dialect/LLVMIR/LLVMDialect.h"
#include "mlir/Dialect/MemRef/IR/MemRef.h"
#include "mlir/Dialect/SCF/IR/SCF.h"
#include "mlir/IR/IRMapping.h"
#include "mlir/IR/PatternMatch.h"
#include "mlir/Rewrite/FrozenRewritePatternSet.h"
#include "mlir/Transforms/DialectConversion.h"
#include "mlir/Transforms/GreedyPatternRewriteDriver.h"

#include "Conversion/CalToFunc/CalToFunc.h"
#include "Conversion/Passes.h"

namespace mlir {
#define GEN_PASS_DEF_CONVERTCALTOFUNC
#include "Conversion/Passes.h.inc"

// Cache line size in bytes for padding to avoid false sharing.
static constexpr int64_t CACHE_LINE_SIZE_I32 =
    CACHE_LINE_SIZE / sizeof(int32_t);

/// Parses the actor partitioning mode from a string option.
///
/// This function converts a string representation of the actor partitioning
/// mode into the corresponding `ActorPartitioningMode` enum value. It is used
/// to configure how actors are scheduled and executed in the generated code.
///
/// @param mode The string representation of the partitioning mode
/// @return The corresponding ActorPartitioningMode enum value
/// @throws llvm::report_fatal_error if the mode string is not recognized
static ActorPartitioningMode parsePartitioningMode(const std::string &mode) {
  if (mode == "single-threaded")
    return ActorPartitioningMode::Singlethreaded;
  else if (mode == "multi-threaded")
    return ActorPartitioningMode::Multithreaded;
  else {
    llvm::report_fatal_error(llvm::Twine("Unknown actor partitioning mode: ") +
                             mode);
  }
}

/// Creates and initializes the termination and progress flags for
/// multi-threaded actor execution.
///
/// This function allocates and initializes two memory regions used for
/// coordinating multi-threaded actor execution:
///
/// 1. **Termination flag** (memref<1xi32>) initialized to 0:
///    Used to signal when all actors should stop executing. When set to 1,
///    all actor threads check this flag (with optimized non-atomic loads
///    before atomic operations) and terminate.
///
/// 2. **Progress flags array** (memref<numThreads x CACHE_LINE_SIZE_I32 x i32>)
///    with each element initialized to 1:
///    Used to track whether each actor group has made progress in the current
///    iteration. Each group sets its flag to 1 when it performs work
///    (using optimized check-before-atomic-write). The monitoring loop
///    reads these flags atomically (resetting them to 0) to detect global
///    progress. Array elements are padded by CACHE_LINE_SIZE_I32 to avoid false
///    sharing.
///
/// The generated structure:
/// ```
/// %c0_i32 = arith.constant 0 : i32
/// %c1_i32 = arith.constant 1 : i32
/// %c0 = arith.constant 0 : index
/// %termination_flag = memref.alloc() : memref<1xi32>
/// %init_term = memref.atomic_rmw assign %c0_i32, %termination_flag[%c0] :
///   (i32, memref<1xi32>) -> i32
/// %progress_flags = memref.alloc() : memref<numThreads*CACHE_LINE_SIZE_I32 x
/// i32> %init_progress_0 = memref.atomic_rmw assign %c1_i32,
/// %progress_flags[%c0] :
///   (i32, memref<...xi32>) -> i32
/// %init_progress_1 = memref.atomic_rmw assign %c1_i32,
/// %progress_flags[%c_CACHE_LINE_SIZE_I32] :
///   (i32, memref<...xi32>) -> i32
/// // ... one initialization per group, spaced by CACHE_LINE_SIZE_I32
/// ```
///
/// @param rewriter The pattern rewriter used to create operations
/// @param loc The location to associate with created operations
/// @param networkBody The block containing actor function calls (used to count
///   actors)
/// @param numThreads The number of actor groups (threads) to create flags for
/// @return A tuple containing (terminationFlag, progressFlags, numThreads)
static std::tuple<Value, Value, int>
createActorSynchronizationFlags(PatternRewriter &rewriter, Location loc,
                                Block &networkBody, int numThreads) {

  // Create constant values for initialization
  auto c0_i32 =
      rewriter.create<arith::ConstantOp>(loc, rewriter.getI32IntegerAttr(0));
  auto c1_i32 =
      rewriter.create<arith::ConstantOp>(loc, rewriter.getI32IntegerAttr(1));
  auto c0_index =
      rewriter.create<arith::ConstantOp>(loc, rewriter.getIndexAttr(0));

  // Create termination flag: memref<1xi32>
  auto terminationFlagType = MemRefType::get({1}, rewriter.getI32Type());
  Value terminationFlag =
      rewriter.create<memref::AllocOp>(loc, terminationFlagType);

  // Initialize termination flag to 0
  rewriter.create<memref::AtomicRMWOp>(loc, arith::AtomicRMWKind::assign,
                                       c0_i32, terminationFlag,
                                       ValueRange{c0_index});

  // Create progress flags array: memref<numThreads x CACHE_LINE_SIZE_I32 x i32>
  // Multiply by CACHE_LINE_SIZE_I32 for padding to avoid false sharing between
  // threads
  auto progressFlagsType = MemRefType::get({numThreads * CACHE_LINE_SIZE_I32},
                                           rewriter.getI32Type());
  Value progressFlags =
      rewriter.create<memref::AllocOp>(loc, progressFlagsType);

  // Initialize each progress flag to 1
  for (int i = 0; i < numThreads; i++) {
    auto indexConst = rewriter.create<arith::ConstantOp>(
        loc, rewriter.getIndexAttr(i * CACHE_LINE_SIZE_I32));
    rewriter.create<memref::AtomicRMWOp>(loc, arith::AtomicRMWKind::assign,
                                         c1_i32, progressFlags,
                                         ValueRange{indexConst});
  }

  return std::make_tuple(terminationFlag, progressFlags, numThreads);
}

/// Declares the `usleep` external function at module level if not already
/// present.
///
/// This function ensures that `llvm.func @usleep(i32) -> i32` is declared in
/// the module before any calls to it are made. The declaration is inserted at
/// the beginning of the module.
///
/// @param rewriter The pattern rewriter used to create operations
/// @param loc The location to associate with the declaration
/// @param entryBlock The entry block of the function where usleep will be
/// called
static void declareUsleepFunction(PatternRewriter &rewriter, Location loc,
                                  Block *entryBlock) {
  // Get the parent module to declare the usleep function
  Operation *parentOp = entryBlock->getParentOp();
  while (parentOp && !isa<ModuleOp>(parentOp)) {
    parentOp = parentOp->getParentOp();
  }

  if (auto moduleOp = dyn_cast_or_null<ModuleOp>(parentOp)) {
    // Check if usleep is already declared, if not, declare it
    if (!moduleOp.lookupSymbol("usleep")) {
      OpBuilder::InsertionGuard guard(rewriter);
      rewriter.setInsertionPointToStart(moduleOp.getBody());

      auto i32Type = rewriter.getI32Type();
      auto usleepFuncType = LLVM::LLVMFunctionType::get(i32Type, {i32Type});
      rewriter.create<LLVM::LLVMFuncOp>(loc, "usleep", usleepFuncType);
    }
  } else {
    llvm::report_fatal_error(
        "Failed to find parent ModuleOp for usleep declaration");
  }
}

/// Wraps groups of actor function calls in `async.execute` blocks with infinite
/// loops.
///
/// This function processes groups of actors (grouped by device_affinity) and
/// wraps each group in its own `async.execute` region. Actors within the same
/// group (same device_affinity) are executed sequentially within a single
/// thread.
///
/// @param rewriter The pattern rewriter used to create operations
/// @param loc The location to associate with created operations
/// @param actorGroups Groups of actor calls (by device_affinity)
/// @param terminationFlag The shared termination flag memref
/// @param progressFlags The shared progress flags array memref
/// @return A vector of async tokens, one for each group
static SmallVector<Value> wrapActorGroupsInAsyncExecute(
    PatternRewriter &rewriter, Location loc,
    const SmallVector<SmallVector<Operation *>> &actorGroups,
    Value terminationFlag, Value progressFlags) {
  SmallVector<Value> asyncTokens;

  int groupIndex = 0;
  for (const auto &actorGroup : actorGroups) {
    // Create async.execute block for this group
    auto executeOp = rewriter.create<async::ExecuteOp>(
        loc, TypeRange{}, ValueRange{}, ValueRange{});

    // Clear the default block that comes with async.execute
    executeOp.getRegion().getBlocks().clear();

    // Create a new block for the async body
    Block *executeBody = rewriter.createBlock(&executeOp.getBodyRegion());
    rewriter.setInsertionPointToStart(executeBody);

    // Create an infinite while loop inside the async.execute block
    auto trueVal =
        rewriter.create<arith::ConstantOp>(loc, rewriter.getBoolAttr(true));

    auto whileOp =
        rewriter.create<scf::WhileOp>(loc, TypeRange{}, ValueRange{trueVal});

    // Create the condition check block that monitors the termination flag
    rewriter.createBlock(&whileOp.getBefore());
    Block &condBlock = whileOp.getBefore().front();
    condBlock.addArgument(rewriter.getI1Type(), loc);
    rewriter.setInsertionPointToStart(&condBlock);

    // Create constants needed for termination check
    auto c0_i32 =
        rewriter.create<arith::ConstantOp>(loc, rewriter.getI32IntegerAttr(0));
    auto c1_i32 =
        rewriter.create<arith::ConstantOp>(loc, rewriter.getI32IntegerAttr(1));
    auto idx0 =
        rewriter.create<arith::ConstantOp>(loc, rewriter.getIndexAttr(0));

    // Check termination flag with non-atomic load first
    auto currentTermValue =
        rewriter.create<memref::LoadOp>(loc, terminationFlag, ValueRange{idx0});
    auto isOne = rewriter.create<arith::CmpIOp>(
        loc, arith::CmpIPredicate::eq, currentTermValue, c1_i32.getResult());

    auto ifOp = rewriter.create<scf::IfOp>(
        loc, TypeRange{rewriter.getI32Type()}, isOne, /*hasElse=*/true);
    rewriter.setInsertionPointToStart(ifOp.thenBlock());
    auto atomicTermVal = rewriter.create<memref::AtomicRMWOp>(
        loc, arith::AtomicRMWKind::addi, c0_i32, terminationFlag,
        ValueRange{idx0});
    rewriter.create<scf::YieldOp>(loc, ValueRange{atomicTermVal.getResult()});

    rewriter.setInsertionPointToStart(ifOp.elseBlock());
    rewriter.create<scf::YieldOp>(loc, ValueRange{c0_i32.getResult()});

    rewriter.setInsertionPointAfter(ifOp);
    Value termVal = ifOp.getResult(0);

    auto shouldContinue = rewriter.create<arith::CmpIOp>(
        loc, arith::CmpIPredicate::eq, termVal, c0_i32.getResult());

    rewriter.create<scf::ConditionOp>(loc, shouldContinue.getResult(),
                                      ValueRange{});

    // Create the loop body block
    rewriter.createBlock(&whileOp.getAfter());
    Block &bodyBlock = whileOp.getAfter().front();
    rewriter.setInsertionPointToStart(&bodyBlock);

    // Initialize progress flag for this group
    auto constFalse =
        rewriter.create<arith::ConstantOp>(loc, rewriter.getBoolAttr(false));
    Value groupProgress = constFalse.getResult();

    // Move all actor calls in this group into the while loop body
    for (Operation *actorCall : actorGroup) {
      actorCall->moveBefore(&bodyBlock, bodyBlock.end());
      Value actorResult = actorCall->getResult(0);

      // OR this actor's result with the group's progress
      auto orOp =
          rewriter.create<arith::OrIOp>(loc, groupProgress, actorResult);
      groupProgress = orOp.getResult();
    }

    // If any actor in the group made progress, update the progress flag
    auto ifOp2 = rewriter.create<scf::IfOp>(loc, TypeRange{}, groupProgress,
                                            /*hasElse=*/false);
    rewriter.setInsertionPointToStart(ifOp2.thenBlock());

    auto cGroupIdx = rewriter.create<arith::ConstantOp>(
        loc, rewriter.getIndexAttr(groupIndex * CACHE_LINE_SIZE_I32));

    // Check current value with non-atomic load before atomic operation
    auto currentValue = rewriter.create<memref::LoadOp>(loc, progressFlags,
                                                        ValueRange{cGroupIdx});
    auto needsUpdate = rewriter.create<arith::CmpIOp>(
        loc, arith::CmpIPredicate::eq, currentValue, c0_i32.getResult());

    auto innerIfOp = rewriter.create<scf::IfOp>(loc, TypeRange{}, needsUpdate,
                                                /*hasElse=*/false);
    rewriter.setInsertionPointToStart(innerIfOp.thenBlock());
    rewriter.create<memref::AtomicRMWOp>(loc, arith::AtomicRMWKind::assign,
                                         c1_i32, progressFlags,
                                         ValueRange{cGroupIdx});

    // Continue the infinite loop
    rewriter.setInsertionPointAfter(ifOp2);
    rewriter.create<scf::YieldOp>(loc, ValueRange{trueVal});

    // Add async.yield terminator after the while loop
    rewriter.setInsertionPointToEnd(executeBody);
    rewriter.create<async::YieldOp>(loc, ValueRange{});

    // Store the async token for synchronization
    asyncTokens.push_back(executeOp.getToken());

    // Move to next group
    rewriter.setInsertionPointAfter(executeOp);
    groupIndex++;
  }

  return asyncTokens;
}

/// Creates the monitoring while loop that checks actor group progress and
/// manages termination.
///
/// This function generates a while loop that:
/// 1. Reads all progress flags atomically and resets them to 0
///    Note: Currently uses unconditional atomic operations. This could be
///    optimized further with non-atomic loads first, but the monitoring loop
///    runs less frequently so the impact is lower.
/// 2. ORs them together to check if any actor group made progress
/// 3. Sleeps briefly (50ms) to avoid busy-waiting
/// 4. Continues looping if progress was made, otherwise exits
/// 5. Sets the termination flag when no progress is detected
///
/// The generated structure:
/// ```
/// scf.while (%arg0 = %true) : (i1) -> () {
///   scf.condition(%arg0)
/// } do {
///   // Atomically read and reset progress flags (spaced by
///   CACHE_LINE_SIZE_I32) %prog_0 = memref.atomic_rmw assign %c0_i32,
///   %progress_flags[%c0] : (i32, memref<Nxi32>) -> i32 %prog_1 =
///   memref.atomic_rmw assign %c0_i32, %progress_flags[%c_CACHE_LINE_SIZE_I32]
///   : (i32, memref<Nxi32>) -> i32
///   ...
///   %any_progress = arith.ori %prog_0, %prog_1 : i32
///   %has_progress = arith.cmpi eq, %any_progress, %c1_i32 : i32
///   %sleep_res = llvm.call @usleep(%sleep_us) : (i32) -> i32
///   scf.yield %has_progress : i1
/// }
/// %set_term = memref.atomic_rmw assign %c1_i32, %termination_flag[%c0] : (i32,
/// memref<1xi32>) -> i32
/// ```
///
/// @param rewriter The pattern rewriter used to create operations
/// @param loc The location to associate with created operations
/// @param numThreads The number of actor groups to monitor
/// @param terminationFlag The termination flag memref to set when stopping
/// @param progressFlags The progress flags array memref to monitor (with cache
/// line padding)
static void createProgressMonitoringLoop(PatternRewriter &rewriter,
                                         Location loc, int numThreads,
                                         Value terminationFlag,
                                         Value progressFlags) {
  // Create initial true value for loop initialization
  auto trueVal =
      rewriter.create<arith::ConstantOp>(loc, rewriter.getBoolAttr(true));

  // Create the while loop structure
  auto whileOp =
      rewriter.create<scf::WhileOp>(loc, TypeRange{}, ValueRange{trueVal});

  // Create the condition check block
  rewriter.createBlock(&whileOp.getBefore());
  Block &condBlock = whileOp.getBefore().front();
  condBlock.addArgument(rewriter.getI1Type(), loc);
  rewriter.setInsertionPointToStart(&condBlock);
  Value argToCheck = condBlock.getArgument(0);
  rewriter.create<scf::ConditionOp>(loc, argToCheck, ValueRange{});

  // Create the loop body block
  rewriter.createBlock(&whileOp.getAfter());
  Block &bodyBlock = whileOp.getAfter().front();
  rewriter.setInsertionPointToStart(&bodyBlock);

  // Sleep using usleep to avoid busy-waiting
  auto sleepUs = rewriter.create<arith::ConstantOp>(
      loc, rewriter.getI32IntegerAttr(50000)); // 50 milliseconds

  // Create constant values needed for atomic operations
  auto c0_i32 =
      rewriter.create<arith::ConstantOp>(loc, rewriter.getI32IntegerAttr(0));
  auto c1_i32 =
      rewriter.create<arith::ConstantOp>(loc, rewriter.getI32IntegerAttr(1));

  // Read all progress flags atomically and reset them to 0
  // Each flag is spaced by CACHE_LINE_SIZE_I32 to avoid false sharing
  SmallVector<Value> progressFlagValues;
  for (int i = 0; i < numThreads; i++) {
    auto indexConst = rewriter.create<arith::ConstantOp>(
        loc, rewriter.getIndexAttr(i * CACHE_LINE_SIZE_I32));

    // Atomic read-and-reset operation
    auto atomicResult = rewriter.create<memref::AtomicRMWOp>(
        loc, arith::AtomicRMWKind::assign, c0_i32, progressFlags,
        ValueRange{indexConst});

    progressFlagValues.push_back(atomicResult.getResult());
  }

  // OR all progress flags together to check if any thread made progress
  Value anyProgress = progressFlagValues[0];
  for (int i = 1; i < numThreads; i++) {
    anyProgress =
        rewriter.create<arith::OrIOp>(loc, anyProgress, progressFlagValues[i])
            .getResult();
  }

  // Convert i32 to i1 for condition check
  // If anyProgress == 1, then at least one actor made progress and we should
  // continue
  auto hasProgress = rewriter.create<arith::CmpIOp>(
      loc, arith::CmpIPredicate::eq, anyProgress, c1_i32.getResult());

  auto i32Type = rewriter.getI32Type();
  auto usleepType = LLVM::LLVMFunctionType::get(i32Type, {i32Type});
  rewriter.create<LLVM::CallOp>(loc, usleepType, "usleep", ValueRange{sleepUs});

  // Yield the progress check result to determine if loop continues
  rewriter.create<scf::YieldOp>(loc, ValueRange{hasProgress});

  // After the while loop exits, set the termination flag
  rewriter.setInsertionPointAfter(whileOp);

  auto idx0 = rewriter.create<arith::ConstantOp>(loc, rewriter.getIndexAttr(0));
  rewriter.create<memref::AtomicRMWOp>(loc, arith::AtomicRMWKind::assign,
                                       c1_i32, terminationFlag,
                                       ValueRange{idx0});
}

/// Creates a single-threaded round-robin scheduling loop for actor execution.
///
/// This function generates an `scf.while` loop that repeatedly invokes all
/// actor functions in round-robin fashion until no actor reports progress.
/// Each actor function call returns an `i1` flag indicating whether it
/// performed an action. These flags are `OR`ed together to determine if the
/// loop should continue.
///
/// The generated structure:
/// ```
/// scf.while (%arg0 = %true) : (i1) -> () {
///   scf.condition(%arg0)
/// } do {
///   %0 = func.call @actor1(...) -> i1
///   %1 = func.call @actor2(...) -> i1
///   %progress = arith.ori %0, %1 : i1
///   scf.yield %progress : i1
/// }
/// ```
static void createSingleThreadedRoundRobinLoop(PatternRewriter &rewriter,
                                               Location loc, Block &networkBody,
                                               Block *entryBlock) {
  // Create initial true value for loop initialization
  auto trueVal =
      rewriter.create<arith::ConstantOp>(loc, rewriter.getBoolAttr(true));

  // Create the while loop structure
  auto whileOp =
      rewriter.create<scf::WhileOp>(loc, TypeRange{}, ValueRange{trueVal});

  // Create the condition check block
  rewriter.createBlock(&whileOp.getBefore());
  Block &condBlock = whileOp.getBefore().front();
  condBlock.addArgument(rewriter.getI1Type(), loc);
  rewriter.setInsertionPointToStart(&condBlock);
  Value argToCheck = condBlock.getArgument(0);
  rewriter.create<scf::ConditionOp>(loc, argToCheck, ValueRange{});

  // Create the loop body block
  rewriter.createBlock(&whileOp.getAfter());
  Block &bodyBlock = whileOp.getAfter().front();
  rewriter.setInsertionPointToStart(&bodyBlock);

  // Initialize progress flag to false
  auto constFalse =
      rewriter.create<arith::ConstantOp>(loc, rewriter.getBoolAttr(false));
  Value actionPerformedFlag = constFalse.getResult();

  // Move all actor function calls into the loop body and OR their results
  while (!networkBody.empty()) {
    Operation &opToMove = networkBody.front();
    opToMove.moveBefore(&bodyBlock, bodyBlock.end());
    Value result = opToMove.getResult(0);
    auto newActionPerformedFlag =
        rewriter.create<arith::OrIOp>(loc, result, actionPerformedFlag);
    actionPerformedFlag = newActionPerformedFlag.getResult();
  }

  // Yield the combined progress flag back to the condition block
  rewriter.create<scf::YieldOp>(loc, ValueRange{actionPerformedFlag});

  // Reset insertion point to continue building the main function
  rewriter.setInsertionPointToEnd(entryBlock);
}

/// Groups actor function calls by their device_affinity attribute.
///
/// This function partitions actor calls into groups based on their
/// device_affinity:
/// - Actors with the same device_affinity string are grouped together
/// - Actors without device_affinity each get their own individual group
///
/// @param networkBody The block containing actor function calls
/// @return A vector of groups, where each group contains actor calls with the
/// same affinity
static SmallVector<SmallVector<Operation *>>
groupActorCallsByAffinity(Block &networkBody) {
  // Map from device_affinity string to list of operations
  llvm::StringMap<SmallVector<Operation *>> affinityGroups;
  SmallVector<Operation *> noAffinityOps;

  for (Operation &op : networkBody) {
    if (auto callOp = llvm::dyn_cast<func::CallOp>(op)) {
      if (callOp->hasAttr("from_create_instance")) {
        if (auto deviceAffinity =
                callOp->getAttrOfType<mlir::StringAttr>("device_affinity")) {
          affinityGroups[deviceAffinity.getValue()].push_back(&op);
        } else {
          noAffinityOps.push_back(&op);
        }
      }
    }
  }

  // Build the result: groups with affinity first, then individual groups for
  // no-affinity actors
  SmallVector<SmallVector<Operation *>> result;

  // Add groups with device_affinity
  for (auto &entry : affinityGroups) {
    result.push_back(std::move(entry.second));
  }

  // Add individual groups for actors without affinity
  for (Operation *op : noAffinityOps) {
    SmallVector<Operation *> singleGroup;
    singleGroup.push_back(op);
    result.push_back(std::move(singleGroup));
  }

  return result;
}

/// Creates a multi-threaded execution model with one thread per actor group.
///
/// This function generates a multi-threaded runtime structure where each actor
/// group (actors with the same device_affinity) runs in its own `async.execute`
/// block with an infinite loop. Actors within the same group execute
/// sequentially in a single thread. A central monitoring loop tracks progress
/// across all groups using atomic flags and coordinates global termination when
/// no group makes progress.
///
/// **Actor Grouping:**
/// - Actors with the same `device_affinity` attribute are grouped together and
///   execute sequentially within a single thread
/// - Actors without `device_affinity` each get their own individual thread
/// - This enables explicit control over actor-to-core mappings for performance
/// tuning
///
/// **Performance Optimizations:**
/// - Termination flag checks use non-atomic loads before atomic operations
/// - Progress flag updates use non-atomic loads to avoid redundant atomic
/// writes
/// - Progress flags are padded by cache line size to prevent false sharing
/// - Monitoring loop sleeps to avoid busy-waiting
///
/// The generated structure consists of three main components:
///
/// 1. **Synchronization Infrastructure:**
///    - Termination flag (memref<1xi32>): Signals when all actor groups should
///    stop
///    - Progress flags array (memref<N*CACHE_LINE_SIZE_I32 x i32>): Tracks
///    whether
///      each actor group made progress, with cache line padding to avoid false
///      sharing
///
/// 2. **Per-Group Async Blocks:**
///    Each actor group is wrapped in its own async.execute containing:
///    ```
///    %token = async.execute {
///      scf.while (%arg0 = %true) : (i1) -> () {
///        // Optimized termination check: non-atomic load first
///        %current = memref.load %termination_flag[%c0]
///        %is_set = arith.cmpi eq, %current, %c1_i32
///        %term_val = scf.if %is_set {
///          %atomic = memref.atomic_rmw addi %c0_i32, %termination_flag[%c0]
///          scf.yield %atomic
///        } else {
///          scf.yield %c0_i32
///        }
///        %should_continue = arith.cmpi eq, %term_val, %c0_i32 : i1
///        scf.condition(%should_continue)
///      } do {
///        // Call all actors in this group sequentially
///        %result1 = func.call @actor1(...) : (...) -> i1
///        %result2 = func.call @actor2(...) : (...) -> i1
///        %group_progress = arith.ori %result1, %result2 : i1
///        scf.if %group_progress {
///          // Optimized progress update: check before atomic write
///          %current_val = memref.load %progress_flags[%group_idx]
///          %needs_update = arith.cmpi eq, %current_val, %c0_i32
///          scf.if %needs_update {
///            memref.atomic_rmw assign %c1_i32, %progress_flags[%group_idx]
///          }
///        }
///        scf.yield %true : i1
///      }
///      async.yield
///    }
///    ```
///
/// 3. **Progress Monitoring Loop:**
///    A central loop that:
///    - Atomically reads and resets all progress flags to 0
///    - ORs them together to check if any actor group made progress
///    - Sleeps briefly (50ms) to avoid busy-waiting
///    - Exits when no progress is detected across all groups
///    - Sets the termination flag to signal all groups to stop
///
/// 4. **Synchronization Barrier:**
///    After setting the termination flag, awaits all async tokens to ensure
///    all actor groups have completed before returning.
///
/// @param rewriter The pattern rewriter used to create operations
/// @param loc The location to associate with created operations
/// @param networkBody The block containing actor function calls to wrap
/// @param entryBlock The entry block of the main function being constructed
static void createOneThreadPerActorRuntimeLoop(PatternRewriter &rewriter,
                                               Location loc, Block &networkBody,
                                               Block *entryBlock) {
  // Step 1: Ensure usleep is declared in the module for progress monitoring
  declareUsleepFunction(rewriter, loc, entryBlock);

  // Step 2: Group actors by device_affinity
  auto actorGroups = groupActorCallsByAffinity(networkBody);
  int numThreads = actorGroups.size();

  // Step 3: Create and initialize synchronization flags
  auto [terminationFlag, progressFlags, _] =
      createActorSynchronizationFlags(rewriter, loc, networkBody, numThreads);

  // Step 4: Wrap all actor groups in async.execute blocks and collect their
  // tokens
  SmallVector<Value> asyncTokens = wrapActorGroupsInAsyncExecute(
      rewriter, loc, actorGroups, terminationFlag, progressFlags);

  // Step 5: Create the progress monitoring loop that checks actor progress
  createProgressMonitoringLoop(rewriter, loc, numThreads, terminationFlag,
                               progressFlags);

  // Step 6: Wait for all async tokens to ensure all actor threads complete
  for (Value token : asyncTokens) {
    rewriter.create<async::AwaitOp>(loc, token);
  }

  // Reset insertion point to continue building the main function
  rewriter.setInsertionPointToEnd(entryBlock);
}

/// Converts a `cal.network` operation into a top-level `func.func @main`
/// function.
///
/// In the CAL dialect, `cal.network` defines the top-level structure of the
/// actor-based computation, including actor instances, FIFO channels, and
/// initial constants. This transformation lowers the network into an executable
/// main function as follows:
///
/// - All top-level constant values are lowered to standard `arith.constant`
/// operations.
/// - FIFO channels created with `fifo.create` are preserved as-is, with
/// appropriate result SSA values.
/// - `fifo.print` operations are lowered directly to their runtime equivalents.
/// - Each `cal.create_instance` is replaced with a call to a function
/// representing the actor, preserving operand and port associations.
///
/// The execution model depends on the selected actor partitioning mode:
///
/// **Single-threaded mode:**
/// Actor calls are wrapped in an `scf.while` loop that simulates round-robin
/// scheduling by re-invoking actor functions in each iteration. The boolean
/// return flag from each call indicates whether an action was successfully
/// fired. These flags are `OR`ed together to determine whether to continue
/// the loop, which continues as long as at least one actor reports progress.
///
/// **Multi-threaded mode (one-actor-per-thread):**
/// Actors are grouped by their `device_affinity` attribute. Actors with the
/// same affinity execute sequentially in the same thread, while actors without
/// affinity each get their own thread. Each group is wrapped in its own
/// `async.execute` block containing an infinite loop. A separate monitoring
/// loop tracks progress across all groups using atomic flags and coordinates
/// termination when no group makes progress.
///
/// Example Input:
/// ```
/// cal.network {
///   %0 = arith.constant 11 : i32
///   %1 = arith.constant 12 : i32
///
///   %in0, %out0 = fifo.create<i32>(3) : !fifo.input_port<i32>,
///       !fifo.output_port<i32> %in1, %out1 = fifo.create<i32>(3) :
///       !fifo.input_port<i32>, !fifo.output_port<i32>
///
///   fifo.print("start\n\00")
///
///   cal.create_instance @src "srcA" (%0: i32)
///       ports_out(%in0 : !fifo.input_port<i32>)
///
///   cal.create_instance @src "srcB" (%1: i32)
///       ports_out(%in1 : !fifo.input_port<i32>)
/// }
/// ```
///
/// Example Output (single-threaded mode):
/// ```
/// func.func @main() {
///   %true = arith.constant true
///   %c11_i32 = arith.constant 11 : i32
///   %c12_i32 = arith.constant 12 : i32
///
///   %inputPort, %outputPort = fifo.create<i32>(3) : !fifo.input_port<i32>,
///       !fifo.output_port<i32>
///   %inputPort_0, %outputPort_1 = fifo.create<i32>(3) :
///       !fifo.input_port<i32>, !fifo.output_port<i32>
///
///   fifo.print("start\0A\00")
///
///   scf.while (%arg0 = %true) : (i1) -> () {
///     scf.condition(%arg0)
///   } do {
///     %0 = func.call @src(%c11_i32, %inputPort) {from_create_instance} : (i32,
///        !fifo.input_port<i32>) -> i1
///     %1 = func.call @src(%c12_i32, %inputPort_0) {from_create_instance} :
///        (i32, !fifo.input_port<i32>) -> i1
///     %2 = arith.ori %1, %0 : i1
///     scf.yield %2 : i1
///   }
///   return
/// }
/// ```
struct ConvertCalNetworkToMainFunc : public OpRewritePattern<cal::NetworkOp> {

  ActorPartitioningMode partitioningMode;

  ConvertCalNetworkToMainFunc(MLIRContext *context, ActorPartitioningMode mode)
      : OpRewritePattern<cal::NetworkOp>(context), partitioningMode(mode) {}

  LogicalResult matchAndRewrite(cal::NetworkOp op,
                                PatternRewriter &rewriter) const override {

    // Verify that all cal.create_instance ops have been converted to func.call.
    // This pattern expects to process only the lowered representation.
    for (Operation &innerOp : op.getBody().front()) {
      if (mlir::isa<cal::CreateInstanceOp>(innerOp)) {
        return failure();
      }
    }

    mlir::Location loc = op.getLoc();
    auto functionType = rewriter.getFunctionType({}, {});
    auto function = rewriter.create<func::FuncOp>(loc, "main", functionType);
    Block *entryBlock = function.addEntryBlock();
    rewriter.setInsertionPointToStart(entryBlock);

    // Handle empty network - create a minimal main function
    if (op.getBody().empty()) {
      rewriter.create<func::ReturnOp>(function.getLoc());
      rewriter.replaceOp(op, function);
      return success();
    }

    Block &networkBody = op.getBody().front();

    // Step 1: Move initialization operations (constants, FIFO creation, prints)
    // into the main function entry block before the scheduling loop.
    // Actor function calls (marked with "from_create_instance") are skipped
    // and will be processed in Step 2.
    auto beginIt = networkBody.begin();
    auto endIt = networkBody.end();

    for (auto it = beginIt; it != endIt;) {
      Operation &opToMove = *it;
      // Increment iterator before moving to avoid invalidation
      ++it;

      // Skip actor calls - these go into the scheduling loop
      if (auto callOp = llvm::dyn_cast<func::CallOp>(opToMove)) {
        if (callOp->hasAttr("from_create_instance")) {
          continue;
        }
      }

      opToMove.moveBefore(entryBlock, entryBlock->end());
    }

    // Step 2: Create the scheduling loop based on partitioning mode
    if (partitioningMode == ActorPartitioningMode::Singlethreaded) {
      createSingleThreadedRoundRobinLoop(rewriter, loc, networkBody,
                                         entryBlock);
    } else if (partitioningMode == ActorPartitioningMode::Multithreaded) {
      createOneThreadPerActorRuntimeLoop(rewriter, loc, networkBody,
                                         entryBlock);
    } else {
      // This should never happen due to validation in parsePartitioningMode,
      // but handle defensively
      return failure();
    }

    // Step 3: Add the return terminator to complete the main function
    rewriter.setInsertionPointToEnd(entryBlock);
    rewriter.create<func::ReturnOp>(function.getLoc());

    rewriter.replaceOp(op, function);

    return success();
  }
};

/// Converts a `cal.actor` operation into a standard `func.func`. In this
/// conversion, the actor's execution body is lowered to the function body, and
/// all inputs (including state variables and ports) are passed as function
/// arguments.
///
/// The result of the `cal.action_done` is returned from the function as an
/// `i1`, preserving the actor's indication of whether an action fired (`true`)
/// or not (`false`).
///
/// Note: This conversion assumes that any state variable initializations have
/// already been hoisted out of the actor via the `hoistCalStateOutOfActor`
/// pass, so the actor contains only execution logic.
///
/// Example:
/// Input:
/// cal.actor @src(%max_tokens_to_send: i32)
///     ports_out(%out0: !fifo.input_port<i32>)
/// {
///     cal.execution_body {
///         fifo.print("Hi\0A\00")
///         %true = arith.constant 1 : i1
///         cal.action_done %true : i1
///     }
/// }
///
/// Output:
/// func.func @src(%arg0: i32, %arg1: !fifo.input_port<i32>) -> i1 {
///     %true = arith.constant true
///     fifo.print("Hi\0A\00")
///     return %true : i1
/// }
class ConvertCalActorToFunc : public OpRewritePattern<cal::ActorOp> {
  using OpRewritePattern::OpRewritePattern;

  LogicalResult matchAndRewrite(cal::ActorOp op,
                                PatternRewriter &rewriter) const override {
    mlir::Location loc = op.getLoc();

    mlir::Region &actorBody = op.getBody();

    // 1. Generate the function signature for the actor.
    auto i1ReturnType = rewriter.getIntegerType(1);
    auto argumentTypes = actorBody.getArgumentTypes();
    auto functionType = rewriter.getFunctionType(argumentTypes, {i1ReturnType});
    auto function =
        rewriter.create<func::FuncOp>(loc, op.getSymName(), functionType);

    // 2. Create and populate the entry block of the function.
    Block *entryBlock = function.addEntryBlock();

    rewriter.setInsertionPointToStart(entryBlock);

    // 2.1 We need to map the original actor body arguments to the
    // function arguments. This is necessary to ensure that the cloned
    // operations in the actor body can refer to the correct function arguments.
    IRMapping originalToClonedOperandsMap;
    originalToClonedOperandsMap.map(actorBody.getArguments(),
                                    function.getBody().getArguments());

    // 2.2 Iterate through the operations in the actor body and clone them
    // into the function body, using the mapping created above.
    auto beginIt = actorBody.op_begin();
    auto endIt = actorBody.op_end();
    bool hasExecutionBody = false;
    for (auto it = beginIt; it != endIt; ++it) {
      Operation &opToClone = *it; // reference to the operation

      // Most operations can be cloned directly
      if (!mlir::isa<cal::ExecutionBody>(opToClone)) {
        rewriter.clone(opToClone, originalToClonedOperandsMap);
      } else {
        hasExecutionBody = true;
        // The last operation in the body can be an ExecutionBody it contains
        // a region with the actual execution logic. We need to clone all the
        // instructions in this region into the function body.
        auto execBodyOp = mlir::cast<cal::ExecutionBody>(opToClone);
        auto beginExecBodyIt = execBodyOp.getBody().op_begin();
        auto endExecBodyIt = execBodyOp.getBody().op_end();
        for (auto itExecBody = beginExecBodyIt; itExecBody != endExecBodyIt;
             ++itExecBody) {
          Operation &opToCloneInExecBody =
              *itExecBody; // reference to the operation
          rewriter.clone(opToCloneInExecBody, originalToClonedOperandsMap);
        }
      }
    }

    // 3.3 If there is no execution body, we need to create a terminator for the
    // function
    if (!hasExecutionBody) {
      auto falseVal = rewriter.create<mlir::arith::ConstantOp>(
          loc, rewriter.getBoolAttr(false));
      rewriter.create<func::ReturnOp>(loc, falseVal.getResult());
    }

    rewriter.replaceOp(op, function);

    return success();
  }
}; // namespace mlir

/// Converts a `cal.action_done` terminator into a `func.return` terminator.
///
/// In the CAL dialect, `cal.action_done` marks the completion of an action and
/// must return a single boolean value. This flag indicates whether the action
/// successfully fired (`true`) or not (`false`). When lowering CAL actors to
/// standard MLIR functions, this operation is translated into a `func.return`,
/// returning the flag from the function.
///
/// Example:
///   Input:
///     %true = arith.constant 1 : i1
///     cal.action_done %true : i1
///
///   Output:
///     %true = arith.constant 1 : i1
///     return %true : i1
class ConvertCalTerminatorToFuncTerminator
    : public OpRewritePattern<cal::ActionDoneOp> {
  using OpRewritePattern::OpRewritePattern;

  LogicalResult matchAndRewrite(cal::ActionDoneOp op,
                                PatternRewriter &rewriter) const override {
    auto funcTerminator =
        rewriter.create<func::ReturnOp>(op.getLoc(), op.getOperand());
    rewriter.replaceOp(op, funcTerminator);

    return success();
  }
};

/// Converts a `cal.create_instance` operation into a direct `func.call`.
///
/// A `cal.create_instance` op is used in CAL to create an instance
/// of an actor function, passing initial arguments and port bindings. This
/// conversion lowers it to a simple `func.call` to the actor function.
///
/// Example:
///   Input:
///     cal.create_instance @src "srcA" (%0: i32)
///         ports_out(%in0 : !fifo.input_port<i32>)
///
///   Output:
///     %0 = func.call @src(%c11_i32, %inputPort) {from_create_instance}
///           : (i32, !fifo.input_port<i32>) -> i1
///
/// This transformation preserves the original argument ordering and annotations
/// any generated call with the `{from_create_instance}` attribute to trace
/// provenance during further lowering or analysis.
///
/// Note: Port direction (`ports_out`, `ports_in`, etc.) is flattened here and
/// all port values are passed directly to the function call.
class ConvertCalCreateInstanceToFuncCall
    : public OpRewritePattern<cal::CreateInstanceOp> {
  using OpRewritePattern::OpRewritePattern;

  LogicalResult matchAndRewrite(cal::CreateInstanceOp op,
                                PatternRewriter &rewriter) const override {
    Type i1ReturnType = rewriter.getI1Type();
    SmallVector<Type, 1> resultTypes{i1ReturnType};

    auto funcCall = rewriter.create<func::CallOp>(
        op.getLoc(), op.getActorRef(), resultTypes, op.getOperands());

    funcCall->setAttr("from_create_instance", rewriter.getUnitAttr());
    if (auto deviceAffinity = op.getDeviceAffinityAttr()) {
      funcCall->setAttr("device_affinity", deviceAffinity);
    }

    rewriter.eraseOp(op);
    return success();
  }
};

/// This pass defines the `ConvertCalToFuncPass`, which lowers the CAL dialect
/// to the Func dialect to enable further lowering to LLVM.
///
/// Specifically, this pass performs the following rewrites:
///   - `cal.actor` ops are converted to `func.func` functions. The actor's
///     state and initialization logic are encoded as function arguments and
///     instructions within the function body.
///   - `cal.create_instance` ops are replaced with `func.call` ops, invoking
///     the corresponding actor function. An attribute is added to mark these
///     calls as originating from actor instantiation.
///   - `cal.action_done` ops are converted to `func.return` ops, returning a
///     boolean flag that indicates whether the actor performed any action.
///   - The top-level `cal.network` op is rewritten into a `func.func` named
///     "main". This function executes any one-time initialization logic and
///     contains either a single-threaded round-robin scheduling loop or a
///     multi-threaded execution model with async.execute blocks and progress
///     monitoring, depending on the selected actor partitioning mode.
///
///
/// This pass enables the transformation of a CAL program into a purely
/// `func`-based representation, which is directly compatible with downstream
/// LLVM-based code generation.
class ConvertCalToFuncPass
    : public impl::ConvertCalToFuncBase<ConvertCalToFuncPass> {
public:
  ConvertCalToFuncPass(const ConvertCalToFuncOptions &options)
      : impl::ConvertCalToFuncBase<ConvertCalToFuncPass>(options) {}

  ConvertCalToFuncPass() {}

  void runOnOperation() final {

    ActorPartitioningMode partitioningMode =
        parsePartitioningMode(actor_paritioning_mode);

    // 1. Check if the module contains any `cal.action` operations.
    // If it does, we cannot convert the module to func, as `cal.action` is
    // not supported here. Emit an error and signal pass failure.
    Operation *module = getOperation();
    module->walk([&](cal::ActorOp actor) {
      for (Block &block : actor.getBody()) {
        for (Operation &op : block) {
          if (isa<cal::ActionOp>(op)) {
            actor.emitError("cal.actor contains cal.action - cannot convert to "
                            "func dialect. Only actors with cal.execution_body "
                            "are valid in this pass");
            signalPassFailure();
            return WalkResult::interrupt(); // Stop walking
          }
        }
      }
      return WalkResult::advance();
    });

    // 2. If the module does not contain any `cal.action` operations, we can
    // proceed with the conversion to func operations
    RewritePatternSet patterns(&getContext());
    patterns.add<ConvertCalActorToFunc>(&getContext());
    patterns.add<ConvertCalTerminatorToFuncTerminator>(&getContext());
    patterns.add<ConvertCalCreateInstanceToFuncCall>(&getContext());
    patterns.add<ConvertCalNetworkToMainFunc>(&getContext(), partitioningMode);

    if (failed(applyPatternsGreedily(getOperation(), std::move(patterns)))) {
      signalPassFailure();
    }
  }
};

} // namespace mlir