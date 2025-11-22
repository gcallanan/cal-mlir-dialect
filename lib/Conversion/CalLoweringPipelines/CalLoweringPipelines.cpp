#include "Conversion/CalLoweringPipelines/CalLoweringPipelines.h"

// MLIR Core
#include "mlir/IR/MLIRContext.h"
#include "mlir/InitAllDialects.h"
#include "mlir/InitAllExtensions.h"
#include "mlir/InitAllPasses.h"
#include "mlir/Pass/Pass.h"
#include "mlir/Pass/PassManager.h"
#include "mlir/Pass/PassRegistry.h"
#include "mlir/Support/FileUtilities.h"
#include "mlir/Tools/mlir-opt/MlirOptMain.h"
#include "mlir/Transforms/Passes.h"
#include "Transforms/Passes.h"

// MLIR Conversions
#include "mlir/Conversion/GPUToNVVM/GPUToNVVMPass.h"
#include "mlir/Conversion/UBToLLVM/UBToLLVM.h"
#include "mlir/Conversion/ComplexToStandard/ComplexToStandard.h"
#include "mlir/Conversion/ComplexToLLVM/ComplexToLLVM.h"

// MLIR Dialects and Transforms
#include "mlir/Dialect/Arith/Transforms/BufferDeallocationOpInterfaceImpl.h"
#include "mlir/Dialect/Arith/Transforms/BufferViewFlowOpInterfaceImpl.h"
#include "mlir/Dialect/Arith/Transforms/BufferizableOpInterfaceImpl.h"
#include "mlir/Dialect/Bufferization/IR/Bufferization.h"
#include "mlir/Dialect/Bufferization/Pipelines/Passes.h"
#include "mlir/Dialect/Bufferization/Transforms/FuncBufferizableOpInterfaceImpl.h"
#include "mlir/Dialect/Bufferization/Transforms/Passes.h"
#include "mlir/Dialect/GPU/IR/GPUDialect.h"
#include "mlir/Dialect/GPU/Pipelines/Passes.h"
#include "mlir/Dialect/GPU/Transforms/Passes.h"
#include "mlir/Dialect/Linalg/Transforms/AllInterfaces.h"
#include "mlir/Dialect/SCF/Transforms/BufferDeallocationOpInterfaceImpl.h"
#include "mlir/Dialect/SCF/Transforms/BufferizableOpInterfaceImpl.h"
#include "mlir/Dialect/Tensor/Transforms/BufferizableOpInterfaceImpl.h"
#include "mlir/Dialect/UB/IR/UBOps.h"

// MLIR LLVM Target Support
#include "mlir/Target/LLVMIR/Dialect/GPU/GPUToLLVMIRTranslation.h"
#include "mlir/Target/LLVMIR/Dialect/NVVM/NVVMToLLVMIRTranslation.h"

// Project-specific dialects
#include "Dialect/Cal/CalDialect.h"
#include "Dialect/Cal/CalPasses.h"
#include "Dialect/Fifo/BufferizableOpInterfaceImpl.h"
#include "Dialect/Fifo/FifoDialect.h"
#include "Dialect/Fifo/FifoPasses.h"

// Project-specific conversions and transformations
#define GEN_PASS_DECL_ELABORATECALCONNECTIONSPASS
#define GEN_PASS_DECL_FLATTENCALNETWORKSPASS
#include "Transforms/Passes.h.inc"
#undef GEN_PASS_DECL_ELABORATECALCONNECTIONSPASS
#undef GEN_PASS_DECL_FLATTENCALNETWORKSPASS
#include "Conversion/Passes.h"
#include "Transforms/Passes.h"
#define GEN_PASS_DECL_ELABORATECALCONNECTIONSPREPPASS
#define GEN_PASS_DECL_ELABORATECALCONNECTIONSFINALIZEPASS
#include "Transforms/Passes.h.inc"
#undef GEN_PASS_DECL_ELABORATECALCONNECTIONSPREPPASS
#undef GEN_PASS_DECL_ELABORATECALCONNECTIONSFINALIZEPASS

namespace mlir::cal {

void registerCalPipelines() {
  registerLowerCalToLLVMPipeline();
  registerLowerCalToLLVMWithStaticSchedulePipeline();
  registerLowerCalToLLVMWithGPUTensorsPipeline();
}

/**
 * Registers the pipeline for lowering FIFO and CAL dialects to the LLVM
 * dialect. This pipeline assumes all actors are not SDF or CSDF actors so makes
 * no assumptions about the static schedule of the actors.
 *
 * This function uses MLIR's inline pass pipeline registration to register a
 * pipeline with the name "lower-cal-to-llvm" and a brief description. The
 * pipeline first applies FIFO/CAL-specific passes (e.g. lowering FIFO to memref
 * and decomposing FIFO tuples) and then applies a series of passes to lower the
 * remaining standard MLIR dialects (SCF, Arith, MemRef, Func, etc.) into their
 * corresponding LLVM representations.
 *
 * For pass pipeline registration and instance-specific pass options see:
 *   https://mlir.llvm.org/docs/PassManagement/#pass-pipeline-registration
 *   https://mlir.llvm.org/docs/PassManagement/#instance-specific-pass-options
 * Example inline pipeline builders:
 *   llvm-project/mlir/lib/Dialect/Bufferization/Pipelines/BufferizationPipelines.cpp
 */
void registerLowerCalToLLVMPipeline() {
  mlir::PassPipelineRegistration<CalGenericPipelineOptions>(
      "lower-cal-to-llvm",
      "Pipeline lowering FIFO and CAL dialects to LLVM dialect.",
      [](mlir::OpPassManager &pm, const CalGenericPipelineOptions &options) {
        // 1. FIFO/CAL-specific lowering

        // First lower any cal.fsm schedules into a unified cal.execution_body.
        // Keep the standalone pass available separately; this just integrates
        // it into the default pipeline so users don't need to spell it out.
        pm.addPass(mlir::cal::lowerCalFsmToExecutionBody());

        // Early shape inference on dynamic memref state vars: specialize
        // create_state_var memref types when an initializing value provides
        // a fully-static shape. This reduces dynamic allocs and surfaces
        // missing size operand issues earlier.
        pm.addPass(mlir::createInferCalDynamicStateShapesPass());

        pm.addPass(mlir::cal::insertCalPortPredicates());
        // Convert any remaining cal.action-based actors (non-FSM actors)
        // into execution bodies.
        pm.addPass(mlir::cal::convertCalActionsToExecutionBodies());

        // Hoist actor state init out of actors so state persists across
        // scheduler iterations; selective rules inside the pass avoid
        // isolation violations for dynamic-sized states.
        pm.addPass(mlir::cal::hoistCalStateOutOfActor());
        pm.addPass(mlir::createCanonicalizerPass());

        // Honor pipeline option to drain actors by default (non-preemptive).
        pm.addPass(
            mlir::createConvertCalToFuncPass(options.nonPreemptiveDefault));

        // Convert complex ops to standard forms now that actors are functions.
        pm.addPass(mlir::createConvertComplexToStandardPass());

        // We add this pass as we often get functions that are the same but with
        // different names.
        pm.addPass(mlir::func::createDuplicateFunctionEliminationPass());

        pm.addPass(mlir::createLowerCalStateToMemref());
        pm.addPass(mlir::createLowerFifoToMemrefPass());
        pm.addPass(mlir::createDecomposeFifoTuples());
        pm.addPass(mlir::fifo::createLowerFifoPrintToLLVM());

        mlir::bufferization::OneShotBufferizationOptions bufferizeOptions;
        bufferizeOptions.bufferizeFunctionBoundaries = true;
        pm.addPass(
            mlir::bufferization::createOneShotBufferizePass(bufferizeOptions));
        if (!options.disableHoistAllocs)
          pm.addPass(mlir::createHoistAllocsPass());
        pm.addPass(mlir::createCanonicalizerPass());
        // BufferDeallocation is a function-only pass; add it as a nested pass
        pm.addNestedPass<mlir::func::FuncOp>(
            mlir::bufferization::createBufferDeallocationPass());
        pm.addPass(mlir::createCanonicalizerPass());
        pm.addPass(mlir::createConvertLinalgToLoopsPass());
        pm.addPass(mlir::createCanonicalizerPass());

        // Lower any remaining Affine operations to SCF before control-flow
        // conversion. We keep another LowerAffine pass later (after
        // memref::ExpandStridedMetadata) to clean up Affine ops that may be
        // introduced by that expansion.
        pm.addPass(mlir::createLowerAffinePass());

        // 2. Standard MLIR to LLVM lowering:
        //    The following passes lower various MLIR dialects to LLVM.
        //    (The ordering and combination of these passes follow similar
        //    pipelines as in the LLVM project, for example in
        //    TestLowertoLLVM.cpp.)

        // Convert SCF to CF (always needed).
        pm.addPass(mlir::createConvertSCFToCFPass());
        // Sprinkle some cleanups.
        pm.addPass(mlir::createCanonicalizerPass());
        pm.addPass(mlir::createCSEPass());

        // (Complex already lowered earlier; do not repeat here.)
        pm.addPass(mlir::createConvertComplexToLLVMPass());

        // Convert Math to LLVM (always needed).
        pm.addNestedPass<mlir::func::FuncOp>(
            mlir::createConvertMathToLLVMPass());
        // Expand complicated MemRef operations before lowering them.
        pm.addPass(mlir::memref::createExpandStridedMetadataPass());
        // The expansion may create affine expressions. Get rid of them.
        pm.addPass(mlir::createLowerAffinePass());
        // Convert MemRef to LLVM (always needed) – keep before
        // func/cf/arithmetic.
        pm.addPass(mlir::createFinalizeMemRefToLLVMConversionPass());
        // Convert Func to LLVM (always needed).
        pm.addPass(mlir::createConvertFuncToLLVMPass());
        // Convert Arith to LLVM (always needed).
        pm.addPass(mlir::createArithToLLVMConversionPass());
        // Convert CF to LLVM (always needed).
        pm.addPass(mlir::createConvertControlFlowToLLVMPass());
        // Convert Index to LLVM (always needed).
        pm.addPass(mlir::createConvertIndexToLLVMPass());
        // Convert remaining unrealized_casts (always needed).
        pm.addPass(mlir::createReconcileUnrealizedCastsPass());
        pm.addPass(mlir::createCanonicalizerPass());
      });
}

/**
 * Registers a pipeline for lowering FIFO and CAL dialects to LLVM assuming
 * SDF/CSDF actors with a static execution schedule.
 */
void registerLowerCalToLLVMWithStaticSchedulePipeline() {
  mlir::PassPipelineRegistration<CalGenericPipelineOptions>(
      "lower-cal-to-llvm-with-static-schedule",
      "Pipeline lowering FIFO and CAL dialects to LLVM dialect. Assumes the "
      "actors are SDF and CSDF actors and statically schedules the execution "
      "order.",
      [](mlir::OpPassManager &pm, const CalGenericPipelineOptions &options) {
        // 1. FIFO/CAL-specific lowering

        pm.addPass(mlir::createCanonicalizerPass());
        pm.addPass(mlir::createConvertCalToFuncWithStaticSchedulePass());

        // We add this pass as we often get functions that are the same but with
        // different names.
        pm.addPass(mlir::func::createDuplicateFunctionEliminationPass());

        // Early complex lowering (static schedule path).
        pm.addPass(mlir::createConvertComplexToStandardPass());

        pm.addPass(mlir::createLowerCalStateToMemref());
        pm.addPass(mlir::createLowerFifoToMemrefPass());
        pm.addPass(mlir::createDecomposeFifoTuples());
        pm.addPass(mlir::fifo::createLowerFifoPrintToLLVM());

        // 2. We need to add deallocation operations. However the
        // createConvertCalToFuncWithStaticSchedulePass generates CF, not SCF,
        // in the main function. The buffer deallocation pass expects SCF. So
        // we add a conversion here. The conversion gets undone in later passes
        pm.addPass(mlir::createLiftControlFlowToSCFPass());

        // 3. Standard MLIR to LLVM lowering
        mlir::bufferization::OneShotBufferizationOptions bufferizeOptions;
        bufferizeOptions.bufferizeFunctionBoundaries = true;
        pm.addPass(
            mlir::bufferization::createOneShotBufferizePass(bufferizeOptions));
        if (!options.disableHoistAllocs)
          pm.addPass(mlir::createHoistAllocsPass());
        pm.addPass(mlir::createCanonicalizerPass());
        // BufferDeallocation operates on func.func; must be nested.
        pm.addNestedPass<mlir::func::FuncOp>(
            mlir::bufferization::createBufferDeallocationPass());
        pm.addPass(mlir::createCanonicalizerPass());
        pm.addPass(mlir::createConvertLinalgToLoopsPass());
        pm.addPass(mlir::createCanonicalizerPass());

        // Convert SCF to CF (always needed).
        pm.addPass(mlir::createConvertSCFToCFPass());
        // Sprinkle some cleanups.
        pm.addPass(mlir::createCanonicalizerPass());
        pm.addPass(mlir::createCSEPass());

        // (Complex already lowered earlier; skip here.)

        // Convert Math to LLVM (always needed).
        pm.addNestedPass<mlir::func::FuncOp>(
            mlir::createConvertMathToLLVMPass());
        // Expand complicated MemRef operations before lowering them.
        pm.addPass(mlir::memref::createExpandStridedMetadataPass());
        // The expansion may create affine expressions. Get rid of them.
        pm.addPass(mlir::createLowerAffinePass());
        // Convert MemRef to LLVM (always needed).
        pm.addPass(mlir::createFinalizeMemRefToLLVMConversionPass());
        // Convert Func to LLVM (always needed).
        pm.addPass(mlir::createConvertFuncToLLVMPass());
        // Convert Arith to LLVM (always needed).
        pm.addPass(mlir::createArithToLLVMConversionPass());
        // Convert CF to LLVM (always needed).
        pm.addPass(mlir::createConvertControlFlowToLLVMPass());
        // Convert Index to LLVM (always needed).
        pm.addPass(mlir::createConvertIndexToLLVMPass());
        // Convert remaining unrealized_casts (always needed).
        pm.addPass(mlir::createReconcileUnrealizedCastsPass());
      });
}

/**
 * Builds a pipeline to lower FIFO and CAL dialects to LLVM with GPU tensors.
 */
void buildLowerCalToLLVMWithGPUTensorsPipeline(
    OpPassManager &pm, const CalToLLVMWithGPUTensorsPipelineOptions &options) {
  // 1. FIFO/CAL-specific lowering

  // Integrate FSM lowering here as well so GPU path behaves the same.
  pm.addPass(mlir::cal::lowerCalFsmToExecutionBody());

  pm.addPass(mlir::cal::insertCalPortPredicates());
  // Convert any remaining cal.action-based actors (non-FSM actors).
  pm.addPass(mlir::cal::convertCalActionsToExecutionBodies());

  pm.addPass(mlir::cal::hoistCalStateOutOfActor());
  pm.addPass(mlir::createCanonicalizerPass());
  // Early complex lowering (GPU path) prior to bufferization & GPU transforms.
  pm.addPass(mlir::createConvertComplexToStandardPass());
  // Honor pipeline option to drain actors by default (non-preemptive).
  pm.addPass(mlir::createConvertCalToFuncPass(options.nonPreemptiveDefault));

  // We often see duplicate functions differing only by name.
  // pm.addPass(mlir::func::createDuplicateFunctionEliminationPass());

  mlir::LowerCalStateToMemrefOptions stateOptions;
  stateOptions.which_alloc = std::string("GPU");
  pm.addPass(mlir::createLowerCalStateToMemref(stateOptions));

  mlir::LowerFifoToMemrefPassOptions fifoOptions;
  fifoOptions.which_alloc = std::string("GPU");
  pm.addPass(mlir::createLowerFifoToMemrefPass(fifoOptions));
  pm.addPass(mlir::createDecomposeFifoTuples());

  mlir::fifo::LowerFifoPrintToLLVMOptions printOptions;
  printOptions.tensors_on_gpu = true; // We want to lower the prints to GPU
  pm.addPass(mlir::fifo::createLowerFifoPrintToLLVM(printOptions));

  if (!options.disableHoistAllocs)
    pm.addPass(mlir::createHoistAllocsPass());
  pm.addPass(mlir::createDenseConstantsToGpuPass());
  pm.addPass(mlir::createGpuAwareBufferizePass());
  pm.addPass(mlir::createCanonicalizerPass());
  if (!options.disableHoistAllocs)
    pm.addPass(mlir::createHoistAllocsPass());
  pm.addPass(mlir::createCanonicalizerPass());
  // If we hoist the allocs, we need to disable deallocation as this causes
  // the program to crash when deallocating. TODO: Fix this bug
  if (options.disableHoistAllocs)
    // Nested because the pass is restricted to func.func.
    pm.addNestedPass<mlir::func::FuncOp>(
        mlir::bufferization::createBufferDeallocationPass());
  pm.addPass(mlir::createCanonicalizerPass());
  pm.addPass(mlir::createConvertLinalgToParallelLoopsPass());
  pm.addPass(mlir::createCanonicalizerPass());
  pm.addPass(mlir::createParallelLoopFusionPass());
  pm.addPass(mlir::createConvertLinalgToLoopsPass());
  llvm::SmallVector<int64_t, 3> tileSizes;
  if (!options.parallelLoopTileSizes.empty()) {
    tileSizes.assign(options.parallelLoopTileSizes.begin(),
                     options.parallelLoopTileSizes.end());
  } else {
    tileSizes = {1024, 1, 1};
  }
  pm.addPass(mlir::createParallelLoopTilingPass(tileSizes, true));

  // 2. GPU-specific lowering
  pm.addPass(mlir::createGpuMapParallelLoopsPass());
  pm.addPass(mlir::createParallelLoopToGpuPass());
  pm.addPass(mlir::createGpuKernelOutliningPass());
  pm.addPass(mlir::createCSEPass());
  if (options.enableAsyncGPUBehaviour) {
    pm.addPass(mlir::createCalPrepareGpuAsyncRegionsPass());
  } else {
    // This pass makes the gpu ops async, but within a very limited scope
    // We do this as the gpu ops need to be async to be compiled.
    pm.addPass(mlir::createGpuAsyncRegionPass());
  }
  pm.addPass(mlir::createConvertSCFToCFPass());

  mlir::gpu::GPUToNVVMPipelineOptions nvvmOptions;
  nvvmOptions.cubinChip = options.cubinChip;
  nvvmOptions.optLevel = options.optLevel;
  mlir::gpu::buildLowerToNVVMPassPipeline(pm, nvvmOptions);

  // Complex ops were lowered earlier; no action here.
}

/**
 * Registers the pipeline for lowering FIFO and CAL dialects to LLVM with GPU
 * tensors.
 */
void registerLowerCalToLLVMWithGPUTensorsPipeline() {
  mlir::PassPipelineRegistration<CalToLLVMWithGPUTensorsPipelineOptions>(
      "lower-cal-to-llvm-with-gpu-tensors",
      "Pipeline lowering FIFO and CAL dialects to LLVM dialect and executing "
      "tensor operations on NVVM GPUs",
      buildLowerCalToLLVMWithGPUTensorsPipeline);
}

} // namespace mlir::cal

// Migrate pipeline registration from former RegisterPipelines.cpp.
// We keep the original function name so existing callers (e.g. cal-opt) continue to work.
namespace mlir {
void registerCalGenericTransformationsPipelines() {
  // Unified network elaboration pipeline with explicit 'top' selection
  // (interface: --cal-network-elab=top=<symbol>). If omitted, falls back to
  // CAL_NETWORK_ELAB_TOP. The pipeline performs two-phase connection
  // elaboration and a two-stage flatten (first without pruning, then with
  // pruning) to fully inline hierarchy while preserving specialized network
  // symbols until final materialization.
  struct CalNetworkElabOptions : public PassPipelineOptions<CalNetworkElabOptions> {
    Option<std::string> top{*this, "top",
                            llvm::cl::desc("Symbol name of the top cal.network to elaborate/retain; if empty, falls back to CAL_NETWORK_ELAB_TOP env var."),
                            llvm::cl::init("")};
    Option<bool> disableSecondFlatten{*this, "disable-second-flatten",
                                      llvm::cl::desc("Disable the second flatten+prune phase (for debugging incremental elaboration)."),
                                      llvm::cl::init(false)};
  };

  // Note: Former debug marker/instrumentation passes were removed.

  auto buildCalNetworkElabPipeline = [&](OpPassManager &pm, const CalNetworkElabOptions &opts) {
    // Phase 0: Parameter resolution and structural preparation up to
    // network-elements elaboration.
    pm.addPass(createConstJITResolvePass());
    pm.addPass(createParamSpecializePass());
    pm.addPass(mlir::createCanonicalizerPass());
    pm.addPass(createConstJITResolvePass());
    pm.addPass(mlir::createCanonicalizerPass());
    pm.addPass(createInferCalInstanceArrayShapePass());
    pm.addPass(mlir::createCanonicalizerPass());
    pm.addPass(createNetworkElementsElabPass());

    pm.addPass(mlir::createCanonicalizerPass());

    // Determine top via option or CAL_NETWORK_ELAB_TOP.
    std::string topValue = opts.top;
    if (topValue.empty()) {
      if (const char *topEnv = ::getenv("CAL_NETWORK_ELAB_TOP")) {
        if (topEnv && *topEnv)
          topValue = std::string(topEnv);
      }
    }

    // Forward top selection and build the elaboration sequence.
    // Ordering matters: prep → normalize → flatten → fanout → finalize.
    // This keeps symbolic cal.connect ops available for fanout insertion and
    // defers erroring on duplicate-source connects until after normalization.
    FlattenCalNetworksPassOptions flOpts; // defaults unless option/env provided
    if (!topValue.empty())
      flOpts.top = topValue;

    // 1) Prep: plan/validate only; retain cal.connect. Duplicate-source
    //    connects are tolerated at this stage.
    pm.addPass(createElaborateCalConnectionsPrepPass());
    pm.addPass(mlir::createCanonicalizerPass());
    // 1.5) Normalize: scalarize array-indexed endpoints so coverage checks see
    //      scalar instance handles.
    pm.addPass(createNormalizeCalConnectsPass());
    pm.addPass(mlir::createCanonicalizerPass());
    // 2) Flatten: retain symbolic connects; allow duplicate source-port
    //    connects so multi-sink fanout normalization can run afterwards.
    flOpts.disablePruning = true; // keep nested networks for finalize
    flOpts.allowSourcePortMultiConnect = true; // relax duplicate source checks pre-fanout
    pm.addPass(createFlattenCalNetworksPass(std::move(flOpts)));
    pm.addPass(mlir::createCanonicalizerPass());
    // 3) Fanout: insert fanout actors on flattened topology to normalize
    //    multi-sink sources.
    pm.addPass(createInsertFanoutOnMultiSinkPass());
    pm.addPass(mlir::createCanonicalizerPass());
    // 4) Finalize: materialize channels/instances and erase connects; verify.
    pm.addPass(createElaborateCalConnectionsFinalizePass());
    pm.addPass(mlir::createCanonicalizerPass());
    pm.addPass(createVerifyInstanceArrayFillsPass());
    pm.addPass(createVerifyConnectPortsPass());
    pm.addPass(createVerifyInstanceArrayStaticUsagePass());
    // 5) Second flatten (optional): inline any remaining networks into top
    //    and enable pruning to drop unreferenced symbols.
    if (!opts.disableSecondFlatten) {
      FlattenCalNetworksPassOptions flOpts2;
      if (!topValue.empty())
        flOpts2.top = topValue;
      flOpts2.disablePruning = false;
      pm.addPass(createFlattenCalNetworksPass(std::move(flOpts2)));
      pm.addPass(mlir::createCanonicalizerPass());
      // 6) Prune: remove unreachable network symbols (e.g., unused specializations).
      pm.addPass(createPruneUnusedNetworksPass());
      pm.addPass(mlir::createCanonicalizerPass());
      // End two-stage flattening.
    }
  };

  PassPipelineRegistration<CalNetworkElabOptions> calNetworkElab(
      "cal-network-elab",
      "Unified CAL network elaboration (supports --cal-network-elab=top=<symbol>). Performs specialization, two-phase connection elaboration, fanout insertion, double flatten, and pruning.",
      buildCalNetworkElabPipeline);
}
} // namespace mlir