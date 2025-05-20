#ifndef CAL_MLIR_CONVERSION_PASSES
#define CAL_MLIR_CONVERSION_PASSES

include "mlir/Pass/PassBase.td"
include "Dialect/Cal/CalDialect.td"
include "Dialect/Fifo/FifoDialect.td"

def ConvertCalToFunc : Pass<"convert-cal-to-func"> {
    let summary = "A pass that converts CAL actors and networks to a series of functions that are called in a loop";

    let constructor = "mlir::createConvertCalToFuncPass()";

    let dependentDialects = [
        "func::FuncDialect",
        "fifo::FifoDialect",
        "cal::CalDialect",
    ];
}

def LowerCalStateToMemref: Pass<"lower-cal-state-to-memref"> {
  let summary = "Lower CAL state operations to MemRef dialect operations";
  let description = [{
    This pass lowers state-related operations from the CAL dialect, specifically
    `cal.state`, `cal.get`, and `cal.set`, to equivalent operations in the MemRef
    dialect. The transformation replaces CAL state definitions with `memref.alloc`
    operations, and rewrites `cal.get` and `cal.set` into `memref.load` and
    `memref.store`, respectively.

    Description originally written by Gareth Callanan and refined using ChatGPT.
  }];
  let constructor = "mlir::lowerCalStateToMemref()";
  let dependentDialects = [
    "cal::CalDialect",
    "index::IndexDialect",
    "arith::ArithDialect",
    "memref::MemRefDialect"
  ];
}

#endif // CAL_MLIR_CONVERSION_PASSES