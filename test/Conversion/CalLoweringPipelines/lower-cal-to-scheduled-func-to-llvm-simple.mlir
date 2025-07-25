// RUN: cal-opt %s --lower-cal-to-llvm-with-static-schedule | cal-translate --mlir-to-llvmir | lli | FileCheck %s

//CHECK: Tx: 0
//CHECK-NEXT: Tx: 1
//CHECK-NEXT: Rx: 0
//CHECK-NEXT: Rx: 1
//CHECK-NEXT: Tx: 2
//CHECK-NEXT: Tx: 3
//CHECK-NEXT: Rx: 2
//CHECK-NEXT: Rx: 3
//CHECK-NEXT: Tx: 4
//CHECK-NEXT: Tx: 5
//CHECK-NEXT: Rx: 4
//CHECK-NEXT: Rx: 5
//CHECK-NEXT: Tx: 6
//CHECK-NEXT: Tx: 7
//CHECK-NEXT: Rx: 6
//CHECK-NEXT: Rx: 7
//CHECK-NEXT: Tx: 8
//CHECK-NEXT: Tx: 9
//CHECK-NEXT: Rx: 8
//CHECK-NEXT: Rx: 9
//CHECK-NEXT: Tx: 10
//CHECK-NEXT: Tx: 11
//CHECK-NEXT: Rx: 10
//CHECK-NEXT: Rx: 11
//CHECK-NEXT: Tx: 12
//CHECK-NEXT: Tx: 13
//CHECK-NEXT: Rx: 12
//CHECK-NEXT: Rx: 13
//CHECK-NEXT: Tx: 14
//CHECK-NEXT: Tx: 15
//CHECK-NEXT: Rx: 14
//CHECK-NEXT: Rx: 15
//CHECK-NEXT: Tx: 16
//CHECK-NEXT: Tx: 17
//CHECK-NEXT: Rx: 16
//CHECK-NEXT: Rx: 17
//CHECK-NEXT: Tx: 18
//CHECK-NEXT: Tx: 19
//CHECK-NEXT: Rx: 18
//CHECK-NEXT: Rx: 19


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