// RUN: cal-opt %s --canonicalize  --convert-cal-to-func-with-static-schedule="print-csdf-schedule-for-testing" | FileCheck %s

// CHECK: CSDF Phases for actor: data_dependant
// CHECK-NEXT:	No CSDF phases available for this actor.
cal.actor @data_dependant()
    ports_in(%in0: !fifo.output_port<i32>, %in1: !fifo.output_port<i32>)
    ports_out(%out0: !fifo.input_port<i32>)
{
    cal.action {
        %token = fifo.pop(%in0: !fifo.output_port<i32>) : i32
        fifo.push(%out0: !fifo.input_port<i32>, %token: i32)
    }

    cal.action{
        %token = fifo.pop(%in1: !fifo.output_port<i32>) : i32
        fifo.push(%out0: !fifo.input_port<i32>, %token: i32)
    }
}

// CHECK: CSDF Phases for actor: single_action
// CHECK-NEXT: 	Action: "receive"
// CHECK-NEXT: 		Port: <block argument> of type '!fifo.output_port<i16>' at index: 0 Rate: -1

cal.actor @single_action ()
	ports_in(%In: !fifo.output_port<i16>)
{
	// -- Actor body
	// Generation action: receive
	cal.action "receive" priority=0 {
		// Input Pattern: Start
		%l_t__71_d1_0 = fifo.pop(%In: !fifo.output_port<i16>) : i16
		// Input Pattern: End
	}
}

//CHECK: CSDF Phases for actor: dynamic_fsm
//CHECK-NEXT: 	Action: "many"
//CHECK-NEXT: 		Port: <block argument> of type '!fifo.output_port<i22>' at index: 0 Rate: -1
//CHECK-NEXT: 		Port: <block argument> of type '!fifo.output_port<i16>' at index: 1 Rate: -1
//CHECK-NEXT: 		Port: <block argument> of type '!fifo.input_port<i22>' at index: 2 Rate: 1
//CHECK-NEXT: 		Port: <block argument> of type '!fifo.input_port<i16>' at index: 4 Rate: 2
//CHECK-NEXT: 	Action: "many"
//CHECK-NEXT: 		Port: <block argument> of type '!fifo.output_port<i22>' at index: 0 Rate: -1
//CHECK-NEXT: 		Port: <block argument> of type '!fifo.output_port<i16>' at index: 1 Rate: -1
//CHECK-NEXT: 		Port: <block argument> of type '!fifo.input_port<i22>' at index: 2 Rate: 1
//CHECK-NEXT: 		Port: <block argument> of type '!fifo.input_port<i16>' at index: 4 Rate: 2
//CHECK-NEXT: 	Action: "many"
//CHECK-NEXT: 		Port: <block argument> of type '!fifo.output_port<i22>' at index: 0 Rate: -1
//CHECK-NEXT: 		Port: <block argument> of type '!fifo.output_port<i16>' at index: 1 Rate: -1
//CHECK-NEXT: 		Port: <block argument> of type '!fifo.input_port<i22>' at index: 2 Rate: 1
//CHECK-NEXT: 		Port: <block argument> of type '!fifo.input_port<i16>' at index: 4 Rate: 2
//CHECK-NEXT: 	Action: "many"
//CHECK-NEXT: 		Port: <block argument> of type '!fifo.output_port<i22>' at index: 0 Rate: -1
//CHECK-NEXT: 		Port: <block argument> of type '!fifo.output_port<i16>' at index: 1 Rate: -1
//CHECK-NEXT: 		Port: <block argument> of type '!fifo.input_port<i22>' at index: 2 Rate: 1
//CHECK-NEXT: 		Port: <block argument> of type '!fifo.input_port<i16>' at index: 4 Rate: 2
//CHECK-NEXT: 	Action: "many"
//CHECK-NEXT: 		Port: <block argument> of type '!fifo.output_port<i22>' at index: 0 Rate: -1
//CHECK-NEXT: 		Port: <block argument> of type '!fifo.output_port<i16>' at index: 1 Rate: -1
//CHECK-NEXT: 		Port: <block argument> of type '!fifo.input_port<i22>' at index: 2 Rate: 1
//CHECK-NEXT: 		Port: <block argument> of type '!fifo.input_port<i16>' at index: 4 Rate: 2
//CHECK-NEXT: 	Action: "many"
//CHECK-NEXT: 		Port: <block argument> of type '!fifo.output_port<i22>' at index: 0 Rate: -1
//CHECK-NEXT: 		Port: <block argument> of type '!fifo.output_port<i16>' at index: 1 Rate: -1
//CHECK-NEXT: 		Port: <block argument> of type '!fifo.input_port<i22>' at index: 2 Rate: 1
//CHECK-NEXT: 		Port: <block argument> of type '!fifo.input_port<i16>' at index: 4 Rate: 2
//CHECK-NEXT: 	Action: "many"
//CHECK-NEXT: 		Port: <block argument> of type '!fifo.output_port<i22>' at index: 0 Rate: -1
//CHECK-NEXT: 		Port: <block argument> of type '!fifo.output_port<i16>' at index: 1 Rate: -1
//CHECK-NEXT: 		Port: <block argument> of type '!fifo.input_port<i22>' at index: 2 Rate: 1
//CHECK-NEXT: 		Port: <block argument> of type '!fifo.input_port<i16>' at index: 4 Rate: 2
//CHECK-NEXT: 	Action: "many"
//CHECK-NEXT: 		Port: <block argument> of type '!fifo.output_port<i22>' at index: 0 Rate: -1
//CHECK-NEXT: 		Port: <block argument> of type '!fifo.output_port<i16>' at index: 1 Rate: -1
//CHECK-NEXT: 		Port: <block argument> of type '!fifo.input_port<i22>' at index: 2 Rate: 1
//CHECK-NEXT: 		Port: <block argument> of type '!fifo.input_port<i16>' at index: 4 Rate: 2
//CHECK-NEXT: 	Action: "once"
//CHECK-NEXT: 		Port: <block argument> of type '!fifo.input_port<i22>' at index: 3 Rate: 1


cal.actor @dynamic_fsm ()
	ports_in(%x_in: !fifo.output_port<i22>,%cordic_angles_in: !fifo.output_port<i16>)
	ports_out(%x_out: !fifo.input_port<i22>,%r_out: !fifo.input_port<i22>,%cordic_angles_out: !fifo.input_port<i16>)
{
	// -- Actor body
	%l_r__424 = cal.create_state_var<i22> : !cal.state_ref<i22>
	%tmp_0 = arith.constant 0 : i1
	%tmp_1 = arith.extui %tmp_0 : i1 to i22
	cal.set(%l_r__424: !cal.state_ref<i22>, %tmp_1: i22)
	%l_count__425 = cal.create_state_var<i32> : !cal.state_ref<i32>
	%tmp_2 = arith.constant 0 : i1
	%tmp_3 = arith.extui %tmp_2 : i1 to i32
	cal.set(%l_count__425: !cal.state_ref<i32>, %tmp_3: i32)
	// Generation action: $untagged0
	cal.action "many" priority=0 {
		// Guard: Start
		cal.predicate {
			%tmp_4 = cal.get(%l_count__425: !cal.state_ref<i32>) : i32
			// Evaluate global variable $eval1.
			%tmp_5 = arith.constant 8 : i4
			%tmp_6 = arith.extui %tmp_5 : i4 to i32
			// Evaluate global variable $eval1 done: assigned to tmp_6 above in this context.
			%tmp_7 = arith.cmpi ult, %tmp_4, %tmp_6 : i32
			cal.predicate_result %tmp_7 : i1
		}
		%cordic_angles = fifo.pop(%cordic_angles_in: !fifo.output_port<i16>) : i16
		%x_in_value = fifo.pop(%x_in: !fifo.output_port<i22>) : i22
		%tmp_53 = cal.get(%l_count__425: !cal.state_ref<i32>) : i32
		%tmp_54 = arith.constant 1 : i1
		%tmp_55 = arith.extui %tmp_54 : i1 to i32
		%tmp_56 = arith.addi %tmp_53, %tmp_55 : i32
		cal.set(%l_count__425: !cal.state_ref<i32>, %tmp_56: i32)
		// Assignment Statement: End
		// Output Expression: Start
        %tmp_out_1 = arith.constant 0 : i22
        %tmp_out_2 = arith.constant 0 : i16
		fifo.push(%x_out: !fifo.input_port<i22>, %tmp_out_1: i22)
		// Output Expression: End
		// Output Expression: Start
		fifo.push(%cordic_angles_out: !fifo.input_port<i16>, %tmp_out_2: i16)
		fifo.push(%cordic_angles_out: !fifo.input_port<i16>, %tmp_out_2: i16)
		// Output Expression: End
	}
	// Generation action: $untagged1
	cal.action "once" priority=0 {
		// Guard: Start
		cal.predicate {
			%tmp_57 = cal.get(%l_count__425: !cal.state_ref<i32>) : i32
			// Evaluate global variable $eval1.
			%tmp_58 = arith.constant 8 : i4
			%tmp_59 = arith.extui %tmp_58 : i4 to i32
			// Evaluate global variable $eval1 done: assigned to tmp_59 above in this context.
			%tmp_60 = arith.cmpi eq, %tmp_57, %tmp_59 : i32
			cal.predicate_result %tmp_60 : i1
		}
		// Guard: End
		// Assignment Statement: Start
		%tmp_61 = arith.constant 0 : i1
		%tmp_62 = arith.extui %tmp_61 : i1 to i32
		cal.set(%l_count__425: !cal.state_ref<i32>, %tmp_62: i32)
		// Assignment Statement: End
		// Output Expression: Start
		%tmp_63 = cal.get(%l_r__424: !cal.state_ref<i22>) : i22
		fifo.push(%r_out: !fifo.input_port<i22>, %tmp_63: i22)
		// Output Expression: End
	}
}