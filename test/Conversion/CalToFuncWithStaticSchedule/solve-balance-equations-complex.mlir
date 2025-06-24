// RUN: cal-opt %s --canonicalize --convert-cal-to-func-with-static-schedule="print-solved-balance-equations-for-testing" | FileCheck %s

// CHECK: Number of firings of the all the CSDF phases per actor:
// CHECK-NEXT:   boundaryCells_0: 1
// CHECK-NEXT:   boundaryCells_1: 1
// CHECK-NEXT:   boundaryCells_2: 1
// CHECK-NEXT:   boundaryCells_3: 1
// CHECK-NEXT:   caps_cordic_0: 4
// CHECK-NEXT:   caps_cordic_1: 4
// CHECK-NEXT:   caps_cordic_2: 4
// CHECK-NEXT:   caps_cordic_3: 4
// CHECK-NEXT:   caps_q_0: 4
// CHECK-NEXT:   caps_q_1: 4
// CHECK-NEXT:   caps_q_2: 4
// CHECK-NEXT:   caps_q_3: 4
// CHECK-NEXT:   caps_r_0: 4
// CHECK-NEXT:   caps_r_1: 3
// CHECK-NEXT:   caps_r_2: 2
// CHECK-NEXT:   caps_r_3: 1
// CHECK-NEXT:   caps_x_0: 4
// CHECK-NEXT:   caps_x_1: 4
// CHECK-NEXT:   caps_x_2: 4
// CHECK-NEXT:   caps_x_3: 4
// CHECK-NEXT:   iGenerator_0: 4
// CHECK-NEXT:   iGenerator_1: 4
// CHECK-NEXT:   iGenerator_2: 4
// CHECK-NEXT:   iGenerator_3: 4
// CHECK-NEXT:   innerCells_q_0: 1
// CHECK-NEXT:   innerCells_q_1: 1
// CHECK-NEXT:   innerCells_q_10: 1
// CHECK-NEXT:   innerCells_q_11: 1
// CHECK-NEXT:   innerCells_q_12: 1
// CHECK-NEXT:   innerCells_q_13: 1
// CHECK-NEXT:   innerCells_q_14: 1
// CHECK-NEXT:   innerCells_q_15: 1
// CHECK-NEXT:   innerCells_q_2: 1
// CHECK-NEXT:   innerCells_q_3: 1
// CHECK-NEXT:   innerCells_q_4: 1
// CHECK-NEXT:   innerCells_q_5: 1
// CHECK-NEXT:   innerCells_q_6: 1
// CHECK-NEXT:   innerCells_q_7: 1
// CHECK-NEXT:   innerCells_q_8: 1
// CHECK-NEXT:   innerCells_q_9: 1
// CHECK-NEXT:   innerCells_r_0: 1
// CHECK-NEXT:   innerCells_r_1: 1
// CHECK-NEXT:   innerCells_r_2: 1
// CHECK-NEXT:   innerCells_r_3: 1
// CHECK-NEXT:   innerCells_r_4: 1
// CHECK-NEXT:   innerCells_r_5: 1
// CHECK-NEXT:   joinersPerRow_q_0: 1
// CHECK-NEXT:   joinersPerRow_q_1: 1
// CHECK-NEXT:   joinersPerRow_q_2: 1
// CHECK-NEXT:   joinersPerRow_q_3: 1
// CHECK-NEXT:   joinersPerRow_r_0: 1
// CHECK-NEXT:   joinersPerRow_r_1: 1
// CHECK-NEXT:   joinersPerRow_r_2: 1
// CHECK-NEXT:   joinersPerRow_r_3: 1
// CHECK-NEXT:   source: 4


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

//-- Definition of actor class: JoinerRowR
cal.actor @joinersPerRow_r_3 ()
	ports_in(%r_in_array_0_x: !fifo.output_port<i22>)
	ports_out(%r_out: !fifo.input_port<i22>)
{
	// -- Actor body
	%l_matrix__number__81 = cal.create_state_var<i32> : !cal.state_ref<i32>
	%tmp_0 = arith.constant 0 : i1
	%tmp_1 = arith.extui %tmp_0 : i1 to i32
	cal.set(%l_matrix__number__81: !cal.state_ref<i32>, %tmp_1: i32)
	// Generation action: $untagged0
	cal.action "$untagged0" priority=0 {
		// Input Pattern: Start
		%l_____input0______83_d1_0 = fifo.pop(%r_in_array_0_x: !fifo.output_port<i22>) : i22
		// Input Pattern: End
		// Action Local Variable Decl: Start
		%tmp_2 = memref.alloc() : memref<1xi32>
		%tmp_3 = arith.constant 0: index
		%tmp_4 = arith.extsi %l_____input0______83_d1_0 : i22 to i32
		memref.store %tmp_4, %tmp_2[%tmp_3] : memref<1xi32>
		// l_input__85_d1_0 aliased to tmp_2
		// Action Local Variable Decl: End
		// If Statement: Begin
		%tmp_5 = cal.get(%l_matrix__number__81: !cal.state_ref<i32>) : i32
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
			%tmp_12 = cal.get(%l_matrix__number__81: !cal.state_ref<i32>) : i32
			fifo.print("R%u: row 3: \00", %tmp_12) : (i32)
			// Call Statement: End
			// If Statement: Begin
			// Evaluate global variable $eval9.
			%tmp_13 = arith.constant 3 : i2
			%tmp_14 = arith.extui %tmp_13 : i2 to i32
			// Evaluate global variable $eval9 done: assigned to tmp_14 above in this context.
			%tmp_15 = arith.constant 0 : i1
			%tmp_16 = arith.extui %tmp_15 : i1 to i32
			%tmp_17 = arith.cmpi ne, %tmp_14, %tmp_16 : i32
			scf.if %tmp_17 {
				// Foreach Statement: Begin
				%tmp_18 = arith.constant 0 : i1
				%tmp_19 = arith.extui %tmp_18 : i1 to i32
				%tmp_20_lb = index.casts %tmp_19 : i32 to index
				// Evaluate global variable $eval1.
				%tmp_21 = arith.constant 4 : i3
				%tmp_22 = arith.extui %tmp_21 : i3 to i32
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
		%tmp_48 = cal.get(%l_matrix__number__81: !cal.state_ref<i32>) : i32
		%tmp_49 = arith.constant 1 : i1
		%tmp_50 = arith.extui %tmp_49 : i1 to i32
		%tmp_51 = arith.addi %tmp_48, %tmp_50 : i32
		cal.set(%l_matrix__number__81: !cal.state_ref<i32>, %tmp_51: i32)
		// Assignment Statement: End
		// Output Expression: Start
		%tmp_52 = arith.constant 0 : index
		%tmp_53 = memref.load %tmp_2[%tmp_52] : memref<1xi32>
		%tmp_54 = arith.trunci %tmp_53 : i32 to i22
		fifo.push(%r_out: !fifo.input_port<i22>, %tmp_54: i22)
		// Output Expression: End
	}
}

//-- Definition of actor class: Cap_Iterations
cal.actor @caps_cordic_3 ()
	ports_in(%In: !fifo.output_port<i16>)
{
	// -- Actor body
	// Generation action: receive
	cal.action "receive" priority=0 {
		// Input Pattern: Start
		%l_t__39_d1_0 = fifo.pop(%In: !fifo.output_port<i16>) : i16
		// Input Pattern: End
	}
}

//-- Definition of actor class: Cap_Iterations
cal.actor @caps_cordic_2 ()
	ports_in(%In: !fifo.output_port<i16>)
{
	// -- Actor body
	// Generation action: receive
	cal.action "receive" priority=0 {
		// Input Pattern: Start
		%l_t__39_d1_0 = fifo.pop(%In: !fifo.output_port<i16>) : i16
		// Input Pattern: End
	}
}

//-- Definition of actor class: Cap_Iterations
cal.actor @caps_cordic_1 ()
	ports_in(%In: !fifo.output_port<i16>)
{
	// -- Actor body
	// Generation action: receive
	cal.action "receive" priority=0 {
		// Input Pattern: Start
		%l_t__39_d1_0 = fifo.pop(%In: !fifo.output_port<i16>) : i16
		// Input Pattern: End
	}
}

//-- Definition of actor class: BoundaryCell
cal.actor @boundaryCells_1 ()
	ports_in(%x_in: !fifo.output_port<i22>)
	ports_out(%r_out: !fifo.input_port<i22>,%cordic_angles_out: !fifo.input_port<i16>)
{
	// -- Actor body
	%l_r__142 = cal.create_state_var<i22> : !cal.state_ref<i22>
	%tmp_0 = arith.constant 0 : i1
	%tmp_1 = arith.extui %tmp_0 : i1 to i22
	cal.set(%l_r__142: !cal.state_ref<i22>, %tmp_1: i22)
	%l_count__143 = cal.create_state_var<i32> : !cal.state_ref<i32>
	%tmp_2 = arith.constant 0 : i1
	%tmp_3 = arith.extui %tmp_2 : i1 to i32
	cal.set(%l_count__143: !cal.state_ref<i32>, %tmp_3: i32)
	// Generation action: $untagged0
	cal.action "$untagged0" priority=0 {
		// Guard: Start
		cal.predicate {
			%tmp_4 = cal.get(%l_count__143: !cal.state_ref<i32>) : i32
			// Evaluate global variable $eval1.
			%tmp_5 = arith.constant 4 : i3
			%tmp_6 = arith.extui %tmp_5 : i3 to i32
			// Evaluate global variable $eval1 done: assigned to tmp_6 above in this context.
			%tmp_7 = arith.cmpi ult, %tmp_4, %tmp_6 : i32
			cal.predicate_result %tmp_7 : i1
		}
		// Guard: End
		// Input Pattern: Start
		%l_x__in__145_d1_0 = fifo.pop(%x_in: !fifo.output_port<i22>) : i22
		// Input Pattern: End
		// Action Local Variable Decl: Start
		%l_x__j__148_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_x__j__plus__1__149_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_x__j__shifted__150_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_y__j__151_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_y__j__plus__1__152_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_y__j__shifted__153_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%tmp_8 = arith.constant 0 : i1
		%tmp_9 = arith.extui %tmp_8 : i1 to i16
		// l_rotation__angles__147_d1_0 aliased to tmp_9
		// Action Local Variable Decl: End
		// If Statement: Begin
		%tmp_10 = cal.get(%l_count__143: !cal.state_ref<i32>) : i32
		%tmp_11 = arith.constant 0 : i1
		%tmp_12 = arith.extui %tmp_11 : i1 to i32
		%tmp_13 = arith.cmpi eq, %tmp_10, %tmp_12 : i32
		scf.if %tmp_13 {
			// Assignment Statement: Start
			%tmp_14 = arith.constant 0 : i1
			%tmp_15 = arith.extui %tmp_14 : i1 to i22
			cal.set(%l_r__142: !cal.state_ref<i22>, %tmp_15: i22)
			// Assignment Statement: End
		} else {
		}
		// If Statement: End
		// Assignment Statement: Start
		// l_x__j__148_d1_1 aliased to l_x__in__145_d1_0
		// Assignment Statement: End
		// Assignment Statement: Start
		%tmp_16 = cal.get(%l_r__142: !cal.state_ref<i22>) : i22
		// l_y__j__151_d1_1 aliased to tmp_16
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
		%l_rotation__angles__147_d1_1, %l_x__j__148_d1_2, %l_x__j__plus__1__149_d1_1, %l_x__j__shifted__150_d1_1, %l_y__j__151_d1_2, %l_y__j__plus__1__152_d1_1, %l_y__j__shifted__153_d1_1 = scf.for %l_j_d1_0 = %tmp_19_lb to %tmp_27_ub_plus_1 step %tmp_26_step
				iter_args(%l_rotation__angles__147_d2_0 = %tmp_9, %l_x__j__148_d2_0 = %l_x__in__145_d1_0, %l_x__j__plus__1__149_d2_0 = %l_x__j__plus__1__149_d1_0, %l_x__j__shifted__150_d2_0 = %l_x__j__shifted__150_d1_0, %l_y__j__151_d2_0 = %tmp_16, %l_y__j__plus__1__152_d2_0 = %l_y__j__plus__1__152_d1_0, %l_y__j__shifted__153_d2_0 = %l_y__j__shifted__153_d1_0) -> (i16, i22, i22, i22, i22, i22, i22) {
			%l_j_d2_0 = arith.index_cast %l_j_d1_0 : index to i32
			%l_j_d2_1 = arith.trunci %l_j_d2_0 : i32 to i8
			// Assignment Statement: Start
			%tmp_28 = arith.extui %l_j_d2_1 : i8 to i22
			%tmp_29 = arith.shrsi %l_y__j__151_d2_0, %tmp_28 : i22
			// l_y__j__shifted__153_d2_1 aliased to tmp_29
			// Assignment Statement: End
			// Assignment Statement: Start
			%tmp_30 = arith.extui %l_j_d2_1 : i8 to i22
			%tmp_31 = arith.shrsi %l_x__j__148_d2_0, %tmp_30 : i22
			// l_x__j__shifted__150_d2_1 aliased to tmp_31
			// Assignment Statement: End
			// If Statement: Begin
			%tmp_32 = arith.constant 0 : i1
			%tmp_33 = arith.extui %tmp_32 : i1 to i22
			%tmp_34 = arith.cmpi sgt, %l_x__j__148_d2_0, %tmp_33 : i22
			%tmp_35 = arith.constant 0 : i1
			%tmp_36 = arith.extui %tmp_35 : i1 to i22
			%tmp_37 = arith.cmpi sgt, %l_y__j__151_d2_0, %tmp_36 : i22
			%tmp_38 = arith.andi %tmp_34, %tmp_37 : i1
			%tmp_39 = arith.constant 0 : i1
			%tmp_40 = arith.extui %tmp_39 : i1 to i22
			%tmp_41 = arith.cmpi slt, %l_x__j__148_d2_0, %tmp_40 : i22
			%tmp_42 = arith.constant 0 : i1
			%tmp_43 = arith.extui %tmp_42 : i1 to i22
			%tmp_44 = arith.cmpi slt, %l_y__j__151_d2_0, %tmp_43 : i22
			%tmp_45 = arith.andi %tmp_41, %tmp_44 : i1
			%tmp_46 = arith.ori %tmp_38, %tmp_45 : i1
			%l_rotation__angles__147_d2_1, %l_x__j__plus__1__149_d2_1, %l_y__j__plus__1__152_d2_1 = scf.if %tmp_46 -> (i16, i22, i22) {
				// Assignment Statement: Start
				%tmp_47 = arith.extsi %l_x__j__148_d2_0 : i22 to i23
				%tmp_48 = arith.extsi %tmp_29 : i22 to i23
				%tmp_49 = arith.addi %tmp_47, %tmp_48 : i23
				%tmp_50 = arith.trunci %tmp_49 : i23 to i22
				// l_x__j__plus__1__149_d3_0 aliased to tmp_50
				// Assignment Statement: End
				// Assignment Statement: Start
				%tmp_51 = arith.subi %l_y__j__151_d2_0, %tmp_31 : i22
				// l_y__j__plus__1__152_d3_0 aliased to tmp_51
				// Assignment Statement: End
				// Assignment Statement: Start
				%tmp_52 = arith.constant 1 : i1
				%tmp_53 = arith.extui %tmp_52 : i1 to i64
				%tmp_54 = arith.extui %l_j_d2_1 : i8 to i64
				%tmp_55 = arith.shli %tmp_53, %tmp_54 : i64
				%tmp_56 = arith.extui %l_rotation__angles__147_d2_0 : i16 to i64
				%tmp_57 = arith.ori %tmp_56, %tmp_55 : i64
				%tmp_58 = arith.trunci %tmp_57 : i64 to i16
				// l_rotation__angles__147_d3_0 aliased to tmp_58
				// Assignment Statement: End
				scf.yield %tmp_58, %tmp_50, %tmp_51 : i16, i22, i22
			} else {
				// Assignment Statement: Start
				%tmp_59 = arith.subi %l_x__j__148_d2_0, %tmp_29 : i22
				// l_x__j__plus__1__149_d3_0 aliased to tmp_59
				// Assignment Statement: End
				// Assignment Statement: Start
				%tmp_60 = arith.extsi %l_y__j__151_d2_0 : i22 to i23
				%tmp_61 = arith.extsi %tmp_31 : i22 to i23
				%tmp_62 = arith.addi %tmp_60, %tmp_61 : i23
				%tmp_63 = arith.trunci %tmp_62 : i23 to i22
				// l_y__j__plus__1__152_d3_0 aliased to tmp_63
				// Assignment Statement: End
				scf.yield %l_rotation__angles__147_d2_0, %tmp_59, %tmp_63 : i16, i22, i22
			}
			// If Statement: End
			// Assignment Statement: Start
			// l_x__j__148_d2_1 aliased to l_x__j__plus__1__149_d2_1
			// Assignment Statement: End
			// Assignment Statement: Start
			// l_y__j__151_d2_1 aliased to l_y__j__plus__1__152_d2_1
			// Assignment Statement: End
			scf.yield %l_rotation__angles__147_d2_1, %l_x__j__plus__1__149_d2_1, %l_x__j__plus__1__149_d2_1, %tmp_31, %l_y__j__plus__1__152_d2_1, %l_y__j__plus__1__152_d2_1, %tmp_29 : i16, i22, i22, i22, i22, i22, i22
		}
		// Foreach Statement: End
		// Assignment Statement: Start
		// Evaluate global variable k_CORDIC_constant.
		%tmp_65 = arith.constant 318375 : i19
		%tmp_66 = arith.extui %tmp_65 : i19 to i22
		// Evaluate global variable k_CORDIC_constant done: assigned to tmp_66 above in this context.
		// Evaluate global variable fixedPointMultiply.
		%tmp_64 = func.call @g_qrd_fixedPointMultiply(%l_x__j__148_d1_2,%tmp_66) : (i22,i22) -> i22
		cal.set(%l_r__142: !cal.state_ref<i22>, %tmp_64: i22)
		// Assignment Statement: End
		// Assignment Statement: Start
		%tmp_67 = cal.get(%l_count__143: !cal.state_ref<i32>) : i32
		%tmp_68 = arith.constant 1 : i1
		%tmp_69 = arith.extui %tmp_68 : i1 to i32
		%tmp_70 = arith.addi %tmp_67, %tmp_69 : i32
		cal.set(%l_count__143: !cal.state_ref<i32>, %tmp_70: i32)
		// Assignment Statement: End
		// Output Expression: Start
		fifo.push(%cordic_angles_out: !fifo.input_port<i16>, %l_rotation__angles__147_d1_1: i16)
		// Output Expression: End
	}
	// Generation action: $untagged1
	cal.action "$untagged1" priority=0 {
		// Guard: Start
		cal.predicate {
			%tmp_71 = cal.get(%l_count__143: !cal.state_ref<i32>) : i32
			// Evaluate global variable $eval1.
			%tmp_72 = arith.constant 4 : i3
			%tmp_73 = arith.extui %tmp_72 : i3 to i32
			// Evaluate global variable $eval1 done: assigned to tmp_73 above in this context.
			%tmp_74 = arith.cmpi eq, %tmp_71, %tmp_73 : i32
			cal.predicate_result %tmp_74 : i1
		}
		// Guard: End
		// Assignment Statement: Start
		%tmp_75 = arith.constant 0 : i1
		%tmp_76 = arith.extui %tmp_75 : i1 to i32
		cal.set(%l_count__143: !cal.state_ref<i32>, %tmp_76: i32)
		// Assignment Statement: End
		// Output Expression: Start
		%tmp_77 = cal.get(%l_r__142: !cal.state_ref<i22>) : i22
		fifo.push(%r_out: !fifo.input_port<i22>, %tmp_77: i22)
		// Output Expression: End
	}
}

//-- Definition of actor class: InnerCell
cal.actor @innerCells_q_0 ()
	ports_in(%x_in: !fifo.output_port<i22>,%cordic_angles_in: !fifo.output_port<i16>)
	ports_out(%x_out: !fifo.input_port<i22>,%r_out: !fifo.input_port<i22>,%cordic_angles_out: !fifo.input_port<i16>)
{
	// -- Actor body
	%l_r__154 = cal.create_state_var<i22> : !cal.state_ref<i22>
	%tmp_0 = arith.constant 0 : i1
	%tmp_1 = arith.extui %tmp_0 : i1 to i22
	cal.set(%l_r__154: !cal.state_ref<i22>, %tmp_1: i22)
	%l_count__155 = cal.create_state_var<i32> : !cal.state_ref<i32>
	%tmp_2 = arith.constant 0 : i1
	%tmp_3 = arith.extui %tmp_2 : i1 to i32
	cal.set(%l_count__155: !cal.state_ref<i32>, %tmp_3: i32)
	// Generation action: $untagged0
	cal.action "$untagged0" priority=0 {
		// Guard: Start
		cal.predicate {
			%tmp_4 = cal.get(%l_count__155: !cal.state_ref<i32>) : i32
			// Evaluate global variable $eval1.
			%tmp_5 = arith.constant 4 : i3
			%tmp_6 = arith.extui %tmp_5 : i3 to i32
			// Evaluate global variable $eval1 done: assigned to tmp_6 above in this context.
			%tmp_7 = arith.cmpi ult, %tmp_4, %tmp_6 : i32
			cal.predicate_result %tmp_7 : i1
		}
		// Guard: End
		// Input Pattern: Start
		%l_x__in__157_d1_0 = fifo.pop(%x_in: !fifo.output_port<i22>) : i22
		// Input Pattern: End
		// Input Pattern: Start
		%l_rotation__angles__160_d1_0 = fifo.pop(%cordic_angles_in: !fifo.output_port<i16>) : i16
		// Input Pattern: End
		// Action Local Variable Decl: Start
		%l_x__out__162_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_x__j__163_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_x__j__plus__1__164_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_x__j__shifted__165_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_y__j__166_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_y__j__plus__1__167_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_y__j__shifted__168_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// If Statement: Begin
		%tmp_8 = cal.get(%l_count__155: !cal.state_ref<i32>) : i32
		%tmp_9 = arith.constant 0 : i1
		%tmp_10 = arith.extui %tmp_9 : i1 to i32
		%tmp_11 = arith.cmpi eq, %tmp_8, %tmp_10 : i32
		scf.if %tmp_11 {
			// Assignment Statement: Start
			%tmp_12 = arith.constant 0 : i1
			%tmp_13 = arith.extui %tmp_12 : i1 to i22
			cal.set(%l_r__154: !cal.state_ref<i22>, %tmp_13: i22)
			// Assignment Statement: End
		} else {
		}
		// If Statement: End
		// Assignment Statement: Start
		// l_x__j__163_d1_1 aliased to l_x__in__157_d1_0
		// Assignment Statement: End
		// Assignment Statement: Start
		%tmp_14 = cal.get(%l_r__154: !cal.state_ref<i22>) : i22
		// l_y__j__166_d1_1 aliased to tmp_14
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
		%l_x__j__163_d1_2, %l_x__j__plus__1__164_d1_1, %l_x__j__shifted__165_d1_1, %l_y__j__166_d1_2, %l_y__j__plus__1__167_d1_1, %l_y__j__shifted__168_d1_1 = scf.for %l_j_d1_0 = %tmp_17_lb to %tmp_25_ub_plus_1 step %tmp_24_step
				iter_args(%l_x__j__163_d2_0 = %l_x__in__157_d1_0, %l_x__j__plus__1__164_d2_0 = %l_x__j__plus__1__164_d1_0, %l_x__j__shifted__165_d2_0 = %l_x__j__shifted__165_d1_0, %l_y__j__166_d2_0 = %tmp_14, %l_y__j__plus__1__167_d2_0 = %l_y__j__plus__1__167_d1_0, %l_y__j__shifted__168_d2_0 = %l_y__j__shifted__168_d1_0) -> (i22, i22, i22, i22, i22, i22) {
			%l_j_d2_0 = arith.index_cast %l_j_d1_0 : index to i32
			%l_j_d2_1 = arith.trunci %l_j_d2_0 : i32 to i8
			// Assignment Statement: Start
			%tmp_26 = arith.extui %l_j_d2_1 : i8 to i22
			%tmp_27 = arith.shrsi %l_y__j__166_d2_0, %tmp_26 : i22
			// l_y__j__shifted__168_d2_1 aliased to tmp_27
			// Assignment Statement: End
			// Assignment Statement: Start
			%tmp_28 = arith.extui %l_j_d2_1 : i8 to i22
			%tmp_29 = arith.shrsi %l_x__j__163_d2_0, %tmp_28 : i22
			// l_x__j__shifted__165_d2_1 aliased to tmp_29
			// Assignment Statement: End
			// If Statement: Begin
			%tmp_30 = arith.extui %l_j_d2_1 : i8 to i16
			%tmp_31 = arith.shrui %l_rotation__angles__160_d1_0, %tmp_30 : i16
			%tmp_32 = arith.constant 1 : i1
			%tmp_33 = arith.trunci %tmp_31 : i16 to i1
			%tmp_34 = arith.andi %tmp_33, %tmp_32 : i1
			%tmp_35 = arith.constant 1 : i1
			%tmp_36 = arith.cmpi eq, %tmp_34, %tmp_35 : i1
			%l_x__j__plus__1__164_d2_1, %l_y__j__plus__1__167_d2_1 = scf.if %tmp_36 -> (i22, i22) {
				// Assignment Statement: Start
				%tmp_37 = arith.extsi %l_x__j__163_d2_0 : i22 to i23
				%tmp_38 = arith.extsi %tmp_27 : i22 to i23
				%tmp_39 = arith.addi %tmp_37, %tmp_38 : i23
				%tmp_40 = arith.trunci %tmp_39 : i23 to i22
				// l_x__j__plus__1__164_d3_0 aliased to tmp_40
				// Assignment Statement: End
				// Assignment Statement: Start
				%tmp_41 = arith.subi %l_y__j__166_d2_0, %tmp_29 : i22
				// l_y__j__plus__1__167_d3_0 aliased to tmp_41
				// Assignment Statement: End
				scf.yield %tmp_40, %tmp_41 : i22, i22
			} else {
				// Assignment Statement: Start
				%tmp_42 = arith.subi %l_x__j__163_d2_0, %tmp_27 : i22
				// l_x__j__plus__1__164_d3_0 aliased to tmp_42
				// Assignment Statement: End
				// Assignment Statement: Start
				%tmp_43 = arith.extsi %l_y__j__166_d2_0 : i22 to i23
				%tmp_44 = arith.extsi %tmp_29 : i22 to i23
				%tmp_45 = arith.addi %tmp_43, %tmp_44 : i23
				%tmp_46 = arith.trunci %tmp_45 : i23 to i22
				// l_y__j__plus__1__167_d3_0 aliased to tmp_46
				// Assignment Statement: End
				scf.yield %tmp_42, %tmp_46 : i22, i22
			}
			// If Statement: End
			// Assignment Statement: Start
			// l_x__j__163_d2_1 aliased to l_x__j__plus__1__164_d2_1
			// Assignment Statement: End
			// Assignment Statement: Start
			// l_y__j__166_d2_1 aliased to l_y__j__plus__1__167_d2_1
			// Assignment Statement: End
			scf.yield %l_x__j__plus__1__164_d2_1, %l_x__j__plus__1__164_d2_1, %tmp_29, %l_y__j__plus__1__167_d2_1, %l_y__j__plus__1__167_d2_1, %tmp_27 : i22, i22, i22, i22, i22, i22
		}
		// Foreach Statement: End
		// Assignment Statement: Start
		// Evaluate global variable k_CORDIC_constant.
		%tmp_48 = arith.constant 318375 : i19
		%tmp_49 = arith.extui %tmp_48 : i19 to i22
		// Evaluate global variable k_CORDIC_constant done: assigned to tmp_49 above in this context.
		// Evaluate global variable fixedPointMultiply.
		%tmp_47 = func.call @g_qrd_fixedPointMultiply(%tmp_49,%l_y__j__166_d1_2) : (i22,i22) -> i22
		// l_x__out__162_d1_1 aliased to tmp_47
		// Assignment Statement: End
		// Assignment Statement: Start
		// Evaluate global variable k_CORDIC_constant.
		%tmp_51 = arith.constant 318375 : i19
		%tmp_52 = arith.extui %tmp_51 : i19 to i22
		// Evaluate global variable k_CORDIC_constant done: assigned to tmp_52 above in this context.
		// Evaluate global variable fixedPointMultiply.
		%tmp_50 = func.call @g_qrd_fixedPointMultiply(%tmp_52,%l_x__j__163_d1_2) : (i22,i22) -> i22
		cal.set(%l_r__154: !cal.state_ref<i22>, %tmp_50: i22)
		// Assignment Statement: End
		// Assignment Statement: Start
		%tmp_53 = cal.get(%l_count__155: !cal.state_ref<i32>) : i32
		%tmp_54 = arith.constant 1 : i1
		%tmp_55 = arith.extui %tmp_54 : i1 to i32
		%tmp_56 = arith.addi %tmp_53, %tmp_55 : i32
		cal.set(%l_count__155: !cal.state_ref<i32>, %tmp_56: i32)
		// Assignment Statement: End
		// Output Expression: Start
		fifo.push(%x_out: !fifo.input_port<i22>, %tmp_47: i22)
		// Output Expression: End
		// Output Expression: Start
		fifo.push(%cordic_angles_out: !fifo.input_port<i16>, %l_rotation__angles__160_d1_0: i16)
		// Output Expression: End
	}
	// Generation action: $untagged1
	cal.action "$untagged1" priority=0 {
		// Guard: Start
		cal.predicate {
			%tmp_57 = cal.get(%l_count__155: !cal.state_ref<i32>) : i32
			// Evaluate global variable $eval1.
			%tmp_58 = arith.constant 4 : i3
			%tmp_59 = arith.extui %tmp_58 : i3 to i32
			// Evaluate global variable $eval1 done: assigned to tmp_59 above in this context.
			%tmp_60 = arith.cmpi eq, %tmp_57, %tmp_59 : i32
			cal.predicate_result %tmp_60 : i1
		}
		// Guard: End
		// Assignment Statement: Start
		%tmp_61 = arith.constant 0 : i1
		%tmp_62 = arith.extui %tmp_61 : i1 to i32
		cal.set(%l_count__155: !cal.state_ref<i32>, %tmp_62: i32)
		// Assignment Statement: End
		// Output Expression: Start
		%tmp_63 = cal.get(%l_r__154: !cal.state_ref<i22>) : i22
		fifo.push(%r_out: !fifo.input_port<i22>, %tmp_63: i22)
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
		%l_t__39_d1_0 = fifo.pop(%In: !fifo.output_port<i16>) : i16
		// Input Pattern: End
	}
}

//-- Definition of actor class: BoundaryCell
cal.actor @boundaryCells_0 ()
	ports_in(%x_in: !fifo.output_port<i22>)
	ports_out(%r_out: !fifo.input_port<i22>,%cordic_angles_out: !fifo.input_port<i16>)
{
	// -- Actor body
	%l_r__142 = cal.create_state_var<i22> : !cal.state_ref<i22>
	%tmp_0 = arith.constant 0 : i1
	%tmp_1 = arith.extui %tmp_0 : i1 to i22
	cal.set(%l_r__142: !cal.state_ref<i22>, %tmp_1: i22)
	%l_count__143 = cal.create_state_var<i32> : !cal.state_ref<i32>
	%tmp_2 = arith.constant 0 : i1
	%tmp_3 = arith.extui %tmp_2 : i1 to i32
	cal.set(%l_count__143: !cal.state_ref<i32>, %tmp_3: i32)
	// Generation action: $untagged0
	cal.action "$untagged0" priority=0 {
		// Guard: Start
		cal.predicate {
			%tmp_4 = cal.get(%l_count__143: !cal.state_ref<i32>) : i32
			// Evaluate global variable $eval1.
			%tmp_5 = arith.constant 4 : i3
			%tmp_6 = arith.extui %tmp_5 : i3 to i32
			// Evaluate global variable $eval1 done: assigned to tmp_6 above in this context.
			%tmp_7 = arith.cmpi ult, %tmp_4, %tmp_6 : i32
			cal.predicate_result %tmp_7 : i1
		}
		// Guard: End
		// Input Pattern: Start
		%l_x__in__145_d1_0 = fifo.pop(%x_in: !fifo.output_port<i22>) : i22
		// Input Pattern: End
		// Action Local Variable Decl: Start
		%l_x__j__148_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_x__j__plus__1__149_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_x__j__shifted__150_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_y__j__151_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_y__j__plus__1__152_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_y__j__shifted__153_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%tmp_8 = arith.constant 0 : i1
		%tmp_9 = arith.extui %tmp_8 : i1 to i16
		// l_rotation__angles__147_d1_0 aliased to tmp_9
		// Action Local Variable Decl: End
		// If Statement: Begin
		%tmp_10 = cal.get(%l_count__143: !cal.state_ref<i32>) : i32
		%tmp_11 = arith.constant 0 : i1
		%tmp_12 = arith.extui %tmp_11 : i1 to i32
		%tmp_13 = arith.cmpi eq, %tmp_10, %tmp_12 : i32
		scf.if %tmp_13 {
			// Assignment Statement: Start
			%tmp_14 = arith.constant 0 : i1
			%tmp_15 = arith.extui %tmp_14 : i1 to i22
			cal.set(%l_r__142: !cal.state_ref<i22>, %tmp_15: i22)
			// Assignment Statement: End
		} else {
		}
		// If Statement: End
		// Assignment Statement: Start
		// l_x__j__148_d1_1 aliased to l_x__in__145_d1_0
		// Assignment Statement: End
		// Assignment Statement: Start
		%tmp_16 = cal.get(%l_r__142: !cal.state_ref<i22>) : i22
		// l_y__j__151_d1_1 aliased to tmp_16
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
		%l_rotation__angles__147_d1_1, %l_x__j__148_d1_2, %l_x__j__plus__1__149_d1_1, %l_x__j__shifted__150_d1_1, %l_y__j__151_d1_2, %l_y__j__plus__1__152_d1_1, %l_y__j__shifted__153_d1_1 = scf.for %l_j_d1_0 = %tmp_19_lb to %tmp_27_ub_plus_1 step %tmp_26_step
				iter_args(%l_rotation__angles__147_d2_0 = %tmp_9, %l_x__j__148_d2_0 = %l_x__in__145_d1_0, %l_x__j__plus__1__149_d2_0 = %l_x__j__plus__1__149_d1_0, %l_x__j__shifted__150_d2_0 = %l_x__j__shifted__150_d1_0, %l_y__j__151_d2_0 = %tmp_16, %l_y__j__plus__1__152_d2_0 = %l_y__j__plus__1__152_d1_0, %l_y__j__shifted__153_d2_0 = %l_y__j__shifted__153_d1_0) -> (i16, i22, i22, i22, i22, i22, i22) {
			%l_j_d2_0 = arith.index_cast %l_j_d1_0 : index to i32
			%l_j_d2_1 = arith.trunci %l_j_d2_0 : i32 to i8
			// Assignment Statement: Start
			%tmp_28 = arith.extui %l_j_d2_1 : i8 to i22
			%tmp_29 = arith.shrsi %l_y__j__151_d2_0, %tmp_28 : i22
			// l_y__j__shifted__153_d2_1 aliased to tmp_29
			// Assignment Statement: End
			// Assignment Statement: Start
			%tmp_30 = arith.extui %l_j_d2_1 : i8 to i22
			%tmp_31 = arith.shrsi %l_x__j__148_d2_0, %tmp_30 : i22
			// l_x__j__shifted__150_d2_1 aliased to tmp_31
			// Assignment Statement: End
			// If Statement: Begin
			%tmp_32 = arith.constant 0 : i1
			%tmp_33 = arith.extui %tmp_32 : i1 to i22
			%tmp_34 = arith.cmpi sgt, %l_x__j__148_d2_0, %tmp_33 : i22
			%tmp_35 = arith.constant 0 : i1
			%tmp_36 = arith.extui %tmp_35 : i1 to i22
			%tmp_37 = arith.cmpi sgt, %l_y__j__151_d2_0, %tmp_36 : i22
			%tmp_38 = arith.andi %tmp_34, %tmp_37 : i1
			%tmp_39 = arith.constant 0 : i1
			%tmp_40 = arith.extui %tmp_39 : i1 to i22
			%tmp_41 = arith.cmpi slt, %l_x__j__148_d2_0, %tmp_40 : i22
			%tmp_42 = arith.constant 0 : i1
			%tmp_43 = arith.extui %tmp_42 : i1 to i22
			%tmp_44 = arith.cmpi slt, %l_y__j__151_d2_0, %tmp_43 : i22
			%tmp_45 = arith.andi %tmp_41, %tmp_44 : i1
			%tmp_46 = arith.ori %tmp_38, %tmp_45 : i1
			%l_rotation__angles__147_d2_1, %l_x__j__plus__1__149_d2_1, %l_y__j__plus__1__152_d2_1 = scf.if %tmp_46 -> (i16, i22, i22) {
				// Assignment Statement: Start
				%tmp_47 = arith.extsi %l_x__j__148_d2_0 : i22 to i23
				%tmp_48 = arith.extsi %tmp_29 : i22 to i23
				%tmp_49 = arith.addi %tmp_47, %tmp_48 : i23
				%tmp_50 = arith.trunci %tmp_49 : i23 to i22
				// l_x__j__plus__1__149_d3_0 aliased to tmp_50
				// Assignment Statement: End
				// Assignment Statement: Start
				%tmp_51 = arith.subi %l_y__j__151_d2_0, %tmp_31 : i22
				// l_y__j__plus__1__152_d3_0 aliased to tmp_51
				// Assignment Statement: End
				// Assignment Statement: Start
				%tmp_52 = arith.constant 1 : i1
				%tmp_53 = arith.extui %tmp_52 : i1 to i64
				%tmp_54 = arith.extui %l_j_d2_1 : i8 to i64
				%tmp_55 = arith.shli %tmp_53, %tmp_54 : i64
				%tmp_56 = arith.extui %l_rotation__angles__147_d2_0 : i16 to i64
				%tmp_57 = arith.ori %tmp_56, %tmp_55 : i64
				%tmp_58 = arith.trunci %tmp_57 : i64 to i16
				// l_rotation__angles__147_d3_0 aliased to tmp_58
				// Assignment Statement: End
				scf.yield %tmp_58, %tmp_50, %tmp_51 : i16, i22, i22
			} else {
				// Assignment Statement: Start
				%tmp_59 = arith.subi %l_x__j__148_d2_0, %tmp_29 : i22
				// l_x__j__plus__1__149_d3_0 aliased to tmp_59
				// Assignment Statement: End
				// Assignment Statement: Start
				%tmp_60 = arith.extsi %l_y__j__151_d2_0 : i22 to i23
				%tmp_61 = arith.extsi %tmp_31 : i22 to i23
				%tmp_62 = arith.addi %tmp_60, %tmp_61 : i23
				%tmp_63 = arith.trunci %tmp_62 : i23 to i22
				// l_y__j__plus__1__152_d3_0 aliased to tmp_63
				// Assignment Statement: End
				scf.yield %l_rotation__angles__147_d2_0, %tmp_59, %tmp_63 : i16, i22, i22
			}
			// If Statement: End
			// Assignment Statement: Start
			// l_x__j__148_d2_1 aliased to l_x__j__plus__1__149_d2_1
			// Assignment Statement: End
			// Assignment Statement: Start
			// l_y__j__151_d2_1 aliased to l_y__j__plus__1__152_d2_1
			// Assignment Statement: End
			scf.yield %l_rotation__angles__147_d2_1, %l_x__j__plus__1__149_d2_1, %l_x__j__plus__1__149_d2_1, %tmp_31, %l_y__j__plus__1__152_d2_1, %l_y__j__plus__1__152_d2_1, %tmp_29 : i16, i22, i22, i22, i22, i22, i22
		}
		// Foreach Statement: End
		// Assignment Statement: Start
		// Evaluate global variable k_CORDIC_constant.
		%tmp_65 = arith.constant 318375 : i19
		%tmp_66 = arith.extui %tmp_65 : i19 to i22
		// Evaluate global variable k_CORDIC_constant done: assigned to tmp_66 above in this context.
		// Evaluate global variable fixedPointMultiply.
		%tmp_64 = func.call @g_qrd_fixedPointMultiply(%l_x__j__148_d1_2,%tmp_66) : (i22,i22) -> i22
		cal.set(%l_r__142: !cal.state_ref<i22>, %tmp_64: i22)
		// Assignment Statement: End
		// Assignment Statement: Start
		%tmp_67 = cal.get(%l_count__143: !cal.state_ref<i32>) : i32
		%tmp_68 = arith.constant 1 : i1
		%tmp_69 = arith.extui %tmp_68 : i1 to i32
		%tmp_70 = arith.addi %tmp_67, %tmp_69 : i32
		cal.set(%l_count__143: !cal.state_ref<i32>, %tmp_70: i32)
		// Assignment Statement: End
		// Output Expression: Start
		fifo.push(%cordic_angles_out: !fifo.input_port<i16>, %l_rotation__angles__147_d1_1: i16)
		// Output Expression: End
	}
	// Generation action: $untagged1
	cal.action "$untagged1" priority=0 {
		// Guard: Start
		cal.predicate {
			%tmp_71 = cal.get(%l_count__143: !cal.state_ref<i32>) : i32
			// Evaluate global variable $eval1.
			%tmp_72 = arith.constant 4 : i3
			%tmp_73 = arith.extui %tmp_72 : i3 to i32
			// Evaluate global variable $eval1 done: assigned to tmp_73 above in this context.
			%tmp_74 = arith.cmpi eq, %tmp_71, %tmp_73 : i32
			cal.predicate_result %tmp_74 : i1
		}
		// Guard: End
		// Assignment Statement: Start
		%tmp_75 = arith.constant 0 : i1
		%tmp_76 = arith.extui %tmp_75 : i1 to i32
		cal.set(%l_count__143: !cal.state_ref<i32>, %tmp_76: i32)
		// Assignment Statement: End
		// Output Expression: Start
		%tmp_77 = cal.get(%l_r__142: !cal.state_ref<i22>) : i22
		fifo.push(%r_out: !fifo.input_port<i22>, %tmp_77: i22)
		// Output Expression: End
	}
}

//-- Definition of actor class: InnerCell
cal.actor @innerCells_q_1 ()
	ports_in(%x_in: !fifo.output_port<i22>,%cordic_angles_in: !fifo.output_port<i16>)
	ports_out(%x_out: !fifo.input_port<i22>,%r_out: !fifo.input_port<i22>,%cordic_angles_out: !fifo.input_port<i16>)
{
	// -- Actor body
	%l_r__154 = cal.create_state_var<i22> : !cal.state_ref<i22>
	%tmp_0 = arith.constant 0 : i1
	%tmp_1 = arith.extui %tmp_0 : i1 to i22
	cal.set(%l_r__154: !cal.state_ref<i22>, %tmp_1: i22)
	%l_count__155 = cal.create_state_var<i32> : !cal.state_ref<i32>
	%tmp_2 = arith.constant 0 : i1
	%tmp_3 = arith.extui %tmp_2 : i1 to i32
	cal.set(%l_count__155: !cal.state_ref<i32>, %tmp_3: i32)
	// Generation action: $untagged0
	cal.action "$untagged0" priority=0 {
		// Guard: Start
		cal.predicate {
			%tmp_4 = cal.get(%l_count__155: !cal.state_ref<i32>) : i32
			// Evaluate global variable $eval1.
			%tmp_5 = arith.constant 4 : i3
			%tmp_6 = arith.extui %tmp_5 : i3 to i32
			// Evaluate global variable $eval1 done: assigned to tmp_6 above in this context.
			%tmp_7 = arith.cmpi ult, %tmp_4, %tmp_6 : i32
			cal.predicate_result %tmp_7 : i1
		}
		// Guard: End
		// Input Pattern: Start
		%l_x__in__157_d1_0 = fifo.pop(%x_in: !fifo.output_port<i22>) : i22
		// Input Pattern: End
		// Input Pattern: Start
		%l_rotation__angles__160_d1_0 = fifo.pop(%cordic_angles_in: !fifo.output_port<i16>) : i16
		// Input Pattern: End
		// Action Local Variable Decl: Start
		%l_x__out__162_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_x__j__163_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_x__j__plus__1__164_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_x__j__shifted__165_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_y__j__166_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_y__j__plus__1__167_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_y__j__shifted__168_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// If Statement: Begin
		%tmp_8 = cal.get(%l_count__155: !cal.state_ref<i32>) : i32
		%tmp_9 = arith.constant 0 : i1
		%tmp_10 = arith.extui %tmp_9 : i1 to i32
		%tmp_11 = arith.cmpi eq, %tmp_8, %tmp_10 : i32
		scf.if %tmp_11 {
			// Assignment Statement: Start
			%tmp_12 = arith.constant 0 : i1
			%tmp_13 = arith.extui %tmp_12 : i1 to i22
			cal.set(%l_r__154: !cal.state_ref<i22>, %tmp_13: i22)
			// Assignment Statement: End
		} else {
		}
		// If Statement: End
		// Assignment Statement: Start
		// l_x__j__163_d1_1 aliased to l_x__in__157_d1_0
		// Assignment Statement: End
		// Assignment Statement: Start
		%tmp_14 = cal.get(%l_r__154: !cal.state_ref<i22>) : i22
		// l_y__j__166_d1_1 aliased to tmp_14
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
		%l_x__j__163_d1_2, %l_x__j__plus__1__164_d1_1, %l_x__j__shifted__165_d1_1, %l_y__j__166_d1_2, %l_y__j__plus__1__167_d1_1, %l_y__j__shifted__168_d1_1 = scf.for %l_j_d1_0 = %tmp_17_lb to %tmp_25_ub_plus_1 step %tmp_24_step
				iter_args(%l_x__j__163_d2_0 = %l_x__in__157_d1_0, %l_x__j__plus__1__164_d2_0 = %l_x__j__plus__1__164_d1_0, %l_x__j__shifted__165_d2_0 = %l_x__j__shifted__165_d1_0, %l_y__j__166_d2_0 = %tmp_14, %l_y__j__plus__1__167_d2_0 = %l_y__j__plus__1__167_d1_0, %l_y__j__shifted__168_d2_0 = %l_y__j__shifted__168_d1_0) -> (i22, i22, i22, i22, i22, i22) {
			%l_j_d2_0 = arith.index_cast %l_j_d1_0 : index to i32
			%l_j_d2_1 = arith.trunci %l_j_d2_0 : i32 to i8
			// Assignment Statement: Start
			%tmp_26 = arith.extui %l_j_d2_1 : i8 to i22
			%tmp_27 = arith.shrsi %l_y__j__166_d2_0, %tmp_26 : i22
			// l_y__j__shifted__168_d2_1 aliased to tmp_27
			// Assignment Statement: End
			// Assignment Statement: Start
			%tmp_28 = arith.extui %l_j_d2_1 : i8 to i22
			%tmp_29 = arith.shrsi %l_x__j__163_d2_0, %tmp_28 : i22
			// l_x__j__shifted__165_d2_1 aliased to tmp_29
			// Assignment Statement: End
			// If Statement: Begin
			%tmp_30 = arith.extui %l_j_d2_1 : i8 to i16
			%tmp_31 = arith.shrui %l_rotation__angles__160_d1_0, %tmp_30 : i16
			%tmp_32 = arith.constant 1 : i1
			%tmp_33 = arith.trunci %tmp_31 : i16 to i1
			%tmp_34 = arith.andi %tmp_33, %tmp_32 : i1
			%tmp_35 = arith.constant 1 : i1
			%tmp_36 = arith.cmpi eq, %tmp_34, %tmp_35 : i1
			%l_x__j__plus__1__164_d2_1, %l_y__j__plus__1__167_d2_1 = scf.if %tmp_36 -> (i22, i22) {
				// Assignment Statement: Start
				%tmp_37 = arith.extsi %l_x__j__163_d2_0 : i22 to i23
				%tmp_38 = arith.extsi %tmp_27 : i22 to i23
				%tmp_39 = arith.addi %tmp_37, %tmp_38 : i23
				%tmp_40 = arith.trunci %tmp_39 : i23 to i22
				// l_x__j__plus__1__164_d3_0 aliased to tmp_40
				// Assignment Statement: End
				// Assignment Statement: Start
				%tmp_41 = arith.subi %l_y__j__166_d2_0, %tmp_29 : i22
				// l_y__j__plus__1__167_d3_0 aliased to tmp_41
				// Assignment Statement: End
				scf.yield %tmp_40, %tmp_41 : i22, i22
			} else {
				// Assignment Statement: Start
				%tmp_42 = arith.subi %l_x__j__163_d2_0, %tmp_27 : i22
				// l_x__j__plus__1__164_d3_0 aliased to tmp_42
				// Assignment Statement: End
				// Assignment Statement: Start
				%tmp_43 = arith.extsi %l_y__j__166_d2_0 : i22 to i23
				%tmp_44 = arith.extsi %tmp_29 : i22 to i23
				%tmp_45 = arith.addi %tmp_43, %tmp_44 : i23
				%tmp_46 = arith.trunci %tmp_45 : i23 to i22
				// l_y__j__plus__1__167_d3_0 aliased to tmp_46
				// Assignment Statement: End
				scf.yield %tmp_42, %tmp_46 : i22, i22
			}
			// If Statement: End
			// Assignment Statement: Start
			// l_x__j__163_d2_1 aliased to l_x__j__plus__1__164_d2_1
			// Assignment Statement: End
			// Assignment Statement: Start
			// l_y__j__166_d2_1 aliased to l_y__j__plus__1__167_d2_1
			// Assignment Statement: End
			scf.yield %l_x__j__plus__1__164_d2_1, %l_x__j__plus__1__164_d2_1, %tmp_29, %l_y__j__plus__1__167_d2_1, %l_y__j__plus__1__167_d2_1, %tmp_27 : i22, i22, i22, i22, i22, i22
		}
		// Foreach Statement: End
		// Assignment Statement: Start
		// Evaluate global variable k_CORDIC_constant.
		%tmp_48 = arith.constant 318375 : i19
		%tmp_49 = arith.extui %tmp_48 : i19 to i22
		// Evaluate global variable k_CORDIC_constant done: assigned to tmp_49 above in this context.
		// Evaluate global variable fixedPointMultiply.
		%tmp_47 = func.call @g_qrd_fixedPointMultiply(%tmp_49,%l_y__j__166_d1_2) : (i22,i22) -> i22
		// l_x__out__162_d1_1 aliased to tmp_47
		// Assignment Statement: End
		// Assignment Statement: Start
		// Evaluate global variable k_CORDIC_constant.
		%tmp_51 = arith.constant 318375 : i19
		%tmp_52 = arith.extui %tmp_51 : i19 to i22
		// Evaluate global variable k_CORDIC_constant done: assigned to tmp_52 above in this context.
		// Evaluate global variable fixedPointMultiply.
		%tmp_50 = func.call @g_qrd_fixedPointMultiply(%tmp_52,%l_x__j__163_d1_2) : (i22,i22) -> i22
		cal.set(%l_r__154: !cal.state_ref<i22>, %tmp_50: i22)
		// Assignment Statement: End
		// Assignment Statement: Start
		%tmp_53 = cal.get(%l_count__155: !cal.state_ref<i32>) : i32
		%tmp_54 = arith.constant 1 : i1
		%tmp_55 = arith.extui %tmp_54 : i1 to i32
		%tmp_56 = arith.addi %tmp_53, %tmp_55 : i32
		cal.set(%l_count__155: !cal.state_ref<i32>, %tmp_56: i32)
		// Assignment Statement: End
		// Output Expression: Start
		fifo.push(%x_out: !fifo.input_port<i22>, %tmp_47: i22)
		// Output Expression: End
		// Output Expression: Start
		fifo.push(%cordic_angles_out: !fifo.input_port<i16>, %l_rotation__angles__160_d1_0: i16)
		// Output Expression: End
	}
	// Generation action: $untagged1
	cal.action "$untagged1" priority=0 {
		// Guard: Start
		cal.predicate {
			%tmp_57 = cal.get(%l_count__155: !cal.state_ref<i32>) : i32
			// Evaluate global variable $eval1.
			%tmp_58 = arith.constant 4 : i3
			%tmp_59 = arith.extui %tmp_58 : i3 to i32
			// Evaluate global variable $eval1 done: assigned to tmp_59 above in this context.
			%tmp_60 = arith.cmpi eq, %tmp_57, %tmp_59 : i32
			cal.predicate_result %tmp_60 : i1
		}
		// Guard: End
		// Assignment Statement: Start
		%tmp_61 = arith.constant 0 : i1
		%tmp_62 = arith.extui %tmp_61 : i1 to i32
		cal.set(%l_count__155: !cal.state_ref<i32>, %tmp_62: i32)
		// Assignment Statement: End
		// Output Expression: Start
		%tmp_63 = cal.get(%l_r__154: !cal.state_ref<i22>) : i22
		fifo.push(%r_out: !fifo.input_port<i22>, %tmp_63: i22)
		// Output Expression: End
	}
}

//-- Definition of actor class: BoundaryCell
cal.actor @boundaryCells_3 ()
	ports_in(%x_in: !fifo.output_port<i22>)
	ports_out(%r_out: !fifo.input_port<i22>,%cordic_angles_out: !fifo.input_port<i16>)
{
	// -- Actor body
	%l_r__142 = cal.create_state_var<i22> : !cal.state_ref<i22>
	%tmp_0 = arith.constant 0 : i1
	%tmp_1 = arith.extui %tmp_0 : i1 to i22
	cal.set(%l_r__142: !cal.state_ref<i22>, %tmp_1: i22)
	%l_count__143 = cal.create_state_var<i32> : !cal.state_ref<i32>
	%tmp_2 = arith.constant 0 : i1
	%tmp_3 = arith.extui %tmp_2 : i1 to i32
	cal.set(%l_count__143: !cal.state_ref<i32>, %tmp_3: i32)
	// Generation action: $untagged0
	cal.action "$untagged0" priority=0 {
		// Guard: Start
		cal.predicate {
			%tmp_4 = cal.get(%l_count__143: !cal.state_ref<i32>) : i32
			// Evaluate global variable $eval1.
			%tmp_5 = arith.constant 4 : i3
			%tmp_6 = arith.extui %tmp_5 : i3 to i32
			// Evaluate global variable $eval1 done: assigned to tmp_6 above in this context.
			%tmp_7 = arith.cmpi ult, %tmp_4, %tmp_6 : i32
			cal.predicate_result %tmp_7 : i1
		}
		// Guard: End
		// Input Pattern: Start
		%l_x__in__145_d1_0 = fifo.pop(%x_in: !fifo.output_port<i22>) : i22
		// Input Pattern: End
		// Action Local Variable Decl: Start
		%l_x__j__148_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_x__j__plus__1__149_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_x__j__shifted__150_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_y__j__151_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_y__j__plus__1__152_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_y__j__shifted__153_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%tmp_8 = arith.constant 0 : i1
		%tmp_9 = arith.extui %tmp_8 : i1 to i16
		// l_rotation__angles__147_d1_0 aliased to tmp_9
		// Action Local Variable Decl: End
		// If Statement: Begin
		%tmp_10 = cal.get(%l_count__143: !cal.state_ref<i32>) : i32
		%tmp_11 = arith.constant 0 : i1
		%tmp_12 = arith.extui %tmp_11 : i1 to i32
		%tmp_13 = arith.cmpi eq, %tmp_10, %tmp_12 : i32
		scf.if %tmp_13 {
			// Assignment Statement: Start
			%tmp_14 = arith.constant 0 : i1
			%tmp_15 = arith.extui %tmp_14 : i1 to i22
			cal.set(%l_r__142: !cal.state_ref<i22>, %tmp_15: i22)
			// Assignment Statement: End
		} else {
		}
		// If Statement: End
		// Assignment Statement: Start
		// l_x__j__148_d1_1 aliased to l_x__in__145_d1_0
		// Assignment Statement: End
		// Assignment Statement: Start
		%tmp_16 = cal.get(%l_r__142: !cal.state_ref<i22>) : i22
		// l_y__j__151_d1_1 aliased to tmp_16
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
		%l_rotation__angles__147_d1_1, %l_x__j__148_d1_2, %l_x__j__plus__1__149_d1_1, %l_x__j__shifted__150_d1_1, %l_y__j__151_d1_2, %l_y__j__plus__1__152_d1_1, %l_y__j__shifted__153_d1_1 = scf.for %l_j_d1_0 = %tmp_19_lb to %tmp_27_ub_plus_1 step %tmp_26_step
				iter_args(%l_rotation__angles__147_d2_0 = %tmp_9, %l_x__j__148_d2_0 = %l_x__in__145_d1_0, %l_x__j__plus__1__149_d2_0 = %l_x__j__plus__1__149_d1_0, %l_x__j__shifted__150_d2_0 = %l_x__j__shifted__150_d1_0, %l_y__j__151_d2_0 = %tmp_16, %l_y__j__plus__1__152_d2_0 = %l_y__j__plus__1__152_d1_0, %l_y__j__shifted__153_d2_0 = %l_y__j__shifted__153_d1_0) -> (i16, i22, i22, i22, i22, i22, i22) {
			%l_j_d2_0 = arith.index_cast %l_j_d1_0 : index to i32
			%l_j_d2_1 = arith.trunci %l_j_d2_0 : i32 to i8
			// Assignment Statement: Start
			%tmp_28 = arith.extui %l_j_d2_1 : i8 to i22
			%tmp_29 = arith.shrsi %l_y__j__151_d2_0, %tmp_28 : i22
			// l_y__j__shifted__153_d2_1 aliased to tmp_29
			// Assignment Statement: End
			// Assignment Statement: Start
			%tmp_30 = arith.extui %l_j_d2_1 : i8 to i22
			%tmp_31 = arith.shrsi %l_x__j__148_d2_0, %tmp_30 : i22
			// l_x__j__shifted__150_d2_1 aliased to tmp_31
			// Assignment Statement: End
			// If Statement: Begin
			%tmp_32 = arith.constant 0 : i1
			%tmp_33 = arith.extui %tmp_32 : i1 to i22
			%tmp_34 = arith.cmpi sgt, %l_x__j__148_d2_0, %tmp_33 : i22
			%tmp_35 = arith.constant 0 : i1
			%tmp_36 = arith.extui %tmp_35 : i1 to i22
			%tmp_37 = arith.cmpi sgt, %l_y__j__151_d2_0, %tmp_36 : i22
			%tmp_38 = arith.andi %tmp_34, %tmp_37 : i1
			%tmp_39 = arith.constant 0 : i1
			%tmp_40 = arith.extui %tmp_39 : i1 to i22
			%tmp_41 = arith.cmpi slt, %l_x__j__148_d2_0, %tmp_40 : i22
			%tmp_42 = arith.constant 0 : i1
			%tmp_43 = arith.extui %tmp_42 : i1 to i22
			%tmp_44 = arith.cmpi slt, %l_y__j__151_d2_0, %tmp_43 : i22
			%tmp_45 = arith.andi %tmp_41, %tmp_44 : i1
			%tmp_46 = arith.ori %tmp_38, %tmp_45 : i1
			%l_rotation__angles__147_d2_1, %l_x__j__plus__1__149_d2_1, %l_y__j__plus__1__152_d2_1 = scf.if %tmp_46 -> (i16, i22, i22) {
				// Assignment Statement: Start
				%tmp_47 = arith.extsi %l_x__j__148_d2_0 : i22 to i23
				%tmp_48 = arith.extsi %tmp_29 : i22 to i23
				%tmp_49 = arith.addi %tmp_47, %tmp_48 : i23
				%tmp_50 = arith.trunci %tmp_49 : i23 to i22
				// l_x__j__plus__1__149_d3_0 aliased to tmp_50
				// Assignment Statement: End
				// Assignment Statement: Start
				%tmp_51 = arith.subi %l_y__j__151_d2_0, %tmp_31 : i22
				// l_y__j__plus__1__152_d3_0 aliased to tmp_51
				// Assignment Statement: End
				// Assignment Statement: Start
				%tmp_52 = arith.constant 1 : i1
				%tmp_53 = arith.extui %tmp_52 : i1 to i64
				%tmp_54 = arith.extui %l_j_d2_1 : i8 to i64
				%tmp_55 = arith.shli %tmp_53, %tmp_54 : i64
				%tmp_56 = arith.extui %l_rotation__angles__147_d2_0 : i16 to i64
				%tmp_57 = arith.ori %tmp_56, %tmp_55 : i64
				%tmp_58 = arith.trunci %tmp_57 : i64 to i16
				// l_rotation__angles__147_d3_0 aliased to tmp_58
				// Assignment Statement: End
				scf.yield %tmp_58, %tmp_50, %tmp_51 : i16, i22, i22
			} else {
				// Assignment Statement: Start
				%tmp_59 = arith.subi %l_x__j__148_d2_0, %tmp_29 : i22
				// l_x__j__plus__1__149_d3_0 aliased to tmp_59
				// Assignment Statement: End
				// Assignment Statement: Start
				%tmp_60 = arith.extsi %l_y__j__151_d2_0 : i22 to i23
				%tmp_61 = arith.extsi %tmp_31 : i22 to i23
				%tmp_62 = arith.addi %tmp_60, %tmp_61 : i23
				%tmp_63 = arith.trunci %tmp_62 : i23 to i22
				// l_y__j__plus__1__152_d3_0 aliased to tmp_63
				// Assignment Statement: End
				scf.yield %l_rotation__angles__147_d2_0, %tmp_59, %tmp_63 : i16, i22, i22
			}
			// If Statement: End
			// Assignment Statement: Start
			// l_x__j__148_d2_1 aliased to l_x__j__plus__1__149_d2_1
			// Assignment Statement: End
			// Assignment Statement: Start
			// l_y__j__151_d2_1 aliased to l_y__j__plus__1__152_d2_1
			// Assignment Statement: End
			scf.yield %l_rotation__angles__147_d2_1, %l_x__j__plus__1__149_d2_1, %l_x__j__plus__1__149_d2_1, %tmp_31, %l_y__j__plus__1__152_d2_1, %l_y__j__plus__1__152_d2_1, %tmp_29 : i16, i22, i22, i22, i22, i22, i22
		}
		// Foreach Statement: End
		// Assignment Statement: Start
		// Evaluate global variable k_CORDIC_constant.
		%tmp_65 = arith.constant 318375 : i19
		%tmp_66 = arith.extui %tmp_65 : i19 to i22
		// Evaluate global variable k_CORDIC_constant done: assigned to tmp_66 above in this context.
		// Evaluate global variable fixedPointMultiply.
		%tmp_64 = func.call @g_qrd_fixedPointMultiply(%l_x__j__148_d1_2,%tmp_66) : (i22,i22) -> i22
		cal.set(%l_r__142: !cal.state_ref<i22>, %tmp_64: i22)
		// Assignment Statement: End
		// Assignment Statement: Start
		%tmp_67 = cal.get(%l_count__143: !cal.state_ref<i32>) : i32
		%tmp_68 = arith.constant 1 : i1
		%tmp_69 = arith.extui %tmp_68 : i1 to i32
		%tmp_70 = arith.addi %tmp_67, %tmp_69 : i32
		cal.set(%l_count__143: !cal.state_ref<i32>, %tmp_70: i32)
		// Assignment Statement: End
		// Output Expression: Start
		fifo.push(%cordic_angles_out: !fifo.input_port<i16>, %l_rotation__angles__147_d1_1: i16)
		// Output Expression: End
	}
	// Generation action: $untagged1
	cal.action "$untagged1" priority=0 {
		// Guard: Start
		cal.predicate {
			%tmp_71 = cal.get(%l_count__143: !cal.state_ref<i32>) : i32
			// Evaluate global variable $eval1.
			%tmp_72 = arith.constant 4 : i3
			%tmp_73 = arith.extui %tmp_72 : i3 to i32
			// Evaluate global variable $eval1 done: assigned to tmp_73 above in this context.
			%tmp_74 = arith.cmpi eq, %tmp_71, %tmp_73 : i32
			cal.predicate_result %tmp_74 : i1
		}
		// Guard: End
		// Assignment Statement: Start
		%tmp_75 = arith.constant 0 : i1
		%tmp_76 = arith.extui %tmp_75 : i1 to i32
		cal.set(%l_count__143: !cal.state_ref<i32>, %tmp_76: i32)
		// Assignment Statement: End
		// Output Expression: Start
		%tmp_77 = cal.get(%l_r__142: !cal.state_ref<i22>) : i22
		fifo.push(%r_out: !fifo.input_port<i22>, %tmp_77: i22)
		// Output Expression: End
	}
}

//-- Definition of actor class: Source
cal.actor @source ()
	ports_out(%Out_array_0_x: !fifo.input_port<i22>,%Out_array_1_x: !fifo.input_port<i22>,%Out_array_2_x: !fifo.input_port<i22>,%Out_array_3_x: !fifo.input_port<i22>)
{
	// -- Actor body
	%l_row__index__44 = cal.create_state_var<i32> : !cal.state_ref<i32>
	%tmp_0 = arith.constant 0 : i1
	%tmp_1 = arith.extui %tmp_0 : i1 to i32
	cal.set(%l_row__index__44: !cal.state_ref<i32>, %tmp_1: i32)
	%l_matrix__number__45 = cal.create_state_var<i32> : !cal.state_ref<i32>
	%tmp_2 = arith.constant 0 : i1
	%tmp_3 = arith.extui %tmp_2 : i1 to i32
	cal.set(%l_matrix__number__45: !cal.state_ref<i32>, %tmp_3: i32)
	%l_next__46 = cal.create_state_var<i22> : !cal.state_ref<i22>
	// Evaluate global variable fp_increment.
	%tmp_4 = arith.constant 57671 : i16
	%tmp_5 = arith.extui %tmp_4 : i16 to i22
	// Evaluate global variable fp_increment done: assigned to tmp_5 above in this context.
	cal.set(%l_next__46: !cal.state_ref<i22>, %tmp_5: i22)
	// Generation action: transmit
	cal.action "transmit" priority=0 {
		// Guard: Start
		cal.predicate {
			%tmp_6 = cal.get(%l_matrix__number__45: !cal.state_ref<i32>) : i32
			// Evaluate global variable num_matrices.
			%tmp_7 = arith.constant 10000 : i14
			%tmp_8 = arith.extui %tmp_7 : i14 to i32
			// Evaluate global variable num_matrices done: assigned to tmp_8 above in this context.
			%tmp_9 = arith.cmpi slt, %tmp_6, %tmp_8 : i32
			cal.predicate_result %tmp_9 : i1
		}
		// Guard: End
		// Action Local Variable Decl: Start
		%l_output__47_d1_0 = memref.alloc() : memref<4xi32>
		// Action Local Variable Decl: End
		// Foreach Statement: Begin
		%tmp_10 = arith.constant 0 : i1
		%tmp_11 = arith.extui %tmp_10 : i1 to i32
		%tmp_12_lb = index.casts %tmp_11 : i32 to index
		// Evaluate global variable $eval1.
		%tmp_13 = arith.constant 4 : i3
		%tmp_14 = arith.extui %tmp_13 : i3 to i32
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
			%tmp_23 = cal.get(%l_next__46: !cal.state_ref<i22>) : i22
			%tmp_24 = arith.extsi %tmp_23 : i22 to i32
			memref.store %tmp_24, %l_output__47_d1_0[%tmp_22] : memref<4xi32>
			// Assignment Statement: End
			// Assignment Statement: Start
			%tmp_25 = cal.get(%l_next__46: !cal.state_ref<i22>) : i22
			// Evaluate global variable fp_increment.
			%tmp_26 = arith.constant 57671 : i16
			%tmp_27 = arith.extui %tmp_26 : i16 to i22
			// Evaluate global variable fp_increment done: assigned to tmp_27 above in this context.
			%tmp_28 = arith.extsi %tmp_25 : i22 to i23
			%tmp_29 = arith.extsi %tmp_27 : i22 to i23
			%tmp_30 = arith.addi %tmp_28, %tmp_29 : i23
			%tmp_31 = arith.trunci %tmp_30 : i23 to i22
			cal.set(%l_next__46: !cal.state_ref<i22>, %tmp_31: i22)
			// Assignment Statement: End
			// If Statement: Begin
			%tmp_32 = cal.get(%l_next__46: !cal.state_ref<i22>) : i22
			// Evaluate global variable fixed_point_one.
			%tmp_33 = arith.constant 524288 : i20
			%tmp_34 = arith.extui %tmp_33 : i20 to i22
			// Evaluate global variable fixed_point_one done: assigned to tmp_34 above in this context.
			%tmp_35 = arith.cmpi sge, %tmp_32, %tmp_34 : i22
			scf.if %tmp_35 {
				// Assignment Statement: Start
				%tmp_36 = cal.get(%l_next__46: !cal.state_ref<i22>) : i22
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
				cal.set(%l_next__46: !cal.state_ref<i22>, %tmp_42: i22)
				// Assignment Statement: End
			} else {
			}
			// If Statement: End
		}
		// Foreach Statement: End
		// If Statement: Begin
		%tmp_43 = cal.get(%l_row__index__44: !cal.state_ref<i32>) : i32
		// Evaluate global variable $eval1.
		%tmp_44 = arith.constant 4 : i3
		%tmp_45 = arith.extui %tmp_44 : i3 to i32
		// Evaluate global variable $eval1 done: assigned to tmp_45 above in this context.
		%tmp_46 = arith.cmpi eq, %tmp_43, %tmp_45 : i32
		scf.if %tmp_46 {
			// Assignment Statement: Start
			%tmp_47 = arith.constant 0 : i1
			%tmp_48 = arith.extui %tmp_47 : i1 to i32
			cal.set(%l_row__index__44: !cal.state_ref<i32>, %tmp_48: i32)
			// Assignment Statement: End
			// Assignment Statement: Start
			// Evaluate global variable fp_increment.
			%tmp_49 = arith.constant 57671 : i16
			%tmp_50 = arith.extui %tmp_49 : i16 to i22
			// Evaluate global variable fp_increment done: assigned to tmp_50 above in this context.
			cal.set(%l_next__46: !cal.state_ref<i22>, %tmp_50: i22)
			// Assignment Statement: End
			// Assignment Statement: Start
			%tmp_51 = cal.get(%l_matrix__number__45: !cal.state_ref<i32>) : i32
			%tmp_52 = arith.constant 1 : i1
			%tmp_53 = arith.extui %tmp_52 : i1 to i32
			%tmp_54 = arith.addi %tmp_51, %tmp_53 : i32
			cal.set(%l_matrix__number__45: !cal.state_ref<i32>, %tmp_54: i32)
			// Assignment Statement: End
		} else {
		}
		// If Statement: End
		// Output Expression: Start
		%tmp_55 = arith.constant 0 : i1
		%tmp_56 = arith.extui %tmp_55 : i1 to i32
		%tmp_57 = arith.index_cast %tmp_56: i32 to index
		%tmp_59 = memref.load %l_output__47_d1_0[%tmp_57] : memref<4xi32>
		%tmp_58 = arith.trunci %tmp_59 : i32 to i22
		fifo.push(%Out_array_0_x: !fifo.input_port<i22>, %tmp_58: i22)
		// Output Expression: End
		// Output Expression: Start
		%tmp_60 = arith.constant 1 : i1
		%tmp_61 = arith.extui %tmp_60 : i1 to i32
		%tmp_62 = arith.index_cast %tmp_61: i32 to index
		%tmp_64 = memref.load %l_output__47_d1_0[%tmp_62] : memref<4xi32>
		%tmp_63 = arith.trunci %tmp_64 : i32 to i22
		fifo.push(%Out_array_1_x: !fifo.input_port<i22>, %tmp_63: i22)
		// Output Expression: End
		// Output Expression: Start
		%tmp_65 = arith.constant 2 : i2
		%tmp_66 = arith.extui %tmp_65 : i2 to i32
		%tmp_67 = arith.index_cast %tmp_66: i32 to index
		%tmp_69 = memref.load %l_output__47_d1_0[%tmp_67] : memref<4xi32>
		%tmp_68 = arith.trunci %tmp_69 : i32 to i22
		fifo.push(%Out_array_2_x: !fifo.input_port<i22>, %tmp_68: i22)
		// Output Expression: End
		// Output Expression: Start
		%tmp_70 = arith.constant 3 : i2
		%tmp_71 = arith.extui %tmp_70 : i2 to i32
		%tmp_72 = arith.index_cast %tmp_71: i32 to index
		%tmp_74 = memref.load %l_output__47_d1_0[%tmp_72] : memref<4xi32>
		%tmp_73 = arith.trunci %tmp_74 : i32 to i22
		fifo.push(%Out_array_3_x: !fifo.input_port<i22>, %tmp_73: i22)
		// Output Expression: End
	}
}

//-- Definition of actor class: BoundaryCell
cal.actor @boundaryCells_2 ()
	ports_in(%x_in: !fifo.output_port<i22>)
	ports_out(%r_out: !fifo.input_port<i22>,%cordic_angles_out: !fifo.input_port<i16>)
{
	// -- Actor body
	%l_r__142 = cal.create_state_var<i22> : !cal.state_ref<i22>
	%tmp_0 = arith.constant 0 : i1
	%tmp_1 = arith.extui %tmp_0 : i1 to i22
	cal.set(%l_r__142: !cal.state_ref<i22>, %tmp_1: i22)
	%l_count__143 = cal.create_state_var<i32> : !cal.state_ref<i32>
	%tmp_2 = arith.constant 0 : i1
	%tmp_3 = arith.extui %tmp_2 : i1 to i32
	cal.set(%l_count__143: !cal.state_ref<i32>, %tmp_3: i32)
	// Generation action: $untagged0
	cal.action "$untagged0" priority=0 {
		// Guard: Start
		cal.predicate {
			%tmp_4 = cal.get(%l_count__143: !cal.state_ref<i32>) : i32
			// Evaluate global variable $eval1.
			%tmp_5 = arith.constant 4 : i3
			%tmp_6 = arith.extui %tmp_5 : i3 to i32
			// Evaluate global variable $eval1 done: assigned to tmp_6 above in this context.
			%tmp_7 = arith.cmpi ult, %tmp_4, %tmp_6 : i32
			cal.predicate_result %tmp_7 : i1
		}
		// Guard: End
		// Input Pattern: Start
		%l_x__in__145_d1_0 = fifo.pop(%x_in: !fifo.output_port<i22>) : i22
		// Input Pattern: End
		// Action Local Variable Decl: Start
		%l_x__j__148_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_x__j__plus__1__149_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_x__j__shifted__150_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_y__j__151_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_y__j__plus__1__152_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_y__j__shifted__153_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%tmp_8 = arith.constant 0 : i1
		%tmp_9 = arith.extui %tmp_8 : i1 to i16
		// l_rotation__angles__147_d1_0 aliased to tmp_9
		// Action Local Variable Decl: End
		// If Statement: Begin
		%tmp_10 = cal.get(%l_count__143: !cal.state_ref<i32>) : i32
		%tmp_11 = arith.constant 0 : i1
		%tmp_12 = arith.extui %tmp_11 : i1 to i32
		%tmp_13 = arith.cmpi eq, %tmp_10, %tmp_12 : i32
		scf.if %tmp_13 {
			// Assignment Statement: Start
			%tmp_14 = arith.constant 0 : i1
			%tmp_15 = arith.extui %tmp_14 : i1 to i22
			cal.set(%l_r__142: !cal.state_ref<i22>, %tmp_15: i22)
			// Assignment Statement: End
		} else {
		}
		// If Statement: End
		// Assignment Statement: Start
		// l_x__j__148_d1_1 aliased to l_x__in__145_d1_0
		// Assignment Statement: End
		// Assignment Statement: Start
		%tmp_16 = cal.get(%l_r__142: !cal.state_ref<i22>) : i22
		// l_y__j__151_d1_1 aliased to tmp_16
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
		%l_rotation__angles__147_d1_1, %l_x__j__148_d1_2, %l_x__j__plus__1__149_d1_1, %l_x__j__shifted__150_d1_1, %l_y__j__151_d1_2, %l_y__j__plus__1__152_d1_1, %l_y__j__shifted__153_d1_1 = scf.for %l_j_d1_0 = %tmp_19_lb to %tmp_27_ub_plus_1 step %tmp_26_step
				iter_args(%l_rotation__angles__147_d2_0 = %tmp_9, %l_x__j__148_d2_0 = %l_x__in__145_d1_0, %l_x__j__plus__1__149_d2_0 = %l_x__j__plus__1__149_d1_0, %l_x__j__shifted__150_d2_0 = %l_x__j__shifted__150_d1_0, %l_y__j__151_d2_0 = %tmp_16, %l_y__j__plus__1__152_d2_0 = %l_y__j__plus__1__152_d1_0, %l_y__j__shifted__153_d2_0 = %l_y__j__shifted__153_d1_0) -> (i16, i22, i22, i22, i22, i22, i22) {
			%l_j_d2_0 = arith.index_cast %l_j_d1_0 : index to i32
			%l_j_d2_1 = arith.trunci %l_j_d2_0 : i32 to i8
			// Assignment Statement: Start
			%tmp_28 = arith.extui %l_j_d2_1 : i8 to i22
			%tmp_29 = arith.shrsi %l_y__j__151_d2_0, %tmp_28 : i22
			// l_y__j__shifted__153_d2_1 aliased to tmp_29
			// Assignment Statement: End
			// Assignment Statement: Start
			%tmp_30 = arith.extui %l_j_d2_1 : i8 to i22
			%tmp_31 = arith.shrsi %l_x__j__148_d2_0, %tmp_30 : i22
			// l_x__j__shifted__150_d2_1 aliased to tmp_31
			// Assignment Statement: End
			// If Statement: Begin
			%tmp_32 = arith.constant 0 : i1
			%tmp_33 = arith.extui %tmp_32 : i1 to i22
			%tmp_34 = arith.cmpi sgt, %l_x__j__148_d2_0, %tmp_33 : i22
			%tmp_35 = arith.constant 0 : i1
			%tmp_36 = arith.extui %tmp_35 : i1 to i22
			%tmp_37 = arith.cmpi sgt, %l_y__j__151_d2_0, %tmp_36 : i22
			%tmp_38 = arith.andi %tmp_34, %tmp_37 : i1
			%tmp_39 = arith.constant 0 : i1
			%tmp_40 = arith.extui %tmp_39 : i1 to i22
			%tmp_41 = arith.cmpi slt, %l_x__j__148_d2_0, %tmp_40 : i22
			%tmp_42 = arith.constant 0 : i1
			%tmp_43 = arith.extui %tmp_42 : i1 to i22
			%tmp_44 = arith.cmpi slt, %l_y__j__151_d2_0, %tmp_43 : i22
			%tmp_45 = arith.andi %tmp_41, %tmp_44 : i1
			%tmp_46 = arith.ori %tmp_38, %tmp_45 : i1
			%l_rotation__angles__147_d2_1, %l_x__j__plus__1__149_d2_1, %l_y__j__plus__1__152_d2_1 = scf.if %tmp_46 -> (i16, i22, i22) {
				// Assignment Statement: Start
				%tmp_47 = arith.extsi %l_x__j__148_d2_0 : i22 to i23
				%tmp_48 = arith.extsi %tmp_29 : i22 to i23
				%tmp_49 = arith.addi %tmp_47, %tmp_48 : i23
				%tmp_50 = arith.trunci %tmp_49 : i23 to i22
				// l_x__j__plus__1__149_d3_0 aliased to tmp_50
				// Assignment Statement: End
				// Assignment Statement: Start
				%tmp_51 = arith.subi %l_y__j__151_d2_0, %tmp_31 : i22
				// l_y__j__plus__1__152_d3_0 aliased to tmp_51
				// Assignment Statement: End
				// Assignment Statement: Start
				%tmp_52 = arith.constant 1 : i1
				%tmp_53 = arith.extui %tmp_52 : i1 to i64
				%tmp_54 = arith.extui %l_j_d2_1 : i8 to i64
				%tmp_55 = arith.shli %tmp_53, %tmp_54 : i64
				%tmp_56 = arith.extui %l_rotation__angles__147_d2_0 : i16 to i64
				%tmp_57 = arith.ori %tmp_56, %tmp_55 : i64
				%tmp_58 = arith.trunci %tmp_57 : i64 to i16
				// l_rotation__angles__147_d3_0 aliased to tmp_58
				// Assignment Statement: End
				scf.yield %tmp_58, %tmp_50, %tmp_51 : i16, i22, i22
			} else {
				// Assignment Statement: Start
				%tmp_59 = arith.subi %l_x__j__148_d2_0, %tmp_29 : i22
				// l_x__j__plus__1__149_d3_0 aliased to tmp_59
				// Assignment Statement: End
				// Assignment Statement: Start
				%tmp_60 = arith.extsi %l_y__j__151_d2_0 : i22 to i23
				%tmp_61 = arith.extsi %tmp_31 : i22 to i23
				%tmp_62 = arith.addi %tmp_60, %tmp_61 : i23
				%tmp_63 = arith.trunci %tmp_62 : i23 to i22
				// l_y__j__plus__1__152_d3_0 aliased to tmp_63
				// Assignment Statement: End
				scf.yield %l_rotation__angles__147_d2_0, %tmp_59, %tmp_63 : i16, i22, i22
			}
			// If Statement: End
			// Assignment Statement: Start
			// l_x__j__148_d2_1 aliased to l_x__j__plus__1__149_d2_1
			// Assignment Statement: End
			// Assignment Statement: Start
			// l_y__j__151_d2_1 aliased to l_y__j__plus__1__152_d2_1
			// Assignment Statement: End
			scf.yield %l_rotation__angles__147_d2_1, %l_x__j__plus__1__149_d2_1, %l_x__j__plus__1__149_d2_1, %tmp_31, %l_y__j__plus__1__152_d2_1, %l_y__j__plus__1__152_d2_1, %tmp_29 : i16, i22, i22, i22, i22, i22, i22
		}
		// Foreach Statement: End
		// Assignment Statement: Start
		// Evaluate global variable k_CORDIC_constant.
		%tmp_65 = arith.constant 318375 : i19
		%tmp_66 = arith.extui %tmp_65 : i19 to i22
		// Evaluate global variable k_CORDIC_constant done: assigned to tmp_66 above in this context.
		// Evaluate global variable fixedPointMultiply.
		%tmp_64 = func.call @g_qrd_fixedPointMultiply(%l_x__j__148_d1_2,%tmp_66) : (i22,i22) -> i22
		cal.set(%l_r__142: !cal.state_ref<i22>, %tmp_64: i22)
		// Assignment Statement: End
		// Assignment Statement: Start
		%tmp_67 = cal.get(%l_count__143: !cal.state_ref<i32>) : i32
		%tmp_68 = arith.constant 1 : i1
		%tmp_69 = arith.extui %tmp_68 : i1 to i32
		%tmp_70 = arith.addi %tmp_67, %tmp_69 : i32
		cal.set(%l_count__143: !cal.state_ref<i32>, %tmp_70: i32)
		// Assignment Statement: End
		// Output Expression: Start
		fifo.push(%cordic_angles_out: !fifo.input_port<i16>, %l_rotation__angles__147_d1_1: i16)
		// Output Expression: End
	}
	// Generation action: $untagged1
	cal.action "$untagged1" priority=0 {
		// Guard: Start
		cal.predicate {
			%tmp_71 = cal.get(%l_count__143: !cal.state_ref<i32>) : i32
			// Evaluate global variable $eval1.
			%tmp_72 = arith.constant 4 : i3
			%tmp_73 = arith.extui %tmp_72 : i3 to i32
			// Evaluate global variable $eval1 done: assigned to tmp_73 above in this context.
			%tmp_74 = arith.cmpi eq, %tmp_71, %tmp_73 : i32
			cal.predicate_result %tmp_74 : i1
		}
		// Guard: End
		// Assignment Statement: Start
		%tmp_75 = arith.constant 0 : i1
		%tmp_76 = arith.extui %tmp_75 : i1 to i32
		cal.set(%l_count__143: !cal.state_ref<i32>, %tmp_76: i32)
		// Assignment Statement: End
		// Output Expression: Start
		%tmp_77 = cal.get(%l_r__142: !cal.state_ref<i22>) : i22
		fifo.push(%r_out: !fifo.input_port<i22>, %tmp_77: i22)
		// Output Expression: End
	}
}

//-- Definition of actor class: InnerCell
cal.actor @innerCells_r_5 ()
	ports_in(%x_in: !fifo.output_port<i22>,%cordic_angles_in: !fifo.output_port<i16>)
	ports_out(%x_out: !fifo.input_port<i22>,%r_out: !fifo.input_port<i22>,%cordic_angles_out: !fifo.input_port<i16>)
{
	// -- Actor body
	%l_r__154 = cal.create_state_var<i22> : !cal.state_ref<i22>
	%tmp_0 = arith.constant 0 : i1
	%tmp_1 = arith.extui %tmp_0 : i1 to i22
	cal.set(%l_r__154: !cal.state_ref<i22>, %tmp_1: i22)
	%l_count__155 = cal.create_state_var<i32> : !cal.state_ref<i32>
	%tmp_2 = arith.constant 0 : i1
	%tmp_3 = arith.extui %tmp_2 : i1 to i32
	cal.set(%l_count__155: !cal.state_ref<i32>, %tmp_3: i32)
	// Generation action: $untagged0
	cal.action "$untagged0" priority=0 {
		// Guard: Start
		cal.predicate {
			%tmp_4 = cal.get(%l_count__155: !cal.state_ref<i32>) : i32
			// Evaluate global variable $eval1.
			%tmp_5 = arith.constant 4 : i3
			%tmp_6 = arith.extui %tmp_5 : i3 to i32
			// Evaluate global variable $eval1 done: assigned to tmp_6 above in this context.
			%tmp_7 = arith.cmpi ult, %tmp_4, %tmp_6 : i32
			cal.predicate_result %tmp_7 : i1
		}
		// Guard: End
		// Input Pattern: Start
		%l_x__in__157_d1_0 = fifo.pop(%x_in: !fifo.output_port<i22>) : i22
		// Input Pattern: End
		// Input Pattern: Start
		%l_rotation__angles__160_d1_0 = fifo.pop(%cordic_angles_in: !fifo.output_port<i16>) : i16
		// Input Pattern: End
		// Action Local Variable Decl: Start
		%l_x__out__162_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_x__j__163_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_x__j__plus__1__164_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_x__j__shifted__165_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_y__j__166_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_y__j__plus__1__167_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_y__j__shifted__168_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// If Statement: Begin
		%tmp_8 = cal.get(%l_count__155: !cal.state_ref<i32>) : i32
		%tmp_9 = arith.constant 0 : i1
		%tmp_10 = arith.extui %tmp_9 : i1 to i32
		%tmp_11 = arith.cmpi eq, %tmp_8, %tmp_10 : i32
		scf.if %tmp_11 {
			// Assignment Statement: Start
			%tmp_12 = arith.constant 0 : i1
			%tmp_13 = arith.extui %tmp_12 : i1 to i22
			cal.set(%l_r__154: !cal.state_ref<i22>, %tmp_13: i22)
			// Assignment Statement: End
		} else {
		}
		// If Statement: End
		// Assignment Statement: Start
		// l_x__j__163_d1_1 aliased to l_x__in__157_d1_0
		// Assignment Statement: End
		// Assignment Statement: Start
		%tmp_14 = cal.get(%l_r__154: !cal.state_ref<i22>) : i22
		// l_y__j__166_d1_1 aliased to tmp_14
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
		%l_x__j__163_d1_2, %l_x__j__plus__1__164_d1_1, %l_x__j__shifted__165_d1_1, %l_y__j__166_d1_2, %l_y__j__plus__1__167_d1_1, %l_y__j__shifted__168_d1_1 = scf.for %l_j_d1_0 = %tmp_17_lb to %tmp_25_ub_plus_1 step %tmp_24_step
				iter_args(%l_x__j__163_d2_0 = %l_x__in__157_d1_0, %l_x__j__plus__1__164_d2_0 = %l_x__j__plus__1__164_d1_0, %l_x__j__shifted__165_d2_0 = %l_x__j__shifted__165_d1_0, %l_y__j__166_d2_0 = %tmp_14, %l_y__j__plus__1__167_d2_0 = %l_y__j__plus__1__167_d1_0, %l_y__j__shifted__168_d2_0 = %l_y__j__shifted__168_d1_0) -> (i22, i22, i22, i22, i22, i22) {
			%l_j_d2_0 = arith.index_cast %l_j_d1_0 : index to i32
			%l_j_d2_1 = arith.trunci %l_j_d2_0 : i32 to i8
			// Assignment Statement: Start
			%tmp_26 = arith.extui %l_j_d2_1 : i8 to i22
			%tmp_27 = arith.shrsi %l_y__j__166_d2_0, %tmp_26 : i22
			// l_y__j__shifted__168_d2_1 aliased to tmp_27
			// Assignment Statement: End
			// Assignment Statement: Start
			%tmp_28 = arith.extui %l_j_d2_1 : i8 to i22
			%tmp_29 = arith.shrsi %l_x__j__163_d2_0, %tmp_28 : i22
			// l_x__j__shifted__165_d2_1 aliased to tmp_29
			// Assignment Statement: End
			// If Statement: Begin
			%tmp_30 = arith.extui %l_j_d2_1 : i8 to i16
			%tmp_31 = arith.shrui %l_rotation__angles__160_d1_0, %tmp_30 : i16
			%tmp_32 = arith.constant 1 : i1
			%tmp_33 = arith.trunci %tmp_31 : i16 to i1
			%tmp_34 = arith.andi %tmp_33, %tmp_32 : i1
			%tmp_35 = arith.constant 1 : i1
			%tmp_36 = arith.cmpi eq, %tmp_34, %tmp_35 : i1
			%l_x__j__plus__1__164_d2_1, %l_y__j__plus__1__167_d2_1 = scf.if %tmp_36 -> (i22, i22) {
				// Assignment Statement: Start
				%tmp_37 = arith.extsi %l_x__j__163_d2_0 : i22 to i23
				%tmp_38 = arith.extsi %tmp_27 : i22 to i23
				%tmp_39 = arith.addi %tmp_37, %tmp_38 : i23
				%tmp_40 = arith.trunci %tmp_39 : i23 to i22
				// l_x__j__plus__1__164_d3_0 aliased to tmp_40
				// Assignment Statement: End
				// Assignment Statement: Start
				%tmp_41 = arith.subi %l_y__j__166_d2_0, %tmp_29 : i22
				// l_y__j__plus__1__167_d3_0 aliased to tmp_41
				// Assignment Statement: End
				scf.yield %tmp_40, %tmp_41 : i22, i22
			} else {
				// Assignment Statement: Start
				%tmp_42 = arith.subi %l_x__j__163_d2_0, %tmp_27 : i22
				// l_x__j__plus__1__164_d3_0 aliased to tmp_42
				// Assignment Statement: End
				// Assignment Statement: Start
				%tmp_43 = arith.extsi %l_y__j__166_d2_0 : i22 to i23
				%tmp_44 = arith.extsi %tmp_29 : i22 to i23
				%tmp_45 = arith.addi %tmp_43, %tmp_44 : i23
				%tmp_46 = arith.trunci %tmp_45 : i23 to i22
				// l_y__j__plus__1__167_d3_0 aliased to tmp_46
				// Assignment Statement: End
				scf.yield %tmp_42, %tmp_46 : i22, i22
			}
			// If Statement: End
			// Assignment Statement: Start
			// l_x__j__163_d2_1 aliased to l_x__j__plus__1__164_d2_1
			// Assignment Statement: End
			// Assignment Statement: Start
			// l_y__j__166_d2_1 aliased to l_y__j__plus__1__167_d2_1
			// Assignment Statement: End
			scf.yield %l_x__j__plus__1__164_d2_1, %l_x__j__plus__1__164_d2_1, %tmp_29, %l_y__j__plus__1__167_d2_1, %l_y__j__plus__1__167_d2_1, %tmp_27 : i22, i22, i22, i22, i22, i22
		}
		// Foreach Statement: End
		// Assignment Statement: Start
		// Evaluate global variable k_CORDIC_constant.
		%tmp_48 = arith.constant 318375 : i19
		%tmp_49 = arith.extui %tmp_48 : i19 to i22
		// Evaluate global variable k_CORDIC_constant done: assigned to tmp_49 above in this context.
		// Evaluate global variable fixedPointMultiply.
		%tmp_47 = func.call @g_qrd_fixedPointMultiply(%tmp_49,%l_y__j__166_d1_2) : (i22,i22) -> i22
		// l_x__out__162_d1_1 aliased to tmp_47
		// Assignment Statement: End
		// Assignment Statement: Start
		// Evaluate global variable k_CORDIC_constant.
		%tmp_51 = arith.constant 318375 : i19
		%tmp_52 = arith.extui %tmp_51 : i19 to i22
		// Evaluate global variable k_CORDIC_constant done: assigned to tmp_52 above in this context.
		// Evaluate global variable fixedPointMultiply.
		%tmp_50 = func.call @g_qrd_fixedPointMultiply(%tmp_52,%l_x__j__163_d1_2) : (i22,i22) -> i22
		cal.set(%l_r__154: !cal.state_ref<i22>, %tmp_50: i22)
		// Assignment Statement: End
		// Assignment Statement: Start
		%tmp_53 = cal.get(%l_count__155: !cal.state_ref<i32>) : i32
		%tmp_54 = arith.constant 1 : i1
		%tmp_55 = arith.extui %tmp_54 : i1 to i32
		%tmp_56 = arith.addi %tmp_53, %tmp_55 : i32
		cal.set(%l_count__155: !cal.state_ref<i32>, %tmp_56: i32)
		// Assignment Statement: End
		// Output Expression: Start
		fifo.push(%x_out: !fifo.input_port<i22>, %tmp_47: i22)
		// Output Expression: End
		// Output Expression: Start
		fifo.push(%cordic_angles_out: !fifo.input_port<i16>, %l_rotation__angles__160_d1_0: i16)
		// Output Expression: End
	}
	// Generation action: $untagged1
	cal.action "$untagged1" priority=0 {
		// Guard: Start
		cal.predicate {
			%tmp_57 = cal.get(%l_count__155: !cal.state_ref<i32>) : i32
			// Evaluate global variable $eval1.
			%tmp_58 = arith.constant 4 : i3
			%tmp_59 = arith.extui %tmp_58 : i3 to i32
			// Evaluate global variable $eval1 done: assigned to tmp_59 above in this context.
			%tmp_60 = arith.cmpi eq, %tmp_57, %tmp_59 : i32
			cal.predicate_result %tmp_60 : i1
		}
		// Guard: End
		// Assignment Statement: Start
		%tmp_61 = arith.constant 0 : i1
		%tmp_62 = arith.extui %tmp_61 : i1 to i32
		cal.set(%l_count__155: !cal.state_ref<i32>, %tmp_62: i32)
		// Assignment Statement: End
		// Output Expression: Start
		%tmp_63 = cal.get(%l_r__154: !cal.state_ref<i22>) : i22
		fifo.push(%r_out: !fifo.input_port<i22>, %tmp_63: i22)
		// Output Expression: End
	}
}

//-- Definition of actor class: InnerCell
cal.actor @innerCells_r_3 ()
	ports_in(%x_in: !fifo.output_port<i22>,%cordic_angles_in: !fifo.output_port<i16>)
	ports_out(%x_out: !fifo.input_port<i22>,%r_out: !fifo.input_port<i22>,%cordic_angles_out: !fifo.input_port<i16>)
{
	// -- Actor body
	%l_r__154 = cal.create_state_var<i22> : !cal.state_ref<i22>
	%tmp_0 = arith.constant 0 : i1
	%tmp_1 = arith.extui %tmp_0 : i1 to i22
	cal.set(%l_r__154: !cal.state_ref<i22>, %tmp_1: i22)
	%l_count__155 = cal.create_state_var<i32> : !cal.state_ref<i32>
	%tmp_2 = arith.constant 0 : i1
	%tmp_3 = arith.extui %tmp_2 : i1 to i32
	cal.set(%l_count__155: !cal.state_ref<i32>, %tmp_3: i32)
	// Generation action: $untagged0
	cal.action "$untagged0" priority=0 {
		// Guard: Start
		cal.predicate {
			%tmp_4 = cal.get(%l_count__155: !cal.state_ref<i32>) : i32
			// Evaluate global variable $eval1.
			%tmp_5 = arith.constant 4 : i3
			%tmp_6 = arith.extui %tmp_5 : i3 to i32
			// Evaluate global variable $eval1 done: assigned to tmp_6 above in this context.
			%tmp_7 = arith.cmpi ult, %tmp_4, %tmp_6 : i32
			cal.predicate_result %tmp_7 : i1
		}
		// Guard: End
		// Input Pattern: Start
		%l_x__in__157_d1_0 = fifo.pop(%x_in: !fifo.output_port<i22>) : i22
		// Input Pattern: End
		// Input Pattern: Start
		%l_rotation__angles__160_d1_0 = fifo.pop(%cordic_angles_in: !fifo.output_port<i16>) : i16
		// Input Pattern: End
		// Action Local Variable Decl: Start
		%l_x__out__162_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_x__j__163_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_x__j__plus__1__164_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_x__j__shifted__165_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_y__j__166_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_y__j__plus__1__167_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_y__j__shifted__168_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// If Statement: Begin
		%tmp_8 = cal.get(%l_count__155: !cal.state_ref<i32>) : i32
		%tmp_9 = arith.constant 0 : i1
		%tmp_10 = arith.extui %tmp_9 : i1 to i32
		%tmp_11 = arith.cmpi eq, %tmp_8, %tmp_10 : i32
		scf.if %tmp_11 {
			// Assignment Statement: Start
			%tmp_12 = arith.constant 0 : i1
			%tmp_13 = arith.extui %tmp_12 : i1 to i22
			cal.set(%l_r__154: !cal.state_ref<i22>, %tmp_13: i22)
			// Assignment Statement: End
		} else {
		}
		// If Statement: End
		// Assignment Statement: Start
		// l_x__j__163_d1_1 aliased to l_x__in__157_d1_0
		// Assignment Statement: End
		// Assignment Statement: Start
		%tmp_14 = cal.get(%l_r__154: !cal.state_ref<i22>) : i22
		// l_y__j__166_d1_1 aliased to tmp_14
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
		%l_x__j__163_d1_2, %l_x__j__plus__1__164_d1_1, %l_x__j__shifted__165_d1_1, %l_y__j__166_d1_2, %l_y__j__plus__1__167_d1_1, %l_y__j__shifted__168_d1_1 = scf.for %l_j_d1_0 = %tmp_17_lb to %tmp_25_ub_plus_1 step %tmp_24_step
				iter_args(%l_x__j__163_d2_0 = %l_x__in__157_d1_0, %l_x__j__plus__1__164_d2_0 = %l_x__j__plus__1__164_d1_0, %l_x__j__shifted__165_d2_0 = %l_x__j__shifted__165_d1_0, %l_y__j__166_d2_0 = %tmp_14, %l_y__j__plus__1__167_d2_0 = %l_y__j__plus__1__167_d1_0, %l_y__j__shifted__168_d2_0 = %l_y__j__shifted__168_d1_0) -> (i22, i22, i22, i22, i22, i22) {
			%l_j_d2_0 = arith.index_cast %l_j_d1_0 : index to i32
			%l_j_d2_1 = arith.trunci %l_j_d2_0 : i32 to i8
			// Assignment Statement: Start
			%tmp_26 = arith.extui %l_j_d2_1 : i8 to i22
			%tmp_27 = arith.shrsi %l_y__j__166_d2_0, %tmp_26 : i22
			// l_y__j__shifted__168_d2_1 aliased to tmp_27
			// Assignment Statement: End
			// Assignment Statement: Start
			%tmp_28 = arith.extui %l_j_d2_1 : i8 to i22
			%tmp_29 = arith.shrsi %l_x__j__163_d2_0, %tmp_28 : i22
			// l_x__j__shifted__165_d2_1 aliased to tmp_29
			// Assignment Statement: End
			// If Statement: Begin
			%tmp_30 = arith.extui %l_j_d2_1 : i8 to i16
			%tmp_31 = arith.shrui %l_rotation__angles__160_d1_0, %tmp_30 : i16
			%tmp_32 = arith.constant 1 : i1
			%tmp_33 = arith.trunci %tmp_31 : i16 to i1
			%tmp_34 = arith.andi %tmp_33, %tmp_32 : i1
			%tmp_35 = arith.constant 1 : i1
			%tmp_36 = arith.cmpi eq, %tmp_34, %tmp_35 : i1
			%l_x__j__plus__1__164_d2_1, %l_y__j__plus__1__167_d2_1 = scf.if %tmp_36 -> (i22, i22) {
				// Assignment Statement: Start
				%tmp_37 = arith.extsi %l_x__j__163_d2_0 : i22 to i23
				%tmp_38 = arith.extsi %tmp_27 : i22 to i23
				%tmp_39 = arith.addi %tmp_37, %tmp_38 : i23
				%tmp_40 = arith.trunci %tmp_39 : i23 to i22
				// l_x__j__plus__1__164_d3_0 aliased to tmp_40
				// Assignment Statement: End
				// Assignment Statement: Start
				%tmp_41 = arith.subi %l_y__j__166_d2_0, %tmp_29 : i22
				// l_y__j__plus__1__167_d3_0 aliased to tmp_41
				// Assignment Statement: End
				scf.yield %tmp_40, %tmp_41 : i22, i22
			} else {
				// Assignment Statement: Start
				%tmp_42 = arith.subi %l_x__j__163_d2_0, %tmp_27 : i22
				// l_x__j__plus__1__164_d3_0 aliased to tmp_42
				// Assignment Statement: End
				// Assignment Statement: Start
				%tmp_43 = arith.extsi %l_y__j__166_d2_0 : i22 to i23
				%tmp_44 = arith.extsi %tmp_29 : i22 to i23
				%tmp_45 = arith.addi %tmp_43, %tmp_44 : i23
				%tmp_46 = arith.trunci %tmp_45 : i23 to i22
				// l_y__j__plus__1__167_d3_0 aliased to tmp_46
				// Assignment Statement: End
				scf.yield %tmp_42, %tmp_46 : i22, i22
			}
			// If Statement: End
			// Assignment Statement: Start
			// l_x__j__163_d2_1 aliased to l_x__j__plus__1__164_d2_1
			// Assignment Statement: End
			// Assignment Statement: Start
			// l_y__j__166_d2_1 aliased to l_y__j__plus__1__167_d2_1
			// Assignment Statement: End
			scf.yield %l_x__j__plus__1__164_d2_1, %l_x__j__plus__1__164_d2_1, %tmp_29, %l_y__j__plus__1__167_d2_1, %l_y__j__plus__1__167_d2_1, %tmp_27 : i22, i22, i22, i22, i22, i22
		}
		// Foreach Statement: End
		// Assignment Statement: Start
		// Evaluate global variable k_CORDIC_constant.
		%tmp_48 = arith.constant 318375 : i19
		%tmp_49 = arith.extui %tmp_48 : i19 to i22
		// Evaluate global variable k_CORDIC_constant done: assigned to tmp_49 above in this context.
		// Evaluate global variable fixedPointMultiply.
		%tmp_47 = func.call @g_qrd_fixedPointMultiply(%tmp_49,%l_y__j__166_d1_2) : (i22,i22) -> i22
		// l_x__out__162_d1_1 aliased to tmp_47
		// Assignment Statement: End
		// Assignment Statement: Start
		// Evaluate global variable k_CORDIC_constant.
		%tmp_51 = arith.constant 318375 : i19
		%tmp_52 = arith.extui %tmp_51 : i19 to i22
		// Evaluate global variable k_CORDIC_constant done: assigned to tmp_52 above in this context.
		// Evaluate global variable fixedPointMultiply.
		%tmp_50 = func.call @g_qrd_fixedPointMultiply(%tmp_52,%l_x__j__163_d1_2) : (i22,i22) -> i22
		cal.set(%l_r__154: !cal.state_ref<i22>, %tmp_50: i22)
		// Assignment Statement: End
		// Assignment Statement: Start
		%tmp_53 = cal.get(%l_count__155: !cal.state_ref<i32>) : i32
		%tmp_54 = arith.constant 1 : i1
		%tmp_55 = arith.extui %tmp_54 : i1 to i32
		%tmp_56 = arith.addi %tmp_53, %tmp_55 : i32
		cal.set(%l_count__155: !cal.state_ref<i32>, %tmp_56: i32)
		// Assignment Statement: End
		// Output Expression: Start
		fifo.push(%x_out: !fifo.input_port<i22>, %tmp_47: i22)
		// Output Expression: End
		// Output Expression: Start
		fifo.push(%cordic_angles_out: !fifo.input_port<i16>, %l_rotation__angles__160_d1_0: i16)
		// Output Expression: End
	}
	// Generation action: $untagged1
	cal.action "$untagged1" priority=0 {
		// Guard: Start
		cal.predicate {
			%tmp_57 = cal.get(%l_count__155: !cal.state_ref<i32>) : i32
			// Evaluate global variable $eval1.
			%tmp_58 = arith.constant 4 : i3
			%tmp_59 = arith.extui %tmp_58 : i3 to i32
			// Evaluate global variable $eval1 done: assigned to tmp_59 above in this context.
			%tmp_60 = arith.cmpi eq, %tmp_57, %tmp_59 : i32
			cal.predicate_result %tmp_60 : i1
		}
		// Guard: End
		// Assignment Statement: Start
		%tmp_61 = arith.constant 0 : i1
		%tmp_62 = arith.extui %tmp_61 : i1 to i32
		cal.set(%l_count__155: !cal.state_ref<i32>, %tmp_62: i32)
		// Assignment Statement: End
		// Output Expression: Start
		%tmp_63 = cal.get(%l_r__154: !cal.state_ref<i22>) : i22
		fifo.push(%r_out: !fifo.input_port<i22>, %tmp_63: i22)
		// Output Expression: End
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
		%l_t__42_d1_0 = fifo.pop(%In: !fifo.output_port<i22>) : i22
		// Input Pattern: End
	}
}

//-- Definition of actor class: InnerCell
cal.actor @innerCells_r_4 ()
	ports_in(%x_in: !fifo.output_port<i22>,%cordic_angles_in: !fifo.output_port<i16>)
	ports_out(%x_out: !fifo.input_port<i22>,%r_out: !fifo.input_port<i22>,%cordic_angles_out: !fifo.input_port<i16>)
{
	// -- Actor body
	%l_r__154 = cal.create_state_var<i22> : !cal.state_ref<i22>
	%tmp_0 = arith.constant 0 : i1
	%tmp_1 = arith.extui %tmp_0 : i1 to i22
	cal.set(%l_r__154: !cal.state_ref<i22>, %tmp_1: i22)
	%l_count__155 = cal.create_state_var<i32> : !cal.state_ref<i32>
	%tmp_2 = arith.constant 0 : i1
	%tmp_3 = arith.extui %tmp_2 : i1 to i32
	cal.set(%l_count__155: !cal.state_ref<i32>, %tmp_3: i32)
	// Generation action: $untagged0
	cal.action "$untagged0" priority=0 {
		// Guard: Start
		cal.predicate {
			%tmp_4 = cal.get(%l_count__155: !cal.state_ref<i32>) : i32
			// Evaluate global variable $eval1.
			%tmp_5 = arith.constant 4 : i3
			%tmp_6 = arith.extui %tmp_5 : i3 to i32
			// Evaluate global variable $eval1 done: assigned to tmp_6 above in this context.
			%tmp_7 = arith.cmpi ult, %tmp_4, %tmp_6 : i32
			cal.predicate_result %tmp_7 : i1
		}
		// Guard: End
		// Input Pattern: Start
		%l_x__in__157_d1_0 = fifo.pop(%x_in: !fifo.output_port<i22>) : i22
		// Input Pattern: End
		// Input Pattern: Start
		%l_rotation__angles__160_d1_0 = fifo.pop(%cordic_angles_in: !fifo.output_port<i16>) : i16
		// Input Pattern: End
		// Action Local Variable Decl: Start
		%l_x__out__162_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_x__j__163_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_x__j__plus__1__164_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_x__j__shifted__165_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_y__j__166_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_y__j__plus__1__167_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_y__j__shifted__168_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// If Statement: Begin
		%tmp_8 = cal.get(%l_count__155: !cal.state_ref<i32>) : i32
		%tmp_9 = arith.constant 0 : i1
		%tmp_10 = arith.extui %tmp_9 : i1 to i32
		%tmp_11 = arith.cmpi eq, %tmp_8, %tmp_10 : i32
		scf.if %tmp_11 {
			// Assignment Statement: Start
			%tmp_12 = arith.constant 0 : i1
			%tmp_13 = arith.extui %tmp_12 : i1 to i22
			cal.set(%l_r__154: !cal.state_ref<i22>, %tmp_13: i22)
			// Assignment Statement: End
		} else {
		}
		// If Statement: End
		// Assignment Statement: Start
		// l_x__j__163_d1_1 aliased to l_x__in__157_d1_0
		// Assignment Statement: End
		// Assignment Statement: Start
		%tmp_14 = cal.get(%l_r__154: !cal.state_ref<i22>) : i22
		// l_y__j__166_d1_1 aliased to tmp_14
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
		%l_x__j__163_d1_2, %l_x__j__plus__1__164_d1_1, %l_x__j__shifted__165_d1_1, %l_y__j__166_d1_2, %l_y__j__plus__1__167_d1_1, %l_y__j__shifted__168_d1_1 = scf.for %l_j_d1_0 = %tmp_17_lb to %tmp_25_ub_plus_1 step %tmp_24_step
				iter_args(%l_x__j__163_d2_0 = %l_x__in__157_d1_0, %l_x__j__plus__1__164_d2_0 = %l_x__j__plus__1__164_d1_0, %l_x__j__shifted__165_d2_0 = %l_x__j__shifted__165_d1_0, %l_y__j__166_d2_0 = %tmp_14, %l_y__j__plus__1__167_d2_0 = %l_y__j__plus__1__167_d1_0, %l_y__j__shifted__168_d2_0 = %l_y__j__shifted__168_d1_0) -> (i22, i22, i22, i22, i22, i22) {
			%l_j_d2_0 = arith.index_cast %l_j_d1_0 : index to i32
			%l_j_d2_1 = arith.trunci %l_j_d2_0 : i32 to i8
			// Assignment Statement: Start
			%tmp_26 = arith.extui %l_j_d2_1 : i8 to i22
			%tmp_27 = arith.shrsi %l_y__j__166_d2_0, %tmp_26 : i22
			// l_y__j__shifted__168_d2_1 aliased to tmp_27
			// Assignment Statement: End
			// Assignment Statement: Start
			%tmp_28 = arith.extui %l_j_d2_1 : i8 to i22
			%tmp_29 = arith.shrsi %l_x__j__163_d2_0, %tmp_28 : i22
			// l_x__j__shifted__165_d2_1 aliased to tmp_29
			// Assignment Statement: End
			// If Statement: Begin
			%tmp_30 = arith.extui %l_j_d2_1 : i8 to i16
			%tmp_31 = arith.shrui %l_rotation__angles__160_d1_0, %tmp_30 : i16
			%tmp_32 = arith.constant 1 : i1
			%tmp_33 = arith.trunci %tmp_31 : i16 to i1
			%tmp_34 = arith.andi %tmp_33, %tmp_32 : i1
			%tmp_35 = arith.constant 1 : i1
			%tmp_36 = arith.cmpi eq, %tmp_34, %tmp_35 : i1
			%l_x__j__plus__1__164_d2_1, %l_y__j__plus__1__167_d2_1 = scf.if %tmp_36 -> (i22, i22) {
				// Assignment Statement: Start
				%tmp_37 = arith.extsi %l_x__j__163_d2_0 : i22 to i23
				%tmp_38 = arith.extsi %tmp_27 : i22 to i23
				%tmp_39 = arith.addi %tmp_37, %tmp_38 : i23
				%tmp_40 = arith.trunci %tmp_39 : i23 to i22
				// l_x__j__plus__1__164_d3_0 aliased to tmp_40
				// Assignment Statement: End
				// Assignment Statement: Start
				%tmp_41 = arith.subi %l_y__j__166_d2_0, %tmp_29 : i22
				// l_y__j__plus__1__167_d3_0 aliased to tmp_41
				// Assignment Statement: End
				scf.yield %tmp_40, %tmp_41 : i22, i22
			} else {
				// Assignment Statement: Start
				%tmp_42 = arith.subi %l_x__j__163_d2_0, %tmp_27 : i22
				// l_x__j__plus__1__164_d3_0 aliased to tmp_42
				// Assignment Statement: End
				// Assignment Statement: Start
				%tmp_43 = arith.extsi %l_y__j__166_d2_0 : i22 to i23
				%tmp_44 = arith.extsi %tmp_29 : i22 to i23
				%tmp_45 = arith.addi %tmp_43, %tmp_44 : i23
				%tmp_46 = arith.trunci %tmp_45 : i23 to i22
				// l_y__j__plus__1__167_d3_0 aliased to tmp_46
				// Assignment Statement: End
				scf.yield %tmp_42, %tmp_46 : i22, i22
			}
			// If Statement: End
			// Assignment Statement: Start
			// l_x__j__163_d2_1 aliased to l_x__j__plus__1__164_d2_1
			// Assignment Statement: End
			// Assignment Statement: Start
			// l_y__j__166_d2_1 aliased to l_y__j__plus__1__167_d2_1
			// Assignment Statement: End
			scf.yield %l_x__j__plus__1__164_d2_1, %l_x__j__plus__1__164_d2_1, %tmp_29, %l_y__j__plus__1__167_d2_1, %l_y__j__plus__1__167_d2_1, %tmp_27 : i22, i22, i22, i22, i22, i22
		}
		// Foreach Statement: End
		// Assignment Statement: Start
		// Evaluate global variable k_CORDIC_constant.
		%tmp_48 = arith.constant 318375 : i19
		%tmp_49 = arith.extui %tmp_48 : i19 to i22
		// Evaluate global variable k_CORDIC_constant done: assigned to tmp_49 above in this context.
		// Evaluate global variable fixedPointMultiply.
		%tmp_47 = func.call @g_qrd_fixedPointMultiply(%tmp_49,%l_y__j__166_d1_2) : (i22,i22) -> i22
		// l_x__out__162_d1_1 aliased to tmp_47
		// Assignment Statement: End
		// Assignment Statement: Start
		// Evaluate global variable k_CORDIC_constant.
		%tmp_51 = arith.constant 318375 : i19
		%tmp_52 = arith.extui %tmp_51 : i19 to i22
		// Evaluate global variable k_CORDIC_constant done: assigned to tmp_52 above in this context.
		// Evaluate global variable fixedPointMultiply.
		%tmp_50 = func.call @g_qrd_fixedPointMultiply(%tmp_52,%l_x__j__163_d1_2) : (i22,i22) -> i22
		cal.set(%l_r__154: !cal.state_ref<i22>, %tmp_50: i22)
		// Assignment Statement: End
		// Assignment Statement: Start
		%tmp_53 = cal.get(%l_count__155: !cal.state_ref<i32>) : i32
		%tmp_54 = arith.constant 1 : i1
		%tmp_55 = arith.extui %tmp_54 : i1 to i32
		%tmp_56 = arith.addi %tmp_53, %tmp_55 : i32
		cal.set(%l_count__155: !cal.state_ref<i32>, %tmp_56: i32)
		// Assignment Statement: End
		// Output Expression: Start
		fifo.push(%x_out: !fifo.input_port<i22>, %tmp_47: i22)
		// Output Expression: End
		// Output Expression: Start
		fifo.push(%cordic_angles_out: !fifo.input_port<i16>, %l_rotation__angles__160_d1_0: i16)
		// Output Expression: End
	}
	// Generation action: $untagged1
	cal.action "$untagged1" priority=0 {
		// Guard: Start
		cal.predicate {
			%tmp_57 = cal.get(%l_count__155: !cal.state_ref<i32>) : i32
			// Evaluate global variable $eval1.
			%tmp_58 = arith.constant 4 : i3
			%tmp_59 = arith.extui %tmp_58 : i3 to i32
			// Evaluate global variable $eval1 done: assigned to tmp_59 above in this context.
			%tmp_60 = arith.cmpi eq, %tmp_57, %tmp_59 : i32
			cal.predicate_result %tmp_60 : i1
		}
		// Guard: End
		// Assignment Statement: Start
		%tmp_61 = arith.constant 0 : i1
		%tmp_62 = arith.extui %tmp_61 : i1 to i32
		cal.set(%l_count__155: !cal.state_ref<i32>, %tmp_62: i32)
		// Assignment Statement: End
		// Output Expression: Start
		%tmp_63 = cal.get(%l_r__154: !cal.state_ref<i22>) : i22
		fifo.push(%r_out: !fifo.input_port<i22>, %tmp_63: i22)
		// Output Expression: End
	}
}

//-- Definition of actor class: InnerCell
cal.actor @innerCells_r_1 ()
	ports_in(%x_in: !fifo.output_port<i22>,%cordic_angles_in: !fifo.output_port<i16>)
	ports_out(%x_out: !fifo.input_port<i22>,%r_out: !fifo.input_port<i22>,%cordic_angles_out: !fifo.input_port<i16>)
{
	// -- Actor body
	%l_r__154 = cal.create_state_var<i22> : !cal.state_ref<i22>
	%tmp_0 = arith.constant 0 : i1
	%tmp_1 = arith.extui %tmp_0 : i1 to i22
	cal.set(%l_r__154: !cal.state_ref<i22>, %tmp_1: i22)
	%l_count__155 = cal.create_state_var<i32> : !cal.state_ref<i32>
	%tmp_2 = arith.constant 0 : i1
	%tmp_3 = arith.extui %tmp_2 : i1 to i32
	cal.set(%l_count__155: !cal.state_ref<i32>, %tmp_3: i32)
	// Generation action: $untagged0
	cal.action "$untagged0" priority=0 {
		// Guard: Start
		cal.predicate {
			%tmp_4 = cal.get(%l_count__155: !cal.state_ref<i32>) : i32
			// Evaluate global variable $eval1.
			%tmp_5 = arith.constant 4 : i3
			%tmp_6 = arith.extui %tmp_5 : i3 to i32
			// Evaluate global variable $eval1 done: assigned to tmp_6 above in this context.
			%tmp_7 = arith.cmpi ult, %tmp_4, %tmp_6 : i32
			cal.predicate_result %tmp_7 : i1
		}
		// Guard: End
		// Input Pattern: Start
		%l_x__in__157_d1_0 = fifo.pop(%x_in: !fifo.output_port<i22>) : i22
		// Input Pattern: End
		// Input Pattern: Start
		%l_rotation__angles__160_d1_0 = fifo.pop(%cordic_angles_in: !fifo.output_port<i16>) : i16
		// Input Pattern: End
		// Action Local Variable Decl: Start
		%l_x__out__162_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_x__j__163_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_x__j__plus__1__164_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_x__j__shifted__165_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_y__j__166_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_y__j__plus__1__167_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_y__j__shifted__168_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// If Statement: Begin
		%tmp_8 = cal.get(%l_count__155: !cal.state_ref<i32>) : i32
		%tmp_9 = arith.constant 0 : i1
		%tmp_10 = arith.extui %tmp_9 : i1 to i32
		%tmp_11 = arith.cmpi eq, %tmp_8, %tmp_10 : i32
		scf.if %tmp_11 {
			// Assignment Statement: Start
			%tmp_12 = arith.constant 0 : i1
			%tmp_13 = arith.extui %tmp_12 : i1 to i22
			cal.set(%l_r__154: !cal.state_ref<i22>, %tmp_13: i22)
			// Assignment Statement: End
		} else {
		}
		// If Statement: End
		// Assignment Statement: Start
		// l_x__j__163_d1_1 aliased to l_x__in__157_d1_0
		// Assignment Statement: End
		// Assignment Statement: Start
		%tmp_14 = cal.get(%l_r__154: !cal.state_ref<i22>) : i22
		// l_y__j__166_d1_1 aliased to tmp_14
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
		%l_x__j__163_d1_2, %l_x__j__plus__1__164_d1_1, %l_x__j__shifted__165_d1_1, %l_y__j__166_d1_2, %l_y__j__plus__1__167_d1_1, %l_y__j__shifted__168_d1_1 = scf.for %l_j_d1_0 = %tmp_17_lb to %tmp_25_ub_plus_1 step %tmp_24_step
				iter_args(%l_x__j__163_d2_0 = %l_x__in__157_d1_0, %l_x__j__plus__1__164_d2_0 = %l_x__j__plus__1__164_d1_0, %l_x__j__shifted__165_d2_0 = %l_x__j__shifted__165_d1_0, %l_y__j__166_d2_0 = %tmp_14, %l_y__j__plus__1__167_d2_0 = %l_y__j__plus__1__167_d1_0, %l_y__j__shifted__168_d2_0 = %l_y__j__shifted__168_d1_0) -> (i22, i22, i22, i22, i22, i22) {
			%l_j_d2_0 = arith.index_cast %l_j_d1_0 : index to i32
			%l_j_d2_1 = arith.trunci %l_j_d2_0 : i32 to i8
			// Assignment Statement: Start
			%tmp_26 = arith.extui %l_j_d2_1 : i8 to i22
			%tmp_27 = arith.shrsi %l_y__j__166_d2_0, %tmp_26 : i22
			// l_y__j__shifted__168_d2_1 aliased to tmp_27
			// Assignment Statement: End
			// Assignment Statement: Start
			%tmp_28 = arith.extui %l_j_d2_1 : i8 to i22
			%tmp_29 = arith.shrsi %l_x__j__163_d2_0, %tmp_28 : i22
			// l_x__j__shifted__165_d2_1 aliased to tmp_29
			// Assignment Statement: End
			// If Statement: Begin
			%tmp_30 = arith.extui %l_j_d2_1 : i8 to i16
			%tmp_31 = arith.shrui %l_rotation__angles__160_d1_0, %tmp_30 : i16
			%tmp_32 = arith.constant 1 : i1
			%tmp_33 = arith.trunci %tmp_31 : i16 to i1
			%tmp_34 = arith.andi %tmp_33, %tmp_32 : i1
			%tmp_35 = arith.constant 1 : i1
			%tmp_36 = arith.cmpi eq, %tmp_34, %tmp_35 : i1
			%l_x__j__plus__1__164_d2_1, %l_y__j__plus__1__167_d2_1 = scf.if %tmp_36 -> (i22, i22) {
				// Assignment Statement: Start
				%tmp_37 = arith.extsi %l_x__j__163_d2_0 : i22 to i23
				%tmp_38 = arith.extsi %tmp_27 : i22 to i23
				%tmp_39 = arith.addi %tmp_37, %tmp_38 : i23
				%tmp_40 = arith.trunci %tmp_39 : i23 to i22
				// l_x__j__plus__1__164_d3_0 aliased to tmp_40
				// Assignment Statement: End
				// Assignment Statement: Start
				%tmp_41 = arith.subi %l_y__j__166_d2_0, %tmp_29 : i22
				// l_y__j__plus__1__167_d3_0 aliased to tmp_41
				// Assignment Statement: End
				scf.yield %tmp_40, %tmp_41 : i22, i22
			} else {
				// Assignment Statement: Start
				%tmp_42 = arith.subi %l_x__j__163_d2_0, %tmp_27 : i22
				// l_x__j__plus__1__164_d3_0 aliased to tmp_42
				// Assignment Statement: End
				// Assignment Statement: Start
				%tmp_43 = arith.extsi %l_y__j__166_d2_0 : i22 to i23
				%tmp_44 = arith.extsi %tmp_29 : i22 to i23
				%tmp_45 = arith.addi %tmp_43, %tmp_44 : i23
				%tmp_46 = arith.trunci %tmp_45 : i23 to i22
				// l_y__j__plus__1__167_d3_0 aliased to tmp_46
				// Assignment Statement: End
				scf.yield %tmp_42, %tmp_46 : i22, i22
			}
			// If Statement: End
			// Assignment Statement: Start
			// l_x__j__163_d2_1 aliased to l_x__j__plus__1__164_d2_1
			// Assignment Statement: End
			// Assignment Statement: Start
			// l_y__j__166_d2_1 aliased to l_y__j__plus__1__167_d2_1
			// Assignment Statement: End
			scf.yield %l_x__j__plus__1__164_d2_1, %l_x__j__plus__1__164_d2_1, %tmp_29, %l_y__j__plus__1__167_d2_1, %l_y__j__plus__1__167_d2_1, %tmp_27 : i22, i22, i22, i22, i22, i22
		}
		// Foreach Statement: End
		// Assignment Statement: Start
		// Evaluate global variable k_CORDIC_constant.
		%tmp_48 = arith.constant 318375 : i19
		%tmp_49 = arith.extui %tmp_48 : i19 to i22
		// Evaluate global variable k_CORDIC_constant done: assigned to tmp_49 above in this context.
		// Evaluate global variable fixedPointMultiply.
		%tmp_47 = func.call @g_qrd_fixedPointMultiply(%tmp_49,%l_y__j__166_d1_2) : (i22,i22) -> i22
		// l_x__out__162_d1_1 aliased to tmp_47
		// Assignment Statement: End
		// Assignment Statement: Start
		// Evaluate global variable k_CORDIC_constant.
		%tmp_51 = arith.constant 318375 : i19
		%tmp_52 = arith.extui %tmp_51 : i19 to i22
		// Evaluate global variable k_CORDIC_constant done: assigned to tmp_52 above in this context.
		// Evaluate global variable fixedPointMultiply.
		%tmp_50 = func.call @g_qrd_fixedPointMultiply(%tmp_52,%l_x__j__163_d1_2) : (i22,i22) -> i22
		cal.set(%l_r__154: !cal.state_ref<i22>, %tmp_50: i22)
		// Assignment Statement: End
		// Assignment Statement: Start
		%tmp_53 = cal.get(%l_count__155: !cal.state_ref<i32>) : i32
		%tmp_54 = arith.constant 1 : i1
		%tmp_55 = arith.extui %tmp_54 : i1 to i32
		%tmp_56 = arith.addi %tmp_53, %tmp_55 : i32
		cal.set(%l_count__155: !cal.state_ref<i32>, %tmp_56: i32)
		// Assignment Statement: End
		// Output Expression: Start
		fifo.push(%x_out: !fifo.input_port<i22>, %tmp_47: i22)
		// Output Expression: End
		// Output Expression: Start
		fifo.push(%cordic_angles_out: !fifo.input_port<i16>, %l_rotation__angles__160_d1_0: i16)
		// Output Expression: End
	}
	// Generation action: $untagged1
	cal.action "$untagged1" priority=0 {
		// Guard: Start
		cal.predicate {
			%tmp_57 = cal.get(%l_count__155: !cal.state_ref<i32>) : i32
			// Evaluate global variable $eval1.
			%tmp_58 = arith.constant 4 : i3
			%tmp_59 = arith.extui %tmp_58 : i3 to i32
			// Evaluate global variable $eval1 done: assigned to tmp_59 above in this context.
			%tmp_60 = arith.cmpi eq, %tmp_57, %tmp_59 : i32
			cal.predicate_result %tmp_60 : i1
		}
		// Guard: End
		// Assignment Statement: Start
		%tmp_61 = arith.constant 0 : i1
		%tmp_62 = arith.extui %tmp_61 : i1 to i32
		cal.set(%l_count__155: !cal.state_ref<i32>, %tmp_62: i32)
		// Assignment Statement: End
		// Output Expression: Start
		%tmp_63 = cal.get(%l_r__154: !cal.state_ref<i22>) : i22
		fifo.push(%r_out: !fifo.input_port<i22>, %tmp_63: i22)
		// Output Expression: End
	}
}

//-- Definition of actor class: Cap
cal.actor @caps_r_2 ()
	ports_in(%In: !fifo.output_port<i22>)
{
	// -- Actor body
	// Generation action: receive
	cal.action "receive" priority=0 {
		// Input Pattern: Start
		%l_t__42_d1_0 = fifo.pop(%In: !fifo.output_port<i22>) : i22
		// Input Pattern: End
	}
}

//-- Definition of actor class: InnerCell
cal.actor @innerCells_r_2 ()
	ports_in(%x_in: !fifo.output_port<i22>,%cordic_angles_in: !fifo.output_port<i16>)
	ports_out(%x_out: !fifo.input_port<i22>,%r_out: !fifo.input_port<i22>,%cordic_angles_out: !fifo.input_port<i16>)
{
	// -- Actor body
	%l_r__154 = cal.create_state_var<i22> : !cal.state_ref<i22>
	%tmp_0 = arith.constant 0 : i1
	%tmp_1 = arith.extui %tmp_0 : i1 to i22
	cal.set(%l_r__154: !cal.state_ref<i22>, %tmp_1: i22)
	%l_count__155 = cal.create_state_var<i32> : !cal.state_ref<i32>
	%tmp_2 = arith.constant 0 : i1
	%tmp_3 = arith.extui %tmp_2 : i1 to i32
	cal.set(%l_count__155: !cal.state_ref<i32>, %tmp_3: i32)
	// Generation action: $untagged0
	cal.action "$untagged0" priority=0 {
		// Guard: Start
		cal.predicate {
			%tmp_4 = cal.get(%l_count__155: !cal.state_ref<i32>) : i32
			// Evaluate global variable $eval1.
			%tmp_5 = arith.constant 4 : i3
			%tmp_6 = arith.extui %tmp_5 : i3 to i32
			// Evaluate global variable $eval1 done: assigned to tmp_6 above in this context.
			%tmp_7 = arith.cmpi ult, %tmp_4, %tmp_6 : i32
			cal.predicate_result %tmp_7 : i1
		}
		// Guard: End
		// Input Pattern: Start
		%l_x__in__157_d1_0 = fifo.pop(%x_in: !fifo.output_port<i22>) : i22
		// Input Pattern: End
		// Input Pattern: Start
		%l_rotation__angles__160_d1_0 = fifo.pop(%cordic_angles_in: !fifo.output_port<i16>) : i16
		// Input Pattern: End
		// Action Local Variable Decl: Start
		%l_x__out__162_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_x__j__163_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_x__j__plus__1__164_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_x__j__shifted__165_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_y__j__166_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_y__j__plus__1__167_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_y__j__shifted__168_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// If Statement: Begin
		%tmp_8 = cal.get(%l_count__155: !cal.state_ref<i32>) : i32
		%tmp_9 = arith.constant 0 : i1
		%tmp_10 = arith.extui %tmp_9 : i1 to i32
		%tmp_11 = arith.cmpi eq, %tmp_8, %tmp_10 : i32
		scf.if %tmp_11 {
			// Assignment Statement: Start
			%tmp_12 = arith.constant 0 : i1
			%tmp_13 = arith.extui %tmp_12 : i1 to i22
			cal.set(%l_r__154: !cal.state_ref<i22>, %tmp_13: i22)
			// Assignment Statement: End
		} else {
		}
		// If Statement: End
		// Assignment Statement: Start
		// l_x__j__163_d1_1 aliased to l_x__in__157_d1_0
		// Assignment Statement: End
		// Assignment Statement: Start
		%tmp_14 = cal.get(%l_r__154: !cal.state_ref<i22>) : i22
		// l_y__j__166_d1_1 aliased to tmp_14
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
		%l_x__j__163_d1_2, %l_x__j__plus__1__164_d1_1, %l_x__j__shifted__165_d1_1, %l_y__j__166_d1_2, %l_y__j__plus__1__167_d1_1, %l_y__j__shifted__168_d1_1 = scf.for %l_j_d1_0 = %tmp_17_lb to %tmp_25_ub_plus_1 step %tmp_24_step
				iter_args(%l_x__j__163_d2_0 = %l_x__in__157_d1_0, %l_x__j__plus__1__164_d2_0 = %l_x__j__plus__1__164_d1_0, %l_x__j__shifted__165_d2_0 = %l_x__j__shifted__165_d1_0, %l_y__j__166_d2_0 = %tmp_14, %l_y__j__plus__1__167_d2_0 = %l_y__j__plus__1__167_d1_0, %l_y__j__shifted__168_d2_0 = %l_y__j__shifted__168_d1_0) -> (i22, i22, i22, i22, i22, i22) {
			%l_j_d2_0 = arith.index_cast %l_j_d1_0 : index to i32
			%l_j_d2_1 = arith.trunci %l_j_d2_0 : i32 to i8
			// Assignment Statement: Start
			%tmp_26 = arith.extui %l_j_d2_1 : i8 to i22
			%tmp_27 = arith.shrsi %l_y__j__166_d2_0, %tmp_26 : i22
			// l_y__j__shifted__168_d2_1 aliased to tmp_27
			// Assignment Statement: End
			// Assignment Statement: Start
			%tmp_28 = arith.extui %l_j_d2_1 : i8 to i22
			%tmp_29 = arith.shrsi %l_x__j__163_d2_0, %tmp_28 : i22
			// l_x__j__shifted__165_d2_1 aliased to tmp_29
			// Assignment Statement: End
			// If Statement: Begin
			%tmp_30 = arith.extui %l_j_d2_1 : i8 to i16
			%tmp_31 = arith.shrui %l_rotation__angles__160_d1_0, %tmp_30 : i16
			%tmp_32 = arith.constant 1 : i1
			%tmp_33 = arith.trunci %tmp_31 : i16 to i1
			%tmp_34 = arith.andi %tmp_33, %tmp_32 : i1
			%tmp_35 = arith.constant 1 : i1
			%tmp_36 = arith.cmpi eq, %tmp_34, %tmp_35 : i1
			%l_x__j__plus__1__164_d2_1, %l_y__j__plus__1__167_d2_1 = scf.if %tmp_36 -> (i22, i22) {
				// Assignment Statement: Start
				%tmp_37 = arith.extsi %l_x__j__163_d2_0 : i22 to i23
				%tmp_38 = arith.extsi %tmp_27 : i22 to i23
				%tmp_39 = arith.addi %tmp_37, %tmp_38 : i23
				%tmp_40 = arith.trunci %tmp_39 : i23 to i22
				// l_x__j__plus__1__164_d3_0 aliased to tmp_40
				// Assignment Statement: End
				// Assignment Statement: Start
				%tmp_41 = arith.subi %l_y__j__166_d2_0, %tmp_29 : i22
				// l_y__j__plus__1__167_d3_0 aliased to tmp_41
				// Assignment Statement: End
				scf.yield %tmp_40, %tmp_41 : i22, i22
			} else {
				// Assignment Statement: Start
				%tmp_42 = arith.subi %l_x__j__163_d2_0, %tmp_27 : i22
				// l_x__j__plus__1__164_d3_0 aliased to tmp_42
				// Assignment Statement: End
				// Assignment Statement: Start
				%tmp_43 = arith.extsi %l_y__j__166_d2_0 : i22 to i23
				%tmp_44 = arith.extsi %tmp_29 : i22 to i23
				%tmp_45 = arith.addi %tmp_43, %tmp_44 : i23
				%tmp_46 = arith.trunci %tmp_45 : i23 to i22
				// l_y__j__plus__1__167_d3_0 aliased to tmp_46
				// Assignment Statement: End
				scf.yield %tmp_42, %tmp_46 : i22, i22
			}
			// If Statement: End
			// Assignment Statement: Start
			// l_x__j__163_d2_1 aliased to l_x__j__plus__1__164_d2_1
			// Assignment Statement: End
			// Assignment Statement: Start
			// l_y__j__166_d2_1 aliased to l_y__j__plus__1__167_d2_1
			// Assignment Statement: End
			scf.yield %l_x__j__plus__1__164_d2_1, %l_x__j__plus__1__164_d2_1, %tmp_29, %l_y__j__plus__1__167_d2_1, %l_y__j__plus__1__167_d2_1, %tmp_27 : i22, i22, i22, i22, i22, i22
		}
		// Foreach Statement: End
		// Assignment Statement: Start
		// Evaluate global variable k_CORDIC_constant.
		%tmp_48 = arith.constant 318375 : i19
		%tmp_49 = arith.extui %tmp_48 : i19 to i22
		// Evaluate global variable k_CORDIC_constant done: assigned to tmp_49 above in this context.
		// Evaluate global variable fixedPointMultiply.
		%tmp_47 = func.call @g_qrd_fixedPointMultiply(%tmp_49,%l_y__j__166_d1_2) : (i22,i22) -> i22
		// l_x__out__162_d1_1 aliased to tmp_47
		// Assignment Statement: End
		// Assignment Statement: Start
		// Evaluate global variable k_CORDIC_constant.
		%tmp_51 = arith.constant 318375 : i19
		%tmp_52 = arith.extui %tmp_51 : i19 to i22
		// Evaluate global variable k_CORDIC_constant done: assigned to tmp_52 above in this context.
		// Evaluate global variable fixedPointMultiply.
		%tmp_50 = func.call @g_qrd_fixedPointMultiply(%tmp_52,%l_x__j__163_d1_2) : (i22,i22) -> i22
		cal.set(%l_r__154: !cal.state_ref<i22>, %tmp_50: i22)
		// Assignment Statement: End
		// Assignment Statement: Start
		%tmp_53 = cal.get(%l_count__155: !cal.state_ref<i32>) : i32
		%tmp_54 = arith.constant 1 : i1
		%tmp_55 = arith.extui %tmp_54 : i1 to i32
		%tmp_56 = arith.addi %tmp_53, %tmp_55 : i32
		cal.set(%l_count__155: !cal.state_ref<i32>, %tmp_56: i32)
		// Assignment Statement: End
		// Output Expression: Start
		fifo.push(%x_out: !fifo.input_port<i22>, %tmp_47: i22)
		// Output Expression: End
		// Output Expression: Start
		fifo.push(%cordic_angles_out: !fifo.input_port<i16>, %l_rotation__angles__160_d1_0: i16)
		// Output Expression: End
	}
	// Generation action: $untagged1
	cal.action "$untagged1" priority=0 {
		// Guard: Start
		cal.predicate {
			%tmp_57 = cal.get(%l_count__155: !cal.state_ref<i32>) : i32
			// Evaluate global variable $eval1.
			%tmp_58 = arith.constant 4 : i3
			%tmp_59 = arith.extui %tmp_58 : i3 to i32
			// Evaluate global variable $eval1 done: assigned to tmp_59 above in this context.
			%tmp_60 = arith.cmpi eq, %tmp_57, %tmp_59 : i32
			cal.predicate_result %tmp_60 : i1
		}
		// Guard: End
		// Assignment Statement: Start
		%tmp_61 = arith.constant 0 : i1
		%tmp_62 = arith.extui %tmp_61 : i1 to i32
		cal.set(%l_count__155: !cal.state_ref<i32>, %tmp_62: i32)
		// Assignment Statement: End
		// Output Expression: Start
		%tmp_63 = cal.get(%l_r__154: !cal.state_ref<i22>) : i22
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
		%l_t__42_d1_0 = fifo.pop(%In: !fifo.output_port<i22>) : i22
		// Input Pattern: End
	}
}

//-- Definition of actor class: JoinerRowQ
cal.actor @joinersPerRow_q_1 ()
	ports_in(%r_in_array_0_x: !fifo.output_port<i22>,%r_in_array_1_x: !fifo.output_port<i22>,%r_in_array_2_x: !fifo.output_port<i22>,%r_in_array_3_x: !fifo.output_port<i22>)
	ports_out(%q_out: !fifo.input_port<i22>)
{
	// -- Actor body
	%l_matrix__number__100 = cal.create_state_var<i32> : !cal.state_ref<i32>
	%tmp_0 = arith.constant 0 : i1
	%tmp_1 = arith.extui %tmp_0 : i1 to i32
	cal.set(%l_matrix__number__100: !cal.state_ref<i32>, %tmp_1: i32)
	// Generation action: $untagged0
	cal.action "$untagged0" priority=0 {
		// Input Pattern: Start
		%l_____input0______102_d1_0 = fifo.pop(%r_in_array_0_x: !fifo.output_port<i22>) : i22
		// Input Pattern: End
		// Input Pattern: Start
		%l_____input1______105_d1_0 = fifo.pop(%r_in_array_1_x: !fifo.output_port<i22>) : i22
		// Input Pattern: End
		// Input Pattern: Start
		%l_____input2______108_d1_0 = fifo.pop(%r_in_array_2_x: !fifo.output_port<i22>) : i22
		// Input Pattern: End
		// Input Pattern: Start
		%l_____input3______111_d1_0 = fifo.pop(%r_in_array_3_x: !fifo.output_port<i22>) : i22
		// Input Pattern: End
		// Action Local Variable Decl: Start
		%tmp_2 = memref.alloc() : memref<4xi32>
		%tmp_3 = arith.constant 0: index
		%tmp_4 = arith.extsi %l_____input0______102_d1_0 : i22 to i32
		memref.store %tmp_4, %tmp_2[%tmp_3] : memref<4xi32>
		%tmp_5 = arith.constant 1: index
		%tmp_6 = arith.extsi %l_____input1______105_d1_0 : i22 to i32
		memref.store %tmp_6, %tmp_2[%tmp_5] : memref<4xi32>
		%tmp_7 = arith.constant 2: index
		%tmp_8 = arith.extsi %l_____input2______108_d1_0 : i22 to i32
		memref.store %tmp_8, %tmp_2[%tmp_7] : memref<4xi32>
		%tmp_9 = arith.constant 3: index
		%tmp_10 = arith.extsi %l_____input3______111_d1_0 : i22 to i32
		memref.store %tmp_10, %tmp_2[%tmp_9] : memref<4xi32>
		// l_input__113_d1_0 aliased to tmp_2
		// Action Local Variable Decl: End
		// If Statement: Begin
		%tmp_11 = cal.get(%l_matrix__number__100: !cal.state_ref<i32>) : i32
		// Evaluate global variable num_matrices.
		%tmp_12 = arith.constant 10000 : i14
		%tmp_13 = arith.extui %tmp_12 : i14 to i32
		// Evaluate global variable num_matrices done: assigned to tmp_13 above in this context.
		%tmp_14 = arith.constant 10 : i4
		%tmp_15 = arith.extui %tmp_14 : i4 to i32
		%tmp_16 = arith.subi %tmp_13, %tmp_15 : i32
		%tmp_17 = arith.cmpi eq, %tmp_11, %tmp_16 : i32
		scf.if %tmp_17 {
			// Call Statement: Start
			%tmp_18 = cal.get(%l_matrix__number__100: !cal.state_ref<i32>) : i32
			fifo.print("Q%u: row 1: \00", %tmp_18) : (i32)
			// Call Statement: End
			// Foreach Statement: Begin
			%tmp_19 = arith.constant 0 : i1
			%tmp_20 = arith.extui %tmp_19 : i1 to i32
			%tmp_21_lb = index.casts %tmp_20 : i32 to index
			// Evaluate global variable $eval1.
			%tmp_22 = arith.constant 4 : i3
			%tmp_23 = arith.extui %tmp_22 : i3 to i32
			// Evaluate global variable $eval1 done: assigned to tmp_23 above in this context.
			%tmp_24 = arith.constant 1 : i1
			%tmp_25 = arith.extui %tmp_24 : i1 to i32
			%tmp_26 = arith.subi %tmp_23, %tmp_25 : i32
			%tmp_27_ub = index.casts %tmp_26 : i32 to index
			%tmp_28_step = index.constant 1
			%tmp_29_ub_plus_1 = arith.addi %tmp_27_ub, %tmp_28_step : index
			scf.for %l_index_d2_0 = %tmp_21_lb to %tmp_29_ub_plus_1 step %tmp_28_step
					iter_args() -> () {
				%l_index_d3_0 = arith.index_cast %l_index_d2_0 : index to i32
				%l_index_d3_1 = arith.trunci %l_index_d3_0 : i32 to i8
				// Call Statement: Start
				%tmp_30 = arith.extui %l_index_d3_1 : i8 to i32
				%tmp_31 = arith.index_cast %tmp_30: i32 to index
				%tmp_33 = memref.load %tmp_2[%tmp_31] : memref<4xi32>
				%tmp_32 = arith.trunci %tmp_33 : i32 to i22
				%tmp_34 = arith.extsi %tmp_32 : i22 to i32
				fifo.print("%i \00", %tmp_34) : (i32)
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
		%tmp_35 = cal.get(%l_matrix__number__100: !cal.state_ref<i32>) : i32
		%tmp_36 = arith.constant 1 : i1
		%tmp_37 = arith.extui %tmp_36 : i1 to i32
		%tmp_38 = arith.addi %tmp_35, %tmp_37 : i32
		cal.set(%l_matrix__number__100: !cal.state_ref<i32>, %tmp_38: i32)
		// Assignment Statement: End
		// Output Expression: Start
		%tmp_39 = arith.constant 0 : index
		%tmp_40 = memref.load %tmp_2[%tmp_39] : memref<4xi32>
		%tmp_41 = arith.trunci %tmp_40 : i32 to i22
		fifo.push(%q_out: !fifo.input_port<i22>, %tmp_41: i22)
		%tmp_42 = arith.constant 1 : index
		%tmp_43 = memref.load %tmp_2[%tmp_42] : memref<4xi32>
		%tmp_44 = arith.trunci %tmp_43 : i32 to i22
		fifo.push(%q_out: !fifo.input_port<i22>, %tmp_44: i22)
		%tmp_45 = arith.constant 2 : index
		%tmp_46 = memref.load %tmp_2[%tmp_45] : memref<4xi32>
		%tmp_47 = arith.trunci %tmp_46 : i32 to i22
		fifo.push(%q_out: !fifo.input_port<i22>, %tmp_47: i22)
		%tmp_48 = arith.constant 3 : index
		%tmp_49 = memref.load %tmp_2[%tmp_48] : memref<4xi32>
		%tmp_50 = arith.trunci %tmp_49 : i32 to i22
		fifo.push(%q_out: !fifo.input_port<i22>, %tmp_50: i22)
		// Output Expression: End
	}
}

//-- Definition of actor class: IGenerator
cal.actor @iGenerator_2 ()
	ports_out(%Out: !fifo.input_port<i22>)
{
	// -- Actor body
	%l_row__index__30 = cal.create_state_var<i32> : !cal.state_ref<i32>
	%tmp_0 = arith.constant 0 : i1
	%tmp_1 = arith.extui %tmp_0 : i1 to i32
	cal.set(%l_row__index__30: !cal.state_ref<i32>, %tmp_1: i32)
	%l_total__rows__31 = cal.create_state_var<i32> : !cal.state_ref<i32>
	%tmp_2 = arith.constant 0 : i1
	%tmp_3 = arith.extui %tmp_2 : i1 to i32
	cal.set(%l_total__rows__31: !cal.state_ref<i32>, %tmp_3: i32)
	%l_total__actions__32 = cal.create_state_var<i32> : !cal.state_ref<i32>
	// Evaluate global variable $eval1.
	%tmp_4 = arith.constant 4 : i3
	%tmp_5 = arith.extui %tmp_4 : i3 to i32
	// Evaluate global variable $eval1 done: assigned to tmp_5 above in this context.
	// Evaluate global variable num_matrices.
	%tmp_6 = arith.constant 10000 : i14
	%tmp_7 = arith.extui %tmp_6 : i14 to i32
	// Evaluate global variable num_matrices done: assigned to tmp_7 above in this context.
	%tmp_8 = arith.muli %tmp_5, %tmp_7 : i32
	cal.set(%l_total__actions__32: !cal.state_ref<i32>, %tmp_8: i32)
	// Generation action: $untagged0
	cal.action "$untagged0" priority=0 {
		// Guard: Start
		cal.predicate {
			%tmp_9 = cal.get(%l_total__rows__31: !cal.state_ref<i32>) : i32
			%tmp_10 = cal.get(%l_total__actions__32: !cal.state_ref<i32>) : i32
			%tmp_11 = arith.cmpi ult, %tmp_9, %tmp_10 : i32
			cal.predicate_result %tmp_11 : i1
		}
		// Guard: End
		// Action Local Variable Decl: Start
		%tmp_12 = arith.constant 0 : i1
		%tmp_13 = arith.extui %tmp_12 : i1 to i22
		// l_outVal__33_d1_0 aliased to tmp_13
		// Action Local Variable Decl: End
		// If Statement: Begin
		%tmp_14 = cal.get(%l_row__index__30: !cal.state_ref<i32>) : i32
		// Evaluate global variable $eval7.
		%tmp_15 = arith.constant 2 : i2
		%tmp_16 = arith.extui %tmp_15 : i2 to i32
		// Evaluate global variable $eval7 done: assigned to tmp_16 above in this context.
		%tmp_17 = arith.cmpi eq, %tmp_14, %tmp_16 : i32
		%l_outVal__33_d1_1 = scf.if %tmp_17 -> (i22) {
			// Assignment Statement: Start
			// Evaluate global variable fixed_point_one.
			%tmp_18 = arith.constant 524288 : i20
			%tmp_19 = arith.extui %tmp_18 : i20 to i22
			// Evaluate global variable fixed_point_one done: assigned to tmp_19 above in this context.
			// l_outVal__33_d2_0 aliased to tmp_19
			// Assignment Statement: End
			scf.yield %tmp_19 : i22
		} else {
			scf.yield %tmp_13 : i22
		}
		// If Statement: End
		// Assignment Statement: Start
		%tmp_20 = cal.get(%l_row__index__30: !cal.state_ref<i32>) : i32
		%tmp_21 = arith.constant 1 : i1
		%tmp_22 = arith.extui %tmp_21 : i1 to i32
		%tmp_23 = arith.addi %tmp_20, %tmp_22 : i32
		// Evaluate global variable $eval1.
		%tmp_24 = arith.constant 4 : i3
		%tmp_25 = arith.extui %tmp_24 : i3 to i32
		// Evaluate global variable $eval1 done: assigned to tmp_25 above in this context.
		%tmp_26 = arith.remui %tmp_23, %tmp_25 : i32
		cal.set(%l_row__index__30: !cal.state_ref<i32>, %tmp_26: i32)
		// Assignment Statement: End
		// Assignment Statement: Start
		%tmp_27 = cal.get(%l_total__rows__31: !cal.state_ref<i32>) : i32
		%tmp_28 = arith.constant 1 : i1
		%tmp_29 = arith.extui %tmp_28 : i1 to i32
		%tmp_30 = arith.addi %tmp_27, %tmp_29 : i32
		cal.set(%l_total__rows__31: !cal.state_ref<i32>, %tmp_30: i32)
		// Assignment Statement: End
		// Output Expression: Start
		fifo.push(%Out: !fifo.input_port<i22>, %l_outVal__33_d1_1: i22)
		// Output Expression: End
	}
}

//-- Definition of actor class: Cap
cal.actor @caps_r_3 ()
	ports_in(%In: !fifo.output_port<i22>)
{
	// -- Actor body
	// Generation action: receive
	cal.action "receive" priority=0 {
		// Input Pattern: Start
		%l_t__42_d1_0 = fifo.pop(%In: !fifo.output_port<i22>) : i22
		// Input Pattern: End
	}
}

//-- Definition of actor class: JoinerRowQ
cal.actor @joinersPerRow_q_0 ()
	ports_in(%r_in_array_0_x: !fifo.output_port<i22>,%r_in_array_1_x: !fifo.output_port<i22>,%r_in_array_2_x: !fifo.output_port<i22>,%r_in_array_3_x: !fifo.output_port<i22>)
	ports_out(%q_out: !fifo.input_port<i22>)
{
	// -- Actor body
	%l_matrix__number__86 = cal.create_state_var<i32> : !cal.state_ref<i32>
	%tmp_0 = arith.constant 0 : i1
	%tmp_1 = arith.extui %tmp_0 : i1 to i32
	cal.set(%l_matrix__number__86: !cal.state_ref<i32>, %tmp_1: i32)
	// Generation action: $untagged0
	cal.action "$untagged0" priority=0 {
		// Input Pattern: Start
		%l_____input0______88_d1_0 = fifo.pop(%r_in_array_0_x: !fifo.output_port<i22>) : i22
		// Input Pattern: End
		// Input Pattern: Start
		%l_____input1______91_d1_0 = fifo.pop(%r_in_array_1_x: !fifo.output_port<i22>) : i22
		// Input Pattern: End
		// Input Pattern: Start
		%l_____input2______94_d1_0 = fifo.pop(%r_in_array_2_x: !fifo.output_port<i22>) : i22
		// Input Pattern: End
		// Input Pattern: Start
		%l_____input3______97_d1_0 = fifo.pop(%r_in_array_3_x: !fifo.output_port<i22>) : i22
		// Input Pattern: End
		// Action Local Variable Decl: Start
		%tmp_2 = memref.alloc() : memref<4xi32>
		%tmp_3 = arith.constant 0: index
		%tmp_4 = arith.extsi %l_____input0______88_d1_0 : i22 to i32
		memref.store %tmp_4, %tmp_2[%tmp_3] : memref<4xi32>
		%tmp_5 = arith.constant 1: index
		%tmp_6 = arith.extsi %l_____input1______91_d1_0 : i22 to i32
		memref.store %tmp_6, %tmp_2[%tmp_5] : memref<4xi32>
		%tmp_7 = arith.constant 2: index
		%tmp_8 = arith.extsi %l_____input2______94_d1_0 : i22 to i32
		memref.store %tmp_8, %tmp_2[%tmp_7] : memref<4xi32>
		%tmp_9 = arith.constant 3: index
		%tmp_10 = arith.extsi %l_____input3______97_d1_0 : i22 to i32
		memref.store %tmp_10, %tmp_2[%tmp_9] : memref<4xi32>
		// l_input__99_d1_0 aliased to tmp_2
		// Action Local Variable Decl: End
		// If Statement: Begin
		%tmp_11 = cal.get(%l_matrix__number__86: !cal.state_ref<i32>) : i32
		// Evaluate global variable num_matrices.
		%tmp_12 = arith.constant 10000 : i14
		%tmp_13 = arith.extui %tmp_12 : i14 to i32
		// Evaluate global variable num_matrices done: assigned to tmp_13 above in this context.
		%tmp_14 = arith.constant 10 : i4
		%tmp_15 = arith.extui %tmp_14 : i4 to i32
		%tmp_16 = arith.subi %tmp_13, %tmp_15 : i32
		%tmp_17 = arith.cmpi eq, %tmp_11, %tmp_16 : i32
		scf.if %tmp_17 {
			// Call Statement: Start
			%tmp_18 = cal.get(%l_matrix__number__86: !cal.state_ref<i32>) : i32
			fifo.print("Q%u: row 0: \00", %tmp_18) : (i32)
			// Call Statement: End
			// Foreach Statement: Begin
			%tmp_19 = arith.constant 0 : i1
			%tmp_20 = arith.extui %tmp_19 : i1 to i32
			%tmp_21_lb = index.casts %tmp_20 : i32 to index
			// Evaluate global variable $eval1.
			%tmp_22 = arith.constant 4 : i3
			%tmp_23 = arith.extui %tmp_22 : i3 to i32
			// Evaluate global variable $eval1 done: assigned to tmp_23 above in this context.
			%tmp_24 = arith.constant 1 : i1
			%tmp_25 = arith.extui %tmp_24 : i1 to i32
			%tmp_26 = arith.subi %tmp_23, %tmp_25 : i32
			%tmp_27_ub = index.casts %tmp_26 : i32 to index
			%tmp_28_step = index.constant 1
			%tmp_29_ub_plus_1 = arith.addi %tmp_27_ub, %tmp_28_step : index
			scf.for %l_index_d2_0 = %tmp_21_lb to %tmp_29_ub_plus_1 step %tmp_28_step
					iter_args() -> () {
				%l_index_d3_0 = arith.index_cast %l_index_d2_0 : index to i32
				%l_index_d3_1 = arith.trunci %l_index_d3_0 : i32 to i8
				// Call Statement: Start
				%tmp_30 = arith.extui %l_index_d3_1 : i8 to i32
				%tmp_31 = arith.index_cast %tmp_30: i32 to index
				%tmp_33 = memref.load %tmp_2[%tmp_31] : memref<4xi32>
				%tmp_32 = arith.trunci %tmp_33 : i32 to i22
				%tmp_34 = arith.extsi %tmp_32 : i22 to i32
				fifo.print("%i \00", %tmp_34) : (i32)
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
		%tmp_35 = cal.get(%l_matrix__number__86: !cal.state_ref<i32>) : i32
		%tmp_36 = arith.constant 1 : i1
		%tmp_37 = arith.extui %tmp_36 : i1 to i32
		%tmp_38 = arith.addi %tmp_35, %tmp_37 : i32
		cal.set(%l_matrix__number__86: !cal.state_ref<i32>, %tmp_38: i32)
		// Assignment Statement: End
		// Output Expression: Start
		%tmp_39 = arith.constant 0 : index
		%tmp_40 = memref.load %tmp_2[%tmp_39] : memref<4xi32>
		%tmp_41 = arith.trunci %tmp_40 : i32 to i22
		fifo.push(%q_out: !fifo.input_port<i22>, %tmp_41: i22)
		%tmp_42 = arith.constant 1 : index
		%tmp_43 = memref.load %tmp_2[%tmp_42] : memref<4xi32>
		%tmp_44 = arith.trunci %tmp_43 : i32 to i22
		fifo.push(%q_out: !fifo.input_port<i22>, %tmp_44: i22)
		%tmp_45 = arith.constant 2 : index
		%tmp_46 = memref.load %tmp_2[%tmp_45] : memref<4xi32>
		%tmp_47 = arith.trunci %tmp_46 : i32 to i22
		fifo.push(%q_out: !fifo.input_port<i22>, %tmp_47: i22)
		%tmp_48 = arith.constant 3 : index
		%tmp_49 = memref.load %tmp_2[%tmp_48] : memref<4xi32>
		%tmp_50 = arith.trunci %tmp_49 : i32 to i22
		fifo.push(%q_out: !fifo.input_port<i22>, %tmp_50: i22)
		// Output Expression: End
	}
}

//-- Definition of actor class: IGenerator
cal.actor @iGenerator_1 ()
	ports_out(%Out: !fifo.input_port<i22>)
{
	// -- Actor body
	%l_row__index__26 = cal.create_state_var<i32> : !cal.state_ref<i32>
	%tmp_0 = arith.constant 0 : i1
	%tmp_1 = arith.extui %tmp_0 : i1 to i32
	cal.set(%l_row__index__26: !cal.state_ref<i32>, %tmp_1: i32)
	%l_total__rows__27 = cal.create_state_var<i32> : !cal.state_ref<i32>
	%tmp_2 = arith.constant 0 : i1
	%tmp_3 = arith.extui %tmp_2 : i1 to i32
	cal.set(%l_total__rows__27: !cal.state_ref<i32>, %tmp_3: i32)
	%l_total__actions__28 = cal.create_state_var<i32> : !cal.state_ref<i32>
	// Evaluate global variable $eval1.
	%tmp_4 = arith.constant 4 : i3
	%tmp_5 = arith.extui %tmp_4 : i3 to i32
	// Evaluate global variable $eval1 done: assigned to tmp_5 above in this context.
	// Evaluate global variable num_matrices.
	%tmp_6 = arith.constant 10000 : i14
	%tmp_7 = arith.extui %tmp_6 : i14 to i32
	// Evaluate global variable num_matrices done: assigned to tmp_7 above in this context.
	%tmp_8 = arith.muli %tmp_5, %tmp_7 : i32
	cal.set(%l_total__actions__28: !cal.state_ref<i32>, %tmp_8: i32)
	// Generation action: $untagged0
	cal.action "$untagged0" priority=0 {
		// Guard: Start
		cal.predicate {
			%tmp_9 = cal.get(%l_total__rows__27: !cal.state_ref<i32>) : i32
			%tmp_10 = cal.get(%l_total__actions__28: !cal.state_ref<i32>) : i32
			%tmp_11 = arith.cmpi ult, %tmp_9, %tmp_10 : i32
			cal.predicate_result %tmp_11 : i1
		}
		// Guard: End
		// Action Local Variable Decl: Start
		%tmp_12 = arith.constant 0 : i1
		%tmp_13 = arith.extui %tmp_12 : i1 to i22
		// l_outVal__29_d1_0 aliased to tmp_13
		// Action Local Variable Decl: End
		// If Statement: Begin
		%tmp_14 = cal.get(%l_row__index__26: !cal.state_ref<i32>) : i32
		// Evaluate global variable $eval5.
		%tmp_15 = arith.constant 1 : i1
		%tmp_16 = arith.extui %tmp_15 : i1 to i32
		// Evaluate global variable $eval5 done: assigned to tmp_16 above in this context.
		%tmp_17 = arith.cmpi eq, %tmp_14, %tmp_16 : i32
		%l_outVal__29_d1_1 = scf.if %tmp_17 -> (i22) {
			// Assignment Statement: Start
			// Evaluate global variable fixed_point_one.
			%tmp_18 = arith.constant 524288 : i20
			%tmp_19 = arith.extui %tmp_18 : i20 to i22
			// Evaluate global variable fixed_point_one done: assigned to tmp_19 above in this context.
			// l_outVal__29_d2_0 aliased to tmp_19
			// Assignment Statement: End
			scf.yield %tmp_19 : i22
		} else {
			scf.yield %tmp_13 : i22
		}
		// If Statement: End
		// Assignment Statement: Start
		%tmp_20 = cal.get(%l_row__index__26: !cal.state_ref<i32>) : i32
		%tmp_21 = arith.constant 1 : i1
		%tmp_22 = arith.extui %tmp_21 : i1 to i32
		%tmp_23 = arith.addi %tmp_20, %tmp_22 : i32
		// Evaluate global variable $eval1.
		%tmp_24 = arith.constant 4 : i3
		%tmp_25 = arith.extui %tmp_24 : i3 to i32
		// Evaluate global variable $eval1 done: assigned to tmp_25 above in this context.
		%tmp_26 = arith.remui %tmp_23, %tmp_25 : i32
		cal.set(%l_row__index__26: !cal.state_ref<i32>, %tmp_26: i32)
		// Assignment Statement: End
		// Assignment Statement: Start
		%tmp_27 = cal.get(%l_total__rows__27: !cal.state_ref<i32>) : i32
		%tmp_28 = arith.constant 1 : i1
		%tmp_29 = arith.extui %tmp_28 : i1 to i32
		%tmp_30 = arith.addi %tmp_27, %tmp_29 : i32
		cal.set(%l_total__rows__27: !cal.state_ref<i32>, %tmp_30: i32)
		// Assignment Statement: End
		// Output Expression: Start
		fifo.push(%Out: !fifo.input_port<i22>, %l_outVal__29_d1_1: i22)
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
		%l_t__42_d1_0 = fifo.pop(%In: !fifo.output_port<i22>) : i22
		// Input Pattern: End
	}
}

//-- Definition of actor class: JoinerRowQ
cal.actor @joinersPerRow_q_3 ()
	ports_in(%r_in_array_0_x: !fifo.output_port<i22>,%r_in_array_1_x: !fifo.output_port<i22>,%r_in_array_2_x: !fifo.output_port<i22>,%r_in_array_3_x: !fifo.output_port<i22>)
	ports_out(%q_out: !fifo.input_port<i22>)
{
	// -- Actor body
	%l_matrix__number__128 = cal.create_state_var<i32> : !cal.state_ref<i32>
	%tmp_0 = arith.constant 0 : i1
	%tmp_1 = arith.extui %tmp_0 : i1 to i32
	cal.set(%l_matrix__number__128: !cal.state_ref<i32>, %tmp_1: i32)
	// Generation action: $untagged0
	cal.action "$untagged0" priority=0 {
		// Input Pattern: Start
		%l_____input0______130_d1_0 = fifo.pop(%r_in_array_0_x: !fifo.output_port<i22>) : i22
		// Input Pattern: End
		// Input Pattern: Start
		%l_____input1______133_d1_0 = fifo.pop(%r_in_array_1_x: !fifo.output_port<i22>) : i22
		// Input Pattern: End
		// Input Pattern: Start
		%l_____input2______136_d1_0 = fifo.pop(%r_in_array_2_x: !fifo.output_port<i22>) : i22
		// Input Pattern: End
		// Input Pattern: Start
		%l_____input3______139_d1_0 = fifo.pop(%r_in_array_3_x: !fifo.output_port<i22>) : i22
		// Input Pattern: End
		// Action Local Variable Decl: Start
		%tmp_2 = memref.alloc() : memref<4xi32>
		%tmp_3 = arith.constant 0: index
		%tmp_4 = arith.extsi %l_____input0______130_d1_0 : i22 to i32
		memref.store %tmp_4, %tmp_2[%tmp_3] : memref<4xi32>
		%tmp_5 = arith.constant 1: index
		%tmp_6 = arith.extsi %l_____input1______133_d1_0 : i22 to i32
		memref.store %tmp_6, %tmp_2[%tmp_5] : memref<4xi32>
		%tmp_7 = arith.constant 2: index
		%tmp_8 = arith.extsi %l_____input2______136_d1_0 : i22 to i32
		memref.store %tmp_8, %tmp_2[%tmp_7] : memref<4xi32>
		%tmp_9 = arith.constant 3: index
		%tmp_10 = arith.extsi %l_____input3______139_d1_0 : i22 to i32
		memref.store %tmp_10, %tmp_2[%tmp_9] : memref<4xi32>
		// l_input__141_d1_0 aliased to tmp_2
		// Action Local Variable Decl: End
		// If Statement: Begin
		%tmp_11 = cal.get(%l_matrix__number__128: !cal.state_ref<i32>) : i32
		// Evaluate global variable num_matrices.
		%tmp_12 = arith.constant 10000 : i14
		%tmp_13 = arith.extui %tmp_12 : i14 to i32
		// Evaluate global variable num_matrices done: assigned to tmp_13 above in this context.
		%tmp_14 = arith.constant 10 : i4
		%tmp_15 = arith.extui %tmp_14 : i4 to i32
		%tmp_16 = arith.subi %tmp_13, %tmp_15 : i32
		%tmp_17 = arith.cmpi eq, %tmp_11, %tmp_16 : i32
		scf.if %tmp_17 {
			// Call Statement: Start
			%tmp_18 = cal.get(%l_matrix__number__128: !cal.state_ref<i32>) : i32
			fifo.print("Q%u: row 3: \00", %tmp_18) : (i32)
			// Call Statement: End
			// Foreach Statement: Begin
			%tmp_19 = arith.constant 0 : i1
			%tmp_20 = arith.extui %tmp_19 : i1 to i32
			%tmp_21_lb = index.casts %tmp_20 : i32 to index
			// Evaluate global variable $eval1.
			%tmp_22 = arith.constant 4 : i3
			%tmp_23 = arith.extui %tmp_22 : i3 to i32
			// Evaluate global variable $eval1 done: assigned to tmp_23 above in this context.
			%tmp_24 = arith.constant 1 : i1
			%tmp_25 = arith.extui %tmp_24 : i1 to i32
			%tmp_26 = arith.subi %tmp_23, %tmp_25 : i32
			%tmp_27_ub = index.casts %tmp_26 : i32 to index
			%tmp_28_step = index.constant 1
			%tmp_29_ub_plus_1 = arith.addi %tmp_27_ub, %tmp_28_step : index
			scf.for %l_index_d2_0 = %tmp_21_lb to %tmp_29_ub_plus_1 step %tmp_28_step
					iter_args() -> () {
				%l_index_d3_0 = arith.index_cast %l_index_d2_0 : index to i32
				%l_index_d3_1 = arith.trunci %l_index_d3_0 : i32 to i8
				// Call Statement: Start
				%tmp_30 = arith.extui %l_index_d3_1 : i8 to i32
				%tmp_31 = arith.index_cast %tmp_30: i32 to index
				%tmp_33 = memref.load %tmp_2[%tmp_31] : memref<4xi32>
				%tmp_32 = arith.trunci %tmp_33 : i32 to i22
				%tmp_34 = arith.extsi %tmp_32 : i22 to i32
				fifo.print("%i \00", %tmp_34) : (i32)
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
		%tmp_35 = cal.get(%l_matrix__number__128: !cal.state_ref<i32>) : i32
		%tmp_36 = arith.constant 1 : i1
		%tmp_37 = arith.extui %tmp_36 : i1 to i32
		%tmp_38 = arith.addi %tmp_35, %tmp_37 : i32
		cal.set(%l_matrix__number__128: !cal.state_ref<i32>, %tmp_38: i32)
		// Assignment Statement: End
		// Output Expression: Start
		%tmp_39 = arith.constant 0 : index
		%tmp_40 = memref.load %tmp_2[%tmp_39] : memref<4xi32>
		%tmp_41 = arith.trunci %tmp_40 : i32 to i22
		fifo.push(%q_out: !fifo.input_port<i22>, %tmp_41: i22)
		%tmp_42 = arith.constant 1 : index
		%tmp_43 = memref.load %tmp_2[%tmp_42] : memref<4xi32>
		%tmp_44 = arith.trunci %tmp_43 : i32 to i22
		fifo.push(%q_out: !fifo.input_port<i22>, %tmp_44: i22)
		%tmp_45 = arith.constant 2 : index
		%tmp_46 = memref.load %tmp_2[%tmp_45] : memref<4xi32>
		%tmp_47 = arith.trunci %tmp_46 : i32 to i22
		fifo.push(%q_out: !fifo.input_port<i22>, %tmp_47: i22)
		%tmp_48 = arith.constant 3 : index
		%tmp_49 = memref.load %tmp_2[%tmp_48] : memref<4xi32>
		%tmp_50 = arith.trunci %tmp_49 : i32 to i22
		fifo.push(%q_out: !fifo.input_port<i22>, %tmp_50: i22)
		// Output Expression: End
	}
}

//-- Definition of actor class: JoinerRowQ
cal.actor @joinersPerRow_q_2 ()
	ports_in(%r_in_array_0_x: !fifo.output_port<i22>,%r_in_array_1_x: !fifo.output_port<i22>,%r_in_array_2_x: !fifo.output_port<i22>,%r_in_array_3_x: !fifo.output_port<i22>)
	ports_out(%q_out: !fifo.input_port<i22>)
{
	// -- Actor body
	%l_matrix__number__114 = cal.create_state_var<i32> : !cal.state_ref<i32>
	%tmp_0 = arith.constant 0 : i1
	%tmp_1 = arith.extui %tmp_0 : i1 to i32
	cal.set(%l_matrix__number__114: !cal.state_ref<i32>, %tmp_1: i32)
	// Generation action: $untagged0
	cal.action "$untagged0" priority=0 {
		// Input Pattern: Start
		%l_____input0______116_d1_0 = fifo.pop(%r_in_array_0_x: !fifo.output_port<i22>) : i22
		// Input Pattern: End
		// Input Pattern: Start
		%l_____input1______119_d1_0 = fifo.pop(%r_in_array_1_x: !fifo.output_port<i22>) : i22
		// Input Pattern: End
		// Input Pattern: Start
		%l_____input2______122_d1_0 = fifo.pop(%r_in_array_2_x: !fifo.output_port<i22>) : i22
		// Input Pattern: End
		// Input Pattern: Start
		%l_____input3______125_d1_0 = fifo.pop(%r_in_array_3_x: !fifo.output_port<i22>) : i22
		// Input Pattern: End
		// Action Local Variable Decl: Start
		%tmp_2 = memref.alloc() : memref<4xi32>
		%tmp_3 = arith.constant 0: index
		%tmp_4 = arith.extsi %l_____input0______116_d1_0 : i22 to i32
		memref.store %tmp_4, %tmp_2[%tmp_3] : memref<4xi32>
		%tmp_5 = arith.constant 1: index
		%tmp_6 = arith.extsi %l_____input1______119_d1_0 : i22 to i32
		memref.store %tmp_6, %tmp_2[%tmp_5] : memref<4xi32>
		%tmp_7 = arith.constant 2: index
		%tmp_8 = arith.extsi %l_____input2______122_d1_0 : i22 to i32
		memref.store %tmp_8, %tmp_2[%tmp_7] : memref<4xi32>
		%tmp_9 = arith.constant 3: index
		%tmp_10 = arith.extsi %l_____input3______125_d1_0 : i22 to i32
		memref.store %tmp_10, %tmp_2[%tmp_9] : memref<4xi32>
		// l_input__127_d1_0 aliased to tmp_2
		// Action Local Variable Decl: End
		// If Statement: Begin
		%tmp_11 = cal.get(%l_matrix__number__114: !cal.state_ref<i32>) : i32
		// Evaluate global variable num_matrices.
		%tmp_12 = arith.constant 10000 : i14
		%tmp_13 = arith.extui %tmp_12 : i14 to i32
		// Evaluate global variable num_matrices done: assigned to tmp_13 above in this context.
		%tmp_14 = arith.constant 10 : i4
		%tmp_15 = arith.extui %tmp_14 : i4 to i32
		%tmp_16 = arith.subi %tmp_13, %tmp_15 : i32
		%tmp_17 = arith.cmpi eq, %tmp_11, %tmp_16 : i32
		scf.if %tmp_17 {
			// Call Statement: Start
			%tmp_18 = cal.get(%l_matrix__number__114: !cal.state_ref<i32>) : i32
			fifo.print("Q%u: row 2: \00", %tmp_18) : (i32)
			// Call Statement: End
			// Foreach Statement: Begin
			%tmp_19 = arith.constant 0 : i1
			%tmp_20 = arith.extui %tmp_19 : i1 to i32
			%tmp_21_lb = index.casts %tmp_20 : i32 to index
			// Evaluate global variable $eval1.
			%tmp_22 = arith.constant 4 : i3
			%tmp_23 = arith.extui %tmp_22 : i3 to i32
			// Evaluate global variable $eval1 done: assigned to tmp_23 above in this context.
			%tmp_24 = arith.constant 1 : i1
			%tmp_25 = arith.extui %tmp_24 : i1 to i32
			%tmp_26 = arith.subi %tmp_23, %tmp_25 : i32
			%tmp_27_ub = index.casts %tmp_26 : i32 to index
			%tmp_28_step = index.constant 1
			%tmp_29_ub_plus_1 = arith.addi %tmp_27_ub, %tmp_28_step : index
			scf.for %l_index_d2_0 = %tmp_21_lb to %tmp_29_ub_plus_1 step %tmp_28_step
					iter_args() -> () {
				%l_index_d3_0 = arith.index_cast %l_index_d2_0 : index to i32
				%l_index_d3_1 = arith.trunci %l_index_d3_0 : i32 to i8
				// Call Statement: Start
				%tmp_30 = arith.extui %l_index_d3_1 : i8 to i32
				%tmp_31 = arith.index_cast %tmp_30: i32 to index
				%tmp_33 = memref.load %tmp_2[%tmp_31] : memref<4xi32>
				%tmp_32 = arith.trunci %tmp_33 : i32 to i22
				%tmp_34 = arith.extsi %tmp_32 : i22 to i32
				fifo.print("%i \00", %tmp_34) : (i32)
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
		%tmp_35 = cal.get(%l_matrix__number__114: !cal.state_ref<i32>) : i32
		%tmp_36 = arith.constant 1 : i1
		%tmp_37 = arith.extui %tmp_36 : i1 to i32
		%tmp_38 = arith.addi %tmp_35, %tmp_37 : i32
		cal.set(%l_matrix__number__114: !cal.state_ref<i32>, %tmp_38: i32)
		// Assignment Statement: End
		// Output Expression: Start
		%tmp_39 = arith.constant 0 : index
		%tmp_40 = memref.load %tmp_2[%tmp_39] : memref<4xi32>
		%tmp_41 = arith.trunci %tmp_40 : i32 to i22
		fifo.push(%q_out: !fifo.input_port<i22>, %tmp_41: i22)
		%tmp_42 = arith.constant 1 : index
		%tmp_43 = memref.load %tmp_2[%tmp_42] : memref<4xi32>
		%tmp_44 = arith.trunci %tmp_43 : i32 to i22
		fifo.push(%q_out: !fifo.input_port<i22>, %tmp_44: i22)
		%tmp_45 = arith.constant 2 : index
		%tmp_46 = memref.load %tmp_2[%tmp_45] : memref<4xi32>
		%tmp_47 = arith.trunci %tmp_46 : i32 to i22
		fifo.push(%q_out: !fifo.input_port<i22>, %tmp_47: i22)
		%tmp_48 = arith.constant 3 : index
		%tmp_49 = memref.load %tmp_2[%tmp_48] : memref<4xi32>
		%tmp_50 = arith.trunci %tmp_49 : i32 to i22
		fifo.push(%q_out: !fifo.input_port<i22>, %tmp_50: i22)
		// Output Expression: End
	}
}

//-- Definition of actor class: IGenerator
cal.actor @iGenerator_3 ()
	ports_out(%Out: !fifo.input_port<i22>)
{
	// -- Actor body
	%l_row__index__34 = cal.create_state_var<i32> : !cal.state_ref<i32>
	%tmp_0 = arith.constant 0 : i1
	%tmp_1 = arith.extui %tmp_0 : i1 to i32
	cal.set(%l_row__index__34: !cal.state_ref<i32>, %tmp_1: i32)
	%l_total__rows__35 = cal.create_state_var<i32> : !cal.state_ref<i32>
	%tmp_2 = arith.constant 0 : i1
	%tmp_3 = arith.extui %tmp_2 : i1 to i32
	cal.set(%l_total__rows__35: !cal.state_ref<i32>, %tmp_3: i32)
	%l_total__actions__36 = cal.create_state_var<i32> : !cal.state_ref<i32>
	// Evaluate global variable $eval1.
	%tmp_4 = arith.constant 4 : i3
	%tmp_5 = arith.extui %tmp_4 : i3 to i32
	// Evaluate global variable $eval1 done: assigned to tmp_5 above in this context.
	// Evaluate global variable num_matrices.
	%tmp_6 = arith.constant 10000 : i14
	%tmp_7 = arith.extui %tmp_6 : i14 to i32
	// Evaluate global variable num_matrices done: assigned to tmp_7 above in this context.
	%tmp_8 = arith.muli %tmp_5, %tmp_7 : i32
	cal.set(%l_total__actions__36: !cal.state_ref<i32>, %tmp_8: i32)
	// Generation action: $untagged0
	cal.action "$untagged0" priority=0 {
		// Guard: Start
		cal.predicate {
			%tmp_9 = cal.get(%l_total__rows__35: !cal.state_ref<i32>) : i32
			%tmp_10 = cal.get(%l_total__actions__36: !cal.state_ref<i32>) : i32
			%tmp_11 = arith.cmpi ult, %tmp_9, %tmp_10 : i32
			cal.predicate_result %tmp_11 : i1
		}
		// Guard: End
		// Action Local Variable Decl: Start
		%tmp_12 = arith.constant 0 : i1
		%tmp_13 = arith.extui %tmp_12 : i1 to i22
		// l_outVal__37_d1_0 aliased to tmp_13
		// Action Local Variable Decl: End
		// If Statement: Begin
		%tmp_14 = cal.get(%l_row__index__34: !cal.state_ref<i32>) : i32
		// Evaluate global variable $eval9.
		%tmp_15 = arith.constant 3 : i2
		%tmp_16 = arith.extui %tmp_15 : i2 to i32
		// Evaluate global variable $eval9 done: assigned to tmp_16 above in this context.
		%tmp_17 = arith.cmpi eq, %tmp_14, %tmp_16 : i32
		%l_outVal__37_d1_1 = scf.if %tmp_17 -> (i22) {
			// Assignment Statement: Start
			// Evaluate global variable fixed_point_one.
			%tmp_18 = arith.constant 524288 : i20
			%tmp_19 = arith.extui %tmp_18 : i20 to i22
			// Evaluate global variable fixed_point_one done: assigned to tmp_19 above in this context.
			// l_outVal__37_d2_0 aliased to tmp_19
			// Assignment Statement: End
			scf.yield %tmp_19 : i22
		} else {
			scf.yield %tmp_13 : i22
		}
		// If Statement: End
		// Assignment Statement: Start
		%tmp_20 = cal.get(%l_row__index__34: !cal.state_ref<i32>) : i32
		%tmp_21 = arith.constant 1 : i1
		%tmp_22 = arith.extui %tmp_21 : i1 to i32
		%tmp_23 = arith.addi %tmp_20, %tmp_22 : i32
		// Evaluate global variable $eval1.
		%tmp_24 = arith.constant 4 : i3
		%tmp_25 = arith.extui %tmp_24 : i3 to i32
		// Evaluate global variable $eval1 done: assigned to tmp_25 above in this context.
		%tmp_26 = arith.remui %tmp_23, %tmp_25 : i32
		cal.set(%l_row__index__34: !cal.state_ref<i32>, %tmp_26: i32)
		// Assignment Statement: End
		// Assignment Statement: Start
		%tmp_27 = cal.get(%l_total__rows__35: !cal.state_ref<i32>) : i32
		%tmp_28 = arith.constant 1 : i1
		%tmp_29 = arith.extui %tmp_28 : i1 to i32
		%tmp_30 = arith.addi %tmp_27, %tmp_29 : i32
		cal.set(%l_total__rows__35: !cal.state_ref<i32>, %tmp_30: i32)
		// Assignment Statement: End
		// Output Expression: Start
		fifo.push(%Out: !fifo.input_port<i22>, %l_outVal__37_d1_1: i22)
		// Output Expression: End
	}
}

//-- Definition of actor class: Cap
cal.actor @caps_x_2 ()
	ports_in(%In: !fifo.output_port<i22>)
{
	// -- Actor body
	// Generation action: receive
	cal.action "receive" priority=0 {
		// Input Pattern: Start
		%l_t__42_d1_0 = fifo.pop(%In: !fifo.output_port<i22>) : i22
		// Input Pattern: End
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
		%l_t__42_d1_0 = fifo.pop(%In: !fifo.output_port<i22>) : i22
		// Input Pattern: End
	}
}

//-- Definition of actor class: IGenerator
cal.actor @iGenerator_0 ()
	ports_out(%Out: !fifo.input_port<i22>)
{
	// -- Actor body
	%l_row__index__22 = cal.create_state_var<i32> : !cal.state_ref<i32>
	%tmp_0 = arith.constant 0 : i1
	%tmp_1 = arith.extui %tmp_0 : i1 to i32
	cal.set(%l_row__index__22: !cal.state_ref<i32>, %tmp_1: i32)
	%l_total__rows__23 = cal.create_state_var<i32> : !cal.state_ref<i32>
	%tmp_2 = arith.constant 0 : i1
	%tmp_3 = arith.extui %tmp_2 : i1 to i32
	cal.set(%l_total__rows__23: !cal.state_ref<i32>, %tmp_3: i32)
	%l_total__actions__24 = cal.create_state_var<i32> : !cal.state_ref<i32>
	// Evaluate global variable $eval1.
	%tmp_4 = arith.constant 4 : i3
	%tmp_5 = arith.extui %tmp_4 : i3 to i32
	// Evaluate global variable $eval1 done: assigned to tmp_5 above in this context.
	// Evaluate global variable num_matrices.
	%tmp_6 = arith.constant 10000 : i14
	%tmp_7 = arith.extui %tmp_6 : i14 to i32
	// Evaluate global variable num_matrices done: assigned to tmp_7 above in this context.
	%tmp_8 = arith.muli %tmp_5, %tmp_7 : i32
	cal.set(%l_total__actions__24: !cal.state_ref<i32>, %tmp_8: i32)
	// Generation action: $untagged0
	cal.action "$untagged0" priority=0 {
		// Guard: Start
		cal.predicate {
			%tmp_9 = cal.get(%l_total__rows__23: !cal.state_ref<i32>) : i32
			%tmp_10 = cal.get(%l_total__actions__24: !cal.state_ref<i32>) : i32
			%tmp_11 = arith.cmpi ult, %tmp_9, %tmp_10 : i32
			cal.predicate_result %tmp_11 : i1
		}
		// Guard: End
		// Action Local Variable Decl: Start
		%tmp_12 = arith.constant 0 : i1
		%tmp_13 = arith.extui %tmp_12 : i1 to i22
		// l_outVal__25_d1_0 aliased to tmp_13
		// Action Local Variable Decl: End
		// If Statement: Begin
		%tmp_14 = cal.get(%l_row__index__22: !cal.state_ref<i32>) : i32
		// Evaluate global variable $eval3.
		%tmp_15 = arith.constant 0 : i1
		%tmp_16 = arith.extui %tmp_15 : i1 to i32
		// Evaluate global variable $eval3 done: assigned to tmp_16 above in this context.
		%tmp_17 = arith.cmpi eq, %tmp_14, %tmp_16 : i32
		%l_outVal__25_d1_1 = scf.if %tmp_17 -> (i22) {
			// Assignment Statement: Start
			// Evaluate global variable fixed_point_one.
			%tmp_18 = arith.constant 524288 : i20
			%tmp_19 = arith.extui %tmp_18 : i20 to i22
			// Evaluate global variable fixed_point_one done: assigned to tmp_19 above in this context.
			// l_outVal__25_d2_0 aliased to tmp_19
			// Assignment Statement: End
			scf.yield %tmp_19 : i22
		} else {
			scf.yield %tmp_13 : i22
		}
		// If Statement: End
		// Assignment Statement: Start
		%tmp_20 = cal.get(%l_row__index__22: !cal.state_ref<i32>) : i32
		%tmp_21 = arith.constant 1 : i1
		%tmp_22 = arith.extui %tmp_21 : i1 to i32
		%tmp_23 = arith.addi %tmp_20, %tmp_22 : i32
		// Evaluate global variable $eval1.
		%tmp_24 = arith.constant 4 : i3
		%tmp_25 = arith.extui %tmp_24 : i3 to i32
		// Evaluate global variable $eval1 done: assigned to tmp_25 above in this context.
		%tmp_26 = arith.remui %tmp_23, %tmp_25 : i32
		cal.set(%l_row__index__22: !cal.state_ref<i32>, %tmp_26: i32)
		// Assignment Statement: End
		// Assignment Statement: Start
		%tmp_27 = cal.get(%l_total__rows__23: !cal.state_ref<i32>) : i32
		%tmp_28 = arith.constant 1 : i1
		%tmp_29 = arith.extui %tmp_28 : i1 to i32
		%tmp_30 = arith.addi %tmp_27, %tmp_29 : i32
		cal.set(%l_total__rows__23: !cal.state_ref<i32>, %tmp_30: i32)
		// Assignment Statement: End
		// Output Expression: Start
		fifo.push(%Out: !fifo.input_port<i22>, %l_outVal__25_d1_1: i22)
		// Output Expression: End
	}
}

//-- Definition of actor class: Cap
cal.actor @caps_x_3 ()
	ports_in(%In: !fifo.output_port<i22>)
{
	// -- Actor body
	// Generation action: receive
	cal.action "receive" priority=0 {
		// Input Pattern: Start
		%l_t__42_d1_0 = fifo.pop(%In: !fifo.output_port<i22>) : i22
		// Input Pattern: End
	}
}

//-- Definition of actor class: InnerCell
cal.actor @innerCells_r_0 ()
	ports_in(%x_in: !fifo.output_port<i22>,%cordic_angles_in: !fifo.output_port<i16>)
	ports_out(%x_out: !fifo.input_port<i22>,%r_out: !fifo.input_port<i22>,%cordic_angles_out: !fifo.input_port<i16>)
{
	// -- Actor body
	%l_r__154 = cal.create_state_var<i22> : !cal.state_ref<i22>
	%tmp_0 = arith.constant 0 : i1
	%tmp_1 = arith.extui %tmp_0 : i1 to i22
	cal.set(%l_r__154: !cal.state_ref<i22>, %tmp_1: i22)
	%l_count__155 = cal.create_state_var<i32> : !cal.state_ref<i32>
	%tmp_2 = arith.constant 0 : i1
	%tmp_3 = arith.extui %tmp_2 : i1 to i32
	cal.set(%l_count__155: !cal.state_ref<i32>, %tmp_3: i32)
	// Generation action: $untagged0
	cal.action "$untagged0" priority=0 {
		// Guard: Start
		cal.predicate {
			%tmp_4 = cal.get(%l_count__155: !cal.state_ref<i32>) : i32
			// Evaluate global variable $eval1.
			%tmp_5 = arith.constant 4 : i3
			%tmp_6 = arith.extui %tmp_5 : i3 to i32
			// Evaluate global variable $eval1 done: assigned to tmp_6 above in this context.
			%tmp_7 = arith.cmpi ult, %tmp_4, %tmp_6 : i32
			cal.predicate_result %tmp_7 : i1
		}
		// Guard: End
		// Input Pattern: Start
		%l_x__in__157_d1_0 = fifo.pop(%x_in: !fifo.output_port<i22>) : i22
		// Input Pattern: End
		// Input Pattern: Start
		%l_rotation__angles__160_d1_0 = fifo.pop(%cordic_angles_in: !fifo.output_port<i16>) : i16
		// Input Pattern: End
		// Action Local Variable Decl: Start
		%l_x__out__162_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_x__j__163_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_x__j__plus__1__164_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_x__j__shifted__165_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_y__j__166_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_y__j__plus__1__167_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_y__j__shifted__168_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// If Statement: Begin
		%tmp_8 = cal.get(%l_count__155: !cal.state_ref<i32>) : i32
		%tmp_9 = arith.constant 0 : i1
		%tmp_10 = arith.extui %tmp_9 : i1 to i32
		%tmp_11 = arith.cmpi eq, %tmp_8, %tmp_10 : i32
		scf.if %tmp_11 {
			// Assignment Statement: Start
			%tmp_12 = arith.constant 0 : i1
			%tmp_13 = arith.extui %tmp_12 : i1 to i22
			cal.set(%l_r__154: !cal.state_ref<i22>, %tmp_13: i22)
			// Assignment Statement: End
		} else {
		}
		// If Statement: End
		// Assignment Statement: Start
		// l_x__j__163_d1_1 aliased to l_x__in__157_d1_0
		// Assignment Statement: End
		// Assignment Statement: Start
		%tmp_14 = cal.get(%l_r__154: !cal.state_ref<i22>) : i22
		// l_y__j__166_d1_1 aliased to tmp_14
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
		%l_x__j__163_d1_2, %l_x__j__plus__1__164_d1_1, %l_x__j__shifted__165_d1_1, %l_y__j__166_d1_2, %l_y__j__plus__1__167_d1_1, %l_y__j__shifted__168_d1_1 = scf.for %l_j_d1_0 = %tmp_17_lb to %tmp_25_ub_plus_1 step %tmp_24_step
				iter_args(%l_x__j__163_d2_0 = %l_x__in__157_d1_0, %l_x__j__plus__1__164_d2_0 = %l_x__j__plus__1__164_d1_0, %l_x__j__shifted__165_d2_0 = %l_x__j__shifted__165_d1_0, %l_y__j__166_d2_0 = %tmp_14, %l_y__j__plus__1__167_d2_0 = %l_y__j__plus__1__167_d1_0, %l_y__j__shifted__168_d2_0 = %l_y__j__shifted__168_d1_0) -> (i22, i22, i22, i22, i22, i22) {
			%l_j_d2_0 = arith.index_cast %l_j_d1_0 : index to i32
			%l_j_d2_1 = arith.trunci %l_j_d2_0 : i32 to i8
			// Assignment Statement: Start
			%tmp_26 = arith.extui %l_j_d2_1 : i8 to i22
			%tmp_27 = arith.shrsi %l_y__j__166_d2_0, %tmp_26 : i22
			// l_y__j__shifted__168_d2_1 aliased to tmp_27
			// Assignment Statement: End
			// Assignment Statement: Start
			%tmp_28 = arith.extui %l_j_d2_1 : i8 to i22
			%tmp_29 = arith.shrsi %l_x__j__163_d2_0, %tmp_28 : i22
			// l_x__j__shifted__165_d2_1 aliased to tmp_29
			// Assignment Statement: End
			// If Statement: Begin
			%tmp_30 = arith.extui %l_j_d2_1 : i8 to i16
			%tmp_31 = arith.shrui %l_rotation__angles__160_d1_0, %tmp_30 : i16
			%tmp_32 = arith.constant 1 : i1
			%tmp_33 = arith.trunci %tmp_31 : i16 to i1
			%tmp_34 = arith.andi %tmp_33, %tmp_32 : i1
			%tmp_35 = arith.constant 1 : i1
			%tmp_36 = arith.cmpi eq, %tmp_34, %tmp_35 : i1
			%l_x__j__plus__1__164_d2_1, %l_y__j__plus__1__167_d2_1 = scf.if %tmp_36 -> (i22, i22) {
				// Assignment Statement: Start
				%tmp_37 = arith.extsi %l_x__j__163_d2_0 : i22 to i23
				%tmp_38 = arith.extsi %tmp_27 : i22 to i23
				%tmp_39 = arith.addi %tmp_37, %tmp_38 : i23
				%tmp_40 = arith.trunci %tmp_39 : i23 to i22
				// l_x__j__plus__1__164_d3_0 aliased to tmp_40
				// Assignment Statement: End
				// Assignment Statement: Start
				%tmp_41 = arith.subi %l_y__j__166_d2_0, %tmp_29 : i22
				// l_y__j__plus__1__167_d3_0 aliased to tmp_41
				// Assignment Statement: End
				scf.yield %tmp_40, %tmp_41 : i22, i22
			} else {
				// Assignment Statement: Start
				%tmp_42 = arith.subi %l_x__j__163_d2_0, %tmp_27 : i22
				// l_x__j__plus__1__164_d3_0 aliased to tmp_42
				// Assignment Statement: End
				// Assignment Statement: Start
				%tmp_43 = arith.extsi %l_y__j__166_d2_0 : i22 to i23
				%tmp_44 = arith.extsi %tmp_29 : i22 to i23
				%tmp_45 = arith.addi %tmp_43, %tmp_44 : i23
				%tmp_46 = arith.trunci %tmp_45 : i23 to i22
				// l_y__j__plus__1__167_d3_0 aliased to tmp_46
				// Assignment Statement: End
				scf.yield %tmp_42, %tmp_46 : i22, i22
			}
			// If Statement: End
			// Assignment Statement: Start
			// l_x__j__163_d2_1 aliased to l_x__j__plus__1__164_d2_1
			// Assignment Statement: End
			// Assignment Statement: Start
			// l_y__j__166_d2_1 aliased to l_y__j__plus__1__167_d2_1
			// Assignment Statement: End
			scf.yield %l_x__j__plus__1__164_d2_1, %l_x__j__plus__1__164_d2_1, %tmp_29, %l_y__j__plus__1__167_d2_1, %l_y__j__plus__1__167_d2_1, %tmp_27 : i22, i22, i22, i22, i22, i22
		}
		// Foreach Statement: End
		// Assignment Statement: Start
		// Evaluate global variable k_CORDIC_constant.
		%tmp_48 = arith.constant 318375 : i19
		%tmp_49 = arith.extui %tmp_48 : i19 to i22
		// Evaluate global variable k_CORDIC_constant done: assigned to tmp_49 above in this context.
		// Evaluate global variable fixedPointMultiply.
		%tmp_47 = func.call @g_qrd_fixedPointMultiply(%tmp_49,%l_y__j__166_d1_2) : (i22,i22) -> i22
		// l_x__out__162_d1_1 aliased to tmp_47
		// Assignment Statement: End
		// Assignment Statement: Start
		// Evaluate global variable k_CORDIC_constant.
		%tmp_51 = arith.constant 318375 : i19
		%tmp_52 = arith.extui %tmp_51 : i19 to i22
		// Evaluate global variable k_CORDIC_constant done: assigned to tmp_52 above in this context.
		// Evaluate global variable fixedPointMultiply.
		%tmp_50 = func.call @g_qrd_fixedPointMultiply(%tmp_52,%l_x__j__163_d1_2) : (i22,i22) -> i22
		cal.set(%l_r__154: !cal.state_ref<i22>, %tmp_50: i22)
		// Assignment Statement: End
		// Assignment Statement: Start
		%tmp_53 = cal.get(%l_count__155: !cal.state_ref<i32>) : i32
		%tmp_54 = arith.constant 1 : i1
		%tmp_55 = arith.extui %tmp_54 : i1 to i32
		%tmp_56 = arith.addi %tmp_53, %tmp_55 : i32
		cal.set(%l_count__155: !cal.state_ref<i32>, %tmp_56: i32)
		// Assignment Statement: End
		// Output Expression: Start
		fifo.push(%x_out: !fifo.input_port<i22>, %tmp_47: i22)
		// Output Expression: End
		// Output Expression: Start
		fifo.push(%cordic_angles_out: !fifo.input_port<i16>, %l_rotation__angles__160_d1_0: i16)
		// Output Expression: End
	}
	// Generation action: $untagged1
	cal.action "$untagged1" priority=0 {
		// Guard: Start
		cal.predicate {
			%tmp_57 = cal.get(%l_count__155: !cal.state_ref<i32>) : i32
			// Evaluate global variable $eval1.
			%tmp_58 = arith.constant 4 : i3
			%tmp_59 = arith.extui %tmp_58 : i3 to i32
			// Evaluate global variable $eval1 done: assigned to tmp_59 above in this context.
			%tmp_60 = arith.cmpi eq, %tmp_57, %tmp_59 : i32
			cal.predicate_result %tmp_60 : i1
		}
		// Guard: End
		// Assignment Statement: Start
		%tmp_61 = arith.constant 0 : i1
		%tmp_62 = arith.extui %tmp_61 : i1 to i32
		cal.set(%l_count__155: !cal.state_ref<i32>, %tmp_62: i32)
		// Assignment Statement: End
		// Output Expression: Start
		%tmp_63 = cal.get(%l_r__154: !cal.state_ref<i22>) : i22
		fifo.push(%r_out: !fifo.input_port<i22>, %tmp_63: i22)
		// Output Expression: End
	}
}

//-- Definition of actor class: InnerCell
cal.actor @innerCells_q_11 ()
	ports_in(%x_in: !fifo.output_port<i22>,%cordic_angles_in: !fifo.output_port<i16>)
	ports_out(%x_out: !fifo.input_port<i22>,%r_out: !fifo.input_port<i22>,%cordic_angles_out: !fifo.input_port<i16>)
{
	// -- Actor body
	%l_r__154 = cal.create_state_var<i22> : !cal.state_ref<i22>
	%tmp_0 = arith.constant 0 : i1
	%tmp_1 = arith.extui %tmp_0 : i1 to i22
	cal.set(%l_r__154: !cal.state_ref<i22>, %tmp_1: i22)
	%l_count__155 = cal.create_state_var<i32> : !cal.state_ref<i32>
	%tmp_2 = arith.constant 0 : i1
	%tmp_3 = arith.extui %tmp_2 : i1 to i32
	cal.set(%l_count__155: !cal.state_ref<i32>, %tmp_3: i32)
	// Generation action: $untagged0
	cal.action "$untagged0" priority=0 {
		// Guard: Start
		cal.predicate {
			%tmp_4 = cal.get(%l_count__155: !cal.state_ref<i32>) : i32
			// Evaluate global variable $eval1.
			%tmp_5 = arith.constant 4 : i3
			%tmp_6 = arith.extui %tmp_5 : i3 to i32
			// Evaluate global variable $eval1 done: assigned to tmp_6 above in this context.
			%tmp_7 = arith.cmpi ult, %tmp_4, %tmp_6 : i32
			cal.predicate_result %tmp_7 : i1
		}
		// Guard: End
		// Input Pattern: Start
		%l_x__in__157_d1_0 = fifo.pop(%x_in: !fifo.output_port<i22>) : i22
		// Input Pattern: End
		// Input Pattern: Start
		%l_rotation__angles__160_d1_0 = fifo.pop(%cordic_angles_in: !fifo.output_port<i16>) : i16
		// Input Pattern: End
		// Action Local Variable Decl: Start
		%l_x__out__162_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_x__j__163_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_x__j__plus__1__164_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_x__j__shifted__165_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_y__j__166_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_y__j__plus__1__167_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_y__j__shifted__168_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// If Statement: Begin
		%tmp_8 = cal.get(%l_count__155: !cal.state_ref<i32>) : i32
		%tmp_9 = arith.constant 0 : i1
		%tmp_10 = arith.extui %tmp_9 : i1 to i32
		%tmp_11 = arith.cmpi eq, %tmp_8, %tmp_10 : i32
		scf.if %tmp_11 {
			// Assignment Statement: Start
			%tmp_12 = arith.constant 0 : i1
			%tmp_13 = arith.extui %tmp_12 : i1 to i22
			cal.set(%l_r__154: !cal.state_ref<i22>, %tmp_13: i22)
			// Assignment Statement: End
		} else {
		}
		// If Statement: End
		// Assignment Statement: Start
		// l_x__j__163_d1_1 aliased to l_x__in__157_d1_0
		// Assignment Statement: End
		// Assignment Statement: Start
		%tmp_14 = cal.get(%l_r__154: !cal.state_ref<i22>) : i22
		// l_y__j__166_d1_1 aliased to tmp_14
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
		%l_x__j__163_d1_2, %l_x__j__plus__1__164_d1_1, %l_x__j__shifted__165_d1_1, %l_y__j__166_d1_2, %l_y__j__plus__1__167_d1_1, %l_y__j__shifted__168_d1_1 = scf.for %l_j_d1_0 = %tmp_17_lb to %tmp_25_ub_plus_1 step %tmp_24_step
				iter_args(%l_x__j__163_d2_0 = %l_x__in__157_d1_0, %l_x__j__plus__1__164_d2_0 = %l_x__j__plus__1__164_d1_0, %l_x__j__shifted__165_d2_0 = %l_x__j__shifted__165_d1_0, %l_y__j__166_d2_0 = %tmp_14, %l_y__j__plus__1__167_d2_0 = %l_y__j__plus__1__167_d1_0, %l_y__j__shifted__168_d2_0 = %l_y__j__shifted__168_d1_0) -> (i22, i22, i22, i22, i22, i22) {
			%l_j_d2_0 = arith.index_cast %l_j_d1_0 : index to i32
			%l_j_d2_1 = arith.trunci %l_j_d2_0 : i32 to i8
			// Assignment Statement: Start
			%tmp_26 = arith.extui %l_j_d2_1 : i8 to i22
			%tmp_27 = arith.shrsi %l_y__j__166_d2_0, %tmp_26 : i22
			// l_y__j__shifted__168_d2_1 aliased to tmp_27
			// Assignment Statement: End
			// Assignment Statement: Start
			%tmp_28 = arith.extui %l_j_d2_1 : i8 to i22
			%tmp_29 = arith.shrsi %l_x__j__163_d2_0, %tmp_28 : i22
			// l_x__j__shifted__165_d2_1 aliased to tmp_29
			// Assignment Statement: End
			// If Statement: Begin
			%tmp_30 = arith.extui %l_j_d2_1 : i8 to i16
			%tmp_31 = arith.shrui %l_rotation__angles__160_d1_0, %tmp_30 : i16
			%tmp_32 = arith.constant 1 : i1
			%tmp_33 = arith.trunci %tmp_31 : i16 to i1
			%tmp_34 = arith.andi %tmp_33, %tmp_32 : i1
			%tmp_35 = arith.constant 1 : i1
			%tmp_36 = arith.cmpi eq, %tmp_34, %tmp_35 : i1
			%l_x__j__plus__1__164_d2_1, %l_y__j__plus__1__167_d2_1 = scf.if %tmp_36 -> (i22, i22) {
				// Assignment Statement: Start
				%tmp_37 = arith.extsi %l_x__j__163_d2_0 : i22 to i23
				%tmp_38 = arith.extsi %tmp_27 : i22 to i23
				%tmp_39 = arith.addi %tmp_37, %tmp_38 : i23
				%tmp_40 = arith.trunci %tmp_39 : i23 to i22
				// l_x__j__plus__1__164_d3_0 aliased to tmp_40
				// Assignment Statement: End
				// Assignment Statement: Start
				%tmp_41 = arith.subi %l_y__j__166_d2_0, %tmp_29 : i22
				// l_y__j__plus__1__167_d3_0 aliased to tmp_41
				// Assignment Statement: End
				scf.yield %tmp_40, %tmp_41 : i22, i22
			} else {
				// Assignment Statement: Start
				%tmp_42 = arith.subi %l_x__j__163_d2_0, %tmp_27 : i22
				// l_x__j__plus__1__164_d3_0 aliased to tmp_42
				// Assignment Statement: End
				// Assignment Statement: Start
				%tmp_43 = arith.extsi %l_y__j__166_d2_0 : i22 to i23
				%tmp_44 = arith.extsi %tmp_29 : i22 to i23
				%tmp_45 = arith.addi %tmp_43, %tmp_44 : i23
				%tmp_46 = arith.trunci %tmp_45 : i23 to i22
				// l_y__j__plus__1__167_d3_0 aliased to tmp_46
				// Assignment Statement: End
				scf.yield %tmp_42, %tmp_46 : i22, i22
			}
			// If Statement: End
			// Assignment Statement: Start
			// l_x__j__163_d2_1 aliased to l_x__j__plus__1__164_d2_1
			// Assignment Statement: End
			// Assignment Statement: Start
			// l_y__j__166_d2_1 aliased to l_y__j__plus__1__167_d2_1
			// Assignment Statement: End
			scf.yield %l_x__j__plus__1__164_d2_1, %l_x__j__plus__1__164_d2_1, %tmp_29, %l_y__j__plus__1__167_d2_1, %l_y__j__plus__1__167_d2_1, %tmp_27 : i22, i22, i22, i22, i22, i22
		}
		// Foreach Statement: End
		// Assignment Statement: Start
		// Evaluate global variable k_CORDIC_constant.
		%tmp_48 = arith.constant 318375 : i19
		%tmp_49 = arith.extui %tmp_48 : i19 to i22
		// Evaluate global variable k_CORDIC_constant done: assigned to tmp_49 above in this context.
		// Evaluate global variable fixedPointMultiply.
		%tmp_47 = func.call @g_qrd_fixedPointMultiply(%tmp_49,%l_y__j__166_d1_2) : (i22,i22) -> i22
		// l_x__out__162_d1_1 aliased to tmp_47
		// Assignment Statement: End
		// Assignment Statement: Start
		// Evaluate global variable k_CORDIC_constant.
		%tmp_51 = arith.constant 318375 : i19
		%tmp_52 = arith.extui %tmp_51 : i19 to i22
		// Evaluate global variable k_CORDIC_constant done: assigned to tmp_52 above in this context.
		// Evaluate global variable fixedPointMultiply.
		%tmp_50 = func.call @g_qrd_fixedPointMultiply(%tmp_52,%l_x__j__163_d1_2) : (i22,i22) -> i22
		cal.set(%l_r__154: !cal.state_ref<i22>, %tmp_50: i22)
		// Assignment Statement: End
		// Assignment Statement: Start
		%tmp_53 = cal.get(%l_count__155: !cal.state_ref<i32>) : i32
		%tmp_54 = arith.constant 1 : i1
		%tmp_55 = arith.extui %tmp_54 : i1 to i32
		%tmp_56 = arith.addi %tmp_53, %tmp_55 : i32
		cal.set(%l_count__155: !cal.state_ref<i32>, %tmp_56: i32)
		// Assignment Statement: End
		// Output Expression: Start
		fifo.push(%x_out: !fifo.input_port<i22>, %tmp_47: i22)
		// Output Expression: End
		// Output Expression: Start
		fifo.push(%cordic_angles_out: !fifo.input_port<i16>, %l_rotation__angles__160_d1_0: i16)
		// Output Expression: End
	}
	// Generation action: $untagged1
	cal.action "$untagged1" priority=0 {
		// Guard: Start
		cal.predicate {
			%tmp_57 = cal.get(%l_count__155: !cal.state_ref<i32>) : i32
			// Evaluate global variable $eval1.
			%tmp_58 = arith.constant 4 : i3
			%tmp_59 = arith.extui %tmp_58 : i3 to i32
			// Evaluate global variable $eval1 done: assigned to tmp_59 above in this context.
			%tmp_60 = arith.cmpi eq, %tmp_57, %tmp_59 : i32
			cal.predicate_result %tmp_60 : i1
		}
		// Guard: End
		// Assignment Statement: Start
		%tmp_61 = arith.constant 0 : i1
		%tmp_62 = arith.extui %tmp_61 : i1 to i32
		cal.set(%l_count__155: !cal.state_ref<i32>, %tmp_62: i32)
		// Assignment Statement: End
		// Output Expression: Start
		%tmp_63 = cal.get(%l_r__154: !cal.state_ref<i22>) : i22
		fifo.push(%r_out: !fifo.input_port<i22>, %tmp_63: i22)
		// Output Expression: End
	}
}

//-- Definition of actor class: InnerCell
cal.actor @innerCells_q_12 ()
	ports_in(%x_in: !fifo.output_port<i22>,%cordic_angles_in: !fifo.output_port<i16>)
	ports_out(%x_out: !fifo.input_port<i22>,%r_out: !fifo.input_port<i22>,%cordic_angles_out: !fifo.input_port<i16>)
{
	// -- Actor body
	%l_r__154 = cal.create_state_var<i22> : !cal.state_ref<i22>
	%tmp_0 = arith.constant 0 : i1
	%tmp_1 = arith.extui %tmp_0 : i1 to i22
	cal.set(%l_r__154: !cal.state_ref<i22>, %tmp_1: i22)
	%l_count__155 = cal.create_state_var<i32> : !cal.state_ref<i32>
	%tmp_2 = arith.constant 0 : i1
	%tmp_3 = arith.extui %tmp_2 : i1 to i32
	cal.set(%l_count__155: !cal.state_ref<i32>, %tmp_3: i32)
	// Generation action: $untagged0
	cal.action "$untagged0" priority=0 {
		// Guard: Start
		cal.predicate {
			%tmp_4 = cal.get(%l_count__155: !cal.state_ref<i32>) : i32
			// Evaluate global variable $eval1.
			%tmp_5 = arith.constant 4 : i3
			%tmp_6 = arith.extui %tmp_5 : i3 to i32
			// Evaluate global variable $eval1 done: assigned to tmp_6 above in this context.
			%tmp_7 = arith.cmpi ult, %tmp_4, %tmp_6 : i32
			cal.predicate_result %tmp_7 : i1
		}
		// Guard: End
		// Input Pattern: Start
		%l_x__in__157_d1_0 = fifo.pop(%x_in: !fifo.output_port<i22>) : i22
		// Input Pattern: End
		// Input Pattern: Start
		%l_rotation__angles__160_d1_0 = fifo.pop(%cordic_angles_in: !fifo.output_port<i16>) : i16
		// Input Pattern: End
		// Action Local Variable Decl: Start
		%l_x__out__162_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_x__j__163_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_x__j__plus__1__164_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_x__j__shifted__165_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_y__j__166_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_y__j__plus__1__167_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_y__j__shifted__168_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// If Statement: Begin
		%tmp_8 = cal.get(%l_count__155: !cal.state_ref<i32>) : i32
		%tmp_9 = arith.constant 0 : i1
		%tmp_10 = arith.extui %tmp_9 : i1 to i32
		%tmp_11 = arith.cmpi eq, %tmp_8, %tmp_10 : i32
		scf.if %tmp_11 {
			// Assignment Statement: Start
			%tmp_12 = arith.constant 0 : i1
			%tmp_13 = arith.extui %tmp_12 : i1 to i22
			cal.set(%l_r__154: !cal.state_ref<i22>, %tmp_13: i22)
			// Assignment Statement: End
		} else {
		}
		// If Statement: End
		// Assignment Statement: Start
		// l_x__j__163_d1_1 aliased to l_x__in__157_d1_0
		// Assignment Statement: End
		// Assignment Statement: Start
		%tmp_14 = cal.get(%l_r__154: !cal.state_ref<i22>) : i22
		// l_y__j__166_d1_1 aliased to tmp_14
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
		%l_x__j__163_d1_2, %l_x__j__plus__1__164_d1_1, %l_x__j__shifted__165_d1_1, %l_y__j__166_d1_2, %l_y__j__plus__1__167_d1_1, %l_y__j__shifted__168_d1_1 = scf.for %l_j_d1_0 = %tmp_17_lb to %tmp_25_ub_plus_1 step %tmp_24_step
				iter_args(%l_x__j__163_d2_0 = %l_x__in__157_d1_0, %l_x__j__plus__1__164_d2_0 = %l_x__j__plus__1__164_d1_0, %l_x__j__shifted__165_d2_0 = %l_x__j__shifted__165_d1_0, %l_y__j__166_d2_0 = %tmp_14, %l_y__j__plus__1__167_d2_0 = %l_y__j__plus__1__167_d1_0, %l_y__j__shifted__168_d2_0 = %l_y__j__shifted__168_d1_0) -> (i22, i22, i22, i22, i22, i22) {
			%l_j_d2_0 = arith.index_cast %l_j_d1_0 : index to i32
			%l_j_d2_1 = arith.trunci %l_j_d2_0 : i32 to i8
			// Assignment Statement: Start
			%tmp_26 = arith.extui %l_j_d2_1 : i8 to i22
			%tmp_27 = arith.shrsi %l_y__j__166_d2_0, %tmp_26 : i22
			// l_y__j__shifted__168_d2_1 aliased to tmp_27
			// Assignment Statement: End
			// Assignment Statement: Start
			%tmp_28 = arith.extui %l_j_d2_1 : i8 to i22
			%tmp_29 = arith.shrsi %l_x__j__163_d2_0, %tmp_28 : i22
			// l_x__j__shifted__165_d2_1 aliased to tmp_29
			// Assignment Statement: End
			// If Statement: Begin
			%tmp_30 = arith.extui %l_j_d2_1 : i8 to i16
			%tmp_31 = arith.shrui %l_rotation__angles__160_d1_0, %tmp_30 : i16
			%tmp_32 = arith.constant 1 : i1
			%tmp_33 = arith.trunci %tmp_31 : i16 to i1
			%tmp_34 = arith.andi %tmp_33, %tmp_32 : i1
			%tmp_35 = arith.constant 1 : i1
			%tmp_36 = arith.cmpi eq, %tmp_34, %tmp_35 : i1
			%l_x__j__plus__1__164_d2_1, %l_y__j__plus__1__167_d2_1 = scf.if %tmp_36 -> (i22, i22) {
				// Assignment Statement: Start
				%tmp_37 = arith.extsi %l_x__j__163_d2_0 : i22 to i23
				%tmp_38 = arith.extsi %tmp_27 : i22 to i23
				%tmp_39 = arith.addi %tmp_37, %tmp_38 : i23
				%tmp_40 = arith.trunci %tmp_39 : i23 to i22
				// l_x__j__plus__1__164_d3_0 aliased to tmp_40
				// Assignment Statement: End
				// Assignment Statement: Start
				%tmp_41 = arith.subi %l_y__j__166_d2_0, %tmp_29 : i22
				// l_y__j__plus__1__167_d3_0 aliased to tmp_41
				// Assignment Statement: End
				scf.yield %tmp_40, %tmp_41 : i22, i22
			} else {
				// Assignment Statement: Start
				%tmp_42 = arith.subi %l_x__j__163_d2_0, %tmp_27 : i22
				// l_x__j__plus__1__164_d3_0 aliased to tmp_42
				// Assignment Statement: End
				// Assignment Statement: Start
				%tmp_43 = arith.extsi %l_y__j__166_d2_0 : i22 to i23
				%tmp_44 = arith.extsi %tmp_29 : i22 to i23
				%tmp_45 = arith.addi %tmp_43, %tmp_44 : i23
				%tmp_46 = arith.trunci %tmp_45 : i23 to i22
				// l_y__j__plus__1__167_d3_0 aliased to tmp_46
				// Assignment Statement: End
				scf.yield %tmp_42, %tmp_46 : i22, i22
			}
			// If Statement: End
			// Assignment Statement: Start
			// l_x__j__163_d2_1 aliased to l_x__j__plus__1__164_d2_1
			// Assignment Statement: End
			// Assignment Statement: Start
			// l_y__j__166_d2_1 aliased to l_y__j__plus__1__167_d2_1
			// Assignment Statement: End
			scf.yield %l_x__j__plus__1__164_d2_1, %l_x__j__plus__1__164_d2_1, %tmp_29, %l_y__j__plus__1__167_d2_1, %l_y__j__plus__1__167_d2_1, %tmp_27 : i22, i22, i22, i22, i22, i22
		}
		// Foreach Statement: End
		// Assignment Statement: Start
		// Evaluate global variable k_CORDIC_constant.
		%tmp_48 = arith.constant 318375 : i19
		%tmp_49 = arith.extui %tmp_48 : i19 to i22
		// Evaluate global variable k_CORDIC_constant done: assigned to tmp_49 above in this context.
		// Evaluate global variable fixedPointMultiply.
		%tmp_47 = func.call @g_qrd_fixedPointMultiply(%tmp_49,%l_y__j__166_d1_2) : (i22,i22) -> i22
		// l_x__out__162_d1_1 aliased to tmp_47
		// Assignment Statement: End
		// Assignment Statement: Start
		// Evaluate global variable k_CORDIC_constant.
		%tmp_51 = arith.constant 318375 : i19
		%tmp_52 = arith.extui %tmp_51 : i19 to i22
		// Evaluate global variable k_CORDIC_constant done: assigned to tmp_52 above in this context.
		// Evaluate global variable fixedPointMultiply.
		%tmp_50 = func.call @g_qrd_fixedPointMultiply(%tmp_52,%l_x__j__163_d1_2) : (i22,i22) -> i22
		cal.set(%l_r__154: !cal.state_ref<i22>, %tmp_50: i22)
		// Assignment Statement: End
		// Assignment Statement: Start
		%tmp_53 = cal.get(%l_count__155: !cal.state_ref<i32>) : i32
		%tmp_54 = arith.constant 1 : i1
		%tmp_55 = arith.extui %tmp_54 : i1 to i32
		%tmp_56 = arith.addi %tmp_53, %tmp_55 : i32
		cal.set(%l_count__155: !cal.state_ref<i32>, %tmp_56: i32)
		// Assignment Statement: End
		// Output Expression: Start
		fifo.push(%x_out: !fifo.input_port<i22>, %tmp_47: i22)
		// Output Expression: End
		// Output Expression: Start
		fifo.push(%cordic_angles_out: !fifo.input_port<i16>, %l_rotation__angles__160_d1_0: i16)
		// Output Expression: End
	}
	// Generation action: $untagged1
	cal.action "$untagged1" priority=0 {
		// Guard: Start
		cal.predicate {
			%tmp_57 = cal.get(%l_count__155: !cal.state_ref<i32>) : i32
			// Evaluate global variable $eval1.
			%tmp_58 = arith.constant 4 : i3
			%tmp_59 = arith.extui %tmp_58 : i3 to i32
			// Evaluate global variable $eval1 done: assigned to tmp_59 above in this context.
			%tmp_60 = arith.cmpi eq, %tmp_57, %tmp_59 : i32
			cal.predicate_result %tmp_60 : i1
		}
		// Guard: End
		// Assignment Statement: Start
		%tmp_61 = arith.constant 0 : i1
		%tmp_62 = arith.extui %tmp_61 : i1 to i32
		cal.set(%l_count__155: !cal.state_ref<i32>, %tmp_62: i32)
		// Assignment Statement: End
		// Output Expression: Start
		%tmp_63 = cal.get(%l_r__154: !cal.state_ref<i22>) : i22
		fifo.push(%r_out: !fifo.input_port<i22>, %tmp_63: i22)
		// Output Expression: End
	}
}

//-- Definition of actor class: InnerCell
cal.actor @innerCells_q_10 ()
	ports_in(%x_in: !fifo.output_port<i22>,%cordic_angles_in: !fifo.output_port<i16>)
	ports_out(%x_out: !fifo.input_port<i22>,%r_out: !fifo.input_port<i22>,%cordic_angles_out: !fifo.input_port<i16>)
{
	// -- Actor body
	%l_r__154 = cal.create_state_var<i22> : !cal.state_ref<i22>
	%tmp_0 = arith.constant 0 : i1
	%tmp_1 = arith.extui %tmp_0 : i1 to i22
	cal.set(%l_r__154: !cal.state_ref<i22>, %tmp_1: i22)
	%l_count__155 = cal.create_state_var<i32> : !cal.state_ref<i32>
	%tmp_2 = arith.constant 0 : i1
	%tmp_3 = arith.extui %tmp_2 : i1 to i32
	cal.set(%l_count__155: !cal.state_ref<i32>, %tmp_3: i32)
	// Generation action: $untagged0
	cal.action "$untagged0" priority=0 {
		// Guard: Start
		cal.predicate {
			%tmp_4 = cal.get(%l_count__155: !cal.state_ref<i32>) : i32
			// Evaluate global variable $eval1.
			%tmp_5 = arith.constant 4 : i3
			%tmp_6 = arith.extui %tmp_5 : i3 to i32
			// Evaluate global variable $eval1 done: assigned to tmp_6 above in this context.
			%tmp_7 = arith.cmpi ult, %tmp_4, %tmp_6 : i32
			cal.predicate_result %tmp_7 : i1
		}
		// Guard: End
		// Input Pattern: Start
		%l_x__in__157_d1_0 = fifo.pop(%x_in: !fifo.output_port<i22>) : i22
		// Input Pattern: End
		// Input Pattern: Start
		%l_rotation__angles__160_d1_0 = fifo.pop(%cordic_angles_in: !fifo.output_port<i16>) : i16
		// Input Pattern: End
		// Action Local Variable Decl: Start
		%l_x__out__162_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_x__j__163_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_x__j__plus__1__164_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_x__j__shifted__165_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_y__j__166_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_y__j__plus__1__167_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_y__j__shifted__168_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// If Statement: Begin
		%tmp_8 = cal.get(%l_count__155: !cal.state_ref<i32>) : i32
		%tmp_9 = arith.constant 0 : i1
		%tmp_10 = arith.extui %tmp_9 : i1 to i32
		%tmp_11 = arith.cmpi eq, %tmp_8, %tmp_10 : i32
		scf.if %tmp_11 {
			// Assignment Statement: Start
			%tmp_12 = arith.constant 0 : i1
			%tmp_13 = arith.extui %tmp_12 : i1 to i22
			cal.set(%l_r__154: !cal.state_ref<i22>, %tmp_13: i22)
			// Assignment Statement: End
		} else {
		}
		// If Statement: End
		// Assignment Statement: Start
		// l_x__j__163_d1_1 aliased to l_x__in__157_d1_0
		// Assignment Statement: End
		// Assignment Statement: Start
		%tmp_14 = cal.get(%l_r__154: !cal.state_ref<i22>) : i22
		// l_y__j__166_d1_1 aliased to tmp_14
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
		%l_x__j__163_d1_2, %l_x__j__plus__1__164_d1_1, %l_x__j__shifted__165_d1_1, %l_y__j__166_d1_2, %l_y__j__plus__1__167_d1_1, %l_y__j__shifted__168_d1_1 = scf.for %l_j_d1_0 = %tmp_17_lb to %tmp_25_ub_plus_1 step %tmp_24_step
				iter_args(%l_x__j__163_d2_0 = %l_x__in__157_d1_0, %l_x__j__plus__1__164_d2_0 = %l_x__j__plus__1__164_d1_0, %l_x__j__shifted__165_d2_0 = %l_x__j__shifted__165_d1_0, %l_y__j__166_d2_0 = %tmp_14, %l_y__j__plus__1__167_d2_0 = %l_y__j__plus__1__167_d1_0, %l_y__j__shifted__168_d2_0 = %l_y__j__shifted__168_d1_0) -> (i22, i22, i22, i22, i22, i22) {
			%l_j_d2_0 = arith.index_cast %l_j_d1_0 : index to i32
			%l_j_d2_1 = arith.trunci %l_j_d2_0 : i32 to i8
			// Assignment Statement: Start
			%tmp_26 = arith.extui %l_j_d2_1 : i8 to i22
			%tmp_27 = arith.shrsi %l_y__j__166_d2_0, %tmp_26 : i22
			// l_y__j__shifted__168_d2_1 aliased to tmp_27
			// Assignment Statement: End
			// Assignment Statement: Start
			%tmp_28 = arith.extui %l_j_d2_1 : i8 to i22
			%tmp_29 = arith.shrsi %l_x__j__163_d2_0, %tmp_28 : i22
			// l_x__j__shifted__165_d2_1 aliased to tmp_29
			// Assignment Statement: End
			// If Statement: Begin
			%tmp_30 = arith.extui %l_j_d2_1 : i8 to i16
			%tmp_31 = arith.shrui %l_rotation__angles__160_d1_0, %tmp_30 : i16
			%tmp_32 = arith.constant 1 : i1
			%tmp_33 = arith.trunci %tmp_31 : i16 to i1
			%tmp_34 = arith.andi %tmp_33, %tmp_32 : i1
			%tmp_35 = arith.constant 1 : i1
			%tmp_36 = arith.cmpi eq, %tmp_34, %tmp_35 : i1
			%l_x__j__plus__1__164_d2_1, %l_y__j__plus__1__167_d2_1 = scf.if %tmp_36 -> (i22, i22) {
				// Assignment Statement: Start
				%tmp_37 = arith.extsi %l_x__j__163_d2_0 : i22 to i23
				%tmp_38 = arith.extsi %tmp_27 : i22 to i23
				%tmp_39 = arith.addi %tmp_37, %tmp_38 : i23
				%tmp_40 = arith.trunci %tmp_39 : i23 to i22
				// l_x__j__plus__1__164_d3_0 aliased to tmp_40
				// Assignment Statement: End
				// Assignment Statement: Start
				%tmp_41 = arith.subi %l_y__j__166_d2_0, %tmp_29 : i22
				// l_y__j__plus__1__167_d3_0 aliased to tmp_41
				// Assignment Statement: End
				scf.yield %tmp_40, %tmp_41 : i22, i22
			} else {
				// Assignment Statement: Start
				%tmp_42 = arith.subi %l_x__j__163_d2_0, %tmp_27 : i22
				// l_x__j__plus__1__164_d3_0 aliased to tmp_42
				// Assignment Statement: End
				// Assignment Statement: Start
				%tmp_43 = arith.extsi %l_y__j__166_d2_0 : i22 to i23
				%tmp_44 = arith.extsi %tmp_29 : i22 to i23
				%tmp_45 = arith.addi %tmp_43, %tmp_44 : i23
				%tmp_46 = arith.trunci %tmp_45 : i23 to i22
				// l_y__j__plus__1__167_d3_0 aliased to tmp_46
				// Assignment Statement: End
				scf.yield %tmp_42, %tmp_46 : i22, i22
			}
			// If Statement: End
			// Assignment Statement: Start
			// l_x__j__163_d2_1 aliased to l_x__j__plus__1__164_d2_1
			// Assignment Statement: End
			// Assignment Statement: Start
			// l_y__j__166_d2_1 aliased to l_y__j__plus__1__167_d2_1
			// Assignment Statement: End
			scf.yield %l_x__j__plus__1__164_d2_1, %l_x__j__plus__1__164_d2_1, %tmp_29, %l_y__j__plus__1__167_d2_1, %l_y__j__plus__1__167_d2_1, %tmp_27 : i22, i22, i22, i22, i22, i22
		}
		// Foreach Statement: End
		// Assignment Statement: Start
		// Evaluate global variable k_CORDIC_constant.
		%tmp_48 = arith.constant 318375 : i19
		%tmp_49 = arith.extui %tmp_48 : i19 to i22
		// Evaluate global variable k_CORDIC_constant done: assigned to tmp_49 above in this context.
		// Evaluate global variable fixedPointMultiply.
		%tmp_47 = func.call @g_qrd_fixedPointMultiply(%tmp_49,%l_y__j__166_d1_2) : (i22,i22) -> i22
		// l_x__out__162_d1_1 aliased to tmp_47
		// Assignment Statement: End
		// Assignment Statement: Start
		// Evaluate global variable k_CORDIC_constant.
		%tmp_51 = arith.constant 318375 : i19
		%tmp_52 = arith.extui %tmp_51 : i19 to i22
		// Evaluate global variable k_CORDIC_constant done: assigned to tmp_52 above in this context.
		// Evaluate global variable fixedPointMultiply.
		%tmp_50 = func.call @g_qrd_fixedPointMultiply(%tmp_52,%l_x__j__163_d1_2) : (i22,i22) -> i22
		cal.set(%l_r__154: !cal.state_ref<i22>, %tmp_50: i22)
		// Assignment Statement: End
		// Assignment Statement: Start
		%tmp_53 = cal.get(%l_count__155: !cal.state_ref<i32>) : i32
		%tmp_54 = arith.constant 1 : i1
		%tmp_55 = arith.extui %tmp_54 : i1 to i32
		%tmp_56 = arith.addi %tmp_53, %tmp_55 : i32
		cal.set(%l_count__155: !cal.state_ref<i32>, %tmp_56: i32)
		// Assignment Statement: End
		// Output Expression: Start
		fifo.push(%x_out: !fifo.input_port<i22>, %tmp_47: i22)
		// Output Expression: End
		// Output Expression: Start
		fifo.push(%cordic_angles_out: !fifo.input_port<i16>, %l_rotation__angles__160_d1_0: i16)
		// Output Expression: End
	}
	// Generation action: $untagged1
	cal.action "$untagged1" priority=0 {
		// Guard: Start
		cal.predicate {
			%tmp_57 = cal.get(%l_count__155: !cal.state_ref<i32>) : i32
			// Evaluate global variable $eval1.
			%tmp_58 = arith.constant 4 : i3
			%tmp_59 = arith.extui %tmp_58 : i3 to i32
			// Evaluate global variable $eval1 done: assigned to tmp_59 above in this context.
			%tmp_60 = arith.cmpi eq, %tmp_57, %tmp_59 : i32
			cal.predicate_result %tmp_60 : i1
		}
		// Guard: End
		// Assignment Statement: Start
		%tmp_61 = arith.constant 0 : i1
		%tmp_62 = arith.extui %tmp_61 : i1 to i32
		cal.set(%l_count__155: !cal.state_ref<i32>, %tmp_62: i32)
		// Assignment Statement: End
		// Output Expression: Start
		%tmp_63 = cal.get(%l_r__154: !cal.state_ref<i22>) : i22
		fifo.push(%r_out: !fifo.input_port<i22>, %tmp_63: i22)
		// Output Expression: End
	}
}

//-- Definition of actor class: InnerCell
cal.actor @innerCells_q_15 ()
	ports_in(%x_in: !fifo.output_port<i22>,%cordic_angles_in: !fifo.output_port<i16>)
	ports_out(%x_out: !fifo.input_port<i22>,%r_out: !fifo.input_port<i22>,%cordic_angles_out: !fifo.input_port<i16>)
{
	// -- Actor body
	%l_r__154 = cal.create_state_var<i22> : !cal.state_ref<i22>
	%tmp_0 = arith.constant 0 : i1
	%tmp_1 = arith.extui %tmp_0 : i1 to i22
	cal.set(%l_r__154: !cal.state_ref<i22>, %tmp_1: i22)
	%l_count__155 = cal.create_state_var<i32> : !cal.state_ref<i32>
	%tmp_2 = arith.constant 0 : i1
	%tmp_3 = arith.extui %tmp_2 : i1 to i32
	cal.set(%l_count__155: !cal.state_ref<i32>, %tmp_3: i32)
	// Generation action: $untagged0
	cal.action "$untagged0" priority=0 {
		// Guard: Start
		cal.predicate {
			%tmp_4 = cal.get(%l_count__155: !cal.state_ref<i32>) : i32
			// Evaluate global variable $eval1.
			%tmp_5 = arith.constant 4 : i3
			%tmp_6 = arith.extui %tmp_5 : i3 to i32
			// Evaluate global variable $eval1 done: assigned to tmp_6 above in this context.
			%tmp_7 = arith.cmpi ult, %tmp_4, %tmp_6 : i32
			cal.predicate_result %tmp_7 : i1
		}
		// Guard: End
		// Input Pattern: Start
		%l_x__in__157_d1_0 = fifo.pop(%x_in: !fifo.output_port<i22>) : i22
		// Input Pattern: End
		// Input Pattern: Start
		%l_rotation__angles__160_d1_0 = fifo.pop(%cordic_angles_in: !fifo.output_port<i16>) : i16
		// Input Pattern: End
		// Action Local Variable Decl: Start
		%l_x__out__162_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_x__j__163_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_x__j__plus__1__164_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_x__j__shifted__165_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_y__j__166_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_y__j__plus__1__167_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_y__j__shifted__168_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// If Statement: Begin
		%tmp_8 = cal.get(%l_count__155: !cal.state_ref<i32>) : i32
		%tmp_9 = arith.constant 0 : i1
		%tmp_10 = arith.extui %tmp_9 : i1 to i32
		%tmp_11 = arith.cmpi eq, %tmp_8, %tmp_10 : i32
		scf.if %tmp_11 {
			// Assignment Statement: Start
			%tmp_12 = arith.constant 0 : i1
			%tmp_13 = arith.extui %tmp_12 : i1 to i22
			cal.set(%l_r__154: !cal.state_ref<i22>, %tmp_13: i22)
			// Assignment Statement: End
		} else {
		}
		// If Statement: End
		// Assignment Statement: Start
		// l_x__j__163_d1_1 aliased to l_x__in__157_d1_0
		// Assignment Statement: End
		// Assignment Statement: Start
		%tmp_14 = cal.get(%l_r__154: !cal.state_ref<i22>) : i22
		// l_y__j__166_d1_1 aliased to tmp_14
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
		%l_x__j__163_d1_2, %l_x__j__plus__1__164_d1_1, %l_x__j__shifted__165_d1_1, %l_y__j__166_d1_2, %l_y__j__plus__1__167_d1_1, %l_y__j__shifted__168_d1_1 = scf.for %l_j_d1_0 = %tmp_17_lb to %tmp_25_ub_plus_1 step %tmp_24_step
				iter_args(%l_x__j__163_d2_0 = %l_x__in__157_d1_0, %l_x__j__plus__1__164_d2_0 = %l_x__j__plus__1__164_d1_0, %l_x__j__shifted__165_d2_0 = %l_x__j__shifted__165_d1_0, %l_y__j__166_d2_0 = %tmp_14, %l_y__j__plus__1__167_d2_0 = %l_y__j__plus__1__167_d1_0, %l_y__j__shifted__168_d2_0 = %l_y__j__shifted__168_d1_0) -> (i22, i22, i22, i22, i22, i22) {
			%l_j_d2_0 = arith.index_cast %l_j_d1_0 : index to i32
			%l_j_d2_1 = arith.trunci %l_j_d2_0 : i32 to i8
			// Assignment Statement: Start
			%tmp_26 = arith.extui %l_j_d2_1 : i8 to i22
			%tmp_27 = arith.shrsi %l_y__j__166_d2_0, %tmp_26 : i22
			// l_y__j__shifted__168_d2_1 aliased to tmp_27
			// Assignment Statement: End
			// Assignment Statement: Start
			%tmp_28 = arith.extui %l_j_d2_1 : i8 to i22
			%tmp_29 = arith.shrsi %l_x__j__163_d2_0, %tmp_28 : i22
			// l_x__j__shifted__165_d2_1 aliased to tmp_29
			// Assignment Statement: End
			// If Statement: Begin
			%tmp_30 = arith.extui %l_j_d2_1 : i8 to i16
			%tmp_31 = arith.shrui %l_rotation__angles__160_d1_0, %tmp_30 : i16
			%tmp_32 = arith.constant 1 : i1
			%tmp_33 = arith.trunci %tmp_31 : i16 to i1
			%tmp_34 = arith.andi %tmp_33, %tmp_32 : i1
			%tmp_35 = arith.constant 1 : i1
			%tmp_36 = arith.cmpi eq, %tmp_34, %tmp_35 : i1
			%l_x__j__plus__1__164_d2_1, %l_y__j__plus__1__167_d2_1 = scf.if %tmp_36 -> (i22, i22) {
				// Assignment Statement: Start
				%tmp_37 = arith.extsi %l_x__j__163_d2_0 : i22 to i23
				%tmp_38 = arith.extsi %tmp_27 : i22 to i23
				%tmp_39 = arith.addi %tmp_37, %tmp_38 : i23
				%tmp_40 = arith.trunci %tmp_39 : i23 to i22
				// l_x__j__plus__1__164_d3_0 aliased to tmp_40
				// Assignment Statement: End
				// Assignment Statement: Start
				%tmp_41 = arith.subi %l_y__j__166_d2_0, %tmp_29 : i22
				// l_y__j__plus__1__167_d3_0 aliased to tmp_41
				// Assignment Statement: End
				scf.yield %tmp_40, %tmp_41 : i22, i22
			} else {
				// Assignment Statement: Start
				%tmp_42 = arith.subi %l_x__j__163_d2_0, %tmp_27 : i22
				// l_x__j__plus__1__164_d3_0 aliased to tmp_42
				// Assignment Statement: End
				// Assignment Statement: Start
				%tmp_43 = arith.extsi %l_y__j__166_d2_0 : i22 to i23
				%tmp_44 = arith.extsi %tmp_29 : i22 to i23
				%tmp_45 = arith.addi %tmp_43, %tmp_44 : i23
				%tmp_46 = arith.trunci %tmp_45 : i23 to i22
				// l_y__j__plus__1__167_d3_0 aliased to tmp_46
				// Assignment Statement: End
				scf.yield %tmp_42, %tmp_46 : i22, i22
			}
			// If Statement: End
			// Assignment Statement: Start
			// l_x__j__163_d2_1 aliased to l_x__j__plus__1__164_d2_1
			// Assignment Statement: End
			// Assignment Statement: Start
			// l_y__j__166_d2_1 aliased to l_y__j__plus__1__167_d2_1
			// Assignment Statement: End
			scf.yield %l_x__j__plus__1__164_d2_1, %l_x__j__plus__1__164_d2_1, %tmp_29, %l_y__j__plus__1__167_d2_1, %l_y__j__plus__1__167_d2_1, %tmp_27 : i22, i22, i22, i22, i22, i22
		}
		// Foreach Statement: End
		// Assignment Statement: Start
		// Evaluate global variable k_CORDIC_constant.
		%tmp_48 = arith.constant 318375 : i19
		%tmp_49 = arith.extui %tmp_48 : i19 to i22
		// Evaluate global variable k_CORDIC_constant done: assigned to tmp_49 above in this context.
		// Evaluate global variable fixedPointMultiply.
		%tmp_47 = func.call @g_qrd_fixedPointMultiply(%tmp_49,%l_y__j__166_d1_2) : (i22,i22) -> i22
		// l_x__out__162_d1_1 aliased to tmp_47
		// Assignment Statement: End
		// Assignment Statement: Start
		// Evaluate global variable k_CORDIC_constant.
		%tmp_51 = arith.constant 318375 : i19
		%tmp_52 = arith.extui %tmp_51 : i19 to i22
		// Evaluate global variable k_CORDIC_constant done: assigned to tmp_52 above in this context.
		// Evaluate global variable fixedPointMultiply.
		%tmp_50 = func.call @g_qrd_fixedPointMultiply(%tmp_52,%l_x__j__163_d1_2) : (i22,i22) -> i22
		cal.set(%l_r__154: !cal.state_ref<i22>, %tmp_50: i22)
		// Assignment Statement: End
		// Assignment Statement: Start
		%tmp_53 = cal.get(%l_count__155: !cal.state_ref<i32>) : i32
		%tmp_54 = arith.constant 1 : i1
		%tmp_55 = arith.extui %tmp_54 : i1 to i32
		%tmp_56 = arith.addi %tmp_53, %tmp_55 : i32
		cal.set(%l_count__155: !cal.state_ref<i32>, %tmp_56: i32)
		// Assignment Statement: End
		// Output Expression: Start
		fifo.push(%x_out: !fifo.input_port<i22>, %tmp_47: i22)
		// Output Expression: End
		// Output Expression: Start
		fifo.push(%cordic_angles_out: !fifo.input_port<i16>, %l_rotation__angles__160_d1_0: i16)
		// Output Expression: End
	}
	// Generation action: $untagged1
	cal.action "$untagged1" priority=0 {
		// Guard: Start
		cal.predicate {
			%tmp_57 = cal.get(%l_count__155: !cal.state_ref<i32>) : i32
			// Evaluate global variable $eval1.
			%tmp_58 = arith.constant 4 : i3
			%tmp_59 = arith.extui %tmp_58 : i3 to i32
			// Evaluate global variable $eval1 done: assigned to tmp_59 above in this context.
			%tmp_60 = arith.cmpi eq, %tmp_57, %tmp_59 : i32
			cal.predicate_result %tmp_60 : i1
		}
		// Guard: End
		// Assignment Statement: Start
		%tmp_61 = arith.constant 0 : i1
		%tmp_62 = arith.extui %tmp_61 : i1 to i32
		cal.set(%l_count__155: !cal.state_ref<i32>, %tmp_62: i32)
		// Assignment Statement: End
		// Output Expression: Start
		%tmp_63 = cal.get(%l_r__154: !cal.state_ref<i22>) : i22
		fifo.push(%r_out: !fifo.input_port<i22>, %tmp_63: i22)
		// Output Expression: End
	}
}

//-- Definition of actor class: InnerCell
cal.actor @innerCells_q_13 ()
	ports_in(%x_in: !fifo.output_port<i22>,%cordic_angles_in: !fifo.output_port<i16>)
	ports_out(%x_out: !fifo.input_port<i22>,%r_out: !fifo.input_port<i22>,%cordic_angles_out: !fifo.input_port<i16>)
{
	// -- Actor body
	%l_r__154 = cal.create_state_var<i22> : !cal.state_ref<i22>
	%tmp_0 = arith.constant 0 : i1
	%tmp_1 = arith.extui %tmp_0 : i1 to i22
	cal.set(%l_r__154: !cal.state_ref<i22>, %tmp_1: i22)
	%l_count__155 = cal.create_state_var<i32> : !cal.state_ref<i32>
	%tmp_2 = arith.constant 0 : i1
	%tmp_3 = arith.extui %tmp_2 : i1 to i32
	cal.set(%l_count__155: !cal.state_ref<i32>, %tmp_3: i32)
	// Generation action: $untagged0
	cal.action "$untagged0" priority=0 {
		// Guard: Start
		cal.predicate {
			%tmp_4 = cal.get(%l_count__155: !cal.state_ref<i32>) : i32
			// Evaluate global variable $eval1.
			%tmp_5 = arith.constant 4 : i3
			%tmp_6 = arith.extui %tmp_5 : i3 to i32
			// Evaluate global variable $eval1 done: assigned to tmp_6 above in this context.
			%tmp_7 = arith.cmpi ult, %tmp_4, %tmp_6 : i32
			cal.predicate_result %tmp_7 : i1
		}
		// Guard: End
		// Input Pattern: Start
		%l_x__in__157_d1_0 = fifo.pop(%x_in: !fifo.output_port<i22>) : i22
		// Input Pattern: End
		// Input Pattern: Start
		%l_rotation__angles__160_d1_0 = fifo.pop(%cordic_angles_in: !fifo.output_port<i16>) : i16
		// Input Pattern: End
		// Action Local Variable Decl: Start
		%l_x__out__162_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_x__j__163_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_x__j__plus__1__164_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_x__j__shifted__165_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_y__j__166_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_y__j__plus__1__167_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_y__j__shifted__168_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// If Statement: Begin
		%tmp_8 = cal.get(%l_count__155: !cal.state_ref<i32>) : i32
		%tmp_9 = arith.constant 0 : i1
		%tmp_10 = arith.extui %tmp_9 : i1 to i32
		%tmp_11 = arith.cmpi eq, %tmp_8, %tmp_10 : i32
		scf.if %tmp_11 {
			// Assignment Statement: Start
			%tmp_12 = arith.constant 0 : i1
			%tmp_13 = arith.extui %tmp_12 : i1 to i22
			cal.set(%l_r__154: !cal.state_ref<i22>, %tmp_13: i22)
			// Assignment Statement: End
		} else {
		}
		// If Statement: End
		// Assignment Statement: Start
		// l_x__j__163_d1_1 aliased to l_x__in__157_d1_0
		// Assignment Statement: End
		// Assignment Statement: Start
		%tmp_14 = cal.get(%l_r__154: !cal.state_ref<i22>) : i22
		// l_y__j__166_d1_1 aliased to tmp_14
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
		%l_x__j__163_d1_2, %l_x__j__plus__1__164_d1_1, %l_x__j__shifted__165_d1_1, %l_y__j__166_d1_2, %l_y__j__plus__1__167_d1_1, %l_y__j__shifted__168_d1_1 = scf.for %l_j_d1_0 = %tmp_17_lb to %tmp_25_ub_plus_1 step %tmp_24_step
				iter_args(%l_x__j__163_d2_0 = %l_x__in__157_d1_0, %l_x__j__plus__1__164_d2_0 = %l_x__j__plus__1__164_d1_0, %l_x__j__shifted__165_d2_0 = %l_x__j__shifted__165_d1_0, %l_y__j__166_d2_0 = %tmp_14, %l_y__j__plus__1__167_d2_0 = %l_y__j__plus__1__167_d1_0, %l_y__j__shifted__168_d2_0 = %l_y__j__shifted__168_d1_0) -> (i22, i22, i22, i22, i22, i22) {
			%l_j_d2_0 = arith.index_cast %l_j_d1_0 : index to i32
			%l_j_d2_1 = arith.trunci %l_j_d2_0 : i32 to i8
			// Assignment Statement: Start
			%tmp_26 = arith.extui %l_j_d2_1 : i8 to i22
			%tmp_27 = arith.shrsi %l_y__j__166_d2_0, %tmp_26 : i22
			// l_y__j__shifted__168_d2_1 aliased to tmp_27
			// Assignment Statement: End
			// Assignment Statement: Start
			%tmp_28 = arith.extui %l_j_d2_1 : i8 to i22
			%tmp_29 = arith.shrsi %l_x__j__163_d2_0, %tmp_28 : i22
			// l_x__j__shifted__165_d2_1 aliased to tmp_29
			// Assignment Statement: End
			// If Statement: Begin
			%tmp_30 = arith.extui %l_j_d2_1 : i8 to i16
			%tmp_31 = arith.shrui %l_rotation__angles__160_d1_0, %tmp_30 : i16
			%tmp_32 = arith.constant 1 : i1
			%tmp_33 = arith.trunci %tmp_31 : i16 to i1
			%tmp_34 = arith.andi %tmp_33, %tmp_32 : i1
			%tmp_35 = arith.constant 1 : i1
			%tmp_36 = arith.cmpi eq, %tmp_34, %tmp_35 : i1
			%l_x__j__plus__1__164_d2_1, %l_y__j__plus__1__167_d2_1 = scf.if %tmp_36 -> (i22, i22) {
				// Assignment Statement: Start
				%tmp_37 = arith.extsi %l_x__j__163_d2_0 : i22 to i23
				%tmp_38 = arith.extsi %tmp_27 : i22 to i23
				%tmp_39 = arith.addi %tmp_37, %tmp_38 : i23
				%tmp_40 = arith.trunci %tmp_39 : i23 to i22
				// l_x__j__plus__1__164_d3_0 aliased to tmp_40
				// Assignment Statement: End
				// Assignment Statement: Start
				%tmp_41 = arith.subi %l_y__j__166_d2_0, %tmp_29 : i22
				// l_y__j__plus__1__167_d3_0 aliased to tmp_41
				// Assignment Statement: End
				scf.yield %tmp_40, %tmp_41 : i22, i22
			} else {
				// Assignment Statement: Start
				%tmp_42 = arith.subi %l_x__j__163_d2_0, %tmp_27 : i22
				// l_x__j__plus__1__164_d3_0 aliased to tmp_42
				// Assignment Statement: End
				// Assignment Statement: Start
				%tmp_43 = arith.extsi %l_y__j__166_d2_0 : i22 to i23
				%tmp_44 = arith.extsi %tmp_29 : i22 to i23
				%tmp_45 = arith.addi %tmp_43, %tmp_44 : i23
				%tmp_46 = arith.trunci %tmp_45 : i23 to i22
				// l_y__j__plus__1__167_d3_0 aliased to tmp_46
				// Assignment Statement: End
				scf.yield %tmp_42, %tmp_46 : i22, i22
			}
			// If Statement: End
			// Assignment Statement: Start
			// l_x__j__163_d2_1 aliased to l_x__j__plus__1__164_d2_1
			// Assignment Statement: End
			// Assignment Statement: Start
			// l_y__j__166_d2_1 aliased to l_y__j__plus__1__167_d2_1
			// Assignment Statement: End
			scf.yield %l_x__j__plus__1__164_d2_1, %l_x__j__plus__1__164_d2_1, %tmp_29, %l_y__j__plus__1__167_d2_1, %l_y__j__plus__1__167_d2_1, %tmp_27 : i22, i22, i22, i22, i22, i22
		}
		// Foreach Statement: End
		// Assignment Statement: Start
		// Evaluate global variable k_CORDIC_constant.
		%tmp_48 = arith.constant 318375 : i19
		%tmp_49 = arith.extui %tmp_48 : i19 to i22
		// Evaluate global variable k_CORDIC_constant done: assigned to tmp_49 above in this context.
		// Evaluate global variable fixedPointMultiply.
		%tmp_47 = func.call @g_qrd_fixedPointMultiply(%tmp_49,%l_y__j__166_d1_2) : (i22,i22) -> i22
		// l_x__out__162_d1_1 aliased to tmp_47
		// Assignment Statement: End
		// Assignment Statement: Start
		// Evaluate global variable k_CORDIC_constant.
		%tmp_51 = arith.constant 318375 : i19
		%tmp_52 = arith.extui %tmp_51 : i19 to i22
		// Evaluate global variable k_CORDIC_constant done: assigned to tmp_52 above in this context.
		// Evaluate global variable fixedPointMultiply.
		%tmp_50 = func.call @g_qrd_fixedPointMultiply(%tmp_52,%l_x__j__163_d1_2) : (i22,i22) -> i22
		cal.set(%l_r__154: !cal.state_ref<i22>, %tmp_50: i22)
		// Assignment Statement: End
		// Assignment Statement: Start
		%tmp_53 = cal.get(%l_count__155: !cal.state_ref<i32>) : i32
		%tmp_54 = arith.constant 1 : i1
		%tmp_55 = arith.extui %tmp_54 : i1 to i32
		%tmp_56 = arith.addi %tmp_53, %tmp_55 : i32
		cal.set(%l_count__155: !cal.state_ref<i32>, %tmp_56: i32)
		// Assignment Statement: End
		// Output Expression: Start
		fifo.push(%x_out: !fifo.input_port<i22>, %tmp_47: i22)
		// Output Expression: End
		// Output Expression: Start
		fifo.push(%cordic_angles_out: !fifo.input_port<i16>, %l_rotation__angles__160_d1_0: i16)
		// Output Expression: End
	}
	// Generation action: $untagged1
	cal.action "$untagged1" priority=0 {
		// Guard: Start
		cal.predicate {
			%tmp_57 = cal.get(%l_count__155: !cal.state_ref<i32>) : i32
			// Evaluate global variable $eval1.
			%tmp_58 = arith.constant 4 : i3
			%tmp_59 = arith.extui %tmp_58 : i3 to i32
			// Evaluate global variable $eval1 done: assigned to tmp_59 above in this context.
			%tmp_60 = arith.cmpi eq, %tmp_57, %tmp_59 : i32
			cal.predicate_result %tmp_60 : i1
		}
		// Guard: End
		// Assignment Statement: Start
		%tmp_61 = arith.constant 0 : i1
		%tmp_62 = arith.extui %tmp_61 : i1 to i32
		cal.set(%l_count__155: !cal.state_ref<i32>, %tmp_62: i32)
		// Assignment Statement: End
		// Output Expression: Start
		%tmp_63 = cal.get(%l_r__154: !cal.state_ref<i22>) : i22
		fifo.push(%r_out: !fifo.input_port<i22>, %tmp_63: i22)
		// Output Expression: End
	}
}

//-- Definition of actor class: InnerCell
cal.actor @innerCells_q_14 ()
	ports_in(%x_in: !fifo.output_port<i22>,%cordic_angles_in: !fifo.output_port<i16>)
	ports_out(%x_out: !fifo.input_port<i22>,%r_out: !fifo.input_port<i22>,%cordic_angles_out: !fifo.input_port<i16>)
{
	// -- Actor body
	%l_r__154 = cal.create_state_var<i22> : !cal.state_ref<i22>
	%tmp_0 = arith.constant 0 : i1
	%tmp_1 = arith.extui %tmp_0 : i1 to i22
	cal.set(%l_r__154: !cal.state_ref<i22>, %tmp_1: i22)
	%l_count__155 = cal.create_state_var<i32> : !cal.state_ref<i32>
	%tmp_2 = arith.constant 0 : i1
	%tmp_3 = arith.extui %tmp_2 : i1 to i32
	cal.set(%l_count__155: !cal.state_ref<i32>, %tmp_3: i32)
	// Generation action: $untagged0
	cal.action "$untagged0" priority=0 {
		// Guard: Start
		cal.predicate {
			%tmp_4 = cal.get(%l_count__155: !cal.state_ref<i32>) : i32
			// Evaluate global variable $eval1.
			%tmp_5 = arith.constant 4 : i3
			%tmp_6 = arith.extui %tmp_5 : i3 to i32
			// Evaluate global variable $eval1 done: assigned to tmp_6 above in this context.
			%tmp_7 = arith.cmpi ult, %tmp_4, %tmp_6 : i32
			cal.predicate_result %tmp_7 : i1
		}
		// Guard: End
		// Input Pattern: Start
		%l_x__in__157_d1_0 = fifo.pop(%x_in: !fifo.output_port<i22>) : i22
		// Input Pattern: End
		// Input Pattern: Start
		%l_rotation__angles__160_d1_0 = fifo.pop(%cordic_angles_in: !fifo.output_port<i16>) : i16
		// Input Pattern: End
		// Action Local Variable Decl: Start
		%l_x__out__162_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_x__j__163_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_x__j__plus__1__164_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_x__j__shifted__165_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_y__j__166_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_y__j__plus__1__167_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_y__j__shifted__168_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// If Statement: Begin
		%tmp_8 = cal.get(%l_count__155: !cal.state_ref<i32>) : i32
		%tmp_9 = arith.constant 0 : i1
		%tmp_10 = arith.extui %tmp_9 : i1 to i32
		%tmp_11 = arith.cmpi eq, %tmp_8, %tmp_10 : i32
		scf.if %tmp_11 {
			// Assignment Statement: Start
			%tmp_12 = arith.constant 0 : i1
			%tmp_13 = arith.extui %tmp_12 : i1 to i22
			cal.set(%l_r__154: !cal.state_ref<i22>, %tmp_13: i22)
			// Assignment Statement: End
		} else {
		}
		// If Statement: End
		// Assignment Statement: Start
		// l_x__j__163_d1_1 aliased to l_x__in__157_d1_0
		// Assignment Statement: End
		// Assignment Statement: Start
		%tmp_14 = cal.get(%l_r__154: !cal.state_ref<i22>) : i22
		// l_y__j__166_d1_1 aliased to tmp_14
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
		%l_x__j__163_d1_2, %l_x__j__plus__1__164_d1_1, %l_x__j__shifted__165_d1_1, %l_y__j__166_d1_2, %l_y__j__plus__1__167_d1_1, %l_y__j__shifted__168_d1_1 = scf.for %l_j_d1_0 = %tmp_17_lb to %tmp_25_ub_plus_1 step %tmp_24_step
				iter_args(%l_x__j__163_d2_0 = %l_x__in__157_d1_0, %l_x__j__plus__1__164_d2_0 = %l_x__j__plus__1__164_d1_0, %l_x__j__shifted__165_d2_0 = %l_x__j__shifted__165_d1_0, %l_y__j__166_d2_0 = %tmp_14, %l_y__j__plus__1__167_d2_0 = %l_y__j__plus__1__167_d1_0, %l_y__j__shifted__168_d2_0 = %l_y__j__shifted__168_d1_0) -> (i22, i22, i22, i22, i22, i22) {
			%l_j_d2_0 = arith.index_cast %l_j_d1_0 : index to i32
			%l_j_d2_1 = arith.trunci %l_j_d2_0 : i32 to i8
			// Assignment Statement: Start
			%tmp_26 = arith.extui %l_j_d2_1 : i8 to i22
			%tmp_27 = arith.shrsi %l_y__j__166_d2_0, %tmp_26 : i22
			// l_y__j__shifted__168_d2_1 aliased to tmp_27
			// Assignment Statement: End
			// Assignment Statement: Start
			%tmp_28 = arith.extui %l_j_d2_1 : i8 to i22
			%tmp_29 = arith.shrsi %l_x__j__163_d2_0, %tmp_28 : i22
			// l_x__j__shifted__165_d2_1 aliased to tmp_29
			// Assignment Statement: End
			// If Statement: Begin
			%tmp_30 = arith.extui %l_j_d2_1 : i8 to i16
			%tmp_31 = arith.shrui %l_rotation__angles__160_d1_0, %tmp_30 : i16
			%tmp_32 = arith.constant 1 : i1
			%tmp_33 = arith.trunci %tmp_31 : i16 to i1
			%tmp_34 = arith.andi %tmp_33, %tmp_32 : i1
			%tmp_35 = arith.constant 1 : i1
			%tmp_36 = arith.cmpi eq, %tmp_34, %tmp_35 : i1
			%l_x__j__plus__1__164_d2_1, %l_y__j__plus__1__167_d2_1 = scf.if %tmp_36 -> (i22, i22) {
				// Assignment Statement: Start
				%tmp_37 = arith.extsi %l_x__j__163_d2_0 : i22 to i23
				%tmp_38 = arith.extsi %tmp_27 : i22 to i23
				%tmp_39 = arith.addi %tmp_37, %tmp_38 : i23
				%tmp_40 = arith.trunci %tmp_39 : i23 to i22
				// l_x__j__plus__1__164_d3_0 aliased to tmp_40
				// Assignment Statement: End
				// Assignment Statement: Start
				%tmp_41 = arith.subi %l_y__j__166_d2_0, %tmp_29 : i22
				// l_y__j__plus__1__167_d3_0 aliased to tmp_41
				// Assignment Statement: End
				scf.yield %tmp_40, %tmp_41 : i22, i22
			} else {
				// Assignment Statement: Start
				%tmp_42 = arith.subi %l_x__j__163_d2_0, %tmp_27 : i22
				// l_x__j__plus__1__164_d3_0 aliased to tmp_42
				// Assignment Statement: End
				// Assignment Statement: Start
				%tmp_43 = arith.extsi %l_y__j__166_d2_0 : i22 to i23
				%tmp_44 = arith.extsi %tmp_29 : i22 to i23
				%tmp_45 = arith.addi %tmp_43, %tmp_44 : i23
				%tmp_46 = arith.trunci %tmp_45 : i23 to i22
				// l_y__j__plus__1__167_d3_0 aliased to tmp_46
				// Assignment Statement: End
				scf.yield %tmp_42, %tmp_46 : i22, i22
			}
			// If Statement: End
			// Assignment Statement: Start
			// l_x__j__163_d2_1 aliased to l_x__j__plus__1__164_d2_1
			// Assignment Statement: End
			// Assignment Statement: Start
			// l_y__j__166_d2_1 aliased to l_y__j__plus__1__167_d2_1
			// Assignment Statement: End
			scf.yield %l_x__j__plus__1__164_d2_1, %l_x__j__plus__1__164_d2_1, %tmp_29, %l_y__j__plus__1__167_d2_1, %l_y__j__plus__1__167_d2_1, %tmp_27 : i22, i22, i22, i22, i22, i22
		}
		// Foreach Statement: End
		// Assignment Statement: Start
		// Evaluate global variable k_CORDIC_constant.
		%tmp_48 = arith.constant 318375 : i19
		%tmp_49 = arith.extui %tmp_48 : i19 to i22
		// Evaluate global variable k_CORDIC_constant done: assigned to tmp_49 above in this context.
		// Evaluate global variable fixedPointMultiply.
		%tmp_47 = func.call @g_qrd_fixedPointMultiply(%tmp_49,%l_y__j__166_d1_2) : (i22,i22) -> i22
		// l_x__out__162_d1_1 aliased to tmp_47
		// Assignment Statement: End
		// Assignment Statement: Start
		// Evaluate global variable k_CORDIC_constant.
		%tmp_51 = arith.constant 318375 : i19
		%tmp_52 = arith.extui %tmp_51 : i19 to i22
		// Evaluate global variable k_CORDIC_constant done: assigned to tmp_52 above in this context.
		// Evaluate global variable fixedPointMultiply.
		%tmp_50 = func.call @g_qrd_fixedPointMultiply(%tmp_52,%l_x__j__163_d1_2) : (i22,i22) -> i22
		cal.set(%l_r__154: !cal.state_ref<i22>, %tmp_50: i22)
		// Assignment Statement: End
		// Assignment Statement: Start
		%tmp_53 = cal.get(%l_count__155: !cal.state_ref<i32>) : i32
		%tmp_54 = arith.constant 1 : i1
		%tmp_55 = arith.extui %tmp_54 : i1 to i32
		%tmp_56 = arith.addi %tmp_53, %tmp_55 : i32
		cal.set(%l_count__155: !cal.state_ref<i32>, %tmp_56: i32)
		// Assignment Statement: End
		// Output Expression: Start
		fifo.push(%x_out: !fifo.input_port<i22>, %tmp_47: i22)
		// Output Expression: End
		// Output Expression: Start
		fifo.push(%cordic_angles_out: !fifo.input_port<i16>, %l_rotation__angles__160_d1_0: i16)
		// Output Expression: End
	}
	// Generation action: $untagged1
	cal.action "$untagged1" priority=0 {
		// Guard: Start
		cal.predicate {
			%tmp_57 = cal.get(%l_count__155: !cal.state_ref<i32>) : i32
			// Evaluate global variable $eval1.
			%tmp_58 = arith.constant 4 : i3
			%tmp_59 = arith.extui %tmp_58 : i3 to i32
			// Evaluate global variable $eval1 done: assigned to tmp_59 above in this context.
			%tmp_60 = arith.cmpi eq, %tmp_57, %tmp_59 : i32
			cal.predicate_result %tmp_60 : i1
		}
		// Guard: End
		// Assignment Statement: Start
		%tmp_61 = arith.constant 0 : i1
		%tmp_62 = arith.extui %tmp_61 : i1 to i32
		cal.set(%l_count__155: !cal.state_ref<i32>, %tmp_62: i32)
		// Assignment Statement: End
		// Output Expression: Start
		%tmp_63 = cal.get(%l_r__154: !cal.state_ref<i22>) : i22
		fifo.push(%r_out: !fifo.input_port<i22>, %tmp_63: i22)
		// Output Expression: End
	}
}

//-- Definition of actor class: InnerCell
cal.actor @innerCells_q_8 ()
	ports_in(%x_in: !fifo.output_port<i22>,%cordic_angles_in: !fifo.output_port<i16>)
	ports_out(%x_out: !fifo.input_port<i22>,%r_out: !fifo.input_port<i22>,%cordic_angles_out: !fifo.input_port<i16>)
{
	// -- Actor body
	%l_r__154 = cal.create_state_var<i22> : !cal.state_ref<i22>
	%tmp_0 = arith.constant 0 : i1
	%tmp_1 = arith.extui %tmp_0 : i1 to i22
	cal.set(%l_r__154: !cal.state_ref<i22>, %tmp_1: i22)
	%l_count__155 = cal.create_state_var<i32> : !cal.state_ref<i32>
	%tmp_2 = arith.constant 0 : i1
	%tmp_3 = arith.extui %tmp_2 : i1 to i32
	cal.set(%l_count__155: !cal.state_ref<i32>, %tmp_3: i32)
	// Generation action: $untagged0
	cal.action "$untagged0" priority=0 {
		// Guard: Start
		cal.predicate {
			%tmp_4 = cal.get(%l_count__155: !cal.state_ref<i32>) : i32
			// Evaluate global variable $eval1.
			%tmp_5 = arith.constant 4 : i3
			%tmp_6 = arith.extui %tmp_5 : i3 to i32
			// Evaluate global variable $eval1 done: assigned to tmp_6 above in this context.
			%tmp_7 = arith.cmpi ult, %tmp_4, %tmp_6 : i32
			cal.predicate_result %tmp_7 : i1
		}
		// Guard: End
		// Input Pattern: Start
		%l_x__in__157_d1_0 = fifo.pop(%x_in: !fifo.output_port<i22>) : i22
		// Input Pattern: End
		// Input Pattern: Start
		%l_rotation__angles__160_d1_0 = fifo.pop(%cordic_angles_in: !fifo.output_port<i16>) : i16
		// Input Pattern: End
		// Action Local Variable Decl: Start
		%l_x__out__162_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_x__j__163_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_x__j__plus__1__164_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_x__j__shifted__165_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_y__j__166_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_y__j__plus__1__167_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_y__j__shifted__168_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// If Statement: Begin
		%tmp_8 = cal.get(%l_count__155: !cal.state_ref<i32>) : i32
		%tmp_9 = arith.constant 0 : i1
		%tmp_10 = arith.extui %tmp_9 : i1 to i32
		%tmp_11 = arith.cmpi eq, %tmp_8, %tmp_10 : i32
		scf.if %tmp_11 {
			// Assignment Statement: Start
			%tmp_12 = arith.constant 0 : i1
			%tmp_13 = arith.extui %tmp_12 : i1 to i22
			cal.set(%l_r__154: !cal.state_ref<i22>, %tmp_13: i22)
			// Assignment Statement: End
		} else {
		}
		// If Statement: End
		// Assignment Statement: Start
		// l_x__j__163_d1_1 aliased to l_x__in__157_d1_0
		// Assignment Statement: End
		// Assignment Statement: Start
		%tmp_14 = cal.get(%l_r__154: !cal.state_ref<i22>) : i22
		// l_y__j__166_d1_1 aliased to tmp_14
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
		%l_x__j__163_d1_2, %l_x__j__plus__1__164_d1_1, %l_x__j__shifted__165_d1_1, %l_y__j__166_d1_2, %l_y__j__plus__1__167_d1_1, %l_y__j__shifted__168_d1_1 = scf.for %l_j_d1_0 = %tmp_17_lb to %tmp_25_ub_plus_1 step %tmp_24_step
				iter_args(%l_x__j__163_d2_0 = %l_x__in__157_d1_0, %l_x__j__plus__1__164_d2_0 = %l_x__j__plus__1__164_d1_0, %l_x__j__shifted__165_d2_0 = %l_x__j__shifted__165_d1_0, %l_y__j__166_d2_0 = %tmp_14, %l_y__j__plus__1__167_d2_0 = %l_y__j__plus__1__167_d1_0, %l_y__j__shifted__168_d2_0 = %l_y__j__shifted__168_d1_0) -> (i22, i22, i22, i22, i22, i22) {
			%l_j_d2_0 = arith.index_cast %l_j_d1_0 : index to i32
			%l_j_d2_1 = arith.trunci %l_j_d2_0 : i32 to i8
			// Assignment Statement: Start
			%tmp_26 = arith.extui %l_j_d2_1 : i8 to i22
			%tmp_27 = arith.shrsi %l_y__j__166_d2_0, %tmp_26 : i22
			// l_y__j__shifted__168_d2_1 aliased to tmp_27
			// Assignment Statement: End
			// Assignment Statement: Start
			%tmp_28 = arith.extui %l_j_d2_1 : i8 to i22
			%tmp_29 = arith.shrsi %l_x__j__163_d2_0, %tmp_28 : i22
			// l_x__j__shifted__165_d2_1 aliased to tmp_29
			// Assignment Statement: End
			// If Statement: Begin
			%tmp_30 = arith.extui %l_j_d2_1 : i8 to i16
			%tmp_31 = arith.shrui %l_rotation__angles__160_d1_0, %tmp_30 : i16
			%tmp_32 = arith.constant 1 : i1
			%tmp_33 = arith.trunci %tmp_31 : i16 to i1
			%tmp_34 = arith.andi %tmp_33, %tmp_32 : i1
			%tmp_35 = arith.constant 1 : i1
			%tmp_36 = arith.cmpi eq, %tmp_34, %tmp_35 : i1
			%l_x__j__plus__1__164_d2_1, %l_y__j__plus__1__167_d2_1 = scf.if %tmp_36 -> (i22, i22) {
				// Assignment Statement: Start
				%tmp_37 = arith.extsi %l_x__j__163_d2_0 : i22 to i23
				%tmp_38 = arith.extsi %tmp_27 : i22 to i23
				%tmp_39 = arith.addi %tmp_37, %tmp_38 : i23
				%tmp_40 = arith.trunci %tmp_39 : i23 to i22
				// l_x__j__plus__1__164_d3_0 aliased to tmp_40
				// Assignment Statement: End
				// Assignment Statement: Start
				%tmp_41 = arith.subi %l_y__j__166_d2_0, %tmp_29 : i22
				// l_y__j__plus__1__167_d3_0 aliased to tmp_41
				// Assignment Statement: End
				scf.yield %tmp_40, %tmp_41 : i22, i22
			} else {
				// Assignment Statement: Start
				%tmp_42 = arith.subi %l_x__j__163_d2_0, %tmp_27 : i22
				// l_x__j__plus__1__164_d3_0 aliased to tmp_42
				// Assignment Statement: End
				// Assignment Statement: Start
				%tmp_43 = arith.extsi %l_y__j__166_d2_0 : i22 to i23
				%tmp_44 = arith.extsi %tmp_29 : i22 to i23
				%tmp_45 = arith.addi %tmp_43, %tmp_44 : i23
				%tmp_46 = arith.trunci %tmp_45 : i23 to i22
				// l_y__j__plus__1__167_d3_0 aliased to tmp_46
				// Assignment Statement: End
				scf.yield %tmp_42, %tmp_46 : i22, i22
			}
			// If Statement: End
			// Assignment Statement: Start
			// l_x__j__163_d2_1 aliased to l_x__j__plus__1__164_d2_1
			// Assignment Statement: End
			// Assignment Statement: Start
			// l_y__j__166_d2_1 aliased to l_y__j__plus__1__167_d2_1
			// Assignment Statement: End
			scf.yield %l_x__j__plus__1__164_d2_1, %l_x__j__plus__1__164_d2_1, %tmp_29, %l_y__j__plus__1__167_d2_1, %l_y__j__plus__1__167_d2_1, %tmp_27 : i22, i22, i22, i22, i22, i22
		}
		// Foreach Statement: End
		// Assignment Statement: Start
		// Evaluate global variable k_CORDIC_constant.
		%tmp_48 = arith.constant 318375 : i19
		%tmp_49 = arith.extui %tmp_48 : i19 to i22
		// Evaluate global variable k_CORDIC_constant done: assigned to tmp_49 above in this context.
		// Evaluate global variable fixedPointMultiply.
		%tmp_47 = func.call @g_qrd_fixedPointMultiply(%tmp_49,%l_y__j__166_d1_2) : (i22,i22) -> i22
		// l_x__out__162_d1_1 aliased to tmp_47
		// Assignment Statement: End
		// Assignment Statement: Start
		// Evaluate global variable k_CORDIC_constant.
		%tmp_51 = arith.constant 318375 : i19
		%tmp_52 = arith.extui %tmp_51 : i19 to i22
		// Evaluate global variable k_CORDIC_constant done: assigned to tmp_52 above in this context.
		// Evaluate global variable fixedPointMultiply.
		%tmp_50 = func.call @g_qrd_fixedPointMultiply(%tmp_52,%l_x__j__163_d1_2) : (i22,i22) -> i22
		cal.set(%l_r__154: !cal.state_ref<i22>, %tmp_50: i22)
		// Assignment Statement: End
		// Assignment Statement: Start
		%tmp_53 = cal.get(%l_count__155: !cal.state_ref<i32>) : i32
		%tmp_54 = arith.constant 1 : i1
		%tmp_55 = arith.extui %tmp_54 : i1 to i32
		%tmp_56 = arith.addi %tmp_53, %tmp_55 : i32
		cal.set(%l_count__155: !cal.state_ref<i32>, %tmp_56: i32)
		// Assignment Statement: End
		// Output Expression: Start
		fifo.push(%x_out: !fifo.input_port<i22>, %tmp_47: i22)
		// Output Expression: End
		// Output Expression: Start
		fifo.push(%cordic_angles_out: !fifo.input_port<i16>, %l_rotation__angles__160_d1_0: i16)
		// Output Expression: End
	}
	// Generation action: $untagged1
	cal.action "$untagged1" priority=0 {
		// Guard: Start
		cal.predicate {
			%tmp_57 = cal.get(%l_count__155: !cal.state_ref<i32>) : i32
			// Evaluate global variable $eval1.
			%tmp_58 = arith.constant 4 : i3
			%tmp_59 = arith.extui %tmp_58 : i3 to i32
			// Evaluate global variable $eval1 done: assigned to tmp_59 above in this context.
			%tmp_60 = arith.cmpi eq, %tmp_57, %tmp_59 : i32
			cal.predicate_result %tmp_60 : i1
		}
		// Guard: End
		// Assignment Statement: Start
		%tmp_61 = arith.constant 0 : i1
		%tmp_62 = arith.extui %tmp_61 : i1 to i32
		cal.set(%l_count__155: !cal.state_ref<i32>, %tmp_62: i32)
		// Assignment Statement: End
		// Output Expression: Start
		%tmp_63 = cal.get(%l_r__154: !cal.state_ref<i22>) : i22
		fifo.push(%r_out: !fifo.input_port<i22>, %tmp_63: i22)
		// Output Expression: End
	}
}

//-- Definition of actor class: InnerCell
cal.actor @innerCells_q_9 ()
	ports_in(%x_in: !fifo.output_port<i22>,%cordic_angles_in: !fifo.output_port<i16>)
	ports_out(%x_out: !fifo.input_port<i22>,%r_out: !fifo.input_port<i22>,%cordic_angles_out: !fifo.input_port<i16>)
{
	// -- Actor body
	%l_r__154 = cal.create_state_var<i22> : !cal.state_ref<i22>
	%tmp_0 = arith.constant 0 : i1
	%tmp_1 = arith.extui %tmp_0 : i1 to i22
	cal.set(%l_r__154: !cal.state_ref<i22>, %tmp_1: i22)
	%l_count__155 = cal.create_state_var<i32> : !cal.state_ref<i32>
	%tmp_2 = arith.constant 0 : i1
	%tmp_3 = arith.extui %tmp_2 : i1 to i32
	cal.set(%l_count__155: !cal.state_ref<i32>, %tmp_3: i32)
	// Generation action: $untagged0
	cal.action "$untagged0" priority=0 {
		// Guard: Start
		cal.predicate {
			%tmp_4 = cal.get(%l_count__155: !cal.state_ref<i32>) : i32
			// Evaluate global variable $eval1.
			%tmp_5 = arith.constant 4 : i3
			%tmp_6 = arith.extui %tmp_5 : i3 to i32
			// Evaluate global variable $eval1 done: assigned to tmp_6 above in this context.
			%tmp_7 = arith.cmpi ult, %tmp_4, %tmp_6 : i32
			cal.predicate_result %tmp_7 : i1
		}
		// Guard: End
		// Input Pattern: Start
		%l_x__in__157_d1_0 = fifo.pop(%x_in: !fifo.output_port<i22>) : i22
		// Input Pattern: End
		// Input Pattern: Start
		%l_rotation__angles__160_d1_0 = fifo.pop(%cordic_angles_in: !fifo.output_port<i16>) : i16
		// Input Pattern: End
		// Action Local Variable Decl: Start
		%l_x__out__162_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_x__j__163_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_x__j__plus__1__164_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_x__j__shifted__165_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_y__j__166_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_y__j__plus__1__167_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_y__j__shifted__168_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// If Statement: Begin
		%tmp_8 = cal.get(%l_count__155: !cal.state_ref<i32>) : i32
		%tmp_9 = arith.constant 0 : i1
		%tmp_10 = arith.extui %tmp_9 : i1 to i32
		%tmp_11 = arith.cmpi eq, %tmp_8, %tmp_10 : i32
		scf.if %tmp_11 {
			// Assignment Statement: Start
			%tmp_12 = arith.constant 0 : i1
			%tmp_13 = arith.extui %tmp_12 : i1 to i22
			cal.set(%l_r__154: !cal.state_ref<i22>, %tmp_13: i22)
			// Assignment Statement: End
		} else {
		}
		// If Statement: End
		// Assignment Statement: Start
		// l_x__j__163_d1_1 aliased to l_x__in__157_d1_0
		// Assignment Statement: End
		// Assignment Statement: Start
		%tmp_14 = cal.get(%l_r__154: !cal.state_ref<i22>) : i22
		// l_y__j__166_d1_1 aliased to tmp_14
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
		%l_x__j__163_d1_2, %l_x__j__plus__1__164_d1_1, %l_x__j__shifted__165_d1_1, %l_y__j__166_d1_2, %l_y__j__plus__1__167_d1_1, %l_y__j__shifted__168_d1_1 = scf.for %l_j_d1_0 = %tmp_17_lb to %tmp_25_ub_plus_1 step %tmp_24_step
				iter_args(%l_x__j__163_d2_0 = %l_x__in__157_d1_0, %l_x__j__plus__1__164_d2_0 = %l_x__j__plus__1__164_d1_0, %l_x__j__shifted__165_d2_0 = %l_x__j__shifted__165_d1_0, %l_y__j__166_d2_0 = %tmp_14, %l_y__j__plus__1__167_d2_0 = %l_y__j__plus__1__167_d1_0, %l_y__j__shifted__168_d2_0 = %l_y__j__shifted__168_d1_0) -> (i22, i22, i22, i22, i22, i22) {
			%l_j_d2_0 = arith.index_cast %l_j_d1_0 : index to i32
			%l_j_d2_1 = arith.trunci %l_j_d2_0 : i32 to i8
			// Assignment Statement: Start
			%tmp_26 = arith.extui %l_j_d2_1 : i8 to i22
			%tmp_27 = arith.shrsi %l_y__j__166_d2_0, %tmp_26 : i22
			// l_y__j__shifted__168_d2_1 aliased to tmp_27
			// Assignment Statement: End
			// Assignment Statement: Start
			%tmp_28 = arith.extui %l_j_d2_1 : i8 to i22
			%tmp_29 = arith.shrsi %l_x__j__163_d2_0, %tmp_28 : i22
			// l_x__j__shifted__165_d2_1 aliased to tmp_29
			// Assignment Statement: End
			// If Statement: Begin
			%tmp_30 = arith.extui %l_j_d2_1 : i8 to i16
			%tmp_31 = arith.shrui %l_rotation__angles__160_d1_0, %tmp_30 : i16
			%tmp_32 = arith.constant 1 : i1
			%tmp_33 = arith.trunci %tmp_31 : i16 to i1
			%tmp_34 = arith.andi %tmp_33, %tmp_32 : i1
			%tmp_35 = arith.constant 1 : i1
			%tmp_36 = arith.cmpi eq, %tmp_34, %tmp_35 : i1
			%l_x__j__plus__1__164_d2_1, %l_y__j__plus__1__167_d2_1 = scf.if %tmp_36 -> (i22, i22) {
				// Assignment Statement: Start
				%tmp_37 = arith.extsi %l_x__j__163_d2_0 : i22 to i23
				%tmp_38 = arith.extsi %tmp_27 : i22 to i23
				%tmp_39 = arith.addi %tmp_37, %tmp_38 : i23
				%tmp_40 = arith.trunci %tmp_39 : i23 to i22
				// l_x__j__plus__1__164_d3_0 aliased to tmp_40
				// Assignment Statement: End
				// Assignment Statement: Start
				%tmp_41 = arith.subi %l_y__j__166_d2_0, %tmp_29 : i22
				// l_y__j__plus__1__167_d3_0 aliased to tmp_41
				// Assignment Statement: End
				scf.yield %tmp_40, %tmp_41 : i22, i22
			} else {
				// Assignment Statement: Start
				%tmp_42 = arith.subi %l_x__j__163_d2_0, %tmp_27 : i22
				// l_x__j__plus__1__164_d3_0 aliased to tmp_42
				// Assignment Statement: End
				// Assignment Statement: Start
				%tmp_43 = arith.extsi %l_y__j__166_d2_0 : i22 to i23
				%tmp_44 = arith.extsi %tmp_29 : i22 to i23
				%tmp_45 = arith.addi %tmp_43, %tmp_44 : i23
				%tmp_46 = arith.trunci %tmp_45 : i23 to i22
				// l_y__j__plus__1__167_d3_0 aliased to tmp_46
				// Assignment Statement: End
				scf.yield %tmp_42, %tmp_46 : i22, i22
			}
			// If Statement: End
			// Assignment Statement: Start
			// l_x__j__163_d2_1 aliased to l_x__j__plus__1__164_d2_1
			// Assignment Statement: End
			// Assignment Statement: Start
			// l_y__j__166_d2_1 aliased to l_y__j__plus__1__167_d2_1
			// Assignment Statement: End
			scf.yield %l_x__j__plus__1__164_d2_1, %l_x__j__plus__1__164_d2_1, %tmp_29, %l_y__j__plus__1__167_d2_1, %l_y__j__plus__1__167_d2_1, %tmp_27 : i22, i22, i22, i22, i22, i22
		}
		// Foreach Statement: End
		// Assignment Statement: Start
		// Evaluate global variable k_CORDIC_constant.
		%tmp_48 = arith.constant 318375 : i19
		%tmp_49 = arith.extui %tmp_48 : i19 to i22
		// Evaluate global variable k_CORDIC_constant done: assigned to tmp_49 above in this context.
		// Evaluate global variable fixedPointMultiply.
		%tmp_47 = func.call @g_qrd_fixedPointMultiply(%tmp_49,%l_y__j__166_d1_2) : (i22,i22) -> i22
		// l_x__out__162_d1_1 aliased to tmp_47
		// Assignment Statement: End
		// Assignment Statement: Start
		// Evaluate global variable k_CORDIC_constant.
		%tmp_51 = arith.constant 318375 : i19
		%tmp_52 = arith.extui %tmp_51 : i19 to i22
		// Evaluate global variable k_CORDIC_constant done: assigned to tmp_52 above in this context.
		// Evaluate global variable fixedPointMultiply.
		%tmp_50 = func.call @g_qrd_fixedPointMultiply(%tmp_52,%l_x__j__163_d1_2) : (i22,i22) -> i22
		cal.set(%l_r__154: !cal.state_ref<i22>, %tmp_50: i22)
		// Assignment Statement: End
		// Assignment Statement: Start
		%tmp_53 = cal.get(%l_count__155: !cal.state_ref<i32>) : i32
		%tmp_54 = arith.constant 1 : i1
		%tmp_55 = arith.extui %tmp_54 : i1 to i32
		%tmp_56 = arith.addi %tmp_53, %tmp_55 : i32
		cal.set(%l_count__155: !cal.state_ref<i32>, %tmp_56: i32)
		// Assignment Statement: End
		// Output Expression: Start
		fifo.push(%x_out: !fifo.input_port<i22>, %tmp_47: i22)
		// Output Expression: End
		// Output Expression: Start
		fifo.push(%cordic_angles_out: !fifo.input_port<i16>, %l_rotation__angles__160_d1_0: i16)
		// Output Expression: End
	}
	// Generation action: $untagged1
	cal.action "$untagged1" priority=0 {
		// Guard: Start
		cal.predicate {
			%tmp_57 = cal.get(%l_count__155: !cal.state_ref<i32>) : i32
			// Evaluate global variable $eval1.
			%tmp_58 = arith.constant 4 : i3
			%tmp_59 = arith.extui %tmp_58 : i3 to i32
			// Evaluate global variable $eval1 done: assigned to tmp_59 above in this context.
			%tmp_60 = arith.cmpi eq, %tmp_57, %tmp_59 : i32
			cal.predicate_result %tmp_60 : i1
		}
		// Guard: End
		// Assignment Statement: Start
		%tmp_61 = arith.constant 0 : i1
		%tmp_62 = arith.extui %tmp_61 : i1 to i32
		cal.set(%l_count__155: !cal.state_ref<i32>, %tmp_62: i32)
		// Assignment Statement: End
		// Output Expression: Start
		%tmp_63 = cal.get(%l_r__154: !cal.state_ref<i22>) : i22
		fifo.push(%r_out: !fifo.input_port<i22>, %tmp_63: i22)
		// Output Expression: End
	}
}

//-- Definition of actor class: InnerCell
cal.actor @innerCells_q_6 ()
	ports_in(%x_in: !fifo.output_port<i22>,%cordic_angles_in: !fifo.output_port<i16>)
	ports_out(%x_out: !fifo.input_port<i22>,%r_out: !fifo.input_port<i22>,%cordic_angles_out: !fifo.input_port<i16>)
{
	// -- Actor body
	%l_r__154 = cal.create_state_var<i22> : !cal.state_ref<i22>
	%tmp_0 = arith.constant 0 : i1
	%tmp_1 = arith.extui %tmp_0 : i1 to i22
	cal.set(%l_r__154: !cal.state_ref<i22>, %tmp_1: i22)
	%l_count__155 = cal.create_state_var<i32> : !cal.state_ref<i32>
	%tmp_2 = arith.constant 0 : i1
	%tmp_3 = arith.extui %tmp_2 : i1 to i32
	cal.set(%l_count__155: !cal.state_ref<i32>, %tmp_3: i32)
	// Generation action: $untagged0
	cal.action "$untagged0" priority=0 {
		// Guard: Start
		cal.predicate {
			%tmp_4 = cal.get(%l_count__155: !cal.state_ref<i32>) : i32
			// Evaluate global variable $eval1.
			%tmp_5 = arith.constant 4 : i3
			%tmp_6 = arith.extui %tmp_5 : i3 to i32
			// Evaluate global variable $eval1 done: assigned to tmp_6 above in this context.
			%tmp_7 = arith.cmpi ult, %tmp_4, %tmp_6 : i32
			cal.predicate_result %tmp_7 : i1
		}
		// Guard: End
		// Input Pattern: Start
		%l_x__in__157_d1_0 = fifo.pop(%x_in: !fifo.output_port<i22>) : i22
		// Input Pattern: End
		// Input Pattern: Start
		%l_rotation__angles__160_d1_0 = fifo.pop(%cordic_angles_in: !fifo.output_port<i16>) : i16
		// Input Pattern: End
		// Action Local Variable Decl: Start
		%l_x__out__162_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_x__j__163_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_x__j__plus__1__164_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_x__j__shifted__165_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_y__j__166_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_y__j__plus__1__167_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_y__j__shifted__168_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// If Statement: Begin
		%tmp_8 = cal.get(%l_count__155: !cal.state_ref<i32>) : i32
		%tmp_9 = arith.constant 0 : i1
		%tmp_10 = arith.extui %tmp_9 : i1 to i32
		%tmp_11 = arith.cmpi eq, %tmp_8, %tmp_10 : i32
		scf.if %tmp_11 {
			// Assignment Statement: Start
			%tmp_12 = arith.constant 0 : i1
			%tmp_13 = arith.extui %tmp_12 : i1 to i22
			cal.set(%l_r__154: !cal.state_ref<i22>, %tmp_13: i22)
			// Assignment Statement: End
		} else {
		}
		// If Statement: End
		// Assignment Statement: Start
		// l_x__j__163_d1_1 aliased to l_x__in__157_d1_0
		// Assignment Statement: End
		// Assignment Statement: Start
		%tmp_14 = cal.get(%l_r__154: !cal.state_ref<i22>) : i22
		// l_y__j__166_d1_1 aliased to tmp_14
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
		%l_x__j__163_d1_2, %l_x__j__plus__1__164_d1_1, %l_x__j__shifted__165_d1_1, %l_y__j__166_d1_2, %l_y__j__plus__1__167_d1_1, %l_y__j__shifted__168_d1_1 = scf.for %l_j_d1_0 = %tmp_17_lb to %tmp_25_ub_plus_1 step %tmp_24_step
				iter_args(%l_x__j__163_d2_0 = %l_x__in__157_d1_0, %l_x__j__plus__1__164_d2_0 = %l_x__j__plus__1__164_d1_0, %l_x__j__shifted__165_d2_0 = %l_x__j__shifted__165_d1_0, %l_y__j__166_d2_0 = %tmp_14, %l_y__j__plus__1__167_d2_0 = %l_y__j__plus__1__167_d1_0, %l_y__j__shifted__168_d2_0 = %l_y__j__shifted__168_d1_0) -> (i22, i22, i22, i22, i22, i22) {
			%l_j_d2_0 = arith.index_cast %l_j_d1_0 : index to i32
			%l_j_d2_1 = arith.trunci %l_j_d2_0 : i32 to i8
			// Assignment Statement: Start
			%tmp_26 = arith.extui %l_j_d2_1 : i8 to i22
			%tmp_27 = arith.shrsi %l_y__j__166_d2_0, %tmp_26 : i22
			// l_y__j__shifted__168_d2_1 aliased to tmp_27
			// Assignment Statement: End
			// Assignment Statement: Start
			%tmp_28 = arith.extui %l_j_d2_1 : i8 to i22
			%tmp_29 = arith.shrsi %l_x__j__163_d2_0, %tmp_28 : i22
			// l_x__j__shifted__165_d2_1 aliased to tmp_29
			// Assignment Statement: End
			// If Statement: Begin
			%tmp_30 = arith.extui %l_j_d2_1 : i8 to i16
			%tmp_31 = arith.shrui %l_rotation__angles__160_d1_0, %tmp_30 : i16
			%tmp_32 = arith.constant 1 : i1
			%tmp_33 = arith.trunci %tmp_31 : i16 to i1
			%tmp_34 = arith.andi %tmp_33, %tmp_32 : i1
			%tmp_35 = arith.constant 1 : i1
			%tmp_36 = arith.cmpi eq, %tmp_34, %tmp_35 : i1
			%l_x__j__plus__1__164_d2_1, %l_y__j__plus__1__167_d2_1 = scf.if %tmp_36 -> (i22, i22) {
				// Assignment Statement: Start
				%tmp_37 = arith.extsi %l_x__j__163_d2_0 : i22 to i23
				%tmp_38 = arith.extsi %tmp_27 : i22 to i23
				%tmp_39 = arith.addi %tmp_37, %tmp_38 : i23
				%tmp_40 = arith.trunci %tmp_39 : i23 to i22
				// l_x__j__plus__1__164_d3_0 aliased to tmp_40
				// Assignment Statement: End
				// Assignment Statement: Start
				%tmp_41 = arith.subi %l_y__j__166_d2_0, %tmp_29 : i22
				// l_y__j__plus__1__167_d3_0 aliased to tmp_41
				// Assignment Statement: End
				scf.yield %tmp_40, %tmp_41 : i22, i22
			} else {
				// Assignment Statement: Start
				%tmp_42 = arith.subi %l_x__j__163_d2_0, %tmp_27 : i22
				// l_x__j__plus__1__164_d3_0 aliased to tmp_42
				// Assignment Statement: End
				// Assignment Statement: Start
				%tmp_43 = arith.extsi %l_y__j__166_d2_0 : i22 to i23
				%tmp_44 = arith.extsi %tmp_29 : i22 to i23
				%tmp_45 = arith.addi %tmp_43, %tmp_44 : i23
				%tmp_46 = arith.trunci %tmp_45 : i23 to i22
				// l_y__j__plus__1__167_d3_0 aliased to tmp_46
				// Assignment Statement: End
				scf.yield %tmp_42, %tmp_46 : i22, i22
			}
			// If Statement: End
			// Assignment Statement: Start
			// l_x__j__163_d2_1 aliased to l_x__j__plus__1__164_d2_1
			// Assignment Statement: End
			// Assignment Statement: Start
			// l_y__j__166_d2_1 aliased to l_y__j__plus__1__167_d2_1
			// Assignment Statement: End
			scf.yield %l_x__j__plus__1__164_d2_1, %l_x__j__plus__1__164_d2_1, %tmp_29, %l_y__j__plus__1__167_d2_1, %l_y__j__plus__1__167_d2_1, %tmp_27 : i22, i22, i22, i22, i22, i22
		}
		// Foreach Statement: End
		// Assignment Statement: Start
		// Evaluate global variable k_CORDIC_constant.
		%tmp_48 = arith.constant 318375 : i19
		%tmp_49 = arith.extui %tmp_48 : i19 to i22
		// Evaluate global variable k_CORDIC_constant done: assigned to tmp_49 above in this context.
		// Evaluate global variable fixedPointMultiply.
		%tmp_47 = func.call @g_qrd_fixedPointMultiply(%tmp_49,%l_y__j__166_d1_2) : (i22,i22) -> i22
		// l_x__out__162_d1_1 aliased to tmp_47
		// Assignment Statement: End
		// Assignment Statement: Start
		// Evaluate global variable k_CORDIC_constant.
		%tmp_51 = arith.constant 318375 : i19
		%tmp_52 = arith.extui %tmp_51 : i19 to i22
		// Evaluate global variable k_CORDIC_constant done: assigned to tmp_52 above in this context.
		// Evaluate global variable fixedPointMultiply.
		%tmp_50 = func.call @g_qrd_fixedPointMultiply(%tmp_52,%l_x__j__163_d1_2) : (i22,i22) -> i22
		cal.set(%l_r__154: !cal.state_ref<i22>, %tmp_50: i22)
		// Assignment Statement: End
		// Assignment Statement: Start
		%tmp_53 = cal.get(%l_count__155: !cal.state_ref<i32>) : i32
		%tmp_54 = arith.constant 1 : i1
		%tmp_55 = arith.extui %tmp_54 : i1 to i32
		%tmp_56 = arith.addi %tmp_53, %tmp_55 : i32
		cal.set(%l_count__155: !cal.state_ref<i32>, %tmp_56: i32)
		// Assignment Statement: End
		// Output Expression: Start
		fifo.push(%x_out: !fifo.input_port<i22>, %tmp_47: i22)
		// Output Expression: End
		// Output Expression: Start
		fifo.push(%cordic_angles_out: !fifo.input_port<i16>, %l_rotation__angles__160_d1_0: i16)
		// Output Expression: End
	}
	// Generation action: $untagged1
	cal.action "$untagged1" priority=0 {
		// Guard: Start
		cal.predicate {
			%tmp_57 = cal.get(%l_count__155: !cal.state_ref<i32>) : i32
			// Evaluate global variable $eval1.
			%tmp_58 = arith.constant 4 : i3
			%tmp_59 = arith.extui %tmp_58 : i3 to i32
			// Evaluate global variable $eval1 done: assigned to tmp_59 above in this context.
			%tmp_60 = arith.cmpi eq, %tmp_57, %tmp_59 : i32
			cal.predicate_result %tmp_60 : i1
		}
		// Guard: End
		// Assignment Statement: Start
		%tmp_61 = arith.constant 0 : i1
		%tmp_62 = arith.extui %tmp_61 : i1 to i32
		cal.set(%l_count__155: !cal.state_ref<i32>, %tmp_62: i32)
		// Assignment Statement: End
		// Output Expression: Start
		%tmp_63 = cal.get(%l_r__154: !cal.state_ref<i22>) : i22
		fifo.push(%r_out: !fifo.input_port<i22>, %tmp_63: i22)
		// Output Expression: End
	}
}

//-- Definition of actor class: InnerCell
cal.actor @innerCells_q_7 ()
	ports_in(%x_in: !fifo.output_port<i22>,%cordic_angles_in: !fifo.output_port<i16>)
	ports_out(%x_out: !fifo.input_port<i22>,%r_out: !fifo.input_port<i22>,%cordic_angles_out: !fifo.input_port<i16>)
{
	// -- Actor body
	%l_r__154 = cal.create_state_var<i22> : !cal.state_ref<i22>
	%tmp_0 = arith.constant 0 : i1
	%tmp_1 = arith.extui %tmp_0 : i1 to i22
	cal.set(%l_r__154: !cal.state_ref<i22>, %tmp_1: i22)
	%l_count__155 = cal.create_state_var<i32> : !cal.state_ref<i32>
	%tmp_2 = arith.constant 0 : i1
	%tmp_3 = arith.extui %tmp_2 : i1 to i32
	cal.set(%l_count__155: !cal.state_ref<i32>, %tmp_3: i32)
	// Generation action: $untagged0
	cal.action "$untagged0" priority=0 {
		// Guard: Start
		cal.predicate {
			%tmp_4 = cal.get(%l_count__155: !cal.state_ref<i32>) : i32
			// Evaluate global variable $eval1.
			%tmp_5 = arith.constant 4 : i3
			%tmp_6 = arith.extui %tmp_5 : i3 to i32
			// Evaluate global variable $eval1 done: assigned to tmp_6 above in this context.
			%tmp_7 = arith.cmpi ult, %tmp_4, %tmp_6 : i32
			cal.predicate_result %tmp_7 : i1
		}
		// Guard: End
		// Input Pattern: Start
		%l_x__in__157_d1_0 = fifo.pop(%x_in: !fifo.output_port<i22>) : i22
		// Input Pattern: End
		// Input Pattern: Start
		%l_rotation__angles__160_d1_0 = fifo.pop(%cordic_angles_in: !fifo.output_port<i16>) : i16
		// Input Pattern: End
		// Action Local Variable Decl: Start
		%l_x__out__162_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_x__j__163_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_x__j__plus__1__164_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_x__j__shifted__165_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_y__j__166_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_y__j__plus__1__167_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_y__j__shifted__168_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// If Statement: Begin
		%tmp_8 = cal.get(%l_count__155: !cal.state_ref<i32>) : i32
		%tmp_9 = arith.constant 0 : i1
		%tmp_10 = arith.extui %tmp_9 : i1 to i32
		%tmp_11 = arith.cmpi eq, %tmp_8, %tmp_10 : i32
		scf.if %tmp_11 {
			// Assignment Statement: Start
			%tmp_12 = arith.constant 0 : i1
			%tmp_13 = arith.extui %tmp_12 : i1 to i22
			cal.set(%l_r__154: !cal.state_ref<i22>, %tmp_13: i22)
			// Assignment Statement: End
		} else {
		}
		// If Statement: End
		// Assignment Statement: Start
		// l_x__j__163_d1_1 aliased to l_x__in__157_d1_0
		// Assignment Statement: End
		// Assignment Statement: Start
		%tmp_14 = cal.get(%l_r__154: !cal.state_ref<i22>) : i22
		// l_y__j__166_d1_1 aliased to tmp_14
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
		%l_x__j__163_d1_2, %l_x__j__plus__1__164_d1_1, %l_x__j__shifted__165_d1_1, %l_y__j__166_d1_2, %l_y__j__plus__1__167_d1_1, %l_y__j__shifted__168_d1_1 = scf.for %l_j_d1_0 = %tmp_17_lb to %tmp_25_ub_plus_1 step %tmp_24_step
				iter_args(%l_x__j__163_d2_0 = %l_x__in__157_d1_0, %l_x__j__plus__1__164_d2_0 = %l_x__j__plus__1__164_d1_0, %l_x__j__shifted__165_d2_0 = %l_x__j__shifted__165_d1_0, %l_y__j__166_d2_0 = %tmp_14, %l_y__j__plus__1__167_d2_0 = %l_y__j__plus__1__167_d1_0, %l_y__j__shifted__168_d2_0 = %l_y__j__shifted__168_d1_0) -> (i22, i22, i22, i22, i22, i22) {
			%l_j_d2_0 = arith.index_cast %l_j_d1_0 : index to i32
			%l_j_d2_1 = arith.trunci %l_j_d2_0 : i32 to i8
			// Assignment Statement: Start
			%tmp_26 = arith.extui %l_j_d2_1 : i8 to i22
			%tmp_27 = arith.shrsi %l_y__j__166_d2_0, %tmp_26 : i22
			// l_y__j__shifted__168_d2_1 aliased to tmp_27
			// Assignment Statement: End
			// Assignment Statement: Start
			%tmp_28 = arith.extui %l_j_d2_1 : i8 to i22
			%tmp_29 = arith.shrsi %l_x__j__163_d2_0, %tmp_28 : i22
			// l_x__j__shifted__165_d2_1 aliased to tmp_29
			// Assignment Statement: End
			// If Statement: Begin
			%tmp_30 = arith.extui %l_j_d2_1 : i8 to i16
			%tmp_31 = arith.shrui %l_rotation__angles__160_d1_0, %tmp_30 : i16
			%tmp_32 = arith.constant 1 : i1
			%tmp_33 = arith.trunci %tmp_31 : i16 to i1
			%tmp_34 = arith.andi %tmp_33, %tmp_32 : i1
			%tmp_35 = arith.constant 1 : i1
			%tmp_36 = arith.cmpi eq, %tmp_34, %tmp_35 : i1
			%l_x__j__plus__1__164_d2_1, %l_y__j__plus__1__167_d2_1 = scf.if %tmp_36 -> (i22, i22) {
				// Assignment Statement: Start
				%tmp_37 = arith.extsi %l_x__j__163_d2_0 : i22 to i23
				%tmp_38 = arith.extsi %tmp_27 : i22 to i23
				%tmp_39 = arith.addi %tmp_37, %tmp_38 : i23
				%tmp_40 = arith.trunci %tmp_39 : i23 to i22
				// l_x__j__plus__1__164_d3_0 aliased to tmp_40
				// Assignment Statement: End
				// Assignment Statement: Start
				%tmp_41 = arith.subi %l_y__j__166_d2_0, %tmp_29 : i22
				// l_y__j__plus__1__167_d3_0 aliased to tmp_41
				// Assignment Statement: End
				scf.yield %tmp_40, %tmp_41 : i22, i22
			} else {
				// Assignment Statement: Start
				%tmp_42 = arith.subi %l_x__j__163_d2_0, %tmp_27 : i22
				// l_x__j__plus__1__164_d3_0 aliased to tmp_42
				// Assignment Statement: End
				// Assignment Statement: Start
				%tmp_43 = arith.extsi %l_y__j__166_d2_0 : i22 to i23
				%tmp_44 = arith.extsi %tmp_29 : i22 to i23
				%tmp_45 = arith.addi %tmp_43, %tmp_44 : i23
				%tmp_46 = arith.trunci %tmp_45 : i23 to i22
				// l_y__j__plus__1__167_d3_0 aliased to tmp_46
				// Assignment Statement: End
				scf.yield %tmp_42, %tmp_46 : i22, i22
			}
			// If Statement: End
			// Assignment Statement: Start
			// l_x__j__163_d2_1 aliased to l_x__j__plus__1__164_d2_1
			// Assignment Statement: End
			// Assignment Statement: Start
			// l_y__j__166_d2_1 aliased to l_y__j__plus__1__167_d2_1
			// Assignment Statement: End
			scf.yield %l_x__j__plus__1__164_d2_1, %l_x__j__plus__1__164_d2_1, %tmp_29, %l_y__j__plus__1__167_d2_1, %l_y__j__plus__1__167_d2_1, %tmp_27 : i22, i22, i22, i22, i22, i22
		}
		// Foreach Statement: End
		// Assignment Statement: Start
		// Evaluate global variable k_CORDIC_constant.
		%tmp_48 = arith.constant 318375 : i19
		%tmp_49 = arith.extui %tmp_48 : i19 to i22
		// Evaluate global variable k_CORDIC_constant done: assigned to tmp_49 above in this context.
		// Evaluate global variable fixedPointMultiply.
		%tmp_47 = func.call @g_qrd_fixedPointMultiply(%tmp_49,%l_y__j__166_d1_2) : (i22,i22) -> i22
		// l_x__out__162_d1_1 aliased to tmp_47
		// Assignment Statement: End
		// Assignment Statement: Start
		// Evaluate global variable k_CORDIC_constant.
		%tmp_51 = arith.constant 318375 : i19
		%tmp_52 = arith.extui %tmp_51 : i19 to i22
		// Evaluate global variable k_CORDIC_constant done: assigned to tmp_52 above in this context.
		// Evaluate global variable fixedPointMultiply.
		%tmp_50 = func.call @g_qrd_fixedPointMultiply(%tmp_52,%l_x__j__163_d1_2) : (i22,i22) -> i22
		cal.set(%l_r__154: !cal.state_ref<i22>, %tmp_50: i22)
		// Assignment Statement: End
		// Assignment Statement: Start
		%tmp_53 = cal.get(%l_count__155: !cal.state_ref<i32>) : i32
		%tmp_54 = arith.constant 1 : i1
		%tmp_55 = arith.extui %tmp_54 : i1 to i32
		%tmp_56 = arith.addi %tmp_53, %tmp_55 : i32
		cal.set(%l_count__155: !cal.state_ref<i32>, %tmp_56: i32)
		// Assignment Statement: End
		// Output Expression: Start
		fifo.push(%x_out: !fifo.input_port<i22>, %tmp_47: i22)
		// Output Expression: End
		// Output Expression: Start
		fifo.push(%cordic_angles_out: !fifo.input_port<i16>, %l_rotation__angles__160_d1_0: i16)
		// Output Expression: End
	}
	// Generation action: $untagged1
	cal.action "$untagged1" priority=0 {
		// Guard: Start
		cal.predicate {
			%tmp_57 = cal.get(%l_count__155: !cal.state_ref<i32>) : i32
			// Evaluate global variable $eval1.
			%tmp_58 = arith.constant 4 : i3
			%tmp_59 = arith.extui %tmp_58 : i3 to i32
			// Evaluate global variable $eval1 done: assigned to tmp_59 above in this context.
			%tmp_60 = arith.cmpi eq, %tmp_57, %tmp_59 : i32
			cal.predicate_result %tmp_60 : i1
		}
		// Guard: End
		// Assignment Statement: Start
		%tmp_61 = arith.constant 0 : i1
		%tmp_62 = arith.extui %tmp_61 : i1 to i32
		cal.set(%l_count__155: !cal.state_ref<i32>, %tmp_62: i32)
		// Assignment Statement: End
		// Output Expression: Start
		%tmp_63 = cal.get(%l_r__154: !cal.state_ref<i22>) : i22
		fifo.push(%r_out: !fifo.input_port<i22>, %tmp_63: i22)
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
		%l_t__42_d1_0 = fifo.pop(%In: !fifo.output_port<i22>) : i22
		// Input Pattern: End
	}
}

//-- Definition of actor class: InnerCell
cal.actor @innerCells_q_4 ()
	ports_in(%x_in: !fifo.output_port<i22>,%cordic_angles_in: !fifo.output_port<i16>)
	ports_out(%x_out: !fifo.input_port<i22>,%r_out: !fifo.input_port<i22>,%cordic_angles_out: !fifo.input_port<i16>)
{
	// -- Actor body
	%l_r__154 = cal.create_state_var<i22> : !cal.state_ref<i22>
	%tmp_0 = arith.constant 0 : i1
	%tmp_1 = arith.extui %tmp_0 : i1 to i22
	cal.set(%l_r__154: !cal.state_ref<i22>, %tmp_1: i22)
	%l_count__155 = cal.create_state_var<i32> : !cal.state_ref<i32>
	%tmp_2 = arith.constant 0 : i1
	%tmp_3 = arith.extui %tmp_2 : i1 to i32
	cal.set(%l_count__155: !cal.state_ref<i32>, %tmp_3: i32)
	// Generation action: $untagged0
	cal.action "$untagged0" priority=0 {
		// Guard: Start
		cal.predicate {
			%tmp_4 = cal.get(%l_count__155: !cal.state_ref<i32>) : i32
			// Evaluate global variable $eval1.
			%tmp_5 = arith.constant 4 : i3
			%tmp_6 = arith.extui %tmp_5 : i3 to i32
			// Evaluate global variable $eval1 done: assigned to tmp_6 above in this context.
			%tmp_7 = arith.cmpi ult, %tmp_4, %tmp_6 : i32
			cal.predicate_result %tmp_7 : i1
		}
		// Guard: End
		// Input Pattern: Start
		%l_x__in__157_d1_0 = fifo.pop(%x_in: !fifo.output_port<i22>) : i22
		// Input Pattern: End
		// Input Pattern: Start
		%l_rotation__angles__160_d1_0 = fifo.pop(%cordic_angles_in: !fifo.output_port<i16>) : i16
		// Input Pattern: End
		// Action Local Variable Decl: Start
		%l_x__out__162_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_x__j__163_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_x__j__plus__1__164_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_x__j__shifted__165_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_y__j__166_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_y__j__plus__1__167_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_y__j__shifted__168_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// If Statement: Begin
		%tmp_8 = cal.get(%l_count__155: !cal.state_ref<i32>) : i32
		%tmp_9 = arith.constant 0 : i1
		%tmp_10 = arith.extui %tmp_9 : i1 to i32
		%tmp_11 = arith.cmpi eq, %tmp_8, %tmp_10 : i32
		scf.if %tmp_11 {
			// Assignment Statement: Start
			%tmp_12 = arith.constant 0 : i1
			%tmp_13 = arith.extui %tmp_12 : i1 to i22
			cal.set(%l_r__154: !cal.state_ref<i22>, %tmp_13: i22)
			// Assignment Statement: End
		} else {
		}
		// If Statement: End
		// Assignment Statement: Start
		// l_x__j__163_d1_1 aliased to l_x__in__157_d1_0
		// Assignment Statement: End
		// Assignment Statement: Start
		%tmp_14 = cal.get(%l_r__154: !cal.state_ref<i22>) : i22
		// l_y__j__166_d1_1 aliased to tmp_14
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
		%l_x__j__163_d1_2, %l_x__j__plus__1__164_d1_1, %l_x__j__shifted__165_d1_1, %l_y__j__166_d1_2, %l_y__j__plus__1__167_d1_1, %l_y__j__shifted__168_d1_1 = scf.for %l_j_d1_0 = %tmp_17_lb to %tmp_25_ub_plus_1 step %tmp_24_step
				iter_args(%l_x__j__163_d2_0 = %l_x__in__157_d1_0, %l_x__j__plus__1__164_d2_0 = %l_x__j__plus__1__164_d1_0, %l_x__j__shifted__165_d2_0 = %l_x__j__shifted__165_d1_0, %l_y__j__166_d2_0 = %tmp_14, %l_y__j__plus__1__167_d2_0 = %l_y__j__plus__1__167_d1_0, %l_y__j__shifted__168_d2_0 = %l_y__j__shifted__168_d1_0) -> (i22, i22, i22, i22, i22, i22) {
			%l_j_d2_0 = arith.index_cast %l_j_d1_0 : index to i32
			%l_j_d2_1 = arith.trunci %l_j_d2_0 : i32 to i8
			// Assignment Statement: Start
			%tmp_26 = arith.extui %l_j_d2_1 : i8 to i22
			%tmp_27 = arith.shrsi %l_y__j__166_d2_0, %tmp_26 : i22
			// l_y__j__shifted__168_d2_1 aliased to tmp_27
			// Assignment Statement: End
			// Assignment Statement: Start
			%tmp_28 = arith.extui %l_j_d2_1 : i8 to i22
			%tmp_29 = arith.shrsi %l_x__j__163_d2_0, %tmp_28 : i22
			// l_x__j__shifted__165_d2_1 aliased to tmp_29
			// Assignment Statement: End
			// If Statement: Begin
			%tmp_30 = arith.extui %l_j_d2_1 : i8 to i16
			%tmp_31 = arith.shrui %l_rotation__angles__160_d1_0, %tmp_30 : i16
			%tmp_32 = arith.constant 1 : i1
			%tmp_33 = arith.trunci %tmp_31 : i16 to i1
			%tmp_34 = arith.andi %tmp_33, %tmp_32 : i1
			%tmp_35 = arith.constant 1 : i1
			%tmp_36 = arith.cmpi eq, %tmp_34, %tmp_35 : i1
			%l_x__j__plus__1__164_d2_1, %l_y__j__plus__1__167_d2_1 = scf.if %tmp_36 -> (i22, i22) {
				// Assignment Statement: Start
				%tmp_37 = arith.extsi %l_x__j__163_d2_0 : i22 to i23
				%tmp_38 = arith.extsi %tmp_27 : i22 to i23
				%tmp_39 = arith.addi %tmp_37, %tmp_38 : i23
				%tmp_40 = arith.trunci %tmp_39 : i23 to i22
				// l_x__j__plus__1__164_d3_0 aliased to tmp_40
				// Assignment Statement: End
				// Assignment Statement: Start
				%tmp_41 = arith.subi %l_y__j__166_d2_0, %tmp_29 : i22
				// l_y__j__plus__1__167_d3_0 aliased to tmp_41
				// Assignment Statement: End
				scf.yield %tmp_40, %tmp_41 : i22, i22
			} else {
				// Assignment Statement: Start
				%tmp_42 = arith.subi %l_x__j__163_d2_0, %tmp_27 : i22
				// l_x__j__plus__1__164_d3_0 aliased to tmp_42
				// Assignment Statement: End
				// Assignment Statement: Start
				%tmp_43 = arith.extsi %l_y__j__166_d2_0 : i22 to i23
				%tmp_44 = arith.extsi %tmp_29 : i22 to i23
				%tmp_45 = arith.addi %tmp_43, %tmp_44 : i23
				%tmp_46 = arith.trunci %tmp_45 : i23 to i22
				// l_y__j__plus__1__167_d3_0 aliased to tmp_46
				// Assignment Statement: End
				scf.yield %tmp_42, %tmp_46 : i22, i22
			}
			// If Statement: End
			// Assignment Statement: Start
			// l_x__j__163_d2_1 aliased to l_x__j__plus__1__164_d2_1
			// Assignment Statement: End
			// Assignment Statement: Start
			// l_y__j__166_d2_1 aliased to l_y__j__plus__1__167_d2_1
			// Assignment Statement: End
			scf.yield %l_x__j__plus__1__164_d2_1, %l_x__j__plus__1__164_d2_1, %tmp_29, %l_y__j__plus__1__167_d2_1, %l_y__j__plus__1__167_d2_1, %tmp_27 : i22, i22, i22, i22, i22, i22
		}
		// Foreach Statement: End
		// Assignment Statement: Start
		// Evaluate global variable k_CORDIC_constant.
		%tmp_48 = arith.constant 318375 : i19
		%tmp_49 = arith.extui %tmp_48 : i19 to i22
		// Evaluate global variable k_CORDIC_constant done: assigned to tmp_49 above in this context.
		// Evaluate global variable fixedPointMultiply.
		%tmp_47 = func.call @g_qrd_fixedPointMultiply(%tmp_49,%l_y__j__166_d1_2) : (i22,i22) -> i22
		// l_x__out__162_d1_1 aliased to tmp_47
		// Assignment Statement: End
		// Assignment Statement: Start
		// Evaluate global variable k_CORDIC_constant.
		%tmp_51 = arith.constant 318375 : i19
		%tmp_52 = arith.extui %tmp_51 : i19 to i22
		// Evaluate global variable k_CORDIC_constant done: assigned to tmp_52 above in this context.
		// Evaluate global variable fixedPointMultiply.
		%tmp_50 = func.call @g_qrd_fixedPointMultiply(%tmp_52,%l_x__j__163_d1_2) : (i22,i22) -> i22
		cal.set(%l_r__154: !cal.state_ref<i22>, %tmp_50: i22)
		// Assignment Statement: End
		// Assignment Statement: Start
		%tmp_53 = cal.get(%l_count__155: !cal.state_ref<i32>) : i32
		%tmp_54 = arith.constant 1 : i1
		%tmp_55 = arith.extui %tmp_54 : i1 to i32
		%tmp_56 = arith.addi %tmp_53, %tmp_55 : i32
		cal.set(%l_count__155: !cal.state_ref<i32>, %tmp_56: i32)
		// Assignment Statement: End
		// Output Expression: Start
		fifo.push(%x_out: !fifo.input_port<i22>, %tmp_47: i22)
		// Output Expression: End
		// Output Expression: Start
		fifo.push(%cordic_angles_out: !fifo.input_port<i16>, %l_rotation__angles__160_d1_0: i16)
		// Output Expression: End
	}
	// Generation action: $untagged1
	cal.action "$untagged1" priority=0 {
		// Guard: Start
		cal.predicate {
			%tmp_57 = cal.get(%l_count__155: !cal.state_ref<i32>) : i32
			// Evaluate global variable $eval1.
			%tmp_58 = arith.constant 4 : i3
			%tmp_59 = arith.extui %tmp_58 : i3 to i32
			// Evaluate global variable $eval1 done: assigned to tmp_59 above in this context.
			%tmp_60 = arith.cmpi eq, %tmp_57, %tmp_59 : i32
			cal.predicate_result %tmp_60 : i1
		}
		// Guard: End
		// Assignment Statement: Start
		%tmp_61 = arith.constant 0 : i1
		%tmp_62 = arith.extui %tmp_61 : i1 to i32
		cal.set(%l_count__155: !cal.state_ref<i32>, %tmp_62: i32)
		// Assignment Statement: End
		// Output Expression: Start
		%tmp_63 = cal.get(%l_r__154: !cal.state_ref<i22>) : i22
		fifo.push(%r_out: !fifo.input_port<i22>, %tmp_63: i22)
		// Output Expression: End
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
		%l_t__42_d1_0 = fifo.pop(%In: !fifo.output_port<i22>) : i22
		// Input Pattern: End
	}
}

//-- Definition of actor class: InnerCell
cal.actor @innerCells_q_5 ()
	ports_in(%x_in: !fifo.output_port<i22>,%cordic_angles_in: !fifo.output_port<i16>)
	ports_out(%x_out: !fifo.input_port<i22>,%r_out: !fifo.input_port<i22>,%cordic_angles_out: !fifo.input_port<i16>)
{
	// -- Actor body
	%l_r__154 = cal.create_state_var<i22> : !cal.state_ref<i22>
	%tmp_0 = arith.constant 0 : i1
	%tmp_1 = arith.extui %tmp_0 : i1 to i22
	cal.set(%l_r__154: !cal.state_ref<i22>, %tmp_1: i22)
	%l_count__155 = cal.create_state_var<i32> : !cal.state_ref<i32>
	%tmp_2 = arith.constant 0 : i1
	%tmp_3 = arith.extui %tmp_2 : i1 to i32
	cal.set(%l_count__155: !cal.state_ref<i32>, %tmp_3: i32)
	// Generation action: $untagged0
	cal.action "$untagged0" priority=0 {
		// Guard: Start
		cal.predicate {
			%tmp_4 = cal.get(%l_count__155: !cal.state_ref<i32>) : i32
			// Evaluate global variable $eval1.
			%tmp_5 = arith.constant 4 : i3
			%tmp_6 = arith.extui %tmp_5 : i3 to i32
			// Evaluate global variable $eval1 done: assigned to tmp_6 above in this context.
			%tmp_7 = arith.cmpi ult, %tmp_4, %tmp_6 : i32
			cal.predicate_result %tmp_7 : i1
		}
		// Guard: End
		// Input Pattern: Start
		%l_x__in__157_d1_0 = fifo.pop(%x_in: !fifo.output_port<i22>) : i22
		// Input Pattern: End
		// Input Pattern: Start
		%l_rotation__angles__160_d1_0 = fifo.pop(%cordic_angles_in: !fifo.output_port<i16>) : i16
		// Input Pattern: End
		// Action Local Variable Decl: Start
		%l_x__out__162_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_x__j__163_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_x__j__plus__1__164_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_x__j__shifted__165_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_y__j__166_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_y__j__plus__1__167_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_y__j__shifted__168_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// If Statement: Begin
		%tmp_8 = cal.get(%l_count__155: !cal.state_ref<i32>) : i32
		%tmp_9 = arith.constant 0 : i1
		%tmp_10 = arith.extui %tmp_9 : i1 to i32
		%tmp_11 = arith.cmpi eq, %tmp_8, %tmp_10 : i32
		scf.if %tmp_11 {
			// Assignment Statement: Start
			%tmp_12 = arith.constant 0 : i1
			%tmp_13 = arith.extui %tmp_12 : i1 to i22
			cal.set(%l_r__154: !cal.state_ref<i22>, %tmp_13: i22)
			// Assignment Statement: End
		} else {
		}
		// If Statement: End
		// Assignment Statement: Start
		// l_x__j__163_d1_1 aliased to l_x__in__157_d1_0
		// Assignment Statement: End
		// Assignment Statement: Start
		%tmp_14 = cal.get(%l_r__154: !cal.state_ref<i22>) : i22
		// l_y__j__166_d1_1 aliased to tmp_14
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
		%l_x__j__163_d1_2, %l_x__j__plus__1__164_d1_1, %l_x__j__shifted__165_d1_1, %l_y__j__166_d1_2, %l_y__j__plus__1__167_d1_1, %l_y__j__shifted__168_d1_1 = scf.for %l_j_d1_0 = %tmp_17_lb to %tmp_25_ub_plus_1 step %tmp_24_step
				iter_args(%l_x__j__163_d2_0 = %l_x__in__157_d1_0, %l_x__j__plus__1__164_d2_0 = %l_x__j__plus__1__164_d1_0, %l_x__j__shifted__165_d2_0 = %l_x__j__shifted__165_d1_0, %l_y__j__166_d2_0 = %tmp_14, %l_y__j__plus__1__167_d2_0 = %l_y__j__plus__1__167_d1_0, %l_y__j__shifted__168_d2_0 = %l_y__j__shifted__168_d1_0) -> (i22, i22, i22, i22, i22, i22) {
			%l_j_d2_0 = arith.index_cast %l_j_d1_0 : index to i32
			%l_j_d2_1 = arith.trunci %l_j_d2_0 : i32 to i8
			// Assignment Statement: Start
			%tmp_26 = arith.extui %l_j_d2_1 : i8 to i22
			%tmp_27 = arith.shrsi %l_y__j__166_d2_0, %tmp_26 : i22
			// l_y__j__shifted__168_d2_1 aliased to tmp_27
			// Assignment Statement: End
			// Assignment Statement: Start
			%tmp_28 = arith.extui %l_j_d2_1 : i8 to i22
			%tmp_29 = arith.shrsi %l_x__j__163_d2_0, %tmp_28 : i22
			// l_x__j__shifted__165_d2_1 aliased to tmp_29
			// Assignment Statement: End
			// If Statement: Begin
			%tmp_30 = arith.extui %l_j_d2_1 : i8 to i16
			%tmp_31 = arith.shrui %l_rotation__angles__160_d1_0, %tmp_30 : i16
			%tmp_32 = arith.constant 1 : i1
			%tmp_33 = arith.trunci %tmp_31 : i16 to i1
			%tmp_34 = arith.andi %tmp_33, %tmp_32 : i1
			%tmp_35 = arith.constant 1 : i1
			%tmp_36 = arith.cmpi eq, %tmp_34, %tmp_35 : i1
			%l_x__j__plus__1__164_d2_1, %l_y__j__plus__1__167_d2_1 = scf.if %tmp_36 -> (i22, i22) {
				// Assignment Statement: Start
				%tmp_37 = arith.extsi %l_x__j__163_d2_0 : i22 to i23
				%tmp_38 = arith.extsi %tmp_27 : i22 to i23
				%tmp_39 = arith.addi %tmp_37, %tmp_38 : i23
				%tmp_40 = arith.trunci %tmp_39 : i23 to i22
				// l_x__j__plus__1__164_d3_0 aliased to tmp_40
				// Assignment Statement: End
				// Assignment Statement: Start
				%tmp_41 = arith.subi %l_y__j__166_d2_0, %tmp_29 : i22
				// l_y__j__plus__1__167_d3_0 aliased to tmp_41
				// Assignment Statement: End
				scf.yield %tmp_40, %tmp_41 : i22, i22
			} else {
				// Assignment Statement: Start
				%tmp_42 = arith.subi %l_x__j__163_d2_0, %tmp_27 : i22
				// l_x__j__plus__1__164_d3_0 aliased to tmp_42
				// Assignment Statement: End
				// Assignment Statement: Start
				%tmp_43 = arith.extsi %l_y__j__166_d2_0 : i22 to i23
				%tmp_44 = arith.extsi %tmp_29 : i22 to i23
				%tmp_45 = arith.addi %tmp_43, %tmp_44 : i23
				%tmp_46 = arith.trunci %tmp_45 : i23 to i22
				// l_y__j__plus__1__167_d3_0 aliased to tmp_46
				// Assignment Statement: End
				scf.yield %tmp_42, %tmp_46 : i22, i22
			}
			// If Statement: End
			// Assignment Statement: Start
			// l_x__j__163_d2_1 aliased to l_x__j__plus__1__164_d2_1
			// Assignment Statement: End
			// Assignment Statement: Start
			// l_y__j__166_d2_1 aliased to l_y__j__plus__1__167_d2_1
			// Assignment Statement: End
			scf.yield %l_x__j__plus__1__164_d2_1, %l_x__j__plus__1__164_d2_1, %tmp_29, %l_y__j__plus__1__167_d2_1, %l_y__j__plus__1__167_d2_1, %tmp_27 : i22, i22, i22, i22, i22, i22
		}
		// Foreach Statement: End
		// Assignment Statement: Start
		// Evaluate global variable k_CORDIC_constant.
		%tmp_48 = arith.constant 318375 : i19
		%tmp_49 = arith.extui %tmp_48 : i19 to i22
		// Evaluate global variable k_CORDIC_constant done: assigned to tmp_49 above in this context.
		// Evaluate global variable fixedPointMultiply.
		%tmp_47 = func.call @g_qrd_fixedPointMultiply(%tmp_49,%l_y__j__166_d1_2) : (i22,i22) -> i22
		// l_x__out__162_d1_1 aliased to tmp_47
		// Assignment Statement: End
		// Assignment Statement: Start
		// Evaluate global variable k_CORDIC_constant.
		%tmp_51 = arith.constant 318375 : i19
		%tmp_52 = arith.extui %tmp_51 : i19 to i22
		// Evaluate global variable k_CORDIC_constant done: assigned to tmp_52 above in this context.
		// Evaluate global variable fixedPointMultiply.
		%tmp_50 = func.call @g_qrd_fixedPointMultiply(%tmp_52,%l_x__j__163_d1_2) : (i22,i22) -> i22
		cal.set(%l_r__154: !cal.state_ref<i22>, %tmp_50: i22)
		// Assignment Statement: End
		// Assignment Statement: Start
		%tmp_53 = cal.get(%l_count__155: !cal.state_ref<i32>) : i32
		%tmp_54 = arith.constant 1 : i1
		%tmp_55 = arith.extui %tmp_54 : i1 to i32
		%tmp_56 = arith.addi %tmp_53, %tmp_55 : i32
		cal.set(%l_count__155: !cal.state_ref<i32>, %tmp_56: i32)
		// Assignment Statement: End
		// Output Expression: Start
		fifo.push(%x_out: !fifo.input_port<i22>, %tmp_47: i22)
		// Output Expression: End
		// Output Expression: Start
		fifo.push(%cordic_angles_out: !fifo.input_port<i16>, %l_rotation__angles__160_d1_0: i16)
		// Output Expression: End
	}
	// Generation action: $untagged1
	cal.action "$untagged1" priority=0 {
		// Guard: Start
		cal.predicate {
			%tmp_57 = cal.get(%l_count__155: !cal.state_ref<i32>) : i32
			// Evaluate global variable $eval1.
			%tmp_58 = arith.constant 4 : i3
			%tmp_59 = arith.extui %tmp_58 : i3 to i32
			// Evaluate global variable $eval1 done: assigned to tmp_59 above in this context.
			%tmp_60 = arith.cmpi eq, %tmp_57, %tmp_59 : i32
			cal.predicate_result %tmp_60 : i1
		}
		// Guard: End
		// Assignment Statement: Start
		%tmp_61 = arith.constant 0 : i1
		%tmp_62 = arith.extui %tmp_61 : i1 to i32
		cal.set(%l_count__155: !cal.state_ref<i32>, %tmp_62: i32)
		// Assignment Statement: End
		// Output Expression: Start
		%tmp_63 = cal.get(%l_r__154: !cal.state_ref<i22>) : i22
		fifo.push(%r_out: !fifo.input_port<i22>, %tmp_63: i22)
		// Output Expression: End
	}
}

//-- Definition of actor class: Cap
cal.actor @caps_q_3 ()
	ports_in(%In: !fifo.output_port<i22>)
{
	// -- Actor body
	// Generation action: receive
	cal.action "receive" priority=0 {
		// Input Pattern: Start
		%l_t__42_d1_0 = fifo.pop(%In: !fifo.output_port<i22>) : i22
		// Input Pattern: End
	}
}

//-- Definition of actor class: InnerCell
cal.actor @innerCells_q_2 ()
	ports_in(%x_in: !fifo.output_port<i22>,%cordic_angles_in: !fifo.output_port<i16>)
	ports_out(%x_out: !fifo.input_port<i22>,%r_out: !fifo.input_port<i22>,%cordic_angles_out: !fifo.input_port<i16>)
{
	// -- Actor body
	%l_r__154 = cal.create_state_var<i22> : !cal.state_ref<i22>
	%tmp_0 = arith.constant 0 : i1
	%tmp_1 = arith.extui %tmp_0 : i1 to i22
	cal.set(%l_r__154: !cal.state_ref<i22>, %tmp_1: i22)
	%l_count__155 = cal.create_state_var<i32> : !cal.state_ref<i32>
	%tmp_2 = arith.constant 0 : i1
	%tmp_3 = arith.extui %tmp_2 : i1 to i32
	cal.set(%l_count__155: !cal.state_ref<i32>, %tmp_3: i32)
	// Generation action: $untagged0
	cal.action "$untagged0" priority=0 {
		// Guard: Start
		cal.predicate {
			%tmp_4 = cal.get(%l_count__155: !cal.state_ref<i32>) : i32
			// Evaluate global variable $eval1.
			%tmp_5 = arith.constant 4 : i3
			%tmp_6 = arith.extui %tmp_5 : i3 to i32
			// Evaluate global variable $eval1 done: assigned to tmp_6 above in this context.
			%tmp_7 = arith.cmpi ult, %tmp_4, %tmp_6 : i32
			cal.predicate_result %tmp_7 : i1
		}
		// Guard: End
		// Input Pattern: Start
		%l_x__in__157_d1_0 = fifo.pop(%x_in: !fifo.output_port<i22>) : i22
		// Input Pattern: End
		// Input Pattern: Start
		%l_rotation__angles__160_d1_0 = fifo.pop(%cordic_angles_in: !fifo.output_port<i16>) : i16
		// Input Pattern: End
		// Action Local Variable Decl: Start
		%l_x__out__162_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_x__j__163_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_x__j__plus__1__164_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_x__j__shifted__165_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_y__j__166_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_y__j__plus__1__167_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_y__j__shifted__168_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// If Statement: Begin
		%tmp_8 = cal.get(%l_count__155: !cal.state_ref<i32>) : i32
		%tmp_9 = arith.constant 0 : i1
		%tmp_10 = arith.extui %tmp_9 : i1 to i32
		%tmp_11 = arith.cmpi eq, %tmp_8, %tmp_10 : i32
		scf.if %tmp_11 {
			// Assignment Statement: Start
			%tmp_12 = arith.constant 0 : i1
			%tmp_13 = arith.extui %tmp_12 : i1 to i22
			cal.set(%l_r__154: !cal.state_ref<i22>, %tmp_13: i22)
			// Assignment Statement: End
		} else {
		}
		// If Statement: End
		// Assignment Statement: Start
		// l_x__j__163_d1_1 aliased to l_x__in__157_d1_0
		// Assignment Statement: End
		// Assignment Statement: Start
		%tmp_14 = cal.get(%l_r__154: !cal.state_ref<i22>) : i22
		// l_y__j__166_d1_1 aliased to tmp_14
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
		%l_x__j__163_d1_2, %l_x__j__plus__1__164_d1_1, %l_x__j__shifted__165_d1_1, %l_y__j__166_d1_2, %l_y__j__plus__1__167_d1_1, %l_y__j__shifted__168_d1_1 = scf.for %l_j_d1_0 = %tmp_17_lb to %tmp_25_ub_plus_1 step %tmp_24_step
				iter_args(%l_x__j__163_d2_0 = %l_x__in__157_d1_0, %l_x__j__plus__1__164_d2_0 = %l_x__j__plus__1__164_d1_0, %l_x__j__shifted__165_d2_0 = %l_x__j__shifted__165_d1_0, %l_y__j__166_d2_0 = %tmp_14, %l_y__j__plus__1__167_d2_0 = %l_y__j__plus__1__167_d1_0, %l_y__j__shifted__168_d2_0 = %l_y__j__shifted__168_d1_0) -> (i22, i22, i22, i22, i22, i22) {
			%l_j_d2_0 = arith.index_cast %l_j_d1_0 : index to i32
			%l_j_d2_1 = arith.trunci %l_j_d2_0 : i32 to i8
			// Assignment Statement: Start
			%tmp_26 = arith.extui %l_j_d2_1 : i8 to i22
			%tmp_27 = arith.shrsi %l_y__j__166_d2_0, %tmp_26 : i22
			// l_y__j__shifted__168_d2_1 aliased to tmp_27
			// Assignment Statement: End
			// Assignment Statement: Start
			%tmp_28 = arith.extui %l_j_d2_1 : i8 to i22
			%tmp_29 = arith.shrsi %l_x__j__163_d2_0, %tmp_28 : i22
			// l_x__j__shifted__165_d2_1 aliased to tmp_29
			// Assignment Statement: End
			// If Statement: Begin
			%tmp_30 = arith.extui %l_j_d2_1 : i8 to i16
			%tmp_31 = arith.shrui %l_rotation__angles__160_d1_0, %tmp_30 : i16
			%tmp_32 = arith.constant 1 : i1
			%tmp_33 = arith.trunci %tmp_31 : i16 to i1
			%tmp_34 = arith.andi %tmp_33, %tmp_32 : i1
			%tmp_35 = arith.constant 1 : i1
			%tmp_36 = arith.cmpi eq, %tmp_34, %tmp_35 : i1
			%l_x__j__plus__1__164_d2_1, %l_y__j__plus__1__167_d2_1 = scf.if %tmp_36 -> (i22, i22) {
				// Assignment Statement: Start
				%tmp_37 = arith.extsi %l_x__j__163_d2_0 : i22 to i23
				%tmp_38 = arith.extsi %tmp_27 : i22 to i23
				%tmp_39 = arith.addi %tmp_37, %tmp_38 : i23
				%tmp_40 = arith.trunci %tmp_39 : i23 to i22
				// l_x__j__plus__1__164_d3_0 aliased to tmp_40
				// Assignment Statement: End
				// Assignment Statement: Start
				%tmp_41 = arith.subi %l_y__j__166_d2_0, %tmp_29 : i22
				// l_y__j__plus__1__167_d3_0 aliased to tmp_41
				// Assignment Statement: End
				scf.yield %tmp_40, %tmp_41 : i22, i22
			} else {
				// Assignment Statement: Start
				%tmp_42 = arith.subi %l_x__j__163_d2_0, %tmp_27 : i22
				// l_x__j__plus__1__164_d3_0 aliased to tmp_42
				// Assignment Statement: End
				// Assignment Statement: Start
				%tmp_43 = arith.extsi %l_y__j__166_d2_0 : i22 to i23
				%tmp_44 = arith.extsi %tmp_29 : i22 to i23
				%tmp_45 = arith.addi %tmp_43, %tmp_44 : i23
				%tmp_46 = arith.trunci %tmp_45 : i23 to i22
				// l_y__j__plus__1__167_d3_0 aliased to tmp_46
				// Assignment Statement: End
				scf.yield %tmp_42, %tmp_46 : i22, i22
			}
			// If Statement: End
			// Assignment Statement: Start
			// l_x__j__163_d2_1 aliased to l_x__j__plus__1__164_d2_1
			// Assignment Statement: End
			// Assignment Statement: Start
			// l_y__j__166_d2_1 aliased to l_y__j__plus__1__167_d2_1
			// Assignment Statement: End
			scf.yield %l_x__j__plus__1__164_d2_1, %l_x__j__plus__1__164_d2_1, %tmp_29, %l_y__j__plus__1__167_d2_1, %l_y__j__plus__1__167_d2_1, %tmp_27 : i22, i22, i22, i22, i22, i22
		}
		// Foreach Statement: End
		// Assignment Statement: Start
		// Evaluate global variable k_CORDIC_constant.
		%tmp_48 = arith.constant 318375 : i19
		%tmp_49 = arith.extui %tmp_48 : i19 to i22
		// Evaluate global variable k_CORDIC_constant done: assigned to tmp_49 above in this context.
		// Evaluate global variable fixedPointMultiply.
		%tmp_47 = func.call @g_qrd_fixedPointMultiply(%tmp_49,%l_y__j__166_d1_2) : (i22,i22) -> i22
		// l_x__out__162_d1_1 aliased to tmp_47
		// Assignment Statement: End
		// Assignment Statement: Start
		// Evaluate global variable k_CORDIC_constant.
		%tmp_51 = arith.constant 318375 : i19
		%tmp_52 = arith.extui %tmp_51 : i19 to i22
		// Evaluate global variable k_CORDIC_constant done: assigned to tmp_52 above in this context.
		// Evaluate global variable fixedPointMultiply.
		%tmp_50 = func.call @g_qrd_fixedPointMultiply(%tmp_52,%l_x__j__163_d1_2) : (i22,i22) -> i22
		cal.set(%l_r__154: !cal.state_ref<i22>, %tmp_50: i22)
		// Assignment Statement: End
		// Assignment Statement: Start
		%tmp_53 = cal.get(%l_count__155: !cal.state_ref<i32>) : i32
		%tmp_54 = arith.constant 1 : i1
		%tmp_55 = arith.extui %tmp_54 : i1 to i32
		%tmp_56 = arith.addi %tmp_53, %tmp_55 : i32
		cal.set(%l_count__155: !cal.state_ref<i32>, %tmp_56: i32)
		// Assignment Statement: End
		// Output Expression: Start
		fifo.push(%x_out: !fifo.input_port<i22>, %tmp_47: i22)
		// Output Expression: End
		// Output Expression: Start
		fifo.push(%cordic_angles_out: !fifo.input_port<i16>, %l_rotation__angles__160_d1_0: i16)
		// Output Expression: End
	}
	// Generation action: $untagged1
	cal.action "$untagged1" priority=0 {
		// Guard: Start
		cal.predicate {
			%tmp_57 = cal.get(%l_count__155: !cal.state_ref<i32>) : i32
			// Evaluate global variable $eval1.
			%tmp_58 = arith.constant 4 : i3
			%tmp_59 = arith.extui %tmp_58 : i3 to i32
			// Evaluate global variable $eval1 done: assigned to tmp_59 above in this context.
			%tmp_60 = arith.cmpi eq, %tmp_57, %tmp_59 : i32
			cal.predicate_result %tmp_60 : i1
		}
		// Guard: End
		// Assignment Statement: Start
		%tmp_61 = arith.constant 0 : i1
		%tmp_62 = arith.extui %tmp_61 : i1 to i32
		cal.set(%l_count__155: !cal.state_ref<i32>, %tmp_62: i32)
		// Assignment Statement: End
		// Output Expression: Start
		%tmp_63 = cal.get(%l_r__154: !cal.state_ref<i22>) : i22
		fifo.push(%r_out: !fifo.input_port<i22>, %tmp_63: i22)
		// Output Expression: End
	}
}

//-- Definition of actor class: Cap
cal.actor @caps_q_2 ()
	ports_in(%In: !fifo.output_port<i22>)
{
	// -- Actor body
	// Generation action: receive
	cal.action "receive" priority=0 {
		// Input Pattern: Start
		%l_t__42_d1_0 = fifo.pop(%In: !fifo.output_port<i22>) : i22
		// Input Pattern: End
	}
}

//-- Definition of actor class: InnerCell
cal.actor @innerCells_q_3 ()
	ports_in(%x_in: !fifo.output_port<i22>,%cordic_angles_in: !fifo.output_port<i16>)
	ports_out(%x_out: !fifo.input_port<i22>,%r_out: !fifo.input_port<i22>,%cordic_angles_out: !fifo.input_port<i16>)
{
	// -- Actor body
	%l_r__154 = cal.create_state_var<i22> : !cal.state_ref<i22>
	%tmp_0 = arith.constant 0 : i1
	%tmp_1 = arith.extui %tmp_0 : i1 to i22
	cal.set(%l_r__154: !cal.state_ref<i22>, %tmp_1: i22)
	%l_count__155 = cal.create_state_var<i32> : !cal.state_ref<i32>
	%tmp_2 = arith.constant 0 : i1
	%tmp_3 = arith.extui %tmp_2 : i1 to i32
	cal.set(%l_count__155: !cal.state_ref<i32>, %tmp_3: i32)
	// Generation action: $untagged0
	cal.action "$untagged0" priority=0 {
		// Guard: Start
		cal.predicate {
			%tmp_4 = cal.get(%l_count__155: !cal.state_ref<i32>) : i32
			// Evaluate global variable $eval1.
			%tmp_5 = arith.constant 4 : i3
			%tmp_6 = arith.extui %tmp_5 : i3 to i32
			// Evaluate global variable $eval1 done: assigned to tmp_6 above in this context.
			%tmp_7 = arith.cmpi ult, %tmp_4, %tmp_6 : i32
			cal.predicate_result %tmp_7 : i1
		}
		// Guard: End
		// Input Pattern: Start
		%l_x__in__157_d1_0 = fifo.pop(%x_in: !fifo.output_port<i22>) : i22
		// Input Pattern: End
		// Input Pattern: Start
		%l_rotation__angles__160_d1_0 = fifo.pop(%cordic_angles_in: !fifo.output_port<i16>) : i16
		// Input Pattern: End
		// Action Local Variable Decl: Start
		%l_x__out__162_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_x__j__163_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_x__j__plus__1__164_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_x__j__shifted__165_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_y__j__166_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_y__j__plus__1__167_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_y__j__shifted__168_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// If Statement: Begin
		%tmp_8 = cal.get(%l_count__155: !cal.state_ref<i32>) : i32
		%tmp_9 = arith.constant 0 : i1
		%tmp_10 = arith.extui %tmp_9 : i1 to i32
		%tmp_11 = arith.cmpi eq, %tmp_8, %tmp_10 : i32
		scf.if %tmp_11 {
			// Assignment Statement: Start
			%tmp_12 = arith.constant 0 : i1
			%tmp_13 = arith.extui %tmp_12 : i1 to i22
			cal.set(%l_r__154: !cal.state_ref<i22>, %tmp_13: i22)
			// Assignment Statement: End
		} else {
		}
		// If Statement: End
		// Assignment Statement: Start
		// l_x__j__163_d1_1 aliased to l_x__in__157_d1_0
		// Assignment Statement: End
		// Assignment Statement: Start
		%tmp_14 = cal.get(%l_r__154: !cal.state_ref<i22>) : i22
		// l_y__j__166_d1_1 aliased to tmp_14
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
		%l_x__j__163_d1_2, %l_x__j__plus__1__164_d1_1, %l_x__j__shifted__165_d1_1, %l_y__j__166_d1_2, %l_y__j__plus__1__167_d1_1, %l_y__j__shifted__168_d1_1 = scf.for %l_j_d1_0 = %tmp_17_lb to %tmp_25_ub_plus_1 step %tmp_24_step
				iter_args(%l_x__j__163_d2_0 = %l_x__in__157_d1_0, %l_x__j__plus__1__164_d2_0 = %l_x__j__plus__1__164_d1_0, %l_x__j__shifted__165_d2_0 = %l_x__j__shifted__165_d1_0, %l_y__j__166_d2_0 = %tmp_14, %l_y__j__plus__1__167_d2_0 = %l_y__j__plus__1__167_d1_0, %l_y__j__shifted__168_d2_0 = %l_y__j__shifted__168_d1_0) -> (i22, i22, i22, i22, i22, i22) {
			%l_j_d2_0 = arith.index_cast %l_j_d1_0 : index to i32
			%l_j_d2_1 = arith.trunci %l_j_d2_0 : i32 to i8
			// Assignment Statement: Start
			%tmp_26 = arith.extui %l_j_d2_1 : i8 to i22
			%tmp_27 = arith.shrsi %l_y__j__166_d2_0, %tmp_26 : i22
			// l_y__j__shifted__168_d2_1 aliased to tmp_27
			// Assignment Statement: End
			// Assignment Statement: Start
			%tmp_28 = arith.extui %l_j_d2_1 : i8 to i22
			%tmp_29 = arith.shrsi %l_x__j__163_d2_0, %tmp_28 : i22
			// l_x__j__shifted__165_d2_1 aliased to tmp_29
			// Assignment Statement: End
			// If Statement: Begin
			%tmp_30 = arith.extui %l_j_d2_1 : i8 to i16
			%tmp_31 = arith.shrui %l_rotation__angles__160_d1_0, %tmp_30 : i16
			%tmp_32 = arith.constant 1 : i1
			%tmp_33 = arith.trunci %tmp_31 : i16 to i1
			%tmp_34 = arith.andi %tmp_33, %tmp_32 : i1
			%tmp_35 = arith.constant 1 : i1
			%tmp_36 = arith.cmpi eq, %tmp_34, %tmp_35 : i1
			%l_x__j__plus__1__164_d2_1, %l_y__j__plus__1__167_d2_1 = scf.if %tmp_36 -> (i22, i22) {
				// Assignment Statement: Start
				%tmp_37 = arith.extsi %l_x__j__163_d2_0 : i22 to i23
				%tmp_38 = arith.extsi %tmp_27 : i22 to i23
				%tmp_39 = arith.addi %tmp_37, %tmp_38 : i23
				%tmp_40 = arith.trunci %tmp_39 : i23 to i22
				// l_x__j__plus__1__164_d3_0 aliased to tmp_40
				// Assignment Statement: End
				// Assignment Statement: Start
				%tmp_41 = arith.subi %l_y__j__166_d2_0, %tmp_29 : i22
				// l_y__j__plus__1__167_d3_0 aliased to tmp_41
				// Assignment Statement: End
				scf.yield %tmp_40, %tmp_41 : i22, i22
			} else {
				// Assignment Statement: Start
				%tmp_42 = arith.subi %l_x__j__163_d2_0, %tmp_27 : i22
				// l_x__j__plus__1__164_d3_0 aliased to tmp_42
				// Assignment Statement: End
				// Assignment Statement: Start
				%tmp_43 = arith.extsi %l_y__j__166_d2_0 : i22 to i23
				%tmp_44 = arith.extsi %tmp_29 : i22 to i23
				%tmp_45 = arith.addi %tmp_43, %tmp_44 : i23
				%tmp_46 = arith.trunci %tmp_45 : i23 to i22
				// l_y__j__plus__1__167_d3_0 aliased to tmp_46
				// Assignment Statement: End
				scf.yield %tmp_42, %tmp_46 : i22, i22
			}
			// If Statement: End
			// Assignment Statement: Start
			// l_x__j__163_d2_1 aliased to l_x__j__plus__1__164_d2_1
			// Assignment Statement: End
			// Assignment Statement: Start
			// l_y__j__166_d2_1 aliased to l_y__j__plus__1__167_d2_1
			// Assignment Statement: End
			scf.yield %l_x__j__plus__1__164_d2_1, %l_x__j__plus__1__164_d2_1, %tmp_29, %l_y__j__plus__1__167_d2_1, %l_y__j__plus__1__167_d2_1, %tmp_27 : i22, i22, i22, i22, i22, i22
		}
		// Foreach Statement: End
		// Assignment Statement: Start
		// Evaluate global variable k_CORDIC_constant.
		%tmp_48 = arith.constant 318375 : i19
		%tmp_49 = arith.extui %tmp_48 : i19 to i22
		// Evaluate global variable k_CORDIC_constant done: assigned to tmp_49 above in this context.
		// Evaluate global variable fixedPointMultiply.
		%tmp_47 = func.call @g_qrd_fixedPointMultiply(%tmp_49,%l_y__j__166_d1_2) : (i22,i22) -> i22
		// l_x__out__162_d1_1 aliased to tmp_47
		// Assignment Statement: End
		// Assignment Statement: Start
		// Evaluate global variable k_CORDIC_constant.
		%tmp_51 = arith.constant 318375 : i19
		%tmp_52 = arith.extui %tmp_51 : i19 to i22
		// Evaluate global variable k_CORDIC_constant done: assigned to tmp_52 above in this context.
		// Evaluate global variable fixedPointMultiply.
		%tmp_50 = func.call @g_qrd_fixedPointMultiply(%tmp_52,%l_x__j__163_d1_2) : (i22,i22) -> i22
		cal.set(%l_r__154: !cal.state_ref<i22>, %tmp_50: i22)
		// Assignment Statement: End
		// Assignment Statement: Start
		%tmp_53 = cal.get(%l_count__155: !cal.state_ref<i32>) : i32
		%tmp_54 = arith.constant 1 : i1
		%tmp_55 = arith.extui %tmp_54 : i1 to i32
		%tmp_56 = arith.addi %tmp_53, %tmp_55 : i32
		cal.set(%l_count__155: !cal.state_ref<i32>, %tmp_56: i32)
		// Assignment Statement: End
		// Output Expression: Start
		fifo.push(%x_out: !fifo.input_port<i22>, %tmp_47: i22)
		// Output Expression: End
		// Output Expression: Start
		fifo.push(%cordic_angles_out: !fifo.input_port<i16>, %l_rotation__angles__160_d1_0: i16)
		// Output Expression: End
	}
	// Generation action: $untagged1
	cal.action "$untagged1" priority=0 {
		// Guard: Start
		cal.predicate {
			%tmp_57 = cal.get(%l_count__155: !cal.state_ref<i32>) : i32
			// Evaluate global variable $eval1.
			%tmp_58 = arith.constant 4 : i3
			%tmp_59 = arith.extui %tmp_58 : i3 to i32
			// Evaluate global variable $eval1 done: assigned to tmp_59 above in this context.
			%tmp_60 = arith.cmpi eq, %tmp_57, %tmp_59 : i32
			cal.predicate_result %tmp_60 : i1
		}
		// Guard: End
		// Assignment Statement: Start
		%tmp_61 = arith.constant 0 : i1
		%tmp_62 = arith.extui %tmp_61 : i1 to i32
		cal.set(%l_count__155: !cal.state_ref<i32>, %tmp_62: i32)
		// Assignment Statement: End
		// Output Expression: Start
		%tmp_63 = cal.get(%l_r__154: !cal.state_ref<i22>) : i22
		fifo.push(%r_out: !fifo.input_port<i22>, %tmp_63: i22)
		// Output Expression: End
	}
}

//-- Definition of actor class: JoinerRowR
cal.actor @joinersPerRow_r_0 ()
	ports_in(%r_in_array_0_x: !fifo.output_port<i22>,%r_in_array_1_x: !fifo.output_port<i22>,%r_in_array_2_x: !fifo.output_port<i22>,%r_in_array_3_x: !fifo.output_port<i22>)
	ports_out(%r_out: !fifo.input_port<i22>)
{
	// -- Actor body
	%l_matrix__number__48 = cal.create_state_var<i32> : !cal.state_ref<i32>
	%tmp_0 = arith.constant 0 : i1
	%tmp_1 = arith.extui %tmp_0 : i1 to i32
	cal.set(%l_matrix__number__48: !cal.state_ref<i32>, %tmp_1: i32)
	// Generation action: $untagged0
	cal.action "$untagged0" priority=0 {
		// Input Pattern: Start
		%l_____input0______50_d1_0 = fifo.pop(%r_in_array_0_x: !fifo.output_port<i22>) : i22
		// Input Pattern: End
		// Input Pattern: Start
		%l_____input1______53_d1_0 = fifo.pop(%r_in_array_1_x: !fifo.output_port<i22>) : i22
		// Input Pattern: End
		// Input Pattern: Start
		%l_____input2______56_d1_0 = fifo.pop(%r_in_array_2_x: !fifo.output_port<i22>) : i22
		// Input Pattern: End
		// Input Pattern: Start
		%l_____input3______59_d1_0 = fifo.pop(%r_in_array_3_x: !fifo.output_port<i22>) : i22
		// Input Pattern: End
		// Action Local Variable Decl: Start
		%tmp_2 = memref.alloc() : memref<4xi32>
		%tmp_3 = arith.constant 0: index
		%tmp_4 = arith.extsi %l_____input0______50_d1_0 : i22 to i32
		memref.store %tmp_4, %tmp_2[%tmp_3] : memref<4xi32>
		%tmp_5 = arith.constant 1: index
		%tmp_6 = arith.extsi %l_____input1______53_d1_0 : i22 to i32
		memref.store %tmp_6, %tmp_2[%tmp_5] : memref<4xi32>
		%tmp_7 = arith.constant 2: index
		%tmp_8 = arith.extsi %l_____input2______56_d1_0 : i22 to i32
		memref.store %tmp_8, %tmp_2[%tmp_7] : memref<4xi32>
		%tmp_9 = arith.constant 3: index
		%tmp_10 = arith.extsi %l_____input3______59_d1_0 : i22 to i32
		memref.store %tmp_10, %tmp_2[%tmp_9] : memref<4xi32>
		// l_input__61_d1_0 aliased to tmp_2
		// Action Local Variable Decl: End
		// If Statement: Begin
		%tmp_11 = cal.get(%l_matrix__number__48: !cal.state_ref<i32>) : i32
		// Evaluate global variable num_matrices.
		%tmp_12 = arith.constant 10000 : i14
		%tmp_13 = arith.extui %tmp_12 : i14 to i32
		// Evaluate global variable num_matrices done: assigned to tmp_13 above in this context.
		%tmp_14 = arith.constant 10 : i4
		%tmp_15 = arith.extui %tmp_14 : i4 to i32
		%tmp_16 = arith.subi %tmp_13, %tmp_15 : i32
		%tmp_17 = arith.cmpi eq, %tmp_11, %tmp_16 : i32
		scf.if %tmp_17 {
			// Call Statement: Start
			%tmp_18 = cal.get(%l_matrix__number__48: !cal.state_ref<i32>) : i32
			fifo.print("R%u: row 0: \00", %tmp_18) : (i32)
			// Call Statement: End
			// If Statement: Begin
			// Evaluate global variable $eval3.
			%tmp_19 = arith.constant 0 : i1
			%tmp_20 = arith.extui %tmp_19 : i1 to i32
			// Evaluate global variable $eval3 done: assigned to tmp_20 above in this context.
			%tmp_21 = arith.constant 0 : i1
			%tmp_22 = arith.extui %tmp_21 : i1 to i32
			%tmp_23 = arith.cmpi ne, %tmp_20, %tmp_22 : i32
			scf.if %tmp_23 {
				// Foreach Statement: Begin
				%tmp_24 = arith.constant 0 : i1
				%tmp_25 = arith.extui %tmp_24 : i1 to i32
				%tmp_26_lb = index.casts %tmp_25 : i32 to index
				// Evaluate global variable $eval1.
				%tmp_27 = arith.constant 4 : i3
				%tmp_28 = arith.extui %tmp_27 : i3 to i32
				// Evaluate global variable $eval1 done: assigned to tmp_28 above in this context.
				// Evaluate global variable $eval1.
				%tmp_29 = arith.constant 4 : i3
				%tmp_30 = arith.extui %tmp_29 : i3 to i32
				// Evaluate global variable $eval1 done: assigned to tmp_30 above in this context.
				%tmp_31 = arith.subi %tmp_28, %tmp_30 : i32
				%tmp_32 = arith.constant 1 : i1
				%tmp_33 = arith.extui %tmp_32 : i1 to i32
				%tmp_34 = arith.subi %tmp_31, %tmp_33 : i32
				%tmp_35_ub = index.casts %tmp_34 : i32 to index
				%tmp_36_step = index.constant 1
				%tmp_37_ub_plus_1 = arith.addi %tmp_35_ub, %tmp_36_step : index
				scf.for %l_index_d3_0 = %tmp_26_lb to %tmp_37_ub_plus_1 step %tmp_36_step
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
			%tmp_38 = arith.constant 0 : i1
			%tmp_39 = arith.extui %tmp_38 : i1 to i32
			%tmp_40_lb = index.casts %tmp_39 : i32 to index
			// Evaluate global variable $eval1.
			%tmp_41 = arith.constant 4 : i3
			%tmp_42 = arith.extui %tmp_41 : i3 to i32
			// Evaluate global variable $eval1 done: assigned to tmp_42 above in this context.
			%tmp_43 = arith.constant 1 : i1
			%tmp_44 = arith.extui %tmp_43 : i1 to i32
			%tmp_45 = arith.subi %tmp_42, %tmp_44 : i32
			%tmp_46_ub = index.casts %tmp_45 : i32 to index
			%tmp_47_step = index.constant 1
			%tmp_48_ub_plus_1 = arith.addi %tmp_46_ub, %tmp_47_step : index
			scf.for %l_index_d2_0 = %tmp_40_lb to %tmp_48_ub_plus_1 step %tmp_47_step
					iter_args() -> () {
				%l_index_d3_0 = arith.index_cast %l_index_d2_0 : index to i32
				%l_index_d3_1 = arith.trunci %l_index_d3_0 : i32 to i8
				// Call Statement: Start
				%tmp_49 = arith.extui %l_index_d3_1 : i8 to i32
				%tmp_50 = arith.index_cast %tmp_49: i32 to index
				%tmp_52 = memref.load %tmp_2[%tmp_50] : memref<4xi32>
				%tmp_51 = arith.trunci %tmp_52 : i32 to i22
				%tmp_53 = arith.extsi %tmp_51 : i22 to i32
				fifo.print("%i \00", %tmp_53) : (i32)
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
		%tmp_54 = cal.get(%l_matrix__number__48: !cal.state_ref<i32>) : i32
		%tmp_55 = arith.constant 1 : i1
		%tmp_56 = arith.extui %tmp_55 : i1 to i32
		%tmp_57 = arith.addi %tmp_54, %tmp_56 : i32
		cal.set(%l_matrix__number__48: !cal.state_ref<i32>, %tmp_57: i32)
		// Assignment Statement: End
		// Output Expression: Start
		%tmp_58 = arith.constant 0 : index
		%tmp_59 = memref.load %tmp_2[%tmp_58] : memref<4xi32>
		%tmp_60 = arith.trunci %tmp_59 : i32 to i22
		fifo.push(%r_out: !fifo.input_port<i22>, %tmp_60: i22)
		%tmp_61 = arith.constant 1 : index
		%tmp_62 = memref.load %tmp_2[%tmp_61] : memref<4xi32>
		%tmp_63 = arith.trunci %tmp_62 : i32 to i22
		fifo.push(%r_out: !fifo.input_port<i22>, %tmp_63: i22)
		%tmp_64 = arith.constant 2 : index
		%tmp_65 = memref.load %tmp_2[%tmp_64] : memref<4xi32>
		%tmp_66 = arith.trunci %tmp_65 : i32 to i22
		fifo.push(%r_out: !fifo.input_port<i22>, %tmp_66: i22)
		%tmp_67 = arith.constant 3 : index
		%tmp_68 = memref.load %tmp_2[%tmp_67] : memref<4xi32>
		%tmp_69 = arith.trunci %tmp_68 : i32 to i22
		fifo.push(%r_out: !fifo.input_port<i22>, %tmp_69: i22)
		// Output Expression: End
	}
}

//-- Definition of actor class: JoinerRowR
cal.actor @joinersPerRow_r_2 ()
	ports_in(%r_in_array_0_x: !fifo.output_port<i22>,%r_in_array_1_x: !fifo.output_port<i22>)
	ports_out(%r_out: !fifo.input_port<i22>)
{
	// -- Actor body
	%l_matrix__number__73 = cal.create_state_var<i32> : !cal.state_ref<i32>
	%tmp_0 = arith.constant 0 : i1
	%tmp_1 = arith.extui %tmp_0 : i1 to i32
	cal.set(%l_matrix__number__73: !cal.state_ref<i32>, %tmp_1: i32)
	// Generation action: $untagged0
	cal.action "$untagged0" priority=0 {
		// Input Pattern: Start
		%l_____input0______75_d1_0 = fifo.pop(%r_in_array_0_x: !fifo.output_port<i22>) : i22
		// Input Pattern: End
		// Input Pattern: Start
		%l_____input1______78_d1_0 = fifo.pop(%r_in_array_1_x: !fifo.output_port<i22>) : i22
		// Input Pattern: End
		// Action Local Variable Decl: Start
		%tmp_2 = memref.alloc() : memref<2xi32>
		%tmp_3 = arith.constant 0: index
		%tmp_4 = arith.extsi %l_____input0______75_d1_0 : i22 to i32
		memref.store %tmp_4, %tmp_2[%tmp_3] : memref<2xi32>
		%tmp_5 = arith.constant 1: index
		%tmp_6 = arith.extsi %l_____input1______78_d1_0 : i22 to i32
		memref.store %tmp_6, %tmp_2[%tmp_5] : memref<2xi32>
		// l_input__80_d1_0 aliased to tmp_2
		// Action Local Variable Decl: End
		// If Statement: Begin
		%tmp_7 = cal.get(%l_matrix__number__73: !cal.state_ref<i32>) : i32
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
			%tmp_14 = cal.get(%l_matrix__number__73: !cal.state_ref<i32>) : i32
			fifo.print("R%u: row 2: \00", %tmp_14) : (i32)
			// Call Statement: End
			// If Statement: Begin
			// Evaluate global variable $eval7.
			%tmp_15 = arith.constant 2 : i2
			%tmp_16 = arith.extui %tmp_15 : i2 to i32
			// Evaluate global variable $eval7 done: assigned to tmp_16 above in this context.
			%tmp_17 = arith.constant 0 : i1
			%tmp_18 = arith.extui %tmp_17 : i1 to i32
			%tmp_19 = arith.cmpi ne, %tmp_16, %tmp_18 : i32
			scf.if %tmp_19 {
				// Foreach Statement: Begin
				%tmp_20 = arith.constant 0 : i1
				%tmp_21 = arith.extui %tmp_20 : i1 to i32
				%tmp_22_lb = index.casts %tmp_21 : i32 to index
				// Evaluate global variable $eval1.
				%tmp_23 = arith.constant 4 : i3
				%tmp_24 = arith.extui %tmp_23 : i3 to i32
				// Evaluate global variable $eval1 done: assigned to tmp_24 above in this context.
				// Evaluate global variable $eval7.
				%tmp_25 = arith.constant 2 : i2
				%tmp_26 = arith.extui %tmp_25 : i2 to i32
				// Evaluate global variable $eval7 done: assigned to tmp_26 above in this context.
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
			// Evaluate global variable $eval7.
			%tmp_37 = arith.constant 2 : i2
			%tmp_38 = arith.extui %tmp_37 : i2 to i32
			// Evaluate global variable $eval7 done: assigned to tmp_38 above in this context.
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
		%tmp_50 = cal.get(%l_matrix__number__73: !cal.state_ref<i32>) : i32
		%tmp_51 = arith.constant 1 : i1
		%tmp_52 = arith.extui %tmp_51 : i1 to i32
		%tmp_53 = arith.addi %tmp_50, %tmp_52 : i32
		cal.set(%l_matrix__number__73: !cal.state_ref<i32>, %tmp_53: i32)
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

//-- Definition of actor class: JoinerRowR
cal.actor @joinersPerRow_r_1 ()
	ports_in(%r_in_array_0_x: !fifo.output_port<i22>,%r_in_array_1_x: !fifo.output_port<i22>,%r_in_array_2_x: !fifo.output_port<i22>)
	ports_out(%r_out: !fifo.input_port<i22>)
{
	// -- Actor body
	%l_matrix__number__62 = cal.create_state_var<i32> : !cal.state_ref<i32>
	%tmp_0 = arith.constant 0 : i1
	%tmp_1 = arith.extui %tmp_0 : i1 to i32
	cal.set(%l_matrix__number__62: !cal.state_ref<i32>, %tmp_1: i32)
	// Generation action: $untagged0
	cal.action "$untagged0" priority=0 {
		// Input Pattern: Start
		%l_____input0______64_d1_0 = fifo.pop(%r_in_array_0_x: !fifo.output_port<i22>) : i22
		// Input Pattern: End
		// Input Pattern: Start
		%l_____input1______67_d1_0 = fifo.pop(%r_in_array_1_x: !fifo.output_port<i22>) : i22
		// Input Pattern: End
		// Input Pattern: Start
		%l_____input2______70_d1_0 = fifo.pop(%r_in_array_2_x: !fifo.output_port<i22>) : i22
		// Input Pattern: End
		// Action Local Variable Decl: Start
		%tmp_2 = memref.alloc() : memref<3xi32>
		%tmp_3 = arith.constant 0: index
		%tmp_4 = arith.extsi %l_____input0______64_d1_0 : i22 to i32
		memref.store %tmp_4, %tmp_2[%tmp_3] : memref<3xi32>
		%tmp_5 = arith.constant 1: index
		%tmp_6 = arith.extsi %l_____input1______67_d1_0 : i22 to i32
		memref.store %tmp_6, %tmp_2[%tmp_5] : memref<3xi32>
		%tmp_7 = arith.constant 2: index
		%tmp_8 = arith.extsi %l_____input2______70_d1_0 : i22 to i32
		memref.store %tmp_8, %tmp_2[%tmp_7] : memref<3xi32>
		// l_input__72_d1_0 aliased to tmp_2
		// Action Local Variable Decl: End
		// If Statement: Begin
		%tmp_9 = cal.get(%l_matrix__number__62: !cal.state_ref<i32>) : i32
		// Evaluate global variable num_matrices.
		%tmp_10 = arith.constant 10000 : i14
		%tmp_11 = arith.extui %tmp_10 : i14 to i32
		// Evaluate global variable num_matrices done: assigned to tmp_11 above in this context.
		%tmp_12 = arith.constant 10 : i4
		%tmp_13 = arith.extui %tmp_12 : i4 to i32
		%tmp_14 = arith.subi %tmp_11, %tmp_13 : i32
		%tmp_15 = arith.cmpi eq, %tmp_9, %tmp_14 : i32
		scf.if %tmp_15 {
			// Call Statement: Start
			%tmp_16 = cal.get(%l_matrix__number__62: !cal.state_ref<i32>) : i32
			fifo.print("R%u: row 1: \00", %tmp_16) : (i32)
			// Call Statement: End
			// If Statement: Begin
			// Evaluate global variable $eval5.
			%tmp_17 = arith.constant 1 : i1
			%tmp_18 = arith.extui %tmp_17 : i1 to i32
			// Evaluate global variable $eval5 done: assigned to tmp_18 above in this context.
			%tmp_19 = arith.constant 0 : i1
			%tmp_20 = arith.extui %tmp_19 : i1 to i32
			%tmp_21 = arith.cmpi ne, %tmp_18, %tmp_20 : i32
			scf.if %tmp_21 {
				// Foreach Statement: Begin
				%tmp_22 = arith.constant 0 : i1
				%tmp_23 = arith.extui %tmp_22 : i1 to i32
				%tmp_24_lb = index.casts %tmp_23 : i32 to index
				// Evaluate global variable $eval1.
				%tmp_25 = arith.constant 4 : i3
				%tmp_26 = arith.extui %tmp_25 : i3 to i32
				// Evaluate global variable $eval1 done: assigned to tmp_26 above in this context.
				// Evaluate global variable $eval9.
				%tmp_27 = arith.constant 3 : i2
				%tmp_28 = arith.extui %tmp_27 : i2 to i32
				// Evaluate global variable $eval9 done: assigned to tmp_28 above in this context.
				%tmp_29 = arith.subi %tmp_26, %tmp_28 : i32
				%tmp_30 = arith.constant 1 : i1
				%tmp_31 = arith.extui %tmp_30 : i1 to i32
				%tmp_32 = arith.subi %tmp_29, %tmp_31 : i32
				%tmp_33_ub = index.casts %tmp_32 : i32 to index
				%tmp_34_step = index.constant 1
				%tmp_35_ub_plus_1 = arith.addi %tmp_33_ub, %tmp_34_step : index
				scf.for %l_index_d3_0 = %tmp_24_lb to %tmp_35_ub_plus_1 step %tmp_34_step
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
			%tmp_36 = arith.constant 0 : i1
			%tmp_37 = arith.extui %tmp_36 : i1 to i32
			%tmp_38_lb = index.casts %tmp_37 : i32 to index
			// Evaluate global variable $eval9.
			%tmp_39 = arith.constant 3 : i2
			%tmp_40 = arith.extui %tmp_39 : i2 to i32
			// Evaluate global variable $eval9 done: assigned to tmp_40 above in this context.
			%tmp_41 = arith.constant 1 : i1
			%tmp_42 = arith.extui %tmp_41 : i1 to i32
			%tmp_43 = arith.subi %tmp_40, %tmp_42 : i32
			%tmp_44_ub = index.casts %tmp_43 : i32 to index
			%tmp_45_step = index.constant 1
			%tmp_46_ub_plus_1 = arith.addi %tmp_44_ub, %tmp_45_step : index
			scf.for %l_index_d2_0 = %tmp_38_lb to %tmp_46_ub_plus_1 step %tmp_45_step
					iter_args() -> () {
				%l_index_d3_0 = arith.index_cast %l_index_d2_0 : index to i32
				%l_index_d3_1 = arith.trunci %l_index_d3_0 : i32 to i8
				// Call Statement: Start
				%tmp_47 = arith.extui %l_index_d3_1 : i8 to i32
				%tmp_48 = arith.index_cast %tmp_47: i32 to index
				%tmp_50 = memref.load %tmp_2[%tmp_48] : memref<3xi32>
				%tmp_49 = arith.trunci %tmp_50 : i32 to i22
				%tmp_51 = arith.extsi %tmp_49 : i22 to i32
				fifo.print("%i \00", %tmp_51) : (i32)
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
		%tmp_52 = cal.get(%l_matrix__number__62: !cal.state_ref<i32>) : i32
		%tmp_53 = arith.constant 1 : i1
		%tmp_54 = arith.extui %tmp_53 : i1 to i32
		%tmp_55 = arith.addi %tmp_52, %tmp_54 : i32
		cal.set(%l_matrix__number__62: !cal.state_ref<i32>, %tmp_55: i32)
		// Assignment Statement: End
		// Output Expression: Start
		%tmp_56 = arith.constant 0 : index
		%tmp_57 = memref.load %tmp_2[%tmp_56] : memref<3xi32>
		%tmp_58 = arith.trunci %tmp_57 : i32 to i22
		fifo.push(%r_out: !fifo.input_port<i22>, %tmp_58: i22)
		%tmp_59 = arith.constant 1 : index
		%tmp_60 = memref.load %tmp_2[%tmp_59] : memref<3xi32>
		%tmp_61 = arith.trunci %tmp_60 : i32 to i22
		fifo.push(%r_out: !fifo.input_port<i22>, %tmp_61: i22)
		%tmp_62 = arith.constant 2 : index
		%tmp_63 = memref.load %tmp_2[%tmp_62] : memref<3xi32>
		%tmp_64 = arith.trunci %tmp_63 : i32 to i22
		fifo.push(%r_out: !fifo.input_port<i22>, %tmp_64: i22)
		// Output Expression: End
	}
}

// -- Top Network: Defines structure of actor application
cal.network
{

	// -- Instantiate channels between actors
	%queue_from_innerCells_q_6_r_out, %queue_to_joinersPerRow_q_2_r_in_array_1_x = fifo.create<i22>(1) : !fifo.input_port<i22>, !fifo.output_port<i22>
	%queue_from_boundaryCells_3_r_out, %queue_to_joinersPerRow_r_3_r_in_array_0_x = fifo.create<i22>(1) : !fifo.input_port<i22>, !fifo.output_port<i22>
	%queue_from_innerCells_q_6_cordic_angles_out, %queue_to_innerCells_q_7_cordic_angles_in = fifo.create<i16>(1) : !fifo.input_port<i16>, !fifo.output_port<i16>
	%queue_from_iGenerator_3_Out, %queue_to_innerCells_q_3_x_in = fifo.create<i22>(1) : !fifo.input_port<i22>, !fifo.output_port<i22>
	%queue_from_innerCells_q_2_cordic_angles_out, %queue_to_innerCells_q_3_cordic_angles_in = fifo.create<i16>(1) : !fifo.input_port<i16>, !fifo.output_port<i16>
	%queue_from_innerCells_r_3_cordic_angles_out, %queue_to_innerCells_r_4_cordic_angles_in = fifo.create<i16>(1) : !fifo.input_port<i16>, !fifo.output_port<i16>
	%queue_from_joinersPerRow_r_2_r_out, %queue_to_caps_r_2_In = fifo.create<i22>(4) : !fifo.input_port<i22>, !fifo.output_port<i22>
	%queue_from_innerCells_q_12_r_out, %queue_to_joinersPerRow_q_0_r_in_array_3_x = fifo.create<i22>(1) : !fifo.input_port<i22>, !fifo.output_port<i22>
	%queue_from_boundaryCells_3_cordic_angles_out, %queue_to_innerCells_q_12_cordic_angles_in = fifo.create<i16>(1) : !fifo.input_port<i16>, !fifo.output_port<i16>
	%queue_from_innerCells_q_10_x_out, %queue_to_innerCells_q_14_x_in = fifo.create<i22>(1) : !fifo.input_port<i22>, !fifo.output_port<i22>
	%queue_from_innerCells_q_14_x_out, %queue_to_caps_x_2_In = fifo.create<i22>(1) : !fifo.input_port<i22>, !fifo.output_port<i22>
	%queue_from_joinersPerRow_q_0_q_out, %queue_to_caps_q_0_In = fifo.create<i22>(4) : !fifo.input_port<i22>, !fifo.output_port<i22>
	%queue_from_innerCells_q_8_x_out, %queue_to_innerCells_q_12_x_in = fifo.create<i22>(1) : !fifo.input_port<i22>, !fifo.output_port<i22>
	%queue_from_innerCells_q_4_x_out, %queue_to_innerCells_q_8_x_in = fifo.create<i22>(1) : !fifo.input_port<i22>, !fifo.output_port<i22>
	%queue_from_innerCells_r_5_x_out, %queue_to_boundaryCells_3_x_in = fifo.create<i22>(1) : !fifo.input_port<i22>, !fifo.output_port<i22>
	%queue_from_innerCells_q_0_x_out, %queue_to_innerCells_q_4_x_in = fifo.create<i22>(1) : !fifo.input_port<i22>, !fifo.output_port<i22>
	%queue_from_innerCells_q_11_cordic_angles_out, %queue_to_caps_cordic_2_In = fifo.create<i16>(1) : !fifo.input_port<i16>, !fifo.output_port<i16>
	%queue_from_innerCells_r_1_x_out, %queue_to_innerCells_r_3_x_in = fifo.create<i22>(1) : !fifo.input_port<i22>, !fifo.output_port<i22>
	%queue_from_innerCells_q_15_cordic_angles_out, %queue_to_caps_cordic_3_In = fifo.create<i16>(1) : !fifo.input_port<i16>, !fifo.output_port<i16>
	%queue_from_innerCells_q_1_r_out, %queue_to_joinersPerRow_q_1_r_in_array_0_x = fifo.create<i22>(1) : !fifo.input_port<i22>, !fifo.output_port<i22>
	%queue_from_innerCells_r_2_r_out, %queue_to_joinersPerRow_r_0_r_in_array_3_x = fifo.create<i22>(1) : !fifo.input_port<i22>, !fifo.output_port<i22>
	%queue_from_joinersPerRow_r_1_r_out, %queue_to_caps_r_1_In = fifo.create<i22>(4) : !fifo.input_port<i22>, !fifo.output_port<i22>
	%queue_from_innerCells_q_5_r_out, %queue_to_joinersPerRow_q_1_r_in_array_1_x = fifo.create<i22>(1) : !fifo.input_port<i22>, !fifo.output_port<i22>
	%queue_from_innerCells_q_9_cordic_angles_out, %queue_to_innerCells_q_10_cordic_angles_in = fifo.create<i16>(1) : !fifo.input_port<i16>, !fifo.output_port<i16>
	%queue_from_boundaryCells_0_cordic_angles_out, %queue_to_innerCells_r_0_cordic_angles_in = fifo.create<i16>(1) : !fifo.input_port<i16>, !fifo.output_port<i16>
	%queue_from_innerCells_q_9_r_out, %queue_to_joinersPerRow_q_1_r_in_array_2_x = fifo.create<i22>(1) : !fifo.input_port<i22>, !fifo.output_port<i22>
	%queue_from_innerCells_r_2_cordic_angles_out, %queue_to_innerCells_q_0_cordic_angles_in = fifo.create<i16>(1) : !fifo.input_port<i16>, !fifo.output_port<i16>
	%queue_from_innerCells_q_13_r_out, %queue_to_joinersPerRow_q_1_r_in_array_3_x = fifo.create<i22>(1) : !fifo.input_port<i22>, !fifo.output_port<i22>
	%queue_from_innerCells_q_5_cordic_angles_out, %queue_to_innerCells_q_6_cordic_angles_in = fifo.create<i16>(1) : !fifo.input_port<i16>, !fifo.output_port<i16>
	%queue_from_iGenerator_0_Out, %queue_to_innerCells_q_0_x_in = fifo.create<i22>(1) : !fifo.input_port<i22>, !fifo.output_port<i22>
	%queue_from_source_Out_array_3_x, %queue_to_innerCells_r_2_x_in = fifo.create<i22>(5) : !fifo.input_port<i22>, !fifo.output_port<i22>
	%queue_from_innerCells_q_11_x_out, %queue_to_innerCells_q_15_x_in = fifo.create<i22>(1) : !fifo.input_port<i22>, !fifo.output_port<i22>
	%queue_from_innerCells_q_1_cordic_angles_out, %queue_to_innerCells_q_2_cordic_angles_in = fifo.create<i16>(1) : !fifo.input_port<i16>, !fifo.output_port<i16>
	%queue_from_source_Out_array_1_x, %queue_to_innerCells_r_0_x_in = fifo.create<i22>(5) : !fifo.input_port<i22>, !fifo.output_port<i22>
	%queue_from_innerCells_q_15_x_out, %queue_to_caps_x_3_In = fifo.create<i22>(1) : !fifo.input_port<i22>, !fifo.output_port<i22>
	%queue_from_boundaryCells_2_r_out, %queue_to_joinersPerRow_r_2_r_in_array_0_x = fifo.create<i22>(1) : !fifo.input_port<i22>, !fifo.output_port<i22>
	%queue_from_joinersPerRow_q_1_q_out, %queue_to_caps_q_1_In = fifo.create<i22>(4) : !fifo.input_port<i22>, !fifo.output_port<i22>
	%queue_from_innerCells_q_9_x_out, %queue_to_innerCells_q_13_x_in = fifo.create<i22>(1) : !fifo.input_port<i22>, !fifo.output_port<i22>
	%queue_from_innerCells_r_2_x_out, %queue_to_innerCells_r_4_x_in = fifo.create<i22>(1) : !fifo.input_port<i22>, !fifo.output_port<i22>
	%queue_from_innerCells_q_5_x_out, %queue_to_innerCells_q_9_x_in = fifo.create<i22>(1) : !fifo.input_port<i22>, !fifo.output_port<i22>
	%queue_from_innerCells_q_10_cordic_angles_out, %queue_to_innerCells_q_11_cordic_angles_in = fifo.create<i16>(1) : !fifo.input_port<i16>, !fifo.output_port<i16>
	%queue_from_innerCells_q_0_r_out, %queue_to_joinersPerRow_q_0_r_in_array_0_x = fifo.create<i22>(1) : !fifo.input_port<i22>, !fifo.output_port<i22>
	%queue_from_innerCells_q_1_x_out, %queue_to_innerCells_q_5_x_in = fifo.create<i22>(1) : !fifo.input_port<i22>, !fifo.output_port<i22>
	%queue_from_innerCells_r_1_r_out, %queue_to_joinersPerRow_r_0_r_in_array_2_x = fifo.create<i22>(1) : !fifo.input_port<i22>, !fifo.output_port<i22>
	%queue_from_innerCells_q_14_cordic_angles_out, %queue_to_innerCells_q_15_cordic_angles_in = fifo.create<i16>(1) : !fifo.input_port<i16>, !fifo.output_port<i16>
	%queue_from_innerCells_q_4_r_out, %queue_to_joinersPerRow_q_0_r_in_array_1_x = fifo.create<i22>(1) : !fifo.input_port<i22>, !fifo.output_port<i22>
	%queue_from_innerCells_r_5_r_out, %queue_to_joinersPerRow_r_2_r_in_array_1_x = fifo.create<i22>(1) : !fifo.input_port<i22>, !fifo.output_port<i22>
	%queue_from_innerCells_r_5_cordic_angles_out, %queue_to_innerCells_q_8_cordic_angles_in = fifo.create<i16>(1) : !fifo.input_port<i16>, !fifo.output_port<i16>
	%queue_from_joinersPerRow_r_0_r_out, %queue_to_caps_r_0_In = fifo.create<i22>(4) : !fifo.input_port<i22>, !fifo.output_port<i22>
	%queue_from_iGenerator_1_Out, %queue_to_innerCells_q_1_x_in = fifo.create<i22>(1) : !fifo.input_port<i22>, !fifo.output_port<i22>
	%queue_from_innerCells_q_8_r_out, %queue_to_joinersPerRow_q_0_r_in_array_2_x = fifo.create<i22>(1) : !fifo.input_port<i22>, !fifo.output_port<i22>
	%queue_from_innerCells_q_8_cordic_angles_out, %queue_to_innerCells_q_9_cordic_angles_in = fifo.create<i16>(1) : !fifo.input_port<i16>, !fifo.output_port<i16>
	%queue_from_innerCells_r_1_cordic_angles_out, %queue_to_innerCells_r_2_cordic_angles_in = fifo.create<i16>(1) : !fifo.input_port<i16>, !fifo.output_port<i16>
	%queue_from_innerCells_q_14_r_out, %queue_to_joinersPerRow_q_2_r_in_array_3_x = fifo.create<i22>(1) : !fifo.input_port<i22>, !fifo.output_port<i22>
	%queue_from_boundaryCells_1_cordic_angles_out, %queue_to_innerCells_r_3_cordic_angles_in = fifo.create<i16>(1) : !fifo.input_port<i16>, !fifo.output_port<i16>
	%queue_from_innerCells_q_4_cordic_angles_out, %queue_to_innerCells_q_5_cordic_angles_in = fifo.create<i16>(1) : !fifo.input_port<i16>, !fifo.output_port<i16>
	%queue_from_innerCells_q_12_x_out, %queue_to_caps_x_0_In = fifo.create<i22>(1) : !fifo.input_port<i22>, !fifo.output_port<i22>
	%queue_from_innerCells_q_0_cordic_angles_out, %queue_to_innerCells_q_1_cordic_angles_in = fifo.create<i16>(1) : !fifo.input_port<i16>, !fifo.output_port<i16>
	%queue_from_boundaryCells_1_r_out, %queue_to_joinersPerRow_r_1_r_in_array_0_x = fifo.create<i22>(1) : !fifo.input_port<i22>, !fifo.output_port<i22>
	%queue_from_innerCells_r_3_x_out, %queue_to_boundaryCells_2_x_in = fifo.create<i22>(1) : !fifo.input_port<i22>, !fifo.output_port<i22>
	%queue_from_joinersPerRow_q_2_q_out, %queue_to_caps_q_2_In = fifo.create<i22>(4) : !fifo.input_port<i22>, !fifo.output_port<i22>
	%queue_from_innerCells_q_6_x_out, %queue_to_innerCells_q_10_x_in = fifo.create<i22>(1) : !fifo.input_port<i22>, !fifo.output_port<i22>
	%queue_from_innerCells_q_10_r_out, %queue_to_joinersPerRow_q_2_r_in_array_2_x = fifo.create<i22>(1) : !fifo.input_port<i22>, !fifo.output_port<i22>
	%queue_from_innerCells_q_2_x_out, %queue_to_innerCells_q_6_x_in = fifo.create<i22>(1) : !fifo.input_port<i22>, !fifo.output_port<i22>
	%queue_from_innerCells_r_0_r_out, %queue_to_joinersPerRow_r_0_r_in_array_1_x = fifo.create<i22>(1) : !fifo.input_port<i22>, !fifo.output_port<i22>
	%queue_from_innerCells_q_13_cordic_angles_out, %queue_to_innerCells_q_14_cordic_angles_in = fifo.create<i16>(1) : !fifo.input_port<i16>, !fifo.output_port<i16>
	%queue_from_innerCells_q_3_r_out, %queue_to_joinersPerRow_q_3_r_in_array_0_x = fifo.create<i22>(1) : !fifo.input_port<i22>, !fifo.output_port<i22>
	%queue_from_innerCells_q_7_cordic_angles_out, %queue_to_caps_cordic_1_In = fifo.create<i16>(1) : !fifo.input_port<i16>, !fifo.output_port<i16>
	%queue_from_iGenerator_2_Out, %queue_to_innerCells_q_2_x_in = fifo.create<i22>(1) : !fifo.input_port<i22>, !fifo.output_port<i22>
	%queue_from_innerCells_r_4_r_out, %queue_to_joinersPerRow_r_1_r_in_array_2_x = fifo.create<i22>(1) : !fifo.input_port<i22>, !fifo.output_port<i22>
	%queue_from_innerCells_q_7_r_out, %queue_to_joinersPerRow_q_3_r_in_array_1_x = fifo.create<i22>(1) : !fifo.input_port<i22>, !fifo.output_port<i22>
	%queue_from_innerCells_q_15_r_out, %queue_to_joinersPerRow_q_3_r_in_array_3_x = fifo.create<i22>(1) : !fifo.input_port<i22>, !fifo.output_port<i22>
	%queue_from_innerCells_q_3_cordic_angles_out, %queue_to_caps_cordic_0_In = fifo.create<i16>(1) : !fifo.input_port<i16>, !fifo.output_port<i16>
	%queue_from_joinersPerRow_r_3_r_out, %queue_to_caps_r_3_In = fifo.create<i22>(4) : !fifo.input_port<i22>, !fifo.output_port<i22>
	%queue_from_boundaryCells_2_cordic_angles_out, %queue_to_innerCells_r_5_cordic_angles_in = fifo.create<i16>(1) : !fifo.input_port<i16>, !fifo.output_port<i16>
	%queue_from_innerCells_r_4_cordic_angles_out, %queue_to_innerCells_q_4_cordic_angles_in = fifo.create<i16>(1) : !fifo.input_port<i16>, !fifo.output_port<i16>
	%queue_from_innerCells_q_13_x_out, %queue_to_caps_x_1_In = fifo.create<i22>(1) : !fifo.input_port<i22>, !fifo.output_port<i22>
	%queue_from_source_Out_array_2_x, %queue_to_innerCells_r_1_x_in = fifo.create<i22>(5) : !fifo.input_port<i22>, !fifo.output_port<i22>
	%queue_from_innerCells_r_0_cordic_angles_out, %queue_to_innerCells_r_1_cordic_angles_in = fifo.create<i16>(1) : !fifo.input_port<i16>, !fifo.output_port<i16>
	%queue_from_source_Out_array_0_x, %queue_to_boundaryCells_0_x_in = fifo.create<i22>(5) : !fifo.input_port<i22>, !fifo.output_port<i22>
	%queue_from_boundaryCells_0_r_out, %queue_to_joinersPerRow_r_0_r_in_array_0_x = fifo.create<i22>(1) : !fifo.input_port<i22>, !fifo.output_port<i22>
	%queue_from_innerCells_q_7_x_out, %queue_to_innerCells_q_11_x_in = fifo.create<i22>(1) : !fifo.input_port<i22>, !fifo.output_port<i22>
	%queue_from_innerCells_q_3_x_out, %queue_to_innerCells_q_7_x_in = fifo.create<i22>(1) : !fifo.input_port<i22>, !fifo.output_port<i22>
	%queue_from_innerCells_r_4_x_out, %queue_to_innerCells_r_5_x_in = fifo.create<i22>(1) : !fifo.input_port<i22>, !fifo.output_port<i22>
	%queue_from_joinersPerRow_q_3_q_out, %queue_to_caps_q_3_In = fifo.create<i22>(4) : !fifo.input_port<i22>, !fifo.output_port<i22>
	%queue_from_innerCells_q_12_cordic_angles_out, %queue_to_innerCells_q_13_cordic_angles_in = fifo.create<i16>(1) : !fifo.input_port<i16>, !fifo.output_port<i16>
	%queue_from_innerCells_q_11_r_out, %queue_to_joinersPerRow_q_3_r_in_array_2_x = fifo.create<i22>(1) : !fifo.input_port<i22>, !fifo.output_port<i22>
	%queue_from_innerCells_r_0_x_out, %queue_to_boundaryCells_1_x_in = fifo.create<i22>(1) : !fifo.input_port<i22>, !fifo.output_port<i22>
	%queue_from_innerCells_q_2_r_out, %queue_to_joinersPerRow_q_2_r_in_array_0_x = fifo.create<i22>(1) : !fifo.input_port<i22>, !fifo.output_port<i22>
	%queue_from_innerCells_r_3_r_out, %queue_to_joinersPerRow_r_1_r_in_array_1_x = fifo.create<i22>(1) : !fifo.input_port<i22>, !fifo.output_port<i22>

	// -- Instantiate actors (also known as nodes/instances)
	cal.create_instance @joinersPerRow_r_3 "joinersPerRow_r_3" ()
		ports_in(%queue_to_joinersPerRow_r_3_r_in_array_0_x: !fifo.output_port<i22>)
		ports_out(%queue_from_joinersPerRow_r_3_r_out: !fifo.input_port<i22>)
	cal.create_instance @caps_cordic_3 "caps_cordic_3" ()
		ports_in(%queue_to_caps_cordic_3_In: !fifo.output_port<i16>)
	cal.create_instance @caps_cordic_2 "caps_cordic_2" ()
		ports_in(%queue_to_caps_cordic_2_In: !fifo.output_port<i16>)
	cal.create_instance @caps_cordic_1 "caps_cordic_1" ()
		ports_in(%queue_to_caps_cordic_1_In: !fifo.output_port<i16>)
	cal.create_instance @boundaryCells_1 "boundaryCells_1" ()
		ports_in(%queue_to_boundaryCells_1_x_in: !fifo.output_port<i22>)
		ports_out(%queue_from_boundaryCells_1_r_out, %queue_from_boundaryCells_1_cordic_angles_out: !fifo.input_port<i22>, !fifo.input_port<i16>)
	cal.create_instance @innerCells_q_0 "innerCells_q_0" ()
		ports_in(%queue_to_innerCells_q_0_x_in, %queue_to_innerCells_q_0_cordic_angles_in: !fifo.output_port<i22>, !fifo.output_port<i16>)
		ports_out(%queue_from_innerCells_q_0_x_out, %queue_from_innerCells_q_0_r_out, %queue_from_innerCells_q_0_cordic_angles_out: !fifo.input_port<i22>, !fifo.input_port<i22>, !fifo.input_port<i16>)
	cal.create_instance @caps_cordic_0 "caps_cordic_0" ()
		ports_in(%queue_to_caps_cordic_0_In: !fifo.output_port<i16>)
	cal.create_instance @boundaryCells_0 "boundaryCells_0" ()
		ports_in(%queue_to_boundaryCells_0_x_in: !fifo.output_port<i22>)
		ports_out(%queue_from_boundaryCells_0_r_out, %queue_from_boundaryCells_0_cordic_angles_out: !fifo.input_port<i22>, !fifo.input_port<i16>)
	cal.create_instance @innerCells_q_1 "innerCells_q_1" ()
		ports_in(%queue_to_innerCells_q_1_x_in, %queue_to_innerCells_q_1_cordic_angles_in: !fifo.output_port<i22>, !fifo.output_port<i16>)
		ports_out(%queue_from_innerCells_q_1_x_out, %queue_from_innerCells_q_1_r_out, %queue_from_innerCells_q_1_cordic_angles_out: !fifo.input_port<i22>, !fifo.input_port<i22>, !fifo.input_port<i16>)
	cal.create_instance @boundaryCells_3 "boundaryCells_3" ()
		ports_in(%queue_to_boundaryCells_3_x_in: !fifo.output_port<i22>)
		ports_out(%queue_from_boundaryCells_3_r_out, %queue_from_boundaryCells_3_cordic_angles_out: !fifo.input_port<i22>, !fifo.input_port<i16>)
	cal.create_instance @source "source" ()
		ports_out(%queue_from_source_Out_array_0_x, %queue_from_source_Out_array_1_x, %queue_from_source_Out_array_2_x, %queue_from_source_Out_array_3_x: !fifo.input_port<i22>, !fifo.input_port<i22>, !fifo.input_port<i22>, !fifo.input_port<i22>)
	cal.create_instance @boundaryCells_2 "boundaryCells_2" ()
		ports_in(%queue_to_boundaryCells_2_x_in: !fifo.output_port<i22>)
		ports_out(%queue_from_boundaryCells_2_r_out, %queue_from_boundaryCells_2_cordic_angles_out: !fifo.input_port<i22>, !fifo.input_port<i16>)
	cal.create_instance @innerCells_r_5 "innerCells_r_5" ()
		ports_in(%queue_to_innerCells_r_5_x_in, %queue_to_innerCells_r_5_cordic_angles_in: !fifo.output_port<i22>, !fifo.output_port<i16>)
		ports_out(%queue_from_innerCells_r_5_x_out, %queue_from_innerCells_r_5_r_out, %queue_from_innerCells_r_5_cordic_angles_out: !fifo.input_port<i22>, !fifo.input_port<i22>, !fifo.input_port<i16>)
	cal.create_instance @innerCells_r_3 "innerCells_r_3" ()
		ports_in(%queue_to_innerCells_r_3_x_in, %queue_to_innerCells_r_3_cordic_angles_in: !fifo.output_port<i22>, !fifo.output_port<i16>)
		ports_out(%queue_from_innerCells_r_3_x_out, %queue_from_innerCells_r_3_r_out, %queue_from_innerCells_r_3_cordic_angles_out: !fifo.input_port<i22>, !fifo.input_port<i22>, !fifo.input_port<i16>)
	cal.create_instance @caps_r_0 "caps_r_0" ()
		ports_in(%queue_to_caps_r_0_In: !fifo.output_port<i22>)
	cal.create_instance @innerCells_r_4 "innerCells_r_4" ()
		ports_in(%queue_to_innerCells_r_4_x_in, %queue_to_innerCells_r_4_cordic_angles_in: !fifo.output_port<i22>, !fifo.output_port<i16>)
		ports_out(%queue_from_innerCells_r_4_x_out, %queue_from_innerCells_r_4_r_out, %queue_from_innerCells_r_4_cordic_angles_out: !fifo.input_port<i22>, !fifo.input_port<i22>, !fifo.input_port<i16>)
	cal.create_instance @innerCells_r_1 "innerCells_r_1" ()
		ports_in(%queue_to_innerCells_r_1_x_in, %queue_to_innerCells_r_1_cordic_angles_in: !fifo.output_port<i22>, !fifo.output_port<i16>)
		ports_out(%queue_from_innerCells_r_1_x_out, %queue_from_innerCells_r_1_r_out, %queue_from_innerCells_r_1_cordic_angles_out: !fifo.input_port<i22>, !fifo.input_port<i22>, !fifo.input_port<i16>)
	cal.create_instance @caps_r_2 "caps_r_2" ()
		ports_in(%queue_to_caps_r_2_In: !fifo.output_port<i22>)
	cal.create_instance @innerCells_r_2 "innerCells_r_2" ()
		ports_in(%queue_to_innerCells_r_2_x_in, %queue_to_innerCells_r_2_cordic_angles_in: !fifo.output_port<i22>, !fifo.output_port<i16>)
		ports_out(%queue_from_innerCells_r_2_x_out, %queue_from_innerCells_r_2_r_out, %queue_from_innerCells_r_2_cordic_angles_out: !fifo.input_port<i22>, !fifo.input_port<i22>, !fifo.input_port<i16>)
	cal.create_instance @caps_r_1 "caps_r_1" ()
		ports_in(%queue_to_caps_r_1_In: !fifo.output_port<i22>)
	cal.create_instance @joinersPerRow_q_1 "joinersPerRow_q_1" ()
		ports_in(%queue_to_joinersPerRow_q_1_r_in_array_0_x, %queue_to_joinersPerRow_q_1_r_in_array_1_x, %queue_to_joinersPerRow_q_1_r_in_array_2_x, %queue_to_joinersPerRow_q_1_r_in_array_3_x: !fifo.output_port<i22>, !fifo.output_port<i22>, !fifo.output_port<i22>, !fifo.output_port<i22>)
		ports_out(%queue_from_joinersPerRow_q_1_q_out: !fifo.input_port<i22>)
	cal.create_instance @iGenerator_2 "iGenerator_2" ()
		ports_out(%queue_from_iGenerator_2_Out: !fifo.input_port<i22>)
	cal.create_instance @caps_r_3 "caps_r_3" ()
		ports_in(%queue_to_caps_r_3_In: !fifo.output_port<i22>)
	cal.create_instance @joinersPerRow_q_0 "joinersPerRow_q_0" ()
		ports_in(%queue_to_joinersPerRow_q_0_r_in_array_0_x, %queue_to_joinersPerRow_q_0_r_in_array_1_x, %queue_to_joinersPerRow_q_0_r_in_array_2_x, %queue_to_joinersPerRow_q_0_r_in_array_3_x: !fifo.output_port<i22>, !fifo.output_port<i22>, !fifo.output_port<i22>, !fifo.output_port<i22>)
		ports_out(%queue_from_joinersPerRow_q_0_q_out: !fifo.input_port<i22>)
	cal.create_instance @iGenerator_1 "iGenerator_1" ()
		ports_out(%queue_from_iGenerator_1_Out: !fifo.input_port<i22>)
	cal.create_instance @caps_x_0 "caps_x_0" ()
		ports_in(%queue_to_caps_x_0_In: !fifo.output_port<i22>)
	cal.create_instance @joinersPerRow_q_3 "joinersPerRow_q_3" ()
		ports_in(%queue_to_joinersPerRow_q_3_r_in_array_0_x, %queue_to_joinersPerRow_q_3_r_in_array_1_x, %queue_to_joinersPerRow_q_3_r_in_array_2_x, %queue_to_joinersPerRow_q_3_r_in_array_3_x: !fifo.output_port<i22>, !fifo.output_port<i22>, !fifo.output_port<i22>, !fifo.output_port<i22>)
		ports_out(%queue_from_joinersPerRow_q_3_q_out: !fifo.input_port<i22>)
	cal.create_instance @joinersPerRow_q_2 "joinersPerRow_q_2" ()
		ports_in(%queue_to_joinersPerRow_q_2_r_in_array_0_x, %queue_to_joinersPerRow_q_2_r_in_array_1_x, %queue_to_joinersPerRow_q_2_r_in_array_2_x, %queue_to_joinersPerRow_q_2_r_in_array_3_x: !fifo.output_port<i22>, !fifo.output_port<i22>, !fifo.output_port<i22>, !fifo.output_port<i22>)
		ports_out(%queue_from_joinersPerRow_q_2_q_out: !fifo.input_port<i22>)
	cal.create_instance @iGenerator_3 "iGenerator_3" ()
		ports_out(%queue_from_iGenerator_3_Out: !fifo.input_port<i22>)
	cal.create_instance @caps_x_2 "caps_x_2" ()
		ports_in(%queue_to_caps_x_2_In: !fifo.output_port<i22>)
	cal.create_instance @caps_x_1 "caps_x_1" ()
		ports_in(%queue_to_caps_x_1_In: !fifo.output_port<i22>)
	cal.create_instance @iGenerator_0 "iGenerator_0" ()
		ports_out(%queue_from_iGenerator_0_Out: !fifo.input_port<i22>)
	cal.create_instance @caps_x_3 "caps_x_3" ()
		ports_in(%queue_to_caps_x_3_In: !fifo.output_port<i22>)
	cal.create_instance @innerCells_r_0 "innerCells_r_0" ()
		ports_in(%queue_to_innerCells_r_0_x_in, %queue_to_innerCells_r_0_cordic_angles_in: !fifo.output_port<i22>, !fifo.output_port<i16>)
		ports_out(%queue_from_innerCells_r_0_x_out, %queue_from_innerCells_r_0_r_out, %queue_from_innerCells_r_0_cordic_angles_out: !fifo.input_port<i22>, !fifo.input_port<i22>, !fifo.input_port<i16>)
	cal.create_instance @innerCells_q_11 "innerCells_q_11" ()
		ports_in(%queue_to_innerCells_q_11_x_in, %queue_to_innerCells_q_11_cordic_angles_in: !fifo.output_port<i22>, !fifo.output_port<i16>)
		ports_out(%queue_from_innerCells_q_11_x_out, %queue_from_innerCells_q_11_r_out, %queue_from_innerCells_q_11_cordic_angles_out: !fifo.input_port<i22>, !fifo.input_port<i22>, !fifo.input_port<i16>)
	cal.create_instance @innerCells_q_12 "innerCells_q_12" ()
		ports_in(%queue_to_innerCells_q_12_x_in, %queue_to_innerCells_q_12_cordic_angles_in: !fifo.output_port<i22>, !fifo.output_port<i16>)
		ports_out(%queue_from_innerCells_q_12_x_out, %queue_from_innerCells_q_12_r_out, %queue_from_innerCells_q_12_cordic_angles_out: !fifo.input_port<i22>, !fifo.input_port<i22>, !fifo.input_port<i16>)
	cal.create_instance @innerCells_q_10 "innerCells_q_10" ()
		ports_in(%queue_to_innerCells_q_10_x_in, %queue_to_innerCells_q_10_cordic_angles_in: !fifo.output_port<i22>, !fifo.output_port<i16>)
		ports_out(%queue_from_innerCells_q_10_x_out, %queue_from_innerCells_q_10_r_out, %queue_from_innerCells_q_10_cordic_angles_out: !fifo.input_port<i22>, !fifo.input_port<i22>, !fifo.input_port<i16>)
	cal.create_instance @innerCells_q_15 "innerCells_q_15" ()
		ports_in(%queue_to_innerCells_q_15_x_in, %queue_to_innerCells_q_15_cordic_angles_in: !fifo.output_port<i22>, !fifo.output_port<i16>)
		ports_out(%queue_from_innerCells_q_15_x_out, %queue_from_innerCells_q_15_r_out, %queue_from_innerCells_q_15_cordic_angles_out: !fifo.input_port<i22>, !fifo.input_port<i22>, !fifo.input_port<i16>)
	cal.create_instance @innerCells_q_13 "innerCells_q_13" ()
		ports_in(%queue_to_innerCells_q_13_x_in, %queue_to_innerCells_q_13_cordic_angles_in: !fifo.output_port<i22>, !fifo.output_port<i16>)
		ports_out(%queue_from_innerCells_q_13_x_out, %queue_from_innerCells_q_13_r_out, %queue_from_innerCells_q_13_cordic_angles_out: !fifo.input_port<i22>, !fifo.input_port<i22>, !fifo.input_port<i16>)
	cal.create_instance @innerCells_q_14 "innerCells_q_14" ()
		ports_in(%queue_to_innerCells_q_14_x_in, %queue_to_innerCells_q_14_cordic_angles_in: !fifo.output_port<i22>, !fifo.output_port<i16>)
		ports_out(%queue_from_innerCells_q_14_x_out, %queue_from_innerCells_q_14_r_out, %queue_from_innerCells_q_14_cordic_angles_out: !fifo.input_port<i22>, !fifo.input_port<i22>, !fifo.input_port<i16>)
	cal.create_instance @innerCells_q_8 "innerCells_q_8" ()
		ports_in(%queue_to_innerCells_q_8_x_in, %queue_to_innerCells_q_8_cordic_angles_in: !fifo.output_port<i22>, !fifo.output_port<i16>)
		ports_out(%queue_from_innerCells_q_8_x_out, %queue_from_innerCells_q_8_r_out, %queue_from_innerCells_q_8_cordic_angles_out: !fifo.input_port<i22>, !fifo.input_port<i22>, !fifo.input_port<i16>)
	cal.create_instance @innerCells_q_9 "innerCells_q_9" ()
		ports_in(%queue_to_innerCells_q_9_x_in, %queue_to_innerCells_q_9_cordic_angles_in: !fifo.output_port<i22>, !fifo.output_port<i16>)
		ports_out(%queue_from_innerCells_q_9_x_out, %queue_from_innerCells_q_9_r_out, %queue_from_innerCells_q_9_cordic_angles_out: !fifo.input_port<i22>, !fifo.input_port<i22>, !fifo.input_port<i16>)
	cal.create_instance @innerCells_q_6 "innerCells_q_6" ()
		ports_in(%queue_to_innerCells_q_6_x_in, %queue_to_innerCells_q_6_cordic_angles_in: !fifo.output_port<i22>, !fifo.output_port<i16>)
		ports_out(%queue_from_innerCells_q_6_x_out, %queue_from_innerCells_q_6_r_out, %queue_from_innerCells_q_6_cordic_angles_out: !fifo.input_port<i22>, !fifo.input_port<i22>, !fifo.input_port<i16>)
	cal.create_instance @innerCells_q_7 "innerCells_q_7" ()
		ports_in(%queue_to_innerCells_q_7_x_in, %queue_to_innerCells_q_7_cordic_angles_in: !fifo.output_port<i22>, !fifo.output_port<i16>)
		ports_out(%queue_from_innerCells_q_7_x_out, %queue_from_innerCells_q_7_r_out, %queue_from_innerCells_q_7_cordic_angles_out: !fifo.input_port<i22>, !fifo.input_port<i22>, !fifo.input_port<i16>)
	cal.create_instance @caps_q_1 "caps_q_1" ()
		ports_in(%queue_to_caps_q_1_In: !fifo.output_port<i22>)
	cal.create_instance @innerCells_q_4 "innerCells_q_4" ()
		ports_in(%queue_to_innerCells_q_4_x_in, %queue_to_innerCells_q_4_cordic_angles_in: !fifo.output_port<i22>, !fifo.output_port<i16>)
		ports_out(%queue_from_innerCells_q_4_x_out, %queue_from_innerCells_q_4_r_out, %queue_from_innerCells_q_4_cordic_angles_out: !fifo.input_port<i22>, !fifo.input_port<i22>, !fifo.input_port<i16>)
	cal.create_instance @caps_q_0 "caps_q_0" ()
		ports_in(%queue_to_caps_q_0_In: !fifo.output_port<i22>)
	cal.create_instance @innerCells_q_5 "innerCells_q_5" ()
		ports_in(%queue_to_innerCells_q_5_x_in, %queue_to_innerCells_q_5_cordic_angles_in: !fifo.output_port<i22>, !fifo.output_port<i16>)
		ports_out(%queue_from_innerCells_q_5_x_out, %queue_from_innerCells_q_5_r_out, %queue_from_innerCells_q_5_cordic_angles_out: !fifo.input_port<i22>, !fifo.input_port<i22>, !fifo.input_port<i16>)
	cal.create_instance @caps_q_3 "caps_q_3" ()
		ports_in(%queue_to_caps_q_3_In: !fifo.output_port<i22>)
	cal.create_instance @innerCells_q_2 "innerCells_q_2" ()
		ports_in(%queue_to_innerCells_q_2_x_in, %queue_to_innerCells_q_2_cordic_angles_in: !fifo.output_port<i22>, !fifo.output_port<i16>)
		ports_out(%queue_from_innerCells_q_2_x_out, %queue_from_innerCells_q_2_r_out, %queue_from_innerCells_q_2_cordic_angles_out: !fifo.input_port<i22>, !fifo.input_port<i22>, !fifo.input_port<i16>)
	cal.create_instance @caps_q_2 "caps_q_2" ()
		ports_in(%queue_to_caps_q_2_In: !fifo.output_port<i22>)
	cal.create_instance @innerCells_q_3 "innerCells_q_3" ()
		ports_in(%queue_to_innerCells_q_3_x_in, %queue_to_innerCells_q_3_cordic_angles_in: !fifo.output_port<i22>, !fifo.output_port<i16>)
		ports_out(%queue_from_innerCells_q_3_x_out, %queue_from_innerCells_q_3_r_out, %queue_from_innerCells_q_3_cordic_angles_out: !fifo.input_port<i22>, !fifo.input_port<i22>, !fifo.input_port<i16>)
	cal.create_instance @joinersPerRow_r_0 "joinersPerRow_r_0" ()
		ports_in(%queue_to_joinersPerRow_r_0_r_in_array_0_x, %queue_to_joinersPerRow_r_0_r_in_array_1_x, %queue_to_joinersPerRow_r_0_r_in_array_2_x, %queue_to_joinersPerRow_r_0_r_in_array_3_x: !fifo.output_port<i22>, !fifo.output_port<i22>, !fifo.output_port<i22>, !fifo.output_port<i22>)
		ports_out(%queue_from_joinersPerRow_r_0_r_out: !fifo.input_port<i22>)
	cal.create_instance @joinersPerRow_r_2 "joinersPerRow_r_2" ()
		ports_in(%queue_to_joinersPerRow_r_2_r_in_array_0_x, %queue_to_joinersPerRow_r_2_r_in_array_1_x: !fifo.output_port<i22>, !fifo.output_port<i22>)
		ports_out(%queue_from_joinersPerRow_r_2_r_out: !fifo.input_port<i22>)
	cal.create_instance @joinersPerRow_r_1 "joinersPerRow_r_1" ()
		ports_in(%queue_to_joinersPerRow_r_1_r_in_array_0_x, %queue_to_joinersPerRow_r_1_r_in_array_1_x, %queue_to_joinersPerRow_r_1_r_in_array_2_x: !fifo.output_port<i22>, !fifo.output_port<i22>, !fifo.output_port<i22>)
		ports_out(%queue_from_joinersPerRow_r_1_r_out: !fifo.input_port<i22>)

}

