//===- cal-opt.cpp ---------------------------------------*- C++ -*-===//
//
// This file is licensed under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

// MLIR Core
#include "mlir/IR/MLIRContext.h"
#include "mlir/InitAllDialects.h"
#include "mlir/InitAllExtensions.h"
#include "mlir/InitAllPasses.h"
#include "mlir/Pass/Pass.h"
#include "mlir/Pass/PassManager.h"
#include "mlir/Support/FileUtilities.h"
#include "mlir/Tools/mlir-opt/MlirOptMain.h"
#include "mlir/Transforms/Passes.h"

// MLIR Conversions
#include "mlir/Conversion/GPUToNVVM/GPUToNVVMPass.h"

// MLIR Dialects
#include "mlir/Dialect/GPU/IR/GPUDialect.h"
#include "mlir/Dialect/GPU/Transforms/Passes.h"
#include "mlir/Dialect/UB/IR/UBOps.h"

// MLIR Dialect Transforms
#include "mlir/Conversion/UBToLLVM/UBToLLVM.h"
#include "mlir/Dialect/Arith/Transforms/BufferDeallocationOpInterfaceImpl.h"
#include "mlir/Dialect/Arith/Transforms/BufferViewFlowOpInterfaceImpl.h"
#include "mlir/Dialect/Arith/Transforms/BufferizableOpInterfaceImpl.h"
#include "mlir/Dialect/Bufferization/IR/Bufferization.h"
#include "mlir/Dialect/Bufferization/Pipelines/Passes.h"
#include "mlir/Dialect/Bufferization/Transforms/FuncBufferizableOpInterfaceImpl.h"
#include "mlir/Dialect/Bufferization/Transforms/Passes.h"
#include "mlir/Dialect/GPU/Pipelines/Passes.h"
#include "mlir/Dialect/Linalg/Transforms/AllInterfaces.h"
#include "mlir/Dialect/SCF/Transforms/BufferDeallocationOpInterfaceImpl.h"
#include "mlir/Dialect/SCF/Transforms/BufferizableOpInterfaceImpl.h"
#include "mlir/Dialect/Tensor/Transforms/BufferizableOpInterfaceImpl.h"
#include "mlir/Target/LLVMIR/Dialect/GPU/GPUToLLVMIRTranslation.h"
#include "mlir/Target/LLVMIR/Dialect/NVVM/NVVMToLLVMIRTranslation.h"

// Project-specific dialects
#include "Dialect/Cal/CalDialect.h"
#include "Dialect/Cal/CalPasses.h"
#include "Dialect/Fifo/FifoDialect.h"
#include "Dialect/Fifo/FifoPasses.h"

// Project-specific conversions and Transformations
#include "Conversion/Passes.h"
#include "Dialect/Fifo/BufferizableOpInterfaceImpl.h"
#include "Transforms/GPUDeallocInterface/GpuDeallocInterface.h"
#include "Transforms/DenseConstantsToGPU/DenseConstantsToGPU.h"
#include "Transforms/Passes.h"

void registerLowerCalToLLVMPipeline();
void registerLowerCalToLLVMWithStaticSchedulePipeline();
void registerLowerCalToLLVMWithGPUTensorsPipeline();

int main(int argc, char **argv) {
  mlir::registerAllPasses();
  mlir::cal::registerPasses();
  mlir::registerCalConversionPasses();
  mlir::fifo::registerPasses();
  mlir::registerCalGenericTransformationsPasses();

  mlir::DialectRegistry registry;
  registry.insert<
      mlir::cal::CalDialect, mlir::fifo::FifoDialect, mlir::arith::ArithDialect,
      mlir::func::FuncDialect, mlir::memref::MemRefDialect,
      mlir::index::IndexDialect, mlir::LLVM::LLVMDialect,
      mlir::cf::ControlFlowDialect, mlir::scf::SCFDialect,
      mlir::math::MathDialect, mlir::func::FuncDialect, mlir::gpu::GPUDialect,
      mlir::nvgpu::NVGPUDialect, mlir::NVVM::NVVMDialect,
      mlir::tosa::TosaDialect, mlir::linalg::LinalgDialect,
      mlir::tensor::TensorDialect, mlir::bufferization::BufferizationDialect,
      mlir::affine::AffineDialect, mlir::ub::UBDialect>();

  // We need this to be able to run the --buffer-deallocation pass which can
  // automatically insert deallocation operations
  mlir::memref::registerAllocationOpInterfaceExternalModels(registry);
  mlir::registerGpuDeallocInterface(registry);
  mlir::arith::registerBufferDeallocationOpInterfaceExternalModels(registry);
  mlir::cf::registerBufferDeallocationOpInterfaceExternalModels(registry);
  mlir::scf::registerBufferDeallocationOpInterfaceExternalModels(registry);

  // These were all the things we needed to register to get bufferisation
  // working with the Cal dialect. Bufferisztion converts tensor types to memref
  // types which we need to get the linalg dialect to work properly.
  mlir::arith::registerBufferizableOpInterfaceExternalModels(registry);
  mlir::arith::registerBufferViewFlowOpInterfaceExternalModels(registry);
  mlir::arith::registerValueBoundsOpInterfaceExternalModels(registry);
  mlir::scf::registerBufferizableOpInterfaceExternalModels(registry);
  mlir::cf::registerBufferizableOpInterfaceExternalModels(registry);
  mlir::tensor::registerBufferizableOpInterfaceExternalModels(registry);
  mlir::tensor::registerValueBoundsOpInterfaceExternalModels(registry);
  mlir::tensor::registerInferTypeOpInterfaceExternalModels(registry);
  mlir::linalg::registerAllDialectInterfaceImplementations(registry);
  mlir::bufferization::func_ext::registerBufferizableOpInterfaceExternalModels(
      registry);
  mlir::fifo::registerBufferizableOpInterfaceExternalModels(registry);

  // This was needed by the pipeline created in
  // the registerLowerCalToLLVMWithGPUTensorsPipeline(...)
  mlir::arith::registerConvertArithToLLVMInterface(registry);
  mlir::registerConvertComplexToLLVMInterface(registry);
  mlir::cf::registerConvertControlFlowToLLVMInterface(registry);
  // mlir::func::registerAllExtensions(registry);
  // mlir::tensor::registerAllExtensions(registry);
  mlir::registerConvertFuncToLLVMInterface(registry);
  mlir::index::registerConvertIndexToLLVMInterface(registry);
  mlir::registerConvertMathToLLVMInterface(registry);
  mlir::registerConvertMemRefToLLVMInterface(registry);
  mlir::registerConvertNVVMToLLVMInterface(registry);
  // mlir::registerConvertOpenMPToLLVMInterface(registry);
  mlir::ub::registerConvertUBToLLVMInterface(registry);
  // mlir::registerConvertAMXToLLVMInterface(registry);
  mlir::gpu::registerConvertGpuToLLVMInterface(registry);
  mlir::NVVM::registerConvertGpuToNVVMInterface(registry);
  mlir::NVVM::registerNVVMTargetInterfaceExternalModels(registry);
  mlir::registerGPUDialectTranslation(registry);
  mlir::registerLLVMDialectTranslation(registry);
  mlir::registerNVVMDialectTranslation(registry);

  // Add the following to include *all* MLIR Core dialects, or selectively
  // include what you need like above. You only need to register dialects that
  // will be *parsed* by the tool, not the one generated
  // registerAllDialects(registry);

  registerLowerCalToLLVMPipeline();
  registerLowerCalToLLVMWithStaticSchedulePipeline();
  registerLowerCalToLLVMWithGPUTensorsPipeline();

  return mlir::asMainReturnCode(
      mlir::MlirOptMain(argc, argv, "Cal optimizer driver\n", registry));
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
 * For details on pass pipeline registration and instance-specific pass options,
 * see: https://mlir.llvm.org/docs/PassManagement/#pass-pipeline-registration
 *   https://mlir.llvm.org/docs/PassManagement/#instance-specific-pass-options
 *
 * A similar example of an inline pipeline builder can be found in:
 *   llvm-project/mlir/lib/Dialect/Bufferization/Pipelines/BufferizationPipelines.cpp
 *
 * DISCLAIMER: This description has been generated by ChatGPT but verified by
 * the code author.
 */
void registerLowerCalToLLVMPipeline() {
  mlir::PassPipelineRegistration<>(
      "lower-cal-to-llvm",
      "Pipeline lowering FIFO and CAL dialects to LLVM dialect.",
      [](mlir::OpPassManager &pm) {
        // 1. FIFO/CAL-specific lowering
        pm.addPass(mlir::cal::insertCalPortPredicates());
        pm.addPass(mlir::cal::convertCalActionsToExecutionBodies());

        pm.addPass(mlir::cal::hoistCalStateOutOfActor());
        pm.addPass(mlir::createCanonicalizerPass());
        pm.addPass(mlir::createConvertCalToFuncPass());
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
        pm.addPass(mlir::createCanonicalizerPass());
        pm.addPass(mlir::bufferization::createBufferDeallocationPass());
        pm.addPass(mlir::createCanonicalizerPass());
        pm.addPass(mlir::createConvertLinalgToLoopsPass());
        pm.addPass(mlir::createCanonicalizerPass());

        // 2. Standard MLIR to LLVM lowering:
        //    The following passes lower various MLIR dialects to LLVM.
        //    (The ordering and combination of these passes follow similar
        //    pipelines
        //     as in the LLVM project, for example in TestLowertoLLVM.cpp.)

        // pm.addNestedPass<func::FuncOp>(createConvertVectorToSCFPass());
        // // Blanket-convert any remaining linalg ops to loops if any remain.
        // pm.addNestedPass<func::FuncOp>(createConvertLinalgToLoopsPass());
        // // Blanket-convert any remaining affine ops if any remain.
        // pm.addPass(createLowerAffinePass());
        // Convert SCF to CF (always needed).
        pm.addPass(mlir::createConvertSCFToCFPass());
        // Sprinkle some cleanups.
        pm.addPass(mlir::createCanonicalizerPass());
        pm.addPass(mlir::createCSEPass());
        // Convert vector to LLVM (always needed).
        // pm.addPass(createConvertVectorToLLVMPass(
        //     // TODO: add more options on a per-need basis.
        //     ConvertVectorToLLVMPassOptions{options.reassociateFPReductions}));
        // // Convert Math to LLVM (always needed).
        pm.addNestedPass<mlir::func::FuncOp>(
            mlir::createConvertMathToLLVMPass());
        // Expand complicated MemRef operations before lowering them.
        pm.addPass(mlir::memref::createExpandStridedMetadataPass());
        // // The expansion may create affine expressions. Get rid of them.
        pm.addPass(mlir::createLowerAffinePass());
        // // Convert MemRef to LLVM (always needed).
        pm.addPass(mlir::createFinalizeMemRefToLLVMConversionPass());
        // // Convert Func to LLVM (always needed).
        pm.addPass(mlir::createConvertFuncToLLVMPass());
        // // Convert Arith to LLVM (always needed).
        pm.addPass(mlir::createArithToLLVMConversionPass());
        // // Convert CF to LLVM (always needed).
        pm.addPass(mlir::createConvertControlFlowToLLVMPass());
        // // Convert Index to LLVM (always needed).
        pm.addPass(mlir::createConvertIndexToLLVMPass());
        // // Convert remaining unrealized_casts (always needed).
        pm.addPass(mlir::createReconcileUnrealizedCastsPass());
      });
}

/**
 * Registers the pipeline for lowering FIFO and CAL dialects to the LLVM
 * dialect. This pipeline assumes all actors are not SDF or CSDF actors so makes
 * no assumptions about the static schedule of the actors.
 *
 */
void registerLowerCalToLLVMWithStaticSchedulePipeline() {
  mlir::PassPipelineRegistration<>(
      "lower-cal-to-llvm-with-static-schedule",
      "Pipeline lowering FIFO and CAL dialects to LLVM dialect. Assumes the "
      "actors are SDF and CSDF actors and statically schedules the execution "
      "order.",
      [](mlir::OpPassManager &pm) {
        // 1. FIFO/CAL-specific lowering
        pm.addPass(mlir::createCanonicalizerPass());

        pm.addPass(mlir::createConvertCalToFuncWithStaticSchedulePass());

        // We add this pass as we often get functions that are the same but with
        // different names.
        pm.addPass(mlir::func::createDuplicateFunctionEliminationPass());

        pm.addPass(mlir::createLowerCalStateToMemref());
        pm.addPass(mlir::createLowerFifoToMemrefPass());
        pm.addPass(mlir::createDecomposeFifoTuples());
        pm.addPass(mlir::fifo::createLowerFifoPrintToLLVM());

        // 2. We need to add deallocation operations. However the
        // createConvertCalToFuncWithStaticSchedulePass genrerates CF, not SCF,
        // in the main function. The buffer deallocation pass expects SCF. So
        // we add a conversion here. The conversion gets undone in later passes
        pm.addPass(mlir::createLiftControlFlowToSCFPass());

        // 3. Standard MLIR to LLVM lowering:
        //    The following passes lower various MLIR dialects to LLVM.
        //    (The ordering and combination of these passes follow similar
        //    pipelines
        //     as in the LLVM project, for example in TestLowertoLLVM.cpp.)
        mlir::bufferization::OneShotBufferizationOptions bufferizeOptions;
        bufferizeOptions.bufferizeFunctionBoundaries = true;
        pm.addPass(
            mlir::bufferization::createOneShotBufferizePass(bufferizeOptions));
        pm.addPass(mlir::createCanonicalizerPass());
        pm.addPass(mlir::bufferization::createBufferDeallocationPass());
        pm.addPass(mlir::createCanonicalizerPass());
        pm.addPass(mlir::createConvertLinalgToLoopsPass());
        pm.addPass(mlir::createCanonicalizerPass());
        // pm.addNestedPass<func::FuncOp>(createConvertVectorToSCFPass());
        // // Blanket-convert any remaining linalg ops to loops if any remain.
        // pm.addNestedPass<func::FuncOp>(createConvertLinalgToLoopsPass());
        // // Blanket-convert any remaining affine ops if any remain.
        // pm.addPass(createLowerAffinePass());
        // Convert SCF to CF (always needed).
        pm.addPass(mlir::createConvertSCFToCFPass());
        // Sprinkle some cleanups.
        pm.addPass(mlir::createCanonicalizerPass());
        pm.addPass(mlir::createCSEPass());
        // Convert vector to LLVM (always needed).
        // pm.addPass(createConvertVectorToLLVMPass(
        //     // TODO: add more options on a per-need basis.
        //     ConvertVectorToLLVMPassOptions{options.reassociateFPReductions}));
        // // Convert Math to LLVM (always needed).
        pm.addNestedPass<mlir::func::FuncOp>(
            mlir::createConvertMathToLLVMPass());
        // Expand complicated MemRef operations before lowering them.
        pm.addPass(mlir::memref::createExpandStridedMetadataPass());
        // // The expansion may create affine expressions. Get rid of them.
        pm.addPass(mlir::createLowerAffinePass());
        // // Convert MemRef to LLVM (always needed).
        pm.addPass(mlir::createFinalizeMemRefToLLVMConversionPass());
        // // Convert Func to LLVM (always needed).
        pm.addPass(mlir::createConvertFuncToLLVMPass());
        // // Convert Arith to LLVM (always needed).
        pm.addPass(mlir::createArithToLLVMConversionPass());
        // // Convert CF to LLVM (always needed).
        pm.addPass(mlir::createConvertControlFlowToLLVMPass());
        // // Convert Index to LLVM (always needed).
        pm.addPass(mlir::createConvertIndexToLLVMPass());
        // // Convert remaining unrealized_casts (always needed).
        pm.addPass(mlir::createReconcileUnrealizedCastsPass());
      });
}

void registerLowerCalToLLVMWithGPUTensorsPipeline() {
  mlir::PassPipelineRegistration<>(
      "lower-cal-to-llvm-with-gpu-tensors",
      "Pipeline lowering FIFO and CAL dialects to LLVM dialect and executing "
      "tensor operations on NVVM GPUs",
      [](mlir::OpPassManager &pm) {
        // 1. FIFO/CAL-specific lowering
        pm.addPass(mlir::cal::insertCalPortPredicates());
        pm.addPass(mlir::cal::convertCalActionsToExecutionBodies());

        pm.addPass(mlir::cal::hoistCalStateOutOfActor());
        pm.addPass(mlir::createCanonicalizerPass());
        pm.addPass(mlir::createConvertCalToFuncPass());
        // We add this pass as we often get functions that are the same but with
        // different names.
        pm.addPass(mlir::func::createDuplicateFunctionEliminationPass());

        mlir::LowerCalStateToMemrefOptions stateOptions;
        stateOptions.which_alloc = std::string("GPU");
        pm.addPass(mlir::createLowerCalStateToMemref(stateOptions));
        mlir::LowerFifoToMemrefPassOptions fifoOptions;
        fifoOptions.which_alloc = std::string("GPU");
        pm.addPass(mlir::createLowerFifoToMemrefPass(fifoOptions));
        pm.addPass(mlir::createDecomposeFifoTuples());
        mlir::fifo::LowerFifoPrintToLLVMOptions printOptions;
        printOptions.tensors_on_gpu =
            true; // We want to lower the prints to GPU
        pm.addPass(mlir::fifo::createLowerFifoPrintToLLVM(printOptions));

        pm.addPass(mlir::createDenseConstantsToGpuPass());
        pm.addPass(mlir::createGpuAwareBufferizePass());

        pm.addPass(mlir::createCanonicalizerPass());
        // pm.addPass(mlir::bufferization::createBufferDeallocationPass());
        pm.addPass(mlir::createCanonicalizerPass());
        pm.addPass(mlir::createConvertLinalgToParallelLoopsPass());
        pm.addPass(mlir::createCanonicalizerPass());

        // 2. Now we start the GPU-specific lowering
        pm.addPass(mlir::createGpuMapParallelLoopsPass());
        pm.addPass(mlir::createParallelLoopToGpuPass());
        pm.addPass(mlir::createGpuKernelOutliningPass());
        pm.addPass(mlir::createCSEPass());
        pm.addPass(mlir::createGpuAsyncRegionPass());

        // pm.addPass(mlir::memref::createExpandStridedMetadataPass());
        // pm.addPass(mlir::createLowerAffinePass());
        // pm.addPass(mlir::createFinalizeMemRefToLLVMConversionPass());

        mlir::gpu::GPUToNVVMPipelineOptions nvvmOptions;
        nvvmOptions.cubinChip = "sm_75";
        nvvmOptions.optLevel = 3;
        // nvvmOptions.kernelUseBarePtrCallConv = true;
        // nvvmOptions.hostUseBarePtrCallConv = true;
        mlir::gpu::buildLowerToNVVMPassPipeline(pm, nvvmOptions);
      });
}
