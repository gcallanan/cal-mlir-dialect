#include "mlir/Dialect/Arith/IR/Arith.h"
#include "mlir/Dialect/Bufferization/IR/Bufferization.h"
#include "mlir/Dialect/Func/IR/FuncOps.h"
#include "mlir/Dialect/GPU/IR/GPUDialect.h"
#include "mlir/Dialect/MemRef/IR/MemRef.h"
#include "mlir/Dialect/SCF/IR/SCF.h"
#include "mlir/Dialect/Tensor/IR/Tensor.h"
#include "mlir/IR/BuiltinOps.h"
#include "mlir/IR/PatternMatch.h"
#include "mlir/Pass/Pass.h"
#include "mlir/Rewrite/FrozenRewritePatternSet.h"
#include "mlir/Transforms/DialectConversion.h"
#include "mlir/Transforms/GreedyPatternRewriteDriver.h"

// clang-format off
// For some reason, the include order matters here
// TODO: Investigate why this is the case
#include "Transforms/Passes.h"
#include "Transforms/CalPrepareGpuAsyncRegions/CalPrepareGpuAsyncRegions.h"
// clang-format on

namespace mlir {

#define GEN_PASS_DEF_CALPREPAREGPUASYNCREGIONSPASS
#include "Transforms/Passes.h.inc"

/// Converts all GPU operations within the given block to execute
/// asynchronously, using the provided token for synchronization. Returns a new
/// token representing the completion of all asynchronous GPU operations in the
/// block.
///
/// \param block The block containing GPU operations to be made asynchronous.
/// \param rewriter The pattern rewriter used to apply transformations.
/// \param token The initial token to chain asynchronous execution.
/// \return A Value representing the token after all asynchronous GPU
/// operations.
static Value makeGpuOpsInBlockAsynchronous(Block &block,
                                           PatternRewriter &rewriter,
                                           Value token);

/// Transforms the given scf::IfOp into an asynchronous operation by associating
/// it with the provided token.
///
/// \param ifOp The scf::IfOp to be made asynchronous.
/// \param rewriter The PatternRewriter used to perform IR modifications.
/// \param token The async token to associate with the IfOp.
/// \return The new Value representing the asynchronous IfOp.
static Value makeIfOpAsynchronous(scf::IfOp ifOp, PatternRewriter &rewriter,
                                  Value token);

/// Makes a gpu.alloc op asynchronous by cloning it with an async dependency and
/// returning the new async token.
///
/// \param allocOp The gpu.alloc operation to be made asynchronous.
/// \param asyncToken The async token to use as a dependency.
/// \param rewriter The pattern rewriter used to perform IR modifications.
/// \return The new async token produced by the asynchronous alloc op.
static Value makeGpuAllocOpAsynchronous(gpu::AllocOp allocOp, Value asyncToken,
                                        PatternRewriter &rewriter) {
  rewriter.setInsertionPoint(allocOp);
  auto loc = allocOp.getLoc();
  auto type = allocOp.getType();
  auto dynSizes = allocOp.getDynamicSizes();
  auto symbolOperands = allocOp.getSymbolOperands();
  auto tokenType = asyncToken.getType();
  auto newAllocOp = rewriter.create<mlir::gpu::AllocOp>(
      loc, type, tokenType, ValueRange{asyncToken}, dynSizes, symbolOperands,
      allocOp.getHostShared());
  // Copy all attributes except those set by the builder.
  for (auto attr : allocOp->getAttrs()) {
    if (attr.getName() != "operandSegmentSizes")
      newAllocOp->setAttr(attr.getName(), attr.getValue());
  }
  rewriter.replaceOp(allocOp, newAllocOp.getMemref());
  return newAllocOp.getAsyncToken();
}

/// Makes a gpu.dealloc op asynchronous by cloning it with an async dependency
/// and returning the new async token.
///
/// \param deallocOp The gpu.dealloc operation to be made asynchronous.
/// \param asyncToken The async token to use as a dependency.
/// \param rewriter The pattern rewriter used to perform IR modifications.
/// \return The new async token produced by the asynchronous alloc op.
static Value makeGpuDeallocOpAsynchronous(gpu::DeallocOp deallocOp,
                                          Value asyncToken,
                                          PatternRewriter &rewriter) {
  // llvm::outs() << "Making gpu.dealloc asynchronous\n";
  // llvm::outs() << deallocOp << "\n";
  rewriter.setInsertionPoint(deallocOp);
  auto loc = deallocOp.getLoc();
  auto tokenType = asyncToken.getType();
  auto newDeallocOp = rewriter.create<mlir::gpu::DeallocOp>(
      loc, tokenType, ValueRange{asyncToken}, deallocOp.getMemref());
  // llvm::outs() << newDeallocOp << "\n";
  // Copy all attributes except those set by the builder.
  for (auto attr : newDeallocOp->getAttrs()) {
    if (attr.getName() != "operandSegmentSizes")
      newDeallocOp->setAttr(attr.getName(), attr.getValue());
  }
  // rewriter.replaceOp(allocOp, newAllocOp.getMemref());
  rewriter.eraseOp(deallocOp);
  return newDeallocOp.getAsyncToken();
}

/// Makes a gpu.memcpy op asynchronous by cloning it with an async dependency
/// and returning the new async token.
///
/// This function attempts to detect if the memcpy destination is on the device
/// by checking if the destination memref is used by a memref::LoadOp. If so,
/// it inserts a synchronous gpu.wait after the memcpy to ensure proper
/// synchronization between device and host.
///
/// Note: This detection is a rough heuristic and is not robust for all cases.
/// A more precise analysis of memory spaces and data flow would improve
/// correctness.
///
/// \param memcpyOp The gpu.memcpy operation to be made asynchronous.
/// \param asyncToken The async token to use as a dependency.
/// \param rewriter The pattern rewriter used to perform IR modifications.
/// \return The new async token produced by the asynchronous memcpy op.
static Value makeGpuMemcpyOpAsynchronous(gpu::MemcpyOp memcpyOp,
                                         Value asyncToken,
                                         PatternRewriter &rewriter) {
  rewriter.setInsertionPoint(memcpyOp);
  // 1. Determine if the destination is on the host.
  // If it is, we need to synchronize after the memcpy.
  bool isOnHost = false;
  for (auto &use : memcpyOp.getDst().getUses()) {
    if (isa<memref::LoadOp>(use.getOwner())) {
      isOnHost = true;
      break;
    }
  }

  // 2. Create a new gpu.memcpy op with the difference being the async token.
  auto newMemcpy = rewriter.create<gpu::MemcpyOp>(
      memcpyOp.getLoc(), asyncToken.getType(), ValueRange{asyncToken},
      memcpyOp.getDst(), memcpyOp.getSrc());
  Value outToken = newMemcpy.getAsyncToken();

  // 3. If the destination is on host, we need to synchronize.
  if (isOnHost) {
    // Synchronize if the memcpy destination is on host
    rewriter.create<mlir::gpu::WaitOp>(memcpyOp.getLoc(), Type{},
                                       ValueRange{outToken});
    auto waitOp = rewriter.create<mlir::gpu::WaitOp>(
        memcpyOp.getLoc(), outToken.getType(), ValueRange{});
    outToken = waitOp.getAsyncToken();
  }

  // 4. Erase the old memcpy op and return the new async token.
  rewriter.eraseOp(memcpyOp);
  return outToken;
}

// Copied and modified from AsyncRegionRewriter.cpp
static Value makeGpuLaunchOpAsynchronous(gpu::LaunchFuncOp launchOp,
                                         Value asyncToken,
                                         PatternRewriter &rewriter) {
  rewriter.setInsertionPoint(launchOp);
  mlir::gpu::KernelDim3 gridSize{launchOp.getGridSizeX(),
                                 launchOp.getGridSizeY(),
                                 launchOp.getGridSizeZ()};
  mlir::gpu::KernelDim3 blockSize{launchOp.getBlockSizeX(),
                                  launchOp.getBlockSizeY(),
                                  launchOp.getBlockSizeZ()};
  std::optional<mlir::gpu::KernelDim3> clusterSize;
  if (launchOp.getClusterSizeX()) {
    clusterSize = mlir::gpu::KernelDim3{launchOp.getClusterSizeX(),
                                        launchOp.getClusterSizeY(),
                                        launchOp.getClusterSizeZ()};
  }
  auto newOp = rewriter.create<gpu::LaunchFuncOp>(
      launchOp.getLoc(), launchOp.getKernel(), gridSize, blockSize,
      launchOp.getDynamicSharedMemorySize(), launchOp.getKernelOperands(),
      asyncToken.getType(), ValueRange{asyncToken}, clusterSize);
  // Copy only safe/needed attributes (avoid those that are auto-generated or
  // segment-related)
  for (auto attr : launchOp->getAttrs()) {
    if (attr.getName() != "operandSegmentSizes")
      newOp->setAttr(attr.getName(), attr.getValue());
  }
  rewriter.eraseOp(launchOp);
  return newOp.getAsyncToken();
}

/// Updates a func.call operation to take and return a gpu.async.token.
///
/// This function appends the provided gpu.async.token to the operands of the
/// call, updates the result types to include the token, and replaces the
/// original call with a new one. All uses of the original call's results
/// (except the token) are redirected to the new call's results. The new async
/// token is returned.
///
/// \param rewriter The pattern rewriter used to perform IR modifications.
/// \param callOp The func.call operation to update.
/// \param gpuToken The gpu.async.token to pass as an operand.
/// \return The new async token produced by the updated call.
static Value updateFuncCallWithGpuToken(PatternRewriter &rewriter,
                                        func::CallOp callOp, Value gpuToken) {
  // 1. Prepare new operands: existing + gpuToken
  SmallVector<Value, 8> newOperands(callOp.getOperands().begin(),
                                    callOp.getOperands().end());
  newOperands.push_back(gpuToken);

  // 2. Prepare new result types: existing + token
  SmallVector<Type, 8> newResultTypes(callOp.getResultTypes().begin(),
                                      callOp.getResultTypes().end());
  auto tokenType = mlir::gpu::AsyncTokenType::get(callOp.getContext());
  newResultTypes.push_back(tokenType);

  // 3. Replace the call with a new call that takes/returns the token
  auto newCall = rewriter.create<func::CallOp>(
      callOp.getLoc(), callOp.getCallee(), newResultTypes, newOperands);

  // Replace all uses of the old call results (except the token)
  for (auto it : llvm::zip(callOp.getResults(), newCall.getResults().take_front(
                                                    callOp.getNumResults()))) {
    std::get<0>(it).replaceAllUsesWith(std::get<1>(it));
  }

  // Erase the old call
  rewriter.eraseOp(callOp);

  // Return the new token result (last result)
  return newCall.getResults().back();
}

/// Transforms the given scf::IfOp into an asynchronous operation by associating
/// it with the provided token.
///
/// This function creates a new scf::IfOp with an additional result and argument
/// for a gpu.async.token. It updates the then and else blocks to propagate the
/// async token, and rewrites the scf.yield statements in both branches to yield
/// the new token along with any existing values.
///
/// Before transformation:
/// ```mlir
/// %res = scf.if %cond -> (i1) {
///   %token1 = gpu.launch_func ...
///   %token2 = gpu.memcpy %dst, %src : memref<...>, memref<...>
///   scf.yield %some_value : i1
/// } else {
///   %token3 = gpu.memcpy %dst2, %src2 : memref<...>, memref<...>
///   gpu.wait [%token3]
///   scf.yield %other_value : i1
/// }
/// ```
///
/// After transformation:
/// ```mlir
/// %res:2 = scf.if %cond -> (i1, !gpu.async.token) {
///   %token1 = gpu.launch_func async [%input_token] ...
///   %token2 = gpu.memcpy async [%token1] %dst, %src : memref<...>, memref<...>
///   scf.yield %some_value, %token2 : i1, !gpu.async.token
/// } else {
///   %token3 = gpu.memcpy async [%input_token] %dst2, %src2 : memref<...>,
///   memref<...> gpu.wait [%token3] %token4 = gpu.wait async scf.yield
///   %other_value, %token4 : i1, !gpu.async.token
/// }
/// ```
///
/// \param ifOp The scf::IfOp to be made asynchronous.
/// \param rewriter The PatternRewriter used to perform IR modifications.
/// \param token The async token to associate with the IfOp.
/// \return The new Value
static Value makeIfOpAsynchronous(scf::IfOp ifOp, PatternRewriter &rewriter,
                                  Value token) {

  // 1. Prepare the new ifOp with an extra result type: gpu.async.token as well
  // as an extra argument in the then/else regions.
  auto tokenType = mlir::gpu::AsyncTokenType::get(ifOp.getContext());
  SmallVector<Type, 4> newResultTypes(ifOp.getResultTypes());
  newResultTypes.push_back(tokenType);

  rewriter.setInsertionPoint(ifOp);
  bool hasElseRegion = !ifOp.getElseRegion().empty();
  auto newIfOp = rewriter.create<scf::IfOp>(ifOp.getLoc(), newResultTypes,
                                            ifOp.getCondition(), hasElseRegion);

  // 2. Add the gpu.async.token argument to the then region and yield a token
  // 2. Add the gpu.async.token argument to the then region and yield a token
  Value thenToken = token;
  for (auto &block : ifOp.getThenRegion()) {
    thenToken = makeGpuOpsInBlockAsynchronous(block, rewriter, token);
  }
  rewriter.inlineRegionBefore(ifOp.getThenRegion(), newIfOp.getThenRegion(),
                              newIfOp.getThenRegion().begin());

  auto &thenBlock = newIfOp.getThenRegion().front();
  auto *thenTerminator = thenBlock.getTerminator();
  if (auto thenYield = dyn_cast<scf::YieldOp>(thenTerminator)) {
    SmallVector<Value, 4> newThenYieldOperands(thenYield.getOperands().begin(),
                                               thenYield.getOperands().end());
    newThenYieldOperands.push_back(thenToken);
    rewriter.setInsertionPoint(thenYield);
    rewriter.replaceOpWithNewOp<scf::YieldOp>(thenYield, newThenYieldOperands);
  }

  // 3. Add the gpu.async.token argument to the else region and yield a token
  if (hasElseRegion) {
    // Move else-region blocks
    Value elseToken = token;
    for (auto &block : ifOp.getElseRegion()) {
      token = makeGpuOpsInBlockAsynchronous(block, rewriter, token);
    }
    rewriter.inlineRegionBefore(ifOp.getElseRegion(), newIfOp.getElseRegion(),
                                newIfOp.getElseRegion().begin());

    auto &elseBlock = newIfOp.getElseRegion().front();
    auto *elseTerminator = elseBlock.getTerminator();
    auto elseYield = dyn_cast<scf::YieldOp>(elseTerminator);
    if (elseYield) {
      SmallVector<Value, 4> newElseYieldOperands(
          elseYield.getOperands().begin(), elseYield.getOperands().end());
      newElseYieldOperands.push_back(elseToken);
      rewriter.setInsertionPoint(elseYield);
      rewriter.replaceOpWithNewOp<scf::YieldOp>(elseYield,
                                                newElseYieldOperands);
    }

  } else {
    // If there is no else region, we still need to create an empty one
    newIfOp.getElseRegion().push_back(new Block());
    rewriter.setInsertionPointToEnd(&newIfOp.getElseRegion().front());
    rewriter.create<scf::YieldOp>(ifOp.getLoc(), token);
  }

  // 4. Replace the old ifOp with the new one
  rewriter.replaceOp(ifOp, newIfOp.getResults().drop_back());
  return newIfOp.getResults().back(); // Return the new token
} // namespace mlir

/// Handles a single operation, making it asynchronous if needed.
///
/// This function dispatches to the appropriate helper based on the operation
/// type:
/// - gpu.memcpy: Makes the memcpy asynchronous and returns the new async token.
/// - scf.if: Converts the if operation to propagate and yield a
/// gpu.async.token.
/// - gpu.launch_func: Makes the launch asynchronous and returns the new async
/// token.
/// - gpu.alloc: Makes the allocation asynchronous and returns the new async
/// token. For unsupported operations, the input token is returned unchanged.
///
/// TODO: Handle additional operations such as scf.for, scf.while ops.
///
/// \param op The operation to potentially make asynchronous.
/// \param rewriter The pattern rewriter used to perform IR modifications.
/// \param token The async token to use as a dependency.
/// \return The new async token produced by the operation, or the input token if
/// unchanged.
static Value makeGpuOpsAsynchronous(Operation *op, PatternRewriter &rewriter,
                                    Value token) {
  if (auto memcpyOp = dyn_cast<mlir::gpu::MemcpyOp>(op)) {
    return makeGpuMemcpyOpAsynchronous(memcpyOp, token, rewriter);
  } else if (auto ifOp = dyn_cast<mlir::scf::IfOp>(op)) {
    return makeIfOpAsynchronous(ifOp, rewriter, token);
  } else if (auto launchFuncOp = dyn_cast<mlir::gpu::LaunchFuncOp>(op)) {
    return makeGpuLaunchOpAsynchronous(launchFuncOp, token, rewriter);
  } else if (auto allocOp = dyn_cast<mlir::gpu::AllocOp>(op)) {
    return makeGpuAllocOpAsynchronous(allocOp, token, rewriter);
  } else if (auto deallocOp = dyn_cast<mlir::gpu::DeallocOp>(op)) {
    return makeGpuDeallocOpAsynchronous(deallocOp, token, rewriter);
  }
  // TODO: Handle scf.for, scf.while ops
  return token;
}

// Converts all GPU-related operations within the given block to execute
// asynchronously,
/// chaining them using the provided async token for synchronization.
///
/// This function iterates over all operations in the block, dispatching each to
/// makeGpuOpsAsynchronous, and threads the async token through each operation
/// in order. The returned token represents the completion of all asynchronous
/// GPU operations in the block.
///
/// \param block The block containing GPU operations to be made asynchronous.
/// \param rewriter The pattern rewriter used to apply transformations.
/// \param token The initial token to chain asynchronous execution.
/// \return A Value representing the token after all asynchronous GPU
/// operations.
static Value makeGpuOpsInBlockAsynchronous(Block &block,
                                           PatternRewriter &rewriter,
                                           Value token) {
  // Copy operations to a separate container to allow safe modification.
  SmallVector<Operation *, 8> opsToIterate;
  for (auto &op : block)
    opsToIterate.push_back(&op);

  for (auto *op : opsToIterate) {
    token = makeGpuOpsAsynchronous(op, rewriter, token);
  }

  return token;
}

/// Updates a function to take and return a gpu.async.token for asynchronous GPU
/// coordination.
///
/// This function is intended for functions called within the main while loop.
/// It updates the function signature to accept an additional gpu.async.token
/// argument and to return a gpu.async.token as an extra result. All GPU
/// operations within the function are made asynchronous and chained using the
/// token, ensuring proper coordination of asynchronous execution on the GPU.
/// The function's return operation is also updated to yield the final async
/// token.
///
//// Example before:
/// ```mlir
/// func.func @accumulator(%arg0: i32, %arg1: memref<10x10xi32>) -> i1 {
///   %0 = gpu.launch_func @kernel ...
///   %1 = gpu.memcpy %arg1, %arg1 : memref<10x10xi32>, memref<10x10xi32>
///   return %true : i1
/// }
/// ```
///
/// Example after:
/// ```mlir
/// func.func @accumulator(%arg0: i32, %arg1: memref<10x10xi32>, %token:
/// !gpu.async.token) -> (i1, !gpu.async.token) {
///   %0 = gpu.launch_func async [%token] @kernel ...
///   %1 = gpu.memcpy async [%0] %arg1, %arg1 : memref<10x10xi32>,
///   memref<10x10xi32> return %true, %1 : i1, !gpu.async.token
/// }
/// ```
///
/// \param funcOp The function to update.
/// \param rewriter The pattern rewriter used to perform IR modifications.
/// \return The updated function operation.
static func::FuncOp updateFuncWithGpuTokens(func::FuncOp funcOp,
                                            PatternRewriter &rewriter) {
  // 1. Add a new argument of type gpu.async.token to the function
  Block &entryBlock = funcOp.getBody().front();
  auto currentFuncType = funcOp.getFunctionType();
  SmallVector<Type, 8> newInputTypes(currentFuncType.getInputs().begin(),
                                     currentFuncType.getInputs().end());
  auto tokenType = mlir::gpu::AsyncTokenType::get(funcOp.getContext());
  newInputTypes.push_back(tokenType);
  BlockArgument tokenIn = entryBlock.addArgument(tokenType, funcOp.getLoc());

  // 2. Add a return value of type gpu.async.token
  SmallVector<Type, 8> newResultTypes(currentFuncType.getResults().begin(),
                                      currentFuncType.getResults().end());
  newResultTypes.push_back(tokenType);

  // 3. Find the return operation to be used later.
  func::ReturnOp returnOp = nullptr;
  for (auto &block : funcOp.getBody()) {
    if (auto ret = dyn_cast<func::ReturnOp>(block.getTerminator())) {
      returnOp = ret;
      break;
    }
  }

  // 4. Create the new func type with the updated inputs and results
  auto newFuncType = rewriter.getFunctionType(newInputTypes, newResultTypes);
  funcOp.setType(newFuncType);

  // 5. Make the body of the new func asnchronous
  Value gpuToken = makeGpuOpsInBlockAsynchronous(entryBlock, rewriter, tokenIn);

  // 6. Update the return operation to include the gpu.async.token
  rewriter.setInsertionPoint(returnOp);
  SmallVector<Value, 8> newOperands(returnOp.getOperands().begin(),
                                    returnOp.getOperands().end());
  newOperands.push_back(gpuToken);
  rewriter.replaceOpWithNewOp<func::ReturnOp>(returnOp, newOperands);

  return funcOp;
}

/// Updates the main function so that the main while loop passes and returns a
/// gpu.async.token, enabling asynchronous coordination of GPU operations across
/// loop iterations.
///
/// This function rewrites the main function to:
/// - Add a gpu.async.token as an extra argument and result to the main
/// scf.while loop.
/// - Thread the token through the loop's condition and body blocks.
/// - Update all func.call operations within the loop body (using
/// updateFuncWithGpuTokens) so that they take and return a gpu.async.token,
/// allowing GPU operations in called functions to be coordinated
/// asynchronously.
/// - Insert initial and intermediate gpu.wait ops as needed to produce and
/// synchronize the async token before and after the loop.
/// - Makes all operations before the while loop asynchronous (by threading an
/// async token), but synchronizes (waits) after each one to ensure completion.
/// This is done to support further passes that expect all GPU ops to be
/// asynchronous, even though these ops still execute synchronously from the
/// host's perspective.
///
/// Example before:
/// ```mlir
/// scf.while (%arg0 = %true) : (i1) -> () {
///   scf.condition(%arg0)
/// } do {
///   %1 = func.call @src(...) : (...) -> i1
///   %2 = func.call @accumulator(...) : (...) -> i1
///   %3 = arith.ori %2, %1 : i1
///   scf.yield %3 : i1
/// }
/// ```
///
/// Example after:
/// ```mlir
/// %10 = gpu.wait async
/// %11 = scf.while (%arg0 = %true, %arg1 = %10) : (i1, !gpu.async.token) ->
/// !gpu.async.token {
///   scf.condition(%arg0) %arg1 : !gpu.async.token
/// } do {
/// ^bb0(%arg0: !gpu.async.token):
///   %12:2 = func.call @src(..., %arg0) : (..., !gpu.async.token) -> (i1,
///   !gpu.async.token) %13:2 = func.call @accumulator(..., %12#1) : (...,
///   !gpu.async.token) -> (i1, !gpu.async.token) %14 = arith.ori %13#0, %12#0 :
///   i1 scf.yield %14, %13#1 : i1, !gpu.async.token
/// }
/// ```
///
/// \param rewriter The pattern rewriter used to perform IR modifications.
/// \param funcOp The main function to update.
/// \param callees The set of functions called within the main while loop that
/// should also be updated. \return LogicalResult indicating success or failure
/// of the transformation.
static LogicalResult
updateMainFuncWithGpuTokens(PatternRewriter &rewriter, func::FuncOp funcOp,
                            SmallVector<func::FuncOp, 8> &callees) {

  // 1. Find the last scf.WhileOp and check for early exit conditions
  scf::WhileOp lastWhileOp = nullptr;
  for (auto &block : funcOp.getBody()) {
    for (auto &op : block) {
      if (auto whileOp = dyn_cast<scf::WhileOp>(op)) {
        lastWhileOp = whileOp;
      } else if (auto waitOp = dyn_cast<mlir::gpu::WaitOp>(op)) {
        return failure();
      }
    }
  }
  if (!lastWhileOp) {
    return failure();
  }

  // 2. Update all operations before and after the last while op to have async
  // tokens but still wait on the host for the GPU asynchronous operations to
  // complete. We do this as later phases require all gpu operations to be
  // asynchronous. 2.1 Collect all operations before the last while op
  SmallVector<Operation *, 8> beforeOps;
  SmallVector<Operation *, 8> afterOps;
  bool beforeLastWhile = true;
  for (auto &block : funcOp.getBody()) {
    for (auto &op : block) {
      if (&op == lastWhileOp) {
        beforeLastWhile = false;
        continue;
      }
      if (beforeLastWhile) {
        beforeOps.push_back(&op);
      } else {
        afterOps.push_back(&op);
      }
    }
  }

  // 2.2 Insert an initial gpu.wait op to produce the first async token
  rewriter.setInsertionPointToStart(&funcOp.getBody().front());
  auto tokenType = mlir::gpu::AsyncTokenType::get(funcOp.getContext());
  auto initPhaseWait = rewriter.create<mlir::gpu::WaitOp>(
      funcOp.getLoc(), tokenType, ValueRange{});
  Value initPhaseToken = initPhaseWait.getAsyncToken();

  // 2.3 Make all ops before the while op asynchronous, synchronizing as needed
  for (auto *op : beforeOps) {
    auto *nextOp = op->getNextNode();
    Value newToken = makeGpuOpsAsynchronous(op, rewriter, initPhaseToken);
    if (newToken != initPhaseToken) {
      rewriter.setInsertionPoint(nextOp);
      rewriter.create<mlir::gpu::WaitOp>(funcOp.getLoc(), Type{},
                                         ValueRange{newToken});
      initPhaseWait = rewriter.create<mlir::gpu::WaitOp>(
          funcOp.getLoc(), tokenType, ValueRange{});
      initPhaseToken = initPhaseWait.getAsyncToken();
    }
  }

  // 2.4 Wait on the last token before the while loop
  rewriter.setInsertionPoint(lastWhileOp);
  rewriter.create<mlir::gpu::WaitOp>(funcOp.getLoc(), Type{},
                                     ValueRange{initPhaseToken});

  // 3. Update the last while loop to pass async tokens between the functions
  // 3.1. Create a new async token for the while loop
  rewriter.setInsertionPoint(lastWhileOp);
  auto waitOp = rewriter.create<mlir::gpu::WaitOp>(lastWhileOp.getLoc(),
                                                   /*asyncToken=*/tokenType,
                                                   /*operands=*/ValueRange{});
  Value token = waitOp.getAsyncToken();

  // 3.2. Create a new WhileOp with extra token argument/result
  SmallVector<Value, 8> newOperands(lastWhileOp.getOperands().begin(),
                                    lastWhileOp.getOperands().end());
  newOperands.push_back(token);
  SmallVector<Type, 8> newResultTypes(lastWhileOp.getResultTypes().begin(),
                                      lastWhileOp.getResultTypes().end());
  newResultTypes.push_back(tokenType);
  auto newWhileOp = rewriter.create<scf::WhileOp>(lastWhileOp.getLoc(),
                                                  newResultTypes, newOperands);

  // 3.3 Fill in the condition region
  {
    Block &condBlock = newWhileOp.getBefore().emplaceBlock();
    for (auto t : newWhileOp.getOperandTypes())
      condBlock.addArgument(t, lastWhileOp.getLoc());
    rewriter.setInsertionPointToEnd(&condBlock);
    rewriter.create<scf::ConditionOp>(lastWhileOp.getLoc(),
                                      condBlock.getArgument(0),
                                      condBlock.getArguments().drop_front());
  }

  // 3.4 Fill in the body region and propagate the token
  {
    Block &bodyBlock = newWhileOp.getAfter().emplaceBlock();
    for (auto it = std::next(newWhileOp.getOperandTypes().begin());
         it != newWhileOp.getOperandTypes().end(); ++it) {
      bodyBlock.addArgument(*it, lastWhileOp.getLoc());
    }
    Value gpuToken = bodyBlock.getArgument(0);
    rewriter.setInsertionPointToEnd(&bodyBlock);
    SmallVector<Value, 8> yieldOperands;
    auto *oldAfterBlock = lastWhileOp.getAfterBody();
    IRMapping mapping;
    for (auto &op : *oldAfterBlock) {
      if (isa<scf::YieldOp>(op)) {
        yieldOperands.push_back(mapping.lookupOrDefault(op.getOperand(0)));
        continue;
      }
      auto clonedOp = rewriter.clone(op, mapping);
    }
    SmallVector<Operation *, 8> opsToIterate;
    for (auto &op : bodyBlock)
      opsToIterate.push_back(&op);
    for (auto *op : opsToIterate) {
      if (auto callOp = dyn_cast<func::CallOp>(op)) {
        gpuToken = updateFuncCallWithGpuToken(rewriter, callOp, gpuToken);
      } else {
        op->moveBefore(rewriter.getInsertionBlock(),
                       rewriter.getInsertionPoint());
      }
    }
    yieldOperands.push_back(gpuToken);
    rewriter.create<scf::YieldOp>(lastWhileOp.getLoc(), yieldOperands);
  }

  // 4. Terminate while and make the ops after the while op asynchronous
  // 4.1 Insert a synchronous wait on the returned token if needed
  Value newToken = newWhileOp.getResults().back();
  rewriter.setInsertionPointAfter(newWhileOp);
  rewriter.create<mlir::gpu::WaitOp>(newWhileOp.getLoc(), Type{},
                                     ValueRange{newToken});

  auto cleanupPhaseWait = rewriter.create<mlir::gpu::WaitOp>(
      funcOp.getLoc(), tokenType, ValueRange{});
  Value cleanupPhaseToken = cleanupPhaseWait.getAsyncToken();

  // 4.2 Make all ops after the while op asynchronous, synchronizing as
  // needed
  for (auto *op : afterOps) {
    auto *nextOp = op->getNextNode();
    Value newToken = makeGpuOpsAsynchronous(op, rewriter, cleanupPhaseToken);
    if (newToken != cleanupPhaseToken) {
      rewriter.setInsertionPoint(nextOp);
      rewriter.create<mlir::gpu::WaitOp>(funcOp.getLoc(), Type{},
                                         ValueRange{newToken});
      cleanupPhaseWait = rewriter.create<mlir::gpu::WaitOp>(
          funcOp.getLoc(), tokenType, ValueRange{});
      cleanupPhaseToken = cleanupPhaseWait.getAsyncToken();
    }
  }

  // 4.3 Wait on the last token on all of the after ops
  rewriter.create<mlir::gpu::WaitOp>(funcOp.getLoc(), Type{},
                                     ValueRange{cleanupPhaseToken});

  rewriter.eraseOp(lastWhileOp);
  return success();
}

/// Pattern to update functions for asynchronous GPU coordination in the CAL
/// dialect.
///
/// This pattern is used to update the main function and its callees so that
/// they take and return a `gpu.async.token`, enabling asynchronous execution
/// and coordination of GPU operations across function boundaries. It works in
/// conjunction with the main transformation pass to ensure that all relevant
/// functions in the call graph are updated to propagate the async token.
///
/// The transformation process:
/// 1. **Main Function Update**: If the function is `@main`, rewrites the main
/// while loop and all preceding GPU ops to use and propagate a
/// `gpu.async.token`, updating call sites as needed.
/// 2. **Callee Update**: For each function called within the main while loop,
/// updates the function signature to take and return a `gpu.async.token`, and
/// rewrites the function body to thread the token through all GPU operations.
/// 3. Skips functions that have already been updated (i.e.,
/// already take a `gpu.async.token` argument).
///
/// This pattern is intended to be used as part of a rewrite pattern set in a
/// pass, and is applied greedily to ensure all relevant functions are updated
/// for asynchronous GPU execution.
///
/// Example:
/// ```mlir
/// func.func @main() { ... }
/// func.func @callee(...) { ... }
/// ```
///
/// After transformation:
/// ```mlir
/// func.func @main(...) { ... } // Now has gpu.async.tokens throughout
/// func.func @callee(..., !gpu.async.token) -> (..., !gpu.async.token) { ... }
struct UpdateFuncs : public OpRewritePattern<func::FuncOp> {
  SmallVector<func::FuncOp, 8> &callees;
  func::FuncOp mainFunction;

  UpdateFuncs(MLIRContext *ctx, SmallVector<func::FuncOp, 8> &calleesList,
              func::FuncOp main)
      : OpRewritePattern(ctx), callees(calleesList), mainFunction(main) {}

  LogicalResult matchAndRewrite(func::FuncOp funcOp,
                                PatternRewriter &rewriter) const override {

    // 1. Check if this function is the main function, if so update it
    // accordingly
    if (funcOp.getName() == "main") {
      return updateMainFuncWithGpuTokens(rewriter, funcOp, callees);
    }

    // 2. Deal with callee functions in the main function
    // 2.1 Check if this function is one of the callees
    // If not, we skip the update
    bool matched = false;
    for (const auto &callee : callees) {
      if (funcOp == callee) {
        matched = true;
        break;
      }
    }

    if (!matched) {
      return failure();
    }

    // 2.2 Check if the last argument is of type !gpu.async.token
    // We skip the update if this is the case as it has already been done
    auto &entryBlock = funcOp.getBody().front();
    if (!entryBlock.empty()) {
      auto lastArg = entryBlock.getArguments().back();
      if (mlir::isa<mlir::gpu::AsyncTokenType>(lastArg.getType())) {
        return failure();
      }
    }

    // 2.3 Update the function to have an additional gpu.async.token argument
    updateFuncWithGpuTokens(funcOp, rewriter);

    return success();
  }
};

/// Pass to prepare GPU regions for asynchronous execution in the CAL dialect.
///
/// This pass rewrites the main function and its callees to enable asynchronous
/// coordination of GPU operations using `gpu.async.token`. It transforms all
/// relevant GPU operations (such as `gpu.launch_func`, `gpu.memcpy`, and
/// `gpu.alloc`) to execute asynchronously, threads async tokens through
/// function calls and control flow, and updates the main while loop to pass
/// and return a `gpu.async.token`.
///
/// The transformation process:
/// 1. **Main Function Update**: Locates the `@main` function and rewrites its
///    main `scf.while` loop and all preceding GPU ops to use and propagate a
///    `gpu.async.token`, updating call sites as needed.
/// 2. **Callee Update**: For each function called within the main while loop,
///    updates the function signature to take and return a `gpu.async.token`,
///    and rewrites the function body to thread the token through all GPU
///    operations.
/// 3. **Async Token Propagation**: Ensures that all GPU operations in the
///    relevant call graph are made asynchronous and properly coordinated via
///    the async token, including updating `scf.if` and function call sites.
/// 4. **Idempotence**: Skips functions that have already been updated (i.e.,
///    already take a `gpu.async.token` argument).
///
/// This pass is intended for use in GPU-targeted pipelines where asynchronous
/// execution and coordination of GPU operations is required for performance or
/// correctness. It is typically run after outlining GPU regions and before
/// lowering to lower-level GPU dialects or code generation.
///
/// TODO: Extend support to other operations such as `scf.for`, `scf.while`
///
/// Example Input:
/// ```mlir
/// func.func @main() { ... }
/// func.func @callee(...) { ... }
/// ```
///
/// Example Output:
/// ```mlir
/// func.func @main(...) { ... } // main while loop and GPU ops now use async
/// tokens func.func @callee(..., !gpu.async.token) -> (..., !gpu.async.token) {
/// ... }
/// ```
class CalPrepareGpuAsyncRegionsPass
    : public impl::CalPrepareGpuAsyncRegionsPassBase<
          CalPrepareGpuAsyncRegionsPass> {
public:
  void runOnOperation() override {
    // Find the @main function
    mlir::func::FuncOp mainFunc = nullptr;
    getOperation()->walk([&](mlir::func::FuncOp funcOp) {
      if (funcOp.getName() == "main") {
        mainFunc = funcOp;
        return WalkResult::interrupt();
      }
      return WalkResult::advance();
    });

    if (!mainFunc) {
      // Skip the pass if no main function is found
      return;
    }

    // Find the last occurring scf::WhileOp directly under the main function
    scf::WhileOp lastWhileOp = nullptr;
    for (auto whileOp : mainFunc.getBody().front().getOps<scf::WhileOp>()) {
      lastWhileOp = whileOp;
    }
    if (!lastWhileOp) {
      // Skip the pass if no scf::WhileOp is found
      return;
    }

    // Collect all callee functions from the last while loop
    auto module = mainFunc->getParentOfType<ModuleOp>();
    SmallVector<func::FuncOp, 8> callees;
    for (auto funcCall : lastWhileOp.getAfterBody()->getOps<func::CallOp>()) {
      auto callee = module.lookupSymbol<func::FuncOp>(funcCall.getCallee());
      if (!callee) {
        mlir::emitError(funcCall.getLoc(), "Callee function not found: ")
            << funcCall.getCallee();
        signalPassFailure();
      }
      callees.push_back(callee);
    }

    auto *ctx = &getContext();

    // Set up and apply the pattern rewrite set
    RewritePatternSet patterns(ctx);
    patterns.add<UpdateFuncs>(ctx, callees, mainFunc);

    if (failed(applyPatternsAndFoldGreedily(getOperation(),
                                            std::move(patterns)))) {
      signalPassFailure();
      return;
    }
  }
};
} // namespace mlir