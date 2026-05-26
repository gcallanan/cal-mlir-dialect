//RUN: cal-opt --convert-cal-to-func-with-static-schedule="print-fsm-for-testing exit-on-testing-print" %s | FileCheck %s

//CHECK: FSM for actor: cycleWithInitAndTerminateActor. Type: FSM (Unclassified)
//CHECK-NEXT:   Node 0: action0
//CHECK-NEXT:     -> Next: Node 1
//CHECK-NEXT:   Node 1: action1
//CHECK-NEXT:     -> Next: Node 2
//CHECK-NEXT:   Node 2: action2
//CHECK-NEXT:     -> Next: Node 3
//CHECK-NEXT:   Node 3: action3
//CHECK-NEXT:     -> Next: Node 4
//CHECK-NEXT:     -> Next: Node 2
//CHECK-NEXT:   Node 4: action4
//CHECK-NEXT:     -> Next: Node 5
//CHECK-NEXT:   Node 5: <null>
//CHECK-NEXT:     -> (no edges)


//-- Definition of actor class: CycleWithInitAndTerminateActor
cal.actor @cycleWithInitAndTerminateActor ()
{
	// -- Actor body
	%l_state__0 = cal.create_state_var<i32> : !cal.state_ref<i32>
	%tmp_0 = arith.constant 0 : i1
	%tmp_1 = arith.extui %tmp_0 : i1 to i32
	cal.set(%l_state__0: !cal.state_ref<i32>, %tmp_1: i32)
	%l_cycles__1 = cal.create_state_var<i32> : !cal.state_ref<i32>
	%tmp_2 = arith.constant 0 : i1
	%tmp_3 = arith.extui %tmp_2 : i1 to i32
	cal.set(%l_cycles__1: !cal.state_ref<i32>, %tmp_3: i32)
	%l_$state = cal.create_state_var<i32> : !cal.state_ref<i32>
	%tmp_4 = arith.constant 0 : i1
	%tmp_5 = arith.extui %tmp_4 : i1 to i32
	cal.set(%l_$state: !cal.state_ref<i32>, %tmp_5: i32)
	// Generation action: action0
	cal.action "action0" priority=0 {
		// Guard: Start
		cal.predicate {
			%tmp_6 = cal.get(%l_state__0: !cal.state_ref<i32>) : i32
			%tmp_7 = arith.constant 0 : i1
			%tmp_8 = arith.extui %tmp_7 : i1 to i32
			%tmp_9 = arith.cmpi eq, %tmp_6, %tmp_8 : i32
			cal.predicate_result %tmp_9 : i1
		}
		// Guard: End
		// Call Statement: Start
		fifo.print("In state 0, taking action0\n\00")
		// Call Statement: End
		// Assignment Statement: Start
		%tmp_10 = arith.constant 1 : i1
		%tmp_11 = arith.extui %tmp_10 : i1 to i32
		cal.set(%l_state__0: !cal.state_ref<i32>, %tmp_11: i32)
		// Assignment Statement: End
		// Assignment Statement: Start
		%tmp_12 = arith.constant 0 : i1
		%tmp_13 = arith.extui %tmp_12 : i1 to i32
		cal.set(%l_$state: !cal.state_ref<i32>, %tmp_13: i32)
		// Assignment Statement: End
	}
	// Generation action: action1
	cal.action "action1" priority=0 {
		// Guard: Start
		cal.predicate {
			%tmp_14 = cal.get(%l_state__0: !cal.state_ref<i32>) : i32
			%tmp_15 = arith.constant 1 : i1
			%tmp_16 = arith.extui %tmp_15 : i1 to i32
			%tmp_17 = arith.cmpi eq, %tmp_14, %tmp_16 : i32
			cal.predicate_result %tmp_17 : i1
		}
		// Guard: End
		// Call Statement: Start
		fifo.print("In state 1, taking action1\n\00")
		// Call Statement: End
		// Assignment Statement: Start
		%tmp_18 = arith.constant 2 : i2
		%tmp_19 = arith.extui %tmp_18 : i2 to i32
		cal.set(%l_state__0: !cal.state_ref<i32>, %tmp_19: i32)
		// Assignment Statement: End
		// Assignment Statement: Start
		%tmp_20 = arith.constant 0 : i1
		%tmp_21 = arith.extui %tmp_20 : i1 to i32
		cal.set(%l_$state: !cal.state_ref<i32>, %tmp_21: i32)
		// Assignment Statement: End
	}
	// Generation action: action2
	cal.action "action2" priority=0 {
		// Guard: Start
		cal.predicate {
			%tmp_22 = cal.get(%l_state__0: !cal.state_ref<i32>) : i32
			%tmp_23 = arith.constant 2 : i2
			%tmp_24 = arith.extui %tmp_23 : i2 to i32
			%tmp_25 = arith.cmpi eq, %tmp_22, %tmp_24 : i32
			cal.predicate_result %tmp_25 : i1
		}
		// Guard: End
		// Call Statement: Start
		fifo.print("In state 2, taking action2\n\00")
		// Call Statement: End
		// Assignment Statement: Start
		%tmp_26 = arith.constant 3 : i2
		%tmp_27 = arith.extui %tmp_26 : i2 to i32
		cal.set(%l_state__0: !cal.state_ref<i32>, %tmp_27: i32)
		// Assignment Statement: End
		// Assignment Statement: Start
		%tmp_28 = arith.constant 0 : i1
		%tmp_29 = arith.extui %tmp_28 : i1 to i32
		cal.set(%l_$state: !cal.state_ref<i32>, %tmp_29: i32)
		// Assignment Statement: End
	}
	// Generation action: action3
	cal.action "action3" priority=0 {
		// Guard: Start
		cal.predicate {
			%tmp_30 = cal.get(%l_state__0: !cal.state_ref<i32>) : i32
			%tmp_31 = arith.constant 3 : i2
			%tmp_32 = arith.extui %tmp_31 : i2 to i32
			%tmp_33 = arith.cmpi eq, %tmp_30, %tmp_32 : i32
			cal.predicate_result %tmp_33 : i1
		}
		// Guard: End
		// Call Statement: Start
		fifo.print("In state 3, taking action3\n\00")
		// Call Statement: End
		// Assignment Statement: Start
		%tmp_34 = cal.get(%l_cycles__1: !cal.state_ref<i32>) : i32
		%tmp_35 = arith.constant 1 : i1
		%tmp_36 = arith.extui %tmp_35 : i1 to i32
		%tmp_37 = arith.addi %tmp_34, %tmp_36 : i32
		cal.set(%l_cycles__1: !cal.state_ref<i32>, %tmp_37: i32)
		// Assignment Statement: End
		// If Statement: Begin
		%tmp_38 = cal.get(%l_cycles__1: !cal.state_ref<i32>) : i32
		%tmp_39 = arith.constant 10 : i4
		%tmp_40 = arith.extui %tmp_39 : i4 to i32
		%tmp_41 = arith.cmpi eq, %tmp_38, %tmp_40 : i32
		scf.if %tmp_41 {
			// Assignment Statement: Start
			%tmp_42 = arith.constant 4 : i3
			%tmp_43 = arith.extui %tmp_42 : i3 to i32
			cal.set(%l_state__0: !cal.state_ref<i32>, %tmp_43: i32)
			// Assignment Statement: End
		} else {
			// Assignment Statement: Start
			%tmp_44 = arith.constant 2 : i2
			%tmp_45 = arith.extui %tmp_44 : i2 to i32
			cal.set(%l_state__0: !cal.state_ref<i32>, %tmp_45: i32)
			// Assignment Statement: End
		}
		// If Statement: End
		// Assignment Statement: Start
		%tmp_46 = arith.constant 0 : i1
		%tmp_47 = arith.extui %tmp_46 : i1 to i32
		cal.set(%l_$state: !cal.state_ref<i32>, %tmp_47: i32)
		// Assignment Statement: End
	}
	// Generation action: action4
	cal.action "action4" priority=0 {
		// Guard: Start
		cal.predicate {
			%tmp_48 = cal.get(%l_state__0: !cal.state_ref<i32>) : i32
			%tmp_49 = arith.constant 4 : i3
			%tmp_50 = arith.extui %tmp_49 : i3 to i32
			%tmp_51 = arith.cmpi eq, %tmp_48, %tmp_50 : i32
			cal.predicate_result %tmp_51 : i1
		}
		// Guard: End
		// Call Statement: Start
		fifo.print("In state 4, taking action4\n\00")
		// Call Statement: End
		// Assignment Statement: Start
		%tmp_52 = arith.constant 5 : i3
		%tmp_53 = arith.extui %tmp_52 : i3 to i32
		cal.set(%l_state__0: !cal.state_ref<i32>, %tmp_53: i32)
		// Assignment Statement: End
		// Assignment Statement: Start
		%tmp_54 = arith.constant 0 : i1
		%tmp_55 = arith.extui %tmp_54 : i1 to i32
		cal.set(%l_$state: !cal.state_ref<i32>, %tmp_55: i32)
		// Assignment Statement: End
	}
}

// -- Top Network: Defines structure of actor application
cal.network @top()
{

	// -- Instantiate channels between actors

	// -- Instantiate actors (also known as nodes/instances)
	cal.create_instance @cycleWithInitAndTerminateActor "cycleWithInitAndTerminateActor" ()

}

