// RUN: cal-opt --insert-cal-port-predicates  %s | FileCheck %s

cal.actor @mixed_loops_actor()
    ports_in(%in0: !fifo.output_port<i32>)
    ports_out(%out0: !fifo.input_port<i32>)
{
    cal.action {
        // Mixed scenario: SCF for loop with 2 iterations, each containing an affine for loop with 3 iterations
        // SCF: 2 iterations × (affine: 3 iterations × 1 pop + 1 push) = consumption rate 6, production rate 6
        
        // CHECK: cal.predicate {
        // CHECK-NEXT:     %{{.*}} = fifo.size(%arg0 : !fifo.output_port<i32>) : index
        // CHECK-NEXT:     %{{.*}} = arith.index_cast %{{.*}} : index to i32
        // CHECK-NEXT:     %{{.*}} = arith.cmpi sge, %{{.*}}, %c6_i32 : i32
        // CHECK-NEXT:     cal.predicate_result %{{.*}} : i1
        // CHECK-NEXT: } {inserted_by_pass}
        // CHECK-NEXT: cal.predicate {
        // CHECK-NEXT:     %{{.*}} = fifo.space(%arg1 : !fifo.input_port<i32>) : index
        // CHECK-NEXT:     %{{.*}} = arith.index_cast %{{.*}} : index to i32
        // CHECK-NEXT:     %{{.*}} = arith.cmpi sge, %{{.*}}, %c6_i32 : i32
        // CHECK-NEXT:     cal.predicate_result %{{.*}} : i1
        // CHECK-NEXT: } {inserted_by_pass}
        
        %c0 = arith.constant 0 : index
        %c2 = arith.constant 2 : index
        %c1 = arith.constant 1 : index
        
        scf.for %i = %c0 to %c2 step %c1 {
            affine.for %j = 0 to 3 {
                %token = fifo.pop(%in0: !fifo.output_port<i32>) : i32
                fifo.push(%out0: !fifo.input_port<i32>, %token: i32)
            }
        }
    }
}