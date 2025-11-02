// RUN: cal-opt --flatten-cal-networks='allow-dynamic-indices allow-partial-connectivity' -verify-diagnostics %s

// An actor with one input and one output FIFO port
cal.actor @A()
  ports_in(%i: !fifo.output_port<i32>)
  ports_out(%o: !fifo.input_port<i32>) {
  cal.execution_body {
    %t = arith.constant true
    cal.action_done %t : i1
  }
}

// Build a 2D instance array via init/set and attempt to connect with a dynamic ND index
cal.network @DynNDAllow() {
  %i0 = arith.constant 0 : index
  %cond = arith.constant true
  %in0, %out0 = fifo.create<i32>(2) : !fifo.input_port<i32>, !fifo.output_port<i32>

  // Make a "dynamic" index via scf.if even though both branches are constant; elaboration treats it as dynamic
  %di = scf.if %cond -> (index) {
    scf.yield %i0 : index
  } else {
    scf.yield %i0 : index
  }

  // Prepare a concrete handle and place it in [0,0] of a 2D array
  // expected-remark@+1 {{skipping materialization of partially-connected instance}}
  %h00 = cal.instantiate @A instance("a00") : !cal.instance<@A>
  %arr0 = cal.instance.array.init : !cal.instance.array<@A, [2, 2]>
  %arr1 = cal.instance.array.set %arr0[%i0, %i0], %h00 : !cal.instance.array<@A, [2, 2]>, !cal.instance<@A> -> !cal.instance.array<@A, [2, 2]>

  // Dynamic ND index on source; elaboration should skip and emit a remark under allow-dynamic-indices
  // expected-remark@+1 {{skipping connect with dynamic ND array index during elaboration}}
  cal.connect %arr1[%di, %i0] : !cal.instance.array<@A, [2, 2]> "out" -> %in0 : !fifo.input_port<i32> "out"
}

// (No IR checks here; this test validates expected diagnostics only.)