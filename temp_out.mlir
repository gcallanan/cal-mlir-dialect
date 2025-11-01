module {
  cal.actor @A() {
    cal.execution_body {
      %t = arith.constant true
      cal.action_done %t : i1
    }
  }

  cal.network @n() {
    %arr = cal.instantiate_array @A count(1) : !cal.instance.array<@A, 1>
    %cond = arith.constant true
    %h = cal.instance_if %cond {
      %c0 = arith.constant 0 : index
      %h0 = cal.instance_at %arr[%c0] : !cal.instance.array<@A, 1>, index -> !cal.instance<@A>
      cal.instance_yield %h0 : !cal.instance<@A>
    } else {
      %c0b = arith.constant 0 : index
      %h0b = cal.instance_at %arr[%c0b] : !cal.instance.array<@A, 1>, index -> !cal.instance<@A>
      cal.instance_yield %h0b : !cal.instance<@A>
    } : !cal.instance<@A>
  }
}
module {
  cal.actor @src(%arg0: i32, %arg1: i32)
    ports_out (
      %arg2: !fifo.input_port<i32>
    )
  {
    %0 = cal.create_state_var<i32> : !cal.state_ref<i32>
    %c0_i32 = arith.constant 0 : i32
    cal.set(%0 : !cal.state_ref<i32>, %c0_i32 : i32)
    cal.action "send"
    {
      cal.predicate {
        %5 = cal.get(%0 : !cal.state_ref<i32>) : i32
        %6 = arith.cmpi slt, %5, %arg0 : i32
        cal.predicate_result %6 : i1
      }
      %c1_i32 = arith.constant 1 : i32
      %1 = cal.get(%0 : !cal.state_ref<i32>) : i32
      %2 = arith.addi %1, %c1_i32 : i32
      cal.set(%0 : !cal.state_ref<i32>, %2 : i32)
      %c100_i32 = arith.constant 100 : i32
      %3 = arith.muli %arg1, %c100_i32 : i32
      %4 = arith.addi %1, %3 : i32
      fifo.push(%arg2 : !fifo.input_port<i32>, %4 : i32)
      fifo.print("Src %d -> %d\0A\00", %arg1, %4) : (i32, i32)
    }
    
  }
  
  cal.actor @arbiter()
    ports_in (
      %arg0: !fifo.output_port<i32>, 
      %arg1: !fifo.output_port<i32>
    )
    ports_out (
      %arg2: !fifo.input_port<i32>
    )
  {
    %0 = cal.create_state_var<i32> : !cal.state_ref<i32>
    %c0_i32 = arith.constant 0 : i32
    cal.set(%0 : !cal.state_ref<i32>, %c0_i32 : i32)
    cal.execution_body {
      %1 = cal.get(%0 : !cal.state_ref<i32>) : i32
      %false = arith.constant false
      %c0_i32_0 = arith.constant 0 : i32
      %2 = arith.cmpi eq, %1, %c0_i32_0 : i32
      %3:2 = scf.if %2 -> (i1, i32) {
        %false_1 = arith.constant false
        %c0_i32_2 = arith.constant 0 : i32
        %4 = fifo.size(%arg0 : !fifo.output_port<i32>) : index
        %c0 = arith.constant 0 : index
        %5 = arith.cmpi sgt, %4, %c0 : index
        %true = arith.constant true
        %c1 = arith.constant 1 : index
        %6 = fifo.space(%arg2 : !fifo.input_port<i32>) : index
        %7 = arith.cmpi sge, %6, %c1 : index
        %8 = arith.andi %true, %7 : i1
        %c1_3 = arith.constant 1 : index
        %9 = fifo.size(%arg0 : !fifo.output_port<i32>) : index
        %10 = arith.cmpi sge, %9, %c1_3 : index
        %11 = arith.andi %8, %10 : i1
        %12 = arith.andi %5, %11 : i1
        %true_4 = arith.constant true
        %13 = arith.xori %false_1, %true_4 : i1
        %14 = arith.andi %13, %12 : i1
        %15:2 = scf.if %14 -> (i1, i32) {
          %28 = fifo.pop(%arg0 : !fifo.output_port<i32>) : i32
          fifo.print("ARB 0 %d\0A\00", %28) : (i32)
          fifo.push(%arg2 : !fifo.input_port<i32>, %28 : i32)
          %true_10 = arith.constant true
          %c0_i32_11 = arith.constant 0 : i32
          scf.yield %true_10, %c0_i32_11 : i1, i32
        } else {
          scf.yield %false_1, %c0_i32_2 : i1, i32
        }
        %16 = fifo.size(%arg1 : !fifo.output_port<i32>) : index
        %c0_5 = arith.constant 0 : index
        %17 = arith.cmpi sgt, %16, %c0_5 : index
        %true_6 = arith.constant true
        %c1_7 = arith.constant 1 : index
        %18 = fifo.space(%arg2 : !fifo.input_port<i32>) : index
        %19 = arith.cmpi sge, %18, %c1_7 : index
        %20 = arith.andi %true_6, %19 : i1
        %c1_8 = arith.constant 1 : index
        %21 = fifo.size(%arg1 : !fifo.output_port<i32>) : index
        %22 = arith.cmpi sge, %21, %c1_8 : index
        %23 = arith.andi %20, %22 : i1
        %24 = arith.andi %17, %23 : i1
        %true_9 = arith.constant true
        %25 = arith.xori %15#0, %true_9 : i1
        %26 = arith.andi %25, %24 : i1
        %27:2 = scf.if %26 -> (i1, i32) {
          %28 = fifo.pop(%arg1 : !fifo.output_port<i32>) : i32
          fifo.print("ARB 1 %d\0A\00", %28) : (i32)
          fifo.push(%arg2 : !fifo.input_port<i32>, %28 : i32)
          %true_10 = arith.constant true
          %c0_i32_11 = arith.constant 0 : i32
          scf.yield %true_10, %c0_i32_11 : i1, i32
        } else {
          scf.yield %15#0, %15#1 : i1, i32
        }
        scf.yield %27#0, %27#1 : i1, i32
      } else {
        scf.yield %false, %1 : i1, i32
      }
      cal.set(%0 : !cal.state_ref<i32>, %3#1 : i32)
      cal.action_done %3#0 : i1
    }
  }
  
  cal.actor @sink()
    ports_in (
      %arg0: !fifo.output_port<i32>
    )
  {
    cal.action
    {
      %0 = fifo.pop(%arg0 : !fifo.output_port<i32>) : i32
      fifo.print("SINK %d\0A\00", %0) : (i32)
    }
    
  }
  
  cal.network @arbiter_net()
  {
    %c10_i32 = arith.constant 10 : i32
    %c1_i32 = arith.constant 1 : i32
    %c2_i32 = arith.constant 2 : i32
    %inputPort, %outputPort = fifo.create<i32> (3) : !fifo.input_port<i32>, !fifo.output_port<i32>
    %inputPort_0, %outputPort_1 = fifo.create<i32> (3) : !fifo.input_port<i32>, !fifo.output_port<i32>
    %inputPort_2, %outputPort_3 = fifo.create<i32> (6) : !fifo.input_port<i32>, !fifo.output_port<i32>
    cal.create_instance @src "A" (%c10_i32, %c1_i32 : i32, i32)
        ports_out (%inputPort : !fifo.input_port<i32>)
    cal.create_instance @src "B" (%c10_i32, %c2_i32 : i32, i32)
        ports_out (%inputPort_0 : !fifo.input_port<i32>)
    cal.create_instance @arbiter "arb" ()
        ports_in (%outputPort, %outputPort_1 : !fifo.output_port<i32>, !fifo.output_port<i32>)
        ports_out (%inputPort_2 : !fifo.input_port<i32>)
    cal.create_instance @sink "sink" ()
        ports_in (%outputPort_3 : !fifo.output_port<i32>)
  }
  
}

