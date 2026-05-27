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
#include "mlir/Dialect/Async/IR/Async.h"

namespace mlir {

//===- Generated passes ---------------------------------------------------===//

constexpr int64_t CACHE_LINE_SIZE = 64;

enum class AllocLocation {
  HOST,
  GPU
};

enum class ActorPartitioningMode {
  Singlethreaded,
  Multithreaded
};

#define GEN_PASS_REGISTRATION
#include "Conversion/Passes.h.inc"

//===----------------------------------------------------------------------===//

} // namespace mlir::cal
