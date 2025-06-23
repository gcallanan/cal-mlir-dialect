#ifndef CAL_MLIR_CONVERSION_PASSES
#define CAL_MLIR_CONVERSION_PASSES

include "mlir/Pass/PassBase.td"
include "Dialect/Cal/CalDialect.td"
include "Dialect/Fifo/FifoDialect.td"

def ConvertCalToFunc : Pass<"convert-cal-to-func"> {
    let summary = "A pass that converts CAL actors and networks to a series of functions that are called in a loop";
    let description = [{
        Creates a pass to lower CAL dialect operations (`cal.actor`, `cal.network`,
        and related constructs) into standard MLIR `func` operations suitable for
        LLVM lowering and execution.
        This pass performs a series of rewrites to:
          - Convert each `cal.actor` into a `func.func` function with matching
            arguments and logic.
          - Replace `cal.create_instance` operations with calls to the corresponding
            actor functions, passing necessary operands explicitly.
          - Rewrite `cal.action_done` into a `func.return` to signal action
            completion.
          - Transform the top-level `cal.network` into a `func.func` called "main",
            which initializes the network and then repeatedly calls each actor
            function in a `scf.while` loop until no actor performs any further work.
        After this transformation, the CAL program is expressed entirely in terms of
        `func.func`, `func.call`, and other core dialects, enabling straightforward
        lowering to LLVM.

        NOTE: This pass only supports cal.actors containing a cal.execution_body
        and does not support cal.actors containing cal.action operations. If
        such operations are present, the pass will fail. Each
        cal.action represents its own CFG and a function
        with multiple CFGs does not make sense. These instead need to be merged
        into a single CFG which is what the cal.execution_body represents. There
        should be a different pass that merges the cal.actions into a single
        cal.execution_body which should be run before this pass.

        Description originally written by Gareth Callanan and refined using ChatGPT.
    }];

    let constructor = "mlir::createConvertCalToFuncPass()";

    let dependentDialects = [
        "func::FuncDialect",
        "fifo::FifoDialect",
        "cal::CalDialect",
        "scf::SCFDialect"
    ];
}

def LowerCalStateToMemref: Pass<"lower-cal-state-to-memref"> {
  let summary = "Lower CAL state operations to MemRef dialect operations";
  let description = [{
    This pass lowers state-related operations from the CAL dialect, specifically
    `cal.state`, `cal.get`, and `cal.set`, to equivalent operations in the MemRef
    dialect. The transformation replaces CAL state definitions with `memref.alloc`
    operations, and rewrites `cal.get` and `cal.set` into `memref.load` and
    `memref.store`, respectively. It also creates `memref.dealloc` operations
    at the end of the region to deallocate allocated memory

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

def ConvertCalToFuncWithStaticSchedule : Pass<"convert-cal-to-func-with-static-schedule"> {
    let summary = "TODO";
    let description = [{
        
    }];

    let options = [
      Option<"print_fsm_for_testing", "print-fsm-for-testing", "bool", /*default=*/"false",
            "Print out the FSM for each actor for testing purposes.">,
    ];

    let constructor = "mlir::createConvertCalToFuncWithStaticSchedulePass()";

    let dependentDialects = [
        "func::FuncDialect",
        "fifo::FifoDialect",
        "cal::CalDialect",
        "scf::SCFDialect"
    ];
}

#endif // CAL_MLIR_CONVERSION_PASSES