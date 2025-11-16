module {
  cal.actor @fft__Print()
    in_names ["In"]
    ports_in(%In: !fifo.output_port<f32>)
  {
    cal.action "$untagged0" priority=0 {
      %t0 = fifo.pop(%In: !fifo.output_port<f32> ) : f32 loc(#loc0)
      fifo.print("Value: %f\n\00", %t0) : (f32) loc(#loc1)
    } loc(#loc2)
  } loc(#loc3)
  cal.network @fft__Top()
  {
    %t0 = arith.constant 20.0 : f32 loc(#loc4)
    %t1 = arith.constant 30.0 : f32 loc(#loc5)
    %t2 = arith.constant 70.0 : f32 loc(#loc6)
    %t3 = arith.constant 256 : i32 loc(#loc7)
    %t4 = arith.constant 8 : i32 loc(#loc8)
    %t5 = arith.constant 16.0 : f32 loc(#loc9)
    %add1 = cal.instantiate @fft__Add__T_f32 instance("add1") : !cal.instance<@fft__Add__T_f32>
    %add2 = cal.instantiate @fft__Add__T_f32 instance("add2") : !cal.instance<@fft__Add__T_f32>
    %t6 = arith.constant 2.0 : f32 loc(#loc10)
    %t7 = arith.constant 3.14 : f32 loc(#loc11)
    %t8 = arith.mulf %t6, %t7 : f32 loc(#loc12)
    %t9 = arith.divf %t8, %t0 : f32 loc(#loc12)
    %s1 = cal.instantiate @fft__Sine (%t9 : f32) instance("s1") : !cal.instance<@fft__Sine>
    %t10 = arith.constant 2.0 : f32 loc(#loc13)
    %t11 = arith.constant 3.14 : f32 loc(#loc14)
    %t12 = arith.mulf %t10, %t11 : f32 loc(#loc15)
    %t13 = arith.divf %t12, %t1 : f32 loc(#loc15)
    %s2 = cal.instantiate @fft__Sine (%t13 : f32) instance("s2") : !cal.instance<@fft__Sine>
    %t14 = arith.constant 2.0 : f32 loc(#loc16)
    %t15 = arith.constant 3.14 : f32 loc(#loc17)
    %t16 = arith.mulf %t14, %t15 : f32 loc(#loc18)
    %t17 = arith.divf %t16, %t2 : f32 loc(#loc18)
    %s3 = cal.instantiate @fft__Sine (%t17 : f32) instance("s3") : !cal.instance<@fft__Sine>
    %t18 = arith.constant 1.0 : f32 loc(#loc19)
    %t19 = arith.divf %t18, %t5 : f32 loc(#loc19)
    %dft = cal.instantiate @fft__ButterflyFFT (%t4, %t19 : i32, f32) instance("dft") : !cal.instance<@fft__ButterflyFFT>
    %p = cal.instantiate @fft__Print instance("p") : !cal.instance<@fft__Print>
    cal.connect %s1 : !cal.instance<@fft__Sine> "Out" -> %add1 : !cal.instance<@fft__Add__T_f32> "A" capacity(4096)
    cal.connect %s2 : !cal.instance<@fft__Sine> "Out" -> %add1 : !cal.instance<@fft__Add__T_f32> "B" capacity(4096)
    cal.connect %add1 : !cal.instance<@fft__Add__T_f32> "Out" -> %add2 : !cal.instance<@fft__Add__T_f32> "A" capacity(4096)
    cal.connect %s3 : !cal.instance<@fft__Sine> "Out" -> %add2 : !cal.instance<@fft__Add__T_f32> "B" capacity(4096)
    cal.connect %add2 : !cal.instance<@fft__Add__T_f32> "Out" -> %dft : !cal.instance<@fft__ButterflyFFT> "In" capacity(4096)
    cal.connect %dft : !cal.instance<@fft__ButterflyFFT> "Out" -> %p : !cal.instance<@fft__Print> "In" capacity(4096)
  } loc(#loc20)
  cal.actor @fft__Add__T_f32()
    in_names ["A", "B"]
    out_names ["Out"]
    ports_in(%A: !fifo.output_port<f32>, %B: !fifo.output_port<f32>)
    ports_out(%Out: !fifo.input_port<f32>)
  {
    cal.action "$untagged0" priority=0 {
      %t0 = fifo.pop(%A: !fifo.output_port<f32> ) : f32 loc(#loc21)
      %t1 = fifo.pop(%B: !fifo.output_port<f32> ) : f32 loc(#loc22)
      %t2 = arith.addf %t0, %t1 : f32 loc(#loc23)
      fifo.push(%Out: !fifo.input_port<f32>, %t2: f32)
    } loc(#loc24)
  } loc(#loc25)
  cal.actor @fft__Sine(%d: f32)
    out_names ["Out"]
    ports_out(%Out: !fifo.input_port<f32>)
  {
    %t0 = cal.create_state_var<f32> : !cal.state_ref<f32>
    %t1 = arith.constant 0.0 : f32 loc(#loc26)
    cal.set(%t0: !cal.state_ref<f32>, %t1: f32)
    cal.action "$untagged0" priority=0 {
      %t2 = cal.get(%t0: !cal.state_ref<f32>) : f32
      %t3 = arith.addf %t2, %d : f32 loc(#loc27)
      cal.set(%t0: !cal.state_ref<f32>, %t3: f32)
      %t4 = cal.get(%t0: !cal.state_ref<f32>) : f32
      %t5 = cal.get(%t0: !cal.state_ref<f32>) : f32
      %t6 = math.sin %t5 : f32 loc(#loc28)
      fifo.push(%Out: !fifo.input_port<f32>, %t6: f32)
    } loc(#loc29)
  } loc(#loc30)
  cal.network @fft__ButterflyFFT(%NSTAGES: i32, %scale: f32)
    in_names ["In"]
    out_names ["Out"]
    ports_in(%In: !fifo.output_port<f32>)
    ports_out(%Out: !fifo.input_port<f32>)
  {
    %bf = cal.instantiate @fft__Butterfly (%NSTAGES : i32) instance("bf") : !cal.instance<@fft__Butterfly>
    %scaler = cal.instantiate @fft__ConstantMultiply__T_f32 (%scale : f32) instance("scaler") : !cal.instance<@fft__ConstantMultiply__T_f32>
    cal.connect %In : !fifo.output_port<f32> "out" -> %bf : !cal.instance<@fft__Butterfly> "In" capacity(4096)
    cal.connect %bf : !cal.instance<@fft__Butterfly> "Out" -> %scaler : !cal.instance<@fft__ConstantMultiply__T_f32> "In" capacity(4096)
    cal.connect %scaler : !cal.instance<@fft__ConstantMultiply__T_f32> "Out" -> %Out : !fifo.input_port<f32> "in" capacity(4096)
  } loc(#loc31)
  func.func @fft__Butterfly__fn_pow2(%a: i32) -> i32 attributes { cal.ns = "fft", cal.owner = "Butterfly" } {
    %t0 = arith.constant 0 : i32 loc(#loc33)
    %t1 = arith.cmpi eq, %a, %t0 : i32 loc(#loc34)
    %t8 = scf.if %t1 -> i32 {
      %t2 = arith.constant 1 : i32 loc(#loc35)
      scf.yield %t2 : i32
    } else {
      %t3 = arith.constant 2 : i32 loc(#loc36)
      %t4 = arith.constant 1 : i32 loc(#loc37)
      %t5 = arith.subi %a, %t4 : i32 loc(#loc38)
      %t6 = func.call @fft__Butterfly__fn_pow2(%t5) : (i32) -> i32 loc(#loc39)
      %t7 = arith.muli %t3, %t6 : i32 loc(#loc36)
      scf.yield %t7 : i32
    }
    return %t8 : i32
  } loc(#loc32)
  cal.network @fft__Butterfly(%NSTAGES: i32)
    in_names ["In"]
    out_names ["Out"]
    ports_in(%In: !fifo.output_port<f32>)
    ports_out(%Out: !fifo.input_port<f32>)
  {
    %t0 = arith.constant 1 : i32 loc(#loc40)
    %t1 = arith.subi %NSTAGES, %t0 : i32 loc(#loc41)
    %t2 = func.call @fft__Butterfly__fn_pow2(%t1) : (i32) -> i32 loc(#loc42)
    %t3 = arith.constant 1 : i32 loc(#loc43)
    %t4 = arith.cmpi ugt, %NSTAGES, %t3 : i32 loc(#loc44)
    %t7 = scf.if %t4 -> i32 {
      %t5 = arith.constant 2 : i32 loc(#loc45)
      scf.yield %t5 : i32
    } else {
      %t6 = arith.constant 0 : i32 loc(#loc46)
      scf.yield %t6 : i32
    }
    %split = cal.instantiate @fft__Split__T_f32 (%t2 : i32) instance("split") : !cal.instance<@fft__Split__T_f32>
    %merge = cal.instantiate @fft__Merge__T_f32 instance("merge") : !cal.instance<@fft__Merge__T_f32>
    %twiddles = cal.instantiate @fft__TwiddleGenerator__T_f32 (%t2 : i32) instance("twiddles") : !cal.instance<@fft__TwiddleGenerator__T_f32>
    %r2cell = cal.instantiate @fft__Radix2Cell__T_f32 instance("r2cell") : !cal.instance<@fft__Radix2Cell__T_f32>
    %t8 = arith.constant 0 : i32 loc(#loc47)
    %t9 = arith.index_cast %t8 : i32 to index
    %t10 = arith.constant 1 : i32 loc(#loc48)
    %t11 = arith.subi %t7, %t10 : i32 loc(#loc49)
    %t12 = arith.index_cast %t11 : i32 to index
    %t13 = arith.constant 1 : index
    %t14 = arith.subi %t12, %t9 : index
    %t15 = arith.addi %t14, %t13 : index
    %t16 = arith.addi %t9, %t15 : index
    %t17 = cal.instance.array.init(%t15 : index) : !cal.instance.array<@fft__Butterfly, [?]>
    %bf = scf.for %t18 = %t9 to %t16 step %t13 iter_args(%acc = %t17) -> !cal.instance.array<@fft__Butterfly, [?]> {
      %t19 = arith.subi %t18, %t9 : index
      %t21 = arith.index_cast %t18 : index to i32
      %t22 = arith.constant 1 : i32 loc(#loc50)
      %t23 = arith.subi %NSTAGES, %t22 : i32 loc(#loc51)
      %t20 = cal.instantiate @fft__Butterfly (%t23 : i32) : !cal.instance<@fft__Butterfly>
      %t24 = cal.instance.array.set %acc[%t19], %t20 : !cal.instance.array<@fft__Butterfly, [?]>, !cal.instance<@fft__Butterfly> -> !cal.instance.array<@fft__Butterfly, [?]>
      scf.yield %t24 : !cal.instance.array<@fft__Butterfly, [?]>
    }
    cal.connect %In : !fifo.output_port<f32> "out" -> %split : !cal.instance<@fft__Split__T_f32> "In" capacity(4096)
    cal.connect %In : !fifo.output_port<f32> "out" -> %twiddles : !cal.instance<@fft__TwiddleGenerator__T_f32> "Trigger" capacity(4096)
    cal.connect %merge : !cal.instance<@fft__Merge__T_f32> "Out" -> %Out : !fifo.input_port<f32> "in" capacity(4096)
    cal.connect %split : !cal.instance<@fft__Split__T_f32> "A" -> %r2cell : !cal.instance<@fft__Radix2Cell__T_f32> "X0" capacity(4096)
    cal.connect %split : !cal.instance<@fft__Split__T_f32> "B" -> %r2cell : !cal.instance<@fft__Radix2Cell__T_f32> "X1" capacity(4096)
    cal.connect %twiddles : !cal.instance<@fft__TwiddleGenerator__T_f32> "W" -> %r2cell : !cal.instance<@fft__Radix2Cell__T_f32> "W" capacity(4096)
    %t25 = arith.constant 1 : i32 loc(#loc52)
    %t26 = arith.cmpi ugt, %NSTAGES, %t25 : i32 loc(#loc53)
    scf.if %t26 {
      %t27 = arith.constant 0 : i32 loc(#loc54)
      %t28 = arith.index_cast %t27 : i32 to index
      cal.connect %r2cell : !cal.instance<@fft__Radix2Cell__T_f32> "Y0" -> %bf[%t28] : !cal.instance.array<@fft__Butterfly, [?]> "In" capacity(4096)
      %t29 = arith.constant 1 : i32 loc(#loc55)
      %t30 = arith.index_cast %t29 : i32 to index
      cal.connect %r2cell : !cal.instance<@fft__Radix2Cell__T_f32> "Y1" -> %bf[%t30] : !cal.instance.array<@fft__Butterfly, [?]> "In" capacity(4096)
      %t31 = arith.constant 0 : i32 loc(#loc56)
      %t32 = arith.index_cast %t31 : i32 to index
      cal.connect %bf[%t32] : !cal.instance.array<@fft__Butterfly, [?]> "Out" -> %merge : !cal.instance<@fft__Merge__T_f32> "A" capacity(4096)
      %t33 = arith.constant 1 : i32 loc(#loc57)
      %t34 = arith.index_cast %t33 : i32 to index
      cal.connect %bf[%t34] : !cal.instance.array<@fft__Butterfly, [?]> "Out" -> %merge : !cal.instance<@fft__Merge__T_f32> "B" capacity(4096)
    } else {
      cal.connect %r2cell : !cal.instance<@fft__Radix2Cell__T_f32> "Y0" -> %merge : !cal.instance<@fft__Merge__T_f32> "A" capacity(4096)
      cal.connect %r2cell : !cal.instance<@fft__Radix2Cell__T_f32> "Y1" -> %merge : !cal.instance<@fft__Merge__T_f32> "B" capacity(4096)
    }
  } loc(#loc58)
  cal.actor @fft__ConstantMultiply__T_f32(%c: f32)
    in_names ["In"]
    out_names ["Out"]
    ports_in(%In: !fifo.output_port<f32>)
    ports_out(%Out: !fifo.input_port<f32>)
  {
    cal.action "$untagged0" priority=0 {
      %t0 = fifo.pop(%In: !fifo.output_port<f32> ) : f32 loc(#loc59)
      %t1 = arith.mulf %c, %t0 : f32 loc(#loc60)
      fifo.push(%Out: !fifo.input_port<f32>, %t1: f32)
    } loc(#loc61)
  } loc(#loc62)
  cal.actor @fft__Split__T_f32(%N: i32)
    in_names ["In"]
    out_names ["A", "B"]
    ports_in(%In: !fifo.output_port<f32>)
    ports_out(%A: !fifo.input_port<f32>, %B: !fifo.input_port<f32>)
  {
    %t0 = cal.create_state_var<i1> : !cal.state_ref<i1>
    %t1 = arith.constant 1 : i1
    cal.set(%t0: !cal.state_ref<i1>, %t1: i1)
    %t2 = cal.create_state_var<i32> : !cal.state_ref<i32>
    %t3 = arith.constant 0 : i32 loc(#loc63)
    cal.set(%t2: !cal.state_ref<i32>, %t3: i32)
    cal.action "$untagged0" priority=1 {
      cal.predicate {
        %t4 = cal.get(%t0: !cal.state_ref<i1>) : i1
        cal.predicate_result %t4 : i1
      }
      %t5 = fifo.pop(%In: !fifo.output_port<f32> ) : f32 loc(#loc64)
      %t6 = cal.get(%t2: !cal.state_ref<i32>) : i32
      %t7 = arith.constant 1 : i32 loc(#loc65)
      %t8 = arith.addi %t6, %t7 : i32 loc(#loc66)
      cal.set(%t2: !cal.state_ref<i32>, %t8: i32)
      %t9 = cal.get(%t2: !cal.state_ref<i32>) : i32
      %t10 = arith.cmpi uge, %t9, %N : i32 loc(#loc67)
      %t11 = scf.if %t10 -> i1 {
        %t12 = arith.constant 0 : i32 loc(#loc68)
        cal.set(%t2: !cal.state_ref<i32>, %t12: i32)
        %t13 = arith.constant 0 : i1
        cal.set(%t0: !cal.state_ref<i1>, %t13: i1)
        %t14 = arith.constant 1 : i1
        scf.yield %t14 : i1
      } else {
        %t15 = arith.constant 0 : i1
        scf.yield %t15 : i1
      }
      fifo.push(%A: !fifo.input_port<f32>, %t5: f32)
    } loc(#loc69)
    cal.action "$untagged1" priority=1 {
      cal.predicate {
        %t16 = cal.get(%t0: !cal.state_ref<i1>) : i1
        %t17 = arith.constant 1 : i1
        %t18 = arith.xori %t16, %t17 : i1 loc(#loc70)
        cal.predicate_result %t18 : i1
      }
      %t19 = fifo.pop(%In: !fifo.output_port<f32> ) : f32 loc(#loc71)
      %t20 = cal.get(%t2: !cal.state_ref<i32>) : i32
      %t21 = arith.constant 1 : i32 loc(#loc72)
      %t22 = arith.addi %t20, %t21 : i32 loc(#loc73)
      cal.set(%t2: !cal.state_ref<i32>, %t22: i32)
      %t23 = cal.get(%t2: !cal.state_ref<i32>) : i32
      %t24 = arith.cmpi uge, %t23, %N : i32 loc(#loc74)
      %t25 = scf.if %t24 -> i1 {
        %t26 = arith.constant 0 : i32 loc(#loc75)
        cal.set(%t2: !cal.state_ref<i32>, %t26: i32)
        %t27 = arith.constant 1 : i1
        cal.set(%t0: !cal.state_ref<i1>, %t27: i1)
        %t28 = arith.constant 1 : i1
        scf.yield %t28 : i1
      } else {
        %t29 = arith.constant 0 : i1
        scf.yield %t29 : i1
      }
      fifo.push(%B: !fifo.input_port<f32>, %t19: f32)
    } loc(#loc76)
  } loc(#loc77)
  cal.actor @fft__Merge__T_f32()
    in_names ["A", "B"]
    out_names ["Out"]
    ports_in(%A: !fifo.output_port<f32>, %B: !fifo.output_port<f32>)
    ports_out(%Out: !fifo.input_port<f32>)
  {
    cal.fsm {
      cal.state @s0 {
        cal.transition action("A") -> @s1
      } { initial }
      cal.state @s1 {
        cal.transition action("B") -> @s0
      }
    }
    cal.action "A" priority=1 {
      %t0 = fifo.pop(%A: !fifo.output_port<f32> ) : f32 loc(#loc78)
      fifo.push(%Out: !fifo.input_port<f32>, %t0: f32)
    } loc(#loc79)
    cal.action "B" priority=1 {
      %t1 = fifo.pop(%B: !fifo.output_port<f32> ) : f32 loc(#loc80)
      fifo.push(%Out: !fifo.input_port<f32>, %t1: f32)
    } loc(#loc81)
  } loc(#loc82)
  cal.actor @fft__TwiddleGenerator__T_f32(%N: i32)
    in_names ["Trigger"]
    out_names ["W"]
    ports_in(%Trigger: !fifo.output_port<f32>)
    ports_out(%W: !fifo.input_port<f32>)
  {
    %t0 = cal.create_state_var<i32> : !cal.state_ref<i32>
    %t1 = arith.constant 0 : i32 loc(#loc83)
    cal.set(%t0: !cal.state_ref<i32>, %t1: i32)
    %t2 = cal.create_state_var<f32> : !cal.state_ref<f32>
    %t3 = arith.constant 3.1415926535 : f32 loc(#loc84)
    %t4 = arith.negf %t3 : f32 loc(#loc85)
    cal.set(%t2: !cal.state_ref<f32>, %t4: f32)
    %t5 = cal.create_state_var<memref<?xf32>> : !cal.state_ref<memref<?xf32>>
    %t7 = arith.constant 1 : index
    %t6 = memref.alloc(%t7) : memref<?xf32>
    %t8 = arith.constant 0 : i32 loc(#loc86)
    %t9 = cal.get(%t2: !cal.state_ref<f32>) : f32
    %t10 = arith.negf %t9 : f32 loc(#loc87)
    %t11 = arith.constant 0 : i32 // unresolved var k
    %t12 = arith.fptosi %t10 : f32 to i32
    %t13 = arith.muli %t12, %t11 : i32 loc(#loc88)
    %t14 = arith.divui %t13, %N : i32 loc(#loc88)
    %t15 = arith.sitofp %t8 : i32 to f32
    %t16 = arith.sitofp %t14 : i32 to f32
    %t17 = complex.create %t15, %t16 : complex<f32>
    %t18 = complex.exp %t17 : complex<f32> loc(#loc89)
    %t19 = complex.re %t18 : complex<f32>
    %t20 = arith.constant 0 : index
    memref.store %t19, %t6[%t20] : memref<?xf32>
    cal.set(%t5: !cal.state_ref<memref<?xf32>>, %t6: memref<?xf32>)
    cal.action "$untagged0" priority=0 {
      %t21 = fifo.pop(%Trigger: !fifo.output_port<f32> ) : f32 loc(#loc90)
      %t22 = fifo.pop(%Trigger: !fifo.output_port<f32> ) : f32 loc(#loc90)
      %t23 = cal.get(%t0: !cal.state_ref<i32>) : i32
      %t24 = arith.constant 1 : i32 loc(#loc91)
      %t25 = arith.addi %t23, %t24 : i32 loc(#loc92)
      cal.set(%t0: !cal.state_ref<i32>, %t25: i32)
      %t26 = cal.get(%t0: !cal.state_ref<i32>) : i32
      %t27 = arith.cmpi uge, %t26, %N : i32 loc(#loc93)
      %t28 = scf.if %t27 -> i1 {
        %t29 = arith.constant 0 : i32 loc(#loc94)
        cal.set(%t0: !cal.state_ref<i32>, %t29: i32)
        %t30 = arith.constant 1 : i1
        scf.yield %t30 : i1
      } else {
        %t31 = arith.constant 0 : i1
        scf.yield %t31 : i1
      }
      %t32 = cal.get(%t5: !cal.state_ref<memref<?xf32>>) : memref<?xf32>
      %t33 = cal.get(%t0: !cal.state_ref<i32>) : i32
      %t34 = cal.get(%t0: !cal.state_ref<i32>) : i32
      %t35 = arith.index_cast %t34 : i32 to index
      %t36 = memref.load %t32[%t35] : memref<?xf32> loc(#loc95)
      fifo.push(%W: !fifo.input_port<f32>, %t36: f32)
    } loc(#loc96)
  } loc(#loc97)
  cal.actor @fft__Radix2Cell__T_f32()
    in_names ["X0", "X1", "W"]
    out_names ["Y0", "Y1"]
    ports_in(%X0: !fifo.output_port<f32>, %X1: !fifo.output_port<f32>, %W: !fifo.output_port<f32>)
    ports_out(%Y0: !fifo.input_port<f32>, %Y1: !fifo.input_port<f32>)
  {
    cal.action "$untagged0" priority=0 {
      %t0 = fifo.pop(%X0: !fifo.output_port<f32> ) : f32 loc(#loc98)
      %t1 = fifo.pop(%X1: !fifo.output_port<f32> ) : f32 loc(#loc99)
      %t2 = fifo.pop(%W: !fifo.output_port<f32> ) : f32 loc(#loc100)
      %t3 = arith.addf %t0, %t1 : f32 loc(#loc101)
      fifo.push(%Y0: !fifo.input_port<f32>, %t3: f32)
      %t4 = arith.subf %t0, %t1 : f32 loc(#loc102)
      %t5 = arith.mulf %t4, %t2 : f32 loc(#loc102)
      fifo.push(%Y1: !fifo.input_port<f32>, %t5: f32)
    } loc(#loc103)
  } loc(#loc104)
} loc(#loc105)
#loc0 = loc("file:///Users/endrix/git/streamblocks/langium-cal/examples/fft/Top.cal":8:10)
#loc1 = loc("file:///Users/endrix/git/streamblocks/langium-cal/examples/fft/Top.cal":10:4)
#loc2 = loc("file:///Users/endrix/git/streamblocks/langium-cal/examples/fft/Top.cal":8:3)
#loc3 = loc("file:///Users/endrix/git/streamblocks/langium-cal/examples/fft/Top.cal":6:2)
#loc4 = loc("file:///Users/endrix/git/streamblocks/langium-cal/examples/fft/Top.cal":19:14)
#loc5 = loc("file:///Users/endrix/git/streamblocks/langium-cal/examples/fft/Top.cal":20:14)
#loc6 = loc("file:///Users/endrix/git/streamblocks/langium-cal/examples/fft/Top.cal":21:14)
#loc7 = loc("file:///Users/endrix/git/streamblocks/langium-cal/examples/fft/Top.cal":23:12)
#loc8 = loc("file:///Users/endrix/git/streamblocks/langium-cal/examples/fft/Top.cal":24:16)
#loc9 = loc("file:///Users/endrix/git/streamblocks/langium-cal/examples/fft/Top.cal":25:17)
#loc10 = loc("file:///Users/endrix/git/streamblocks/langium-cal/examples/fft/Top.cal":30:18)
#loc11 = loc("file:///Users/endrix/git/streamblocks/langium-cal/examples/fft/Top.cal":30:24)
#loc12 = loc("file:///Users/endrix/git/streamblocks/langium-cal/examples/fft/Top.cal":30:17)
#loc13 = loc("file:///Users/endrix/git/streamblocks/langium-cal/examples/fft/Top.cal":31:18)
#loc14 = loc("file:///Users/endrix/git/streamblocks/langium-cal/examples/fft/Top.cal":31:24)
#loc15 = loc("file:///Users/endrix/git/streamblocks/langium-cal/examples/fft/Top.cal":31:17)
#loc16 = loc("file:///Users/endrix/git/streamblocks/langium-cal/examples/fft/Top.cal":32:18)
#loc17 = loc("file:///Users/endrix/git/streamblocks/langium-cal/examples/fft/Top.cal":32:24)
#loc18 = loc("file:///Users/endrix/git/streamblocks/langium-cal/examples/fft/Top.cal":32:17)
#loc19 = loc("file:///Users/endrix/git/streamblocks/langium-cal/examples/fft/Top.cal":35:56)
#loc20 = loc("file:///Users/endrix/git/streamblocks/langium-cal/examples/fft/Top.cal":15:2)
#loc21 = loc("file:///Users/endrix/git/streamblocks/langium-cal/examples/fft/Add.cal":5:10)
#loc22 = loc("file:///Users/endrix/git/streamblocks/langium-cal/examples/fft/Add.cal":5:17)
#loc23 = loc("file:///Users/endrix/git/streamblocks/langium-cal/examples/fft/Add.cal":5:32)
#loc24 = loc("file:///Users/endrix/git/streamblocks/langium-cal/examples/fft/Add.cal":5:3)
#loc25 = loc("file:///Users/endrix/git/streamblocks/langium-cal/examples/fft/Add.cal":3:2)
#loc26 = loc("file:///Users/endrix/git/streamblocks/langium-cal/examples/fft/Sine.cal":7:14)
#loc27 = loc("file:///Users/endrix/git/streamblocks/langium-cal/examples/fft/Sine.cal":11:9)
#loc28 = loc("file:///Users/endrix/git/streamblocks/langium-cal/examples/fft/Sine.cal":9:19)
#loc29 = loc("file:///Users/endrix/git/streamblocks/langium-cal/examples/fft/Sine.cal":9:3)
#loc30 = loc("file:///Users/endrix/git/streamblocks/langium-cal/examples/fft/Sine.cal":5:2)
#loc31 = loc("file:///Users/endrix/git/streamblocks/langium-cal/examples/fft/ButterflyFFT.cal":4:2)
#loc32 = loc("file:///Users/endrix/git/streamblocks/langium-cal/examples/fft/butterfly/Butterfly.cal":6:3)
#loc33 = loc("file:///Users/endrix/git/streamblocks/langium-cal/examples/fft/butterfly/Butterfly.cal":7:11)
#loc34 = loc("file:///Users/endrix/git/streamblocks/langium-cal/examples/fft/butterfly/Butterfly.cal":7:7)
#loc35 = loc("file:///Users/endrix/git/streamblocks/langium-cal/examples/fft/butterfly/Butterfly.cal":7:18)
#loc36 = loc("file:///Users/endrix/git/streamblocks/langium-cal/examples/fft/butterfly/Butterfly.cal":7:25)
#loc37 = loc("file:///Users/endrix/git/streamblocks/langium-cal/examples/fft/butterfly/Butterfly.cal":7:38)
#loc38 = loc("file:///Users/endrix/git/streamblocks/langium-cal/examples/fft/butterfly/Butterfly.cal":7:34)
#loc39 = loc("file:///Users/endrix/git/streamblocks/langium-cal/examples/fft/butterfly/Butterfly.cal":7:29)
#loc40 = loc("file:///Users/endrix/git/streamblocks/langium-cal/examples/fft/butterfly/Butterfly.cal":10:28)
#loc41 = loc("file:///Users/endrix/git/streamblocks/langium-cal/examples/fft/butterfly/Butterfly.cal":10:18)
#loc42 = loc("file:///Users/endrix/git/streamblocks/langium-cal/examples/fft/butterfly/Butterfly.cal":10:13)
#loc43 = loc("file:///Users/endrix/git/streamblocks/langium-cal/examples/fft/butterfly/Butterfly.cal":11:27)
#loc44 = loc("file:///Users/endrix/git/streamblocks/langium-cal/examples/fft/butterfly/Butterfly.cal":11:17)
#loc45 = loc("file:///Users/endrix/git/streamblocks/langium-cal/examples/fft/butterfly/Butterfly.cal":11:34)
#loc46 = loc("file:///Users/endrix/git/streamblocks/langium-cal/examples/fft/butterfly/Butterfly.cal":11:41)
#loc47 = loc("file:///Users/endrix/git/streamblocks/langium-cal/examples/fft/butterfly/Butterfly.cal":17:64)
#loc48 = loc("file:///Users/endrix/git/streamblocks/langium-cal/examples/fft/butterfly/Butterfly.cal":17:73)
#loc49 = loc("file:///Users/endrix/git/streamblocks/langium-cal/examples/fft/butterfly/Butterfly.cal":17:69)
#loc50 = loc("file:///Users/endrix/git/streamblocks/langium-cal/examples/fft/butterfly/Butterfly.cal":17:45)
#loc51 = loc("file:///Users/endrix/git/streamblocks/langium-cal/examples/fft/butterfly/Butterfly.cal":17:35)
#loc52 = loc("file:///Users/endrix/git/streamblocks/langium-cal/examples/fft/butterfly/Butterfly.cal":28:16)
#loc53 = loc("file:///Users/endrix/git/streamblocks/langium-cal/examples/fft/butterfly/Butterfly.cal":28:6)
#loc54 = loc("file:///Users/endrix/git/streamblocks/langium-cal/examples/fft/butterfly/Butterfly.cal":29:21)
#loc55 = loc("file:///Users/endrix/git/streamblocks/langium-cal/examples/fft/butterfly/Butterfly.cal":30:21)
#loc56 = loc("file:///Users/endrix/git/streamblocks/langium-cal/examples/fft/butterfly/Butterfly.cal":31:7)
#loc57 = loc("file:///Users/endrix/git/streamblocks/langium-cal/examples/fft/butterfly/Butterfly.cal":32:7)
#loc58 = loc("file:///Users/endrix/git/streamblocks/langium-cal/examples/fft/butterfly/Butterfly.cal":3:2)
#loc59 = loc("file:///Users/endrix/git/streamblocks/langium-cal/examples/fft/ConstantMultiply.cal":5:10)
#loc60 = loc("file:///Users/endrix/git/streamblocks/langium-cal/examples/fft/ConstantMultiply.cal":5:26)
#loc61 = loc("file:///Users/endrix/git/streamblocks/langium-cal/examples/fft/ConstantMultiply.cal":5:3)
#loc62 = loc("file:///Users/endrix/git/streamblocks/langium-cal/examples/fft/ConstantMultiply.cal":3:2)
#loc63 = loc("file:///Users/endrix/git/streamblocks/langium-cal/examples/fft/butterfly/Split.cal":6:13)
#loc64 = loc("file:///Users/endrix/git/streamblocks/langium-cal/examples/fft/butterfly/Split.cal":8:10)
#loc65 = loc("file:///Users/endrix/git/streamblocks/langium-cal/examples/fft/butterfly/Split.cal":12:13)
#loc66 = loc("file:///Users/endrix/git/streamblocks/langium-cal/examples/fft/butterfly/Split.cal":12:9)
#loc67 = loc("file:///Users/endrix/git/streamblocks/langium-cal/examples/fft/butterfly/Split.cal":13:7)
#loc68 = loc("file:///Users/endrix/git/streamblocks/langium-cal/examples/fft/butterfly/Split.cal":14:10)
#loc69 = loc("file:///Users/endrix/git/streamblocks/langium-cal/examples/fft/butterfly/Split.cal":8:3)
#loc70 = loc("file:///Users/endrix/git/streamblocks/langium-cal/examples/fft/butterfly/Split.cal":21:4)
#loc71 = loc("file:///Users/endrix/git/streamblocks/langium-cal/examples/fft/butterfly/Split.cal":19:10)
#loc72 = loc("file:///Users/endrix/git/streamblocks/langium-cal/examples/fft/butterfly/Split.cal":23:13)
#loc73 = loc("file:///Users/endrix/git/streamblocks/langium-cal/examples/fft/butterfly/Split.cal":23:9)
#loc74 = loc("file:///Users/endrix/git/streamblocks/langium-cal/examples/fft/butterfly/Split.cal":24:7)
#loc75 = loc("file:///Users/endrix/git/streamblocks/langium-cal/examples/fft/butterfly/Split.cal":25:10)
#loc76 = loc("file:///Users/endrix/git/streamblocks/langium-cal/examples/fft/butterfly/Split.cal":19:3)
#loc77 = loc("file:///Users/endrix/git/streamblocks/langium-cal/examples/fft/butterfly/Split.cal":3:2)
#loc78 = loc("file:///Users/endrix/git/streamblocks/langium-cal/examples/fft/butterfly/Merge.cal":5:13)
#loc79 = loc("file:///Users/endrix/git/streamblocks/langium-cal/examples/fft/butterfly/Merge.cal":5:3)
#loc80 = loc("file:///Users/endrix/git/streamblocks/langium-cal/examples/fft/butterfly/Merge.cal":6:13)
#loc81 = loc("file:///Users/endrix/git/streamblocks/langium-cal/examples/fft/butterfly/Merge.cal":6:3)
#loc82 = loc("file:///Users/endrix/git/streamblocks/langium-cal/examples/fft/butterfly/Merge.cal":3:2)
#loc83 = loc("file:///Users/endrix/git/streamblocks/langium-cal/examples/fft/butterfly/TwiddleGenerator.cal":9:13)
#loc84 = loc("file:///Users/endrix/git/streamblocks/langium-cal/examples/fft/butterfly/TwiddleGenerator.cal":11:15)
#loc85 = loc("file:///Users/endrix/git/streamblocks/langium-cal/examples/fft/butterfly/TwiddleGenerator.cal":11:14)
#loc86 = loc("file:///Users/endrix/git/streamblocks/langium-cal/examples/fft/butterfly/TwiddleGenerator.cal":13:82)
#loc87 = loc("file:///Users/endrix/git/streamblocks/langium-cal/examples/fft/butterfly/TwiddleGenerator.cal":13:86)
#loc88 = loc("file:///Users/endrix/git/streamblocks/langium-cal/examples/fft/butterfly/TwiddleGenerator.cal":13:85)
#loc89 = loc("file:///Users/endrix/git/streamblocks/langium-cal/examples/fft/butterfly/TwiddleGenerator.cal":13:52)
#loc90 = loc("file:///Users/endrix/git/streamblocks/langium-cal/examples/fft/butterfly/TwiddleGenerator.cal":15:10)
#loc91 = loc("file:///Users/endrix/git/streamblocks/langium-cal/examples/fft/butterfly/TwiddleGenerator.cal":17:13)
#loc92 = loc("file:///Users/endrix/git/streamblocks/langium-cal/examples/fft/butterfly/TwiddleGenerator.cal":17:9)
#loc93 = loc("file:///Users/endrix/git/streamblocks/langium-cal/examples/fft/butterfly/TwiddleGenerator.cal":18:7)
#loc94 = loc("file:///Users/endrix/git/streamblocks/langium-cal/examples/fft/butterfly/TwiddleGenerator.cal":19:10)
#loc95 = loc("file:///Users/endrix/git/streamblocks/langium-cal/examples/fft/butterfly/TwiddleGenerator.cal":15:36)
#loc96 = loc("file:///Users/endrix/git/streamblocks/langium-cal/examples/fft/butterfly/TwiddleGenerator.cal":15:3)
#loc97 = loc("file:///Users/endrix/git/streamblocks/langium-cal/examples/fft/butterfly/TwiddleGenerator.cal":7:2)
#loc98 = loc("file:///Users/endrix/git/streamblocks/langium-cal/examples/fft/butterfly/Radix2Cell.cal":5:10)
#loc99 = loc("file:///Users/endrix/git/streamblocks/langium-cal/examples/fft/butterfly/Radix2Cell.cal":5:20)
#loc100 = loc("file:///Users/endrix/git/streamblocks/langium-cal/examples/fft/butterfly/Radix2Cell.cal":5:30)
#loc101 = loc("file:///Users/endrix/git/streamblocks/langium-cal/examples/fft/butterfly/Radix2Cell.cal":5:46)
#loc102 = loc("file:///Users/endrix/git/streamblocks/langium-cal/examples/fft/butterfly/Radix2Cell.cal":5:61)
#loc103 = loc("file:///Users/endrix/git/streamblocks/langium-cal/examples/fft/butterfly/Radix2Cell.cal":5:3)
#loc104 = loc("file:///Users/endrix/git/streamblocks/langium-cal/examples/fft/butterfly/Radix2Cell.cal":3:2)
#loc105 = loc("/Users/endrix/git/streamblocks/langium-cal/examples/fft/Top.cal":1:1)