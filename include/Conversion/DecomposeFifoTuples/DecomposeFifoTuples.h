#ifndef DECOMPOSE_FIFO_TUPLES_H
#define DECOMPOSE_FIFO_TUPLES_H

#include "mlir/Pass/Pass.h"
#include "mlir/Transforms/DialectConversion.h"

namespace mlir {

#define GEN_PASS_DECL_DECOMPOSEFIFOTUPLES
#include "Conversion/Passes.h.inc"

} // namespace mlir

#endif // DECOMPOSE_FIFO_TUPLES_H