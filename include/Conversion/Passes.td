#ifndef CAL_MLIR_CONVERSION_PASSES
#define CAL_MLIR_CONVERSION_PASSES

include "mlir/Pass/PassBase.td"
include "Dialect/Cal/CalDialect.td"
include "Dialect/Fifo/FifoDialect.td"

def ConvertCalToFunc : Pass<"convert-cal-to-func"> {
    let summary = "A pass that converts CAL actors and networks to a series of functions that are called in a loop";

    let constructor = "mlir::cal::createConvertCalToFuncPass()";

    let dependentDialects = [
        "func::FuncDialect",
        "fifo::FifoDialect",
        "cal::CalDialect",
    ];
}

#endif // CAL_MLIR_CONVERSION_PASSES