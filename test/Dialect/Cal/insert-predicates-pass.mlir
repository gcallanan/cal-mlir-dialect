// RUN: cal-opt --insert-cal-port-predicates  %s | FileCheck %s

cal.actor @merge()
    ports_in(%in0: !fifo.output_port<i32>, %in1: !fifo.output_port<i32>)
    ports_out(%out0: !fifo.input_port<i32>)
{
    cal.action {
        //CHECK: cal.predicate {
        //CHECK-NEXT:     %3 = fifo.size(%arg0 : !fifo.output_port<i32>) : index
        //CHECK-NEXT:     %4 = arith.index_cast %3 : index to i32
        //CHECK-NEXT:     %5 = arith.cmpi sge, %4, %c3_i32 : i32
        //CHECK-NEXT:     cal.predicate_result %5 : i1
        //CHECK-NEXT: } {inserted_by_pass}
        //CHECK-NEXT: cal.predicate {
        //CHECK-NEXT:     %3 = fifo.space(%arg2 : !fifo.input_port<i32>) : index
        //CHECK-NEXT:     %4 = arith.index_cast %3 : index to i32
        //CHECK-NEXT:     %5 = arith.cmpi sge, %4, %c1_i32 : i32
        //CHECK-NEXT:     cal.predicate_result %5 : i1
        //CHECK-NEXT: } {inserted_by_pass}
        %token = fifo.pop(%in0: !fifo.output_port<i32>) : i32
        %token1 = fifo.pop(%in0: !fifo.output_port<i32>) : i32
        %token2 = fifo.pop(%in0: !fifo.output_port<i32>) : i32
        fifo.push(%out0: !fifo.input_port<i32>, %token: i32)
    }

    cal.action {
        // CHECK: cal.predicate {
        // CHECK-NEXT:     %1 = fifo.size(%arg1 : !fifo.output_port<i32>) : index
        // CHECK-NEXT:     %2 = arith.index_cast %1 : index to i32
        // CHECK-NEXT:     %3 = arith.cmpi sge, %2, %c1_i32 : i32
        // CHECK-NEXT:     cal.predicate_result %3 : i1
        // CHECK-NEXT: } {inserted_by_pass}
        // CHECK-NEXT: cal.predicate {
        // CHECK-NEXT:     %1 = fifo.space(%arg2 : !fifo.input_port<i32>) : index
        // CHECK-NEXT:     %2 = arith.index_cast %1 : index to i32
        // CHECK-NEXT:     %3 = arith.cmpi sge, %2, %c1_i32 : i32
        // CHECK-NEXT:     cal.predicate_result %3 : i1
        // CHECK-NEXT: } {inserted_by_pass}
        %token = fifo.pop(%in1: !fifo.output_port<i32>) : i32
        fifo.push(%out0: !fifo.input_port<i32>, %token: i32)
    }

    cal.action {
        // CHECK: cal.predicate {
        // CHECK-NEXT:     %2 = fifo.size(%arg0 : !fifo.output_port<i32>) : index
        // CHECK-NEXT:     %3 = arith.index_cast %2 : index to i32
        // CHECK-NEXT:     %4 = arith.cmpi sge, %3, %c2_i32 : i32
        // CHECK-NEXT:     cal.predicate_result %4 : i1
        // CHECK-NEXT: } {inserted_by_pass}
        // CHECK-NEXT: cal.predicate {
        // CHECK-NEXT:     %2 = fifo.space(%arg2 : !fifo.input_port<i32>) : index
        // CHECK-NEXT:     %3 = arith.index_cast %2 : index to i32
        // CHECK-NEXT:     %4 = arith.cmpi sge, %3, %c2_i32 : i32
        // CHECK-NEXT:     cal.predicate_result %4 : i1
        // CHECK-NEXT: } {inserted_by_pass}
        %token = fifo.pop(%in0: !fifo.output_port<i32>) : i32
        %token1 = fifo.pop(%in0: !fifo.output_port<i32>) : i32
        fifo.push(%out0: !fifo.input_port<i32>, %token: i32)
        fifo.push(%out0: !fifo.input_port<i32>, %token: i32)
    }
}
