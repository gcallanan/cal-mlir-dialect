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

  cal.actor @fft__Print()
    in_names ["In"]
    ports_in(%In: !fifo.output_port<complex<f32>>)
  {
    %t0 = cal.create_state_var<i32> : !cal.state_ref<i32>
    %t1 = arith.constant 0 : i32 loc(#loc0)
    cal.set(%t0: !cal.state_ref<i32>, %t1: i32)
    cal.action "$untagged0" priority=0 {
      %t2 = fifo.pop(%In: !fifo.output_port<complex<f32>> ) : complex<f32>
      %t3 = cal.get(%t0: !cal.state_ref<i32>) : i32
      %t4 = complex.re %t2 : complex<f32>
      %t5 = complex.im %t2 : complex<f32>
      fifo.print("%i, Re: %f, Im: %f\n\00", %t3, %t4, %t5) : (i32, f32, f32)
      %t6 = cal.get(%t0: !cal.state_ref<i32>) : i32
      %t7 = arith.constant 1 : i32 loc(#loc2)
      %t8 = arith.addi %t6, %t7 : i32 loc(#loc3)
      cal.set(%t0: !cal.state_ref<i32>, %t8: i32)
    } loc(#loc1)
  } loc(#loc4)
  cal.network @fft__Top()
  {
    %t0 = arith.constant 20.0 : f32 loc(#loc5)
    %t1 = arith.constant 30.0 : f32 loc(#loc6)
    %t2 = arith.constant 70.0 : f32 loc(#loc7)
    %t3 = arith.constant 32768 : i32 loc(#loc8)
    %t4 = arith.constant 8 : i32 loc(#loc9)
    %t5 = arith.constant 16.0 : f32 loc(#loc10)
    %t6 = arith.constant 256 : i32 loc(#loc11)
    %trigger = cal.instantiate @fft__Trigger__v__N_256 (%t6 : i32) instance("trigger") {cal.instance_name = "trigger", cal.class_name = "@fft__Trigger__v__N_256"} : !cal.instance<@fft__Trigger__v__N_256>
    %add1 = cal.instantiate @fft__Add instance("add1") {cal.instance_name = "add1", cal.class_name = "@fft__Add"} : !cal.instance<@fft__Add>
    %add2 = cal.instantiate @fft__Add instance("add2") {cal.instance_name = "add2", cal.class_name = "@fft__Add"} : !cal.instance<@fft__Add>
    %t7 = arith.constant 2.0 : f32 loc(#loc12)
    %t8 = arith.constant 3.14 : f32 loc(#loc13)
    %t9 = arith.mulf %t7, %t8 : f32 loc(#loc14)
    %t10 = arith.divf %t9, %t0 : f32 loc(#loc14)
    %s1 = cal.instantiate @fft__Sine__v__d_dyn (%t10 : f32) instance("s1") {cal.instance_name = "s1", cal.class_name = "@fft__Sine__v__d_dyn"} : !cal.instance<@fft__Sine__v__d_dyn>
    %t11 = arith.constant 2.0 : f32 loc(#loc15)
    %t12 = arith.constant 3.14 : f32 loc(#loc16)
    %t13 = arith.mulf %t11, %t12 : f32 loc(#loc17)
    %t14 = arith.divf %t13, %t1 : f32 loc(#loc17)
    %s2 = cal.instantiate @fft__Sine__v__d_dyn (%t14 : f32) instance("s2") {cal.instance_name = "s2", cal.class_name = "@fft__Sine__v__d_dyn"} : !cal.instance<@fft__Sine__v__d_dyn>
    %t15 = arith.constant 2.0 : f32 loc(#loc18)
    %t16 = arith.constant 3.14 : f32 loc(#loc19)
    %t17 = arith.mulf %t15, %t16 : f32 loc(#loc20)
    %t18 = arith.divf %t17, %t2 : f32 loc(#loc20)
    %s3 = cal.instantiate @fft__Sine__v__d_dyn (%t18 : f32) instance("s3") {cal.instance_name = "s3", cal.class_name = "@fft__Sine__v__d_dyn"} : !cal.instance<@fft__Sine__v__d_dyn>
    %t19 = arith.constant 1.0 : f32 loc(#loc21)
    %t20 = arith.divf %t19, %t5 : f32 loc(#loc21)
    %dft = cal.instantiate @fft__ButterflyFFT (%t4, %t20 : i32, f32) instance("dft") {cal.instance_name = "dft", cal.class_name = "@fft__ButterflyFFT"} : !cal.instance<@fft__ButterflyFFT>
    %p = cal.instantiate @fft__Print instance("p") {cal.instance_name = "p", cal.class_name = "@fft__Print"} : !cal.instance<@fft__Print>
    cal.connect %trigger : !cal.instance<@fft__Trigger__v__N_256> "Trigger" -> %s1 : !cal.instance<@fft__Sine__v__d_dyn> "Trigger" capacity(4096)
    cal.connect %trigger : !cal.instance<@fft__Trigger__v__N_256> "Trigger" -> %s2 : !cal.instance<@fft__Sine__v__d_dyn> "Trigger" capacity(4096)
    cal.connect %trigger : !cal.instance<@fft__Trigger__v__N_256> "Trigger" -> %s3 : !cal.instance<@fft__Sine__v__d_dyn> "Trigger" capacity(4096)
    cal.connect %s1 : !cal.instance<@fft__Sine__v__d_dyn> "Out" -> %add1 : !cal.instance<@fft__Add> "A" capacity(4096)
    cal.connect %s2 : !cal.instance<@fft__Sine__v__d_dyn> "Out" -> %add1 : !cal.instance<@fft__Add> "B" capacity(4096)
    cal.connect %add1 : !cal.instance<@fft__Add> "Out" -> %add2 : !cal.instance<@fft__Add> "A" capacity(4096)
    cal.connect %s3 : !cal.instance<@fft__Sine__v__d_dyn> "Out" -> %add2 : !cal.instance<@fft__Add> "B" capacity(4096)
    cal.connect %add2 : !cal.instance<@fft__Add> "Out" -> %dft : !cal.instance<@fft__ButterflyFFT> "In" capacity(4096)
    cal.connect %dft : !cal.instance<@fft__ButterflyFFT> "Out" -> %p : !cal.instance<@fft__Print> "In" capacity(4096)
  }
  cal.actor @fft__Add()
    in_names ["A", "B"]
    out_names ["Out"]
    ports_in(%A: !fifo.output_port<complex<f32>>, %B: !fifo.output_port<complex<f32>>)
    ports_out(%Out: !fifo.input_port<complex<f32>>)
  {
    cal.action "$untagged0" priority=0 {
      %t0 = fifo.pop(%A: !fifo.output_port<complex<f32>> ) : complex<f32>
      %t1 = fifo.pop(%B: !fifo.output_port<complex<f32>> ) : complex<f32>
      %t2 = complex.add %t0, %t1 : complex<f32> loc(#loc23)
      fifo.push(%Out: !fifo.input_port<complex<f32>>, %t2: complex<f32>)
    } loc(#loc22)
  } loc(#loc24)
  cal.actor @fft__Merge()
    in_names ["A", "B"]
    out_names ["Out"]
    ports_in(%A: !fifo.output_port<complex<f32>>, %B: !fifo.output_port<complex<f32>>)
    ports_out(%Out: !fifo.input_port<complex<f32>>)
  {
    %t0 = cal.create_state_var<i32> : !cal.state_ref<i32>
    %t1 = arith.constant 0 : i32 loc(#loc25)
    cal.set(%t0: !cal.state_ref<i32>, %t1: i32)
    cal.action "A" priority=1 {
      cal.predicate {
        %t2 = cal.get(%t0: !cal.state_ref<i32>) : i32
        %t3 = arith.constant 0 : i32 loc(#loc27)
        %t4 = arith.cmpi eq, %t2, %t3 : i32 loc(#loc28)
        cal.predicate_result %t4 : i1
      }
      %t5 = fifo.pop(%A: !fifo.output_port<complex<f32>> ) : complex<f32>
      %t6 = arith.constant 1 : i32 loc(#loc29)
      cal.set(%t0: !cal.state_ref<i32>, %t6: i32)
      fifo.push(%Out: !fifo.input_port<complex<f32>>, %t5: complex<f32>)
    } loc(#loc26)
    cal.action "B" priority=1 {
      cal.predicate {
        %t7 = cal.get(%t0: !cal.state_ref<i32>) : i32
        %t8 = arith.constant 1 : i32 loc(#loc31)
        %t9 = arith.cmpi eq, %t7, %t8 : i32 loc(#loc32)
        cal.predicate_result %t9 : i1
      }
      %t10 = fifo.pop(%B: !fifo.output_port<complex<f32>> ) : complex<f32>
      %t11 = arith.constant 0 : i32 loc(#loc33)
      cal.set(%t0: !cal.state_ref<i32>, %t11: i32)
      fifo.push(%Out: !fifo.input_port<complex<f32>>, %t10: complex<f32>)
    } loc(#loc30)
  } loc(#loc34)
  cal.actor @fft__Radix2Cell()
    in_names ["X0", "X1", "W"]
    out_names ["Y0", "Y1"]
    ports_in(%X0: !fifo.output_port<complex<f32>>, %X1: !fifo.output_port<complex<f32>>, %W: !fifo.output_port<complex<f32>>)
    ports_out(%Y0: !fifo.input_port<complex<f32>>, %Y1: !fifo.input_port<complex<f32>>)
  {
    cal.action "$untagged0" priority=0 {
      %t0 = fifo.pop(%X0: !fifo.output_port<complex<f32>> ) : complex<f32>
      %t1 = fifo.pop(%X1: !fifo.output_port<complex<f32>> ) : complex<f32>
      %t2 = fifo.pop(%W: !fifo.output_port<complex<f32>> ) : complex<f32>
      %t3 = complex.add %t0, %t1 : complex<f32> loc(#loc36)
      fifo.push(%Y0: !fifo.input_port<complex<f32>>, %t3: complex<f32>)
      %t4 = complex.sub %t0, %t1 : complex<f32> loc(#loc37)
      %t5 = complex.mul %t4, %t2 : complex<f32> loc(#loc37)
      fifo.push(%Y1: !fifo.input_port<complex<f32>>, %t5: complex<f32>)
    } loc(#loc35)
  } loc(#loc38)
  cal.actor @fft__Trigger__v__N_256(%N: i32)
    out_names ["Trigger"]
    ports_out(%Trigger: !fifo.input_port<i32>)
  {
    %t0 = cal.create_state_var<i32> : !cal.state_ref<i32>
    %t1 = arith.constant 0 : i32 loc(#loc39)
    cal.set(%t0: !cal.state_ref<i32>, %t1: i32)
    cal.action "$untagged0" priority=0 {
      cal.predicate {
        %t2 = cal.get(%t0: !cal.state_ref<i32>) : i32
        %t3 = arith.cmpi ult, %t2, %N : i32 loc(#loc41)
        cal.predicate_result %t3 : i1
      }
      %t4 = cal.get(%t0: !cal.state_ref<i32>) : i32
      %t5 = arith.constant 1 : i32 loc(#loc42)
      %t6 = arith.addi %t4, %t5 : i32 loc(#loc43)
      cal.set(%t0: !cal.state_ref<i32>, %t6: i32)
      %t7 = cal.get(%t0: !cal.state_ref<i32>) : i32
      %t8 = cal.get(%t0: !cal.state_ref<i32>) : i32
      fifo.push(%Trigger: !fifo.input_port<i32>, %t8: i32)
    } loc(#loc40)
  } loc(#loc44)
  cal.actor @fft__Sine__v__d_dyn(%d: f32)
    in_names ["Trigger"]
    out_names ["Out"]
    ports_in(%Trigger: !fifo.output_port<i32>)
    ports_out(%Out: !fifo.input_port<complex<f32>>)
  {
    %t0 = cal.create_state_var<complex<f32>> : !cal.state_ref<complex<f32>>
    %t1 = arith.constant 0.0 : f32 loc(#loc45)
    %t2 = arith.constant 0.0 : f32 loc(#loc46)
    %t3 = complex.create %t1, %t2 : complex<f32>
    cal.set(%t0: !cal.state_ref<complex<f32>>, %t3: complex<f32>)
    cal.action "$untagged0" priority=0 {
      %t4 = fifo.pop(%Trigger: !fifo.output_port<i32> ) : i32
      %t5 = cal.get(%t0: !cal.state_ref<complex<f32>>) : complex<f32>
      %t6 = arith.constant 0.0 : f32
      %t7 = complex.create %d, %t6 : complex<f32> loc(#loc48)
      %t8 = complex.add %t5, %t7 : complex<f32> loc(#loc48)
      cal.set(%t0: !cal.state_ref<complex<f32>>, %t8: complex<f32>)
      %t9 = cal.get(%t0: !cal.state_ref<complex<f32>>) : complex<f32>
      %t10 = cal.get(%t0: !cal.state_ref<complex<f32>>) : complex<f32>
      %t11 = complex.sin %t10 : complex<f32>
      fifo.push(%Out: !fifo.input_port<complex<f32>>, %t11: complex<f32>)
    } loc(#loc47)
  } loc(#loc49)
  cal.network @fft__ButterflyFFT(%NSTAGES: i32, %scale: f32)
    in_names ["In"]
    out_names ["Out"]
    ports_in(%In: !fifo.output_port<complex<f32>>)
    ports_out(%Out: !fifo.input_port<complex<f32>>)
  {
    %bf = cal.instantiate @fft__Butterfly (%NSTAGES : i32) instance("bf") {cal.instance_name = "bf", cal.class_name = "@fft__Butterfly"} : !cal.instance<@fft__Butterfly>
    %scaler = cal.instantiate @fft__ConstantMultiply__v__c_dyn (%scale : f32) instance("scaler") {cal.instance_name = "scaler", cal.class_name = "@fft__ConstantMultiply__v__c_dyn"} : !cal.instance<@fft__ConstantMultiply__v__c_dyn>
    cal.connect %In : !fifo.output_port<complex<f32>> "out" -> %bf : !cal.instance<@fft__Butterfly> "In" capacity(4096)
    cal.connect %bf : !cal.instance<@fft__Butterfly> "Out" -> %scaler : !cal.instance<@fft__ConstantMultiply__v__c_dyn> "In" capacity(4096)
    cal.connect %scaler : !cal.instance<@fft__ConstantMultiply__v__c_dyn> "Out" -> %Out : !fifo.input_port<complex<f32>> "in" capacity(4096)
  }
  func.func @fft__Butterfly__fn_pow2(%a: i32) -> i32 attributes { cal.ns = "fft", cal.owner = "Butterfly" } {
    %t0 = arith.constant 0 : i32 loc(#loc50)
    %t1 = arith.cmpi eq, %a, %t0 : i32 loc(#loc51)
    %t8 = scf.if %t1 -> i32 {
      %t2 = arith.constant 1 : i32 loc(#loc52)
      scf.yield %t2 : i32
    } else {
      %t3 = arith.constant 2 : i32 loc(#loc53)
      %t4 = arith.constant 1 : i32 loc(#loc54)
      %t5 = arith.subi %a, %t4 : i32 loc(#loc55)
      %t6 = func.call @fft__Butterfly__fn_pow2(%t5) : (i32) -> i32 loc(#loc56)
      %t7 = arith.muli %t3, %t6 : i32 loc(#loc53)
      scf.yield %t7 : i32
    }
    return %t8 : i32
  }
  cal.network @fft__Butterfly(%NSTAGES: i32)
    in_names ["In"]
    out_names ["Out"]
    ports_in(%In: !fifo.output_port<complex<f32>>)
    ports_out(%Out: !fifo.input_port<complex<f32>>)
  {
    %t0 = arith.constant 1 : i32 loc(#loc57)
    %t1 = arith.subi %NSTAGES, %t0 : i32 loc(#loc58)
    %t2 = func.call @fft__Butterfly__fn_pow2(%t1) : (i32) -> i32 loc(#loc59)
    %t3 = arith.constant 1 : i32 loc(#loc60)
    %t4 = arith.cmpi ugt, %NSTAGES, %t3 : i32 loc(#loc61)
    %t7 = scf.if %t4 -> i32 {
      %t5 = arith.constant 2 : i32 loc(#loc62)
      scf.yield %t5 : i32
    } else {
      %t6 = arith.constant 0 : i32 loc(#loc63)
      scf.yield %t6 : i32
    }
    %split = cal.instantiate @fft__Split__v__N_dyn (%t2 : i32) instance("split") {cal.instance_name = "split", cal.class_name = "@fft__Split__v__N_dyn"} : !cal.instance<@fft__Split__v__N_dyn>
    %merge = cal.instantiate @fft__Merge instance("merge") {cal.instance_name = "merge", cal.class_name = "@fft__Merge"} : !cal.instance<@fft__Merge>
    %twiddles = cal.instantiate @fft__TwiddleGenerator__v__N_dyn (%t2 : i32) instance("twiddles") {cal.instance_name = "twiddles", cal.class_name = "@fft__TwiddleGenerator__v__N_dyn"} : !cal.instance<@fft__TwiddleGenerator__v__N_dyn>
    %r2cell = cal.instantiate @fft__Radix2Cell instance("r2cell") {cal.instance_name = "r2cell", cal.class_name = "@fft__Radix2Cell"} : !cal.instance<@fft__Radix2Cell>
    %t8 = arith.constant 1 : i32 loc(#loc64)
    %t9 = arith.index_cast %t8 : i32 to index
    %t10 = arith.index_cast %t7 : i32 to index
    %t11 = arith.constant 1 : index
    %t12 = arith.subi %t10, %t9 : index
    %t13 = arith.addi %t12, %t11 : index
    %t14 = arith.addi %t9, %t13 : index
    %t15 = cal.instance.array.init(%t13 : index) : !cal.instance.array<@fft__Butterfly, [?]>
    %bf = scf.for %t16 = %t9 to %t14 step %t11 iter_args(%acc = %t15) -> !cal.instance.array<@fft__Butterfly, [?]> {
      %t17 = arith.subi %t16, %t9 : index
      %t19 = arith.index_cast %t16 : index to i32
      %t20 = arith.constant 1 : i32 loc(#loc65)
      %t21 = arith.subi %NSTAGES, %t20 : i32 loc(#loc66)
      %t18 = cal.instantiate @fft__Butterfly (%t21 : i32) : !cal.instance<@fft__Butterfly>
      %t22 = cal.instance.array.set %acc[%t17], %t18 : !cal.instance.array<@fft__Butterfly, [?]>, !cal.instance<@fft__Butterfly> -> !cal.instance.array<@fft__Butterfly, [?]>
      scf.yield %t22 : !cal.instance.array<@fft__Butterfly, [?]>
    }
    cal.connect %In : !fifo.output_port<complex<f32>> "out" -> %split : !cal.instance<@fft__Split__v__N_dyn> "In" capacity(4096)
    cal.connect %In : !fifo.output_port<complex<f32>> "out" -> %twiddles : !cal.instance<@fft__TwiddleGenerator__v__N_dyn> "Trigger" capacity(4096)
    cal.connect %merge : !cal.instance<@fft__Merge> "Out" -> %Out : !fifo.input_port<complex<f32>> "in" capacity(4096)
    cal.connect %split : !cal.instance<@fft__Split__v__N_dyn> "A" -> %r2cell : !cal.instance<@fft__Radix2Cell> "X0" capacity(4096)
    cal.connect %split : !cal.instance<@fft__Split__v__N_dyn> "B" -> %r2cell : !cal.instance<@fft__Radix2Cell> "X1" capacity(4096)
    cal.connect %twiddles : !cal.instance<@fft__TwiddleGenerator__v__N_dyn> "W" -> %r2cell : !cal.instance<@fft__Radix2Cell> "W" capacity(4096)
    %t23 = arith.constant 1 : i32 loc(#loc67)
    %t24 = arith.cmpi ugt, %NSTAGES, %t23 : i32 loc(#loc68)
    scf.if %t24 {
      %t25 = arith.constant 0 : i32 loc(#loc69)
      %t26 = arith.index_cast %t25 : i32 to index
      cal.connect %r2cell : !cal.instance<@fft__Radix2Cell> "Y0" -> %bf[%t26] : !cal.instance.array<@fft__Butterfly, [?]> "In" capacity(4096)
      %t27 = arith.constant 1 : i32 loc(#loc70)
      %t28 = arith.index_cast %t27 : i32 to index
      cal.connect %r2cell : !cal.instance<@fft__Radix2Cell> "Y1" -> %bf[%t28] : !cal.instance.array<@fft__Butterfly, [?]> "In" capacity(4096)
      %t29 = arith.constant 0 : i32 loc(#loc71)
      %t30 = arith.index_cast %t29 : i32 to index
      cal.connect %bf[%t30] : !cal.instance.array<@fft__Butterfly, [?]> "Out" -> %merge : !cal.instance<@fft__Merge> "A" capacity(4096)
      %t31 = arith.constant 1 : i32 loc(#loc72)
      %t32 = arith.index_cast %t31 : i32 to index
      cal.connect %bf[%t32] : !cal.instance.array<@fft__Butterfly, [?]> "Out" -> %merge : !cal.instance<@fft__Merge> "B" capacity(4096)
    } else {
      cal.connect %r2cell : !cal.instance<@fft__Radix2Cell> "Y0" -> %merge : !cal.instance<@fft__Merge> "A" capacity(4096)
      cal.connect %r2cell : !cal.instance<@fft__Radix2Cell> "Y1" -> %merge : !cal.instance<@fft__Merge> "B" capacity(4096)
    }
  }
  cal.actor @fft__ConstantMultiply__v__c_dyn(%c: f32)
    in_names ["In"]
    out_names ["Out"]
    ports_in(%In: !fifo.output_port<complex<f32>>)
    ports_out(%Out: !fifo.input_port<complex<f32>>)
  {
    cal.action "$untagged0" priority=0 {
      %t0 = fifo.pop(%In: !fifo.output_port<complex<f32>> ) : complex<f32>
      %t1 = arith.constant 0.0 : f32
      %t2 = complex.create %c, %t1 : complex<f32> loc(#loc74)
      %t3 = complex.mul %t2, %t0 : complex<f32> loc(#loc74)
      fifo.push(%Out: !fifo.input_port<complex<f32>>, %t3: complex<f32>)
    } loc(#loc73)
  } loc(#loc75)
  cal.actor @fft__Split__v__N_dyn(%N: i32)
    in_names ["In"]
    out_names ["A", "B"]
    ports_in(%In: !fifo.output_port<complex<f32>>)
    ports_out(%A: !fifo.input_port<complex<f32>>, %B: !fifo.input_port<complex<f32>>)
  {
    %t0 = cal.create_state_var<i1> : !cal.state_ref<i1>
    %t1 = arith.constant 1 : i1
    cal.set(%t0: !cal.state_ref<i1>, %t1: i1)
    %t2 = cal.create_state_var<i32> : !cal.state_ref<i32>
    %t3 = arith.constant 0 : i32 loc(#loc76)
    cal.set(%t2: !cal.state_ref<i32>, %t3: i32)
    cal.action "$untagged0" priority=1 {
      cal.predicate {
        %t4 = cal.get(%t0: !cal.state_ref<i1>) : i1
        cal.predicate_result %t4 : i1
      }
      %t5 = fifo.pop(%In: !fifo.output_port<complex<f32>> ) : complex<f32>
      %t6 = cal.get(%t2: !cal.state_ref<i32>) : i32
      %t7 = arith.constant 1 : i32 loc(#loc78)
      %t8 = arith.addi %t6, %t7 : i32 loc(#loc79)
      cal.set(%t2: !cal.state_ref<i32>, %t8: i32)
      %t9 = cal.get(%t2: !cal.state_ref<i32>) : i32
      %t10 = arith.cmpi uge, %t9, %N : i32 loc(#loc80)
      %t11 = scf.if %t10 -> i1 {
        %t12 = arith.constant 0 : i32 loc(#loc81)
        cal.set(%t2: !cal.state_ref<i32>, %t12: i32)
        %t13 = arith.constant 0 : i1
        cal.set(%t0: !cal.state_ref<i1>, %t13: i1)
        %t14 = arith.constant 1 : i1
        scf.yield %t14 : i1
      } else {
        %t15 = arith.constant 0 : i1
        scf.yield %t15 : i1
      }
      fifo.push(%A: !fifo.input_port<complex<f32>>, %t5: complex<f32>)
    } loc(#loc77)
    cal.action "$untagged1" priority=1 {
      cal.predicate {
        %t16 = cal.get(%t0: !cal.state_ref<i1>) : i1
        %t17 = arith.constant 1 : i1
        %t18 = arith.xori %t16, %t17 : i1 loc(#loc83)
        cal.predicate_result %t18 : i1
      }
      %t19 = fifo.pop(%In: !fifo.output_port<complex<f32>> ) : complex<f32>
      %t20 = cal.get(%t2: !cal.state_ref<i32>) : i32
      %t21 = arith.constant 1 : i32 loc(#loc84)
      %t22 = arith.addi %t20, %t21 : i32 loc(#loc85)
      cal.set(%t2: !cal.state_ref<i32>, %t22: i32)
      %t23 = cal.get(%t2: !cal.state_ref<i32>) : i32
      %t24 = arith.cmpi uge, %t23, %N : i32 loc(#loc86)
      %t25 = scf.if %t24 -> i1 {
        %t26 = arith.constant 0 : i32 loc(#loc87)
        cal.set(%t2: !cal.state_ref<i32>, %t26: i32)
        %t27 = arith.constant 1 : i1
        cal.set(%t0: !cal.state_ref<i1>, %t27: i1)
        %t28 = arith.constant 1 : i1
        scf.yield %t28 : i1
      } else {
        %t29 = arith.constant 0 : i1
        scf.yield %t29 : i1
      }
      fifo.push(%B: !fifo.input_port<complex<f32>>, %t19: complex<f32>)
    } loc(#loc82)
  } loc(#loc88)
  cal.actor @fft__TwiddleGenerator__v__N_dyn(%N: i32)
    in_names ["Trigger"]
    out_names ["W"]
    ports_in(%Trigger: !fifo.output_port<complex<f32>>)
    ports_out(%W: !fifo.input_port<complex<f32>>)
  {
    %t0 = cal.create_state_var<i32> : !cal.state_ref<i32>
    %t1 = arith.constant 0 : i32 loc(#loc89)
    cal.set(%t0: !cal.state_ref<i32>, %t1: i32)
    %t2 = cal.create_state_var<f32> : !cal.state_ref<f32>
    %t3 = arith.constant 3.1415926535 : f32 loc(#loc90)
    %t4 = arith.negf %t3 : f32 loc(#loc91)
    cal.set(%t2: !cal.state_ref<f32>, %t4: f32)
    %t6 = arith.index_cast %N : i32 to index
    %t5 = cal.create_state_var<memref<?xcomplex<f32>>>(%t6 : index) : !cal.state_ref<memref<?xcomplex<f32>>>
    %t7 = cal.get(%t5: !cal.state_ref<memref<?xcomplex<f32>>>) : memref<?xcomplex<f32>>
    %t8 = arith.constant 0 : i32 loc(#loc92)
    %t9 = arith.constant 1 : i32 loc(#loc93)
    %t10 = arith.subi %N, %t9 : i32 loc(#loc94)
    %t11 = arith.index_cast %t8 : i32 to index
    %t12 = arith.index_cast %t10 : i32 to index
    %t13 = arith.constant 1 : index
    %t14 = arith.addi %t12, %t13 : index
    %t15 = arith.constant 1 : index
    scf.for %t16 = %t11 to %t14 step %t15 {
      %t17 = arith.index_cast %t16 : index to i32
      %t18 = arith.constant 0 : i32 loc(#loc95)
      %t19 = cal.get(%t2: !cal.state_ref<f32>) : f32
      %t20 = arith.negf %t19 : f32 loc(#loc96)
      %t21 = arith.fptosi %t20 : f32 to i32
      %t22 = arith.muli %t21, %t17 : i32 loc(#loc97)
      %t23 = arith.divui %t22, %N : i32 loc(#loc97)
      %t24 = arith.sitofp %t18 : i32 to f32
      %t25 = arith.sitofp %t23 : i32 to f32
      %t26 = complex.create %t24, %t25 : complex<f32>
      %t27 = complex.exp %t26 : complex<f32>
      %t29 = arith.subi %t16, %t11 : index
      memref.store %t27, %t7[%t29] : memref<?xcomplex<f32>>
      scf.yield
    }
    cal.action "$untagged0" priority=0 {
      %t30 = fifo.pop(%Trigger: !fifo.output_port<complex<f32>> ) : complex<f32>
      %t31 = fifo.pop(%Trigger: !fifo.output_port<complex<f32>> ) : complex<f32>
      %t32 = cal.get(%t0: !cal.state_ref<i32>) : i32
      %t33 = arith.constant 1 : i32 loc(#loc99)
      %t34 = arith.addi %t32, %t33 : i32 loc(#loc100)
      cal.set(%t0: !cal.state_ref<i32>, %t34: i32)
      %t35 = cal.get(%t0: !cal.state_ref<i32>) : i32
      %t36 = arith.cmpi uge, %t35, %N : i32 loc(#loc101)
      %t37 = scf.if %t36 -> i1 {
        %t38 = arith.constant 0 : i32 loc(#loc102)
        cal.set(%t0: !cal.state_ref<i32>, %t38: i32)
        %t39 = arith.constant 1 : i1
        scf.yield %t39 : i1
      } else {
        %t40 = arith.constant 0 : i1
        scf.yield %t40 : i1
      }
      %t41 = cal.get(%t5: !cal.state_ref<memref<?xcomplex<f32>>>) : memref<?xcomplex<f32>>
      %t42 = cal.get(%t0: !cal.state_ref<i32>) : i32
      %t43 = cal.get(%t0: !cal.state_ref<i32>) : i32
      %t44 = arith.index_cast %t43 : i32 to index
      %t45 = memref.load %t41[%t44] : memref<?xcomplex<f32>> loc(#loc103)
      fifo.push(%W: !fifo.input_port<complex<f32>>, %t45: complex<f32>)
    } loc(#loc98)
  } loc(#loc104)
} loc(#loc105)
#loc0 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/fft/Top.cal":22:18)
#loc1 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/fft/Top.cal":23:3)
#loc2 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/fft/Top.cal":26:25)
#loc3 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/fft/Top.cal":26:15)
#loc4 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/fft/Top.cal":21:2)
#loc5 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/fft/Top.cal":34:14)
#loc6 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/fft/Top.cal":35:14)
#loc7 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/fft/Top.cal":36:14)
#loc8 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/fft/Top.cal":38:12)
#loc9 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/fft/Top.cal":39:16)
#loc10 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/fft/Top.cal":40:17)
#loc11 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/fft/Top.cal":43:25)
#loc12 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/fft/Top.cal":46:18)
#loc13 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/fft/Top.cal":46:24)
#loc14 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/fft/Top.cal":46:17)
#loc15 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/fft/Top.cal":47:18)
#loc16 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/fft/Top.cal":47:24)
#loc17 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/fft/Top.cal":47:17)
#loc18 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/fft/Top.cal":48:18)
#loc19 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/fft/Top.cal":48:24)
#loc20 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/fft/Top.cal":48:17)
#loc21 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/fft/Top.cal":51:47)
#loc22 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/fft/Add.cal":5:3)
#loc23 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/fft/Add.cal":5:32)
#loc24 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/fft/Add.cal":3:2)
#loc25 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/fft/butterfly/Merge.cal":9:20)
#loc26 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/fft/butterfly/Merge.cal":11:3)
#loc27 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/fft/butterfly/Merge.cal":12:20)
#loc28 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/fft/butterfly/Merge.cal":12:9)
#loc29 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/fft/butterfly/Merge.cal":14:16)
#loc30 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/fft/butterfly/Merge.cal":17:3)
#loc31 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/fft/butterfly/Merge.cal":18:20)
#loc32 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/fft/butterfly/Merge.cal":18:9)
#loc33 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/fft/butterfly/Merge.cal":20:16)
#loc34 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/fft/butterfly/Merge.cal":3:2)
#loc35 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/fft/butterfly/Radix2Cell.cal":12:3)
#loc36 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/fft/butterfly/Radix2Cell.cal":12:46)
#loc37 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/fft/butterfly/Radix2Cell.cal":12:61)
#loc38 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/fft/butterfly/Radix2Cell.cal":3:2)
#loc39 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/fft/Top.cal":10:17)
#loc40 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/fft/Top.cal":12:3)
#loc41 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/fft/Top.cal":14:4)
#loc42 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/fft/Top.cal":16:21)
#loc43 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/fft/Top.cal":16:13)
#loc44 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/fft/Top.cal":8:2)
#loc45 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/fft/Sine.cal":12:44)
#loc46 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/fft/Sine.cal":12:49)
#loc47 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/fft/Sine.cal":14:3)
#loc48 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/fft/Sine.cal":16:9)
#loc49 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/fft/Sine.cal":6:2)
#loc50 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/fft/butterfly/Butterfly.cal":9:11)
#loc51 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/fft/butterfly/Butterfly.cal":9:7)
#loc52 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/fft/butterfly/Butterfly.cal":9:18)
#loc53 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/fft/butterfly/Butterfly.cal":9:25)
#loc54 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/fft/butterfly/Butterfly.cal":9:38)
#loc55 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/fft/butterfly/Butterfly.cal":9:34)
#loc56 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/fft/butterfly/Butterfly.cal":9:29)
#loc57 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/fft/butterfly/Butterfly.cal":12:28)
#loc58 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/fft/butterfly/Butterfly.cal":12:18)
#loc59 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/fft/butterfly/Butterfly.cal":12:13)
#loc60 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/fft/butterfly/Butterfly.cal":13:27)
#loc61 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/fft/butterfly/Butterfly.cal":13:17)
#loc62 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/fft/butterfly/Butterfly.cal":13:34)
#loc63 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/fft/butterfly/Butterfly.cal":13:41)
#loc64 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/fft/butterfly/Butterfly.cal":19:58)
#loc65 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/fft/butterfly/Butterfly.cal":19:39)
#loc66 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/fft/butterfly/Butterfly.cal":19:29)
#loc67 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/fft/butterfly/Butterfly.cal":30:16)
#loc68 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/fft/butterfly/Butterfly.cal":30:6)
#loc69 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/fft/butterfly/Butterfly.cal":31:21)
#loc70 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/fft/butterfly/Butterfly.cal":32:21)
#loc71 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/fft/butterfly/Butterfly.cal":33:7)
#loc72 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/fft/butterfly/Butterfly.cal":34:7)
#loc73 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/fft/ConstantMultiply.cal":5:3)
#loc74 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/fft/ConstantMultiply.cal":5:26)
#loc75 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/fft/ConstantMultiply.cal":3:2)
#loc76 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/fft/butterfly/Split.cal":7:13)
#loc77 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/fft/butterfly/Split.cal":9:3)
#loc78 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/fft/butterfly/Split.cal":13:13)
#loc79 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/fft/butterfly/Split.cal":13:9)
#loc80 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/fft/butterfly/Split.cal":14:7)
#loc81 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/fft/butterfly/Split.cal":15:10)
#loc82 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/fft/butterfly/Split.cal":20:3)
#loc83 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/fft/butterfly/Split.cal":22:4)
#loc84 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/fft/butterfly/Split.cal":24:13)
#loc85 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/fft/butterfly/Split.cal":24:9)
#loc86 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/fft/butterfly/Split.cal":25:7)
#loc87 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/fft/butterfly/Split.cal":26:10)
#loc88 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/fft/butterfly/Split.cal":4:2)
#loc89 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/fft/butterfly/TwiddleGenerator.cal":13:13)
#loc90 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/fft/butterfly/TwiddleGenerator.cal":15:15)
#loc91 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/fft/butterfly/TwiddleGenerator.cal":15:14)
#loc92 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/fft/butterfly/TwiddleGenerator.cal":17:119)
#loc93 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/fft/butterfly/TwiddleGenerator.cal":17:128)
#loc94 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/fft/butterfly/TwiddleGenerator.cal":17:124)
#loc95 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/fft/butterfly/TwiddleGenerator.cal":17:84)
#loc96 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/fft/butterfly/TwiddleGenerator.cal":17:88)
#loc97 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/fft/butterfly/TwiddleGenerator.cal":17:87)
#loc98 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/fft/butterfly/TwiddleGenerator.cal":19:3)
#loc99 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/fft/butterfly/TwiddleGenerator.cal":21:13)
#loc100 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/fft/butterfly/TwiddleGenerator.cal":21:9)
#loc101 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/fft/butterfly/TwiddleGenerator.cal":22:7)
#loc102 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/fft/butterfly/TwiddleGenerator.cal":23:10)
#loc103 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/fft/butterfly/TwiddleGenerator.cal":19:36)
#loc104 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/fft/butterfly/TwiddleGenerator.cal":7:2)
#loc105 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/fft/Top.cal":1:1)