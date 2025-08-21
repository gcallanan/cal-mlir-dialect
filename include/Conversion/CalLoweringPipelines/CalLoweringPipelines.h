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
  PassOptions::Option<bool> mergeActorChains{
      *this, "merge-actor-chains",
      llvm::cl::desc("Merge chains of single action actors with a single input "
                     "and output port together."),
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
  PassOptions::Option<bool> enableAsyncGPUBehaviour{
      *this, "enable-asynch-gpu-behavior",
      llvm::cl::desc(
          "Enable experimental pass that makes GPU operations asynchonous."),
      llvm::cl::init(false)};
  PassOptions::ListOption<int64_t> parallelLoopTileSizes{
      *this, "parallel-loop-tile-sizes",
      llvm::cl::desc("Tile sizes for scf.parallel loop tiling "
                     "(comma-separated, e.g. 1024,1,1)"),
      llvm::cl::ZeroOrMore};
};

void registerCalPipelines();

void registerLowerCalToLLVMPipeline();
void registerLowerCalToLLVMWithStaticSchedulePipeline();
void registerLowerCalToLLVMWithGPUTensorsPipeline();

} // namespace mlir::cal

#endif // CAL_LOWERING_PIPELINES_H