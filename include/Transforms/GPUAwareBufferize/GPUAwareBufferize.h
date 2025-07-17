#ifndef GPUAWAREBUFFERIZE_H
#define GPUAWAREBUFFERIZE_H

#include "mlir/Pass/Pass.h"
#include "mlir/Transforms/DialectConversion.h"

namespace mlir {

std::unique_ptr<mlir::Pass> createGpuAwareBufferizePass();

#define GEN_PASS_DECL_GPUAWAREBUFFERIZEPASS
#include "Transforms/Passes.h.inc"

} // namespace mlir

#endif