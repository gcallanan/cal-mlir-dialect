#ifndef GPUDEALLOCINTERFACE_H
#define GPUDEALLOCINTERFACE_H

#include "mlir/Dialect/Bufferization/IR/AllocationOpInterface.h"
#include "mlir/Dialect/GPU/IR/GPUDialect.h"

namespace mlir {

// External model for GPU deallocation interface - provides deallocation
// behavior for gpu.alloc

// Note by Gareth Callanan: I would like this interface to be provided by mlir
// itself, but it currently does not have a GPU deallocation interface. This
// currently works in our test cases, but may not be suitable for all GPU
// operations.
struct GpuDeallocInterface
    : public mlir::bufferization::detail::AllocationOpInterfaceInterfaceTraits::
          ExternalModel<GpuDeallocInterface, mlir::gpu::AllocOp> {

  // Emit a gpu.dealloc for the given gpu.alloc result
  static std::optional<mlir::Operation *> buildDealloc(mlir::OpBuilder &builder,
                                                       mlir::Value alloc);

  // GPU buffers typically aren't cloned
  static std::optional<mlir::Value> buildClone(mlir::OpBuilder &, mlir::Value);

  // Enable loop/block hoisting — safe if gpu.alloc is host-side
  static mlir::HoistingKind getHoistingKind();

  // GPU buffers can't be promoted to stack (no gpu.alloca)
  static std::optional<mlir::Operation *> buildPromotedAlloc(mlir::OpBuilder &,
                                                             mlir::Value);
};

// Function to register the GPU deallocation interface
void registerGpuDeallocInterface(mlir::DialectRegistry &registry);

} // namespace mlir

#endif