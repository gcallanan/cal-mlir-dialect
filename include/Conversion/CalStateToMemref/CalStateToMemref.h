#ifndef CAL_STATE_TO_MEMREF_H
#define CAL_STATE_TO_MEMREF_H

#include "mlir/Pass/Pass.h"
#include "mlir/Transforms/DialectConversion.h"

namespace mlir {

std::unique_ptr<mlir::Pass> lowerCalStateToMemref();

#define GEN_PASS_DECL_LOWERCALSTATETOMEMREF
#include "Conversion/Passes.h.inc"

} // namespace mlir

#endif // CAL_STATE_TO_MEMREF_H