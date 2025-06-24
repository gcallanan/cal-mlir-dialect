// RUN: cal-opt %s --canonicalize --convert-cal-to-func-with-static-schedule="print-solved-balance-equations-for-testing" | FileCheck %s

// CHECK: Number of firings of the all the CSDF phases per actor:
// CHECK-NEXT:   pass: 1
// CHECK-NEXT:   sink: 2
// CHECK-NEXT:   source: 2

module {
  cal.actor @source()
    ports_out (
      %arg0: !fifo.input_port<i32>
    )
  {
    %c1_i32 = arith.constant 1 : i32
    %c20_i32 = arith.constant 20 : i32
    %c0_i32 = arith.constant 0 : i32
    %0 = cal.create_state_var<i32> : !cal.state_ref<i32>
    cal.set(%0 : !cal.state_ref<i32>, %c0_i32 : i32)
    cal.action "transmit" priority=0
    {
      cal.predicate {
        %4 = cal.get(%0 : !cal.state_ref<i32>) : i32
        %5 = arith.cmpi slt, %4, %c20_i32 : i32
        cal.predicate_result %5 : i1
      }
      %1 = cal.get(%0 : !cal.state_ref<i32>) : i32
      fifo.print("Tx: %i\0A\00", %1) : (i32)
      %2 = cal.get(%0 : !cal.state_ref<i32>) : i32
      %3 = arith.addi %2, %c1_i32 : i32
      cal.set(%0 : !cal.state_ref<i32>, %3 : i32)
      fifo.push(%arg0 : !fifo.input_port<i32>, %1 : i32)
    }
    
  }
  
  cal.actor @pass()
    ports_in (
      %arg0: !fifo.output_port<i32>
    )
    ports_out (
      %arg1: !fifo.input_port<i32>
    )
  {
    cal.action "passThrough" priority=0
    {
      %0 = fifo.pop(%arg0 : !fifo.output_port<i32>) : i32
      %1 = fifo.pop(%arg0 : !fifo.output_port<i32>) : i32
      fifo.push(%arg1 : !fifo.input_port<i32>, %0 : i32)
      fifo.push(%arg1 : !fifo.input_port<i32>, %1 : i32)
    }
    
  }
  
  cal.actor @sink()
    ports_in (
      %arg0: !fifo.output_port<i32>
    )
  {
    cal.action "receive" priority=0
    {
      %0 = fifo.pop(%arg0 : !fifo.output_port<i32>) : i32
      fifo.print("Rx: %i\0A\00", %0) : (i32)
    }
    
  }
  
  cal.network {
    %inputPort, %outputPort = fifo.create<i32> (1) : !fifo.input_port<i32>, !fifo.output_port<i32>
    %inputPort_0, %outputPort_1 = fifo.create<i32> (1) : !fifo.input_port<i32>, !fifo.output_port<i32>
    cal.create_instance @source "source" ()
        ports_out (%inputPort_0 : !fifo.input_port<i32>)
    cal.create_instance @pass "pass" ()
        ports_in (%outputPort_1 : !fifo.output_port<i32>)
        ports_out (%inputPort : !fifo.input_port<i32>)
    cal.create_instance @sink "sink" ()
        ports_in (%outputPort : !fifo.output_port<i32>)
  }
}
