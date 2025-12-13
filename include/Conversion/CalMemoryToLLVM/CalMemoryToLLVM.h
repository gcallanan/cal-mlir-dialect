#ifndef CAL_MEMORY_TO_LLVM_H
#define CAL_MEMORY_TO_LLVM_H

#include "mlir/Pass/Pass.h"
#include "mlir/Transforms/DialectConversion.h"

namespace mlir {

#define GEN_PASS_DECL_CONVERTCALMEMORYTOLLVM
#include "Conversion/Passes.h.inc"

} // namespace mlir

#endif // CAL_MEMORY_TO_LLVM_H
