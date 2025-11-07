module {
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

  cal.actor @Split(%N: index)
    ports_in(%in: !fifo.output_port<f32>)
    ports_out(%out0: !fifo.input_port<f32>, %out1: !fifo.input_port<f32>) {
    cal.execution_body {
      %f = arith.constant false
      cal.action_done %f : i1
    }
  }

  cal.actor @Merge()
    ports_in(%in0: !fifo.output_port<f32>, %in1: !fifo.output_port<f32>)
    ports_out(%out: !fifo.input_port<f32>) {
    cal.execution_body {
      %f = arith.constant false
      cal.action_done %f : i1
    }
  }

  cal.actor @TwiddleGenerator(%N: index)
    ports_in(%in: !fifo.output_port<f32>)
    ports_out(%out: !fifo.input_port<f32>) {
    cal.execution_body {
      %f = arith.constant false
      cal.action_done %f : i1
    }
  }

  cal.actor @Radix2Cell()
    ports_in(%in0: !fifo.output_port<f32>, %in1: !fifo.output_port<f32>, %in2: !fifo.output_port<f32>)
    ports_out(%out0: !fifo.input_port<f32>, %out1: !fifo.input_port<f32>) {
    cal.execution_body {
      %f = arith.constant false
      cal.action_done %f : i1
    }
  }

  cal.network @Butterfly(%NSTAGES: index)
    ports_in(%in: !fifo.output_port<f32>)
    ports_out(%out: !fifo.input_port<f32>) {
    %c0 = arith.constant 0 : index
    %c1 = arith.constant 1 : index
    %c2 = arith.constant 2 : index

    %nstages_m1 = arith.subi %NSTAGES, %c1 : index
    %N3 = func.call @pow2(%nstages_m1) : (index) -> index

    %gt1 = arith.cmpi sgt, %NSTAGES, %c1 : index
    %nBF = scf.if %gt1 -> (index) {
      scf.yield %c2 : index
    } else {
      scf.yield %c0 : index
    }

    %split = cal.instantiate @Split(%N3 : index) instance("split") : !cal.instance<@Split>
    %merge = cal.instantiate @Merge instance("merge") : !cal.instance<@Merge>
    %tw    = cal.instantiate @TwiddleGenerator(%N3 : index) instance("twiddles") : !cal.instance<@TwiddleGenerator>
    %r2    = cal.instantiate @Radix2Cell instance("r2cell") : !cal.instance<@Radix2Cell>

    %bf0 = cal.instance.array.init(%nBF : index) : !cal.instance.array<@Butterfly, [?]>
    %bf = scf.for %i = %c0 to %nBF step %c1 iter_args(%acc = %bf0) -> !cal.instance.array<@Butterfly, [?]> {
      %child = cal.instantiate @Butterfly(%nstages_m1 : index) instance("bf") : !cal.instance<@Butterfly>
      %acc2 = cal.instance.array.set %acc[%i], %child : !cal.instance.array<@Butterfly, [?]>, !cal.instance<@Butterfly> -> !cal.instance.array<@Butterfly, [?]>
      scf.yield %acc2 : !cal.instance.array<@Butterfly, [?]>
    }

    cal.connect %in : !fifo.output_port<f32> "in" -> %split : !cal.instance<@Split> "in"
    cal.connect %in : !fifo.output_port<f32> "in" -> %tw : !cal.instance<@TwiddleGenerator> "in"
    cal.connect %merge : !cal.instance<@Merge> "out" -> %out : !fifo.input_port<f32> "out"

    cal.connect %split : !cal.instance<@Split> "out0" -> %r2 : !cal.instance<@Radix2Cell> "in0"
    cal.connect %split : !cal.instance<@Split> "out1" -> %r2 : !cal.instance<@Radix2Cell> "in1"
    cal.connect %tw    : !cal.instance<@TwiddleGenerator> "out" -> %r2 : !cal.instance<@Radix2Cell> "in2"

    %i0 = arith.constant 0 : index
    %i1 = arith.constant 1 : index
    scf.if %gt1 {
      cal.connect %r2 : !cal.instance<@Radix2Cell> "out0" -> %bf[%i0] : !cal.instance.array<@Butterfly, [?]> "in"
      cal.connect %bf[%i0] : !cal.instance.array<@Butterfly, [?]> "out" -> %merge : !cal.instance<@Merge> "in0"
      cal.connect %r2 : !cal.instance<@Radix2Cell> "out1" -> %bf[%i1] : !cal.instance.array<@Butterfly, [?]> "in"
      cal.connect %bf[%i1] : !cal.instance.array<@Butterfly, [?]> "out" -> %merge : !cal.instance<@Merge> "in1"
    } else {
      cal.connect %r2 : !cal.instance<@Radix2Cell> "out0" -> %merge : !cal.instance<@Merge> "in0"
      cal.connect %r2 : !cal.instance<@Radix2Cell> "out1" -> %merge : !cal.instance<@Merge> "in1"
    }
  }

  // Top network that fixes NSTAGES = 2 and wires IO
  cal.network @Top()
    ports_in(%in: !fifo.output_port<f32>)
    ports_out(%out: !fifo.input_port<f32>) {
    %two = arith.constant 2 : index
    %bf = cal.instantiate @Butterfly(%two : index) instance("bf_top") : !cal.instance<@Butterfly>
    cal.connect %in : !fifo.output_port<f32> "in" -> %bf : !cal.instance<@Butterfly> "in"
    cal.connect %bf : !cal.instance<@Butterfly> "out" -> %out : !fifo.input_port<f32> "out"
  }
}
