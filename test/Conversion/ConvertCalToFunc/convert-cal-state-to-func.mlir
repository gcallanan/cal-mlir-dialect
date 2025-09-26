// NOTE: This network is a bit of a nonsensical example
// RUN: cal-opt --convert-cal-to-func %s | FileCheck %s

// CHECK: func.func @src(%arg0: i32, %arg1: !fifo.input_port<i32>) -> i1
cal.actor @src(%max_tokens_to_send: i32)
    ports_out(%out0: !fifo.input_port<i32>)
{
    // CHECK-NOT: cal.execution_body
    cal.execution_body
    {
        fifo.print("Hi\0A\00")
        %true = arith.constant 1 : i1
        // CHECK: return %true : i1
        cal.action_done %true : i1
    }
}

// CHECK:  func.func @main()
cal.network @Top(){
    %0 = arith.constant 11 : i32
    %1 = arith.constant 12 : i32
    %2 = arith.constant 13 : i32

    %in0, %out0 = fifo.create<i32>(3) : !fifo.input_port<i32>, !fifo.output_port<i32>
    %in1, %out1 = fifo.create<i32>(3) : !fifo.input_port<i32>, !fifo.output_port<i32>
    %in2, %out2 = fifo.create<i32>(3) : !fifo.input_port<i32>, !fifo.output_port<i32>

    fifo.print("start\n\00")
    // CHECK: fifo.print("start\0A\00")
    //CHECK-NEXT: scf.while (%arg0 = %true) : (i1) -> () {
    //CHECK-NEXT:   scf.condition(%arg0)
    //CHECK-NEXT: } do {
    //CHECK-NEXT:   %0 = func.call @src(%c11_i32, %inputPort) {from_create_instance} : (i32, !fifo.input_port<i32>) -> i1
    //CHECK-NEXT:   %1 = func.call @src(%c12_i32, %inputPort_0) {from_create_instance} : (i32, !fifo.input_port<i32>) -> i1
    //CHECK-NEXT:   %2 = arith.ori %1, %0 : i1
    //CHECK-NEXT:   %3 = func.call @src(%c13_i32, %inputPort_2) {from_create_instance} : (i32, !fifo.input_port<i32>) -> i1
    //CHECK-NEXT:   %4 = arith.ori %3, %2 : i1
    //CHECK-NEXT:   scf.yield %4 : i1
    //CHECK-NEXT: }


    cal.create_instance @src "srcA" (%0: i32)
            ports_out(%in0 : !fifo.input_port<i32>)

    cal.create_instance @src "srcB" (%1: i32)
            ports_out(%in1 : !fifo.input_port<i32>)

    cal.create_instance @src "srcC" (%2: i32)
            ports_out(%in2 : !fifo.input_port<i32>)

    // CHECK: return
}