#pragma once

#include "mlir/Pass/Pass.h"
#include "Dialect/Cal/CalDialect.h"
#include "Dialect/Fifo/FifoDialect.h"
#include "Conversion/CalToFunc/CalToFunc.h"
#include "Conversion/CalStateToMemref/CalStateToMemref.h"
#include "Conversion/CalToFuncWithStaticSchedule/CalToFuncWithStaticSchedule.h"
#include "Conversion/FifoToMemref/ConvertFifoToMemref.h"
#include "Conversion/DecomposeFifoTuples/DecomposeFifoTuples.h"
#include "Conversion/CalMemoryToLLVM/CalMemoryToLLVM.h"
#include "Conversion/CalVariantToLLVM/CalVariantToLLVM.h"

namespace mlir {

//===- Generated passes ---------------------------------------------------===//

enum class AllocLocation {
  HOST,
  GPU
};

#define GEN_PASS_REGISTRATION
#include "Conversion/Passes.h.inc"

//===----------------------------------------------------------------------===//

} // namespace mlir::cal
