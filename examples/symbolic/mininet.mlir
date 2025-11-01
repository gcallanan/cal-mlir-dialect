// Minimal end-to-end symbolic example using instantiate/connect and flattening.
// You can run:
//   cal-opt -pass-pipeline='builtin.module(flatten-cal-networks)' examples/symbolic/mininet.mlir \
//     | cal-opt --lower-cal-to-llvm \
//     | mlir-runner --entry-point-result=void

cal.actor @Producer(%n: i32)
  out_names ["out"]
  ports_out(%o: !fifo.input_port<i32>) {
  // Fire exactly once: track a boolean state flag
  %f = cal.create_state_var<i1> : !cal.state_ref<i1>
  %false = arith.constant false
  cal.set(%f: !cal.state_ref<i1>, %false: i1)

  cal.execution_body {
    %false0 = arith.constant false
    %true0 = arith.constant true
    %v = cal.get(%f: !cal.state_ref<i1>) : i1
    %not_fired = arith.cmpi eq, %v, %false0 : i1
    scf.if %not_fired {
      // mark fired
      cal.set(%f: !cal.state_ref<i1>, %true0: i1)
      scf.yield
    } else {
      scf.yield
    }
    cal.action_done %not_fired : i1
  }
}

cal.actor @Consumer()
  in_names ["in"] out_names ["out"]
  ports_in(%i: !fifo.output_port<i32>)
  ports_out(%o: !fifo.input_port<i32>) {
  // Fire exactly once
  %f = cal.create_state_var<i1> : !cal.state_ref<i1>
  %false = arith.constant false
  cal.set(%f: !cal.state_ref<i1>, %false: i1)

  cal.execution_body {
    %false0 = arith.constant false
    %true0 = arith.constant true
    %v = cal.get(%f: !cal.state_ref<i1>) : i1
    %not_fired = arith.cmpi eq, %v, %false0 : i1
    scf.if %not_fired {
      cal.set(%f: !cal.state_ref<i1>, %true0: i1)
      scf.yield
    } else {
      scf.yield
    }
    cal.action_done %not_fired : i1
  }
}

cal.network @Top() {
  %n = arith.constant 4 : i32
  // boundary ports
  %sink_in, %sink_out = fifo.create<i32>(2) : !fifo.input_port<i32>, !fifo.output_port<i32>

  // instantiate actors symbolically
  %p = cal.instantiate @Producer (%n : i32) : !cal.instance<@Producer>
  %c = cal.instantiate @Consumer : !cal.instance<@Consumer>

  // connect producer -> consumer
  cal.connect %p : !cal.instance<@Producer> "out" -> %c : !cal.instance<@Consumer> "in"

  // connect consumer to network sink
  cal.connect %c : !cal.instance<@Consumer> "out" -> %sink_in : !fifo.input_port<i32> "in"
}
