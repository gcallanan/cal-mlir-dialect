#ifndef CAL_TO_FUNC_H
#define CAL_TO_FUNC_H

#include "mlir/Pass/Pass.h"
#include "mlir/Transforms/DialectConversion.h"

namespace mlir {

std::unique_ptr<mlir::Pass> createConvertCalToFuncPass();

// Convenience factory to set options programmatically.
std::unique_ptr<mlir::Pass> createConvertCalToFuncPass(bool nonPreemptiveDefault);

#define GEN_PASS_DECL_CONVERTCALTOFUNC
#include "Conversion/Passes.h.inc"

} // namespace mlir

#endif