#include "Transforms/GPUDeallocInterface/GpuDeallocInterface.h"
#include "mlir/Dialect/GPU/IR/GPUDialect.h"
#include "mlir/Dialect/Bufferization/IR/AllocationOpInterface.h"

namespace mlir {

// Implement the GpuDeallocInterface methods
std::optional<mlir::Operation *> GpuDeallocInterface::buildDealloc(mlir::OpBuilder &builder, mlir::Value alloc) {
  return builder.create<mlir::gpu::DeallocOp>(alloc.getLoc(), mlir::TypeRange{}, mlir::ValueRange{}, alloc).getOperation();
}

std::optional<mlir::Value> GpuDeallocInterface::buildClone(mlir::OpBuilder &, mlir::Value) {
  return std::nullopt;
}

mlir::HoistingKind GpuDeallocInterface::getHoistingKind() {
  return mlir::HoistingKind::Loop | mlir::HoistingKind::Block;
}

std::optional<mlir::Operation *> GpuDeallocInterface::buildPromotedAlloc(mlir::OpBuilder &, mlir::Value) {
  return std::nullopt;
}

// Utility function to register the interface
void registerGpuDeallocInterface(mlir::DialectRegistry &registry) {
  registry.addExtension(+[](MLIRContext *ctx, mlir::gpu::GPUDialect *dialect) {
    mlir::gpu::AllocOp::attachInterface<GpuDeallocInterface>(*ctx);
  });
}

} // namespace mlir