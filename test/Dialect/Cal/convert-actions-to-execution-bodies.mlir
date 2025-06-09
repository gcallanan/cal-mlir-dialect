// RUN: cal-opt --convert-cal-actions-to-execution-bodies  %s | FileCheck %s

// CHECK-NOT: cal.action{{$}}
// CHECK-NOT: cal.action{
// CHECK-NOT: cal.action {

cal.actor @src(%arg0: i32, %arg1: i32)
    ports_out (
      %arg2: !fifo.input_port<i32>
    )
  {
    %c100_i32 = arith.constant 100 : i32
    %c1_i32 = arith.constant 1 : i32
    %c0_i32 = arith.constant 0 : i32
    %0 = cal.create_state_var<i32> : !cal.state_ref<i32>
    cal.set(%0 : !cal.state_ref<i32>, %c0_i32 : i32)
    cal.action
    {
      cal.predicate {
        %5 = fifo.space(%arg2 : !fifo.input_port<i32>) : index
        %6 = arith.index_cast %5 : index to i32
        %7 = arith.cmpi sge, %6, %c1_i32 : i32
        cal.predicate_result %7 : i1
      } {inserted_by_pass}
      cal.predicate {
        %5 = cal.get(%0 : !cal.state_ref<i32>) : i32
        %6 = arith.cmpi slt, %5, %arg0 : i32
        cal.predicate_result %6 : i1
      }
      %1 = cal.get(%0 : !cal.state_ref<i32>) : i32
      %2 = arith.addi %1, %c1_i32 : i32
      cal.set(%0 : !cal.state_ref<i32>, %2 : i32)
      %3 = arith.muli %arg1, %c100_i32 : i32
      %4 = arith.addi %1, %3 : i32
      fifo.push(%arg2 : !fifo.input_port<i32>, %4 : i32)
      fifo.print("Src %d, pushed token: %d\0A\00", %arg1, %4) : (i32, i32)
    }

    // CHECK: cal.execution_body {
    // CHECK-NEXT:   %1 = fifo.space(%arg2 : !fifo.input_port<i32>) : index
    // CHECK-NEXT:   %2 = arith.index_cast %1 : index to i32
    // CHECK-NEXT:   %3 = arith.cmpi sge, %2, %c1_i32 : i32
    // CHECK-NEXT:   %4 = cal.get(%0 : !cal.state_ref<i32>) : i32
    // CHECK-NEXT:   %5 = arith.cmpi slt, %4, %arg0 : i32
    // CHECK-NEXT:   %6 = arith.andi %5, %3 : i1
    // CHECK-NEXT:   %7 = scf.if %6 -> (i1) {
    // CHECK-NEXT:     %8 = cal.get(%0 : !cal.state_ref<i32>) : i32
    // CHECK-NEXT:     %9 = arith.addi %8, %c1_i32 : i32
    // CHECK-NEXT:     cal.set(%0 : !cal.state_ref<i32>, %9 : i32)
    // CHECK-NEXT:     %10 = arith.muli %arg1, %c100_i32 : i32
    // CHECK-NEXT:     %11 = arith.addi %8, %10 : i32
    // CHECK-NEXT:     fifo.push(%arg2 : !fifo.input_port<i32>, %11 : i32)
    // CHECK-NEXT:     fifo.print("Src %d, pushed token: %d\0A\00", %arg1, %11) : (i32, i32)
    // CHECK-NEXT:     scf.yield %true : i1
    // CHECK-NEXT:   } else {
    // CHECK-NEXT:     scf.yield %false : i1
    // CHECK-NEXT:   }
    // CHECK-NEXT:   cal.action_done %7 : i1
    // CHECK-NEXT: }


    // CHECK-NOT: cal.action{{$}}
    // CHECK-NOT: cal.action{
    // CHECK-NOT: cal.action {
  }
  
  cal.actor @sink()
    ports_in (
      %arg0: !fifo.output_port<i32>
    )
  {
    %c1_i32 = arith.constant 1 : i32
    cal.action
    {
      cal.predicate {
        %1 = fifo.size(%arg0 : !fifo.output_port<i32>) : index
        %2 = arith.index_cast %1 : index to i32
        %3 = arith.cmpi sge, %2, %c1_i32 : i32
        cal.predicate_result %3 : i1
      } {inserted_by_pass}
      %0 = fifo.pop(%arg0 : !fifo.output_port<i32>) : i32
      fifo.print("Popped Token: %d\0A\00", %0) : (i32)
    }

    // CHECK: cal.execution_body {
    // CHECK-NEXT:   %0 = fifo.size(%arg0 : !fifo.output_port<i32>) : index
    // CHECK-NEXT:   %1 = arith.index_cast %0 : index to i32
    // CHECK-NEXT:   %2 = arith.cmpi sge, %1, %c1_i32 : i32
    // CHECK-NEXT:   %3 = scf.if %2 -> (i1) {
    // CHECK-NEXT:     %4 = fifo.pop(%arg0 : !fifo.output_port<i32>) : i32
    // CHECK-NEXT:     fifo.print("Popped Token: %d\0A\00", %4) : (i32)
    // CHECK-NEXT:     scf.yield %true : i1
    // CHECK-NEXT:   } else {
    // CHECK-NEXT:     scf.yield %false : i1
    // CHECK-NEXT:   }
    // CHECK-NEXT:   cal.action_done %3 : i1
    // CHECK-NEXT: }

    // CHECK-NOT: cal.action{{$}}
    // CHECK-NOT: cal.action{
    // CHECK-NOT: cal.action {
    
  }
  
  cal.actor @merge()
    ports_in (
      %arg0: !fifo.output_port<i32>, 
      %arg1: !fifo.output_port<i32>
    )
    ports_out (
      %arg2: !fifo.input_port<i32>
    )
  {
    %c1_i32 = arith.constant 1 : i32
    cal.action
    {
      cal.predicate {
        %1 = fifo.size(%arg0 : !fifo.output_port<i32>) : index
        %2 = arith.index_cast %1 : index to i32
        %3 = arith.cmpi sge, %2, %c1_i32 : i32
        cal.predicate_result %3 : i1
      } {inserted_by_pass}
      cal.predicate {
        %1 = fifo.space(%arg2 : !fifo.input_port<i32>) : index
        %2 = arith.index_cast %1 : index to i32
        %3 = arith.cmpi sge, %2, %c1_i32 : i32
        cal.predicate_result %3 : i1
      } {inserted_by_pass}
      %0 = fifo.pop(%arg0 : !fifo.output_port<i32>) : i32
      fifo.push(%arg2 : !fifo.input_port<i32>, %0 : i32)
    }
    
    cal.action
    {
      cal.predicate {
        %1 = fifo.size(%arg1 : !fifo.output_port<i32>) : index
        %2 = arith.index_cast %1 : index to i32
        %3 = arith.cmpi sge, %2, %c1_i32 : i32
        cal.predicate_result %3 : i1
      } {inserted_by_pass}
      cal.predicate {
        %1 = fifo.space(%arg2 : !fifo.input_port<i32>) : index
        %2 = arith.index_cast %1 : index to i32
        %3 = arith.cmpi sge, %2, %c1_i32 : i32
        cal.predicate_result %3 : i1
      } {inserted_by_pass}
      %0 = fifo.pop(%arg1 : !fifo.output_port<i32>) : i32
      fifo.push(%arg2 : !fifo.input_port<i32>, %0 : i32)
    }
    
    //CHECK: cal.execution_body {
    //CHECK-NEXT:   %0 = fifo.size(%arg0 : !fifo.output_port<i32>) : index
    //CHECK-NEXT:   %1 = arith.index_cast %0 : index to i32
    //CHECK-NEXT:   %2 = arith.cmpi sge, %1, %c1_i32 : i32
    //CHECK-NEXT:   %3 = fifo.space(%arg2 : !fifo.input_port<i32>) : index
    //CHECK-NEXT:   %4 = arith.index_cast %3 : index to i32
    //CHECK-NEXT:   %5 = arith.cmpi sge, %4, %c1_i32 : i32
    //CHECK-NEXT:   %6 = arith.andi %5, %2 : i1
    //CHECK-NEXT:   %7 = fifo.size(%arg1 : !fifo.output_port<i32>) : index
    //CHECK-NEXT:   %8 = arith.index_cast %7 : index to i32
    //CHECK-NEXT:   %9 = arith.cmpi sge, %8, %c1_i32 : i32
    //CHECK-NEXT:   %10 = fifo.space(%arg2 : !fifo.input_port<i32>) : index
    //CHECK-NEXT:   %11 = arith.index_cast %10 : index to i32
    //CHECK-NEXT:   %12 = arith.cmpi sge, %11, %c1_i32 : i32
    //CHECK-NEXT:   %13 = arith.andi %12, %9 : i1
    //CHECK-NEXT:   %14 = scf.if %6 -> (i1) {
    //CHECK-NEXT:     %15 = fifo.pop(%arg0 : !fifo.output_port<i32>) : i32
    //CHECK-NEXT:     fifo.push(%arg2 : !fifo.input_port<i32>, %15 : i32)
    //CHECK-NEXT:     scf.yield %true : i1
    //CHECK-NEXT:   } else {
    //CHECK-NEXT:     %15 = scf.if %13 -> (i1) {
    //CHECK-NEXT:       %16 = fifo.pop(%arg1 : !fifo.output_port<i32>) : i32
    //CHECK-NEXT:       fifo.push(%arg2 : !fifo.input_port<i32>, %16 : i32)
    //CHECK-NEXT:       scf.yield %true : i1
    //CHECK-NEXT:     } else {
    //CHECK-NEXT:       scf.yield %false : i1
    //CHECK-NEXT:     }
    //CHECK-NEXT:     scf.yield %15 : i1
    //CHECK-NEXT:   }
    //CHECK-NEXT:   cal.action_done %14 : i1
    //CHECK-NEXT: }


    // CHECK-NOT: cal.action{{$}}
    // CHECK-NOT: cal.action{
    // CHECK-NOT: cal.action {
  }
