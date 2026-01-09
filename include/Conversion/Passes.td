#ifndef CAL_MLIR_CONVERSION_PASSES
#define CAL_MLIR_CONVERSION_PASSES

include "mlir/Pass/PassBase.td"
include "Dialect/Cal/CalDialect.td"
include "Dialect/Fifo/FifoDialect.td"

def ConvertCalToFunc : Pass<"convert-cal-to-func"> {
    let summary = "A pass that converts CAL actors and networks to function calls and a main function";
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
            which initializes the network and starts the execution.
        After this transformation, the CAL program is expressed entirely in terms of
        `func.func`, `func.call`, and other core dialects, enabling straightforward
        lowering to LLVM.

        This pass supports creation of a multi-threaded implementation by allowing
        actors to be executed in single threads. This is controlled via the
        `--actor-partitioning-mode` flag.

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

    let options = [
      Option<"actor_paritioning_mode", "actor-paritioning-mode", "std::string",
        /*default=*/"\"single-threaded\"",
        "Actor partitioning mode : single-threaded | one-actor-per-thread">,
    ];

    let dependentDialects = [
        "func::FuncDialect",
        "fifo::FifoDialect",
        "async::AsyncDialect",
        "LLVM::LLVMDialect",
        "cal::CalDialect",
        "scf::SCFDialect",
        "memref::MemRefDialect",
    ];
}

def LowerCalStateToMemref: Pass<"lower-cal-state-to-memref"> {
  let summary = "Lower CAL state operations to MemRef dialect operations";
  let description = [{
    This pass lowers state-related operations from the CAL dialect, specifically
    `cal.create_state_var`, `cal.get`, and `cal.set`, to equivalent operations in the MemRef
    dialect. The transformation replaces CAL state definitions with `memref.alloc`
    operations with different behaviors based on the state type:

    - For scalar types: Creates a `memref.alloc` of size 1 to simulate scalar state.
      `cal.get` becomes `memref.load` from index 0, and `cal.set` becomes `memref.store` to index 0.
    - For memref types: The memref becomes the buffer directly without additional wrapping.
      `cal.get` returns the memref directly, and `cal.set` uses `memref.copy` to copy data.
    - For tensor types: Converts tensors to equivalent memref types for allocation.
      `cal.get` retrieves from buffer and converts to tensor using `bufferization.to_tensor`,
      and `cal.set` converts tensor to memref using `bufferization.to_memref` and copies.

    Memory deallocation can be handled by other MLIR passes (such as --buffer-deallocation).

    Description originally written by Gareth Callanan and refined using ChatGPT.
  }];

  let options = [
    Option<"which_alloc", "which-alloc", "std::string", /*default=*/"\"HOST\"",
           "Choose allocation target for tensor types: HOST | GPU">,
  ];

  let dependentDialects = [
    "cal::CalDialect",
    "gpu::GPUDialect",
    "index::IndexDialect",
    "arith::ArithDialect",
    "memref::MemRefDialect",
    "tensor::TensorDialect",
    "bufferization::BufferizationDialect"
  ];
}

def ConvertCalToFuncWithStaticSchedule : Pass<"convert-cal-to-func-with-static-schedule"> {
    let summary = "A pass that converts CAL actors and networks to functions using static scheduling";
    let description = [{
        Creates a pass to lower CAL dialect operations (`cal.actor` with `cal.action`
        operations, `cal.network`, and related constructs) into standard MLIR `func`
        operations using cyclo-static dataflow (CSDF) analysis for deterministic
        static scheduling.

        This pass differs from `ConvertCalToFunc` by supporting actors with multiple
        named actions and generating static schedules instead of dynamic while loops.
        It performs the following transformations:

          - Runs CSDF analysis to compute firing patterns, balance equations, and
            static schedules for all actors in the network.
          - Converts each `cal.action` within a `cal.actor` into a separate
            `func.func` function named `{actorName}_{actionName}`, with predicates
            wrapped in `scf.if` operations.
          - Transforms the top-level `cal.network` into a `func.func` called "main"
            with explicit control flow based on the pre-computed static schedule.
          - Creates basic blocks for each action firing in the schedule, with
            conditional branches based on predicate evaluation results.
          - Hoists state variable declarations from actor bodies to the network
            level to avoid duplication.

        The resulting code has deterministic execution order and eliminates runtime
        scheduling overhead, making it suitable for real-time applications and
        enabling better static analysis.

        NOTE: This pass only supports `cal.actor` operations containing `cal.action`
        operations and requires all actors to be either synchronous dataflow (SDF)
        or cyclo-static dataflow (CSDF) actors. Non-schedulable actors will cause
        the pass to fail. This is complementary to `ConvertCalToFunc` which handles
        actors with `cal.execution_body`.

        Description originally written by Gareth Callanan and refined using Copilot.
    }];

    let options = [
      Option<"print_fsm_for_testing", "print-fsm-for-testing", "bool", /*default=*/"false",
            "Print out the FSM for each actor for testing purposes.">,
      Option<"print_csdf_schedule_for_testing", "print-csdf-schedule-for-testing", "bool", /*default=*/"false",
            "Print out the CSDF schedule for each actor for testing purposes.">,
      Option<"print_balance_equations_for_testing", "print-balance-equations-for-testing", "bool", /*default=*/"false",
            "Print out the balance equations generated for the network.">,
      Option<"print_solved_balance_equations_for_testing", "print-solved-balance-equations-for-testing", "bool", /*default=*/"false",
            "Print out the number of firings per actor by solving the balance equations.">,
      Option<"print_static_schedule_for_testing", "print-static-schedule-for-testing", "bool", /*default=*/"false",
            "Generate an action-level schedule using the solved balance equations.">,
      Option<"exit_on_testing_print", "exit-on-testing-print", "bool", /*default=*/"false",
          "Exits compilation after testing print complete. Does not print IR afterwards">,
    ];

    let dependentDialects = [
        "func::FuncDialect",
        "fifo::FifoDialect",
        "cal::CalDialect",
        "cf::ControlFlowDialect",
        "scf::SCFDialect"
    ];
}

def LowerFifoToMemrefPass: Pass<"lower-fifo-to-memref"> {
  let summary = "Lowers to fifo dialect to memref dialect";
  let description = [{
    The `lower-fifo-to-memref` pass converts operations in the FIFO dialect to equivalent
    operations in the MemRef dialect. This pass is used to lower abstract FIFO queues into
    concrete representation of this FIFO in memory.

    This pass works by transforming FIFO buffer operations (such as `fifo.create`, `fifo.push`,
    and `fifo.pop`) into MemRef-based operations that represent memory buffers. The pass
    supports scalar, tensor, and memref element types, handling tensor-to-memref conversions
    as needed for FIFO operations. 

    Thread-safety / concurrency:

    By default (index mode `legacy`) the lowered representation uses a circular buffer with
    read/write indices stored modulo (capacity + 1) and assumes single-threaded scheduling.
    An experimental SPSC lock-free mode can be enabled with the option
    `--fifo-index-mode=spsc-lockfree`. In this mode the indices are treated as monotonically
    increasing counters (no extra sentinel slot) and each push/pop uses the counter modulo
    capacity for the physical slot. This mode is intended for Single-Producer / Single-Consumer
    scenarios possibly executed on different threads orchestrated by the async dialect or host
    threading. Atomics are not yet inserted at this lowering stage; correctness under true
    parallel execution requires a subsequent pass (or future enhancement) to turn the loads /
    stores of the index counters into acquire/release atomic operations. Until that follow-up
    is implemented the SPSC mode should only be used in environments where the compiler or
    runtime preserves program order between producer and consumer steps.

    Description originally written by Gareth Callanan and refined using ChatGPT.
  }];
  let options = [
    Option<"which_alloc", "which-alloc", "std::string", /*default=*/"\"HOST\"",
           "Choose allocation target for tensor types: HOST | GPU">,
    Option<"fifo_index_mode", "fifo-index-mode", "std::string", /*default=*/"\"legacy\"",
      "FIFO index management mode: legacy | spsc-lockfree">,
  ];
  let dependentDialects = [
    "memref::MemRefDialect",
    "index::IndexDialect",
    "arith::ArithDialect",
    "fifo::FifoDialect",
    "tensor::TensorDialect",
    "gpu::GPUDialect",
    "bufferization::BufferizationDialect"
  ];
}

def DecomposeFifoTuples: Pass<"decompose-fifo-tuples"> {
  let summary = "Eliminate tuple constructs in the FIFO dialect.";
  let description = [{
    In the FIFO dialect, the `lower-fifo-to-memref` pass transforms `fifo.input_port`
    and `fifo.output_port` operations into `memref` types, resulting in types like
    `tuple<memref<Axi32>, memref<Bxi32>>`. These are constructed using the
    `fifo.make_tuple` operation (e.g., `%tuple = fifo.make_tuple(%a, %b)`) and accessed
    via `fifo.get_element` (e.g., `%element = fifo.get_element(%tuple, %index)`).

    This pass simplifies the IR by removing `fifo.make_tuple` and
    `fifo.get_element` operations, replacing tuple-based constructs with direct use of
    the original operands.

    Description originally written by Gareth Callanan and refined using ChatGPT.
  }];
  let dependentDialects = [
    "fifo::FifoDialect"
  ];
}

#endif // CAL_MLIR_CONVERSION_PASSES