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
	%l_matrix__number__58 = cal.create_state_var<i32> : !cal.state_ref<i32>
	%tmp_0 = arith.constant 0 : i1
	%tmp_1 = arith.extui %tmp_0 : i1 to i32
	cal.set(%l_matrix__number__58: !cal.state_ref<i32>, %tmp_1: i32)
	%l_$state = cal.create_state_var<i32> : !cal.state_ref<i32>
	%tmp_2 = arith.constant 0 : i1
	%tmp_3 = arith.extui %tmp_2 : i1 to i32
	cal.set(%l_$state: !cal.state_ref<i32>, %tmp_3: i32)
	// Generation action: $untagged0
	cal.action "$untagged0" priority=0 {
		// Input Pattern: Start
		%l_____input0______60_d1_0 = fifo.pop(%r_in_array_0_x: !fifo.output_port<i22>) : i22
		// Input Pattern: End
		// Action Local Variable Decl: Start
		%tmp_4 = memref.alloc() : memref<1xi32>
		%tmp_5 = arith.constant 0: index
		%tmp_6 = arith.extsi %l_____input0______60_d1_0 : i22 to i32
		memref.store %tmp_6, %tmp_4[%tmp_5] : memref<1xi32>
		// l_input__62_d1_0 aliased to tmp_4
		// Action Local Variable Decl: End
		// If Statement: Begin
		%tmp_7 = cal.get(%l_matrix__number__58: !cal.state_ref<i32>) : i32
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
			%tmp_14 = cal.get(%l_matrix__number__58: !cal.state_ref<i32>) : i32
			fifo.print("R%u: row 3: \00", %tmp_14) : (i32)
			// Call Statement: End
			// If Statement: Begin
			// Evaluate global variable $eval9.
			%tmp_15 = arith.constant 3 : i2
			%tmp_16 = arith.extui %tmp_15 : i2 to i32
			// Evaluate global variable $eval9 done: assigned to tmp_16 above in this context.
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
				// Evaluate global variable $eval5.
				%tmp_25 = arith.constant 1 : i1
				%tmp_26 = arith.extui %tmp_25 : i1 to i32
				// Evaluate global variable $eval5 done: assigned to tmp_26 above in this context.
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
			// Evaluate global variable $eval5.
			%tmp_37 = arith.constant 1 : i1
			%tmp_38 = arith.extui %tmp_37 : i1 to i32
			// Evaluate global variable $eval5 done: assigned to tmp_38 above in this context.
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
				%tmp_48 = memref.load %tmp_4[%tmp_46] : memref<1xi32>
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
		%tmp_50 = cal.get(%l_matrix__number__58: !cal.state_ref<i32>) : i32
		%tmp_51 = arith.constant 1 : i1
		%tmp_52 = arith.extui %tmp_51 : i1 to i32
		%tmp_53 = arith.addi %tmp_50, %tmp_52 : i32
		cal.set(%l_matrix__number__58: !cal.state_ref<i32>, %tmp_53: i32)
		// Assignment Statement: End
		// Assignment Statement: Start
		%tmp_54 = arith.constant 0 : i1
		%tmp_55 = arith.extui %tmp_54 : i1 to i32
		cal.set(%l_$state: !cal.state_ref<i32>, %tmp_55: i32)
		// Assignment Statement: End
		// Output Expression: Start
		%tmp_56 = arith.constant 0 : index
		%tmp_57 = memref.load %tmp_4[%tmp_56] : memref<1xi32>
		%tmp_58 = arith.trunci %tmp_57 : i32 to i22
		fifo.push(%r_out: !fifo.input_port<i22>, %tmp_58: i22)
		// Output Expression: End
	}
}

//-- Definition of actor class: Cap_Iterations
cal.actor @caps_cordic_3 ()
	ports_in(%In: !fifo.output_port<i16>)
{
	// -- Actor body
	%l_$state = cal.create_state_var<i32> : !cal.state_ref<i32>
	%tmp_0 = arith.constant 0 : i1
	%tmp_1 = arith.extui %tmp_0 : i1 to i32
	cal.set(%l_$state: !cal.state_ref<i32>, %tmp_1: i32)
	// Generation action: receive
	cal.action "receive" priority=0 {
		// Input Pattern: Start
		%l_t__23_d1_0 = fifo.pop(%In: !fifo.output_port<i16>) : i16
		// Input Pattern: End
		// Assignment Statement: Start
		%tmp_2 = arith.constant 0 : i1
		%tmp_3 = arith.extui %tmp_2 : i1 to i32
		cal.set(%l_$state: !cal.state_ref<i32>, %tmp_3: i32)
		// Assignment Statement: End
	}
}

//-- Definition of actor class: Cap_Iterations
cal.actor @caps_cordic_2 ()
	ports_in(%In: !fifo.output_port<i16>)
{
	// -- Actor body
	%l_$state = cal.create_state_var<i32> : !cal.state_ref<i32>
	%tmp_0 = arith.constant 0 : i1
	%tmp_1 = arith.extui %tmp_0 : i1 to i32
	cal.set(%l_$state: !cal.state_ref<i32>, %tmp_1: i32)
	// Generation action: receive
	cal.action "receive" priority=0 {
		// Input Pattern: Start
		%l_t__23_d1_0 = fifo.pop(%In: !fifo.output_port<i16>) : i16
		// Input Pattern: End
		// Assignment Statement: Start
		%tmp_2 = arith.constant 0 : i1
		%tmp_3 = arith.extui %tmp_2 : i1 to i32
		cal.set(%l_$state: !cal.state_ref<i32>, %tmp_3: i32)
		// Assignment Statement: End
	}
}

//-- Definition of actor class: Cap_Iterations
cal.actor @caps_cordic_1 ()
	ports_in(%In: !fifo.output_port<i16>)
{
	// -- Actor body
	%l_$state = cal.create_state_var<i32> : !cal.state_ref<i32>
	%tmp_0 = arith.constant 0 : i1
	%tmp_1 = arith.extui %tmp_0 : i1 to i32
	cal.set(%l_$state: !cal.state_ref<i32>, %tmp_1: i32)
	// Generation action: receive
	cal.action "receive" priority=0 {
		// Input Pattern: Start
		%l_t__23_d1_0 = fifo.pop(%In: !fifo.output_port<i16>) : i16
		// Input Pattern: End
		// Assignment Statement: Start
		%tmp_2 = arith.constant 0 : i1
		%tmp_3 = arith.extui %tmp_2 : i1 to i32
		cal.set(%l_$state: !cal.state_ref<i32>, %tmp_3: i32)
		// Assignment Statement: End
	}
}

//-- Definition of actor class: BoundaryCell
cal.actor @boundaryCells_1 ()
	ports_in(%x_in: !fifo.output_port<i22>)
	ports_out(%r_out: !fifo.input_port<i22>,%cordic_angles_out: !fifo.input_port<i16>)
{
	// -- Actor body
	%l_r__78 = cal.create_state_var<i22> : !cal.state_ref<i22>
	%tmp_0 = arith.constant 0 : i1
	%tmp_1 = arith.extui %tmp_0 : i1 to i22
	cal.set(%l_r__78: !cal.state_ref<i22>, %tmp_1: i22)
	%l_count__79 = cal.create_state_var<i32> : !cal.state_ref<i32>
	%tmp_2 = arith.constant 0 : i1
	%tmp_3 = arith.extui %tmp_2 : i1 to i32
	cal.set(%l_count__79: !cal.state_ref<i32>, %tmp_3: i32)
	%l_$state = cal.create_state_var<i32> : !cal.state_ref<i32>
	%tmp_4 = arith.constant 0 : i1
	%tmp_5 = arith.extui %tmp_4 : i1 to i32
	cal.set(%l_$state: !cal.state_ref<i32>, %tmp_5: i32)
	// Generation action: normal
	cal.action "normal" priority=0 {
		// Guard: Start
		cal.predicate {
			%tmp_6 = cal.get(%l_count__79: !cal.state_ref<i32>) : i32
			// Evaluate global variable $eval1.
			%tmp_7 = arith.constant 4 : i3
			%tmp_8 = arith.extui %tmp_7 : i3 to i32
			// Evaluate global variable $eval1 done: assigned to tmp_8 above in this context.
			%tmp_9 = arith.cmpi ult, %tmp_6, %tmp_8 : i32
			cal.predicate_result %tmp_9 : i1
		}
		// Guard: End
		// Input Pattern: Start
		%l_x__in__81_d1_0 = fifo.pop(%x_in: !fifo.output_port<i22>) : i22
		// Input Pattern: End
		// Action Local Variable Decl: Start
		%l_x__j__84_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_x__j__plus__1__85_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_x__j__shifted__86_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_y__j__87_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_y__j__plus__1__88_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_y__j__shifted__89_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%tmp_10 = arith.constant 0 : i1
		%tmp_11 = arith.extui %tmp_10 : i1 to i16
		// l_rotation__angles__83_d1_0 aliased to tmp_11
		// Action Local Variable Decl: End
		// If Statement: Begin
		%tmp_12 = cal.get(%l_count__79: !cal.state_ref<i32>) : i32
		%tmp_13 = arith.constant 0 : i1
		%tmp_14 = arith.extui %tmp_13 : i1 to i32
		%tmp_15 = arith.cmpi eq, %tmp_12, %tmp_14 : i32
		scf.if %tmp_15 {
			// Assignment Statement: Start
			%tmp_16 = arith.constant 0 : i1
			%tmp_17 = arith.extui %tmp_16 : i1 to i22
			cal.set(%l_r__78: !cal.state_ref<i22>, %tmp_17: i22)
			// Assignment Statement: End
		} else {
		}
		// If Statement: End
		// Assignment Statement: Start
		// l_x__j__84_d1_1 aliased to l_x__in__81_d1_0
		// Assignment Statement: End
		// Assignment Statement: Start
		%tmp_18 = cal.get(%l_r__78: !cal.state_ref<i22>) : i22
		// l_y__j__87_d1_1 aliased to tmp_18
		// Assignment Statement: End
		// Foreach Statement: Begin
		%tmp_19 = arith.constant 0 : i1
		%tmp_20 = arith.extui %tmp_19 : i1 to i32
		%tmp_21_lb = index.casts %tmp_20 : i32 to index
		// Evaluate global variable num_CORDIC_iterations.
		%tmp_22 = arith.constant 16 : i5
		%tmp_23 = arith.extui %tmp_22 : i5 to i32
		// Evaluate global variable num_CORDIC_iterations done: assigned to tmp_23 above in this context.
		%tmp_24 = arith.constant 1 : i1
		%tmp_25 = arith.extui %tmp_24 : i1 to i32
		%tmp_26 = arith.subi %tmp_23, %tmp_25 : i32
		%tmp_27_ub = index.casts %tmp_26 : i32 to index
		%tmp_28_step = index.constant 1
		%tmp_29_ub_plus_1 = arith.addi %tmp_27_ub, %tmp_28_step : index
		%l_rotation__angles__83_d1_1, %l_x__j__84_d1_2, %l_x__j__plus__1__85_d1_1, %l_x__j__shifted__86_d1_1, %l_y__j__87_d1_2, %l_y__j__plus__1__88_d1_1, %l_y__j__shifted__89_d1_1 = scf.for %l_j_d1_0 = %tmp_21_lb to %tmp_29_ub_plus_1 step %tmp_28_step
				iter_args(%l_rotation__angles__83_d2_0 = %tmp_11, %l_x__j__84_d2_0 = %l_x__in__81_d1_0, %l_x__j__plus__1__85_d2_0 = %l_x__j__plus__1__85_d1_0, %l_x__j__shifted__86_d2_0 = %l_x__j__shifted__86_d1_0, %l_y__j__87_d2_0 = %tmp_18, %l_y__j__plus__1__88_d2_0 = %l_y__j__plus__1__88_d1_0, %l_y__j__shifted__89_d2_0 = %l_y__j__shifted__89_d1_0) -> (i16, i22, i22, i22, i22, i22, i22) {
			%l_j_d2_0 = arith.index_cast %l_j_d1_0 : index to i32
			%l_j_d2_1 = arith.trunci %l_j_d2_0 : i32 to i8
			// Assignment Statement: Start
			%tmp_30 = arith.extui %l_j_d2_1 : i8 to i22
			%tmp_31 = arith.shrsi %l_y__j__87_d2_0, %tmp_30 : i22
			// l_y__j__shifted__89_d2_1 aliased to tmp_31
			// Assignment Statement: End
			// Assignment Statement: Start
			%tmp_32 = arith.extui %l_j_d2_1 : i8 to i22
			%tmp_33 = arith.shrsi %l_x__j__84_d2_0, %tmp_32 : i22
			// l_x__j__shifted__86_d2_1 aliased to tmp_33
			// Assignment Statement: End
			// If Statement: Begin
			%tmp_34 = arith.constant 0 : i1
			%tmp_35 = arith.extui %tmp_34 : i1 to i22
			%tmp_36 = arith.cmpi sgt, %l_x__j__84_d2_0, %tmp_35 : i22
			%tmp_37 = arith.constant 0 : i1
			%tmp_38 = arith.extui %tmp_37 : i1 to i22
			%tmp_39 = arith.cmpi sgt, %l_y__j__87_d2_0, %tmp_38 : i22
			%tmp_40 = arith.andi %tmp_36, %tmp_39 : i1
			%tmp_41 = arith.constant 0 : i1
			%tmp_42 = arith.extui %tmp_41 : i1 to i22
			%tmp_43 = arith.cmpi slt, %l_x__j__84_d2_0, %tmp_42 : i22
			%tmp_44 = arith.constant 0 : i1
			%tmp_45 = arith.extui %tmp_44 : i1 to i22
			%tmp_46 = arith.cmpi slt, %l_y__j__87_d2_0, %tmp_45 : i22
			%tmp_47 = arith.andi %tmp_43, %tmp_46 : i1
			%tmp_48 = arith.ori %tmp_40, %tmp_47 : i1
			%l_rotation__angles__83_d2_1, %l_x__j__plus__1__85_d2_1, %l_y__j__plus__1__88_d2_1 = scf.if %tmp_48 -> (i16, i22, i22) {
				// Assignment Statement: Start
				%tmp_49 = arith.extsi %l_x__j__84_d2_0 : i22 to i23
				%tmp_50 = arith.extsi %tmp_31 : i22 to i23
				%tmp_51 = arith.addi %tmp_49, %tmp_50 : i23
				%tmp_52 = arith.trunci %tmp_51 : i23 to i22
				// l_x__j__plus__1__85_d3_0 aliased to tmp_52
				// Assignment Statement: End
				// Assignment Statement: Start
				%tmp_53 = arith.subi %l_y__j__87_d2_0, %tmp_33 : i22
				// l_y__j__plus__1__88_d3_0 aliased to tmp_53
				// Assignment Statement: End
				// Assignment Statement: Start
				%tmp_54 = arith.constant 1 : i1
				%tmp_55 = arith.extui %tmp_54 : i1 to i64
				%tmp_56 = arith.extui %l_j_d2_1 : i8 to i64
				%tmp_57 = arith.shli %tmp_55, %tmp_56 : i64
				%tmp_58 = arith.extui %l_rotation__angles__83_d2_0 : i16 to i64
				%tmp_59 = arith.ori %tmp_58, %tmp_57 : i64
				%tmp_60 = arith.trunci %tmp_59 : i64 to i16
				// l_rotation__angles__83_d3_0 aliased to tmp_60
				// Assignment Statement: End
				scf.yield %tmp_60, %tmp_52, %tmp_53 : i16, i22, i22
			} else {
				// Assignment Statement: Start
				%tmp_61 = arith.subi %l_x__j__84_d2_0, %tmp_31 : i22
				// l_x__j__plus__1__85_d3_0 aliased to tmp_61
				// Assignment Statement: End
				// Assignment Statement: Start
				%tmp_62 = arith.extsi %l_y__j__87_d2_0 : i22 to i23
				%tmp_63 = arith.extsi %tmp_33 : i22 to i23
				%tmp_64 = arith.addi %tmp_62, %tmp_63 : i23
				%tmp_65 = arith.trunci %tmp_64 : i23 to i22
				// l_y__j__plus__1__88_d3_0 aliased to tmp_65
				// Assignment Statement: End
				scf.yield %l_rotation__angles__83_d2_0, %tmp_61, %tmp_65 : i16, i22, i22
			}
			// If Statement: End
			// Assignment Statement: Start
			// l_x__j__84_d2_1 aliased to l_x__j__plus__1__85_d2_1
			// Assignment Statement: End
			// Assignment Statement: Start
			// l_y__j__87_d2_1 aliased to l_y__j__plus__1__88_d2_1
			// Assignment Statement: End
			scf.yield %l_rotation__angles__83_d2_1, %l_x__j__plus__1__85_d2_1, %l_x__j__plus__1__85_d2_1, %tmp_33, %l_y__j__plus__1__88_d2_1, %l_y__j__plus__1__88_d2_1, %tmp_31 : i16, i22, i22, i22, i22, i22, i22
		}
		// Foreach Statement: End
		// Assignment Statement: Start
		// Evaluate global variable k_CORDIC_constant.
		%tmp_67 = arith.constant 318375 : i19
		%tmp_68 = arith.extui %tmp_67 : i19 to i22
		// Evaluate global variable k_CORDIC_constant done: assigned to tmp_68 above in this context.
		// Evaluate global variable fixedPointMultiply.
		%tmp_66 = func.call @g_qrd_fixedPointMultiply(%l_x__j__84_d1_2,%tmp_68) : (i22,i22) -> i22
		cal.set(%l_r__78: !cal.state_ref<i22>, %tmp_66: i22)
		// Assignment Statement: End
		// Assignment Statement: Start
		%tmp_69 = cal.get(%l_count__79: !cal.state_ref<i32>) : i32
		%tmp_70 = arith.constant 1 : i1
		%tmp_71 = arith.extui %tmp_70 : i1 to i32
		%tmp_72 = arith.addi %tmp_69, %tmp_71 : i32
		cal.set(%l_count__79: !cal.state_ref<i32>, %tmp_72: i32)
		// Assignment Statement: End
		// Assignment Statement: Start
		%tmp_73 = arith.constant 0 : i1
		%tmp_74 = arith.extui %tmp_73 : i1 to i32
		cal.set(%l_$state: !cal.state_ref<i32>, %tmp_74: i32)
		// Assignment Statement: End
		// Output Expression: Start
		fifo.push(%cordic_angles_out: !fifo.input_port<i16>, %l_rotation__angles__83_d1_1: i16)
		// Output Expression: End
	}
	// Generation action: final
	cal.action "final" priority=0 {
		// Guard: Start
		cal.predicate {
			%tmp_75 = cal.get(%l_count__79: !cal.state_ref<i32>) : i32
			// Evaluate global variable $eval1.
			%tmp_76 = arith.constant 4 : i3
			%tmp_77 = arith.extui %tmp_76 : i3 to i32
			// Evaluate global variable $eval1 done: assigned to tmp_77 above in this context.
			%tmp_78 = arith.cmpi eq, %tmp_75, %tmp_77 : i32
			cal.predicate_result %tmp_78 : i1
		}
		// Guard: End
		// Assignment Statement: Start
		%tmp_79 = arith.constant 0 : i1
		%tmp_80 = arith.extui %tmp_79 : i1 to i32
		cal.set(%l_count__79: !cal.state_ref<i32>, %tmp_80: i32)
		// Assignment Statement: End
		// Assignment Statement: Start
		%tmp_81 = arith.constant 0 : i1
		%tmp_82 = arith.extui %tmp_81 : i1 to i32
		cal.set(%l_$state: !cal.state_ref<i32>, %tmp_82: i32)
		// Assignment Statement: End
		// Output Expression: Start
		%tmp_83 = cal.get(%l_r__78: !cal.state_ref<i22>) : i22
		fifo.push(%r_out: !fifo.input_port<i22>, %tmp_83: i22)
		// Output Expression: End
	}
}

//-- Definition of actor class: Cap_Iterations
cal.actor @caps_cordic_0 ()
	ports_in(%In: !fifo.output_port<i16>)
{
	// -- Actor body
	%l_$state = cal.create_state_var<i32> : !cal.state_ref<i32>
	%tmp_0 = arith.constant 0 : i1
	%tmp_1 = arith.extui %tmp_0 : i1 to i32
	cal.set(%l_$state: !cal.state_ref<i32>, %tmp_1: i32)
	// Generation action: receive
	cal.action "receive" priority=0 {
		// Input Pattern: Start
		%l_t__23_d1_0 = fifo.pop(%In: !fifo.output_port<i16>) : i16
		// Input Pattern: End
		// Assignment Statement: Start
		%tmp_2 = arith.constant 0 : i1
		%tmp_3 = arith.extui %tmp_2 : i1 to i32
		cal.set(%l_$state: !cal.state_ref<i32>, %tmp_3: i32)
		// Assignment Statement: End
	}
}

//-- Definition of actor class: InnerCell
cal.actor @innerCells_q_0 ()
	ports_in(%x_in: !fifo.output_port<i22>,%cordic_angles_in: !fifo.output_port<i16>)
	ports_out(%x_out: !fifo.input_port<i22>,%r_out: !fifo.input_port<i22>,%cordic_angles_out: !fifo.input_port<i16>)
{
	// -- Actor body
	%l_r__63 = cal.create_state_var<i22> : !cal.state_ref<i22>
	%tmp_0 = arith.constant 0 : i1
	%tmp_1 = arith.extui %tmp_0 : i1 to i22
	cal.set(%l_r__63: !cal.state_ref<i22>, %tmp_1: i22)
	%l_count__64 = cal.create_state_var<i32> : !cal.state_ref<i32>
	%tmp_2 = arith.constant 0 : i1
	%tmp_3 = arith.extui %tmp_2 : i1 to i32
	cal.set(%l_count__64: !cal.state_ref<i32>, %tmp_3: i32)
	%l_$state = cal.create_state_var<i32> : !cal.state_ref<i32>
	%tmp_4 = arith.constant 0 : i1
	%tmp_5 = arith.extui %tmp_4 : i1 to i32
	cal.set(%l_$state: !cal.state_ref<i32>, %tmp_5: i32)
	// Generation action: normal
	cal.action "normal" priority=0 {
		// Guard: Start
		cal.predicate {
			%tmp_6 = cal.get(%l_count__64: !cal.state_ref<i32>) : i32
			// Evaluate global variable $eval1.
			%tmp_7 = arith.constant 4 : i3
			%tmp_8 = arith.extui %tmp_7 : i3 to i32
			// Evaluate global variable $eval1 done: assigned to tmp_8 above in this context.
			%tmp_9 = arith.cmpi ult, %tmp_6, %tmp_8 : i32
			cal.predicate_result %tmp_9 : i1
		}
		// Guard: End
		// Input Pattern: Start
		%l_x__in__66_d1_0 = fifo.pop(%x_in: !fifo.output_port<i22>) : i22
		// Input Pattern: End
		// Input Pattern: Start
		%l_rotation__angles__69_d1_0 = fifo.pop(%cordic_angles_in: !fifo.output_port<i16>) : i16
		// Input Pattern: End
		// Action Local Variable Decl: Start
		%l_x__out__71_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_x__j__72_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_x__j__plus__1__73_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_x__j__shifted__74_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_y__j__75_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_y__j__plus__1__76_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_y__j__shifted__77_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// If Statement: Begin
		%tmp_10 = cal.get(%l_count__64: !cal.state_ref<i32>) : i32
		%tmp_11 = arith.constant 0 : i1
		%tmp_12 = arith.extui %tmp_11 : i1 to i32
		%tmp_13 = arith.cmpi eq, %tmp_10, %tmp_12 : i32
		scf.if %tmp_13 {
			// Assignment Statement: Start
			%tmp_14 = arith.constant 0 : i1
			%tmp_15 = arith.extui %tmp_14 : i1 to i22
			cal.set(%l_r__63: !cal.state_ref<i22>, %tmp_15: i22)
			// Assignment Statement: End
		} else {
		}
		// If Statement: End
		// Assignment Statement: Start
		// l_x__j__72_d1_1 aliased to l_x__in__66_d1_0
		// Assignment Statement: End
		// Assignment Statement: Start
		%tmp_16 = cal.get(%l_r__63: !cal.state_ref<i22>) : i22
		// l_y__j__75_d1_1 aliased to tmp_16
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
		%l_x__j__72_d1_2, %l_x__j__plus__1__73_d1_1, %l_x__j__shifted__74_d1_1, %l_y__j__75_d1_2, %l_y__j__plus__1__76_d1_1, %l_y__j__shifted__77_d1_1 = scf.for %l_j_d1_0 = %tmp_19_lb to %tmp_27_ub_plus_1 step %tmp_26_step
				iter_args(%l_x__j__72_d2_0 = %l_x__in__66_d1_0, %l_x__j__plus__1__73_d2_0 = %l_x__j__plus__1__73_d1_0, %l_x__j__shifted__74_d2_0 = %l_x__j__shifted__74_d1_0, %l_y__j__75_d2_0 = %tmp_16, %l_y__j__plus__1__76_d2_0 = %l_y__j__plus__1__76_d1_0, %l_y__j__shifted__77_d2_0 = %l_y__j__shifted__77_d1_0) -> (i22, i22, i22, i22, i22, i22) {
			%l_j_d2_0 = arith.index_cast %l_j_d1_0 : index to i32
			%l_j_d2_1 = arith.trunci %l_j_d2_0 : i32 to i8
			// Assignment Statement: Start
			%tmp_28 = arith.extui %l_j_d2_1 : i8 to i22
			%tmp_29 = arith.shrsi %l_y__j__75_d2_0, %tmp_28 : i22
			// l_y__j__shifted__77_d2_1 aliased to tmp_29
			// Assignment Statement: End
			// Assignment Statement: Start
			%tmp_30 = arith.extui %l_j_d2_1 : i8 to i22
			%tmp_31 = arith.shrsi %l_x__j__72_d2_0, %tmp_30 : i22
			// l_x__j__shifted__74_d2_1 aliased to tmp_31
			// Assignment Statement: End
			// If Statement: Begin
			%tmp_32 = arith.extui %l_j_d2_1 : i8 to i16
			%tmp_33 = arith.shrui %l_rotation__angles__69_d1_0, %tmp_32 : i16
			%tmp_34 = arith.constant 1 : i1
			%tmp_35 = arith.trunci %tmp_33 : i16 to i1
			%tmp_36 = arith.andi %tmp_35, %tmp_34 : i1
			%tmp_37 = arith.constant 1 : i1
			%tmp_38 = arith.cmpi eq, %tmp_36, %tmp_37 : i1
			%l_x__j__plus__1__73_d2_1, %l_y__j__plus__1__76_d2_1 = scf.if %tmp_38 -> (i22, i22) {
				// Assignment Statement: Start
				%tmp_39 = arith.extsi %l_x__j__72_d2_0 : i22 to i23
				%tmp_40 = arith.extsi %tmp_29 : i22 to i23
				%tmp_41 = arith.addi %tmp_39, %tmp_40 : i23
				%tmp_42 = arith.trunci %tmp_41 : i23 to i22
				// l_x__j__plus__1__73_d3_0 aliased to tmp_42
				// Assignment Statement: End
				// Assignment Statement: Start
				%tmp_43 = arith.subi %l_y__j__75_d2_0, %tmp_31 : i22
				// l_y__j__plus__1__76_d3_0 aliased to tmp_43
				// Assignment Statement: End
				scf.yield %tmp_42, %tmp_43 : i22, i22
			} else {
				// Assignment Statement: Start
				%tmp_44 = arith.subi %l_x__j__72_d2_0, %tmp_29 : i22
				// l_x__j__plus__1__73_d3_0 aliased to tmp_44
				// Assignment Statement: End
				// Assignment Statement: Start
				%tmp_45 = arith.extsi %l_y__j__75_d2_0 : i22 to i23
				%tmp_46 = arith.extsi %tmp_31 : i22 to i23
				%tmp_47 = arith.addi %tmp_45, %tmp_46 : i23
				%tmp_48 = arith.trunci %tmp_47 : i23 to i22
				// l_y__j__plus__1__76_d3_0 aliased to tmp_48
				// Assignment Statement: End
				scf.yield %tmp_44, %tmp_48 : i22, i22
			}
			// If Statement: End
			// Assignment Statement: Start
			// l_x__j__72_d2_1 aliased to l_x__j__plus__1__73_d2_1
			// Assignment Statement: End
			// Assignment Statement: Start
			// l_y__j__75_d2_1 aliased to l_y__j__plus__1__76_d2_1
			// Assignment Statement: End
			scf.yield %l_x__j__plus__1__73_d2_1, %l_x__j__plus__1__73_d2_1, %tmp_31, %l_y__j__plus__1__76_d2_1, %l_y__j__plus__1__76_d2_1, %tmp_29 : i22, i22, i22, i22, i22, i22
		}
		// Foreach Statement: End
		// Assignment Statement: Start
		// Evaluate global variable k_CORDIC_constant.
		%tmp_50 = arith.constant 318375 : i19
		%tmp_51 = arith.extui %tmp_50 : i19 to i22
		// Evaluate global variable k_CORDIC_constant done: assigned to tmp_51 above in this context.
		// Evaluate global variable fixedPointMultiply.
		%tmp_49 = func.call @g_qrd_fixedPointMultiply(%tmp_51,%l_y__j__75_d1_2) : (i22,i22) -> i22
		// l_x__out__71_d1_1 aliased to tmp_49
		// Assignment Statement: End
		// Assignment Statement: Start
		// Evaluate global variable k_CORDIC_constant.
		%tmp_53 = arith.constant 318375 : i19
		%tmp_54 = arith.extui %tmp_53 : i19 to i22
		// Evaluate global variable k_CORDIC_constant done: assigned to tmp_54 above in this context.
		// Evaluate global variable fixedPointMultiply.
		%tmp_52 = func.call @g_qrd_fixedPointMultiply(%tmp_54,%l_x__j__72_d1_2) : (i22,i22) -> i22
		cal.set(%l_r__63: !cal.state_ref<i22>, %tmp_52: i22)
		// Assignment Statement: End
		// Assignment Statement: Start
		%tmp_55 = cal.get(%l_count__64: !cal.state_ref<i32>) : i32
		%tmp_56 = arith.constant 1 : i1
		%tmp_57 = arith.extui %tmp_56 : i1 to i32
		%tmp_58 = arith.addi %tmp_55, %tmp_57 : i32
		cal.set(%l_count__64: !cal.state_ref<i32>, %tmp_58: i32)
		// Assignment Statement: End
		// Assignment Statement: Start
		%tmp_59 = arith.constant 0 : i1
		%tmp_60 = arith.extui %tmp_59 : i1 to i32
		cal.set(%l_$state: !cal.state_ref<i32>, %tmp_60: i32)
		// Assignment Statement: End
		// Output Expression: Start
		fifo.push(%x_out: !fifo.input_port<i22>, %tmp_49: i22)
		// Output Expression: End
		// Output Expression: Start
		fifo.push(%cordic_angles_out: !fifo.input_port<i16>, %l_rotation__angles__69_d1_0: i16)
		// Output Expression: End
	}
	// Generation action: final
	cal.action "final" priority=0 {
		// Guard: Start
		cal.predicate {
			%tmp_61 = cal.get(%l_count__64: !cal.state_ref<i32>) : i32
			// Evaluate global variable $eval1.
			%tmp_62 = arith.constant 4 : i3
			%tmp_63 = arith.extui %tmp_62 : i3 to i32
			// Evaluate global variable $eval1 done: assigned to tmp_63 above in this context.
			%tmp_64 = arith.cmpi eq, %tmp_61, %tmp_63 : i32
			cal.predicate_result %tmp_64 : i1
		}
		// Guard: End
		// Assignment Statement: Start
		%tmp_65 = arith.constant 0 : i1
		%tmp_66 = arith.extui %tmp_65 : i1 to i32
		cal.set(%l_count__64: !cal.state_ref<i32>, %tmp_66: i32)
		// Assignment Statement: End
		// Assignment Statement: Start
		%tmp_67 = arith.constant 0 : i1
		%tmp_68 = arith.extui %tmp_67 : i1 to i32
		cal.set(%l_$state: !cal.state_ref<i32>, %tmp_68: i32)
		// Assignment Statement: End
		// Output Expression: Start
		%tmp_69 = cal.get(%l_r__63: !cal.state_ref<i22>) : i22
		fifo.push(%r_out: !fifo.input_port<i22>, %tmp_69: i22)
		// Output Expression: End
	}
}

//-- Definition of actor class: BoundaryCell
cal.actor @boundaryCells_0 ()
	ports_in(%x_in: !fifo.output_port<i22>)
	ports_out(%r_out: !fifo.input_port<i22>,%cordic_angles_out: !fifo.input_port<i16>)
{
	// -- Actor body
	%l_r__78 = cal.create_state_var<i22> : !cal.state_ref<i22>
	%tmp_0 = arith.constant 0 : i1
	%tmp_1 = arith.extui %tmp_0 : i1 to i22
	cal.set(%l_r__78: !cal.state_ref<i22>, %tmp_1: i22)
	%l_count__79 = cal.create_state_var<i32> : !cal.state_ref<i32>
	%tmp_2 = arith.constant 0 : i1
	%tmp_3 = arith.extui %tmp_2 : i1 to i32
	cal.set(%l_count__79: !cal.state_ref<i32>, %tmp_3: i32)
	%l_$state = cal.create_state_var<i32> : !cal.state_ref<i32>
	%tmp_4 = arith.constant 0 : i1
	%tmp_5 = arith.extui %tmp_4 : i1 to i32
	cal.set(%l_$state: !cal.state_ref<i32>, %tmp_5: i32)
	// Generation action: normal
	cal.action "normal" priority=0 {
		// Guard: Start
		cal.predicate {
			%tmp_6 = cal.get(%l_count__79: !cal.state_ref<i32>) : i32
			// Evaluate global variable $eval1.
			%tmp_7 = arith.constant 4 : i3
			%tmp_8 = arith.extui %tmp_7 : i3 to i32
			// Evaluate global variable $eval1 done: assigned to tmp_8 above in this context.
			%tmp_9 = arith.cmpi ult, %tmp_6, %tmp_8 : i32
			cal.predicate_result %tmp_9 : i1
		}
		// Guard: End
		// Input Pattern: Start
		%l_x__in__81_d1_0 = fifo.pop(%x_in: !fifo.output_port<i22>) : i22
		// Input Pattern: End
		// Action Local Variable Decl: Start
		%l_x__j__84_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_x__j__plus__1__85_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_x__j__shifted__86_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_y__j__87_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_y__j__plus__1__88_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_y__j__shifted__89_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%tmp_10 = arith.constant 0 : i1
		%tmp_11 = arith.extui %tmp_10 : i1 to i16
		// l_rotation__angles__83_d1_0 aliased to tmp_11
		// Action Local Variable Decl: End
		// If Statement: Begin
		%tmp_12 = cal.get(%l_count__79: !cal.state_ref<i32>) : i32
		%tmp_13 = arith.constant 0 : i1
		%tmp_14 = arith.extui %tmp_13 : i1 to i32
		%tmp_15 = arith.cmpi eq, %tmp_12, %tmp_14 : i32
		scf.if %tmp_15 {
			// Assignment Statement: Start
			%tmp_16 = arith.constant 0 : i1
			%tmp_17 = arith.extui %tmp_16 : i1 to i22
			cal.set(%l_r__78: !cal.state_ref<i22>, %tmp_17: i22)
			// Assignment Statement: End
		} else {
		}
		// If Statement: End
		// Assignment Statement: Start
		// l_x__j__84_d1_1 aliased to l_x__in__81_d1_0
		// Assignment Statement: End
		// Assignment Statement: Start
		%tmp_18 = cal.get(%l_r__78: !cal.state_ref<i22>) : i22
		// l_y__j__87_d1_1 aliased to tmp_18
		// Assignment Statement: End
		// Foreach Statement: Begin
		%tmp_19 = arith.constant 0 : i1
		%tmp_20 = arith.extui %tmp_19 : i1 to i32
		%tmp_21_lb = index.casts %tmp_20 : i32 to index
		// Evaluate global variable num_CORDIC_iterations.
		%tmp_22 = arith.constant 16 : i5
		%tmp_23 = arith.extui %tmp_22 : i5 to i32
		// Evaluate global variable num_CORDIC_iterations done: assigned to tmp_23 above in this context.
		%tmp_24 = arith.constant 1 : i1
		%tmp_25 = arith.extui %tmp_24 : i1 to i32
		%tmp_26 = arith.subi %tmp_23, %tmp_25 : i32
		%tmp_27_ub = index.casts %tmp_26 : i32 to index
		%tmp_28_step = index.constant 1
		%tmp_29_ub_plus_1 = arith.addi %tmp_27_ub, %tmp_28_step : index
		%l_rotation__angles__83_d1_1, %l_x__j__84_d1_2, %l_x__j__plus__1__85_d1_1, %l_x__j__shifted__86_d1_1, %l_y__j__87_d1_2, %l_y__j__plus__1__88_d1_1, %l_y__j__shifted__89_d1_1 = scf.for %l_j_d1_0 = %tmp_21_lb to %tmp_29_ub_plus_1 step %tmp_28_step
				iter_args(%l_rotation__angles__83_d2_0 = %tmp_11, %l_x__j__84_d2_0 = %l_x__in__81_d1_0, %l_x__j__plus__1__85_d2_0 = %l_x__j__plus__1__85_d1_0, %l_x__j__shifted__86_d2_0 = %l_x__j__shifted__86_d1_0, %l_y__j__87_d2_0 = %tmp_18, %l_y__j__plus__1__88_d2_0 = %l_y__j__plus__1__88_d1_0, %l_y__j__shifted__89_d2_0 = %l_y__j__shifted__89_d1_0) -> (i16, i22, i22, i22, i22, i22, i22) {
			%l_j_d2_0 = arith.index_cast %l_j_d1_0 : index to i32
			%l_j_d2_1 = arith.trunci %l_j_d2_0 : i32 to i8
			// Assignment Statement: Start
			%tmp_30 = arith.extui %l_j_d2_1 : i8 to i22
			%tmp_31 = arith.shrsi %l_y__j__87_d2_0, %tmp_30 : i22
			// l_y__j__shifted__89_d2_1 aliased to tmp_31
			// Assignment Statement: End
			// Assignment Statement: Start
			%tmp_32 = arith.extui %l_j_d2_1 : i8 to i22
			%tmp_33 = arith.shrsi %l_x__j__84_d2_0, %tmp_32 : i22
			// l_x__j__shifted__86_d2_1 aliased to tmp_33
			// Assignment Statement: End
			// If Statement: Begin
			%tmp_34 = arith.constant 0 : i1
			%tmp_35 = arith.extui %tmp_34 : i1 to i22
			%tmp_36 = arith.cmpi sgt, %l_x__j__84_d2_0, %tmp_35 : i22
			%tmp_37 = arith.constant 0 : i1
			%tmp_38 = arith.extui %tmp_37 : i1 to i22
			%tmp_39 = arith.cmpi sgt, %l_y__j__87_d2_0, %tmp_38 : i22
			%tmp_40 = arith.andi %tmp_36, %tmp_39 : i1
			%tmp_41 = arith.constant 0 : i1
			%tmp_42 = arith.extui %tmp_41 : i1 to i22
			%tmp_43 = arith.cmpi slt, %l_x__j__84_d2_0, %tmp_42 : i22
			%tmp_44 = arith.constant 0 : i1
			%tmp_45 = arith.extui %tmp_44 : i1 to i22
			%tmp_46 = arith.cmpi slt, %l_y__j__87_d2_0, %tmp_45 : i22
			%tmp_47 = arith.andi %tmp_43, %tmp_46 : i1
			%tmp_48 = arith.ori %tmp_40, %tmp_47 : i1
			%l_rotation__angles__83_d2_1, %l_x__j__plus__1__85_d2_1, %l_y__j__plus__1__88_d2_1 = scf.if %tmp_48 -> (i16, i22, i22) {
				// Assignment Statement: Start
				%tmp_49 = arith.extsi %l_x__j__84_d2_0 : i22 to i23
				%tmp_50 = arith.extsi %tmp_31 : i22 to i23
				%tmp_51 = arith.addi %tmp_49, %tmp_50 : i23
				%tmp_52 = arith.trunci %tmp_51 : i23 to i22
				// l_x__j__plus__1__85_d3_0 aliased to tmp_52
				// Assignment Statement: End
				// Assignment Statement: Start
				%tmp_53 = arith.subi %l_y__j__87_d2_0, %tmp_33 : i22
				// l_y__j__plus__1__88_d3_0 aliased to tmp_53
				// Assignment Statement: End
				// Assignment Statement: Start
				%tmp_54 = arith.constant 1 : i1
				%tmp_55 = arith.extui %tmp_54 : i1 to i64
				%tmp_56 = arith.extui %l_j_d2_1 : i8 to i64
				%tmp_57 = arith.shli %tmp_55, %tmp_56 : i64
				%tmp_58 = arith.extui %l_rotation__angles__83_d2_0 : i16 to i64
				%tmp_59 = arith.ori %tmp_58, %tmp_57 : i64
				%tmp_60 = arith.trunci %tmp_59 : i64 to i16
				// l_rotation__angles__83_d3_0 aliased to tmp_60
				// Assignment Statement: End
				scf.yield %tmp_60, %tmp_52, %tmp_53 : i16, i22, i22
			} else {
				// Assignment Statement: Start
				%tmp_61 = arith.subi %l_x__j__84_d2_0, %tmp_31 : i22
				// l_x__j__plus__1__85_d3_0 aliased to tmp_61
				// Assignment Statement: End
				// Assignment Statement: Start
				%tmp_62 = arith.extsi %l_y__j__87_d2_0 : i22 to i23
				%tmp_63 = arith.extsi %tmp_33 : i22 to i23
				%tmp_64 = arith.addi %tmp_62, %tmp_63 : i23
				%tmp_65 = arith.trunci %tmp_64 : i23 to i22
				// l_y__j__plus__1__88_d3_0 aliased to tmp_65
				// Assignment Statement: End
				scf.yield %l_rotation__angles__83_d2_0, %tmp_61, %tmp_65 : i16, i22, i22
			}
			// If Statement: End
			// Assignment Statement: Start
			// l_x__j__84_d2_1 aliased to l_x__j__plus__1__85_d2_1
			// Assignment Statement: End
			// Assignment Statement: Start
			// l_y__j__87_d2_1 aliased to l_y__j__plus__1__88_d2_1
			// Assignment Statement: End
			scf.yield %l_rotation__angles__83_d2_1, %l_x__j__plus__1__85_d2_1, %l_x__j__plus__1__85_d2_1, %tmp_33, %l_y__j__plus__1__88_d2_1, %l_y__j__plus__1__88_d2_1, %tmp_31 : i16, i22, i22, i22, i22, i22, i22
		}
		// Foreach Statement: End
		// Assignment Statement: Start
		// Evaluate global variable k_CORDIC_constant.
		%tmp_67 = arith.constant 318375 : i19
		%tmp_68 = arith.extui %tmp_67 : i19 to i22
		// Evaluate global variable k_CORDIC_constant done: assigned to tmp_68 above in this context.
		// Evaluate global variable fixedPointMultiply.
		%tmp_66 = func.call @g_qrd_fixedPointMultiply(%l_x__j__84_d1_2,%tmp_68) : (i22,i22) -> i22
		cal.set(%l_r__78: !cal.state_ref<i22>, %tmp_66: i22)
		// Assignment Statement: End
		// Assignment Statement: Start
		%tmp_69 = cal.get(%l_count__79: !cal.state_ref<i32>) : i32
		%tmp_70 = arith.constant 1 : i1
		%tmp_71 = arith.extui %tmp_70 : i1 to i32
		%tmp_72 = arith.addi %tmp_69, %tmp_71 : i32
		cal.set(%l_count__79: !cal.state_ref<i32>, %tmp_72: i32)
		// Assignment Statement: End
		// Assignment Statement: Start
		%tmp_73 = arith.constant 0 : i1
		%tmp_74 = arith.extui %tmp_73 : i1 to i32
		cal.set(%l_$state: !cal.state_ref<i32>, %tmp_74: i32)
		// Assignment Statement: End
		// Output Expression: Start
		fifo.push(%cordic_angles_out: !fifo.input_port<i16>, %l_rotation__angles__83_d1_1: i16)
		// Output Expression: End
	}
	// Generation action: final
	cal.action "final" priority=0 {
		// Guard: Start
		cal.predicate {
			%tmp_75 = cal.get(%l_count__79: !cal.state_ref<i32>) : i32
			// Evaluate global variable $eval1.
			%tmp_76 = arith.constant 4 : i3
			%tmp_77 = arith.extui %tmp_76 : i3 to i32
			// Evaluate global variable $eval1 done: assigned to tmp_77 above in this context.
			%tmp_78 = arith.cmpi eq, %tmp_75, %tmp_77 : i32
			cal.predicate_result %tmp_78 : i1
		}
		// Guard: End
		// Assignment Statement: Start
		%tmp_79 = arith.constant 0 : i1
		%tmp_80 = arith.extui %tmp_79 : i1 to i32
		cal.set(%l_count__79: !cal.state_ref<i32>, %tmp_80: i32)
		// Assignment Statement: End
		// Assignment Statement: Start
		%tmp_81 = arith.constant 0 : i1
		%tmp_82 = arith.extui %tmp_81 : i1 to i32
		cal.set(%l_$state: !cal.state_ref<i32>, %tmp_82: i32)
		// Assignment Statement: End
		// Output Expression: Start
		%tmp_83 = cal.get(%l_r__78: !cal.state_ref<i22>) : i22
		fifo.push(%r_out: !fifo.input_port<i22>, %tmp_83: i22)
		// Output Expression: End
	}
}

//-- Definition of actor class: InnerCell
cal.actor @innerCells_q_1 ()
	ports_in(%x_in: !fifo.output_port<i22>,%cordic_angles_in: !fifo.output_port<i16>)
	ports_out(%x_out: !fifo.input_port<i22>,%r_out: !fifo.input_port<i22>,%cordic_angles_out: !fifo.input_port<i16>)
{
	// -- Actor body
	%l_r__63 = cal.create_state_var<i22> : !cal.state_ref<i22>
	%tmp_0 = arith.constant 0 : i1
	%tmp_1 = arith.extui %tmp_0 : i1 to i22
	cal.set(%l_r__63: !cal.state_ref<i22>, %tmp_1: i22)
	%l_count__64 = cal.create_state_var<i32> : !cal.state_ref<i32>
	%tmp_2 = arith.constant 0 : i1
	%tmp_3 = arith.extui %tmp_2 : i1 to i32
	cal.set(%l_count__64: !cal.state_ref<i32>, %tmp_3: i32)
	%l_$state = cal.create_state_var<i32> : !cal.state_ref<i32>
	%tmp_4 = arith.constant 0 : i1
	%tmp_5 = arith.extui %tmp_4 : i1 to i32
	cal.set(%l_$state: !cal.state_ref<i32>, %tmp_5: i32)
	// Generation action: normal
	cal.action "normal" priority=0 {
		// Guard: Start
		cal.predicate {
			%tmp_6 = cal.get(%l_count__64: !cal.state_ref<i32>) : i32
			// Evaluate global variable $eval1.
			%tmp_7 = arith.constant 4 : i3
			%tmp_8 = arith.extui %tmp_7 : i3 to i32
			// Evaluate global variable $eval1 done: assigned to tmp_8 above in this context.
			%tmp_9 = arith.cmpi ult, %tmp_6, %tmp_8 : i32
			cal.predicate_result %tmp_9 : i1
		}
		// Guard: End
		// Input Pattern: Start
		%l_x__in__66_d1_0 = fifo.pop(%x_in: !fifo.output_port<i22>) : i22
		// Input Pattern: End
		// Input Pattern: Start
		%l_rotation__angles__69_d1_0 = fifo.pop(%cordic_angles_in: !fifo.output_port<i16>) : i16
		// Input Pattern: End
		// Action Local Variable Decl: Start
		%l_x__out__71_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_x__j__72_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_x__j__plus__1__73_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_x__j__shifted__74_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_y__j__75_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_y__j__plus__1__76_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_y__j__shifted__77_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// If Statement: Begin
		%tmp_10 = cal.get(%l_count__64: !cal.state_ref<i32>) : i32
		%tmp_11 = arith.constant 0 : i1
		%tmp_12 = arith.extui %tmp_11 : i1 to i32
		%tmp_13 = arith.cmpi eq, %tmp_10, %tmp_12 : i32
		scf.if %tmp_13 {
			// Assignment Statement: Start
			%tmp_14 = arith.constant 0 : i1
			%tmp_15 = arith.extui %tmp_14 : i1 to i22
			cal.set(%l_r__63: !cal.state_ref<i22>, %tmp_15: i22)
			// Assignment Statement: End
		} else {
		}
		// If Statement: End
		// Assignment Statement: Start
		// l_x__j__72_d1_1 aliased to l_x__in__66_d1_0
		// Assignment Statement: End
		// Assignment Statement: Start
		%tmp_16 = cal.get(%l_r__63: !cal.state_ref<i22>) : i22
		// l_y__j__75_d1_1 aliased to tmp_16
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
		%l_x__j__72_d1_2, %l_x__j__plus__1__73_d1_1, %l_x__j__shifted__74_d1_1, %l_y__j__75_d1_2, %l_y__j__plus__1__76_d1_1, %l_y__j__shifted__77_d1_1 = scf.for %l_j_d1_0 = %tmp_19_lb to %tmp_27_ub_plus_1 step %tmp_26_step
				iter_args(%l_x__j__72_d2_0 = %l_x__in__66_d1_0, %l_x__j__plus__1__73_d2_0 = %l_x__j__plus__1__73_d1_0, %l_x__j__shifted__74_d2_0 = %l_x__j__shifted__74_d1_0, %l_y__j__75_d2_0 = %tmp_16, %l_y__j__plus__1__76_d2_0 = %l_y__j__plus__1__76_d1_0, %l_y__j__shifted__77_d2_0 = %l_y__j__shifted__77_d1_0) -> (i22, i22, i22, i22, i22, i22) {
			%l_j_d2_0 = arith.index_cast %l_j_d1_0 : index to i32
			%l_j_d2_1 = arith.trunci %l_j_d2_0 : i32 to i8
			// Assignment Statement: Start
			%tmp_28 = arith.extui %l_j_d2_1 : i8 to i22
			%tmp_29 = arith.shrsi %l_y__j__75_d2_0, %tmp_28 : i22
			// l_y__j__shifted__77_d2_1 aliased to tmp_29
			// Assignment Statement: End
			// Assignment Statement: Start
			%tmp_30 = arith.extui %l_j_d2_1 : i8 to i22
			%tmp_31 = arith.shrsi %l_x__j__72_d2_0, %tmp_30 : i22
			// l_x__j__shifted__74_d2_1 aliased to tmp_31
			// Assignment Statement: End
			// If Statement: Begin
			%tmp_32 = arith.extui %l_j_d2_1 : i8 to i16
			%tmp_33 = arith.shrui %l_rotation__angles__69_d1_0, %tmp_32 : i16
			%tmp_34 = arith.constant 1 : i1
			%tmp_35 = arith.trunci %tmp_33 : i16 to i1
			%tmp_36 = arith.andi %tmp_35, %tmp_34 : i1
			%tmp_37 = arith.constant 1 : i1
			%tmp_38 = arith.cmpi eq, %tmp_36, %tmp_37 : i1
			%l_x__j__plus__1__73_d2_1, %l_y__j__plus__1__76_d2_1 = scf.if %tmp_38 -> (i22, i22) {
				// Assignment Statement: Start
				%tmp_39 = arith.extsi %l_x__j__72_d2_0 : i22 to i23
				%tmp_40 = arith.extsi %tmp_29 : i22 to i23
				%tmp_41 = arith.addi %tmp_39, %tmp_40 : i23
				%tmp_42 = arith.trunci %tmp_41 : i23 to i22
				// l_x__j__plus__1__73_d3_0 aliased to tmp_42
				// Assignment Statement: End
				// Assignment Statement: Start
				%tmp_43 = arith.subi %l_y__j__75_d2_0, %tmp_31 : i22
				// l_y__j__plus__1__76_d3_0 aliased to tmp_43
				// Assignment Statement: End
				scf.yield %tmp_42, %tmp_43 : i22, i22
			} else {
				// Assignment Statement: Start
				%tmp_44 = arith.subi %l_x__j__72_d2_0, %tmp_29 : i22
				// l_x__j__plus__1__73_d3_0 aliased to tmp_44
				// Assignment Statement: End
				// Assignment Statement: Start
				%tmp_45 = arith.extsi %l_y__j__75_d2_0 : i22 to i23
				%tmp_46 = arith.extsi %tmp_31 : i22 to i23
				%tmp_47 = arith.addi %tmp_45, %tmp_46 : i23
				%tmp_48 = arith.trunci %tmp_47 : i23 to i22
				// l_y__j__plus__1__76_d3_0 aliased to tmp_48
				// Assignment Statement: End
				scf.yield %tmp_44, %tmp_48 : i22, i22
			}
			// If Statement: End
			// Assignment Statement: Start
			// l_x__j__72_d2_1 aliased to l_x__j__plus__1__73_d2_1
			// Assignment Statement: End
			// Assignment Statement: Start
			// l_y__j__75_d2_1 aliased to l_y__j__plus__1__76_d2_1
			// Assignment Statement: End
			scf.yield %l_x__j__plus__1__73_d2_1, %l_x__j__plus__1__73_d2_1, %tmp_31, %l_y__j__plus__1__76_d2_1, %l_y__j__plus__1__76_d2_1, %tmp_29 : i22, i22, i22, i22, i22, i22
		}
		// Foreach Statement: End
		// Assignment Statement: Start
		// Evaluate global variable k_CORDIC_constant.
		%tmp_50 = arith.constant 318375 : i19
		%tmp_51 = arith.extui %tmp_50 : i19 to i22
		// Evaluate global variable k_CORDIC_constant done: assigned to tmp_51 above in this context.
		// Evaluate global variable fixedPointMultiply.
		%tmp_49 = func.call @g_qrd_fixedPointMultiply(%tmp_51,%l_y__j__75_d1_2) : (i22,i22) -> i22
		// l_x__out__71_d1_1 aliased to tmp_49
		// Assignment Statement: End
		// Assignment Statement: Start
		// Evaluate global variable k_CORDIC_constant.
		%tmp_53 = arith.constant 318375 : i19
		%tmp_54 = arith.extui %tmp_53 : i19 to i22
		// Evaluate global variable k_CORDIC_constant done: assigned to tmp_54 above in this context.
		// Evaluate global variable fixedPointMultiply.
		%tmp_52 = func.call @g_qrd_fixedPointMultiply(%tmp_54,%l_x__j__72_d1_2) : (i22,i22) -> i22
		cal.set(%l_r__63: !cal.state_ref<i22>, %tmp_52: i22)
		// Assignment Statement: End
		// Assignment Statement: Start
		%tmp_55 = cal.get(%l_count__64: !cal.state_ref<i32>) : i32
		%tmp_56 = arith.constant 1 : i1
		%tmp_57 = arith.extui %tmp_56 : i1 to i32
		%tmp_58 = arith.addi %tmp_55, %tmp_57 : i32
		cal.set(%l_count__64: !cal.state_ref<i32>, %tmp_58: i32)
		// Assignment Statement: End
		// Assignment Statement: Start
		%tmp_59 = arith.constant 0 : i1
		%tmp_60 = arith.extui %tmp_59 : i1 to i32
		cal.set(%l_$state: !cal.state_ref<i32>, %tmp_60: i32)
		// Assignment Statement: End
		// Output Expression: Start
		fifo.push(%x_out: !fifo.input_port<i22>, %tmp_49: i22)
		// Output Expression: End
		// Output Expression: Start
		fifo.push(%cordic_angles_out: !fifo.input_port<i16>, %l_rotation__angles__69_d1_0: i16)
		// Output Expression: End
	}
	// Generation action: final
	cal.action "final" priority=0 {
		// Guard: Start
		cal.predicate {
			%tmp_61 = cal.get(%l_count__64: !cal.state_ref<i32>) : i32
			// Evaluate global variable $eval1.
			%tmp_62 = arith.constant 4 : i3
			%tmp_63 = arith.extui %tmp_62 : i3 to i32
			// Evaluate global variable $eval1 done: assigned to tmp_63 above in this context.
			%tmp_64 = arith.cmpi eq, %tmp_61, %tmp_63 : i32
			cal.predicate_result %tmp_64 : i1
		}
		// Guard: End
		// Assignment Statement: Start
		%tmp_65 = arith.constant 0 : i1
		%tmp_66 = arith.extui %tmp_65 : i1 to i32
		cal.set(%l_count__64: !cal.state_ref<i32>, %tmp_66: i32)
		// Assignment Statement: End
		// Assignment Statement: Start
		%tmp_67 = arith.constant 0 : i1
		%tmp_68 = arith.extui %tmp_67 : i1 to i32
		cal.set(%l_$state: !cal.state_ref<i32>, %tmp_68: i32)
		// Assignment Statement: End
		// Output Expression: Start
		%tmp_69 = cal.get(%l_r__63: !cal.state_ref<i22>) : i22
		fifo.push(%r_out: !fifo.input_port<i22>, %tmp_69: i22)
		// Output Expression: End
	}
}

//-- Definition of actor class: BoundaryCell
cal.actor @boundaryCells_3 ()
	ports_in(%x_in: !fifo.output_port<i22>)
	ports_out(%r_out: !fifo.input_port<i22>,%cordic_angles_out: !fifo.input_port<i16>)
{
	// -- Actor body
	%l_r__78 = cal.create_state_var<i22> : !cal.state_ref<i22>
	%tmp_0 = arith.constant 0 : i1
	%tmp_1 = arith.extui %tmp_0 : i1 to i22
	cal.set(%l_r__78: !cal.state_ref<i22>, %tmp_1: i22)
	%l_count__79 = cal.create_state_var<i32> : !cal.state_ref<i32>
	%tmp_2 = arith.constant 0 : i1
	%tmp_3 = arith.extui %tmp_2 : i1 to i32
	cal.set(%l_count__79: !cal.state_ref<i32>, %tmp_3: i32)
	%l_$state = cal.create_state_var<i32> : !cal.state_ref<i32>
	%tmp_4 = arith.constant 0 : i1
	%tmp_5 = arith.extui %tmp_4 : i1 to i32
	cal.set(%l_$state: !cal.state_ref<i32>, %tmp_5: i32)
	// Generation action: normal
	cal.action "normal" priority=0 {
		// Guard: Start
		cal.predicate {
			%tmp_6 = cal.get(%l_count__79: !cal.state_ref<i32>) : i32
			// Evaluate global variable $eval1.
			%tmp_7 = arith.constant 4 : i3
			%tmp_8 = arith.extui %tmp_7 : i3 to i32
			// Evaluate global variable $eval1 done: assigned to tmp_8 above in this context.
			%tmp_9 = arith.cmpi ult, %tmp_6, %tmp_8 : i32
			cal.predicate_result %tmp_9 : i1
		}
		// Guard: End
		// Input Pattern: Start
		%l_x__in__81_d1_0 = fifo.pop(%x_in: !fifo.output_port<i22>) : i22
		// Input Pattern: End
		// Action Local Variable Decl: Start
		%l_x__j__84_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_x__j__plus__1__85_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_x__j__shifted__86_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_y__j__87_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_y__j__plus__1__88_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_y__j__shifted__89_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%tmp_10 = arith.constant 0 : i1
		%tmp_11 = arith.extui %tmp_10 : i1 to i16
		// l_rotation__angles__83_d1_0 aliased to tmp_11
		// Action Local Variable Decl: End
		// If Statement: Begin
		%tmp_12 = cal.get(%l_count__79: !cal.state_ref<i32>) : i32
		%tmp_13 = arith.constant 0 : i1
		%tmp_14 = arith.extui %tmp_13 : i1 to i32
		%tmp_15 = arith.cmpi eq, %tmp_12, %tmp_14 : i32
		scf.if %tmp_15 {
			// Assignment Statement: Start
			%tmp_16 = arith.constant 0 : i1
			%tmp_17 = arith.extui %tmp_16 : i1 to i22
			cal.set(%l_r__78: !cal.state_ref<i22>, %tmp_17: i22)
			// Assignment Statement: End
		} else {
		}
		// If Statement: End
		// Assignment Statement: Start
		// l_x__j__84_d1_1 aliased to l_x__in__81_d1_0
		// Assignment Statement: End
		// Assignment Statement: Start
		%tmp_18 = cal.get(%l_r__78: !cal.state_ref<i22>) : i22
		// l_y__j__87_d1_1 aliased to tmp_18
		// Assignment Statement: End
		// Foreach Statement: Begin
		%tmp_19 = arith.constant 0 : i1
		%tmp_20 = arith.extui %tmp_19 : i1 to i32
		%tmp_21_lb = index.casts %tmp_20 : i32 to index
		// Evaluate global variable num_CORDIC_iterations.
		%tmp_22 = arith.constant 16 : i5
		%tmp_23 = arith.extui %tmp_22 : i5 to i32
		// Evaluate global variable num_CORDIC_iterations done: assigned to tmp_23 above in this context.
		%tmp_24 = arith.constant 1 : i1
		%tmp_25 = arith.extui %tmp_24 : i1 to i32
		%tmp_26 = arith.subi %tmp_23, %tmp_25 : i32
		%tmp_27_ub = index.casts %tmp_26 : i32 to index
		%tmp_28_step = index.constant 1
		%tmp_29_ub_plus_1 = arith.addi %tmp_27_ub, %tmp_28_step : index
		%l_rotation__angles__83_d1_1, %l_x__j__84_d1_2, %l_x__j__plus__1__85_d1_1, %l_x__j__shifted__86_d1_1, %l_y__j__87_d1_2, %l_y__j__plus__1__88_d1_1, %l_y__j__shifted__89_d1_1 = scf.for %l_j_d1_0 = %tmp_21_lb to %tmp_29_ub_plus_1 step %tmp_28_step
				iter_args(%l_rotation__angles__83_d2_0 = %tmp_11, %l_x__j__84_d2_0 = %l_x__in__81_d1_0, %l_x__j__plus__1__85_d2_0 = %l_x__j__plus__1__85_d1_0, %l_x__j__shifted__86_d2_0 = %l_x__j__shifted__86_d1_0, %l_y__j__87_d2_0 = %tmp_18, %l_y__j__plus__1__88_d2_0 = %l_y__j__plus__1__88_d1_0, %l_y__j__shifted__89_d2_0 = %l_y__j__shifted__89_d1_0) -> (i16, i22, i22, i22, i22, i22, i22) {
			%l_j_d2_0 = arith.index_cast %l_j_d1_0 : index to i32
			%l_j_d2_1 = arith.trunci %l_j_d2_0 : i32 to i8
			// Assignment Statement: Start
			%tmp_30 = arith.extui %l_j_d2_1 : i8 to i22
			%tmp_31 = arith.shrsi %l_y__j__87_d2_0, %tmp_30 : i22
			// l_y__j__shifted__89_d2_1 aliased to tmp_31
			// Assignment Statement: End
			// Assignment Statement: Start
			%tmp_32 = arith.extui %l_j_d2_1 : i8 to i22
			%tmp_33 = arith.shrsi %l_x__j__84_d2_0, %tmp_32 : i22
			// l_x__j__shifted__86_d2_1 aliased to tmp_33
			// Assignment Statement: End
			// If Statement: Begin
			%tmp_34 = arith.constant 0 : i1
			%tmp_35 = arith.extui %tmp_34 : i1 to i22
			%tmp_36 = arith.cmpi sgt, %l_x__j__84_d2_0, %tmp_35 : i22
			%tmp_37 = arith.constant 0 : i1
			%tmp_38 = arith.extui %tmp_37 : i1 to i22
			%tmp_39 = arith.cmpi sgt, %l_y__j__87_d2_0, %tmp_38 : i22
			%tmp_40 = arith.andi %tmp_36, %tmp_39 : i1
			%tmp_41 = arith.constant 0 : i1
			%tmp_42 = arith.extui %tmp_41 : i1 to i22
			%tmp_43 = arith.cmpi slt, %l_x__j__84_d2_0, %tmp_42 : i22
			%tmp_44 = arith.constant 0 : i1
			%tmp_45 = arith.extui %tmp_44 : i1 to i22
			%tmp_46 = arith.cmpi slt, %l_y__j__87_d2_0, %tmp_45 : i22
			%tmp_47 = arith.andi %tmp_43, %tmp_46 : i1
			%tmp_48 = arith.ori %tmp_40, %tmp_47 : i1
			%l_rotation__angles__83_d2_1, %l_x__j__plus__1__85_d2_1, %l_y__j__plus__1__88_d2_1 = scf.if %tmp_48 -> (i16, i22, i22) {
				// Assignment Statement: Start
				%tmp_49 = arith.extsi %l_x__j__84_d2_0 : i22 to i23
				%tmp_50 = arith.extsi %tmp_31 : i22 to i23
				%tmp_51 = arith.addi %tmp_49, %tmp_50 : i23
				%tmp_52 = arith.trunci %tmp_51 : i23 to i22
				// l_x__j__plus__1__85_d3_0 aliased to tmp_52
				// Assignment Statement: End
				// Assignment Statement: Start
				%tmp_53 = arith.subi %l_y__j__87_d2_0, %tmp_33 : i22
				// l_y__j__plus__1__88_d3_0 aliased to tmp_53
				// Assignment Statement: End
				// Assignment Statement: Start
				%tmp_54 = arith.constant 1 : i1
				%tmp_55 = arith.extui %tmp_54 : i1 to i64
				%tmp_56 = arith.extui %l_j_d2_1 : i8 to i64
				%tmp_57 = arith.shli %tmp_55, %tmp_56 : i64
				%tmp_58 = arith.extui %l_rotation__angles__83_d2_0 : i16 to i64
				%tmp_59 = arith.ori %tmp_58, %tmp_57 : i64
				%tmp_60 = arith.trunci %tmp_59 : i64 to i16
				// l_rotation__angles__83_d3_0 aliased to tmp_60
				// Assignment Statement: End
				scf.yield %tmp_60, %tmp_52, %tmp_53 : i16, i22, i22
			} else {
				// Assignment Statement: Start
				%tmp_61 = arith.subi %l_x__j__84_d2_0, %tmp_31 : i22
				// l_x__j__plus__1__85_d3_0 aliased to tmp_61
				// Assignment Statement: End
				// Assignment Statement: Start
				%tmp_62 = arith.extsi %l_y__j__87_d2_0 : i22 to i23
				%tmp_63 = arith.extsi %tmp_33 : i22 to i23
				%tmp_64 = arith.addi %tmp_62, %tmp_63 : i23
				%tmp_65 = arith.trunci %tmp_64 : i23 to i22
				// l_y__j__plus__1__88_d3_0 aliased to tmp_65
				// Assignment Statement: End
				scf.yield %l_rotation__angles__83_d2_0, %tmp_61, %tmp_65 : i16, i22, i22
			}
			// If Statement: End
			// Assignment Statement: Start
			// l_x__j__84_d2_1 aliased to l_x__j__plus__1__85_d2_1
			// Assignment Statement: End
			// Assignment Statement: Start
			// l_y__j__87_d2_1 aliased to l_y__j__plus__1__88_d2_1
			// Assignment Statement: End
			scf.yield %l_rotation__angles__83_d2_1, %l_x__j__plus__1__85_d2_1, %l_x__j__plus__1__85_d2_1, %tmp_33, %l_y__j__plus__1__88_d2_1, %l_y__j__plus__1__88_d2_1, %tmp_31 : i16, i22, i22, i22, i22, i22, i22
		}
		// Foreach Statement: End
		// Assignment Statement: Start
		// Evaluate global variable k_CORDIC_constant.
		%tmp_67 = arith.constant 318375 : i19
		%tmp_68 = arith.extui %tmp_67 : i19 to i22
		// Evaluate global variable k_CORDIC_constant done: assigned to tmp_68 above in this context.
		// Evaluate global variable fixedPointMultiply.
		%tmp_66 = func.call @g_qrd_fixedPointMultiply(%l_x__j__84_d1_2,%tmp_68) : (i22,i22) -> i22
		cal.set(%l_r__78: !cal.state_ref<i22>, %tmp_66: i22)
		// Assignment Statement: End
		// Assignment Statement: Start
		%tmp_69 = cal.get(%l_count__79: !cal.state_ref<i32>) : i32
		%tmp_70 = arith.constant 1 : i1
		%tmp_71 = arith.extui %tmp_70 : i1 to i32
		%tmp_72 = arith.addi %tmp_69, %tmp_71 : i32
		cal.set(%l_count__79: !cal.state_ref<i32>, %tmp_72: i32)
		// Assignment Statement: End
		// Assignment Statement: Start
		%tmp_73 = arith.constant 0 : i1
		%tmp_74 = arith.extui %tmp_73 : i1 to i32
		cal.set(%l_$state: !cal.state_ref<i32>, %tmp_74: i32)
		// Assignment Statement: End
		// Output Expression: Start
		fifo.push(%cordic_angles_out: !fifo.input_port<i16>, %l_rotation__angles__83_d1_1: i16)
		// Output Expression: End
	}
	// Generation action: final
	cal.action "final" priority=0 {
		// Guard: Start
		cal.predicate {
			%tmp_75 = cal.get(%l_count__79: !cal.state_ref<i32>) : i32
			// Evaluate global variable $eval1.
			%tmp_76 = arith.constant 4 : i3
			%tmp_77 = arith.extui %tmp_76 : i3 to i32
			// Evaluate global variable $eval1 done: assigned to tmp_77 above in this context.
			%tmp_78 = arith.cmpi eq, %tmp_75, %tmp_77 : i32
			cal.predicate_result %tmp_78 : i1
		}
		// Guard: End
		// Assignment Statement: Start
		%tmp_79 = arith.constant 0 : i1
		%tmp_80 = arith.extui %tmp_79 : i1 to i32
		cal.set(%l_count__79: !cal.state_ref<i32>, %tmp_80: i32)
		// Assignment Statement: End
		// Assignment Statement: Start
		%tmp_81 = arith.constant 0 : i1
		%tmp_82 = arith.extui %tmp_81 : i1 to i32
		cal.set(%l_$state: !cal.state_ref<i32>, %tmp_82: i32)
		// Assignment Statement: End
		// Output Expression: Start
		%tmp_83 = cal.get(%l_r__78: !cal.state_ref<i22>) : i22
		fifo.push(%r_out: !fifo.input_port<i22>, %tmp_83: i22)
		// Output Expression: End
	}
}

//-- Definition of actor class: BoundaryCell
cal.actor @boundaryCells_2 ()
	ports_in(%x_in: !fifo.output_port<i22>)
	ports_out(%r_out: !fifo.input_port<i22>,%cordic_angles_out: !fifo.input_port<i16>)
{
	// -- Actor body
	%l_r__78 = cal.create_state_var<i22> : !cal.state_ref<i22>
	%tmp_0 = arith.constant 0 : i1
	%tmp_1 = arith.extui %tmp_0 : i1 to i22
	cal.set(%l_r__78: !cal.state_ref<i22>, %tmp_1: i22)
	%l_count__79 = cal.create_state_var<i32> : !cal.state_ref<i32>
	%tmp_2 = arith.constant 0 : i1
	%tmp_3 = arith.extui %tmp_2 : i1 to i32
	cal.set(%l_count__79: !cal.state_ref<i32>, %tmp_3: i32)
	%l_$state = cal.create_state_var<i32> : !cal.state_ref<i32>
	%tmp_4 = arith.constant 0 : i1
	%tmp_5 = arith.extui %tmp_4 : i1 to i32
	cal.set(%l_$state: !cal.state_ref<i32>, %tmp_5: i32)
	// Generation action: normal
	cal.action "normal" priority=0 {
		// Guard: Start
		cal.predicate {
			%tmp_6 = cal.get(%l_count__79: !cal.state_ref<i32>) : i32
			// Evaluate global variable $eval1.
			%tmp_7 = arith.constant 4 : i3
			%tmp_8 = arith.extui %tmp_7 : i3 to i32
			// Evaluate global variable $eval1 done: assigned to tmp_8 above in this context.
			%tmp_9 = arith.cmpi ult, %tmp_6, %tmp_8 : i32
			cal.predicate_result %tmp_9 : i1
		}
		// Guard: End
		// Input Pattern: Start
		%l_x__in__81_d1_0 = fifo.pop(%x_in: !fifo.output_port<i22>) : i22
		// Input Pattern: End
		// Action Local Variable Decl: Start
		%l_x__j__84_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_x__j__plus__1__85_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_x__j__shifted__86_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_y__j__87_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_y__j__plus__1__88_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_y__j__shifted__89_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%tmp_10 = arith.constant 0 : i1
		%tmp_11 = arith.extui %tmp_10 : i1 to i16
		// l_rotation__angles__83_d1_0 aliased to tmp_11
		// Action Local Variable Decl: End
		// If Statement: Begin
		%tmp_12 = cal.get(%l_count__79: !cal.state_ref<i32>) : i32
		%tmp_13 = arith.constant 0 : i1
		%tmp_14 = arith.extui %tmp_13 : i1 to i32
		%tmp_15 = arith.cmpi eq, %tmp_12, %tmp_14 : i32
		scf.if %tmp_15 {
			// Assignment Statement: Start
			%tmp_16 = arith.constant 0 : i1
			%tmp_17 = arith.extui %tmp_16 : i1 to i22
			cal.set(%l_r__78: !cal.state_ref<i22>, %tmp_17: i22)
			// Assignment Statement: End
		} else {
		}
		// If Statement: End
		// Assignment Statement: Start
		// l_x__j__84_d1_1 aliased to l_x__in__81_d1_0
		// Assignment Statement: End
		// Assignment Statement: Start
		%tmp_18 = cal.get(%l_r__78: !cal.state_ref<i22>) : i22
		// l_y__j__87_d1_1 aliased to tmp_18
		// Assignment Statement: End
		// Foreach Statement: Begin
		%tmp_19 = arith.constant 0 : i1
		%tmp_20 = arith.extui %tmp_19 : i1 to i32
		%tmp_21_lb = index.casts %tmp_20 : i32 to index
		// Evaluate global variable num_CORDIC_iterations.
		%tmp_22 = arith.constant 16 : i5
		%tmp_23 = arith.extui %tmp_22 : i5 to i32
		// Evaluate global variable num_CORDIC_iterations done: assigned to tmp_23 above in this context.
		%tmp_24 = arith.constant 1 : i1
		%tmp_25 = arith.extui %tmp_24 : i1 to i32
		%tmp_26 = arith.subi %tmp_23, %tmp_25 : i32
		%tmp_27_ub = index.casts %tmp_26 : i32 to index
		%tmp_28_step = index.constant 1
		%tmp_29_ub_plus_1 = arith.addi %tmp_27_ub, %tmp_28_step : index
		%l_rotation__angles__83_d1_1, %l_x__j__84_d1_2, %l_x__j__plus__1__85_d1_1, %l_x__j__shifted__86_d1_1, %l_y__j__87_d1_2, %l_y__j__plus__1__88_d1_1, %l_y__j__shifted__89_d1_1 = scf.for %l_j_d1_0 = %tmp_21_lb to %tmp_29_ub_plus_1 step %tmp_28_step
				iter_args(%l_rotation__angles__83_d2_0 = %tmp_11, %l_x__j__84_d2_0 = %l_x__in__81_d1_0, %l_x__j__plus__1__85_d2_0 = %l_x__j__plus__1__85_d1_0, %l_x__j__shifted__86_d2_0 = %l_x__j__shifted__86_d1_0, %l_y__j__87_d2_0 = %tmp_18, %l_y__j__plus__1__88_d2_0 = %l_y__j__plus__1__88_d1_0, %l_y__j__shifted__89_d2_0 = %l_y__j__shifted__89_d1_0) -> (i16, i22, i22, i22, i22, i22, i22) {
			%l_j_d2_0 = arith.index_cast %l_j_d1_0 : index to i32
			%l_j_d2_1 = arith.trunci %l_j_d2_0 : i32 to i8
			// Assignment Statement: Start
			%tmp_30 = arith.extui %l_j_d2_1 : i8 to i22
			%tmp_31 = arith.shrsi %l_y__j__87_d2_0, %tmp_30 : i22
			// l_y__j__shifted__89_d2_1 aliased to tmp_31
			// Assignment Statement: End
			// Assignment Statement: Start
			%tmp_32 = arith.extui %l_j_d2_1 : i8 to i22
			%tmp_33 = arith.shrsi %l_x__j__84_d2_0, %tmp_32 : i22
			// l_x__j__shifted__86_d2_1 aliased to tmp_33
			// Assignment Statement: End
			// If Statement: Begin
			%tmp_34 = arith.constant 0 : i1
			%tmp_35 = arith.extui %tmp_34 : i1 to i22
			%tmp_36 = arith.cmpi sgt, %l_x__j__84_d2_0, %tmp_35 : i22
			%tmp_37 = arith.constant 0 : i1
			%tmp_38 = arith.extui %tmp_37 : i1 to i22
			%tmp_39 = arith.cmpi sgt, %l_y__j__87_d2_0, %tmp_38 : i22
			%tmp_40 = arith.andi %tmp_36, %tmp_39 : i1
			%tmp_41 = arith.constant 0 : i1
			%tmp_42 = arith.extui %tmp_41 : i1 to i22
			%tmp_43 = arith.cmpi slt, %l_x__j__84_d2_0, %tmp_42 : i22
			%tmp_44 = arith.constant 0 : i1
			%tmp_45 = arith.extui %tmp_44 : i1 to i22
			%tmp_46 = arith.cmpi slt, %l_y__j__87_d2_0, %tmp_45 : i22
			%tmp_47 = arith.andi %tmp_43, %tmp_46 : i1
			%tmp_48 = arith.ori %tmp_40, %tmp_47 : i1
			%l_rotation__angles__83_d2_1, %l_x__j__plus__1__85_d2_1, %l_y__j__plus__1__88_d2_1 = scf.if %tmp_48 -> (i16, i22, i22) {
				// Assignment Statement: Start
				%tmp_49 = arith.extsi %l_x__j__84_d2_0 : i22 to i23
				%tmp_50 = arith.extsi %tmp_31 : i22 to i23
				%tmp_51 = arith.addi %tmp_49, %tmp_50 : i23
				%tmp_52 = arith.trunci %tmp_51 : i23 to i22
				// l_x__j__plus__1__85_d3_0 aliased to tmp_52
				// Assignment Statement: End
				// Assignment Statement: Start
				%tmp_53 = arith.subi %l_y__j__87_d2_0, %tmp_33 : i22
				// l_y__j__plus__1__88_d3_0 aliased to tmp_53
				// Assignment Statement: End
				// Assignment Statement: Start
				%tmp_54 = arith.constant 1 : i1
				%tmp_55 = arith.extui %tmp_54 : i1 to i64
				%tmp_56 = arith.extui %l_j_d2_1 : i8 to i64
				%tmp_57 = arith.shli %tmp_55, %tmp_56 : i64
				%tmp_58 = arith.extui %l_rotation__angles__83_d2_0 : i16 to i64
				%tmp_59 = arith.ori %tmp_58, %tmp_57 : i64
				%tmp_60 = arith.trunci %tmp_59 : i64 to i16
				// l_rotation__angles__83_d3_0 aliased to tmp_60
				// Assignment Statement: End
				scf.yield %tmp_60, %tmp_52, %tmp_53 : i16, i22, i22
			} else {
				// Assignment Statement: Start
				%tmp_61 = arith.subi %l_x__j__84_d2_0, %tmp_31 : i22
				// l_x__j__plus__1__85_d3_0 aliased to tmp_61
				// Assignment Statement: End
				// Assignment Statement: Start
				%tmp_62 = arith.extsi %l_y__j__87_d2_0 : i22 to i23
				%tmp_63 = arith.extsi %tmp_33 : i22 to i23
				%tmp_64 = arith.addi %tmp_62, %tmp_63 : i23
				%tmp_65 = arith.trunci %tmp_64 : i23 to i22
				// l_y__j__plus__1__88_d3_0 aliased to tmp_65
				// Assignment Statement: End
				scf.yield %l_rotation__angles__83_d2_0, %tmp_61, %tmp_65 : i16, i22, i22
			}
			// If Statement: End
			// Assignment Statement: Start
			// l_x__j__84_d2_1 aliased to l_x__j__plus__1__85_d2_1
			// Assignment Statement: End
			// Assignment Statement: Start
			// l_y__j__87_d2_1 aliased to l_y__j__plus__1__88_d2_1
			// Assignment Statement: End
			scf.yield %l_rotation__angles__83_d2_1, %l_x__j__plus__1__85_d2_1, %l_x__j__plus__1__85_d2_1, %tmp_33, %l_y__j__plus__1__88_d2_1, %l_y__j__plus__1__88_d2_1, %tmp_31 : i16, i22, i22, i22, i22, i22, i22
		}
		// Foreach Statement: End
		// Assignment Statement: Start
		// Evaluate global variable k_CORDIC_constant.
		%tmp_67 = arith.constant 318375 : i19
		%tmp_68 = arith.extui %tmp_67 : i19 to i22
		// Evaluate global variable k_CORDIC_constant done: assigned to tmp_68 above in this context.
		// Evaluate global variable fixedPointMultiply.
		%tmp_66 = func.call @g_qrd_fixedPointMultiply(%l_x__j__84_d1_2,%tmp_68) : (i22,i22) -> i22
		cal.set(%l_r__78: !cal.state_ref<i22>, %tmp_66: i22)
		// Assignment Statement: End
		// Assignment Statement: Start
		%tmp_69 = cal.get(%l_count__79: !cal.state_ref<i32>) : i32
		%tmp_70 = arith.constant 1 : i1
		%tmp_71 = arith.extui %tmp_70 : i1 to i32
		%tmp_72 = arith.addi %tmp_69, %tmp_71 : i32
		cal.set(%l_count__79: !cal.state_ref<i32>, %tmp_72: i32)
		// Assignment Statement: End
		// Assignment Statement: Start
		%tmp_73 = arith.constant 0 : i1
		%tmp_74 = arith.extui %tmp_73 : i1 to i32
		cal.set(%l_$state: !cal.state_ref<i32>, %tmp_74: i32)
		// Assignment Statement: End
		// Output Expression: Start
		fifo.push(%cordic_angles_out: !fifo.input_port<i16>, %l_rotation__angles__83_d1_1: i16)
		// Output Expression: End
	}
	// Generation action: final
	cal.action "final" priority=0 {
		// Guard: Start
		cal.predicate {
			%tmp_75 = cal.get(%l_count__79: !cal.state_ref<i32>) : i32
			// Evaluate global variable $eval1.
			%tmp_76 = arith.constant 4 : i3
			%tmp_77 = arith.extui %tmp_76 : i3 to i32
			// Evaluate global variable $eval1 done: assigned to tmp_77 above in this context.
			%tmp_78 = arith.cmpi eq, %tmp_75, %tmp_77 : i32
			cal.predicate_result %tmp_78 : i1
		}
		// Guard: End
		// Assignment Statement: Start
		%tmp_79 = arith.constant 0 : i1
		%tmp_80 = arith.extui %tmp_79 : i1 to i32
		cal.set(%l_count__79: !cal.state_ref<i32>, %tmp_80: i32)
		// Assignment Statement: End
		// Assignment Statement: Start
		%tmp_81 = arith.constant 0 : i1
		%tmp_82 = arith.extui %tmp_81 : i1 to i32
		cal.set(%l_$state: !cal.state_ref<i32>, %tmp_82: i32)
		// Assignment Statement: End
		// Output Expression: Start
		%tmp_83 = cal.get(%l_r__78: !cal.state_ref<i22>) : i22
		fifo.push(%r_out: !fifo.input_port<i22>, %tmp_83: i22)
		// Output Expression: End
	}
}

//-- Definition of actor class: Source
cal.actor @source ()
	ports_out(%Out_array_0_x: !fifo.input_port<i22>,%Out_array_1_x: !fifo.input_port<i22>,%Out_array_2_x: !fifo.input_port<i22>,%Out_array_3_x: !fifo.input_port<i22>)
{
	// -- Actor body
	%l_row__index__165 = cal.create_state_var<i32> : !cal.state_ref<i32>
	%tmp_0 = arith.constant 0 : i1
	%tmp_1 = arith.extui %tmp_0 : i1 to i32
	cal.set(%l_row__index__165: !cal.state_ref<i32>, %tmp_1: i32)
	%l_matrix__number__166 = cal.create_state_var<i32> : !cal.state_ref<i32>
	%tmp_2 = arith.constant 0 : i1
	%tmp_3 = arith.extui %tmp_2 : i1 to i32
	cal.set(%l_matrix__number__166: !cal.state_ref<i32>, %tmp_3: i32)
	%l_next__167 = cal.create_state_var<i22> : !cal.state_ref<i22>
	// Evaluate global variable fp_increment.
	%tmp_4 = arith.constant 57671 : i16
	%tmp_5 = arith.extui %tmp_4 : i16 to i22
	// Evaluate global variable fp_increment done: assigned to tmp_5 above in this context.
	cal.set(%l_next__167: !cal.state_ref<i22>, %tmp_5: i22)
	%l_$state = cal.create_state_var<i32> : !cal.state_ref<i32>
	%tmp_6 = arith.constant 0 : i1
	%tmp_7 = arith.extui %tmp_6 : i1 to i32
	cal.set(%l_$state: !cal.state_ref<i32>, %tmp_7: i32)
	// Generation action: transmit
	cal.action "transmit" priority=0 {
		// Guard: Start
		cal.predicate {
			%tmp_8 = cal.get(%l_matrix__number__166: !cal.state_ref<i32>) : i32
			// Evaluate global variable num_matrices.
			%tmp_9 = arith.constant 10000 : i14
			%tmp_10 = arith.extui %tmp_9 : i14 to i32
			// Evaluate global variable num_matrices done: assigned to tmp_10 above in this context.
			%tmp_11 = arith.cmpi slt, %tmp_8, %tmp_10 : i32
			cal.predicate_result %tmp_11 : i1
		}
		// Guard: End
		// Action Local Variable Decl: Start
		%l_output__168_d1_0 = memref.alloc() : memref<4xi32>
		// Action Local Variable Decl: End
		// If Statement: Begin
		%tmp_12 = cal.get(%l_matrix__number__166: !cal.state_ref<i32>) : i32
		// Evaluate global variable num_matrices.
		%tmp_13 = arith.constant 10000 : i14
		%tmp_14 = arith.extui %tmp_13 : i14 to i32
		// Evaluate global variable num_matrices done: assigned to tmp_14 above in this context.
		%tmp_15 = arith.constant 10 : i4
		%tmp_16 = arith.extui %tmp_15 : i4 to i32
		%tmp_17 = arith.subi %tmp_14, %tmp_16 : i32
		%tmp_18 = arith.cmpi eq, %tmp_12, %tmp_17 : i32
		scf.if %tmp_18 {
			// Call Statement: Start
			%tmp_19 = cal.get(%l_matrix__number__166: !cal.state_ref<i32>) : i32
			%tmp_20 = cal.get(%l_row__index__165: !cal.state_ref<i32>) : i32
			fifo.print("A%i: row %i: \00", %tmp_19, %tmp_20) : (i32, i32)
			// Call Statement: End
		} else {
		}
		// If Statement: End
		// Foreach Statement: Begin
		%tmp_21 = arith.constant 0 : i1
		%tmp_22 = arith.extui %tmp_21 : i1 to i32
		%tmp_23_lb = index.casts %tmp_22 : i32 to index
		// Evaluate global variable $eval1.
		%tmp_24 = arith.constant 4 : i3
		%tmp_25 = arith.extui %tmp_24 : i3 to i32
		// Evaluate global variable $eval1 done: assigned to tmp_25 above in this context.
		%tmp_26 = arith.constant 1 : i1
		%tmp_27 = arith.extui %tmp_26 : i1 to i32
		%tmp_28 = arith.subi %tmp_25, %tmp_27 : i32
		%tmp_29_ub = index.casts %tmp_28 : i32 to index
		%tmp_30_step = index.constant 1
		%tmp_31_ub_plus_1 = arith.addi %tmp_29_ub, %tmp_30_step : index
		scf.for %l_index_d1_0 = %tmp_23_lb to %tmp_31_ub_plus_1 step %tmp_30_step
				iter_args() -> () {
			%l_index_d2_0 = arith.index_cast %l_index_d1_0 : index to i32
			%l_index_d2_1 = arith.trunci %l_index_d2_0 : i32 to i8
			// Assignment Statement: Start
			%tmp_32 = arith.extui %l_index_d2_1 : i8 to i32
			%tmp_33 = arith.index_cast %tmp_32: i32 to index
			%tmp_34 = cal.get(%l_next__167: !cal.state_ref<i22>) : i22
			%tmp_35 = arith.extsi %tmp_34 : i22 to i32
			memref.store %tmp_35, %l_output__168_d1_0[%tmp_33] : memref<4xi32>
			// Assignment Statement: End
			// If Statement: Begin
			%tmp_36 = cal.get(%l_matrix__number__166: !cal.state_ref<i32>) : i32
			// Evaluate global variable num_matrices.
			%tmp_37 = arith.constant 10000 : i14
			%tmp_38 = arith.extui %tmp_37 : i14 to i32
			// Evaluate global variable num_matrices done: assigned to tmp_38 above in this context.
			%tmp_39 = arith.constant 10 : i4
			%tmp_40 = arith.extui %tmp_39 : i4 to i32
			%tmp_41 = arith.subi %tmp_38, %tmp_40 : i32
			%tmp_42 = arith.cmpi eq, %tmp_36, %tmp_41 : i32
			scf.if %tmp_42 {
				// Call Statement: Start
				%tmp_43 = arith.extui %l_index_d2_1 : i8 to i32
				%tmp_44 = arith.index_cast %tmp_43: i32 to index
				%tmp_46 = memref.load %l_output__168_d1_0[%tmp_44] : memref<4xi32>
				%tmp_45 = arith.trunci %tmp_46 : i32 to i22
				%tmp_47 = arith.extsi %tmp_45 : i22 to i32
				fifo.print("%i \00", %tmp_47) : (i32)
				// Call Statement: End
			} else {
			}
			// If Statement: End
			// Assignment Statement: Start
			%tmp_48 = cal.get(%l_next__167: !cal.state_ref<i22>) : i22
			// Evaluate global variable fp_increment.
			%tmp_49 = arith.constant 57671 : i16
			%tmp_50 = arith.extui %tmp_49 : i16 to i22
			// Evaluate global variable fp_increment done: assigned to tmp_50 above in this context.
			%tmp_51 = arith.extsi %tmp_48 : i22 to i23
			%tmp_52 = arith.extsi %tmp_50 : i22 to i23
			%tmp_53 = arith.addi %tmp_51, %tmp_52 : i23
			%tmp_54 = arith.trunci %tmp_53 : i23 to i22
			cal.set(%l_next__167: !cal.state_ref<i22>, %tmp_54: i22)
			// Assignment Statement: End
			// If Statement: Begin
			%tmp_55 = cal.get(%l_next__167: !cal.state_ref<i22>) : i22
			// Evaluate global variable fixed_point_one.
			%tmp_56 = arith.constant 524288 : i20
			%tmp_57 = arith.extui %tmp_56 : i20 to i22
			// Evaluate global variable fixed_point_one done: assigned to tmp_57 above in this context.
			%tmp_58 = arith.cmpi sge, %tmp_55, %tmp_57 : i22
			scf.if %tmp_58 {
				// Assignment Statement: Start
				%tmp_59 = cal.get(%l_next__167: !cal.state_ref<i22>) : i22
				// Evaluate global variable fixed_point_one.
				%tmp_60 = arith.constant 524288 : i20
				%tmp_61 = arith.extui %tmp_60 : i20 to i22
				// Evaluate global variable fixed_point_one done: assigned to tmp_61 above in this context.
				%tmp_62 = arith.subi %tmp_59, %tmp_61 : i22
				// Evaluate global variable fixed_point_one.
				%tmp_63 = arith.constant 524288 : i20
				%tmp_64 = arith.extui %tmp_63 : i20 to i22
				// Evaluate global variable fixed_point_one done: assigned to tmp_64 above in this context.
				%tmp_65 = arith.subi %tmp_62, %tmp_64 : i22
				cal.set(%l_next__167: !cal.state_ref<i22>, %tmp_65: i22)
				// Assignment Statement: End
			} else {
			}
			// If Statement: End
		}
		// Foreach Statement: End
		// Assignment Statement: Start
		%tmp_66 = cal.get(%l_row__index__165: !cal.state_ref<i32>) : i32
		%tmp_67 = arith.constant 1 : i1
		%tmp_68 = arith.extui %tmp_67 : i1 to i32
		%tmp_69 = arith.addi %tmp_66, %tmp_68 : i32
		cal.set(%l_row__index__165: !cal.state_ref<i32>, %tmp_69: i32)
		// Assignment Statement: End
		// If Statement: Begin
		%tmp_70 = cal.get(%l_matrix__number__166: !cal.state_ref<i32>) : i32
		// Evaluate global variable num_matrices.
		%tmp_71 = arith.constant 10000 : i14
		%tmp_72 = arith.extui %tmp_71 : i14 to i32
		// Evaluate global variable num_matrices done: assigned to tmp_72 above in this context.
		%tmp_73 = arith.constant 10 : i4
		%tmp_74 = arith.extui %tmp_73 : i4 to i32
		%tmp_75 = arith.subi %tmp_72, %tmp_74 : i32
		%tmp_76 = arith.cmpi eq, %tmp_70, %tmp_75 : i32
		scf.if %tmp_76 {
			// Call Statement: Start
			fifo.print("\n\00")
			// Call Statement: End
		} else {
		}
		// If Statement: End
		// If Statement: Begin
		%tmp_77 = cal.get(%l_row__index__165: !cal.state_ref<i32>) : i32
		// Evaluate global variable $eval1.
		%tmp_78 = arith.constant 4 : i3
		%tmp_79 = arith.extui %tmp_78 : i3 to i32
		// Evaluate global variable $eval1 done: assigned to tmp_79 above in this context.
		%tmp_80 = arith.cmpi eq, %tmp_77, %tmp_79 : i32
		scf.if %tmp_80 {
			// Assignment Statement: Start
			%tmp_81 = arith.constant 0 : i1
			%tmp_82 = arith.extui %tmp_81 : i1 to i32
			cal.set(%l_row__index__165: !cal.state_ref<i32>, %tmp_82: i32)
			// Assignment Statement: End
			// Assignment Statement: Start
			// Evaluate global variable fp_increment.
			%tmp_83 = arith.constant 57671 : i16
			%tmp_84 = arith.extui %tmp_83 : i16 to i22
			// Evaluate global variable fp_increment done: assigned to tmp_84 above in this context.
			cal.set(%l_next__167: !cal.state_ref<i22>, %tmp_84: i22)
			// Assignment Statement: End
			// Assignment Statement: Start
			%tmp_85 = cal.get(%l_matrix__number__166: !cal.state_ref<i32>) : i32
			%tmp_86 = arith.constant 1 : i1
			%tmp_87 = arith.extui %tmp_86 : i1 to i32
			%tmp_88 = arith.addi %tmp_85, %tmp_87 : i32
			cal.set(%l_matrix__number__166: !cal.state_ref<i32>, %tmp_88: i32)
			// Assignment Statement: End
		} else {
		}
		// If Statement: End
		// Assignment Statement: Start
		%tmp_89 = arith.constant 0 : i1
		%tmp_90 = arith.extui %tmp_89 : i1 to i32
		cal.set(%l_$state: !cal.state_ref<i32>, %tmp_90: i32)
		// Assignment Statement: End
		// Output Expression: Start
		%tmp_91 = arith.constant 0 : i1
		%tmp_92 = arith.extui %tmp_91 : i1 to i32
		%tmp_93 = arith.index_cast %tmp_92: i32 to index
		%tmp_95 = memref.load %l_output__168_d1_0[%tmp_93] : memref<4xi32>
		%tmp_94 = arith.trunci %tmp_95 : i32 to i22
		fifo.push(%Out_array_0_x: !fifo.input_port<i22>, %tmp_94: i22)
		// Output Expression: End
		// Output Expression: Start
		%tmp_96 = arith.constant 1 : i1
		%tmp_97 = arith.extui %tmp_96 : i1 to i32
		%tmp_98 = arith.index_cast %tmp_97: i32 to index
		%tmp_100 = memref.load %l_output__168_d1_0[%tmp_98] : memref<4xi32>
		%tmp_99 = arith.trunci %tmp_100 : i32 to i22
		fifo.push(%Out_array_1_x: !fifo.input_port<i22>, %tmp_99: i22)
		// Output Expression: End
		// Output Expression: Start
		%tmp_101 = arith.constant 2 : i2
		%tmp_102 = arith.extui %tmp_101 : i2 to i32
		%tmp_103 = arith.index_cast %tmp_102: i32 to index
		%tmp_105 = memref.load %l_output__168_d1_0[%tmp_103] : memref<4xi32>
		%tmp_104 = arith.trunci %tmp_105 : i32 to i22
		fifo.push(%Out_array_2_x: !fifo.input_port<i22>, %tmp_104: i22)
		// Output Expression: End
		// Output Expression: Start
		%tmp_106 = arith.constant 3 : i2
		%tmp_107 = arith.extui %tmp_106 : i2 to i32
		%tmp_108 = arith.index_cast %tmp_107: i32 to index
		%tmp_110 = memref.load %l_output__168_d1_0[%tmp_108] : memref<4xi32>
		%tmp_109 = arith.trunci %tmp_110 : i32 to i22
		fifo.push(%Out_array_3_x: !fifo.input_port<i22>, %tmp_109: i22)
		// Output Expression: End
	}
}

//-- Definition of actor class: InnerCell
cal.actor @innerCells_r_5 ()
	ports_in(%x_in: !fifo.output_port<i22>,%cordic_angles_in: !fifo.output_port<i16>)
	ports_out(%x_out: !fifo.input_port<i22>,%r_out: !fifo.input_port<i22>,%cordic_angles_out: !fifo.input_port<i16>)
{
	// -- Actor body
	%l_r__63 = cal.create_state_var<i22> : !cal.state_ref<i22>
	%tmp_0 = arith.constant 0 : i1
	%tmp_1 = arith.extui %tmp_0 : i1 to i22
	cal.set(%l_r__63: !cal.state_ref<i22>, %tmp_1: i22)
	%l_count__64 = cal.create_state_var<i32> : !cal.state_ref<i32>
	%tmp_2 = arith.constant 0 : i1
	%tmp_3 = arith.extui %tmp_2 : i1 to i32
	cal.set(%l_count__64: !cal.state_ref<i32>, %tmp_3: i32)
	%l_$state = cal.create_state_var<i32> : !cal.state_ref<i32>
	%tmp_4 = arith.constant 0 : i1
	%tmp_5 = arith.extui %tmp_4 : i1 to i32
	cal.set(%l_$state: !cal.state_ref<i32>, %tmp_5: i32)
	// Generation action: normal
	cal.action "normal" priority=0 {
		// Guard: Start
		cal.predicate {
			%tmp_6 = cal.get(%l_count__64: !cal.state_ref<i32>) : i32
			// Evaluate global variable $eval1.
			%tmp_7 = arith.constant 4 : i3
			%tmp_8 = arith.extui %tmp_7 : i3 to i32
			// Evaluate global variable $eval1 done: assigned to tmp_8 above in this context.
			%tmp_9 = arith.cmpi ult, %tmp_6, %tmp_8 : i32
			cal.predicate_result %tmp_9 : i1
		}
		// Guard: End
		// Input Pattern: Start
		%l_x__in__66_d1_0 = fifo.pop(%x_in: !fifo.output_port<i22>) : i22
		// Input Pattern: End
		// Input Pattern: Start
		%l_rotation__angles__69_d1_0 = fifo.pop(%cordic_angles_in: !fifo.output_port<i16>) : i16
		// Input Pattern: End
		// Action Local Variable Decl: Start
		%l_x__out__71_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_x__j__72_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_x__j__plus__1__73_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_x__j__shifted__74_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_y__j__75_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_y__j__plus__1__76_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_y__j__shifted__77_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// If Statement: Begin
		%tmp_10 = cal.get(%l_count__64: !cal.state_ref<i32>) : i32
		%tmp_11 = arith.constant 0 : i1
		%tmp_12 = arith.extui %tmp_11 : i1 to i32
		%tmp_13 = arith.cmpi eq, %tmp_10, %tmp_12 : i32
		scf.if %tmp_13 {
			// Assignment Statement: Start
			%tmp_14 = arith.constant 0 : i1
			%tmp_15 = arith.extui %tmp_14 : i1 to i22
			cal.set(%l_r__63: !cal.state_ref<i22>, %tmp_15: i22)
			// Assignment Statement: End
		} else {
		}
		// If Statement: End
		// Assignment Statement: Start
		// l_x__j__72_d1_1 aliased to l_x__in__66_d1_0
		// Assignment Statement: End
		// Assignment Statement: Start
		%tmp_16 = cal.get(%l_r__63: !cal.state_ref<i22>) : i22
		// l_y__j__75_d1_1 aliased to tmp_16
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
		%l_x__j__72_d1_2, %l_x__j__plus__1__73_d1_1, %l_x__j__shifted__74_d1_1, %l_y__j__75_d1_2, %l_y__j__plus__1__76_d1_1, %l_y__j__shifted__77_d1_1 = scf.for %l_j_d1_0 = %tmp_19_lb to %tmp_27_ub_plus_1 step %tmp_26_step
				iter_args(%l_x__j__72_d2_0 = %l_x__in__66_d1_0, %l_x__j__plus__1__73_d2_0 = %l_x__j__plus__1__73_d1_0, %l_x__j__shifted__74_d2_0 = %l_x__j__shifted__74_d1_0, %l_y__j__75_d2_0 = %tmp_16, %l_y__j__plus__1__76_d2_0 = %l_y__j__plus__1__76_d1_0, %l_y__j__shifted__77_d2_0 = %l_y__j__shifted__77_d1_0) -> (i22, i22, i22, i22, i22, i22) {
			%l_j_d2_0 = arith.index_cast %l_j_d1_0 : index to i32
			%l_j_d2_1 = arith.trunci %l_j_d2_0 : i32 to i8
			// Assignment Statement: Start
			%tmp_28 = arith.extui %l_j_d2_1 : i8 to i22
			%tmp_29 = arith.shrsi %l_y__j__75_d2_0, %tmp_28 : i22
			// l_y__j__shifted__77_d2_1 aliased to tmp_29
			// Assignment Statement: End
			// Assignment Statement: Start
			%tmp_30 = arith.extui %l_j_d2_1 : i8 to i22
			%tmp_31 = arith.shrsi %l_x__j__72_d2_0, %tmp_30 : i22
			// l_x__j__shifted__74_d2_1 aliased to tmp_31
			// Assignment Statement: End
			// If Statement: Begin
			%tmp_32 = arith.extui %l_j_d2_1 : i8 to i16
			%tmp_33 = arith.shrui %l_rotation__angles__69_d1_0, %tmp_32 : i16
			%tmp_34 = arith.constant 1 : i1
			%tmp_35 = arith.trunci %tmp_33 : i16 to i1
			%tmp_36 = arith.andi %tmp_35, %tmp_34 : i1
			%tmp_37 = arith.constant 1 : i1
			%tmp_38 = arith.cmpi eq, %tmp_36, %tmp_37 : i1
			%l_x__j__plus__1__73_d2_1, %l_y__j__plus__1__76_d2_1 = scf.if %tmp_38 -> (i22, i22) {
				// Assignment Statement: Start
				%tmp_39 = arith.extsi %l_x__j__72_d2_0 : i22 to i23
				%tmp_40 = arith.extsi %tmp_29 : i22 to i23
				%tmp_41 = arith.addi %tmp_39, %tmp_40 : i23
				%tmp_42 = arith.trunci %tmp_41 : i23 to i22
				// l_x__j__plus__1__73_d3_0 aliased to tmp_42
				// Assignment Statement: End
				// Assignment Statement: Start
				%tmp_43 = arith.subi %l_y__j__75_d2_0, %tmp_31 : i22
				// l_y__j__plus__1__76_d3_0 aliased to tmp_43
				// Assignment Statement: End
				scf.yield %tmp_42, %tmp_43 : i22, i22
			} else {
				// Assignment Statement: Start
				%tmp_44 = arith.subi %l_x__j__72_d2_0, %tmp_29 : i22
				// l_x__j__plus__1__73_d3_0 aliased to tmp_44
				// Assignment Statement: End
				// Assignment Statement: Start
				%tmp_45 = arith.extsi %l_y__j__75_d2_0 : i22 to i23
				%tmp_46 = arith.extsi %tmp_31 : i22 to i23
				%tmp_47 = arith.addi %tmp_45, %tmp_46 : i23
				%tmp_48 = arith.trunci %tmp_47 : i23 to i22
				// l_y__j__plus__1__76_d3_0 aliased to tmp_48
				// Assignment Statement: End
				scf.yield %tmp_44, %tmp_48 : i22, i22
			}
			// If Statement: End
			// Assignment Statement: Start
			// l_x__j__72_d2_1 aliased to l_x__j__plus__1__73_d2_1
			// Assignment Statement: End
			// Assignment Statement: Start
			// l_y__j__75_d2_1 aliased to l_y__j__plus__1__76_d2_1
			// Assignment Statement: End
			scf.yield %l_x__j__plus__1__73_d2_1, %l_x__j__plus__1__73_d2_1, %tmp_31, %l_y__j__plus__1__76_d2_1, %l_y__j__plus__1__76_d2_1, %tmp_29 : i22, i22, i22, i22, i22, i22
		}
		// Foreach Statement: End
		// Assignment Statement: Start
		// Evaluate global variable k_CORDIC_constant.
		%tmp_50 = arith.constant 318375 : i19
		%tmp_51 = arith.extui %tmp_50 : i19 to i22
		// Evaluate global variable k_CORDIC_constant done: assigned to tmp_51 above in this context.
		// Evaluate global variable fixedPointMultiply.
		%tmp_49 = func.call @g_qrd_fixedPointMultiply(%tmp_51,%l_y__j__75_d1_2) : (i22,i22) -> i22
		// l_x__out__71_d1_1 aliased to tmp_49
		// Assignment Statement: End
		// Assignment Statement: Start
		// Evaluate global variable k_CORDIC_constant.
		%tmp_53 = arith.constant 318375 : i19
		%tmp_54 = arith.extui %tmp_53 : i19 to i22
		// Evaluate global variable k_CORDIC_constant done: assigned to tmp_54 above in this context.
		// Evaluate global variable fixedPointMultiply.
		%tmp_52 = func.call @g_qrd_fixedPointMultiply(%tmp_54,%l_x__j__72_d1_2) : (i22,i22) -> i22
		cal.set(%l_r__63: !cal.state_ref<i22>, %tmp_52: i22)
		// Assignment Statement: End
		// Assignment Statement: Start
		%tmp_55 = cal.get(%l_count__64: !cal.state_ref<i32>) : i32
		%tmp_56 = arith.constant 1 : i1
		%tmp_57 = arith.extui %tmp_56 : i1 to i32
		%tmp_58 = arith.addi %tmp_55, %tmp_57 : i32
		cal.set(%l_count__64: !cal.state_ref<i32>, %tmp_58: i32)
		// Assignment Statement: End
		// Assignment Statement: Start
		%tmp_59 = arith.constant 0 : i1
		%tmp_60 = arith.extui %tmp_59 : i1 to i32
		cal.set(%l_$state: !cal.state_ref<i32>, %tmp_60: i32)
		// Assignment Statement: End
		// Output Expression: Start
		fifo.push(%x_out: !fifo.input_port<i22>, %tmp_49: i22)
		// Output Expression: End
		// Output Expression: Start
		fifo.push(%cordic_angles_out: !fifo.input_port<i16>, %l_rotation__angles__69_d1_0: i16)
		// Output Expression: End
	}
	// Generation action: final
	cal.action "final" priority=0 {
		// Guard: Start
		cal.predicate {
			%tmp_61 = cal.get(%l_count__64: !cal.state_ref<i32>) : i32
			// Evaluate global variable $eval1.
			%tmp_62 = arith.constant 4 : i3
			%tmp_63 = arith.extui %tmp_62 : i3 to i32
			// Evaluate global variable $eval1 done: assigned to tmp_63 above in this context.
			%tmp_64 = arith.cmpi eq, %tmp_61, %tmp_63 : i32
			cal.predicate_result %tmp_64 : i1
		}
		// Guard: End
		// Assignment Statement: Start
		%tmp_65 = arith.constant 0 : i1
		%tmp_66 = arith.extui %tmp_65 : i1 to i32
		cal.set(%l_count__64: !cal.state_ref<i32>, %tmp_66: i32)
		// Assignment Statement: End
		// Assignment Statement: Start
		%tmp_67 = arith.constant 0 : i1
		%tmp_68 = arith.extui %tmp_67 : i1 to i32
		cal.set(%l_$state: !cal.state_ref<i32>, %tmp_68: i32)
		// Assignment Statement: End
		// Output Expression: Start
		%tmp_69 = cal.get(%l_r__63: !cal.state_ref<i22>) : i22
		fifo.push(%r_out: !fifo.input_port<i22>, %tmp_69: i22)
		// Output Expression: End
	}
}

//-- Definition of actor class: Cap
cal.actor @caps_r_0 ()
	ports_in(%In: !fifo.output_port<i22>)
{
	// -- Actor body
	%l_$state = cal.create_state_var<i32> : !cal.state_ref<i32>
	%tmp_0 = arith.constant 0 : i1
	%tmp_1 = arith.extui %tmp_0 : i1 to i32
	cal.set(%l_$state: !cal.state_ref<i32>, %tmp_1: i32)
	// Generation action: receive
	cal.action "receive" priority=0 {
		// Input Pattern: Start
		%l_t__107_d1_0 = fifo.pop(%In: !fifo.output_port<i22>) : i22
		// Input Pattern: End
		// Assignment Statement: Start
		%tmp_2 = arith.constant 0 : i1
		%tmp_3 = arith.extui %tmp_2 : i1 to i32
		cal.set(%l_$state: !cal.state_ref<i32>, %tmp_3: i32)
		// Assignment Statement: End
	}
}

//-- Definition of actor class: InnerCell
cal.actor @innerCells_r_3 ()
	ports_in(%x_in: !fifo.output_port<i22>,%cordic_angles_in: !fifo.output_port<i16>)
	ports_out(%x_out: !fifo.input_port<i22>,%r_out: !fifo.input_port<i22>,%cordic_angles_out: !fifo.input_port<i16>)
{
	// -- Actor body
	%l_r__63 = cal.create_state_var<i22> : !cal.state_ref<i22>
	%tmp_0 = arith.constant 0 : i1
	%tmp_1 = arith.extui %tmp_0 : i1 to i22
	cal.set(%l_r__63: !cal.state_ref<i22>, %tmp_1: i22)
	%l_count__64 = cal.create_state_var<i32> : !cal.state_ref<i32>
	%tmp_2 = arith.constant 0 : i1
	%tmp_3 = arith.extui %tmp_2 : i1 to i32
	cal.set(%l_count__64: !cal.state_ref<i32>, %tmp_3: i32)
	%l_$state = cal.create_state_var<i32> : !cal.state_ref<i32>
	%tmp_4 = arith.constant 0 : i1
	%tmp_5 = arith.extui %tmp_4 : i1 to i32
	cal.set(%l_$state: !cal.state_ref<i32>, %tmp_5: i32)
	// Generation action: normal
	cal.action "normal" priority=0 {
		// Guard: Start
		cal.predicate {
			%tmp_6 = cal.get(%l_count__64: !cal.state_ref<i32>) : i32
			// Evaluate global variable $eval1.
			%tmp_7 = arith.constant 4 : i3
			%tmp_8 = arith.extui %tmp_7 : i3 to i32
			// Evaluate global variable $eval1 done: assigned to tmp_8 above in this context.
			%tmp_9 = arith.cmpi ult, %tmp_6, %tmp_8 : i32
			cal.predicate_result %tmp_9 : i1
		}
		// Guard: End
		// Input Pattern: Start
		%l_x__in__66_d1_0 = fifo.pop(%x_in: !fifo.output_port<i22>) : i22
		// Input Pattern: End
		// Input Pattern: Start
		%l_rotation__angles__69_d1_0 = fifo.pop(%cordic_angles_in: !fifo.output_port<i16>) : i16
		// Input Pattern: End
		// Action Local Variable Decl: Start
		%l_x__out__71_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_x__j__72_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_x__j__plus__1__73_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_x__j__shifted__74_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_y__j__75_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_y__j__plus__1__76_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_y__j__shifted__77_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// If Statement: Begin
		%tmp_10 = cal.get(%l_count__64: !cal.state_ref<i32>) : i32
		%tmp_11 = arith.constant 0 : i1
		%tmp_12 = arith.extui %tmp_11 : i1 to i32
		%tmp_13 = arith.cmpi eq, %tmp_10, %tmp_12 : i32
		scf.if %tmp_13 {
			// Assignment Statement: Start
			%tmp_14 = arith.constant 0 : i1
			%tmp_15 = arith.extui %tmp_14 : i1 to i22
			cal.set(%l_r__63: !cal.state_ref<i22>, %tmp_15: i22)
			// Assignment Statement: End
		} else {
		}
		// If Statement: End
		// Assignment Statement: Start
		// l_x__j__72_d1_1 aliased to l_x__in__66_d1_0
		// Assignment Statement: End
		// Assignment Statement: Start
		%tmp_16 = cal.get(%l_r__63: !cal.state_ref<i22>) : i22
		// l_y__j__75_d1_1 aliased to tmp_16
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
		%l_x__j__72_d1_2, %l_x__j__plus__1__73_d1_1, %l_x__j__shifted__74_d1_1, %l_y__j__75_d1_2, %l_y__j__plus__1__76_d1_1, %l_y__j__shifted__77_d1_1 = scf.for %l_j_d1_0 = %tmp_19_lb to %tmp_27_ub_plus_1 step %tmp_26_step
				iter_args(%l_x__j__72_d2_0 = %l_x__in__66_d1_0, %l_x__j__plus__1__73_d2_0 = %l_x__j__plus__1__73_d1_0, %l_x__j__shifted__74_d2_0 = %l_x__j__shifted__74_d1_0, %l_y__j__75_d2_0 = %tmp_16, %l_y__j__plus__1__76_d2_0 = %l_y__j__plus__1__76_d1_0, %l_y__j__shifted__77_d2_0 = %l_y__j__shifted__77_d1_0) -> (i22, i22, i22, i22, i22, i22) {
			%l_j_d2_0 = arith.index_cast %l_j_d1_0 : index to i32
			%l_j_d2_1 = arith.trunci %l_j_d2_0 : i32 to i8
			// Assignment Statement: Start
			%tmp_28 = arith.extui %l_j_d2_1 : i8 to i22
			%tmp_29 = arith.shrsi %l_y__j__75_d2_0, %tmp_28 : i22
			// l_y__j__shifted__77_d2_1 aliased to tmp_29
			// Assignment Statement: End
			// Assignment Statement: Start
			%tmp_30 = arith.extui %l_j_d2_1 : i8 to i22
			%tmp_31 = arith.shrsi %l_x__j__72_d2_0, %tmp_30 : i22
			// l_x__j__shifted__74_d2_1 aliased to tmp_31
			// Assignment Statement: End
			// If Statement: Begin
			%tmp_32 = arith.extui %l_j_d2_1 : i8 to i16
			%tmp_33 = arith.shrui %l_rotation__angles__69_d1_0, %tmp_32 : i16
			%tmp_34 = arith.constant 1 : i1
			%tmp_35 = arith.trunci %tmp_33 : i16 to i1
			%tmp_36 = arith.andi %tmp_35, %tmp_34 : i1
			%tmp_37 = arith.constant 1 : i1
			%tmp_38 = arith.cmpi eq, %tmp_36, %tmp_37 : i1
			%l_x__j__plus__1__73_d2_1, %l_y__j__plus__1__76_d2_1 = scf.if %tmp_38 -> (i22, i22) {
				// Assignment Statement: Start
				%tmp_39 = arith.extsi %l_x__j__72_d2_0 : i22 to i23
				%tmp_40 = arith.extsi %tmp_29 : i22 to i23
				%tmp_41 = arith.addi %tmp_39, %tmp_40 : i23
				%tmp_42 = arith.trunci %tmp_41 : i23 to i22
				// l_x__j__plus__1__73_d3_0 aliased to tmp_42
				// Assignment Statement: End
				// Assignment Statement: Start
				%tmp_43 = arith.subi %l_y__j__75_d2_0, %tmp_31 : i22
				// l_y__j__plus__1__76_d3_0 aliased to tmp_43
				// Assignment Statement: End
				scf.yield %tmp_42, %tmp_43 : i22, i22
			} else {
				// Assignment Statement: Start
				%tmp_44 = arith.subi %l_x__j__72_d2_0, %tmp_29 : i22
				// l_x__j__plus__1__73_d3_0 aliased to tmp_44
				// Assignment Statement: End
				// Assignment Statement: Start
				%tmp_45 = arith.extsi %l_y__j__75_d2_0 : i22 to i23
				%tmp_46 = arith.extsi %tmp_31 : i22 to i23
				%tmp_47 = arith.addi %tmp_45, %tmp_46 : i23
				%tmp_48 = arith.trunci %tmp_47 : i23 to i22
				// l_y__j__plus__1__76_d3_0 aliased to tmp_48
				// Assignment Statement: End
				scf.yield %tmp_44, %tmp_48 : i22, i22
			}
			// If Statement: End
			// Assignment Statement: Start
			// l_x__j__72_d2_1 aliased to l_x__j__plus__1__73_d2_1
			// Assignment Statement: End
			// Assignment Statement: Start
			// l_y__j__75_d2_1 aliased to l_y__j__plus__1__76_d2_1
			// Assignment Statement: End
			scf.yield %l_x__j__plus__1__73_d2_1, %l_x__j__plus__1__73_d2_1, %tmp_31, %l_y__j__plus__1__76_d2_1, %l_y__j__plus__1__76_d2_1, %tmp_29 : i22, i22, i22, i22, i22, i22
		}
		// Foreach Statement: End
		// Assignment Statement: Start
		// Evaluate global variable k_CORDIC_constant.
		%tmp_50 = arith.constant 318375 : i19
		%tmp_51 = arith.extui %tmp_50 : i19 to i22
		// Evaluate global variable k_CORDIC_constant done: assigned to tmp_51 above in this context.
		// Evaluate global variable fixedPointMultiply.
		%tmp_49 = func.call @g_qrd_fixedPointMultiply(%tmp_51,%l_y__j__75_d1_2) : (i22,i22) -> i22
		// l_x__out__71_d1_1 aliased to tmp_49
		// Assignment Statement: End
		// Assignment Statement: Start
		// Evaluate global variable k_CORDIC_constant.
		%tmp_53 = arith.constant 318375 : i19
		%tmp_54 = arith.extui %tmp_53 : i19 to i22
		// Evaluate global variable k_CORDIC_constant done: assigned to tmp_54 above in this context.
		// Evaluate global variable fixedPointMultiply.
		%tmp_52 = func.call @g_qrd_fixedPointMultiply(%tmp_54,%l_x__j__72_d1_2) : (i22,i22) -> i22
		cal.set(%l_r__63: !cal.state_ref<i22>, %tmp_52: i22)
		// Assignment Statement: End
		// Assignment Statement: Start
		%tmp_55 = cal.get(%l_count__64: !cal.state_ref<i32>) : i32
		%tmp_56 = arith.constant 1 : i1
		%tmp_57 = arith.extui %tmp_56 : i1 to i32
		%tmp_58 = arith.addi %tmp_55, %tmp_57 : i32
		cal.set(%l_count__64: !cal.state_ref<i32>, %tmp_58: i32)
		// Assignment Statement: End
		// Assignment Statement: Start
		%tmp_59 = arith.constant 0 : i1
		%tmp_60 = arith.extui %tmp_59 : i1 to i32
		cal.set(%l_$state: !cal.state_ref<i32>, %tmp_60: i32)
		// Assignment Statement: End
		// Output Expression: Start
		fifo.push(%x_out: !fifo.input_port<i22>, %tmp_49: i22)
		// Output Expression: End
		// Output Expression: Start
		fifo.push(%cordic_angles_out: !fifo.input_port<i16>, %l_rotation__angles__69_d1_0: i16)
		// Output Expression: End
	}
	// Generation action: final
	cal.action "final" priority=0 {
		// Guard: Start
		cal.predicate {
			%tmp_61 = cal.get(%l_count__64: !cal.state_ref<i32>) : i32
			// Evaluate global variable $eval1.
			%tmp_62 = arith.constant 4 : i3
			%tmp_63 = arith.extui %tmp_62 : i3 to i32
			// Evaluate global variable $eval1 done: assigned to tmp_63 above in this context.
			%tmp_64 = arith.cmpi eq, %tmp_61, %tmp_63 : i32
			cal.predicate_result %tmp_64 : i1
		}
		// Guard: End
		// Assignment Statement: Start
		%tmp_65 = arith.constant 0 : i1
		%tmp_66 = arith.extui %tmp_65 : i1 to i32
		cal.set(%l_count__64: !cal.state_ref<i32>, %tmp_66: i32)
		// Assignment Statement: End
		// Assignment Statement: Start
		%tmp_67 = arith.constant 0 : i1
		%tmp_68 = arith.extui %tmp_67 : i1 to i32
		cal.set(%l_$state: !cal.state_ref<i32>, %tmp_68: i32)
		// Assignment Statement: End
		// Output Expression: Start
		%tmp_69 = cal.get(%l_r__63: !cal.state_ref<i22>) : i22
		fifo.push(%r_out: !fifo.input_port<i22>, %tmp_69: i22)
		// Output Expression: End
	}
}

//-- Definition of actor class: InnerCell
cal.actor @innerCells_r_4 ()
	ports_in(%x_in: !fifo.output_port<i22>,%cordic_angles_in: !fifo.output_port<i16>)
	ports_out(%x_out: !fifo.input_port<i22>,%r_out: !fifo.input_port<i22>,%cordic_angles_out: !fifo.input_port<i16>)
{
	// -- Actor body
	%l_r__63 = cal.create_state_var<i22> : !cal.state_ref<i22>
	%tmp_0 = arith.constant 0 : i1
	%tmp_1 = arith.extui %tmp_0 : i1 to i22
	cal.set(%l_r__63: !cal.state_ref<i22>, %tmp_1: i22)
	%l_count__64 = cal.create_state_var<i32> : !cal.state_ref<i32>
	%tmp_2 = arith.constant 0 : i1
	%tmp_3 = arith.extui %tmp_2 : i1 to i32
	cal.set(%l_count__64: !cal.state_ref<i32>, %tmp_3: i32)
	%l_$state = cal.create_state_var<i32> : !cal.state_ref<i32>
	%tmp_4 = arith.constant 0 : i1
	%tmp_5 = arith.extui %tmp_4 : i1 to i32
	cal.set(%l_$state: !cal.state_ref<i32>, %tmp_5: i32)
	// Generation action: normal
	cal.action "normal" priority=0 {
		// Guard: Start
		cal.predicate {
			%tmp_6 = cal.get(%l_count__64: !cal.state_ref<i32>) : i32
			// Evaluate global variable $eval1.
			%tmp_7 = arith.constant 4 : i3
			%tmp_8 = arith.extui %tmp_7 : i3 to i32
			// Evaluate global variable $eval1 done: assigned to tmp_8 above in this context.
			%tmp_9 = arith.cmpi ult, %tmp_6, %tmp_8 : i32
			cal.predicate_result %tmp_9 : i1
		}
		// Guard: End
		// Input Pattern: Start
		%l_x__in__66_d1_0 = fifo.pop(%x_in: !fifo.output_port<i22>) : i22
		// Input Pattern: End
		// Input Pattern: Start
		%l_rotation__angles__69_d1_0 = fifo.pop(%cordic_angles_in: !fifo.output_port<i16>) : i16
		// Input Pattern: End
		// Action Local Variable Decl: Start
		%l_x__out__71_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_x__j__72_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_x__j__plus__1__73_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_x__j__shifted__74_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_y__j__75_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_y__j__plus__1__76_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_y__j__shifted__77_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// If Statement: Begin
		%tmp_10 = cal.get(%l_count__64: !cal.state_ref<i32>) : i32
		%tmp_11 = arith.constant 0 : i1
		%tmp_12 = arith.extui %tmp_11 : i1 to i32
		%tmp_13 = arith.cmpi eq, %tmp_10, %tmp_12 : i32
		scf.if %tmp_13 {
			// Assignment Statement: Start
			%tmp_14 = arith.constant 0 : i1
			%tmp_15 = arith.extui %tmp_14 : i1 to i22
			cal.set(%l_r__63: !cal.state_ref<i22>, %tmp_15: i22)
			// Assignment Statement: End
		} else {
		}
		// If Statement: End
		// Assignment Statement: Start
		// l_x__j__72_d1_1 aliased to l_x__in__66_d1_0
		// Assignment Statement: End
		// Assignment Statement: Start
		%tmp_16 = cal.get(%l_r__63: !cal.state_ref<i22>) : i22
		// l_y__j__75_d1_1 aliased to tmp_16
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
		%l_x__j__72_d1_2, %l_x__j__plus__1__73_d1_1, %l_x__j__shifted__74_d1_1, %l_y__j__75_d1_2, %l_y__j__plus__1__76_d1_1, %l_y__j__shifted__77_d1_1 = scf.for %l_j_d1_0 = %tmp_19_lb to %tmp_27_ub_plus_1 step %tmp_26_step
				iter_args(%l_x__j__72_d2_0 = %l_x__in__66_d1_0, %l_x__j__plus__1__73_d2_0 = %l_x__j__plus__1__73_d1_0, %l_x__j__shifted__74_d2_0 = %l_x__j__shifted__74_d1_0, %l_y__j__75_d2_0 = %tmp_16, %l_y__j__plus__1__76_d2_0 = %l_y__j__plus__1__76_d1_0, %l_y__j__shifted__77_d2_0 = %l_y__j__shifted__77_d1_0) -> (i22, i22, i22, i22, i22, i22) {
			%l_j_d2_0 = arith.index_cast %l_j_d1_0 : index to i32
			%l_j_d2_1 = arith.trunci %l_j_d2_0 : i32 to i8
			// Assignment Statement: Start
			%tmp_28 = arith.extui %l_j_d2_1 : i8 to i22
			%tmp_29 = arith.shrsi %l_y__j__75_d2_0, %tmp_28 : i22
			// l_y__j__shifted__77_d2_1 aliased to tmp_29
			// Assignment Statement: End
			// Assignment Statement: Start
			%tmp_30 = arith.extui %l_j_d2_1 : i8 to i22
			%tmp_31 = arith.shrsi %l_x__j__72_d2_0, %tmp_30 : i22
			// l_x__j__shifted__74_d2_1 aliased to tmp_31
			// Assignment Statement: End
			// If Statement: Begin
			%tmp_32 = arith.extui %l_j_d2_1 : i8 to i16
			%tmp_33 = arith.shrui %l_rotation__angles__69_d1_0, %tmp_32 : i16
			%tmp_34 = arith.constant 1 : i1
			%tmp_35 = arith.trunci %tmp_33 : i16 to i1
			%tmp_36 = arith.andi %tmp_35, %tmp_34 : i1
			%tmp_37 = arith.constant 1 : i1
			%tmp_38 = arith.cmpi eq, %tmp_36, %tmp_37 : i1
			%l_x__j__plus__1__73_d2_1, %l_y__j__plus__1__76_d2_1 = scf.if %tmp_38 -> (i22, i22) {
				// Assignment Statement: Start
				%tmp_39 = arith.extsi %l_x__j__72_d2_0 : i22 to i23
				%tmp_40 = arith.extsi %tmp_29 : i22 to i23
				%tmp_41 = arith.addi %tmp_39, %tmp_40 : i23
				%tmp_42 = arith.trunci %tmp_41 : i23 to i22
				// l_x__j__plus__1__73_d3_0 aliased to tmp_42
				// Assignment Statement: End
				// Assignment Statement: Start
				%tmp_43 = arith.subi %l_y__j__75_d2_0, %tmp_31 : i22
				// l_y__j__plus__1__76_d3_0 aliased to tmp_43
				// Assignment Statement: End
				scf.yield %tmp_42, %tmp_43 : i22, i22
			} else {
				// Assignment Statement: Start
				%tmp_44 = arith.subi %l_x__j__72_d2_0, %tmp_29 : i22
				// l_x__j__plus__1__73_d3_0 aliased to tmp_44
				// Assignment Statement: End
				// Assignment Statement: Start
				%tmp_45 = arith.extsi %l_y__j__75_d2_0 : i22 to i23
				%tmp_46 = arith.extsi %tmp_31 : i22 to i23
				%tmp_47 = arith.addi %tmp_45, %tmp_46 : i23
				%tmp_48 = arith.trunci %tmp_47 : i23 to i22
				// l_y__j__plus__1__76_d3_0 aliased to tmp_48
				// Assignment Statement: End
				scf.yield %tmp_44, %tmp_48 : i22, i22
			}
			// If Statement: End
			// Assignment Statement: Start
			// l_x__j__72_d2_1 aliased to l_x__j__plus__1__73_d2_1
			// Assignment Statement: End
			// Assignment Statement: Start
			// l_y__j__75_d2_1 aliased to l_y__j__plus__1__76_d2_1
			// Assignment Statement: End
			scf.yield %l_x__j__plus__1__73_d2_1, %l_x__j__plus__1__73_d2_1, %tmp_31, %l_y__j__plus__1__76_d2_1, %l_y__j__plus__1__76_d2_1, %tmp_29 : i22, i22, i22, i22, i22, i22
		}
		// Foreach Statement: End
		// Assignment Statement: Start
		// Evaluate global variable k_CORDIC_constant.
		%tmp_50 = arith.constant 318375 : i19
		%tmp_51 = arith.extui %tmp_50 : i19 to i22
		// Evaluate global variable k_CORDIC_constant done: assigned to tmp_51 above in this context.
		// Evaluate global variable fixedPointMultiply.
		%tmp_49 = func.call @g_qrd_fixedPointMultiply(%tmp_51,%l_y__j__75_d1_2) : (i22,i22) -> i22
		// l_x__out__71_d1_1 aliased to tmp_49
		// Assignment Statement: End
		// Assignment Statement: Start
		// Evaluate global variable k_CORDIC_constant.
		%tmp_53 = arith.constant 318375 : i19
		%tmp_54 = arith.extui %tmp_53 : i19 to i22
		// Evaluate global variable k_CORDIC_constant done: assigned to tmp_54 above in this context.
		// Evaluate global variable fixedPointMultiply.
		%tmp_52 = func.call @g_qrd_fixedPointMultiply(%tmp_54,%l_x__j__72_d1_2) : (i22,i22) -> i22
		cal.set(%l_r__63: !cal.state_ref<i22>, %tmp_52: i22)
		// Assignment Statement: End
		// Assignment Statement: Start
		%tmp_55 = cal.get(%l_count__64: !cal.state_ref<i32>) : i32
		%tmp_56 = arith.constant 1 : i1
		%tmp_57 = arith.extui %tmp_56 : i1 to i32
		%tmp_58 = arith.addi %tmp_55, %tmp_57 : i32
		cal.set(%l_count__64: !cal.state_ref<i32>, %tmp_58: i32)
		// Assignment Statement: End
		// Assignment Statement: Start
		%tmp_59 = arith.constant 0 : i1
		%tmp_60 = arith.extui %tmp_59 : i1 to i32
		cal.set(%l_$state: !cal.state_ref<i32>, %tmp_60: i32)
		// Assignment Statement: End
		// Output Expression: Start
		fifo.push(%x_out: !fifo.input_port<i22>, %tmp_49: i22)
		// Output Expression: End
		// Output Expression: Start
		fifo.push(%cordic_angles_out: !fifo.input_port<i16>, %l_rotation__angles__69_d1_0: i16)
		// Output Expression: End
	}
	// Generation action: final
	cal.action "final" priority=0 {
		// Guard: Start
		cal.predicate {
			%tmp_61 = cal.get(%l_count__64: !cal.state_ref<i32>) : i32
			// Evaluate global variable $eval1.
			%tmp_62 = arith.constant 4 : i3
			%tmp_63 = arith.extui %tmp_62 : i3 to i32
			// Evaluate global variable $eval1 done: assigned to tmp_63 above in this context.
			%tmp_64 = arith.cmpi eq, %tmp_61, %tmp_63 : i32
			cal.predicate_result %tmp_64 : i1
		}
		// Guard: End
		// Assignment Statement: Start
		%tmp_65 = arith.constant 0 : i1
		%tmp_66 = arith.extui %tmp_65 : i1 to i32
		cal.set(%l_count__64: !cal.state_ref<i32>, %tmp_66: i32)
		// Assignment Statement: End
		// Assignment Statement: Start
		%tmp_67 = arith.constant 0 : i1
		%tmp_68 = arith.extui %tmp_67 : i1 to i32
		cal.set(%l_$state: !cal.state_ref<i32>, %tmp_68: i32)
		// Assignment Statement: End
		// Output Expression: Start
		%tmp_69 = cal.get(%l_r__63: !cal.state_ref<i22>) : i22
		fifo.push(%r_out: !fifo.input_port<i22>, %tmp_69: i22)
		// Output Expression: End
	}
}

//-- Definition of actor class: Cap
cal.actor @caps_r_2 ()
	ports_in(%In: !fifo.output_port<i22>)
{
	// -- Actor body
	%l_$state = cal.create_state_var<i32> : !cal.state_ref<i32>
	%tmp_0 = arith.constant 0 : i1
	%tmp_1 = arith.extui %tmp_0 : i1 to i32
	cal.set(%l_$state: !cal.state_ref<i32>, %tmp_1: i32)
	// Generation action: receive
	cal.action "receive" priority=0 {
		// Input Pattern: Start
		%l_t__107_d1_0 = fifo.pop(%In: !fifo.output_port<i22>) : i22
		// Input Pattern: End
		// Assignment Statement: Start
		%tmp_2 = arith.constant 0 : i1
		%tmp_3 = arith.extui %tmp_2 : i1 to i32
		cal.set(%l_$state: !cal.state_ref<i32>, %tmp_3: i32)
		// Assignment Statement: End
	}
}

//-- Definition of actor class: InnerCell
cal.actor @innerCells_r_1 ()
	ports_in(%x_in: !fifo.output_port<i22>,%cordic_angles_in: !fifo.output_port<i16>)
	ports_out(%x_out: !fifo.input_port<i22>,%r_out: !fifo.input_port<i22>,%cordic_angles_out: !fifo.input_port<i16>)
{
	// -- Actor body
	%l_r__63 = cal.create_state_var<i22> : !cal.state_ref<i22>
	%tmp_0 = arith.constant 0 : i1
	%tmp_1 = arith.extui %tmp_0 : i1 to i22
	cal.set(%l_r__63: !cal.state_ref<i22>, %tmp_1: i22)
	%l_count__64 = cal.create_state_var<i32> : !cal.state_ref<i32>
	%tmp_2 = arith.constant 0 : i1
	%tmp_3 = arith.extui %tmp_2 : i1 to i32
	cal.set(%l_count__64: !cal.state_ref<i32>, %tmp_3: i32)
	%l_$state = cal.create_state_var<i32> : !cal.state_ref<i32>
	%tmp_4 = arith.constant 0 : i1
	%tmp_5 = arith.extui %tmp_4 : i1 to i32
	cal.set(%l_$state: !cal.state_ref<i32>, %tmp_5: i32)
	// Generation action: normal
	cal.action "normal" priority=0 {
		// Guard: Start
		cal.predicate {
			%tmp_6 = cal.get(%l_count__64: !cal.state_ref<i32>) : i32
			// Evaluate global variable $eval1.
			%tmp_7 = arith.constant 4 : i3
			%tmp_8 = arith.extui %tmp_7 : i3 to i32
			// Evaluate global variable $eval1 done: assigned to tmp_8 above in this context.
			%tmp_9 = arith.cmpi ult, %tmp_6, %tmp_8 : i32
			cal.predicate_result %tmp_9 : i1
		}
		// Guard: End
		// Input Pattern: Start
		%l_x__in__66_d1_0 = fifo.pop(%x_in: !fifo.output_port<i22>) : i22
		// Input Pattern: End
		// Input Pattern: Start
		%l_rotation__angles__69_d1_0 = fifo.pop(%cordic_angles_in: !fifo.output_port<i16>) : i16
		// Input Pattern: End
		// Action Local Variable Decl: Start
		%l_x__out__71_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_x__j__72_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_x__j__plus__1__73_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_x__j__shifted__74_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_y__j__75_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_y__j__plus__1__76_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_y__j__shifted__77_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// If Statement: Begin
		%tmp_10 = cal.get(%l_count__64: !cal.state_ref<i32>) : i32
		%tmp_11 = arith.constant 0 : i1
		%tmp_12 = arith.extui %tmp_11 : i1 to i32
		%tmp_13 = arith.cmpi eq, %tmp_10, %tmp_12 : i32
		scf.if %tmp_13 {
			// Assignment Statement: Start
			%tmp_14 = arith.constant 0 : i1
			%tmp_15 = arith.extui %tmp_14 : i1 to i22
			cal.set(%l_r__63: !cal.state_ref<i22>, %tmp_15: i22)
			// Assignment Statement: End
		} else {
		}
		// If Statement: End
		// Assignment Statement: Start
		// l_x__j__72_d1_1 aliased to l_x__in__66_d1_0
		// Assignment Statement: End
		// Assignment Statement: Start
		%tmp_16 = cal.get(%l_r__63: !cal.state_ref<i22>) : i22
		// l_y__j__75_d1_1 aliased to tmp_16
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
		%l_x__j__72_d1_2, %l_x__j__plus__1__73_d1_1, %l_x__j__shifted__74_d1_1, %l_y__j__75_d1_2, %l_y__j__plus__1__76_d1_1, %l_y__j__shifted__77_d1_1 = scf.for %l_j_d1_0 = %tmp_19_lb to %tmp_27_ub_plus_1 step %tmp_26_step
				iter_args(%l_x__j__72_d2_0 = %l_x__in__66_d1_0, %l_x__j__plus__1__73_d2_0 = %l_x__j__plus__1__73_d1_0, %l_x__j__shifted__74_d2_0 = %l_x__j__shifted__74_d1_0, %l_y__j__75_d2_0 = %tmp_16, %l_y__j__plus__1__76_d2_0 = %l_y__j__plus__1__76_d1_0, %l_y__j__shifted__77_d2_0 = %l_y__j__shifted__77_d1_0) -> (i22, i22, i22, i22, i22, i22) {
			%l_j_d2_0 = arith.index_cast %l_j_d1_0 : index to i32
			%l_j_d2_1 = arith.trunci %l_j_d2_0 : i32 to i8
			// Assignment Statement: Start
			%tmp_28 = arith.extui %l_j_d2_1 : i8 to i22
			%tmp_29 = arith.shrsi %l_y__j__75_d2_0, %tmp_28 : i22
			// l_y__j__shifted__77_d2_1 aliased to tmp_29
			// Assignment Statement: End
			// Assignment Statement: Start
			%tmp_30 = arith.extui %l_j_d2_1 : i8 to i22
			%tmp_31 = arith.shrsi %l_x__j__72_d2_0, %tmp_30 : i22
			// l_x__j__shifted__74_d2_1 aliased to tmp_31
			// Assignment Statement: End
			// If Statement: Begin
			%tmp_32 = arith.extui %l_j_d2_1 : i8 to i16
			%tmp_33 = arith.shrui %l_rotation__angles__69_d1_0, %tmp_32 : i16
			%tmp_34 = arith.constant 1 : i1
			%tmp_35 = arith.trunci %tmp_33 : i16 to i1
			%tmp_36 = arith.andi %tmp_35, %tmp_34 : i1
			%tmp_37 = arith.constant 1 : i1
			%tmp_38 = arith.cmpi eq, %tmp_36, %tmp_37 : i1
			%l_x__j__plus__1__73_d2_1, %l_y__j__plus__1__76_d2_1 = scf.if %tmp_38 -> (i22, i22) {
				// Assignment Statement: Start
				%tmp_39 = arith.extsi %l_x__j__72_d2_0 : i22 to i23
				%tmp_40 = arith.extsi %tmp_29 : i22 to i23
				%tmp_41 = arith.addi %tmp_39, %tmp_40 : i23
				%tmp_42 = arith.trunci %tmp_41 : i23 to i22
				// l_x__j__plus__1__73_d3_0 aliased to tmp_42
				// Assignment Statement: End
				// Assignment Statement: Start
				%tmp_43 = arith.subi %l_y__j__75_d2_0, %tmp_31 : i22
				// l_y__j__plus__1__76_d3_0 aliased to tmp_43
				// Assignment Statement: End
				scf.yield %tmp_42, %tmp_43 : i22, i22
			} else {
				// Assignment Statement: Start
				%tmp_44 = arith.subi %l_x__j__72_d2_0, %tmp_29 : i22
				// l_x__j__plus__1__73_d3_0 aliased to tmp_44
				// Assignment Statement: End
				// Assignment Statement: Start
				%tmp_45 = arith.extsi %l_y__j__75_d2_0 : i22 to i23
				%tmp_46 = arith.extsi %tmp_31 : i22 to i23
				%tmp_47 = arith.addi %tmp_45, %tmp_46 : i23
				%tmp_48 = arith.trunci %tmp_47 : i23 to i22
				// l_y__j__plus__1__76_d3_0 aliased to tmp_48
				// Assignment Statement: End
				scf.yield %tmp_44, %tmp_48 : i22, i22
			}
			// If Statement: End
			// Assignment Statement: Start
			// l_x__j__72_d2_1 aliased to l_x__j__plus__1__73_d2_1
			// Assignment Statement: End
			// Assignment Statement: Start
			// l_y__j__75_d2_1 aliased to l_y__j__plus__1__76_d2_1
			// Assignment Statement: End
			scf.yield %l_x__j__plus__1__73_d2_1, %l_x__j__plus__1__73_d2_1, %tmp_31, %l_y__j__plus__1__76_d2_1, %l_y__j__plus__1__76_d2_1, %tmp_29 : i22, i22, i22, i22, i22, i22
		}
		// Foreach Statement: End
		// Assignment Statement: Start
		// Evaluate global variable k_CORDIC_constant.
		%tmp_50 = arith.constant 318375 : i19
		%tmp_51 = arith.extui %tmp_50 : i19 to i22
		// Evaluate global variable k_CORDIC_constant done: assigned to tmp_51 above in this context.
		// Evaluate global variable fixedPointMultiply.
		%tmp_49 = func.call @g_qrd_fixedPointMultiply(%tmp_51,%l_y__j__75_d1_2) : (i22,i22) -> i22
		// l_x__out__71_d1_1 aliased to tmp_49
		// Assignment Statement: End
		// Assignment Statement: Start
		// Evaluate global variable k_CORDIC_constant.
		%tmp_53 = arith.constant 318375 : i19
		%tmp_54 = arith.extui %tmp_53 : i19 to i22
		// Evaluate global variable k_CORDIC_constant done: assigned to tmp_54 above in this context.
		// Evaluate global variable fixedPointMultiply.
		%tmp_52 = func.call @g_qrd_fixedPointMultiply(%tmp_54,%l_x__j__72_d1_2) : (i22,i22) -> i22
		cal.set(%l_r__63: !cal.state_ref<i22>, %tmp_52: i22)
		// Assignment Statement: End
		// Assignment Statement: Start
		%tmp_55 = cal.get(%l_count__64: !cal.state_ref<i32>) : i32
		%tmp_56 = arith.constant 1 : i1
		%tmp_57 = arith.extui %tmp_56 : i1 to i32
		%tmp_58 = arith.addi %tmp_55, %tmp_57 : i32
		cal.set(%l_count__64: !cal.state_ref<i32>, %tmp_58: i32)
		// Assignment Statement: End
		// Assignment Statement: Start
		%tmp_59 = arith.constant 0 : i1
		%tmp_60 = arith.extui %tmp_59 : i1 to i32
		cal.set(%l_$state: !cal.state_ref<i32>, %tmp_60: i32)
		// Assignment Statement: End
		// Output Expression: Start
		fifo.push(%x_out: !fifo.input_port<i22>, %tmp_49: i22)
		// Output Expression: End
		// Output Expression: Start
		fifo.push(%cordic_angles_out: !fifo.input_port<i16>, %l_rotation__angles__69_d1_0: i16)
		// Output Expression: End
	}
	// Generation action: final
	cal.action "final" priority=0 {
		// Guard: Start
		cal.predicate {
			%tmp_61 = cal.get(%l_count__64: !cal.state_ref<i32>) : i32
			// Evaluate global variable $eval1.
			%tmp_62 = arith.constant 4 : i3
			%tmp_63 = arith.extui %tmp_62 : i3 to i32
			// Evaluate global variable $eval1 done: assigned to tmp_63 above in this context.
			%tmp_64 = arith.cmpi eq, %tmp_61, %tmp_63 : i32
			cal.predicate_result %tmp_64 : i1
		}
		// Guard: End
		// Assignment Statement: Start
		%tmp_65 = arith.constant 0 : i1
		%tmp_66 = arith.extui %tmp_65 : i1 to i32
		cal.set(%l_count__64: !cal.state_ref<i32>, %tmp_66: i32)
		// Assignment Statement: End
		// Assignment Statement: Start
		%tmp_67 = arith.constant 0 : i1
		%tmp_68 = arith.extui %tmp_67 : i1 to i32
		cal.set(%l_$state: !cal.state_ref<i32>, %tmp_68: i32)
		// Assignment Statement: End
		// Output Expression: Start
		%tmp_69 = cal.get(%l_r__63: !cal.state_ref<i22>) : i22
		fifo.push(%r_out: !fifo.input_port<i22>, %tmp_69: i22)
		// Output Expression: End
	}
}

//-- Definition of actor class: Cap
cal.actor @caps_r_1 ()
	ports_in(%In: !fifo.output_port<i22>)
{
	// -- Actor body
	%l_$state = cal.create_state_var<i32> : !cal.state_ref<i32>
	%tmp_0 = arith.constant 0 : i1
	%tmp_1 = arith.extui %tmp_0 : i1 to i32
	cal.set(%l_$state: !cal.state_ref<i32>, %tmp_1: i32)
	// Generation action: receive
	cal.action "receive" priority=0 {
		// Input Pattern: Start
		%l_t__107_d1_0 = fifo.pop(%In: !fifo.output_port<i22>) : i22
		// Input Pattern: End
		// Assignment Statement: Start
		%tmp_2 = arith.constant 0 : i1
		%tmp_3 = arith.extui %tmp_2 : i1 to i32
		cal.set(%l_$state: !cal.state_ref<i32>, %tmp_3: i32)
		// Assignment Statement: End
	}
}

//-- Definition of actor class: InnerCell
cal.actor @innerCells_r_2 ()
	ports_in(%x_in: !fifo.output_port<i22>,%cordic_angles_in: !fifo.output_port<i16>)
	ports_out(%x_out: !fifo.input_port<i22>,%r_out: !fifo.input_port<i22>,%cordic_angles_out: !fifo.input_port<i16>)
{
	// -- Actor body
	%l_r__63 = cal.create_state_var<i22> : !cal.state_ref<i22>
	%tmp_0 = arith.constant 0 : i1
	%tmp_1 = arith.extui %tmp_0 : i1 to i22
	cal.set(%l_r__63: !cal.state_ref<i22>, %tmp_1: i22)
	%l_count__64 = cal.create_state_var<i32> : !cal.state_ref<i32>
	%tmp_2 = arith.constant 0 : i1
	%tmp_3 = arith.extui %tmp_2 : i1 to i32
	cal.set(%l_count__64: !cal.state_ref<i32>, %tmp_3: i32)
	%l_$state = cal.create_state_var<i32> : !cal.state_ref<i32>
	%tmp_4 = arith.constant 0 : i1
	%tmp_5 = arith.extui %tmp_4 : i1 to i32
	cal.set(%l_$state: !cal.state_ref<i32>, %tmp_5: i32)
	// Generation action: normal
	cal.action "normal" priority=0 {
		// Guard: Start
		cal.predicate {
			%tmp_6 = cal.get(%l_count__64: !cal.state_ref<i32>) : i32
			// Evaluate global variable $eval1.
			%tmp_7 = arith.constant 4 : i3
			%tmp_8 = arith.extui %tmp_7 : i3 to i32
			// Evaluate global variable $eval1 done: assigned to tmp_8 above in this context.
			%tmp_9 = arith.cmpi ult, %tmp_6, %tmp_8 : i32
			cal.predicate_result %tmp_9 : i1
		}
		// Guard: End
		// Input Pattern: Start
		%l_x__in__66_d1_0 = fifo.pop(%x_in: !fifo.output_port<i22>) : i22
		// Input Pattern: End
		// Input Pattern: Start
		%l_rotation__angles__69_d1_0 = fifo.pop(%cordic_angles_in: !fifo.output_port<i16>) : i16
		// Input Pattern: End
		// Action Local Variable Decl: Start
		%l_x__out__71_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_x__j__72_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_x__j__plus__1__73_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_x__j__shifted__74_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_y__j__75_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_y__j__plus__1__76_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_y__j__shifted__77_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// If Statement: Begin
		%tmp_10 = cal.get(%l_count__64: !cal.state_ref<i32>) : i32
		%tmp_11 = arith.constant 0 : i1
		%tmp_12 = arith.extui %tmp_11 : i1 to i32
		%tmp_13 = arith.cmpi eq, %tmp_10, %tmp_12 : i32
		scf.if %tmp_13 {
			// Assignment Statement: Start
			%tmp_14 = arith.constant 0 : i1
			%tmp_15 = arith.extui %tmp_14 : i1 to i22
			cal.set(%l_r__63: !cal.state_ref<i22>, %tmp_15: i22)
			// Assignment Statement: End
		} else {
		}
		// If Statement: End
		// Assignment Statement: Start
		// l_x__j__72_d1_1 aliased to l_x__in__66_d1_0
		// Assignment Statement: End
		// Assignment Statement: Start
		%tmp_16 = cal.get(%l_r__63: !cal.state_ref<i22>) : i22
		// l_y__j__75_d1_1 aliased to tmp_16
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
		%l_x__j__72_d1_2, %l_x__j__plus__1__73_d1_1, %l_x__j__shifted__74_d1_1, %l_y__j__75_d1_2, %l_y__j__plus__1__76_d1_1, %l_y__j__shifted__77_d1_1 = scf.for %l_j_d1_0 = %tmp_19_lb to %tmp_27_ub_plus_1 step %tmp_26_step
				iter_args(%l_x__j__72_d2_0 = %l_x__in__66_d1_0, %l_x__j__plus__1__73_d2_0 = %l_x__j__plus__1__73_d1_0, %l_x__j__shifted__74_d2_0 = %l_x__j__shifted__74_d1_0, %l_y__j__75_d2_0 = %tmp_16, %l_y__j__plus__1__76_d2_0 = %l_y__j__plus__1__76_d1_0, %l_y__j__shifted__77_d2_0 = %l_y__j__shifted__77_d1_0) -> (i22, i22, i22, i22, i22, i22) {
			%l_j_d2_0 = arith.index_cast %l_j_d1_0 : index to i32
			%l_j_d2_1 = arith.trunci %l_j_d2_0 : i32 to i8
			// Assignment Statement: Start
			%tmp_28 = arith.extui %l_j_d2_1 : i8 to i22
			%tmp_29 = arith.shrsi %l_y__j__75_d2_0, %tmp_28 : i22
			// l_y__j__shifted__77_d2_1 aliased to tmp_29
			// Assignment Statement: End
			// Assignment Statement: Start
			%tmp_30 = arith.extui %l_j_d2_1 : i8 to i22
			%tmp_31 = arith.shrsi %l_x__j__72_d2_0, %tmp_30 : i22
			// l_x__j__shifted__74_d2_1 aliased to tmp_31
			// Assignment Statement: End
			// If Statement: Begin
			%tmp_32 = arith.extui %l_j_d2_1 : i8 to i16
			%tmp_33 = arith.shrui %l_rotation__angles__69_d1_0, %tmp_32 : i16
			%tmp_34 = arith.constant 1 : i1
			%tmp_35 = arith.trunci %tmp_33 : i16 to i1
			%tmp_36 = arith.andi %tmp_35, %tmp_34 : i1
			%tmp_37 = arith.constant 1 : i1
			%tmp_38 = arith.cmpi eq, %tmp_36, %tmp_37 : i1
			%l_x__j__plus__1__73_d2_1, %l_y__j__plus__1__76_d2_1 = scf.if %tmp_38 -> (i22, i22) {
				// Assignment Statement: Start
				%tmp_39 = arith.extsi %l_x__j__72_d2_0 : i22 to i23
				%tmp_40 = arith.extsi %tmp_29 : i22 to i23
				%tmp_41 = arith.addi %tmp_39, %tmp_40 : i23
				%tmp_42 = arith.trunci %tmp_41 : i23 to i22
				// l_x__j__plus__1__73_d3_0 aliased to tmp_42
				// Assignment Statement: End
				// Assignment Statement: Start
				%tmp_43 = arith.subi %l_y__j__75_d2_0, %tmp_31 : i22
				// l_y__j__plus__1__76_d3_0 aliased to tmp_43
				// Assignment Statement: End
				scf.yield %tmp_42, %tmp_43 : i22, i22
			} else {
				// Assignment Statement: Start
				%tmp_44 = arith.subi %l_x__j__72_d2_0, %tmp_29 : i22
				// l_x__j__plus__1__73_d3_0 aliased to tmp_44
				// Assignment Statement: End
				// Assignment Statement: Start
				%tmp_45 = arith.extsi %l_y__j__75_d2_0 : i22 to i23
				%tmp_46 = arith.extsi %tmp_31 : i22 to i23
				%tmp_47 = arith.addi %tmp_45, %tmp_46 : i23
				%tmp_48 = arith.trunci %tmp_47 : i23 to i22
				// l_y__j__plus__1__76_d3_0 aliased to tmp_48
				// Assignment Statement: End
				scf.yield %tmp_44, %tmp_48 : i22, i22
			}
			// If Statement: End
			// Assignment Statement: Start
			// l_x__j__72_d2_1 aliased to l_x__j__plus__1__73_d2_1
			// Assignment Statement: End
			// Assignment Statement: Start
			// l_y__j__75_d2_1 aliased to l_y__j__plus__1__76_d2_1
			// Assignment Statement: End
			scf.yield %l_x__j__plus__1__73_d2_1, %l_x__j__plus__1__73_d2_1, %tmp_31, %l_y__j__plus__1__76_d2_1, %l_y__j__plus__1__76_d2_1, %tmp_29 : i22, i22, i22, i22, i22, i22
		}
		// Foreach Statement: End
		// Assignment Statement: Start
		// Evaluate global variable k_CORDIC_constant.
		%tmp_50 = arith.constant 318375 : i19
		%tmp_51 = arith.extui %tmp_50 : i19 to i22
		// Evaluate global variable k_CORDIC_constant done: assigned to tmp_51 above in this context.
		// Evaluate global variable fixedPointMultiply.
		%tmp_49 = func.call @g_qrd_fixedPointMultiply(%tmp_51,%l_y__j__75_d1_2) : (i22,i22) -> i22
		// l_x__out__71_d1_1 aliased to tmp_49
		// Assignment Statement: End
		// Assignment Statement: Start
		// Evaluate global variable k_CORDIC_constant.
		%tmp_53 = arith.constant 318375 : i19
		%tmp_54 = arith.extui %tmp_53 : i19 to i22
		// Evaluate global variable k_CORDIC_constant done: assigned to tmp_54 above in this context.
		// Evaluate global variable fixedPointMultiply.
		%tmp_52 = func.call @g_qrd_fixedPointMultiply(%tmp_54,%l_x__j__72_d1_2) : (i22,i22) -> i22
		cal.set(%l_r__63: !cal.state_ref<i22>, %tmp_52: i22)
		// Assignment Statement: End
		// Assignment Statement: Start
		%tmp_55 = cal.get(%l_count__64: !cal.state_ref<i32>) : i32
		%tmp_56 = arith.constant 1 : i1
		%tmp_57 = arith.extui %tmp_56 : i1 to i32
		%tmp_58 = arith.addi %tmp_55, %tmp_57 : i32
		cal.set(%l_count__64: !cal.state_ref<i32>, %tmp_58: i32)
		// Assignment Statement: End
		// Assignment Statement: Start
		%tmp_59 = arith.constant 0 : i1
		%tmp_60 = arith.extui %tmp_59 : i1 to i32
		cal.set(%l_$state: !cal.state_ref<i32>, %tmp_60: i32)
		// Assignment Statement: End
		// Output Expression: Start
		fifo.push(%x_out: !fifo.input_port<i22>, %tmp_49: i22)
		// Output Expression: End
		// Output Expression: Start
		fifo.push(%cordic_angles_out: !fifo.input_port<i16>, %l_rotation__angles__69_d1_0: i16)
		// Output Expression: End
	}
	// Generation action: final
	cal.action "final" priority=0 {
		// Guard: Start
		cal.predicate {
			%tmp_61 = cal.get(%l_count__64: !cal.state_ref<i32>) : i32
			// Evaluate global variable $eval1.
			%tmp_62 = arith.constant 4 : i3
			%tmp_63 = arith.extui %tmp_62 : i3 to i32
			// Evaluate global variable $eval1 done: assigned to tmp_63 above in this context.
			%tmp_64 = arith.cmpi eq, %tmp_61, %tmp_63 : i32
			cal.predicate_result %tmp_64 : i1
		}
		// Guard: End
		// Assignment Statement: Start
		%tmp_65 = arith.constant 0 : i1
		%tmp_66 = arith.extui %tmp_65 : i1 to i32
		cal.set(%l_count__64: !cal.state_ref<i32>, %tmp_66: i32)
		// Assignment Statement: End
		// Assignment Statement: Start
		%tmp_67 = arith.constant 0 : i1
		%tmp_68 = arith.extui %tmp_67 : i1 to i32
		cal.set(%l_$state: !cal.state_ref<i32>, %tmp_68: i32)
		// Assignment Statement: End
		// Output Expression: Start
		%tmp_69 = cal.get(%l_r__63: !cal.state_ref<i22>) : i22
		fifo.push(%r_out: !fifo.input_port<i22>, %tmp_69: i22)
		// Output Expression: End
	}
}

//-- Definition of actor class: IGenerator
cal.actor @iGenerator_2 ()
	ports_out(%Out: !fifo.input_port<i22>)
{
	// -- Actor body
	%l_row__index__98 = cal.create_state_var<i32> : !cal.state_ref<i32>
	%tmp_0 = arith.constant 0 : i1
	%tmp_1 = arith.extui %tmp_0 : i1 to i32
	cal.set(%l_row__index__98: !cal.state_ref<i32>, %tmp_1: i32)
	%l_total__rows__99 = cal.create_state_var<i32> : !cal.state_ref<i32>
	%tmp_2 = arith.constant 0 : i1
	%tmp_3 = arith.extui %tmp_2 : i1 to i32
	cal.set(%l_total__rows__99: !cal.state_ref<i32>, %tmp_3: i32)
	%l_total__actions__100 = cal.create_state_var<i32> : !cal.state_ref<i32>
	// Evaluate global variable $eval1.
	%tmp_4 = arith.constant 4 : i3
	%tmp_5 = arith.extui %tmp_4 : i3 to i32
	// Evaluate global variable $eval1 done: assigned to tmp_5 above in this context.
	// Evaluate global variable num_matrices.
	%tmp_6 = arith.constant 10000 : i14
	%tmp_7 = arith.extui %tmp_6 : i14 to i32
	// Evaluate global variable num_matrices done: assigned to tmp_7 above in this context.
	%tmp_8 = arith.muli %tmp_5, %tmp_7 : i32
	cal.set(%l_total__actions__100: !cal.state_ref<i32>, %tmp_8: i32)
	%l_$state = cal.create_state_var<i32> : !cal.state_ref<i32>
	%tmp_9 = arith.constant 0 : i1
	%tmp_10 = arith.extui %tmp_9 : i1 to i32
	cal.set(%l_$state: !cal.state_ref<i32>, %tmp_10: i32)
	// Generation action: $untagged0
	cal.action "$untagged0" priority=0 {
		// Guard: Start
		cal.predicate {
			%tmp_11 = cal.get(%l_total__rows__99: !cal.state_ref<i32>) : i32
			%tmp_12 = cal.get(%l_total__actions__100: !cal.state_ref<i32>) : i32
			%tmp_13 = arith.cmpi ult, %tmp_11, %tmp_12 : i32
			cal.predicate_result %tmp_13 : i1
		}
		// Guard: End
		// Action Local Variable Decl: Start
		%tmp_14 = arith.constant 0 : i1
		%tmp_15 = arith.extui %tmp_14 : i1 to i22
		// l_outVal__101_d1_0 aliased to tmp_15
		// Action Local Variable Decl: End
		// If Statement: Begin
		%tmp_16 = cal.get(%l_row__index__98: !cal.state_ref<i32>) : i32
		// Evaluate global variable $eval7.
		%tmp_17 = arith.constant 2 : i2
		%tmp_18 = arith.extui %tmp_17 : i2 to i32
		// Evaluate global variable $eval7 done: assigned to tmp_18 above in this context.
		%tmp_19 = arith.cmpi eq, %tmp_16, %tmp_18 : i32
		%l_outVal__101_d1_1 = scf.if %tmp_19 -> (i22) {
			// Assignment Statement: Start
			// Evaluate global variable fixed_point_one.
			%tmp_20 = arith.constant 524288 : i20
			%tmp_21 = arith.extui %tmp_20 : i20 to i22
			// Evaluate global variable fixed_point_one done: assigned to tmp_21 above in this context.
			// l_outVal__101_d2_0 aliased to tmp_21
			// Assignment Statement: End
			scf.yield %tmp_21 : i22
		} else {
			scf.yield %tmp_15 : i22
		}
		// If Statement: End
		// Assignment Statement: Start
		%tmp_22 = cal.get(%l_row__index__98: !cal.state_ref<i32>) : i32
		%tmp_23 = arith.constant 1 : i1
		%tmp_24 = arith.extui %tmp_23 : i1 to i32
		%tmp_25 = arith.addi %tmp_22, %tmp_24 : i32
		// Evaluate global variable $eval1.
		%tmp_26 = arith.constant 4 : i3
		%tmp_27 = arith.extui %tmp_26 : i3 to i32
		// Evaluate global variable $eval1 done: assigned to tmp_27 above in this context.
		%tmp_28 = arith.remui %tmp_25, %tmp_27 : i32
		cal.set(%l_row__index__98: !cal.state_ref<i32>, %tmp_28: i32)
		// Assignment Statement: End
		// Assignment Statement: Start
		%tmp_29 = cal.get(%l_total__rows__99: !cal.state_ref<i32>) : i32
		%tmp_30 = arith.constant 1 : i1
		%tmp_31 = arith.extui %tmp_30 : i1 to i32
		%tmp_32 = arith.addi %tmp_29, %tmp_31 : i32
		cal.set(%l_total__rows__99: !cal.state_ref<i32>, %tmp_32: i32)
		// Assignment Statement: End
		// Assignment Statement: Start
		%tmp_33 = arith.constant 0 : i1
		%tmp_34 = arith.extui %tmp_33 : i1 to i32
		cal.set(%l_$state: !cal.state_ref<i32>, %tmp_34: i32)
		// Assignment Statement: End
		// Output Expression: Start
		fifo.push(%Out: !fifo.input_port<i22>, %l_outVal__101_d1_1: i22)
		// Output Expression: End
	}
}

//-- Definition of actor class: JoinerRowQ
cal.actor @joinersPerRow_q_1 ()
	ports_in(%r_in_array_0_x: !fifo.output_port<i22>,%r_in_array_1_x: !fifo.output_port<i22>,%r_in_array_2_x: !fifo.output_port<i22>,%r_in_array_3_x: !fifo.output_port<i22>)
	ports_out(%q_out: !fifo.input_port<i22>)
{
	// -- Actor body
	%l_matrix__number__123 = cal.create_state_var<i32> : !cal.state_ref<i32>
	%tmp_0 = arith.constant 0 : i1
	%tmp_1 = arith.extui %tmp_0 : i1 to i32
	cal.set(%l_matrix__number__123: !cal.state_ref<i32>, %tmp_1: i32)
	%l_$state = cal.create_state_var<i32> : !cal.state_ref<i32>
	%tmp_2 = arith.constant 0 : i1
	%tmp_3 = arith.extui %tmp_2 : i1 to i32
	cal.set(%l_$state: !cal.state_ref<i32>, %tmp_3: i32)
	// Generation action: $untagged0
	cal.action "$untagged0" priority=0 {
		// Input Pattern: Start
		%l_____input0______125_d1_0 = fifo.pop(%r_in_array_0_x: !fifo.output_port<i22>) : i22
		// Input Pattern: End
		// Input Pattern: Start
		%l_____input1______128_d1_0 = fifo.pop(%r_in_array_1_x: !fifo.output_port<i22>) : i22
		// Input Pattern: End
		// Input Pattern: Start
		%l_____input2______131_d1_0 = fifo.pop(%r_in_array_2_x: !fifo.output_port<i22>) : i22
		// Input Pattern: End
		// Input Pattern: Start
		%l_____input3______134_d1_0 = fifo.pop(%r_in_array_3_x: !fifo.output_port<i22>) : i22
		// Input Pattern: End
		// Action Local Variable Decl: Start
		%tmp_4 = memref.alloc() : memref<4xi32>
		%tmp_5 = arith.constant 0: index
		%tmp_6 = arith.extsi %l_____input0______125_d1_0 : i22 to i32
		memref.store %tmp_6, %tmp_4[%tmp_5] : memref<4xi32>
		%tmp_7 = arith.constant 1: index
		%tmp_8 = arith.extsi %l_____input1______128_d1_0 : i22 to i32
		memref.store %tmp_8, %tmp_4[%tmp_7] : memref<4xi32>
		%tmp_9 = arith.constant 2: index
		%tmp_10 = arith.extsi %l_____input2______131_d1_0 : i22 to i32
		memref.store %tmp_10, %tmp_4[%tmp_9] : memref<4xi32>
		%tmp_11 = arith.constant 3: index
		%tmp_12 = arith.extsi %l_____input3______134_d1_0 : i22 to i32
		memref.store %tmp_12, %tmp_4[%tmp_11] : memref<4xi32>
		// l_input__136_d1_0 aliased to tmp_4
		// Action Local Variable Decl: End
		// If Statement: Begin
		%tmp_13 = cal.get(%l_matrix__number__123: !cal.state_ref<i32>) : i32
		// Evaluate global variable num_matrices.
		%tmp_14 = arith.constant 10000 : i14
		%tmp_15 = arith.extui %tmp_14 : i14 to i32
		// Evaluate global variable num_matrices done: assigned to tmp_15 above in this context.
		%tmp_16 = arith.constant 10 : i4
		%tmp_17 = arith.extui %tmp_16 : i4 to i32
		%tmp_18 = arith.subi %tmp_15, %tmp_17 : i32
		%tmp_19 = arith.cmpi eq, %tmp_13, %tmp_18 : i32
		scf.if %tmp_19 {
			// Call Statement: Start
			%tmp_20 = cal.get(%l_matrix__number__123: !cal.state_ref<i32>) : i32
			fifo.print("Q%u: row 1: \00", %tmp_20) : (i32)
			// Call Statement: End
			// Foreach Statement: Begin
			%tmp_21 = arith.constant 0 : i1
			%tmp_22 = arith.extui %tmp_21 : i1 to i32
			%tmp_23_lb = index.casts %tmp_22 : i32 to index
			// Evaluate global variable $eval1.
			%tmp_24 = arith.constant 4 : i3
			%tmp_25 = arith.extui %tmp_24 : i3 to i32
			// Evaluate global variable $eval1 done: assigned to tmp_25 above in this context.
			%tmp_26 = arith.constant 1 : i1
			%tmp_27 = arith.extui %tmp_26 : i1 to i32
			%tmp_28 = arith.subi %tmp_25, %tmp_27 : i32
			%tmp_29_ub = index.casts %tmp_28 : i32 to index
			%tmp_30_step = index.constant 1
			%tmp_31_ub_plus_1 = arith.addi %tmp_29_ub, %tmp_30_step : index
			scf.for %l_index_d2_0 = %tmp_23_lb to %tmp_31_ub_plus_1 step %tmp_30_step
					iter_args() -> () {
				%l_index_d3_0 = arith.index_cast %l_index_d2_0 : index to i32
				%l_index_d3_1 = arith.trunci %l_index_d3_0 : i32 to i8
				// Call Statement: Start
				%tmp_32 = arith.extui %l_index_d3_1 : i8 to i32
				%tmp_33 = arith.index_cast %tmp_32: i32 to index
				%tmp_35 = memref.load %tmp_4[%tmp_33] : memref<4xi32>
				%tmp_34 = arith.trunci %tmp_35 : i32 to i22
				%tmp_36 = arith.extsi %tmp_34 : i22 to i32
				fifo.print("%i \00", %tmp_36) : (i32)
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
		%tmp_37 = cal.get(%l_matrix__number__123: !cal.state_ref<i32>) : i32
		%tmp_38 = arith.constant 1 : i1
		%tmp_39 = arith.extui %tmp_38 : i1 to i32
		%tmp_40 = arith.addi %tmp_37, %tmp_39 : i32
		cal.set(%l_matrix__number__123: !cal.state_ref<i32>, %tmp_40: i32)
		// Assignment Statement: End
		// Assignment Statement: Start
		%tmp_41 = arith.constant 0 : i1
		%tmp_42 = arith.extui %tmp_41 : i1 to i32
		cal.set(%l_$state: !cal.state_ref<i32>, %tmp_42: i32)
		// Assignment Statement: End
		// Output Expression: Start
		%tmp_43 = arith.constant 0 : index
		%tmp_44 = memref.load %tmp_4[%tmp_43] : memref<4xi32>
		%tmp_45 = arith.trunci %tmp_44 : i32 to i22
		fifo.push(%q_out: !fifo.input_port<i22>, %tmp_45: i22)
		%tmp_46 = arith.constant 1 : index
		%tmp_47 = memref.load %tmp_4[%tmp_46] : memref<4xi32>
		%tmp_48 = arith.trunci %tmp_47 : i32 to i22
		fifo.push(%q_out: !fifo.input_port<i22>, %tmp_48: i22)
		%tmp_49 = arith.constant 2 : index
		%tmp_50 = memref.load %tmp_4[%tmp_49] : memref<4xi32>
		%tmp_51 = arith.trunci %tmp_50 : i32 to i22
		fifo.push(%q_out: !fifo.input_port<i22>, %tmp_51: i22)
		%tmp_52 = arith.constant 3 : index
		%tmp_53 = memref.load %tmp_4[%tmp_52] : memref<4xi32>
		%tmp_54 = arith.trunci %tmp_53 : i32 to i22
		fifo.push(%q_out: !fifo.input_port<i22>, %tmp_54: i22)
		// Output Expression: End
	}
}

//-- Definition of actor class: Cap
cal.actor @caps_r_3 ()
	ports_in(%In: !fifo.output_port<i22>)
{
	// -- Actor body
	%l_$state = cal.create_state_var<i32> : !cal.state_ref<i32>
	%tmp_0 = arith.constant 0 : i1
	%tmp_1 = arith.extui %tmp_0 : i1 to i32
	cal.set(%l_$state: !cal.state_ref<i32>, %tmp_1: i32)
	// Generation action: receive
	cal.action "receive" priority=0 {
		// Input Pattern: Start
		%l_t__107_d1_0 = fifo.pop(%In: !fifo.output_port<i22>) : i22
		// Input Pattern: End
		// Assignment Statement: Start
		%tmp_2 = arith.constant 0 : i1
		%tmp_3 = arith.extui %tmp_2 : i1 to i32
		cal.set(%l_$state: !cal.state_ref<i32>, %tmp_3: i32)
		// Assignment Statement: End
	}
}

//-- Definition of actor class: IGenerator
cal.actor @iGenerator_1 ()
	ports_out(%Out: !fifo.input_port<i22>)
{
	// -- Actor body
	%l_row__index__94 = cal.create_state_var<i32> : !cal.state_ref<i32>
	%tmp_0 = arith.constant 0 : i1
	%tmp_1 = arith.extui %tmp_0 : i1 to i32
	cal.set(%l_row__index__94: !cal.state_ref<i32>, %tmp_1: i32)
	%l_total__rows__95 = cal.create_state_var<i32> : !cal.state_ref<i32>
	%tmp_2 = arith.constant 0 : i1
	%tmp_3 = arith.extui %tmp_2 : i1 to i32
	cal.set(%l_total__rows__95: !cal.state_ref<i32>, %tmp_3: i32)
	%l_total__actions__96 = cal.create_state_var<i32> : !cal.state_ref<i32>
	// Evaluate global variable $eval1.
	%tmp_4 = arith.constant 4 : i3
	%tmp_5 = arith.extui %tmp_4 : i3 to i32
	// Evaluate global variable $eval1 done: assigned to tmp_5 above in this context.
	// Evaluate global variable num_matrices.
	%tmp_6 = arith.constant 10000 : i14
	%tmp_7 = arith.extui %tmp_6 : i14 to i32
	// Evaluate global variable num_matrices done: assigned to tmp_7 above in this context.
	%tmp_8 = arith.muli %tmp_5, %tmp_7 : i32
	cal.set(%l_total__actions__96: !cal.state_ref<i32>, %tmp_8: i32)
	%l_$state = cal.create_state_var<i32> : !cal.state_ref<i32>
	%tmp_9 = arith.constant 0 : i1
	%tmp_10 = arith.extui %tmp_9 : i1 to i32
	cal.set(%l_$state: !cal.state_ref<i32>, %tmp_10: i32)
	// Generation action: $untagged0
	cal.action "$untagged0" priority=0 {
		// Guard: Start
		cal.predicate {
			%tmp_11 = cal.get(%l_total__rows__95: !cal.state_ref<i32>) : i32
			%tmp_12 = cal.get(%l_total__actions__96: !cal.state_ref<i32>) : i32
			%tmp_13 = arith.cmpi ult, %tmp_11, %tmp_12 : i32
			cal.predicate_result %tmp_13 : i1
		}
		// Guard: End
		// Action Local Variable Decl: Start
		%tmp_14 = arith.constant 0 : i1
		%tmp_15 = arith.extui %tmp_14 : i1 to i22
		// l_outVal__97_d1_0 aliased to tmp_15
		// Action Local Variable Decl: End
		// If Statement: Begin
		%tmp_16 = cal.get(%l_row__index__94: !cal.state_ref<i32>) : i32
		// Evaluate global variable $eval5.
		%tmp_17 = arith.constant 1 : i1
		%tmp_18 = arith.extui %tmp_17 : i1 to i32
		// Evaluate global variable $eval5 done: assigned to tmp_18 above in this context.
		%tmp_19 = arith.cmpi eq, %tmp_16, %tmp_18 : i32
		%l_outVal__97_d1_1 = scf.if %tmp_19 -> (i22) {
			// Assignment Statement: Start
			// Evaluate global variable fixed_point_one.
			%tmp_20 = arith.constant 524288 : i20
			%tmp_21 = arith.extui %tmp_20 : i20 to i22
			// Evaluate global variable fixed_point_one done: assigned to tmp_21 above in this context.
			// l_outVal__97_d2_0 aliased to tmp_21
			// Assignment Statement: End
			scf.yield %tmp_21 : i22
		} else {
			scf.yield %tmp_15 : i22
		}
		// If Statement: End
		// Assignment Statement: Start
		%tmp_22 = cal.get(%l_row__index__94: !cal.state_ref<i32>) : i32
		%tmp_23 = arith.constant 1 : i1
		%tmp_24 = arith.extui %tmp_23 : i1 to i32
		%tmp_25 = arith.addi %tmp_22, %tmp_24 : i32
		// Evaluate global variable $eval1.
		%tmp_26 = arith.constant 4 : i3
		%tmp_27 = arith.extui %tmp_26 : i3 to i32
		// Evaluate global variable $eval1 done: assigned to tmp_27 above in this context.
		%tmp_28 = arith.remui %tmp_25, %tmp_27 : i32
		cal.set(%l_row__index__94: !cal.state_ref<i32>, %tmp_28: i32)
		// Assignment Statement: End
		// Assignment Statement: Start
		%tmp_29 = cal.get(%l_total__rows__95: !cal.state_ref<i32>) : i32
		%tmp_30 = arith.constant 1 : i1
		%tmp_31 = arith.extui %tmp_30 : i1 to i32
		%tmp_32 = arith.addi %tmp_29, %tmp_31 : i32
		cal.set(%l_total__rows__95: !cal.state_ref<i32>, %tmp_32: i32)
		// Assignment Statement: End
		// Assignment Statement: Start
		%tmp_33 = arith.constant 0 : i1
		%tmp_34 = arith.extui %tmp_33 : i1 to i32
		cal.set(%l_$state: !cal.state_ref<i32>, %tmp_34: i32)
		// Assignment Statement: End
		// Output Expression: Start
		fifo.push(%Out: !fifo.input_port<i22>, %l_outVal__97_d1_1: i22)
		// Output Expression: End
	}
}

//-- Definition of actor class: JoinerRowQ
cal.actor @joinersPerRow_q_0 ()
	ports_in(%r_in_array_0_x: !fifo.output_port<i22>,%r_in_array_1_x: !fifo.output_port<i22>,%r_in_array_2_x: !fifo.output_port<i22>,%r_in_array_3_x: !fifo.output_port<i22>)
	ports_out(%q_out: !fifo.input_port<i22>)
{
	// -- Actor body
	%l_matrix__number__109 = cal.create_state_var<i32> : !cal.state_ref<i32>
	%tmp_0 = arith.constant 0 : i1
	%tmp_1 = arith.extui %tmp_0 : i1 to i32
	cal.set(%l_matrix__number__109: !cal.state_ref<i32>, %tmp_1: i32)
	%l_$state = cal.create_state_var<i32> : !cal.state_ref<i32>
	%tmp_2 = arith.constant 0 : i1
	%tmp_3 = arith.extui %tmp_2 : i1 to i32
	cal.set(%l_$state: !cal.state_ref<i32>, %tmp_3: i32)
	// Generation action: $untagged0
	cal.action "$untagged0" priority=0 {
		// Input Pattern: Start
		%l_____input0______111_d1_0 = fifo.pop(%r_in_array_0_x: !fifo.output_port<i22>) : i22
		// Input Pattern: End
		// Input Pattern: Start
		%l_____input1______114_d1_0 = fifo.pop(%r_in_array_1_x: !fifo.output_port<i22>) : i22
		// Input Pattern: End
		// Input Pattern: Start
		%l_____input2______117_d1_0 = fifo.pop(%r_in_array_2_x: !fifo.output_port<i22>) : i22
		// Input Pattern: End
		// Input Pattern: Start
		%l_____input3______120_d1_0 = fifo.pop(%r_in_array_3_x: !fifo.output_port<i22>) : i22
		// Input Pattern: End
		// Action Local Variable Decl: Start
		%tmp_4 = memref.alloc() : memref<4xi32>
		%tmp_5 = arith.constant 0: index
		%tmp_6 = arith.extsi %l_____input0______111_d1_0 : i22 to i32
		memref.store %tmp_6, %tmp_4[%tmp_5] : memref<4xi32>
		%tmp_7 = arith.constant 1: index
		%tmp_8 = arith.extsi %l_____input1______114_d1_0 : i22 to i32
		memref.store %tmp_8, %tmp_4[%tmp_7] : memref<4xi32>
		%tmp_9 = arith.constant 2: index
		%tmp_10 = arith.extsi %l_____input2______117_d1_0 : i22 to i32
		memref.store %tmp_10, %tmp_4[%tmp_9] : memref<4xi32>
		%tmp_11 = arith.constant 3: index
		%tmp_12 = arith.extsi %l_____input3______120_d1_0 : i22 to i32
		memref.store %tmp_12, %tmp_4[%tmp_11] : memref<4xi32>
		// l_input__122_d1_0 aliased to tmp_4
		// Action Local Variable Decl: End
		// If Statement: Begin
		%tmp_13 = cal.get(%l_matrix__number__109: !cal.state_ref<i32>) : i32
		// Evaluate global variable num_matrices.
		%tmp_14 = arith.constant 10000 : i14
		%tmp_15 = arith.extui %tmp_14 : i14 to i32
		// Evaluate global variable num_matrices done: assigned to tmp_15 above in this context.
		%tmp_16 = arith.constant 10 : i4
		%tmp_17 = arith.extui %tmp_16 : i4 to i32
		%tmp_18 = arith.subi %tmp_15, %tmp_17 : i32
		%tmp_19 = arith.cmpi eq, %tmp_13, %tmp_18 : i32
		scf.if %tmp_19 {
			// Call Statement: Start
			%tmp_20 = cal.get(%l_matrix__number__109: !cal.state_ref<i32>) : i32
			fifo.print("Q%u: row 0: \00", %tmp_20) : (i32)
			// Call Statement: End
			// Foreach Statement: Begin
			%tmp_21 = arith.constant 0 : i1
			%tmp_22 = arith.extui %tmp_21 : i1 to i32
			%tmp_23_lb = index.casts %tmp_22 : i32 to index
			// Evaluate global variable $eval1.
			%tmp_24 = arith.constant 4 : i3
			%tmp_25 = arith.extui %tmp_24 : i3 to i32
			// Evaluate global variable $eval1 done: assigned to tmp_25 above in this context.
			%tmp_26 = arith.constant 1 : i1
			%tmp_27 = arith.extui %tmp_26 : i1 to i32
			%tmp_28 = arith.subi %tmp_25, %tmp_27 : i32
			%tmp_29_ub = index.casts %tmp_28 : i32 to index
			%tmp_30_step = index.constant 1
			%tmp_31_ub_plus_1 = arith.addi %tmp_29_ub, %tmp_30_step : index
			scf.for %l_index_d2_0 = %tmp_23_lb to %tmp_31_ub_plus_1 step %tmp_30_step
					iter_args() -> () {
				%l_index_d3_0 = arith.index_cast %l_index_d2_0 : index to i32
				%l_index_d3_1 = arith.trunci %l_index_d3_0 : i32 to i8
				// Call Statement: Start
				%tmp_32 = arith.extui %l_index_d3_1 : i8 to i32
				%tmp_33 = arith.index_cast %tmp_32: i32 to index
				%tmp_35 = memref.load %tmp_4[%tmp_33] : memref<4xi32>
				%tmp_34 = arith.trunci %tmp_35 : i32 to i22
				%tmp_36 = arith.extsi %tmp_34 : i22 to i32
				fifo.print("%i \00", %tmp_36) : (i32)
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
		%tmp_37 = cal.get(%l_matrix__number__109: !cal.state_ref<i32>) : i32
		%tmp_38 = arith.constant 1 : i1
		%tmp_39 = arith.extui %tmp_38 : i1 to i32
		%tmp_40 = arith.addi %tmp_37, %tmp_39 : i32
		cal.set(%l_matrix__number__109: !cal.state_ref<i32>, %tmp_40: i32)
		// Assignment Statement: End
		// Assignment Statement: Start
		%tmp_41 = arith.constant 0 : i1
		%tmp_42 = arith.extui %tmp_41 : i1 to i32
		cal.set(%l_$state: !cal.state_ref<i32>, %tmp_42: i32)
		// Assignment Statement: End
		// Output Expression: Start
		%tmp_43 = arith.constant 0 : index
		%tmp_44 = memref.load %tmp_4[%tmp_43] : memref<4xi32>
		%tmp_45 = arith.trunci %tmp_44 : i32 to i22
		fifo.push(%q_out: !fifo.input_port<i22>, %tmp_45: i22)
		%tmp_46 = arith.constant 1 : index
		%tmp_47 = memref.load %tmp_4[%tmp_46] : memref<4xi32>
		%tmp_48 = arith.trunci %tmp_47 : i32 to i22
		fifo.push(%q_out: !fifo.input_port<i22>, %tmp_48: i22)
		%tmp_49 = arith.constant 2 : index
		%tmp_50 = memref.load %tmp_4[%tmp_49] : memref<4xi32>
		%tmp_51 = arith.trunci %tmp_50 : i32 to i22
		fifo.push(%q_out: !fifo.input_port<i22>, %tmp_51: i22)
		%tmp_52 = arith.constant 3 : index
		%tmp_53 = memref.load %tmp_4[%tmp_52] : memref<4xi32>
		%tmp_54 = arith.trunci %tmp_53 : i32 to i22
		fifo.push(%q_out: !fifo.input_port<i22>, %tmp_54: i22)
		// Output Expression: End
	}
}

//-- Definition of actor class: JoinerRowQ
cal.actor @joinersPerRow_q_3 ()
	ports_in(%r_in_array_0_x: !fifo.output_port<i22>,%r_in_array_1_x: !fifo.output_port<i22>,%r_in_array_2_x: !fifo.output_port<i22>,%r_in_array_3_x: !fifo.output_port<i22>)
	ports_out(%q_out: !fifo.input_port<i22>)
{
	// -- Actor body
	%l_matrix__number__151 = cal.create_state_var<i32> : !cal.state_ref<i32>
	%tmp_0 = arith.constant 0 : i1
	%tmp_1 = arith.extui %tmp_0 : i1 to i32
	cal.set(%l_matrix__number__151: !cal.state_ref<i32>, %tmp_1: i32)
	%l_$state = cal.create_state_var<i32> : !cal.state_ref<i32>
	%tmp_2 = arith.constant 0 : i1
	%tmp_3 = arith.extui %tmp_2 : i1 to i32
	cal.set(%l_$state: !cal.state_ref<i32>, %tmp_3: i32)
	// Generation action: $untagged0
	cal.action "$untagged0" priority=0 {
		// Input Pattern: Start
		%l_____input0______153_d1_0 = fifo.pop(%r_in_array_0_x: !fifo.output_port<i22>) : i22
		// Input Pattern: End
		// Input Pattern: Start
		%l_____input1______156_d1_0 = fifo.pop(%r_in_array_1_x: !fifo.output_port<i22>) : i22
		// Input Pattern: End
		// Input Pattern: Start
		%l_____input2______159_d1_0 = fifo.pop(%r_in_array_2_x: !fifo.output_port<i22>) : i22
		// Input Pattern: End
		// Input Pattern: Start
		%l_____input3______162_d1_0 = fifo.pop(%r_in_array_3_x: !fifo.output_port<i22>) : i22
		// Input Pattern: End
		// Action Local Variable Decl: Start
		%tmp_4 = memref.alloc() : memref<4xi32>
		%tmp_5 = arith.constant 0: index
		%tmp_6 = arith.extsi %l_____input0______153_d1_0 : i22 to i32
		memref.store %tmp_6, %tmp_4[%tmp_5] : memref<4xi32>
		%tmp_7 = arith.constant 1: index
		%tmp_8 = arith.extsi %l_____input1______156_d1_0 : i22 to i32
		memref.store %tmp_8, %tmp_4[%tmp_7] : memref<4xi32>
		%tmp_9 = arith.constant 2: index
		%tmp_10 = arith.extsi %l_____input2______159_d1_0 : i22 to i32
		memref.store %tmp_10, %tmp_4[%tmp_9] : memref<4xi32>
		%tmp_11 = arith.constant 3: index
		%tmp_12 = arith.extsi %l_____input3______162_d1_0 : i22 to i32
		memref.store %tmp_12, %tmp_4[%tmp_11] : memref<4xi32>
		// l_input__164_d1_0 aliased to tmp_4
		// Action Local Variable Decl: End
		// If Statement: Begin
		%tmp_13 = cal.get(%l_matrix__number__151: !cal.state_ref<i32>) : i32
		// Evaluate global variable num_matrices.
		%tmp_14 = arith.constant 10000 : i14
		%tmp_15 = arith.extui %tmp_14 : i14 to i32
		// Evaluate global variable num_matrices done: assigned to tmp_15 above in this context.
		%tmp_16 = arith.constant 10 : i4
		%tmp_17 = arith.extui %tmp_16 : i4 to i32
		%tmp_18 = arith.subi %tmp_15, %tmp_17 : i32
		%tmp_19 = arith.cmpi eq, %tmp_13, %tmp_18 : i32
		scf.if %tmp_19 {
			// Call Statement: Start
			%tmp_20 = cal.get(%l_matrix__number__151: !cal.state_ref<i32>) : i32
			fifo.print("Q%u: row 3: \00", %tmp_20) : (i32)
			// Call Statement: End
			// Foreach Statement: Begin
			%tmp_21 = arith.constant 0 : i1
			%tmp_22 = arith.extui %tmp_21 : i1 to i32
			%tmp_23_lb = index.casts %tmp_22 : i32 to index
			// Evaluate global variable $eval1.
			%tmp_24 = arith.constant 4 : i3
			%tmp_25 = arith.extui %tmp_24 : i3 to i32
			// Evaluate global variable $eval1 done: assigned to tmp_25 above in this context.
			%tmp_26 = arith.constant 1 : i1
			%tmp_27 = arith.extui %tmp_26 : i1 to i32
			%tmp_28 = arith.subi %tmp_25, %tmp_27 : i32
			%tmp_29_ub = index.casts %tmp_28 : i32 to index
			%tmp_30_step = index.constant 1
			%tmp_31_ub_plus_1 = arith.addi %tmp_29_ub, %tmp_30_step : index
			scf.for %l_index_d2_0 = %tmp_23_lb to %tmp_31_ub_plus_1 step %tmp_30_step
					iter_args() -> () {
				%l_index_d3_0 = arith.index_cast %l_index_d2_0 : index to i32
				%l_index_d3_1 = arith.trunci %l_index_d3_0 : i32 to i8
				// Call Statement: Start
				%tmp_32 = arith.extui %l_index_d3_1 : i8 to i32
				%tmp_33 = arith.index_cast %tmp_32: i32 to index
				%tmp_35 = memref.load %tmp_4[%tmp_33] : memref<4xi32>
				%tmp_34 = arith.trunci %tmp_35 : i32 to i22
				%tmp_36 = arith.extsi %tmp_34 : i22 to i32
				fifo.print("%i \00", %tmp_36) : (i32)
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
		%tmp_37 = cal.get(%l_matrix__number__151: !cal.state_ref<i32>) : i32
		%tmp_38 = arith.constant 1 : i1
		%tmp_39 = arith.extui %tmp_38 : i1 to i32
		%tmp_40 = arith.addi %tmp_37, %tmp_39 : i32
		cal.set(%l_matrix__number__151: !cal.state_ref<i32>, %tmp_40: i32)
		// Assignment Statement: End
		// Assignment Statement: Start
		%tmp_41 = arith.constant 0 : i1
		%tmp_42 = arith.extui %tmp_41 : i1 to i32
		cal.set(%l_$state: !cal.state_ref<i32>, %tmp_42: i32)
		// Assignment Statement: End
		// Output Expression: Start
		%tmp_43 = arith.constant 0 : index
		%tmp_44 = memref.load %tmp_4[%tmp_43] : memref<4xi32>
		%tmp_45 = arith.trunci %tmp_44 : i32 to i22
		fifo.push(%q_out: !fifo.input_port<i22>, %tmp_45: i22)
		%tmp_46 = arith.constant 1 : index
		%tmp_47 = memref.load %tmp_4[%tmp_46] : memref<4xi32>
		%tmp_48 = arith.trunci %tmp_47 : i32 to i22
		fifo.push(%q_out: !fifo.input_port<i22>, %tmp_48: i22)
		%tmp_49 = arith.constant 2 : index
		%tmp_50 = memref.load %tmp_4[%tmp_49] : memref<4xi32>
		%tmp_51 = arith.trunci %tmp_50 : i32 to i22
		fifo.push(%q_out: !fifo.input_port<i22>, %tmp_51: i22)
		%tmp_52 = arith.constant 3 : index
		%tmp_53 = memref.load %tmp_4[%tmp_52] : memref<4xi32>
		%tmp_54 = arith.trunci %tmp_53 : i32 to i22
		fifo.push(%q_out: !fifo.input_port<i22>, %tmp_54: i22)
		// Output Expression: End
	}
}

//-- Definition of actor class: Cap
cal.actor @caps_x_0 ()
	ports_in(%In: !fifo.output_port<i22>)
{
	// -- Actor body
	%l_$state = cal.create_state_var<i32> : !cal.state_ref<i32>
	%tmp_0 = arith.constant 0 : i1
	%tmp_1 = arith.extui %tmp_0 : i1 to i32
	cal.set(%l_$state: !cal.state_ref<i32>, %tmp_1: i32)
	// Generation action: receive
	cal.action "receive" priority=0 {
		// Input Pattern: Start
		%l_t__107_d1_0 = fifo.pop(%In: !fifo.output_port<i22>) : i22
		// Input Pattern: End
		// Assignment Statement: Start
		%tmp_2 = arith.constant 0 : i1
		%tmp_3 = arith.extui %tmp_2 : i1 to i32
		cal.set(%l_$state: !cal.state_ref<i32>, %tmp_3: i32)
		// Assignment Statement: End
	}
}

//-- Definition of actor class: IGenerator
cal.actor @iGenerator_3 ()
	ports_out(%Out: !fifo.input_port<i22>)
{
	// -- Actor body
	%l_row__index__102 = cal.create_state_var<i32> : !cal.state_ref<i32>
	%tmp_0 = arith.constant 0 : i1
	%tmp_1 = arith.extui %tmp_0 : i1 to i32
	cal.set(%l_row__index__102: !cal.state_ref<i32>, %tmp_1: i32)
	%l_total__rows__103 = cal.create_state_var<i32> : !cal.state_ref<i32>
	%tmp_2 = arith.constant 0 : i1
	%tmp_3 = arith.extui %tmp_2 : i1 to i32
	cal.set(%l_total__rows__103: !cal.state_ref<i32>, %tmp_3: i32)
	%l_total__actions__104 = cal.create_state_var<i32> : !cal.state_ref<i32>
	// Evaluate global variable $eval1.
	%tmp_4 = arith.constant 4 : i3
	%tmp_5 = arith.extui %tmp_4 : i3 to i32
	// Evaluate global variable $eval1 done: assigned to tmp_5 above in this context.
	// Evaluate global variable num_matrices.
	%tmp_6 = arith.constant 10000 : i14
	%tmp_7 = arith.extui %tmp_6 : i14 to i32
	// Evaluate global variable num_matrices done: assigned to tmp_7 above in this context.
	%tmp_8 = arith.muli %tmp_5, %tmp_7 : i32
	cal.set(%l_total__actions__104: !cal.state_ref<i32>, %tmp_8: i32)
	%l_$state = cal.create_state_var<i32> : !cal.state_ref<i32>
	%tmp_9 = arith.constant 0 : i1
	%tmp_10 = arith.extui %tmp_9 : i1 to i32
	cal.set(%l_$state: !cal.state_ref<i32>, %tmp_10: i32)
	// Generation action: $untagged0
	cal.action "$untagged0" priority=0 {
		// Guard: Start
		cal.predicate {
			%tmp_11 = cal.get(%l_total__rows__103: !cal.state_ref<i32>) : i32
			%tmp_12 = cal.get(%l_total__actions__104: !cal.state_ref<i32>) : i32
			%tmp_13 = arith.cmpi ult, %tmp_11, %tmp_12 : i32
			cal.predicate_result %tmp_13 : i1
		}
		// Guard: End
		// Action Local Variable Decl: Start
		%tmp_14 = arith.constant 0 : i1
		%tmp_15 = arith.extui %tmp_14 : i1 to i22
		// l_outVal__105_d1_0 aliased to tmp_15
		// Action Local Variable Decl: End
		// If Statement: Begin
		%tmp_16 = cal.get(%l_row__index__102: !cal.state_ref<i32>) : i32
		// Evaluate global variable $eval9.
		%tmp_17 = arith.constant 3 : i2
		%tmp_18 = arith.extui %tmp_17 : i2 to i32
		// Evaluate global variable $eval9 done: assigned to tmp_18 above in this context.
		%tmp_19 = arith.cmpi eq, %tmp_16, %tmp_18 : i32
		%l_outVal__105_d1_1 = scf.if %tmp_19 -> (i22) {
			// Assignment Statement: Start
			// Evaluate global variable fixed_point_one.
			%tmp_20 = arith.constant 524288 : i20
			%tmp_21 = arith.extui %tmp_20 : i20 to i22
			// Evaluate global variable fixed_point_one done: assigned to tmp_21 above in this context.
			// l_outVal__105_d2_0 aliased to tmp_21
			// Assignment Statement: End
			scf.yield %tmp_21 : i22
		} else {
			scf.yield %tmp_15 : i22
		}
		// If Statement: End
		// Assignment Statement: Start
		%tmp_22 = cal.get(%l_row__index__102: !cal.state_ref<i32>) : i32
		%tmp_23 = arith.constant 1 : i1
		%tmp_24 = arith.extui %tmp_23 : i1 to i32
		%tmp_25 = arith.addi %tmp_22, %tmp_24 : i32
		// Evaluate global variable $eval1.
		%tmp_26 = arith.constant 4 : i3
		%tmp_27 = arith.extui %tmp_26 : i3 to i32
		// Evaluate global variable $eval1 done: assigned to tmp_27 above in this context.
		%tmp_28 = arith.remui %tmp_25, %tmp_27 : i32
		cal.set(%l_row__index__102: !cal.state_ref<i32>, %tmp_28: i32)
		// Assignment Statement: End
		// Assignment Statement: Start
		%tmp_29 = cal.get(%l_total__rows__103: !cal.state_ref<i32>) : i32
		%tmp_30 = arith.constant 1 : i1
		%tmp_31 = arith.extui %tmp_30 : i1 to i32
		%tmp_32 = arith.addi %tmp_29, %tmp_31 : i32
		cal.set(%l_total__rows__103: !cal.state_ref<i32>, %tmp_32: i32)
		// Assignment Statement: End
		// Assignment Statement: Start
		%tmp_33 = arith.constant 0 : i1
		%tmp_34 = arith.extui %tmp_33 : i1 to i32
		cal.set(%l_$state: !cal.state_ref<i32>, %tmp_34: i32)
		// Assignment Statement: End
		// Output Expression: Start
		fifo.push(%Out: !fifo.input_port<i22>, %l_outVal__105_d1_1: i22)
		// Output Expression: End
	}
}

//-- Definition of actor class: JoinerRowQ
cal.actor @joinersPerRow_q_2 ()
	ports_in(%r_in_array_0_x: !fifo.output_port<i22>,%r_in_array_1_x: !fifo.output_port<i22>,%r_in_array_2_x: !fifo.output_port<i22>,%r_in_array_3_x: !fifo.output_port<i22>)
	ports_out(%q_out: !fifo.input_port<i22>)
{
	// -- Actor body
	%l_matrix__number__137 = cal.create_state_var<i32> : !cal.state_ref<i32>
	%tmp_0 = arith.constant 0 : i1
	%tmp_1 = arith.extui %tmp_0 : i1 to i32
	cal.set(%l_matrix__number__137: !cal.state_ref<i32>, %tmp_1: i32)
	%l_$state = cal.create_state_var<i32> : !cal.state_ref<i32>
	%tmp_2 = arith.constant 0 : i1
	%tmp_3 = arith.extui %tmp_2 : i1 to i32
	cal.set(%l_$state: !cal.state_ref<i32>, %tmp_3: i32)
	// Generation action: $untagged0
	cal.action "$untagged0" priority=0 {
		// Input Pattern: Start
		%l_____input0______139_d1_0 = fifo.pop(%r_in_array_0_x: !fifo.output_port<i22>) : i22
		// Input Pattern: End
		// Input Pattern: Start
		%l_____input1______142_d1_0 = fifo.pop(%r_in_array_1_x: !fifo.output_port<i22>) : i22
		// Input Pattern: End
		// Input Pattern: Start
		%l_____input2______145_d1_0 = fifo.pop(%r_in_array_2_x: !fifo.output_port<i22>) : i22
		// Input Pattern: End
		// Input Pattern: Start
		%l_____input3______148_d1_0 = fifo.pop(%r_in_array_3_x: !fifo.output_port<i22>) : i22
		// Input Pattern: End
		// Action Local Variable Decl: Start
		%tmp_4 = memref.alloc() : memref<4xi32>
		%tmp_5 = arith.constant 0: index
		%tmp_6 = arith.extsi %l_____input0______139_d1_0 : i22 to i32
		memref.store %tmp_6, %tmp_4[%tmp_5] : memref<4xi32>
		%tmp_7 = arith.constant 1: index
		%tmp_8 = arith.extsi %l_____input1______142_d1_0 : i22 to i32
		memref.store %tmp_8, %tmp_4[%tmp_7] : memref<4xi32>
		%tmp_9 = arith.constant 2: index
		%tmp_10 = arith.extsi %l_____input2______145_d1_0 : i22 to i32
		memref.store %tmp_10, %tmp_4[%tmp_9] : memref<4xi32>
		%tmp_11 = arith.constant 3: index
		%tmp_12 = arith.extsi %l_____input3______148_d1_0 : i22 to i32
		memref.store %tmp_12, %tmp_4[%tmp_11] : memref<4xi32>
		// l_input__150_d1_0 aliased to tmp_4
		// Action Local Variable Decl: End
		// If Statement: Begin
		%tmp_13 = cal.get(%l_matrix__number__137: !cal.state_ref<i32>) : i32
		// Evaluate global variable num_matrices.
		%tmp_14 = arith.constant 10000 : i14
		%tmp_15 = arith.extui %tmp_14 : i14 to i32
		// Evaluate global variable num_matrices done: assigned to tmp_15 above in this context.
		%tmp_16 = arith.constant 10 : i4
		%tmp_17 = arith.extui %tmp_16 : i4 to i32
		%tmp_18 = arith.subi %tmp_15, %tmp_17 : i32
		%tmp_19 = arith.cmpi eq, %tmp_13, %tmp_18 : i32
		scf.if %tmp_19 {
			// Call Statement: Start
			%tmp_20 = cal.get(%l_matrix__number__137: !cal.state_ref<i32>) : i32
			fifo.print("Q%u: row 2: \00", %tmp_20) : (i32)
			// Call Statement: End
			// Foreach Statement: Begin
			%tmp_21 = arith.constant 0 : i1
			%tmp_22 = arith.extui %tmp_21 : i1 to i32
			%tmp_23_lb = index.casts %tmp_22 : i32 to index
			// Evaluate global variable $eval1.
			%tmp_24 = arith.constant 4 : i3
			%tmp_25 = arith.extui %tmp_24 : i3 to i32
			// Evaluate global variable $eval1 done: assigned to tmp_25 above in this context.
			%tmp_26 = arith.constant 1 : i1
			%tmp_27 = arith.extui %tmp_26 : i1 to i32
			%tmp_28 = arith.subi %tmp_25, %tmp_27 : i32
			%tmp_29_ub = index.casts %tmp_28 : i32 to index
			%tmp_30_step = index.constant 1
			%tmp_31_ub_plus_1 = arith.addi %tmp_29_ub, %tmp_30_step : index
			scf.for %l_index_d2_0 = %tmp_23_lb to %tmp_31_ub_plus_1 step %tmp_30_step
					iter_args() -> () {
				%l_index_d3_0 = arith.index_cast %l_index_d2_0 : index to i32
				%l_index_d3_1 = arith.trunci %l_index_d3_0 : i32 to i8
				// Call Statement: Start
				%tmp_32 = arith.extui %l_index_d3_1 : i8 to i32
				%tmp_33 = arith.index_cast %tmp_32: i32 to index
				%tmp_35 = memref.load %tmp_4[%tmp_33] : memref<4xi32>
				%tmp_34 = arith.trunci %tmp_35 : i32 to i22
				%tmp_36 = arith.extsi %tmp_34 : i22 to i32
				fifo.print("%i \00", %tmp_36) : (i32)
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
		%tmp_37 = cal.get(%l_matrix__number__137: !cal.state_ref<i32>) : i32
		%tmp_38 = arith.constant 1 : i1
		%tmp_39 = arith.extui %tmp_38 : i1 to i32
		%tmp_40 = arith.addi %tmp_37, %tmp_39 : i32
		cal.set(%l_matrix__number__137: !cal.state_ref<i32>, %tmp_40: i32)
		// Assignment Statement: End
		// Assignment Statement: Start
		%tmp_41 = arith.constant 0 : i1
		%tmp_42 = arith.extui %tmp_41 : i1 to i32
		cal.set(%l_$state: !cal.state_ref<i32>, %tmp_42: i32)
		// Assignment Statement: End
		// Output Expression: Start
		%tmp_43 = arith.constant 0 : index
		%tmp_44 = memref.load %tmp_4[%tmp_43] : memref<4xi32>
		%tmp_45 = arith.trunci %tmp_44 : i32 to i22
		fifo.push(%q_out: !fifo.input_port<i22>, %tmp_45: i22)
		%tmp_46 = arith.constant 1 : index
		%tmp_47 = memref.load %tmp_4[%tmp_46] : memref<4xi32>
		%tmp_48 = arith.trunci %tmp_47 : i32 to i22
		fifo.push(%q_out: !fifo.input_port<i22>, %tmp_48: i22)
		%tmp_49 = arith.constant 2 : index
		%tmp_50 = memref.load %tmp_4[%tmp_49] : memref<4xi32>
		%tmp_51 = arith.trunci %tmp_50 : i32 to i22
		fifo.push(%q_out: !fifo.input_port<i22>, %tmp_51: i22)
		%tmp_52 = arith.constant 3 : index
		%tmp_53 = memref.load %tmp_4[%tmp_52] : memref<4xi32>
		%tmp_54 = arith.trunci %tmp_53 : i32 to i22
		fifo.push(%q_out: !fifo.input_port<i22>, %tmp_54: i22)
		// Output Expression: End
	}
}

//-- Definition of actor class: Cap
cal.actor @caps_x_2 ()
	ports_in(%In: !fifo.output_port<i22>)
{
	// -- Actor body
	%l_$state = cal.create_state_var<i32> : !cal.state_ref<i32>
	%tmp_0 = arith.constant 0 : i1
	%tmp_1 = arith.extui %tmp_0 : i1 to i32
	cal.set(%l_$state: !cal.state_ref<i32>, %tmp_1: i32)
	// Generation action: receive
	cal.action "receive" priority=0 {
		// Input Pattern: Start
		%l_t__107_d1_0 = fifo.pop(%In: !fifo.output_port<i22>) : i22
		// Input Pattern: End
		// Assignment Statement: Start
		%tmp_2 = arith.constant 0 : i1
		%tmp_3 = arith.extui %tmp_2 : i1 to i32
		cal.set(%l_$state: !cal.state_ref<i32>, %tmp_3: i32)
		// Assignment Statement: End
	}
}

//-- Definition of actor class: Cap
cal.actor @caps_x_1 ()
	ports_in(%In: !fifo.output_port<i22>)
{
	// -- Actor body
	%l_$state = cal.create_state_var<i32> : !cal.state_ref<i32>
	%tmp_0 = arith.constant 0 : i1
	%tmp_1 = arith.extui %tmp_0 : i1 to i32
	cal.set(%l_$state: !cal.state_ref<i32>, %tmp_1: i32)
	// Generation action: receive
	cal.action "receive" priority=0 {
		// Input Pattern: Start
		%l_t__107_d1_0 = fifo.pop(%In: !fifo.output_port<i22>) : i22
		// Input Pattern: End
		// Assignment Statement: Start
		%tmp_2 = arith.constant 0 : i1
		%tmp_3 = arith.extui %tmp_2 : i1 to i32
		cal.set(%l_$state: !cal.state_ref<i32>, %tmp_3: i32)
		// Assignment Statement: End
	}
}

//-- Definition of actor class: IGenerator
cal.actor @iGenerator_0 ()
	ports_out(%Out: !fifo.input_port<i22>)
{
	// -- Actor body
	%l_row__index__90 = cal.create_state_var<i32> : !cal.state_ref<i32>
	%tmp_0 = arith.constant 0 : i1
	%tmp_1 = arith.extui %tmp_0 : i1 to i32
	cal.set(%l_row__index__90: !cal.state_ref<i32>, %tmp_1: i32)
	%l_total__rows__91 = cal.create_state_var<i32> : !cal.state_ref<i32>
	%tmp_2 = arith.constant 0 : i1
	%tmp_3 = arith.extui %tmp_2 : i1 to i32
	cal.set(%l_total__rows__91: !cal.state_ref<i32>, %tmp_3: i32)
	%l_total__actions__92 = cal.create_state_var<i32> : !cal.state_ref<i32>
	// Evaluate global variable $eval1.
	%tmp_4 = arith.constant 4 : i3
	%tmp_5 = arith.extui %tmp_4 : i3 to i32
	// Evaluate global variable $eval1 done: assigned to tmp_5 above in this context.
	// Evaluate global variable num_matrices.
	%tmp_6 = arith.constant 10000 : i14
	%tmp_7 = arith.extui %tmp_6 : i14 to i32
	// Evaluate global variable num_matrices done: assigned to tmp_7 above in this context.
	%tmp_8 = arith.muli %tmp_5, %tmp_7 : i32
	cal.set(%l_total__actions__92: !cal.state_ref<i32>, %tmp_8: i32)
	%l_$state = cal.create_state_var<i32> : !cal.state_ref<i32>
	%tmp_9 = arith.constant 0 : i1
	%tmp_10 = arith.extui %tmp_9 : i1 to i32
	cal.set(%l_$state: !cal.state_ref<i32>, %tmp_10: i32)
	// Generation action: $untagged0
	cal.action "$untagged0" priority=0 {
		// Guard: Start
		cal.predicate {
			%tmp_11 = cal.get(%l_total__rows__91: !cal.state_ref<i32>) : i32
			%tmp_12 = cal.get(%l_total__actions__92: !cal.state_ref<i32>) : i32
			%tmp_13 = arith.cmpi ult, %tmp_11, %tmp_12 : i32
			cal.predicate_result %tmp_13 : i1
		}
		// Guard: End
		// Action Local Variable Decl: Start
		%tmp_14 = arith.constant 0 : i1
		%tmp_15 = arith.extui %tmp_14 : i1 to i22
		// l_outVal__93_d1_0 aliased to tmp_15
		// Action Local Variable Decl: End
		// If Statement: Begin
		%tmp_16 = cal.get(%l_row__index__90: !cal.state_ref<i32>) : i32
		// Evaluate global variable $eval3.
		%tmp_17 = arith.constant 0 : i1
		%tmp_18 = arith.extui %tmp_17 : i1 to i32
		// Evaluate global variable $eval3 done: assigned to tmp_18 above in this context.
		%tmp_19 = arith.cmpi eq, %tmp_16, %tmp_18 : i32
		%l_outVal__93_d1_1 = scf.if %tmp_19 -> (i22) {
			// Assignment Statement: Start
			// Evaluate global variable fixed_point_one.
			%tmp_20 = arith.constant 524288 : i20
			%tmp_21 = arith.extui %tmp_20 : i20 to i22
			// Evaluate global variable fixed_point_one done: assigned to tmp_21 above in this context.
			// l_outVal__93_d2_0 aliased to tmp_21
			// Assignment Statement: End
			scf.yield %tmp_21 : i22
		} else {
			scf.yield %tmp_15 : i22
		}
		// If Statement: End
		// Assignment Statement: Start
		%tmp_22 = cal.get(%l_row__index__90: !cal.state_ref<i32>) : i32
		%tmp_23 = arith.constant 1 : i1
		%tmp_24 = arith.extui %tmp_23 : i1 to i32
		%tmp_25 = arith.addi %tmp_22, %tmp_24 : i32
		// Evaluate global variable $eval1.
		%tmp_26 = arith.constant 4 : i3
		%tmp_27 = arith.extui %tmp_26 : i3 to i32
		// Evaluate global variable $eval1 done: assigned to tmp_27 above in this context.
		%tmp_28 = arith.remui %tmp_25, %tmp_27 : i32
		cal.set(%l_row__index__90: !cal.state_ref<i32>, %tmp_28: i32)
		// Assignment Statement: End
		// Assignment Statement: Start
		%tmp_29 = cal.get(%l_total__rows__91: !cal.state_ref<i32>) : i32
		%tmp_30 = arith.constant 1 : i1
		%tmp_31 = arith.extui %tmp_30 : i1 to i32
		%tmp_32 = arith.addi %tmp_29, %tmp_31 : i32
		cal.set(%l_total__rows__91: !cal.state_ref<i32>, %tmp_32: i32)
		// Assignment Statement: End
		// Assignment Statement: Start
		%tmp_33 = arith.constant 0 : i1
		%tmp_34 = arith.extui %tmp_33 : i1 to i32
		cal.set(%l_$state: !cal.state_ref<i32>, %tmp_34: i32)
		// Assignment Statement: End
		// Output Expression: Start
		fifo.push(%Out: !fifo.input_port<i22>, %l_outVal__93_d1_1: i22)
		// Output Expression: End
	}
}

//-- Definition of actor class: Cap
cal.actor @caps_x_3 ()
	ports_in(%In: !fifo.output_port<i22>)
{
	// -- Actor body
	%l_$state = cal.create_state_var<i32> : !cal.state_ref<i32>
	%tmp_0 = arith.constant 0 : i1
	%tmp_1 = arith.extui %tmp_0 : i1 to i32
	cal.set(%l_$state: !cal.state_ref<i32>, %tmp_1: i32)
	// Generation action: receive
	cal.action "receive" priority=0 {
		// Input Pattern: Start
		%l_t__107_d1_0 = fifo.pop(%In: !fifo.output_port<i22>) : i22
		// Input Pattern: End
		// Assignment Statement: Start
		%tmp_2 = arith.constant 0 : i1
		%tmp_3 = arith.extui %tmp_2 : i1 to i32
		cal.set(%l_$state: !cal.state_ref<i32>, %tmp_3: i32)
		// Assignment Statement: End
	}
}

//-- Definition of actor class: InnerCell
cal.actor @innerCells_r_0 ()
	ports_in(%x_in: !fifo.output_port<i22>,%cordic_angles_in: !fifo.output_port<i16>)
	ports_out(%x_out: !fifo.input_port<i22>,%r_out: !fifo.input_port<i22>,%cordic_angles_out: !fifo.input_port<i16>)
{
	// -- Actor body
	%l_r__63 = cal.create_state_var<i22> : !cal.state_ref<i22>
	%tmp_0 = arith.constant 0 : i1
	%tmp_1 = arith.extui %tmp_0 : i1 to i22
	cal.set(%l_r__63: !cal.state_ref<i22>, %tmp_1: i22)
	%l_count__64 = cal.create_state_var<i32> : !cal.state_ref<i32>
	%tmp_2 = arith.constant 0 : i1
	%tmp_3 = arith.extui %tmp_2 : i1 to i32
	cal.set(%l_count__64: !cal.state_ref<i32>, %tmp_3: i32)
	%l_$state = cal.create_state_var<i32> : !cal.state_ref<i32>
	%tmp_4 = arith.constant 0 : i1
	%tmp_5 = arith.extui %tmp_4 : i1 to i32
	cal.set(%l_$state: !cal.state_ref<i32>, %tmp_5: i32)
	// Generation action: normal
	cal.action "normal" priority=0 {
		// Guard: Start
		cal.predicate {
			%tmp_6 = cal.get(%l_count__64: !cal.state_ref<i32>) : i32
			// Evaluate global variable $eval1.
			%tmp_7 = arith.constant 4 : i3
			%tmp_8 = arith.extui %tmp_7 : i3 to i32
			// Evaluate global variable $eval1 done: assigned to tmp_8 above in this context.
			%tmp_9 = arith.cmpi ult, %tmp_6, %tmp_8 : i32
			cal.predicate_result %tmp_9 : i1
		}
		// Guard: End
		// Input Pattern: Start
		%l_x__in__66_d1_0 = fifo.pop(%x_in: !fifo.output_port<i22>) : i22
		// Input Pattern: End
		// Input Pattern: Start
		%l_rotation__angles__69_d1_0 = fifo.pop(%cordic_angles_in: !fifo.output_port<i16>) : i16
		// Input Pattern: End
		// Action Local Variable Decl: Start
		%l_x__out__71_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_x__j__72_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_x__j__plus__1__73_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_x__j__shifted__74_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_y__j__75_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_y__j__plus__1__76_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_y__j__shifted__77_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// If Statement: Begin
		%tmp_10 = cal.get(%l_count__64: !cal.state_ref<i32>) : i32
		%tmp_11 = arith.constant 0 : i1
		%tmp_12 = arith.extui %tmp_11 : i1 to i32
		%tmp_13 = arith.cmpi eq, %tmp_10, %tmp_12 : i32
		scf.if %tmp_13 {
			// Assignment Statement: Start
			%tmp_14 = arith.constant 0 : i1
			%tmp_15 = arith.extui %tmp_14 : i1 to i22
			cal.set(%l_r__63: !cal.state_ref<i22>, %tmp_15: i22)
			// Assignment Statement: End
		} else {
		}
		// If Statement: End
		// Assignment Statement: Start
		// l_x__j__72_d1_1 aliased to l_x__in__66_d1_0
		// Assignment Statement: End
		// Assignment Statement: Start
		%tmp_16 = cal.get(%l_r__63: !cal.state_ref<i22>) : i22
		// l_y__j__75_d1_1 aliased to tmp_16
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
		%l_x__j__72_d1_2, %l_x__j__plus__1__73_d1_1, %l_x__j__shifted__74_d1_1, %l_y__j__75_d1_2, %l_y__j__plus__1__76_d1_1, %l_y__j__shifted__77_d1_1 = scf.for %l_j_d1_0 = %tmp_19_lb to %tmp_27_ub_plus_1 step %tmp_26_step
				iter_args(%l_x__j__72_d2_0 = %l_x__in__66_d1_0, %l_x__j__plus__1__73_d2_0 = %l_x__j__plus__1__73_d1_0, %l_x__j__shifted__74_d2_0 = %l_x__j__shifted__74_d1_0, %l_y__j__75_d2_0 = %tmp_16, %l_y__j__plus__1__76_d2_0 = %l_y__j__plus__1__76_d1_0, %l_y__j__shifted__77_d2_0 = %l_y__j__shifted__77_d1_0) -> (i22, i22, i22, i22, i22, i22) {
			%l_j_d2_0 = arith.index_cast %l_j_d1_0 : index to i32
			%l_j_d2_1 = arith.trunci %l_j_d2_0 : i32 to i8
			// Assignment Statement: Start
			%tmp_28 = arith.extui %l_j_d2_1 : i8 to i22
			%tmp_29 = arith.shrsi %l_y__j__75_d2_0, %tmp_28 : i22
			// l_y__j__shifted__77_d2_1 aliased to tmp_29
			// Assignment Statement: End
			// Assignment Statement: Start
			%tmp_30 = arith.extui %l_j_d2_1 : i8 to i22
			%tmp_31 = arith.shrsi %l_x__j__72_d2_0, %tmp_30 : i22
			// l_x__j__shifted__74_d2_1 aliased to tmp_31
			// Assignment Statement: End
			// If Statement: Begin
			%tmp_32 = arith.extui %l_j_d2_1 : i8 to i16
			%tmp_33 = arith.shrui %l_rotation__angles__69_d1_0, %tmp_32 : i16
			%tmp_34 = arith.constant 1 : i1
			%tmp_35 = arith.trunci %tmp_33 : i16 to i1
			%tmp_36 = arith.andi %tmp_35, %tmp_34 : i1
			%tmp_37 = arith.constant 1 : i1
			%tmp_38 = arith.cmpi eq, %tmp_36, %tmp_37 : i1
			%l_x__j__plus__1__73_d2_1, %l_y__j__plus__1__76_d2_1 = scf.if %tmp_38 -> (i22, i22) {
				// Assignment Statement: Start
				%tmp_39 = arith.extsi %l_x__j__72_d2_0 : i22 to i23
				%tmp_40 = arith.extsi %tmp_29 : i22 to i23
				%tmp_41 = arith.addi %tmp_39, %tmp_40 : i23
				%tmp_42 = arith.trunci %tmp_41 : i23 to i22
				// l_x__j__plus__1__73_d3_0 aliased to tmp_42
				// Assignment Statement: End
				// Assignment Statement: Start
				%tmp_43 = arith.subi %l_y__j__75_d2_0, %tmp_31 : i22
				// l_y__j__plus__1__76_d3_0 aliased to tmp_43
				// Assignment Statement: End
				scf.yield %tmp_42, %tmp_43 : i22, i22
			} else {
				// Assignment Statement: Start
				%tmp_44 = arith.subi %l_x__j__72_d2_0, %tmp_29 : i22
				// l_x__j__plus__1__73_d3_0 aliased to tmp_44
				// Assignment Statement: End
				// Assignment Statement: Start
				%tmp_45 = arith.extsi %l_y__j__75_d2_0 : i22 to i23
				%tmp_46 = arith.extsi %tmp_31 : i22 to i23
				%tmp_47 = arith.addi %tmp_45, %tmp_46 : i23
				%tmp_48 = arith.trunci %tmp_47 : i23 to i22
				// l_y__j__plus__1__76_d3_0 aliased to tmp_48
				// Assignment Statement: End
				scf.yield %tmp_44, %tmp_48 : i22, i22
			}
			// If Statement: End
			// Assignment Statement: Start
			// l_x__j__72_d2_1 aliased to l_x__j__plus__1__73_d2_1
			// Assignment Statement: End
			// Assignment Statement: Start
			// l_y__j__75_d2_1 aliased to l_y__j__plus__1__76_d2_1
			// Assignment Statement: End
			scf.yield %l_x__j__plus__1__73_d2_1, %l_x__j__plus__1__73_d2_1, %tmp_31, %l_y__j__plus__1__76_d2_1, %l_y__j__plus__1__76_d2_1, %tmp_29 : i22, i22, i22, i22, i22, i22
		}
		// Foreach Statement: End
		// Assignment Statement: Start
		// Evaluate global variable k_CORDIC_constant.
		%tmp_50 = arith.constant 318375 : i19
		%tmp_51 = arith.extui %tmp_50 : i19 to i22
		// Evaluate global variable k_CORDIC_constant done: assigned to tmp_51 above in this context.
		// Evaluate global variable fixedPointMultiply.
		%tmp_49 = func.call @g_qrd_fixedPointMultiply(%tmp_51,%l_y__j__75_d1_2) : (i22,i22) -> i22
		// l_x__out__71_d1_1 aliased to tmp_49
		// Assignment Statement: End
		// Assignment Statement: Start
		// Evaluate global variable k_CORDIC_constant.
		%tmp_53 = arith.constant 318375 : i19
		%tmp_54 = arith.extui %tmp_53 : i19 to i22
		// Evaluate global variable k_CORDIC_constant done: assigned to tmp_54 above in this context.
		// Evaluate global variable fixedPointMultiply.
		%tmp_52 = func.call @g_qrd_fixedPointMultiply(%tmp_54,%l_x__j__72_d1_2) : (i22,i22) -> i22
		cal.set(%l_r__63: !cal.state_ref<i22>, %tmp_52: i22)
		// Assignment Statement: End
		// Assignment Statement: Start
		%tmp_55 = cal.get(%l_count__64: !cal.state_ref<i32>) : i32
		%tmp_56 = arith.constant 1 : i1
		%tmp_57 = arith.extui %tmp_56 : i1 to i32
		%tmp_58 = arith.addi %tmp_55, %tmp_57 : i32
		cal.set(%l_count__64: !cal.state_ref<i32>, %tmp_58: i32)
		// Assignment Statement: End
		// Assignment Statement: Start
		%tmp_59 = arith.constant 0 : i1
		%tmp_60 = arith.extui %tmp_59 : i1 to i32
		cal.set(%l_$state: !cal.state_ref<i32>, %tmp_60: i32)
		// Assignment Statement: End
		// Output Expression: Start
		fifo.push(%x_out: !fifo.input_port<i22>, %tmp_49: i22)
		// Output Expression: End
		// Output Expression: Start
		fifo.push(%cordic_angles_out: !fifo.input_port<i16>, %l_rotation__angles__69_d1_0: i16)
		// Output Expression: End
	}
	// Generation action: final
	cal.action "final" priority=0 {
		// Guard: Start
		cal.predicate {
			%tmp_61 = cal.get(%l_count__64: !cal.state_ref<i32>) : i32
			// Evaluate global variable $eval1.
			%tmp_62 = arith.constant 4 : i3
			%tmp_63 = arith.extui %tmp_62 : i3 to i32
			// Evaluate global variable $eval1 done: assigned to tmp_63 above in this context.
			%tmp_64 = arith.cmpi eq, %tmp_61, %tmp_63 : i32
			cal.predicate_result %tmp_64 : i1
		}
		// Guard: End
		// Assignment Statement: Start
		%tmp_65 = arith.constant 0 : i1
		%tmp_66 = arith.extui %tmp_65 : i1 to i32
		cal.set(%l_count__64: !cal.state_ref<i32>, %tmp_66: i32)
		// Assignment Statement: End
		// Assignment Statement: Start
		%tmp_67 = arith.constant 0 : i1
		%tmp_68 = arith.extui %tmp_67 : i1 to i32
		cal.set(%l_$state: !cal.state_ref<i32>, %tmp_68: i32)
		// Assignment Statement: End
		// Output Expression: Start
		%tmp_69 = cal.get(%l_r__63: !cal.state_ref<i22>) : i22
		fifo.push(%r_out: !fifo.input_port<i22>, %tmp_69: i22)
		// Output Expression: End
	}
}

//-- Definition of actor class: InnerCell
cal.actor @innerCells_q_11 ()
	ports_in(%x_in: !fifo.output_port<i22>,%cordic_angles_in: !fifo.output_port<i16>)
	ports_out(%x_out: !fifo.input_port<i22>,%r_out: !fifo.input_port<i22>,%cordic_angles_out: !fifo.input_port<i16>)
{
	// -- Actor body
	%l_r__63 = cal.create_state_var<i22> : !cal.state_ref<i22>
	%tmp_0 = arith.constant 0 : i1
	%tmp_1 = arith.extui %tmp_0 : i1 to i22
	cal.set(%l_r__63: !cal.state_ref<i22>, %tmp_1: i22)
	%l_count__64 = cal.create_state_var<i32> : !cal.state_ref<i32>
	%tmp_2 = arith.constant 0 : i1
	%tmp_3 = arith.extui %tmp_2 : i1 to i32
	cal.set(%l_count__64: !cal.state_ref<i32>, %tmp_3: i32)
	%l_$state = cal.create_state_var<i32> : !cal.state_ref<i32>
	%tmp_4 = arith.constant 0 : i1
	%tmp_5 = arith.extui %tmp_4 : i1 to i32
	cal.set(%l_$state: !cal.state_ref<i32>, %tmp_5: i32)
	// Generation action: normal
	cal.action "normal" priority=0 {
		// Guard: Start
		cal.predicate {
			%tmp_6 = cal.get(%l_count__64: !cal.state_ref<i32>) : i32
			// Evaluate global variable $eval1.
			%tmp_7 = arith.constant 4 : i3
			%tmp_8 = arith.extui %tmp_7 : i3 to i32
			// Evaluate global variable $eval1 done: assigned to tmp_8 above in this context.
			%tmp_9 = arith.cmpi ult, %tmp_6, %tmp_8 : i32
			cal.predicate_result %tmp_9 : i1
		}
		// Guard: End
		// Input Pattern: Start
		%l_x__in__66_d1_0 = fifo.pop(%x_in: !fifo.output_port<i22>) : i22
		// Input Pattern: End
		// Input Pattern: Start
		%l_rotation__angles__69_d1_0 = fifo.pop(%cordic_angles_in: !fifo.output_port<i16>) : i16
		// Input Pattern: End
		// Action Local Variable Decl: Start
		%l_x__out__71_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_x__j__72_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_x__j__plus__1__73_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_x__j__shifted__74_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_y__j__75_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_y__j__plus__1__76_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_y__j__shifted__77_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// If Statement: Begin
		%tmp_10 = cal.get(%l_count__64: !cal.state_ref<i32>) : i32
		%tmp_11 = arith.constant 0 : i1
		%tmp_12 = arith.extui %tmp_11 : i1 to i32
		%tmp_13 = arith.cmpi eq, %tmp_10, %tmp_12 : i32
		scf.if %tmp_13 {
			// Assignment Statement: Start
			%tmp_14 = arith.constant 0 : i1
			%tmp_15 = arith.extui %tmp_14 : i1 to i22
			cal.set(%l_r__63: !cal.state_ref<i22>, %tmp_15: i22)
			// Assignment Statement: End
		} else {
		}
		// If Statement: End
		// Assignment Statement: Start
		// l_x__j__72_d1_1 aliased to l_x__in__66_d1_0
		// Assignment Statement: End
		// Assignment Statement: Start
		%tmp_16 = cal.get(%l_r__63: !cal.state_ref<i22>) : i22
		// l_y__j__75_d1_1 aliased to tmp_16
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
		%l_x__j__72_d1_2, %l_x__j__plus__1__73_d1_1, %l_x__j__shifted__74_d1_1, %l_y__j__75_d1_2, %l_y__j__plus__1__76_d1_1, %l_y__j__shifted__77_d1_1 = scf.for %l_j_d1_0 = %tmp_19_lb to %tmp_27_ub_plus_1 step %tmp_26_step
				iter_args(%l_x__j__72_d2_0 = %l_x__in__66_d1_0, %l_x__j__plus__1__73_d2_0 = %l_x__j__plus__1__73_d1_0, %l_x__j__shifted__74_d2_0 = %l_x__j__shifted__74_d1_0, %l_y__j__75_d2_0 = %tmp_16, %l_y__j__plus__1__76_d2_0 = %l_y__j__plus__1__76_d1_0, %l_y__j__shifted__77_d2_0 = %l_y__j__shifted__77_d1_0) -> (i22, i22, i22, i22, i22, i22) {
			%l_j_d2_0 = arith.index_cast %l_j_d1_0 : index to i32
			%l_j_d2_1 = arith.trunci %l_j_d2_0 : i32 to i8
			// Assignment Statement: Start
			%tmp_28 = arith.extui %l_j_d2_1 : i8 to i22
			%tmp_29 = arith.shrsi %l_y__j__75_d2_0, %tmp_28 : i22
			// l_y__j__shifted__77_d2_1 aliased to tmp_29
			// Assignment Statement: End
			// Assignment Statement: Start
			%tmp_30 = arith.extui %l_j_d2_1 : i8 to i22
			%tmp_31 = arith.shrsi %l_x__j__72_d2_0, %tmp_30 : i22
			// l_x__j__shifted__74_d2_1 aliased to tmp_31
			// Assignment Statement: End
			// If Statement: Begin
			%tmp_32 = arith.extui %l_j_d2_1 : i8 to i16
			%tmp_33 = arith.shrui %l_rotation__angles__69_d1_0, %tmp_32 : i16
			%tmp_34 = arith.constant 1 : i1
			%tmp_35 = arith.trunci %tmp_33 : i16 to i1
			%tmp_36 = arith.andi %tmp_35, %tmp_34 : i1
			%tmp_37 = arith.constant 1 : i1
			%tmp_38 = arith.cmpi eq, %tmp_36, %tmp_37 : i1
			%l_x__j__plus__1__73_d2_1, %l_y__j__plus__1__76_d2_1 = scf.if %tmp_38 -> (i22, i22) {
				// Assignment Statement: Start
				%tmp_39 = arith.extsi %l_x__j__72_d2_0 : i22 to i23
				%tmp_40 = arith.extsi %tmp_29 : i22 to i23
				%tmp_41 = arith.addi %tmp_39, %tmp_40 : i23
				%tmp_42 = arith.trunci %tmp_41 : i23 to i22
				// l_x__j__plus__1__73_d3_0 aliased to tmp_42
				// Assignment Statement: End
				// Assignment Statement: Start
				%tmp_43 = arith.subi %l_y__j__75_d2_0, %tmp_31 : i22
				// l_y__j__plus__1__76_d3_0 aliased to tmp_43
				// Assignment Statement: End
				scf.yield %tmp_42, %tmp_43 : i22, i22
			} else {
				// Assignment Statement: Start
				%tmp_44 = arith.subi %l_x__j__72_d2_0, %tmp_29 : i22
				// l_x__j__plus__1__73_d3_0 aliased to tmp_44
				// Assignment Statement: End
				// Assignment Statement: Start
				%tmp_45 = arith.extsi %l_y__j__75_d2_0 : i22 to i23
				%tmp_46 = arith.extsi %tmp_31 : i22 to i23
				%tmp_47 = arith.addi %tmp_45, %tmp_46 : i23
				%tmp_48 = arith.trunci %tmp_47 : i23 to i22
				// l_y__j__plus__1__76_d3_0 aliased to tmp_48
				// Assignment Statement: End
				scf.yield %tmp_44, %tmp_48 : i22, i22
			}
			// If Statement: End
			// Assignment Statement: Start
			// l_x__j__72_d2_1 aliased to l_x__j__plus__1__73_d2_1
			// Assignment Statement: End
			// Assignment Statement: Start
			// l_y__j__75_d2_1 aliased to l_y__j__plus__1__76_d2_1
			// Assignment Statement: End
			scf.yield %l_x__j__plus__1__73_d2_1, %l_x__j__plus__1__73_d2_1, %tmp_31, %l_y__j__plus__1__76_d2_1, %l_y__j__plus__1__76_d2_1, %tmp_29 : i22, i22, i22, i22, i22, i22
		}
		// Foreach Statement: End
		// Assignment Statement: Start
		// Evaluate global variable k_CORDIC_constant.
		%tmp_50 = arith.constant 318375 : i19
		%tmp_51 = arith.extui %tmp_50 : i19 to i22
		// Evaluate global variable k_CORDIC_constant done: assigned to tmp_51 above in this context.
		// Evaluate global variable fixedPointMultiply.
		%tmp_49 = func.call @g_qrd_fixedPointMultiply(%tmp_51,%l_y__j__75_d1_2) : (i22,i22) -> i22
		// l_x__out__71_d1_1 aliased to tmp_49
		// Assignment Statement: End
		// Assignment Statement: Start
		// Evaluate global variable k_CORDIC_constant.
		%tmp_53 = arith.constant 318375 : i19
		%tmp_54 = arith.extui %tmp_53 : i19 to i22
		// Evaluate global variable k_CORDIC_constant done: assigned to tmp_54 above in this context.
		// Evaluate global variable fixedPointMultiply.
		%tmp_52 = func.call @g_qrd_fixedPointMultiply(%tmp_54,%l_x__j__72_d1_2) : (i22,i22) -> i22
		cal.set(%l_r__63: !cal.state_ref<i22>, %tmp_52: i22)
		// Assignment Statement: End
		// Assignment Statement: Start
		%tmp_55 = cal.get(%l_count__64: !cal.state_ref<i32>) : i32
		%tmp_56 = arith.constant 1 : i1
		%tmp_57 = arith.extui %tmp_56 : i1 to i32
		%tmp_58 = arith.addi %tmp_55, %tmp_57 : i32
		cal.set(%l_count__64: !cal.state_ref<i32>, %tmp_58: i32)
		// Assignment Statement: End
		// Assignment Statement: Start
		%tmp_59 = arith.constant 0 : i1
		%tmp_60 = arith.extui %tmp_59 : i1 to i32
		cal.set(%l_$state: !cal.state_ref<i32>, %tmp_60: i32)
		// Assignment Statement: End
		// Output Expression: Start
		fifo.push(%x_out: !fifo.input_port<i22>, %tmp_49: i22)
		// Output Expression: End
		// Output Expression: Start
		fifo.push(%cordic_angles_out: !fifo.input_port<i16>, %l_rotation__angles__69_d1_0: i16)
		// Output Expression: End
	}
	// Generation action: final
	cal.action "final" priority=0 {
		// Guard: Start
		cal.predicate {
			%tmp_61 = cal.get(%l_count__64: !cal.state_ref<i32>) : i32
			// Evaluate global variable $eval1.
			%tmp_62 = arith.constant 4 : i3
			%tmp_63 = arith.extui %tmp_62 : i3 to i32
			// Evaluate global variable $eval1 done: assigned to tmp_63 above in this context.
			%tmp_64 = arith.cmpi eq, %tmp_61, %tmp_63 : i32
			cal.predicate_result %tmp_64 : i1
		}
		// Guard: End
		// Assignment Statement: Start
		%tmp_65 = arith.constant 0 : i1
		%tmp_66 = arith.extui %tmp_65 : i1 to i32
		cal.set(%l_count__64: !cal.state_ref<i32>, %tmp_66: i32)
		// Assignment Statement: End
		// Assignment Statement: Start
		%tmp_67 = arith.constant 0 : i1
		%tmp_68 = arith.extui %tmp_67 : i1 to i32
		cal.set(%l_$state: !cal.state_ref<i32>, %tmp_68: i32)
		// Assignment Statement: End
		// Output Expression: Start
		%tmp_69 = cal.get(%l_r__63: !cal.state_ref<i22>) : i22
		fifo.push(%r_out: !fifo.input_port<i22>, %tmp_69: i22)
		// Output Expression: End
	}
}

//-- Definition of actor class: InnerCell
cal.actor @innerCells_q_12 ()
	ports_in(%x_in: !fifo.output_port<i22>,%cordic_angles_in: !fifo.output_port<i16>)
	ports_out(%x_out: !fifo.input_port<i22>,%r_out: !fifo.input_port<i22>,%cordic_angles_out: !fifo.input_port<i16>)
{
	// -- Actor body
	%l_r__63 = cal.create_state_var<i22> : !cal.state_ref<i22>
	%tmp_0 = arith.constant 0 : i1
	%tmp_1 = arith.extui %tmp_0 : i1 to i22
	cal.set(%l_r__63: !cal.state_ref<i22>, %tmp_1: i22)
	%l_count__64 = cal.create_state_var<i32> : !cal.state_ref<i32>
	%tmp_2 = arith.constant 0 : i1
	%tmp_3 = arith.extui %tmp_2 : i1 to i32
	cal.set(%l_count__64: !cal.state_ref<i32>, %tmp_3: i32)
	%l_$state = cal.create_state_var<i32> : !cal.state_ref<i32>
	%tmp_4 = arith.constant 0 : i1
	%tmp_5 = arith.extui %tmp_4 : i1 to i32
	cal.set(%l_$state: !cal.state_ref<i32>, %tmp_5: i32)
	// Generation action: normal
	cal.action "normal" priority=0 {
		// Guard: Start
		cal.predicate {
			%tmp_6 = cal.get(%l_count__64: !cal.state_ref<i32>) : i32
			// Evaluate global variable $eval1.
			%tmp_7 = arith.constant 4 : i3
			%tmp_8 = arith.extui %tmp_7 : i3 to i32
			// Evaluate global variable $eval1 done: assigned to tmp_8 above in this context.
			%tmp_9 = arith.cmpi ult, %tmp_6, %tmp_8 : i32
			cal.predicate_result %tmp_9 : i1
		}
		// Guard: End
		// Input Pattern: Start
		%l_x__in__66_d1_0 = fifo.pop(%x_in: !fifo.output_port<i22>) : i22
		// Input Pattern: End
		// Input Pattern: Start
		%l_rotation__angles__69_d1_0 = fifo.pop(%cordic_angles_in: !fifo.output_port<i16>) : i16
		// Input Pattern: End
		// Action Local Variable Decl: Start
		%l_x__out__71_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_x__j__72_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_x__j__plus__1__73_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_x__j__shifted__74_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_y__j__75_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_y__j__plus__1__76_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_y__j__shifted__77_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// If Statement: Begin
		%tmp_10 = cal.get(%l_count__64: !cal.state_ref<i32>) : i32
		%tmp_11 = arith.constant 0 : i1
		%tmp_12 = arith.extui %tmp_11 : i1 to i32
		%tmp_13 = arith.cmpi eq, %tmp_10, %tmp_12 : i32
		scf.if %tmp_13 {
			// Assignment Statement: Start
			%tmp_14 = arith.constant 0 : i1
			%tmp_15 = arith.extui %tmp_14 : i1 to i22
			cal.set(%l_r__63: !cal.state_ref<i22>, %tmp_15: i22)
			// Assignment Statement: End
		} else {
		}
		// If Statement: End
		// Assignment Statement: Start
		// l_x__j__72_d1_1 aliased to l_x__in__66_d1_0
		// Assignment Statement: End
		// Assignment Statement: Start
		%tmp_16 = cal.get(%l_r__63: !cal.state_ref<i22>) : i22
		// l_y__j__75_d1_1 aliased to tmp_16
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
		%l_x__j__72_d1_2, %l_x__j__plus__1__73_d1_1, %l_x__j__shifted__74_d1_1, %l_y__j__75_d1_2, %l_y__j__plus__1__76_d1_1, %l_y__j__shifted__77_d1_1 = scf.for %l_j_d1_0 = %tmp_19_lb to %tmp_27_ub_plus_1 step %tmp_26_step
				iter_args(%l_x__j__72_d2_0 = %l_x__in__66_d1_0, %l_x__j__plus__1__73_d2_0 = %l_x__j__plus__1__73_d1_0, %l_x__j__shifted__74_d2_0 = %l_x__j__shifted__74_d1_0, %l_y__j__75_d2_0 = %tmp_16, %l_y__j__plus__1__76_d2_0 = %l_y__j__plus__1__76_d1_0, %l_y__j__shifted__77_d2_0 = %l_y__j__shifted__77_d1_0) -> (i22, i22, i22, i22, i22, i22) {
			%l_j_d2_0 = arith.index_cast %l_j_d1_0 : index to i32
			%l_j_d2_1 = arith.trunci %l_j_d2_0 : i32 to i8
			// Assignment Statement: Start
			%tmp_28 = arith.extui %l_j_d2_1 : i8 to i22
			%tmp_29 = arith.shrsi %l_y__j__75_d2_0, %tmp_28 : i22
			// l_y__j__shifted__77_d2_1 aliased to tmp_29
			// Assignment Statement: End
			// Assignment Statement: Start
			%tmp_30 = arith.extui %l_j_d2_1 : i8 to i22
			%tmp_31 = arith.shrsi %l_x__j__72_d2_0, %tmp_30 : i22
			// l_x__j__shifted__74_d2_1 aliased to tmp_31
			// Assignment Statement: End
			// If Statement: Begin
			%tmp_32 = arith.extui %l_j_d2_1 : i8 to i16
			%tmp_33 = arith.shrui %l_rotation__angles__69_d1_0, %tmp_32 : i16
			%tmp_34 = arith.constant 1 : i1
			%tmp_35 = arith.trunci %tmp_33 : i16 to i1
			%tmp_36 = arith.andi %tmp_35, %tmp_34 : i1
			%tmp_37 = arith.constant 1 : i1
			%tmp_38 = arith.cmpi eq, %tmp_36, %tmp_37 : i1
			%l_x__j__plus__1__73_d2_1, %l_y__j__plus__1__76_d2_1 = scf.if %tmp_38 -> (i22, i22) {
				// Assignment Statement: Start
				%tmp_39 = arith.extsi %l_x__j__72_d2_0 : i22 to i23
				%tmp_40 = arith.extsi %tmp_29 : i22 to i23
				%tmp_41 = arith.addi %tmp_39, %tmp_40 : i23
				%tmp_42 = arith.trunci %tmp_41 : i23 to i22
				// l_x__j__plus__1__73_d3_0 aliased to tmp_42
				// Assignment Statement: End
				// Assignment Statement: Start
				%tmp_43 = arith.subi %l_y__j__75_d2_0, %tmp_31 : i22
				// l_y__j__plus__1__76_d3_0 aliased to tmp_43
				// Assignment Statement: End
				scf.yield %tmp_42, %tmp_43 : i22, i22
			} else {
				// Assignment Statement: Start
				%tmp_44 = arith.subi %l_x__j__72_d2_0, %tmp_29 : i22
				// l_x__j__plus__1__73_d3_0 aliased to tmp_44
				// Assignment Statement: End
				// Assignment Statement: Start
				%tmp_45 = arith.extsi %l_y__j__75_d2_0 : i22 to i23
				%tmp_46 = arith.extsi %tmp_31 : i22 to i23
				%tmp_47 = arith.addi %tmp_45, %tmp_46 : i23
				%tmp_48 = arith.trunci %tmp_47 : i23 to i22
				// l_y__j__plus__1__76_d3_0 aliased to tmp_48
				// Assignment Statement: End
				scf.yield %tmp_44, %tmp_48 : i22, i22
			}
			// If Statement: End
			// Assignment Statement: Start
			// l_x__j__72_d2_1 aliased to l_x__j__plus__1__73_d2_1
			// Assignment Statement: End
			// Assignment Statement: Start
			// l_y__j__75_d2_1 aliased to l_y__j__plus__1__76_d2_1
			// Assignment Statement: End
			scf.yield %l_x__j__plus__1__73_d2_1, %l_x__j__plus__1__73_d2_1, %tmp_31, %l_y__j__plus__1__76_d2_1, %l_y__j__plus__1__76_d2_1, %tmp_29 : i22, i22, i22, i22, i22, i22
		}
		// Foreach Statement: End
		// Assignment Statement: Start
		// Evaluate global variable k_CORDIC_constant.
		%tmp_50 = arith.constant 318375 : i19
		%tmp_51 = arith.extui %tmp_50 : i19 to i22
		// Evaluate global variable k_CORDIC_constant done: assigned to tmp_51 above in this context.
		// Evaluate global variable fixedPointMultiply.
		%tmp_49 = func.call @g_qrd_fixedPointMultiply(%tmp_51,%l_y__j__75_d1_2) : (i22,i22) -> i22
		// l_x__out__71_d1_1 aliased to tmp_49
		// Assignment Statement: End
		// Assignment Statement: Start
		// Evaluate global variable k_CORDIC_constant.
		%tmp_53 = arith.constant 318375 : i19
		%tmp_54 = arith.extui %tmp_53 : i19 to i22
		// Evaluate global variable k_CORDIC_constant done: assigned to tmp_54 above in this context.
		// Evaluate global variable fixedPointMultiply.
		%tmp_52 = func.call @g_qrd_fixedPointMultiply(%tmp_54,%l_x__j__72_d1_2) : (i22,i22) -> i22
		cal.set(%l_r__63: !cal.state_ref<i22>, %tmp_52: i22)
		// Assignment Statement: End
		// Assignment Statement: Start
		%tmp_55 = cal.get(%l_count__64: !cal.state_ref<i32>) : i32
		%tmp_56 = arith.constant 1 : i1
		%tmp_57 = arith.extui %tmp_56 : i1 to i32
		%tmp_58 = arith.addi %tmp_55, %tmp_57 : i32
		cal.set(%l_count__64: !cal.state_ref<i32>, %tmp_58: i32)
		// Assignment Statement: End
		// Assignment Statement: Start
		%tmp_59 = arith.constant 0 : i1
		%tmp_60 = arith.extui %tmp_59 : i1 to i32
		cal.set(%l_$state: !cal.state_ref<i32>, %tmp_60: i32)
		// Assignment Statement: End
		// Output Expression: Start
		fifo.push(%x_out: !fifo.input_port<i22>, %tmp_49: i22)
		// Output Expression: End
		// Output Expression: Start
		fifo.push(%cordic_angles_out: !fifo.input_port<i16>, %l_rotation__angles__69_d1_0: i16)
		// Output Expression: End
	}
	// Generation action: final
	cal.action "final" priority=0 {
		// Guard: Start
		cal.predicate {
			%tmp_61 = cal.get(%l_count__64: !cal.state_ref<i32>) : i32
			// Evaluate global variable $eval1.
			%tmp_62 = arith.constant 4 : i3
			%tmp_63 = arith.extui %tmp_62 : i3 to i32
			// Evaluate global variable $eval1 done: assigned to tmp_63 above in this context.
			%tmp_64 = arith.cmpi eq, %tmp_61, %tmp_63 : i32
			cal.predicate_result %tmp_64 : i1
		}
		// Guard: End
		// Assignment Statement: Start
		%tmp_65 = arith.constant 0 : i1
		%tmp_66 = arith.extui %tmp_65 : i1 to i32
		cal.set(%l_count__64: !cal.state_ref<i32>, %tmp_66: i32)
		// Assignment Statement: End
		// Assignment Statement: Start
		%tmp_67 = arith.constant 0 : i1
		%tmp_68 = arith.extui %tmp_67 : i1 to i32
		cal.set(%l_$state: !cal.state_ref<i32>, %tmp_68: i32)
		// Assignment Statement: End
		// Output Expression: Start
		%tmp_69 = cal.get(%l_r__63: !cal.state_ref<i22>) : i22
		fifo.push(%r_out: !fifo.input_port<i22>, %tmp_69: i22)
		// Output Expression: End
	}
}

//-- Definition of actor class: InnerCell
cal.actor @innerCells_q_10 ()
	ports_in(%x_in: !fifo.output_port<i22>,%cordic_angles_in: !fifo.output_port<i16>)
	ports_out(%x_out: !fifo.input_port<i22>,%r_out: !fifo.input_port<i22>,%cordic_angles_out: !fifo.input_port<i16>)
{
	// -- Actor body
	%l_r__63 = cal.create_state_var<i22> : !cal.state_ref<i22>
	%tmp_0 = arith.constant 0 : i1
	%tmp_1 = arith.extui %tmp_0 : i1 to i22
	cal.set(%l_r__63: !cal.state_ref<i22>, %tmp_1: i22)
	%l_count__64 = cal.create_state_var<i32> : !cal.state_ref<i32>
	%tmp_2 = arith.constant 0 : i1
	%tmp_3 = arith.extui %tmp_2 : i1 to i32
	cal.set(%l_count__64: !cal.state_ref<i32>, %tmp_3: i32)
	%l_$state = cal.create_state_var<i32> : !cal.state_ref<i32>
	%tmp_4 = arith.constant 0 : i1
	%tmp_5 = arith.extui %tmp_4 : i1 to i32
	cal.set(%l_$state: !cal.state_ref<i32>, %tmp_5: i32)
	// Generation action: normal
	cal.action "normal" priority=0 {
		// Guard: Start
		cal.predicate {
			%tmp_6 = cal.get(%l_count__64: !cal.state_ref<i32>) : i32
			// Evaluate global variable $eval1.
			%tmp_7 = arith.constant 4 : i3
			%tmp_8 = arith.extui %tmp_7 : i3 to i32
			// Evaluate global variable $eval1 done: assigned to tmp_8 above in this context.
			%tmp_9 = arith.cmpi ult, %tmp_6, %tmp_8 : i32
			cal.predicate_result %tmp_9 : i1
		}
		// Guard: End
		// Input Pattern: Start
		%l_x__in__66_d1_0 = fifo.pop(%x_in: !fifo.output_port<i22>) : i22
		// Input Pattern: End
		// Input Pattern: Start
		%l_rotation__angles__69_d1_0 = fifo.pop(%cordic_angles_in: !fifo.output_port<i16>) : i16
		// Input Pattern: End
		// Action Local Variable Decl: Start
		%l_x__out__71_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_x__j__72_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_x__j__plus__1__73_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_x__j__shifted__74_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_y__j__75_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_y__j__plus__1__76_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_y__j__shifted__77_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// If Statement: Begin
		%tmp_10 = cal.get(%l_count__64: !cal.state_ref<i32>) : i32
		%tmp_11 = arith.constant 0 : i1
		%tmp_12 = arith.extui %tmp_11 : i1 to i32
		%tmp_13 = arith.cmpi eq, %tmp_10, %tmp_12 : i32
		scf.if %tmp_13 {
			// Assignment Statement: Start
			%tmp_14 = arith.constant 0 : i1
			%tmp_15 = arith.extui %tmp_14 : i1 to i22
			cal.set(%l_r__63: !cal.state_ref<i22>, %tmp_15: i22)
			// Assignment Statement: End
		} else {
		}
		// If Statement: End
		// Assignment Statement: Start
		// l_x__j__72_d1_1 aliased to l_x__in__66_d1_0
		// Assignment Statement: End
		// Assignment Statement: Start
		%tmp_16 = cal.get(%l_r__63: !cal.state_ref<i22>) : i22
		// l_y__j__75_d1_1 aliased to tmp_16
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
		%l_x__j__72_d1_2, %l_x__j__plus__1__73_d1_1, %l_x__j__shifted__74_d1_1, %l_y__j__75_d1_2, %l_y__j__plus__1__76_d1_1, %l_y__j__shifted__77_d1_1 = scf.for %l_j_d1_0 = %tmp_19_lb to %tmp_27_ub_plus_1 step %tmp_26_step
				iter_args(%l_x__j__72_d2_0 = %l_x__in__66_d1_0, %l_x__j__plus__1__73_d2_0 = %l_x__j__plus__1__73_d1_0, %l_x__j__shifted__74_d2_0 = %l_x__j__shifted__74_d1_0, %l_y__j__75_d2_0 = %tmp_16, %l_y__j__plus__1__76_d2_0 = %l_y__j__plus__1__76_d1_0, %l_y__j__shifted__77_d2_0 = %l_y__j__shifted__77_d1_0) -> (i22, i22, i22, i22, i22, i22) {
			%l_j_d2_0 = arith.index_cast %l_j_d1_0 : index to i32
			%l_j_d2_1 = arith.trunci %l_j_d2_0 : i32 to i8
			// Assignment Statement: Start
			%tmp_28 = arith.extui %l_j_d2_1 : i8 to i22
			%tmp_29 = arith.shrsi %l_y__j__75_d2_0, %tmp_28 : i22
			// l_y__j__shifted__77_d2_1 aliased to tmp_29
			// Assignment Statement: End
			// Assignment Statement: Start
			%tmp_30 = arith.extui %l_j_d2_1 : i8 to i22
			%tmp_31 = arith.shrsi %l_x__j__72_d2_0, %tmp_30 : i22
			// l_x__j__shifted__74_d2_1 aliased to tmp_31
			// Assignment Statement: End
			// If Statement: Begin
			%tmp_32 = arith.extui %l_j_d2_1 : i8 to i16
			%tmp_33 = arith.shrui %l_rotation__angles__69_d1_0, %tmp_32 : i16
			%tmp_34 = arith.constant 1 : i1
			%tmp_35 = arith.trunci %tmp_33 : i16 to i1
			%tmp_36 = arith.andi %tmp_35, %tmp_34 : i1
			%tmp_37 = arith.constant 1 : i1
			%tmp_38 = arith.cmpi eq, %tmp_36, %tmp_37 : i1
			%l_x__j__plus__1__73_d2_1, %l_y__j__plus__1__76_d2_1 = scf.if %tmp_38 -> (i22, i22) {
				// Assignment Statement: Start
				%tmp_39 = arith.extsi %l_x__j__72_d2_0 : i22 to i23
				%tmp_40 = arith.extsi %tmp_29 : i22 to i23
				%tmp_41 = arith.addi %tmp_39, %tmp_40 : i23
				%tmp_42 = arith.trunci %tmp_41 : i23 to i22
				// l_x__j__plus__1__73_d3_0 aliased to tmp_42
				// Assignment Statement: End
				// Assignment Statement: Start
				%tmp_43 = arith.subi %l_y__j__75_d2_0, %tmp_31 : i22
				// l_y__j__plus__1__76_d3_0 aliased to tmp_43
				// Assignment Statement: End
				scf.yield %tmp_42, %tmp_43 : i22, i22
			} else {
				// Assignment Statement: Start
				%tmp_44 = arith.subi %l_x__j__72_d2_0, %tmp_29 : i22
				// l_x__j__plus__1__73_d3_0 aliased to tmp_44
				// Assignment Statement: End
				// Assignment Statement: Start
				%tmp_45 = arith.extsi %l_y__j__75_d2_0 : i22 to i23
				%tmp_46 = arith.extsi %tmp_31 : i22 to i23
				%tmp_47 = arith.addi %tmp_45, %tmp_46 : i23
				%tmp_48 = arith.trunci %tmp_47 : i23 to i22
				// l_y__j__plus__1__76_d3_0 aliased to tmp_48
				// Assignment Statement: End
				scf.yield %tmp_44, %tmp_48 : i22, i22
			}
			// If Statement: End
			// Assignment Statement: Start
			// l_x__j__72_d2_1 aliased to l_x__j__plus__1__73_d2_1
			// Assignment Statement: End
			// Assignment Statement: Start
			// l_y__j__75_d2_1 aliased to l_y__j__plus__1__76_d2_1
			// Assignment Statement: End
			scf.yield %l_x__j__plus__1__73_d2_1, %l_x__j__plus__1__73_d2_1, %tmp_31, %l_y__j__plus__1__76_d2_1, %l_y__j__plus__1__76_d2_1, %tmp_29 : i22, i22, i22, i22, i22, i22
		}
		// Foreach Statement: End
		// Assignment Statement: Start
		// Evaluate global variable k_CORDIC_constant.
		%tmp_50 = arith.constant 318375 : i19
		%tmp_51 = arith.extui %tmp_50 : i19 to i22
		// Evaluate global variable k_CORDIC_constant done: assigned to tmp_51 above in this context.
		// Evaluate global variable fixedPointMultiply.
		%tmp_49 = func.call @g_qrd_fixedPointMultiply(%tmp_51,%l_y__j__75_d1_2) : (i22,i22) -> i22
		// l_x__out__71_d1_1 aliased to tmp_49
		// Assignment Statement: End
		// Assignment Statement: Start
		// Evaluate global variable k_CORDIC_constant.
		%tmp_53 = arith.constant 318375 : i19
		%tmp_54 = arith.extui %tmp_53 : i19 to i22
		// Evaluate global variable k_CORDIC_constant done: assigned to tmp_54 above in this context.
		// Evaluate global variable fixedPointMultiply.
		%tmp_52 = func.call @g_qrd_fixedPointMultiply(%tmp_54,%l_x__j__72_d1_2) : (i22,i22) -> i22
		cal.set(%l_r__63: !cal.state_ref<i22>, %tmp_52: i22)
		// Assignment Statement: End
		// Assignment Statement: Start
		%tmp_55 = cal.get(%l_count__64: !cal.state_ref<i32>) : i32
		%tmp_56 = arith.constant 1 : i1
		%tmp_57 = arith.extui %tmp_56 : i1 to i32
		%tmp_58 = arith.addi %tmp_55, %tmp_57 : i32
		cal.set(%l_count__64: !cal.state_ref<i32>, %tmp_58: i32)
		// Assignment Statement: End
		// Assignment Statement: Start
		%tmp_59 = arith.constant 0 : i1
		%tmp_60 = arith.extui %tmp_59 : i1 to i32
		cal.set(%l_$state: !cal.state_ref<i32>, %tmp_60: i32)
		// Assignment Statement: End
		// Output Expression: Start
		fifo.push(%x_out: !fifo.input_port<i22>, %tmp_49: i22)
		// Output Expression: End
		// Output Expression: Start
		fifo.push(%cordic_angles_out: !fifo.input_port<i16>, %l_rotation__angles__69_d1_0: i16)
		// Output Expression: End
	}
	// Generation action: final
	cal.action "final" priority=0 {
		// Guard: Start
		cal.predicate {
			%tmp_61 = cal.get(%l_count__64: !cal.state_ref<i32>) : i32
			// Evaluate global variable $eval1.
			%tmp_62 = arith.constant 4 : i3
			%tmp_63 = arith.extui %tmp_62 : i3 to i32
			// Evaluate global variable $eval1 done: assigned to tmp_63 above in this context.
			%tmp_64 = arith.cmpi eq, %tmp_61, %tmp_63 : i32
			cal.predicate_result %tmp_64 : i1
		}
		// Guard: End
		// Assignment Statement: Start
		%tmp_65 = arith.constant 0 : i1
		%tmp_66 = arith.extui %tmp_65 : i1 to i32
		cal.set(%l_count__64: !cal.state_ref<i32>, %tmp_66: i32)
		// Assignment Statement: End
		// Assignment Statement: Start
		%tmp_67 = arith.constant 0 : i1
		%tmp_68 = arith.extui %tmp_67 : i1 to i32
		cal.set(%l_$state: !cal.state_ref<i32>, %tmp_68: i32)
		// Assignment Statement: End
		// Output Expression: Start
		%tmp_69 = cal.get(%l_r__63: !cal.state_ref<i22>) : i22
		fifo.push(%r_out: !fifo.input_port<i22>, %tmp_69: i22)
		// Output Expression: End
	}
}

//-- Definition of actor class: InnerCell
cal.actor @innerCells_q_15 ()
	ports_in(%x_in: !fifo.output_port<i22>,%cordic_angles_in: !fifo.output_port<i16>)
	ports_out(%x_out: !fifo.input_port<i22>,%r_out: !fifo.input_port<i22>,%cordic_angles_out: !fifo.input_port<i16>)
{
	// -- Actor body
	%l_r__63 = cal.create_state_var<i22> : !cal.state_ref<i22>
	%tmp_0 = arith.constant 0 : i1
	%tmp_1 = arith.extui %tmp_0 : i1 to i22
	cal.set(%l_r__63: !cal.state_ref<i22>, %tmp_1: i22)
	%l_count__64 = cal.create_state_var<i32> : !cal.state_ref<i32>
	%tmp_2 = arith.constant 0 : i1
	%tmp_3 = arith.extui %tmp_2 : i1 to i32
	cal.set(%l_count__64: !cal.state_ref<i32>, %tmp_3: i32)
	%l_$state = cal.create_state_var<i32> : !cal.state_ref<i32>
	%tmp_4 = arith.constant 0 : i1
	%tmp_5 = arith.extui %tmp_4 : i1 to i32
	cal.set(%l_$state: !cal.state_ref<i32>, %tmp_5: i32)
	// Generation action: normal
	cal.action "normal" priority=0 {
		// Guard: Start
		cal.predicate {
			%tmp_6 = cal.get(%l_count__64: !cal.state_ref<i32>) : i32
			// Evaluate global variable $eval1.
			%tmp_7 = arith.constant 4 : i3
			%tmp_8 = arith.extui %tmp_7 : i3 to i32
			// Evaluate global variable $eval1 done: assigned to tmp_8 above in this context.
			%tmp_9 = arith.cmpi ult, %tmp_6, %tmp_8 : i32
			cal.predicate_result %tmp_9 : i1
		}
		// Guard: End
		// Input Pattern: Start
		%l_x__in__66_d1_0 = fifo.pop(%x_in: !fifo.output_port<i22>) : i22
		// Input Pattern: End
		// Input Pattern: Start
		%l_rotation__angles__69_d1_0 = fifo.pop(%cordic_angles_in: !fifo.output_port<i16>) : i16
		// Input Pattern: End
		// Action Local Variable Decl: Start
		%l_x__out__71_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_x__j__72_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_x__j__plus__1__73_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_x__j__shifted__74_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_y__j__75_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_y__j__plus__1__76_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_y__j__shifted__77_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// If Statement: Begin
		%tmp_10 = cal.get(%l_count__64: !cal.state_ref<i32>) : i32
		%tmp_11 = arith.constant 0 : i1
		%tmp_12 = arith.extui %tmp_11 : i1 to i32
		%tmp_13 = arith.cmpi eq, %tmp_10, %tmp_12 : i32
		scf.if %tmp_13 {
			// Assignment Statement: Start
			%tmp_14 = arith.constant 0 : i1
			%tmp_15 = arith.extui %tmp_14 : i1 to i22
			cal.set(%l_r__63: !cal.state_ref<i22>, %tmp_15: i22)
			// Assignment Statement: End
		} else {
		}
		// If Statement: End
		// Assignment Statement: Start
		// l_x__j__72_d1_1 aliased to l_x__in__66_d1_0
		// Assignment Statement: End
		// Assignment Statement: Start
		%tmp_16 = cal.get(%l_r__63: !cal.state_ref<i22>) : i22
		// l_y__j__75_d1_1 aliased to tmp_16
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
		%l_x__j__72_d1_2, %l_x__j__plus__1__73_d1_1, %l_x__j__shifted__74_d1_1, %l_y__j__75_d1_2, %l_y__j__plus__1__76_d1_1, %l_y__j__shifted__77_d1_1 = scf.for %l_j_d1_0 = %tmp_19_lb to %tmp_27_ub_plus_1 step %tmp_26_step
				iter_args(%l_x__j__72_d2_0 = %l_x__in__66_d1_0, %l_x__j__plus__1__73_d2_0 = %l_x__j__plus__1__73_d1_0, %l_x__j__shifted__74_d2_0 = %l_x__j__shifted__74_d1_0, %l_y__j__75_d2_0 = %tmp_16, %l_y__j__plus__1__76_d2_0 = %l_y__j__plus__1__76_d1_0, %l_y__j__shifted__77_d2_0 = %l_y__j__shifted__77_d1_0) -> (i22, i22, i22, i22, i22, i22) {
			%l_j_d2_0 = arith.index_cast %l_j_d1_0 : index to i32
			%l_j_d2_1 = arith.trunci %l_j_d2_0 : i32 to i8
			// Assignment Statement: Start
			%tmp_28 = arith.extui %l_j_d2_1 : i8 to i22
			%tmp_29 = arith.shrsi %l_y__j__75_d2_0, %tmp_28 : i22
			// l_y__j__shifted__77_d2_1 aliased to tmp_29
			// Assignment Statement: End
			// Assignment Statement: Start
			%tmp_30 = arith.extui %l_j_d2_1 : i8 to i22
			%tmp_31 = arith.shrsi %l_x__j__72_d2_0, %tmp_30 : i22
			// l_x__j__shifted__74_d2_1 aliased to tmp_31
			// Assignment Statement: End
			// If Statement: Begin
			%tmp_32 = arith.extui %l_j_d2_1 : i8 to i16
			%tmp_33 = arith.shrui %l_rotation__angles__69_d1_0, %tmp_32 : i16
			%tmp_34 = arith.constant 1 : i1
			%tmp_35 = arith.trunci %tmp_33 : i16 to i1
			%tmp_36 = arith.andi %tmp_35, %tmp_34 : i1
			%tmp_37 = arith.constant 1 : i1
			%tmp_38 = arith.cmpi eq, %tmp_36, %tmp_37 : i1
			%l_x__j__plus__1__73_d2_1, %l_y__j__plus__1__76_d2_1 = scf.if %tmp_38 -> (i22, i22) {
				// Assignment Statement: Start
				%tmp_39 = arith.extsi %l_x__j__72_d2_0 : i22 to i23
				%tmp_40 = arith.extsi %tmp_29 : i22 to i23
				%tmp_41 = arith.addi %tmp_39, %tmp_40 : i23
				%tmp_42 = arith.trunci %tmp_41 : i23 to i22
				// l_x__j__plus__1__73_d3_0 aliased to tmp_42
				// Assignment Statement: End
				// Assignment Statement: Start
				%tmp_43 = arith.subi %l_y__j__75_d2_0, %tmp_31 : i22
				// l_y__j__plus__1__76_d3_0 aliased to tmp_43
				// Assignment Statement: End
				scf.yield %tmp_42, %tmp_43 : i22, i22
			} else {
				// Assignment Statement: Start
				%tmp_44 = arith.subi %l_x__j__72_d2_0, %tmp_29 : i22
				// l_x__j__plus__1__73_d3_0 aliased to tmp_44
				// Assignment Statement: End
				// Assignment Statement: Start
				%tmp_45 = arith.extsi %l_y__j__75_d2_0 : i22 to i23
				%tmp_46 = arith.extsi %tmp_31 : i22 to i23
				%tmp_47 = arith.addi %tmp_45, %tmp_46 : i23
				%tmp_48 = arith.trunci %tmp_47 : i23 to i22
				// l_y__j__plus__1__76_d3_0 aliased to tmp_48
				// Assignment Statement: End
				scf.yield %tmp_44, %tmp_48 : i22, i22
			}
			// If Statement: End
			// Assignment Statement: Start
			// l_x__j__72_d2_1 aliased to l_x__j__plus__1__73_d2_1
			// Assignment Statement: End
			// Assignment Statement: Start
			// l_y__j__75_d2_1 aliased to l_y__j__plus__1__76_d2_1
			// Assignment Statement: End
			scf.yield %l_x__j__plus__1__73_d2_1, %l_x__j__plus__1__73_d2_1, %tmp_31, %l_y__j__plus__1__76_d2_1, %l_y__j__plus__1__76_d2_1, %tmp_29 : i22, i22, i22, i22, i22, i22
		}
		// Foreach Statement: End
		// Assignment Statement: Start
		// Evaluate global variable k_CORDIC_constant.
		%tmp_50 = arith.constant 318375 : i19
		%tmp_51 = arith.extui %tmp_50 : i19 to i22
		// Evaluate global variable k_CORDIC_constant done: assigned to tmp_51 above in this context.
		// Evaluate global variable fixedPointMultiply.
		%tmp_49 = func.call @g_qrd_fixedPointMultiply(%tmp_51,%l_y__j__75_d1_2) : (i22,i22) -> i22
		// l_x__out__71_d1_1 aliased to tmp_49
		// Assignment Statement: End
		// Assignment Statement: Start
		// Evaluate global variable k_CORDIC_constant.
		%tmp_53 = arith.constant 318375 : i19
		%tmp_54 = arith.extui %tmp_53 : i19 to i22
		// Evaluate global variable k_CORDIC_constant done: assigned to tmp_54 above in this context.
		// Evaluate global variable fixedPointMultiply.
		%tmp_52 = func.call @g_qrd_fixedPointMultiply(%tmp_54,%l_x__j__72_d1_2) : (i22,i22) -> i22
		cal.set(%l_r__63: !cal.state_ref<i22>, %tmp_52: i22)
		// Assignment Statement: End
		// Assignment Statement: Start
		%tmp_55 = cal.get(%l_count__64: !cal.state_ref<i32>) : i32
		%tmp_56 = arith.constant 1 : i1
		%tmp_57 = arith.extui %tmp_56 : i1 to i32
		%tmp_58 = arith.addi %tmp_55, %tmp_57 : i32
		cal.set(%l_count__64: !cal.state_ref<i32>, %tmp_58: i32)
		// Assignment Statement: End
		// Assignment Statement: Start
		%tmp_59 = arith.constant 0 : i1
		%tmp_60 = arith.extui %tmp_59 : i1 to i32
		cal.set(%l_$state: !cal.state_ref<i32>, %tmp_60: i32)
		// Assignment Statement: End
		// Output Expression: Start
		fifo.push(%x_out: !fifo.input_port<i22>, %tmp_49: i22)
		// Output Expression: End
		// Output Expression: Start
		fifo.push(%cordic_angles_out: !fifo.input_port<i16>, %l_rotation__angles__69_d1_0: i16)
		// Output Expression: End
	}
	// Generation action: final
	cal.action "final" priority=0 {
		// Guard: Start
		cal.predicate {
			%tmp_61 = cal.get(%l_count__64: !cal.state_ref<i32>) : i32
			// Evaluate global variable $eval1.
			%tmp_62 = arith.constant 4 : i3
			%tmp_63 = arith.extui %tmp_62 : i3 to i32
			// Evaluate global variable $eval1 done: assigned to tmp_63 above in this context.
			%tmp_64 = arith.cmpi eq, %tmp_61, %tmp_63 : i32
			cal.predicate_result %tmp_64 : i1
		}
		// Guard: End
		// Assignment Statement: Start
		%tmp_65 = arith.constant 0 : i1
		%tmp_66 = arith.extui %tmp_65 : i1 to i32
		cal.set(%l_count__64: !cal.state_ref<i32>, %tmp_66: i32)
		// Assignment Statement: End
		// Assignment Statement: Start
		%tmp_67 = arith.constant 0 : i1
		%tmp_68 = arith.extui %tmp_67 : i1 to i32
		cal.set(%l_$state: !cal.state_ref<i32>, %tmp_68: i32)
		// Assignment Statement: End
		// Output Expression: Start
		%tmp_69 = cal.get(%l_r__63: !cal.state_ref<i22>) : i22
		fifo.push(%r_out: !fifo.input_port<i22>, %tmp_69: i22)
		// Output Expression: End
	}
}

//-- Definition of actor class: InnerCell
cal.actor @innerCells_q_13 ()
	ports_in(%x_in: !fifo.output_port<i22>,%cordic_angles_in: !fifo.output_port<i16>)
	ports_out(%x_out: !fifo.input_port<i22>,%r_out: !fifo.input_port<i22>,%cordic_angles_out: !fifo.input_port<i16>)
{
	// -- Actor body
	%l_r__63 = cal.create_state_var<i22> : !cal.state_ref<i22>
	%tmp_0 = arith.constant 0 : i1
	%tmp_1 = arith.extui %tmp_0 : i1 to i22
	cal.set(%l_r__63: !cal.state_ref<i22>, %tmp_1: i22)
	%l_count__64 = cal.create_state_var<i32> : !cal.state_ref<i32>
	%tmp_2 = arith.constant 0 : i1
	%tmp_3 = arith.extui %tmp_2 : i1 to i32
	cal.set(%l_count__64: !cal.state_ref<i32>, %tmp_3: i32)
	%l_$state = cal.create_state_var<i32> : !cal.state_ref<i32>
	%tmp_4 = arith.constant 0 : i1
	%tmp_5 = arith.extui %tmp_4 : i1 to i32
	cal.set(%l_$state: !cal.state_ref<i32>, %tmp_5: i32)
	// Generation action: normal
	cal.action "normal" priority=0 {
		// Guard: Start
		cal.predicate {
			%tmp_6 = cal.get(%l_count__64: !cal.state_ref<i32>) : i32
			// Evaluate global variable $eval1.
			%tmp_7 = arith.constant 4 : i3
			%tmp_8 = arith.extui %tmp_7 : i3 to i32
			// Evaluate global variable $eval1 done: assigned to tmp_8 above in this context.
			%tmp_9 = arith.cmpi ult, %tmp_6, %tmp_8 : i32
			cal.predicate_result %tmp_9 : i1
		}
		// Guard: End
		// Input Pattern: Start
		%l_x__in__66_d1_0 = fifo.pop(%x_in: !fifo.output_port<i22>) : i22
		// Input Pattern: End
		// Input Pattern: Start
		%l_rotation__angles__69_d1_0 = fifo.pop(%cordic_angles_in: !fifo.output_port<i16>) : i16
		// Input Pattern: End
		// Action Local Variable Decl: Start
		%l_x__out__71_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_x__j__72_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_x__j__plus__1__73_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_x__j__shifted__74_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_y__j__75_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_y__j__plus__1__76_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_y__j__shifted__77_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// If Statement: Begin
		%tmp_10 = cal.get(%l_count__64: !cal.state_ref<i32>) : i32
		%tmp_11 = arith.constant 0 : i1
		%tmp_12 = arith.extui %tmp_11 : i1 to i32
		%tmp_13 = arith.cmpi eq, %tmp_10, %tmp_12 : i32
		scf.if %tmp_13 {
			// Assignment Statement: Start
			%tmp_14 = arith.constant 0 : i1
			%tmp_15 = arith.extui %tmp_14 : i1 to i22
			cal.set(%l_r__63: !cal.state_ref<i22>, %tmp_15: i22)
			// Assignment Statement: End
		} else {
		}
		// If Statement: End
		// Assignment Statement: Start
		// l_x__j__72_d1_1 aliased to l_x__in__66_d1_0
		// Assignment Statement: End
		// Assignment Statement: Start
		%tmp_16 = cal.get(%l_r__63: !cal.state_ref<i22>) : i22
		// l_y__j__75_d1_1 aliased to tmp_16
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
		%l_x__j__72_d1_2, %l_x__j__plus__1__73_d1_1, %l_x__j__shifted__74_d1_1, %l_y__j__75_d1_2, %l_y__j__plus__1__76_d1_1, %l_y__j__shifted__77_d1_1 = scf.for %l_j_d1_0 = %tmp_19_lb to %tmp_27_ub_plus_1 step %tmp_26_step
				iter_args(%l_x__j__72_d2_0 = %l_x__in__66_d1_0, %l_x__j__plus__1__73_d2_0 = %l_x__j__plus__1__73_d1_0, %l_x__j__shifted__74_d2_0 = %l_x__j__shifted__74_d1_0, %l_y__j__75_d2_0 = %tmp_16, %l_y__j__plus__1__76_d2_0 = %l_y__j__plus__1__76_d1_0, %l_y__j__shifted__77_d2_0 = %l_y__j__shifted__77_d1_0) -> (i22, i22, i22, i22, i22, i22) {
			%l_j_d2_0 = arith.index_cast %l_j_d1_0 : index to i32
			%l_j_d2_1 = arith.trunci %l_j_d2_0 : i32 to i8
			// Assignment Statement: Start
			%tmp_28 = arith.extui %l_j_d2_1 : i8 to i22
			%tmp_29 = arith.shrsi %l_y__j__75_d2_0, %tmp_28 : i22
			// l_y__j__shifted__77_d2_1 aliased to tmp_29
			// Assignment Statement: End
			// Assignment Statement: Start
			%tmp_30 = arith.extui %l_j_d2_1 : i8 to i22
			%tmp_31 = arith.shrsi %l_x__j__72_d2_0, %tmp_30 : i22
			// l_x__j__shifted__74_d2_1 aliased to tmp_31
			// Assignment Statement: End
			// If Statement: Begin
			%tmp_32 = arith.extui %l_j_d2_1 : i8 to i16
			%tmp_33 = arith.shrui %l_rotation__angles__69_d1_0, %tmp_32 : i16
			%tmp_34 = arith.constant 1 : i1
			%tmp_35 = arith.trunci %tmp_33 : i16 to i1
			%tmp_36 = arith.andi %tmp_35, %tmp_34 : i1
			%tmp_37 = arith.constant 1 : i1
			%tmp_38 = arith.cmpi eq, %tmp_36, %tmp_37 : i1
			%l_x__j__plus__1__73_d2_1, %l_y__j__plus__1__76_d2_1 = scf.if %tmp_38 -> (i22, i22) {
				// Assignment Statement: Start
				%tmp_39 = arith.extsi %l_x__j__72_d2_0 : i22 to i23
				%tmp_40 = arith.extsi %tmp_29 : i22 to i23
				%tmp_41 = arith.addi %tmp_39, %tmp_40 : i23
				%tmp_42 = arith.trunci %tmp_41 : i23 to i22
				// l_x__j__plus__1__73_d3_0 aliased to tmp_42
				// Assignment Statement: End
				// Assignment Statement: Start
				%tmp_43 = arith.subi %l_y__j__75_d2_0, %tmp_31 : i22
				// l_y__j__plus__1__76_d3_0 aliased to tmp_43
				// Assignment Statement: End
				scf.yield %tmp_42, %tmp_43 : i22, i22
			} else {
				// Assignment Statement: Start
				%tmp_44 = arith.subi %l_x__j__72_d2_0, %tmp_29 : i22
				// l_x__j__plus__1__73_d3_0 aliased to tmp_44
				// Assignment Statement: End
				// Assignment Statement: Start
				%tmp_45 = arith.extsi %l_y__j__75_d2_0 : i22 to i23
				%tmp_46 = arith.extsi %tmp_31 : i22 to i23
				%tmp_47 = arith.addi %tmp_45, %tmp_46 : i23
				%tmp_48 = arith.trunci %tmp_47 : i23 to i22
				// l_y__j__plus__1__76_d3_0 aliased to tmp_48
				// Assignment Statement: End
				scf.yield %tmp_44, %tmp_48 : i22, i22
			}
			// If Statement: End
			// Assignment Statement: Start
			// l_x__j__72_d2_1 aliased to l_x__j__plus__1__73_d2_1
			// Assignment Statement: End
			// Assignment Statement: Start
			// l_y__j__75_d2_1 aliased to l_y__j__plus__1__76_d2_1
			// Assignment Statement: End
			scf.yield %l_x__j__plus__1__73_d2_1, %l_x__j__plus__1__73_d2_1, %tmp_31, %l_y__j__plus__1__76_d2_1, %l_y__j__plus__1__76_d2_1, %tmp_29 : i22, i22, i22, i22, i22, i22
		}
		// Foreach Statement: End
		// Assignment Statement: Start
		// Evaluate global variable k_CORDIC_constant.
		%tmp_50 = arith.constant 318375 : i19
		%tmp_51 = arith.extui %tmp_50 : i19 to i22
		// Evaluate global variable k_CORDIC_constant done: assigned to tmp_51 above in this context.
		// Evaluate global variable fixedPointMultiply.
		%tmp_49 = func.call @g_qrd_fixedPointMultiply(%tmp_51,%l_y__j__75_d1_2) : (i22,i22) -> i22
		// l_x__out__71_d1_1 aliased to tmp_49
		// Assignment Statement: End
		// Assignment Statement: Start
		// Evaluate global variable k_CORDIC_constant.
		%tmp_53 = arith.constant 318375 : i19
		%tmp_54 = arith.extui %tmp_53 : i19 to i22
		// Evaluate global variable k_CORDIC_constant done: assigned to tmp_54 above in this context.
		// Evaluate global variable fixedPointMultiply.
		%tmp_52 = func.call @g_qrd_fixedPointMultiply(%tmp_54,%l_x__j__72_d1_2) : (i22,i22) -> i22
		cal.set(%l_r__63: !cal.state_ref<i22>, %tmp_52: i22)
		// Assignment Statement: End
		// Assignment Statement: Start
		%tmp_55 = cal.get(%l_count__64: !cal.state_ref<i32>) : i32
		%tmp_56 = arith.constant 1 : i1
		%tmp_57 = arith.extui %tmp_56 : i1 to i32
		%tmp_58 = arith.addi %tmp_55, %tmp_57 : i32
		cal.set(%l_count__64: !cal.state_ref<i32>, %tmp_58: i32)
		// Assignment Statement: End
		// Assignment Statement: Start
		%tmp_59 = arith.constant 0 : i1
		%tmp_60 = arith.extui %tmp_59 : i1 to i32
		cal.set(%l_$state: !cal.state_ref<i32>, %tmp_60: i32)
		// Assignment Statement: End
		// Output Expression: Start
		fifo.push(%x_out: !fifo.input_port<i22>, %tmp_49: i22)
		// Output Expression: End
		// Output Expression: Start
		fifo.push(%cordic_angles_out: !fifo.input_port<i16>, %l_rotation__angles__69_d1_0: i16)
		// Output Expression: End
	}
	// Generation action: final
	cal.action "final" priority=0 {
		// Guard: Start
		cal.predicate {
			%tmp_61 = cal.get(%l_count__64: !cal.state_ref<i32>) : i32
			// Evaluate global variable $eval1.
			%tmp_62 = arith.constant 4 : i3
			%tmp_63 = arith.extui %tmp_62 : i3 to i32
			// Evaluate global variable $eval1 done: assigned to tmp_63 above in this context.
			%tmp_64 = arith.cmpi eq, %tmp_61, %tmp_63 : i32
			cal.predicate_result %tmp_64 : i1
		}
		// Guard: End
		// Assignment Statement: Start
		%tmp_65 = arith.constant 0 : i1
		%tmp_66 = arith.extui %tmp_65 : i1 to i32
		cal.set(%l_count__64: !cal.state_ref<i32>, %tmp_66: i32)
		// Assignment Statement: End
		// Assignment Statement: Start
		%tmp_67 = arith.constant 0 : i1
		%tmp_68 = arith.extui %tmp_67 : i1 to i32
		cal.set(%l_$state: !cal.state_ref<i32>, %tmp_68: i32)
		// Assignment Statement: End
		// Output Expression: Start
		%tmp_69 = cal.get(%l_r__63: !cal.state_ref<i22>) : i22
		fifo.push(%r_out: !fifo.input_port<i22>, %tmp_69: i22)
		// Output Expression: End
	}
}

//-- Definition of actor class: InnerCell
cal.actor @innerCells_q_14 ()
	ports_in(%x_in: !fifo.output_port<i22>,%cordic_angles_in: !fifo.output_port<i16>)
	ports_out(%x_out: !fifo.input_port<i22>,%r_out: !fifo.input_port<i22>,%cordic_angles_out: !fifo.input_port<i16>)
{
	// -- Actor body
	%l_r__63 = cal.create_state_var<i22> : !cal.state_ref<i22>
	%tmp_0 = arith.constant 0 : i1
	%tmp_1 = arith.extui %tmp_0 : i1 to i22
	cal.set(%l_r__63: !cal.state_ref<i22>, %tmp_1: i22)
	%l_count__64 = cal.create_state_var<i32> : !cal.state_ref<i32>
	%tmp_2 = arith.constant 0 : i1
	%tmp_3 = arith.extui %tmp_2 : i1 to i32
	cal.set(%l_count__64: !cal.state_ref<i32>, %tmp_3: i32)
	%l_$state = cal.create_state_var<i32> : !cal.state_ref<i32>
	%tmp_4 = arith.constant 0 : i1
	%tmp_5 = arith.extui %tmp_4 : i1 to i32
	cal.set(%l_$state: !cal.state_ref<i32>, %tmp_5: i32)
	// Generation action: normal
	cal.action "normal" priority=0 {
		// Guard: Start
		cal.predicate {
			%tmp_6 = cal.get(%l_count__64: !cal.state_ref<i32>) : i32
			// Evaluate global variable $eval1.
			%tmp_7 = arith.constant 4 : i3
			%tmp_8 = arith.extui %tmp_7 : i3 to i32
			// Evaluate global variable $eval1 done: assigned to tmp_8 above in this context.
			%tmp_9 = arith.cmpi ult, %tmp_6, %tmp_8 : i32
			cal.predicate_result %tmp_9 : i1
		}
		// Guard: End
		// Input Pattern: Start
		%l_x__in__66_d1_0 = fifo.pop(%x_in: !fifo.output_port<i22>) : i22
		// Input Pattern: End
		// Input Pattern: Start
		%l_rotation__angles__69_d1_0 = fifo.pop(%cordic_angles_in: !fifo.output_port<i16>) : i16
		// Input Pattern: End
		// Action Local Variable Decl: Start
		%l_x__out__71_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_x__j__72_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_x__j__plus__1__73_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_x__j__shifted__74_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_y__j__75_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_y__j__plus__1__76_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_y__j__shifted__77_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// If Statement: Begin
		%tmp_10 = cal.get(%l_count__64: !cal.state_ref<i32>) : i32
		%tmp_11 = arith.constant 0 : i1
		%tmp_12 = arith.extui %tmp_11 : i1 to i32
		%tmp_13 = arith.cmpi eq, %tmp_10, %tmp_12 : i32
		scf.if %tmp_13 {
			// Assignment Statement: Start
			%tmp_14 = arith.constant 0 : i1
			%tmp_15 = arith.extui %tmp_14 : i1 to i22
			cal.set(%l_r__63: !cal.state_ref<i22>, %tmp_15: i22)
			// Assignment Statement: End
		} else {
		}
		// If Statement: End
		// Assignment Statement: Start
		// l_x__j__72_d1_1 aliased to l_x__in__66_d1_0
		// Assignment Statement: End
		// Assignment Statement: Start
		%tmp_16 = cal.get(%l_r__63: !cal.state_ref<i22>) : i22
		// l_y__j__75_d1_1 aliased to tmp_16
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
		%l_x__j__72_d1_2, %l_x__j__plus__1__73_d1_1, %l_x__j__shifted__74_d1_1, %l_y__j__75_d1_2, %l_y__j__plus__1__76_d1_1, %l_y__j__shifted__77_d1_1 = scf.for %l_j_d1_0 = %tmp_19_lb to %tmp_27_ub_plus_1 step %tmp_26_step
				iter_args(%l_x__j__72_d2_0 = %l_x__in__66_d1_0, %l_x__j__plus__1__73_d2_0 = %l_x__j__plus__1__73_d1_0, %l_x__j__shifted__74_d2_0 = %l_x__j__shifted__74_d1_0, %l_y__j__75_d2_0 = %tmp_16, %l_y__j__plus__1__76_d2_0 = %l_y__j__plus__1__76_d1_0, %l_y__j__shifted__77_d2_0 = %l_y__j__shifted__77_d1_0) -> (i22, i22, i22, i22, i22, i22) {
			%l_j_d2_0 = arith.index_cast %l_j_d1_0 : index to i32
			%l_j_d2_1 = arith.trunci %l_j_d2_0 : i32 to i8
			// Assignment Statement: Start
			%tmp_28 = arith.extui %l_j_d2_1 : i8 to i22
			%tmp_29 = arith.shrsi %l_y__j__75_d2_0, %tmp_28 : i22
			// l_y__j__shifted__77_d2_1 aliased to tmp_29
			// Assignment Statement: End
			// Assignment Statement: Start
			%tmp_30 = arith.extui %l_j_d2_1 : i8 to i22
			%tmp_31 = arith.shrsi %l_x__j__72_d2_0, %tmp_30 : i22
			// l_x__j__shifted__74_d2_1 aliased to tmp_31
			// Assignment Statement: End
			// If Statement: Begin
			%tmp_32 = arith.extui %l_j_d2_1 : i8 to i16
			%tmp_33 = arith.shrui %l_rotation__angles__69_d1_0, %tmp_32 : i16
			%tmp_34 = arith.constant 1 : i1
			%tmp_35 = arith.trunci %tmp_33 : i16 to i1
			%tmp_36 = arith.andi %tmp_35, %tmp_34 : i1
			%tmp_37 = arith.constant 1 : i1
			%tmp_38 = arith.cmpi eq, %tmp_36, %tmp_37 : i1
			%l_x__j__plus__1__73_d2_1, %l_y__j__plus__1__76_d2_1 = scf.if %tmp_38 -> (i22, i22) {
				// Assignment Statement: Start
				%tmp_39 = arith.extsi %l_x__j__72_d2_0 : i22 to i23
				%tmp_40 = arith.extsi %tmp_29 : i22 to i23
				%tmp_41 = arith.addi %tmp_39, %tmp_40 : i23
				%tmp_42 = arith.trunci %tmp_41 : i23 to i22
				// l_x__j__plus__1__73_d3_0 aliased to tmp_42
				// Assignment Statement: End
				// Assignment Statement: Start
				%tmp_43 = arith.subi %l_y__j__75_d2_0, %tmp_31 : i22
				// l_y__j__plus__1__76_d3_0 aliased to tmp_43
				// Assignment Statement: End
				scf.yield %tmp_42, %tmp_43 : i22, i22
			} else {
				// Assignment Statement: Start
				%tmp_44 = arith.subi %l_x__j__72_d2_0, %tmp_29 : i22
				// l_x__j__plus__1__73_d3_0 aliased to tmp_44
				// Assignment Statement: End
				// Assignment Statement: Start
				%tmp_45 = arith.extsi %l_y__j__75_d2_0 : i22 to i23
				%tmp_46 = arith.extsi %tmp_31 : i22 to i23
				%tmp_47 = arith.addi %tmp_45, %tmp_46 : i23
				%tmp_48 = arith.trunci %tmp_47 : i23 to i22
				// l_y__j__plus__1__76_d3_0 aliased to tmp_48
				// Assignment Statement: End
				scf.yield %tmp_44, %tmp_48 : i22, i22
			}
			// If Statement: End
			// Assignment Statement: Start
			// l_x__j__72_d2_1 aliased to l_x__j__plus__1__73_d2_1
			// Assignment Statement: End
			// Assignment Statement: Start
			// l_y__j__75_d2_1 aliased to l_y__j__plus__1__76_d2_1
			// Assignment Statement: End
			scf.yield %l_x__j__plus__1__73_d2_1, %l_x__j__plus__1__73_d2_1, %tmp_31, %l_y__j__plus__1__76_d2_1, %l_y__j__plus__1__76_d2_1, %tmp_29 : i22, i22, i22, i22, i22, i22
		}
		// Foreach Statement: End
		// Assignment Statement: Start
		// Evaluate global variable k_CORDIC_constant.
		%tmp_50 = arith.constant 318375 : i19
		%tmp_51 = arith.extui %tmp_50 : i19 to i22
		// Evaluate global variable k_CORDIC_constant done: assigned to tmp_51 above in this context.
		// Evaluate global variable fixedPointMultiply.
		%tmp_49 = func.call @g_qrd_fixedPointMultiply(%tmp_51,%l_y__j__75_d1_2) : (i22,i22) -> i22
		// l_x__out__71_d1_1 aliased to tmp_49
		// Assignment Statement: End
		// Assignment Statement: Start
		// Evaluate global variable k_CORDIC_constant.
		%tmp_53 = arith.constant 318375 : i19
		%tmp_54 = arith.extui %tmp_53 : i19 to i22
		// Evaluate global variable k_CORDIC_constant done: assigned to tmp_54 above in this context.
		// Evaluate global variable fixedPointMultiply.
		%tmp_52 = func.call @g_qrd_fixedPointMultiply(%tmp_54,%l_x__j__72_d1_2) : (i22,i22) -> i22
		cal.set(%l_r__63: !cal.state_ref<i22>, %tmp_52: i22)
		// Assignment Statement: End
		// Assignment Statement: Start
		%tmp_55 = cal.get(%l_count__64: !cal.state_ref<i32>) : i32
		%tmp_56 = arith.constant 1 : i1
		%tmp_57 = arith.extui %tmp_56 : i1 to i32
		%tmp_58 = arith.addi %tmp_55, %tmp_57 : i32
		cal.set(%l_count__64: !cal.state_ref<i32>, %tmp_58: i32)
		// Assignment Statement: End
		// Assignment Statement: Start
		%tmp_59 = arith.constant 0 : i1
		%tmp_60 = arith.extui %tmp_59 : i1 to i32
		cal.set(%l_$state: !cal.state_ref<i32>, %tmp_60: i32)
		// Assignment Statement: End
		// Output Expression: Start
		fifo.push(%x_out: !fifo.input_port<i22>, %tmp_49: i22)
		// Output Expression: End
		// Output Expression: Start
		fifo.push(%cordic_angles_out: !fifo.input_port<i16>, %l_rotation__angles__69_d1_0: i16)
		// Output Expression: End
	}
	// Generation action: final
	cal.action "final" priority=0 {
		// Guard: Start
		cal.predicate {
			%tmp_61 = cal.get(%l_count__64: !cal.state_ref<i32>) : i32
			// Evaluate global variable $eval1.
			%tmp_62 = arith.constant 4 : i3
			%tmp_63 = arith.extui %tmp_62 : i3 to i32
			// Evaluate global variable $eval1 done: assigned to tmp_63 above in this context.
			%tmp_64 = arith.cmpi eq, %tmp_61, %tmp_63 : i32
			cal.predicate_result %tmp_64 : i1
		}
		// Guard: End
		// Assignment Statement: Start
		%tmp_65 = arith.constant 0 : i1
		%tmp_66 = arith.extui %tmp_65 : i1 to i32
		cal.set(%l_count__64: !cal.state_ref<i32>, %tmp_66: i32)
		// Assignment Statement: End
		// Assignment Statement: Start
		%tmp_67 = arith.constant 0 : i1
		%tmp_68 = arith.extui %tmp_67 : i1 to i32
		cal.set(%l_$state: !cal.state_ref<i32>, %tmp_68: i32)
		// Assignment Statement: End
		// Output Expression: Start
		%tmp_69 = cal.get(%l_r__63: !cal.state_ref<i22>) : i22
		fifo.push(%r_out: !fifo.input_port<i22>, %tmp_69: i22)
		// Output Expression: End
	}
}

//-- Definition of actor class: InnerCell
cal.actor @innerCells_q_8 ()
	ports_in(%x_in: !fifo.output_port<i22>,%cordic_angles_in: !fifo.output_port<i16>)
	ports_out(%x_out: !fifo.input_port<i22>,%r_out: !fifo.input_port<i22>,%cordic_angles_out: !fifo.input_port<i16>)
{
	// -- Actor body
	%l_r__63 = cal.create_state_var<i22> : !cal.state_ref<i22>
	%tmp_0 = arith.constant 0 : i1
	%tmp_1 = arith.extui %tmp_0 : i1 to i22
	cal.set(%l_r__63: !cal.state_ref<i22>, %tmp_1: i22)
	%l_count__64 = cal.create_state_var<i32> : !cal.state_ref<i32>
	%tmp_2 = arith.constant 0 : i1
	%tmp_3 = arith.extui %tmp_2 : i1 to i32
	cal.set(%l_count__64: !cal.state_ref<i32>, %tmp_3: i32)
	%l_$state = cal.create_state_var<i32> : !cal.state_ref<i32>
	%tmp_4 = arith.constant 0 : i1
	%tmp_5 = arith.extui %tmp_4 : i1 to i32
	cal.set(%l_$state: !cal.state_ref<i32>, %tmp_5: i32)
	// Generation action: normal
	cal.action "normal" priority=0 {
		// Guard: Start
		cal.predicate {
			%tmp_6 = cal.get(%l_count__64: !cal.state_ref<i32>) : i32
			// Evaluate global variable $eval1.
			%tmp_7 = arith.constant 4 : i3
			%tmp_8 = arith.extui %tmp_7 : i3 to i32
			// Evaluate global variable $eval1 done: assigned to tmp_8 above in this context.
			%tmp_9 = arith.cmpi ult, %tmp_6, %tmp_8 : i32
			cal.predicate_result %tmp_9 : i1
		}
		// Guard: End
		// Input Pattern: Start
		%l_x__in__66_d1_0 = fifo.pop(%x_in: !fifo.output_port<i22>) : i22
		// Input Pattern: End
		// Input Pattern: Start
		%l_rotation__angles__69_d1_0 = fifo.pop(%cordic_angles_in: !fifo.output_port<i16>) : i16
		// Input Pattern: End
		// Action Local Variable Decl: Start
		%l_x__out__71_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_x__j__72_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_x__j__plus__1__73_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_x__j__shifted__74_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_y__j__75_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_y__j__plus__1__76_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_y__j__shifted__77_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// If Statement: Begin
		%tmp_10 = cal.get(%l_count__64: !cal.state_ref<i32>) : i32
		%tmp_11 = arith.constant 0 : i1
		%tmp_12 = arith.extui %tmp_11 : i1 to i32
		%tmp_13 = arith.cmpi eq, %tmp_10, %tmp_12 : i32
		scf.if %tmp_13 {
			// Assignment Statement: Start
			%tmp_14 = arith.constant 0 : i1
			%tmp_15 = arith.extui %tmp_14 : i1 to i22
			cal.set(%l_r__63: !cal.state_ref<i22>, %tmp_15: i22)
			// Assignment Statement: End
		} else {
		}
		// If Statement: End
		// Assignment Statement: Start
		// l_x__j__72_d1_1 aliased to l_x__in__66_d1_0
		// Assignment Statement: End
		// Assignment Statement: Start
		%tmp_16 = cal.get(%l_r__63: !cal.state_ref<i22>) : i22
		// l_y__j__75_d1_1 aliased to tmp_16
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
		%l_x__j__72_d1_2, %l_x__j__plus__1__73_d1_1, %l_x__j__shifted__74_d1_1, %l_y__j__75_d1_2, %l_y__j__plus__1__76_d1_1, %l_y__j__shifted__77_d1_1 = scf.for %l_j_d1_0 = %tmp_19_lb to %tmp_27_ub_plus_1 step %tmp_26_step
				iter_args(%l_x__j__72_d2_0 = %l_x__in__66_d1_0, %l_x__j__plus__1__73_d2_0 = %l_x__j__plus__1__73_d1_0, %l_x__j__shifted__74_d2_0 = %l_x__j__shifted__74_d1_0, %l_y__j__75_d2_0 = %tmp_16, %l_y__j__plus__1__76_d2_0 = %l_y__j__plus__1__76_d1_0, %l_y__j__shifted__77_d2_0 = %l_y__j__shifted__77_d1_0) -> (i22, i22, i22, i22, i22, i22) {
			%l_j_d2_0 = arith.index_cast %l_j_d1_0 : index to i32
			%l_j_d2_1 = arith.trunci %l_j_d2_0 : i32 to i8
			// Assignment Statement: Start
			%tmp_28 = arith.extui %l_j_d2_1 : i8 to i22
			%tmp_29 = arith.shrsi %l_y__j__75_d2_0, %tmp_28 : i22
			// l_y__j__shifted__77_d2_1 aliased to tmp_29
			// Assignment Statement: End
			// Assignment Statement: Start
			%tmp_30 = arith.extui %l_j_d2_1 : i8 to i22
			%tmp_31 = arith.shrsi %l_x__j__72_d2_0, %tmp_30 : i22
			// l_x__j__shifted__74_d2_1 aliased to tmp_31
			// Assignment Statement: End
			// If Statement: Begin
			%tmp_32 = arith.extui %l_j_d2_1 : i8 to i16
			%tmp_33 = arith.shrui %l_rotation__angles__69_d1_0, %tmp_32 : i16
			%tmp_34 = arith.constant 1 : i1
			%tmp_35 = arith.trunci %tmp_33 : i16 to i1
			%tmp_36 = arith.andi %tmp_35, %tmp_34 : i1
			%tmp_37 = arith.constant 1 : i1
			%tmp_38 = arith.cmpi eq, %tmp_36, %tmp_37 : i1
			%l_x__j__plus__1__73_d2_1, %l_y__j__plus__1__76_d2_1 = scf.if %tmp_38 -> (i22, i22) {
				// Assignment Statement: Start
				%tmp_39 = arith.extsi %l_x__j__72_d2_0 : i22 to i23
				%tmp_40 = arith.extsi %tmp_29 : i22 to i23
				%tmp_41 = arith.addi %tmp_39, %tmp_40 : i23
				%tmp_42 = arith.trunci %tmp_41 : i23 to i22
				// l_x__j__plus__1__73_d3_0 aliased to tmp_42
				// Assignment Statement: End
				// Assignment Statement: Start
				%tmp_43 = arith.subi %l_y__j__75_d2_0, %tmp_31 : i22
				// l_y__j__plus__1__76_d3_0 aliased to tmp_43
				// Assignment Statement: End
				scf.yield %tmp_42, %tmp_43 : i22, i22
			} else {
				// Assignment Statement: Start
				%tmp_44 = arith.subi %l_x__j__72_d2_0, %tmp_29 : i22
				// l_x__j__plus__1__73_d3_0 aliased to tmp_44
				// Assignment Statement: End
				// Assignment Statement: Start
				%tmp_45 = arith.extsi %l_y__j__75_d2_0 : i22 to i23
				%tmp_46 = arith.extsi %tmp_31 : i22 to i23
				%tmp_47 = arith.addi %tmp_45, %tmp_46 : i23
				%tmp_48 = arith.trunci %tmp_47 : i23 to i22
				// l_y__j__plus__1__76_d3_0 aliased to tmp_48
				// Assignment Statement: End
				scf.yield %tmp_44, %tmp_48 : i22, i22
			}
			// If Statement: End
			// Assignment Statement: Start
			// l_x__j__72_d2_1 aliased to l_x__j__plus__1__73_d2_1
			// Assignment Statement: End
			// Assignment Statement: Start
			// l_y__j__75_d2_1 aliased to l_y__j__plus__1__76_d2_1
			// Assignment Statement: End
			scf.yield %l_x__j__plus__1__73_d2_1, %l_x__j__plus__1__73_d2_1, %tmp_31, %l_y__j__plus__1__76_d2_1, %l_y__j__plus__1__76_d2_1, %tmp_29 : i22, i22, i22, i22, i22, i22
		}
		// Foreach Statement: End
		// Assignment Statement: Start
		// Evaluate global variable k_CORDIC_constant.
		%tmp_50 = arith.constant 318375 : i19
		%tmp_51 = arith.extui %tmp_50 : i19 to i22
		// Evaluate global variable k_CORDIC_constant done: assigned to tmp_51 above in this context.
		// Evaluate global variable fixedPointMultiply.
		%tmp_49 = func.call @g_qrd_fixedPointMultiply(%tmp_51,%l_y__j__75_d1_2) : (i22,i22) -> i22
		// l_x__out__71_d1_1 aliased to tmp_49
		// Assignment Statement: End
		// Assignment Statement: Start
		// Evaluate global variable k_CORDIC_constant.
		%tmp_53 = arith.constant 318375 : i19
		%tmp_54 = arith.extui %tmp_53 : i19 to i22
		// Evaluate global variable k_CORDIC_constant done: assigned to tmp_54 above in this context.
		// Evaluate global variable fixedPointMultiply.
		%tmp_52 = func.call @g_qrd_fixedPointMultiply(%tmp_54,%l_x__j__72_d1_2) : (i22,i22) -> i22
		cal.set(%l_r__63: !cal.state_ref<i22>, %tmp_52: i22)
		// Assignment Statement: End
		// Assignment Statement: Start
		%tmp_55 = cal.get(%l_count__64: !cal.state_ref<i32>) : i32
		%tmp_56 = arith.constant 1 : i1
		%tmp_57 = arith.extui %tmp_56 : i1 to i32
		%tmp_58 = arith.addi %tmp_55, %tmp_57 : i32
		cal.set(%l_count__64: !cal.state_ref<i32>, %tmp_58: i32)
		// Assignment Statement: End
		// Assignment Statement: Start
		%tmp_59 = arith.constant 0 : i1
		%tmp_60 = arith.extui %tmp_59 : i1 to i32
		cal.set(%l_$state: !cal.state_ref<i32>, %tmp_60: i32)
		// Assignment Statement: End
		// Output Expression: Start
		fifo.push(%x_out: !fifo.input_port<i22>, %tmp_49: i22)
		// Output Expression: End
		// Output Expression: Start
		fifo.push(%cordic_angles_out: !fifo.input_port<i16>, %l_rotation__angles__69_d1_0: i16)
		// Output Expression: End
	}
	// Generation action: final
	cal.action "final" priority=0 {
		// Guard: Start
		cal.predicate {
			%tmp_61 = cal.get(%l_count__64: !cal.state_ref<i32>) : i32
			// Evaluate global variable $eval1.
			%tmp_62 = arith.constant 4 : i3
			%tmp_63 = arith.extui %tmp_62 : i3 to i32
			// Evaluate global variable $eval1 done: assigned to tmp_63 above in this context.
			%tmp_64 = arith.cmpi eq, %tmp_61, %tmp_63 : i32
			cal.predicate_result %tmp_64 : i1
		}
		// Guard: End
		// Assignment Statement: Start
		%tmp_65 = arith.constant 0 : i1
		%tmp_66 = arith.extui %tmp_65 : i1 to i32
		cal.set(%l_count__64: !cal.state_ref<i32>, %tmp_66: i32)
		// Assignment Statement: End
		// Assignment Statement: Start
		%tmp_67 = arith.constant 0 : i1
		%tmp_68 = arith.extui %tmp_67 : i1 to i32
		cal.set(%l_$state: !cal.state_ref<i32>, %tmp_68: i32)
		// Assignment Statement: End
		// Output Expression: Start
		%tmp_69 = cal.get(%l_r__63: !cal.state_ref<i22>) : i22
		fifo.push(%r_out: !fifo.input_port<i22>, %tmp_69: i22)
		// Output Expression: End
	}
}

//-- Definition of actor class: InnerCell
cal.actor @innerCells_q_9 ()
	ports_in(%x_in: !fifo.output_port<i22>,%cordic_angles_in: !fifo.output_port<i16>)
	ports_out(%x_out: !fifo.input_port<i22>,%r_out: !fifo.input_port<i22>,%cordic_angles_out: !fifo.input_port<i16>)
{
	// -- Actor body
	%l_r__63 = cal.create_state_var<i22> : !cal.state_ref<i22>
	%tmp_0 = arith.constant 0 : i1
	%tmp_1 = arith.extui %tmp_0 : i1 to i22
	cal.set(%l_r__63: !cal.state_ref<i22>, %tmp_1: i22)
	%l_count__64 = cal.create_state_var<i32> : !cal.state_ref<i32>
	%tmp_2 = arith.constant 0 : i1
	%tmp_3 = arith.extui %tmp_2 : i1 to i32
	cal.set(%l_count__64: !cal.state_ref<i32>, %tmp_3: i32)
	%l_$state = cal.create_state_var<i32> : !cal.state_ref<i32>
	%tmp_4 = arith.constant 0 : i1
	%tmp_5 = arith.extui %tmp_4 : i1 to i32
	cal.set(%l_$state: !cal.state_ref<i32>, %tmp_5: i32)
	// Generation action: normal
	cal.action "normal" priority=0 {
		// Guard: Start
		cal.predicate {
			%tmp_6 = cal.get(%l_count__64: !cal.state_ref<i32>) : i32
			// Evaluate global variable $eval1.
			%tmp_7 = arith.constant 4 : i3
			%tmp_8 = arith.extui %tmp_7 : i3 to i32
			// Evaluate global variable $eval1 done: assigned to tmp_8 above in this context.
			%tmp_9 = arith.cmpi ult, %tmp_6, %tmp_8 : i32
			cal.predicate_result %tmp_9 : i1
		}
		// Guard: End
		// Input Pattern: Start
		%l_x__in__66_d1_0 = fifo.pop(%x_in: !fifo.output_port<i22>) : i22
		// Input Pattern: End
		// Input Pattern: Start
		%l_rotation__angles__69_d1_0 = fifo.pop(%cordic_angles_in: !fifo.output_port<i16>) : i16
		// Input Pattern: End
		// Action Local Variable Decl: Start
		%l_x__out__71_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_x__j__72_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_x__j__plus__1__73_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_x__j__shifted__74_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_y__j__75_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_y__j__plus__1__76_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_y__j__shifted__77_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// If Statement: Begin
		%tmp_10 = cal.get(%l_count__64: !cal.state_ref<i32>) : i32
		%tmp_11 = arith.constant 0 : i1
		%tmp_12 = arith.extui %tmp_11 : i1 to i32
		%tmp_13 = arith.cmpi eq, %tmp_10, %tmp_12 : i32
		scf.if %tmp_13 {
			// Assignment Statement: Start
			%tmp_14 = arith.constant 0 : i1
			%tmp_15 = arith.extui %tmp_14 : i1 to i22
			cal.set(%l_r__63: !cal.state_ref<i22>, %tmp_15: i22)
			// Assignment Statement: End
		} else {
		}
		// If Statement: End
		// Assignment Statement: Start
		// l_x__j__72_d1_1 aliased to l_x__in__66_d1_0
		// Assignment Statement: End
		// Assignment Statement: Start
		%tmp_16 = cal.get(%l_r__63: !cal.state_ref<i22>) : i22
		// l_y__j__75_d1_1 aliased to tmp_16
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
		%l_x__j__72_d1_2, %l_x__j__plus__1__73_d1_1, %l_x__j__shifted__74_d1_1, %l_y__j__75_d1_2, %l_y__j__plus__1__76_d1_1, %l_y__j__shifted__77_d1_1 = scf.for %l_j_d1_0 = %tmp_19_lb to %tmp_27_ub_plus_1 step %tmp_26_step
				iter_args(%l_x__j__72_d2_0 = %l_x__in__66_d1_0, %l_x__j__plus__1__73_d2_0 = %l_x__j__plus__1__73_d1_0, %l_x__j__shifted__74_d2_0 = %l_x__j__shifted__74_d1_0, %l_y__j__75_d2_0 = %tmp_16, %l_y__j__plus__1__76_d2_0 = %l_y__j__plus__1__76_d1_0, %l_y__j__shifted__77_d2_0 = %l_y__j__shifted__77_d1_0) -> (i22, i22, i22, i22, i22, i22) {
			%l_j_d2_0 = arith.index_cast %l_j_d1_0 : index to i32
			%l_j_d2_1 = arith.trunci %l_j_d2_0 : i32 to i8
			// Assignment Statement: Start
			%tmp_28 = arith.extui %l_j_d2_1 : i8 to i22
			%tmp_29 = arith.shrsi %l_y__j__75_d2_0, %tmp_28 : i22
			// l_y__j__shifted__77_d2_1 aliased to tmp_29
			// Assignment Statement: End
			// Assignment Statement: Start
			%tmp_30 = arith.extui %l_j_d2_1 : i8 to i22
			%tmp_31 = arith.shrsi %l_x__j__72_d2_0, %tmp_30 : i22
			// l_x__j__shifted__74_d2_1 aliased to tmp_31
			// Assignment Statement: End
			// If Statement: Begin
			%tmp_32 = arith.extui %l_j_d2_1 : i8 to i16
			%tmp_33 = arith.shrui %l_rotation__angles__69_d1_0, %tmp_32 : i16
			%tmp_34 = arith.constant 1 : i1
			%tmp_35 = arith.trunci %tmp_33 : i16 to i1
			%tmp_36 = arith.andi %tmp_35, %tmp_34 : i1
			%tmp_37 = arith.constant 1 : i1
			%tmp_38 = arith.cmpi eq, %tmp_36, %tmp_37 : i1
			%l_x__j__plus__1__73_d2_1, %l_y__j__plus__1__76_d2_1 = scf.if %tmp_38 -> (i22, i22) {
				// Assignment Statement: Start
				%tmp_39 = arith.extsi %l_x__j__72_d2_0 : i22 to i23
				%tmp_40 = arith.extsi %tmp_29 : i22 to i23
				%tmp_41 = arith.addi %tmp_39, %tmp_40 : i23
				%tmp_42 = arith.trunci %tmp_41 : i23 to i22
				// l_x__j__plus__1__73_d3_0 aliased to tmp_42
				// Assignment Statement: End
				// Assignment Statement: Start
				%tmp_43 = arith.subi %l_y__j__75_d2_0, %tmp_31 : i22
				// l_y__j__plus__1__76_d3_0 aliased to tmp_43
				// Assignment Statement: End
				scf.yield %tmp_42, %tmp_43 : i22, i22
			} else {
				// Assignment Statement: Start
				%tmp_44 = arith.subi %l_x__j__72_d2_0, %tmp_29 : i22
				// l_x__j__plus__1__73_d3_0 aliased to tmp_44
				// Assignment Statement: End
				// Assignment Statement: Start
				%tmp_45 = arith.extsi %l_y__j__75_d2_0 : i22 to i23
				%tmp_46 = arith.extsi %tmp_31 : i22 to i23
				%tmp_47 = arith.addi %tmp_45, %tmp_46 : i23
				%tmp_48 = arith.trunci %tmp_47 : i23 to i22
				// l_y__j__plus__1__76_d3_0 aliased to tmp_48
				// Assignment Statement: End
				scf.yield %tmp_44, %tmp_48 : i22, i22
			}
			// If Statement: End
			// Assignment Statement: Start
			// l_x__j__72_d2_1 aliased to l_x__j__plus__1__73_d2_1
			// Assignment Statement: End
			// Assignment Statement: Start
			// l_y__j__75_d2_1 aliased to l_y__j__plus__1__76_d2_1
			// Assignment Statement: End
			scf.yield %l_x__j__plus__1__73_d2_1, %l_x__j__plus__1__73_d2_1, %tmp_31, %l_y__j__plus__1__76_d2_1, %l_y__j__plus__1__76_d2_1, %tmp_29 : i22, i22, i22, i22, i22, i22
		}
		// Foreach Statement: End
		// Assignment Statement: Start
		// Evaluate global variable k_CORDIC_constant.
		%tmp_50 = arith.constant 318375 : i19
		%tmp_51 = arith.extui %tmp_50 : i19 to i22
		// Evaluate global variable k_CORDIC_constant done: assigned to tmp_51 above in this context.
		// Evaluate global variable fixedPointMultiply.
		%tmp_49 = func.call @g_qrd_fixedPointMultiply(%tmp_51,%l_y__j__75_d1_2) : (i22,i22) -> i22
		// l_x__out__71_d1_1 aliased to tmp_49
		// Assignment Statement: End
		// Assignment Statement: Start
		// Evaluate global variable k_CORDIC_constant.
		%tmp_53 = arith.constant 318375 : i19
		%tmp_54 = arith.extui %tmp_53 : i19 to i22
		// Evaluate global variable k_CORDIC_constant done: assigned to tmp_54 above in this context.
		// Evaluate global variable fixedPointMultiply.
		%tmp_52 = func.call @g_qrd_fixedPointMultiply(%tmp_54,%l_x__j__72_d1_2) : (i22,i22) -> i22
		cal.set(%l_r__63: !cal.state_ref<i22>, %tmp_52: i22)
		// Assignment Statement: End
		// Assignment Statement: Start
		%tmp_55 = cal.get(%l_count__64: !cal.state_ref<i32>) : i32
		%tmp_56 = arith.constant 1 : i1
		%tmp_57 = arith.extui %tmp_56 : i1 to i32
		%tmp_58 = arith.addi %tmp_55, %tmp_57 : i32
		cal.set(%l_count__64: !cal.state_ref<i32>, %tmp_58: i32)
		// Assignment Statement: End
		// Assignment Statement: Start
		%tmp_59 = arith.constant 0 : i1
		%tmp_60 = arith.extui %tmp_59 : i1 to i32
		cal.set(%l_$state: !cal.state_ref<i32>, %tmp_60: i32)
		// Assignment Statement: End
		// Output Expression: Start
		fifo.push(%x_out: !fifo.input_port<i22>, %tmp_49: i22)
		// Output Expression: End
		// Output Expression: Start
		fifo.push(%cordic_angles_out: !fifo.input_port<i16>, %l_rotation__angles__69_d1_0: i16)
		// Output Expression: End
	}
	// Generation action: final
	cal.action "final" priority=0 {
		// Guard: Start
		cal.predicate {
			%tmp_61 = cal.get(%l_count__64: !cal.state_ref<i32>) : i32
			// Evaluate global variable $eval1.
			%tmp_62 = arith.constant 4 : i3
			%tmp_63 = arith.extui %tmp_62 : i3 to i32
			// Evaluate global variable $eval1 done: assigned to tmp_63 above in this context.
			%tmp_64 = arith.cmpi eq, %tmp_61, %tmp_63 : i32
			cal.predicate_result %tmp_64 : i1
		}
		// Guard: End
		// Assignment Statement: Start
		%tmp_65 = arith.constant 0 : i1
		%tmp_66 = arith.extui %tmp_65 : i1 to i32
		cal.set(%l_count__64: !cal.state_ref<i32>, %tmp_66: i32)
		// Assignment Statement: End
		// Assignment Statement: Start
		%tmp_67 = arith.constant 0 : i1
		%tmp_68 = arith.extui %tmp_67 : i1 to i32
		cal.set(%l_$state: !cal.state_ref<i32>, %tmp_68: i32)
		// Assignment Statement: End
		// Output Expression: Start
		%tmp_69 = cal.get(%l_r__63: !cal.state_ref<i22>) : i22
		fifo.push(%r_out: !fifo.input_port<i22>, %tmp_69: i22)
		// Output Expression: End
	}
}

//-- Definition of actor class: InnerCell
cal.actor @innerCells_q_6 ()
	ports_in(%x_in: !fifo.output_port<i22>,%cordic_angles_in: !fifo.output_port<i16>)
	ports_out(%x_out: !fifo.input_port<i22>,%r_out: !fifo.input_port<i22>,%cordic_angles_out: !fifo.input_port<i16>)
{
	// -- Actor body
	%l_r__63 = cal.create_state_var<i22> : !cal.state_ref<i22>
	%tmp_0 = arith.constant 0 : i1
	%tmp_1 = arith.extui %tmp_0 : i1 to i22
	cal.set(%l_r__63: !cal.state_ref<i22>, %tmp_1: i22)
	%l_count__64 = cal.create_state_var<i32> : !cal.state_ref<i32>
	%tmp_2 = arith.constant 0 : i1
	%tmp_3 = arith.extui %tmp_2 : i1 to i32
	cal.set(%l_count__64: !cal.state_ref<i32>, %tmp_3: i32)
	%l_$state = cal.create_state_var<i32> : !cal.state_ref<i32>
	%tmp_4 = arith.constant 0 : i1
	%tmp_5 = arith.extui %tmp_4 : i1 to i32
	cal.set(%l_$state: !cal.state_ref<i32>, %tmp_5: i32)
	// Generation action: normal
	cal.action "normal" priority=0 {
		// Guard: Start
		cal.predicate {
			%tmp_6 = cal.get(%l_count__64: !cal.state_ref<i32>) : i32
			// Evaluate global variable $eval1.
			%tmp_7 = arith.constant 4 : i3
			%tmp_8 = arith.extui %tmp_7 : i3 to i32
			// Evaluate global variable $eval1 done: assigned to tmp_8 above in this context.
			%tmp_9 = arith.cmpi ult, %tmp_6, %tmp_8 : i32
			cal.predicate_result %tmp_9 : i1
		}
		// Guard: End
		// Input Pattern: Start
		%l_x__in__66_d1_0 = fifo.pop(%x_in: !fifo.output_port<i22>) : i22
		// Input Pattern: End
		// Input Pattern: Start
		%l_rotation__angles__69_d1_0 = fifo.pop(%cordic_angles_in: !fifo.output_port<i16>) : i16
		// Input Pattern: End
		// Action Local Variable Decl: Start
		%l_x__out__71_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_x__j__72_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_x__j__plus__1__73_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_x__j__shifted__74_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_y__j__75_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_y__j__plus__1__76_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_y__j__shifted__77_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// If Statement: Begin
		%tmp_10 = cal.get(%l_count__64: !cal.state_ref<i32>) : i32
		%tmp_11 = arith.constant 0 : i1
		%tmp_12 = arith.extui %tmp_11 : i1 to i32
		%tmp_13 = arith.cmpi eq, %tmp_10, %tmp_12 : i32
		scf.if %tmp_13 {
			// Assignment Statement: Start
			%tmp_14 = arith.constant 0 : i1
			%tmp_15 = arith.extui %tmp_14 : i1 to i22
			cal.set(%l_r__63: !cal.state_ref<i22>, %tmp_15: i22)
			// Assignment Statement: End
		} else {
		}
		// If Statement: End
		// Assignment Statement: Start
		// l_x__j__72_d1_1 aliased to l_x__in__66_d1_0
		// Assignment Statement: End
		// Assignment Statement: Start
		%tmp_16 = cal.get(%l_r__63: !cal.state_ref<i22>) : i22
		// l_y__j__75_d1_1 aliased to tmp_16
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
		%l_x__j__72_d1_2, %l_x__j__plus__1__73_d1_1, %l_x__j__shifted__74_d1_1, %l_y__j__75_d1_2, %l_y__j__plus__1__76_d1_1, %l_y__j__shifted__77_d1_1 = scf.for %l_j_d1_0 = %tmp_19_lb to %tmp_27_ub_plus_1 step %tmp_26_step
				iter_args(%l_x__j__72_d2_0 = %l_x__in__66_d1_0, %l_x__j__plus__1__73_d2_0 = %l_x__j__plus__1__73_d1_0, %l_x__j__shifted__74_d2_0 = %l_x__j__shifted__74_d1_0, %l_y__j__75_d2_0 = %tmp_16, %l_y__j__plus__1__76_d2_0 = %l_y__j__plus__1__76_d1_0, %l_y__j__shifted__77_d2_0 = %l_y__j__shifted__77_d1_0) -> (i22, i22, i22, i22, i22, i22) {
			%l_j_d2_0 = arith.index_cast %l_j_d1_0 : index to i32
			%l_j_d2_1 = arith.trunci %l_j_d2_0 : i32 to i8
			// Assignment Statement: Start
			%tmp_28 = arith.extui %l_j_d2_1 : i8 to i22
			%tmp_29 = arith.shrsi %l_y__j__75_d2_0, %tmp_28 : i22
			// l_y__j__shifted__77_d2_1 aliased to tmp_29
			// Assignment Statement: End
			// Assignment Statement: Start
			%tmp_30 = arith.extui %l_j_d2_1 : i8 to i22
			%tmp_31 = arith.shrsi %l_x__j__72_d2_0, %tmp_30 : i22
			// l_x__j__shifted__74_d2_1 aliased to tmp_31
			// Assignment Statement: End
			// If Statement: Begin
			%tmp_32 = arith.extui %l_j_d2_1 : i8 to i16
			%tmp_33 = arith.shrui %l_rotation__angles__69_d1_0, %tmp_32 : i16
			%tmp_34 = arith.constant 1 : i1
			%tmp_35 = arith.trunci %tmp_33 : i16 to i1
			%tmp_36 = arith.andi %tmp_35, %tmp_34 : i1
			%tmp_37 = arith.constant 1 : i1
			%tmp_38 = arith.cmpi eq, %tmp_36, %tmp_37 : i1
			%l_x__j__plus__1__73_d2_1, %l_y__j__plus__1__76_d2_1 = scf.if %tmp_38 -> (i22, i22) {
				// Assignment Statement: Start
				%tmp_39 = arith.extsi %l_x__j__72_d2_0 : i22 to i23
				%tmp_40 = arith.extsi %tmp_29 : i22 to i23
				%tmp_41 = arith.addi %tmp_39, %tmp_40 : i23
				%tmp_42 = arith.trunci %tmp_41 : i23 to i22
				// l_x__j__plus__1__73_d3_0 aliased to tmp_42
				// Assignment Statement: End
				// Assignment Statement: Start
				%tmp_43 = arith.subi %l_y__j__75_d2_0, %tmp_31 : i22
				// l_y__j__plus__1__76_d3_0 aliased to tmp_43
				// Assignment Statement: End
				scf.yield %tmp_42, %tmp_43 : i22, i22
			} else {
				// Assignment Statement: Start
				%tmp_44 = arith.subi %l_x__j__72_d2_0, %tmp_29 : i22
				// l_x__j__plus__1__73_d3_0 aliased to tmp_44
				// Assignment Statement: End
				// Assignment Statement: Start
				%tmp_45 = arith.extsi %l_y__j__75_d2_0 : i22 to i23
				%tmp_46 = arith.extsi %tmp_31 : i22 to i23
				%tmp_47 = arith.addi %tmp_45, %tmp_46 : i23
				%tmp_48 = arith.trunci %tmp_47 : i23 to i22
				// l_y__j__plus__1__76_d3_0 aliased to tmp_48
				// Assignment Statement: End
				scf.yield %tmp_44, %tmp_48 : i22, i22
			}
			// If Statement: End
			// Assignment Statement: Start
			// l_x__j__72_d2_1 aliased to l_x__j__plus__1__73_d2_1
			// Assignment Statement: End
			// Assignment Statement: Start
			// l_y__j__75_d2_1 aliased to l_y__j__plus__1__76_d2_1
			// Assignment Statement: End
			scf.yield %l_x__j__plus__1__73_d2_1, %l_x__j__plus__1__73_d2_1, %tmp_31, %l_y__j__plus__1__76_d2_1, %l_y__j__plus__1__76_d2_1, %tmp_29 : i22, i22, i22, i22, i22, i22
		}
		// Foreach Statement: End
		// Assignment Statement: Start
		// Evaluate global variable k_CORDIC_constant.
		%tmp_50 = arith.constant 318375 : i19
		%tmp_51 = arith.extui %tmp_50 : i19 to i22
		// Evaluate global variable k_CORDIC_constant done: assigned to tmp_51 above in this context.
		// Evaluate global variable fixedPointMultiply.
		%tmp_49 = func.call @g_qrd_fixedPointMultiply(%tmp_51,%l_y__j__75_d1_2) : (i22,i22) -> i22
		// l_x__out__71_d1_1 aliased to tmp_49
		// Assignment Statement: End
		// Assignment Statement: Start
		// Evaluate global variable k_CORDIC_constant.
		%tmp_53 = arith.constant 318375 : i19
		%tmp_54 = arith.extui %tmp_53 : i19 to i22
		// Evaluate global variable k_CORDIC_constant done: assigned to tmp_54 above in this context.
		// Evaluate global variable fixedPointMultiply.
		%tmp_52 = func.call @g_qrd_fixedPointMultiply(%tmp_54,%l_x__j__72_d1_2) : (i22,i22) -> i22
		cal.set(%l_r__63: !cal.state_ref<i22>, %tmp_52: i22)
		// Assignment Statement: End
		// Assignment Statement: Start
		%tmp_55 = cal.get(%l_count__64: !cal.state_ref<i32>) : i32
		%tmp_56 = arith.constant 1 : i1
		%tmp_57 = arith.extui %tmp_56 : i1 to i32
		%tmp_58 = arith.addi %tmp_55, %tmp_57 : i32
		cal.set(%l_count__64: !cal.state_ref<i32>, %tmp_58: i32)
		// Assignment Statement: End
		// Assignment Statement: Start
		%tmp_59 = arith.constant 0 : i1
		%tmp_60 = arith.extui %tmp_59 : i1 to i32
		cal.set(%l_$state: !cal.state_ref<i32>, %tmp_60: i32)
		// Assignment Statement: End
		// Output Expression: Start
		fifo.push(%x_out: !fifo.input_port<i22>, %tmp_49: i22)
		// Output Expression: End
		// Output Expression: Start
		fifo.push(%cordic_angles_out: !fifo.input_port<i16>, %l_rotation__angles__69_d1_0: i16)
		// Output Expression: End
	}
	// Generation action: final
	cal.action "final" priority=0 {
		// Guard: Start
		cal.predicate {
			%tmp_61 = cal.get(%l_count__64: !cal.state_ref<i32>) : i32
			// Evaluate global variable $eval1.
			%tmp_62 = arith.constant 4 : i3
			%tmp_63 = arith.extui %tmp_62 : i3 to i32
			// Evaluate global variable $eval1 done: assigned to tmp_63 above in this context.
			%tmp_64 = arith.cmpi eq, %tmp_61, %tmp_63 : i32
			cal.predicate_result %tmp_64 : i1
		}
		// Guard: End
		// Assignment Statement: Start
		%tmp_65 = arith.constant 0 : i1
		%tmp_66 = arith.extui %tmp_65 : i1 to i32
		cal.set(%l_count__64: !cal.state_ref<i32>, %tmp_66: i32)
		// Assignment Statement: End
		// Assignment Statement: Start
		%tmp_67 = arith.constant 0 : i1
		%tmp_68 = arith.extui %tmp_67 : i1 to i32
		cal.set(%l_$state: !cal.state_ref<i32>, %tmp_68: i32)
		// Assignment Statement: End
		// Output Expression: Start
		%tmp_69 = cal.get(%l_r__63: !cal.state_ref<i22>) : i22
		fifo.push(%r_out: !fifo.input_port<i22>, %tmp_69: i22)
		// Output Expression: End
	}
}

//-- Definition of actor class: InnerCell
cal.actor @innerCells_q_7 ()
	ports_in(%x_in: !fifo.output_port<i22>,%cordic_angles_in: !fifo.output_port<i16>)
	ports_out(%x_out: !fifo.input_port<i22>,%r_out: !fifo.input_port<i22>,%cordic_angles_out: !fifo.input_port<i16>)
{
	// -- Actor body
	%l_r__63 = cal.create_state_var<i22> : !cal.state_ref<i22>
	%tmp_0 = arith.constant 0 : i1
	%tmp_1 = arith.extui %tmp_0 : i1 to i22
	cal.set(%l_r__63: !cal.state_ref<i22>, %tmp_1: i22)
	%l_count__64 = cal.create_state_var<i32> : !cal.state_ref<i32>
	%tmp_2 = arith.constant 0 : i1
	%tmp_3 = arith.extui %tmp_2 : i1 to i32
	cal.set(%l_count__64: !cal.state_ref<i32>, %tmp_3: i32)
	%l_$state = cal.create_state_var<i32> : !cal.state_ref<i32>
	%tmp_4 = arith.constant 0 : i1
	%tmp_5 = arith.extui %tmp_4 : i1 to i32
	cal.set(%l_$state: !cal.state_ref<i32>, %tmp_5: i32)
	// Generation action: normal
	cal.action "normal" priority=0 {
		// Guard: Start
		cal.predicate {
			%tmp_6 = cal.get(%l_count__64: !cal.state_ref<i32>) : i32
			// Evaluate global variable $eval1.
			%tmp_7 = arith.constant 4 : i3
			%tmp_8 = arith.extui %tmp_7 : i3 to i32
			// Evaluate global variable $eval1 done: assigned to tmp_8 above in this context.
			%tmp_9 = arith.cmpi ult, %tmp_6, %tmp_8 : i32
			cal.predicate_result %tmp_9 : i1
		}
		// Guard: End
		// Input Pattern: Start
		%l_x__in__66_d1_0 = fifo.pop(%x_in: !fifo.output_port<i22>) : i22
		// Input Pattern: End
		// Input Pattern: Start
		%l_rotation__angles__69_d1_0 = fifo.pop(%cordic_angles_in: !fifo.output_port<i16>) : i16
		// Input Pattern: End
		// Action Local Variable Decl: Start
		%l_x__out__71_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_x__j__72_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_x__j__plus__1__73_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_x__j__shifted__74_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_y__j__75_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_y__j__plus__1__76_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_y__j__shifted__77_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// If Statement: Begin
		%tmp_10 = cal.get(%l_count__64: !cal.state_ref<i32>) : i32
		%tmp_11 = arith.constant 0 : i1
		%tmp_12 = arith.extui %tmp_11 : i1 to i32
		%tmp_13 = arith.cmpi eq, %tmp_10, %tmp_12 : i32
		scf.if %tmp_13 {
			// Assignment Statement: Start
			%tmp_14 = arith.constant 0 : i1
			%tmp_15 = arith.extui %tmp_14 : i1 to i22
			cal.set(%l_r__63: !cal.state_ref<i22>, %tmp_15: i22)
			// Assignment Statement: End
		} else {
		}
		// If Statement: End
		// Assignment Statement: Start
		// l_x__j__72_d1_1 aliased to l_x__in__66_d1_0
		// Assignment Statement: End
		// Assignment Statement: Start
		%tmp_16 = cal.get(%l_r__63: !cal.state_ref<i22>) : i22
		// l_y__j__75_d1_1 aliased to tmp_16
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
		%l_x__j__72_d1_2, %l_x__j__plus__1__73_d1_1, %l_x__j__shifted__74_d1_1, %l_y__j__75_d1_2, %l_y__j__plus__1__76_d1_1, %l_y__j__shifted__77_d1_1 = scf.for %l_j_d1_0 = %tmp_19_lb to %tmp_27_ub_plus_1 step %tmp_26_step
				iter_args(%l_x__j__72_d2_0 = %l_x__in__66_d1_0, %l_x__j__plus__1__73_d2_0 = %l_x__j__plus__1__73_d1_0, %l_x__j__shifted__74_d2_0 = %l_x__j__shifted__74_d1_0, %l_y__j__75_d2_0 = %tmp_16, %l_y__j__plus__1__76_d2_0 = %l_y__j__plus__1__76_d1_0, %l_y__j__shifted__77_d2_0 = %l_y__j__shifted__77_d1_0) -> (i22, i22, i22, i22, i22, i22) {
			%l_j_d2_0 = arith.index_cast %l_j_d1_0 : index to i32
			%l_j_d2_1 = arith.trunci %l_j_d2_0 : i32 to i8
			// Assignment Statement: Start
			%tmp_28 = arith.extui %l_j_d2_1 : i8 to i22
			%tmp_29 = arith.shrsi %l_y__j__75_d2_0, %tmp_28 : i22
			// l_y__j__shifted__77_d2_1 aliased to tmp_29
			// Assignment Statement: End
			// Assignment Statement: Start
			%tmp_30 = arith.extui %l_j_d2_1 : i8 to i22
			%tmp_31 = arith.shrsi %l_x__j__72_d2_0, %tmp_30 : i22
			// l_x__j__shifted__74_d2_1 aliased to tmp_31
			// Assignment Statement: End
			// If Statement: Begin
			%tmp_32 = arith.extui %l_j_d2_1 : i8 to i16
			%tmp_33 = arith.shrui %l_rotation__angles__69_d1_0, %tmp_32 : i16
			%tmp_34 = arith.constant 1 : i1
			%tmp_35 = arith.trunci %tmp_33 : i16 to i1
			%tmp_36 = arith.andi %tmp_35, %tmp_34 : i1
			%tmp_37 = arith.constant 1 : i1
			%tmp_38 = arith.cmpi eq, %tmp_36, %tmp_37 : i1
			%l_x__j__plus__1__73_d2_1, %l_y__j__plus__1__76_d2_1 = scf.if %tmp_38 -> (i22, i22) {
				// Assignment Statement: Start
				%tmp_39 = arith.extsi %l_x__j__72_d2_0 : i22 to i23
				%tmp_40 = arith.extsi %tmp_29 : i22 to i23
				%tmp_41 = arith.addi %tmp_39, %tmp_40 : i23
				%tmp_42 = arith.trunci %tmp_41 : i23 to i22
				// l_x__j__plus__1__73_d3_0 aliased to tmp_42
				// Assignment Statement: End
				// Assignment Statement: Start
				%tmp_43 = arith.subi %l_y__j__75_d2_0, %tmp_31 : i22
				// l_y__j__plus__1__76_d3_0 aliased to tmp_43
				// Assignment Statement: End
				scf.yield %tmp_42, %tmp_43 : i22, i22
			} else {
				// Assignment Statement: Start
				%tmp_44 = arith.subi %l_x__j__72_d2_0, %tmp_29 : i22
				// l_x__j__plus__1__73_d3_0 aliased to tmp_44
				// Assignment Statement: End
				// Assignment Statement: Start
				%tmp_45 = arith.extsi %l_y__j__75_d2_0 : i22 to i23
				%tmp_46 = arith.extsi %tmp_31 : i22 to i23
				%tmp_47 = arith.addi %tmp_45, %tmp_46 : i23
				%tmp_48 = arith.trunci %tmp_47 : i23 to i22
				// l_y__j__plus__1__76_d3_0 aliased to tmp_48
				// Assignment Statement: End
				scf.yield %tmp_44, %tmp_48 : i22, i22
			}
			// If Statement: End
			// Assignment Statement: Start
			// l_x__j__72_d2_1 aliased to l_x__j__plus__1__73_d2_1
			// Assignment Statement: End
			// Assignment Statement: Start
			// l_y__j__75_d2_1 aliased to l_y__j__plus__1__76_d2_1
			// Assignment Statement: End
			scf.yield %l_x__j__plus__1__73_d2_1, %l_x__j__plus__1__73_d2_1, %tmp_31, %l_y__j__plus__1__76_d2_1, %l_y__j__plus__1__76_d2_1, %tmp_29 : i22, i22, i22, i22, i22, i22
		}
		// Foreach Statement: End
		// Assignment Statement: Start
		// Evaluate global variable k_CORDIC_constant.
		%tmp_50 = arith.constant 318375 : i19
		%tmp_51 = arith.extui %tmp_50 : i19 to i22
		// Evaluate global variable k_CORDIC_constant done: assigned to tmp_51 above in this context.
		// Evaluate global variable fixedPointMultiply.
		%tmp_49 = func.call @g_qrd_fixedPointMultiply(%tmp_51,%l_y__j__75_d1_2) : (i22,i22) -> i22
		// l_x__out__71_d1_1 aliased to tmp_49
		// Assignment Statement: End
		// Assignment Statement: Start
		// Evaluate global variable k_CORDIC_constant.
		%tmp_53 = arith.constant 318375 : i19
		%tmp_54 = arith.extui %tmp_53 : i19 to i22
		// Evaluate global variable k_CORDIC_constant done: assigned to tmp_54 above in this context.
		// Evaluate global variable fixedPointMultiply.
		%tmp_52 = func.call @g_qrd_fixedPointMultiply(%tmp_54,%l_x__j__72_d1_2) : (i22,i22) -> i22
		cal.set(%l_r__63: !cal.state_ref<i22>, %tmp_52: i22)
		// Assignment Statement: End
		// Assignment Statement: Start
		%tmp_55 = cal.get(%l_count__64: !cal.state_ref<i32>) : i32
		%tmp_56 = arith.constant 1 : i1
		%tmp_57 = arith.extui %tmp_56 : i1 to i32
		%tmp_58 = arith.addi %tmp_55, %tmp_57 : i32
		cal.set(%l_count__64: !cal.state_ref<i32>, %tmp_58: i32)
		// Assignment Statement: End
		// Assignment Statement: Start
		%tmp_59 = arith.constant 0 : i1
		%tmp_60 = arith.extui %tmp_59 : i1 to i32
		cal.set(%l_$state: !cal.state_ref<i32>, %tmp_60: i32)
		// Assignment Statement: End
		// Output Expression: Start
		fifo.push(%x_out: !fifo.input_port<i22>, %tmp_49: i22)
		// Output Expression: End
		// Output Expression: Start
		fifo.push(%cordic_angles_out: !fifo.input_port<i16>, %l_rotation__angles__69_d1_0: i16)
		// Output Expression: End
	}
	// Generation action: final
	cal.action "final" priority=0 {
		// Guard: Start
		cal.predicate {
			%tmp_61 = cal.get(%l_count__64: !cal.state_ref<i32>) : i32
			// Evaluate global variable $eval1.
			%tmp_62 = arith.constant 4 : i3
			%tmp_63 = arith.extui %tmp_62 : i3 to i32
			// Evaluate global variable $eval1 done: assigned to tmp_63 above in this context.
			%tmp_64 = arith.cmpi eq, %tmp_61, %tmp_63 : i32
			cal.predicate_result %tmp_64 : i1
		}
		// Guard: End
		// Assignment Statement: Start
		%tmp_65 = arith.constant 0 : i1
		%tmp_66 = arith.extui %tmp_65 : i1 to i32
		cal.set(%l_count__64: !cal.state_ref<i32>, %tmp_66: i32)
		// Assignment Statement: End
		// Assignment Statement: Start
		%tmp_67 = arith.constant 0 : i1
		%tmp_68 = arith.extui %tmp_67 : i1 to i32
		cal.set(%l_$state: !cal.state_ref<i32>, %tmp_68: i32)
		// Assignment Statement: End
		// Output Expression: Start
		%tmp_69 = cal.get(%l_r__63: !cal.state_ref<i22>) : i22
		fifo.push(%r_out: !fifo.input_port<i22>, %tmp_69: i22)
		// Output Expression: End
	}
}

//-- Definition of actor class: InnerCell
cal.actor @innerCells_q_4 ()
	ports_in(%x_in: !fifo.output_port<i22>,%cordic_angles_in: !fifo.output_port<i16>)
	ports_out(%x_out: !fifo.input_port<i22>,%r_out: !fifo.input_port<i22>,%cordic_angles_out: !fifo.input_port<i16>)
{
	// -- Actor body
	%l_r__63 = cal.create_state_var<i22> : !cal.state_ref<i22>
	%tmp_0 = arith.constant 0 : i1
	%tmp_1 = arith.extui %tmp_0 : i1 to i22
	cal.set(%l_r__63: !cal.state_ref<i22>, %tmp_1: i22)
	%l_count__64 = cal.create_state_var<i32> : !cal.state_ref<i32>
	%tmp_2 = arith.constant 0 : i1
	%tmp_3 = arith.extui %tmp_2 : i1 to i32
	cal.set(%l_count__64: !cal.state_ref<i32>, %tmp_3: i32)
	%l_$state = cal.create_state_var<i32> : !cal.state_ref<i32>
	%tmp_4 = arith.constant 0 : i1
	%tmp_5 = arith.extui %tmp_4 : i1 to i32
	cal.set(%l_$state: !cal.state_ref<i32>, %tmp_5: i32)
	// Generation action: normal
	cal.action "normal" priority=0 {
		// Guard: Start
		cal.predicate {
			%tmp_6 = cal.get(%l_count__64: !cal.state_ref<i32>) : i32
			// Evaluate global variable $eval1.
			%tmp_7 = arith.constant 4 : i3
			%tmp_8 = arith.extui %tmp_7 : i3 to i32
			// Evaluate global variable $eval1 done: assigned to tmp_8 above in this context.
			%tmp_9 = arith.cmpi ult, %tmp_6, %tmp_8 : i32
			cal.predicate_result %tmp_9 : i1
		}
		// Guard: End
		// Input Pattern: Start
		%l_x__in__66_d1_0 = fifo.pop(%x_in: !fifo.output_port<i22>) : i22
		// Input Pattern: End
		// Input Pattern: Start
		%l_rotation__angles__69_d1_0 = fifo.pop(%cordic_angles_in: !fifo.output_port<i16>) : i16
		// Input Pattern: End
		// Action Local Variable Decl: Start
		%l_x__out__71_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_x__j__72_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_x__j__plus__1__73_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_x__j__shifted__74_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_y__j__75_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_y__j__plus__1__76_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_y__j__shifted__77_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// If Statement: Begin
		%tmp_10 = cal.get(%l_count__64: !cal.state_ref<i32>) : i32
		%tmp_11 = arith.constant 0 : i1
		%tmp_12 = arith.extui %tmp_11 : i1 to i32
		%tmp_13 = arith.cmpi eq, %tmp_10, %tmp_12 : i32
		scf.if %tmp_13 {
			// Assignment Statement: Start
			%tmp_14 = arith.constant 0 : i1
			%tmp_15 = arith.extui %tmp_14 : i1 to i22
			cal.set(%l_r__63: !cal.state_ref<i22>, %tmp_15: i22)
			// Assignment Statement: End
		} else {
		}
		// If Statement: End
		// Assignment Statement: Start
		// l_x__j__72_d1_1 aliased to l_x__in__66_d1_0
		// Assignment Statement: End
		// Assignment Statement: Start
		%tmp_16 = cal.get(%l_r__63: !cal.state_ref<i22>) : i22
		// l_y__j__75_d1_1 aliased to tmp_16
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
		%l_x__j__72_d1_2, %l_x__j__plus__1__73_d1_1, %l_x__j__shifted__74_d1_1, %l_y__j__75_d1_2, %l_y__j__plus__1__76_d1_1, %l_y__j__shifted__77_d1_1 = scf.for %l_j_d1_0 = %tmp_19_lb to %tmp_27_ub_plus_1 step %tmp_26_step
				iter_args(%l_x__j__72_d2_0 = %l_x__in__66_d1_0, %l_x__j__plus__1__73_d2_0 = %l_x__j__plus__1__73_d1_0, %l_x__j__shifted__74_d2_0 = %l_x__j__shifted__74_d1_0, %l_y__j__75_d2_0 = %tmp_16, %l_y__j__plus__1__76_d2_0 = %l_y__j__plus__1__76_d1_0, %l_y__j__shifted__77_d2_0 = %l_y__j__shifted__77_d1_0) -> (i22, i22, i22, i22, i22, i22) {
			%l_j_d2_0 = arith.index_cast %l_j_d1_0 : index to i32
			%l_j_d2_1 = arith.trunci %l_j_d2_0 : i32 to i8
			// Assignment Statement: Start
			%tmp_28 = arith.extui %l_j_d2_1 : i8 to i22
			%tmp_29 = arith.shrsi %l_y__j__75_d2_0, %tmp_28 : i22
			// l_y__j__shifted__77_d2_1 aliased to tmp_29
			// Assignment Statement: End
			// Assignment Statement: Start
			%tmp_30 = arith.extui %l_j_d2_1 : i8 to i22
			%tmp_31 = arith.shrsi %l_x__j__72_d2_0, %tmp_30 : i22
			// l_x__j__shifted__74_d2_1 aliased to tmp_31
			// Assignment Statement: End
			// If Statement: Begin
			%tmp_32 = arith.extui %l_j_d2_1 : i8 to i16
			%tmp_33 = arith.shrui %l_rotation__angles__69_d1_0, %tmp_32 : i16
			%tmp_34 = arith.constant 1 : i1
			%tmp_35 = arith.trunci %tmp_33 : i16 to i1
			%tmp_36 = arith.andi %tmp_35, %tmp_34 : i1
			%tmp_37 = arith.constant 1 : i1
			%tmp_38 = arith.cmpi eq, %tmp_36, %tmp_37 : i1
			%l_x__j__plus__1__73_d2_1, %l_y__j__plus__1__76_d2_1 = scf.if %tmp_38 -> (i22, i22) {
				// Assignment Statement: Start
				%tmp_39 = arith.extsi %l_x__j__72_d2_0 : i22 to i23
				%tmp_40 = arith.extsi %tmp_29 : i22 to i23
				%tmp_41 = arith.addi %tmp_39, %tmp_40 : i23
				%tmp_42 = arith.trunci %tmp_41 : i23 to i22
				// l_x__j__plus__1__73_d3_0 aliased to tmp_42
				// Assignment Statement: End
				// Assignment Statement: Start
				%tmp_43 = arith.subi %l_y__j__75_d2_0, %tmp_31 : i22
				// l_y__j__plus__1__76_d3_0 aliased to tmp_43
				// Assignment Statement: End
				scf.yield %tmp_42, %tmp_43 : i22, i22
			} else {
				// Assignment Statement: Start
				%tmp_44 = arith.subi %l_x__j__72_d2_0, %tmp_29 : i22
				// l_x__j__plus__1__73_d3_0 aliased to tmp_44
				// Assignment Statement: End
				// Assignment Statement: Start
				%tmp_45 = arith.extsi %l_y__j__75_d2_0 : i22 to i23
				%tmp_46 = arith.extsi %tmp_31 : i22 to i23
				%tmp_47 = arith.addi %tmp_45, %tmp_46 : i23
				%tmp_48 = arith.trunci %tmp_47 : i23 to i22
				// l_y__j__plus__1__76_d3_0 aliased to tmp_48
				// Assignment Statement: End
				scf.yield %tmp_44, %tmp_48 : i22, i22
			}
			// If Statement: End
			// Assignment Statement: Start
			// l_x__j__72_d2_1 aliased to l_x__j__plus__1__73_d2_1
			// Assignment Statement: End
			// Assignment Statement: Start
			// l_y__j__75_d2_1 aliased to l_y__j__plus__1__76_d2_1
			// Assignment Statement: End
			scf.yield %l_x__j__plus__1__73_d2_1, %l_x__j__plus__1__73_d2_1, %tmp_31, %l_y__j__plus__1__76_d2_1, %l_y__j__plus__1__76_d2_1, %tmp_29 : i22, i22, i22, i22, i22, i22
		}
		// Foreach Statement: End
		// Assignment Statement: Start
		// Evaluate global variable k_CORDIC_constant.
		%tmp_50 = arith.constant 318375 : i19
		%tmp_51 = arith.extui %tmp_50 : i19 to i22
		// Evaluate global variable k_CORDIC_constant done: assigned to tmp_51 above in this context.
		// Evaluate global variable fixedPointMultiply.
		%tmp_49 = func.call @g_qrd_fixedPointMultiply(%tmp_51,%l_y__j__75_d1_2) : (i22,i22) -> i22
		// l_x__out__71_d1_1 aliased to tmp_49
		// Assignment Statement: End
		// Assignment Statement: Start
		// Evaluate global variable k_CORDIC_constant.
		%tmp_53 = arith.constant 318375 : i19
		%tmp_54 = arith.extui %tmp_53 : i19 to i22
		// Evaluate global variable k_CORDIC_constant done: assigned to tmp_54 above in this context.
		// Evaluate global variable fixedPointMultiply.
		%tmp_52 = func.call @g_qrd_fixedPointMultiply(%tmp_54,%l_x__j__72_d1_2) : (i22,i22) -> i22
		cal.set(%l_r__63: !cal.state_ref<i22>, %tmp_52: i22)
		// Assignment Statement: End
		// Assignment Statement: Start
		%tmp_55 = cal.get(%l_count__64: !cal.state_ref<i32>) : i32
		%tmp_56 = arith.constant 1 : i1
		%tmp_57 = arith.extui %tmp_56 : i1 to i32
		%tmp_58 = arith.addi %tmp_55, %tmp_57 : i32
		cal.set(%l_count__64: !cal.state_ref<i32>, %tmp_58: i32)
		// Assignment Statement: End
		// Assignment Statement: Start
		%tmp_59 = arith.constant 0 : i1
		%tmp_60 = arith.extui %tmp_59 : i1 to i32
		cal.set(%l_$state: !cal.state_ref<i32>, %tmp_60: i32)
		// Assignment Statement: End
		// Output Expression: Start
		fifo.push(%x_out: !fifo.input_port<i22>, %tmp_49: i22)
		// Output Expression: End
		// Output Expression: Start
		fifo.push(%cordic_angles_out: !fifo.input_port<i16>, %l_rotation__angles__69_d1_0: i16)
		// Output Expression: End
	}
	// Generation action: final
	cal.action "final" priority=0 {
		// Guard: Start
		cal.predicate {
			%tmp_61 = cal.get(%l_count__64: !cal.state_ref<i32>) : i32
			// Evaluate global variable $eval1.
			%tmp_62 = arith.constant 4 : i3
			%tmp_63 = arith.extui %tmp_62 : i3 to i32
			// Evaluate global variable $eval1 done: assigned to tmp_63 above in this context.
			%tmp_64 = arith.cmpi eq, %tmp_61, %tmp_63 : i32
			cal.predicate_result %tmp_64 : i1
		}
		// Guard: End
		// Assignment Statement: Start
		%tmp_65 = arith.constant 0 : i1
		%tmp_66 = arith.extui %tmp_65 : i1 to i32
		cal.set(%l_count__64: !cal.state_ref<i32>, %tmp_66: i32)
		// Assignment Statement: End
		// Assignment Statement: Start
		%tmp_67 = arith.constant 0 : i1
		%tmp_68 = arith.extui %tmp_67 : i1 to i32
		cal.set(%l_$state: !cal.state_ref<i32>, %tmp_68: i32)
		// Assignment Statement: End
		// Output Expression: Start
		%tmp_69 = cal.get(%l_r__63: !cal.state_ref<i22>) : i22
		fifo.push(%r_out: !fifo.input_port<i22>, %tmp_69: i22)
		// Output Expression: End
	}
}

//-- Definition of actor class: Cap
cal.actor @caps_q_1 ()
	ports_in(%In: !fifo.output_port<i22>)
{
	// -- Actor body
	%l_$state = cal.create_state_var<i32> : !cal.state_ref<i32>
	%tmp_0 = arith.constant 0 : i1
	%tmp_1 = arith.extui %tmp_0 : i1 to i32
	cal.set(%l_$state: !cal.state_ref<i32>, %tmp_1: i32)
	// Generation action: receive
	cal.action "receive" priority=0 {
		// Input Pattern: Start
		%l_t__107_d1_0 = fifo.pop(%In: !fifo.output_port<i22>) : i22
		// Input Pattern: End
		// Assignment Statement: Start
		%tmp_2 = arith.constant 0 : i1
		%tmp_3 = arith.extui %tmp_2 : i1 to i32
		cal.set(%l_$state: !cal.state_ref<i32>, %tmp_3: i32)
		// Assignment Statement: End
	}
}

//-- Definition of actor class: InnerCell
cal.actor @innerCells_q_5 ()
	ports_in(%x_in: !fifo.output_port<i22>,%cordic_angles_in: !fifo.output_port<i16>)
	ports_out(%x_out: !fifo.input_port<i22>,%r_out: !fifo.input_port<i22>,%cordic_angles_out: !fifo.input_port<i16>)
{
	// -- Actor body
	%l_r__63 = cal.create_state_var<i22> : !cal.state_ref<i22>
	%tmp_0 = arith.constant 0 : i1
	%tmp_1 = arith.extui %tmp_0 : i1 to i22
	cal.set(%l_r__63: !cal.state_ref<i22>, %tmp_1: i22)
	%l_count__64 = cal.create_state_var<i32> : !cal.state_ref<i32>
	%tmp_2 = arith.constant 0 : i1
	%tmp_3 = arith.extui %tmp_2 : i1 to i32
	cal.set(%l_count__64: !cal.state_ref<i32>, %tmp_3: i32)
	%l_$state = cal.create_state_var<i32> : !cal.state_ref<i32>
	%tmp_4 = arith.constant 0 : i1
	%tmp_5 = arith.extui %tmp_4 : i1 to i32
	cal.set(%l_$state: !cal.state_ref<i32>, %tmp_5: i32)
	// Generation action: normal
	cal.action "normal" priority=0 {
		// Guard: Start
		cal.predicate {
			%tmp_6 = cal.get(%l_count__64: !cal.state_ref<i32>) : i32
			// Evaluate global variable $eval1.
			%tmp_7 = arith.constant 4 : i3
			%tmp_8 = arith.extui %tmp_7 : i3 to i32
			// Evaluate global variable $eval1 done: assigned to tmp_8 above in this context.
			%tmp_9 = arith.cmpi ult, %tmp_6, %tmp_8 : i32
			cal.predicate_result %tmp_9 : i1
		}
		// Guard: End
		// Input Pattern: Start
		%l_x__in__66_d1_0 = fifo.pop(%x_in: !fifo.output_port<i22>) : i22
		// Input Pattern: End
		// Input Pattern: Start
		%l_rotation__angles__69_d1_0 = fifo.pop(%cordic_angles_in: !fifo.output_port<i16>) : i16
		// Input Pattern: End
		// Action Local Variable Decl: Start
		%l_x__out__71_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_x__j__72_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_x__j__plus__1__73_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_x__j__shifted__74_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_y__j__75_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_y__j__plus__1__76_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_y__j__shifted__77_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// If Statement: Begin
		%tmp_10 = cal.get(%l_count__64: !cal.state_ref<i32>) : i32
		%tmp_11 = arith.constant 0 : i1
		%tmp_12 = arith.extui %tmp_11 : i1 to i32
		%tmp_13 = arith.cmpi eq, %tmp_10, %tmp_12 : i32
		scf.if %tmp_13 {
			// Assignment Statement: Start
			%tmp_14 = arith.constant 0 : i1
			%tmp_15 = arith.extui %tmp_14 : i1 to i22
			cal.set(%l_r__63: !cal.state_ref<i22>, %tmp_15: i22)
			// Assignment Statement: End
		} else {
		}
		// If Statement: End
		// Assignment Statement: Start
		// l_x__j__72_d1_1 aliased to l_x__in__66_d1_0
		// Assignment Statement: End
		// Assignment Statement: Start
		%tmp_16 = cal.get(%l_r__63: !cal.state_ref<i22>) : i22
		// l_y__j__75_d1_1 aliased to tmp_16
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
		%l_x__j__72_d1_2, %l_x__j__plus__1__73_d1_1, %l_x__j__shifted__74_d1_1, %l_y__j__75_d1_2, %l_y__j__plus__1__76_d1_1, %l_y__j__shifted__77_d1_1 = scf.for %l_j_d1_0 = %tmp_19_lb to %tmp_27_ub_plus_1 step %tmp_26_step
				iter_args(%l_x__j__72_d2_0 = %l_x__in__66_d1_0, %l_x__j__plus__1__73_d2_0 = %l_x__j__plus__1__73_d1_0, %l_x__j__shifted__74_d2_0 = %l_x__j__shifted__74_d1_0, %l_y__j__75_d2_0 = %tmp_16, %l_y__j__plus__1__76_d2_0 = %l_y__j__plus__1__76_d1_0, %l_y__j__shifted__77_d2_0 = %l_y__j__shifted__77_d1_0) -> (i22, i22, i22, i22, i22, i22) {
			%l_j_d2_0 = arith.index_cast %l_j_d1_0 : index to i32
			%l_j_d2_1 = arith.trunci %l_j_d2_0 : i32 to i8
			// Assignment Statement: Start
			%tmp_28 = arith.extui %l_j_d2_1 : i8 to i22
			%tmp_29 = arith.shrsi %l_y__j__75_d2_0, %tmp_28 : i22
			// l_y__j__shifted__77_d2_1 aliased to tmp_29
			// Assignment Statement: End
			// Assignment Statement: Start
			%tmp_30 = arith.extui %l_j_d2_1 : i8 to i22
			%tmp_31 = arith.shrsi %l_x__j__72_d2_0, %tmp_30 : i22
			// l_x__j__shifted__74_d2_1 aliased to tmp_31
			// Assignment Statement: End
			// If Statement: Begin
			%tmp_32 = arith.extui %l_j_d2_1 : i8 to i16
			%tmp_33 = arith.shrui %l_rotation__angles__69_d1_0, %tmp_32 : i16
			%tmp_34 = arith.constant 1 : i1
			%tmp_35 = arith.trunci %tmp_33 : i16 to i1
			%tmp_36 = arith.andi %tmp_35, %tmp_34 : i1
			%tmp_37 = arith.constant 1 : i1
			%tmp_38 = arith.cmpi eq, %tmp_36, %tmp_37 : i1
			%l_x__j__plus__1__73_d2_1, %l_y__j__plus__1__76_d2_1 = scf.if %tmp_38 -> (i22, i22) {
				// Assignment Statement: Start
				%tmp_39 = arith.extsi %l_x__j__72_d2_0 : i22 to i23
				%tmp_40 = arith.extsi %tmp_29 : i22 to i23
				%tmp_41 = arith.addi %tmp_39, %tmp_40 : i23
				%tmp_42 = arith.trunci %tmp_41 : i23 to i22
				// l_x__j__plus__1__73_d3_0 aliased to tmp_42
				// Assignment Statement: End
				// Assignment Statement: Start
				%tmp_43 = arith.subi %l_y__j__75_d2_0, %tmp_31 : i22
				// l_y__j__plus__1__76_d3_0 aliased to tmp_43
				// Assignment Statement: End
				scf.yield %tmp_42, %tmp_43 : i22, i22
			} else {
				// Assignment Statement: Start
				%tmp_44 = arith.subi %l_x__j__72_d2_0, %tmp_29 : i22
				// l_x__j__plus__1__73_d3_0 aliased to tmp_44
				// Assignment Statement: End
				// Assignment Statement: Start
				%tmp_45 = arith.extsi %l_y__j__75_d2_0 : i22 to i23
				%tmp_46 = arith.extsi %tmp_31 : i22 to i23
				%tmp_47 = arith.addi %tmp_45, %tmp_46 : i23
				%tmp_48 = arith.trunci %tmp_47 : i23 to i22
				// l_y__j__plus__1__76_d3_0 aliased to tmp_48
				// Assignment Statement: End
				scf.yield %tmp_44, %tmp_48 : i22, i22
			}
			// If Statement: End
			// Assignment Statement: Start
			// l_x__j__72_d2_1 aliased to l_x__j__plus__1__73_d2_1
			// Assignment Statement: End
			// Assignment Statement: Start
			// l_y__j__75_d2_1 aliased to l_y__j__plus__1__76_d2_1
			// Assignment Statement: End
			scf.yield %l_x__j__plus__1__73_d2_1, %l_x__j__plus__1__73_d2_1, %tmp_31, %l_y__j__plus__1__76_d2_1, %l_y__j__plus__1__76_d2_1, %tmp_29 : i22, i22, i22, i22, i22, i22
		}
		// Foreach Statement: End
		// Assignment Statement: Start
		// Evaluate global variable k_CORDIC_constant.
		%tmp_50 = arith.constant 318375 : i19
		%tmp_51 = arith.extui %tmp_50 : i19 to i22
		// Evaluate global variable k_CORDIC_constant done: assigned to tmp_51 above in this context.
		// Evaluate global variable fixedPointMultiply.
		%tmp_49 = func.call @g_qrd_fixedPointMultiply(%tmp_51,%l_y__j__75_d1_2) : (i22,i22) -> i22
		// l_x__out__71_d1_1 aliased to tmp_49
		// Assignment Statement: End
		// Assignment Statement: Start
		// Evaluate global variable k_CORDIC_constant.
		%tmp_53 = arith.constant 318375 : i19
		%tmp_54 = arith.extui %tmp_53 : i19 to i22
		// Evaluate global variable k_CORDIC_constant done: assigned to tmp_54 above in this context.
		// Evaluate global variable fixedPointMultiply.
		%tmp_52 = func.call @g_qrd_fixedPointMultiply(%tmp_54,%l_x__j__72_d1_2) : (i22,i22) -> i22
		cal.set(%l_r__63: !cal.state_ref<i22>, %tmp_52: i22)
		// Assignment Statement: End
		// Assignment Statement: Start
		%tmp_55 = cal.get(%l_count__64: !cal.state_ref<i32>) : i32
		%tmp_56 = arith.constant 1 : i1
		%tmp_57 = arith.extui %tmp_56 : i1 to i32
		%tmp_58 = arith.addi %tmp_55, %tmp_57 : i32
		cal.set(%l_count__64: !cal.state_ref<i32>, %tmp_58: i32)
		// Assignment Statement: End
		// Assignment Statement: Start
		%tmp_59 = arith.constant 0 : i1
		%tmp_60 = arith.extui %tmp_59 : i1 to i32
		cal.set(%l_$state: !cal.state_ref<i32>, %tmp_60: i32)
		// Assignment Statement: End
		// Output Expression: Start
		fifo.push(%x_out: !fifo.input_port<i22>, %tmp_49: i22)
		// Output Expression: End
		// Output Expression: Start
		fifo.push(%cordic_angles_out: !fifo.input_port<i16>, %l_rotation__angles__69_d1_0: i16)
		// Output Expression: End
	}
	// Generation action: final
	cal.action "final" priority=0 {
		// Guard: Start
		cal.predicate {
			%tmp_61 = cal.get(%l_count__64: !cal.state_ref<i32>) : i32
			// Evaluate global variable $eval1.
			%tmp_62 = arith.constant 4 : i3
			%tmp_63 = arith.extui %tmp_62 : i3 to i32
			// Evaluate global variable $eval1 done: assigned to tmp_63 above in this context.
			%tmp_64 = arith.cmpi eq, %tmp_61, %tmp_63 : i32
			cal.predicate_result %tmp_64 : i1
		}
		// Guard: End
		// Assignment Statement: Start
		%tmp_65 = arith.constant 0 : i1
		%tmp_66 = arith.extui %tmp_65 : i1 to i32
		cal.set(%l_count__64: !cal.state_ref<i32>, %tmp_66: i32)
		// Assignment Statement: End
		// Assignment Statement: Start
		%tmp_67 = arith.constant 0 : i1
		%tmp_68 = arith.extui %tmp_67 : i1 to i32
		cal.set(%l_$state: !cal.state_ref<i32>, %tmp_68: i32)
		// Assignment Statement: End
		// Output Expression: Start
		%tmp_69 = cal.get(%l_r__63: !cal.state_ref<i22>) : i22
		fifo.push(%r_out: !fifo.input_port<i22>, %tmp_69: i22)
		// Output Expression: End
	}
}

//-- Definition of actor class: Cap
cal.actor @caps_q_0 ()
	ports_in(%In: !fifo.output_port<i22>)
{
	// -- Actor body
	%l_$state = cal.create_state_var<i32> : !cal.state_ref<i32>
	%tmp_0 = arith.constant 0 : i1
	%tmp_1 = arith.extui %tmp_0 : i1 to i32
	cal.set(%l_$state: !cal.state_ref<i32>, %tmp_1: i32)
	// Generation action: receive
	cal.action "receive" priority=0 {
		// Input Pattern: Start
		%l_t__107_d1_0 = fifo.pop(%In: !fifo.output_port<i22>) : i22
		// Input Pattern: End
		// Assignment Statement: Start
		%tmp_2 = arith.constant 0 : i1
		%tmp_3 = arith.extui %tmp_2 : i1 to i32
		cal.set(%l_$state: !cal.state_ref<i32>, %tmp_3: i32)
		// Assignment Statement: End
	}
}

//-- Definition of actor class: InnerCell
cal.actor @innerCells_q_2 ()
	ports_in(%x_in: !fifo.output_port<i22>,%cordic_angles_in: !fifo.output_port<i16>)
	ports_out(%x_out: !fifo.input_port<i22>,%r_out: !fifo.input_port<i22>,%cordic_angles_out: !fifo.input_port<i16>)
{
	// -- Actor body
	%l_r__63 = cal.create_state_var<i22> : !cal.state_ref<i22>
	%tmp_0 = arith.constant 0 : i1
	%tmp_1 = arith.extui %tmp_0 : i1 to i22
	cal.set(%l_r__63: !cal.state_ref<i22>, %tmp_1: i22)
	%l_count__64 = cal.create_state_var<i32> : !cal.state_ref<i32>
	%tmp_2 = arith.constant 0 : i1
	%tmp_3 = arith.extui %tmp_2 : i1 to i32
	cal.set(%l_count__64: !cal.state_ref<i32>, %tmp_3: i32)
	%l_$state = cal.create_state_var<i32> : !cal.state_ref<i32>
	%tmp_4 = arith.constant 0 : i1
	%tmp_5 = arith.extui %tmp_4 : i1 to i32
	cal.set(%l_$state: !cal.state_ref<i32>, %tmp_5: i32)
	// Generation action: normal
	cal.action "normal" priority=0 {
		// Guard: Start
		cal.predicate {
			%tmp_6 = cal.get(%l_count__64: !cal.state_ref<i32>) : i32
			// Evaluate global variable $eval1.
			%tmp_7 = arith.constant 4 : i3
			%tmp_8 = arith.extui %tmp_7 : i3 to i32
			// Evaluate global variable $eval1 done: assigned to tmp_8 above in this context.
			%tmp_9 = arith.cmpi ult, %tmp_6, %tmp_8 : i32
			cal.predicate_result %tmp_9 : i1
		}
		// Guard: End
		// Input Pattern: Start
		%l_x__in__66_d1_0 = fifo.pop(%x_in: !fifo.output_port<i22>) : i22
		// Input Pattern: End
		// Input Pattern: Start
		%l_rotation__angles__69_d1_0 = fifo.pop(%cordic_angles_in: !fifo.output_port<i16>) : i16
		// Input Pattern: End
		// Action Local Variable Decl: Start
		%l_x__out__71_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_x__j__72_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_x__j__plus__1__73_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_x__j__shifted__74_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_y__j__75_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_y__j__plus__1__76_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_y__j__shifted__77_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// If Statement: Begin
		%tmp_10 = cal.get(%l_count__64: !cal.state_ref<i32>) : i32
		%tmp_11 = arith.constant 0 : i1
		%tmp_12 = arith.extui %tmp_11 : i1 to i32
		%tmp_13 = arith.cmpi eq, %tmp_10, %tmp_12 : i32
		scf.if %tmp_13 {
			// Assignment Statement: Start
			%tmp_14 = arith.constant 0 : i1
			%tmp_15 = arith.extui %tmp_14 : i1 to i22
			cal.set(%l_r__63: !cal.state_ref<i22>, %tmp_15: i22)
			// Assignment Statement: End
		} else {
		}
		// If Statement: End
		// Assignment Statement: Start
		// l_x__j__72_d1_1 aliased to l_x__in__66_d1_0
		// Assignment Statement: End
		// Assignment Statement: Start
		%tmp_16 = cal.get(%l_r__63: !cal.state_ref<i22>) : i22
		// l_y__j__75_d1_1 aliased to tmp_16
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
		%l_x__j__72_d1_2, %l_x__j__plus__1__73_d1_1, %l_x__j__shifted__74_d1_1, %l_y__j__75_d1_2, %l_y__j__plus__1__76_d1_1, %l_y__j__shifted__77_d1_1 = scf.for %l_j_d1_0 = %tmp_19_lb to %tmp_27_ub_plus_1 step %tmp_26_step
				iter_args(%l_x__j__72_d2_0 = %l_x__in__66_d1_0, %l_x__j__plus__1__73_d2_0 = %l_x__j__plus__1__73_d1_0, %l_x__j__shifted__74_d2_0 = %l_x__j__shifted__74_d1_0, %l_y__j__75_d2_0 = %tmp_16, %l_y__j__plus__1__76_d2_0 = %l_y__j__plus__1__76_d1_0, %l_y__j__shifted__77_d2_0 = %l_y__j__shifted__77_d1_0) -> (i22, i22, i22, i22, i22, i22) {
			%l_j_d2_0 = arith.index_cast %l_j_d1_0 : index to i32
			%l_j_d2_1 = arith.trunci %l_j_d2_0 : i32 to i8
			// Assignment Statement: Start
			%tmp_28 = arith.extui %l_j_d2_1 : i8 to i22
			%tmp_29 = arith.shrsi %l_y__j__75_d2_0, %tmp_28 : i22
			// l_y__j__shifted__77_d2_1 aliased to tmp_29
			// Assignment Statement: End
			// Assignment Statement: Start
			%tmp_30 = arith.extui %l_j_d2_1 : i8 to i22
			%tmp_31 = arith.shrsi %l_x__j__72_d2_0, %tmp_30 : i22
			// l_x__j__shifted__74_d2_1 aliased to tmp_31
			// Assignment Statement: End
			// If Statement: Begin
			%tmp_32 = arith.extui %l_j_d2_1 : i8 to i16
			%tmp_33 = arith.shrui %l_rotation__angles__69_d1_0, %tmp_32 : i16
			%tmp_34 = arith.constant 1 : i1
			%tmp_35 = arith.trunci %tmp_33 : i16 to i1
			%tmp_36 = arith.andi %tmp_35, %tmp_34 : i1
			%tmp_37 = arith.constant 1 : i1
			%tmp_38 = arith.cmpi eq, %tmp_36, %tmp_37 : i1
			%l_x__j__plus__1__73_d2_1, %l_y__j__plus__1__76_d2_1 = scf.if %tmp_38 -> (i22, i22) {
				// Assignment Statement: Start
				%tmp_39 = arith.extsi %l_x__j__72_d2_0 : i22 to i23
				%tmp_40 = arith.extsi %tmp_29 : i22 to i23
				%tmp_41 = arith.addi %tmp_39, %tmp_40 : i23
				%tmp_42 = arith.trunci %tmp_41 : i23 to i22
				// l_x__j__plus__1__73_d3_0 aliased to tmp_42
				// Assignment Statement: End
				// Assignment Statement: Start
				%tmp_43 = arith.subi %l_y__j__75_d2_0, %tmp_31 : i22
				// l_y__j__plus__1__76_d3_0 aliased to tmp_43
				// Assignment Statement: End
				scf.yield %tmp_42, %tmp_43 : i22, i22
			} else {
				// Assignment Statement: Start
				%tmp_44 = arith.subi %l_x__j__72_d2_0, %tmp_29 : i22
				// l_x__j__plus__1__73_d3_0 aliased to tmp_44
				// Assignment Statement: End
				// Assignment Statement: Start
				%tmp_45 = arith.extsi %l_y__j__75_d2_0 : i22 to i23
				%tmp_46 = arith.extsi %tmp_31 : i22 to i23
				%tmp_47 = arith.addi %tmp_45, %tmp_46 : i23
				%tmp_48 = arith.trunci %tmp_47 : i23 to i22
				// l_y__j__plus__1__76_d3_0 aliased to tmp_48
				// Assignment Statement: End
				scf.yield %tmp_44, %tmp_48 : i22, i22
			}
			// If Statement: End
			// Assignment Statement: Start
			// l_x__j__72_d2_1 aliased to l_x__j__plus__1__73_d2_1
			// Assignment Statement: End
			// Assignment Statement: Start
			// l_y__j__75_d2_1 aliased to l_y__j__plus__1__76_d2_1
			// Assignment Statement: End
			scf.yield %l_x__j__plus__1__73_d2_1, %l_x__j__plus__1__73_d2_1, %tmp_31, %l_y__j__plus__1__76_d2_1, %l_y__j__plus__1__76_d2_1, %tmp_29 : i22, i22, i22, i22, i22, i22
		}
		// Foreach Statement: End
		// Assignment Statement: Start
		// Evaluate global variable k_CORDIC_constant.
		%tmp_50 = arith.constant 318375 : i19
		%tmp_51 = arith.extui %tmp_50 : i19 to i22
		// Evaluate global variable k_CORDIC_constant done: assigned to tmp_51 above in this context.
		// Evaluate global variable fixedPointMultiply.
		%tmp_49 = func.call @g_qrd_fixedPointMultiply(%tmp_51,%l_y__j__75_d1_2) : (i22,i22) -> i22
		// l_x__out__71_d1_1 aliased to tmp_49
		// Assignment Statement: End
		// Assignment Statement: Start
		// Evaluate global variable k_CORDIC_constant.
		%tmp_53 = arith.constant 318375 : i19
		%tmp_54 = arith.extui %tmp_53 : i19 to i22
		// Evaluate global variable k_CORDIC_constant done: assigned to tmp_54 above in this context.
		// Evaluate global variable fixedPointMultiply.
		%tmp_52 = func.call @g_qrd_fixedPointMultiply(%tmp_54,%l_x__j__72_d1_2) : (i22,i22) -> i22
		cal.set(%l_r__63: !cal.state_ref<i22>, %tmp_52: i22)
		// Assignment Statement: End
		// Assignment Statement: Start
		%tmp_55 = cal.get(%l_count__64: !cal.state_ref<i32>) : i32
		%tmp_56 = arith.constant 1 : i1
		%tmp_57 = arith.extui %tmp_56 : i1 to i32
		%tmp_58 = arith.addi %tmp_55, %tmp_57 : i32
		cal.set(%l_count__64: !cal.state_ref<i32>, %tmp_58: i32)
		// Assignment Statement: End
		// Assignment Statement: Start
		%tmp_59 = arith.constant 0 : i1
		%tmp_60 = arith.extui %tmp_59 : i1 to i32
		cal.set(%l_$state: !cal.state_ref<i32>, %tmp_60: i32)
		// Assignment Statement: End
		// Output Expression: Start
		fifo.push(%x_out: !fifo.input_port<i22>, %tmp_49: i22)
		// Output Expression: End
		// Output Expression: Start
		fifo.push(%cordic_angles_out: !fifo.input_port<i16>, %l_rotation__angles__69_d1_0: i16)
		// Output Expression: End
	}
	// Generation action: final
	cal.action "final" priority=0 {
		// Guard: Start
		cal.predicate {
			%tmp_61 = cal.get(%l_count__64: !cal.state_ref<i32>) : i32
			// Evaluate global variable $eval1.
			%tmp_62 = arith.constant 4 : i3
			%tmp_63 = arith.extui %tmp_62 : i3 to i32
			// Evaluate global variable $eval1 done: assigned to tmp_63 above in this context.
			%tmp_64 = arith.cmpi eq, %tmp_61, %tmp_63 : i32
			cal.predicate_result %tmp_64 : i1
		}
		// Guard: End
		// Assignment Statement: Start
		%tmp_65 = arith.constant 0 : i1
		%tmp_66 = arith.extui %tmp_65 : i1 to i32
		cal.set(%l_count__64: !cal.state_ref<i32>, %tmp_66: i32)
		// Assignment Statement: End
		// Assignment Statement: Start
		%tmp_67 = arith.constant 0 : i1
		%tmp_68 = arith.extui %tmp_67 : i1 to i32
		cal.set(%l_$state: !cal.state_ref<i32>, %tmp_68: i32)
		// Assignment Statement: End
		// Output Expression: Start
		%tmp_69 = cal.get(%l_r__63: !cal.state_ref<i22>) : i22
		fifo.push(%r_out: !fifo.input_port<i22>, %tmp_69: i22)
		// Output Expression: End
	}
}

//-- Definition of actor class: Cap
cal.actor @caps_q_3 ()
	ports_in(%In: !fifo.output_port<i22>)
{
	// -- Actor body
	%l_$state = cal.create_state_var<i32> : !cal.state_ref<i32>
	%tmp_0 = arith.constant 0 : i1
	%tmp_1 = arith.extui %tmp_0 : i1 to i32
	cal.set(%l_$state: !cal.state_ref<i32>, %tmp_1: i32)
	// Generation action: receive
	cal.action "receive" priority=0 {
		// Input Pattern: Start
		%l_t__107_d1_0 = fifo.pop(%In: !fifo.output_port<i22>) : i22
		// Input Pattern: End
		// Assignment Statement: Start
		%tmp_2 = arith.constant 0 : i1
		%tmp_3 = arith.extui %tmp_2 : i1 to i32
		cal.set(%l_$state: !cal.state_ref<i32>, %tmp_3: i32)
		// Assignment Statement: End
	}
}

//-- Definition of actor class: InnerCell
cal.actor @innerCells_q_3 ()
	ports_in(%x_in: !fifo.output_port<i22>,%cordic_angles_in: !fifo.output_port<i16>)
	ports_out(%x_out: !fifo.input_port<i22>,%r_out: !fifo.input_port<i22>,%cordic_angles_out: !fifo.input_port<i16>)
{
	// -- Actor body
	%l_r__63 = cal.create_state_var<i22> : !cal.state_ref<i22>
	%tmp_0 = arith.constant 0 : i1
	%tmp_1 = arith.extui %tmp_0 : i1 to i22
	cal.set(%l_r__63: !cal.state_ref<i22>, %tmp_1: i22)
	%l_count__64 = cal.create_state_var<i32> : !cal.state_ref<i32>
	%tmp_2 = arith.constant 0 : i1
	%tmp_3 = arith.extui %tmp_2 : i1 to i32
	cal.set(%l_count__64: !cal.state_ref<i32>, %tmp_3: i32)
	%l_$state = cal.create_state_var<i32> : !cal.state_ref<i32>
	%tmp_4 = arith.constant 0 : i1
	%tmp_5 = arith.extui %tmp_4 : i1 to i32
	cal.set(%l_$state: !cal.state_ref<i32>, %tmp_5: i32)
	// Generation action: normal
	cal.action "normal" priority=0 {
		// Guard: Start
		cal.predicate {
			%tmp_6 = cal.get(%l_count__64: !cal.state_ref<i32>) : i32
			// Evaluate global variable $eval1.
			%tmp_7 = arith.constant 4 : i3
			%tmp_8 = arith.extui %tmp_7 : i3 to i32
			// Evaluate global variable $eval1 done: assigned to tmp_8 above in this context.
			%tmp_9 = arith.cmpi ult, %tmp_6, %tmp_8 : i32
			cal.predicate_result %tmp_9 : i1
		}
		// Guard: End
		// Input Pattern: Start
		%l_x__in__66_d1_0 = fifo.pop(%x_in: !fifo.output_port<i22>) : i22
		// Input Pattern: End
		// Input Pattern: Start
		%l_rotation__angles__69_d1_0 = fifo.pop(%cordic_angles_in: !fifo.output_port<i16>) : i16
		// Input Pattern: End
		// Action Local Variable Decl: Start
		%l_x__out__71_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_x__j__72_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_x__j__plus__1__73_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_x__j__shifted__74_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_y__j__75_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_y__j__plus__1__76_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// Action Local Variable Decl: Start
		%l_y__j__shifted__77_d1_0 = arith.constant 0 : i22
		// Action Local Variable Decl: End
		// If Statement: Begin
		%tmp_10 = cal.get(%l_count__64: !cal.state_ref<i32>) : i32
		%tmp_11 = arith.constant 0 : i1
		%tmp_12 = arith.extui %tmp_11 : i1 to i32
		%tmp_13 = arith.cmpi eq, %tmp_10, %tmp_12 : i32
		scf.if %tmp_13 {
			// Assignment Statement: Start
			%tmp_14 = arith.constant 0 : i1
			%tmp_15 = arith.extui %tmp_14 : i1 to i22
			cal.set(%l_r__63: !cal.state_ref<i22>, %tmp_15: i22)
			// Assignment Statement: End
		} else {
		}
		// If Statement: End
		// Assignment Statement: Start
		// l_x__j__72_d1_1 aliased to l_x__in__66_d1_0
		// Assignment Statement: End
		// Assignment Statement: Start
		%tmp_16 = cal.get(%l_r__63: !cal.state_ref<i22>) : i22
		// l_y__j__75_d1_1 aliased to tmp_16
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
		%l_x__j__72_d1_2, %l_x__j__plus__1__73_d1_1, %l_x__j__shifted__74_d1_1, %l_y__j__75_d1_2, %l_y__j__plus__1__76_d1_1, %l_y__j__shifted__77_d1_1 = scf.for %l_j_d1_0 = %tmp_19_lb to %tmp_27_ub_plus_1 step %tmp_26_step
				iter_args(%l_x__j__72_d2_0 = %l_x__in__66_d1_0, %l_x__j__plus__1__73_d2_0 = %l_x__j__plus__1__73_d1_0, %l_x__j__shifted__74_d2_0 = %l_x__j__shifted__74_d1_0, %l_y__j__75_d2_0 = %tmp_16, %l_y__j__plus__1__76_d2_0 = %l_y__j__plus__1__76_d1_0, %l_y__j__shifted__77_d2_0 = %l_y__j__shifted__77_d1_0) -> (i22, i22, i22, i22, i22, i22) {
			%l_j_d2_0 = arith.index_cast %l_j_d1_0 : index to i32
			%l_j_d2_1 = arith.trunci %l_j_d2_0 : i32 to i8
			// Assignment Statement: Start
			%tmp_28 = arith.extui %l_j_d2_1 : i8 to i22
			%tmp_29 = arith.shrsi %l_y__j__75_d2_0, %tmp_28 : i22
			// l_y__j__shifted__77_d2_1 aliased to tmp_29
			// Assignment Statement: End
			// Assignment Statement: Start
			%tmp_30 = arith.extui %l_j_d2_1 : i8 to i22
			%tmp_31 = arith.shrsi %l_x__j__72_d2_0, %tmp_30 : i22
			// l_x__j__shifted__74_d2_1 aliased to tmp_31
			// Assignment Statement: End
			// If Statement: Begin
			%tmp_32 = arith.extui %l_j_d2_1 : i8 to i16
			%tmp_33 = arith.shrui %l_rotation__angles__69_d1_0, %tmp_32 : i16
			%tmp_34 = arith.constant 1 : i1
			%tmp_35 = arith.trunci %tmp_33 : i16 to i1
			%tmp_36 = arith.andi %tmp_35, %tmp_34 : i1
			%tmp_37 = arith.constant 1 : i1
			%tmp_38 = arith.cmpi eq, %tmp_36, %tmp_37 : i1
			%l_x__j__plus__1__73_d2_1, %l_y__j__plus__1__76_d2_1 = scf.if %tmp_38 -> (i22, i22) {
				// Assignment Statement: Start
				%tmp_39 = arith.extsi %l_x__j__72_d2_0 : i22 to i23
				%tmp_40 = arith.extsi %tmp_29 : i22 to i23
				%tmp_41 = arith.addi %tmp_39, %tmp_40 : i23
				%tmp_42 = arith.trunci %tmp_41 : i23 to i22
				// l_x__j__plus__1__73_d3_0 aliased to tmp_42
				// Assignment Statement: End
				// Assignment Statement: Start
				%tmp_43 = arith.subi %l_y__j__75_d2_0, %tmp_31 : i22
				// l_y__j__plus__1__76_d3_0 aliased to tmp_43
				// Assignment Statement: End
				scf.yield %tmp_42, %tmp_43 : i22, i22
			} else {
				// Assignment Statement: Start
				%tmp_44 = arith.subi %l_x__j__72_d2_0, %tmp_29 : i22
				// l_x__j__plus__1__73_d3_0 aliased to tmp_44
				// Assignment Statement: End
				// Assignment Statement: Start
				%tmp_45 = arith.extsi %l_y__j__75_d2_0 : i22 to i23
				%tmp_46 = arith.extsi %tmp_31 : i22 to i23
				%tmp_47 = arith.addi %tmp_45, %tmp_46 : i23
				%tmp_48 = arith.trunci %tmp_47 : i23 to i22
				// l_y__j__plus__1__76_d3_0 aliased to tmp_48
				// Assignment Statement: End
				scf.yield %tmp_44, %tmp_48 : i22, i22
			}
			// If Statement: End
			// Assignment Statement: Start
			// l_x__j__72_d2_1 aliased to l_x__j__plus__1__73_d2_1
			// Assignment Statement: End
			// Assignment Statement: Start
			// l_y__j__75_d2_1 aliased to l_y__j__plus__1__76_d2_1
			// Assignment Statement: End
			scf.yield %l_x__j__plus__1__73_d2_1, %l_x__j__plus__1__73_d2_1, %tmp_31, %l_y__j__plus__1__76_d2_1, %l_y__j__plus__1__76_d2_1, %tmp_29 : i22, i22, i22, i22, i22, i22
		}
		// Foreach Statement: End
		// Assignment Statement: Start
		// Evaluate global variable k_CORDIC_constant.
		%tmp_50 = arith.constant 318375 : i19
		%tmp_51 = arith.extui %tmp_50 : i19 to i22
		// Evaluate global variable k_CORDIC_constant done: assigned to tmp_51 above in this context.
		// Evaluate global variable fixedPointMultiply.
		%tmp_49 = func.call @g_qrd_fixedPointMultiply(%tmp_51,%l_y__j__75_d1_2) : (i22,i22) -> i22
		// l_x__out__71_d1_1 aliased to tmp_49
		// Assignment Statement: End
		// Assignment Statement: Start
		// Evaluate global variable k_CORDIC_constant.
		%tmp_53 = arith.constant 318375 : i19
		%tmp_54 = arith.extui %tmp_53 : i19 to i22
		// Evaluate global variable k_CORDIC_constant done: assigned to tmp_54 above in this context.
		// Evaluate global variable fixedPointMultiply.
		%tmp_52 = func.call @g_qrd_fixedPointMultiply(%tmp_54,%l_x__j__72_d1_2) : (i22,i22) -> i22
		cal.set(%l_r__63: !cal.state_ref<i22>, %tmp_52: i22)
		// Assignment Statement: End
		// Assignment Statement: Start
		%tmp_55 = cal.get(%l_count__64: !cal.state_ref<i32>) : i32
		%tmp_56 = arith.constant 1 : i1
		%tmp_57 = arith.extui %tmp_56 : i1 to i32
		%tmp_58 = arith.addi %tmp_55, %tmp_57 : i32
		cal.set(%l_count__64: !cal.state_ref<i32>, %tmp_58: i32)
		// Assignment Statement: End
		// Assignment Statement: Start
		%tmp_59 = arith.constant 0 : i1
		%tmp_60 = arith.extui %tmp_59 : i1 to i32
		cal.set(%l_$state: !cal.state_ref<i32>, %tmp_60: i32)
		// Assignment Statement: End
		// Output Expression: Start
		fifo.push(%x_out: !fifo.input_port<i22>, %tmp_49: i22)
		// Output Expression: End
		// Output Expression: Start
		fifo.push(%cordic_angles_out: !fifo.input_port<i16>, %l_rotation__angles__69_d1_0: i16)
		// Output Expression: End
	}
	// Generation action: final
	cal.action "final" priority=0 {
		// Guard: Start
		cal.predicate {
			%tmp_61 = cal.get(%l_count__64: !cal.state_ref<i32>) : i32
			// Evaluate global variable $eval1.
			%tmp_62 = arith.constant 4 : i3
			%tmp_63 = arith.extui %tmp_62 : i3 to i32
			// Evaluate global variable $eval1 done: assigned to tmp_63 above in this context.
			%tmp_64 = arith.cmpi eq, %tmp_61, %tmp_63 : i32
			cal.predicate_result %tmp_64 : i1
		}
		// Guard: End
		// Assignment Statement: Start
		%tmp_65 = arith.constant 0 : i1
		%tmp_66 = arith.extui %tmp_65 : i1 to i32
		cal.set(%l_count__64: !cal.state_ref<i32>, %tmp_66: i32)
		// Assignment Statement: End
		// Assignment Statement: Start
		%tmp_67 = arith.constant 0 : i1
		%tmp_68 = arith.extui %tmp_67 : i1 to i32
		cal.set(%l_$state: !cal.state_ref<i32>, %tmp_68: i32)
		// Assignment Statement: End
		// Output Expression: Start
		%tmp_69 = cal.get(%l_r__63: !cal.state_ref<i22>) : i22
		fifo.push(%r_out: !fifo.input_port<i22>, %tmp_69: i22)
		// Output Expression: End
	}
}

//-- Definition of actor class: Cap
cal.actor @caps_q_2 ()
	ports_in(%In: !fifo.output_port<i22>)
{
	// -- Actor body
	%l_$state = cal.create_state_var<i32> : !cal.state_ref<i32>
	%tmp_0 = arith.constant 0 : i1
	%tmp_1 = arith.extui %tmp_0 : i1 to i32
	cal.set(%l_$state: !cal.state_ref<i32>, %tmp_1: i32)
	// Generation action: receive
	cal.action "receive" priority=0 {
		// Input Pattern: Start
		%l_t__107_d1_0 = fifo.pop(%In: !fifo.output_port<i22>) : i22
		// Input Pattern: End
		// Assignment Statement: Start
		%tmp_2 = arith.constant 0 : i1
		%tmp_3 = arith.extui %tmp_2 : i1 to i32
		cal.set(%l_$state: !cal.state_ref<i32>, %tmp_3: i32)
		// Assignment Statement: End
	}
}

//-- Definition of actor class: JoinerRowR
cal.actor @joinersPerRow_r_0 ()
	ports_in(%r_in_array_0_x: !fifo.output_port<i22>,%r_in_array_1_x: !fifo.output_port<i22>,%r_in_array_2_x: !fifo.output_port<i22>,%r_in_array_3_x: !fifo.output_port<i22>)
	ports_out(%r_out: !fifo.input_port<i22>)
{
	// -- Actor body
	%l_matrix__number__25 = cal.create_state_var<i32> : !cal.state_ref<i32>
	%tmp_0 = arith.constant 0 : i1
	%tmp_1 = arith.extui %tmp_0 : i1 to i32
	cal.set(%l_matrix__number__25: !cal.state_ref<i32>, %tmp_1: i32)
	%l_$state = cal.create_state_var<i32> : !cal.state_ref<i32>
	%tmp_2 = arith.constant 0 : i1
	%tmp_3 = arith.extui %tmp_2 : i1 to i32
	cal.set(%l_$state: !cal.state_ref<i32>, %tmp_3: i32)
	// Generation action: $untagged0
	cal.action "$untagged0" priority=0 {
		// Input Pattern: Start
		%l_____input0______27_d1_0 = fifo.pop(%r_in_array_0_x: !fifo.output_port<i22>) : i22
		// Input Pattern: End
		// Input Pattern: Start
		%l_____input1______30_d1_0 = fifo.pop(%r_in_array_1_x: !fifo.output_port<i22>) : i22
		// Input Pattern: End
		// Input Pattern: Start
		%l_____input2______33_d1_0 = fifo.pop(%r_in_array_2_x: !fifo.output_port<i22>) : i22
		// Input Pattern: End
		// Input Pattern: Start
		%l_____input3______36_d1_0 = fifo.pop(%r_in_array_3_x: !fifo.output_port<i22>) : i22
		// Input Pattern: End
		// Action Local Variable Decl: Start
		%tmp_4 = memref.alloc() : memref<4xi32>
		%tmp_5 = arith.constant 0: index
		%tmp_6 = arith.extsi %l_____input0______27_d1_0 : i22 to i32
		memref.store %tmp_6, %tmp_4[%tmp_5] : memref<4xi32>
		%tmp_7 = arith.constant 1: index
		%tmp_8 = arith.extsi %l_____input1______30_d1_0 : i22 to i32
		memref.store %tmp_8, %tmp_4[%tmp_7] : memref<4xi32>
		%tmp_9 = arith.constant 2: index
		%tmp_10 = arith.extsi %l_____input2______33_d1_0 : i22 to i32
		memref.store %tmp_10, %tmp_4[%tmp_9] : memref<4xi32>
		%tmp_11 = arith.constant 3: index
		%tmp_12 = arith.extsi %l_____input3______36_d1_0 : i22 to i32
		memref.store %tmp_12, %tmp_4[%tmp_11] : memref<4xi32>
		// l_input__38_d1_0 aliased to tmp_4
		// Action Local Variable Decl: End
		// If Statement: Begin
		%tmp_13 = cal.get(%l_matrix__number__25: !cal.state_ref<i32>) : i32
		// Evaluate global variable num_matrices.
		%tmp_14 = arith.constant 10000 : i14
		%tmp_15 = arith.extui %tmp_14 : i14 to i32
		// Evaluate global variable num_matrices done: assigned to tmp_15 above in this context.
		%tmp_16 = arith.constant 10 : i4
		%tmp_17 = arith.extui %tmp_16 : i4 to i32
		%tmp_18 = arith.subi %tmp_15, %tmp_17 : i32
		%tmp_19 = arith.cmpi eq, %tmp_13, %tmp_18 : i32
		scf.if %tmp_19 {
			// Call Statement: Start
			%tmp_20 = cal.get(%l_matrix__number__25: !cal.state_ref<i32>) : i32
			fifo.print("R%u: row 0: \00", %tmp_20) : (i32)
			// Call Statement: End
			// If Statement: Begin
			// Evaluate global variable $eval3.
			%tmp_21 = arith.constant 0 : i1
			%tmp_22 = arith.extui %tmp_21 : i1 to i32
			// Evaluate global variable $eval3 done: assigned to tmp_22 above in this context.
			%tmp_23 = arith.constant 0 : i1
			%tmp_24 = arith.extui %tmp_23 : i1 to i32
			%tmp_25 = arith.cmpi ne, %tmp_22, %tmp_24 : i32
			scf.if %tmp_25 {
				// Foreach Statement: Begin
				%tmp_26 = arith.constant 0 : i1
				%tmp_27 = arith.extui %tmp_26 : i1 to i32
				%tmp_28_lb = index.casts %tmp_27 : i32 to index
				// Evaluate global variable $eval1.
				%tmp_29 = arith.constant 4 : i3
				%tmp_30 = arith.extui %tmp_29 : i3 to i32
				// Evaluate global variable $eval1 done: assigned to tmp_30 above in this context.
				// Evaluate global variable $eval1.
				%tmp_31 = arith.constant 4 : i3
				%tmp_32 = arith.extui %tmp_31 : i3 to i32
				// Evaluate global variable $eval1 done: assigned to tmp_32 above in this context.
				%tmp_33 = arith.subi %tmp_30, %tmp_32 : i32
				%tmp_34 = arith.constant 1 : i1
				%tmp_35 = arith.extui %tmp_34 : i1 to i32
				%tmp_36 = arith.subi %tmp_33, %tmp_35 : i32
				%tmp_37_ub = index.casts %tmp_36 : i32 to index
				%tmp_38_step = index.constant 1
				%tmp_39_ub_plus_1 = arith.addi %tmp_37_ub, %tmp_38_step : index
				scf.for %l_index_d3_0 = %tmp_28_lb to %tmp_39_ub_plus_1 step %tmp_38_step
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
			%tmp_40 = arith.constant 0 : i1
			%tmp_41 = arith.extui %tmp_40 : i1 to i32
			%tmp_42_lb = index.casts %tmp_41 : i32 to index
			// Evaluate global variable $eval1.
			%tmp_43 = arith.constant 4 : i3
			%tmp_44 = arith.extui %tmp_43 : i3 to i32
			// Evaluate global variable $eval1 done: assigned to tmp_44 above in this context.
			%tmp_45 = arith.constant 1 : i1
			%tmp_46 = arith.extui %tmp_45 : i1 to i32
			%tmp_47 = arith.subi %tmp_44, %tmp_46 : i32
			%tmp_48_ub = index.casts %tmp_47 : i32 to index
			%tmp_49_step = index.constant 1
			%tmp_50_ub_plus_1 = arith.addi %tmp_48_ub, %tmp_49_step : index
			scf.for %l_index_d2_0 = %tmp_42_lb to %tmp_50_ub_plus_1 step %tmp_49_step
					iter_args() -> () {
				%l_index_d3_0 = arith.index_cast %l_index_d2_0 : index to i32
				%l_index_d3_1 = arith.trunci %l_index_d3_0 : i32 to i8
				// Call Statement: Start
				%tmp_51 = arith.extui %l_index_d3_1 : i8 to i32
				%tmp_52 = arith.index_cast %tmp_51: i32 to index
				%tmp_54 = memref.load %tmp_4[%tmp_52] : memref<4xi32>
				%tmp_53 = arith.trunci %tmp_54 : i32 to i22
				%tmp_55 = arith.extsi %tmp_53 : i22 to i32
				fifo.print("%i \00", %tmp_55) : (i32)
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
		%tmp_56 = cal.get(%l_matrix__number__25: !cal.state_ref<i32>) : i32
		%tmp_57 = arith.constant 1 : i1
		%tmp_58 = arith.extui %tmp_57 : i1 to i32
		%tmp_59 = arith.addi %tmp_56, %tmp_58 : i32
		cal.set(%l_matrix__number__25: !cal.state_ref<i32>, %tmp_59: i32)
		// Assignment Statement: End
		// Assignment Statement: Start
		%tmp_60 = arith.constant 0 : i1
		%tmp_61 = arith.extui %tmp_60 : i1 to i32
		cal.set(%l_$state: !cal.state_ref<i32>, %tmp_61: i32)
		// Assignment Statement: End
		// Output Expression: Start
		%tmp_62 = arith.constant 0 : index
		%tmp_63 = memref.load %tmp_4[%tmp_62] : memref<4xi32>
		%tmp_64 = arith.trunci %tmp_63 : i32 to i22
		fifo.push(%r_out: !fifo.input_port<i22>, %tmp_64: i22)
		%tmp_65 = arith.constant 1 : index
		%tmp_66 = memref.load %tmp_4[%tmp_65] : memref<4xi32>
		%tmp_67 = arith.trunci %tmp_66 : i32 to i22
		fifo.push(%r_out: !fifo.input_port<i22>, %tmp_67: i22)
		%tmp_68 = arith.constant 2 : index
		%tmp_69 = memref.load %tmp_4[%tmp_68] : memref<4xi32>
		%tmp_70 = arith.trunci %tmp_69 : i32 to i22
		fifo.push(%r_out: !fifo.input_port<i22>, %tmp_70: i22)
		%tmp_71 = arith.constant 3 : index
		%tmp_72 = memref.load %tmp_4[%tmp_71] : memref<4xi32>
		%tmp_73 = arith.trunci %tmp_72 : i32 to i22
		fifo.push(%r_out: !fifo.input_port<i22>, %tmp_73: i22)
		// Output Expression: End
	}
}

//-- Definition of actor class: JoinerRowR
cal.actor @joinersPerRow_r_2 ()
	ports_in(%r_in_array_0_x: !fifo.output_port<i22>,%r_in_array_1_x: !fifo.output_port<i22>)
	ports_out(%r_out: !fifo.input_port<i22>)
{
	// -- Actor body
	%l_matrix__number__50 = cal.create_state_var<i32> : !cal.state_ref<i32>
	%tmp_0 = arith.constant 0 : i1
	%tmp_1 = arith.extui %tmp_0 : i1 to i32
	cal.set(%l_matrix__number__50: !cal.state_ref<i32>, %tmp_1: i32)
	%l_$state = cal.create_state_var<i32> : !cal.state_ref<i32>
	%tmp_2 = arith.constant 0 : i1
	%tmp_3 = arith.extui %tmp_2 : i1 to i32
	cal.set(%l_$state: !cal.state_ref<i32>, %tmp_3: i32)
	// Generation action: $untagged0
	cal.action "$untagged0" priority=0 {
		// Input Pattern: Start
		%l_____input0______52_d1_0 = fifo.pop(%r_in_array_0_x: !fifo.output_port<i22>) : i22
		// Input Pattern: End
		// Input Pattern: Start
		%l_____input1______55_d1_0 = fifo.pop(%r_in_array_1_x: !fifo.output_port<i22>) : i22
		// Input Pattern: End
		// Action Local Variable Decl: Start
		%tmp_4 = memref.alloc() : memref<2xi32>
		%tmp_5 = arith.constant 0: index
		%tmp_6 = arith.extsi %l_____input0______52_d1_0 : i22 to i32
		memref.store %tmp_6, %tmp_4[%tmp_5] : memref<2xi32>
		%tmp_7 = arith.constant 1: index
		%tmp_8 = arith.extsi %l_____input1______55_d1_0 : i22 to i32
		memref.store %tmp_8, %tmp_4[%tmp_7] : memref<2xi32>
		// l_input__57_d1_0 aliased to tmp_4
		// Action Local Variable Decl: End
		// If Statement: Begin
		%tmp_9 = cal.get(%l_matrix__number__50: !cal.state_ref<i32>) : i32
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
			%tmp_16 = cal.get(%l_matrix__number__50: !cal.state_ref<i32>) : i32
			fifo.print("R%u: row 2: \00", %tmp_16) : (i32)
			// Call Statement: End
			// If Statement: Begin
			// Evaluate global variable $eval7.
			%tmp_17 = arith.constant 2 : i2
			%tmp_18 = arith.extui %tmp_17 : i2 to i32
			// Evaluate global variable $eval7 done: assigned to tmp_18 above in this context.
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
				// Evaluate global variable $eval7.
				%tmp_27 = arith.constant 2 : i2
				%tmp_28 = arith.extui %tmp_27 : i2 to i32
				// Evaluate global variable $eval7 done: assigned to tmp_28 above in this context.
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
			// Evaluate global variable $eval7.
			%tmp_39 = arith.constant 2 : i2
			%tmp_40 = arith.extui %tmp_39 : i2 to i32
			// Evaluate global variable $eval7 done: assigned to tmp_40 above in this context.
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
				%tmp_50 = memref.load %tmp_4[%tmp_48] : memref<2xi32>
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
		%tmp_52 = cal.get(%l_matrix__number__50: !cal.state_ref<i32>) : i32
		%tmp_53 = arith.constant 1 : i1
		%tmp_54 = arith.extui %tmp_53 : i1 to i32
		%tmp_55 = arith.addi %tmp_52, %tmp_54 : i32
		cal.set(%l_matrix__number__50: !cal.state_ref<i32>, %tmp_55: i32)
		// Assignment Statement: End
		// Assignment Statement: Start
		%tmp_56 = arith.constant 0 : i1
		%tmp_57 = arith.extui %tmp_56 : i1 to i32
		cal.set(%l_$state: !cal.state_ref<i32>, %tmp_57: i32)
		// Assignment Statement: End
		// Output Expression: Start
		%tmp_58 = arith.constant 0 : index
		%tmp_59 = memref.load %tmp_4[%tmp_58] : memref<2xi32>
		%tmp_60 = arith.trunci %tmp_59 : i32 to i22
		fifo.push(%r_out: !fifo.input_port<i22>, %tmp_60: i22)
		%tmp_61 = arith.constant 1 : index
		%tmp_62 = memref.load %tmp_4[%tmp_61] : memref<2xi32>
		%tmp_63 = arith.trunci %tmp_62 : i32 to i22
		fifo.push(%r_out: !fifo.input_port<i22>, %tmp_63: i22)
		// Output Expression: End
	}
}

//-- Definition of actor class: JoinerRowR
cal.actor @joinersPerRow_r_1 ()
	ports_in(%r_in_array_0_x: !fifo.output_port<i22>,%r_in_array_1_x: !fifo.output_port<i22>,%r_in_array_2_x: !fifo.output_port<i22>)
	ports_out(%r_out: !fifo.input_port<i22>)
{
	// -- Actor body
	%l_matrix__number__39 = cal.create_state_var<i32> : !cal.state_ref<i32>
	%tmp_0 = arith.constant 0 : i1
	%tmp_1 = arith.extui %tmp_0 : i1 to i32
	cal.set(%l_matrix__number__39: !cal.state_ref<i32>, %tmp_1: i32)
	%l_$state = cal.create_state_var<i32> : !cal.state_ref<i32>
	%tmp_2 = arith.constant 0 : i1
	%tmp_3 = arith.extui %tmp_2 : i1 to i32
	cal.set(%l_$state: !cal.state_ref<i32>, %tmp_3: i32)
	// Generation action: $untagged0
	cal.action "$untagged0" priority=0 {
		// Input Pattern: Start
		%l_____input0______41_d1_0 = fifo.pop(%r_in_array_0_x: !fifo.output_port<i22>) : i22
		// Input Pattern: End
		// Input Pattern: Start
		%l_____input1______44_d1_0 = fifo.pop(%r_in_array_1_x: !fifo.output_port<i22>) : i22
		// Input Pattern: End
		// Input Pattern: Start
		%l_____input2______47_d1_0 = fifo.pop(%r_in_array_2_x: !fifo.output_port<i22>) : i22
		// Input Pattern: End
		// Action Local Variable Decl: Start
		%tmp_4 = memref.alloc() : memref<3xi32>
		%tmp_5 = arith.constant 0: index
		%tmp_6 = arith.extsi %l_____input0______41_d1_0 : i22 to i32
		memref.store %tmp_6, %tmp_4[%tmp_5] : memref<3xi32>
		%tmp_7 = arith.constant 1: index
		%tmp_8 = arith.extsi %l_____input1______44_d1_0 : i22 to i32
		memref.store %tmp_8, %tmp_4[%tmp_7] : memref<3xi32>
		%tmp_9 = arith.constant 2: index
		%tmp_10 = arith.extsi %l_____input2______47_d1_0 : i22 to i32
		memref.store %tmp_10, %tmp_4[%tmp_9] : memref<3xi32>
		// l_input__49_d1_0 aliased to tmp_4
		// Action Local Variable Decl: End
		// If Statement: Begin
		%tmp_11 = cal.get(%l_matrix__number__39: !cal.state_ref<i32>) : i32
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
			%tmp_18 = cal.get(%l_matrix__number__39: !cal.state_ref<i32>) : i32
			fifo.print("R%u: row 1: \00", %tmp_18) : (i32)
			// Call Statement: End
			// If Statement: Begin
			// Evaluate global variable $eval5.
			%tmp_19 = arith.constant 1 : i1
			%tmp_20 = arith.extui %tmp_19 : i1 to i32
			// Evaluate global variable $eval5 done: assigned to tmp_20 above in this context.
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
				// Evaluate global variable $eval9.
				%tmp_29 = arith.constant 3 : i2
				%tmp_30 = arith.extui %tmp_29 : i2 to i32
				// Evaluate global variable $eval9 done: assigned to tmp_30 above in this context.
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
			// Evaluate global variable $eval9.
			%tmp_41 = arith.constant 3 : i2
			%tmp_42 = arith.extui %tmp_41 : i2 to i32
			// Evaluate global variable $eval9 done: assigned to tmp_42 above in this context.
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
				%tmp_52 = memref.load %tmp_4[%tmp_50] : memref<3xi32>
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
		%tmp_54 = cal.get(%l_matrix__number__39: !cal.state_ref<i32>) : i32
		%tmp_55 = arith.constant 1 : i1
		%tmp_56 = arith.extui %tmp_55 : i1 to i32
		%tmp_57 = arith.addi %tmp_54, %tmp_56 : i32
		cal.set(%l_matrix__number__39: !cal.state_ref<i32>, %tmp_57: i32)
		// Assignment Statement: End
		// Assignment Statement: Start
		%tmp_58 = arith.constant 0 : i1
		%tmp_59 = arith.extui %tmp_58 : i1 to i32
		cal.set(%l_$state: !cal.state_ref<i32>, %tmp_59: i32)
		// Assignment Statement: End
		// Output Expression: Start
		%tmp_60 = arith.constant 0 : index
		%tmp_61 = memref.load %tmp_4[%tmp_60] : memref<3xi32>
		%tmp_62 = arith.trunci %tmp_61 : i32 to i22
		fifo.push(%r_out: !fifo.input_port<i22>, %tmp_62: i22)
		%tmp_63 = arith.constant 1 : index
		%tmp_64 = memref.load %tmp_4[%tmp_63] : memref<3xi32>
		%tmp_65 = arith.trunci %tmp_64 : i32 to i22
		fifo.push(%r_out: !fifo.input_port<i22>, %tmp_65: i22)
		%tmp_66 = arith.constant 2 : index
		%tmp_67 = memref.load %tmp_4[%tmp_66] : memref<3xi32>
		%tmp_68 = arith.trunci %tmp_67 : i32 to i22
		fifo.push(%r_out: !fifo.input_port<i22>, %tmp_68: i22)
		// Output Expression: End
	}
}

// -- Top Network: Defines structure of actor application
cal.network @Top()
{

	// -- Instantiate channels between actors
	%queue_from_innerCells_q_6_r_out, %queue_to_joinersPerRow_q_2_r_in_array_1_x = fifo.create<i22>(1) : !fifo.input_port<i22>, !fifo.output_port<i22>
	%queue_from_boundaryCells_3_r_out, %queue_to_joinersPerRow_r_3_r_in_array_0_x = fifo.create<i22>(1) : !fifo.input_port<i22>, !fifo.output_port<i22>
	%queue_from_innerCells_q_6_cordic_angles_out, %queue_to_innerCells_q_7_cordic_angles_in = fifo.create<i16>(100) : !fifo.input_port<i16>, !fifo.output_port<i16>
	%queue_from_iGenerator_3_Out, %queue_to_innerCells_q_3_x_in = fifo.create<i22>(100) : !fifo.input_port<i22>, !fifo.output_port<i22>
	%queue_from_innerCells_q_2_cordic_angles_out, %queue_to_innerCells_q_3_cordic_angles_in = fifo.create<i16>(100) : !fifo.input_port<i16>, !fifo.output_port<i16>
	%queue_from_innerCells_r_3_cordic_angles_out, %queue_to_innerCells_r_4_cordic_angles_in = fifo.create<i16>(100) : !fifo.input_port<i16>, !fifo.output_port<i16>
	%queue_from_joinersPerRow_r_2_r_out, %queue_to_caps_r_2_In = fifo.create<i22>(4) : !fifo.input_port<i22>, !fifo.output_port<i22>
	%queue_from_innerCells_q_12_r_out, %queue_to_joinersPerRow_q_0_r_in_array_3_x = fifo.create<i22>(1) : !fifo.input_port<i22>, !fifo.output_port<i22>
	%queue_from_boundaryCells_3_cordic_angles_out, %queue_to_innerCells_q_12_cordic_angles_in = fifo.create<i16>(100) : !fifo.input_port<i16>, !fifo.output_port<i16>
	%queue_from_innerCells_q_10_x_out, %queue_to_innerCells_q_14_x_in = fifo.create<i22>(100) : !fifo.input_port<i22>, !fifo.output_port<i22>
	%queue_from_innerCells_q_14_x_out, %queue_to_caps_x_2_In = fifo.create<i22>(1) : !fifo.input_port<i22>, !fifo.output_port<i22>
	%queue_from_joinersPerRow_q_0_q_out, %queue_to_caps_q_0_In = fifo.create<i22>(4) : !fifo.input_port<i22>, !fifo.output_port<i22>
	%queue_from_innerCells_q_8_x_out, %queue_to_innerCells_q_12_x_in = fifo.create<i22>(100) : !fifo.input_port<i22>, !fifo.output_port<i22>
	%queue_from_innerCells_q_4_x_out, %queue_to_innerCells_q_8_x_in = fifo.create<i22>(100) : !fifo.input_port<i22>, !fifo.output_port<i22>
	%queue_from_innerCells_r_5_x_out, %queue_to_boundaryCells_3_x_in = fifo.create<i22>(100) : !fifo.input_port<i22>, !fifo.output_port<i22>
	%queue_from_innerCells_q_0_x_out, %queue_to_innerCells_q_4_x_in = fifo.create<i22>(100) : !fifo.input_port<i22>, !fifo.output_port<i22>
	%queue_from_innerCells_q_11_cordic_angles_out, %queue_to_caps_cordic_2_In = fifo.create<i16>(1) : !fifo.input_port<i16>, !fifo.output_port<i16>
	%queue_from_innerCells_r_1_x_out, %queue_to_innerCells_r_3_x_in = fifo.create<i22>(100) : !fifo.input_port<i22>, !fifo.output_port<i22>
	%queue_from_innerCells_q_15_cordic_angles_out, %queue_to_caps_cordic_3_In = fifo.create<i16>(1) : !fifo.input_port<i16>, !fifo.output_port<i16>
	%queue_from_innerCells_q_1_r_out, %queue_to_joinersPerRow_q_1_r_in_array_0_x = fifo.create<i22>(1) : !fifo.input_port<i22>, !fifo.output_port<i22>
	%queue_from_innerCells_r_2_r_out, %queue_to_joinersPerRow_r_0_r_in_array_3_x = fifo.create<i22>(1) : !fifo.input_port<i22>, !fifo.output_port<i22>
	%queue_from_joinersPerRow_r_1_r_out, %queue_to_caps_r_1_In = fifo.create<i22>(4) : !fifo.input_port<i22>, !fifo.output_port<i22>
	%queue_from_innerCells_q_5_r_out, %queue_to_joinersPerRow_q_1_r_in_array_1_x = fifo.create<i22>(1) : !fifo.input_port<i22>, !fifo.output_port<i22>
	%queue_from_innerCells_q_9_cordic_angles_out, %queue_to_innerCells_q_10_cordic_angles_in = fifo.create<i16>(100) : !fifo.input_port<i16>, !fifo.output_port<i16>
	%queue_from_boundaryCells_0_cordic_angles_out, %queue_to_innerCells_r_0_cordic_angles_in = fifo.create<i16>(100) : !fifo.input_port<i16>, !fifo.output_port<i16>
	%queue_from_innerCells_q_9_r_out, %queue_to_joinersPerRow_q_1_r_in_array_2_x = fifo.create<i22>(1) : !fifo.input_port<i22>, !fifo.output_port<i22>
	%queue_from_innerCells_r_2_cordic_angles_out, %queue_to_innerCells_q_0_cordic_angles_in = fifo.create<i16>(100) : !fifo.input_port<i16>, !fifo.output_port<i16>
	%queue_from_innerCells_q_13_r_out, %queue_to_joinersPerRow_q_1_r_in_array_3_x = fifo.create<i22>(1) : !fifo.input_port<i22>, !fifo.output_port<i22>
	%queue_from_innerCells_q_5_cordic_angles_out, %queue_to_innerCells_q_6_cordic_angles_in = fifo.create<i16>(100) : !fifo.input_port<i16>, !fifo.output_port<i16>
	%queue_from_iGenerator_0_Out, %queue_to_innerCells_q_0_x_in = fifo.create<i22>(100) : !fifo.input_port<i22>, !fifo.output_port<i22>
	%queue_from_source_Out_array_3_x, %queue_to_innerCells_r_2_x_in = fifo.create<i22>(104) : !fifo.input_port<i22>, !fifo.output_port<i22>
	%queue_from_innerCells_q_11_x_out, %queue_to_innerCells_q_15_x_in = fifo.create<i22>(100) : !fifo.input_port<i22>, !fifo.output_port<i22>
	%queue_from_innerCells_q_1_cordic_angles_out, %queue_to_innerCells_q_2_cordic_angles_in = fifo.create<i16>(100) : !fifo.input_port<i16>, !fifo.output_port<i16>
	%queue_from_source_Out_array_1_x, %queue_to_innerCells_r_0_x_in = fifo.create<i22>(104) : !fifo.input_port<i22>, !fifo.output_port<i22>
	%queue_from_innerCells_q_15_x_out, %queue_to_caps_x_3_In = fifo.create<i22>(1) : !fifo.input_port<i22>, !fifo.output_port<i22>
	%queue_from_boundaryCells_2_r_out, %queue_to_joinersPerRow_r_2_r_in_array_0_x = fifo.create<i22>(1) : !fifo.input_port<i22>, !fifo.output_port<i22>
	%queue_from_joinersPerRow_q_1_q_out, %queue_to_caps_q_1_In = fifo.create<i22>(4) : !fifo.input_port<i22>, !fifo.output_port<i22>
	%queue_from_innerCells_q_9_x_out, %queue_to_innerCells_q_13_x_in = fifo.create<i22>(100) : !fifo.input_port<i22>, !fifo.output_port<i22>
	%queue_from_innerCells_r_2_x_out, %queue_to_innerCells_r_4_x_in = fifo.create<i22>(100) : !fifo.input_port<i22>, !fifo.output_port<i22>
	%queue_from_innerCells_q_5_x_out, %queue_to_innerCells_q_9_x_in = fifo.create<i22>(100) : !fifo.input_port<i22>, !fifo.output_port<i22>
	%queue_from_innerCells_q_10_cordic_angles_out, %queue_to_innerCells_q_11_cordic_angles_in = fifo.create<i16>(100) : !fifo.input_port<i16>, !fifo.output_port<i16>
	%queue_from_innerCells_q_0_r_out, %queue_to_joinersPerRow_q_0_r_in_array_0_x = fifo.create<i22>(1) : !fifo.input_port<i22>, !fifo.output_port<i22>
	%queue_from_innerCells_q_1_x_out, %queue_to_innerCells_q_5_x_in = fifo.create<i22>(100) : !fifo.input_port<i22>, !fifo.output_port<i22>
	%queue_from_innerCells_r_1_r_out, %queue_to_joinersPerRow_r_0_r_in_array_2_x = fifo.create<i22>(1) : !fifo.input_port<i22>, !fifo.output_port<i22>
	%queue_from_innerCells_q_14_cordic_angles_out, %queue_to_innerCells_q_15_cordic_angles_in = fifo.create<i16>(100) : !fifo.input_port<i16>, !fifo.output_port<i16>
	%queue_from_innerCells_q_4_r_out, %queue_to_joinersPerRow_q_0_r_in_array_1_x = fifo.create<i22>(1) : !fifo.input_port<i22>, !fifo.output_port<i22>
	%queue_from_innerCells_r_5_r_out, %queue_to_joinersPerRow_r_2_r_in_array_1_x = fifo.create<i22>(1) : !fifo.input_port<i22>, !fifo.output_port<i22>
	%queue_from_innerCells_r_5_cordic_angles_out, %queue_to_innerCells_q_8_cordic_angles_in = fifo.create<i16>(100) : !fifo.input_port<i16>, !fifo.output_port<i16>
	%queue_from_joinersPerRow_r_0_r_out, %queue_to_caps_r_0_In = fifo.create<i22>(4) : !fifo.input_port<i22>, !fifo.output_port<i22>
	%queue_from_iGenerator_1_Out, %queue_to_innerCells_q_1_x_in = fifo.create<i22>(100) : !fifo.input_port<i22>, !fifo.output_port<i22>
	%queue_from_innerCells_q_8_r_out, %queue_to_joinersPerRow_q_0_r_in_array_2_x = fifo.create<i22>(1) : !fifo.input_port<i22>, !fifo.output_port<i22>
	%queue_from_innerCells_q_8_cordic_angles_out, %queue_to_innerCells_q_9_cordic_angles_in = fifo.create<i16>(100) : !fifo.input_port<i16>, !fifo.output_port<i16>
	%queue_from_innerCells_r_1_cordic_angles_out, %queue_to_innerCells_r_2_cordic_angles_in = fifo.create<i16>(100) : !fifo.input_port<i16>, !fifo.output_port<i16>
	%queue_from_innerCells_q_14_r_out, %queue_to_joinersPerRow_q_2_r_in_array_3_x = fifo.create<i22>(1) : !fifo.input_port<i22>, !fifo.output_port<i22>
	%queue_from_boundaryCells_1_cordic_angles_out, %queue_to_innerCells_r_3_cordic_angles_in = fifo.create<i16>(100) : !fifo.input_port<i16>, !fifo.output_port<i16>
	%queue_from_innerCells_q_4_cordic_angles_out, %queue_to_innerCells_q_5_cordic_angles_in = fifo.create<i16>(100) : !fifo.input_port<i16>, !fifo.output_port<i16>
	%queue_from_innerCells_q_12_x_out, %queue_to_caps_x_0_In = fifo.create<i22>(1) : !fifo.input_port<i22>, !fifo.output_port<i22>
	%queue_from_innerCells_q_0_cordic_angles_out, %queue_to_innerCells_q_1_cordic_angles_in = fifo.create<i16>(100) : !fifo.input_port<i16>, !fifo.output_port<i16>
	%queue_from_boundaryCells_1_r_out, %queue_to_joinersPerRow_r_1_r_in_array_0_x = fifo.create<i22>(1) : !fifo.input_port<i22>, !fifo.output_port<i22>
	%queue_from_innerCells_r_3_x_out, %queue_to_boundaryCells_2_x_in = fifo.create<i22>(100) : !fifo.input_port<i22>, !fifo.output_port<i22>
	%queue_from_joinersPerRow_q_2_q_out, %queue_to_caps_q_2_In = fifo.create<i22>(4) : !fifo.input_port<i22>, !fifo.output_port<i22>
	%queue_from_innerCells_q_6_x_out, %queue_to_innerCells_q_10_x_in = fifo.create<i22>(100) : !fifo.input_port<i22>, !fifo.output_port<i22>
	%queue_from_innerCells_q_10_r_out, %queue_to_joinersPerRow_q_2_r_in_array_2_x = fifo.create<i22>(1) : !fifo.input_port<i22>, !fifo.output_port<i22>
	%queue_from_innerCells_q_2_x_out, %queue_to_innerCells_q_6_x_in = fifo.create<i22>(100) : !fifo.input_port<i22>, !fifo.output_port<i22>
	%queue_from_innerCells_r_0_r_out, %queue_to_joinersPerRow_r_0_r_in_array_1_x = fifo.create<i22>(1) : !fifo.input_port<i22>, !fifo.output_port<i22>
	%queue_from_innerCells_q_13_cordic_angles_out, %queue_to_innerCells_q_14_cordic_angles_in = fifo.create<i16>(100) : !fifo.input_port<i16>, !fifo.output_port<i16>
	%queue_from_innerCells_q_3_r_out, %queue_to_joinersPerRow_q_3_r_in_array_0_x = fifo.create<i22>(1) : !fifo.input_port<i22>, !fifo.output_port<i22>
	%queue_from_innerCells_q_7_cordic_angles_out, %queue_to_caps_cordic_1_In = fifo.create<i16>(1) : !fifo.input_port<i16>, !fifo.output_port<i16>
	%queue_from_iGenerator_2_Out, %queue_to_innerCells_q_2_x_in = fifo.create<i22>(100) : !fifo.input_port<i22>, !fifo.output_port<i22>
	%queue_from_innerCells_r_4_r_out, %queue_to_joinersPerRow_r_1_r_in_array_2_x = fifo.create<i22>(1) : !fifo.input_port<i22>, !fifo.output_port<i22>
	%queue_from_innerCells_q_7_r_out, %queue_to_joinersPerRow_q_3_r_in_array_1_x = fifo.create<i22>(1) : !fifo.input_port<i22>, !fifo.output_port<i22>
	%queue_from_innerCells_q_15_r_out, %queue_to_joinersPerRow_q_3_r_in_array_3_x = fifo.create<i22>(1) : !fifo.input_port<i22>, !fifo.output_port<i22>
	%queue_from_innerCells_q_3_cordic_angles_out, %queue_to_caps_cordic_0_In = fifo.create<i16>(1) : !fifo.input_port<i16>, !fifo.output_port<i16>
	%queue_from_joinersPerRow_r_3_r_out, %queue_to_caps_r_3_In = fifo.create<i22>(4) : !fifo.input_port<i22>, !fifo.output_port<i22>
	%queue_from_boundaryCells_2_cordic_angles_out, %queue_to_innerCells_r_5_cordic_angles_in = fifo.create<i16>(100) : !fifo.input_port<i16>, !fifo.output_port<i16>
	%queue_from_innerCells_r_4_cordic_angles_out, %queue_to_innerCells_q_4_cordic_angles_in = fifo.create<i16>(100) : !fifo.input_port<i16>, !fifo.output_port<i16>
	%queue_from_innerCells_q_13_x_out, %queue_to_caps_x_1_In = fifo.create<i22>(1) : !fifo.input_port<i22>, !fifo.output_port<i22>
	%queue_from_source_Out_array_2_x, %queue_to_innerCells_r_1_x_in = fifo.create<i22>(104) : !fifo.input_port<i22>, !fifo.output_port<i22>
	%queue_from_innerCells_r_0_cordic_angles_out, %queue_to_innerCells_r_1_cordic_angles_in = fifo.create<i16>(100) : !fifo.input_port<i16>, !fifo.output_port<i16>
	%queue_from_source_Out_array_0_x, %queue_to_boundaryCells_0_x_in = fifo.create<i22>(104) : !fifo.input_port<i22>, !fifo.output_port<i22>
	%queue_from_boundaryCells_0_r_out, %queue_to_joinersPerRow_r_0_r_in_array_0_x = fifo.create<i22>(1) : !fifo.input_port<i22>, !fifo.output_port<i22>
	%queue_from_innerCells_q_7_x_out, %queue_to_innerCells_q_11_x_in = fifo.create<i22>(100) : !fifo.input_port<i22>, !fifo.output_port<i22>
	%queue_from_innerCells_q_3_x_out, %queue_to_innerCells_q_7_x_in = fifo.create<i22>(100) : !fifo.input_port<i22>, !fifo.output_port<i22>
	%queue_from_innerCells_r_4_x_out, %queue_to_innerCells_r_5_x_in = fifo.create<i22>(100) : !fifo.input_port<i22>, !fifo.output_port<i22>
	%queue_from_joinersPerRow_q_3_q_out, %queue_to_caps_q_3_In = fifo.create<i22>(4) : !fifo.input_port<i22>, !fifo.output_port<i22>
	%queue_from_innerCells_q_12_cordic_angles_out, %queue_to_innerCells_q_13_cordic_angles_in = fifo.create<i16>(100) : !fifo.input_port<i16>, !fifo.output_port<i16>
	%queue_from_innerCells_q_11_r_out, %queue_to_joinersPerRow_q_3_r_in_array_2_x = fifo.create<i22>(1) : !fifo.input_port<i22>, !fifo.output_port<i22>
	%queue_from_innerCells_r_0_x_out, %queue_to_boundaryCells_1_x_in = fifo.create<i22>(100) : !fifo.input_port<i22>, !fifo.output_port<i22>
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
	cal.create_instance @caps_cordic_0 "caps_cordic_0" ()
		ports_in(%queue_to_caps_cordic_0_In: !fifo.output_port<i16>)
	cal.create_instance @innerCells_q_0 "innerCells_q_0" ()
		ports_in(%queue_to_innerCells_q_0_x_in, %queue_to_innerCells_q_0_cordic_angles_in: !fifo.output_port<i22>, !fifo.output_port<i16>)
		ports_out(%queue_from_innerCells_q_0_x_out, %queue_from_innerCells_q_0_r_out, %queue_from_innerCells_q_0_cordic_angles_out: !fifo.input_port<i22>, !fifo.input_port<i22>, !fifo.input_port<i16>)
	cal.create_instance @boundaryCells_0 "boundaryCells_0" ()
		ports_in(%queue_to_boundaryCells_0_x_in: !fifo.output_port<i22>)
		ports_out(%queue_from_boundaryCells_0_r_out, %queue_from_boundaryCells_0_cordic_angles_out: !fifo.input_port<i22>, !fifo.input_port<i16>)
	cal.create_instance @innerCells_q_1 "innerCells_q_1" ()
		ports_in(%queue_to_innerCells_q_1_x_in, %queue_to_innerCells_q_1_cordic_angles_in: !fifo.output_port<i22>, !fifo.output_port<i16>)
		ports_out(%queue_from_innerCells_q_1_x_out, %queue_from_innerCells_q_1_r_out, %queue_from_innerCells_q_1_cordic_angles_out: !fifo.input_port<i22>, !fifo.input_port<i22>, !fifo.input_port<i16>)
	cal.create_instance @boundaryCells_3 "boundaryCells_3" ()
		ports_in(%queue_to_boundaryCells_3_x_in: !fifo.output_port<i22>)
		ports_out(%queue_from_boundaryCells_3_r_out, %queue_from_boundaryCells_3_cordic_angles_out: !fifo.input_port<i22>, !fifo.input_port<i16>)
	cal.create_instance @boundaryCells_2 "boundaryCells_2" ()
		ports_in(%queue_to_boundaryCells_2_x_in: !fifo.output_port<i22>)
		ports_out(%queue_from_boundaryCells_2_r_out, %queue_from_boundaryCells_2_cordic_angles_out: !fifo.input_port<i22>, !fifo.input_port<i16>)
	cal.create_instance @source "source" ()
		ports_out(%queue_from_source_Out_array_0_x, %queue_from_source_Out_array_1_x, %queue_from_source_Out_array_2_x, %queue_from_source_Out_array_3_x: !fifo.input_port<i22>, !fifo.input_port<i22>, !fifo.input_port<i22>, !fifo.input_port<i22>)
	cal.create_instance @innerCells_r_5 "innerCells_r_5" ()
		ports_in(%queue_to_innerCells_r_5_x_in, %queue_to_innerCells_r_5_cordic_angles_in: !fifo.output_port<i22>, !fifo.output_port<i16>)
		ports_out(%queue_from_innerCells_r_5_x_out, %queue_from_innerCells_r_5_r_out, %queue_from_innerCells_r_5_cordic_angles_out: !fifo.input_port<i22>, !fifo.input_port<i22>, !fifo.input_port<i16>)
	cal.create_instance @caps_r_0 "caps_r_0" ()
		ports_in(%queue_to_caps_r_0_In: !fifo.output_port<i22>)
	cal.create_instance @innerCells_r_3 "innerCells_r_3" ()
		ports_in(%queue_to_innerCells_r_3_x_in, %queue_to_innerCells_r_3_cordic_angles_in: !fifo.output_port<i22>, !fifo.output_port<i16>)
		ports_out(%queue_from_innerCells_r_3_x_out, %queue_from_innerCells_r_3_r_out, %queue_from_innerCells_r_3_cordic_angles_out: !fifo.input_port<i22>, !fifo.input_port<i22>, !fifo.input_port<i16>)
	cal.create_instance @innerCells_r_4 "innerCells_r_4" ()
		ports_in(%queue_to_innerCells_r_4_x_in, %queue_to_innerCells_r_4_cordic_angles_in: !fifo.output_port<i22>, !fifo.output_port<i16>)
		ports_out(%queue_from_innerCells_r_4_x_out, %queue_from_innerCells_r_4_r_out, %queue_from_innerCells_r_4_cordic_angles_out: !fifo.input_port<i22>, !fifo.input_port<i22>, !fifo.input_port<i16>)
	cal.create_instance @caps_r_2 "caps_r_2" ()
		ports_in(%queue_to_caps_r_2_In: !fifo.output_port<i22>)
	cal.create_instance @innerCells_r_1 "innerCells_r_1" ()
		ports_in(%queue_to_innerCells_r_1_x_in, %queue_to_innerCells_r_1_cordic_angles_in: !fifo.output_port<i22>, !fifo.output_port<i16>)
		ports_out(%queue_from_innerCells_r_1_x_out, %queue_from_innerCells_r_1_r_out, %queue_from_innerCells_r_1_cordic_angles_out: !fifo.input_port<i22>, !fifo.input_port<i22>, !fifo.input_port<i16>)
	cal.create_instance @caps_r_1 "caps_r_1" ()
		ports_in(%queue_to_caps_r_1_In: !fifo.output_port<i22>)
	cal.create_instance @innerCells_r_2 "innerCells_r_2" ()
		ports_in(%queue_to_innerCells_r_2_x_in, %queue_to_innerCells_r_2_cordic_angles_in: !fifo.output_port<i22>, !fifo.output_port<i16>)
		ports_out(%queue_from_innerCells_r_2_x_out, %queue_from_innerCells_r_2_r_out, %queue_from_innerCells_r_2_cordic_angles_out: !fifo.input_port<i22>, !fifo.input_port<i22>, !fifo.input_port<i16>)
	cal.create_instance @iGenerator_2 "iGenerator_2" ()
		ports_out(%queue_from_iGenerator_2_Out: !fifo.input_port<i22>)
	cal.create_instance @joinersPerRow_q_1 "joinersPerRow_q_1" ()
		ports_in(%queue_to_joinersPerRow_q_1_r_in_array_0_x, %queue_to_joinersPerRow_q_1_r_in_array_1_x, %queue_to_joinersPerRow_q_1_r_in_array_2_x, %queue_to_joinersPerRow_q_1_r_in_array_3_x: !fifo.output_port<i22>, !fifo.output_port<i22>, !fifo.output_port<i22>, !fifo.output_port<i22>)
		ports_out(%queue_from_joinersPerRow_q_1_q_out: !fifo.input_port<i22>)
	cal.create_instance @caps_r_3 "caps_r_3" ()
		ports_in(%queue_to_caps_r_3_In: !fifo.output_port<i22>)
	cal.create_instance @iGenerator_1 "iGenerator_1" ()
		ports_out(%queue_from_iGenerator_1_Out: !fifo.input_port<i22>)
	cal.create_instance @joinersPerRow_q_0 "joinersPerRow_q_0" ()
		ports_in(%queue_to_joinersPerRow_q_0_r_in_array_0_x, %queue_to_joinersPerRow_q_0_r_in_array_1_x, %queue_to_joinersPerRow_q_0_r_in_array_2_x, %queue_to_joinersPerRow_q_0_r_in_array_3_x: !fifo.output_port<i22>, !fifo.output_port<i22>, !fifo.output_port<i22>, !fifo.output_port<i22>)
		ports_out(%queue_from_joinersPerRow_q_0_q_out: !fifo.input_port<i22>)
	cal.create_instance @joinersPerRow_q_3 "joinersPerRow_q_3" ()
		ports_in(%queue_to_joinersPerRow_q_3_r_in_array_0_x, %queue_to_joinersPerRow_q_3_r_in_array_1_x, %queue_to_joinersPerRow_q_3_r_in_array_2_x, %queue_to_joinersPerRow_q_3_r_in_array_3_x: !fifo.output_port<i22>, !fifo.output_port<i22>, !fifo.output_port<i22>, !fifo.output_port<i22>)
		ports_out(%queue_from_joinersPerRow_q_3_q_out: !fifo.input_port<i22>)
	cal.create_instance @caps_x_0 "caps_x_0" ()
		ports_in(%queue_to_caps_x_0_In: !fifo.output_port<i22>)
	cal.create_instance @iGenerator_3 "iGenerator_3" ()
		ports_out(%queue_from_iGenerator_3_Out: !fifo.input_port<i22>)
	cal.create_instance @joinersPerRow_q_2 "joinersPerRow_q_2" ()
		ports_in(%queue_to_joinersPerRow_q_2_r_in_array_0_x, %queue_to_joinersPerRow_q_2_r_in_array_1_x, %queue_to_joinersPerRow_q_2_r_in_array_2_x, %queue_to_joinersPerRow_q_2_r_in_array_3_x: !fifo.output_port<i22>, !fifo.output_port<i22>, !fifo.output_port<i22>, !fifo.output_port<i22>)
		ports_out(%queue_from_joinersPerRow_q_2_q_out: !fifo.input_port<i22>)
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
	cal.create_instance @innerCells_q_4 "innerCells_q_4" ()
		ports_in(%queue_to_innerCells_q_4_x_in, %queue_to_innerCells_q_4_cordic_angles_in: !fifo.output_port<i22>, !fifo.output_port<i16>)
		ports_out(%queue_from_innerCells_q_4_x_out, %queue_from_innerCells_q_4_r_out, %queue_from_innerCells_q_4_cordic_angles_out: !fifo.input_port<i22>, !fifo.input_port<i22>, !fifo.input_port<i16>)
	cal.create_instance @caps_q_1 "caps_q_1" ()
		ports_in(%queue_to_caps_q_1_In: !fifo.output_port<i22>)
	cal.create_instance @innerCells_q_5 "innerCells_q_5" ()
		ports_in(%queue_to_innerCells_q_5_x_in, %queue_to_innerCells_q_5_cordic_angles_in: !fifo.output_port<i22>, !fifo.output_port<i16>)
		ports_out(%queue_from_innerCells_q_5_x_out, %queue_from_innerCells_q_5_r_out, %queue_from_innerCells_q_5_cordic_angles_out: !fifo.input_port<i22>, !fifo.input_port<i22>, !fifo.input_port<i16>)
	cal.create_instance @caps_q_0 "caps_q_0" ()
		ports_in(%queue_to_caps_q_0_In: !fifo.output_port<i22>)
	cal.create_instance @innerCells_q_2 "innerCells_q_2" ()
		ports_in(%queue_to_innerCells_q_2_x_in, %queue_to_innerCells_q_2_cordic_angles_in: !fifo.output_port<i22>, !fifo.output_port<i16>)
		ports_out(%queue_from_innerCells_q_2_x_out, %queue_from_innerCells_q_2_r_out, %queue_from_innerCells_q_2_cordic_angles_out: !fifo.input_port<i22>, !fifo.input_port<i22>, !fifo.input_port<i16>)
	cal.create_instance @caps_q_3 "caps_q_3" ()
		ports_in(%queue_to_caps_q_3_In: !fifo.output_port<i22>)
	cal.create_instance @innerCells_q_3 "innerCells_q_3" ()
		ports_in(%queue_to_innerCells_q_3_x_in, %queue_to_innerCells_q_3_cordic_angles_in: !fifo.output_port<i22>, !fifo.output_port<i16>)
		ports_out(%queue_from_innerCells_q_3_x_out, %queue_from_innerCells_q_3_r_out, %queue_from_innerCells_q_3_cordic_angles_out: !fifo.input_port<i22>, !fifo.input_port<i22>, !fifo.input_port<i16>)
	cal.create_instance @caps_q_2 "caps_q_2" ()
		ports_in(%queue_to_caps_q_2_In: !fifo.output_port<i22>)
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

