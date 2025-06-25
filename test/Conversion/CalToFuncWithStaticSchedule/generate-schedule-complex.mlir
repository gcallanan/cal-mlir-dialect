// RUN: cal-opt %s --canonicalize --convert-cal-to-func-with-static-schedule="print-static-schedule-for-testing" | FileCheck %s

//CHECK: Static Schedule:
//Actor: iGenerator_0, Action: "$untagged0"
//Actor: iGenerator_1, Action: "$untagged0"
//CHECK:   Actor: source, Action: "transmit"
//CHECK-NEXT:   Actor: boundaryCells_0, Action: "normal"
//CHECK-NEXT:   Actor: innerCells_r_0, Action: "normal"
//CHECK-NEXT:   Actor: innerCells_q_0, Action: "normal"
//CHECK-NEXT:   Actor: boundaryCells_1, Action: "normal"
//CHECK-NEXT:   Actor: innerCells_q_1, Action: "normal"
//CHECK-NEXT:   Actor: innerCells_q_2, Action: "normal"
// Actor: caps_cordic_0, Action: "receive"
// Actor: caps_x_0, Action: "receive"
// Actor: innerCells_q_3, Action: "normal"
// Actor: caps_cordic_1, Action: "receive"
// Actor: caps_x_1, Action: "receive"
// Actor: iGenerator_0, Action: "$untagged0"
// Actor: iGenerator_1, Action: "$untagged0"
// CHECK: Actor: source, Action: "transmit"
// CHECK-NEXT: Actor: boundaryCells_0, Action: "normal"
// CHECK-NEXT: Actor: innerCells_r_0, Action: "normal"
// CHECK-NEXT: Actor: innerCells_q_0, Action: "normal"
// CHECK-NEXT: Actor: boundaryCells_1, Action: "normal"
// CHECK-NEXT: Actor: innerCells_q_1, Action: "normal"
// CHECK-NEXT: Actor: innerCells_q_2, Action: "normal"
// Actor: caps_cordic_0, Action: "receive"
// Actor: caps_x_0, Action: "receive"
// Actor: innerCells_q_3, Action: "normal"
// Actor: caps_cordic_1, Action: "receive"
// Actor: caps_x_1, Action: "receive"
//CHECK:   Actor: boundaryCells_0, Action: "final"
//CHECK-NEXT:   Actor: boundaryCells_1, Action: "final"
//CHECK-NEXT:   Actor: innerCells_q_0, Action: "final"
//CHECK-NEXT:   Actor: innerCells_q_1, Action: "final"
//CHECK-NEXT:   Actor: innerCells_q_2, Action: "final"
//CHECK-NEXT:   Actor: innerCells_q_3, Action: "final"
//CHECK-NEXT:   Actor: innerCells_r_0, Action: "final"
//CHECK-NEXT:   Actor: joinersPerRow_r_1, Action: "$untagged0"
//CHECK-NEXT:   Actor: joinersPerRow_q_0, Action: "$untagged0"
//CHECK-NEXT:   Actor: joinersPerRow_q_1, Action: "$untagged0"
//CHECK-NEXT:   Actor: joinersPerRow_r_0, Action: "$untagged0"
//CHECK-NEXT:   Actor: caps_r_1, Action: "receive"
//CHECK-NEXT:   Actor: caps_q_0, Action: "receive"
//CHECK-NEXT:   Actor: caps_q_1, Action: "receive"
//CHECK-NEXT:   Actor: caps_r_0, Action: "receive"
//CHECK-NEXT:   Actor: caps_q_0, Action: "receive"
//CHECK-NEXT:   Actor: caps_q_1, Action: "receive"
//CHECK-NEXT:   Actor: caps_r_0, Action: "receive"



// Global callable definition
func.func @g_qrd_fixedPointMultiply(%l_a_d0_0 : i22, %l_b_d0_0 : i22) -> i22 {
	%tmp_0 = arith.extsi %l_a_d0_0 : i22 to i44
	%tmp_1 = arith.extsi %l_b_d0_0 : i22 to i44
	%tmp_2 = arith.muli %tmp_0, %tmp_1 : i44
	// Evaluate global variable n.
	%tmp_3 = arith.constant 19 : i5
	%tmp_4 = arith.extui %tmp_3 : i5 to i32
	// Evaluate global variable n done: assigned to tmp_4 above in this context.
	%tmp_5 = arith.extui %tmp_4 : i32 to i44
	%tmp_6 = arith.shrsi %tmp_2, %tmp_5 : i44
	%tmp_7 = arith.trunci %tmp_6 : i44 to i22
	func.return %tmp_7 : i22
}

//-- Definition of actor class: Cap_Iterations
cal.actor @caps_cordic_1 ()
	ports_in(%In: !fifo.output_port<i16>)
{
	// -- Actor body
	// Generation action: receive
	cal.action "receive" priority=0 {
		// Input Pattern: Start
		%l_t__23_d1_0 = fifo.pop(%In: !fifo.output_port<i16>) : i16
		// Input Pattern: End
	}
}

//-- Definition of actor class: InnerCell
cal.actor @innerCells_q_0 ()
	ports_in(%x_in: !fifo.output_port<i22>,%cordic_angles_in: !fifo.output_port<i16>)
	ports_out(%x_out: !fifo.input_port<i22>,%r_out: !fifo.input_port<i22>,%cordic_angles_out: !fifo.input_port<i16>)
{
	// -- Actor body
	%l_r__73 = cal.create_state_var<i22> : !cal.state_ref<i22>
	%tmp_0 = arith.constant 0 : i1
	%tmp_1 = arith.extui %tmp_0 : i1 to i22
	cal.set(%l_r__73: !cal.state_ref<i22>, %tmp_1: i22)
	%l_count__74 = cal.create_state_var<i32> : !cal.state_ref<i32>
	%tmp_2 = arith.constant 0 : i1
	%tmp_3 = arith.extui %tmp_2 : i1 to i32
	cal.set(%l_count__74: !cal.state_ref<i32>, %tmp_3: i32)
	// Generation action: normal
	cal.action "normal" priority=0 {
		// Guard: Start
		cal.predicate {
			%tmp_4 = cal.get(%l_count__74: !cal.state_ref<i32>) : i32
			// Evaluate global variable $eval1.
			%tmp_5 = arith.constant 2 : i2
			%tmp_6 = arith.extui %tmp_5 : i2 to i32
			// Evaluate global variable $eval1 done: assigned to tmp_6 above in this context.
			%tmp_7 = arith.cmpi ult, %tmp_4, %tmp_6 : i32
			cal.predicate_result %tmp_7 : i1
		}
		// Guard: End
		// Input Pattern: Start
		%l_x__in__76_d1_0 = fifo.pop(%x_in: !fifo.output_port<i22>) : i22
		// Input Pattern: End
		// Input Pattern: Start
		%l_rotation__angles__79_d1_0 = fifo.pop(%cordic_angles_in: !fifo.output_port<i16>) : i16
		// Input Pattern: End
		// Action Local Variable Decl: Start
		%l_x__out__81_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_x__j__82_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_x__j__plus__1__83_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_x__j__shifted__84_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_y__j__85_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_y__j__plus__1__86_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_y__j__shifted__87_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// If Statement: Begin
		%tmp_8 = cal.get(%l_count__74: !cal.state_ref<i32>) : i32
		%tmp_9 = arith.constant 0 : i1
		%tmp_10 = arith.extui %tmp_9 : i1 to i32
		%tmp_11 = arith.cmpi eq, %tmp_8, %tmp_10 : i32
		scf.if %tmp_11 {
			// Assignment Statement: Start
			%tmp_12 = arith.constant 0 : i1
			%tmp_13 = arith.extui %tmp_12 : i1 to i22
			cal.set(%l_r__73: !cal.state_ref<i22>, %tmp_13: i22)
			// Assignment Statement: End
		} else {
		}
		// If Statement: End
		// Assignment Statement: Start
		// l_x__j__82_d1_1 aliased to l_x__in__76_d1_0
		// Assignment Statement: End
		// Assignment Statement: Start
		%tmp_14 = cal.get(%l_r__73: !cal.state_ref<i22>) : i22
		// l_y__j__85_d1_1 aliased to tmp_14
		// Assignment Statement: End
		// Foreach Statement: Begin
		%tmp_15 = arith.constant 0 : i1
		%tmp_16 = arith.extui %tmp_15 : i1 to i32
		%tmp_17_lb = index.casts %tmp_16 : i32 to index
		// Evaluate global variable num_CORDIC_iterations.
		%tmp_18 = arith.constant 16 : i5
		%tmp_19 = arith.extui %tmp_18 : i5 to i32
		// Evaluate global variable num_CORDIC_iterations done: assigned to tmp_19 above in this context.
		%tmp_20 = arith.constant 1 : i1
		%tmp_21 = arith.extui %tmp_20 : i1 to i32
		%tmp_22 = arith.subi %tmp_19, %tmp_21 : i32
		%tmp_23_ub = index.casts %tmp_22 : i32 to index
		%tmp_24_step = index.constant 1
		%tmp_25_ub_plus_1 = arith.addi %tmp_23_ub, %tmp_24_step : index
		%l_x__j__82_d1_2, %l_x__j__plus__1__83_d1_1, %l_x__j__shifted__84_d1_1, %l_y__j__85_d1_2, %l_y__j__plus__1__86_d1_1, %l_y__j__shifted__87_d1_1 = scf.for %l_j_d1_0 = %tmp_17_lb to %tmp_25_ub_plus_1 step %tmp_24_step
				iter_args(%l_x__j__82_d2_0 = %l_x__in__76_d1_0, %l_x__j__plus__1__83_d2_0 = %l_x__j__plus__1__83_d1_0, %l_x__j__shifted__84_d2_0 = %l_x__j__shifted__84_d1_0, %l_y__j__85_d2_0 = %tmp_14, %l_y__j__plus__1__86_d2_0 = %l_y__j__plus__1__86_d1_0, %l_y__j__shifted__87_d2_0 = %l_y__j__shifted__87_d1_0) -> (i22, i22, i22, i22, i22, i22) {
			%l_j_d2_0 = arith.index_cast %l_j_d1_0 : index to i32
			%l_j_d2_1 = arith.trunci %l_j_d2_0 : i32 to i8
			// Assignment Statement: Start
			%tmp_26 = arith.extui %l_j_d2_1 : i8 to i22
			%tmp_27 = arith.shrsi %l_y__j__85_d2_0, %tmp_26 : i22
			// l_y__j__shifted__87_d2_1 aliased to tmp_27
			// Assignment Statement: End
			// Assignment Statement: Start
			%tmp_28 = arith.extui %l_j_d2_1 : i8 to i22
			%tmp_29 = arith.shrsi %l_x__j__82_d2_0, %tmp_28 : i22
			// l_x__j__shifted__84_d2_1 aliased to tmp_29
			// Assignment Statement: End
			// If Statement: Begin
			%tmp_30 = arith.extui %l_j_d2_1 : i8 to i16
			%tmp_31 = arith.shrui %l_rotation__angles__79_d1_0, %tmp_30 : i16
			%tmp_32 = arith.constant 1 : i1
			%tmp_33 = arith.trunci %tmp_31 : i16 to i1
			%tmp_34 = arith.andi %tmp_33, %tmp_32 : i1
			%tmp_35 = arith.constant 1 : i1
			%tmp_36 = arith.cmpi eq, %tmp_34, %tmp_35 : i1
			%l_x__j__plus__1__83_d2_1, %l_y__j__plus__1__86_d2_1 = scf.if %tmp_36 -> (i22, i22) {
				// Assignment Statement: Start
				%tmp_37 = arith.extsi %l_x__j__82_d2_0 : i22 to i23
				%tmp_38 = arith.extsi %tmp_27 : i22 to i23
				%tmp_39 = arith.addi %tmp_37, %tmp_38 : i23
				%tmp_40 = arith.trunci %tmp_39 : i23 to i22
				// l_x__j__plus__1__83_d3_0 aliased to tmp_40
				// Assignment Statement: End
				// Assignment Statement: Start
				%tmp_41 = arith.subi %l_y__j__85_d2_0, %tmp_29 : i22
				// l_y__j__plus__1__86_d3_0 aliased to tmp_41
				// Assignment Statement: End
				scf.yield %tmp_40, %tmp_41 : i22, i22
			} else {
				// Assignment Statement: Start
				%tmp_42 = arith.subi %l_x__j__82_d2_0, %tmp_27 : i22
				// l_x__j__plus__1__83_d3_0 aliased to tmp_42
				// Assignment Statement: End
				// Assignment Statement: Start
				%tmp_43 = arith.extsi %l_y__j__85_d2_0 : i22 to i23
				%tmp_44 = arith.extsi %tmp_29 : i22 to i23
				%tmp_45 = arith.addi %tmp_43, %tmp_44 : i23
				%tmp_46 = arith.trunci %tmp_45 : i23 to i22
				// l_y__j__plus__1__86_d3_0 aliased to tmp_46
				// Assignment Statement: End
				scf.yield %tmp_42, %tmp_46 : i22, i22
			}
			// If Statement: End
			// Assignment Statement: Start
			// l_x__j__82_d2_1 aliased to l_x__j__plus__1__83_d2_1
			// Assignment Statement: End
			// Assignment Statement: Start
			// l_y__j__85_d2_1 aliased to l_y__j__plus__1__86_d2_1
			// Assignment Statement: End
			scf.yield %l_x__j__plus__1__83_d2_1, %l_x__j__plus__1__83_d2_1, %tmp_29, %l_y__j__plus__1__86_d2_1, %l_y__j__plus__1__86_d2_1, %tmp_27 : i22, i22, i22, i22, i22, i22
		}
		// Foreach Statement: End
		// Assignment Statement: Start
		// Evaluate global variable k_CORDIC_constant.
		%tmp_48 = arith.constant 318375 : i19
		%tmp_49 = arith.extui %tmp_48 : i19 to i22
		// Evaluate global variable k_CORDIC_constant done: assigned to tmp_49 above in this context.
		// Evaluate global variable fixedPointMultiply.
		%tmp_47 = func.call @g_qrd_fixedPointMultiply(%tmp_49,%l_y__j__85_d1_2) : (i22,i22) -> i22
		// l_x__out__81_d1_1 aliased to tmp_47
		// Assignment Statement: End
		// Assignment Statement: Start
		// Evaluate global variable k_CORDIC_constant.
		%tmp_51 = arith.constant 318375 : i19
		%tmp_52 = arith.extui %tmp_51 : i19 to i22
		// Evaluate global variable k_CORDIC_constant done: assigned to tmp_52 above in this context.
		// Evaluate global variable fixedPointMultiply.
		%tmp_50 = func.call @g_qrd_fixedPointMultiply(%tmp_52,%l_x__j__82_d1_2) : (i22,i22) -> i22
		cal.set(%l_r__73: !cal.state_ref<i22>, %tmp_50: i22)
		// Assignment Statement: End
		// Assignment Statement: Start
		%tmp_53 = cal.get(%l_count__74: !cal.state_ref<i32>) : i32
		%tmp_54 = arith.constant 1 : i1
		%tmp_55 = arith.extui %tmp_54 : i1 to i32
		%tmp_56 = arith.addi %tmp_53, %tmp_55 : i32
		cal.set(%l_count__74: !cal.state_ref<i32>, %tmp_56: i32)
		// Assignment Statement: End
		// Output Expression: Start
		fifo.push(%x_out: !fifo.input_port<i22>, %tmp_47: i22)
		// Output Expression: End
		// Output Expression: Start
		fifo.push(%cordic_angles_out: !fifo.input_port<i16>, %l_rotation__angles__79_d1_0: i16)
		// Output Expression: End
	}
	// Generation action: final
	cal.action "final" priority=0 {
		// Guard: Start
		cal.predicate {
			%tmp_57 = cal.get(%l_count__74: !cal.state_ref<i32>) : i32
			// Evaluate global variable $eval1.
			%tmp_58 = arith.constant 2 : i2
			%tmp_59 = arith.extui %tmp_58 : i2 to i32
			// Evaluate global variable $eval1 done: assigned to tmp_59 above in this context.
			%tmp_60 = arith.cmpi eq, %tmp_57, %tmp_59 : i32
			cal.predicate_result %tmp_60 : i1
		}
		// Guard: End
		// Assignment Statement: Start
		%tmp_61 = arith.constant 0 : i1
		%tmp_62 = arith.extui %tmp_61 : i1 to i32
		cal.set(%l_count__74: !cal.state_ref<i32>, %tmp_62: i32)
		// Assignment Statement: End
		// Output Expression: Start
		%tmp_63 = cal.get(%l_r__73: !cal.state_ref<i22>) : i22
		fifo.push(%r_out: !fifo.input_port<i22>, %tmp_63: i22)
		// Output Expression: End
	}
}

//-- Definition of actor class: BoundaryCell
cal.actor @boundaryCells_1 ()
	ports_in(%x_in: !fifo.output_port<i22>)
	ports_out(%r_out: !fifo.input_port<i22>,%cordic_angles_out: !fifo.input_port<i16>)
{
	// -- Actor body
	%l_r__61 = cal.create_state_var<i22> : !cal.state_ref<i22>
	%tmp_0 = arith.constant 0 : i1
	%tmp_1 = arith.extui %tmp_0 : i1 to i22
	cal.set(%l_r__61: !cal.state_ref<i22>, %tmp_1: i22)
	%l_count__62 = cal.create_state_var<i32> : !cal.state_ref<i32>
	%tmp_2 = arith.constant 0 : i1
	%tmp_3 = arith.extui %tmp_2 : i1 to i32
	cal.set(%l_count__62: !cal.state_ref<i32>, %tmp_3: i32)
	// Generation action: normal
	cal.action "normal" priority=0 {
		// Guard: Start
		cal.predicate {
			%tmp_4 = cal.get(%l_count__62: !cal.state_ref<i32>) : i32
			// Evaluate global variable $eval1.
			%tmp_5 = arith.constant 2 : i2
			%tmp_6 = arith.extui %tmp_5 : i2 to i32
			// Evaluate global variable $eval1 done: assigned to tmp_6 above in this context.
			%tmp_7 = arith.cmpi ult, %tmp_4, %tmp_6 : i32
			cal.predicate_result %tmp_7 : i1
		}
		// Guard: End
		// Input Pattern: Start
		%l_x__in__64_d1_0 = fifo.pop(%x_in: !fifo.output_port<i22>) : i22
		// Input Pattern: End
		// Action Local Variable Decl: Start
		%l_x__j__67_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_x__j__plus__1__68_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_x__j__shifted__69_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_y__j__70_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_y__j__plus__1__71_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_y__j__shifted__72_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%tmp_8 = arith.constant 0 : i1
		%tmp_9 = arith.extui %tmp_8 : i1 to i16
		// l_rotation__angles__66_d1_0 aliased to tmp_9
		// Action Local Variable Decl: End
		// If Statement: Begin
		%tmp_10 = cal.get(%l_count__62: !cal.state_ref<i32>) : i32
		%tmp_11 = arith.constant 0 : i1
		%tmp_12 = arith.extui %tmp_11 : i1 to i32
		%tmp_13 = arith.cmpi eq, %tmp_10, %tmp_12 : i32
		scf.if %tmp_13 {
			// Assignment Statement: Start
			%tmp_14 = arith.constant 0 : i1
			%tmp_15 = arith.extui %tmp_14 : i1 to i22
			cal.set(%l_r__61: !cal.state_ref<i22>, %tmp_15: i22)
			// Assignment Statement: End
		} else {
		}
		// If Statement: End
		// Assignment Statement: Start
		// l_x__j__67_d1_1 aliased to l_x__in__64_d1_0
		// Assignment Statement: End
		// Assignment Statement: Start
		%tmp_16 = cal.get(%l_r__61: !cal.state_ref<i22>) : i22
		// l_y__j__70_d1_1 aliased to tmp_16
		// Assignment Statement: End
		// Foreach Statement: Begin
		%tmp_17 = arith.constant 0 : i1
		%tmp_18 = arith.extui %tmp_17 : i1 to i32
		%tmp_19_lb = index.casts %tmp_18 : i32 to index
		// Evaluate global variable num_CORDIC_iterations.
		%tmp_20 = arith.constant 16 : i5
		%tmp_21 = arith.extui %tmp_20 : i5 to i32
		// Evaluate global variable num_CORDIC_iterations done: assigned to tmp_21 above in this context.
		%tmp_22 = arith.constant 1 : i1
		%tmp_23 = arith.extui %tmp_22 : i1 to i32
		%tmp_24 = arith.subi %tmp_21, %tmp_23 : i32
		%tmp_25_ub = index.casts %tmp_24 : i32 to index
		%tmp_26_step = index.constant 1
		%tmp_27_ub_plus_1 = arith.addi %tmp_25_ub, %tmp_26_step : index
		%l_rotation__angles__66_d1_1, %l_x__j__67_d1_2, %l_x__j__plus__1__68_d1_1, %l_x__j__shifted__69_d1_1, %l_y__j__70_d1_2, %l_y__j__plus__1__71_d1_1, %l_y__j__shifted__72_d1_1 = scf.for %l_j_d1_0 = %tmp_19_lb to %tmp_27_ub_plus_1 step %tmp_26_step
				iter_args(%l_rotation__angles__66_d2_0 = %tmp_9, %l_x__j__67_d2_0 = %l_x__in__64_d1_0, %l_x__j__plus__1__68_d2_0 = %l_x__j__plus__1__68_d1_0, %l_x__j__shifted__69_d2_0 = %l_x__j__shifted__69_d1_0, %l_y__j__70_d2_0 = %tmp_16, %l_y__j__plus__1__71_d2_0 = %l_y__j__plus__1__71_d1_0, %l_y__j__shifted__72_d2_0 = %l_y__j__shifted__72_d1_0) -> (i16, i22, i22, i22, i22, i22, i22) {
			%l_j_d2_0 = arith.index_cast %l_j_d1_0 : index to i32
			%l_j_d2_1 = arith.trunci %l_j_d2_0 : i32 to i8
			// Assignment Statement: Start
			%tmp_28 = arith.extui %l_j_d2_1 : i8 to i22
			%tmp_29 = arith.shrsi %l_y__j__70_d2_0, %tmp_28 : i22
			// l_y__j__shifted__72_d2_1 aliased to tmp_29
			// Assignment Statement: End
			// Assignment Statement: Start
			%tmp_30 = arith.extui %l_j_d2_1 : i8 to i22
			%tmp_31 = arith.shrsi %l_x__j__67_d2_0, %tmp_30 : i22
			// l_x__j__shifted__69_d2_1 aliased to tmp_31
			// Assignment Statement: End
			// If Statement: Begin
			%tmp_32 = arith.constant 0 : i1
			%tmp_33 = arith.extui %tmp_32 : i1 to i22
			%tmp_34 = arith.cmpi sgt, %l_x__j__67_d2_0, %tmp_33 : i22
			%tmp_35 = arith.constant 0 : i1
			%tmp_36 = arith.extui %tmp_35 : i1 to i22
			%tmp_37 = arith.cmpi sgt, %l_y__j__70_d2_0, %tmp_36 : i22
			%tmp_38 = arith.andi %tmp_34, %tmp_37 : i1
			%tmp_39 = arith.constant 0 : i1
			%tmp_40 = arith.extui %tmp_39 : i1 to i22
			%tmp_41 = arith.cmpi slt, %l_x__j__67_d2_0, %tmp_40 : i22
			%tmp_42 = arith.constant 0 : i1
			%tmp_43 = arith.extui %tmp_42 : i1 to i22
			%tmp_44 = arith.cmpi slt, %l_y__j__70_d2_0, %tmp_43 : i22
			%tmp_45 = arith.andi %tmp_41, %tmp_44 : i1
			%tmp_46 = arith.ori %tmp_38, %tmp_45 : i1
			%l_rotation__angles__66_d2_1, %l_x__j__plus__1__68_d2_1, %l_y__j__plus__1__71_d2_1 = scf.if %tmp_46 -> (i16, i22, i22) {
				// Assignment Statement: Start
				%tmp_47 = arith.extsi %l_x__j__67_d2_0 : i22 to i23
				%tmp_48 = arith.extsi %tmp_29 : i22 to i23
				%tmp_49 = arith.addi %tmp_47, %tmp_48 : i23
				%tmp_50 = arith.trunci %tmp_49 : i23 to i22
				// l_x__j__plus__1__68_d3_0 aliased to tmp_50
				// Assignment Statement: End
				// Assignment Statement: Start
				%tmp_51 = arith.subi %l_y__j__70_d2_0, %tmp_31 : i22
				// l_y__j__plus__1__71_d3_0 aliased to tmp_51
				// Assignment Statement: End
				// Assignment Statement: Start
				%tmp_52 = arith.constant 1 : i1
				%tmp_53 = arith.extui %tmp_52 : i1 to i64
				%tmp_54 = arith.extui %l_j_d2_1 : i8 to i64
				%tmp_55 = arith.shli %tmp_53, %tmp_54 : i64
				%tmp_56 = arith.extui %l_rotation__angles__66_d2_0 : i16 to i64
				%tmp_57 = arith.ori %tmp_56, %tmp_55 : i64
				%tmp_58 = arith.trunci %tmp_57 : i64 to i16
				// l_rotation__angles__66_d3_0 aliased to tmp_58
				// Assignment Statement: End
				scf.yield %tmp_58, %tmp_50, %tmp_51 : i16, i22, i22
			} else {
				// Assignment Statement: Start
				%tmp_59 = arith.subi %l_x__j__67_d2_0, %tmp_29 : i22
				// l_x__j__plus__1__68_d3_0 aliased to tmp_59
				// Assignment Statement: End
				// Assignment Statement: Start
				%tmp_60 = arith.extsi %l_y__j__70_d2_0 : i22 to i23
				%tmp_61 = arith.extsi %tmp_31 : i22 to i23
				%tmp_62 = arith.addi %tmp_60, %tmp_61 : i23
				%tmp_63 = arith.trunci %tmp_62 : i23 to i22
				// l_y__j__plus__1__71_d3_0 aliased to tmp_63
				// Assignment Statement: End
				scf.yield %l_rotation__angles__66_d2_0, %tmp_59, %tmp_63 : i16, i22, i22
			}
			// If Statement: End
			// Assignment Statement: Start
			// l_x__j__67_d2_1 aliased to l_x__j__plus__1__68_d2_1
			// Assignment Statement: End
			// Assignment Statement: Start
			// l_y__j__70_d2_1 aliased to l_y__j__plus__1__71_d2_1
			// Assignment Statement: End
			scf.yield %l_rotation__angles__66_d2_1, %l_x__j__plus__1__68_d2_1, %l_x__j__plus__1__68_d2_1, %tmp_31, %l_y__j__plus__1__71_d2_1, %l_y__j__plus__1__71_d2_1, %tmp_29 : i16, i22, i22, i22, i22, i22, i22
		}
		// Foreach Statement: End
		// Assignment Statement: Start
		// Evaluate global variable k_CORDIC_constant.
		%tmp_65 = arith.constant 318375 : i19
		%tmp_66 = arith.extui %tmp_65 : i19 to i22
		// Evaluate global variable k_CORDIC_constant done: assigned to tmp_66 above in this context.
		// Evaluate global variable fixedPointMultiply.
		%tmp_64 = func.call @g_qrd_fixedPointMultiply(%l_x__j__67_d1_2,%tmp_66) : (i22,i22) -> i22
		cal.set(%l_r__61: !cal.state_ref<i22>, %tmp_64: i22)
		// Assignment Statement: End
		// Assignment Statement: Start
		%tmp_67 = cal.get(%l_count__62: !cal.state_ref<i32>) : i32
		%tmp_68 = arith.constant 1 : i1
		%tmp_69 = arith.extui %tmp_68 : i1 to i32
		%tmp_70 = arith.addi %tmp_67, %tmp_69 : i32
		cal.set(%l_count__62: !cal.state_ref<i32>, %tmp_70: i32)
		// Assignment Statement: End
		// Output Expression: Start
		fifo.push(%cordic_angles_out: !fifo.input_port<i16>, %l_rotation__angles__66_d1_1: i16)
		// Output Expression: End
	}
	// Generation action: final
	cal.action "final" priority=0 {
		// Guard: Start
		cal.predicate {
			%tmp_71 = cal.get(%l_count__62: !cal.state_ref<i32>) : i32
			// Evaluate global variable $eval1.
			%tmp_72 = arith.constant 2 : i2
			%tmp_73 = arith.extui %tmp_72 : i2 to i32
			// Evaluate global variable $eval1 done: assigned to tmp_73 above in this context.
			%tmp_74 = arith.cmpi eq, %tmp_71, %tmp_73 : i32
			cal.predicate_result %tmp_74 : i1
		}
		// Guard: End
		// Assignment Statement: Start
		%tmp_75 = arith.constant 0 : i1
		%tmp_76 = arith.extui %tmp_75 : i1 to i32
		cal.set(%l_count__62: !cal.state_ref<i32>, %tmp_76: i32)
		// Assignment Statement: End
		// Output Expression: Start
		%tmp_77 = cal.get(%l_r__61: !cal.state_ref<i22>) : i22
		fifo.push(%r_out: !fifo.input_port<i22>, %tmp_77: i22)
		// Output Expression: End
	}
}

//-- Definition of actor class: Cap_Iterations
cal.actor @caps_cordic_0 ()
	ports_in(%In: !fifo.output_port<i16>)
{
	// -- Actor body
	// Generation action: receive
	cal.action "receive" priority=0 {
		// Input Pattern: Start
		%l_t__23_d1_0 = fifo.pop(%In: !fifo.output_port<i16>) : i16
		// Input Pattern: End
	}
}

//-- Definition of actor class: InnerCell
cal.actor @innerCells_q_1 ()
	ports_in(%x_in: !fifo.output_port<i22>,%cordic_angles_in: !fifo.output_port<i16>)
	ports_out(%x_out: !fifo.input_port<i22>,%r_out: !fifo.input_port<i22>,%cordic_angles_out: !fifo.input_port<i16>)
{
	// -- Actor body
	%l_r__73 = cal.create_state_var<i22> : !cal.state_ref<i22>
	%tmp_0 = arith.constant 0 : i1
	%tmp_1 = arith.extui %tmp_0 : i1 to i22
	cal.set(%l_r__73: !cal.state_ref<i22>, %tmp_1: i22)
	%l_count__74 = cal.create_state_var<i32> : !cal.state_ref<i32>
	%tmp_2 = arith.constant 0 : i1
	%tmp_3 = arith.extui %tmp_2 : i1 to i32
	cal.set(%l_count__74: !cal.state_ref<i32>, %tmp_3: i32)
	// Generation action: normal
	cal.action "normal" priority=0 {
		// Guard: Start
		cal.predicate {
			%tmp_4 = cal.get(%l_count__74: !cal.state_ref<i32>) : i32
			// Evaluate global variable $eval1.
			%tmp_5 = arith.constant 2 : i2
			%tmp_6 = arith.extui %tmp_5 : i2 to i32
			// Evaluate global variable $eval1 done: assigned to tmp_6 above in this context.
			%tmp_7 = arith.cmpi ult, %tmp_4, %tmp_6 : i32
			cal.predicate_result %tmp_7 : i1
		}
		// Guard: End
		// Input Pattern: Start
		%l_x__in__76_d1_0 = fifo.pop(%x_in: !fifo.output_port<i22>) : i22
		// Input Pattern: End
		// Input Pattern: Start
		%l_rotation__angles__79_d1_0 = fifo.pop(%cordic_angles_in: !fifo.output_port<i16>) : i16
		// Input Pattern: End
		// Action Local Variable Decl: Start
		%l_x__out__81_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_x__j__82_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_x__j__plus__1__83_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_x__j__shifted__84_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_y__j__85_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_y__j__plus__1__86_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_y__j__shifted__87_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// If Statement: Begin
		%tmp_8 = cal.get(%l_count__74: !cal.state_ref<i32>) : i32
		%tmp_9 = arith.constant 0 : i1
		%tmp_10 = arith.extui %tmp_9 : i1 to i32
		%tmp_11 = arith.cmpi eq, %tmp_8, %tmp_10 : i32
		scf.if %tmp_11 {
			// Assignment Statement: Start
			%tmp_12 = arith.constant 0 : i1
			%tmp_13 = arith.extui %tmp_12 : i1 to i22
			cal.set(%l_r__73: !cal.state_ref<i22>, %tmp_13: i22)
			// Assignment Statement: End
		} else {
		}
		// If Statement: End
		// Assignment Statement: Start
		// l_x__j__82_d1_1 aliased to l_x__in__76_d1_0
		// Assignment Statement: End
		// Assignment Statement: Start
		%tmp_14 = cal.get(%l_r__73: !cal.state_ref<i22>) : i22
		// l_y__j__85_d1_1 aliased to tmp_14
		// Assignment Statement: End
		// Foreach Statement: Begin
		%tmp_15 = arith.constant 0 : i1
		%tmp_16 = arith.extui %tmp_15 : i1 to i32
		%tmp_17_lb = index.casts %tmp_16 : i32 to index
		// Evaluate global variable num_CORDIC_iterations.
		%tmp_18 = arith.constant 16 : i5
		%tmp_19 = arith.extui %tmp_18 : i5 to i32
		// Evaluate global variable num_CORDIC_iterations done: assigned to tmp_19 above in this context.
		%tmp_20 = arith.constant 1 : i1
		%tmp_21 = arith.extui %tmp_20 : i1 to i32
		%tmp_22 = arith.subi %tmp_19, %tmp_21 : i32
		%tmp_23_ub = index.casts %tmp_22 : i32 to index
		%tmp_24_step = index.constant 1
		%tmp_25_ub_plus_1 = arith.addi %tmp_23_ub, %tmp_24_step : index
		%l_x__j__82_d1_2, %l_x__j__plus__1__83_d1_1, %l_x__j__shifted__84_d1_1, %l_y__j__85_d1_2, %l_y__j__plus__1__86_d1_1, %l_y__j__shifted__87_d1_1 = scf.for %l_j_d1_0 = %tmp_17_lb to %tmp_25_ub_plus_1 step %tmp_24_step
				iter_args(%l_x__j__82_d2_0 = %l_x__in__76_d1_0, %l_x__j__plus__1__83_d2_0 = %l_x__j__plus__1__83_d1_0, %l_x__j__shifted__84_d2_0 = %l_x__j__shifted__84_d1_0, %l_y__j__85_d2_0 = %tmp_14, %l_y__j__plus__1__86_d2_0 = %l_y__j__plus__1__86_d1_0, %l_y__j__shifted__87_d2_0 = %l_y__j__shifted__87_d1_0) -> (i22, i22, i22, i22, i22, i22) {
			%l_j_d2_0 = arith.index_cast %l_j_d1_0 : index to i32
			%l_j_d2_1 = arith.trunci %l_j_d2_0 : i32 to i8
			// Assignment Statement: Start
			%tmp_26 = arith.extui %l_j_d2_1 : i8 to i22
			%tmp_27 = arith.shrsi %l_y__j__85_d2_0, %tmp_26 : i22
			// l_y__j__shifted__87_d2_1 aliased to tmp_27
			// Assignment Statement: End
			// Assignment Statement: Start
			%tmp_28 = arith.extui %l_j_d2_1 : i8 to i22
			%tmp_29 = arith.shrsi %l_x__j__82_d2_0, %tmp_28 : i22
			// l_x__j__shifted__84_d2_1 aliased to tmp_29
			// Assignment Statement: End
			// If Statement: Begin
			%tmp_30 = arith.extui %l_j_d2_1 : i8 to i16
			%tmp_31 = arith.shrui %l_rotation__angles__79_d1_0, %tmp_30 : i16
			%tmp_32 = arith.constant 1 : i1
			%tmp_33 = arith.trunci %tmp_31 : i16 to i1
			%tmp_34 = arith.andi %tmp_33, %tmp_32 : i1
			%tmp_35 = arith.constant 1 : i1
			%tmp_36 = arith.cmpi eq, %tmp_34, %tmp_35 : i1
			%l_x__j__plus__1__83_d2_1, %l_y__j__plus__1__86_d2_1 = scf.if %tmp_36 -> (i22, i22) {
				// Assignment Statement: Start
				%tmp_37 = arith.extsi %l_x__j__82_d2_0 : i22 to i23
				%tmp_38 = arith.extsi %tmp_27 : i22 to i23
				%tmp_39 = arith.addi %tmp_37, %tmp_38 : i23
				%tmp_40 = arith.trunci %tmp_39 : i23 to i22
				// l_x__j__plus__1__83_d3_0 aliased to tmp_40
				// Assignment Statement: End
				// Assignment Statement: Start
				%tmp_41 = arith.subi %l_y__j__85_d2_0, %tmp_29 : i22
				// l_y__j__plus__1__86_d3_0 aliased to tmp_41
				// Assignment Statement: End
				scf.yield %tmp_40, %tmp_41 : i22, i22
			} else {
				// Assignment Statement: Start
				%tmp_42 = arith.subi %l_x__j__82_d2_0, %tmp_27 : i22
				// l_x__j__plus__1__83_d3_0 aliased to tmp_42
				// Assignment Statement: End
				// Assignment Statement: Start
				%tmp_43 = arith.extsi %l_y__j__85_d2_0 : i22 to i23
				%tmp_44 = arith.extsi %tmp_29 : i22 to i23
				%tmp_45 = arith.addi %tmp_43, %tmp_44 : i23
				%tmp_46 = arith.trunci %tmp_45 : i23 to i22
				// l_y__j__plus__1__86_d3_0 aliased to tmp_46
				// Assignment Statement: End
				scf.yield %tmp_42, %tmp_46 : i22, i22
			}
			// If Statement: End
			// Assignment Statement: Start
			// l_x__j__82_d2_1 aliased to l_x__j__plus__1__83_d2_1
			// Assignment Statement: End
			// Assignment Statement: Start
			// l_y__j__85_d2_1 aliased to l_y__j__plus__1__86_d2_1
			// Assignment Statement: End
			scf.yield %l_x__j__plus__1__83_d2_1, %l_x__j__plus__1__83_d2_1, %tmp_29, %l_y__j__plus__1__86_d2_1, %l_y__j__plus__1__86_d2_1, %tmp_27 : i22, i22, i22, i22, i22, i22
		}
		// Foreach Statement: End
		// Assignment Statement: Start
		// Evaluate global variable k_CORDIC_constant.
		%tmp_48 = arith.constant 318375 : i19
		%tmp_49 = arith.extui %tmp_48 : i19 to i22
		// Evaluate global variable k_CORDIC_constant done: assigned to tmp_49 above in this context.
		// Evaluate global variable fixedPointMultiply.
		%tmp_47 = func.call @g_qrd_fixedPointMultiply(%tmp_49,%l_y__j__85_d1_2) : (i22,i22) -> i22
		// l_x__out__81_d1_1 aliased to tmp_47
		// Assignment Statement: End
		// Assignment Statement: Start
		// Evaluate global variable k_CORDIC_constant.
		%tmp_51 = arith.constant 318375 : i19
		%tmp_52 = arith.extui %tmp_51 : i19 to i22
		// Evaluate global variable k_CORDIC_constant done: assigned to tmp_52 above in this context.
		// Evaluate global variable fixedPointMultiply.
		%tmp_50 = func.call @g_qrd_fixedPointMultiply(%tmp_52,%l_x__j__82_d1_2) : (i22,i22) -> i22
		cal.set(%l_r__73: !cal.state_ref<i22>, %tmp_50: i22)
		// Assignment Statement: End
		// Assignment Statement: Start
		%tmp_53 = cal.get(%l_count__74: !cal.state_ref<i32>) : i32
		%tmp_54 = arith.constant 1 : i1
		%tmp_55 = arith.extui %tmp_54 : i1 to i32
		%tmp_56 = arith.addi %tmp_53, %tmp_55 : i32
		cal.set(%l_count__74: !cal.state_ref<i32>, %tmp_56: i32)
		// Assignment Statement: End
		// Output Expression: Start
		fifo.push(%x_out: !fifo.input_port<i22>, %tmp_47: i22)
		// Output Expression: End
		// Output Expression: Start
		fifo.push(%cordic_angles_out: !fifo.input_port<i16>, %l_rotation__angles__79_d1_0: i16)
		// Output Expression: End
	}
	// Generation action: final
	cal.action "final" priority=0 {
		// Guard: Start
		cal.predicate {
			%tmp_57 = cal.get(%l_count__74: !cal.state_ref<i32>) : i32
			// Evaluate global variable $eval1.
			%tmp_58 = arith.constant 2 : i2
			%tmp_59 = arith.extui %tmp_58 : i2 to i32
			// Evaluate global variable $eval1 done: assigned to tmp_59 above in this context.
			%tmp_60 = arith.cmpi eq, %tmp_57, %tmp_59 : i32
			cal.predicate_result %tmp_60 : i1
		}
		// Guard: End
		// Assignment Statement: Start
		%tmp_61 = arith.constant 0 : i1
		%tmp_62 = arith.extui %tmp_61 : i1 to i32
		cal.set(%l_count__74: !cal.state_ref<i32>, %tmp_62: i32)
		// Assignment Statement: End
		// Output Expression: Start
		%tmp_63 = cal.get(%l_r__73: !cal.state_ref<i22>) : i22
		fifo.push(%r_out: !fifo.input_port<i22>, %tmp_63: i22)
		// Output Expression: End
	}
}

//-- Definition of actor class: BoundaryCell
cal.actor @boundaryCells_0 ()
	ports_in(%x_in: !fifo.output_port<i22>)
	ports_out(%r_out: !fifo.input_port<i22>,%cordic_angles_out: !fifo.input_port<i16>)
{
	// -- Actor body
	%l_r__61 = cal.create_state_var<i22> : !cal.state_ref<i22>
	%tmp_0 = arith.constant 0 : i1
	%tmp_1 = arith.extui %tmp_0 : i1 to i22
	cal.set(%l_r__61: !cal.state_ref<i22>, %tmp_1: i22)
	%l_count__62 = cal.create_state_var<i32> : !cal.state_ref<i32>
	%tmp_2 = arith.constant 0 : i1
	%tmp_3 = arith.extui %tmp_2 : i1 to i32
	cal.set(%l_count__62: !cal.state_ref<i32>, %tmp_3: i32)
	// Generation action: normal
	cal.action "normal" priority=0 {
		// Guard: Start
		cal.predicate {
			%tmp_4 = cal.get(%l_count__62: !cal.state_ref<i32>) : i32
			// Evaluate global variable $eval1.
			%tmp_5 = arith.constant 2 : i2
			%tmp_6 = arith.extui %tmp_5 : i2 to i32
			// Evaluate global variable $eval1 done: assigned to tmp_6 above in this context.
			%tmp_7 = arith.cmpi ult, %tmp_4, %tmp_6 : i32
			cal.predicate_result %tmp_7 : i1
		}
		// Guard: End
		// Input Pattern: Start
		%l_x__in__64_d1_0 = fifo.pop(%x_in: !fifo.output_port<i22>) : i22
		// Input Pattern: End
		// Action Local Variable Decl: Start
		%l_x__j__67_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_x__j__plus__1__68_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_x__j__shifted__69_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_y__j__70_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_y__j__plus__1__71_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_y__j__shifted__72_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%tmp_8 = arith.constant 0 : i1
		%tmp_9 = arith.extui %tmp_8 : i1 to i16
		// l_rotation__angles__66_d1_0 aliased to tmp_9
		// Action Local Variable Decl: End
		// If Statement: Begin
		%tmp_10 = cal.get(%l_count__62: !cal.state_ref<i32>) : i32
		%tmp_11 = arith.constant 0 : i1
		%tmp_12 = arith.extui %tmp_11 : i1 to i32
		%tmp_13 = arith.cmpi eq, %tmp_10, %tmp_12 : i32
		scf.if %tmp_13 {
			// Assignment Statement: Start
			%tmp_14 = arith.constant 0 : i1
			%tmp_15 = arith.extui %tmp_14 : i1 to i22
			cal.set(%l_r__61: !cal.state_ref<i22>, %tmp_15: i22)
			// Assignment Statement: End
		} else {
		}
		// If Statement: End
		// Assignment Statement: Start
		// l_x__j__67_d1_1 aliased to l_x__in__64_d1_0
		// Assignment Statement: End
		// Assignment Statement: Start
		%tmp_16 = cal.get(%l_r__61: !cal.state_ref<i22>) : i22
		// l_y__j__70_d1_1 aliased to tmp_16
		// Assignment Statement: End
		// Foreach Statement: Begin
		%tmp_17 = arith.constant 0 : i1
		%tmp_18 = arith.extui %tmp_17 : i1 to i32
		%tmp_19_lb = index.casts %tmp_18 : i32 to index
		// Evaluate global variable num_CORDIC_iterations.
		%tmp_20 = arith.constant 16 : i5
		%tmp_21 = arith.extui %tmp_20 : i5 to i32
		// Evaluate global variable num_CORDIC_iterations done: assigned to tmp_21 above in this context.
		%tmp_22 = arith.constant 1 : i1
		%tmp_23 = arith.extui %tmp_22 : i1 to i32
		%tmp_24 = arith.subi %tmp_21, %tmp_23 : i32
		%tmp_25_ub = index.casts %tmp_24 : i32 to index
		%tmp_26_step = index.constant 1
		%tmp_27_ub_plus_1 = arith.addi %tmp_25_ub, %tmp_26_step : index
		%l_rotation__angles__66_d1_1, %l_x__j__67_d1_2, %l_x__j__plus__1__68_d1_1, %l_x__j__shifted__69_d1_1, %l_y__j__70_d1_2, %l_y__j__plus__1__71_d1_1, %l_y__j__shifted__72_d1_1 = scf.for %l_j_d1_0 = %tmp_19_lb to %tmp_27_ub_plus_1 step %tmp_26_step
				iter_args(%l_rotation__angles__66_d2_0 = %tmp_9, %l_x__j__67_d2_0 = %l_x__in__64_d1_0, %l_x__j__plus__1__68_d2_0 = %l_x__j__plus__1__68_d1_0, %l_x__j__shifted__69_d2_0 = %l_x__j__shifted__69_d1_0, %l_y__j__70_d2_0 = %tmp_16, %l_y__j__plus__1__71_d2_0 = %l_y__j__plus__1__71_d1_0, %l_y__j__shifted__72_d2_0 = %l_y__j__shifted__72_d1_0) -> (i16, i22, i22, i22, i22, i22, i22) {
			%l_j_d2_0 = arith.index_cast %l_j_d1_0 : index to i32
			%l_j_d2_1 = arith.trunci %l_j_d2_0 : i32 to i8
			// Assignment Statement: Start
			%tmp_28 = arith.extui %l_j_d2_1 : i8 to i22
			%tmp_29 = arith.shrsi %l_y__j__70_d2_0, %tmp_28 : i22
			// l_y__j__shifted__72_d2_1 aliased to tmp_29
			// Assignment Statement: End
			// Assignment Statement: Start
			%tmp_30 = arith.extui %l_j_d2_1 : i8 to i22
			%tmp_31 = arith.shrsi %l_x__j__67_d2_0, %tmp_30 : i22
			// l_x__j__shifted__69_d2_1 aliased to tmp_31
			// Assignment Statement: End
			// If Statement: Begin
			%tmp_32 = arith.constant 0 : i1
			%tmp_33 = arith.extui %tmp_32 : i1 to i22
			%tmp_34 = arith.cmpi sgt, %l_x__j__67_d2_0, %tmp_33 : i22
			%tmp_35 = arith.constant 0 : i1
			%tmp_36 = arith.extui %tmp_35 : i1 to i22
			%tmp_37 = arith.cmpi sgt, %l_y__j__70_d2_0, %tmp_36 : i22
			%tmp_38 = arith.andi %tmp_34, %tmp_37 : i1
			%tmp_39 = arith.constant 0 : i1
			%tmp_40 = arith.extui %tmp_39 : i1 to i22
			%tmp_41 = arith.cmpi slt, %l_x__j__67_d2_0, %tmp_40 : i22
			%tmp_42 = arith.constant 0 : i1
			%tmp_43 = arith.extui %tmp_42 : i1 to i22
			%tmp_44 = arith.cmpi slt, %l_y__j__70_d2_0, %tmp_43 : i22
			%tmp_45 = arith.andi %tmp_41, %tmp_44 : i1
			%tmp_46 = arith.ori %tmp_38, %tmp_45 : i1
			%l_rotation__angles__66_d2_1, %l_x__j__plus__1__68_d2_1, %l_y__j__plus__1__71_d2_1 = scf.if %tmp_46 -> (i16, i22, i22) {
				// Assignment Statement: Start
				%tmp_47 = arith.extsi %l_x__j__67_d2_0 : i22 to i23
				%tmp_48 = arith.extsi %tmp_29 : i22 to i23
				%tmp_49 = arith.addi %tmp_47, %tmp_48 : i23
				%tmp_50 = arith.trunci %tmp_49 : i23 to i22
				// l_x__j__plus__1__68_d3_0 aliased to tmp_50
				// Assignment Statement: End
				// Assignment Statement: Start
				%tmp_51 = arith.subi %l_y__j__70_d2_0, %tmp_31 : i22
				// l_y__j__plus__1__71_d3_0 aliased to tmp_51
				// Assignment Statement: End
				// Assignment Statement: Start
				%tmp_52 = arith.constant 1 : i1
				%tmp_53 = arith.extui %tmp_52 : i1 to i64
				%tmp_54 = arith.extui %l_j_d2_1 : i8 to i64
				%tmp_55 = arith.shli %tmp_53, %tmp_54 : i64
				%tmp_56 = arith.extui %l_rotation__angles__66_d2_0 : i16 to i64
				%tmp_57 = arith.ori %tmp_56, %tmp_55 : i64
				%tmp_58 = arith.trunci %tmp_57 : i64 to i16
				// l_rotation__angles__66_d3_0 aliased to tmp_58
				// Assignment Statement: End
				scf.yield %tmp_58, %tmp_50, %tmp_51 : i16, i22, i22
			} else {
				// Assignment Statement: Start
				%tmp_59 = arith.subi %l_x__j__67_d2_0, %tmp_29 : i22
				// l_x__j__plus__1__68_d3_0 aliased to tmp_59
				// Assignment Statement: End
				// Assignment Statement: Start
				%tmp_60 = arith.extsi %l_y__j__70_d2_0 : i22 to i23
				%tmp_61 = arith.extsi %tmp_31 : i22 to i23
				%tmp_62 = arith.addi %tmp_60, %tmp_61 : i23
				%tmp_63 = arith.trunci %tmp_62 : i23 to i22
				// l_y__j__plus__1__71_d3_0 aliased to tmp_63
				// Assignment Statement: End
				scf.yield %l_rotation__angles__66_d2_0, %tmp_59, %tmp_63 : i16, i22, i22
			}
			// If Statement: End
			// Assignment Statement: Start
			// l_x__j__67_d2_1 aliased to l_x__j__plus__1__68_d2_1
			// Assignment Statement: End
			// Assignment Statement: Start
			// l_y__j__70_d2_1 aliased to l_y__j__plus__1__71_d2_1
			// Assignment Statement: End
			scf.yield %l_rotation__angles__66_d2_1, %l_x__j__plus__1__68_d2_1, %l_x__j__plus__1__68_d2_1, %tmp_31, %l_y__j__plus__1__71_d2_1, %l_y__j__plus__1__71_d2_1, %tmp_29 : i16, i22, i22, i22, i22, i22, i22
		}
		// Foreach Statement: End
		// Assignment Statement: Start
		// Evaluate global variable k_CORDIC_constant.
		%tmp_65 = arith.constant 318375 : i19
		%tmp_66 = arith.extui %tmp_65 : i19 to i22
		// Evaluate global variable k_CORDIC_constant done: assigned to tmp_66 above in this context.
		// Evaluate global variable fixedPointMultiply.
		%tmp_64 = func.call @g_qrd_fixedPointMultiply(%l_x__j__67_d1_2,%tmp_66) : (i22,i22) -> i22
		cal.set(%l_r__61: !cal.state_ref<i22>, %tmp_64: i22)
		// Assignment Statement: End
		// Assignment Statement: Start
		%tmp_67 = cal.get(%l_count__62: !cal.state_ref<i32>) : i32
		%tmp_68 = arith.constant 1 : i1
		%tmp_69 = arith.extui %tmp_68 : i1 to i32
		%tmp_70 = arith.addi %tmp_67, %tmp_69 : i32
		cal.set(%l_count__62: !cal.state_ref<i32>, %tmp_70: i32)
		// Assignment Statement: End
		// Output Expression: Start
		fifo.push(%cordic_angles_out: !fifo.input_port<i16>, %l_rotation__angles__66_d1_1: i16)
		// Output Expression: End
	}
	// Generation action: final
	cal.action "final" priority=0 {
		// Guard: Start
		cal.predicate {
			%tmp_71 = cal.get(%l_count__62: !cal.state_ref<i32>) : i32
			// Evaluate global variable $eval1.
			%tmp_72 = arith.constant 2 : i2
			%tmp_73 = arith.extui %tmp_72 : i2 to i32
			// Evaluate global variable $eval1 done: assigned to tmp_73 above in this context.
			%tmp_74 = arith.cmpi eq, %tmp_71, %tmp_73 : i32
			cal.predicate_result %tmp_74 : i1
		}
		// Guard: End
		// Assignment Statement: Start
		%tmp_75 = arith.constant 0 : i1
		%tmp_76 = arith.extui %tmp_75 : i1 to i32
		cal.set(%l_count__62: !cal.state_ref<i32>, %tmp_76: i32)
		// Assignment Statement: End
		// Output Expression: Start
		%tmp_77 = cal.get(%l_r__61: !cal.state_ref<i22>) : i22
		fifo.push(%r_out: !fifo.input_port<i22>, %tmp_77: i22)
		// Output Expression: End
	}
}

//-- Definition of actor class: InnerCell
cal.actor @innerCells_r_0 ()
	ports_in(%x_in: !fifo.output_port<i22>,%cordic_angles_in: !fifo.output_port<i16>)
	ports_out(%x_out: !fifo.input_port<i22>,%r_out: !fifo.input_port<i22>,%cordic_angles_out: !fifo.input_port<i16>)
{
	// -- Actor body
	%l_r__73 = cal.create_state_var<i22> : !cal.state_ref<i22>
	%tmp_0 = arith.constant 0 : i1
	%tmp_1 = arith.extui %tmp_0 : i1 to i22
	cal.set(%l_r__73: !cal.state_ref<i22>, %tmp_1: i22)
	%l_count__74 = cal.create_state_var<i32> : !cal.state_ref<i32>
	%tmp_2 = arith.constant 0 : i1
	%tmp_3 = arith.extui %tmp_2 : i1 to i32
	cal.set(%l_count__74: !cal.state_ref<i32>, %tmp_3: i32)
	// Generation action: normal
	cal.action "normal" priority=0 {
		// Guard: Start
		cal.predicate {
			%tmp_4 = cal.get(%l_count__74: !cal.state_ref<i32>) : i32
			// Evaluate global variable $eval1.
			%tmp_5 = arith.constant 2 : i2
			%tmp_6 = arith.extui %tmp_5 : i2 to i32
			// Evaluate global variable $eval1 done: assigned to tmp_6 above in this context.
			%tmp_7 = arith.cmpi ult, %tmp_4, %tmp_6 : i32
			cal.predicate_result %tmp_7 : i1
		}
		// Guard: End
		// Input Pattern: Start
		%l_x__in__76_d1_0 = fifo.pop(%x_in: !fifo.output_port<i22>) : i22
		// Input Pattern: End
		// Input Pattern: Start
		%l_rotation__angles__79_d1_0 = fifo.pop(%cordic_angles_in: !fifo.output_port<i16>) : i16
		// Input Pattern: End
		// Action Local Variable Decl: Start
		%l_x__out__81_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_x__j__82_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_x__j__plus__1__83_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_x__j__shifted__84_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_y__j__85_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_y__j__plus__1__86_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_y__j__shifted__87_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// If Statement: Begin
		%tmp_8 = cal.get(%l_count__74: !cal.state_ref<i32>) : i32
		%tmp_9 = arith.constant 0 : i1
		%tmp_10 = arith.extui %tmp_9 : i1 to i32
		%tmp_11 = arith.cmpi eq, %tmp_8, %tmp_10 : i32
		scf.if %tmp_11 {
			// Assignment Statement: Start
			%tmp_12 = arith.constant 0 : i1
			%tmp_13 = arith.extui %tmp_12 : i1 to i22
			cal.set(%l_r__73: !cal.state_ref<i22>, %tmp_13: i22)
			// Assignment Statement: End
		} else {
		}
		// If Statement: End
		// Assignment Statement: Start
		// l_x__j__82_d1_1 aliased to l_x__in__76_d1_0
		// Assignment Statement: End
		// Assignment Statement: Start
		%tmp_14 = cal.get(%l_r__73: !cal.state_ref<i22>) : i22
		// l_y__j__85_d1_1 aliased to tmp_14
		// Assignment Statement: End
		// Foreach Statement: Begin
		%tmp_15 = arith.constant 0 : i1
		%tmp_16 = arith.extui %tmp_15 : i1 to i32
		%tmp_17_lb = index.casts %tmp_16 : i32 to index
		// Evaluate global variable num_CORDIC_iterations.
		%tmp_18 = arith.constant 16 : i5
		%tmp_19 = arith.extui %tmp_18 : i5 to i32
		// Evaluate global variable num_CORDIC_iterations done: assigned to tmp_19 above in this context.
		%tmp_20 = arith.constant 1 : i1
		%tmp_21 = arith.extui %tmp_20 : i1 to i32
		%tmp_22 = arith.subi %tmp_19, %tmp_21 : i32
		%tmp_23_ub = index.casts %tmp_22 : i32 to index
		%tmp_24_step = index.constant 1
		%tmp_25_ub_plus_1 = arith.addi %tmp_23_ub, %tmp_24_step : index
		%l_x__j__82_d1_2, %l_x__j__plus__1__83_d1_1, %l_x__j__shifted__84_d1_1, %l_y__j__85_d1_2, %l_y__j__plus__1__86_d1_1, %l_y__j__shifted__87_d1_1 = scf.for %l_j_d1_0 = %tmp_17_lb to %tmp_25_ub_plus_1 step %tmp_24_step
				iter_args(%l_x__j__82_d2_0 = %l_x__in__76_d1_0, %l_x__j__plus__1__83_d2_0 = %l_x__j__plus__1__83_d1_0, %l_x__j__shifted__84_d2_0 = %l_x__j__shifted__84_d1_0, %l_y__j__85_d2_0 = %tmp_14, %l_y__j__plus__1__86_d2_0 = %l_y__j__plus__1__86_d1_0, %l_y__j__shifted__87_d2_0 = %l_y__j__shifted__87_d1_0) -> (i22, i22, i22, i22, i22, i22) {
			%l_j_d2_0 = arith.index_cast %l_j_d1_0 : index to i32
			%l_j_d2_1 = arith.trunci %l_j_d2_0 : i32 to i8
			// Assignment Statement: Start
			%tmp_26 = arith.extui %l_j_d2_1 : i8 to i22
			%tmp_27 = arith.shrsi %l_y__j__85_d2_0, %tmp_26 : i22
			// l_y__j__shifted__87_d2_1 aliased to tmp_27
			// Assignment Statement: End
			// Assignment Statement: Start
			%tmp_28 = arith.extui %l_j_d2_1 : i8 to i22
			%tmp_29 = arith.shrsi %l_x__j__82_d2_0, %tmp_28 : i22
			// l_x__j__shifted__84_d2_1 aliased to tmp_29
			// Assignment Statement: End
			// If Statement: Begin
			%tmp_30 = arith.extui %l_j_d2_1 : i8 to i16
			%tmp_31 = arith.shrui %l_rotation__angles__79_d1_0, %tmp_30 : i16
			%tmp_32 = arith.constant 1 : i1
			%tmp_33 = arith.trunci %tmp_31 : i16 to i1
			%tmp_34 = arith.andi %tmp_33, %tmp_32 : i1
			%tmp_35 = arith.constant 1 : i1
			%tmp_36 = arith.cmpi eq, %tmp_34, %tmp_35 : i1
			%l_x__j__plus__1__83_d2_1, %l_y__j__plus__1__86_d2_1 = scf.if %tmp_36 -> (i22, i22) {
				// Assignment Statement: Start
				%tmp_37 = arith.extsi %l_x__j__82_d2_0 : i22 to i23
				%tmp_38 = arith.extsi %tmp_27 : i22 to i23
				%tmp_39 = arith.addi %tmp_37, %tmp_38 : i23
				%tmp_40 = arith.trunci %tmp_39 : i23 to i22
				// l_x__j__plus__1__83_d3_0 aliased to tmp_40
				// Assignment Statement: End
				// Assignment Statement: Start
				%tmp_41 = arith.subi %l_y__j__85_d2_0, %tmp_29 : i22
				// l_y__j__plus__1__86_d3_0 aliased to tmp_41
				// Assignment Statement: End
				scf.yield %tmp_40, %tmp_41 : i22, i22
			} else {
				// Assignment Statement: Start
				%tmp_42 = arith.subi %l_x__j__82_d2_0, %tmp_27 : i22
				// l_x__j__plus__1__83_d3_0 aliased to tmp_42
				// Assignment Statement: End
				// Assignment Statement: Start
				%tmp_43 = arith.extsi %l_y__j__85_d2_0 : i22 to i23
				%tmp_44 = arith.extsi %tmp_29 : i22 to i23
				%tmp_45 = arith.addi %tmp_43, %tmp_44 : i23
				%tmp_46 = arith.trunci %tmp_45 : i23 to i22
				// l_y__j__plus__1__86_d3_0 aliased to tmp_46
				// Assignment Statement: End
				scf.yield %tmp_42, %tmp_46 : i22, i22
			}
			// If Statement: End
			// Assignment Statement: Start
			// l_x__j__82_d2_1 aliased to l_x__j__plus__1__83_d2_1
			// Assignment Statement: End
			// Assignment Statement: Start
			// l_y__j__85_d2_1 aliased to l_y__j__plus__1__86_d2_1
			// Assignment Statement: End
			scf.yield %l_x__j__plus__1__83_d2_1, %l_x__j__plus__1__83_d2_1, %tmp_29, %l_y__j__plus__1__86_d2_1, %l_y__j__plus__1__86_d2_1, %tmp_27 : i22, i22, i22, i22, i22, i22
		}
		// Foreach Statement: End
		// Assignment Statement: Start
		// Evaluate global variable k_CORDIC_constant.
		%tmp_48 = arith.constant 318375 : i19
		%tmp_49 = arith.extui %tmp_48 : i19 to i22
		// Evaluate global variable k_CORDIC_constant done: assigned to tmp_49 above in this context.
		// Evaluate global variable fixedPointMultiply.
		%tmp_47 = func.call @g_qrd_fixedPointMultiply(%tmp_49,%l_y__j__85_d1_2) : (i22,i22) -> i22
		// l_x__out__81_d1_1 aliased to tmp_47
		// Assignment Statement: End
		// Assignment Statement: Start
		// Evaluate global variable k_CORDIC_constant.
		%tmp_51 = arith.constant 318375 : i19
		%tmp_52 = arith.extui %tmp_51 : i19 to i22
		// Evaluate global variable k_CORDIC_constant done: assigned to tmp_52 above in this context.
		// Evaluate global variable fixedPointMultiply.
		%tmp_50 = func.call @g_qrd_fixedPointMultiply(%tmp_52,%l_x__j__82_d1_2) : (i22,i22) -> i22
		cal.set(%l_r__73: !cal.state_ref<i22>, %tmp_50: i22)
		// Assignment Statement: End
		// Assignment Statement: Start
		%tmp_53 = cal.get(%l_count__74: !cal.state_ref<i32>) : i32
		%tmp_54 = arith.constant 1 : i1
		%tmp_55 = arith.extui %tmp_54 : i1 to i32
		%tmp_56 = arith.addi %tmp_53, %tmp_55 : i32
		cal.set(%l_count__74: !cal.state_ref<i32>, %tmp_56: i32)
		// Assignment Statement: End
		// Output Expression: Start
		fifo.push(%x_out: !fifo.input_port<i22>, %tmp_47: i22)
		// Output Expression: End
		// Output Expression: Start
		fifo.push(%cordic_angles_out: !fifo.input_port<i16>, %l_rotation__angles__79_d1_0: i16)
		// Output Expression: End
	}
	// Generation action: final
	cal.action "final" priority=0 {
		// Guard: Start
		cal.predicate {
			%tmp_57 = cal.get(%l_count__74: !cal.state_ref<i32>) : i32
			// Evaluate global variable $eval1.
			%tmp_58 = arith.constant 2 : i2
			%tmp_59 = arith.extui %tmp_58 : i2 to i32
			// Evaluate global variable $eval1 done: assigned to tmp_59 above in this context.
			%tmp_60 = arith.cmpi eq, %tmp_57, %tmp_59 : i32
			cal.predicate_result %tmp_60 : i1
		}
		// Guard: End
		// Assignment Statement: Start
		%tmp_61 = arith.constant 0 : i1
		%tmp_62 = arith.extui %tmp_61 : i1 to i32
		cal.set(%l_count__74: !cal.state_ref<i32>, %tmp_62: i32)
		// Assignment Statement: End
		// Output Expression: Start
		%tmp_63 = cal.get(%l_r__73: !cal.state_ref<i22>) : i22
		fifo.push(%r_out: !fifo.input_port<i22>, %tmp_63: i22)
		// Output Expression: End
	}
}

//-- Definition of actor class: Source
cal.actor @source ()
	ports_out(%Out_array_0_x: !fifo.input_port<i22>,%Out_array_1_x: !fifo.input_port<i22>)
{
	// -- Actor body
	%l_row__index__28 = cal.create_state_var<i32> : !cal.state_ref<i32>
	%tmp_0 = arith.constant 0 : i1
	%tmp_1 = arith.extui %tmp_0 : i1 to i32
	cal.set(%l_row__index__28: !cal.state_ref<i32>, %tmp_1: i32)
	%l_matrix__number__29 = cal.create_state_var<i32> : !cal.state_ref<i32>
	%tmp_2 = arith.constant 0 : i1
	%tmp_3 = arith.extui %tmp_2 : i1 to i32
	cal.set(%l_matrix__number__29: !cal.state_ref<i32>, %tmp_3: i32)
	%l_next__30 = cal.create_state_var<i22> : !cal.state_ref<i22>
	// Evaluate global variable fp_increment.
	%tmp_4 = arith.constant 57671 : i16
	%tmp_5 = arith.extui %tmp_4 : i16 to i22
	// Evaluate global variable fp_increment done: assigned to tmp_5 above in this context.
	cal.set(%l_next__30: !cal.state_ref<i22>, %tmp_5: i22)
	// Generation action: transmit
	cal.action "transmit" priority=0 {
		// Guard: Start
		cal.predicate {
			%tmp_6 = cal.get(%l_matrix__number__29: !cal.state_ref<i32>) : i32
			// Evaluate global variable num_matrices.
			%tmp_7 = arith.constant 10000 : i14
			%tmp_8 = arith.extui %tmp_7 : i14 to i32
			// Evaluate global variable num_matrices done: assigned to tmp_8 above in this context.
			%tmp_9 = arith.cmpi slt, %tmp_6, %tmp_8 : i32
			cal.predicate_result %tmp_9 : i1
		}
		// Guard: End
		// Action Local Variable Decl: Start
		%l_output__31_d1_0 = memref.alloc() : memref<2xi32>
		// Action Local Variable Decl: End
		// Foreach Statement: Begin
		%tmp_10 = arith.constant 0 : i1
		%tmp_11 = arith.extui %tmp_10 : i1 to i32
		%tmp_12_lb = index.casts %tmp_11 : i32 to index
		// Evaluate global variable $eval1.
		%tmp_13 = arith.constant 2 : i2
		%tmp_14 = arith.extui %tmp_13 : i2 to i32
		// Evaluate global variable $eval1 done: assigned to tmp_14 above in this context.
		%tmp_15 = arith.constant 1 : i1
		%tmp_16 = arith.extui %tmp_15 : i1 to i32
		%tmp_17 = arith.subi %tmp_14, %tmp_16 : i32
		%tmp_18_ub = index.casts %tmp_17 : i32 to index
		%tmp_19_step = index.constant 1
		%tmp_20_ub_plus_1 = arith.addi %tmp_18_ub, %tmp_19_step : index
		scf.for %l_index_d1_0 = %tmp_12_lb to %tmp_20_ub_plus_1 step %tmp_19_step
				iter_args() -> () {
			%l_index_d2_0 = arith.index_cast %l_index_d1_0 : index to i32
			%l_index_d2_1 = arith.trunci %l_index_d2_0 : i32 to i8
			// Assignment Statement: Start
			%tmp_21 = arith.extui %l_index_d2_1 : i8 to i32
			%tmp_22 = arith.index_cast %tmp_21: i32 to index
			%tmp_23 = cal.get(%l_next__30: !cal.state_ref<i22>) : i22
			%tmp_24 = arith.extsi %tmp_23 : i22 to i32
			memref.store %tmp_24, %l_output__31_d1_0[%tmp_22] : memref<2xi32>
			// Assignment Statement: End
			// Assignment Statement: Start
			%tmp_25 = cal.get(%l_next__30: !cal.state_ref<i22>) : i22
			// Evaluate global variable fp_increment.
			%tmp_26 = arith.constant 57671 : i16
			%tmp_27 = arith.extui %tmp_26 : i16 to i22
			// Evaluate global variable fp_increment done: assigned to tmp_27 above in this context.
			%tmp_28 = arith.extsi %tmp_25 : i22 to i23
			%tmp_29 = arith.extsi %tmp_27 : i22 to i23
			%tmp_30 = arith.addi %tmp_28, %tmp_29 : i23
			%tmp_31 = arith.trunci %tmp_30 : i23 to i22
			cal.set(%l_next__30: !cal.state_ref<i22>, %tmp_31: i22)
			// Assignment Statement: End
			// If Statement: Begin
			%tmp_32 = cal.get(%l_next__30: !cal.state_ref<i22>) : i22
			// Evaluate global variable fixed_point_one.
			%tmp_33 = arith.constant 524288 : i20
			%tmp_34 = arith.extui %tmp_33 : i20 to i22
			// Evaluate global variable fixed_point_one done: assigned to tmp_34 above in this context.
			%tmp_35 = arith.cmpi sge, %tmp_32, %tmp_34 : i22
			scf.if %tmp_35 {
				// Assignment Statement: Start
				%tmp_36 = cal.get(%l_next__30: !cal.state_ref<i22>) : i22
				// Evaluate global variable fixed_point_one.
				%tmp_37 = arith.constant 524288 : i20
				%tmp_38 = arith.extui %tmp_37 : i20 to i22
				// Evaluate global variable fixed_point_one done: assigned to tmp_38 above in this context.
				%tmp_39 = arith.subi %tmp_36, %tmp_38 : i22
				// Evaluate global variable fixed_point_one.
				%tmp_40 = arith.constant 524288 : i20
				%tmp_41 = arith.extui %tmp_40 : i20 to i22
				// Evaluate global variable fixed_point_one done: assigned to tmp_41 above in this context.
				%tmp_42 = arith.subi %tmp_39, %tmp_41 : i22
				cal.set(%l_next__30: !cal.state_ref<i22>, %tmp_42: i22)
				// Assignment Statement: End
			} else {
			}
			// If Statement: End
		}
		// Foreach Statement: End
		// If Statement: Begin
		%tmp_43 = cal.get(%l_row__index__28: !cal.state_ref<i32>) : i32
		// Evaluate global variable $eval1.
		%tmp_44 = arith.constant 2 : i2
		%tmp_45 = arith.extui %tmp_44 : i2 to i32
		// Evaluate global variable $eval1 done: assigned to tmp_45 above in this context.
		%tmp_46 = arith.cmpi eq, %tmp_43, %tmp_45 : i32
		scf.if %tmp_46 {
			// Assignment Statement: Start
			%tmp_47 = arith.constant 0 : i1
			%tmp_48 = arith.extui %tmp_47 : i1 to i32
			cal.set(%l_row__index__28: !cal.state_ref<i32>, %tmp_48: i32)
			// Assignment Statement: End
			// Assignment Statement: Start
			// Evaluate global variable fp_increment.
			%tmp_49 = arith.constant 57671 : i16
			%tmp_50 = arith.extui %tmp_49 : i16 to i22
			// Evaluate global variable fp_increment done: assigned to tmp_50 above in this context.
			cal.set(%l_next__30: !cal.state_ref<i22>, %tmp_50: i22)
			// Assignment Statement: End
			// Assignment Statement: Start
			%tmp_51 = cal.get(%l_matrix__number__29: !cal.state_ref<i32>) : i32
			%tmp_52 = arith.constant 1 : i1
			%tmp_53 = arith.extui %tmp_52 : i1 to i32
			%tmp_54 = arith.addi %tmp_51, %tmp_53 : i32
			cal.set(%l_matrix__number__29: !cal.state_ref<i32>, %tmp_54: i32)
			// Assignment Statement: End
		} else {
		}
		// If Statement: End
		// Output Expression: Start
		%tmp_55 = arith.constant 0 : i1
		%tmp_56 = arith.extui %tmp_55 : i1 to i32
		%tmp_57 = arith.index_cast %tmp_56: i32 to index
		%tmp_59 = memref.load %l_output__31_d1_0[%tmp_57] : memref<2xi32>
		%tmp_58 = arith.trunci %tmp_59 : i32 to i22
		fifo.push(%Out_array_0_x: !fifo.input_port<i22>, %tmp_58: i22)
		// Output Expression: End
		// Output Expression: Start
		%tmp_60 = arith.constant 1 : i1
		%tmp_61 = arith.extui %tmp_60 : i1 to i32
		%tmp_62 = arith.index_cast %tmp_61: i32 to index
		%tmp_64 = memref.load %l_output__31_d1_0[%tmp_62] : memref<2xi32>
		%tmp_63 = arith.trunci %tmp_64 : i32 to i22
		fifo.push(%Out_array_1_x: !fifo.input_port<i22>, %tmp_63: i22)
		// Output Expression: End
	}
}

//-- Definition of actor class: Cap
cal.actor @caps_q_1 ()
	ports_in(%In: !fifo.output_port<i22>)
{
	// -- Actor body
	// Generation action: receive
	cal.action "receive" priority=0 {
		// Input Pattern: Start
		%l_t__26_d1_0 = fifo.pop(%In: !fifo.output_port<i22>) : i22
		// Input Pattern: End
	}
}

//-- Definition of actor class: Cap
cal.actor @caps_r_0 ()
	ports_in(%In: !fifo.output_port<i22>)
{
	// -- Actor body
	// Generation action: receive
	cal.action "receive" priority=0 {
		// Input Pattern: Start
		%l_t__26_d1_0 = fifo.pop(%In: !fifo.output_port<i22>) : i22
		// Input Pattern: End
	}
}

//-- Definition of actor class: Cap
cal.actor @caps_q_0 ()
	ports_in(%In: !fifo.output_port<i22>)
{
	// -- Actor body
	// Generation action: receive
	cal.action "receive" priority=0 {
		// Input Pattern: Start
		%l_t__26_d1_0 = fifo.pop(%In: !fifo.output_port<i22>) : i22
		// Input Pattern: End
	}
}

//-- Definition of actor class: InnerCell
cal.actor @innerCells_q_2 ()
	ports_in(%x_in: !fifo.output_port<i22>,%cordic_angles_in: !fifo.output_port<i16>)
	ports_out(%x_out: !fifo.input_port<i22>,%r_out: !fifo.input_port<i22>,%cordic_angles_out: !fifo.input_port<i16>)
{
	// -- Actor body
	%l_r__73 = cal.create_state_var<i22> : !cal.state_ref<i22>
	%tmp_0 = arith.constant 0 : i1
	%tmp_1 = arith.extui %tmp_0 : i1 to i22
	cal.set(%l_r__73: !cal.state_ref<i22>, %tmp_1: i22)
	%l_count__74 = cal.create_state_var<i32> : !cal.state_ref<i32>
	%tmp_2 = arith.constant 0 : i1
	%tmp_3 = arith.extui %tmp_2 : i1 to i32
	cal.set(%l_count__74: !cal.state_ref<i32>, %tmp_3: i32)
	// Generation action: normal
	cal.action "normal" priority=0 {
		// Guard: Start
		cal.predicate {
			%tmp_4 = cal.get(%l_count__74: !cal.state_ref<i32>) : i32
			// Evaluate global variable $eval1.
			%tmp_5 = arith.constant 2 : i2
			%tmp_6 = arith.extui %tmp_5 : i2 to i32
			// Evaluate global variable $eval1 done: assigned to tmp_6 above in this context.
			%tmp_7 = arith.cmpi ult, %tmp_4, %tmp_6 : i32
			cal.predicate_result %tmp_7 : i1
		}
		// Guard: End
		// Input Pattern: Start
		%l_x__in__76_d1_0 = fifo.pop(%x_in: !fifo.output_port<i22>) : i22
		// Input Pattern: End
		// Input Pattern: Start
		%l_rotation__angles__79_d1_0 = fifo.pop(%cordic_angles_in: !fifo.output_port<i16>) : i16
		// Input Pattern: End
		// Action Local Variable Decl: Start
		%l_x__out__81_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_x__j__82_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_x__j__plus__1__83_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_x__j__shifted__84_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_y__j__85_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_y__j__plus__1__86_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_y__j__shifted__87_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// If Statement: Begin
		%tmp_8 = cal.get(%l_count__74: !cal.state_ref<i32>) : i32
		%tmp_9 = arith.constant 0 : i1
		%tmp_10 = arith.extui %tmp_9 : i1 to i32
		%tmp_11 = arith.cmpi eq, %tmp_8, %tmp_10 : i32
		scf.if %tmp_11 {
			// Assignment Statement: Start
			%tmp_12 = arith.constant 0 : i1
			%tmp_13 = arith.extui %tmp_12 : i1 to i22
			cal.set(%l_r__73: !cal.state_ref<i22>, %tmp_13: i22)
			// Assignment Statement: End
		} else {
		}
		// If Statement: End
		// Assignment Statement: Start
		// l_x__j__82_d1_1 aliased to l_x__in__76_d1_0
		// Assignment Statement: End
		// Assignment Statement: Start
		%tmp_14 = cal.get(%l_r__73: !cal.state_ref<i22>) : i22
		// l_y__j__85_d1_1 aliased to tmp_14
		// Assignment Statement: End
		// Foreach Statement: Begin
		%tmp_15 = arith.constant 0 : i1
		%tmp_16 = arith.extui %tmp_15 : i1 to i32
		%tmp_17_lb = index.casts %tmp_16 : i32 to index
		// Evaluate global variable num_CORDIC_iterations.
		%tmp_18 = arith.constant 16 : i5
		%tmp_19 = arith.extui %tmp_18 : i5 to i32
		// Evaluate global variable num_CORDIC_iterations done: assigned to tmp_19 above in this context.
		%tmp_20 = arith.constant 1 : i1
		%tmp_21 = arith.extui %tmp_20 : i1 to i32
		%tmp_22 = arith.subi %tmp_19, %tmp_21 : i32
		%tmp_23_ub = index.casts %tmp_22 : i32 to index
		%tmp_24_step = index.constant 1
		%tmp_25_ub_plus_1 = arith.addi %tmp_23_ub, %tmp_24_step : index
		%l_x__j__82_d1_2, %l_x__j__plus__1__83_d1_1, %l_x__j__shifted__84_d1_1, %l_y__j__85_d1_2, %l_y__j__plus__1__86_d1_1, %l_y__j__shifted__87_d1_1 = scf.for %l_j_d1_0 = %tmp_17_lb to %tmp_25_ub_plus_1 step %tmp_24_step
				iter_args(%l_x__j__82_d2_0 = %l_x__in__76_d1_0, %l_x__j__plus__1__83_d2_0 = %l_x__j__plus__1__83_d1_0, %l_x__j__shifted__84_d2_0 = %l_x__j__shifted__84_d1_0, %l_y__j__85_d2_0 = %tmp_14, %l_y__j__plus__1__86_d2_0 = %l_y__j__plus__1__86_d1_0, %l_y__j__shifted__87_d2_0 = %l_y__j__shifted__87_d1_0) -> (i22, i22, i22, i22, i22, i22) {
			%l_j_d2_0 = arith.index_cast %l_j_d1_0 : index to i32
			%l_j_d2_1 = arith.trunci %l_j_d2_0 : i32 to i8
			// Assignment Statement: Start
			%tmp_26 = arith.extui %l_j_d2_1 : i8 to i22
			%tmp_27 = arith.shrsi %l_y__j__85_d2_0, %tmp_26 : i22
			// l_y__j__shifted__87_d2_1 aliased to tmp_27
			// Assignment Statement: End
			// Assignment Statement: Start
			%tmp_28 = arith.extui %l_j_d2_1 : i8 to i22
			%tmp_29 = arith.shrsi %l_x__j__82_d2_0, %tmp_28 : i22
			// l_x__j__shifted__84_d2_1 aliased to tmp_29
			// Assignment Statement: End
			// If Statement: Begin
			%tmp_30 = arith.extui %l_j_d2_1 : i8 to i16
			%tmp_31 = arith.shrui %l_rotation__angles__79_d1_0, %tmp_30 : i16
			%tmp_32 = arith.constant 1 : i1
			%tmp_33 = arith.trunci %tmp_31 : i16 to i1
			%tmp_34 = arith.andi %tmp_33, %tmp_32 : i1
			%tmp_35 = arith.constant 1 : i1
			%tmp_36 = arith.cmpi eq, %tmp_34, %tmp_35 : i1
			%l_x__j__plus__1__83_d2_1, %l_y__j__plus__1__86_d2_1 = scf.if %tmp_36 -> (i22, i22) {
				// Assignment Statement: Start
				%tmp_37 = arith.extsi %l_x__j__82_d2_0 : i22 to i23
				%tmp_38 = arith.extsi %tmp_27 : i22 to i23
				%tmp_39 = arith.addi %tmp_37, %tmp_38 : i23
				%tmp_40 = arith.trunci %tmp_39 : i23 to i22
				// l_x__j__plus__1__83_d3_0 aliased to tmp_40
				// Assignment Statement: End
				// Assignment Statement: Start
				%tmp_41 = arith.subi %l_y__j__85_d2_0, %tmp_29 : i22
				// l_y__j__plus__1__86_d3_0 aliased to tmp_41
				// Assignment Statement: End
				scf.yield %tmp_40, %tmp_41 : i22, i22
			} else {
				// Assignment Statement: Start
				%tmp_42 = arith.subi %l_x__j__82_d2_0, %tmp_27 : i22
				// l_x__j__plus__1__83_d3_0 aliased to tmp_42
				// Assignment Statement: End
				// Assignment Statement: Start
				%tmp_43 = arith.extsi %l_y__j__85_d2_0 : i22 to i23
				%tmp_44 = arith.extsi %tmp_29 : i22 to i23
				%tmp_45 = arith.addi %tmp_43, %tmp_44 : i23
				%tmp_46 = arith.trunci %tmp_45 : i23 to i22
				// l_y__j__plus__1__86_d3_0 aliased to tmp_46
				// Assignment Statement: End
				scf.yield %tmp_42, %tmp_46 : i22, i22
			}
			// If Statement: End
			// Assignment Statement: Start
			// l_x__j__82_d2_1 aliased to l_x__j__plus__1__83_d2_1
			// Assignment Statement: End
			// Assignment Statement: Start
			// l_y__j__85_d2_1 aliased to l_y__j__plus__1__86_d2_1
			// Assignment Statement: End
			scf.yield %l_x__j__plus__1__83_d2_1, %l_x__j__plus__1__83_d2_1, %tmp_29, %l_y__j__plus__1__86_d2_1, %l_y__j__plus__1__86_d2_1, %tmp_27 : i22, i22, i22, i22, i22, i22
		}
		// Foreach Statement: End
		// Assignment Statement: Start
		// Evaluate global variable k_CORDIC_constant.
		%tmp_48 = arith.constant 318375 : i19
		%tmp_49 = arith.extui %tmp_48 : i19 to i22
		// Evaluate global variable k_CORDIC_constant done: assigned to tmp_49 above in this context.
		// Evaluate global variable fixedPointMultiply.
		%tmp_47 = func.call @g_qrd_fixedPointMultiply(%tmp_49,%l_y__j__85_d1_2) : (i22,i22) -> i22
		// l_x__out__81_d1_1 aliased to tmp_47
		// Assignment Statement: End
		// Assignment Statement: Start
		// Evaluate global variable k_CORDIC_constant.
		%tmp_51 = arith.constant 318375 : i19
		%tmp_52 = arith.extui %tmp_51 : i19 to i22
		// Evaluate global variable k_CORDIC_constant done: assigned to tmp_52 above in this context.
		// Evaluate global variable fixedPointMultiply.
		%tmp_50 = func.call @g_qrd_fixedPointMultiply(%tmp_52,%l_x__j__82_d1_2) : (i22,i22) -> i22
		cal.set(%l_r__73: !cal.state_ref<i22>, %tmp_50: i22)
		// Assignment Statement: End
		// Assignment Statement: Start
		%tmp_53 = cal.get(%l_count__74: !cal.state_ref<i32>) : i32
		%tmp_54 = arith.constant 1 : i1
		%tmp_55 = arith.extui %tmp_54 : i1 to i32
		%tmp_56 = arith.addi %tmp_53, %tmp_55 : i32
		cal.set(%l_count__74: !cal.state_ref<i32>, %tmp_56: i32)
		// Assignment Statement: End
		// Output Expression: Start
		fifo.push(%x_out: !fifo.input_port<i22>, %tmp_47: i22)
		// Output Expression: End
		// Output Expression: Start
		fifo.push(%cordic_angles_out: !fifo.input_port<i16>, %l_rotation__angles__79_d1_0: i16)
		// Output Expression: End
	}
	// Generation action: final
	cal.action "final" priority=0 {
		// Guard: Start
		cal.predicate {
			%tmp_57 = cal.get(%l_count__74: !cal.state_ref<i32>) : i32
			// Evaluate global variable $eval1.
			%tmp_58 = arith.constant 2 : i2
			%tmp_59 = arith.extui %tmp_58 : i2 to i32
			// Evaluate global variable $eval1 done: assigned to tmp_59 above in this context.
			%tmp_60 = arith.cmpi eq, %tmp_57, %tmp_59 : i32
			cal.predicate_result %tmp_60 : i1
		}
		// Guard: End
		// Assignment Statement: Start
		%tmp_61 = arith.constant 0 : i1
		%tmp_62 = arith.extui %tmp_61 : i1 to i32
		cal.set(%l_count__74: !cal.state_ref<i32>, %tmp_62: i32)
		// Assignment Statement: End
		// Output Expression: Start
		%tmp_63 = cal.get(%l_r__73: !cal.state_ref<i22>) : i22
		fifo.push(%r_out: !fifo.input_port<i22>, %tmp_63: i22)
		// Output Expression: End
	}
}

//-- Definition of actor class: InnerCell
cal.actor @innerCells_q_3 ()
	ports_in(%x_in: !fifo.output_port<i22>,%cordic_angles_in: !fifo.output_port<i16>)
	ports_out(%x_out: !fifo.input_port<i22>,%r_out: !fifo.input_port<i22>,%cordic_angles_out: !fifo.input_port<i16>)
{
	// -- Actor body
	%l_r__73 = cal.create_state_var<i22> : !cal.state_ref<i22>
	%tmp_0 = arith.constant 0 : i1
	%tmp_1 = arith.extui %tmp_0 : i1 to i22
	cal.set(%l_r__73: !cal.state_ref<i22>, %tmp_1: i22)
	%l_count__74 = cal.create_state_var<i32> : !cal.state_ref<i32>
	%tmp_2 = arith.constant 0 : i1
	%tmp_3 = arith.extui %tmp_2 : i1 to i32
	cal.set(%l_count__74: !cal.state_ref<i32>, %tmp_3: i32)
	// Generation action: normal
	cal.action "normal" priority=0 {
		// Guard: Start
		cal.predicate {
			%tmp_4 = cal.get(%l_count__74: !cal.state_ref<i32>) : i32
			// Evaluate global variable $eval1.
			%tmp_5 = arith.constant 2 : i2
			%tmp_6 = arith.extui %tmp_5 : i2 to i32
			// Evaluate global variable $eval1 done: assigned to tmp_6 above in this context.
			%tmp_7 = arith.cmpi ult, %tmp_4, %tmp_6 : i32
			cal.predicate_result %tmp_7 : i1
		}
		// Guard: End
		// Input Pattern: Start
		%l_x__in__76_d1_0 = fifo.pop(%x_in: !fifo.output_port<i22>) : i22
		// Input Pattern: End
		// Input Pattern: Start
		%l_rotation__angles__79_d1_0 = fifo.pop(%cordic_angles_in: !fifo.output_port<i16>) : i16
		// Input Pattern: End
		// Action Local Variable Decl: Start
		%l_x__out__81_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_x__j__82_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_x__j__plus__1__83_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_x__j__shifted__84_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_y__j__85_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_y__j__plus__1__86_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_y__j__shifted__87_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// If Statement: Begin
		%tmp_8 = cal.get(%l_count__74: !cal.state_ref<i32>) : i32
		%tmp_9 = arith.constant 0 : i1
		%tmp_10 = arith.extui %tmp_9 : i1 to i32
		%tmp_11 = arith.cmpi eq, %tmp_8, %tmp_10 : i32
		scf.if %tmp_11 {
			// Assignment Statement: Start
			%tmp_12 = arith.constant 0 : i1
			%tmp_13 = arith.extui %tmp_12 : i1 to i22
			cal.set(%l_r__73: !cal.state_ref<i22>, %tmp_13: i22)
			// Assignment Statement: End
		} else {
		}
		// If Statement: End
		// Assignment Statement: Start
		// l_x__j__82_d1_1 aliased to l_x__in__76_d1_0
		// Assignment Statement: End
		// Assignment Statement: Start
		%tmp_14 = cal.get(%l_r__73: !cal.state_ref<i22>) : i22
		// l_y__j__85_d1_1 aliased to tmp_14
		// Assignment Statement: End
		// Foreach Statement: Begin
		%tmp_15 = arith.constant 0 : i1
		%tmp_16 = arith.extui %tmp_15 : i1 to i32
		%tmp_17_lb = index.casts %tmp_16 : i32 to index
		// Evaluate global variable num_CORDIC_iterations.
		%tmp_18 = arith.constant 16 : i5
		%tmp_19 = arith.extui %tmp_18 : i5 to i32
		// Evaluate global variable num_CORDIC_iterations done: assigned to tmp_19 above in this context.
		%tmp_20 = arith.constant 1 : i1
		%tmp_21 = arith.extui %tmp_20 : i1 to i32
		%tmp_22 = arith.subi %tmp_19, %tmp_21 : i32
		%tmp_23_ub = index.casts %tmp_22 : i32 to index
		%tmp_24_step = index.constant 1
		%tmp_25_ub_plus_1 = arith.addi %tmp_23_ub, %tmp_24_step : index
		%l_x__j__82_d1_2, %l_x__j__plus__1__83_d1_1, %l_x__j__shifted__84_d1_1, %l_y__j__85_d1_2, %l_y__j__plus__1__86_d1_1, %l_y__j__shifted__87_d1_1 = scf.for %l_j_d1_0 = %tmp_17_lb to %tmp_25_ub_plus_1 step %tmp_24_step
				iter_args(%l_x__j__82_d2_0 = %l_x__in__76_d1_0, %l_x__j__plus__1__83_d2_0 = %l_x__j__plus__1__83_d1_0, %l_x__j__shifted__84_d2_0 = %l_x__j__shifted__84_d1_0, %l_y__j__85_d2_0 = %tmp_14, %l_y__j__plus__1__86_d2_0 = %l_y__j__plus__1__86_d1_0, %l_y__j__shifted__87_d2_0 = %l_y__j__shifted__87_d1_0) -> (i22, i22, i22, i22, i22, i22) {
			%l_j_d2_0 = arith.index_cast %l_j_d1_0 : index to i32
			%l_j_d2_1 = arith.trunci %l_j_d2_0 : i32 to i8
			// Assignment Statement: Start
			%tmp_26 = arith.extui %l_j_d2_1 : i8 to i22
			%tmp_27 = arith.shrsi %l_y__j__85_d2_0, %tmp_26 : i22
			// l_y__j__shifted__87_d2_1 aliased to tmp_27
			// Assignment Statement: End
			// Assignment Statement: Start
			%tmp_28 = arith.extui %l_j_d2_1 : i8 to i22
			%tmp_29 = arith.shrsi %l_x__j__82_d2_0, %tmp_28 : i22
			// l_x__j__shifted__84_d2_1 aliased to tmp_29
			// Assignment Statement: End
			// If Statement: Begin
			%tmp_30 = arith.extui %l_j_d2_1 : i8 to i16
			%tmp_31 = arith.shrui %l_rotation__angles__79_d1_0, %tmp_30 : i16
			%tmp_32 = arith.constant 1 : i1
			%tmp_33 = arith.trunci %tmp_31 : i16 to i1
			%tmp_34 = arith.andi %tmp_33, %tmp_32 : i1
			%tmp_35 = arith.constant 1 : i1
			%tmp_36 = arith.cmpi eq, %tmp_34, %tmp_35 : i1
			%l_x__j__plus__1__83_d2_1, %l_y__j__plus__1__86_d2_1 = scf.if %tmp_36 -> (i22, i22) {
				// Assignment Statement: Start
				%tmp_37 = arith.extsi %l_x__j__82_d2_0 : i22 to i23
				%tmp_38 = arith.extsi %tmp_27 : i22 to i23
				%tmp_39 = arith.addi %tmp_37, %tmp_38 : i23
				%tmp_40 = arith.trunci %tmp_39 : i23 to i22
				// l_x__j__plus__1__83_d3_0 aliased to tmp_40
				// Assignment Statement: End
				// Assignment Statement: Start
				%tmp_41 = arith.subi %l_y__j__85_d2_0, %tmp_29 : i22
				// l_y__j__plus__1__86_d3_0 aliased to tmp_41
				// Assignment Statement: End
				scf.yield %tmp_40, %tmp_41 : i22, i22
			} else {
				// Assignment Statement: Start
				%tmp_42 = arith.subi %l_x__j__82_d2_0, %tmp_27 : i22
				// l_x__j__plus__1__83_d3_0 aliased to tmp_42
				// Assignment Statement: End
				// Assignment Statement: Start
				%tmp_43 = arith.extsi %l_y__j__85_d2_0 : i22 to i23
				%tmp_44 = arith.extsi %tmp_29 : i22 to i23
				%tmp_45 = arith.addi %tmp_43, %tmp_44 : i23
				%tmp_46 = arith.trunci %tmp_45 : i23 to i22
				// l_y__j__plus__1__86_d3_0 aliased to tmp_46
				// Assignment Statement: End
				scf.yield %tmp_42, %tmp_46 : i22, i22
			}
			// If Statement: End
			// Assignment Statement: Start
			// l_x__j__82_d2_1 aliased to l_x__j__plus__1__83_d2_1
			// Assignment Statement: End
			// Assignment Statement: Start
			// l_y__j__85_d2_1 aliased to l_y__j__plus__1__86_d2_1
			// Assignment Statement: End
			scf.yield %l_x__j__plus__1__83_d2_1, %l_x__j__plus__1__83_d2_1, %tmp_29, %l_y__j__plus__1__86_d2_1, %l_y__j__plus__1__86_d2_1, %tmp_27 : i22, i22, i22, i22, i22, i22
		}
		// Foreach Statement: End
		// Assignment Statement: Start
		// Evaluate global variable k_CORDIC_constant.
		%tmp_48 = arith.constant 318375 : i19
		%tmp_49 = arith.extui %tmp_48 : i19 to i22
		// Evaluate global variable k_CORDIC_constant done: assigned to tmp_49 above in this context.
		// Evaluate global variable fixedPointMultiply.
		%tmp_47 = func.call @g_qrd_fixedPointMultiply(%tmp_49,%l_y__j__85_d1_2) : (i22,i22) -> i22
		// l_x__out__81_d1_1 aliased to tmp_47
		// Assignment Statement: End
		// Assignment Statement: Start
		// Evaluate global variable k_CORDIC_constant.
		%tmp_51 = arith.constant 318375 : i19
		%tmp_52 = arith.extui %tmp_51 : i19 to i22
		// Evaluate global variable k_CORDIC_constant done: assigned to tmp_52 above in this context.
		// Evaluate global variable fixedPointMultiply.
		%tmp_50 = func.call @g_qrd_fixedPointMultiply(%tmp_52,%l_x__j__82_d1_2) : (i22,i22) -> i22
		cal.set(%l_r__73: !cal.state_ref<i22>, %tmp_50: i22)
		// Assignment Statement: End
		// Assignment Statement: Start
		%tmp_53 = cal.get(%l_count__74: !cal.state_ref<i32>) : i32
		%tmp_54 = arith.constant 1 : i1
		%tmp_55 = arith.extui %tmp_54 : i1 to i32
		%tmp_56 = arith.addi %tmp_53, %tmp_55 : i32
		cal.set(%l_count__74: !cal.state_ref<i32>, %tmp_56: i32)
		// Assignment Statement: End
		// Output Expression: Start
		fifo.push(%x_out: !fifo.input_port<i22>, %tmp_47: i22)
		// Output Expression: End
		// Output Expression: Start
		fifo.push(%cordic_angles_out: !fifo.input_port<i16>, %l_rotation__angles__79_d1_0: i16)
		// Output Expression: End
	}
	// Generation action: final
	cal.action "final" priority=0 {
		// Guard: Start
		cal.predicate {
			%tmp_57 = cal.get(%l_count__74: !cal.state_ref<i32>) : i32
			// Evaluate global variable $eval1.
			%tmp_58 = arith.constant 2 : i2
			%tmp_59 = arith.extui %tmp_58 : i2 to i32
			// Evaluate global variable $eval1 done: assigned to tmp_59 above in this context.
			%tmp_60 = arith.cmpi eq, %tmp_57, %tmp_59 : i32
			cal.predicate_result %tmp_60 : i1
		}
		// Guard: End
		// Assignment Statement: Start
		%tmp_61 = arith.constant 0 : i1
		%tmp_62 = arith.extui %tmp_61 : i1 to i32
		cal.set(%l_count__74: !cal.state_ref<i32>, %tmp_62: i32)
		// Assignment Statement: End
		// Output Expression: Start
		%tmp_63 = cal.get(%l_r__73: !cal.state_ref<i22>) : i22
		fifo.push(%r_out: !fifo.input_port<i22>, %tmp_63: i22)
		// Output Expression: End
	}
}

//-- Definition of actor class: Cap
cal.actor @caps_r_1 ()
	ports_in(%In: !fifo.output_port<i22>)
{
	// -- Actor body
	// Generation action: receive
	cal.action "receive" priority=0 {
		// Input Pattern: Start
		%l_t__26_d1_0 = fifo.pop(%In: !fifo.output_port<i22>) : i22
		// Input Pattern: End
	}
}

//-- Definition of actor class: JoinerRowQ
cal.actor @joinersPerRow_q_1 ()
	ports_in(%r_in_array_0_x: !fifo.output_port<i22>,%r_in_array_1_x: !fifo.output_port<i22>)
	ports_out(%q_out: !fifo.input_port<i22>)
{
	// -- Actor body
	%l_matrix__number__53 = cal.create_state_var<i32> : !cal.state_ref<i32>
	%tmp_0 = arith.constant 0 : i1
	%tmp_1 = arith.extui %tmp_0 : i1 to i32
	cal.set(%l_matrix__number__53: !cal.state_ref<i32>, %tmp_1: i32)
	// Generation action: $untagged0
	cal.action "$untagged0" priority=0 {
		// Input Pattern: Start
		%l_____input0______55_d1_0 = fifo.pop(%r_in_array_0_x: !fifo.output_port<i22>) : i22
		// Input Pattern: End
		// Input Pattern: Start
		%l_____input1______58_d1_0 = fifo.pop(%r_in_array_1_x: !fifo.output_port<i22>) : i22
		// Input Pattern: End
		// Action Local Variable Decl: Start
		%tmp_2 = memref.alloc() : memref<2xi32>
		%tmp_3 = arith.constant 0: index
		%tmp_4 = arith.extsi %l_____input0______55_d1_0 : i22 to i32
		memref.store %tmp_4, %tmp_2[%tmp_3] : memref<2xi32>
		%tmp_5 = arith.constant 1: index
		%tmp_6 = arith.extsi %l_____input1______58_d1_0 : i22 to i32
		memref.store %tmp_6, %tmp_2[%tmp_5] : memref<2xi32>
		// l_input__60_d1_0 aliased to tmp_2
		// Action Local Variable Decl: End
		// If Statement: Begin
		%tmp_7 = cal.get(%l_matrix__number__53: !cal.state_ref<i32>) : i32
		// Evaluate global variable num_matrices.
		%tmp_8 = arith.constant 10000 : i14
		%tmp_9 = arith.extui %tmp_8 : i14 to i32
		// Evaluate global variable num_matrices done: assigned to tmp_9 above in this context.
		%tmp_10 = arith.constant 10 : i4
		%tmp_11 = arith.extui %tmp_10 : i4 to i32
		%tmp_12 = arith.subi %tmp_9, %tmp_11 : i32
		%tmp_13 = arith.cmpi eq, %tmp_7, %tmp_12 : i32
		scf.if %tmp_13 {
			// Call Statement: Start
			%tmp_14 = cal.get(%l_matrix__number__53: !cal.state_ref<i32>) : i32
			fifo.print("Q%u: row 1: \00", %tmp_14) : (i32)
			// Call Statement: End
			// Foreach Statement: Begin
			%tmp_15 = arith.constant 0 : i1
			%tmp_16 = arith.extui %tmp_15 : i1 to i32
			%tmp_17_lb = index.casts %tmp_16 : i32 to index
			// Evaluate global variable $eval1.
			%tmp_18 = arith.constant 2 : i2
			%tmp_19 = arith.extui %tmp_18 : i2 to i32
			// Evaluate global variable $eval1 done: assigned to tmp_19 above in this context.
			%tmp_20 = arith.constant 1 : i1
			%tmp_21 = arith.extui %tmp_20 : i1 to i32
			%tmp_22 = arith.subi %tmp_19, %tmp_21 : i32
			%tmp_23_ub = index.casts %tmp_22 : i32 to index
			%tmp_24_step = index.constant 1
			%tmp_25_ub_plus_1 = arith.addi %tmp_23_ub, %tmp_24_step : index
			scf.for %l_index_d2_0 = %tmp_17_lb to %tmp_25_ub_plus_1 step %tmp_24_step
					iter_args() -> () {
				%l_index_d3_0 = arith.index_cast %l_index_d2_0 : index to i32
				%l_index_d3_1 = arith.trunci %l_index_d3_0 : i32 to i8
				// Call Statement: Start
				%tmp_26 = arith.extui %l_index_d3_1 : i8 to i32
				%tmp_27 = arith.index_cast %tmp_26: i32 to index
				%tmp_29 = memref.load %tmp_2[%tmp_27] : memref<2xi32>
				%tmp_28 = arith.trunci %tmp_29 : i32 to i22
				%tmp_30 = arith.extsi %tmp_28 : i22 to i32
				fifo.print("%i \00", %tmp_30) : (i32)
				// Call Statement: End
			}
			// Foreach Statement: End
			// Call Statement: Start
			fifo.print("\n\00")
			// Call Statement: End
		} else {
		}
		// If Statement: End
		// Assignment Statement: Start
		%tmp_31 = cal.get(%l_matrix__number__53: !cal.state_ref<i32>) : i32
		%tmp_32 = arith.constant 1 : i1
		%tmp_33 = arith.extui %tmp_32 : i1 to i32
		%tmp_34 = arith.addi %tmp_31, %tmp_33 : i32
		cal.set(%l_matrix__number__53: !cal.state_ref<i32>, %tmp_34: i32)
		// Assignment Statement: End
		// Output Expression: Start
		%tmp_35 = arith.constant 0 : index
		%tmp_36 = memref.load %tmp_2[%tmp_35] : memref<2xi32>
		%tmp_37 = arith.trunci %tmp_36 : i32 to i22
		fifo.push(%q_out: !fifo.input_port<i22>, %tmp_37: i22)
		%tmp_38 = arith.constant 1 : index
		%tmp_39 = memref.load %tmp_2[%tmp_38] : memref<2xi32>
		%tmp_40 = arith.trunci %tmp_39 : i32 to i22
		fifo.push(%q_out: !fifo.input_port<i22>, %tmp_40: i22)
		// Output Expression: End
	}
}

//-- Definition of actor class: JoinerRowR
cal.actor @joinersPerRow_r_0 ()
	ports_in(%r_in_array_0_x: !fifo.output_port<i22>,%r_in_array_1_x: !fifo.output_port<i22>)
	ports_out(%r_out: !fifo.input_port<i22>)
{
	// -- Actor body
	%l_matrix__number__32 = cal.create_state_var<i32> : !cal.state_ref<i32>
	%tmp_0 = arith.constant 0 : i1
	%tmp_1 = arith.extui %tmp_0 : i1 to i32
	cal.set(%l_matrix__number__32: !cal.state_ref<i32>, %tmp_1: i32)
	// Generation action: $untagged0
	cal.action "$untagged0" priority=0 {
		// Input Pattern: Start
		%l_____input0______34_d1_0 = fifo.pop(%r_in_array_0_x: !fifo.output_port<i22>) : i22
		// Input Pattern: End
		// Input Pattern: Start
		%l_____input1______37_d1_0 = fifo.pop(%r_in_array_1_x: !fifo.output_port<i22>) : i22
		// Input Pattern: End
		// Action Local Variable Decl: Start
		%tmp_2 = memref.alloc() : memref<2xi32>
		%tmp_3 = arith.constant 0: index
		%tmp_4 = arith.extsi %l_____input0______34_d1_0 : i22 to i32
		memref.store %tmp_4, %tmp_2[%tmp_3] : memref<2xi32>
		%tmp_5 = arith.constant 1: index
		%tmp_6 = arith.extsi %l_____input1______37_d1_0 : i22 to i32
		memref.store %tmp_6, %tmp_2[%tmp_5] : memref<2xi32>
		// l_input__39_d1_0 aliased to tmp_2
		// Action Local Variable Decl: End
		// If Statement: Begin
		%tmp_7 = cal.get(%l_matrix__number__32: !cal.state_ref<i32>) : i32
		// Evaluate global variable num_matrices.
		%tmp_8 = arith.constant 10000 : i14
		%tmp_9 = arith.extui %tmp_8 : i14 to i32
		// Evaluate global variable num_matrices done: assigned to tmp_9 above in this context.
		%tmp_10 = arith.constant 10 : i4
		%tmp_11 = arith.extui %tmp_10 : i4 to i32
		%tmp_12 = arith.subi %tmp_9, %tmp_11 : i32
		%tmp_13 = arith.cmpi eq, %tmp_7, %tmp_12 : i32
		scf.if %tmp_13 {
			// Call Statement: Start
			%tmp_14 = cal.get(%l_matrix__number__32: !cal.state_ref<i32>) : i32
			fifo.print("R%u: row 0: \00", %tmp_14) : (i32)
			// Call Statement: End
			// If Statement: Begin
			// Evaluate global variable $eval3.
			%tmp_15 = arith.constant 0 : i1
			%tmp_16 = arith.extui %tmp_15 : i1 to i32
			// Evaluate global variable $eval3 done: assigned to tmp_16 above in this context.
			%tmp_17 = arith.constant 0 : i1
			%tmp_18 = arith.extui %tmp_17 : i1 to i32
			%tmp_19 = arith.cmpi ne, %tmp_16, %tmp_18 : i32
			scf.if %tmp_19 {
				// Foreach Statement: Begin
				%tmp_20 = arith.constant 0 : i1
				%tmp_21 = arith.extui %tmp_20 : i1 to i32
				%tmp_22_lb = index.casts %tmp_21 : i32 to index
				// Evaluate global variable $eval1.
				%tmp_23 = arith.constant 2 : i2
				%tmp_24 = arith.extui %tmp_23 : i2 to i32
				// Evaluate global variable $eval1 done: assigned to tmp_24 above in this context.
				// Evaluate global variable $eval1.
				%tmp_25 = arith.constant 2 : i2
				%tmp_26 = arith.extui %tmp_25 : i2 to i32
				// Evaluate global variable $eval1 done: assigned to tmp_26 above in this context.
				%tmp_27 = arith.subi %tmp_24, %tmp_26 : i32
				%tmp_28 = arith.constant 1 : i1
				%tmp_29 = arith.extui %tmp_28 : i1 to i32
				%tmp_30 = arith.subi %tmp_27, %tmp_29 : i32
				%tmp_31_ub = index.casts %tmp_30 : i32 to index
				%tmp_32_step = index.constant 1
				%tmp_33_ub_plus_1 = arith.addi %tmp_31_ub, %tmp_32_step : index
				scf.for %l_index_d3_0 = %tmp_22_lb to %tmp_33_ub_plus_1 step %tmp_32_step
						iter_args() -> () {
					%l_index_d4_0 = arith.index_cast %l_index_d3_0 : index to i32
					%l_index_d4_1 = arith.trunci %l_index_d4_0 : i32 to i8
					// Call Statement: Start
					fifo.print("0 \00")
					// Call Statement: End
				}
				// Foreach Statement: End
			} else {
			}
			// If Statement: End
			// Foreach Statement: Begin
			%tmp_34 = arith.constant 0 : i1
			%tmp_35 = arith.extui %tmp_34 : i1 to i32
			%tmp_36_lb = index.casts %tmp_35 : i32 to index
			// Evaluate global variable $eval1.
			%tmp_37 = arith.constant 2 : i2
			%tmp_38 = arith.extui %tmp_37 : i2 to i32
			// Evaluate global variable $eval1 done: assigned to tmp_38 above in this context.
			%tmp_39 = arith.constant 1 : i1
			%tmp_40 = arith.extui %tmp_39 : i1 to i32
			%tmp_41 = arith.subi %tmp_38, %tmp_40 : i32
			%tmp_42_ub = index.casts %tmp_41 : i32 to index
			%tmp_43_step = index.constant 1
			%tmp_44_ub_plus_1 = arith.addi %tmp_42_ub, %tmp_43_step : index
			scf.for %l_index_d2_0 = %tmp_36_lb to %tmp_44_ub_plus_1 step %tmp_43_step
					iter_args() -> () {
				%l_index_d3_0 = arith.index_cast %l_index_d2_0 : index to i32
				%l_index_d3_1 = arith.trunci %l_index_d3_0 : i32 to i8
				// Call Statement: Start
				%tmp_45 = arith.extui %l_index_d3_1 : i8 to i32
				%tmp_46 = arith.index_cast %tmp_45: i32 to index
				%tmp_48 = memref.load %tmp_2[%tmp_46] : memref<2xi32>
				%tmp_47 = arith.trunci %tmp_48 : i32 to i22
				%tmp_49 = arith.extsi %tmp_47 : i22 to i32
				fifo.print("%i \00", %tmp_49) : (i32)
				// Call Statement: End
			}
			// Foreach Statement: End
			// Call Statement: Start
			fifo.print("\n\00")
			// Call Statement: End
		} else {
		}
		// If Statement: End
		// Assignment Statement: Start
		%tmp_50 = cal.get(%l_matrix__number__32: !cal.state_ref<i32>) : i32
		%tmp_51 = arith.constant 1 : i1
		%tmp_52 = arith.extui %tmp_51 : i1 to i32
		%tmp_53 = arith.addi %tmp_50, %tmp_52 : i32
		cal.set(%l_matrix__number__32: !cal.state_ref<i32>, %tmp_53: i32)
		// Assignment Statement: End
		// Output Expression: Start
		%tmp_54 = arith.constant 0 : index
		%tmp_55 = memref.load %tmp_2[%tmp_54] : memref<2xi32>
		%tmp_56 = arith.trunci %tmp_55 : i32 to i22
		fifo.push(%r_out: !fifo.input_port<i22>, %tmp_56: i22)
		%tmp_57 = arith.constant 1 : index
		%tmp_58 = memref.load %tmp_2[%tmp_57] : memref<2xi32>
		%tmp_59 = arith.trunci %tmp_58 : i32 to i22
		fifo.push(%r_out: !fifo.input_port<i22>, %tmp_59: i22)
		// Output Expression: End
	}
}

//-- Definition of actor class: IGenerator
cal.actor @iGenerator_1 ()
	ports_out(%Out: !fifo.input_port<i22>)
{
	// -- Actor body
	%l_row__index__18 = cal.create_state_var<i32> : !cal.state_ref<i32>
	%tmp_0 = arith.constant 0 : i1
	%tmp_1 = arith.extui %tmp_0 : i1 to i32
	cal.set(%l_row__index__18: !cal.state_ref<i32>, %tmp_1: i32)
	%l_total__rows__19 = cal.create_state_var<i32> : !cal.state_ref<i32>
	%tmp_2 = arith.constant 0 : i1
	%tmp_3 = arith.extui %tmp_2 : i1 to i32
	cal.set(%l_total__rows__19: !cal.state_ref<i32>, %tmp_3: i32)
	%l_total__actions__20 = cal.create_state_var<i32> : !cal.state_ref<i32>
	// Evaluate global variable $eval1.
	%tmp_4 = arith.constant 2 : i2
	%tmp_5 = arith.extui %tmp_4 : i2 to i32
	// Evaluate global variable $eval1 done: assigned to tmp_5 above in this context.
	// Evaluate global variable num_matrices.
	%tmp_6 = arith.constant 10000 : i14
	%tmp_7 = arith.extui %tmp_6 : i14 to i32
	// Evaluate global variable num_matrices done: assigned to tmp_7 above in this context.
	%tmp_8 = arith.muli %tmp_5, %tmp_7 : i32
	cal.set(%l_total__actions__20: !cal.state_ref<i32>, %tmp_8: i32)
	// Generation action: $untagged0
	cal.action "$untagged0" priority=0 {
		// Guard: Start
		cal.predicate {
			%tmp_9 = cal.get(%l_total__rows__19: !cal.state_ref<i32>) : i32
			%tmp_10 = cal.get(%l_total__actions__20: !cal.state_ref<i32>) : i32
			%tmp_11 = arith.cmpi ult, %tmp_9, %tmp_10 : i32
			cal.predicate_result %tmp_11 : i1
		}
		// Guard: End
		// Action Local Variable Decl: Start
		%tmp_12 = arith.constant 0 : i1
		%tmp_13 = arith.extui %tmp_12 : i1 to i22
		// l_outVal__21_d1_0 aliased to tmp_13
		// Action Local Variable Decl: End
		// If Statement: Begin
		%tmp_14 = cal.get(%l_row__index__18: !cal.state_ref<i32>) : i32
		// Evaluate global variable $eval5.
		%tmp_15 = arith.constant 1 : i1
		%tmp_16 = arith.extui %tmp_15 : i1 to i32
		// Evaluate global variable $eval5 done: assigned to tmp_16 above in this context.
		%tmp_17 = arith.cmpi eq, %tmp_14, %tmp_16 : i32
		%l_outVal__21_d1_1 = scf.if %tmp_17 -> (i22) {
			// Assignment Statement: Start
			// Evaluate global variable fixed_point_one.
			%tmp_18 = arith.constant 524288 : i20
			%tmp_19 = arith.extui %tmp_18 : i20 to i22
			// Evaluate global variable fixed_point_one done: assigned to tmp_19 above in this context.
			// l_outVal__21_d2_0 aliased to tmp_19
			// Assignment Statement: End
			scf.yield %tmp_19 : i22
		} else {
			scf.yield %tmp_13 : i22
		}
		// If Statement: End
		// Assignment Statement: Start
		%tmp_20 = cal.get(%l_row__index__18: !cal.state_ref<i32>) : i32
		%tmp_21 = arith.constant 1 : i1
		%tmp_22 = arith.extui %tmp_21 : i1 to i32
		%tmp_23 = arith.addi %tmp_20, %tmp_22 : i32
		// Evaluate global variable $eval1.
		%tmp_24 = arith.constant 2 : i2
		%tmp_25 = arith.extui %tmp_24 : i2 to i32
		// Evaluate global variable $eval1 done: assigned to tmp_25 above in this context.
		%tmp_26 = arith.remui %tmp_23, %tmp_25 : i32
		cal.set(%l_row__index__18: !cal.state_ref<i32>, %tmp_26: i32)
		// Assignment Statement: End
		// Assignment Statement: Start
		%tmp_27 = cal.get(%l_total__rows__19: !cal.state_ref<i32>) : i32
		%tmp_28 = arith.constant 1 : i1
		%tmp_29 = arith.extui %tmp_28 : i1 to i32
		%tmp_30 = arith.addi %tmp_27, %tmp_29 : i32
		cal.set(%l_total__rows__19: !cal.state_ref<i32>, %tmp_30: i32)
		// Assignment Statement: End
		// Output Expression: Start
		fifo.push(%Out: !fifo.input_port<i22>, %l_outVal__21_d1_1: i22)
		// Output Expression: End
	}
}

//-- Definition of actor class: JoinerRowQ
cal.actor @joinersPerRow_q_0 ()
	ports_in(%r_in_array_0_x: !fifo.output_port<i22>,%r_in_array_1_x: !fifo.output_port<i22>)
	ports_out(%q_out: !fifo.input_port<i22>)
{
	// -- Actor body
	%l_matrix__number__45 = cal.create_state_var<i32> : !cal.state_ref<i32>
	%tmp_0 = arith.constant 0 : i1
	%tmp_1 = arith.extui %tmp_0 : i1 to i32
	cal.set(%l_matrix__number__45: !cal.state_ref<i32>, %tmp_1: i32)
	// Generation action: $untagged0
	cal.action "$untagged0" priority=0 {
		// Input Pattern: Start
		%l_____input0______47_d1_0 = fifo.pop(%r_in_array_0_x: !fifo.output_port<i22>) : i22
		// Input Pattern: End
		// Input Pattern: Start
		%l_____input1______50_d1_0 = fifo.pop(%r_in_array_1_x: !fifo.output_port<i22>) : i22
		// Input Pattern: End
		// Action Local Variable Decl: Start
		%tmp_2 = memref.alloc() : memref<2xi32>
		%tmp_3 = arith.constant 0: index
		%tmp_4 = arith.extsi %l_____input0______47_d1_0 : i22 to i32
		memref.store %tmp_4, %tmp_2[%tmp_3] : memref<2xi32>
		%tmp_5 = arith.constant 1: index
		%tmp_6 = arith.extsi %l_____input1______50_d1_0 : i22 to i32
		memref.store %tmp_6, %tmp_2[%tmp_5] : memref<2xi32>
		// l_input__52_d1_0 aliased to tmp_2
		// Action Local Variable Decl: End
		// If Statement: Begin
		%tmp_7 = cal.get(%l_matrix__number__45: !cal.state_ref<i32>) : i32
		// Evaluate global variable num_matrices.
		%tmp_8 = arith.constant 10000 : i14
		%tmp_9 = arith.extui %tmp_8 : i14 to i32
		// Evaluate global variable num_matrices done: assigned to tmp_9 above in this context.
		%tmp_10 = arith.constant 10 : i4
		%tmp_11 = arith.extui %tmp_10 : i4 to i32
		%tmp_12 = arith.subi %tmp_9, %tmp_11 : i32
		%tmp_13 = arith.cmpi eq, %tmp_7, %tmp_12 : i32
		scf.if %tmp_13 {
			// Call Statement: Start
			%tmp_14 = cal.get(%l_matrix__number__45: !cal.state_ref<i32>) : i32
			fifo.print("Q%u: row 0: \00", %tmp_14) : (i32)
			// Call Statement: End
			// Foreach Statement: Begin
			%tmp_15 = arith.constant 0 : i1
			%tmp_16 = arith.extui %tmp_15 : i1 to i32
			%tmp_17_lb = index.casts %tmp_16 : i32 to index
			// Evaluate global variable $eval1.
			%tmp_18 = arith.constant 2 : i2
			%tmp_19 = arith.extui %tmp_18 : i2 to i32
			// Evaluate global variable $eval1 done: assigned to tmp_19 above in this context.
			%tmp_20 = arith.constant 1 : i1
			%tmp_21 = arith.extui %tmp_20 : i1 to i32
			%tmp_22 = arith.subi %tmp_19, %tmp_21 : i32
			%tmp_23_ub = index.casts %tmp_22 : i32 to index
			%tmp_24_step = index.constant 1
			%tmp_25_ub_plus_1 = arith.addi %tmp_23_ub, %tmp_24_step : index
			scf.for %l_index_d2_0 = %tmp_17_lb to %tmp_25_ub_plus_1 step %tmp_24_step
					iter_args() -> () {
				%l_index_d3_0 = arith.index_cast %l_index_d2_0 : index to i32
				%l_index_d3_1 = arith.trunci %l_index_d3_0 : i32 to i8
				// Call Statement: Start
				%tmp_26 = arith.extui %l_index_d3_1 : i8 to i32
				%tmp_27 = arith.index_cast %tmp_26: i32 to index
				%tmp_29 = memref.load %tmp_2[%tmp_27] : memref<2xi32>
				%tmp_28 = arith.trunci %tmp_29 : i32 to i22
				%tmp_30 = arith.extsi %tmp_28 : i22 to i32
				fifo.print("%i \00", %tmp_30) : (i32)
				// Call Statement: End
			}
			// Foreach Statement: End
			// Call Statement: Start
			fifo.print("\n\00")
			// Call Statement: End
		} else {
		}
		// If Statement: End
		// Assignment Statement: Start
		%tmp_31 = cal.get(%l_matrix__number__45: !cal.state_ref<i32>) : i32
		%tmp_32 = arith.constant 1 : i1
		%tmp_33 = arith.extui %tmp_32 : i1 to i32
		%tmp_34 = arith.addi %tmp_31, %tmp_33 : i32
		cal.set(%l_matrix__number__45: !cal.state_ref<i32>, %tmp_34: i32)
		// Assignment Statement: End
		// Output Expression: Start
		%tmp_35 = arith.constant 0 : index
		%tmp_36 = memref.load %tmp_2[%tmp_35] : memref<2xi32>
		%tmp_37 = arith.trunci %tmp_36 : i32 to i22
		fifo.push(%q_out: !fifo.input_port<i22>, %tmp_37: i22)
		%tmp_38 = arith.constant 1 : index
		%tmp_39 = memref.load %tmp_2[%tmp_38] : memref<2xi32>
		%tmp_40 = arith.trunci %tmp_39 : i32 to i22
		fifo.push(%q_out: !fifo.input_port<i22>, %tmp_40: i22)
		// Output Expression: End
	}
}

//-- Definition of actor class: Cap
cal.actor @caps_x_0 ()
	ports_in(%In: !fifo.output_port<i22>)
{
	// -- Actor body
	// Generation action: receive
	cal.action "receive" priority=0 {
		// Input Pattern: Start
		%l_t__26_d1_0 = fifo.pop(%In: !fifo.output_port<i22>) : i22
		// Input Pattern: End
	}
}

//-- Definition of actor class: JoinerRowR
cal.actor @joinersPerRow_r_1 ()
	ports_in(%r_in_array_0_x: !fifo.output_port<i22>)
	ports_out(%r_out: !fifo.input_port<i22>)
{
	// -- Actor body
	%l_matrix__number__40 = cal.create_state_var<i32> : !cal.state_ref<i32>
	%tmp_0 = arith.constant 0 : i1
	%tmp_1 = arith.extui %tmp_0 : i1 to i32
	cal.set(%l_matrix__number__40: !cal.state_ref<i32>, %tmp_1: i32)
	// Generation action: $untagged0
	cal.action "$untagged0" priority=0 {
		// Input Pattern: Start
		%l_____input0______42_d1_0 = fifo.pop(%r_in_array_0_x: !fifo.output_port<i22>) : i22
		// Input Pattern: End
		// Action Local Variable Decl: Start
		%tmp_2 = memref.alloc() : memref<1xi32>
		%tmp_3 = arith.constant 0: index
		%tmp_4 = arith.extsi %l_____input0______42_d1_0 : i22 to i32
		memref.store %tmp_4, %tmp_2[%tmp_3] : memref<1xi32>
		// l_input__44_d1_0 aliased to tmp_2
		// Action Local Variable Decl: End
		// If Statement: Begin
		%tmp_5 = cal.get(%l_matrix__number__40: !cal.state_ref<i32>) : i32
		// Evaluate global variable num_matrices.
		%tmp_6 = arith.constant 10000 : i14
		%tmp_7 = arith.extui %tmp_6 : i14 to i32
		// Evaluate global variable num_matrices done: assigned to tmp_7 above in this context.
		%tmp_8 = arith.constant 10 : i4
		%tmp_9 = arith.extui %tmp_8 : i4 to i32
		%tmp_10 = arith.subi %tmp_7, %tmp_9 : i32
		%tmp_11 = arith.cmpi eq, %tmp_5, %tmp_10 : i32
		scf.if %tmp_11 {
			// Call Statement: Start
			%tmp_12 = cal.get(%l_matrix__number__40: !cal.state_ref<i32>) : i32
			fifo.print("R%u: row 1: \00", %tmp_12) : (i32)
			// Call Statement: End
			// If Statement: Begin
			// Evaluate global variable $eval5.
			%tmp_13 = arith.constant 1 : i1
			%tmp_14 = arith.extui %tmp_13 : i1 to i32
			// Evaluate global variable $eval5 done: assigned to tmp_14 above in this context.
			%tmp_15 = arith.constant 0 : i1
			%tmp_16 = arith.extui %tmp_15 : i1 to i32
			%tmp_17 = arith.cmpi ne, %tmp_14, %tmp_16 : i32
			scf.if %tmp_17 {
				// Foreach Statement: Begin
				%tmp_18 = arith.constant 0 : i1
				%tmp_19 = arith.extui %tmp_18 : i1 to i32
				%tmp_20_lb = index.casts %tmp_19 : i32 to index
				// Evaluate global variable $eval1.
				%tmp_21 = arith.constant 2 : i2
				%tmp_22 = arith.extui %tmp_21 : i2 to i32
				// Evaluate global variable $eval1 done: assigned to tmp_22 above in this context.
				// Evaluate global variable $eval5.
				%tmp_23 = arith.constant 1 : i1
				%tmp_24 = arith.extui %tmp_23 : i1 to i32
				// Evaluate global variable $eval5 done: assigned to tmp_24 above in this context.
				%tmp_25 = arith.subi %tmp_22, %tmp_24 : i32
				%tmp_26 = arith.constant 1 : i1
				%tmp_27 = arith.extui %tmp_26 : i1 to i32
				%tmp_28 = arith.subi %tmp_25, %tmp_27 : i32
				%tmp_29_ub = index.casts %tmp_28 : i32 to index
				%tmp_30_step = index.constant 1
				%tmp_31_ub_plus_1 = arith.addi %tmp_29_ub, %tmp_30_step : index
				scf.for %l_index_d3_0 = %tmp_20_lb to %tmp_31_ub_plus_1 step %tmp_30_step
						iter_args() -> () {
					%l_index_d4_0 = arith.index_cast %l_index_d3_0 : index to i32
					%l_index_d4_1 = arith.trunci %l_index_d4_0 : i32 to i8
					// Call Statement: Start
					fifo.print("0 \00")
					// Call Statement: End
				}
				// Foreach Statement: End
			} else {
			}
			// If Statement: End
			// Foreach Statement: Begin
			%tmp_32 = arith.constant 0 : i1
			%tmp_33 = arith.extui %tmp_32 : i1 to i32
			%tmp_34_lb = index.casts %tmp_33 : i32 to index
			// Evaluate global variable $eval5.
			%tmp_35 = arith.constant 1 : i1
			%tmp_36 = arith.extui %tmp_35 : i1 to i32
			// Evaluate global variable $eval5 done: assigned to tmp_36 above in this context.
			%tmp_37 = arith.constant 1 : i1
			%tmp_38 = arith.extui %tmp_37 : i1 to i32
			%tmp_39 = arith.subi %tmp_36, %tmp_38 : i32
			%tmp_40_ub = index.casts %tmp_39 : i32 to index
			%tmp_41_step = index.constant 1
			%tmp_42_ub_plus_1 = arith.addi %tmp_40_ub, %tmp_41_step : index
			scf.for %l_index_d2_0 = %tmp_34_lb to %tmp_42_ub_plus_1 step %tmp_41_step
					iter_args() -> () {
				%l_index_d3_0 = arith.index_cast %l_index_d2_0 : index to i32
				%l_index_d3_1 = arith.trunci %l_index_d3_0 : i32 to i8
				// Call Statement: Start
				%tmp_43 = arith.extui %l_index_d3_1 : i8 to i32
				%tmp_44 = arith.index_cast %tmp_43: i32 to index
				%tmp_46 = memref.load %tmp_2[%tmp_44] : memref<1xi32>
				%tmp_45 = arith.trunci %tmp_46 : i32 to i22
				%tmp_47 = arith.extsi %tmp_45 : i22 to i32
				fifo.print("%i \00", %tmp_47) : (i32)
				// Call Statement: End
			}
			// Foreach Statement: End
			// Call Statement: Start
			fifo.print("\n\00")
			// Call Statement: End
		} else {
		}
		// If Statement: End
		// Assignment Statement: Start
		%tmp_48 = cal.get(%l_matrix__number__40: !cal.state_ref<i32>) : i32
		%tmp_49 = arith.constant 1 : i1
		%tmp_50 = arith.extui %tmp_49 : i1 to i32
		%tmp_51 = arith.addi %tmp_48, %tmp_50 : i32
		cal.set(%l_matrix__number__40: !cal.state_ref<i32>, %tmp_51: i32)
		// Assignment Statement: End
		// Output Expression: Start
		%tmp_52 = arith.constant 0 : index
		%tmp_53 = memref.load %tmp_2[%tmp_52] : memref<1xi32>
		%tmp_54 = arith.trunci %tmp_53 : i32 to i22
		fifo.push(%r_out: !fifo.input_port<i22>, %tmp_54: i22)
		// Output Expression: End
	}
}

//-- Definition of actor class: Cap
cal.actor @caps_x_1 ()
	ports_in(%In: !fifo.output_port<i22>)
{
	// -- Actor body
	// Generation action: receive
	cal.action "receive" priority=0 {
		// Input Pattern: Start
		%l_t__26_d1_0 = fifo.pop(%In: !fifo.output_port<i22>) : i22
		// Input Pattern: End
	}
}

//-- Definition of actor class: IGenerator
cal.actor @iGenerator_0 ()
	ports_out(%Out: !fifo.input_port<i22>)
{
	// -- Actor body
	%l_row__index__14 = cal.create_state_var<i32> : !cal.state_ref<i32>
	%tmp_0 = arith.constant 0 : i1
	%tmp_1 = arith.extui %tmp_0 : i1 to i32
	cal.set(%l_row__index__14: !cal.state_ref<i32>, %tmp_1: i32)
	%l_total__rows__15 = cal.create_state_var<i32> : !cal.state_ref<i32>
	%tmp_2 = arith.constant 0 : i1
	%tmp_3 = arith.extui %tmp_2 : i1 to i32
	cal.set(%l_total__rows__15: !cal.state_ref<i32>, %tmp_3: i32)
	%l_total__actions__16 = cal.create_state_var<i32> : !cal.state_ref<i32>
	// Evaluate global variable $eval1.
	%tmp_4 = arith.constant 2 : i2
	%tmp_5 = arith.extui %tmp_4 : i2 to i32
	// Evaluate global variable $eval1 done: assigned to tmp_5 above in this context.
	// Evaluate global variable num_matrices.
	%tmp_6 = arith.constant 10000 : i14
	%tmp_7 = arith.extui %tmp_6 : i14 to i32
	// Evaluate global variable num_matrices done: assigned to tmp_7 above in this context.
	%tmp_8 = arith.muli %tmp_5, %tmp_7 : i32
	cal.set(%l_total__actions__16: !cal.state_ref<i32>, %tmp_8: i32)
	// Generation action: $untagged0
	cal.action "$untagged0" priority=0 {
		// Guard: Start
		cal.predicate {
			%tmp_9 = cal.get(%l_total__rows__15: !cal.state_ref<i32>) : i32
			%tmp_10 = cal.get(%l_total__actions__16: !cal.state_ref<i32>) : i32
			%tmp_11 = arith.cmpi ult, %tmp_9, %tmp_10 : i32
			cal.predicate_result %tmp_11 : i1
		}
		// Guard: End
		// Action Local Variable Decl: Start
		%tmp_12 = arith.constant 0 : i1
		%tmp_13 = arith.extui %tmp_12 : i1 to i22
		// l_outVal__17_d1_0 aliased to tmp_13
		// Action Local Variable Decl: End
		// If Statement: Begin
		%tmp_14 = cal.get(%l_row__index__14: !cal.state_ref<i32>) : i32
		// Evaluate global variable $eval3.
		%tmp_15 = arith.constant 0 : i1
		%tmp_16 = arith.extui %tmp_15 : i1 to i32
		// Evaluate global variable $eval3 done: assigned to tmp_16 above in this context.
		%tmp_17 = arith.cmpi eq, %tmp_14, %tmp_16 : i32
		%l_outVal__17_d1_1 = scf.if %tmp_17 -> (i22) {
			// Assignment Statement: Start
			// Evaluate global variable fixed_point_one.
			%tmp_18 = arith.constant 524288 : i20
			%tmp_19 = arith.extui %tmp_18 : i20 to i22
			// Evaluate global variable fixed_point_one done: assigned to tmp_19 above in this context.
			// l_outVal__17_d2_0 aliased to tmp_19
			// Assignment Statement: End
			scf.yield %tmp_19 : i22
		} else {
			scf.yield %tmp_13 : i22
		}
		// If Statement: End
		// Assignment Statement: Start
		%tmp_20 = cal.get(%l_row__index__14: !cal.state_ref<i32>) : i32
		%tmp_21 = arith.constant 1 : i1
		%tmp_22 = arith.extui %tmp_21 : i1 to i32
		%tmp_23 = arith.addi %tmp_20, %tmp_22 : i32
		// Evaluate global variable $eval1.
		%tmp_24 = arith.constant 2 : i2
		%tmp_25 = arith.extui %tmp_24 : i2 to i32
		// Evaluate global variable $eval1 done: assigned to tmp_25 above in this context.
		%tmp_26 = arith.remui %tmp_23, %tmp_25 : i32
		cal.set(%l_row__index__14: !cal.state_ref<i32>, %tmp_26: i32)
		// Assignment Statement: End
		// Assignment Statement: Start
		%tmp_27 = cal.get(%l_total__rows__15: !cal.state_ref<i32>) : i32
		%tmp_28 = arith.constant 1 : i1
		%tmp_29 = arith.extui %tmp_28 : i1 to i32
		%tmp_30 = arith.addi %tmp_27, %tmp_29 : i32
		cal.set(%l_total__rows__15: !cal.state_ref<i32>, %tmp_30: i32)
		// Assignment Statement: End
		// Output Expression: Start
		fifo.push(%Out: !fifo.input_port<i22>, %l_outVal__17_d1_1: i22)
		// Output Expression: End
	}
}

// -- Top Network: Defines structure of actor application
cal.network
{

	// -- Instantiate channels between actors
	%queue_from_joinersPerRow_r_0_r_out, %queue_to_caps_r_0_In = fifo.create<i22>(2) : !fifo.input_port<i22>, !fifo.output_port<i22>
	%queue_from_iGenerator_1_Out, %queue_to_innerCells_q_1_x_in = fifo.create<i22>(1) : !fifo.input_port<i22>, !fifo.output_port<i22>
	%queue_from_innerCells_q_2_cordic_angles_out, %queue_to_innerCells_q_3_cordic_angles_in = fifo.create<i16>(1) : !fifo.input_port<i16>, !fifo.output_port<i16>
	%queue_from_boundaryCells_1_cordic_angles_out, %queue_to_innerCells_q_2_cordic_angles_in = fifo.create<i16>(1) : !fifo.input_port<i16>, !fifo.output_port<i16>
	%queue_from_innerCells_q_0_cordic_angles_out, %queue_to_innerCells_q_1_cordic_angles_in = fifo.create<i16>(1) : !fifo.input_port<i16>, !fifo.output_port<i16>
	%queue_from_boundaryCells_1_r_out, %queue_to_joinersPerRow_r_1_r_in_array_0_x = fifo.create<i22>(1) : !fifo.input_port<i22>, !fifo.output_port<i22>
	%queue_from_joinersPerRow_q_0_q_out, %queue_to_caps_q_0_In = fifo.create<i22>(2) : !fifo.input_port<i22>, !fifo.output_port<i22>
	%queue_from_innerCells_q_0_x_out, %queue_to_innerCells_q_2_x_in = fifo.create<i22>(1) : !fifo.input_port<i22>, !fifo.output_port<i22>
	%queue_from_innerCells_q_2_x_out, %queue_to_caps_x_0_In = fifo.create<i22>(1) : !fifo.input_port<i22>, !fifo.output_port<i22>
	%queue_from_innerCells_q_1_r_out, %queue_to_joinersPerRow_q_1_r_in_array_0_x = fifo.create<i22>(1) : !fifo.input_port<i22>, !fifo.output_port<i22>
	%queue_from_innerCells_r_0_r_out, %queue_to_joinersPerRow_r_0_r_in_array_1_x = fifo.create<i22>(1) : !fifo.input_port<i22>, !fifo.output_port<i22>
	%queue_from_innerCells_q_3_r_out, %queue_to_joinersPerRow_q_1_r_in_array_1_x = fifo.create<i22>(1) : !fifo.input_port<i22>, !fifo.output_port<i22>
	%queue_from_joinersPerRow_r_1_r_out, %queue_to_caps_r_1_In = fifo.create<i22>(2) : !fifo.input_port<i22>, !fifo.output_port<i22>
	%queue_from_innerCells_q_3_cordic_angles_out, %queue_to_caps_cordic_1_In = fifo.create<i16>(1) : !fifo.input_port<i16>, !fifo.output_port<i16>
	%queue_from_boundaryCells_0_cordic_angles_out, %queue_to_innerCells_r_0_cordic_angles_in = fifo.create<i16>(1) : !fifo.input_port<i16>, !fifo.output_port<i16>
	%queue_from_iGenerator_0_Out, %queue_to_innerCells_q_0_x_in = fifo.create<i22>(1) : !fifo.input_port<i22>, !fifo.output_port<i22>
	%queue_from_innerCells_q_1_cordic_angles_out, %queue_to_caps_cordic_0_In = fifo.create<i16>(1) : !fifo.input_port<i16>, !fifo.output_port<i16>
	%queue_from_source_Out_array_1_x, %queue_to_innerCells_r_0_x_in = fifo.create<i22>(3) : !fifo.input_port<i22>, !fifo.output_port<i22>
	%queue_from_innerCells_r_0_cordic_angles_out, %queue_to_innerCells_q_0_cordic_angles_in = fifo.create<i16>(1) : !fifo.input_port<i16>, !fifo.output_port<i16>
	%queue_from_source_Out_array_0_x, %queue_to_boundaryCells_0_x_in = fifo.create<i22>(3) : !fifo.input_port<i22>, !fifo.output_port<i22>
	%queue_from_boundaryCells_0_r_out, %queue_to_joinersPerRow_r_0_r_in_array_0_x = fifo.create<i22>(1) : !fifo.input_port<i22>, !fifo.output_port<i22>
	%queue_from_joinersPerRow_q_1_q_out, %queue_to_caps_q_1_In = fifo.create<i22>(2) : !fifo.input_port<i22>, !fifo.output_port<i22>
	%queue_from_innerCells_q_3_x_out, %queue_to_caps_x_1_In = fifo.create<i22>(1) : !fifo.input_port<i22>, !fifo.output_port<i22>
	%queue_from_innerCells_q_0_r_out, %queue_to_joinersPerRow_q_0_r_in_array_0_x = fifo.create<i22>(1) : !fifo.input_port<i22>, !fifo.output_port<i22>
	%queue_from_innerCells_r_0_x_out, %queue_to_boundaryCells_1_x_in = fifo.create<i22>(1) : !fifo.input_port<i22>, !fifo.output_port<i22>
	%queue_from_innerCells_q_1_x_out, %queue_to_innerCells_q_3_x_in = fifo.create<i22>(1) : !fifo.input_port<i22>, !fifo.output_port<i22>
	%queue_from_innerCells_q_2_r_out, %queue_to_joinersPerRow_q_0_r_in_array_1_x = fifo.create<i22>(1) : !fifo.input_port<i22>, !fifo.output_port<i22>

	// -- Instantiate actors (also known as nodes/instances)
	cal.create_instance @caps_cordic_1 "caps_cordic_1" ()
		ports_in(%queue_to_caps_cordic_1_In: !fifo.output_port<i16>)
	cal.create_instance @innerCells_q_0 "innerCells_q_0" ()
		ports_in(%queue_to_innerCells_q_0_x_in, %queue_to_innerCells_q_0_cordic_angles_in: !fifo.output_port<i22>, !fifo.output_port<i16>)
		ports_out(%queue_from_innerCells_q_0_x_out, %queue_from_innerCells_q_0_r_out, %queue_from_innerCells_q_0_cordic_angles_out: !fifo.input_port<i22>, !fifo.input_port<i22>, !fifo.input_port<i16>)
	cal.create_instance @boundaryCells_1 "boundaryCells_1" ()
		ports_in(%queue_to_boundaryCells_1_x_in: !fifo.output_port<i22>)
		ports_out(%queue_from_boundaryCells_1_r_out, %queue_from_boundaryCells_1_cordic_angles_out: !fifo.input_port<i22>, !fifo.input_port<i16>)
	cal.create_instance @caps_cordic_0 "caps_cordic_0" ()
		ports_in(%queue_to_caps_cordic_0_In: !fifo.output_port<i16>)
	cal.create_instance @innerCells_q_1 "innerCells_q_1" ()
		ports_in(%queue_to_innerCells_q_1_x_in, %queue_to_innerCells_q_1_cordic_angles_in: !fifo.output_port<i22>, !fifo.output_port<i16>)
		ports_out(%queue_from_innerCells_q_1_x_out, %queue_from_innerCells_q_1_r_out, %queue_from_innerCells_q_1_cordic_angles_out: !fifo.input_port<i22>, !fifo.input_port<i22>, !fifo.input_port<i16>)
	cal.create_instance @boundaryCells_0 "boundaryCells_0" ()
		ports_in(%queue_to_boundaryCells_0_x_in: !fifo.output_port<i22>)
		ports_out(%queue_from_boundaryCells_0_r_out, %queue_from_boundaryCells_0_cordic_angles_out: !fifo.input_port<i22>, !fifo.input_port<i16>)
	cal.create_instance @innerCells_r_0 "innerCells_r_0" ()
		ports_in(%queue_to_innerCells_r_0_x_in, %queue_to_innerCells_r_0_cordic_angles_in: !fifo.output_port<i22>, !fifo.output_port<i16>)
		ports_out(%queue_from_innerCells_r_0_x_out, %queue_from_innerCells_r_0_r_out, %queue_from_innerCells_r_0_cordic_angles_out: !fifo.input_port<i22>, !fifo.input_port<i22>, !fifo.input_port<i16>)
	cal.create_instance @source "source" ()
		ports_out(%queue_from_source_Out_array_0_x, %queue_from_source_Out_array_1_x: !fifo.input_port<i22>, !fifo.input_port<i22>)
	cal.create_instance @caps_q_1 "caps_q_1" ()
		ports_in(%queue_to_caps_q_1_In: !fifo.output_port<i22>)
	cal.create_instance @caps_r_0 "caps_r_0" ()
		ports_in(%queue_to_caps_r_0_In: !fifo.output_port<i22>)
	cal.create_instance @caps_q_0 "caps_q_0" ()
		ports_in(%queue_to_caps_q_0_In: !fifo.output_port<i22>)
	cal.create_instance @innerCells_q_2 "innerCells_q_2" ()
		ports_in(%queue_to_innerCells_q_2_x_in, %queue_to_innerCells_q_2_cordic_angles_in: !fifo.output_port<i22>, !fifo.output_port<i16>)
		ports_out(%queue_from_innerCells_q_2_x_out, %queue_from_innerCells_q_2_r_out, %queue_from_innerCells_q_2_cordic_angles_out: !fifo.input_port<i22>, !fifo.input_port<i22>, !fifo.input_port<i16>)
	cal.create_instance @innerCells_q_3 "innerCells_q_3" ()
		ports_in(%queue_to_innerCells_q_3_x_in, %queue_to_innerCells_q_3_cordic_angles_in: !fifo.output_port<i22>, !fifo.output_port<i16>)
		ports_out(%queue_from_innerCells_q_3_x_out, %queue_from_innerCells_q_3_r_out, %queue_from_innerCells_q_3_cordic_angles_out: !fifo.input_port<i22>, !fifo.input_port<i22>, !fifo.input_port<i16>)
	cal.create_instance @caps_r_1 "caps_r_1" ()
		ports_in(%queue_to_caps_r_1_In: !fifo.output_port<i22>)
	cal.create_instance @joinersPerRow_q_1 "joinersPerRow_q_1" ()
		ports_in(%queue_to_joinersPerRow_q_1_r_in_array_0_x, %queue_to_joinersPerRow_q_1_r_in_array_1_x: !fifo.output_port<i22>, !fifo.output_port<i22>)
		ports_out(%queue_from_joinersPerRow_q_1_q_out: !fifo.input_port<i22>)
	cal.create_instance @joinersPerRow_r_0 "joinersPerRow_r_0" ()
		ports_in(%queue_to_joinersPerRow_r_0_r_in_array_0_x, %queue_to_joinersPerRow_r_0_r_in_array_1_x: !fifo.output_port<i22>, !fifo.output_port<i22>)
		ports_out(%queue_from_joinersPerRow_r_0_r_out: !fifo.input_port<i22>)
	cal.create_instance @iGenerator_1 "iGenerator_1" ()
		ports_out(%queue_from_iGenerator_1_Out: !fifo.input_port<i22>)
	cal.create_instance @joinersPerRow_q_0 "joinersPerRow_q_0" ()
		ports_in(%queue_to_joinersPerRow_q_0_r_in_array_0_x, %queue_to_joinersPerRow_q_0_r_in_array_1_x: !fifo.output_port<i22>, !fifo.output_port<i22>)
		ports_out(%queue_from_joinersPerRow_q_0_q_out: !fifo.input_port<i22>)
	cal.create_instance @caps_x_0 "caps_x_0" ()
		ports_in(%queue_to_caps_x_0_In: !fifo.output_port<i22>)
	cal.create_instance @joinersPerRow_r_1 "joinersPerRow_r_1" ()
		ports_in(%queue_to_joinersPerRow_r_1_r_in_array_0_x: !fifo.output_port<i22>)
		ports_out(%queue_from_joinersPerRow_r_1_r_out: !fifo.input_port<i22>)
	cal.create_instance @caps_x_1 "caps_x_1" ()
		ports_in(%queue_to_caps_x_1_In: !fifo.output_port<i22>)
	cal.create_instance @iGenerator_0 "iGenerator_0" ()
		ports_out(%queue_from_iGenerator_0_Out: !fifo.input_port<i22>)

}

