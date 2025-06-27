// RUN: cal-opt %s --canonicalize --convert-cal-to-func-with-static-schedule | FileCheck %s

// CHECK:  func.func @source_transmit(%arg0: !fifo.input_port<i32>, %arg1: !cal.state_ref<i32>) -> i1 {
// CHECK-NEXT:    %true = arith.constant true
// CHECK-NEXT:    %false = arith.constant false
// CHECK-NEXT:    %c1_i32 = arith.constant 1 : i32
// CHECK-NEXT:    %c20_i32 = arith.constant 20 : i32
// CHECK-NEXT:    %0 = cal.get(%arg1 : !cal.state_ref<i32>) : i32
// CHECK-NEXT:    %1 = arith.cmpi slt, %0, %c20_i32 : i32
// CHECK-NEXT:    %2 = scf.if %1 -> (i1) {
// CHECK-NEXT:      %3 = cal.get(%arg1 : !cal.state_ref<i32>) : i32
// CHECK-NEXT:      fifo.print("Tx: %i\0A\00", %3) : (i32)
// CHECK-NEXT:      %4 = cal.get(%arg1 : !cal.state_ref<i32>) : i32
// CHECK-NEXT:      %5 = arith.addi %4, %c1_i32 : i32
// CHECK-NEXT:      cal.set(%arg1 : !cal.state_ref<i32>, %5 : i32)
// CHECK-NEXT:      fifo.push(%arg0 : !fifo.input_port<i32>, %3 : i32)
// CHECK-NEXT:      scf.yield %true : i1
// CHECK-NEXT:    } else {
// CHECK-NEXT:      scf.yield %false : i1
// CHECK-NEXT:    }
// CHECK-NEXT:    return %2 : i1
// CHECK-NEXT:  }


// -- Definition of actor class: Source
cal.actor @source ()
	ports_out(%Out: !fifo.input_port<i32>)
{
	// -- Actor body
	%l_counter__2 = cal.create_state_var<i32> : !cal.state_ref<i32>
	%tmp_0 = arith.constant 0 : i1
	%tmp_1 = arith.extui %tmp_0 : i1 to i32
	cal.set(%l_counter__2: !cal.state_ref<i32>, %tmp_1: i32)
	// Generation action: transmit
	cal.action "transmit" priority=0 {
		// Guard: Start
		cal.predicate {
			%tmp_2 = cal.get(%l_counter__2: !cal.state_ref<i32>) : i32
			// Evaluate global variable $eval1.
			%tmp_3 = arith.constant 20 : i5
			%tmp_4 = arith.extui %tmp_3 : i5 to i32
			// Evaluate global variable $eval1 done: assigned to tmp_4 above in this context.
			%tmp_5 = arith.cmpi slt, %tmp_2, %tmp_4 : i32
			cal.predicate_result %tmp_5 : i1
		}
		// Guard: End
		// Action Local Variable Decl: Start
		%tmp_6 = cal.get(%l_counter__2: !cal.state_ref<i32>) : i32
		// l_t__3_d1_0 aliased to tmp_6
		// Action Local Variable Decl: End
		fifo.print("Tx: %i\n\00", %tmp_6) : (i32)
		// Assignment Statement: Start
		%tmp_7 = cal.get(%l_counter__2: !cal.state_ref<i32>) : i32
		%tmp_8 = arith.constant 1 : i1
		%tmp_9 = arith.extui %tmp_8 : i1 to i32
		%tmp_10 = arith.addi %tmp_7, %tmp_9 : i32
		cal.set(%l_counter__2: !cal.state_ref<i32>, %tmp_10: i32)
		// Assignment Statement: End
		// Output Expression: Start
		fifo.push(%Out: !fifo.input_port<i32>, %tmp_6: i32)
		// Output Expression: End
	}
}

// CHECK:  func.func @pass_passThrough(%arg0: !fifo.output_port<i32>, %arg1: !fifo.input_port<i32>) -> i1 {
// CHECK-NEXT:    %true = arith.constant true
// CHECK-NEXT:    %false = arith.constant false
// CHECK-NEXT:    %0 = scf.if %true -> (i1) {
// CHECK-NEXT:      %1 = fifo.pop(%arg0 : !fifo.output_port<i32>) : i32
// CHECK-NEXT:      %2 = fifo.pop(%arg0 : !fifo.output_port<i32>) : i32
// CHECK-NEXT:      fifo.push(%arg1 : !fifo.input_port<i32>, %1 : i32)
// CHECK-NEXT:      fifo.push(%arg1 : !fifo.input_port<i32>, %2 : i32)
// CHECK-NEXT:      scf.yield %true : i1
// CHECK-NEXT:    } else {
// CHECK-NEXT:      scf.yield %false : i1
// CHECK-NEXT:    }
// CHECK-NEXT:    return %0 : i1
// CHECK-NEXT:  }

//-- Definition of actor class: Pass
cal.actor @pass ()
	ports_in(%In: !fifo.output_port<i32>)
	ports_out(%Out: !fifo.input_port<i32>)
{
	// -- Actor body
	// Generation action: $untagged0
	cal.action "passThrough" priority=0 {
		// Input Pattern: Start
		%l_t__8_d1_0 = fifo.pop(%In: !fifo.output_port<i32>) : i32
		%l_t__8_d1_1 = fifo.pop(%In: !fifo.output_port<i32>) : i32
		// Input Pattern: End
		// Output Expression: Start
		fifo.push(%Out: !fifo.input_port<i32>, %l_t__8_d1_0: i32)
		fifo.push(%Out: !fifo.input_port<i32>, %l_t__8_d1_1: i32)
		// Output Expression: End
	}
}

// CHECK:  func.func @sink_receive(%arg0: !fifo.output_port<i32>) -> i1 {
// CHECK-NEXT:    %true = arith.constant true
// CHECK-NEXT:    %false = arith.constant false
// CHECK-NEXT:    %0 = scf.if %true -> (i1) {
// CHECK-NEXT:      %1 = fifo.pop(%arg0 : !fifo.output_port<i32>) : i32
// CHECK-NEXT:      fifo.print("Rx: %i\0A\00", %1) : (i32)
// CHECK-NEXT:      scf.yield %true : i1
// CHECK-NEXT:    } else {
// CHECK-NEXT:      scf.yield %false : i1
// CHECK-NEXT:    }
// CHECK-NEXT:    return %0 : i1
// CHECK-NEXT:  }
//-- Definition of actor class: Sink
cal.actor @sink ()
	ports_in(%In: !fifo.output_port<i32>)
{
	// -- Actor body
	// Generation action: $untagged0
	cal.action "receive" priority=0 {
		// Input Pattern: Start
		%l_t__5_d1_0 = fifo.pop(%In: !fifo.output_port<i32>) : i32
		// Input Pattern: End
		fifo.print("Rx: %i\n\00", %l_t__5_d1_0) : (i32)
	}
}

// CHECK: func.func @main() {
// CHECK-NEXT:     %c0_i32 = arith.constant 0 : i32
// CHECK-NEXT:     %inputPort, %outputPort = fifo.create<i32> (10) : !fifo.input_port<i32>, !fifo.output_port<i32>
// CHECK-NEXT:     %inputPort_0, %outputPort_1 = fifo.create<i32> (10) : !fifo.input_port<i32>, !fifo.output_port<i32>
// CHECK-NEXT:     %0 = cal.create_state_var<i32> : !cal.state_ref<i32>
// CHECK-NEXT:     cal.set(%0 : !cal.state_ref<i32>, %c0_i32 : i32)
// CHECK-NEXT:     cf.br ^bb2
// CHECK-NEXT:   ^bb1:  // 3 preds: ^bb2, ^bb3, ^bb4
// CHECK-NEXT:     return
// CHECK-NEXT:   ^bb2:  // 2 preds: ^bb0, ^bb4
// CHECK-NEXT:     %1 = call @source_transmit(%inputPort_0, %0) : (!fifo.input_port<i32>, !cal.state_ref<i32>) -> i1
// CHECK-NEXT:     cf.cond_br %1, ^bb3, ^bb1
// CHECK-NEXT:   ^bb3:  // pred: ^bb2
// CHECK-NEXT:     %2 = call @source_transmit(%inputPort_0, %0) : (!fifo.input_port<i32>, !cal.state_ref<i32>) -> i1
// CHECK-NEXT:     cf.cond_br %2, ^bb4, ^bb1
// CHECK-NEXT:   ^bb4:  // pred: ^bb3
// CHECK-NEXT:     %3 = call @pass_passThrough(%outputPort_1, %inputPort) : (!fifo.output_port<i32>, !fifo.input_port<i32>) -> i1
// CHECK-NEXT:     %4 = call @sink_receive(%outputPort) : (!fifo.output_port<i32>) -> i1
// CHECK-NEXT:     %5 = call @sink_receive(%outputPort) : (!fifo.output_port<i32>) -> i1
// CHECK-NEXT:     cf.cond_br %5, ^bb2, ^bb1
// CHECK-NEXT:   }


// -- Top Network: Defines structure of actor application
cal.network
{

	// -- Instantiate channels between actors
	%queue_from_pass_Out, %queue_to_sink_In = fifo.create<i32>(10) : !fifo.input_port<i32>, !fifo.output_port<i32>
	%queue_from_source_Out, %queue_to_pass_In = fifo.create<i32>(10) : !fifo.input_port<i32>, !fifo.output_port<i32>

	// -- Instantiate actors (also known as nodes/instances)
	cal.create_instance @source "source" ()
		ports_out(%queue_from_source_Out: !fifo.input_port<i32>)
	cal.create_instance @pass "pass" ()
		ports_in(%queue_to_pass_In: !fifo.output_port<i32>)
		ports_out(%queue_from_pass_Out: !fifo.input_port<i32>)
	cal.create_instance @sink "sink" ()
		ports_in(%queue_to_sink_In: !fifo.output_port<i32>)

}