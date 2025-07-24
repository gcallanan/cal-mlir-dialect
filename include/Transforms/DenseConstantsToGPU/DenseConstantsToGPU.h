#ifndef DENSECONSTANTSTOGPU_H
#define DENSECONSTANTSTOGPU_H

#include "mlir/Pass/Pass.h"
#include "mlir/Transforms/DialectConversion.h"

namespace mlir {

#define GEN_PASS_DECL_DENSECONSTANTSTOGPUPASS
#include "Transforms/Passes.h.inc"

} // namespace mlir

#endif