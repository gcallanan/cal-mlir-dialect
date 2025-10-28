//RUN: cal-opt --convert-cal-to-func-with-static-schedule="print-fsm-for-testing exit-on-testing-print" %s | FileCheck %s

//CHECK: FSM for actor: cycleWithBranchActor. Type: FSM (Unclassified)
//CHECK-NEXT:   Node 0: action0
//CHECK-NEXT:     -> Next: Node 1
//CHECK-NEXT:   Node 1: action1
//CHECK-NEXT:     -> Next: Node 3
//CHECK-NEXT:     -> Next: Node 2
//CHECK-NEXT:   Node 2: action2
//CHECK-NEXT:     -> Next: Node 4
//CHECK-NEXT:   Node 3: action3
//CHECK-NEXT:     -> Next: Node 4
//CHECK-NEXT:   Node 4: action5
//CHECK-NEXT:     -> Next: Node 2


//-- Definition of actor class: CycleWithBranchActor
cal.actor @cycleWithBranchActor ()
{
	// -- Actor body
	%l_state__2 = cal.create_state_var<i32> : !cal.state_ref<i32>
	%tmp_0 = arith.constant 0 : i1
	%tmp_1 = arith.extui %tmp_0 : i1 to i32
	cal.set(%l_state__2: !cal.state_ref<i32>, %tmp_1: i32)
	%l_$state = cal.create_state_var<i32> : !cal.state_ref<i32>
	%tmp_2 = arith.constant 0 : i1
	%tmp_3 = arith.extui %tmp_2 : i1 to i32
	cal.set(%l_$state: !cal.state_ref<i32>, %tmp_3: i32)
	// Generation action: action0
	cal.action "action0" priority=0 {
		// Guard: Start
		cal.predicate {
			%tmp_4 = cal.get(%l_state__2: !cal.state_ref<i32>) : i32
			%tmp_5 = arith.constant 0 : i1
			%tmp_6 = arith.extui %tmp_5 : i1 to i32
			%tmp_7 = arith.cmpi eq, %tmp_4, %tmp_6 : i32
			cal.predicate_result %tmp_7 : i1
		}
		// Guard: End
		// Call Statement: Start
		fifo.print("In state 0, taking action0\n\00")
		// Call Statement: End
		// Assignment Statement: Start
		%tmp_8 = arith.constant 1 : i1
		%tmp_9 = arith.extui %tmp_8 : i1 to i32
		cal.set(%l_state__2: !cal.state_ref<i32>, %tmp_9: i32)
		// Assignment Statement: End
		// Assignment Statement: Start
		%tmp_10 = arith.constant 0 : i1
		%tmp_11 = arith.extui %tmp_10 : i1 to i32
		cal.set(%l_$state: !cal.state_ref<i32>, %tmp_11: i32)
		// Assignment Statement: End
	}
	// Generation action: action1
	cal.action "action1" priority=0 {
		// Guard: Start
		cal.predicate {
			%tmp_12 = cal.get(%l_state__2: !cal.state_ref<i32>) : i32
			%tmp_13 = arith.constant 1 : i1
			%tmp_14 = arith.extui %tmp_13 : i1 to i32
			%tmp_15 = arith.cmpi eq, %tmp_12, %tmp_14 : i32
			cal.predicate_result %tmp_15 : i1
		}
		// Guard: End
		// Call Statement: Start
		fifo.print("In state 1, taking action1\n\00")
		// Call Statement: End
		// If Statement: Begin
		// Evaluate global variable $eval1.
		%tmp_16 = arith.constant 0 : i1
		%tmp_17 = arith.extui %tmp_16 : i1 to i32
		// Evaluate global variable $eval1 done: assigned to tmp_17 above in this context.
		%tmp_18 = arith.constant 5 : i3
		%tmp_19 = arith.extui %tmp_18 : i3 to i32
		%tmp_20 = arith.cmpi slt, %tmp_17, %tmp_19 : i32
		scf.if %tmp_20 {
			// Assignment Statement: Start
			%tmp_21 = arith.constant 3 : i2
			%tmp_22 = arith.extui %tmp_21 : i2 to i32
			cal.set(%l_state__2: !cal.state_ref<i32>, %tmp_22: i32)
			// Assignment Statement: End
		} else {
			// Assignment Statement: Start
			%tmp_23 = arith.constant 2 : i2
			%tmp_24 = arith.extui %tmp_23 : i2 to i32
			cal.set(%l_state__2: !cal.state_ref<i32>, %tmp_24: i32)
			// Assignment Statement: End
		}
		// If Statement: End
		// Assignment Statement: Start
		%tmp_25 = arith.constant 0 : i1
		%tmp_26 = arith.extui %tmp_25 : i1 to i32
		cal.set(%l_$state: !cal.state_ref<i32>, %tmp_26: i32)
		// Assignment Statement: End
	}
	// Generation action: action2
	cal.action "action2" priority=0 {
		// Guard: Start
		cal.predicate {
			%tmp_27 = cal.get(%l_state__2: !cal.state_ref<i32>) : i32
			%tmp_28 = arith.constant 2 : i2
			%tmp_29 = arith.extui %tmp_28 : i2 to i32
			%tmp_30 = arith.cmpi eq, %tmp_27, %tmp_29 : i32
			cal.predicate_result %tmp_30 : i1
		}
		// Guard: End
		// Call Statement: Start
		fifo.print("In state 2, taking action2\n\00")
		// Call Statement: End
		// Assignment Statement: Start
		%tmp_31 = arith.constant 4 : i3
		%tmp_32 = arith.extui %tmp_31 : i3 to i32
		cal.set(%l_state__2: !cal.state_ref<i32>, %tmp_32: i32)
		// Assignment Statement: End
		// Assignment Statement: Start
		%tmp_33 = arith.constant 0 : i1
		%tmp_34 = arith.extui %tmp_33 : i1 to i32
		cal.set(%l_$state: !cal.state_ref<i32>, %tmp_34: i32)
		// Assignment Statement: End
	}
	// Generation action: action3
	cal.action "action3" priority=0 {
		// Guard: Start
		cal.predicate {
			%tmp_35 = cal.get(%l_state__2: !cal.state_ref<i32>) : i32
			%tmp_36 = arith.constant 3 : i2
			%tmp_37 = arith.extui %tmp_36 : i2 to i32
			%tmp_38 = arith.cmpi eq, %tmp_35, %tmp_37 : i32
			cal.predicate_result %tmp_38 : i1
		}
		// Guard: End
		// Call Statement: Start
		fifo.print("In state 3, taking action3\n\00")
		// Call Statement: End
		// Assignment Statement: Start
		%tmp_39 = arith.constant 4 : i3
		%tmp_40 = arith.extui %tmp_39 : i3 to i32
		cal.set(%l_state__2: !cal.state_ref<i32>, %tmp_40: i32)
		// Assignment Statement: End
		// Assignment Statement: Start
		%tmp_41 = arith.constant 0 : i1
		%tmp_42 = arith.extui %tmp_41 : i1 to i32
		cal.set(%l_$state: !cal.state_ref<i32>, %tmp_42: i32)
		// Assignment Statement: End
	}
	// Generation action: action5
	cal.action "action5" priority=0 {
		// Guard: Start
		cal.predicate {
			%tmp_43 = cal.get(%l_state__2: !cal.state_ref<i32>) : i32
			%tmp_44 = arith.constant 4 : i3
			%tmp_45 = arith.extui %tmp_44 : i3 to i32
			%tmp_46 = arith.cmpi eq, %tmp_43, %tmp_45 : i32
			cal.predicate_result %tmp_46 : i1
		}
		// Guard: End
		// Call Statement: Start
		fifo.print("In state 4, taking action4\n\00")
		// Call Statement: End
		// Assignment Statement: Start
		%tmp_47 = arith.constant 2 : i2
		%tmp_48 = arith.extui %tmp_47 : i2 to i32
		cal.set(%l_state__2: !cal.state_ref<i32>, %tmp_48: i32)
		// Assignment Statement: End
		// Assignment Statement: Start
		%tmp_49 = arith.constant 0 : i1
		%tmp_50 = arith.extui %tmp_49 : i1 to i32
		cal.set(%l_$state: !cal.state_ref<i32>, %tmp_50: i32)
		// Assignment Statement: End
	}
}

// -- Top Network: Defines structure of actor application
cal.network
{

	// -- Instantiate channels between actors

	// -- Instantiate actors (also known as nodes/instances)
	cal.create_instance @cycleWithBranchActor "cycleWithBranchActor" ()

}

