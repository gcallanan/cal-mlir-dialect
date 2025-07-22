#ifndef CONVERT_FIFO_TO_MEMREF_H
#define CONVERT_FIFO_TO_MEMREF_H

#include "mlir/Pass/Pass.h"
#include "mlir/Transforms/DialectConversion.h"

namespace mlir {

#define GEN_PASS_DECL_LOWERFIFOTOMEMREFPASS
#include "Conversion/Passes.h.inc"

} // namespace mlir

#endif // CONVERT_FIFO_TO_MEMREF_H