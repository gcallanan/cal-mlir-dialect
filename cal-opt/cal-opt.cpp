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
#include "mlir/Dialect/Complex/IR/Complex.h"
#include "mlir/Dialect/GPU/IR/GPUDialect.h"
#include "mlir/Dialect/GPU/Transforms/Passes.h"
#include "mlir/Dialect/UB/IR/UBOps.h"
// Async dialect
#include "mlir/Dialect/Async/IR/Async.h"
#include "mlir/Dialect/Async/Passes.h"
// (Optional) Inliner interfaces would go here if needed.

// Func dialect extensions (inliner) are not available in this MLIR snapshot;
// avoid including/registering them here to keep link compatibility.

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
#include "mlir/Target/LLVMIR/Dialect/Builtin/BuiltinToLLVMIRTranslation.h"
#include "mlir/Target/LLVMIR/Dialect/LLVMIR/LLVMToLLVMIRTranslation.h"

// Project-specific dialects
#include "Dialect/Cal/CalDialect.h"
#include "Dialect/Cal/CalPasses.h"
#include "Dialect/Fifo/FifoDialect.h"
#include "Dialect/Fifo/FifoPasses.h"

// Project-specific conversions and Transformations
#include "Conversion/Passes.h"
#include "Dialect/Fifo/BufferizableOpInterfaceImpl.h"
#include "Transforms/Passes.h"
#include "Transforms/GPUDeallocInterface/GpuDeallocInterface.h"

// All the CAL pipelines
#include "Conversion/CalLoweringPipelines/CalLoweringPipelines.h"

// Force-link deprecated no-op pass registration for legacy flag compatibility.
namespace mlir { namespace cal { void forceRegisterLegacyMergeSimpleCalActorsPass(); }}

int main(int argc, char **argv) {
  // Pre-scan argv for cal-network-elab helper flag and translate it into
  // an environment variable consumed by the registered pipeline. This avoids
  // introducing RTTI/command-line dependencies into the pipeline library and
  // keeps the user-facing interface to a single flag.
  std::vector<char *> filtered;
  filtered.reserve(argc);
  auto takeValue = [](llvm::StringRef a) -> std::string {
    size_t eq = a.find('=');
    return (eq == llvm::StringRef::npos) ? std::string() : a.drop_front(eq + 1).str();
  };
  for (int i = 0; i < argc; ++i) {
    llvm::StringRef arg(argv[i]);
    // Accept the simplified separate-top flag.
    if (arg.starts_with("--cal-network-elab-top=")) {
      std::string v = takeValue(arg);
      if (!v.empty()) ::setenv("CAL_NETWORK_ELAB_TOP", v.c_str(), /*overwrite=*/1);
      continue; // drop from argv
    }
    // Back-compat/alias: support inline pipeline-style form
    //   --cal-network-elab=top=<sym>
    // or
    //   -cal-network-elab=top=<sym>
    if (arg.starts_with("--cal-network-elab=top=") || arg.starts_with("-cal-network-elab=top=")) {
      // Extract <sym> after the last '='
      std::string v = takeValue(arg);
      if (!v.empty()) ::setenv("CAL_NETWORK_ELAB_TOP", v.c_str(), /*overwrite=*/1);
      // Ensure the pipeline itself is enabled. Replace the inline form with the
      // bare pipeline switch so MLIR sees the pipeline request.
      filtered.push_back(const_cast<char*>("-cal-network-elab"));
      continue; // handled
    }
    // Track explicit pipeline flag if present; forward as-is.
    if (arg == "-cal-network-elab" || arg == "--cal-network-elab") {
      filtered.push_back(argv[i]);
      continue;
    }
    filtered.push_back(argv[i]);
  }
  // Ensure argv ends with null terminator pointer as expected.
  filtered.push_back(nullptr);
  mlir::registerAllPasses();
  mlir::cal::registerPasses();
  mlir::registerCalConversionPasses();
  mlir::fifo::registerPasses();
  mlir::registerCalGenericTransformationsPasses();
  mlir::registerCalGenericTransformationsPipelines();
  mlir::cal::registerCalPipelines();
    // Ensure the TU with the legacy no-op pass is linked into this binary.
    mlir::cal::forceRegisterLegacyMergeSimpleCalActorsPass();

  mlir::DialectRegistry registry;
  registry.insert<
      mlir::cal::CalDialect, mlir::fifo::FifoDialect, mlir::arith::ArithDialect,
    mlir::complex::ComplexDialect,
      mlir::func::FuncDialect, mlir::memref::MemRefDialect,
      mlir::index::IndexDialect, mlir::LLVM::LLVMDialect,
      mlir::cf::ControlFlowDialect, mlir::scf::SCFDialect,
      mlir::math::MathDialect, mlir::func::FuncDialect, mlir::gpu::GPUDialect,
      mlir::nvgpu::NVGPUDialect, mlir::NVVM::NVVMDialect,
      mlir::tosa::TosaDialect, mlir::linalg::LinalgDialect,
      mlir::tensor::TensorDialect, mlir::bufferization::BufferizationDialect,
      mlir::affine::AffineDialect, mlir::ub::UBDialect,
      mlir::async::AsyncDialect>();

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
  // Note: Func inliner extension not registered here due to missing symbol in
  // this MLIR build; CalConstEval avoids inliner use for now.
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
  mlir::registerBuiltinDialectTranslation(registry);
  mlir::registerLLVMDialectTranslation(registry);
  mlir::registerNVVMDialectTranslation(registry);

  // (No-op) If specific dialect extensions are needed, register them here.
  // No local inliner interface registration; CalConstEval implements a small
  // targeted inliner internally for now.
  // Note: Global registerAllExtensions is not available in this MLIR build,
  // so we skip it here to avoid link errors.

  // Add the following to include *all* MLIR Core dialects, or selectively
  // include what you need like above. You only need to register dialects that
  // will be *parsed* by the tool, not the one generated
  // registerAllDialects(registry);

  int newArgc = static_cast<int>(filtered.size()) - 1;
  char **newArgv = filtered.data();
  return mlir::asMainReturnCode(
    mlir::MlirOptMain(newArgc, newArgv, "Cal optimizer driver\n", registry));
}
