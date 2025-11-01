// FFT Butterfly network using scf.for for the bf children (close to CAL spec)
// T is instantiated as i32 for simplicity. Replace types and bodies as needed.
// You can elaborate constants with:
//   cal-opt --composite-fixed-point-pass="pipeline=cal-structural-elaboration" examples/fft/butterfly_scf_for.mlir

module {
  // pow2(a): 2^a for index a (pure, const-evaluable)
  func.func @pow2(%a: index) -> index {
    %c0 = arith.constant 0 : index
    %c1 = arith.constant 1 : index
    %c2 = arith.constant 2 : index
    %acc0 = arith.constant 1 : index
    %res = scf.for %i = %c0 to %a step %c1 iter_args(%acciter = %acc0) -> index {
      %accnext = arith.muli %acciter, %c2 : index
      scf.yield %accnext : index
    }
    return %res : index
  }

  // Split(N): in -> (out0, out1)
  cal.actor @Split(%N: index)
    ports_in(%in: !fifo.output_port<i32>)
    ports_out(%out0: !fifo.input_port<i32>, %out1: !fifo.input_port<i32>) {
    cal.execution_body {
      %f = arith.constant 0 : i1
      cal.action_done %f : i1
    }
  }

  // Merge(): (in0, in1) -> out
  cal.actor @Merge()
    ports_in(%in0: !fifo.output_port<i32>, %in1: !fifo.output_port<i32>)
    ports_out(%out: !fifo.input_port<i32>) {
    cal.execution_body {
      %f = arith.constant 0 : i1
      cal.action_done %f : i1
    }
  }

  // TwiddleGenerator(N): in -> out
  cal.actor @TwiddleGenerator(%N: index)
    ports_in(%in: !fifo.output_port<i32>)
    ports_out(%out: !fifo.input_port<i32>) {
    cal.execution_body {
      %f = arith.constant 0 : i1
      cal.action_done %f : i1
    }
  }

  // Radix2Cell: (in0, in1, in2) -> (out0, out1)
  cal.actor @Radix2Cell()
    ports_in(%in0: !fifo.output_port<i32>, %in1: !fifo.output_port<i32>, %in2: !fifo.output_port<i32>)
    ports_out(%out0: !fifo.input_port<i32>, %out1: !fifo.input_port<i32>) {
    cal.execution_body {
      %f = arith.constant 0 : i1
      cal.action_done %f : i1
    }
  }

  // BFChild is a placeholder for recursive Butterfly(NSTAGES-1)
  cal.actor @BFChild(%NSTAGES: index)
    ports_in(%in: !fifo.output_port<i32>)
    ports_out(%out: !fifo.input_port<i32>) {
    cal.execution_body {
      %f = arith.constant 0 : i1
      cal.action_done %f : i1
    }
  }

  // Butterfly with static NSTAGES (choose a constant for full elaboration): in ==> out
  cal.network @Butterfly()
    ports_in(%in: !fifo.output_port<i32>)
    ports_out(%out: !fifo.input_port<i32>) {
    %c0 = arith.constant 0 : index
    %c1 = arith.constant 1 : index
    %c2 = arith.constant 2 : index
    %NSTAGES = arith.constant 3 : index

    // N3 = 2^(NSTAGES - 1)
  %nstages_m1 = arith.subi %NSTAGES, %c1 : index
    %N3 = func.call @pow2(%nstages_m1) : (index) -> index

  // Entities (declare all entities first; no wiring here)
  %split = cal.instantiate @Split(%N3 : index) instance("split") : !cal.instance<@Split>
  %merge = cal.instantiate @Merge instance("merge") : !cal.instance<@Merge>
  %tw    = cal.instantiate @TwiddleGenerator(%N3 : index) instance("twiddles") : !cal.instance<@TwiddleGenerator>
  %r2    = cal.instantiate @Radix2Cell instance("r2cell") : !cal.instance<@Radix2Cell>
  // Array of BFChild instances (size 2) for the recursive stage; parameters set to NSTAGES-1
  %bf    = cal.instantiate_array @BFChild count(2) basename("bf") (%nstages_m1 : index) : !cal.instance.array<@BFChild, 2>

  // Structure: fixed wires (use canonical port names: in/inN, out/outN)
  cal.connect %in : !fifo.output_port<i32> "in" -> %split : !cal.instance<@Split> "in"
  cal.connect %in : !fifo.output_port<i32> "in" -> %tw : !cal.instance<@TwiddleGenerator> "in"
  cal.connect %merge : !cal.instance<@Merge> "out" -> %out : !fifo.input_port<i32> "out"

  // split has two outputs: out0/out1; r2 inputs are in0/in1/in2
  cal.connect %split : !cal.instance<@Split> "out0" -> %r2 : !cal.instance<@Radix2Cell> "in0"
  cal.connect %split : !cal.instance<@Split> "out1" -> %r2 : !cal.instance<@Radix2Cell> "in1"
  cal.connect %tw    : !cal.instance<@TwiddleGenerator> "out"  -> %r2 : !cal.instance<@Radix2Cell> "in2"

    // if NSTAGES > 1 then wire through bf[0], bf[1]; else wire directly to merge
  %gt1 = arith.cmpi sgt, %NSTAGES, %c1 : index
    scf.if %gt1 {
      %idx0 = arith.constant 0 : index
      %idx1 = arith.constant 1 : index
      %bf0 = cal.instance_at %bf[%idx0] : !cal.instance.array<@BFChild, 2>, index -> !cal.instance<@BFChild>
      %bf1 = cal.instance_at %bf[%idx1] : !cal.instance.array<@BFChild, 2>, index -> !cal.instance<@BFChild>

  // r2 outputs: out0/out1; bf child ports: in/out; merge inputs: in0/in1
  cal.connect %r2 : !cal.instance<@Radix2Cell> "out0" -> %bf0 : !cal.instance<@BFChild> "in"
  cal.connect %bf0 : !cal.instance<@BFChild> "out"   -> %merge : !cal.instance<@Merge> "in0"
  cal.connect %r2 : !cal.instance<@Radix2Cell> "out1" -> %bf1 : !cal.instance<@BFChild> "in"
  cal.connect %bf1 : !cal.instance<@BFChild> "out"   -> %merge : !cal.instance<@Merge> "in1"
    } else {
  // Base case: direct to merge
  cal.connect %r2 : !cal.instance<@Radix2Cell> "out0" -> %merge : !cal.instance<@Merge> "in0"
  cal.connect %r2 : !cal.instance<@Radix2Cell> "out1" -> %merge : !cal.instance<@Merge> "in1"
    }
  }
}
