// RUN: cal-opt --insert-cal-port-predicates  %s | FileCheck %s

cal.actor @affine_loop_actor()
    ports_in(%in0: !fifo.output_port<i32>)
    ports_out(%out0: !fifo.input_port<i32>)
{
    cal.action {
        // This action contains an affine.for loop that executes 5 iterations (0 to 4, step 1)
        // Each iteration pops 1 token and pushes 1 token
        // So total consumption rate = 5, total production rate = 5
        
        // CHECK: cal.predicate {
        // CHECK-NEXT:     %{{.*}} = fifo.size(%arg0 : !fifo.output_port<i32>) : index
        // CHECK-NEXT:     %{{.*}} = arith.index_cast %{{.*}} : index to i32
        // CHECK-NEXT:     %{{.*}} = arith.cmpi sge, %{{.*}}, %c5_i32 : i32
        // CHECK-NEXT:     cal.predicate_result %{{.*}} : i1
        // CHECK-NEXT: } {inserted_by_pass}
        // CHECK-NEXT: cal.predicate {
        // CHECK-NEXT:     %{{.*}} = fifo.space(%arg1 : !fifo.input_port<i32>) : index
        // CHECK-NEXT:     %{{.*}} = arith.index_cast %{{.*}} : index to i32
        // CHECK-NEXT:     %{{.*}} = arith.cmpi sge, %{{.*}}, %c5_i32 : i32
        // CHECK-NEXT:     cal.predicate_result %{{.*}} : i1
        // CHECK-NEXT: } {inserted_by_pass}
        
        %c0 = arith.constant 0 : index
        %c5 = arith.constant 5 : index
        %c1 = arith.constant 1 : index
        
        affine.for %i = 0 to 5 {
            %token = fifo.pop(%in0: !fifo.output_port<i32>) : i32
            fifo.push(%out0: !fifo.input_port<i32>, %token: i32)
        }
    }

    cal.action {
        // This action contains an affine.for loop that executes 3 iterations (1 to 4, step 1)
        // Each iteration pops 2 tokens and pushes 1 token
        // So total consumption rate = 6, total production rate = 3
        
        // CHECK: cal.predicate {
        // CHECK-NEXT:     %{{.*}} = fifo.size(%arg0 : !fifo.output_port<i32>) : index
        // CHECK-NEXT:     %{{.*}} = arith.index_cast %{{.*}} : index to i32
        // CHECK-NEXT:     %{{.*}} = arith.cmpi sge, %{{.*}}, %c6_i32 : i32
        // CHECK-NEXT:     cal.predicate_result %{{.*}} : i1
        // CHECK-NEXT: } {inserted_by_pass}
        // CHECK-NEXT: cal.predicate {
        // CHECK-NEXT:     %{{.*}} = fifo.space(%arg1 : !fifo.input_port<i32>) : index
        // CHECK-NEXT:     %{{.*}} = arith.index_cast %{{.*}} : index to i32
        // CHECK-NEXT:     %{{.*}} = arith.cmpi sge, %{{.*}}, %c3_i32 : i32
        // CHECK-NEXT:     cal.predicate_result %{{.*}} : i1
        // CHECK-NEXT: } {inserted_by_pass}
        
        affine.for %i = 1 to 4 {
            %token1 = fifo.pop(%in0: !fifo.output_port<i32>) : i32
            %token2 = fifo.pop(%in0: !fifo.output_port<i32>) : i32
            fifo.push(%out0: !fifo.input_port<i32>, %token1: i32)
        }
    }

    cal.action {
        // This action contains nested affine.for loops
        // Outer loop: 2 iterations (0 to 1, step 1)
        // Inner loop: 3 iterations (0 to 2, step 1)
        // Each inner iteration pops 1 token and pushes 1 token
        // So total consumption rate = 2 * 3 = 6, total production rate = 2 * 3 = 6
        
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
        
        affine.for %i = 0 to 2 {
            affine.for %j = 0 to 3 {
                %token = fifo.pop(%in0: !fifo.output_port<i32>) : i32
                fifo.push(%out0: !fifo.input_port<i32>, %token: i32)
            }
        }
    }
}