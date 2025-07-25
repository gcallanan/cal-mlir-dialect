#ifndef CAL_LOWERING_PIPELINES_H
#define CAL_LOWERING_PIPELINES_H

#include "mlir/Pass/Pass.h"
#include "mlir/Pass/PassOptions.h"
#include "mlir/Transforms/DialectConversion.h"

namespace mlir::cal {

struct CalToLLVMWithGPUTensorsPipelineOptions
    : public PassPipelineOptions<CalToLLVMWithGPUTensorsPipelineOptions> {
  PassOptions::Option<std::string> cubinChip{
      *this, "cubin-chip", llvm::cl::desc("Chip to use to serialize to cubin."),
      llvm::cl::init("sm_75")};
  PassOptions::Option<int> optLevel{
      *this, "opt-level",
      llvm::cl::desc("Optimization level for NVVM compilation"),
      llvm::cl::init(2)};
};

void registerCalPipelines();

void registerLowerCalToLLVMPipeline();
void registerLowerCalToLLVMWithStaticSchedulePipeline();
void registerLowerCalToLLVMWithGPUTensorsPipeline();

} // namespace mlir

#endif // CAL_LOWERING_PIPELINES_H