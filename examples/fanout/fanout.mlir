module {
  cal.actor @test__Source()
    out_names ["OUT"]
    ports_out(%OUT: !fifo.input_port<i32>)
  {
    %t0 = cal.create_state_var<i32> : !cal.state_ref<i32>
    %t1 = arith.constant 0 : i32 loc(#loc0)
    cal.set(%t0: !cal.state_ref<i32>, %t1: i32)
    cal.action "$untagged0" priority=0 {
      cal.predicate {
        %t2 = cal.get(%t0: !cal.state_ref<i32>) : i32
        %t3 = arith.constant 5 : i32 loc(#loc1)
        %t4 = arith.cmpi slt, %t2, %t3 : i32 loc(#loc2)
        cal.predicate_result %t4 : i1
      }
      %t5 = cal.get(%t0: !cal.state_ref<i32>) : i32
      %t6 = arith.constant 1 : i32 loc(#loc3)
      %t7 = arith.addi %t5, %t6 : i32 loc(#loc4)
      cal.set(%t0: !cal.state_ref<i32>, %t7: i32)
      %t8 = cal.get(%t0: !cal.state_ref<i32>) : i32
      %t9 = cal.get(%t0: !cal.state_ref<i32>) : i32
      fifo.push(%OUT: !fifo.input_port<i32>, %t9: i32)
    } loc(#loc5)
  } loc(#loc6)
  cal.actor @test__Sink(%a: i32)
    in_names ["IN"]
    ports_in(%IN: !fifo.output_port<i32>)
  {
    cal.action "$untagged0" priority=0 {
      %t0 = fifo.pop(%IN: !fifo.output_port<i32> ) : i32 loc(#loc7)
      fifo.print("Sink%i, Received token: %i\n\00", %a, %t0) : (i32, i32) loc(#loc8)
    } loc(#loc9)
  } loc(#loc10)
  cal.network @test__FanoutTest()
  {
    %source = cal.instantiate @test__Source instance("source") : !cal.instance<@test__Source>
    %t0 = arith.constant 0 : i32 loc(#loc11)
    %t1 = arith.index_cast %t0 : i32 to index
    %t2 = arith.constant 5 : i32 loc(#loc12)
    %t3 = arith.index_cast %t2 : i32 to index
    %t4 = arith.constant 1 : index
    %t5 = arith.subi %t3, %t1 : index
    %t6 = arith.addi %t5, %t4 : index
    %t7 = arith.addi %t1, %t6 : index
    %t8 = cal.instance.array.init(%t6 : index) : !cal.instance.array<@test__Sink, [?]>
    %sinks = scf.for %t9 = %t1 to %t7 step %t4 iter_args(%acc = %t8) -> !cal.instance.array<@test__Sink, [?]> {
      %t10 = arith.subi %t9, %t1 : index
      %t12 = arith.index_cast %t9 : index to i32
      %t11 = cal.instantiate @test__Sink (%t12 : i32) : !cal.instance<@test__Sink>
      %t13 = cal.instance.array.set %acc[%t10], %t11 : !cal.instance.array<@test__Sink, [?]>, !cal.instance<@test__Sink> -> !cal.instance.array<@test__Sink, [?]>
      scf.yield %t13 : !cal.instance.array<@test__Sink, [?]>
    }
    %t14 = arith.constant 0 : index
    %t15 = arith.constant 1 : index
    %t16 = arith.constant 0 : index
    scf.for %t17 = %t16 to %t6 step %t15 {
      %t18 = arith.index_cast %t17 : index to i32
      %t19 = arith.index_cast %t18 : i32 to index
      cal.connect %source : !cal.instance<@test__Source> "OUT" -> %sinks[%t19] : !cal.instance.array<@test__Sink, [?]> "IN" capacity(4096)
      scf.yield
    }
  } loc(#loc13)
} loc(#loc14)
#loc0 = loc("file:///home/endrix/git/dataflow/streamblocks/languim-cal/examples/fanout/fanout.cal":7:24)
#loc1 = loc("file:///home/endrix/git/dataflow/streamblocks/languim-cal/examples/fanout/fanout.cal":11:23)
#loc2 = loc("file:///home/endrix/git/dataflow/streamblocks/languim-cal/examples/fanout/fanout.cal":11:13)
#loc3 = loc("file:///home/endrix/git/dataflow/streamblocks/languim-cal/examples/fanout/fanout.cal":13:34)
#loc4 = loc("file:///home/endrix/git/dataflow/streamblocks/languim-cal/examples/fanout/fanout.cal":13:24)
#loc5 = loc("file:///home/endrix/git/dataflow/streamblocks/languim-cal/examples/fanout/fanout.cal":9:9)
#loc6 = loc("file:///home/endrix/git/dataflow/streamblocks/languim-cal/examples/fanout/fanout.cal":5:5)
#loc7 = loc("file:///home/endrix/git/dataflow/streamblocks/languim-cal/examples/fanout/fanout.cal":21:16)
#loc8 = loc("file:///home/endrix/git/dataflow/streamblocks/languim-cal/examples/fanout/fanout.cal":23:13)
#loc9 = loc("file:///home/endrix/git/dataflow/streamblocks/languim-cal/examples/fanout/fanout.cal":21:9)
#loc10 = loc("file:///home/endrix/git/dataflow/streamblocks/languim-cal/examples/fanout/fanout.cal":19:5)
#loc11 = loc("file:///home/endrix/git/dataflow/streamblocks/languim-cal/examples/fanout/fanout.cal":32:47)
#loc12 = loc("file:///home/endrix/git/dataflow/streamblocks/languim-cal/examples/fanout/fanout.cal":32:52)
#loc13 = loc("file:///home/endrix/git/dataflow/streamblocks/languim-cal/examples/fanout/fanout.cal":28:5)
#loc14 = loc("examples/fanout/fanout.cal":1:1)