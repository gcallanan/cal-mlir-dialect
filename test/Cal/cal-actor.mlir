// RUN: cal-opt %s | FileCheck %s


cal.actor @my_actor1
{
}

// CHECK:  cal.actor @my_actor1
// CHECK-NEXT:  {
// CHECK-NEXT:  }


cal.actor @my_actor2
    ports_out (%arg3: !fifo.input_port<i33>, %arg4: !fifo.input_port<i34>, %arg6: !fifo.input_port<i36>)
{
}

// CHECK:  cal.actor @my_actor2
// CHECK-NEXT:    ports_out (
// CHECK-NEXT:      %arg0: !fifo.input_port<i33>,
// CHECK-NEXT:      %arg1: !fifo.input_port<i34>,
// CHECK-NEXT:      %arg2: !fifo.input_port<i36>
// CHECK-NEXT:    )
// CHECK-NEXT:  {
// CHECK-NEXT:  }

cal.actor @my_actor3
    ports_in(%arg0: !fifo.output_port<i31>, %arg1: !fifo.output_port<i32>, %arg2: !fifo.output_port<i35>)
{
}

// CHECK:  cal.actor @my_actor3
// CHECK-NEXT:    ports_in (
// CHECK-NEXT:      %arg0: !fifo.output_port<i31>,
// CHECK-NEXT:      %arg1: !fifo.output_port<i32>,
// CHECK-NEXT:      %arg2: !fifo.output_port<i35>
// CHECK-NEXT:    )
// CHECK-NEXT:  {
// CHECK-NEXT:  }

cal.actor @my_actor4
    ports_in(%arg0: !fifo.output_port<i31>, %arg1: !fifo.output_port<i32>, %arg2: !fifo.output_port<i35>)
    ports_out (%arg3: !fifo.input_port<i33>, %arg4: !fifo.input_port<i34>, %arg6: !fifo.input_port<i36>)
{
    %c1 = arith.constant 10 : i32
}

// CHECK:  cal.actor @my_actor4
// CHECK-NEXT:    ports_in (
// CHECK-NEXT:      %arg0: !fifo.output_port<i31>,
// CHECK-NEXT:      %arg1: !fifo.output_port<i32>,
// CHECK-NEXT:      %arg2: !fifo.output_port<i35>
// CHECK-NEXT:    )
// CHECK-NEXT:    ports_out (
// CHECK-NEXT:      %arg3: !fifo.input_port<i33>,
// CHECK-NEXT:      %arg4: !fifo.input_port<i34>,
// CHECK-NEXT:      %arg5: !fifo.input_port<i36>
// CHECK-NEXT:    )
// CHECK-NEXT:  {
// CHECK-NEXT:    %c10_i32 = arith.constant 10 : i32
// CHECK-NEXT:  }
