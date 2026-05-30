module {
  // libc I/O wrapper declarations for std.io intrinsics
  func.func private @__cal_fopen(!llvm.ptr, !llvm.ptr) -> i64
  func.func private @__cal_fclose(i64) -> i32
  func.func private @__cal_fread(i64, i64, i64, i64) -> i64
  func.func private @__cal_fwrite(i64, i64, i64, i64) -> i64
  func.func private @__cal_fseek(i64, i64, i32) -> i32
  func.func private @__cal_ftell(i64) -> i64
  func.func private @__cal_feof(i64) -> i32
  func.func private @__cal_fflush(i64) -> i32
  func.func private @__cal_ferror(i64) -> i32
  func.func private @__cal_fgetc(i64) -> i32
  func.func private @__cal_fputc(i32, i64) -> i32
  func.func private @__cal_rewind(i64) -> ()
  func.func private @__cal_clearerr(i64) -> ()

  // libc string wrapper declarations for std.string intrinsics
  func.func private @strlen(!llvm.ptr) -> i64
  func.func private @strcmp(!llvm.ptr, !llvm.ptr) -> i32
  func.func private @atoi(!llvm.ptr) -> i32
  func.func private @atof(!llvm.ptr) -> f64
  // String concatenation runtime (allocates and returns new string)
  func.func private @__cal_strcat(!llvm.ptr, !llvm.ptr) -> !llvm.ptr

  // Random number generation runtime declarations
  func.func private @__cal_srand(i64) -> ()
  func.func private @__cal_rand_f32() -> f32
  func.func private @__cal_rand_f64() -> f64
  func.func private @__cal_randn_f32() -> f32
  func.func private @__cal_randn_f64() -> f64
  func.func private @__cal_rand_range_f32(f32, f32) -> f32
  func.func private @__cal_rand_range_f64(f64, f64) -> f64
  func.func private @__cal_randn_params_f32(f32, f32) -> f32
  func.func private @__cal_randn_params_f64(f64, f64) -> f64
  func.func private @__cal_rand_i32() -> i32
  func.func private @__cal_rand_int_range(i32) -> i32

  func.func @idct__Scaled_1d_idct__fn_pmul_1_0(%X: i32) -> i32 attributes { cal.ns = "idct", cal.owner = "Scaled_1d_idct" } {
    %t0 = arith.constant 3 : i32 loc(#loc0)
    %t1 = arith.subi %t0, %X : i32 loc(#loc0)
    %t2 = arith.shrsi %X, %t1 : i32 loc(#loc1)
    %t3 = arith.constant 7 : i32 loc(#loc2)
    %t4 = arith.shrsi %t2, %t3 : i32 loc(#loc1)
    %t5 = arith.subi %X, %t4 : i32 loc(#loc3)
    return %t5 : i32
  }
  func.func @idct__Scaled_1d_idct__fn_pmul_1_1(%X: i32) -> i32 attributes { cal.ns = "idct", cal.owner = "Scaled_1d_idct" } {
    %t0 = arith.constant 3 : i32 loc(#loc4)
    %t1 = arith.subi %t0, %X : i32 loc(#loc4)
    %t2 = arith.shrsi %X, %t1 : i32 loc(#loc5)
    %t3 = arith.constant 7 : i32 loc(#loc6)
    %t4 = arith.shrsi %t2, %t3 : i32 loc(#loc5)
    %t5 = arith.constant 11 : i32 loc(#loc7)
    %t6 = arith.shrsi %X, %t5 : i32 loc(#loc8)
    %t7 = arith.subi %t4, %t6 : i32 loc(#loc9)
    %t8 = arith.constant 1 : i32 loc(#loc10)
    %t9 = arith.shrsi %t7, %t8 : i32 loc(#loc11)
    %t10 = arith.addi %t4, %t9 : i32 loc(#loc12)
    return %t10 : i32
  }
  func.func @idct__Scaled_1d_idct__fn_pmul_2_0(%X: i32) -> i32 attributes { cal.ns = "idct", cal.owner = "Scaled_1d_idct" } {
    %t0 = arith.constant 9 : i32 loc(#loc13)
    %t1 = arith.subi %t0, %X : i32 loc(#loc13)
    %t2 = arith.shrsi %X, %t1 : i32 loc(#loc14)
    %t3 = arith.constant 2 : i32 loc(#loc15)
    %t4 = arith.subi %t3, %t2 : i32 loc(#loc15)
    %t5 = arith.shrsi %t2, %t4 : i32 loc(#loc16)
    return %t5 : i32
  }
  func.func @idct__Scaled_1d_idct__fn_pmul_2_1(%X: i32) -> i32 attributes { cal.ns = "idct", cal.owner = "Scaled_1d_idct" } {
    %t0 = arith.constant 1 : i32 loc(#loc17)
    %t1 = arith.shrsi %X, %t0 : i32 loc(#loc18)
    return %t1 : i32
  }
  func.func @idct__Scaled_1d_idct__fn_pmul_3_0(%X: i32) -> i32 attributes { cal.ns = "idct", cal.owner = "Scaled_1d_idct" } {
    %t0 = arith.addi %X, %X : i32 loc(#loc19)
    %t1 = arith.constant 5 : i32 loc(#loc20)
    %t2 = arith.shrsi %t0, %t1 : i32 loc(#loc19)
    %t3 = arith.constant 2 : i32 loc(#loc21)
    %t4 = arith.shrsi %t2, %t3 : i32 loc(#loc22)
    %t5 = arith.addi %t4, %X : i32 loc(#loc23)
    %t6 = arith.constant 4 : i32 loc(#loc24)
    %t7 = arith.shrsi %t5, %t6 : i32 loc(#loc23)
    return %t7 : i32
  }
  func.func @idct__Scaled_1d_idct__fn_pmul_3_1(%X: i32) -> i32 attributes { cal.ns = "idct", cal.owner = "Scaled_1d_idct" } {
    %t0 = arith.addi %X, %X : i32 loc(#loc25)
    %t1 = arith.constant 5 : i32 loc(#loc26)
    %t2 = arith.shrsi %t0, %t1 : i32 loc(#loc25)
    %t3 = arith.constant 2 : i32 loc(#loc27)
    %t4 = arith.shrsi %t2, %t3 : i32 loc(#loc28)
    %t5 = arith.subi %t2, %t4 : i32 loc(#loc29)
    return %t5 : i32
  }
  cal.network @idct__TopIDCT()
  {
    %t0 = arith.constant 13 : i32 loc(#loc30)
    %t1 = arith.constant 30000 : i32 loc(#loc31)
    %t2 = arith.constant 10000000 : i32 loc(#loc32)
    %source = cal.instantiate @idct__Generator__v__IMG_NUMBERS_30000__SIN_SZ_13__limit_10000000 (%t0, %t1, %t2 : i32, i32, i32) instance("source") {cal.instance_name = "source", cal.class_name = "@idct__Generator__v__IMG_NUMBERS_30000__SIN_SZ_13__limit_10000000"} : !cal.instance<@idct__Generator__v__IMG_NUMBERS_30000__SIN_SZ_13__limit_10000000>
    %t3 = arith.constant 32 : i32 loc(#loc33)
    %t4 = arith.constant 32 : i32 loc(#loc34)
    %t5 = arith.constant 13 : i32 loc(#loc35)
    %idct2d = cal.instantiate @idct__IDCT2D_23002 (%t3, %t4, %t5 : i32, i32, i32) instance("idct2d") {cal.instance_name = "idct2d", cal.class_name = "@idct__IDCT2D_23002"} : !cal.instance<@idct__IDCT2D_23002>
    %t6 = arith.constant 32 : i32 loc(#loc36)
    %t7 = arith.constant 10000000 : i32 loc(#loc37)
    %sink = cal.instantiate @idct__Sink__v__PIX_SZ_32__limit_10000000 (%t6, %t7 : i32, i32) instance("sink") {cal.instance_name = "sink", cal.class_name = "@idct__Sink__v__PIX_SZ_32__limit_10000000"} : !cal.instance<@idct__Sink__v__PIX_SZ_32__limit_10000000>
    cal.connect %source : !cal.instance<@idct__Generator__v__IMG_NUMBERS_30000__SIN_SZ_13__limit_10000000> "OUT" -> %idct2d : !cal.instance<@idct__IDCT2D_23002> "IN" capacity(4096)
    cal.connect %source : !cal.instance<@idct__Generator__v__IMG_NUMBERS_30000__SIN_SZ_13__limit_10000000> "SIGNED" -> %idct2d : !cal.instance<@idct__IDCT2D_23002> "SIGNED" capacity(4096)
    cal.connect %idct2d : !cal.instance<@idct__IDCT2D_23002> "OUT" -> %sink : !cal.instance<@idct__Sink__v__PIX_SZ_32__limit_10000000> "IN" capacity(4096)
  }
  cal.actor @idct__Transpose()
    in_names ["IN"]
    out_names ["OUT"]
    ports_in(%IN: !fifo.output_port<i32>)
    ports_out(%OUT: !fifo.input_port<i32>)
  {
    cal.action "$untagged0" priority=0 {
      %t0 = memref.alloca() : memref<64xi32>
      %t1 = arith.constant 64 : index
      %t2 = arith.constant 0 : index
      %t3 = arith.constant 1 : index
      scf.for %t4 = %t2 to %t1 step %t3 {
        %t5 = fifo.pop(%IN: !fifo.output_port<i32> ) : i32
        memref.store %t5, %t0[%t4] : memref<64xi32>
        scf.yield
      }
      %t6 = arith.constant 0 : i32 loc(#loc39)
      %t7 = arith.constant 7 : i32 loc(#loc40)
      %t8 = arith.index_cast %t6 : i32 to index
      %t9 = arith.index_cast %t7 : i32 to index
      %t10 = arith.constant 1 : index
      %t11 = arith.addi %t9, %t10 : index
      %t12 = arith.constant 0 : i32 loc(#loc41)
      %t13 = arith.constant 7 : i32 loc(#loc42)
      %t14 = arith.index_cast %t12 : i32 to index
      %t15 = arith.index_cast %t13 : i32 to index
      %t16 = arith.constant 1 : index
      %t17 = arith.addi %t15, %t16 : index
      %t18 = arith.constant 1 : index
      scf.for %t19 = %t8 to %t11 step %t18 {
        %t20 = arith.index_cast %t19 : index to i32
        scf.for %t21 = %t14 to %t17 step %t18 {
          %t22 = arith.index_cast %t21 : index to i32
          %t23 = arith.constant 8 : i32 loc(#loc43)
          %t24 = arith.muli %t23, %t22 : i32 loc(#loc43)
          %t25 = arith.addi %t24, %t20 : i32 loc(#loc43)
          %t26 = arith.index_cast %t25 : i32 to index
          %t27 = memref.load %t0[%t26] : memref<64xi32> loc(#loc44)
          fifo.push(%OUT: !fifo.input_port<i32>, %t27: i32)
          scf.yield
        }
        scf.yield
      }
    } loc(#loc38)
  } loc(#loc45)
  cal.actor @idct__Rightshift()
    in_names ["IN"]
    out_names ["OUT"]
    ports_in(%IN: !fifo.output_port<i32>)
    ports_out(%OUT: !fifo.input_port<i32>)
  {
    cal.action "shift" priority=0 {
      %t0 = memref.alloca() : memref<64xi32>
      %t1 = arith.constant 64 : index
      %t2 = arith.constant 0 : index
      %t3 = arith.constant 1 : index
      scf.for %t4 = %t2 to %t1 step %t3 {
        %t5 = fifo.pop(%IN: !fifo.output_port<i32> ) : i32
        memref.store %t5, %t0[%t4] : memref<64xi32>
        scf.yield
      }
      %t6 = arith.constant 0 : i32 loc(#loc47)
      %t7 = arith.constant 63 : i32 loc(#loc48)
      %t8 = arith.index_cast %t6 : i32 to index
      %t9 = arith.index_cast %t7 : i32 to index
      %t10 = arith.constant 1 : index
      %t11 = arith.addi %t9, %t10 : index
      %t12 = arith.constant 1 : index
      scf.for %t13 = %t8 to %t11 step %t12 {
        %t14 = arith.index_cast %t13 : index to i32
        %t15 = arith.index_cast %t14 : i32 to index
        %t16 = memref.load %t0[%t15] : memref<64xi32> loc(#loc49)
        %t17 = arith.constant 13 : i32 loc(#loc50)
        %t18 = arith.shrsi %t16, %t17 : i32 loc(#loc49)
        fifo.push(%OUT: !fifo.input_port<i32>, %t18: i32)
        scf.yield
      }
    } loc(#loc46)
  } loc(#loc51)
  cal.actor @idct__Generator__v__IMG_NUMBERS_30000__SIN_SZ_13__limit_10000000(%SIN_SZ: i32, %IMG_NUMBERS: i32, %limit: i32)
    out_names ["OUT", "SIGNED"]
    ports_out(%OUT: !fifo.input_port<i13>, %SIGNED: !fifo.input_port<i1>)
  {
    %t0 = cal.create_state_var<i32> : !cal.state_ref<i32>
    %t1 = arith.constant 38016 : i32 loc(#loc52)
    %t2 = arith.constant 64 : i32 loc(#loc53)
    %t3 = arith.divsi %t1, %t2 : i32 loc(#loc52)
    cal.set(%t0: !cal.state_ref<i32>, %t3: i32)
    %t4 = cal.create_state_var<memref<64xi13>> : !cal.state_ref<memref<64xi13>>
    %t5 = cal.get(%t4: !cal.state_ref<memref<64xi13>>) : memref<64xi13>
    %t6 = arith.constant 1458 : i32 loc(#loc54)
    %t7 = arith.trunci %t6 : i32 to i13
    %t8 = arith.constant 0 : index
    memref.store %t7, %t5[%t8] : memref<64xi13>
    %t9 = arith.constant 289 : i32 loc(#loc55)
    %t10 = arith.constant 0 : i32 loc(#loc56)
    %t11 = arith.subi %t10, %t9 : i32 loc(#loc56)
    %t12 = arith.trunci %t11 : i32 to i13
    %t13 = arith.constant 1 : index
    memref.store %t12, %t5[%t13] : memref<64xi13>
    %t14 = arith.constant 249 : i32 loc(#loc57)
    %t15 = arith.constant 0 : i32 loc(#loc58)
    %t16 = arith.subi %t15, %t14 : i32 loc(#loc58)
    %t17 = arith.trunci %t16 : i32 to i13
    %t18 = arith.constant 2 : index
    memref.store %t17, %t5[%t18] : memref<64xi13>
    %t19 = arith.constant 149 : i32 loc(#loc59)
    %t20 = arith.constant 0 : i32 loc(#loc60)
    %t21 = arith.subi %t20, %t19 : i32 loc(#loc60)
    %t22 = arith.trunci %t21 : i32 to i13
    %t23 = arith.constant 3 : index
    memref.store %t22, %t5[%t23] : memref<64xi13>
    %t24 = arith.constant 169 : i32 loc(#loc61)
    %t25 = arith.constant 0 : i32 loc(#loc62)
    %t26 = arith.subi %t25, %t24 : i32 loc(#loc62)
    %t27 = arith.trunci %t26 : i32 to i13
    %t28 = arith.constant 4 : index
    memref.store %t27, %t5[%t28] : memref<64xi13>
    %t29 = arith.constant 89 : i32 loc(#loc63)
    %t30 = arith.constant 0 : i32 loc(#loc64)
    %t31 = arith.subi %t30, %t29 : i32 loc(#loc64)
    %t32 = arith.trunci %t31 : i32 to i13
    %t33 = arith.constant 5 : index
    memref.store %t32, %t5[%t33] : memref<64xi13>
    %t34 = arith.constant 49 : i32 loc(#loc65)
    %t35 = arith.constant 0 : i32 loc(#loc66)
    %t36 = arith.subi %t35, %t34 : i32 loc(#loc66)
    %t37 = arith.trunci %t36 : i32 to i13
    %t38 = arith.constant 6 : index
    memref.store %t37, %t5[%t38] : memref<64xi13>
    %t39 = arith.constant 0 : i32 loc(#loc67)
    %t40 = arith.trunci %t39 : i32 to i13
    %t41 = arith.constant 7 : index
    memref.store %t40, %t5[%t41] : memref<64xi13>
    %t42 = arith.constant 49 : i32 loc(#loc68)
    %t43 = arith.trunci %t42 : i32 to i13
    %t44 = arith.constant 8 : index
    memref.store %t43, %t5[%t44] : memref<64xi13>
    %t45 = arith.constant 69 : i32 loc(#loc69)
    %t46 = arith.trunci %t45 : i32 to i13
    %t47 = arith.constant 9 : index
    memref.store %t46, %t5[%t47] : memref<64xi13>
    %t48 = arith.constant 0 : i32 loc(#loc70)
    %t49 = arith.trunci %t48 : i32 to i13
    %t50 = arith.constant 10 : index
    memref.store %t49, %t5[%t50] : memref<64xi13>
    %t51 = arith.constant 0 : i32 loc(#loc71)
    %t52 = arith.trunci %t51 : i32 to i13
    %t53 = arith.constant 11 : index
    memref.store %t52, %t5[%t53] : memref<64xi13>
    %t54 = arith.constant 29 : i32 loc(#loc72)
    %t55 = arith.constant 0 : i32 loc(#loc73)
    %t56 = arith.subi %t55, %t54 : i32 loc(#loc73)
    %t57 = arith.trunci %t56 : i32 to i13
    %t58 = arith.constant 12 : index
    memref.store %t57, %t5[%t58] : memref<64xi13>
    %t59 = arith.constant 29 : i32 loc(#loc74)
    %t60 = arith.constant 0 : i32 loc(#loc75)
    %t61 = arith.subi %t60, %t59 : i32 loc(#loc75)
    %t62 = arith.trunci %t61 : i32 to i13
    %t63 = arith.constant 13 : index
    memref.store %t62, %t5[%t63] : memref<64xi13>
    %t64 = arith.constant 49 : i32 loc(#loc76)
    %t65 = arith.constant 0 : i32 loc(#loc77)
    %t66 = arith.subi %t65, %t64 : i32 loc(#loc77)
    %t67 = arith.trunci %t66 : i32 to i13
    %t68 = arith.constant 14 : index
    memref.store %t67, %t5[%t68] : memref<64xi13>
    %t69 = arith.constant 0 : i32 loc(#loc78)
    %t70 = arith.trunci %t69 : i32 to i13
    %t71 = arith.constant 15 : index
    memref.store %t70, %t5[%t71] : memref<64xi13>
    %t72 = arith.constant 89 : i32 loc(#loc79)
    %t73 = arith.trunci %t72 : i32 to i13
    %t74 = arith.constant 16 : index
    memref.store %t73, %t5[%t74] : memref<64xi13>
    %t75 = arith.constant 69 : i32 loc(#loc80)
    %t76 = arith.constant 0 : i32 loc(#loc81)
    %t77 = arith.subi %t76, %t75 : i32 loc(#loc81)
    %t78 = arith.trunci %t77 : i32 to i13
    %t79 = arith.constant 17 : index
    memref.store %t78, %t5[%t79] : memref<64xi13>
    %t80 = arith.constant 29 : i32 loc(#loc82)
    %t81 = arith.constant 0 : i32 loc(#loc83)
    %t82 = arith.subi %t81, %t80 : i32 loc(#loc83)
    %t83 = arith.trunci %t82 : i32 to i13
    %t84 = arith.constant 18 : index
    memref.store %t83, %t5[%t84] : memref<64xi13>
    %t85 = arith.constant 29 : i32 loc(#loc84)
    %t86 = arith.constant 0 : i32 loc(#loc85)
    %t87 = arith.subi %t86, %t85 : i32 loc(#loc85)
    %t88 = arith.trunci %t87 : i32 to i13
    %t89 = arith.constant 19 : index
    memref.store %t88, %t5[%t89] : memref<64xi13>
    %t90 = arith.constant 49 : i32 loc(#loc86)
    %t91 = arith.trunci %t90 : i32 to i13
    %t92 = arith.constant 20 : index
    memref.store %t91, %t5[%t92] : memref<64xi13>
    %t93 = arith.constant 0 : i32 loc(#loc87)
    %t94 = arith.trunci %t93 : i32 to i13
    %t95 = arith.constant 21 : index
    memref.store %t94, %t5[%t95] : memref<64xi13>
    %t96 = arith.constant 0 : i32 loc(#loc88)
    %t97 = arith.trunci %t96 : i32 to i13
    %t98 = arith.constant 22 : index
    memref.store %t97, %t5[%t98] : memref<64xi13>
    %t99 = arith.constant 0 : i32 loc(#loc89)
    %t100 = arith.trunci %t99 : i32 to i13
    %t101 = arith.constant 23 : index
    memref.store %t100, %t5[%t101] : memref<64xi13>
    %t102 = arith.constant 69 : i32 loc(#loc90)
    %t103 = arith.trunci %t102 : i32 to i13
    %t104 = arith.constant 24 : index
    memref.store %t103, %t5[%t104] : memref<64xi13>
    %t105 = arith.constant 69 : i32 loc(#loc91)
    %t106 = arith.constant 0 : i32 loc(#loc92)
    %t107 = arith.subi %t106, %t105 : i32 loc(#loc92)
    %t108 = arith.trunci %t107 : i32 to i13
    %t109 = arith.constant 25 : index
    memref.store %t108, %t5[%t109] : memref<64xi13>
    %t110 = arith.constant 0 : i32 loc(#loc93)
    %t111 = arith.trunci %t110 : i32 to i13
    %t112 = arith.constant 26 : index
    memref.store %t111, %t5[%t112] : memref<64xi13>
    %t113 = arith.constant 0 : i32 loc(#loc94)
    %t114 = arith.trunci %t113 : i32 to i13
    %t115 = arith.constant 27 : index
    memref.store %t114, %t5[%t115] : memref<64xi13>
    %t116 = arith.constant 0 : i32 loc(#loc95)
    %t117 = arith.trunci %t116 : i32 to i13
    %t118 = arith.constant 28 : index
    memref.store %t117, %t5[%t118] : memref<64xi13>
    %t119 = arith.constant 0 : i32 loc(#loc96)
    %t120 = arith.trunci %t119 : i32 to i13
    %t121 = arith.constant 29 : index
    memref.store %t120, %t5[%t121] : memref<64xi13>
    %t122 = arith.constant 0 : i32 loc(#loc97)
    %t123 = arith.trunci %t122 : i32 to i13
    %t124 = arith.constant 30 : index
    memref.store %t123, %t5[%t124] : memref<64xi13>
    %t125 = arith.constant 0 : i32 loc(#loc98)
    %t126 = arith.trunci %t125 : i32 to i13
    %t127 = arith.constant 31 : index
    memref.store %t126, %t5[%t127] : memref<64xi13>
    %t128 = arith.constant 69 : i32 loc(#loc99)
    %t129 = arith.trunci %t128 : i32 to i13
    %t130 = arith.constant 32 : index
    memref.store %t129, %t5[%t130] : memref<64xi13>
    %t131 = arith.constant 0 : i32 loc(#loc100)
    %t132 = arith.trunci %t131 : i32 to i13
    %t133 = arith.constant 33 : index
    memref.store %t132, %t5[%t133] : memref<64xi13>
    %t134 = arith.constant 0 : i32 loc(#loc101)
    %t135 = arith.trunci %t134 : i32 to i13
    %t136 = arith.constant 34 : index
    memref.store %t135, %t5[%t136] : memref<64xi13>
    %t137 = arith.constant 29 : i32 loc(#loc102)
    %t138 = arith.constant 0 : i32 loc(#loc103)
    %t139 = arith.subi %t138, %t137 : i32 loc(#loc103)
    %t140 = arith.trunci %t139 : i32 to i13
    %t141 = arith.constant 35 : index
    memref.store %t140, %t5[%t141] : memref<64xi13>
    %t142 = arith.constant 29 : i32 loc(#loc104)
    %t143 = arith.constant 0 : i32 loc(#loc105)
    %t144 = arith.subi %t143, %t142 : i32 loc(#loc105)
    %t145 = arith.trunci %t144 : i32 to i13
    %t146 = arith.constant 36 : index
    memref.store %t145, %t5[%t146] : memref<64xi13>
    %t147 = arith.constant 0 : i32 loc(#loc106)
    %t148 = arith.trunci %t147 : i32 to i13
    %t149 = arith.constant 37 : index
    memref.store %t148, %t5[%t149] : memref<64xi13>
    %t150 = arith.constant 0 : i32 loc(#loc107)
    %t151 = arith.trunci %t150 : i32 to i13
    %t152 = arith.constant 38 : index
    memref.store %t151, %t5[%t152] : memref<64xi13>
    %t153 = arith.constant 0 : i32 loc(#loc108)
    %t154 = arith.trunci %t153 : i32 to i13
    %t155 = arith.constant 39 : index
    memref.store %t154, %t5[%t155] : memref<64xi13>
    %t156 = arith.constant 0 : i32 loc(#loc109)
    %t157 = arith.trunci %t156 : i32 to i13
    %t158 = arith.constant 40 : index
    memref.store %t157, %t5[%t158] : memref<64xi13>
    %t159 = arith.constant 0 : i32 loc(#loc110)
    %t160 = arith.trunci %t159 : i32 to i13
    %t161 = arith.constant 41 : index
    memref.store %t160, %t5[%t161] : memref<64xi13>
    %t162 = arith.constant 0 : i32 loc(#loc111)
    %t163 = arith.trunci %t162 : i32 to i13
    %t164 = arith.constant 42 : index
    memref.store %t163, %t5[%t164] : memref<64xi13>
    %t165 = arith.constant 29 : i32 loc(#loc112)
    %t166 = arith.constant 0 : i32 loc(#loc113)
    %t167 = arith.subi %t166, %t165 : i32 loc(#loc113)
    %t168 = arith.trunci %t167 : i32 to i13
    %t169 = arith.constant 43 : index
    memref.store %t168, %t5[%t169] : memref<64xi13>
    %t170 = arith.constant 0 : i32 loc(#loc114)
    %t171 = arith.trunci %t170 : i32 to i13
    %t172 = arith.constant 44 : index
    memref.store %t171, %t5[%t172] : memref<64xi13>
    %t173 = arith.constant 0 : i32 loc(#loc115)
    %t174 = arith.trunci %t173 : i32 to i13
    %t175 = arith.constant 45 : index
    memref.store %t174, %t5[%t175] : memref<64xi13>
    %t176 = arith.constant 0 : i32 loc(#loc116)
    %t177 = arith.trunci %t176 : i32 to i13
    %t178 = arith.constant 46 : index
    memref.store %t177, %t5[%t178] : memref<64xi13>
    %t179 = arith.constant 0 : i32 loc(#loc117)
    %t180 = arith.trunci %t179 : i32 to i13
    %t181 = arith.constant 47 : index
    memref.store %t180, %t5[%t181] : memref<64xi13>
    %t182 = arith.constant 0 : i32 loc(#loc118)
    %t183 = arith.trunci %t182 : i32 to i13
    %t184 = arith.constant 48 : index
    memref.store %t183, %t5[%t184] : memref<64xi13>
    %t185 = arith.constant 0 : i32 loc(#loc119)
    %t186 = arith.trunci %t185 : i32 to i13
    %t187 = arith.constant 49 : index
    memref.store %t186, %t5[%t187] : memref<64xi13>
    %t188 = arith.constant 0 : i32 loc(#loc120)
    %t189 = arith.trunci %t188 : i32 to i13
    %t190 = arith.constant 50 : index
    memref.store %t189, %t5[%t190] : memref<64xi13>
    %t191 = arith.constant 0 : i32 loc(#loc121)
    %t192 = arith.trunci %t191 : i32 to i13
    %t193 = arith.constant 51 : index
    memref.store %t192, %t5[%t193] : memref<64xi13>
    %t194 = arith.constant 0 : i32 loc(#loc122)
    %t195 = arith.trunci %t194 : i32 to i13
    %t196 = arith.constant 52 : index
    memref.store %t195, %t5[%t196] : memref<64xi13>
    %t197 = arith.constant 0 : i32 loc(#loc123)
    %t198 = arith.trunci %t197 : i32 to i13
    %t199 = arith.constant 53 : index
    memref.store %t198, %t5[%t199] : memref<64xi13>
    %t200 = arith.constant 0 : i32 loc(#loc124)
    %t201 = arith.trunci %t200 : i32 to i13
    %t202 = arith.constant 54 : index
    memref.store %t201, %t5[%t202] : memref<64xi13>
    %t203 = arith.constant 0 : i32 loc(#loc125)
    %t204 = arith.trunci %t203 : i32 to i13
    %t205 = arith.constant 55 : index
    memref.store %t204, %t5[%t205] : memref<64xi13>
    %t206 = arith.constant 0 : i32 loc(#loc126)
    %t207 = arith.trunci %t206 : i32 to i13
    %t208 = arith.constant 56 : index
    memref.store %t207, %t5[%t208] : memref<64xi13>
    %t209 = arith.constant 0 : i32 loc(#loc127)
    %t210 = arith.trunci %t209 : i32 to i13
    %t211 = arith.constant 57 : index
    memref.store %t210, %t5[%t211] : memref<64xi13>
    %t212 = arith.constant 0 : i32 loc(#loc128)
    %t213 = arith.trunci %t212 : i32 to i13
    %t214 = arith.constant 58 : index
    memref.store %t213, %t5[%t214] : memref<64xi13>
    %t215 = arith.constant 0 : i32 loc(#loc129)
    %t216 = arith.trunci %t215 : i32 to i13
    %t217 = arith.constant 59 : index
    memref.store %t216, %t5[%t217] : memref<64xi13>
    %t218 = arith.constant 0 : i32 loc(#loc130)
    %t219 = arith.trunci %t218 : i32 to i13
    %t220 = arith.constant 60 : index
    memref.store %t219, %t5[%t220] : memref<64xi13>
    %t221 = arith.constant 0 : i32 loc(#loc131)
    %t222 = arith.trunci %t221 : i32 to i13
    %t223 = arith.constant 61 : index
    memref.store %t222, %t5[%t223] : memref<64xi13>
    %t224 = arith.constant 0 : i32 loc(#loc132)
    %t225 = arith.trunci %t224 : i32 to i13
    %t226 = arith.constant 62 : index
    memref.store %t225, %t5[%t226] : memref<64xi13>
    %t227 = arith.constant 0 : i32 loc(#loc133)
    %t228 = arith.trunci %t227 : i32 to i13
    %t229 = arith.constant 63 : index
    memref.store %t228, %t5[%t229] : memref<64xi13>
    %t230 = cal.create_state_var<i32> : !cal.state_ref<i32>
    %t231 = arith.constant 0 : i32 loc(#loc134)
    cal.set(%t230: !cal.state_ref<i32>, %t231: i32)
    cal.action "$untagged0" priority=0 {
      cal.predicate {
        %t232 = cal.get(%t230: !cal.state_ref<i32>) : i32
        %t233 = arith.cmpi ult, %t232, %limit : i32 loc(#loc136)
        cal.predicate_result %t233 : i1
      }
      %t234 = cal.get(%t230: !cal.state_ref<i32>) : i32
      %t235 = arith.constant 1 : i32 loc(#loc137)
      %t236 = arith.addi %t234, %t235 : i32 loc(#loc138)
      cal.set(%t230: !cal.state_ref<i32>, %t236: i32)
      %t237 = arith.constant 64 : i32 loc(#loc139)
      %t238 = arith.index_cast %t237 : i32 to index
      %t239 = arith.constant 0 : index
      %t240 = arith.constant 1 : index
      scf.for %t241 = %t239 to %t238 step %t240 {
        %t242 = cal.get(%t4: !cal.state_ref<memref<64xi13>>) : memref<64xi13>
        %t243 = memref.load %t242[%t241] : memref<64xi13>
        fifo.push(%OUT: !fifo.input_port<i13>, %t243: i13)
        scf.yield
      }
      %t244 = arith.constant 0 : i1
      fifo.push(%SIGNED: !fifo.input_port<i1>, %t244: i1)
    } loc(#loc135)
  } loc(#loc140)
  cal.network @idct__IDCT2D_23002(%OUT_SZ: i32, %PIX_SZ: i32, %SIN_SZ: i32)
    in_names ["IN", "SIGNED"]
    out_names ["OUT"]
    ports_in(%IN: !fifo.output_port<i13>, %SIGNED: !fifo.output_port<i1>)
    ports_out(%OUT: !fifo.input_port<i32>)
  {
    %scale = cal.instantiate @idct__Scale__v__SIN_SZ_13__SOUT_SZ_32 (%SIN_SZ, %OUT_SZ : i32, i32) instance("scale") {cal.instance_name = "scale", cal.class_name = "@idct__Scale__v__SIN_SZ_13__SOUT_SZ_32"} : !cal.instance<@idct__Scale__v__SIN_SZ_13__SOUT_SZ_32>
    %t0 = arith.constant 32 : i32 loc(#loc141)
    %t1 = arith.constant 32 : i32 loc(#loc142)
    %row = cal.instantiate @idct__Scaled_1d_idct__v__IN_SZ_32__OUT_SZ_32 (%t0, %t1 : i32, i32) instance("row") {cal.instance_name = "row", cal.class_name = "@idct__Scaled_1d_idct__v__IN_SZ_32__OUT_SZ_32"} : !cal.instance<@idct__Scaled_1d_idct__v__IN_SZ_32__OUT_SZ_32>
    %t2 = arith.constant 32 : i32 loc(#loc143)
    %t3 = arith.constant 32 : i32 loc(#loc144)
    %column = cal.instantiate @idct__Scaled_1d_idct__v__IN_SZ_32__OUT_SZ_32 (%t2, %t3 : i32, i32) instance("column") {cal.instance_name = "column", cal.class_name = "@idct__Scaled_1d_idct__v__IN_SZ_32__OUT_SZ_32"} : !cal.instance<@idct__Scaled_1d_idct__v__IN_SZ_32__OUT_SZ_32>
    %transpose = cal.instantiate @idct__Transpose instance("transpose") {cal.instance_name = "transpose", cal.class_name = "@idct__Transpose"} : !cal.instance<@idct__Transpose>
    %retranspose = cal.instantiate @idct__Transpose instance("retranspose") {cal.instance_name = "retranspose", cal.class_name = "@idct__Transpose"} : !cal.instance<@idct__Transpose>
    %shift = cal.instantiate @idct__Rightshift instance("shift") {cal.instance_name = "shift", cal.class_name = "@idct__Rightshift"} : !cal.instance<@idct__Rightshift>
    %clip = cal.instantiate @idct__Clip__v__isz_32__osz_32 (%OUT_SZ, %PIX_SZ : i32, i32) instance("clip") {cal.instance_name = "clip", cal.class_name = "@idct__Clip__v__isz_32__osz_32"} : !cal.instance<@idct__Clip__v__isz_32__osz_32>
    cal.connect %SIGNED : !fifo.output_port<i1> "out" -> %clip : !cal.instance<@idct__Clip__v__isz_32__osz_32> "SIGNED" capacity(4096)
    cal.connect %IN : !fifo.output_port<i13> "out" -> %scale : !cal.instance<@idct__Scale__v__SIN_SZ_13__SOUT_SZ_32> "IN" capacity(4096)
    cal.connect %scale : !cal.instance<@idct__Scale__v__SIN_SZ_13__SOUT_SZ_32> "OUT" -> %row : !cal.instance<@idct__Scaled_1d_idct__v__IN_SZ_32__OUT_SZ_32> "IN" capacity(4096)
    cal.connect %row : !cal.instance<@idct__Scaled_1d_idct__v__IN_SZ_32__OUT_SZ_32> "OUT" -> %transpose : !cal.instance<@idct__Transpose> "IN" capacity(4096)
    cal.connect %transpose : !cal.instance<@idct__Transpose> "OUT" -> %column : !cal.instance<@idct__Scaled_1d_idct__v__IN_SZ_32__OUT_SZ_32> "IN" capacity(4096)
    cal.connect %column : !cal.instance<@idct__Scaled_1d_idct__v__IN_SZ_32__OUT_SZ_32> "OUT" -> %retranspose : !cal.instance<@idct__Transpose> "IN" capacity(4096)
    cal.connect %retranspose : !cal.instance<@idct__Transpose> "OUT" -> %shift : !cal.instance<@idct__Rightshift> "IN" capacity(4096)
    cal.connect %shift : !cal.instance<@idct__Rightshift> "OUT" -> %clip : !cal.instance<@idct__Clip__v__isz_32__osz_32> "I" capacity(4096)
    cal.connect %clip : !cal.instance<@idct__Clip__v__isz_32__osz_32> "O" -> %OUT : !fifo.input_port<i32> "in" capacity(4096)
  }
  cal.actor @idct__Sink__v__PIX_SZ_32__limit_10000000(%PIX_SZ: i32, %limit: i32)
    in_names ["IN"]
    ports_in(%IN: !fifo.output_port<i32>)
  {
    %t0 = cal.create_state_var<i32> : !cal.state_ref<i32>
    %t1 = arith.constant 0 : i32 loc(#loc145)
    cal.set(%t0: !cal.state_ref<i32>, %t1: i32)
    cal.action "$untagged0" priority=0 {
      %t2 = memref.alloca() : memref<64xi32>
      %t3 = arith.constant 64 : index
      %t4 = arith.constant 0 : index
      %t5 = arith.constant 1 : index
      scf.for %t6 = %t4 to %t3 step %t5 {
        %t7 = fifo.pop(%IN: !fifo.output_port<i32> ) : i32
        memref.store %t7, %t2[%t6] : memref<64xi32>
        scf.yield
      }
      %t8 = cal.get(%t0: !cal.state_ref<i32>) : i32
      %t9 = arith.constant 1 : i32 loc(#loc147)
      %t10 = arith.addi %t8, %t9 : i32 loc(#loc148)
      cal.set(%t0: !cal.state_ref<i32>, %t10: i32)
      %t11 = cal.get(%t0: !cal.state_ref<i32>) : i32
      %t12 = arith.cmpi eq, %t11, %limit : i32 loc(#loc149)
      %t13 = scf.if %t12 -> i1 {
        %t14 = arith.constant 0 : i32 loc(#loc150)
        %t15 = arith.constant 63 : i32 loc(#loc151)
        %t16 = arith.index_cast %t14 : i32 to index
        %t17 = arith.index_cast %t15 : i32 to index
        %t18 = arith.constant 1 : index
        %t19 = arith.addi %t17, %t18 : index
        scf.for %t20 = %t16 to %t19 step %t18 {
          %t21 = memref.load %t2[%t20] : memref<64xi32> loc(#loc152)
          fifo.print("%i : %i\n\00", %t20, %t21) : (index, i32)
          scf.yield
        }
        %t22 = arith.constant 1 : i1
        scf.yield %t22 : i1
      } else {
        %t23 = arith.constant 0 : i1
        scf.yield %t23 : i1
      }
    } loc(#loc146)
  } loc(#loc153)
  cal.actor @idct__Scale__v__SIN_SZ_dyn__SOUT_SZ_dyn(%SIN_SZ: i32, %SOUT_SZ: i32)
    in_names ["IN"]
    out_names ["OUT"]
    ports_in(%IN: !fifo.output_port<i32>)
    ports_out(%OUT: !fifo.input_port<i32>)
  {
    %t0 = cal.create_state_var<i32> : !cal.state_ref<i32>
    %t1 = arith.constant 1024 : i32 loc(#loc154)
    cal.set(%t0: !cal.state_ref<i32>, %t1: i32)
    %t2 = cal.create_state_var<i32> : !cal.state_ref<i32>
    %t3 = arith.constant 1138 : i32 loc(#loc155)
    cal.set(%t2: !cal.state_ref<i32>, %t3: i32)
    %t4 = cal.create_state_var<i32> : !cal.state_ref<i32>
    %t5 = arith.constant 1730 : i32 loc(#loc156)
    cal.set(%t4: !cal.state_ref<i32>, %t5: i32)
    %t6 = cal.create_state_var<i32> : !cal.state_ref<i32>
    %t7 = arith.constant 1609 : i32 loc(#loc157)
    cal.set(%t6: !cal.state_ref<i32>, %t7: i32)
    %t8 = cal.create_state_var<i32> : !cal.state_ref<i32>
    %t9 = arith.constant 1264 : i32 loc(#loc158)
    cal.set(%t8: !cal.state_ref<i32>, %t9: i32)
    %t10 = cal.create_state_var<i32> : !cal.state_ref<i32>
    %t11 = arith.constant 1922 : i32 loc(#loc159)
    cal.set(%t10: !cal.state_ref<i32>, %t11: i32)
    %t12 = cal.create_state_var<i32> : !cal.state_ref<i32>
    %t13 = arith.constant 1788 : i32 loc(#loc160)
    cal.set(%t12: !cal.state_ref<i32>, %t13: i32)
    %t14 = cal.create_state_var<i32> : !cal.state_ref<i32>
    %t15 = arith.constant 2923 : i32 loc(#loc161)
    cal.set(%t14: !cal.state_ref<i32>, %t15: i32)
    %t16 = cal.create_state_var<i32> : !cal.state_ref<i32>
    %t17 = arith.constant 2718 : i32 loc(#loc162)
    cal.set(%t16: !cal.state_ref<i32>, %t17: i32)
    %t18 = cal.create_state_var<i32> : !cal.state_ref<i32>
    %t19 = arith.constant 2528 : i32 loc(#loc163)
    cal.set(%t18: !cal.state_ref<i32>, %t19: i32)
    %t20 = cal.create_state_var<memref<64xi32>> : !cal.state_ref<memref<64xi32>>
    %t21 = cal.get(%t20: !cal.state_ref<memref<64xi32>>) : memref<64xi32>
    %t22 = cal.get(%t0: !cal.state_ref<i32>) : i32
    %t23 = arith.constant 0 : index
    memref.store %t22, %t21[%t23] : memref<64xi32>
    %t24 = cal.get(%t2: !cal.state_ref<i32>) : i32
    %t25 = arith.constant 1 : index
    memref.store %t24, %t21[%t25] : memref<64xi32>
    %t26 = cal.get(%t4: !cal.state_ref<i32>) : i32
    %t27 = arith.constant 2 : index
    memref.store %t26, %t21[%t27] : memref<64xi32>
    %t28 = cal.get(%t6: !cal.state_ref<i32>) : i32
    %t29 = arith.constant 3 : index
    memref.store %t28, %t21[%t29] : memref<64xi32>
    %t30 = cal.get(%t0: !cal.state_ref<i32>) : i32
    %t31 = arith.constant 4 : index
    memref.store %t30, %t21[%t31] : memref<64xi32>
    %t32 = cal.get(%t6: !cal.state_ref<i32>) : i32
    %t33 = arith.constant 5 : index
    memref.store %t32, %t21[%t33] : memref<64xi32>
    %t34 = cal.get(%t4: !cal.state_ref<i32>) : i32
    %t35 = arith.constant 6 : index
    memref.store %t34, %t21[%t35] : memref<64xi32>
    %t36 = cal.get(%t2: !cal.state_ref<i32>) : i32
    %t37 = arith.constant 7 : index
    memref.store %t36, %t21[%t37] : memref<64xi32>
    %t38 = cal.get(%t2: !cal.state_ref<i32>) : i32
    %t39 = arith.constant 8 : index
    memref.store %t38, %t21[%t39] : memref<64xi32>
    %t40 = cal.get(%t8: !cal.state_ref<i32>) : i32
    %t41 = arith.constant 9 : index
    memref.store %t40, %t21[%t41] : memref<64xi32>
    %t42 = cal.get(%t10: !cal.state_ref<i32>) : i32
    %t43 = arith.constant 10 : index
    memref.store %t42, %t21[%t43] : memref<64xi32>
    %t44 = cal.get(%t12: !cal.state_ref<i32>) : i32
    %t45 = arith.constant 11 : index
    memref.store %t44, %t21[%t45] : memref<64xi32>
    %t46 = cal.get(%t2: !cal.state_ref<i32>) : i32
    %t47 = arith.constant 12 : index
    memref.store %t46, %t21[%t47] : memref<64xi32>
    %t48 = cal.get(%t12: !cal.state_ref<i32>) : i32
    %t49 = arith.constant 13 : index
    memref.store %t48, %t21[%t49] : memref<64xi32>
    %t50 = cal.get(%t10: !cal.state_ref<i32>) : i32
    %t51 = arith.constant 14 : index
    memref.store %t50, %t21[%t51] : memref<64xi32>
    %t52 = cal.get(%t8: !cal.state_ref<i32>) : i32
    %t53 = arith.constant 15 : index
    memref.store %t52, %t21[%t53] : memref<64xi32>
    %t54 = cal.get(%t4: !cal.state_ref<i32>) : i32
    %t55 = arith.constant 16 : index
    memref.store %t54, %t21[%t55] : memref<64xi32>
    %t56 = cal.get(%t10: !cal.state_ref<i32>) : i32
    %t57 = arith.constant 17 : index
    memref.store %t56, %t21[%t57] : memref<64xi32>
    %t58 = cal.get(%t14: !cal.state_ref<i32>) : i32
    %t59 = arith.constant 18 : index
    memref.store %t58, %t21[%t59] : memref<64xi32>
    %t60 = cal.get(%t16: !cal.state_ref<i32>) : i32
    %t61 = arith.constant 19 : index
    memref.store %t60, %t21[%t61] : memref<64xi32>
    %t62 = cal.get(%t4: !cal.state_ref<i32>) : i32
    %t63 = arith.constant 20 : index
    memref.store %t62, %t21[%t63] : memref<64xi32>
    %t64 = cal.get(%t16: !cal.state_ref<i32>) : i32
    %t65 = arith.constant 21 : index
    memref.store %t64, %t21[%t65] : memref<64xi32>
    %t66 = cal.get(%t14: !cal.state_ref<i32>) : i32
    %t67 = arith.constant 22 : index
    memref.store %t66, %t21[%t67] : memref<64xi32>
    %t68 = cal.get(%t10: !cal.state_ref<i32>) : i32
    %t69 = arith.constant 23 : index
    memref.store %t68, %t21[%t69] : memref<64xi32>
    %t70 = cal.get(%t6: !cal.state_ref<i32>) : i32
    %t71 = arith.constant 24 : index
    memref.store %t70, %t21[%t71] : memref<64xi32>
    %t72 = cal.get(%t12: !cal.state_ref<i32>) : i32
    %t73 = arith.constant 25 : index
    memref.store %t72, %t21[%t73] : memref<64xi32>
    %t74 = cal.get(%t16: !cal.state_ref<i32>) : i32
    %t75 = arith.constant 26 : index
    memref.store %t74, %t21[%t75] : memref<64xi32>
    %t76 = cal.get(%t18: !cal.state_ref<i32>) : i32
    %t77 = arith.constant 27 : index
    memref.store %t76, %t21[%t77] : memref<64xi32>
    %t78 = cal.get(%t6: !cal.state_ref<i32>) : i32
    %t79 = arith.constant 28 : index
    memref.store %t78, %t21[%t79] : memref<64xi32>
    %t80 = cal.get(%t18: !cal.state_ref<i32>) : i32
    %t81 = arith.constant 29 : index
    memref.store %t80, %t21[%t81] : memref<64xi32>
    %t82 = cal.get(%t16: !cal.state_ref<i32>) : i32
    %t83 = arith.constant 30 : index
    memref.store %t82, %t21[%t83] : memref<64xi32>
    %t84 = cal.get(%t12: !cal.state_ref<i32>) : i32
    %t85 = arith.constant 31 : index
    memref.store %t84, %t21[%t85] : memref<64xi32>
    %t86 = cal.get(%t0: !cal.state_ref<i32>) : i32
    %t87 = arith.constant 32 : index
    memref.store %t86, %t21[%t87] : memref<64xi32>
    %t88 = cal.get(%t2: !cal.state_ref<i32>) : i32
    %t89 = arith.constant 33 : index
    memref.store %t88, %t21[%t89] : memref<64xi32>
    %t90 = cal.get(%t4: !cal.state_ref<i32>) : i32
    %t91 = arith.constant 34 : index
    memref.store %t90, %t21[%t91] : memref<64xi32>
    %t92 = cal.get(%t6: !cal.state_ref<i32>) : i32
    %t93 = arith.constant 35 : index
    memref.store %t92, %t21[%t93] : memref<64xi32>
    %t94 = cal.get(%t0: !cal.state_ref<i32>) : i32
    %t95 = arith.constant 36 : index
    memref.store %t94, %t21[%t95] : memref<64xi32>
    %t96 = cal.get(%t6: !cal.state_ref<i32>) : i32
    %t97 = arith.constant 37 : index
    memref.store %t96, %t21[%t97] : memref<64xi32>
    %t98 = cal.get(%t4: !cal.state_ref<i32>) : i32
    %t99 = arith.constant 38 : index
    memref.store %t98, %t21[%t99] : memref<64xi32>
    %t100 = cal.get(%t2: !cal.state_ref<i32>) : i32
    %t101 = arith.constant 39 : index
    memref.store %t100, %t21[%t101] : memref<64xi32>
    %t102 = cal.get(%t6: !cal.state_ref<i32>) : i32
    %t103 = arith.constant 40 : index
    memref.store %t102, %t21[%t103] : memref<64xi32>
    %t104 = cal.get(%t12: !cal.state_ref<i32>) : i32
    %t105 = arith.constant 41 : index
    memref.store %t104, %t21[%t105] : memref<64xi32>
    %t106 = cal.get(%t16: !cal.state_ref<i32>) : i32
    %t107 = arith.constant 42 : index
    memref.store %t106, %t21[%t107] : memref<64xi32>
    %t108 = cal.get(%t18: !cal.state_ref<i32>) : i32
    %t109 = arith.constant 43 : index
    memref.store %t108, %t21[%t109] : memref<64xi32>
    %t110 = cal.get(%t6: !cal.state_ref<i32>) : i32
    %t111 = arith.constant 44 : index
    memref.store %t110, %t21[%t111] : memref<64xi32>
    %t112 = cal.get(%t18: !cal.state_ref<i32>) : i32
    %t113 = arith.constant 45 : index
    memref.store %t112, %t21[%t113] : memref<64xi32>
    %t114 = cal.get(%t16: !cal.state_ref<i32>) : i32
    %t115 = arith.constant 46 : index
    memref.store %t114, %t21[%t115] : memref<64xi32>
    %t116 = cal.get(%t12: !cal.state_ref<i32>) : i32
    %t117 = arith.constant 47 : index
    memref.store %t116, %t21[%t117] : memref<64xi32>
    %t118 = cal.get(%t4: !cal.state_ref<i32>) : i32
    %t119 = arith.constant 48 : index
    memref.store %t118, %t21[%t119] : memref<64xi32>
    %t120 = cal.get(%t10: !cal.state_ref<i32>) : i32
    %t121 = arith.constant 49 : index
    memref.store %t120, %t21[%t121] : memref<64xi32>
    %t122 = cal.get(%t14: !cal.state_ref<i32>) : i32
    %t123 = arith.constant 50 : index
    memref.store %t122, %t21[%t123] : memref<64xi32>
    %t124 = cal.get(%t16: !cal.state_ref<i32>) : i32
    %t125 = arith.constant 51 : index
    memref.store %t124, %t21[%t125] : memref<64xi32>
    %t126 = cal.get(%t4: !cal.state_ref<i32>) : i32
    %t127 = arith.constant 52 : index
    memref.store %t126, %t21[%t127] : memref<64xi32>
    %t128 = cal.get(%t16: !cal.state_ref<i32>) : i32
    %t129 = arith.constant 53 : index
    memref.store %t128, %t21[%t129] : memref<64xi32>
    %t130 = cal.get(%t14: !cal.state_ref<i32>) : i32
    %t131 = arith.constant 54 : index
    memref.store %t130, %t21[%t131] : memref<64xi32>
    %t132 = cal.get(%t10: !cal.state_ref<i32>) : i32
    %t133 = arith.constant 55 : index
    memref.store %t132, %t21[%t133] : memref<64xi32>
    %t134 = cal.get(%t2: !cal.state_ref<i32>) : i32
    %t135 = arith.constant 56 : index
    memref.store %t134, %t21[%t135] : memref<64xi32>
    %t136 = cal.get(%t8: !cal.state_ref<i32>) : i32
    %t137 = arith.constant 57 : index
    memref.store %t136, %t21[%t137] : memref<64xi32>
    %t138 = cal.get(%t10: !cal.state_ref<i32>) : i32
    %t139 = arith.constant 58 : index
    memref.store %t138, %t21[%t139] : memref<64xi32>
    %t140 = cal.get(%t12: !cal.state_ref<i32>) : i32
    %t141 = arith.constant 59 : index
    memref.store %t140, %t21[%t141] : memref<64xi32>
    %t142 = cal.get(%t2: !cal.state_ref<i32>) : i32
    %t143 = arith.constant 60 : index
    memref.store %t142, %t21[%t143] : memref<64xi32>
    %t144 = cal.get(%t12: !cal.state_ref<i32>) : i32
    %t145 = arith.constant 61 : index
    memref.store %t144, %t21[%t145] : memref<64xi32>
    %t146 = cal.get(%t10: !cal.state_ref<i32>) : i32
    %t147 = arith.constant 62 : index
    memref.store %t146, %t21[%t147] : memref<64xi32>
    %t148 = cal.get(%t8: !cal.state_ref<i32>) : i32
    %t149 = arith.constant 63 : index
    memref.store %t148, %t21[%t149] : memref<64xi32>
    cal.action "scale" priority=0 {
      %t150 = memref.alloca() : memref<64xi32>
      %t151 = memref.alloca() : memref<64xi32>
      %t152 = arith.constant 64 : index
      %t153 = arith.constant 0 : index
      %t154 = arith.constant 1 : index
      scf.for %t155 = %t153 to %t152 step %t154 {
        %t156 = fifo.pop(%IN: !fifo.output_port<i32> ) : i32
        memref.store %t156, %t151[%t155] : memref<64xi32>
        scf.yield
      }
      %t157 = arith.constant 0 : i32 loc(#loc165)
      %t158 = arith.constant 63 : i32 loc(#loc166)
      %t159 = arith.index_cast %t157 : i32 to index
      %t160 = arith.index_cast %t158 : i32 to index
      %t161 = arith.constant 1 : index
      %t162 = arith.addi %t160, %t161 : index
      %t163 = arith.constant 1 : index
      scf.for %t164 = %t159 to %t162 step %t163 {
        %t165 = arith.index_cast %t164 : index to i32
        %t166 = arith.index_cast %t165 : i32 to index
        %t167 = memref.load %t151[%t166] : memref<64xi32> loc(#loc167)
        %t168 = cal.get(%t20: !cal.state_ref<memref<64xi32>>) : memref<64xi32>
        %t169 = arith.index_cast %t165 : i32 to index
        %t170 = memref.load %t168[%t169] : memref<64xi32> loc(#loc168)
        %t171 = arith.muli %t167, %t170 : i32 loc(#loc167)
        %t172 = arith.subi %t164, %t159 : index
        memref.store %t171, %t150[%t172] : memref<64xi32>
        scf.yield
      }
      %t173 = arith.constant 0 : i32 loc(#loc169)
      %t174 = arith.index_cast %t173 : i32 to index
      %t175 = arith.constant 0 : i32 loc(#loc170)
      %t176 = arith.index_cast %t175 : i32 to index
      %t177 = memref.load %t150[%t176] : memref<64xi32> loc(#loc171)
      %t178 = arith.constant 1 : i32 loc(#loc172)
      %t179 = arith.constant 12 : i32 loc(#loc173)
      %t180 = arith.shli %t178, %t179 : i32 loc(#loc174)
      %t181 = arith.addi %t177, %t180 : i32 loc(#loc171)
      memref.store %t181, %t150[%t174] : memref<64xi32>
      %t182 = arith.constant 64 : i32 loc(#loc175)
      %t183 = arith.index_cast %t182 : i32 to index
      %t184 = arith.constant 0 : index
      %t185 = arith.constant 1 : index
      scf.for %t186 = %t184 to %t183 step %t185 {
        %t187 = memref.load %t150[%t186] : memref<64xi32>
        fifo.push(%OUT: !fifo.input_port<i32>, %t187: i32)
        scf.yield
      }
    } loc(#loc164)
  } loc(#loc176)
  cal.actor @idct__Scaled_1d_idct__v__IN_SZ_32__OUT_SZ_32(%IN_SZ: i32, %OUT_SZ: i32)
    in_names ["IN"]
    out_names ["OUT"]
    ports_in(%IN: !fifo.output_port<i32>)
    ports_out(%OUT: !fifo.input_port<i32>)
  {
    cal.action "idct1d" priority=0 {
      %t0 = arith.constant 0 : i32
      %t1 = arith.constant 0 : i32
      %t2 = memref.alloca() : memref<8xi32>
      %t3 = memref.alloca() : memref<8xi32>
      %t4 = arith.constant 0 : i32
      %t5 = arith.constant 0 : i32
      %t6 = arith.constant 0 : i32
      %t7 = arith.constant 0 : i32
      %t8 = memref.alloca() : memref<8xi32>
      %t9 = arith.constant 8 : index
      %t10 = arith.constant 0 : index
      %t11 = arith.constant 1 : index
      scf.for %t12 = %t10 to %t9 step %t11 {
        %t13 = fifo.pop(%IN: !fifo.output_port<i32> ) : i32
        memref.store %t13, %t8[%t12] : memref<8xi32>
        scf.yield
      }
      memref.copy %t8, %t2 : memref<8xi32> to memref<8xi32>
      %t14 = arith.constant 1 : i32 loc(#loc178)
      %t15 = arith.index_cast %t14 : i32 to index
      %t16 = memref.load %t2[%t15] : memref<8xi32> loc(#loc179)
      %t17 = arith.constant 7 : i32 loc(#loc180)
      %t18 = arith.index_cast %t17 : i32 to index
      %t19 = memref.load %t2[%t18] : memref<8xi32> loc(#loc181)
      %t20 = arith.addi %t16, %t19 : i32 loc(#loc179)
      %t21 = arith.constant 1 : i32 loc(#loc182)
      %t22 = arith.index_cast %t21 : i32 to index
      %t23 = memref.load %t2[%t22] : memref<8xi32> loc(#loc183)
      %t24 = arith.constant 7 : i32 loc(#loc184)
      %t25 = arith.index_cast %t24 : i32 to index
      %t26 = memref.load %t2[%t25] : memref<8xi32> loc(#loc185)
      %t27 = arith.subi %t23, %t26 : i32 loc(#loc183)
      %t28 = arith.constant 1 : i32 loc(#loc186)
      %t29 = arith.index_cast %t28 : i32 to index
      %t30 = arith.constant 3 : i32 loc(#loc187)
      %t31 = arith.index_cast %t30 : i32 to index
      %t32 = memref.load %t2[%t31] : memref<8xi32> loc(#loc188)
      %t33 = arith.addi %t20, %t32 : i32 loc(#loc189)
      memref.store %t33, %t2[%t29] : memref<8xi32>
      %t34 = arith.constant 3 : i32 loc(#loc190)
      %t35 = arith.index_cast %t34 : i32 to index
      %t36 = arith.constant 3 : i32 loc(#loc191)
      %t37 = arith.index_cast %t36 : i32 to index
      %t38 = memref.load %t2[%t37] : memref<8xi32> loc(#loc192)
      %t39 = arith.subi %t20, %t38 : i32 loc(#loc193)
      memref.store %t39, %t2[%t35] : memref<8xi32>
      %t40 = arith.constant 7 : i32 loc(#loc194)
      %t41 = arith.index_cast %t40 : i32 to index
      %t42 = arith.constant 5 : i32 loc(#loc195)
      %t43 = arith.index_cast %t42 : i32 to index
      %t44 = memref.load %t2[%t43] : memref<8xi32> loc(#loc196)
      %t45 = arith.addi %t27, %t44 : i32 loc(#loc197)
      memref.store %t45, %t2[%t41] : memref<8xi32>
      %t46 = arith.constant 5 : i32 loc(#loc198)
      %t47 = arith.index_cast %t46 : i32 to index
      %t48 = arith.constant 5 : i32 loc(#loc199)
      %t49 = arith.index_cast %t48 : i32 to index
      %t50 = memref.load %t2[%t49] : memref<8xi32> loc(#loc200)
      %t51 = arith.subi %t27, %t50 : i32 loc(#loc201)
      memref.store %t51, %t2[%t47] : memref<8xi32>
      %t52 = arith.constant 3 : i32 loc(#loc202)
      %t53 = arith.index_cast %t52 : i32 to index
      %t54 = memref.load %t2[%t53] : memref<8xi32> loc(#loc203)
      %t55 = func.call @idct__Scaled_1d_idct__fn_pmul_1_0(%t54) : (i32) -> i32 loc(#loc204)
      %t56 = arith.constant 3 : i32 loc(#loc205)
      %t57 = arith.index_cast %t56 : i32 to index
      %t58 = memref.load %t2[%t57] : memref<8xi32> loc(#loc206)
      %t59 = func.call @idct__Scaled_1d_idct__fn_pmul_1_1(%t58) : (i32) -> i32 loc(#loc207)
      %t60 = arith.constant 5 : i32 loc(#loc208)
      %t61 = arith.index_cast %t60 : i32 to index
      %t62 = memref.load %t2[%t61] : memref<8xi32> loc(#loc209)
      %t63 = func.call @idct__Scaled_1d_idct__fn_pmul_1_0(%t62) : (i32) -> i32 loc(#loc210)
      %t64 = arith.constant 5 : i32 loc(#loc211)
      %t65 = arith.index_cast %t64 : i32 to index
      %t66 = memref.load %t2[%t65] : memref<8xi32> loc(#loc212)
      %t67 = func.call @idct__Scaled_1d_idct__fn_pmul_1_1(%t66) : (i32) -> i32 loc(#loc213)
      %t68 = arith.constant 3 : i32 loc(#loc214)
      %t69 = arith.index_cast %t68 : i32 to index
      %t70 = arith.subi %t55, %t67 : i32 loc(#loc215)
      memref.store %t70, %t2[%t69] : memref<8xi32>
      %t71 = arith.constant 5 : i32 loc(#loc216)
      %t72 = arith.index_cast %t71 : i32 to index
      %t73 = arith.addi %t63, %t59 : i32 loc(#loc217)
      memref.store %t73, %t2[%t72] : memref<8xi32>
      %t74 = arith.constant 1 : i32 loc(#loc218)
      %t75 = arith.index_cast %t74 : i32 to index
      %t76 = memref.load %t2[%t75] : memref<8xi32> loc(#loc219)
      %t77 = func.call @idct__Scaled_1d_idct__fn_pmul_2_0(%t76) : (i32) -> i32 loc(#loc220)
      %t78 = arith.constant 1 : i32 loc(#loc221)
      %t79 = arith.index_cast %t78 : i32 to index
      %t80 = memref.load %t2[%t79] : memref<8xi32> loc(#loc222)
      %t81 = func.call @idct__Scaled_1d_idct__fn_pmul_2_1(%t80) : (i32) -> i32 loc(#loc223)
      %t82 = arith.constant 7 : i32 loc(#loc224)
      %t83 = arith.index_cast %t82 : i32 to index
      %t84 = memref.load %t2[%t83] : memref<8xi32> loc(#loc225)
      %t85 = func.call @idct__Scaled_1d_idct__fn_pmul_2_0(%t84) : (i32) -> i32 loc(#loc226)
      %t86 = arith.constant 7 : i32 loc(#loc227)
      %t87 = arith.index_cast %t86 : i32 to index
      %t88 = memref.load %t2[%t87] : memref<8xi32> loc(#loc228)
      %t89 = func.call @idct__Scaled_1d_idct__fn_pmul_2_1(%t88) : (i32) -> i32 loc(#loc229)
      %t90 = arith.constant 1 : i32 loc(#loc230)
      %t91 = arith.index_cast %t90 : i32 to index
      %t92 = arith.addi %t77, %t89 : i32 loc(#loc231)
      memref.store %t92, %t2[%t91] : memref<8xi32>
      %t93 = arith.constant 7 : i32 loc(#loc232)
      %t94 = arith.index_cast %t93 : i32 to index
      %t95 = arith.subi %t85, %t81 : i32 loc(#loc233)
      memref.store %t95, %t2[%t94] : memref<8xi32>
      %t96 = arith.constant 2 : i32 loc(#loc234)
      %t97 = arith.index_cast %t96 : i32 to index
      %t98 = memref.load %t2[%t97] : memref<8xi32> loc(#loc235)
      %t99 = func.call @idct__Scaled_1d_idct__fn_pmul_3_0(%t98) : (i32) -> i32 loc(#loc236)
      %t100 = arith.constant 2 : i32 loc(#loc237)
      %t101 = arith.index_cast %t100 : i32 to index
      %t102 = memref.load %t2[%t101] : memref<8xi32> loc(#loc238)
      %t103 = func.call @idct__Scaled_1d_idct__fn_pmul_3_1(%t102) : (i32) -> i32 loc(#loc239)
      %t104 = arith.constant 6 : i32 loc(#loc240)
      %t105 = arith.index_cast %t104 : i32 to index
      %t106 = memref.load %t2[%t105] : memref<8xi32> loc(#loc241)
      %t107 = func.call @idct__Scaled_1d_idct__fn_pmul_3_0(%t106) : (i32) -> i32 loc(#loc242)
      %t108 = arith.constant 6 : i32 loc(#loc243)
      %t109 = arith.index_cast %t108 : i32 to index
      %t110 = memref.load %t2[%t109] : memref<8xi32> loc(#loc244)
      %t111 = func.call @idct__Scaled_1d_idct__fn_pmul_3_1(%t110) : (i32) -> i32 loc(#loc245)
      %t112 = arith.constant 2 : i32 loc(#loc246)
      %t113 = arith.index_cast %t112 : i32 to index
      %t114 = arith.subi %t99, %t111 : i32 loc(#loc247)
      memref.store %t114, %t2[%t113] : memref<8xi32>
      %t115 = arith.constant 6 : i32 loc(#loc248)
      %t116 = arith.index_cast %t115 : i32 to index
      %t117 = arith.addi %t107, %t103 : i32 loc(#loc249)
      memref.store %t117, %t2[%t116] : memref<8xi32>
      %t118 = arith.constant 0 : i32 loc(#loc250)
      %t119 = arith.index_cast %t118 : i32 to index
      %t120 = memref.load %t2[%t119] : memref<8xi32> loc(#loc251)
      %t121 = arith.constant 4 : i32 loc(#loc252)
      %t122 = arith.index_cast %t121 : i32 to index
      %t123 = memref.load %t2[%t122] : memref<8xi32> loc(#loc253)
      %t124 = arith.addi %t120, %t123 : i32 loc(#loc251)
      %t125 = arith.constant 0 : i32 loc(#loc254)
      %t126 = arith.index_cast %t125 : i32 to index
      %t127 = memref.load %t2[%t126] : memref<8xi32> loc(#loc255)
      %t128 = arith.constant 4 : i32 loc(#loc256)
      %t129 = arith.index_cast %t128 : i32 to index
      %t130 = memref.load %t2[%t129] : memref<8xi32> loc(#loc257)
      %t131 = arith.subi %t127, %t130 : i32 loc(#loc255)
      %t132 = arith.constant 0 : i32 loc(#loc258)
      %t133 = arith.index_cast %t132 : i32 to index
      %t134 = arith.constant 6 : i32 loc(#loc259)
      %t135 = arith.index_cast %t134 : i32 to index
      %t136 = memref.load %t2[%t135] : memref<8xi32> loc(#loc260)
      %t137 = arith.addi %t124, %t136 : i32 loc(#loc261)
      memref.store %t137, %t2[%t133] : memref<8xi32>
      %t138 = arith.constant 6 : i32 loc(#loc262)
      %t139 = arith.index_cast %t138 : i32 to index
      %t140 = arith.constant 6 : i32 loc(#loc263)
      %t141 = arith.index_cast %t140 : i32 to index
      %t142 = memref.load %t2[%t141] : memref<8xi32> loc(#loc264)
      %t143 = arith.subi %t124, %t142 : i32 loc(#loc265)
      memref.store %t143, %t2[%t139] : memref<8xi32>
      %t144 = arith.constant 4 : i32 loc(#loc266)
      %t145 = arith.index_cast %t144 : i32 to index
      %t146 = arith.constant 2 : i32 loc(#loc267)
      %t147 = arith.index_cast %t146 : i32 to index
      %t148 = memref.load %t2[%t147] : memref<8xi32> loc(#loc268)
      %t149 = arith.addi %t131, %t148 : i32 loc(#loc269)
      memref.store %t149, %t2[%t145] : memref<8xi32>
      %t150 = arith.constant 2 : i32 loc(#loc270)
      %t151 = arith.index_cast %t150 : i32 to index
      %t152 = arith.constant 2 : i32 loc(#loc271)
      %t153 = arith.index_cast %t152 : i32 to index
      %t154 = memref.load %t2[%t153] : memref<8xi32> loc(#loc272)
      %t155 = arith.subi %t131, %t154 : i32 loc(#loc273)
      memref.store %t155, %t2[%t151] : memref<8xi32>
      %t156 = arith.constant 0 : i32 loc(#loc274)
      %t157 = arith.index_cast %t156 : i32 to index
      %t158 = memref.load %t2[%t157] : memref<8xi32> loc(#loc275)
      %t159 = arith.constant 1 : i32 loc(#loc276)
      %t160 = arith.index_cast %t159 : i32 to index
      %t161 = memref.load %t2[%t160] : memref<8xi32> loc(#loc277)
      %t162 = arith.addi %t158, %t161 : i32 loc(#loc275)
      %t163 = arith.constant 0 : index
      memref.store %t162, %t3[%t163] : memref<8xi32>
      %t164 = arith.constant 4 : i32 loc(#loc278)
      %t165 = arith.index_cast %t164 : i32 to index
      %t166 = memref.load %t2[%t165] : memref<8xi32> loc(#loc279)
      %t167 = arith.constant 5 : i32 loc(#loc280)
      %t168 = arith.index_cast %t167 : i32 to index
      %t169 = memref.load %t2[%t168] : memref<8xi32> loc(#loc281)
      %t170 = arith.addi %t166, %t169 : i32 loc(#loc279)
      %t171 = arith.constant 1 : index
      memref.store %t170, %t3[%t171] : memref<8xi32>
      %t172 = arith.constant 2 : i32 loc(#loc282)
      %t173 = arith.index_cast %t172 : i32 to index
      %t174 = memref.load %t2[%t173] : memref<8xi32> loc(#loc283)
      %t175 = arith.constant 3 : i32 loc(#loc284)
      %t176 = arith.index_cast %t175 : i32 to index
      %t177 = memref.load %t2[%t176] : memref<8xi32> loc(#loc285)
      %t178 = arith.addi %t174, %t177 : i32 loc(#loc283)
      %t179 = arith.constant 2 : index
      memref.store %t178, %t3[%t179] : memref<8xi32>
      %t180 = arith.constant 6 : i32 loc(#loc286)
      %t181 = arith.index_cast %t180 : i32 to index
      %t182 = memref.load %t2[%t181] : memref<8xi32> loc(#loc287)
      %t183 = arith.constant 7 : i32 loc(#loc288)
      %t184 = arith.index_cast %t183 : i32 to index
      %t185 = memref.load %t2[%t184] : memref<8xi32> loc(#loc289)
      %t186 = arith.addi %t182, %t185 : i32 loc(#loc287)
      %t187 = arith.constant 3 : index
      memref.store %t186, %t3[%t187] : memref<8xi32>
      %t188 = arith.constant 6 : i32 loc(#loc290)
      %t189 = arith.index_cast %t188 : i32 to index
      %t190 = memref.load %t2[%t189] : memref<8xi32> loc(#loc291)
      %t191 = arith.constant 7 : i32 loc(#loc292)
      %t192 = arith.index_cast %t191 : i32 to index
      %t193 = memref.load %t2[%t192] : memref<8xi32> loc(#loc293)
      %t194 = arith.subi %t190, %t193 : i32 loc(#loc291)
      %t195 = arith.constant 4 : index
      memref.store %t194, %t3[%t195] : memref<8xi32>
      %t196 = arith.constant 2 : i32 loc(#loc294)
      %t197 = arith.index_cast %t196 : i32 to index
      %t198 = memref.load %t2[%t197] : memref<8xi32> loc(#loc295)
      %t199 = arith.constant 3 : i32 loc(#loc296)
      %t200 = arith.index_cast %t199 : i32 to index
      %t201 = memref.load %t2[%t200] : memref<8xi32> loc(#loc297)
      %t202 = arith.subi %t198, %t201 : i32 loc(#loc295)
      %t203 = arith.constant 5 : index
      memref.store %t202, %t3[%t203] : memref<8xi32>
      %t204 = arith.constant 4 : i32 loc(#loc298)
      %t205 = arith.index_cast %t204 : i32 to index
      %t206 = memref.load %t2[%t205] : memref<8xi32> loc(#loc299)
      %t207 = arith.constant 5 : i32 loc(#loc300)
      %t208 = arith.index_cast %t207 : i32 to index
      %t209 = memref.load %t2[%t208] : memref<8xi32> loc(#loc301)
      %t210 = arith.subi %t206, %t209 : i32 loc(#loc299)
      %t211 = arith.constant 6 : index
      memref.store %t210, %t3[%t211] : memref<8xi32>
      %t212 = arith.constant 0 : i32 loc(#loc302)
      %t213 = arith.index_cast %t212 : i32 to index
      %t214 = memref.load %t2[%t213] : memref<8xi32> loc(#loc303)
      %t215 = arith.constant 1 : i32 loc(#loc304)
      %t216 = arith.index_cast %t215 : i32 to index
      %t217 = memref.load %t2[%t216] : memref<8xi32> loc(#loc305)
      %t218 = arith.subi %t214, %t217 : i32 loc(#loc303)
      %t219 = arith.constant 7 : index
      memref.store %t218, %t3[%t219] : memref<8xi32>
      %t220 = arith.constant 8 : i32 loc(#loc306)
      %t221 = arith.index_cast %t220 : i32 to index
      %t222 = arith.constant 0 : index
      %t223 = arith.constant 1 : index
      scf.for %t224 = %t222 to %t221 step %t223 {
        %t225 = memref.load %t3[%t224] : memref<8xi32>
        fifo.push(%OUT: !fifo.input_port<i32>, %t225: i32)
        scf.yield
      }
    } loc(#loc177)
  } loc(#loc307)
  cal.actor @idct__Clip__v__isz_dyn__osz_dyn(%isz: i32, %osz: i32)
    in_names ["I", "SIGNED"]
    out_names ["O"]
    ports_in(%I: !fifo.output_port<i32>, %SIGNED: !fifo.output_port<i1>)
    ports_out(%O: !fifo.input_port<i32>)
  {
    cal.action "clip" priority=0 {
      %t0 = fifo.pop(%SIGNED: !fifo.output_port<i1> ) : i1
      %t1 = memref.alloca() : memref<64xi32>
      %t2 = arith.constant 64 : index
      %t3 = arith.constant 0 : index
      %t4 = arith.constant 1 : index
      scf.for %t5 = %t3 to %t2 step %t4 {
        %t6 = fifo.pop(%I: !fifo.output_port<i32> ) : i32
        memref.store %t6, %t1[%t5] : memref<64xi32>
        scf.yield
      }
      %t7 = arith.constant 0 : i32 loc(#loc309)
      %t8 = arith.constant 63 : i32 loc(#loc310)
      %t9 = arith.index_cast %t7 : i32 to index
      %t10 = arith.index_cast %t8 : i32 to index
      %t11 = arith.constant 1 : index
      %t12 = arith.addi %t10, %t11 : index
      %t13 = arith.constant 1 : index
      scf.for %t14 = %t9 to %t12 step %t13 {
        %t15 = arith.index_cast %t14 : index to i32
        %t16 = arith.index_cast %t15 : i32 to index
        %t17 = memref.load %t1[%t16] : memref<64xi32> loc(#loc311)
        %t18 = arith.constant 255 : i32 loc(#loc312)
        %t19 = arith.cmpi sgt, %t17, %t18 : i32 loc(#loc311)
        %t43 = scf.if %t19 -> i32 {
          %t20 = arith.constant 255 : i32 loc(#loc313)
          scf.yield %t20 : i32
        } else {
          %t21 = arith.constant 1 : i1
          %t22 = arith.xori %t0, %t21 : i1 loc(#loc314)
          %t23 = arith.index_cast %t15 : i32 to index
          %t24 = memref.load %t1[%t23] : memref<64xi32> loc(#loc315)
          %t25 = arith.constant 0 : i32 loc(#loc316)
          %t26 = arith.cmpi slt, %t24, %t25 : i32 loc(#loc315)
          %t27 = scf.if %t22 -> i1 {
            scf.yield %t26 : i1
          } else {
            %t28 = arith.constant 0 : i1
            scf.yield %t28 : i1
          }
          %t42 = scf.if %t27 -> i32 {
            %t29 = arith.constant 0 : i32 loc(#loc317)
            scf.yield %t29 : i32
          } else {
            %t30 = arith.index_cast %t15 : i32 to index
            %t31 = memref.load %t1[%t30] : memref<64xi32> loc(#loc318)
            %t32 = arith.constant 255 : i32 loc(#loc319)
            %t33 = arith.constant 0 : i32 loc(#loc320)
            %t34 = arith.subi %t33, %t32 : i32 loc(#loc320)
            %t35 = arith.cmpi slt, %t31, %t34 : i32 loc(#loc318)
            %t41 = scf.if %t35 -> i32 {
              %t36 = arith.constant 255 : i32 loc(#loc321)
              %t37 = arith.constant 0 : i32 loc(#loc322)
              %t38 = arith.subi %t37, %t36 : i32 loc(#loc322)
              scf.yield %t38 : i32
            } else {
              %t39 = arith.index_cast %t15 : i32 to index
              %t40 = memref.load %t1[%t39] : memref<64xi32> loc(#loc323)
              scf.yield %t40 : i32
            }
            scf.yield %t41 : i32
          }
          scf.yield %t42 : i32
        }
        fifo.push(%O: !fifo.input_port<i32>, %t43: i32)
        scf.yield
      }
    } loc(#loc308)
  } loc(#loc324)
  cal.actor @idct__Scale__v__SIN_SZ_13__SOUT_SZ_32(%SIN_SZ: i32, %SOUT_SZ: i32)
    in_names ["IN"]
    out_names ["OUT"]
    ports_in(%IN: !fifo.output_port<i13>)
    ports_out(%OUT: !fifo.input_port<i32>)
  {
    %t0 = cal.create_state_var<i32> : !cal.state_ref<i32>
    %t1 = arith.constant 1024 : i32 loc(#loc154)
    cal.set(%t0: !cal.state_ref<i32>, %t1: i32)
    %t2 = cal.create_state_var<i32> : !cal.state_ref<i32>
    %t3 = arith.constant 1138 : i32 loc(#loc155)
    cal.set(%t2: !cal.state_ref<i32>, %t3: i32)
    %t4 = cal.create_state_var<i32> : !cal.state_ref<i32>
    %t5 = arith.constant 1730 : i32 loc(#loc156)
    cal.set(%t4: !cal.state_ref<i32>, %t5: i32)
    %t6 = cal.create_state_var<i32> : !cal.state_ref<i32>
    %t7 = arith.constant 1609 : i32 loc(#loc157)
    cal.set(%t6: !cal.state_ref<i32>, %t7: i32)
    %t8 = cal.create_state_var<i32> : !cal.state_ref<i32>
    %t9 = arith.constant 1264 : i32 loc(#loc158)
    cal.set(%t8: !cal.state_ref<i32>, %t9: i32)
    %t10 = cal.create_state_var<i32> : !cal.state_ref<i32>
    %t11 = arith.constant 1922 : i32 loc(#loc159)
    cal.set(%t10: !cal.state_ref<i32>, %t11: i32)
    %t12 = cal.create_state_var<i32> : !cal.state_ref<i32>
    %t13 = arith.constant 1788 : i32 loc(#loc160)
    cal.set(%t12: !cal.state_ref<i32>, %t13: i32)
    %t14 = cal.create_state_var<i32> : !cal.state_ref<i32>
    %t15 = arith.constant 2923 : i32 loc(#loc161)
    cal.set(%t14: !cal.state_ref<i32>, %t15: i32)
    %t16 = cal.create_state_var<i32> : !cal.state_ref<i32>
    %t17 = arith.constant 2718 : i32 loc(#loc162)
    cal.set(%t16: !cal.state_ref<i32>, %t17: i32)
    %t18 = cal.create_state_var<i32> : !cal.state_ref<i32>
    %t19 = arith.constant 2528 : i32 loc(#loc163)
    cal.set(%t18: !cal.state_ref<i32>, %t19: i32)
    %t20 = cal.create_state_var<memref<64xi32>> : !cal.state_ref<memref<64xi32>>
    %t21 = cal.get(%t20: !cal.state_ref<memref<64xi32>>) : memref<64xi32>
    %t22 = cal.get(%t0: !cal.state_ref<i32>) : i32
    %t23 = arith.constant 0 : index
    memref.store %t22, %t21[%t23] : memref<64xi32>
    %t24 = cal.get(%t2: !cal.state_ref<i32>) : i32
    %t25 = arith.constant 1 : index
    memref.store %t24, %t21[%t25] : memref<64xi32>
    %t26 = cal.get(%t4: !cal.state_ref<i32>) : i32
    %t27 = arith.constant 2 : index
    memref.store %t26, %t21[%t27] : memref<64xi32>
    %t28 = cal.get(%t6: !cal.state_ref<i32>) : i32
    %t29 = arith.constant 3 : index
    memref.store %t28, %t21[%t29] : memref<64xi32>
    %t30 = cal.get(%t0: !cal.state_ref<i32>) : i32
    %t31 = arith.constant 4 : index
    memref.store %t30, %t21[%t31] : memref<64xi32>
    %t32 = cal.get(%t6: !cal.state_ref<i32>) : i32
    %t33 = arith.constant 5 : index
    memref.store %t32, %t21[%t33] : memref<64xi32>
    %t34 = cal.get(%t4: !cal.state_ref<i32>) : i32
    %t35 = arith.constant 6 : index
    memref.store %t34, %t21[%t35] : memref<64xi32>
    %t36 = cal.get(%t2: !cal.state_ref<i32>) : i32
    %t37 = arith.constant 7 : index
    memref.store %t36, %t21[%t37] : memref<64xi32>
    %t38 = cal.get(%t2: !cal.state_ref<i32>) : i32
    %t39 = arith.constant 8 : index
    memref.store %t38, %t21[%t39] : memref<64xi32>
    %t40 = cal.get(%t8: !cal.state_ref<i32>) : i32
    %t41 = arith.constant 9 : index
    memref.store %t40, %t21[%t41] : memref<64xi32>
    %t42 = cal.get(%t10: !cal.state_ref<i32>) : i32
    %t43 = arith.constant 10 : index
    memref.store %t42, %t21[%t43] : memref<64xi32>
    %t44 = cal.get(%t12: !cal.state_ref<i32>) : i32
    %t45 = arith.constant 11 : index
    memref.store %t44, %t21[%t45] : memref<64xi32>
    %t46 = cal.get(%t2: !cal.state_ref<i32>) : i32
    %t47 = arith.constant 12 : index
    memref.store %t46, %t21[%t47] : memref<64xi32>
    %t48 = cal.get(%t12: !cal.state_ref<i32>) : i32
    %t49 = arith.constant 13 : index
    memref.store %t48, %t21[%t49] : memref<64xi32>
    %t50 = cal.get(%t10: !cal.state_ref<i32>) : i32
    %t51 = arith.constant 14 : index
    memref.store %t50, %t21[%t51] : memref<64xi32>
    %t52 = cal.get(%t8: !cal.state_ref<i32>) : i32
    %t53 = arith.constant 15 : index
    memref.store %t52, %t21[%t53] : memref<64xi32>
    %t54 = cal.get(%t4: !cal.state_ref<i32>) : i32
    %t55 = arith.constant 16 : index
    memref.store %t54, %t21[%t55] : memref<64xi32>
    %t56 = cal.get(%t10: !cal.state_ref<i32>) : i32
    %t57 = arith.constant 17 : index
    memref.store %t56, %t21[%t57] : memref<64xi32>
    %t58 = cal.get(%t14: !cal.state_ref<i32>) : i32
    %t59 = arith.constant 18 : index
    memref.store %t58, %t21[%t59] : memref<64xi32>
    %t60 = cal.get(%t16: !cal.state_ref<i32>) : i32
    %t61 = arith.constant 19 : index
    memref.store %t60, %t21[%t61] : memref<64xi32>
    %t62 = cal.get(%t4: !cal.state_ref<i32>) : i32
    %t63 = arith.constant 20 : index
    memref.store %t62, %t21[%t63] : memref<64xi32>
    %t64 = cal.get(%t16: !cal.state_ref<i32>) : i32
    %t65 = arith.constant 21 : index
    memref.store %t64, %t21[%t65] : memref<64xi32>
    %t66 = cal.get(%t14: !cal.state_ref<i32>) : i32
    %t67 = arith.constant 22 : index
    memref.store %t66, %t21[%t67] : memref<64xi32>
    %t68 = cal.get(%t10: !cal.state_ref<i32>) : i32
    %t69 = arith.constant 23 : index
    memref.store %t68, %t21[%t69] : memref<64xi32>
    %t70 = cal.get(%t6: !cal.state_ref<i32>) : i32
    %t71 = arith.constant 24 : index
    memref.store %t70, %t21[%t71] : memref<64xi32>
    %t72 = cal.get(%t12: !cal.state_ref<i32>) : i32
    %t73 = arith.constant 25 : index
    memref.store %t72, %t21[%t73] : memref<64xi32>
    %t74 = cal.get(%t16: !cal.state_ref<i32>) : i32
    %t75 = arith.constant 26 : index
    memref.store %t74, %t21[%t75] : memref<64xi32>
    %t76 = cal.get(%t18: !cal.state_ref<i32>) : i32
    %t77 = arith.constant 27 : index
    memref.store %t76, %t21[%t77] : memref<64xi32>
    %t78 = cal.get(%t6: !cal.state_ref<i32>) : i32
    %t79 = arith.constant 28 : index
    memref.store %t78, %t21[%t79] : memref<64xi32>
    %t80 = cal.get(%t18: !cal.state_ref<i32>) : i32
    %t81 = arith.constant 29 : index
    memref.store %t80, %t21[%t81] : memref<64xi32>
    %t82 = cal.get(%t16: !cal.state_ref<i32>) : i32
    %t83 = arith.constant 30 : index
    memref.store %t82, %t21[%t83] : memref<64xi32>
    %t84 = cal.get(%t12: !cal.state_ref<i32>) : i32
    %t85 = arith.constant 31 : index
    memref.store %t84, %t21[%t85] : memref<64xi32>
    %t86 = cal.get(%t0: !cal.state_ref<i32>) : i32
    %t87 = arith.constant 32 : index
    memref.store %t86, %t21[%t87] : memref<64xi32>
    %t88 = cal.get(%t2: !cal.state_ref<i32>) : i32
    %t89 = arith.constant 33 : index
    memref.store %t88, %t21[%t89] : memref<64xi32>
    %t90 = cal.get(%t4: !cal.state_ref<i32>) : i32
    %t91 = arith.constant 34 : index
    memref.store %t90, %t21[%t91] : memref<64xi32>
    %t92 = cal.get(%t6: !cal.state_ref<i32>) : i32
    %t93 = arith.constant 35 : index
    memref.store %t92, %t21[%t93] : memref<64xi32>
    %t94 = cal.get(%t0: !cal.state_ref<i32>) : i32
    %t95 = arith.constant 36 : index
    memref.store %t94, %t21[%t95] : memref<64xi32>
    %t96 = cal.get(%t6: !cal.state_ref<i32>) : i32
    %t97 = arith.constant 37 : index
    memref.store %t96, %t21[%t97] : memref<64xi32>
    %t98 = cal.get(%t4: !cal.state_ref<i32>) : i32
    %t99 = arith.constant 38 : index
    memref.store %t98, %t21[%t99] : memref<64xi32>
    %t100 = cal.get(%t2: !cal.state_ref<i32>) : i32
    %t101 = arith.constant 39 : index
    memref.store %t100, %t21[%t101] : memref<64xi32>
    %t102 = cal.get(%t6: !cal.state_ref<i32>) : i32
    %t103 = arith.constant 40 : index
    memref.store %t102, %t21[%t103] : memref<64xi32>
    %t104 = cal.get(%t12: !cal.state_ref<i32>) : i32
    %t105 = arith.constant 41 : index
    memref.store %t104, %t21[%t105] : memref<64xi32>
    %t106 = cal.get(%t16: !cal.state_ref<i32>) : i32
    %t107 = arith.constant 42 : index
    memref.store %t106, %t21[%t107] : memref<64xi32>
    %t108 = cal.get(%t18: !cal.state_ref<i32>) : i32
    %t109 = arith.constant 43 : index
    memref.store %t108, %t21[%t109] : memref<64xi32>
    %t110 = cal.get(%t6: !cal.state_ref<i32>) : i32
    %t111 = arith.constant 44 : index
    memref.store %t110, %t21[%t111] : memref<64xi32>
    %t112 = cal.get(%t18: !cal.state_ref<i32>) : i32
    %t113 = arith.constant 45 : index
    memref.store %t112, %t21[%t113] : memref<64xi32>
    %t114 = cal.get(%t16: !cal.state_ref<i32>) : i32
    %t115 = arith.constant 46 : index
    memref.store %t114, %t21[%t115] : memref<64xi32>
    %t116 = cal.get(%t12: !cal.state_ref<i32>) : i32
    %t117 = arith.constant 47 : index
    memref.store %t116, %t21[%t117] : memref<64xi32>
    %t118 = cal.get(%t4: !cal.state_ref<i32>) : i32
    %t119 = arith.constant 48 : index
    memref.store %t118, %t21[%t119] : memref<64xi32>
    %t120 = cal.get(%t10: !cal.state_ref<i32>) : i32
    %t121 = arith.constant 49 : index
    memref.store %t120, %t21[%t121] : memref<64xi32>
    %t122 = cal.get(%t14: !cal.state_ref<i32>) : i32
    %t123 = arith.constant 50 : index
    memref.store %t122, %t21[%t123] : memref<64xi32>
    %t124 = cal.get(%t16: !cal.state_ref<i32>) : i32
    %t125 = arith.constant 51 : index
    memref.store %t124, %t21[%t125] : memref<64xi32>
    %t126 = cal.get(%t4: !cal.state_ref<i32>) : i32
    %t127 = arith.constant 52 : index
    memref.store %t126, %t21[%t127] : memref<64xi32>
    %t128 = cal.get(%t16: !cal.state_ref<i32>) : i32
    %t129 = arith.constant 53 : index
    memref.store %t128, %t21[%t129] : memref<64xi32>
    %t130 = cal.get(%t14: !cal.state_ref<i32>) : i32
    %t131 = arith.constant 54 : index
    memref.store %t130, %t21[%t131] : memref<64xi32>
    %t132 = cal.get(%t10: !cal.state_ref<i32>) : i32
    %t133 = arith.constant 55 : index
    memref.store %t132, %t21[%t133] : memref<64xi32>
    %t134 = cal.get(%t2: !cal.state_ref<i32>) : i32
    %t135 = arith.constant 56 : index
    memref.store %t134, %t21[%t135] : memref<64xi32>
    %t136 = cal.get(%t8: !cal.state_ref<i32>) : i32
    %t137 = arith.constant 57 : index
    memref.store %t136, %t21[%t137] : memref<64xi32>
    %t138 = cal.get(%t10: !cal.state_ref<i32>) : i32
    %t139 = arith.constant 58 : index
    memref.store %t138, %t21[%t139] : memref<64xi32>
    %t140 = cal.get(%t12: !cal.state_ref<i32>) : i32
    %t141 = arith.constant 59 : index
    memref.store %t140, %t21[%t141] : memref<64xi32>
    %t142 = cal.get(%t2: !cal.state_ref<i32>) : i32
    %t143 = arith.constant 60 : index
    memref.store %t142, %t21[%t143] : memref<64xi32>
    %t144 = cal.get(%t12: !cal.state_ref<i32>) : i32
    %t145 = arith.constant 61 : index
    memref.store %t144, %t21[%t145] : memref<64xi32>
    %t146 = cal.get(%t10: !cal.state_ref<i32>) : i32
    %t147 = arith.constant 62 : index
    memref.store %t146, %t21[%t147] : memref<64xi32>
    %t148 = cal.get(%t8: !cal.state_ref<i32>) : i32
    %t149 = arith.constant 63 : index
    memref.store %t148, %t21[%t149] : memref<64xi32>
    cal.action "scale" priority=0 {
      %t150 = memref.alloca() : memref<64xi32>
      %t151 = memref.alloca() : memref<64xi13>
      %t152 = arith.constant 64 : index
      %t153 = arith.constant 0 : index
      %t154 = arith.constant 1 : index
      scf.for %t155 = %t153 to %t152 step %t154 {
        %t156 = fifo.pop(%IN: !fifo.output_port<i13> ) : i13
        memref.store %t156, %t151[%t155] : memref<64xi13>
        scf.yield
      }
      %t157 = arith.constant 0 : i32 loc(#loc165)
      %t158 = arith.constant 63 : i32 loc(#loc166)
      %t159 = arith.index_cast %t157 : i32 to index
      %t160 = arith.index_cast %t158 : i32 to index
      %t161 = arith.constant 1 : index
      %t162 = arith.addi %t160, %t161 : index
      %t163 = arith.constant 1 : index
      scf.for %t164 = %t159 to %t162 step %t163 {
        %t165 = arith.index_cast %t164 : index to i32
        %t166 = arith.index_cast %t165 : i32 to index
        %t167 = memref.load %t151[%t166] : memref<64xi13> loc(#loc167)
        %t168 = cal.get(%t20: !cal.state_ref<memref<64xi32>>) : memref<64xi32>
        %t169 = arith.index_cast %t165 : i32 to index
        %t170 = memref.load %t168[%t169] : memref<64xi32> loc(#loc168)
        %t171 = arith.extsi %t167 : i13 to i32
        %t172 = arith.muli %t171, %t170 : i32 loc(#loc167)
        %t173 = arith.subi %t164, %t159 : index
        memref.store %t172, %t150[%t173] : memref<64xi32>
        scf.yield
      }
      %t174 = arith.constant 0 : i32 loc(#loc169)
      %t175 = arith.index_cast %t174 : i32 to index
      %t176 = arith.constant 0 : i32 loc(#loc170)
      %t177 = arith.index_cast %t176 : i32 to index
      %t178 = memref.load %t150[%t177] : memref<64xi32> loc(#loc171)
      %t179 = arith.constant 1 : i32 loc(#loc172)
      %t180 = arith.constant 12 : i32 loc(#loc173)
      %t181 = arith.shli %t179, %t180 : i32 loc(#loc174)
      %t182 = arith.addi %t178, %t181 : i32 loc(#loc171)
      memref.store %t182, %t150[%t175] : memref<64xi32>
      %t183 = arith.constant 64 : i32 loc(#loc175)
      %t184 = arith.index_cast %t183 : i32 to index
      %t185 = arith.constant 0 : index
      %t186 = arith.constant 1 : index
      scf.for %t187 = %t185 to %t184 step %t186 {
        %t188 = memref.load %t150[%t187] : memref<64xi32>
        fifo.push(%OUT: !fifo.input_port<i32>, %t188: i32)
        scf.yield
      }
    } loc(#loc164)
  } loc(#loc176)
  cal.actor @idct__Clip__v__isz_32__osz_32(%isz: i32, %osz: i32)
    in_names ["I", "SIGNED"]
    out_names ["O"]
    ports_in(%I: !fifo.output_port<i32>, %SIGNED: !fifo.output_port<i1>)
    ports_out(%O: !fifo.input_port<i32>)
  {
    cal.action "clip" priority=0 {
      %t0 = fifo.pop(%SIGNED: !fifo.output_port<i1> ) : i1
      %t1 = memref.alloca() : memref<64xi32>
      %t2 = arith.constant 64 : index
      %t3 = arith.constant 0 : index
      %t4 = arith.constant 1 : index
      scf.for %t5 = %t3 to %t2 step %t4 {
        %t6 = fifo.pop(%I: !fifo.output_port<i32> ) : i32
        memref.store %t6, %t1[%t5] : memref<64xi32>
        scf.yield
      }
      %t7 = arith.constant 0 : i32 loc(#loc309)
      %t8 = arith.constant 63 : i32 loc(#loc310)
      %t9 = arith.index_cast %t7 : i32 to index
      %t10 = arith.index_cast %t8 : i32 to index
      %t11 = arith.constant 1 : index
      %t12 = arith.addi %t10, %t11 : index
      %t13 = arith.constant 1 : index
      scf.for %t14 = %t9 to %t12 step %t13 {
        %t15 = arith.index_cast %t14 : index to i32
        %t16 = arith.index_cast %t15 : i32 to index
        %t17 = memref.load %t1[%t16] : memref<64xi32> loc(#loc311)
        %t18 = arith.constant 255 : i32 loc(#loc312)
        %t19 = arith.cmpi sgt, %t17, %t18 : i32 loc(#loc311)
        %t43 = scf.if %t19 -> i32 {
          %t20 = arith.constant 255 : i32 loc(#loc313)
          scf.yield %t20 : i32
        } else {
          %t21 = arith.constant 1 : i1
          %t22 = arith.xori %t0, %t21 : i1 loc(#loc314)
          %t23 = arith.index_cast %t15 : i32 to index
          %t24 = memref.load %t1[%t23] : memref<64xi32> loc(#loc315)
          %t25 = arith.constant 0 : i32 loc(#loc316)
          %t26 = arith.cmpi slt, %t24, %t25 : i32 loc(#loc315)
          %t27 = scf.if %t22 -> i1 {
            scf.yield %t26 : i1
          } else {
            %t28 = arith.constant 0 : i1
            scf.yield %t28 : i1
          }
          %t42 = scf.if %t27 -> i32 {
            %t29 = arith.constant 0 : i32 loc(#loc317)
            scf.yield %t29 : i32
          } else {
            %t30 = arith.index_cast %t15 : i32 to index
            %t31 = memref.load %t1[%t30] : memref<64xi32> loc(#loc318)
            %t32 = arith.constant 255 : i32 loc(#loc319)
            %t33 = arith.constant 0 : i32 loc(#loc320)
            %t34 = arith.subi %t33, %t32 : i32 loc(#loc320)
            %t35 = arith.cmpi slt, %t31, %t34 : i32 loc(#loc318)
            %t41 = scf.if %t35 -> i32 {
              %t36 = arith.constant 255 : i32 loc(#loc321)
              %t37 = arith.constant 0 : i32 loc(#loc322)
              %t38 = arith.subi %t37, %t36 : i32 loc(#loc322)
              scf.yield %t38 : i32
            } else {
              %t39 = arith.index_cast %t15 : i32 to index
              %t40 = memref.load %t1[%t39] : memref<64xi32> loc(#loc323)
              scf.yield %t40 : i32
            }
            scf.yield %t41 : i32
          }
          scf.yield %t42 : i32
        }
        fifo.push(%O: !fifo.input_port<i32>, %t43: i32)
        scf.yield
      }
    } loc(#loc308)
  } loc(#loc324)
} loc(#loc325)
#loc0 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/idct/scaled_1d_idct.cal":9:30)
#loc1 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/idct/scaled_1d_idct.cal":9:25)
#loc2 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/idct/scaled_1d_idct.cal":9:39)
#loc3 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/idct/scaled_1d_idct.cal":11:3)
#loc4 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/idct/scaled_1d_idct.cal":16:30)
#loc5 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/idct/scaled_1d_idct.cal":16:25)
#loc6 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/idct/scaled_1d_idct.cal":16:39)
#loc7 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/idct/scaled_1d_idct.cal":17:39)
#loc8 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/idct/scaled_1d_idct.cal":17:33)
#loc9 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/idct/scaled_1d_idct.cal":17:25)
#loc10 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/idct/scaled_1d_idct.cal":19:21)
#loc11 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/idct/scaled_1d_idct.cal":19:11)
#loc12 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/idct/scaled_1d_idct.cal":19:3)
#loc13 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/idct/scaled_1d_idct.cal":24:30)
#loc14 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/idct/scaled_1d_idct.cal":24:25)
#loc15 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/idct/scaled_1d_idct.cal":26:12)
#loc16 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/idct/scaled_1d_idct.cal":26:3)
#loc17 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/idct/scaled_1d_idct.cal":31:8)
#loc18 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/idct/scaled_1d_idct.cal":31:3)
#loc19 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/idct/scaled_1d_idct.cal":36:25)
#loc20 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/idct/scaled_1d_idct.cal":36:34)
#loc21 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/idct/scaled_1d_idct.cal":37:34)
#loc22 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/idct/scaled_1d_idct.cal":37:25)
#loc23 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/idct/scaled_1d_idct.cal":39:3)
#loc24 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/idct/scaled_1d_idct.cal":39:16)
#loc25 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/idct/scaled_1d_idct.cal":44:25)
#loc26 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/idct/scaled_1d_idct.cal":44:34)
#loc27 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/idct/scaled_1d_idct.cal":45:34)
#loc28 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/idct/scaled_1d_idct.cal":45:25)
#loc29 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/idct/scaled_1d_idct.cal":47:3)
#loc30 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/TopIDCT.cal":47:41)
#loc31 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/TopIDCT.cal":47:57)
#loc32 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/TopIDCT.cal":47:70)
#loc33 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/TopIDCT.cal":48:44)
#loc34 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/TopIDCT.cal":48:57)
#loc35 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/TopIDCT.cal":48:70)
#loc36 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/TopIDCT.cal":49:35)
#loc37 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/TopIDCT.cal":49:45)
#loc38 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/idct/Transpose.cal":6:5)
#loc39 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/idct/Transpose.cal":6:74)
#loc40 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/idct/Transpose.cal":6:78)
#loc41 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/idct/Transpose.cal":6:94)
#loc42 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/idct/Transpose.cal":6:99)
#loc43 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/idct/Transpose.cal":6:47)
#loc44 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/idct/Transpose.cal":6:44)
#loc45 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/idct/Transpose.cal":4:3)
#loc46 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/idct/rightshift.cal":6:3)
#loc47 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/idct/rightshift.cal":6:75)
#loc48 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/idct/rightshift.cal":6:80)
#loc49 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/idct/rightshift.cal":6:49)
#loc50 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/idct/rightshift.cal":6:57)
#loc51 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/idct/rightshift.cal":3:2)
#loc52 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/TopIDCT.cal":5:20)
#loc53 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/TopIDCT.cal":5:26)
#loc54 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/TopIDCT.cal":8:13)
#loc55 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/TopIDCT.cal":8:20)
#loc56 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/TopIDCT.cal":8:19)
#loc57 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/TopIDCT.cal":8:26)
#loc58 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/TopIDCT.cal":8:25)
#loc59 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/TopIDCT.cal":8:32)
#loc60 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/TopIDCT.cal":8:31)
#loc61 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/TopIDCT.cal":8:38)
#loc62 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/TopIDCT.cal":8:37)
#loc63 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/TopIDCT.cal":8:44)
#loc64 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/TopIDCT.cal":8:43)
#loc65 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/TopIDCT.cal":8:49)
#loc66 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/TopIDCT.cal":8:48)
#loc67 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/TopIDCT.cal":8:53)
#loc68 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/TopIDCT.cal":9:13)
#loc69 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/TopIDCT.cal":9:17)
#loc70 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/TopIDCT.cal":9:21)
#loc71 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/TopIDCT.cal":9:24)
#loc72 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/TopIDCT.cal":9:28)
#loc73 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/TopIDCT.cal":9:27)
#loc74 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/TopIDCT.cal":9:33)
#loc75 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/TopIDCT.cal":9:32)
#loc76 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/TopIDCT.cal":9:38)
#loc77 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/TopIDCT.cal":9:37)
#loc78 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/TopIDCT.cal":9:42)
#loc79 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/TopIDCT.cal":10:13)
#loc80 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/TopIDCT.cal":10:18)
#loc81 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/TopIDCT.cal":10:17)
#loc82 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/TopIDCT.cal":10:23)
#loc83 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/TopIDCT.cal":10:22)
#loc84 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/TopIDCT.cal":10:28)
#loc85 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/TopIDCT.cal":10:27)
#loc86 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/TopIDCT.cal":10:32)
#loc87 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/TopIDCT.cal":10:36)
#loc88 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/TopIDCT.cal":10:39)
#loc89 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/TopIDCT.cal":10:42)
#loc90 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/TopIDCT.cal":11:13)
#loc91 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/TopIDCT.cal":11:18)
#loc92 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/TopIDCT.cal":11:17)
#loc93 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/TopIDCT.cal":11:22)
#loc94 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/TopIDCT.cal":11:25)
#loc95 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/TopIDCT.cal":11:28)
#loc96 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/TopIDCT.cal":11:31)
#loc97 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/TopIDCT.cal":11:34)
#loc98 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/TopIDCT.cal":11:37)
#loc99 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/TopIDCT.cal":12:13)
#loc100 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/TopIDCT.cal":12:17)
#loc101 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/TopIDCT.cal":12:20)
#loc102 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/TopIDCT.cal":12:24)
#loc103 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/TopIDCT.cal":12:23)
#loc104 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/TopIDCT.cal":12:29)
#loc105 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/TopIDCT.cal":12:28)
#loc106 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/TopIDCT.cal":12:33)
#loc107 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/TopIDCT.cal":12:36)
#loc108 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/TopIDCT.cal":12:39)
#loc109 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/TopIDCT.cal":13:13)
#loc110 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/TopIDCT.cal":13:16)
#loc111 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/TopIDCT.cal":13:19)
#loc112 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/TopIDCT.cal":13:23)
#loc113 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/TopIDCT.cal":13:22)
#loc114 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/TopIDCT.cal":13:27)
#loc115 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/TopIDCT.cal":13:30)
#loc116 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/TopIDCT.cal":13:33)
#loc117 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/TopIDCT.cal":13:36)
#loc118 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/TopIDCT.cal":14:13)
#loc119 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/TopIDCT.cal":14:16)
#loc120 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/TopIDCT.cal":14:19)
#loc121 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/TopIDCT.cal":14:22)
#loc122 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/TopIDCT.cal":14:25)
#loc123 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/TopIDCT.cal":14:28)
#loc124 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/TopIDCT.cal":14:31)
#loc125 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/TopIDCT.cal":14:34)
#loc126 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/TopIDCT.cal":15:13)
#loc127 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/TopIDCT.cal":15:16)
#loc128 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/TopIDCT.cal":15:19)
#loc129 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/TopIDCT.cal":15:22)
#loc130 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/TopIDCT.cal":15:25)
#loc131 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/TopIDCT.cal":15:28)
#loc132 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/TopIDCT.cal":15:31)
#loc133 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/TopIDCT.cal":15:34)
#loc134 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/TopIDCT.cal":17:18)
#loc135 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/TopIDCT.cal":19:9)
#loc136 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/TopIDCT.cal":21:13)
#loc137 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/TopIDCT.cal":23:34)
#loc138 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/TopIDCT.cal":23:24)
#loc139 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/TopIDCT.cal":19:40)
#loc140 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/TopIDCT.cal":3:5)
#loc141 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/idct/idct2d_23002.cal":15:32)
#loc142 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/idct/idct2d_23002.cal":15:45)
#loc143 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/idct/idct2d_23002.cal":17:35)
#loc144 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/idct/idct2d_23002.cal":17:48)
#loc145 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/TopIDCT.cal":30:25)
#loc146 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/TopIDCT.cal":31:9)
#loc147 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/TopIDCT.cal":33:33)
#loc148 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/TopIDCT.cal":33:23)
#loc149 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/TopIDCT.cal":35:15)
#loc150 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/TopIDCT.cal":36:36)
#loc151 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/TopIDCT.cal":36:41)
#loc152 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/TopIDCT.cal":37:43)
#loc153 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/TopIDCT.cal":28:5)
#loc154 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/idct/Scale.cal":8:13)
#loc155 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/idct/Scale.cal":9:13)
#loc156 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/idct/Scale.cal":10:13)
#loc157 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/idct/Scale.cal":11:13)
#loc158 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/idct/Scale.cal":12:13)
#loc159 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/idct/Scale.cal":13:13)
#loc160 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/idct/Scale.cal":14:13)
#loc161 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/idct/Scale.cal":15:13)
#loc162 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/idct/Scale.cal":16:13)
#loc163 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/idct/Scale.cal":17:13)
#loc164 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/idct/Scale.cal":30:5)
#loc165 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/idct/Scale.cal":33:45)
#loc166 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/idct/Scale.cal":33:50)
#loc167 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/idct/Scale.cal":33:15)
#loc168 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/idct/Scale.cal":33:22)
#loc169 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/idct/Scale.cal":34:11)
#loc170 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/idct/Scale.cal":34:19)
#loc171 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/idct/Scale.cal":34:17)
#loc172 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/idct/Scale.cal":34:25)
#loc173 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/idct/Scale.cal":34:30)
#loc174 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/idct/Scale.cal":34:24)
#loc175 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/idct/Scale.cal":30:57)
#loc176 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/idct/Scale.cal":2:3)
#loc177 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/idct/scaled_1d_idct.cal":51:2)
#loc178 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/idct/scaled_1d_idct.cal":59:14)
#loc179 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/idct/scaled_1d_idct.cal":59:12)
#loc180 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/idct/scaled_1d_idct.cal":59:21)
#loc181 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/idct/scaled_1d_idct.cal":59:19)
#loc182 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/idct/scaled_1d_idct.cal":60:14)
#loc183 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/idct/scaled_1d_idct.cal":60:12)
#loc184 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/idct/scaled_1d_idct.cal":60:21)
#loc185 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/idct/scaled_1d_idct.cal":60:19)
#loc186 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/idct/scaled_1d_idct.cal":61:8)
#loc187 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/idct/scaled_1d_idct.cal":61:21)
#loc188 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/idct/scaled_1d_idct.cal":61:19)
#loc189 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/idct/scaled_1d_idct.cal":61:14)
#loc190 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/idct/scaled_1d_idct.cal":62:8)
#loc191 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/idct/scaled_1d_idct.cal":62:21)
#loc192 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/idct/scaled_1d_idct.cal":62:19)
#loc193 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/idct/scaled_1d_idct.cal":62:14)
#loc194 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/idct/scaled_1d_idct.cal":63:8)
#loc195 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/idct/scaled_1d_idct.cal":63:21)
#loc196 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/idct/scaled_1d_idct.cal":63:19)
#loc197 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/idct/scaled_1d_idct.cal":63:14)
#loc198 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/idct/scaled_1d_idct.cal":64:8)
#loc199 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/idct/scaled_1d_idct.cal":64:21)
#loc200 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/idct/scaled_1d_idct.cal":64:19)
#loc201 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/idct/scaled_1d_idct.cal":64:14)
#loc202 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/idct/scaled_1d_idct.cal":66:26)
#loc203 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/idct/scaled_1d_idct.cal":66:24)
#loc204 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/idct/scaled_1d_idct.cal":66:15)
#loc205 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/idct/scaled_1d_idct.cal":67:26)
#loc206 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/idct/scaled_1d_idct.cal":67:24)
#loc207 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/idct/scaled_1d_idct.cal":67:15)
#loc208 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/idct/scaled_1d_idct.cal":68:26)
#loc209 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/idct/scaled_1d_idct.cal":68:24)
#loc210 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/idct/scaled_1d_idct.cal":68:15)
#loc211 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/idct/scaled_1d_idct.cal":69:26)
#loc212 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/idct/scaled_1d_idct.cal":69:24)
#loc213 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/idct/scaled_1d_idct.cal":69:15)
#loc214 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/idct/scaled_1d_idct.cal":71:8)
#loc215 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/idct/scaled_1d_idct.cal":71:14)
#loc216 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/idct/scaled_1d_idct.cal":72:8)
#loc217 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/idct/scaled_1d_idct.cal":72:14)
#loc218 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/idct/scaled_1d_idct.cal":74:26)
#loc219 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/idct/scaled_1d_idct.cal":74:24)
#loc220 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/idct/scaled_1d_idct.cal":74:15)
#loc221 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/idct/scaled_1d_idct.cal":75:26)
#loc222 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/idct/scaled_1d_idct.cal":75:24)
#loc223 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/idct/scaled_1d_idct.cal":75:15)
#loc224 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/idct/scaled_1d_idct.cal":76:26)
#loc225 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/idct/scaled_1d_idct.cal":76:24)
#loc226 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/idct/scaled_1d_idct.cal":76:15)
#loc227 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/idct/scaled_1d_idct.cal":77:26)
#loc228 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/idct/scaled_1d_idct.cal":77:24)
#loc229 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/idct/scaled_1d_idct.cal":77:15)
#loc230 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/idct/scaled_1d_idct.cal":80:8)
#loc231 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/idct/scaled_1d_idct.cal":80:14)
#loc232 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/idct/scaled_1d_idct.cal":81:8)
#loc233 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/idct/scaled_1d_idct.cal":81:14)
#loc234 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/idct/scaled_1d_idct.cal":83:26)
#loc235 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/idct/scaled_1d_idct.cal":83:24)
#loc236 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/idct/scaled_1d_idct.cal":83:15)
#loc237 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/idct/scaled_1d_idct.cal":84:26)
#loc238 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/idct/scaled_1d_idct.cal":84:24)
#loc239 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/idct/scaled_1d_idct.cal":84:15)
#loc240 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/idct/scaled_1d_idct.cal":85:26)
#loc241 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/idct/scaled_1d_idct.cal":85:24)
#loc242 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/idct/scaled_1d_idct.cal":85:15)
#loc243 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/idct/scaled_1d_idct.cal":86:26)
#loc244 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/idct/scaled_1d_idct.cal":86:24)
#loc245 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/idct/scaled_1d_idct.cal":86:15)
#loc246 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/idct/scaled_1d_idct.cal":88:8)
#loc247 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/idct/scaled_1d_idct.cal":88:14)
#loc248 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/idct/scaled_1d_idct.cal":89:8)
#loc249 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/idct/scaled_1d_idct.cal":89:14)
#loc250 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/idct/scaled_1d_idct.cal":91:14)
#loc251 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/idct/scaled_1d_idct.cal":91:12)
#loc252 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/idct/scaled_1d_idct.cal":91:21)
#loc253 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/idct/scaled_1d_idct.cal":91:19)
#loc254 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/idct/scaled_1d_idct.cal":92:14)
#loc255 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/idct/scaled_1d_idct.cal":92:12)
#loc256 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/idct/scaled_1d_idct.cal":92:21)
#loc257 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/idct/scaled_1d_idct.cal":92:19)
#loc258 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/idct/scaled_1d_idct.cal":94:8)
#loc259 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/idct/scaled_1d_idct.cal":94:21)
#loc260 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/idct/scaled_1d_idct.cal":94:19)
#loc261 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/idct/scaled_1d_idct.cal":94:14)
#loc262 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/idct/scaled_1d_idct.cal":95:8)
#loc263 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/idct/scaled_1d_idct.cal":95:21)
#loc264 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/idct/scaled_1d_idct.cal":95:19)
#loc265 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/idct/scaled_1d_idct.cal":95:14)
#loc266 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/idct/scaled_1d_idct.cal":97:8)
#loc267 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/idct/scaled_1d_idct.cal":97:21)
#loc268 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/idct/scaled_1d_idct.cal":97:19)
#loc269 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/idct/scaled_1d_idct.cal":97:14)
#loc270 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/idct/scaled_1d_idct.cal":98:8)
#loc271 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/idct/scaled_1d_idct.cal":98:21)
#loc272 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/idct/scaled_1d_idct.cal":98:19)
#loc273 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/idct/scaled_1d_idct.cal":98:14)
#loc274 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/idct/scaled_1d_idct.cal":100:14)
#loc275 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/idct/scaled_1d_idct.cal":100:12)
#loc276 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/idct/scaled_1d_idct.cal":100:21)
#loc277 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/idct/scaled_1d_idct.cal":100:19)
#loc278 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/idct/scaled_1d_idct.cal":100:27)
#loc279 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/idct/scaled_1d_idct.cal":100:25)
#loc280 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/idct/scaled_1d_idct.cal":100:34)
#loc281 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/idct/scaled_1d_idct.cal":100:32)
#loc282 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/idct/scaled_1d_idct.cal":100:40)
#loc283 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/idct/scaled_1d_idct.cal":100:38)
#loc284 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/idct/scaled_1d_idct.cal":100:47)
#loc285 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/idct/scaled_1d_idct.cal":100:45)
#loc286 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/idct/scaled_1d_idct.cal":100:53)
#loc287 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/idct/scaled_1d_idct.cal":100:51)
#loc288 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/idct/scaled_1d_idct.cal":100:60)
#loc289 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/idct/scaled_1d_idct.cal":100:58)
#loc290 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/idct/scaled_1d_idct.cal":100:66)
#loc291 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/idct/scaled_1d_idct.cal":100:64)
#loc292 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/idct/scaled_1d_idct.cal":100:73)
#loc293 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/idct/scaled_1d_idct.cal":100:71)
#loc294 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/idct/scaled_1d_idct.cal":100:79)
#loc295 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/idct/scaled_1d_idct.cal":100:77)
#loc296 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/idct/scaled_1d_idct.cal":100:86)
#loc297 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/idct/scaled_1d_idct.cal":100:84)
#loc298 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/idct/scaled_1d_idct.cal":100:92)
#loc299 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/idct/scaled_1d_idct.cal":100:90)
#loc300 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/idct/scaled_1d_idct.cal":100:99)
#loc301 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/idct/scaled_1d_idct.cal":100:97)
#loc302 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/idct/scaled_1d_idct.cal":100:105)
#loc303 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/idct/scaled_1d_idct.cal":100:103)
#loc304 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/idct/scaled_1d_idct.cal":100:112)
#loc305 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/idct/scaled_1d_idct.cal":100:110)
#loc306 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/idct/scaled_1d_idct.cal":51:55)
#loc307 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/idct/scaled_1d_idct.cal":5:2)
#loc308 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/idct/Clip.cal":6:3)
#loc309 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/idct/Clip.cal":19:26)
#loc310 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/idct/Clip.cal":19:31)
#loc311 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/idct/Clip.cal":7:10)
#loc312 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/idct/Clip.cal":7:17)
#loc313 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/idct/Clip.cal":8:9)
#loc314 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/idct/Clip.cal":10:12)
#loc315 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/idct/Clip.cal":10:28)
#loc316 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/idct/Clip.cal":10:35)
#loc317 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/idct/Clip.cal":11:11)
#loc318 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/idct/Clip.cal":13:14)
#loc319 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/idct/Clip.cal":13:22)
#loc320 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/idct/Clip.cal":13:21)
#loc321 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/idct/Clip.cal":14:14)
#loc322 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/idct/Clip.cal":14:13)
#loc323 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/idct/Clip.cal":16:13)
#loc324 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/idct/Clip.cal":3:2)
#loc325 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/idct/TopIDCT.cal":1:1)