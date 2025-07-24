#ifndef CAL_GENERIC_TRANSFORM_PASSES
#define CAL_GENERIC_TRANSFORM_PASSES

#include "mlir/Pass/Pass.h"
#include "Dialect/Cal/CalDialect.h"
#include "Dialect/Fifo/FifoDialect.h"
#include "Transforms/GPUAwareBufferize/GPUAwareBufferize.h"
#include "Transforms/DenseConstantsToGPU/DenseConstantsToGPU.h"

namespace mlir {

//===- Generated passes ---------------------------------------------------===//

#define GEN_PASS_REGISTRATION
#include "Transforms/Passes.h.inc"

//===----------------------------------------------------------------------===//

} // namespace mlir::cal

#endif // CAL_GENERIC_TRANSFORM_PASSES