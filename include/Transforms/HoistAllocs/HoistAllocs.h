#ifndef HOISTALLOCS_H
#define HOISTALLOCS_H

#include "mlir/Pass/Pass.h"
#include "mlir/Transforms/DialectConversion.h"

namespace mlir {

#define GEN_PASS_DECL_HOISTALLOCSPASS
#include "Transforms/Passes.h.inc"

} // namespace mlir

#endif