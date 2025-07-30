#ifndef CAL_GENERIC_TRANSFORM_PASSES
#define CAL_GENERIC_TRANSFORM_PASSES

#include "Dialect/Cal/CalDialect.h"
#include "Dialect/Fifo/FifoDialect.h"
#include "Transforms/DenseConstantsToGPU/DenseConstantsToGPU.h"
#include "Transforms/GPUAwareBufferize/GPUAwareBufferize.h"
#include "Transforms/HoistAllocs/HoistAllocs.h"
#include "Transforms/CalPrepareGpuAsyncRegions/CalPrepareGpuAsyncRegions.h"
#include "mlir/Pass/Pass.h"

namespace mlir {

//===- Generated passes ---------------------------------------------------===//

#define GEN_PASS_REGISTRATION
#include "Transforms/Passes.h.inc"

//===----------------------------------------------------------------------===//

} // namespace mlir

#endif // CAL_GENERIC_TRANSFORM_PASSES