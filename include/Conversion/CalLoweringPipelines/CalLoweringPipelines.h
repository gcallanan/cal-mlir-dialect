#ifndef CAL_LOWERING_PIPELINES_H
#define CAL_LOWERING_PIPELINES_H

#include "mlir/Pass/Pass.h"
#include "mlir/Pass/PassOptions.h"
#include "mlir/Transforms/DialectConversion.h"

namespace mlir::cal {

struct CalGenericPipelineOptions
    : public PassPipelineOptions<CalGenericPipelineOptions> {
  PassOptions::Option<bool> disableHoistAllocs{
      *this, "disable-hoist-allocs",
      llvm::cl::desc("Disable hoisting of allocations to main function."),
      llvm::cl::init(false)};
};

struct CalToLLVMWithGPUTensorsPipelineOptions
    : public CalGenericPipelineOptions {
  PassOptions::Option<std::string> cubinChip{
      *this, "cubin-chip", llvm::cl::desc("Chip to use to serialize to cubin."),
      llvm::cl::init("sm_75")};
  PassOptions::Option<int> optLevel{
      *this, "opt-level",
      llvm::cl::desc("Optimization level for NVVM compilation"),
      llvm::cl::init(2)};
  PassOptions::Option<bool> disableAsyncGPUBehaviour{
      *this, "disable-asynch-gpu-behavior",
      llvm::cl::desc("Disable experimental pass that makes GPU operations asynchonous."),
      llvm::cl::init(false)};
};

void registerCalPipelines();

void registerLowerCalToLLVMPipeline();
void registerLowerCalToLLVMWithStaticSchedulePipeline();
void registerLowerCalToLLVMWithGPUTensorsPipeline();

} // namespace mlir::cal

#endif // CAL_LOWERING_PIPELINES_H