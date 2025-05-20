#pragma once

#include "mlir/Pass/Pass.h"
#include "Dialect/Cal/CalDialect.h"
#include "Dialect/Fifo/FifoDialect.h"
#include "Conversion/CalToFunc/CalToFunc.h"

namespace mlir {

//===- Generated passes ---------------------------------------------------===//

#define GEN_PASS_REGISTRATION
#include "Conversion/Passes.h.inc"

//===----------------------------------------------------------------------===//

} // namespace mlir::cal
