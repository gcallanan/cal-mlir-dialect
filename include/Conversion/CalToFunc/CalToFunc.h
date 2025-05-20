#ifndef CAL_TO_FUNC_H
#define CAL_TO_FUNC_H

#include "mlir/Pass/Pass.h"
#include "mlir/Transforms/DialectConversion.h"

namespace mlir {
namespace cal {

//===- Generated includes -------------------------------------------------===//

// #define GEN_PASS_DECL_CONVERTCALTOFUNC
// #include "Conversion/Passes.h.inc"

//===----------------------------------------------------------------------===//

std::unique_ptr<Pass> createConvertCalToFuncPass();

#define GEN_PASS_DECL_CONVERTCALTOFUNC
#include "Conversion/Passes.h.inc"

} // namespace cal
} // namespace mlir

#endif