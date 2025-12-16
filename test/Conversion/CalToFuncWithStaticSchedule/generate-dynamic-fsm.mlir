// RUN: cal-opt %s --canonicalize  --convert-cal-to-func-with-static-schedule="print-fsm-for-testing" | FileCheck %s

// CHECK: FSM for actor: data_dependant. Type: Dynamic
cal.actor @data_dependant()
    ports_in(%in0: !fifo.output_port<i32>, %in1: !fifo.output_port<i32>)
    ports_out(%out0: !fifo.input_port<i32>)
{
    cal.action "act1"{
        %token = fifo.pop(%in0: !fifo.output_port<i32>) : i32
        fifo.push(%out0: !fifo.input_port<i32>, %token: i32)
    }

    cal.action "act2"{
        %token = fifo.pop(%in1: !fifo.output_port<i32>) : i32
        fifo.push(%out0: !fifo.input_port<i32>, %token: i32)
    }
}

// CHECK: FSM for actor: single_action. Type: SingleAction
// CHECK-NEXT:   Node 0: receive
// CHECK-NEXT:     -> Next: Node 0
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

//CHECK: FSM for actor: dynamic_fsm. Type: FSM (SimpleLoop)
//CHECK-NEXT:   Node 0: many
//CHECK-NEXT:     -> Next: Node 1
//CHECK-NEXT:   Node 1: many
//CHECK-NEXT:     -> Next: Node 2
//CHECK-NEXT:   Node 2: many
//CHECK-NEXT:     -> Next: Node 3
//CHECK-NEXT:   Node 3: many
//CHECK-NEXT:     -> Next: Node 4
//CHECK-NEXT:   Node 4: many
//CHECK-NEXT:     -> Next: Node 5
//CHECK-NEXT:   Node 5: many
//CHECK-NEXT:     -> Next: Node 6
//CHECK-NEXT:   Node 6: many
//CHECK-NEXT:     -> Next: Node 7
//CHECK-NEXT:   Node 7: many
//CHECK-NEXT:     -> Next: Node 8
//CHECK-NEXT:   Node 8: once
//CHECK-NEXT:     -> Next: Node 0



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

// CHECK: FSM for actor: infinite_dynamic_fsm. Type: Dynamic
cal.actor @infinite_dynamic_fsm ()
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
		// Output Expression: End
	}
	// Generation action: $untagged1
	cal.action "above" priority=0 {
		// Guard: Start
		cal.predicate {
			%tmp_57 = cal.get(%l_count__425: !cal.state_ref<i32>) : i32
			// Evaluate global variable $eval1.
			%tmp_58 = arith.constant 8 : i4
			%tmp_59 = arith.extui %tmp_58 : i4 to i32
			// Evaluate global variable $eval1 done: assigned to tmp_59 above in this context.
			%tmp_60 = arith.cmpi uge, %tmp_57, %tmp_59 : i32
			cal.predicate_result %tmp_60 : i1
		}
		// Guard: End
		// Assignment Statement: Start
		%tmp_53 = cal.get(%l_count__425: !cal.state_ref<i32>) : i32
		%tmp_54 = arith.constant 1 : i1
		%tmp_55 = arith.extui %tmp_54 : i1 to i32
		%tmp_56 = arith.addi %tmp_53, %tmp_55 : i32
		cal.set(%l_count__425: !cal.state_ref<i32>, %tmp_56: i32)
		// Assignment Statement: End
		// Output Expression: Start
		%tmp_63 = cal.get(%l_r__424: !cal.state_ref<i22>) : i22
		fifo.push(%r_out: !fifo.input_port<i22>, %tmp_63: i22)
		// Output Expression: End
	}
}