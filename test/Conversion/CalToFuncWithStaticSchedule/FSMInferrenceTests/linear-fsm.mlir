//RUN: cal-opt --convert-cal-to-func-with-static-schedule="print-fsm-for-testing exit-on-testing-print" %s | FileCheck %s

//CHECK: FSM for actor: linearFsmActor. Type: FSM (Unclassified)
//CHECK-NEXT:   Node 0: action0
//CHECK-NEXT:     -> Next: Node 1
//CHECK-NEXT:   Node 1: action1
//CHECK-NEXT:     -> Next: Node 2
//CHECK-NEXT:   Node 2: action2
//CHECK-NEXT:     -> Next: Node 3
//CHECK-NEXT:   Node 3: action3
//CHECK-NEXT:     -> Next: Node 4
//CHECK-NEXT:   Node 4: <null>
//CHECK-NEXT:     -> (no edges)


//-- Definition of actor class: LinearFSMActor
cal.actor @linearFsmActor ()
{
	// -- Actor body
	%l_state__0 = cal.create_state_var<i32> : !cal.state_ref<i32>
	%tmp_0 = arith.constant 0 : i1
	%tmp_1 = arith.extui %tmp_0 : i1 to i32
	cal.set(%l_state__0: !cal.state_ref<i32>, %tmp_1: i32)
	%l_$state = cal.create_state_var<i32> : !cal.state_ref<i32>
	%tmp_2 = arith.constant 0 : i1
	%tmp_3 = arith.extui %tmp_2 : i1 to i32
	cal.set(%l_$state: !cal.state_ref<i32>, %tmp_3: i32)
	// Generation action: action0
	cal.action "action0" priority=0 {
		// Guard: Start
		cal.predicate {
			%tmp_4 = cal.get(%l_state__0: !cal.state_ref<i32>) : i32
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
		cal.set(%l_state__0: !cal.state_ref<i32>, %tmp_9: i32)
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
			%tmp_12 = cal.get(%l_state__0: !cal.state_ref<i32>) : i32
			%tmp_13 = arith.constant 1 : i1
			%tmp_14 = arith.extui %tmp_13 : i1 to i32
			%tmp_15 = arith.cmpi eq, %tmp_12, %tmp_14 : i32
			cal.predicate_result %tmp_15 : i1
		}
		// Guard: End
		// Call Statement: Start
		fifo.print("In state 1, taking action1\n\00")
		// Call Statement: End
		// Assignment Statement: Start
		%tmp_16 = arith.constant 2 : i2
		%tmp_17 = arith.extui %tmp_16 : i2 to i32
		cal.set(%l_state__0: !cal.state_ref<i32>, %tmp_17: i32)
		// Assignment Statement: End
		// Assignment Statement: Start
		%tmp_18 = arith.constant 0 : i1
		%tmp_19 = arith.extui %tmp_18 : i1 to i32
		cal.set(%l_$state: !cal.state_ref<i32>, %tmp_19: i32)
		// Assignment Statement: End
	}
	// Generation action: action2
	cal.action "action2" priority=0 {
		// Guard: Start
		cal.predicate {
			%tmp_20 = cal.get(%l_state__0: !cal.state_ref<i32>) : i32
			%tmp_21 = arith.constant 2 : i2
			%tmp_22 = arith.extui %tmp_21 : i2 to i32
			%tmp_23 = arith.cmpi eq, %tmp_20, %tmp_22 : i32
			cal.predicate_result %tmp_23 : i1
		}
		// Guard: End
		// Call Statement: Start
		fifo.print("In state 2, taking action2\n\00")
		// Call Statement: End
		// Assignment Statement: Start
		%tmp_24 = arith.constant 3 : i2
		%tmp_25 = arith.extui %tmp_24 : i2 to i32
		cal.set(%l_state__0: !cal.state_ref<i32>, %tmp_25: i32)
		// Assignment Statement: End
		// Assignment Statement: Start
		%tmp_26 = arith.constant 0 : i1
		%tmp_27 = arith.extui %tmp_26 : i1 to i32
		cal.set(%l_$state: !cal.state_ref<i32>, %tmp_27: i32)
		// Assignment Statement: End
	}
	// Generation action: action3
	cal.action "action3" priority=0 {
		// Guard: Start
		cal.predicate {
			%tmp_28 = cal.get(%l_state__0: !cal.state_ref<i32>) : i32
			%tmp_29 = arith.constant 3 : i2
			%tmp_30 = arith.extui %tmp_29 : i2 to i32
			%tmp_31 = arith.cmpi eq, %tmp_28, %tmp_30 : i32
			cal.predicate_result %tmp_31 : i1
		}
		// Guard: End
		// Call Statement: Start
		fifo.print("In state 3, taking action3\n\00")
		// Call Statement: End
		// Assignment Statement: Start
		%tmp_32 = arith.constant 4 : i3
		%tmp_33 = arith.extui %tmp_32 : i3 to i32
		cal.set(%l_state__0: !cal.state_ref<i32>, %tmp_33: i32)
		// Assignment Statement: End
		// Assignment Statement: Start
		%tmp_34 = arith.constant 0 : i1
		%tmp_35 = arith.extui %tmp_34 : i1 to i32
		cal.set(%l_$state: !cal.state_ref<i32>, %tmp_35: i32)
		// Assignment Statement: End
	}
}

// -- Top Network: Defines structure of actor application
cal.network
{

	// -- Instantiate channels between actors

	// -- Instantiate actors (also known as nodes/instances)
	cal.create_instance @linearFsmActor "linearFsmActor" ()

}

