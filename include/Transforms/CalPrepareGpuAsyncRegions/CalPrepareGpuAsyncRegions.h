#ifndef CALPREPAREGPUASYNCREGIONS_H
#define CALPREPAREGPUASYNCREGIONS_H

#include "mlir/Pass/Pass.h"
#include "mlir/Transforms/DialectConversion.h"
#include "Transforms/Passes.h"

namespace mlir {

#define GEN_PASS_DECL_CALPREPAREGPUASYNCREGIONSPASS
#include "Transforms/Passes.h.inc"

} // namespace mlir

#endif