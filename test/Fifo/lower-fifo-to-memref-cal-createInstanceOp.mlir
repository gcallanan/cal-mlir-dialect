// RUN: cal-opt --lower-fifo-to-memref %s | FileCheck %s

cal.actor @inputs_and_output(%arg0: i32)
    ports_in (
      %arg1: !fifo.output_port<i32>, 
      %arg2: !fifo.output_port<i32>
    )
    ports_out (
      %arg3: !fifo.input_port<i32>
    )
  {
  }
  
  cal.network {
    %c10_i32 = arith.constant 10 : i32
    %inputPort, %outputPort = fifo.create<i32> (3) : !fifo.input_port<i32>, !fifo.output_port<i32>
    %inputPort_0, %outputPort_1 = fifo.create<i32> (4) : !fifo.input_port<i32>, !fifo.output_port<i32>
    
    // CHECK: %cast = memref.cast %1 : memref<4xi32> to memref<?xi32>
    // CHECK: %4 = fifo.make_tuple(%cast, %2, %3) : memref<?xi32>, memref<2xi32>, i32 -> tuple<memref<?xi32>, memref<2xi32>, i32>
    // CHECK: %cast_3 = memref.cast %6 : memref<5xi32> to memref<?xi32>
    // CHECK: %9 = fifo.make_tuple(%cast_3, %7, %8) : memref<?xi32>, memref<2xi32>, i32 -> tuple<memref<?xi32>, memref<2xi32>, i32>

    cal.create_instance @inputs_and_output(%c10_i32 : i32)
        ports_in (%outputPort, %outputPort_1 : !fifo.output_port<i32>, !fifo.output_port<i32>)
        ports_out (%inputPort : !fifo.input_port<i32>)
    
    // CHECK: cal.create_instance @inputs_and_output(%c10_i32, %4, %9, %4 : i32, tuple<memref<?xi32>, memref<2xi32>, i32>, tuple<memref<?xi32>, memref<2xi32>, i32>, tuple<memref<?xi32>, memref<2xi32>, i32>)

  }