// FFT Butterfly network (SCF-first) matching the CAL spec intent
// - T assumed as fp32
// - NSTAGES is passed as a parameter (not constant-propagated into this network)
// - pow2 is a pure helper and is called inside Butterfly to compute N3 = 2^(NSTAGES-1)
// - bf is an instance array of Butterfly(NSTAGES-1), constructed via array.init + scf.for + array.set
// - structure uses scf.if to wire either through bf[0]/bf[1] or directly to merge
//
// Try (preserving SCF condition and partial connectivity decisions at elaboration time):
//   cal-opt --flatten-cal-networks=allow-partial-connectivity \
//           /Users/endrix/git/dataflow/cal-mlir-dialect/examples/fft/butterfly_scf_for.mlir
// Or (if you want the condition folded for a specific NSTAGES in the outer network):
//   cal-opt -canonicalize --flatten-cal-networks \
//           /Users/endrix/git/dataflow/cal-mlir-dialect/examples/fft/butterfly_scf_for.mlir

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
    ports_in(%in: !fifo.output_port<f32>)
    ports_out(%out0: !fifo.input_port<f32>, %out1: !fifo.input_port<f32>) {
    cal.execution_body {
      %f = arith.constant false
      cal.action_done %f : i1
    }
  }

  // Merge(): (in0, in1) -> out
  cal.actor @Merge()
    ports_in(%in0: !fifo.output_port<f32>, %in1: !fifo.output_port<f32>)
    ports_out(%out: !fifo.input_port<f32>) {
    cal.execution_body {
      %f = arith.constant false
      cal.action_done %f : i1
    }
  }

  // TwiddleGenerator(N): in -> out
  cal.actor @TwiddleGenerator(%N: index)
    ports_in(%in: !fifo.output_port<f32>)
    ports_out(%out: !fifo.input_port<f32>) {
    cal.execution_body {
      %f = arith.constant false
      cal.action_done %f : i1
    }
  }

  // Radix2Cell: (in0, in1, in2) -> (out0, out1)
  cal.actor @Radix2Cell()
    ports_in(%in0: !fifo.output_port<f32>, %in1: !fifo.output_port<f32>, %in2: !fifo.output_port<f32>)
    ports_out(%out0: !fifo.input_port<f32>, %out1: !fifo.input_port<f32>) {
    cal.execution_body {
      %f = arith.constant false
      cal.action_done %f : i1
    }
  }

  // Butterfly is a placeholder actor representing the recursive Butterfly(NSTAGES-1)
  // It is parameterized to keep the structure generic; body is elided here.


  // Recursive Butterfly(T=f32, NSTAGES)
  // Ports: in ==> out
  cal.network @Butterfly(%NSTAGES: index)
    ports_in(%in: !fifo.output_port<f32>)
    ports_out(%out: !fifo.input_port<f32>) {
    %c0 = arith.constant 0 : index
    %c1 = arith.constant 1 : index
    %c2 = arith.constant 2 : index

    // N3 = 2^(NSTAGES - 1)
    %nstages_m1 = arith.subi %NSTAGES, %c1 : index
    %N3 = func.call @pow2(%nstages_m1) : (index) -> index

    // nBF = if NSTAGES > 1 then 2 else 0
    %gt1 = arith.cmpi sgt, %NSTAGES, %c1 : index
    %nBF = scf.if %gt1 -> (index) {
      scf.yield %c2 : index
    } else {
      scf.yield %c0 : index
    }

    // Entities
    %split = cal.instantiate @Split(%N3 : index) instance("split") : !cal.instance<@Split>
    %merge = cal.instantiate @Merge instance("merge") : !cal.instance<@Merge>
    %tw    = cal.instantiate @TwiddleGenerator(%N3 : index) instance("twiddles") : !cal.instance<@TwiddleGenerator>
    %r2    = cal.instantiate @Radix2Cell instance("r2cell") : !cal.instance<@Radix2Cell>

    // Instance array of Butterfly(NSTAGES-1), length = nBF (dynamic); SCF-first construction
    %bf0 = cal.instance.array.init(%nBF : index) : !cal.instance.array<@Butterfly, [?]>
    %bf = scf.for %i = %c0 to %nBF step %c1 iter_args(%acc = %bf0) -> !cal.instance.array<@Butterfly, [?]> {
      %child = cal.instantiate @Butterfly(%nstages_m1 : index) instance("bf") : !cal.instance<@Butterfly>
      %acc2 = cal.instance.array.set %acc[%i], %child : !cal.instance.array<@Butterfly, [?]>, !cal.instance<@Butterfly> -> !cal.instance.array<@Butterfly, [?]>
      scf.yield %acc2 : !cal.instance.array<@Butterfly, [?]>
    }

    // Structure: fixed wires (canonical port names)
    cal.connect %in : !fifo.output_port<f32> "in" -> %split : !cal.instance<@Split> "in"
    cal.connect %in : !fifo.output_port<f32> "in" -> %tw : !cal.instance<@TwiddleGenerator> "in"
    cal.connect %merge : !cal.instance<@Merge> "out" -> %out : !fifo.input_port<f32> "out"

    cal.connect %split : !cal.instance<@Split> "out0" -> %r2 : !cal.instance<@Radix2Cell> "in0"
    cal.connect %split : !cal.instance<@Split> "out1" -> %r2 : !cal.instance<@Radix2Cell> "in1"
    cal.connect %tw    : !cal.instance<@TwiddleGenerator> "out" -> %r2 : !cal.instance<@Radix2Cell> "in2"

    // If NSTAGES > 1 then route through bf[0], bf[1]; else directly to merge
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

  // (Optional) instantiate this network from a higher-level environment by
  // inlining or by generating a top-level driver that supplies %NSTAGES.
}

