#ifndef CAL_TO_FUNC_H
#define CAL_TO_FUNC_H

#include "mlir/Pass/Pass.h"
#include "mlir/Transforms/DialectConversion.h"

namespace mlir {

#define GEN_PASS_DECL_CONVERTCALTOFUNC
#include "Conversion/Passes.h.inc"

} // namespace mlir

#endif