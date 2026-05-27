module {
  cal.actor @__fanout_complex_f32__2()
    ports_in (
      %arg0: !fifo.output_port<complex<f32>>
    )
    ports_out (
      %arg1: !fifo.input_port<complex<f32>>, 
      %arg2: !fifo.input_port<complex<f32>>
    )
  {
    cal.action
    {
      %0 = fifo.pop(%arg0 : !fifo.output_port<complex<f32>>) : complex<f32>
      fifo.push(%arg1 : !fifo.input_port<complex<f32>>, %0 : complex<f32>)
      fifo.push(%arg2 : !fifo.input_port<complex<f32>>, %0 : complex<f32>)
    }
    
  }
  
  cal.actor @__fanout_i32_3()
    ports_in (
      %arg0: !fifo.output_port<i32>
    )
    ports_out (
      %arg1: !fifo.input_port<i32>, 
      %arg2: !fifo.input_port<i32>, 
      %arg3: !fifo.input_port<i32>
    )
  {
    cal.action
    {
      %0 = fifo.pop(%arg0 : !fifo.output_port<i32>) : i32
      fifo.push(%arg1 : !fifo.input_port<i32>, %0 : i32)
      fifo.push(%arg2 : !fifo.input_port<i32>, %0 : i32)
      fifo.push(%arg3 : !fifo.input_port<i32>, %0 : i32)
    }
    
  }
  
  cal.actor @fft__Print()
    ports_in (
      %arg0: !fifo.output_port<complex<f32>>
    )
  {
    %c1_i32 = arith.constant 1 : i32
    %c0_i32 = arith.constant 0 : i32
    %0 = cal.create_state_var<i32> : !cal.state_ref<i32>
    cal.set(%0 : !cal.state_ref<i32>, %c0_i32 : i32)
    cal.action "$untagged0" priority=0
    {
      %1 = fifo.pop(%arg0 : !fifo.output_port<complex<f32>>) : complex<f32>
      %2 = cal.get(%0 : !cal.state_ref<i32>) : i32
      %3 = complex.re %1 : complex<f32>
      %4 = complex.im %1 : complex<f32>
      fifo.print("%i, Re: %f, Im: %f\0A\00", %2, %3, %4) : (i32, f32, f32)
      %5 = cal.get(%0 : !cal.state_ref<i32>) : i32
      %6 = arith.addi %5, %c1_i32 : i32
      cal.set(%0 : !cal.state_ref<i32>, %6 : i32)
    }
    
  }
  
  cal.network @fft__Top() attributes {cal.top}
  {
    %c1_i32 = arith.constant 1 : i32
    %c2_i32 = arith.constant 2 : i32
    %c16_i32 = arith.constant 16 : i32
    %c4_i32 = arith.constant 4 : i32
    %c32_i32 = arith.constant 32 : i32
    %c64_i32 = arith.constant 64 : i32
    %c128_i32 = arith.constant 128 : i32
    %cst = arith.constant 6.250000e-02 : f32
    %cst_0 = arith.constant 0.0897142887 : f32
    %cst_1 = arith.constant 0.209333345 : f32
    %cst_2 = arith.constant 3.140000e-01 : f32
    %c8_i32 = arith.constant 8 : i32
    %c256_i32 = arith.constant 256 : i32
    %inputPort, %outputPort = fifo.create<i32> (4096) {cal.name = "fft__Top.trigger.out0->fft__Top.__fanout_i32_3.8.in0"} : !fifo.input_port<i32>, !fifo.output_port<i32>
    %inputPort_3, %outputPort_4 = fifo.create<i32> (4096) {cal.name = "fft__Top.fft__Top.__fanout_i32_3.8.out0->s1.in0"} : !fifo.input_port<i32>, !fifo.output_port<i32>
    %inputPort_5, %outputPort_6 = fifo.create<i32> (4096) {cal.name = "fft__Top.fft__Top.__fanout_i32_3.8.out1->s2.in0"} : !fifo.input_port<i32>, !fifo.output_port<i32>
    %inputPort_7, %outputPort_8 = fifo.create<i32> (4096) {cal.name = "fft__Top.fft__Top.__fanout_i32_3.8.out2->s3.in0"} : !fifo.input_port<i32>, !fifo.output_port<i32>
    %inputPort_9, %outputPort_10 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Top.s1.out0->add1.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_11, %outputPort_12 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Top.s2.out0->add1.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_13, %outputPort_14 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Top.add1.out0->add2.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_15, %outputPort_16 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Top.s3.out0->add2.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_17, %outputPort_18 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Top.add2.out0->dft.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_19, %outputPort_20 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Top.dft.out0->p.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    cal.create_instance @__fanout_i32_3 "fft__Top.__fanout_i32_3.8" device_affinity="cpu0" ()
        ports_in (%outputPort : !fifo.output_port<i32>)
        ports_out (%inputPort_3, %inputPort_5, %inputPort_7 : !fifo.input_port<i32>, !fifo.input_port<i32>, !fifo.input_port<i32>)
    cal.create_instance @fft__Sine__v__d_dyn$spec_13554697526108865926 "s3" (%cst_0 : f32)
        ports_in (%outputPort_8 : !fifo.output_port<i32>)
        ports_out (%inputPort_15 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Trigger__v__N_256$spec_17870807604530591867 "trigger" (%c256_i32 : i32)
        ports_out (%inputPort : !fifo.input_port<i32>)
    cal.create_instance @fft__Sine__v__d_dyn$spec_15203075921786301832 "s1" (%cst_2 : f32)
        ports_in (%outputPort_4 : !fifo.output_port<i32>)
        ports_out (%inputPort_9 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Add "add1" device_affinity="cpu0" ()
        ports_in (%outputPort_10, %outputPort_12 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_13 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Print "p" device_affinity="cpu0" ()
        ports_in (%outputPort_20 : !fifo.output_port<complex<f32>>)
    cal.create_instance @fft__Sine__v__d_dyn$spec_10385615261197223207 "s2" (%cst_1 : f32)
        ports_in (%outputPort_6 : !fifo.output_port<i32>)
        ports_out (%inputPort_11 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Add "add2" device_affinity="cpu0" ()
        ports_in (%outputPort_14, %outputPort_16 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_17 : !fifo.input_port<complex<f32>>)
    %inputPort_21, %outputPort_22 = fifo.create<complex<f32>> (4096) {cal.name = "fft__ButterflyFFT$spec_17634390743475301659.bf.out0->scaler.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    cal.create_instance @fft__ConstantMultiply__v__c_dyn$spec_8169147697905524375 "scaler" (%cst : f32)
        ports_in (%outputPort_22 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_19 : !fifo.input_port<complex<f32>>)
    %inputPort_23, %outputPort_24 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_3319258433404930760.fft__Butterfly$spec_3319258433404930760.__fanout_complex_f32__2.6.out0->split.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_25, %outputPort_26 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_3319258433404930760.fft__Butterfly$spec_3319258433404930760.__fanout_complex_f32__2.6.out1->twiddles.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_27, %outputPort_28 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_3319258433404930760.split.out0->r2cell.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_29, %outputPort_30 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_3319258433404930760.split.out1->r2cell.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_31, %outputPort_32 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_3319258433404930760.twiddles.out0->r2cell.in2"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_33, %outputPort_34 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_3319258433404930760.r2cell.out0->fft__Butterfly$spec_3319258433404930760.fft__Butterfly$spec_11505259727820113654.4.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_35, %outputPort_36 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_3319258433404930760.r2cell.out1->fft__Butterfly$spec_3319258433404930760.fft__Butterfly$spec_11505259727820113654.5.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_37, %outputPort_38 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_3319258433404930760.fft__Butterfly$spec_3319258433404930760.fft__Butterfly$spec_11505259727820113654.4.out0->merge.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_39, %outputPort_40 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_3319258433404930760.fft__Butterfly$spec_3319258433404930760.fft__Butterfly$spec_11505259727820113654.5.out0->merge.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_41, %outputPort_42 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_11505259727820113654.fft__Butterfly$spec_11505259727820113654.__fanout_complex_f32__2.6.out0->split.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_43, %outputPort_44 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_11505259727820113654.fft__Butterfly$spec_11505259727820113654.__fanout_complex_f32__2.6.out1->twiddles.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_45, %outputPort_46 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_11505259727820113654.split.out0->r2cell.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_47, %outputPort_48 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_11505259727820113654.split.out1->r2cell.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_49, %outputPort_50 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_11505259727820113654.twiddles.out0->r2cell.in2"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_51, %outputPort_52 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_11505259727820113654.r2cell.out0->fft__Butterfly$spec_11505259727820113654.fft__Butterfly$spec_17640631431051100303.4.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_53, %outputPort_54 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_11505259727820113654.r2cell.out1->fft__Butterfly$spec_11505259727820113654.fft__Butterfly$spec_17640631431051100303.5.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_55, %outputPort_56 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_11505259727820113654.fft__Butterfly$spec_11505259727820113654.fft__Butterfly$spec_17640631431051100303.4.out0->merge.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_57, %outputPort_58 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_11505259727820113654.fft__Butterfly$spec_11505259727820113654.fft__Butterfly$spec_17640631431051100303.5.out0->merge.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    cal.create_instance @fft__Split__v__N_dyn "split" (%c64_i32 : i32)
        ports_in (%outputPort_42 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_45, %inputPort_47 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @__fanout_complex_f32__2 "fft__Butterfly$spec_11505259727820113654.__fanout_complex_f32__2.6" device_affinity="cpu0" ()
        ports_in (%outputPort_34 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_41, %inputPort_43 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    %inputPort_59, %outputPort_60 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_17640631431051100303.fft__Butterfly$spec_17640631431051100303.__fanout_complex_f32__2.6.out0->split.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_61, %outputPort_62 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_17640631431051100303.fft__Butterfly$spec_17640631431051100303.__fanout_complex_f32__2.6.out1->twiddles.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_63, %outputPort_64 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_17640631431051100303.split.out0->r2cell.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_65, %outputPort_66 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_17640631431051100303.split.out1->r2cell.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_67, %outputPort_68 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_17640631431051100303.twiddles.out0->r2cell.in2"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_69, %outputPort_70 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_17640631431051100303.r2cell.out0->fft__Butterfly$spec_17640631431051100303.fft__Butterfly$spec_3035977640463470463.4.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_71, %outputPort_72 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_17640631431051100303.r2cell.out1->fft__Butterfly$spec_17640631431051100303.fft__Butterfly$spec_3035977640463470463.5.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_73, %outputPort_74 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_17640631431051100303.fft__Butterfly$spec_17640631431051100303.fft__Butterfly$spec_3035977640463470463.4.out0->merge.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_75, %outputPort_76 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_17640631431051100303.fft__Butterfly$spec_17640631431051100303.fft__Butterfly$spec_3035977640463470463.5.out0->merge.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    cal.create_instance @fft__Merge "merge" device_affinity="cpu0" ()
        ports_in (%outputPort_74, %outputPort_76 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_55 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Split__v__N_dyn "split" (%c32_i32 : i32)
        ports_in (%outputPort_60 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_63, %inputPort_65 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    %inputPort_77, %outputPort_78 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_3035977640463470463.fft__Butterfly$spec_3035977640463470463.__fanout_complex_f32__2.6.out0->split.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_79, %outputPort_80 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_3035977640463470463.fft__Butterfly$spec_3035977640463470463.__fanout_complex_f32__2.6.out1->twiddles.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_81, %outputPort_82 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_3035977640463470463.split.out0->r2cell.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_83, %outputPort_84 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_3035977640463470463.split.out1->r2cell.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_85, %outputPort_86 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_3035977640463470463.twiddles.out0->r2cell.in2"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_87, %outputPort_88 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_3035977640463470463.r2cell.out0->fft__Butterfly$spec_3035977640463470463.fft__Butterfly$spec_16755419077516047831.4.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_89, %outputPort_90 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_3035977640463470463.r2cell.out1->fft__Butterfly$spec_3035977640463470463.fft__Butterfly$spec_16755419077516047831.5.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_91, %outputPort_92 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_3035977640463470463.fft__Butterfly$spec_3035977640463470463.fft__Butterfly$spec_16755419077516047831.4.out0->merge.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_93, %outputPort_94 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_3035977640463470463.fft__Butterfly$spec_3035977640463470463.fft__Butterfly$spec_16755419077516047831.5.out0->merge.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    cal.create_instance @fft__TwiddleGenerator__v__N_dyn "twiddles" (%c16_i32 : i32)
        ports_in (%outputPort_80 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_85 : !fifo.input_port<complex<f32>>)
    %inputPort_95, %outputPort_96 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_16755419077516047831.fft__Butterfly$spec_16755419077516047831.__fanout_complex_f32__2.6.out0->split.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_97, %outputPort_98 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_16755419077516047831.fft__Butterfly$spec_16755419077516047831.__fanout_complex_f32__2.6.out1->twiddles.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_99, %outputPort_100 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_16755419077516047831.split.out0->r2cell.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_101, %outputPort_102 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_16755419077516047831.split.out1->r2cell.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_103, %outputPort_104 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_16755419077516047831.twiddles.out0->r2cell.in2"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_105, %outputPort_106 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_16755419077516047831.r2cell.out0->fft__Butterfly$spec_16755419077516047831.fft__Butterfly$spec_9935405952460034831.4.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_107, %outputPort_108 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_16755419077516047831.r2cell.out1->fft__Butterfly$spec_16755419077516047831.fft__Butterfly$spec_9935405952460034831.5.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_109, %outputPort_110 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_16755419077516047831.fft__Butterfly$spec_16755419077516047831.fft__Butterfly$spec_9935405952460034831.4.out0->merge.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_111, %outputPort_112 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_16755419077516047831.fft__Butterfly$spec_16755419077516047831.fft__Butterfly$spec_9935405952460034831.5.out0->merge.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    cal.create_instance @__fanout_complex_f32__2 "fft__Butterfly$spec_16755419077516047831.__fanout_complex_f32__2.6" device_affinity="cpu0" ()
        ports_in (%outputPort_90 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_95, %inputPort_97 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Merge "merge" device_affinity="cpu0" ()
        ports_in (%outputPort_110, %outputPort_112 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_93 : !fifo.input_port<complex<f32>>)
    %inputPort_113, %outputPort_114 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.fft__Butterfly$spec_9935405952460034831.__fanout_complex_f32__2.6.out0->split.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_115, %outputPort_116 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.fft__Butterfly$spec_9935405952460034831.__fanout_complex_f32__2.6.out1->twiddles.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_117, %outputPort_118 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.split.out0->r2cell.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_119, %outputPort_120 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.split.out1->r2cell.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_121, %outputPort_122 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.twiddles.out0->r2cell.in2"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_123, %outputPort_124 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.r2cell.out0->fft__Butterfly$spec_9935405952460034831.fft__Butterfly$spec_1916938481276772234.4.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_125, %outputPort_126 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.r2cell.out1->fft__Butterfly$spec_9935405952460034831.fft__Butterfly$spec_1916938481276772234.5.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_127, %outputPort_128 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.fft__Butterfly$spec_9935405952460034831.fft__Butterfly$spec_1916938481276772234.4.out0->merge.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_129, %outputPort_130 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.fft__Butterfly$spec_9935405952460034831.fft__Butterfly$spec_1916938481276772234.5.out0->merge.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    cal.create_instance @fft__Radix2Cell "r2cell" device_affinity="cpu0" ()
        ports_in (%outputPort_118, %outputPort_120, %outputPort_122 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_123, %inputPort_125 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Split__v__N_dyn "split" (%c4_i32 : i32)
        ports_in (%outputPort_114 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_117, %inputPort_119 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Merge "merge" device_affinity="cpu0" ()
        ports_in (%outputPort_128, %outputPort_130 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_111 : !fifo.input_port<complex<f32>>)
    cal.create_instance @__fanout_complex_f32__2 "fft__Butterfly$spec_9935405952460034831.__fanout_complex_f32__2.6" device_affinity="cpu0" ()
        ports_in (%outputPort_108 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_113, %inputPort_115 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__TwiddleGenerator__v__N_dyn "twiddles" (%c4_i32 : i32)
        ports_in (%outputPort_116 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_121 : !fifo.input_port<complex<f32>>)
    %inputPort_131, %outputPort_132 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_1916938481276772234.__fanout_complex_f32__2.6.out0->split.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_133, %outputPort_134 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_1916938481276772234.__fanout_complex_f32__2.6.out1->twiddles.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_135, %outputPort_136 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.split.out0->r2cell.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_137, %outputPort_138 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.split.out1->r2cell.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_139, %outputPort_140 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.twiddles.out0->r2cell.in2"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_141, %outputPort_142 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.r2cell.out0->fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_15446289516955298258.4.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_143, %outputPort_144 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.r2cell.out1->fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_15446289516955298258.5.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_145, %outputPort_146 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_15446289516955298258.4.out0->merge.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_147, %outputPort_148 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_15446289516955298258.5.out0->merge.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    cal.create_instance @fft__Radix2Cell "r2cell" device_affinity="cpu0" ()
        ports_in (%outputPort_136, %outputPort_138, %outputPort_140 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_141, %inputPort_143 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__TwiddleGenerator__v__N_dyn "twiddles" (%c2_i32 : i32)
        ports_in (%outputPort_134 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_139 : !fifo.input_port<complex<f32>>)
    cal.create_instance @__fanout_complex_f32__2 "fft__Butterfly$spec_1916938481276772234.__fanout_complex_f32__2.6" device_affinity="cpu0" ()
        ports_in (%outputPort_126 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_131, %inputPort_133 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Split__v__N_dyn "split" (%c2_i32 : i32)
        ports_in (%outputPort_132 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_135, %inputPort_137 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    %inputPort_149, %outputPort_150 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4.out0->split.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_151, %outputPort_152 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4.out1->twiddles.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_153, %outputPort_154 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.split.out0->r2cell.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_155, %outputPort_156 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.split.out1->r2cell.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_157, %outputPort_158 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.twiddles.out0->r2cell.in2"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_159, %outputPort_160 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.r2cell.out0->merge.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_161, %outputPort_162 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.r2cell.out1->merge.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    cal.create_instance @fft__Merge "merge" device_affinity="cpu0" ()
        ports_in (%outputPort_160, %outputPort_162 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_145 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__TwiddleGenerator__v__N_dyn "twiddles" (%c1_i32 : i32)
        ports_in (%outputPort_152 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_157 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Split__v__N_dyn "split" (%c1_i32 : i32)
        ports_in (%outputPort_150 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_153, %inputPort_155 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @__fanout_complex_f32__2 "fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4" device_affinity="cpu0" ()
        ports_in (%outputPort_142 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_149, %inputPort_151 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Radix2Cell "r2cell" device_affinity="cpu0" ()
        ports_in (%outputPort_154, %outputPort_156, %outputPort_158 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_159, %inputPort_161 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    %inputPort_163, %outputPort_164 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4.out0->split.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_165, %outputPort_166 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4.out1->twiddles.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_167, %outputPort_168 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.split.out0->r2cell.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_169, %outputPort_170 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.split.out1->r2cell.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_171, %outputPort_172 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.twiddles.out0->r2cell.in2"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_173, %outputPort_174 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.r2cell.out0->merge.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_175, %outputPort_176 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.r2cell.out1->merge.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    cal.create_instance @fft__Merge "merge" device_affinity="cpu0" ()
        ports_in (%outputPort_174, %outputPort_176 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_147 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__TwiddleGenerator__v__N_dyn "twiddles" (%c1_i32 : i32)
        ports_in (%outputPort_166 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_171 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Split__v__N_dyn "split" (%c1_i32 : i32)
        ports_in (%outputPort_164 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_167, %inputPort_169 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @__fanout_complex_f32__2 "fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4" device_affinity="cpu0" ()
        ports_in (%outputPort_144 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_163, %inputPort_165 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Radix2Cell "r2cell" device_affinity="cpu0" ()
        ports_in (%outputPort_168, %outputPort_170, %outputPort_172 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_173, %inputPort_175 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Merge "merge" device_affinity="cpu0" ()
        ports_in (%outputPort_146, %outputPort_148 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_129 : !fifo.input_port<complex<f32>>)
    %inputPort_177, %outputPort_178 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_1916938481276772234.__fanout_complex_f32__2.6.out0->split.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_179, %outputPort_180 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_1916938481276772234.__fanout_complex_f32__2.6.out1->twiddles.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_181, %outputPort_182 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.split.out0->r2cell.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_183, %outputPort_184 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.split.out1->r2cell.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_185, %outputPort_186 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.twiddles.out0->r2cell.in2"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_187, %outputPort_188 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.r2cell.out0->fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_15446289516955298258.4.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_189, %outputPort_190 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.r2cell.out1->fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_15446289516955298258.5.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_191, %outputPort_192 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_15446289516955298258.4.out0->merge.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_193, %outputPort_194 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_15446289516955298258.5.out0->merge.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    cal.create_instance @fft__Radix2Cell "r2cell" device_affinity="cpu0" ()
        ports_in (%outputPort_182, %outputPort_184, %outputPort_186 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_187, %inputPort_189 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__TwiddleGenerator__v__N_dyn "twiddles" (%c2_i32 : i32)
        ports_in (%outputPort_180 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_185 : !fifo.input_port<complex<f32>>)
    cal.create_instance @__fanout_complex_f32__2 "fft__Butterfly$spec_1916938481276772234.__fanout_complex_f32__2.6" device_affinity="cpu0" ()
        ports_in (%outputPort_124 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_177, %inputPort_179 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Split__v__N_dyn "split" (%c2_i32 : i32)
        ports_in (%outputPort_178 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_181, %inputPort_183 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    %inputPort_195, %outputPort_196 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4.out0->split.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_197, %outputPort_198 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4.out1->twiddles.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_199, %outputPort_200 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.split.out0->r2cell.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_201, %outputPort_202 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.split.out1->r2cell.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_203, %outputPort_204 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.twiddles.out0->r2cell.in2"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_205, %outputPort_206 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.r2cell.out0->merge.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_207, %outputPort_208 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.r2cell.out1->merge.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    cal.create_instance @fft__Merge "merge" device_affinity="cpu0" ()
        ports_in (%outputPort_206, %outputPort_208 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_191 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__TwiddleGenerator__v__N_dyn "twiddles" (%c1_i32 : i32)
        ports_in (%outputPort_198 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_203 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Split__v__N_dyn "split" (%c1_i32 : i32)
        ports_in (%outputPort_196 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_199, %inputPort_201 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @__fanout_complex_f32__2 "fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4" device_affinity="cpu0" ()
        ports_in (%outputPort_188 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_195, %inputPort_197 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Radix2Cell "r2cell" device_affinity="cpu0" ()
        ports_in (%outputPort_200, %outputPort_202, %outputPort_204 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_205, %inputPort_207 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    %inputPort_209, %outputPort_210 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4.out0->split.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_211, %outputPort_212 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4.out1->twiddles.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_213, %outputPort_214 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.split.out0->r2cell.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_215, %outputPort_216 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.split.out1->r2cell.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_217, %outputPort_218 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.twiddles.out0->r2cell.in2"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_219, %outputPort_220 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.r2cell.out0->merge.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_221, %outputPort_222 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.r2cell.out1->merge.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    cal.create_instance @fft__Merge "merge" device_affinity="cpu0" ()
        ports_in (%outputPort_220, %outputPort_222 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_193 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__TwiddleGenerator__v__N_dyn "twiddles" (%c1_i32 : i32)
        ports_in (%outputPort_212 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_217 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Split__v__N_dyn "split" (%c1_i32 : i32)
        ports_in (%outputPort_210 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_213, %inputPort_215 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @__fanout_complex_f32__2 "fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4" device_affinity="cpu0" ()
        ports_in (%outputPort_190 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_209, %inputPort_211 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Radix2Cell "r2cell" device_affinity="cpu0" ()
        ports_in (%outputPort_214, %outputPort_216, %outputPort_218 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_219, %inputPort_221 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Merge "merge" device_affinity="cpu0" ()
        ports_in (%outputPort_192, %outputPort_194 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_127 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__TwiddleGenerator__v__N_dyn "twiddles" (%c8_i32 : i32)
        ports_in (%outputPort_98 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_103 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Radix2Cell "r2cell" device_affinity="cpu0" ()
        ports_in (%outputPort_100, %outputPort_102, %outputPort_104 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_105, %inputPort_107 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    %inputPort_223, %outputPort_224 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.fft__Butterfly$spec_9935405952460034831.__fanout_complex_f32__2.6.out0->split.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_225, %outputPort_226 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.fft__Butterfly$spec_9935405952460034831.__fanout_complex_f32__2.6.out1->twiddles.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_227, %outputPort_228 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.split.out0->r2cell.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_229, %outputPort_230 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.split.out1->r2cell.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_231, %outputPort_232 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.twiddles.out0->r2cell.in2"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_233, %outputPort_234 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.r2cell.out0->fft__Butterfly$spec_9935405952460034831.fft__Butterfly$spec_1916938481276772234.4.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_235, %outputPort_236 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.r2cell.out1->fft__Butterfly$spec_9935405952460034831.fft__Butterfly$spec_1916938481276772234.5.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_237, %outputPort_238 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.fft__Butterfly$spec_9935405952460034831.fft__Butterfly$spec_1916938481276772234.4.out0->merge.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_239, %outputPort_240 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.fft__Butterfly$spec_9935405952460034831.fft__Butterfly$spec_1916938481276772234.5.out0->merge.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    cal.create_instance @fft__Radix2Cell "r2cell" device_affinity="cpu0" ()
        ports_in (%outputPort_228, %outputPort_230, %outputPort_232 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_233, %inputPort_235 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Split__v__N_dyn "split" (%c4_i32 : i32)
        ports_in (%outputPort_224 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_227, %inputPort_229 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Merge "merge" device_affinity="cpu0" ()
        ports_in (%outputPort_238, %outputPort_240 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_109 : !fifo.input_port<complex<f32>>)
    cal.create_instance @__fanout_complex_f32__2 "fft__Butterfly$spec_9935405952460034831.__fanout_complex_f32__2.6" device_affinity="cpu0" ()
        ports_in (%outputPort_106 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_223, %inputPort_225 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__TwiddleGenerator__v__N_dyn "twiddles" (%c4_i32 : i32)
        ports_in (%outputPort_226 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_231 : !fifo.input_port<complex<f32>>)
    %inputPort_241, %outputPort_242 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_1916938481276772234.__fanout_complex_f32__2.6.out0->split.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_243, %outputPort_244 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_1916938481276772234.__fanout_complex_f32__2.6.out1->twiddles.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_245, %outputPort_246 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.split.out0->r2cell.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_247, %outputPort_248 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.split.out1->r2cell.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_249, %outputPort_250 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.twiddles.out0->r2cell.in2"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_251, %outputPort_252 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.r2cell.out0->fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_15446289516955298258.4.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_253, %outputPort_254 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.r2cell.out1->fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_15446289516955298258.5.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_255, %outputPort_256 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_15446289516955298258.4.out0->merge.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_257, %outputPort_258 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_15446289516955298258.5.out0->merge.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    cal.create_instance @fft__Radix2Cell "r2cell" device_affinity="cpu0" ()
        ports_in (%outputPort_246, %outputPort_248, %outputPort_250 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_251, %inputPort_253 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__TwiddleGenerator__v__N_dyn "twiddles" (%c2_i32 : i32)
        ports_in (%outputPort_244 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_249 : !fifo.input_port<complex<f32>>)
    cal.create_instance @__fanout_complex_f32__2 "fft__Butterfly$spec_1916938481276772234.__fanout_complex_f32__2.6" device_affinity="cpu0" ()
        ports_in (%outputPort_236 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_241, %inputPort_243 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Split__v__N_dyn "split" (%c2_i32 : i32)
        ports_in (%outputPort_242 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_245, %inputPort_247 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    %inputPort_259, %outputPort_260 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4.out0->split.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_261, %outputPort_262 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4.out1->twiddles.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_263, %outputPort_264 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.split.out0->r2cell.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_265, %outputPort_266 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.split.out1->r2cell.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_267, %outputPort_268 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.twiddles.out0->r2cell.in2"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_269, %outputPort_270 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.r2cell.out0->merge.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_271, %outputPort_272 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.r2cell.out1->merge.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    cal.create_instance @fft__Merge "merge" device_affinity="cpu0" ()
        ports_in (%outputPort_270, %outputPort_272 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_255 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__TwiddleGenerator__v__N_dyn "twiddles" (%c1_i32 : i32)
        ports_in (%outputPort_262 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_267 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Split__v__N_dyn "split" (%c1_i32 : i32)
        ports_in (%outputPort_260 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_263, %inputPort_265 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @__fanout_complex_f32__2 "fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4" device_affinity="cpu0" ()
        ports_in (%outputPort_252 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_259, %inputPort_261 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Radix2Cell "r2cell" device_affinity="cpu0" ()
        ports_in (%outputPort_264, %outputPort_266, %outputPort_268 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_269, %inputPort_271 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    %inputPort_273, %outputPort_274 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4.out0->split.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_275, %outputPort_276 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4.out1->twiddles.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_277, %outputPort_278 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.split.out0->r2cell.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_279, %outputPort_280 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.split.out1->r2cell.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_281, %outputPort_282 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.twiddles.out0->r2cell.in2"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_283, %outputPort_284 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.r2cell.out0->merge.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_285, %outputPort_286 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.r2cell.out1->merge.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    cal.create_instance @fft__Merge "merge" device_affinity="cpu0" ()
        ports_in (%outputPort_284, %outputPort_286 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_257 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__TwiddleGenerator__v__N_dyn "twiddles" (%c1_i32 : i32)
        ports_in (%outputPort_276 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_281 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Split__v__N_dyn "split" (%c1_i32 : i32)
        ports_in (%outputPort_274 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_277, %inputPort_279 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @__fanout_complex_f32__2 "fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4" device_affinity="cpu0" ()
        ports_in (%outputPort_254 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_273, %inputPort_275 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Radix2Cell "r2cell" device_affinity="cpu0" ()
        ports_in (%outputPort_278, %outputPort_280, %outputPort_282 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_283, %inputPort_285 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Merge "merge" device_affinity="cpu0" ()
        ports_in (%outputPort_256, %outputPort_258 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_239 : !fifo.input_port<complex<f32>>)
    %inputPort_287, %outputPort_288 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_1916938481276772234.__fanout_complex_f32__2.6.out0->split.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_289, %outputPort_290 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_1916938481276772234.__fanout_complex_f32__2.6.out1->twiddles.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_291, %outputPort_292 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.split.out0->r2cell.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_293, %outputPort_294 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.split.out1->r2cell.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_295, %outputPort_296 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.twiddles.out0->r2cell.in2"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_297, %outputPort_298 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.r2cell.out0->fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_15446289516955298258.4.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_299, %outputPort_300 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.r2cell.out1->fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_15446289516955298258.5.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_301, %outputPort_302 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_15446289516955298258.4.out0->merge.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_303, %outputPort_304 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_15446289516955298258.5.out0->merge.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    cal.create_instance @fft__Radix2Cell "r2cell" device_affinity="cpu0" ()
        ports_in (%outputPort_292, %outputPort_294, %outputPort_296 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_297, %inputPort_299 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__TwiddleGenerator__v__N_dyn "twiddles" (%c2_i32 : i32)
        ports_in (%outputPort_290 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_295 : !fifo.input_port<complex<f32>>)
    cal.create_instance @__fanout_complex_f32__2 "fft__Butterfly$spec_1916938481276772234.__fanout_complex_f32__2.6" device_affinity="cpu0" ()
        ports_in (%outputPort_234 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_287, %inputPort_289 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Split__v__N_dyn "split" (%c2_i32 : i32)
        ports_in (%outputPort_288 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_291, %inputPort_293 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    %inputPort_305, %outputPort_306 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4.out0->split.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_307, %outputPort_308 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4.out1->twiddles.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_309, %outputPort_310 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.split.out0->r2cell.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_311, %outputPort_312 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.split.out1->r2cell.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_313, %outputPort_314 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.twiddles.out0->r2cell.in2"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_315, %outputPort_316 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.r2cell.out0->merge.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_317, %outputPort_318 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.r2cell.out1->merge.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    cal.create_instance @fft__Merge "merge" device_affinity="cpu0" ()
        ports_in (%outputPort_316, %outputPort_318 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_301 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__TwiddleGenerator__v__N_dyn "twiddles" (%c1_i32 : i32)
        ports_in (%outputPort_308 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_313 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Split__v__N_dyn "split" (%c1_i32 : i32)
        ports_in (%outputPort_306 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_309, %inputPort_311 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @__fanout_complex_f32__2 "fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4" device_affinity="cpu0" ()
        ports_in (%outputPort_298 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_305, %inputPort_307 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Radix2Cell "r2cell" device_affinity="cpu0" ()
        ports_in (%outputPort_310, %outputPort_312, %outputPort_314 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_315, %inputPort_317 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    %inputPort_319, %outputPort_320 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4.out0->split.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_321, %outputPort_322 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4.out1->twiddles.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_323, %outputPort_324 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.split.out0->r2cell.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_325, %outputPort_326 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.split.out1->r2cell.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_327, %outputPort_328 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.twiddles.out0->r2cell.in2"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_329, %outputPort_330 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.r2cell.out0->merge.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_331, %outputPort_332 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.r2cell.out1->merge.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    cal.create_instance @fft__Merge "merge" device_affinity="cpu0" ()
        ports_in (%outputPort_330, %outputPort_332 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_303 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__TwiddleGenerator__v__N_dyn "twiddles" (%c1_i32 : i32)
        ports_in (%outputPort_322 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_327 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Split__v__N_dyn "split" (%c1_i32 : i32)
        ports_in (%outputPort_320 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_323, %inputPort_325 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @__fanout_complex_f32__2 "fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4" device_affinity="cpu0" ()
        ports_in (%outputPort_300 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_319, %inputPort_321 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Radix2Cell "r2cell" device_affinity="cpu0" ()
        ports_in (%outputPort_324, %outputPort_326, %outputPort_328 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_329, %inputPort_331 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Merge "merge" device_affinity="cpu0" ()
        ports_in (%outputPort_302, %outputPort_304 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_237 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Split__v__N_dyn "split" (%c8_i32 : i32)
        ports_in (%outputPort_96 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_99, %inputPort_101 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Radix2Cell "r2cell" device_affinity="cpu0" ()
        ports_in (%outputPort_82, %outputPort_84, %outputPort_86 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_87, %inputPort_89 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Merge "merge" device_affinity="cpu0" ()
        ports_in (%outputPort_92, %outputPort_94 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_73 : !fifo.input_port<complex<f32>>)
    cal.create_instance @__fanout_complex_f32__2 "fft__Butterfly$spec_3035977640463470463.__fanout_complex_f32__2.6" device_affinity="cpu0" ()
        ports_in (%outputPort_70 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_77, %inputPort_79 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    %inputPort_333, %outputPort_334 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_16755419077516047831.fft__Butterfly$spec_16755419077516047831.__fanout_complex_f32__2.6.out0->split.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_335, %outputPort_336 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_16755419077516047831.fft__Butterfly$spec_16755419077516047831.__fanout_complex_f32__2.6.out1->twiddles.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_337, %outputPort_338 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_16755419077516047831.split.out0->r2cell.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_339, %outputPort_340 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_16755419077516047831.split.out1->r2cell.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_341, %outputPort_342 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_16755419077516047831.twiddles.out0->r2cell.in2"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_343, %outputPort_344 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_16755419077516047831.r2cell.out0->fft__Butterfly$spec_16755419077516047831.fft__Butterfly$spec_9935405952460034831.4.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_345, %outputPort_346 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_16755419077516047831.r2cell.out1->fft__Butterfly$spec_16755419077516047831.fft__Butterfly$spec_9935405952460034831.5.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_347, %outputPort_348 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_16755419077516047831.fft__Butterfly$spec_16755419077516047831.fft__Butterfly$spec_9935405952460034831.4.out0->merge.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_349, %outputPort_350 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_16755419077516047831.fft__Butterfly$spec_16755419077516047831.fft__Butterfly$spec_9935405952460034831.5.out0->merge.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    cal.create_instance @__fanout_complex_f32__2 "fft__Butterfly$spec_16755419077516047831.__fanout_complex_f32__2.6" device_affinity="cpu0" ()
        ports_in (%outputPort_88 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_333, %inputPort_335 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Merge "merge" device_affinity="cpu0" ()
        ports_in (%outputPort_348, %outputPort_350 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_91 : !fifo.input_port<complex<f32>>)
    %inputPort_351, %outputPort_352 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.fft__Butterfly$spec_9935405952460034831.__fanout_complex_f32__2.6.out0->split.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_353, %outputPort_354 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.fft__Butterfly$spec_9935405952460034831.__fanout_complex_f32__2.6.out1->twiddles.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_355, %outputPort_356 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.split.out0->r2cell.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_357, %outputPort_358 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.split.out1->r2cell.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_359, %outputPort_360 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.twiddles.out0->r2cell.in2"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_361, %outputPort_362 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.r2cell.out0->fft__Butterfly$spec_9935405952460034831.fft__Butterfly$spec_1916938481276772234.4.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_363, %outputPort_364 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.r2cell.out1->fft__Butterfly$spec_9935405952460034831.fft__Butterfly$spec_1916938481276772234.5.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_365, %outputPort_366 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.fft__Butterfly$spec_9935405952460034831.fft__Butterfly$spec_1916938481276772234.4.out0->merge.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_367, %outputPort_368 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.fft__Butterfly$spec_9935405952460034831.fft__Butterfly$spec_1916938481276772234.5.out0->merge.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    cal.create_instance @fft__Radix2Cell "r2cell" device_affinity="cpu0" ()
        ports_in (%outputPort_356, %outputPort_358, %outputPort_360 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_361, %inputPort_363 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Split__v__N_dyn "split" (%c4_i32 : i32)
        ports_in (%outputPort_352 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_355, %inputPort_357 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Merge "merge" device_affinity="cpu0" ()
        ports_in (%outputPort_366, %outputPort_368 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_349 : !fifo.input_port<complex<f32>>)
    cal.create_instance @__fanout_complex_f32__2 "fft__Butterfly$spec_9935405952460034831.__fanout_complex_f32__2.6" device_affinity="cpu0" ()
        ports_in (%outputPort_346 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_351, %inputPort_353 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__TwiddleGenerator__v__N_dyn "twiddles" (%c4_i32 : i32)
        ports_in (%outputPort_354 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_359 : !fifo.input_port<complex<f32>>)
    %inputPort_369, %outputPort_370 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_1916938481276772234.__fanout_complex_f32__2.6.out0->split.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_371, %outputPort_372 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_1916938481276772234.__fanout_complex_f32__2.6.out1->twiddles.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_373, %outputPort_374 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.split.out0->r2cell.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_375, %outputPort_376 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.split.out1->r2cell.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_377, %outputPort_378 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.twiddles.out0->r2cell.in2"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_379, %outputPort_380 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.r2cell.out0->fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_15446289516955298258.4.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_381, %outputPort_382 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.r2cell.out1->fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_15446289516955298258.5.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_383, %outputPort_384 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_15446289516955298258.4.out0->merge.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_385, %outputPort_386 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_15446289516955298258.5.out0->merge.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    cal.create_instance @fft__Radix2Cell "r2cell" device_affinity="cpu0" ()
        ports_in (%outputPort_374, %outputPort_376, %outputPort_378 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_379, %inputPort_381 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__TwiddleGenerator__v__N_dyn "twiddles" (%c2_i32 : i32)
        ports_in (%outputPort_372 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_377 : !fifo.input_port<complex<f32>>)
    cal.create_instance @__fanout_complex_f32__2 "fft__Butterfly$spec_1916938481276772234.__fanout_complex_f32__2.6" device_affinity="cpu0" ()
        ports_in (%outputPort_364 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_369, %inputPort_371 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Split__v__N_dyn "split" (%c2_i32 : i32)
        ports_in (%outputPort_370 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_373, %inputPort_375 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    %inputPort_387, %outputPort_388 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4.out0->split.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_389, %outputPort_390 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4.out1->twiddles.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_391, %outputPort_392 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.split.out0->r2cell.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_393, %outputPort_394 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.split.out1->r2cell.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_395, %outputPort_396 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.twiddles.out0->r2cell.in2"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_397, %outputPort_398 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.r2cell.out0->merge.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_399, %outputPort_400 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.r2cell.out1->merge.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    cal.create_instance @fft__Merge "merge" device_affinity="cpu0" ()
        ports_in (%outputPort_398, %outputPort_400 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_383 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__TwiddleGenerator__v__N_dyn "twiddles" (%c1_i32 : i32)
        ports_in (%outputPort_390 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_395 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Split__v__N_dyn "split" (%c1_i32 : i32)
        ports_in (%outputPort_388 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_391, %inputPort_393 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @__fanout_complex_f32__2 "fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4" device_affinity="cpu0" ()
        ports_in (%outputPort_380 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_387, %inputPort_389 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Radix2Cell "r2cell" device_affinity="cpu0" ()
        ports_in (%outputPort_392, %outputPort_394, %outputPort_396 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_397, %inputPort_399 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    %inputPort_401, %outputPort_402 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4.out0->split.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_403, %outputPort_404 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4.out1->twiddles.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_405, %outputPort_406 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.split.out0->r2cell.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_407, %outputPort_408 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.split.out1->r2cell.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_409, %outputPort_410 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.twiddles.out0->r2cell.in2"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_411, %outputPort_412 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.r2cell.out0->merge.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_413, %outputPort_414 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.r2cell.out1->merge.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    cal.create_instance @fft__Merge "merge" device_affinity="cpu0" ()
        ports_in (%outputPort_412, %outputPort_414 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_385 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__TwiddleGenerator__v__N_dyn "twiddles" (%c1_i32 : i32)
        ports_in (%outputPort_404 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_409 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Split__v__N_dyn "split" (%c1_i32 : i32)
        ports_in (%outputPort_402 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_405, %inputPort_407 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @__fanout_complex_f32__2 "fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4" device_affinity="cpu0" ()
        ports_in (%outputPort_382 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_401, %inputPort_403 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Radix2Cell "r2cell" device_affinity="cpu0" ()
        ports_in (%outputPort_406, %outputPort_408, %outputPort_410 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_411, %inputPort_413 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Merge "merge" device_affinity="cpu0" ()
        ports_in (%outputPort_384, %outputPort_386 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_367 : !fifo.input_port<complex<f32>>)
    %inputPort_415, %outputPort_416 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_1916938481276772234.__fanout_complex_f32__2.6.out0->split.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_417, %outputPort_418 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_1916938481276772234.__fanout_complex_f32__2.6.out1->twiddles.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_419, %outputPort_420 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.split.out0->r2cell.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_421, %outputPort_422 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.split.out1->r2cell.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_423, %outputPort_424 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.twiddles.out0->r2cell.in2"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_425, %outputPort_426 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.r2cell.out0->fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_15446289516955298258.4.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_427, %outputPort_428 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.r2cell.out1->fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_15446289516955298258.5.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_429, %outputPort_430 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_15446289516955298258.4.out0->merge.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_431, %outputPort_432 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_15446289516955298258.5.out0->merge.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    cal.create_instance @fft__Radix2Cell "r2cell" device_affinity="cpu0" ()
        ports_in (%outputPort_420, %outputPort_422, %outputPort_424 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_425, %inputPort_427 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__TwiddleGenerator__v__N_dyn "twiddles" (%c2_i32 : i32)
        ports_in (%outputPort_418 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_423 : !fifo.input_port<complex<f32>>)
    cal.create_instance @__fanout_complex_f32__2 "fft__Butterfly$spec_1916938481276772234.__fanout_complex_f32__2.6" device_affinity="cpu0" ()
        ports_in (%outputPort_362 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_415, %inputPort_417 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Split__v__N_dyn "split" (%c2_i32 : i32)
        ports_in (%outputPort_416 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_419, %inputPort_421 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    %inputPort_433, %outputPort_434 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4.out0->split.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_435, %outputPort_436 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4.out1->twiddles.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_437, %outputPort_438 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.split.out0->r2cell.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_439, %outputPort_440 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.split.out1->r2cell.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_441, %outputPort_442 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.twiddles.out0->r2cell.in2"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_443, %outputPort_444 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.r2cell.out0->merge.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_445, %outputPort_446 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.r2cell.out1->merge.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    cal.create_instance @fft__Merge "merge" device_affinity="cpu0" ()
        ports_in (%outputPort_444, %outputPort_446 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_429 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__TwiddleGenerator__v__N_dyn "twiddles" (%c1_i32 : i32)
        ports_in (%outputPort_436 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_441 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Split__v__N_dyn "split" (%c1_i32 : i32)
        ports_in (%outputPort_434 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_437, %inputPort_439 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @__fanout_complex_f32__2 "fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4" device_affinity="cpu0" ()
        ports_in (%outputPort_426 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_433, %inputPort_435 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Radix2Cell "r2cell" device_affinity="cpu0" ()
        ports_in (%outputPort_438, %outputPort_440, %outputPort_442 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_443, %inputPort_445 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    %inputPort_447, %outputPort_448 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4.out0->split.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_449, %outputPort_450 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4.out1->twiddles.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_451, %outputPort_452 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.split.out0->r2cell.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_453, %outputPort_454 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.split.out1->r2cell.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_455, %outputPort_456 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.twiddles.out0->r2cell.in2"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_457, %outputPort_458 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.r2cell.out0->merge.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_459, %outputPort_460 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.r2cell.out1->merge.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    cal.create_instance @fft__Merge "merge" device_affinity="cpu0" ()
        ports_in (%outputPort_458, %outputPort_460 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_431 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__TwiddleGenerator__v__N_dyn "twiddles" (%c1_i32 : i32)
        ports_in (%outputPort_450 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_455 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Split__v__N_dyn "split" (%c1_i32 : i32)
        ports_in (%outputPort_448 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_451, %inputPort_453 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @__fanout_complex_f32__2 "fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4" device_affinity="cpu0" ()
        ports_in (%outputPort_428 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_447, %inputPort_449 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Radix2Cell "r2cell" device_affinity="cpu0" ()
        ports_in (%outputPort_452, %outputPort_454, %outputPort_456 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_457, %inputPort_459 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Merge "merge" device_affinity="cpu0" ()
        ports_in (%outputPort_430, %outputPort_432 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_365 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__TwiddleGenerator__v__N_dyn "twiddles" (%c8_i32 : i32)
        ports_in (%outputPort_336 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_341 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Radix2Cell "r2cell" device_affinity="cpu0" ()
        ports_in (%outputPort_338, %outputPort_340, %outputPort_342 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_343, %inputPort_345 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    %inputPort_461, %outputPort_462 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.fft__Butterfly$spec_9935405952460034831.__fanout_complex_f32__2.6.out0->split.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_463, %outputPort_464 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.fft__Butterfly$spec_9935405952460034831.__fanout_complex_f32__2.6.out1->twiddles.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_465, %outputPort_466 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.split.out0->r2cell.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_467, %outputPort_468 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.split.out1->r2cell.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_469, %outputPort_470 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.twiddles.out0->r2cell.in2"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_471, %outputPort_472 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.r2cell.out0->fft__Butterfly$spec_9935405952460034831.fft__Butterfly$spec_1916938481276772234.4.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_473, %outputPort_474 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.r2cell.out1->fft__Butterfly$spec_9935405952460034831.fft__Butterfly$spec_1916938481276772234.5.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_475, %outputPort_476 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.fft__Butterfly$spec_9935405952460034831.fft__Butterfly$spec_1916938481276772234.4.out0->merge.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_477, %outputPort_478 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.fft__Butterfly$spec_9935405952460034831.fft__Butterfly$spec_1916938481276772234.5.out0->merge.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    cal.create_instance @fft__Radix2Cell "r2cell" device_affinity="cpu0" ()
        ports_in (%outputPort_466, %outputPort_468, %outputPort_470 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_471, %inputPort_473 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Split__v__N_dyn "split" (%c4_i32 : i32)
        ports_in (%outputPort_462 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_465, %inputPort_467 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Merge "merge" device_affinity="cpu0" ()
        ports_in (%outputPort_476, %outputPort_478 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_347 : !fifo.input_port<complex<f32>>)
    cal.create_instance @__fanout_complex_f32__2 "fft__Butterfly$spec_9935405952460034831.__fanout_complex_f32__2.6" device_affinity="cpu0" ()
        ports_in (%outputPort_344 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_461, %inputPort_463 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__TwiddleGenerator__v__N_dyn "twiddles" (%c4_i32 : i32)
        ports_in (%outputPort_464 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_469 : !fifo.input_port<complex<f32>>)
    %inputPort_479, %outputPort_480 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_1916938481276772234.__fanout_complex_f32__2.6.out0->split.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_481, %outputPort_482 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_1916938481276772234.__fanout_complex_f32__2.6.out1->twiddles.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_483, %outputPort_484 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.split.out0->r2cell.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_485, %outputPort_486 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.split.out1->r2cell.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_487, %outputPort_488 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.twiddles.out0->r2cell.in2"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_489, %outputPort_490 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.r2cell.out0->fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_15446289516955298258.4.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_491, %outputPort_492 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.r2cell.out1->fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_15446289516955298258.5.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_493, %outputPort_494 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_15446289516955298258.4.out0->merge.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_495, %outputPort_496 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_15446289516955298258.5.out0->merge.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    cal.create_instance @fft__Radix2Cell "r2cell" device_affinity="cpu0" ()
        ports_in (%outputPort_484, %outputPort_486, %outputPort_488 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_489, %inputPort_491 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__TwiddleGenerator__v__N_dyn "twiddles" (%c2_i32 : i32)
        ports_in (%outputPort_482 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_487 : !fifo.input_port<complex<f32>>)
    cal.create_instance @__fanout_complex_f32__2 "fft__Butterfly$spec_1916938481276772234.__fanout_complex_f32__2.6" device_affinity="cpu0" ()
        ports_in (%outputPort_474 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_479, %inputPort_481 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Split__v__N_dyn "split" (%c2_i32 : i32)
        ports_in (%outputPort_480 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_483, %inputPort_485 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    %inputPort_497, %outputPort_498 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4.out0->split.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_499, %outputPort_500 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4.out1->twiddles.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_501, %outputPort_502 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.split.out0->r2cell.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_503, %outputPort_504 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.split.out1->r2cell.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_505, %outputPort_506 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.twiddles.out0->r2cell.in2"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_507, %outputPort_508 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.r2cell.out0->merge.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_509, %outputPort_510 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.r2cell.out1->merge.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    cal.create_instance @fft__Merge "merge" device_affinity="cpu0" ()
        ports_in (%outputPort_508, %outputPort_510 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_493 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__TwiddleGenerator__v__N_dyn "twiddles" (%c1_i32 : i32)
        ports_in (%outputPort_500 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_505 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Split__v__N_dyn "split" (%c1_i32 : i32)
        ports_in (%outputPort_498 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_501, %inputPort_503 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @__fanout_complex_f32__2 "fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4" device_affinity="cpu0" ()
        ports_in (%outputPort_490 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_497, %inputPort_499 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Radix2Cell "r2cell" device_affinity="cpu0" ()
        ports_in (%outputPort_502, %outputPort_504, %outputPort_506 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_507, %inputPort_509 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    %inputPort_511, %outputPort_512 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4.out0->split.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_513, %outputPort_514 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4.out1->twiddles.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_515, %outputPort_516 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.split.out0->r2cell.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_517, %outputPort_518 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.split.out1->r2cell.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_519, %outputPort_520 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.twiddles.out0->r2cell.in2"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_521, %outputPort_522 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.r2cell.out0->merge.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_523, %outputPort_524 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.r2cell.out1->merge.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    cal.create_instance @fft__Merge "merge" device_affinity="cpu0" ()
        ports_in (%outputPort_522, %outputPort_524 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_495 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__TwiddleGenerator__v__N_dyn "twiddles" (%c1_i32 : i32)
        ports_in (%outputPort_514 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_519 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Split__v__N_dyn "split" (%c1_i32 : i32)
        ports_in (%outputPort_512 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_515, %inputPort_517 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @__fanout_complex_f32__2 "fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4" device_affinity="cpu0" ()
        ports_in (%outputPort_492 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_511, %inputPort_513 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Radix2Cell "r2cell" device_affinity="cpu0" ()
        ports_in (%outputPort_516, %outputPort_518, %outputPort_520 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_521, %inputPort_523 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Merge "merge" device_affinity="cpu0" ()
        ports_in (%outputPort_494, %outputPort_496 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_477 : !fifo.input_port<complex<f32>>)
    %inputPort_525, %outputPort_526 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_1916938481276772234.__fanout_complex_f32__2.6.out0->split.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_527, %outputPort_528 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_1916938481276772234.__fanout_complex_f32__2.6.out1->twiddles.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_529, %outputPort_530 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.split.out0->r2cell.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_531, %outputPort_532 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.split.out1->r2cell.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_533, %outputPort_534 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.twiddles.out0->r2cell.in2"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_535, %outputPort_536 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.r2cell.out0->fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_15446289516955298258.4.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_537, %outputPort_538 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.r2cell.out1->fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_15446289516955298258.5.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_539, %outputPort_540 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_15446289516955298258.4.out0->merge.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_541, %outputPort_542 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_15446289516955298258.5.out0->merge.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    cal.create_instance @fft__Radix2Cell "r2cell" device_affinity="cpu0" ()
        ports_in (%outputPort_530, %outputPort_532, %outputPort_534 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_535, %inputPort_537 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__TwiddleGenerator__v__N_dyn "twiddles" (%c2_i32 : i32)
        ports_in (%outputPort_528 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_533 : !fifo.input_port<complex<f32>>)
    cal.create_instance @__fanout_complex_f32__2 "fft__Butterfly$spec_1916938481276772234.__fanout_complex_f32__2.6" device_affinity="cpu0" ()
        ports_in (%outputPort_472 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_525, %inputPort_527 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Split__v__N_dyn "split" (%c2_i32 : i32)
        ports_in (%outputPort_526 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_529, %inputPort_531 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    %inputPort_543, %outputPort_544 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4.out0->split.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_545, %outputPort_546 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4.out1->twiddles.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_547, %outputPort_548 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.split.out0->r2cell.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_549, %outputPort_550 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.split.out1->r2cell.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_551, %outputPort_552 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.twiddles.out0->r2cell.in2"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_553, %outputPort_554 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.r2cell.out0->merge.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_555, %outputPort_556 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.r2cell.out1->merge.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    cal.create_instance @fft__Merge "merge" device_affinity="cpu0" ()
        ports_in (%outputPort_554, %outputPort_556 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_539 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__TwiddleGenerator__v__N_dyn "twiddles" (%c1_i32 : i32)
        ports_in (%outputPort_546 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_551 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Split__v__N_dyn "split" (%c1_i32 : i32)
        ports_in (%outputPort_544 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_547, %inputPort_549 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @__fanout_complex_f32__2 "fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4" device_affinity="cpu0" ()
        ports_in (%outputPort_536 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_543, %inputPort_545 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Radix2Cell "r2cell" device_affinity="cpu0" ()
        ports_in (%outputPort_548, %outputPort_550, %outputPort_552 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_553, %inputPort_555 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    %inputPort_557, %outputPort_558 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4.out0->split.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_559, %outputPort_560 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4.out1->twiddles.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_561, %outputPort_562 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.split.out0->r2cell.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_563, %outputPort_564 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.split.out1->r2cell.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_565, %outputPort_566 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.twiddles.out0->r2cell.in2"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_567, %outputPort_568 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.r2cell.out0->merge.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_569, %outputPort_570 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.r2cell.out1->merge.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    cal.create_instance @fft__Merge "merge" device_affinity="cpu0" ()
        ports_in (%outputPort_568, %outputPort_570 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_541 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__TwiddleGenerator__v__N_dyn "twiddles" (%c1_i32 : i32)
        ports_in (%outputPort_560 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_565 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Split__v__N_dyn "split" (%c1_i32 : i32)
        ports_in (%outputPort_558 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_561, %inputPort_563 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @__fanout_complex_f32__2 "fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4" device_affinity="cpu0" ()
        ports_in (%outputPort_538 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_557, %inputPort_559 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Radix2Cell "r2cell" device_affinity="cpu0" ()
        ports_in (%outputPort_562, %outputPort_564, %outputPort_566 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_567, %inputPort_569 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Merge "merge" device_affinity="cpu0" ()
        ports_in (%outputPort_540, %outputPort_542 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_475 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Split__v__N_dyn "split" (%c8_i32 : i32)
        ports_in (%outputPort_334 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_337, %inputPort_339 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Split__v__N_dyn "split" (%c16_i32 : i32)
        ports_in (%outputPort_78 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_81, %inputPort_83 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Radix2Cell "r2cell" device_affinity="cpu0" ()
        ports_in (%outputPort_64, %outputPort_66, %outputPort_68 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_69, %inputPort_71 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__TwiddleGenerator__v__N_dyn "twiddles" (%c32_i32 : i32)
        ports_in (%outputPort_62 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_67 : !fifo.input_port<complex<f32>>)
    cal.create_instance @__fanout_complex_f32__2 "fft__Butterfly$spec_17640631431051100303.__fanout_complex_f32__2.6" device_affinity="cpu0" ()
        ports_in (%outputPort_52 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_59, %inputPort_61 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    %inputPort_571, %outputPort_572 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_3035977640463470463.fft__Butterfly$spec_3035977640463470463.__fanout_complex_f32__2.6.out0->split.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_573, %outputPort_574 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_3035977640463470463.fft__Butterfly$spec_3035977640463470463.__fanout_complex_f32__2.6.out1->twiddles.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_575, %outputPort_576 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_3035977640463470463.split.out0->r2cell.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_577, %outputPort_578 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_3035977640463470463.split.out1->r2cell.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_579, %outputPort_580 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_3035977640463470463.twiddles.out0->r2cell.in2"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_581, %outputPort_582 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_3035977640463470463.r2cell.out0->fft__Butterfly$spec_3035977640463470463.fft__Butterfly$spec_16755419077516047831.4.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_583, %outputPort_584 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_3035977640463470463.r2cell.out1->fft__Butterfly$spec_3035977640463470463.fft__Butterfly$spec_16755419077516047831.5.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_585, %outputPort_586 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_3035977640463470463.fft__Butterfly$spec_3035977640463470463.fft__Butterfly$spec_16755419077516047831.4.out0->merge.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_587, %outputPort_588 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_3035977640463470463.fft__Butterfly$spec_3035977640463470463.fft__Butterfly$spec_16755419077516047831.5.out0->merge.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    cal.create_instance @fft__TwiddleGenerator__v__N_dyn "twiddles" (%c16_i32 : i32)
        ports_in (%outputPort_574 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_579 : !fifo.input_port<complex<f32>>)
    %inputPort_589, %outputPort_590 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_16755419077516047831.fft__Butterfly$spec_16755419077516047831.__fanout_complex_f32__2.6.out0->split.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_591, %outputPort_592 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_16755419077516047831.fft__Butterfly$spec_16755419077516047831.__fanout_complex_f32__2.6.out1->twiddles.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_593, %outputPort_594 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_16755419077516047831.split.out0->r2cell.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_595, %outputPort_596 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_16755419077516047831.split.out1->r2cell.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_597, %outputPort_598 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_16755419077516047831.twiddles.out0->r2cell.in2"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_599, %outputPort_600 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_16755419077516047831.r2cell.out0->fft__Butterfly$spec_16755419077516047831.fft__Butterfly$spec_9935405952460034831.4.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_601, %outputPort_602 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_16755419077516047831.r2cell.out1->fft__Butterfly$spec_16755419077516047831.fft__Butterfly$spec_9935405952460034831.5.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_603, %outputPort_604 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_16755419077516047831.fft__Butterfly$spec_16755419077516047831.fft__Butterfly$spec_9935405952460034831.4.out0->merge.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_605, %outputPort_606 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_16755419077516047831.fft__Butterfly$spec_16755419077516047831.fft__Butterfly$spec_9935405952460034831.5.out0->merge.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    cal.create_instance @__fanout_complex_f32__2 "fft__Butterfly$spec_16755419077516047831.__fanout_complex_f32__2.6" device_affinity="cpu0" ()
        ports_in (%outputPort_584 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_589, %inputPort_591 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Merge "merge" device_affinity="cpu0" ()
        ports_in (%outputPort_604, %outputPort_606 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_587 : !fifo.input_port<complex<f32>>)
    %inputPort_607, %outputPort_608 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.fft__Butterfly$spec_9935405952460034831.__fanout_complex_f32__2.6.out0->split.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_609, %outputPort_610 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.fft__Butterfly$spec_9935405952460034831.__fanout_complex_f32__2.6.out1->twiddles.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_611, %outputPort_612 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.split.out0->r2cell.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_613, %outputPort_614 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.split.out1->r2cell.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_615, %outputPort_616 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.twiddles.out0->r2cell.in2"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_617, %outputPort_618 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.r2cell.out0->fft__Butterfly$spec_9935405952460034831.fft__Butterfly$spec_1916938481276772234.4.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_619, %outputPort_620 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.r2cell.out1->fft__Butterfly$spec_9935405952460034831.fft__Butterfly$spec_1916938481276772234.5.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_621, %outputPort_622 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.fft__Butterfly$spec_9935405952460034831.fft__Butterfly$spec_1916938481276772234.4.out0->merge.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_623, %outputPort_624 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.fft__Butterfly$spec_9935405952460034831.fft__Butterfly$spec_1916938481276772234.5.out0->merge.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    cal.create_instance @fft__Radix2Cell "r2cell" device_affinity="cpu0" ()
        ports_in (%outputPort_612, %outputPort_614, %outputPort_616 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_617, %inputPort_619 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Split__v__N_dyn "split" (%c4_i32 : i32)
        ports_in (%outputPort_608 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_611, %inputPort_613 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Merge "merge" device_affinity="cpu0" ()
        ports_in (%outputPort_622, %outputPort_624 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_605 : !fifo.input_port<complex<f32>>)
    cal.create_instance @__fanout_complex_f32__2 "fft__Butterfly$spec_9935405952460034831.__fanout_complex_f32__2.6" device_affinity="cpu0" ()
        ports_in (%outputPort_602 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_607, %inputPort_609 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__TwiddleGenerator__v__N_dyn "twiddles" (%c4_i32 : i32)
        ports_in (%outputPort_610 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_615 : !fifo.input_port<complex<f32>>)
    %inputPort_625, %outputPort_626 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_1916938481276772234.__fanout_complex_f32__2.6.out0->split.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_627, %outputPort_628 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_1916938481276772234.__fanout_complex_f32__2.6.out1->twiddles.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_629, %outputPort_630 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.split.out0->r2cell.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_631, %outputPort_632 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.split.out1->r2cell.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_633, %outputPort_634 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.twiddles.out0->r2cell.in2"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_635, %outputPort_636 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.r2cell.out0->fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_15446289516955298258.4.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_637, %outputPort_638 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.r2cell.out1->fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_15446289516955298258.5.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_639, %outputPort_640 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_15446289516955298258.4.out0->merge.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_641, %outputPort_642 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_15446289516955298258.5.out0->merge.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    cal.create_instance @fft__Radix2Cell "r2cell" device_affinity="cpu0" ()
        ports_in (%outputPort_630, %outputPort_632, %outputPort_634 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_635, %inputPort_637 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__TwiddleGenerator__v__N_dyn "twiddles" (%c2_i32 : i32)
        ports_in (%outputPort_628 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_633 : !fifo.input_port<complex<f32>>)
    cal.create_instance @__fanout_complex_f32__2 "fft__Butterfly$spec_1916938481276772234.__fanout_complex_f32__2.6" device_affinity="cpu0" ()
        ports_in (%outputPort_620 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_625, %inputPort_627 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Split__v__N_dyn "split" (%c2_i32 : i32)
        ports_in (%outputPort_626 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_629, %inputPort_631 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    %inputPort_643, %outputPort_644 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4.out0->split.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_645, %outputPort_646 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4.out1->twiddles.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_647, %outputPort_648 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.split.out0->r2cell.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_649, %outputPort_650 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.split.out1->r2cell.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_651, %outputPort_652 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.twiddles.out0->r2cell.in2"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_653, %outputPort_654 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.r2cell.out0->merge.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_655, %outputPort_656 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.r2cell.out1->merge.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    cal.create_instance @fft__Merge "merge" device_affinity="cpu0" ()
        ports_in (%outputPort_654, %outputPort_656 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_639 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__TwiddleGenerator__v__N_dyn "twiddles" (%c1_i32 : i32)
        ports_in (%outputPort_646 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_651 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Split__v__N_dyn "split" (%c1_i32 : i32)
        ports_in (%outputPort_644 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_647, %inputPort_649 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @__fanout_complex_f32__2 "fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4" device_affinity="cpu0" ()
        ports_in (%outputPort_636 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_643, %inputPort_645 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Radix2Cell "r2cell" device_affinity="cpu0" ()
        ports_in (%outputPort_648, %outputPort_650, %outputPort_652 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_653, %inputPort_655 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    %inputPort_657, %outputPort_658 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4.out0->split.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_659, %outputPort_660 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4.out1->twiddles.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_661, %outputPort_662 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.split.out0->r2cell.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_663, %outputPort_664 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.split.out1->r2cell.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_665, %outputPort_666 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.twiddles.out0->r2cell.in2"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_667, %outputPort_668 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.r2cell.out0->merge.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_669, %outputPort_670 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.r2cell.out1->merge.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    cal.create_instance @fft__Merge "merge" device_affinity="cpu0" ()
        ports_in (%outputPort_668, %outputPort_670 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_641 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__TwiddleGenerator__v__N_dyn "twiddles" (%c1_i32 : i32)
        ports_in (%outputPort_660 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_665 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Split__v__N_dyn "split" (%c1_i32 : i32)
        ports_in (%outputPort_658 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_661, %inputPort_663 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @__fanout_complex_f32__2 "fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4" device_affinity="cpu0" ()
        ports_in (%outputPort_638 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_657, %inputPort_659 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Radix2Cell "r2cell" device_affinity="cpu0" ()
        ports_in (%outputPort_662, %outputPort_664, %outputPort_666 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_667, %inputPort_669 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Merge "merge" device_affinity="cpu0" ()
        ports_in (%outputPort_640, %outputPort_642 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_623 : !fifo.input_port<complex<f32>>)
    %inputPort_671, %outputPort_672 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_1916938481276772234.__fanout_complex_f32__2.6.out0->split.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_673, %outputPort_674 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_1916938481276772234.__fanout_complex_f32__2.6.out1->twiddles.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_675, %outputPort_676 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.split.out0->r2cell.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_677, %outputPort_678 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.split.out1->r2cell.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_679, %outputPort_680 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.twiddles.out0->r2cell.in2"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_681, %outputPort_682 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.r2cell.out0->fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_15446289516955298258.4.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_683, %outputPort_684 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.r2cell.out1->fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_15446289516955298258.5.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_685, %outputPort_686 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_15446289516955298258.4.out0->merge.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_687, %outputPort_688 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_15446289516955298258.5.out0->merge.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    cal.create_instance @fft__Radix2Cell "r2cell" device_affinity="cpu0" ()
        ports_in (%outputPort_676, %outputPort_678, %outputPort_680 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_681, %inputPort_683 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__TwiddleGenerator__v__N_dyn "twiddles" (%c2_i32 : i32)
        ports_in (%outputPort_674 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_679 : !fifo.input_port<complex<f32>>)
    cal.create_instance @__fanout_complex_f32__2 "fft__Butterfly$spec_1916938481276772234.__fanout_complex_f32__2.6" device_affinity="cpu0" ()
        ports_in (%outputPort_618 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_671, %inputPort_673 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Split__v__N_dyn "split" (%c2_i32 : i32)
        ports_in (%outputPort_672 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_675, %inputPort_677 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    %inputPort_689, %outputPort_690 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4.out0->split.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_691, %outputPort_692 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4.out1->twiddles.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_693, %outputPort_694 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.split.out0->r2cell.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_695, %outputPort_696 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.split.out1->r2cell.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_697, %outputPort_698 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.twiddles.out0->r2cell.in2"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_699, %outputPort_700 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.r2cell.out0->merge.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_701, %outputPort_702 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.r2cell.out1->merge.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    cal.create_instance @fft__Merge "merge" device_affinity="cpu0" ()
        ports_in (%outputPort_700, %outputPort_702 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_685 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__TwiddleGenerator__v__N_dyn "twiddles" (%c1_i32 : i32)
        ports_in (%outputPort_692 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_697 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Split__v__N_dyn "split" (%c1_i32 : i32)
        ports_in (%outputPort_690 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_693, %inputPort_695 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @__fanout_complex_f32__2 "fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4" device_affinity="cpu0" ()
        ports_in (%outputPort_682 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_689, %inputPort_691 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Radix2Cell "r2cell" device_affinity="cpu0" ()
        ports_in (%outputPort_694, %outputPort_696, %outputPort_698 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_699, %inputPort_701 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    %inputPort_703, %outputPort_704 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4.out0->split.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_705, %outputPort_706 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4.out1->twiddles.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_707, %outputPort_708 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.split.out0->r2cell.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_709, %outputPort_710 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.split.out1->r2cell.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_711, %outputPort_712 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.twiddles.out0->r2cell.in2"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_713, %outputPort_714 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.r2cell.out0->merge.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_715, %outputPort_716 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.r2cell.out1->merge.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    cal.create_instance @fft__Merge "merge" device_affinity="cpu0" ()
        ports_in (%outputPort_714, %outputPort_716 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_687 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__TwiddleGenerator__v__N_dyn "twiddles" (%c1_i32 : i32)
        ports_in (%outputPort_706 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_711 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Split__v__N_dyn "split" (%c1_i32 : i32)
        ports_in (%outputPort_704 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_707, %inputPort_709 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @__fanout_complex_f32__2 "fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4" device_affinity="cpu0" ()
        ports_in (%outputPort_684 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_703, %inputPort_705 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Radix2Cell "r2cell" device_affinity="cpu0" ()
        ports_in (%outputPort_708, %outputPort_710, %outputPort_712 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_713, %inputPort_715 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Merge "merge" device_affinity="cpu0" ()
        ports_in (%outputPort_686, %outputPort_688 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_621 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__TwiddleGenerator__v__N_dyn "twiddles" (%c8_i32 : i32)
        ports_in (%outputPort_592 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_597 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Radix2Cell "r2cell" device_affinity="cpu0" ()
        ports_in (%outputPort_594, %outputPort_596, %outputPort_598 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_599, %inputPort_601 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    %inputPort_717, %outputPort_718 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.fft__Butterfly$spec_9935405952460034831.__fanout_complex_f32__2.6.out0->split.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_719, %outputPort_720 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.fft__Butterfly$spec_9935405952460034831.__fanout_complex_f32__2.6.out1->twiddles.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_721, %outputPort_722 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.split.out0->r2cell.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_723, %outputPort_724 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.split.out1->r2cell.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_725, %outputPort_726 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.twiddles.out0->r2cell.in2"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_727, %outputPort_728 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.r2cell.out0->fft__Butterfly$spec_9935405952460034831.fft__Butterfly$spec_1916938481276772234.4.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_729, %outputPort_730 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.r2cell.out1->fft__Butterfly$spec_9935405952460034831.fft__Butterfly$spec_1916938481276772234.5.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_731, %outputPort_732 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.fft__Butterfly$spec_9935405952460034831.fft__Butterfly$spec_1916938481276772234.4.out0->merge.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_733, %outputPort_734 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.fft__Butterfly$spec_9935405952460034831.fft__Butterfly$spec_1916938481276772234.5.out0->merge.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    cal.create_instance @fft__Radix2Cell "r2cell" device_affinity="cpu0" ()
        ports_in (%outputPort_722, %outputPort_724, %outputPort_726 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_727, %inputPort_729 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Split__v__N_dyn "split" (%c4_i32 : i32)
        ports_in (%outputPort_718 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_721, %inputPort_723 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Merge "merge" device_affinity="cpu0" ()
        ports_in (%outputPort_732, %outputPort_734 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_603 : !fifo.input_port<complex<f32>>)
    cal.create_instance @__fanout_complex_f32__2 "fft__Butterfly$spec_9935405952460034831.__fanout_complex_f32__2.6" device_affinity="cpu0" ()
        ports_in (%outputPort_600 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_717, %inputPort_719 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__TwiddleGenerator__v__N_dyn "twiddles" (%c4_i32 : i32)
        ports_in (%outputPort_720 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_725 : !fifo.input_port<complex<f32>>)
    %inputPort_735, %outputPort_736 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_1916938481276772234.__fanout_complex_f32__2.6.out0->split.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_737, %outputPort_738 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_1916938481276772234.__fanout_complex_f32__2.6.out1->twiddles.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_739, %outputPort_740 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.split.out0->r2cell.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_741, %outputPort_742 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.split.out1->r2cell.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_743, %outputPort_744 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.twiddles.out0->r2cell.in2"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_745, %outputPort_746 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.r2cell.out0->fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_15446289516955298258.4.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_747, %outputPort_748 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.r2cell.out1->fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_15446289516955298258.5.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_749, %outputPort_750 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_15446289516955298258.4.out0->merge.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_751, %outputPort_752 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_15446289516955298258.5.out0->merge.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    cal.create_instance @fft__Radix2Cell "r2cell" device_affinity="cpu0" ()
        ports_in (%outputPort_740, %outputPort_742, %outputPort_744 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_745, %inputPort_747 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__TwiddleGenerator__v__N_dyn "twiddles" (%c2_i32 : i32)
        ports_in (%outputPort_738 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_743 : !fifo.input_port<complex<f32>>)
    cal.create_instance @__fanout_complex_f32__2 "fft__Butterfly$spec_1916938481276772234.__fanout_complex_f32__2.6" device_affinity="cpu0" ()
        ports_in (%outputPort_730 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_735, %inputPort_737 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Split__v__N_dyn "split" (%c2_i32 : i32)
        ports_in (%outputPort_736 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_739, %inputPort_741 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    %inputPort_753, %outputPort_754 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4.out0->split.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_755, %outputPort_756 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4.out1->twiddles.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_757, %outputPort_758 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.split.out0->r2cell.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_759, %outputPort_760 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.split.out1->r2cell.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_761, %outputPort_762 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.twiddles.out0->r2cell.in2"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_763, %outputPort_764 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.r2cell.out0->merge.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_765, %outputPort_766 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.r2cell.out1->merge.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    cal.create_instance @fft__Merge "merge" device_affinity="cpu0" ()
        ports_in (%outputPort_764, %outputPort_766 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_749 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__TwiddleGenerator__v__N_dyn "twiddles" (%c1_i32 : i32)
        ports_in (%outputPort_756 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_761 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Split__v__N_dyn "split" (%c1_i32 : i32)
        ports_in (%outputPort_754 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_757, %inputPort_759 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @__fanout_complex_f32__2 "fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4" device_affinity="cpu0" ()
        ports_in (%outputPort_746 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_753, %inputPort_755 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Radix2Cell "r2cell" device_affinity="cpu0" ()
        ports_in (%outputPort_758, %outputPort_760, %outputPort_762 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_763, %inputPort_765 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    %inputPort_767, %outputPort_768 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4.out0->split.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_769, %outputPort_770 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4.out1->twiddles.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_771, %outputPort_772 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.split.out0->r2cell.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_773, %outputPort_774 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.split.out1->r2cell.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_775, %outputPort_776 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.twiddles.out0->r2cell.in2"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_777, %outputPort_778 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.r2cell.out0->merge.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_779, %outputPort_780 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.r2cell.out1->merge.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    cal.create_instance @fft__Merge "merge" device_affinity="cpu0" ()
        ports_in (%outputPort_778, %outputPort_780 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_751 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__TwiddleGenerator__v__N_dyn "twiddles" (%c1_i32 : i32)
        ports_in (%outputPort_770 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_775 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Split__v__N_dyn "split" (%c1_i32 : i32)
        ports_in (%outputPort_768 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_771, %inputPort_773 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @__fanout_complex_f32__2 "fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4" device_affinity="cpu0" ()
        ports_in (%outputPort_748 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_767, %inputPort_769 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Radix2Cell "r2cell" device_affinity="cpu0" ()
        ports_in (%outputPort_772, %outputPort_774, %outputPort_776 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_777, %inputPort_779 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Merge "merge" device_affinity="cpu0" ()
        ports_in (%outputPort_750, %outputPort_752 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_733 : !fifo.input_port<complex<f32>>)
    %inputPort_781, %outputPort_782 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_1916938481276772234.__fanout_complex_f32__2.6.out0->split.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_783, %outputPort_784 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_1916938481276772234.__fanout_complex_f32__2.6.out1->twiddles.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_785, %outputPort_786 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.split.out0->r2cell.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_787, %outputPort_788 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.split.out1->r2cell.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_789, %outputPort_790 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.twiddles.out0->r2cell.in2"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_791, %outputPort_792 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.r2cell.out0->fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_15446289516955298258.4.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_793, %outputPort_794 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.r2cell.out1->fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_15446289516955298258.5.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_795, %outputPort_796 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_15446289516955298258.4.out0->merge.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_797, %outputPort_798 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_15446289516955298258.5.out0->merge.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    cal.create_instance @fft__Radix2Cell "r2cell" device_affinity="cpu0" ()
        ports_in (%outputPort_786, %outputPort_788, %outputPort_790 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_791, %inputPort_793 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__TwiddleGenerator__v__N_dyn "twiddles" (%c2_i32 : i32)
        ports_in (%outputPort_784 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_789 : !fifo.input_port<complex<f32>>)
    cal.create_instance @__fanout_complex_f32__2 "fft__Butterfly$spec_1916938481276772234.__fanout_complex_f32__2.6" device_affinity="cpu0" ()
        ports_in (%outputPort_728 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_781, %inputPort_783 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Split__v__N_dyn "split" (%c2_i32 : i32)
        ports_in (%outputPort_782 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_785, %inputPort_787 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    %inputPort_799, %outputPort_800 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4.out0->split.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_801, %outputPort_802 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4.out1->twiddles.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_803, %outputPort_804 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.split.out0->r2cell.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_805, %outputPort_806 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.split.out1->r2cell.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_807, %outputPort_808 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.twiddles.out0->r2cell.in2"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_809, %outputPort_810 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.r2cell.out0->merge.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_811, %outputPort_812 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.r2cell.out1->merge.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    cal.create_instance @fft__Merge "merge" device_affinity="cpu0" ()
        ports_in (%outputPort_810, %outputPort_812 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_795 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__TwiddleGenerator__v__N_dyn "twiddles" (%c1_i32 : i32)
        ports_in (%outputPort_802 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_807 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Split__v__N_dyn "split" (%c1_i32 : i32)
        ports_in (%outputPort_800 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_803, %inputPort_805 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @__fanout_complex_f32__2 "fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4" device_affinity="cpu0" ()
        ports_in (%outputPort_792 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_799, %inputPort_801 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Radix2Cell "r2cell" device_affinity="cpu0" ()
        ports_in (%outputPort_804, %outputPort_806, %outputPort_808 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_809, %inputPort_811 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    %inputPort_813, %outputPort_814 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4.out0->split.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_815, %outputPort_816 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4.out1->twiddles.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_817, %outputPort_818 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.split.out0->r2cell.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_819, %outputPort_820 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.split.out1->r2cell.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_821, %outputPort_822 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.twiddles.out0->r2cell.in2"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_823, %outputPort_824 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.r2cell.out0->merge.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_825, %outputPort_826 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.r2cell.out1->merge.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    cal.create_instance @fft__Merge "merge" device_affinity="cpu0" ()
        ports_in (%outputPort_824, %outputPort_826 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_797 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__TwiddleGenerator__v__N_dyn "twiddles" (%c1_i32 : i32)
        ports_in (%outputPort_816 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_821 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Split__v__N_dyn "split" (%c1_i32 : i32)
        ports_in (%outputPort_814 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_817, %inputPort_819 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @__fanout_complex_f32__2 "fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4" device_affinity="cpu0" ()
        ports_in (%outputPort_794 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_813, %inputPort_815 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Radix2Cell "r2cell" device_affinity="cpu0" ()
        ports_in (%outputPort_818, %outputPort_820, %outputPort_822 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_823, %inputPort_825 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Merge "merge" device_affinity="cpu0" ()
        ports_in (%outputPort_796, %outputPort_798 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_731 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Split__v__N_dyn "split" (%c8_i32 : i32)
        ports_in (%outputPort_590 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_593, %inputPort_595 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Radix2Cell "r2cell" device_affinity="cpu0" ()
        ports_in (%outputPort_576, %outputPort_578, %outputPort_580 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_581, %inputPort_583 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Merge "merge" device_affinity="cpu0" ()
        ports_in (%outputPort_586, %outputPort_588 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_75 : !fifo.input_port<complex<f32>>)
    cal.create_instance @__fanout_complex_f32__2 "fft__Butterfly$spec_3035977640463470463.__fanout_complex_f32__2.6" device_affinity="cpu0" ()
        ports_in (%outputPort_72 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_571, %inputPort_573 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    %inputPort_827, %outputPort_828 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_16755419077516047831.fft__Butterfly$spec_16755419077516047831.__fanout_complex_f32__2.6.out0->split.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_829, %outputPort_830 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_16755419077516047831.fft__Butterfly$spec_16755419077516047831.__fanout_complex_f32__2.6.out1->twiddles.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_831, %outputPort_832 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_16755419077516047831.split.out0->r2cell.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_833, %outputPort_834 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_16755419077516047831.split.out1->r2cell.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_835, %outputPort_836 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_16755419077516047831.twiddles.out0->r2cell.in2"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_837, %outputPort_838 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_16755419077516047831.r2cell.out0->fft__Butterfly$spec_16755419077516047831.fft__Butterfly$spec_9935405952460034831.4.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_839, %outputPort_840 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_16755419077516047831.r2cell.out1->fft__Butterfly$spec_16755419077516047831.fft__Butterfly$spec_9935405952460034831.5.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_841, %outputPort_842 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_16755419077516047831.fft__Butterfly$spec_16755419077516047831.fft__Butterfly$spec_9935405952460034831.4.out0->merge.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_843, %outputPort_844 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_16755419077516047831.fft__Butterfly$spec_16755419077516047831.fft__Butterfly$spec_9935405952460034831.5.out0->merge.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    cal.create_instance @__fanout_complex_f32__2 "fft__Butterfly$spec_16755419077516047831.__fanout_complex_f32__2.6" device_affinity="cpu0" ()
        ports_in (%outputPort_582 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_827, %inputPort_829 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Merge "merge" device_affinity="cpu0" ()
        ports_in (%outputPort_842, %outputPort_844 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_585 : !fifo.input_port<complex<f32>>)
    %inputPort_845, %outputPort_846 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.fft__Butterfly$spec_9935405952460034831.__fanout_complex_f32__2.6.out0->split.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_847, %outputPort_848 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.fft__Butterfly$spec_9935405952460034831.__fanout_complex_f32__2.6.out1->twiddles.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_849, %outputPort_850 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.split.out0->r2cell.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_851, %outputPort_852 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.split.out1->r2cell.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_853, %outputPort_854 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.twiddles.out0->r2cell.in2"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_855, %outputPort_856 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.r2cell.out0->fft__Butterfly$spec_9935405952460034831.fft__Butterfly$spec_1916938481276772234.4.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_857, %outputPort_858 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.r2cell.out1->fft__Butterfly$spec_9935405952460034831.fft__Butterfly$spec_1916938481276772234.5.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_859, %outputPort_860 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.fft__Butterfly$spec_9935405952460034831.fft__Butterfly$spec_1916938481276772234.4.out0->merge.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_861, %outputPort_862 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.fft__Butterfly$spec_9935405952460034831.fft__Butterfly$spec_1916938481276772234.5.out0->merge.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    cal.create_instance @fft__Radix2Cell "r2cell" device_affinity="cpu0" ()
        ports_in (%outputPort_850, %outputPort_852, %outputPort_854 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_855, %inputPort_857 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Split__v__N_dyn "split" (%c4_i32 : i32)
        ports_in (%outputPort_846 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_849, %inputPort_851 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Merge "merge" device_affinity="cpu0" ()
        ports_in (%outputPort_860, %outputPort_862 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_843 : !fifo.input_port<complex<f32>>)
    cal.create_instance @__fanout_complex_f32__2 "fft__Butterfly$spec_9935405952460034831.__fanout_complex_f32__2.6" device_affinity="cpu0" ()
        ports_in (%outputPort_840 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_845, %inputPort_847 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__TwiddleGenerator__v__N_dyn "twiddles" (%c4_i32 : i32)
        ports_in (%outputPort_848 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_853 : !fifo.input_port<complex<f32>>)
    %inputPort_863, %outputPort_864 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_1916938481276772234.__fanout_complex_f32__2.6.out0->split.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_865, %outputPort_866 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_1916938481276772234.__fanout_complex_f32__2.6.out1->twiddles.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_867, %outputPort_868 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.split.out0->r2cell.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_869, %outputPort_870 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.split.out1->r2cell.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_871, %outputPort_872 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.twiddles.out0->r2cell.in2"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_873, %outputPort_874 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.r2cell.out0->fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_15446289516955298258.4.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_875, %outputPort_876 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.r2cell.out1->fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_15446289516955298258.5.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_877, %outputPort_878 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_15446289516955298258.4.out0->merge.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_879, %outputPort_880 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_15446289516955298258.5.out0->merge.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    cal.create_instance @fft__Radix2Cell "r2cell" device_affinity="cpu0" ()
        ports_in (%outputPort_868, %outputPort_870, %outputPort_872 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_873, %inputPort_875 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__TwiddleGenerator__v__N_dyn "twiddles" (%c2_i32 : i32)
        ports_in (%outputPort_866 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_871 : !fifo.input_port<complex<f32>>)
    cal.create_instance @__fanout_complex_f32__2 "fft__Butterfly$spec_1916938481276772234.__fanout_complex_f32__2.6" device_affinity="cpu0" ()
        ports_in (%outputPort_858 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_863, %inputPort_865 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Split__v__N_dyn "split" (%c2_i32 : i32)
        ports_in (%outputPort_864 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_867, %inputPort_869 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    %inputPort_881, %outputPort_882 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4.out0->split.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_883, %outputPort_884 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4.out1->twiddles.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_885, %outputPort_886 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.split.out0->r2cell.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_887, %outputPort_888 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.split.out1->r2cell.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_889, %outputPort_890 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.twiddles.out0->r2cell.in2"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_891, %outputPort_892 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.r2cell.out0->merge.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_893, %outputPort_894 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.r2cell.out1->merge.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    cal.create_instance @fft__Merge "merge" device_affinity="cpu0" ()
        ports_in (%outputPort_892, %outputPort_894 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_877 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__TwiddleGenerator__v__N_dyn "twiddles" (%c1_i32 : i32)
        ports_in (%outputPort_884 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_889 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Split__v__N_dyn "split" (%c1_i32 : i32)
        ports_in (%outputPort_882 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_885, %inputPort_887 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @__fanout_complex_f32__2 "fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4" device_affinity="cpu0" ()
        ports_in (%outputPort_874 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_881, %inputPort_883 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Radix2Cell "r2cell" device_affinity="cpu0" ()
        ports_in (%outputPort_886, %outputPort_888, %outputPort_890 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_891, %inputPort_893 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    %inputPort_895, %outputPort_896 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4.out0->split.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_897, %outputPort_898 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4.out1->twiddles.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_899, %outputPort_900 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.split.out0->r2cell.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_901, %outputPort_902 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.split.out1->r2cell.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_903, %outputPort_904 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.twiddles.out0->r2cell.in2"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_905, %outputPort_906 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.r2cell.out0->merge.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_907, %outputPort_908 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.r2cell.out1->merge.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    cal.create_instance @fft__Merge "merge" device_affinity="cpu0" ()
        ports_in (%outputPort_906, %outputPort_908 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_879 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__TwiddleGenerator__v__N_dyn "twiddles" (%c1_i32 : i32)
        ports_in (%outputPort_898 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_903 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Split__v__N_dyn "split" (%c1_i32 : i32)
        ports_in (%outputPort_896 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_899, %inputPort_901 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @__fanout_complex_f32__2 "fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4" device_affinity="cpu0" ()
        ports_in (%outputPort_876 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_895, %inputPort_897 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Radix2Cell "r2cell" device_affinity="cpu0" ()
        ports_in (%outputPort_900, %outputPort_902, %outputPort_904 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_905, %inputPort_907 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Merge "merge" device_affinity="cpu0" ()
        ports_in (%outputPort_878, %outputPort_880 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_861 : !fifo.input_port<complex<f32>>)
    %inputPort_909, %outputPort_910 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_1916938481276772234.__fanout_complex_f32__2.6.out0->split.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_911, %outputPort_912 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_1916938481276772234.__fanout_complex_f32__2.6.out1->twiddles.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_913, %outputPort_914 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.split.out0->r2cell.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_915, %outputPort_916 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.split.out1->r2cell.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_917, %outputPort_918 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.twiddles.out0->r2cell.in2"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_919, %outputPort_920 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.r2cell.out0->fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_15446289516955298258.4.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_921, %outputPort_922 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.r2cell.out1->fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_15446289516955298258.5.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_923, %outputPort_924 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_15446289516955298258.4.out0->merge.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_925, %outputPort_926 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_15446289516955298258.5.out0->merge.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    cal.create_instance @fft__Radix2Cell "r2cell" device_affinity="cpu0" ()
        ports_in (%outputPort_914, %outputPort_916, %outputPort_918 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_919, %inputPort_921 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__TwiddleGenerator__v__N_dyn "twiddles" (%c2_i32 : i32)
        ports_in (%outputPort_912 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_917 : !fifo.input_port<complex<f32>>)
    cal.create_instance @__fanout_complex_f32__2 "fft__Butterfly$spec_1916938481276772234.__fanout_complex_f32__2.6" device_affinity="cpu0" ()
        ports_in (%outputPort_856 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_909, %inputPort_911 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Split__v__N_dyn "split" (%c2_i32 : i32)
        ports_in (%outputPort_910 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_913, %inputPort_915 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    %inputPort_927, %outputPort_928 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4.out0->split.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_929, %outputPort_930 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4.out1->twiddles.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_931, %outputPort_932 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.split.out0->r2cell.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_933, %outputPort_934 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.split.out1->r2cell.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_935, %outputPort_936 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.twiddles.out0->r2cell.in2"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_937, %outputPort_938 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.r2cell.out0->merge.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_939, %outputPort_940 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.r2cell.out1->merge.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    cal.create_instance @fft__Merge "merge" device_affinity="cpu0" ()
        ports_in (%outputPort_938, %outputPort_940 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_923 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__TwiddleGenerator__v__N_dyn "twiddles" (%c1_i32 : i32)
        ports_in (%outputPort_930 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_935 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Split__v__N_dyn "split" (%c1_i32 : i32)
        ports_in (%outputPort_928 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_931, %inputPort_933 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @__fanout_complex_f32__2 "fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4" device_affinity="cpu0" ()
        ports_in (%outputPort_920 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_927, %inputPort_929 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Radix2Cell "r2cell" device_affinity="cpu0" ()
        ports_in (%outputPort_932, %outputPort_934, %outputPort_936 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_937, %inputPort_939 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    %inputPort_941, %outputPort_942 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4.out0->split.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_943, %outputPort_944 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4.out1->twiddles.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_945, %outputPort_946 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.split.out0->r2cell.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_947, %outputPort_948 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.split.out1->r2cell.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_949, %outputPort_950 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.twiddles.out0->r2cell.in2"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_951, %outputPort_952 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.r2cell.out0->merge.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_953, %outputPort_954 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.r2cell.out1->merge.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    cal.create_instance @fft__Merge "merge" device_affinity="cpu0" ()
        ports_in (%outputPort_952, %outputPort_954 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_925 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__TwiddleGenerator__v__N_dyn "twiddles" (%c1_i32 : i32)
        ports_in (%outputPort_944 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_949 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Split__v__N_dyn "split" (%c1_i32 : i32)
        ports_in (%outputPort_942 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_945, %inputPort_947 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @__fanout_complex_f32__2 "fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4" device_affinity="cpu0" ()
        ports_in (%outputPort_922 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_941, %inputPort_943 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Radix2Cell "r2cell" device_affinity="cpu0" ()
        ports_in (%outputPort_946, %outputPort_948, %outputPort_950 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_951, %inputPort_953 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Merge "merge" device_affinity="cpu0" ()
        ports_in (%outputPort_924, %outputPort_926 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_859 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__TwiddleGenerator__v__N_dyn "twiddles" (%c8_i32 : i32)
        ports_in (%outputPort_830 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_835 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Radix2Cell "r2cell" device_affinity="cpu0" ()
        ports_in (%outputPort_832, %outputPort_834, %outputPort_836 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_837, %inputPort_839 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    %inputPort_955, %outputPort_956 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.fft__Butterfly$spec_9935405952460034831.__fanout_complex_f32__2.6.out0->split.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_957, %outputPort_958 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.fft__Butterfly$spec_9935405952460034831.__fanout_complex_f32__2.6.out1->twiddles.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_959, %outputPort_960 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.split.out0->r2cell.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_961, %outputPort_962 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.split.out1->r2cell.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_963, %outputPort_964 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.twiddles.out0->r2cell.in2"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_965, %outputPort_966 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.r2cell.out0->fft__Butterfly$spec_9935405952460034831.fft__Butterfly$spec_1916938481276772234.4.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_967, %outputPort_968 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.r2cell.out1->fft__Butterfly$spec_9935405952460034831.fft__Butterfly$spec_1916938481276772234.5.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_969, %outputPort_970 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.fft__Butterfly$spec_9935405952460034831.fft__Butterfly$spec_1916938481276772234.4.out0->merge.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_971, %outputPort_972 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.fft__Butterfly$spec_9935405952460034831.fft__Butterfly$spec_1916938481276772234.5.out0->merge.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    cal.create_instance @fft__Radix2Cell "r2cell" device_affinity="cpu0" ()
        ports_in (%outputPort_960, %outputPort_962, %outputPort_964 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_965, %inputPort_967 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Split__v__N_dyn "split" (%c4_i32 : i32)
        ports_in (%outputPort_956 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_959, %inputPort_961 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Merge "merge" device_affinity="cpu0" ()
        ports_in (%outputPort_970, %outputPort_972 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_841 : !fifo.input_port<complex<f32>>)
    cal.create_instance @__fanout_complex_f32__2 "fft__Butterfly$spec_9935405952460034831.__fanout_complex_f32__2.6" device_affinity="cpu0" ()
        ports_in (%outputPort_838 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_955, %inputPort_957 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__TwiddleGenerator__v__N_dyn "twiddles" (%c4_i32 : i32)
        ports_in (%outputPort_958 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_963 : !fifo.input_port<complex<f32>>)
    %inputPort_973, %outputPort_974 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_1916938481276772234.__fanout_complex_f32__2.6.out0->split.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_975, %outputPort_976 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_1916938481276772234.__fanout_complex_f32__2.6.out1->twiddles.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_977, %outputPort_978 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.split.out0->r2cell.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_979, %outputPort_980 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.split.out1->r2cell.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_981, %outputPort_982 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.twiddles.out0->r2cell.in2"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_983, %outputPort_984 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.r2cell.out0->fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_15446289516955298258.4.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_985, %outputPort_986 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.r2cell.out1->fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_15446289516955298258.5.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_987, %outputPort_988 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_15446289516955298258.4.out0->merge.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_989, %outputPort_990 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_15446289516955298258.5.out0->merge.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    cal.create_instance @fft__Radix2Cell "r2cell" device_affinity="cpu0" ()
        ports_in (%outputPort_978, %outputPort_980, %outputPort_982 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_983, %inputPort_985 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__TwiddleGenerator__v__N_dyn "twiddles" (%c2_i32 : i32)
        ports_in (%outputPort_976 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_981 : !fifo.input_port<complex<f32>>)
    cal.create_instance @__fanout_complex_f32__2 "fft__Butterfly$spec_1916938481276772234.__fanout_complex_f32__2.6" device_affinity="cpu0" ()
        ports_in (%outputPort_968 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_973, %inputPort_975 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Split__v__N_dyn "split" (%c2_i32 : i32)
        ports_in (%outputPort_974 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_977, %inputPort_979 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    %inputPort_991, %outputPort_992 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4.out0->split.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_993, %outputPort_994 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4.out1->twiddles.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_995, %outputPort_996 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.split.out0->r2cell.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_997, %outputPort_998 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.split.out1->r2cell.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_999, %outputPort_1000 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.twiddles.out0->r2cell.in2"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1001, %outputPort_1002 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.r2cell.out0->merge.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1003, %outputPort_1004 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.r2cell.out1->merge.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    cal.create_instance @fft__Merge "merge" device_affinity="cpu0" ()
        ports_in (%outputPort_1002, %outputPort_1004 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_987 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__TwiddleGenerator__v__N_dyn "twiddles" (%c1_i32 : i32)
        ports_in (%outputPort_994 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_999 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Split__v__N_dyn "split" (%c1_i32 : i32)
        ports_in (%outputPort_992 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_995, %inputPort_997 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @__fanout_complex_f32__2 "fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4" device_affinity="cpu0" ()
        ports_in (%outputPort_984 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_991, %inputPort_993 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Radix2Cell "r2cell" device_affinity="cpu0" ()
        ports_in (%outputPort_996, %outputPort_998, %outputPort_1000 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1001, %inputPort_1003 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    %inputPort_1005, %outputPort_1006 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4.out0->split.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1007, %outputPort_1008 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4.out1->twiddles.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1009, %outputPort_1010 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.split.out0->r2cell.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1011, %outputPort_1012 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.split.out1->r2cell.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1013, %outputPort_1014 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.twiddles.out0->r2cell.in2"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1015, %outputPort_1016 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.r2cell.out0->merge.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1017, %outputPort_1018 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.r2cell.out1->merge.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    cal.create_instance @fft__Merge "merge" device_affinity="cpu0" ()
        ports_in (%outputPort_1016, %outputPort_1018 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_989 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__TwiddleGenerator__v__N_dyn "twiddles" (%c1_i32 : i32)
        ports_in (%outputPort_1008 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1013 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Split__v__N_dyn "split" (%c1_i32 : i32)
        ports_in (%outputPort_1006 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1009, %inputPort_1011 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @__fanout_complex_f32__2 "fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4" device_affinity="cpu0" ()
        ports_in (%outputPort_986 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1005, %inputPort_1007 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Radix2Cell "r2cell" device_affinity="cpu0" ()
        ports_in (%outputPort_1010, %outputPort_1012, %outputPort_1014 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1015, %inputPort_1017 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Merge "merge" device_affinity="cpu0" ()
        ports_in (%outputPort_988, %outputPort_990 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_971 : !fifo.input_port<complex<f32>>)
    %inputPort_1019, %outputPort_1020 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_1916938481276772234.__fanout_complex_f32__2.6.out0->split.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1021, %outputPort_1022 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_1916938481276772234.__fanout_complex_f32__2.6.out1->twiddles.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1023, %outputPort_1024 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.split.out0->r2cell.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1025, %outputPort_1026 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.split.out1->r2cell.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1027, %outputPort_1028 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.twiddles.out0->r2cell.in2"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1029, %outputPort_1030 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.r2cell.out0->fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_15446289516955298258.4.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1031, %outputPort_1032 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.r2cell.out1->fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_15446289516955298258.5.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1033, %outputPort_1034 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_15446289516955298258.4.out0->merge.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1035, %outputPort_1036 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_15446289516955298258.5.out0->merge.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    cal.create_instance @fft__Radix2Cell "r2cell" device_affinity="cpu0" ()
        ports_in (%outputPort_1024, %outputPort_1026, %outputPort_1028 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1029, %inputPort_1031 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__TwiddleGenerator__v__N_dyn "twiddles" (%c2_i32 : i32)
        ports_in (%outputPort_1022 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1027 : !fifo.input_port<complex<f32>>)
    cal.create_instance @__fanout_complex_f32__2 "fft__Butterfly$spec_1916938481276772234.__fanout_complex_f32__2.6" device_affinity="cpu0" ()
        ports_in (%outputPort_966 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1019, %inputPort_1021 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Split__v__N_dyn "split" (%c2_i32 : i32)
        ports_in (%outputPort_1020 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1023, %inputPort_1025 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    %inputPort_1037, %outputPort_1038 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4.out0->split.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1039, %outputPort_1040 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4.out1->twiddles.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1041, %outputPort_1042 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.split.out0->r2cell.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1043, %outputPort_1044 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.split.out1->r2cell.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1045, %outputPort_1046 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.twiddles.out0->r2cell.in2"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1047, %outputPort_1048 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.r2cell.out0->merge.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1049, %outputPort_1050 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.r2cell.out1->merge.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    cal.create_instance @fft__Merge "merge" device_affinity="cpu0" ()
        ports_in (%outputPort_1048, %outputPort_1050 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1033 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__TwiddleGenerator__v__N_dyn "twiddles" (%c1_i32 : i32)
        ports_in (%outputPort_1040 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1045 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Split__v__N_dyn "split" (%c1_i32 : i32)
        ports_in (%outputPort_1038 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1041, %inputPort_1043 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @__fanout_complex_f32__2 "fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4" device_affinity="cpu0" ()
        ports_in (%outputPort_1030 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1037, %inputPort_1039 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Radix2Cell "r2cell" device_affinity="cpu0" ()
        ports_in (%outputPort_1042, %outputPort_1044, %outputPort_1046 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1047, %inputPort_1049 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    %inputPort_1051, %outputPort_1052 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4.out0->split.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1053, %outputPort_1054 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4.out1->twiddles.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1055, %outputPort_1056 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.split.out0->r2cell.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1057, %outputPort_1058 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.split.out1->r2cell.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1059, %outputPort_1060 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.twiddles.out0->r2cell.in2"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1061, %outputPort_1062 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.r2cell.out0->merge.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1063, %outputPort_1064 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.r2cell.out1->merge.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    cal.create_instance @fft__Merge "merge" device_affinity="cpu0" ()
        ports_in (%outputPort_1062, %outputPort_1064 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1035 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__TwiddleGenerator__v__N_dyn "twiddles" (%c1_i32 : i32)
        ports_in (%outputPort_1054 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1059 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Split__v__N_dyn "split" (%c1_i32 : i32)
        ports_in (%outputPort_1052 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1055, %inputPort_1057 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @__fanout_complex_f32__2 "fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4" device_affinity="cpu0" ()
        ports_in (%outputPort_1032 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1051, %inputPort_1053 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Radix2Cell "r2cell" device_affinity="cpu0" ()
        ports_in (%outputPort_1056, %outputPort_1058, %outputPort_1060 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1061, %inputPort_1063 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Merge "merge" device_affinity="cpu0" ()
        ports_in (%outputPort_1034, %outputPort_1036 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_969 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Split__v__N_dyn "split" (%c8_i32 : i32)
        ports_in (%outputPort_828 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_831, %inputPort_833 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Split__v__N_dyn "split" (%c16_i32 : i32)
        ports_in (%outputPort_572 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_575, %inputPort_577 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Radix2Cell "r2cell" device_affinity="cpu0" ()
        ports_in (%outputPort_46, %outputPort_48, %outputPort_50 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_51, %inputPort_53 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__TwiddleGenerator__v__N_dyn "twiddles" (%c64_i32 : i32)
        ports_in (%outputPort_44 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_49 : !fifo.input_port<complex<f32>>)
    %inputPort_1065, %outputPort_1066 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_17640631431051100303.fft__Butterfly$spec_17640631431051100303.__fanout_complex_f32__2.6.out0->split.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1067, %outputPort_1068 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_17640631431051100303.fft__Butterfly$spec_17640631431051100303.__fanout_complex_f32__2.6.out1->twiddles.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1069, %outputPort_1070 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_17640631431051100303.split.out0->r2cell.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1071, %outputPort_1072 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_17640631431051100303.split.out1->r2cell.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1073, %outputPort_1074 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_17640631431051100303.twiddles.out0->r2cell.in2"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1075, %outputPort_1076 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_17640631431051100303.r2cell.out0->fft__Butterfly$spec_17640631431051100303.fft__Butterfly$spec_3035977640463470463.4.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1077, %outputPort_1078 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_17640631431051100303.r2cell.out1->fft__Butterfly$spec_17640631431051100303.fft__Butterfly$spec_3035977640463470463.5.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1079, %outputPort_1080 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_17640631431051100303.fft__Butterfly$spec_17640631431051100303.fft__Butterfly$spec_3035977640463470463.4.out0->merge.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1081, %outputPort_1082 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_17640631431051100303.fft__Butterfly$spec_17640631431051100303.fft__Butterfly$spec_3035977640463470463.5.out0->merge.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    cal.create_instance @fft__Merge "merge" device_affinity="cpu0" ()
        ports_in (%outputPort_1080, %outputPort_1082 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_57 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Split__v__N_dyn "split" (%c32_i32 : i32)
        ports_in (%outputPort_1066 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1069, %inputPort_1071 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    %inputPort_1083, %outputPort_1084 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_3035977640463470463.fft__Butterfly$spec_3035977640463470463.__fanout_complex_f32__2.6.out0->split.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1085, %outputPort_1086 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_3035977640463470463.fft__Butterfly$spec_3035977640463470463.__fanout_complex_f32__2.6.out1->twiddles.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1087, %outputPort_1088 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_3035977640463470463.split.out0->r2cell.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1089, %outputPort_1090 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_3035977640463470463.split.out1->r2cell.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1091, %outputPort_1092 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_3035977640463470463.twiddles.out0->r2cell.in2"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1093, %outputPort_1094 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_3035977640463470463.r2cell.out0->fft__Butterfly$spec_3035977640463470463.fft__Butterfly$spec_16755419077516047831.4.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1095, %outputPort_1096 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_3035977640463470463.r2cell.out1->fft__Butterfly$spec_3035977640463470463.fft__Butterfly$spec_16755419077516047831.5.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1097, %outputPort_1098 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_3035977640463470463.fft__Butterfly$spec_3035977640463470463.fft__Butterfly$spec_16755419077516047831.4.out0->merge.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1099, %outputPort_1100 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_3035977640463470463.fft__Butterfly$spec_3035977640463470463.fft__Butterfly$spec_16755419077516047831.5.out0->merge.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    cal.create_instance @fft__TwiddleGenerator__v__N_dyn "twiddles" (%c16_i32 : i32)
        ports_in (%outputPort_1086 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1091 : !fifo.input_port<complex<f32>>)
    %inputPort_1101, %outputPort_1102 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_16755419077516047831.fft__Butterfly$spec_16755419077516047831.__fanout_complex_f32__2.6.out0->split.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1103, %outputPort_1104 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_16755419077516047831.fft__Butterfly$spec_16755419077516047831.__fanout_complex_f32__2.6.out1->twiddles.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1105, %outputPort_1106 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_16755419077516047831.split.out0->r2cell.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1107, %outputPort_1108 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_16755419077516047831.split.out1->r2cell.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1109, %outputPort_1110 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_16755419077516047831.twiddles.out0->r2cell.in2"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1111, %outputPort_1112 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_16755419077516047831.r2cell.out0->fft__Butterfly$spec_16755419077516047831.fft__Butterfly$spec_9935405952460034831.4.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1113, %outputPort_1114 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_16755419077516047831.r2cell.out1->fft__Butterfly$spec_16755419077516047831.fft__Butterfly$spec_9935405952460034831.5.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1115, %outputPort_1116 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_16755419077516047831.fft__Butterfly$spec_16755419077516047831.fft__Butterfly$spec_9935405952460034831.4.out0->merge.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1117, %outputPort_1118 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_16755419077516047831.fft__Butterfly$spec_16755419077516047831.fft__Butterfly$spec_9935405952460034831.5.out0->merge.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    cal.create_instance @__fanout_complex_f32__2 "fft__Butterfly$spec_16755419077516047831.__fanout_complex_f32__2.6" device_affinity="cpu0" ()
        ports_in (%outputPort_1096 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1101, %inputPort_1103 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Merge "merge" device_affinity="cpu0" ()
        ports_in (%outputPort_1116, %outputPort_1118 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1099 : !fifo.input_port<complex<f32>>)
    %inputPort_1119, %outputPort_1120 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.fft__Butterfly$spec_9935405952460034831.__fanout_complex_f32__2.6.out0->split.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1121, %outputPort_1122 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.fft__Butterfly$spec_9935405952460034831.__fanout_complex_f32__2.6.out1->twiddles.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1123, %outputPort_1124 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.split.out0->r2cell.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1125, %outputPort_1126 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.split.out1->r2cell.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1127, %outputPort_1128 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.twiddles.out0->r2cell.in2"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1129, %outputPort_1130 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.r2cell.out0->fft__Butterfly$spec_9935405952460034831.fft__Butterfly$spec_1916938481276772234.4.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1131, %outputPort_1132 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.r2cell.out1->fft__Butterfly$spec_9935405952460034831.fft__Butterfly$spec_1916938481276772234.5.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1133, %outputPort_1134 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.fft__Butterfly$spec_9935405952460034831.fft__Butterfly$spec_1916938481276772234.4.out0->merge.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1135, %outputPort_1136 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.fft__Butterfly$spec_9935405952460034831.fft__Butterfly$spec_1916938481276772234.5.out0->merge.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    cal.create_instance @fft__Radix2Cell "r2cell" device_affinity="cpu0" ()
        ports_in (%outputPort_1124, %outputPort_1126, %outputPort_1128 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1129, %inputPort_1131 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Split__v__N_dyn "split" (%c4_i32 : i32)
        ports_in (%outputPort_1120 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1123, %inputPort_1125 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Merge "merge" device_affinity="cpu0" ()
        ports_in (%outputPort_1134, %outputPort_1136 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1117 : !fifo.input_port<complex<f32>>)
    cal.create_instance @__fanout_complex_f32__2 "fft__Butterfly$spec_9935405952460034831.__fanout_complex_f32__2.6" device_affinity="cpu0" ()
        ports_in (%outputPort_1114 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1119, %inputPort_1121 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__TwiddleGenerator__v__N_dyn "twiddles" (%c4_i32 : i32)
        ports_in (%outputPort_1122 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1127 : !fifo.input_port<complex<f32>>)
    %inputPort_1137, %outputPort_1138 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_1916938481276772234.__fanout_complex_f32__2.6.out0->split.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1139, %outputPort_1140 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_1916938481276772234.__fanout_complex_f32__2.6.out1->twiddles.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1141, %outputPort_1142 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.split.out0->r2cell.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1143, %outputPort_1144 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.split.out1->r2cell.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1145, %outputPort_1146 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.twiddles.out0->r2cell.in2"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1147, %outputPort_1148 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.r2cell.out0->fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_15446289516955298258.4.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1149, %outputPort_1150 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.r2cell.out1->fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_15446289516955298258.5.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1151, %outputPort_1152 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_15446289516955298258.4.out0->merge.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1153, %outputPort_1154 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_15446289516955298258.5.out0->merge.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    cal.create_instance @fft__Radix2Cell "r2cell" device_affinity="cpu0" ()
        ports_in (%outputPort_1142, %outputPort_1144, %outputPort_1146 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1147, %inputPort_1149 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__TwiddleGenerator__v__N_dyn "twiddles" (%c2_i32 : i32)
        ports_in (%outputPort_1140 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1145 : !fifo.input_port<complex<f32>>)
    cal.create_instance @__fanout_complex_f32__2 "fft__Butterfly$spec_1916938481276772234.__fanout_complex_f32__2.6" device_affinity="cpu0" ()
        ports_in (%outputPort_1132 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1137, %inputPort_1139 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Split__v__N_dyn "split" (%c2_i32 : i32)
        ports_in (%outputPort_1138 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1141, %inputPort_1143 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    %inputPort_1155, %outputPort_1156 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4.out0->split.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1157, %outputPort_1158 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4.out1->twiddles.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1159, %outputPort_1160 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.split.out0->r2cell.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1161, %outputPort_1162 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.split.out1->r2cell.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1163, %outputPort_1164 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.twiddles.out0->r2cell.in2"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1165, %outputPort_1166 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.r2cell.out0->merge.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1167, %outputPort_1168 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.r2cell.out1->merge.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    cal.create_instance @fft__Merge "merge" device_affinity="cpu0" ()
        ports_in (%outputPort_1166, %outputPort_1168 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1151 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__TwiddleGenerator__v__N_dyn "twiddles" (%c1_i32 : i32)
        ports_in (%outputPort_1158 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1163 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Split__v__N_dyn "split" (%c1_i32 : i32)
        ports_in (%outputPort_1156 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1159, %inputPort_1161 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @__fanout_complex_f32__2 "fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4" device_affinity="cpu0" ()
        ports_in (%outputPort_1148 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1155, %inputPort_1157 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Radix2Cell "r2cell" device_affinity="cpu0" ()
        ports_in (%outputPort_1160, %outputPort_1162, %outputPort_1164 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1165, %inputPort_1167 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    %inputPort_1169, %outputPort_1170 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4.out0->split.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1171, %outputPort_1172 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4.out1->twiddles.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1173, %outputPort_1174 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.split.out0->r2cell.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1175, %outputPort_1176 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.split.out1->r2cell.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1177, %outputPort_1178 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.twiddles.out0->r2cell.in2"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1179, %outputPort_1180 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.r2cell.out0->merge.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1181, %outputPort_1182 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.r2cell.out1->merge.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    cal.create_instance @fft__Merge "merge" device_affinity="cpu0" ()
        ports_in (%outputPort_1180, %outputPort_1182 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1153 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__TwiddleGenerator__v__N_dyn "twiddles" (%c1_i32 : i32)
        ports_in (%outputPort_1172 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1177 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Split__v__N_dyn "split" (%c1_i32 : i32)
        ports_in (%outputPort_1170 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1173, %inputPort_1175 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @__fanout_complex_f32__2 "fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4" device_affinity="cpu0" ()
        ports_in (%outputPort_1150 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1169, %inputPort_1171 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Radix2Cell "r2cell" device_affinity="cpu0" ()
        ports_in (%outputPort_1174, %outputPort_1176, %outputPort_1178 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1179, %inputPort_1181 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Merge "merge" device_affinity="cpu0" ()
        ports_in (%outputPort_1152, %outputPort_1154 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1135 : !fifo.input_port<complex<f32>>)
    %inputPort_1183, %outputPort_1184 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_1916938481276772234.__fanout_complex_f32__2.6.out0->split.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1185, %outputPort_1186 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_1916938481276772234.__fanout_complex_f32__2.6.out1->twiddles.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1187, %outputPort_1188 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.split.out0->r2cell.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1189, %outputPort_1190 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.split.out1->r2cell.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1191, %outputPort_1192 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.twiddles.out0->r2cell.in2"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1193, %outputPort_1194 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.r2cell.out0->fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_15446289516955298258.4.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1195, %outputPort_1196 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.r2cell.out1->fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_15446289516955298258.5.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1197, %outputPort_1198 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_15446289516955298258.4.out0->merge.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1199, %outputPort_1200 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_15446289516955298258.5.out0->merge.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    cal.create_instance @fft__Radix2Cell "r2cell" device_affinity="cpu0" ()
        ports_in (%outputPort_1188, %outputPort_1190, %outputPort_1192 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1193, %inputPort_1195 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__TwiddleGenerator__v__N_dyn "twiddles" (%c2_i32 : i32)
        ports_in (%outputPort_1186 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1191 : !fifo.input_port<complex<f32>>)
    cal.create_instance @__fanout_complex_f32__2 "fft__Butterfly$spec_1916938481276772234.__fanout_complex_f32__2.6" device_affinity="cpu0" ()
        ports_in (%outputPort_1130 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1183, %inputPort_1185 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Split__v__N_dyn "split" (%c2_i32 : i32)
        ports_in (%outputPort_1184 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1187, %inputPort_1189 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    %inputPort_1201, %outputPort_1202 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4.out0->split.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1203, %outputPort_1204 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4.out1->twiddles.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1205, %outputPort_1206 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.split.out0->r2cell.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1207, %outputPort_1208 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.split.out1->r2cell.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1209, %outputPort_1210 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.twiddles.out0->r2cell.in2"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1211, %outputPort_1212 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.r2cell.out0->merge.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1213, %outputPort_1214 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.r2cell.out1->merge.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    cal.create_instance @fft__Merge "merge" device_affinity="cpu0" ()
        ports_in (%outputPort_1212, %outputPort_1214 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1197 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__TwiddleGenerator__v__N_dyn "twiddles" (%c1_i32 : i32)
        ports_in (%outputPort_1204 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1209 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Split__v__N_dyn "split" (%c1_i32 : i32)
        ports_in (%outputPort_1202 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1205, %inputPort_1207 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @__fanout_complex_f32__2 "fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4" device_affinity="cpu0" ()
        ports_in (%outputPort_1194 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1201, %inputPort_1203 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Radix2Cell "r2cell" device_affinity="cpu0" ()
        ports_in (%outputPort_1206, %outputPort_1208, %outputPort_1210 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1211, %inputPort_1213 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    %inputPort_1215, %outputPort_1216 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4.out0->split.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1217, %outputPort_1218 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4.out1->twiddles.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1219, %outputPort_1220 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.split.out0->r2cell.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1221, %outputPort_1222 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.split.out1->r2cell.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1223, %outputPort_1224 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.twiddles.out0->r2cell.in2"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1225, %outputPort_1226 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.r2cell.out0->merge.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1227, %outputPort_1228 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.r2cell.out1->merge.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    cal.create_instance @fft__Merge "merge" device_affinity="cpu0" ()
        ports_in (%outputPort_1226, %outputPort_1228 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1199 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__TwiddleGenerator__v__N_dyn "twiddles" (%c1_i32 : i32)
        ports_in (%outputPort_1218 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1223 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Split__v__N_dyn "split" (%c1_i32 : i32)
        ports_in (%outputPort_1216 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1219, %inputPort_1221 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @__fanout_complex_f32__2 "fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4" device_affinity="cpu0" ()
        ports_in (%outputPort_1196 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1215, %inputPort_1217 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Radix2Cell "r2cell" device_affinity="cpu0" ()
        ports_in (%outputPort_1220, %outputPort_1222, %outputPort_1224 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1225, %inputPort_1227 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Merge "merge" device_affinity="cpu0" ()
        ports_in (%outputPort_1198, %outputPort_1200 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1133 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__TwiddleGenerator__v__N_dyn "twiddles" (%c8_i32 : i32)
        ports_in (%outputPort_1104 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1109 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Radix2Cell "r2cell" device_affinity="cpu0" ()
        ports_in (%outputPort_1106, %outputPort_1108, %outputPort_1110 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1111, %inputPort_1113 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    %inputPort_1229, %outputPort_1230 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.fft__Butterfly$spec_9935405952460034831.__fanout_complex_f32__2.6.out0->split.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1231, %outputPort_1232 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.fft__Butterfly$spec_9935405952460034831.__fanout_complex_f32__2.6.out1->twiddles.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1233, %outputPort_1234 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.split.out0->r2cell.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1235, %outputPort_1236 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.split.out1->r2cell.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1237, %outputPort_1238 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.twiddles.out0->r2cell.in2"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1239, %outputPort_1240 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.r2cell.out0->fft__Butterfly$spec_9935405952460034831.fft__Butterfly$spec_1916938481276772234.4.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1241, %outputPort_1242 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.r2cell.out1->fft__Butterfly$spec_9935405952460034831.fft__Butterfly$spec_1916938481276772234.5.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1243, %outputPort_1244 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.fft__Butterfly$spec_9935405952460034831.fft__Butterfly$spec_1916938481276772234.4.out0->merge.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1245, %outputPort_1246 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.fft__Butterfly$spec_9935405952460034831.fft__Butterfly$spec_1916938481276772234.5.out0->merge.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    cal.create_instance @fft__Radix2Cell "r2cell" device_affinity="cpu0" ()
        ports_in (%outputPort_1234, %outputPort_1236, %outputPort_1238 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1239, %inputPort_1241 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Split__v__N_dyn "split" (%c4_i32 : i32)
        ports_in (%outputPort_1230 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1233, %inputPort_1235 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Merge "merge" device_affinity="cpu0" ()
        ports_in (%outputPort_1244, %outputPort_1246 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1115 : !fifo.input_port<complex<f32>>)
    cal.create_instance @__fanout_complex_f32__2 "fft__Butterfly$spec_9935405952460034831.__fanout_complex_f32__2.6" device_affinity="cpu0" ()
        ports_in (%outputPort_1112 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1229, %inputPort_1231 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__TwiddleGenerator__v__N_dyn "twiddles" (%c4_i32 : i32)
        ports_in (%outputPort_1232 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1237 : !fifo.input_port<complex<f32>>)
    %inputPort_1247, %outputPort_1248 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_1916938481276772234.__fanout_complex_f32__2.6.out0->split.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1249, %outputPort_1250 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_1916938481276772234.__fanout_complex_f32__2.6.out1->twiddles.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1251, %outputPort_1252 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.split.out0->r2cell.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1253, %outputPort_1254 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.split.out1->r2cell.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1255, %outputPort_1256 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.twiddles.out0->r2cell.in2"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1257, %outputPort_1258 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.r2cell.out0->fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_15446289516955298258.4.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1259, %outputPort_1260 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.r2cell.out1->fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_15446289516955298258.5.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1261, %outputPort_1262 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_15446289516955298258.4.out0->merge.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1263, %outputPort_1264 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_15446289516955298258.5.out0->merge.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    cal.create_instance @fft__Radix2Cell "r2cell" device_affinity="cpu0" ()
        ports_in (%outputPort_1252, %outputPort_1254, %outputPort_1256 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1257, %inputPort_1259 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__TwiddleGenerator__v__N_dyn "twiddles" (%c2_i32 : i32)
        ports_in (%outputPort_1250 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1255 : !fifo.input_port<complex<f32>>)
    cal.create_instance @__fanout_complex_f32__2 "fft__Butterfly$spec_1916938481276772234.__fanout_complex_f32__2.6" device_affinity="cpu0" ()
        ports_in (%outputPort_1242 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1247, %inputPort_1249 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Split__v__N_dyn "split" (%c2_i32 : i32)
        ports_in (%outputPort_1248 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1251, %inputPort_1253 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    %inputPort_1265, %outputPort_1266 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4.out0->split.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1267, %outputPort_1268 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4.out1->twiddles.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1269, %outputPort_1270 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.split.out0->r2cell.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1271, %outputPort_1272 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.split.out1->r2cell.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1273, %outputPort_1274 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.twiddles.out0->r2cell.in2"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1275, %outputPort_1276 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.r2cell.out0->merge.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1277, %outputPort_1278 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.r2cell.out1->merge.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    cal.create_instance @fft__Merge "merge" device_affinity="cpu0" ()
        ports_in (%outputPort_1276, %outputPort_1278 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1261 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__TwiddleGenerator__v__N_dyn "twiddles" (%c1_i32 : i32)
        ports_in (%outputPort_1268 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1273 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Split__v__N_dyn "split" (%c1_i32 : i32)
        ports_in (%outputPort_1266 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1269, %inputPort_1271 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @__fanout_complex_f32__2 "fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4" device_affinity="cpu0" ()
        ports_in (%outputPort_1258 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1265, %inputPort_1267 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Radix2Cell "r2cell" device_affinity="cpu0" ()
        ports_in (%outputPort_1270, %outputPort_1272, %outputPort_1274 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1275, %inputPort_1277 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    %inputPort_1279, %outputPort_1280 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4.out0->split.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1281, %outputPort_1282 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4.out1->twiddles.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1283, %outputPort_1284 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.split.out0->r2cell.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1285, %outputPort_1286 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.split.out1->r2cell.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1287, %outputPort_1288 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.twiddles.out0->r2cell.in2"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1289, %outputPort_1290 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.r2cell.out0->merge.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1291, %outputPort_1292 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.r2cell.out1->merge.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    cal.create_instance @fft__Merge "merge" device_affinity="cpu0" ()
        ports_in (%outputPort_1290, %outputPort_1292 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1263 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__TwiddleGenerator__v__N_dyn "twiddles" (%c1_i32 : i32)
        ports_in (%outputPort_1282 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1287 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Split__v__N_dyn "split" (%c1_i32 : i32)
        ports_in (%outputPort_1280 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1283, %inputPort_1285 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @__fanout_complex_f32__2 "fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4" device_affinity="cpu0" ()
        ports_in (%outputPort_1260 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1279, %inputPort_1281 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Radix2Cell "r2cell" device_affinity="cpu0" ()
        ports_in (%outputPort_1284, %outputPort_1286, %outputPort_1288 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1289, %inputPort_1291 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Merge "merge" device_affinity="cpu0" ()
        ports_in (%outputPort_1262, %outputPort_1264 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1245 : !fifo.input_port<complex<f32>>)
    %inputPort_1293, %outputPort_1294 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_1916938481276772234.__fanout_complex_f32__2.6.out0->split.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1295, %outputPort_1296 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_1916938481276772234.__fanout_complex_f32__2.6.out1->twiddles.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1297, %outputPort_1298 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.split.out0->r2cell.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1299, %outputPort_1300 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.split.out1->r2cell.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1301, %outputPort_1302 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.twiddles.out0->r2cell.in2"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1303, %outputPort_1304 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.r2cell.out0->fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_15446289516955298258.4.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1305, %outputPort_1306 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.r2cell.out1->fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_15446289516955298258.5.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1307, %outputPort_1308 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_15446289516955298258.4.out0->merge.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1309, %outputPort_1310 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_15446289516955298258.5.out0->merge.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    cal.create_instance @fft__Radix2Cell "r2cell" device_affinity="cpu0" ()
        ports_in (%outputPort_1298, %outputPort_1300, %outputPort_1302 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1303, %inputPort_1305 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__TwiddleGenerator__v__N_dyn "twiddles" (%c2_i32 : i32)
        ports_in (%outputPort_1296 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1301 : !fifo.input_port<complex<f32>>)
    cal.create_instance @__fanout_complex_f32__2 "fft__Butterfly$spec_1916938481276772234.__fanout_complex_f32__2.6" device_affinity="cpu0" ()
        ports_in (%outputPort_1240 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1293, %inputPort_1295 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Split__v__N_dyn "split" (%c2_i32 : i32)
        ports_in (%outputPort_1294 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1297, %inputPort_1299 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    %inputPort_1311, %outputPort_1312 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4.out0->split.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1313, %outputPort_1314 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4.out1->twiddles.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1315, %outputPort_1316 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.split.out0->r2cell.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1317, %outputPort_1318 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.split.out1->r2cell.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1319, %outputPort_1320 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.twiddles.out0->r2cell.in2"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1321, %outputPort_1322 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.r2cell.out0->merge.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1323, %outputPort_1324 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.r2cell.out1->merge.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    cal.create_instance @fft__Merge "merge" device_affinity="cpu0" ()
        ports_in (%outputPort_1322, %outputPort_1324 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1307 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__TwiddleGenerator__v__N_dyn "twiddles" (%c1_i32 : i32)
        ports_in (%outputPort_1314 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1319 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Split__v__N_dyn "split" (%c1_i32 : i32)
        ports_in (%outputPort_1312 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1315, %inputPort_1317 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @__fanout_complex_f32__2 "fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4" device_affinity="cpu0" ()
        ports_in (%outputPort_1304 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1311, %inputPort_1313 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Radix2Cell "r2cell" device_affinity="cpu0" ()
        ports_in (%outputPort_1316, %outputPort_1318, %outputPort_1320 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1321, %inputPort_1323 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    %inputPort_1325, %outputPort_1326 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4.out0->split.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1327, %outputPort_1328 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4.out1->twiddles.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1329, %outputPort_1330 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.split.out0->r2cell.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1331, %outputPort_1332 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.split.out1->r2cell.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1333, %outputPort_1334 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.twiddles.out0->r2cell.in2"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1335, %outputPort_1336 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.r2cell.out0->merge.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1337, %outputPort_1338 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.r2cell.out1->merge.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    cal.create_instance @fft__Merge "merge" device_affinity="cpu0" ()
        ports_in (%outputPort_1336, %outputPort_1338 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1309 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__TwiddleGenerator__v__N_dyn "twiddles" (%c1_i32 : i32)
        ports_in (%outputPort_1328 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1333 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Split__v__N_dyn "split" (%c1_i32 : i32)
        ports_in (%outputPort_1326 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1329, %inputPort_1331 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @__fanout_complex_f32__2 "fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4" device_affinity="cpu0" ()
        ports_in (%outputPort_1306 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1325, %inputPort_1327 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Radix2Cell "r2cell" device_affinity="cpu0" ()
        ports_in (%outputPort_1330, %outputPort_1332, %outputPort_1334 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1335, %inputPort_1337 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Merge "merge" device_affinity="cpu0" ()
        ports_in (%outputPort_1308, %outputPort_1310 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1243 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Split__v__N_dyn "split" (%c8_i32 : i32)
        ports_in (%outputPort_1102 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1105, %inputPort_1107 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Radix2Cell "r2cell" device_affinity="cpu0" ()
        ports_in (%outputPort_1088, %outputPort_1090, %outputPort_1092 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1093, %inputPort_1095 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Merge "merge" device_affinity="cpu0" ()
        ports_in (%outputPort_1098, %outputPort_1100 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1079 : !fifo.input_port<complex<f32>>)
    cal.create_instance @__fanout_complex_f32__2 "fft__Butterfly$spec_3035977640463470463.__fanout_complex_f32__2.6" device_affinity="cpu0" ()
        ports_in (%outputPort_1076 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1083, %inputPort_1085 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    %inputPort_1339, %outputPort_1340 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_16755419077516047831.fft__Butterfly$spec_16755419077516047831.__fanout_complex_f32__2.6.out0->split.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1341, %outputPort_1342 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_16755419077516047831.fft__Butterfly$spec_16755419077516047831.__fanout_complex_f32__2.6.out1->twiddles.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1343, %outputPort_1344 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_16755419077516047831.split.out0->r2cell.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1345, %outputPort_1346 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_16755419077516047831.split.out1->r2cell.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1347, %outputPort_1348 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_16755419077516047831.twiddles.out0->r2cell.in2"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1349, %outputPort_1350 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_16755419077516047831.r2cell.out0->fft__Butterfly$spec_16755419077516047831.fft__Butterfly$spec_9935405952460034831.4.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1351, %outputPort_1352 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_16755419077516047831.r2cell.out1->fft__Butterfly$spec_16755419077516047831.fft__Butterfly$spec_9935405952460034831.5.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1353, %outputPort_1354 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_16755419077516047831.fft__Butterfly$spec_16755419077516047831.fft__Butterfly$spec_9935405952460034831.4.out0->merge.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1355, %outputPort_1356 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_16755419077516047831.fft__Butterfly$spec_16755419077516047831.fft__Butterfly$spec_9935405952460034831.5.out0->merge.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    cal.create_instance @__fanout_complex_f32__2 "fft__Butterfly$spec_16755419077516047831.__fanout_complex_f32__2.6" device_affinity="cpu0" ()
        ports_in (%outputPort_1094 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1339, %inputPort_1341 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Merge "merge" device_affinity="cpu0" ()
        ports_in (%outputPort_1354, %outputPort_1356 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1097 : !fifo.input_port<complex<f32>>)
    %inputPort_1357, %outputPort_1358 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.fft__Butterfly$spec_9935405952460034831.__fanout_complex_f32__2.6.out0->split.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1359, %outputPort_1360 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.fft__Butterfly$spec_9935405952460034831.__fanout_complex_f32__2.6.out1->twiddles.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1361, %outputPort_1362 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.split.out0->r2cell.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1363, %outputPort_1364 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.split.out1->r2cell.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1365, %outputPort_1366 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.twiddles.out0->r2cell.in2"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1367, %outputPort_1368 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.r2cell.out0->fft__Butterfly$spec_9935405952460034831.fft__Butterfly$spec_1916938481276772234.4.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1369, %outputPort_1370 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.r2cell.out1->fft__Butterfly$spec_9935405952460034831.fft__Butterfly$spec_1916938481276772234.5.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1371, %outputPort_1372 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.fft__Butterfly$spec_9935405952460034831.fft__Butterfly$spec_1916938481276772234.4.out0->merge.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1373, %outputPort_1374 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.fft__Butterfly$spec_9935405952460034831.fft__Butterfly$spec_1916938481276772234.5.out0->merge.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    cal.create_instance @fft__Radix2Cell "r2cell" device_affinity="cpu0" ()
        ports_in (%outputPort_1362, %outputPort_1364, %outputPort_1366 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1367, %inputPort_1369 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Split__v__N_dyn "split" (%c4_i32 : i32)
        ports_in (%outputPort_1358 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1361, %inputPort_1363 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Merge "merge" device_affinity="cpu0" ()
        ports_in (%outputPort_1372, %outputPort_1374 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1355 : !fifo.input_port<complex<f32>>)
    cal.create_instance @__fanout_complex_f32__2 "fft__Butterfly$spec_9935405952460034831.__fanout_complex_f32__2.6" device_affinity="cpu0" ()
        ports_in (%outputPort_1352 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1357, %inputPort_1359 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__TwiddleGenerator__v__N_dyn "twiddles" (%c4_i32 : i32)
        ports_in (%outputPort_1360 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1365 : !fifo.input_port<complex<f32>>)
    %inputPort_1375, %outputPort_1376 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_1916938481276772234.__fanout_complex_f32__2.6.out0->split.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1377, %outputPort_1378 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_1916938481276772234.__fanout_complex_f32__2.6.out1->twiddles.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1379, %outputPort_1380 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.split.out0->r2cell.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1381, %outputPort_1382 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.split.out1->r2cell.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1383, %outputPort_1384 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.twiddles.out0->r2cell.in2"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1385, %outputPort_1386 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.r2cell.out0->fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_15446289516955298258.4.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1387, %outputPort_1388 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.r2cell.out1->fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_15446289516955298258.5.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1389, %outputPort_1390 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_15446289516955298258.4.out0->merge.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1391, %outputPort_1392 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_15446289516955298258.5.out0->merge.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    cal.create_instance @fft__Radix2Cell "r2cell" device_affinity="cpu0" ()
        ports_in (%outputPort_1380, %outputPort_1382, %outputPort_1384 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1385, %inputPort_1387 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__TwiddleGenerator__v__N_dyn "twiddles" (%c2_i32 : i32)
        ports_in (%outputPort_1378 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1383 : !fifo.input_port<complex<f32>>)
    cal.create_instance @__fanout_complex_f32__2 "fft__Butterfly$spec_1916938481276772234.__fanout_complex_f32__2.6" device_affinity="cpu0" ()
        ports_in (%outputPort_1370 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1375, %inputPort_1377 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Split__v__N_dyn "split" (%c2_i32 : i32)
        ports_in (%outputPort_1376 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1379, %inputPort_1381 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    %inputPort_1393, %outputPort_1394 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4.out0->split.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1395, %outputPort_1396 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4.out1->twiddles.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1397, %outputPort_1398 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.split.out0->r2cell.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1399, %outputPort_1400 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.split.out1->r2cell.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1401, %outputPort_1402 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.twiddles.out0->r2cell.in2"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1403, %outputPort_1404 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.r2cell.out0->merge.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1405, %outputPort_1406 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.r2cell.out1->merge.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    cal.create_instance @fft__Merge "merge" device_affinity="cpu0" ()
        ports_in (%outputPort_1404, %outputPort_1406 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1389 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__TwiddleGenerator__v__N_dyn "twiddles" (%c1_i32 : i32)
        ports_in (%outputPort_1396 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1401 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Split__v__N_dyn "split" (%c1_i32 : i32)
        ports_in (%outputPort_1394 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1397, %inputPort_1399 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @__fanout_complex_f32__2 "fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4" device_affinity="cpu0" ()
        ports_in (%outputPort_1386 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1393, %inputPort_1395 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Radix2Cell "r2cell" device_affinity="cpu0" ()
        ports_in (%outputPort_1398, %outputPort_1400, %outputPort_1402 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1403, %inputPort_1405 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    %inputPort_1407, %outputPort_1408 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4.out0->split.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1409, %outputPort_1410 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4.out1->twiddles.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1411, %outputPort_1412 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.split.out0->r2cell.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1413, %outputPort_1414 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.split.out1->r2cell.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1415, %outputPort_1416 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.twiddles.out0->r2cell.in2"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1417, %outputPort_1418 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.r2cell.out0->merge.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1419, %outputPort_1420 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.r2cell.out1->merge.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    cal.create_instance @fft__Merge "merge" device_affinity="cpu0" ()
        ports_in (%outputPort_1418, %outputPort_1420 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1391 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__TwiddleGenerator__v__N_dyn "twiddles" (%c1_i32 : i32)
        ports_in (%outputPort_1410 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1415 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Split__v__N_dyn "split" (%c1_i32 : i32)
        ports_in (%outputPort_1408 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1411, %inputPort_1413 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @__fanout_complex_f32__2 "fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4" device_affinity="cpu0" ()
        ports_in (%outputPort_1388 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1407, %inputPort_1409 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Radix2Cell "r2cell" device_affinity="cpu0" ()
        ports_in (%outputPort_1412, %outputPort_1414, %outputPort_1416 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1417, %inputPort_1419 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Merge "merge" device_affinity="cpu0" ()
        ports_in (%outputPort_1390, %outputPort_1392 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1373 : !fifo.input_port<complex<f32>>)
    %inputPort_1421, %outputPort_1422 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_1916938481276772234.__fanout_complex_f32__2.6.out0->split.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1423, %outputPort_1424 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_1916938481276772234.__fanout_complex_f32__2.6.out1->twiddles.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1425, %outputPort_1426 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.split.out0->r2cell.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1427, %outputPort_1428 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.split.out1->r2cell.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1429, %outputPort_1430 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.twiddles.out0->r2cell.in2"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1431, %outputPort_1432 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.r2cell.out0->fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_15446289516955298258.4.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1433, %outputPort_1434 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.r2cell.out1->fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_15446289516955298258.5.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1435, %outputPort_1436 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_15446289516955298258.4.out0->merge.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1437, %outputPort_1438 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_15446289516955298258.5.out0->merge.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    cal.create_instance @fft__Radix2Cell "r2cell" device_affinity="cpu0" ()
        ports_in (%outputPort_1426, %outputPort_1428, %outputPort_1430 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1431, %inputPort_1433 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__TwiddleGenerator__v__N_dyn "twiddles" (%c2_i32 : i32)
        ports_in (%outputPort_1424 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1429 : !fifo.input_port<complex<f32>>)
    cal.create_instance @__fanout_complex_f32__2 "fft__Butterfly$spec_1916938481276772234.__fanout_complex_f32__2.6" device_affinity="cpu0" ()
        ports_in (%outputPort_1368 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1421, %inputPort_1423 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Split__v__N_dyn "split" (%c2_i32 : i32)
        ports_in (%outputPort_1422 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1425, %inputPort_1427 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    %inputPort_1439, %outputPort_1440 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4.out0->split.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1441, %outputPort_1442 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4.out1->twiddles.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1443, %outputPort_1444 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.split.out0->r2cell.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1445, %outputPort_1446 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.split.out1->r2cell.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1447, %outputPort_1448 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.twiddles.out0->r2cell.in2"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1449, %outputPort_1450 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.r2cell.out0->merge.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1451, %outputPort_1452 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.r2cell.out1->merge.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    cal.create_instance @fft__Merge "merge" device_affinity="cpu0" ()
        ports_in (%outputPort_1450, %outputPort_1452 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1435 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__TwiddleGenerator__v__N_dyn "twiddles" (%c1_i32 : i32)
        ports_in (%outputPort_1442 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1447 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Split__v__N_dyn "split" (%c1_i32 : i32)
        ports_in (%outputPort_1440 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1443, %inputPort_1445 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @__fanout_complex_f32__2 "fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4" device_affinity="cpu0" ()
        ports_in (%outputPort_1432 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1439, %inputPort_1441 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Radix2Cell "r2cell" device_affinity="cpu0" ()
        ports_in (%outputPort_1444, %outputPort_1446, %outputPort_1448 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1449, %inputPort_1451 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    %inputPort_1453, %outputPort_1454 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4.out0->split.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1455, %outputPort_1456 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4.out1->twiddles.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1457, %outputPort_1458 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.split.out0->r2cell.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1459, %outputPort_1460 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.split.out1->r2cell.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1461, %outputPort_1462 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.twiddles.out0->r2cell.in2"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1463, %outputPort_1464 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.r2cell.out0->merge.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1465, %outputPort_1466 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.r2cell.out1->merge.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    cal.create_instance @fft__Merge "merge" device_affinity="cpu0" ()
        ports_in (%outputPort_1464, %outputPort_1466 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1437 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__TwiddleGenerator__v__N_dyn "twiddles" (%c1_i32 : i32)
        ports_in (%outputPort_1456 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1461 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Split__v__N_dyn "split" (%c1_i32 : i32)
        ports_in (%outputPort_1454 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1457, %inputPort_1459 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @__fanout_complex_f32__2 "fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4" device_affinity="cpu0" ()
        ports_in (%outputPort_1434 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1453, %inputPort_1455 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Radix2Cell "r2cell" device_affinity="cpu0" ()
        ports_in (%outputPort_1458, %outputPort_1460, %outputPort_1462 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1463, %inputPort_1465 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Merge "merge" device_affinity="cpu0" ()
        ports_in (%outputPort_1436, %outputPort_1438 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1371 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__TwiddleGenerator__v__N_dyn "twiddles" (%c8_i32 : i32)
        ports_in (%outputPort_1342 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1347 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Radix2Cell "r2cell" device_affinity="cpu0" ()
        ports_in (%outputPort_1344, %outputPort_1346, %outputPort_1348 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1349, %inputPort_1351 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    %inputPort_1467, %outputPort_1468 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.fft__Butterfly$spec_9935405952460034831.__fanout_complex_f32__2.6.out0->split.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1469, %outputPort_1470 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.fft__Butterfly$spec_9935405952460034831.__fanout_complex_f32__2.6.out1->twiddles.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1471, %outputPort_1472 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.split.out0->r2cell.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1473, %outputPort_1474 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.split.out1->r2cell.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1475, %outputPort_1476 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.twiddles.out0->r2cell.in2"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1477, %outputPort_1478 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.r2cell.out0->fft__Butterfly$spec_9935405952460034831.fft__Butterfly$spec_1916938481276772234.4.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1479, %outputPort_1480 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.r2cell.out1->fft__Butterfly$spec_9935405952460034831.fft__Butterfly$spec_1916938481276772234.5.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1481, %outputPort_1482 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.fft__Butterfly$spec_9935405952460034831.fft__Butterfly$spec_1916938481276772234.4.out0->merge.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1483, %outputPort_1484 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.fft__Butterfly$spec_9935405952460034831.fft__Butterfly$spec_1916938481276772234.5.out0->merge.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    cal.create_instance @fft__Radix2Cell "r2cell" device_affinity="cpu0" ()
        ports_in (%outputPort_1472, %outputPort_1474, %outputPort_1476 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1477, %inputPort_1479 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Split__v__N_dyn "split" (%c4_i32 : i32)
        ports_in (%outputPort_1468 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1471, %inputPort_1473 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Merge "merge" device_affinity="cpu0" ()
        ports_in (%outputPort_1482, %outputPort_1484 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1353 : !fifo.input_port<complex<f32>>)
    cal.create_instance @__fanout_complex_f32__2 "fft__Butterfly$spec_9935405952460034831.__fanout_complex_f32__2.6" device_affinity="cpu0" ()
        ports_in (%outputPort_1350 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1467, %inputPort_1469 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__TwiddleGenerator__v__N_dyn "twiddles" (%c4_i32 : i32)
        ports_in (%outputPort_1470 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1475 : !fifo.input_port<complex<f32>>)
    %inputPort_1485, %outputPort_1486 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_1916938481276772234.__fanout_complex_f32__2.6.out0->split.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1487, %outputPort_1488 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_1916938481276772234.__fanout_complex_f32__2.6.out1->twiddles.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1489, %outputPort_1490 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.split.out0->r2cell.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1491, %outputPort_1492 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.split.out1->r2cell.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1493, %outputPort_1494 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.twiddles.out0->r2cell.in2"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1495, %outputPort_1496 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.r2cell.out0->fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_15446289516955298258.4.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1497, %outputPort_1498 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.r2cell.out1->fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_15446289516955298258.5.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1499, %outputPort_1500 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_15446289516955298258.4.out0->merge.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1501, %outputPort_1502 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_15446289516955298258.5.out0->merge.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    cal.create_instance @fft__Radix2Cell "r2cell" device_affinity="cpu0" ()
        ports_in (%outputPort_1490, %outputPort_1492, %outputPort_1494 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1495, %inputPort_1497 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__TwiddleGenerator__v__N_dyn "twiddles" (%c2_i32 : i32)
        ports_in (%outputPort_1488 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1493 : !fifo.input_port<complex<f32>>)
    cal.create_instance @__fanout_complex_f32__2 "fft__Butterfly$spec_1916938481276772234.__fanout_complex_f32__2.6" device_affinity="cpu0" ()
        ports_in (%outputPort_1480 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1485, %inputPort_1487 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Split__v__N_dyn "split" (%c2_i32 : i32)
        ports_in (%outputPort_1486 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1489, %inputPort_1491 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    %inputPort_1503, %outputPort_1504 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4.out0->split.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1505, %outputPort_1506 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4.out1->twiddles.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1507, %outputPort_1508 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.split.out0->r2cell.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1509, %outputPort_1510 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.split.out1->r2cell.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1511, %outputPort_1512 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.twiddles.out0->r2cell.in2"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1513, %outputPort_1514 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.r2cell.out0->merge.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1515, %outputPort_1516 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.r2cell.out1->merge.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    cal.create_instance @fft__Merge "merge" device_affinity="cpu0" ()
        ports_in (%outputPort_1514, %outputPort_1516 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1499 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__TwiddleGenerator__v__N_dyn "twiddles" (%c1_i32 : i32)
        ports_in (%outputPort_1506 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1511 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Split__v__N_dyn "split" (%c1_i32 : i32)
        ports_in (%outputPort_1504 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1507, %inputPort_1509 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @__fanout_complex_f32__2 "fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4" device_affinity="cpu0" ()
        ports_in (%outputPort_1496 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1503, %inputPort_1505 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Radix2Cell "r2cell" device_affinity="cpu0" ()
        ports_in (%outputPort_1508, %outputPort_1510, %outputPort_1512 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1513, %inputPort_1515 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    %inputPort_1517, %outputPort_1518 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4.out0->split.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1519, %outputPort_1520 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4.out1->twiddles.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1521, %outputPort_1522 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.split.out0->r2cell.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1523, %outputPort_1524 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.split.out1->r2cell.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1525, %outputPort_1526 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.twiddles.out0->r2cell.in2"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1527, %outputPort_1528 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.r2cell.out0->merge.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1529, %outputPort_1530 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.r2cell.out1->merge.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    cal.create_instance @fft__Merge "merge" device_affinity="cpu0" ()
        ports_in (%outputPort_1528, %outputPort_1530 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1501 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__TwiddleGenerator__v__N_dyn "twiddles" (%c1_i32 : i32)
        ports_in (%outputPort_1520 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1525 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Split__v__N_dyn "split" (%c1_i32 : i32)
        ports_in (%outputPort_1518 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1521, %inputPort_1523 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @__fanout_complex_f32__2 "fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4" device_affinity="cpu0" ()
        ports_in (%outputPort_1498 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1517, %inputPort_1519 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Radix2Cell "r2cell" device_affinity="cpu0" ()
        ports_in (%outputPort_1522, %outputPort_1524, %outputPort_1526 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1527, %inputPort_1529 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Merge "merge" device_affinity="cpu0" ()
        ports_in (%outputPort_1500, %outputPort_1502 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1483 : !fifo.input_port<complex<f32>>)
    %inputPort_1531, %outputPort_1532 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_1916938481276772234.__fanout_complex_f32__2.6.out0->split.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1533, %outputPort_1534 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_1916938481276772234.__fanout_complex_f32__2.6.out1->twiddles.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1535, %outputPort_1536 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.split.out0->r2cell.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1537, %outputPort_1538 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.split.out1->r2cell.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1539, %outputPort_1540 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.twiddles.out0->r2cell.in2"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1541, %outputPort_1542 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.r2cell.out0->fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_15446289516955298258.4.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1543, %outputPort_1544 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.r2cell.out1->fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_15446289516955298258.5.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1545, %outputPort_1546 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_15446289516955298258.4.out0->merge.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1547, %outputPort_1548 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_15446289516955298258.5.out0->merge.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    cal.create_instance @fft__Radix2Cell "r2cell" device_affinity="cpu0" ()
        ports_in (%outputPort_1536, %outputPort_1538, %outputPort_1540 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1541, %inputPort_1543 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__TwiddleGenerator__v__N_dyn "twiddles" (%c2_i32 : i32)
        ports_in (%outputPort_1534 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1539 : !fifo.input_port<complex<f32>>)
    cal.create_instance @__fanout_complex_f32__2 "fft__Butterfly$spec_1916938481276772234.__fanout_complex_f32__2.6" device_affinity="cpu0" ()
        ports_in (%outputPort_1478 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1531, %inputPort_1533 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Split__v__N_dyn "split" (%c2_i32 : i32)
        ports_in (%outputPort_1532 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1535, %inputPort_1537 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    %inputPort_1549, %outputPort_1550 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4.out0->split.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1551, %outputPort_1552 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4.out1->twiddles.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1553, %outputPort_1554 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.split.out0->r2cell.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1555, %outputPort_1556 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.split.out1->r2cell.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1557, %outputPort_1558 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.twiddles.out0->r2cell.in2"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1559, %outputPort_1560 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.r2cell.out0->merge.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1561, %outputPort_1562 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.r2cell.out1->merge.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    cal.create_instance @fft__Merge "merge" device_affinity="cpu0" ()
        ports_in (%outputPort_1560, %outputPort_1562 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1545 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__TwiddleGenerator__v__N_dyn "twiddles" (%c1_i32 : i32)
        ports_in (%outputPort_1552 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1557 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Split__v__N_dyn "split" (%c1_i32 : i32)
        ports_in (%outputPort_1550 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1553, %inputPort_1555 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @__fanout_complex_f32__2 "fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4" device_affinity="cpu0" ()
        ports_in (%outputPort_1542 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1549, %inputPort_1551 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Radix2Cell "r2cell" device_affinity="cpu0" ()
        ports_in (%outputPort_1554, %outputPort_1556, %outputPort_1558 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1559, %inputPort_1561 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    %inputPort_1563, %outputPort_1564 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4.out0->split.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1565, %outputPort_1566 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4.out1->twiddles.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1567, %outputPort_1568 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.split.out0->r2cell.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1569, %outputPort_1570 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.split.out1->r2cell.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1571, %outputPort_1572 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.twiddles.out0->r2cell.in2"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1573, %outputPort_1574 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.r2cell.out0->merge.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1575, %outputPort_1576 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.r2cell.out1->merge.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    cal.create_instance @fft__Merge "merge" device_affinity="cpu0" ()
        ports_in (%outputPort_1574, %outputPort_1576 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1547 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__TwiddleGenerator__v__N_dyn "twiddles" (%c1_i32 : i32)
        ports_in (%outputPort_1566 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1571 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Split__v__N_dyn "split" (%c1_i32 : i32)
        ports_in (%outputPort_1564 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1567, %inputPort_1569 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @__fanout_complex_f32__2 "fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4" device_affinity="cpu0" ()
        ports_in (%outputPort_1544 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1563, %inputPort_1565 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Radix2Cell "r2cell" device_affinity="cpu0" ()
        ports_in (%outputPort_1568, %outputPort_1570, %outputPort_1572 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1573, %inputPort_1575 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Merge "merge" device_affinity="cpu0" ()
        ports_in (%outputPort_1546, %outputPort_1548 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1481 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Split__v__N_dyn "split" (%c8_i32 : i32)
        ports_in (%outputPort_1340 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1343, %inputPort_1345 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Split__v__N_dyn "split" (%c16_i32 : i32)
        ports_in (%outputPort_1084 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1087, %inputPort_1089 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Radix2Cell "r2cell" device_affinity="cpu0" ()
        ports_in (%outputPort_1070, %outputPort_1072, %outputPort_1074 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1075, %inputPort_1077 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__TwiddleGenerator__v__N_dyn "twiddles" (%c32_i32 : i32)
        ports_in (%outputPort_1068 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1073 : !fifo.input_port<complex<f32>>)
    cal.create_instance @__fanout_complex_f32__2 "fft__Butterfly$spec_17640631431051100303.__fanout_complex_f32__2.6" device_affinity="cpu0" ()
        ports_in (%outputPort_54 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1065, %inputPort_1067 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    %inputPort_1577, %outputPort_1578 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_3035977640463470463.fft__Butterfly$spec_3035977640463470463.__fanout_complex_f32__2.6.out0->split.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1579, %outputPort_1580 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_3035977640463470463.fft__Butterfly$spec_3035977640463470463.__fanout_complex_f32__2.6.out1->twiddles.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1581, %outputPort_1582 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_3035977640463470463.split.out0->r2cell.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1583, %outputPort_1584 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_3035977640463470463.split.out1->r2cell.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1585, %outputPort_1586 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_3035977640463470463.twiddles.out0->r2cell.in2"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1587, %outputPort_1588 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_3035977640463470463.r2cell.out0->fft__Butterfly$spec_3035977640463470463.fft__Butterfly$spec_16755419077516047831.4.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1589, %outputPort_1590 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_3035977640463470463.r2cell.out1->fft__Butterfly$spec_3035977640463470463.fft__Butterfly$spec_16755419077516047831.5.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1591, %outputPort_1592 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_3035977640463470463.fft__Butterfly$spec_3035977640463470463.fft__Butterfly$spec_16755419077516047831.4.out0->merge.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1593, %outputPort_1594 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_3035977640463470463.fft__Butterfly$spec_3035977640463470463.fft__Butterfly$spec_16755419077516047831.5.out0->merge.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    cal.create_instance @fft__TwiddleGenerator__v__N_dyn "twiddles" (%c16_i32 : i32)
        ports_in (%outputPort_1580 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1585 : !fifo.input_port<complex<f32>>)
    %inputPort_1595, %outputPort_1596 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_16755419077516047831.fft__Butterfly$spec_16755419077516047831.__fanout_complex_f32__2.6.out0->split.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1597, %outputPort_1598 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_16755419077516047831.fft__Butterfly$spec_16755419077516047831.__fanout_complex_f32__2.6.out1->twiddles.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1599, %outputPort_1600 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_16755419077516047831.split.out0->r2cell.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1601, %outputPort_1602 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_16755419077516047831.split.out1->r2cell.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1603, %outputPort_1604 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_16755419077516047831.twiddles.out0->r2cell.in2"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1605, %outputPort_1606 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_16755419077516047831.r2cell.out0->fft__Butterfly$spec_16755419077516047831.fft__Butterfly$spec_9935405952460034831.4.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1607, %outputPort_1608 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_16755419077516047831.r2cell.out1->fft__Butterfly$spec_16755419077516047831.fft__Butterfly$spec_9935405952460034831.5.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1609, %outputPort_1610 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_16755419077516047831.fft__Butterfly$spec_16755419077516047831.fft__Butterfly$spec_9935405952460034831.4.out0->merge.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1611, %outputPort_1612 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_16755419077516047831.fft__Butterfly$spec_16755419077516047831.fft__Butterfly$spec_9935405952460034831.5.out0->merge.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    cal.create_instance @__fanout_complex_f32__2 "fft__Butterfly$spec_16755419077516047831.__fanout_complex_f32__2.6" device_affinity="cpu0" ()
        ports_in (%outputPort_1590 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1595, %inputPort_1597 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Merge "merge" device_affinity="cpu0" ()
        ports_in (%outputPort_1610, %outputPort_1612 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1593 : !fifo.input_port<complex<f32>>)
    %inputPort_1613, %outputPort_1614 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.fft__Butterfly$spec_9935405952460034831.__fanout_complex_f32__2.6.out0->split.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1615, %outputPort_1616 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.fft__Butterfly$spec_9935405952460034831.__fanout_complex_f32__2.6.out1->twiddles.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1617, %outputPort_1618 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.split.out0->r2cell.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1619, %outputPort_1620 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.split.out1->r2cell.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1621, %outputPort_1622 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.twiddles.out0->r2cell.in2"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1623, %outputPort_1624 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.r2cell.out0->fft__Butterfly$spec_9935405952460034831.fft__Butterfly$spec_1916938481276772234.4.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1625, %outputPort_1626 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.r2cell.out1->fft__Butterfly$spec_9935405952460034831.fft__Butterfly$spec_1916938481276772234.5.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1627, %outputPort_1628 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.fft__Butterfly$spec_9935405952460034831.fft__Butterfly$spec_1916938481276772234.4.out0->merge.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1629, %outputPort_1630 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.fft__Butterfly$spec_9935405952460034831.fft__Butterfly$spec_1916938481276772234.5.out0->merge.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    cal.create_instance @fft__Radix2Cell "r2cell" device_affinity="cpu0" ()
        ports_in (%outputPort_1618, %outputPort_1620, %outputPort_1622 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1623, %inputPort_1625 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Split__v__N_dyn "split" (%c4_i32 : i32)
        ports_in (%outputPort_1614 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1617, %inputPort_1619 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Merge "merge" device_affinity="cpu0" ()
        ports_in (%outputPort_1628, %outputPort_1630 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1611 : !fifo.input_port<complex<f32>>)
    cal.create_instance @__fanout_complex_f32__2 "fft__Butterfly$spec_9935405952460034831.__fanout_complex_f32__2.6" device_affinity="cpu0" ()
        ports_in (%outputPort_1608 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1613, %inputPort_1615 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__TwiddleGenerator__v__N_dyn "twiddles" (%c4_i32 : i32)
        ports_in (%outputPort_1616 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1621 : !fifo.input_port<complex<f32>>)
    %inputPort_1631, %outputPort_1632 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_1916938481276772234.__fanout_complex_f32__2.6.out0->split.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1633, %outputPort_1634 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_1916938481276772234.__fanout_complex_f32__2.6.out1->twiddles.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1635, %outputPort_1636 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.split.out0->r2cell.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1637, %outputPort_1638 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.split.out1->r2cell.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1639, %outputPort_1640 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.twiddles.out0->r2cell.in2"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1641, %outputPort_1642 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.r2cell.out0->fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_15446289516955298258.4.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1643, %outputPort_1644 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.r2cell.out1->fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_15446289516955298258.5.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1645, %outputPort_1646 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_15446289516955298258.4.out0->merge.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1647, %outputPort_1648 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_15446289516955298258.5.out0->merge.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    cal.create_instance @fft__Radix2Cell "r2cell" device_affinity="cpu0" ()
        ports_in (%outputPort_1636, %outputPort_1638, %outputPort_1640 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1641, %inputPort_1643 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__TwiddleGenerator__v__N_dyn "twiddles" (%c2_i32 : i32)
        ports_in (%outputPort_1634 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1639 : !fifo.input_port<complex<f32>>)
    cal.create_instance @__fanout_complex_f32__2 "fft__Butterfly$spec_1916938481276772234.__fanout_complex_f32__2.6" device_affinity="cpu0" ()
        ports_in (%outputPort_1626 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1631, %inputPort_1633 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Split__v__N_dyn "split" (%c2_i32 : i32)
        ports_in (%outputPort_1632 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1635, %inputPort_1637 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    %inputPort_1649, %outputPort_1650 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4.out0->split.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1651, %outputPort_1652 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4.out1->twiddles.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1653, %outputPort_1654 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.split.out0->r2cell.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1655, %outputPort_1656 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.split.out1->r2cell.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1657, %outputPort_1658 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.twiddles.out0->r2cell.in2"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1659, %outputPort_1660 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.r2cell.out0->merge.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1661, %outputPort_1662 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.r2cell.out1->merge.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    cal.create_instance @fft__Merge "merge" device_affinity="cpu0" ()
        ports_in (%outputPort_1660, %outputPort_1662 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1645 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__TwiddleGenerator__v__N_dyn "twiddles" (%c1_i32 : i32)
        ports_in (%outputPort_1652 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1657 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Split__v__N_dyn "split" (%c1_i32 : i32)
        ports_in (%outputPort_1650 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1653, %inputPort_1655 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @__fanout_complex_f32__2 "fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4" device_affinity="cpu0" ()
        ports_in (%outputPort_1642 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1649, %inputPort_1651 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Radix2Cell "r2cell" device_affinity="cpu0" ()
        ports_in (%outputPort_1654, %outputPort_1656, %outputPort_1658 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1659, %inputPort_1661 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    %inputPort_1663, %outputPort_1664 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4.out0->split.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1665, %outputPort_1666 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4.out1->twiddles.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1667, %outputPort_1668 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.split.out0->r2cell.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1669, %outputPort_1670 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.split.out1->r2cell.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1671, %outputPort_1672 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.twiddles.out0->r2cell.in2"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1673, %outputPort_1674 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.r2cell.out0->merge.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1675, %outputPort_1676 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.r2cell.out1->merge.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    cal.create_instance @fft__Merge "merge" device_affinity="cpu0" ()
        ports_in (%outputPort_1674, %outputPort_1676 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1647 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__TwiddleGenerator__v__N_dyn "twiddles" (%c1_i32 : i32)
        ports_in (%outputPort_1666 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1671 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Split__v__N_dyn "split" (%c1_i32 : i32)
        ports_in (%outputPort_1664 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1667, %inputPort_1669 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @__fanout_complex_f32__2 "fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4" device_affinity="cpu0" ()
        ports_in (%outputPort_1644 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1663, %inputPort_1665 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Radix2Cell "r2cell" device_affinity="cpu0" ()
        ports_in (%outputPort_1668, %outputPort_1670, %outputPort_1672 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1673, %inputPort_1675 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Merge "merge" device_affinity="cpu0" ()
        ports_in (%outputPort_1646, %outputPort_1648 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1629 : !fifo.input_port<complex<f32>>)
    %inputPort_1677, %outputPort_1678 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_1916938481276772234.__fanout_complex_f32__2.6.out0->split.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1679, %outputPort_1680 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_1916938481276772234.__fanout_complex_f32__2.6.out1->twiddles.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1681, %outputPort_1682 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.split.out0->r2cell.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1683, %outputPort_1684 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.split.out1->r2cell.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1685, %outputPort_1686 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.twiddles.out0->r2cell.in2"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1687, %outputPort_1688 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.r2cell.out0->fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_15446289516955298258.4.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1689, %outputPort_1690 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.r2cell.out1->fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_15446289516955298258.5.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1691, %outputPort_1692 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_15446289516955298258.4.out0->merge.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1693, %outputPort_1694 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_15446289516955298258.5.out0->merge.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    cal.create_instance @fft__Radix2Cell "r2cell" device_affinity="cpu0" ()
        ports_in (%outputPort_1682, %outputPort_1684, %outputPort_1686 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1687, %inputPort_1689 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__TwiddleGenerator__v__N_dyn "twiddles" (%c2_i32 : i32)
        ports_in (%outputPort_1680 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1685 : !fifo.input_port<complex<f32>>)
    cal.create_instance @__fanout_complex_f32__2 "fft__Butterfly$spec_1916938481276772234.__fanout_complex_f32__2.6" device_affinity="cpu0" ()
        ports_in (%outputPort_1624 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1677, %inputPort_1679 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Split__v__N_dyn "split" (%c2_i32 : i32)
        ports_in (%outputPort_1678 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1681, %inputPort_1683 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    %inputPort_1695, %outputPort_1696 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4.out0->split.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1697, %outputPort_1698 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4.out1->twiddles.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1699, %outputPort_1700 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.split.out0->r2cell.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1701, %outputPort_1702 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.split.out1->r2cell.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1703, %outputPort_1704 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.twiddles.out0->r2cell.in2"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1705, %outputPort_1706 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.r2cell.out0->merge.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1707, %outputPort_1708 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.r2cell.out1->merge.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    cal.create_instance @fft__Merge "merge" device_affinity="cpu0" ()
        ports_in (%outputPort_1706, %outputPort_1708 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1691 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__TwiddleGenerator__v__N_dyn "twiddles" (%c1_i32 : i32)
        ports_in (%outputPort_1698 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1703 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Split__v__N_dyn "split" (%c1_i32 : i32)
        ports_in (%outputPort_1696 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1699, %inputPort_1701 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @__fanout_complex_f32__2 "fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4" device_affinity="cpu0" ()
        ports_in (%outputPort_1688 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1695, %inputPort_1697 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Radix2Cell "r2cell" device_affinity="cpu0" ()
        ports_in (%outputPort_1700, %outputPort_1702, %outputPort_1704 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1705, %inputPort_1707 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    %inputPort_1709, %outputPort_1710 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4.out0->split.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1711, %outputPort_1712 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4.out1->twiddles.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1713, %outputPort_1714 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.split.out0->r2cell.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1715, %outputPort_1716 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.split.out1->r2cell.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1717, %outputPort_1718 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.twiddles.out0->r2cell.in2"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1719, %outputPort_1720 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.r2cell.out0->merge.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1721, %outputPort_1722 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.r2cell.out1->merge.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    cal.create_instance @fft__Merge "merge" device_affinity="cpu0" ()
        ports_in (%outputPort_1720, %outputPort_1722 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1693 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__TwiddleGenerator__v__N_dyn "twiddles" (%c1_i32 : i32)
        ports_in (%outputPort_1712 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1717 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Split__v__N_dyn "split" (%c1_i32 : i32)
        ports_in (%outputPort_1710 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1713, %inputPort_1715 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @__fanout_complex_f32__2 "fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4" device_affinity="cpu0" ()
        ports_in (%outputPort_1690 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1709, %inputPort_1711 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Radix2Cell "r2cell" device_affinity="cpu0" ()
        ports_in (%outputPort_1714, %outputPort_1716, %outputPort_1718 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1719, %inputPort_1721 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Merge "merge" device_affinity="cpu0" ()
        ports_in (%outputPort_1692, %outputPort_1694 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1627 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__TwiddleGenerator__v__N_dyn "twiddles" (%c8_i32 : i32)
        ports_in (%outputPort_1598 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1603 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Radix2Cell "r2cell" device_affinity="cpu0" ()
        ports_in (%outputPort_1600, %outputPort_1602, %outputPort_1604 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1605, %inputPort_1607 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    %inputPort_1723, %outputPort_1724 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.fft__Butterfly$spec_9935405952460034831.__fanout_complex_f32__2.6.out0->split.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1725, %outputPort_1726 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.fft__Butterfly$spec_9935405952460034831.__fanout_complex_f32__2.6.out1->twiddles.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1727, %outputPort_1728 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.split.out0->r2cell.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1729, %outputPort_1730 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.split.out1->r2cell.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1731, %outputPort_1732 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.twiddles.out0->r2cell.in2"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1733, %outputPort_1734 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.r2cell.out0->fft__Butterfly$spec_9935405952460034831.fft__Butterfly$spec_1916938481276772234.4.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1735, %outputPort_1736 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.r2cell.out1->fft__Butterfly$spec_9935405952460034831.fft__Butterfly$spec_1916938481276772234.5.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1737, %outputPort_1738 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.fft__Butterfly$spec_9935405952460034831.fft__Butterfly$spec_1916938481276772234.4.out0->merge.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1739, %outputPort_1740 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.fft__Butterfly$spec_9935405952460034831.fft__Butterfly$spec_1916938481276772234.5.out0->merge.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    cal.create_instance @fft__Radix2Cell "r2cell" device_affinity="cpu0" ()
        ports_in (%outputPort_1728, %outputPort_1730, %outputPort_1732 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1733, %inputPort_1735 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Split__v__N_dyn "split" (%c4_i32 : i32)
        ports_in (%outputPort_1724 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1727, %inputPort_1729 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Merge "merge" device_affinity="cpu0" ()
        ports_in (%outputPort_1738, %outputPort_1740 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1609 : !fifo.input_port<complex<f32>>)
    cal.create_instance @__fanout_complex_f32__2 "fft__Butterfly$spec_9935405952460034831.__fanout_complex_f32__2.6" device_affinity="cpu0" ()
        ports_in (%outputPort_1606 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1723, %inputPort_1725 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__TwiddleGenerator__v__N_dyn "twiddles" (%c4_i32 : i32)
        ports_in (%outputPort_1726 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1731 : !fifo.input_port<complex<f32>>)
    %inputPort_1741, %outputPort_1742 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_1916938481276772234.__fanout_complex_f32__2.6.out0->split.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1743, %outputPort_1744 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_1916938481276772234.__fanout_complex_f32__2.6.out1->twiddles.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1745, %outputPort_1746 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.split.out0->r2cell.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1747, %outputPort_1748 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.split.out1->r2cell.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1749, %outputPort_1750 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.twiddles.out0->r2cell.in2"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1751, %outputPort_1752 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.r2cell.out0->fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_15446289516955298258.4.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1753, %outputPort_1754 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.r2cell.out1->fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_15446289516955298258.5.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1755, %outputPort_1756 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_15446289516955298258.4.out0->merge.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1757, %outputPort_1758 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_15446289516955298258.5.out0->merge.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    cal.create_instance @fft__Radix2Cell "r2cell" device_affinity="cpu0" ()
        ports_in (%outputPort_1746, %outputPort_1748, %outputPort_1750 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1751, %inputPort_1753 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__TwiddleGenerator__v__N_dyn "twiddles" (%c2_i32 : i32)
        ports_in (%outputPort_1744 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1749 : !fifo.input_port<complex<f32>>)
    cal.create_instance @__fanout_complex_f32__2 "fft__Butterfly$spec_1916938481276772234.__fanout_complex_f32__2.6" device_affinity="cpu0" ()
        ports_in (%outputPort_1736 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1741, %inputPort_1743 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Split__v__N_dyn "split" (%c2_i32 : i32)
        ports_in (%outputPort_1742 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1745, %inputPort_1747 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    %inputPort_1759, %outputPort_1760 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4.out0->split.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1761, %outputPort_1762 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4.out1->twiddles.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1763, %outputPort_1764 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.split.out0->r2cell.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1765, %outputPort_1766 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.split.out1->r2cell.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1767, %outputPort_1768 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.twiddles.out0->r2cell.in2"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1769, %outputPort_1770 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.r2cell.out0->merge.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1771, %outputPort_1772 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.r2cell.out1->merge.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    cal.create_instance @fft__Merge "merge" device_affinity="cpu0" ()
        ports_in (%outputPort_1770, %outputPort_1772 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1755 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__TwiddleGenerator__v__N_dyn "twiddles" (%c1_i32 : i32)
        ports_in (%outputPort_1762 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1767 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Split__v__N_dyn "split" (%c1_i32 : i32)
        ports_in (%outputPort_1760 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1763, %inputPort_1765 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @__fanout_complex_f32__2 "fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4" device_affinity="cpu0" ()
        ports_in (%outputPort_1752 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1759, %inputPort_1761 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Radix2Cell "r2cell" device_affinity="cpu0" ()
        ports_in (%outputPort_1764, %outputPort_1766, %outputPort_1768 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1769, %inputPort_1771 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    %inputPort_1773, %outputPort_1774 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4.out0->split.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1775, %outputPort_1776 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4.out1->twiddles.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1777, %outputPort_1778 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.split.out0->r2cell.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1779, %outputPort_1780 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.split.out1->r2cell.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1781, %outputPort_1782 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.twiddles.out0->r2cell.in2"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1783, %outputPort_1784 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.r2cell.out0->merge.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1785, %outputPort_1786 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.r2cell.out1->merge.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    cal.create_instance @fft__Merge "merge" device_affinity="cpu0" ()
        ports_in (%outputPort_1784, %outputPort_1786 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1757 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__TwiddleGenerator__v__N_dyn "twiddles" (%c1_i32 : i32)
        ports_in (%outputPort_1776 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1781 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Split__v__N_dyn "split" (%c1_i32 : i32)
        ports_in (%outputPort_1774 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1777, %inputPort_1779 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @__fanout_complex_f32__2 "fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4" device_affinity="cpu0" ()
        ports_in (%outputPort_1754 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1773, %inputPort_1775 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Radix2Cell "r2cell" device_affinity="cpu0" ()
        ports_in (%outputPort_1778, %outputPort_1780, %outputPort_1782 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1783, %inputPort_1785 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Merge "merge" device_affinity="cpu0" ()
        ports_in (%outputPort_1756, %outputPort_1758 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1739 : !fifo.input_port<complex<f32>>)
    %inputPort_1787, %outputPort_1788 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_1916938481276772234.__fanout_complex_f32__2.6.out0->split.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1789, %outputPort_1790 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_1916938481276772234.__fanout_complex_f32__2.6.out1->twiddles.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1791, %outputPort_1792 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.split.out0->r2cell.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1793, %outputPort_1794 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.split.out1->r2cell.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1795, %outputPort_1796 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.twiddles.out0->r2cell.in2"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1797, %outputPort_1798 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.r2cell.out0->fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_15446289516955298258.4.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1799, %outputPort_1800 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.r2cell.out1->fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_15446289516955298258.5.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1801, %outputPort_1802 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_15446289516955298258.4.out0->merge.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1803, %outputPort_1804 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_15446289516955298258.5.out0->merge.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    cal.create_instance @fft__Radix2Cell "r2cell" device_affinity="cpu0" ()
        ports_in (%outputPort_1792, %outputPort_1794, %outputPort_1796 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1797, %inputPort_1799 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__TwiddleGenerator__v__N_dyn "twiddles" (%c2_i32 : i32)
        ports_in (%outputPort_1790 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1795 : !fifo.input_port<complex<f32>>)
    cal.create_instance @__fanout_complex_f32__2 "fft__Butterfly$spec_1916938481276772234.__fanout_complex_f32__2.6" device_affinity="cpu0" ()
        ports_in (%outputPort_1734 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1787, %inputPort_1789 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Split__v__N_dyn "split" (%c2_i32 : i32)
        ports_in (%outputPort_1788 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1791, %inputPort_1793 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    %inputPort_1805, %outputPort_1806 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4.out0->split.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1807, %outputPort_1808 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4.out1->twiddles.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1809, %outputPort_1810 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.split.out0->r2cell.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1811, %outputPort_1812 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.split.out1->r2cell.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1813, %outputPort_1814 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.twiddles.out0->r2cell.in2"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1815, %outputPort_1816 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.r2cell.out0->merge.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1817, %outputPort_1818 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.r2cell.out1->merge.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    cal.create_instance @fft__Merge "merge" device_affinity="cpu0" ()
        ports_in (%outputPort_1816, %outputPort_1818 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1801 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__TwiddleGenerator__v__N_dyn "twiddles" (%c1_i32 : i32)
        ports_in (%outputPort_1808 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1813 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Split__v__N_dyn "split" (%c1_i32 : i32)
        ports_in (%outputPort_1806 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1809, %inputPort_1811 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @__fanout_complex_f32__2 "fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4" device_affinity="cpu0" ()
        ports_in (%outputPort_1798 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1805, %inputPort_1807 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Radix2Cell "r2cell" device_affinity="cpu0" ()
        ports_in (%outputPort_1810, %outputPort_1812, %outputPort_1814 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1815, %inputPort_1817 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    %inputPort_1819, %outputPort_1820 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4.out0->split.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1821, %outputPort_1822 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4.out1->twiddles.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1823, %outputPort_1824 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.split.out0->r2cell.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1825, %outputPort_1826 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.split.out1->r2cell.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1827, %outputPort_1828 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.twiddles.out0->r2cell.in2"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1829, %outputPort_1830 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.r2cell.out0->merge.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1831, %outputPort_1832 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.r2cell.out1->merge.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    cal.create_instance @fft__Merge "merge" device_affinity="cpu0" ()
        ports_in (%outputPort_1830, %outputPort_1832 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1803 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__TwiddleGenerator__v__N_dyn "twiddles" (%c1_i32 : i32)
        ports_in (%outputPort_1822 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1827 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Split__v__N_dyn "split" (%c1_i32 : i32)
        ports_in (%outputPort_1820 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1823, %inputPort_1825 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @__fanout_complex_f32__2 "fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4" device_affinity="cpu0" ()
        ports_in (%outputPort_1800 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1819, %inputPort_1821 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Radix2Cell "r2cell" device_affinity="cpu0" ()
        ports_in (%outputPort_1824, %outputPort_1826, %outputPort_1828 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1829, %inputPort_1831 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Merge "merge" device_affinity="cpu0" ()
        ports_in (%outputPort_1802, %outputPort_1804 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1737 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Split__v__N_dyn "split" (%c8_i32 : i32)
        ports_in (%outputPort_1596 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1599, %inputPort_1601 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Radix2Cell "r2cell" device_affinity="cpu0" ()
        ports_in (%outputPort_1582, %outputPort_1584, %outputPort_1586 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1587, %inputPort_1589 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Merge "merge" device_affinity="cpu0" ()
        ports_in (%outputPort_1592, %outputPort_1594 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1081 : !fifo.input_port<complex<f32>>)
    cal.create_instance @__fanout_complex_f32__2 "fft__Butterfly$spec_3035977640463470463.__fanout_complex_f32__2.6" device_affinity="cpu0" ()
        ports_in (%outputPort_1078 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1577, %inputPort_1579 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    %inputPort_1833, %outputPort_1834 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_16755419077516047831.fft__Butterfly$spec_16755419077516047831.__fanout_complex_f32__2.6.out0->split.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1835, %outputPort_1836 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_16755419077516047831.fft__Butterfly$spec_16755419077516047831.__fanout_complex_f32__2.6.out1->twiddles.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1837, %outputPort_1838 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_16755419077516047831.split.out0->r2cell.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1839, %outputPort_1840 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_16755419077516047831.split.out1->r2cell.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1841, %outputPort_1842 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_16755419077516047831.twiddles.out0->r2cell.in2"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1843, %outputPort_1844 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_16755419077516047831.r2cell.out0->fft__Butterfly$spec_16755419077516047831.fft__Butterfly$spec_9935405952460034831.4.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1845, %outputPort_1846 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_16755419077516047831.r2cell.out1->fft__Butterfly$spec_16755419077516047831.fft__Butterfly$spec_9935405952460034831.5.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1847, %outputPort_1848 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_16755419077516047831.fft__Butterfly$spec_16755419077516047831.fft__Butterfly$spec_9935405952460034831.4.out0->merge.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1849, %outputPort_1850 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_16755419077516047831.fft__Butterfly$spec_16755419077516047831.fft__Butterfly$spec_9935405952460034831.5.out0->merge.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    cal.create_instance @__fanout_complex_f32__2 "fft__Butterfly$spec_16755419077516047831.__fanout_complex_f32__2.6" device_affinity="cpu0" ()
        ports_in (%outputPort_1588 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1833, %inputPort_1835 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Merge "merge" device_affinity="cpu0" ()
        ports_in (%outputPort_1848, %outputPort_1850 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1591 : !fifo.input_port<complex<f32>>)
    %inputPort_1851, %outputPort_1852 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.fft__Butterfly$spec_9935405952460034831.__fanout_complex_f32__2.6.out0->split.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1853, %outputPort_1854 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.fft__Butterfly$spec_9935405952460034831.__fanout_complex_f32__2.6.out1->twiddles.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1855, %outputPort_1856 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.split.out0->r2cell.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1857, %outputPort_1858 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.split.out1->r2cell.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1859, %outputPort_1860 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.twiddles.out0->r2cell.in2"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1861, %outputPort_1862 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.r2cell.out0->fft__Butterfly$spec_9935405952460034831.fft__Butterfly$spec_1916938481276772234.4.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1863, %outputPort_1864 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.r2cell.out1->fft__Butterfly$spec_9935405952460034831.fft__Butterfly$spec_1916938481276772234.5.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1865, %outputPort_1866 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.fft__Butterfly$spec_9935405952460034831.fft__Butterfly$spec_1916938481276772234.4.out0->merge.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1867, %outputPort_1868 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.fft__Butterfly$spec_9935405952460034831.fft__Butterfly$spec_1916938481276772234.5.out0->merge.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    cal.create_instance @fft__Radix2Cell "r2cell" device_affinity="cpu0" ()
        ports_in (%outputPort_1856, %outputPort_1858, %outputPort_1860 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1861, %inputPort_1863 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Split__v__N_dyn "split" (%c4_i32 : i32)
        ports_in (%outputPort_1852 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1855, %inputPort_1857 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Merge "merge" device_affinity="cpu0" ()
        ports_in (%outputPort_1866, %outputPort_1868 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1849 : !fifo.input_port<complex<f32>>)
    cal.create_instance @__fanout_complex_f32__2 "fft__Butterfly$spec_9935405952460034831.__fanout_complex_f32__2.6" device_affinity="cpu0" ()
        ports_in (%outputPort_1846 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1851, %inputPort_1853 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__TwiddleGenerator__v__N_dyn "twiddles" (%c4_i32 : i32)
        ports_in (%outputPort_1854 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1859 : !fifo.input_port<complex<f32>>)
    %inputPort_1869, %outputPort_1870 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_1916938481276772234.__fanout_complex_f32__2.6.out0->split.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1871, %outputPort_1872 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_1916938481276772234.__fanout_complex_f32__2.6.out1->twiddles.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1873, %outputPort_1874 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.split.out0->r2cell.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1875, %outputPort_1876 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.split.out1->r2cell.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1877, %outputPort_1878 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.twiddles.out0->r2cell.in2"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1879, %outputPort_1880 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.r2cell.out0->fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_15446289516955298258.4.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1881, %outputPort_1882 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.r2cell.out1->fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_15446289516955298258.5.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1883, %outputPort_1884 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_15446289516955298258.4.out0->merge.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1885, %outputPort_1886 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_15446289516955298258.5.out0->merge.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    cal.create_instance @fft__Radix2Cell "r2cell" device_affinity="cpu0" ()
        ports_in (%outputPort_1874, %outputPort_1876, %outputPort_1878 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1879, %inputPort_1881 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__TwiddleGenerator__v__N_dyn "twiddles" (%c2_i32 : i32)
        ports_in (%outputPort_1872 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1877 : !fifo.input_port<complex<f32>>)
    cal.create_instance @__fanout_complex_f32__2 "fft__Butterfly$spec_1916938481276772234.__fanout_complex_f32__2.6" device_affinity="cpu0" ()
        ports_in (%outputPort_1864 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1869, %inputPort_1871 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Split__v__N_dyn "split" (%c2_i32 : i32)
        ports_in (%outputPort_1870 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1873, %inputPort_1875 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    %inputPort_1887, %outputPort_1888 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4.out0->split.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1889, %outputPort_1890 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4.out1->twiddles.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1891, %outputPort_1892 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.split.out0->r2cell.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1893, %outputPort_1894 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.split.out1->r2cell.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1895, %outputPort_1896 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.twiddles.out0->r2cell.in2"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1897, %outputPort_1898 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.r2cell.out0->merge.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1899, %outputPort_1900 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.r2cell.out1->merge.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    cal.create_instance @fft__Merge "merge" device_affinity="cpu0" ()
        ports_in (%outputPort_1898, %outputPort_1900 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1883 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__TwiddleGenerator__v__N_dyn "twiddles" (%c1_i32 : i32)
        ports_in (%outputPort_1890 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1895 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Split__v__N_dyn "split" (%c1_i32 : i32)
        ports_in (%outputPort_1888 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1891, %inputPort_1893 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @__fanout_complex_f32__2 "fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4" device_affinity="cpu0" ()
        ports_in (%outputPort_1880 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1887, %inputPort_1889 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Radix2Cell "r2cell" device_affinity="cpu0" ()
        ports_in (%outputPort_1892, %outputPort_1894, %outputPort_1896 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1897, %inputPort_1899 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    %inputPort_1901, %outputPort_1902 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4.out0->split.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1903, %outputPort_1904 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4.out1->twiddles.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1905, %outputPort_1906 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.split.out0->r2cell.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1907, %outputPort_1908 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.split.out1->r2cell.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1909, %outputPort_1910 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.twiddles.out0->r2cell.in2"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1911, %outputPort_1912 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.r2cell.out0->merge.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1913, %outputPort_1914 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.r2cell.out1->merge.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    cal.create_instance @fft__Merge "merge" device_affinity="cpu0" ()
        ports_in (%outputPort_1912, %outputPort_1914 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1885 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__TwiddleGenerator__v__N_dyn "twiddles" (%c1_i32 : i32)
        ports_in (%outputPort_1904 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1909 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Split__v__N_dyn "split" (%c1_i32 : i32)
        ports_in (%outputPort_1902 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1905, %inputPort_1907 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @__fanout_complex_f32__2 "fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4" device_affinity="cpu0" ()
        ports_in (%outputPort_1882 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1901, %inputPort_1903 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Radix2Cell "r2cell" device_affinity="cpu0" ()
        ports_in (%outputPort_1906, %outputPort_1908, %outputPort_1910 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1911, %inputPort_1913 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Merge "merge" device_affinity="cpu0" ()
        ports_in (%outputPort_1884, %outputPort_1886 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1867 : !fifo.input_port<complex<f32>>)
    %inputPort_1915, %outputPort_1916 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_1916938481276772234.__fanout_complex_f32__2.6.out0->split.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1917, %outputPort_1918 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_1916938481276772234.__fanout_complex_f32__2.6.out1->twiddles.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1919, %outputPort_1920 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.split.out0->r2cell.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1921, %outputPort_1922 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.split.out1->r2cell.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1923, %outputPort_1924 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.twiddles.out0->r2cell.in2"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1925, %outputPort_1926 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.r2cell.out0->fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_15446289516955298258.4.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1927, %outputPort_1928 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.r2cell.out1->fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_15446289516955298258.5.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1929, %outputPort_1930 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_15446289516955298258.4.out0->merge.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1931, %outputPort_1932 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_15446289516955298258.5.out0->merge.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    cal.create_instance @fft__Radix2Cell "r2cell" device_affinity="cpu0" ()
        ports_in (%outputPort_1920, %outputPort_1922, %outputPort_1924 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1925, %inputPort_1927 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__TwiddleGenerator__v__N_dyn "twiddles" (%c2_i32 : i32)
        ports_in (%outputPort_1918 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1923 : !fifo.input_port<complex<f32>>)
    cal.create_instance @__fanout_complex_f32__2 "fft__Butterfly$spec_1916938481276772234.__fanout_complex_f32__2.6" device_affinity="cpu0" ()
        ports_in (%outputPort_1862 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1915, %inputPort_1917 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Split__v__N_dyn "split" (%c2_i32 : i32)
        ports_in (%outputPort_1916 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1919, %inputPort_1921 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    %inputPort_1933, %outputPort_1934 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4.out0->split.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1935, %outputPort_1936 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4.out1->twiddles.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1937, %outputPort_1938 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.split.out0->r2cell.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1939, %outputPort_1940 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.split.out1->r2cell.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1941, %outputPort_1942 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.twiddles.out0->r2cell.in2"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1943, %outputPort_1944 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.r2cell.out0->merge.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1945, %outputPort_1946 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.r2cell.out1->merge.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    cal.create_instance @fft__Merge "merge" device_affinity="cpu0" ()
        ports_in (%outputPort_1944, %outputPort_1946 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1929 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__TwiddleGenerator__v__N_dyn "twiddles" (%c1_i32 : i32)
        ports_in (%outputPort_1936 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1941 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Split__v__N_dyn "split" (%c1_i32 : i32)
        ports_in (%outputPort_1934 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1937, %inputPort_1939 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @__fanout_complex_f32__2 "fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4" device_affinity="cpu0" ()
        ports_in (%outputPort_1926 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1933, %inputPort_1935 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Radix2Cell "r2cell" device_affinity="cpu0" ()
        ports_in (%outputPort_1938, %outputPort_1940, %outputPort_1942 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1943, %inputPort_1945 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    %inputPort_1947, %outputPort_1948 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4.out0->split.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1949, %outputPort_1950 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4.out1->twiddles.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1951, %outputPort_1952 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.split.out0->r2cell.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1953, %outputPort_1954 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.split.out1->r2cell.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1955, %outputPort_1956 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.twiddles.out0->r2cell.in2"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1957, %outputPort_1958 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.r2cell.out0->merge.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1959, %outputPort_1960 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.r2cell.out1->merge.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    cal.create_instance @fft__Merge "merge" device_affinity="cpu0" ()
        ports_in (%outputPort_1958, %outputPort_1960 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1931 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__TwiddleGenerator__v__N_dyn "twiddles" (%c1_i32 : i32)
        ports_in (%outputPort_1950 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1955 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Split__v__N_dyn "split" (%c1_i32 : i32)
        ports_in (%outputPort_1948 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1951, %inputPort_1953 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @__fanout_complex_f32__2 "fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4" device_affinity="cpu0" ()
        ports_in (%outputPort_1928 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1947, %inputPort_1949 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Radix2Cell "r2cell" device_affinity="cpu0" ()
        ports_in (%outputPort_1952, %outputPort_1954, %outputPort_1956 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1957, %inputPort_1959 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Merge "merge" device_affinity="cpu0" ()
        ports_in (%outputPort_1930, %outputPort_1932 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1865 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__TwiddleGenerator__v__N_dyn "twiddles" (%c8_i32 : i32)
        ports_in (%outputPort_1836 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1841 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Radix2Cell "r2cell" device_affinity="cpu0" ()
        ports_in (%outputPort_1838, %outputPort_1840, %outputPort_1842 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1843, %inputPort_1845 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    %inputPort_1961, %outputPort_1962 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.fft__Butterfly$spec_9935405952460034831.__fanout_complex_f32__2.6.out0->split.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1963, %outputPort_1964 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.fft__Butterfly$spec_9935405952460034831.__fanout_complex_f32__2.6.out1->twiddles.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1965, %outputPort_1966 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.split.out0->r2cell.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1967, %outputPort_1968 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.split.out1->r2cell.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1969, %outputPort_1970 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.twiddles.out0->r2cell.in2"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1971, %outputPort_1972 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.r2cell.out0->fft__Butterfly$spec_9935405952460034831.fft__Butterfly$spec_1916938481276772234.4.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1973, %outputPort_1974 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.r2cell.out1->fft__Butterfly$spec_9935405952460034831.fft__Butterfly$spec_1916938481276772234.5.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1975, %outputPort_1976 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.fft__Butterfly$spec_9935405952460034831.fft__Butterfly$spec_1916938481276772234.4.out0->merge.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1977, %outputPort_1978 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.fft__Butterfly$spec_9935405952460034831.fft__Butterfly$spec_1916938481276772234.5.out0->merge.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    cal.create_instance @fft__Radix2Cell "r2cell" device_affinity="cpu0" ()
        ports_in (%outputPort_1966, %outputPort_1968, %outputPort_1970 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1971, %inputPort_1973 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Split__v__N_dyn "split" (%c4_i32 : i32)
        ports_in (%outputPort_1962 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1965, %inputPort_1967 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Merge "merge" device_affinity="cpu0" ()
        ports_in (%outputPort_1976, %outputPort_1978 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1847 : !fifo.input_port<complex<f32>>)
    cal.create_instance @__fanout_complex_f32__2 "fft__Butterfly$spec_9935405952460034831.__fanout_complex_f32__2.6" device_affinity="cpu0" ()
        ports_in (%outputPort_1844 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1961, %inputPort_1963 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__TwiddleGenerator__v__N_dyn "twiddles" (%c4_i32 : i32)
        ports_in (%outputPort_1964 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1969 : !fifo.input_port<complex<f32>>)
    %inputPort_1979, %outputPort_1980 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_1916938481276772234.__fanout_complex_f32__2.6.out0->split.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1981, %outputPort_1982 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_1916938481276772234.__fanout_complex_f32__2.6.out1->twiddles.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1983, %outputPort_1984 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.split.out0->r2cell.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1985, %outputPort_1986 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.split.out1->r2cell.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1987, %outputPort_1988 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.twiddles.out0->r2cell.in2"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1989, %outputPort_1990 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.r2cell.out0->fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_15446289516955298258.4.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1991, %outputPort_1992 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.r2cell.out1->fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_15446289516955298258.5.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1993, %outputPort_1994 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_15446289516955298258.4.out0->merge.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1995, %outputPort_1996 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_15446289516955298258.5.out0->merge.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    cal.create_instance @fft__Radix2Cell "r2cell" device_affinity="cpu0" ()
        ports_in (%outputPort_1984, %outputPort_1986, %outputPort_1988 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1989, %inputPort_1991 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__TwiddleGenerator__v__N_dyn "twiddles" (%c2_i32 : i32)
        ports_in (%outputPort_1982 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1987 : !fifo.input_port<complex<f32>>)
    cal.create_instance @__fanout_complex_f32__2 "fft__Butterfly$spec_1916938481276772234.__fanout_complex_f32__2.6" device_affinity="cpu0" ()
        ports_in (%outputPort_1974 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1979, %inputPort_1981 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Split__v__N_dyn "split" (%c2_i32 : i32)
        ports_in (%outputPort_1980 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1983, %inputPort_1985 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    %inputPort_1997, %outputPort_1998 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4.out0->split.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_1999, %outputPort_2000 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4.out1->twiddles.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2001, %outputPort_2002 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.split.out0->r2cell.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2003, %outputPort_2004 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.split.out1->r2cell.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2005, %outputPort_2006 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.twiddles.out0->r2cell.in2"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2007, %outputPort_2008 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.r2cell.out0->merge.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2009, %outputPort_2010 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.r2cell.out1->merge.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    cal.create_instance @fft__Merge "merge" device_affinity="cpu0" ()
        ports_in (%outputPort_2008, %outputPort_2010 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1993 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__TwiddleGenerator__v__N_dyn "twiddles" (%c1_i32 : i32)
        ports_in (%outputPort_2000 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2005 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Split__v__N_dyn "split" (%c1_i32 : i32)
        ports_in (%outputPort_1998 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2001, %inputPort_2003 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @__fanout_complex_f32__2 "fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4" device_affinity="cpu0" ()
        ports_in (%outputPort_1990 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1997, %inputPort_1999 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Radix2Cell "r2cell" device_affinity="cpu0" ()
        ports_in (%outputPort_2002, %outputPort_2004, %outputPort_2006 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2007, %inputPort_2009 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    %inputPort_2011, %outputPort_2012 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4.out0->split.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2013, %outputPort_2014 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4.out1->twiddles.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2015, %outputPort_2016 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.split.out0->r2cell.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2017, %outputPort_2018 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.split.out1->r2cell.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2019, %outputPort_2020 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.twiddles.out0->r2cell.in2"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2021, %outputPort_2022 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.r2cell.out0->merge.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2023, %outputPort_2024 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.r2cell.out1->merge.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    cal.create_instance @fft__Merge "merge" device_affinity="cpu0" ()
        ports_in (%outputPort_2022, %outputPort_2024 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1995 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__TwiddleGenerator__v__N_dyn "twiddles" (%c1_i32 : i32)
        ports_in (%outputPort_2014 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2019 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Split__v__N_dyn "split" (%c1_i32 : i32)
        ports_in (%outputPort_2012 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2015, %inputPort_2017 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @__fanout_complex_f32__2 "fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4" device_affinity="cpu0" ()
        ports_in (%outputPort_1992 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2011, %inputPort_2013 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Radix2Cell "r2cell" device_affinity="cpu0" ()
        ports_in (%outputPort_2016, %outputPort_2018, %outputPort_2020 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2021, %inputPort_2023 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Merge "merge" device_affinity="cpu0" ()
        ports_in (%outputPort_1994, %outputPort_1996 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1977 : !fifo.input_port<complex<f32>>)
    %inputPort_2025, %outputPort_2026 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_1916938481276772234.__fanout_complex_f32__2.6.out0->split.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2027, %outputPort_2028 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_1916938481276772234.__fanout_complex_f32__2.6.out1->twiddles.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2029, %outputPort_2030 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.split.out0->r2cell.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2031, %outputPort_2032 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.split.out1->r2cell.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2033, %outputPort_2034 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.twiddles.out0->r2cell.in2"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2035, %outputPort_2036 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.r2cell.out0->fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_15446289516955298258.4.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2037, %outputPort_2038 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.r2cell.out1->fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_15446289516955298258.5.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2039, %outputPort_2040 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_15446289516955298258.4.out0->merge.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2041, %outputPort_2042 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_15446289516955298258.5.out0->merge.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    cal.create_instance @fft__Radix2Cell "r2cell" device_affinity="cpu0" ()
        ports_in (%outputPort_2030, %outputPort_2032, %outputPort_2034 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2035, %inputPort_2037 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__TwiddleGenerator__v__N_dyn "twiddles" (%c2_i32 : i32)
        ports_in (%outputPort_2028 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2033 : !fifo.input_port<complex<f32>>)
    cal.create_instance @__fanout_complex_f32__2 "fft__Butterfly$spec_1916938481276772234.__fanout_complex_f32__2.6" device_affinity="cpu0" ()
        ports_in (%outputPort_1972 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2025, %inputPort_2027 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Split__v__N_dyn "split" (%c2_i32 : i32)
        ports_in (%outputPort_2026 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2029, %inputPort_2031 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    %inputPort_2043, %outputPort_2044 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4.out0->split.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2045, %outputPort_2046 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4.out1->twiddles.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2047, %outputPort_2048 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.split.out0->r2cell.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2049, %outputPort_2050 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.split.out1->r2cell.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2051, %outputPort_2052 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.twiddles.out0->r2cell.in2"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2053, %outputPort_2054 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.r2cell.out0->merge.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2055, %outputPort_2056 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.r2cell.out1->merge.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    cal.create_instance @fft__Merge "merge" device_affinity="cpu0" ()
        ports_in (%outputPort_2054, %outputPort_2056 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2039 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__TwiddleGenerator__v__N_dyn "twiddles" (%c1_i32 : i32)
        ports_in (%outputPort_2046 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2051 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Split__v__N_dyn "split" (%c1_i32 : i32)
        ports_in (%outputPort_2044 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2047, %inputPort_2049 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @__fanout_complex_f32__2 "fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4" device_affinity="cpu0" ()
        ports_in (%outputPort_2036 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2043, %inputPort_2045 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Radix2Cell "r2cell" device_affinity="cpu0" ()
        ports_in (%outputPort_2048, %outputPort_2050, %outputPort_2052 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2053, %inputPort_2055 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    %inputPort_2057, %outputPort_2058 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4.out0->split.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2059, %outputPort_2060 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4.out1->twiddles.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2061, %outputPort_2062 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.split.out0->r2cell.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2063, %outputPort_2064 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.split.out1->r2cell.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2065, %outputPort_2066 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.twiddles.out0->r2cell.in2"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2067, %outputPort_2068 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.r2cell.out0->merge.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2069, %outputPort_2070 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.r2cell.out1->merge.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    cal.create_instance @fft__Merge "merge" device_affinity="cpu0" ()
        ports_in (%outputPort_2068, %outputPort_2070 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2041 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__TwiddleGenerator__v__N_dyn "twiddles" (%c1_i32 : i32)
        ports_in (%outputPort_2060 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2065 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Split__v__N_dyn "split" (%c1_i32 : i32)
        ports_in (%outputPort_2058 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2061, %inputPort_2063 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @__fanout_complex_f32__2 "fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4" device_affinity="cpu0" ()
        ports_in (%outputPort_2038 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2057, %inputPort_2059 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Radix2Cell "r2cell" device_affinity="cpu0" ()
        ports_in (%outputPort_2062, %outputPort_2064, %outputPort_2066 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2067, %inputPort_2069 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Merge "merge" device_affinity="cpu0" ()
        ports_in (%outputPort_2040, %outputPort_2042 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1975 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Split__v__N_dyn "split" (%c8_i32 : i32)
        ports_in (%outputPort_1834 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1837, %inputPort_1839 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Split__v__N_dyn "split" (%c16_i32 : i32)
        ports_in (%outputPort_1578 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_1581, %inputPort_1583 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Merge "merge" device_affinity="cpu0" ()
        ports_in (%outputPort_56, %outputPort_58 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_37 : !fifo.input_port<complex<f32>>)
    cal.create_instance @__fanout_complex_f32__2 "fft__Butterfly$spec_3319258433404930760.__fanout_complex_f32__2.6" device_affinity="cpu0" ()
        ports_in (%outputPort_18 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_23, %inputPort_25 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    %inputPort_2071, %outputPort_2072 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_11505259727820113654.fft__Butterfly$spec_11505259727820113654.__fanout_complex_f32__2.6.out0->split.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2073, %outputPort_2074 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_11505259727820113654.fft__Butterfly$spec_11505259727820113654.__fanout_complex_f32__2.6.out1->twiddles.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2075, %outputPort_2076 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_11505259727820113654.split.out0->r2cell.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2077, %outputPort_2078 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_11505259727820113654.split.out1->r2cell.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2079, %outputPort_2080 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_11505259727820113654.twiddles.out0->r2cell.in2"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2081, %outputPort_2082 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_11505259727820113654.r2cell.out0->fft__Butterfly$spec_11505259727820113654.fft__Butterfly$spec_17640631431051100303.4.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2083, %outputPort_2084 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_11505259727820113654.r2cell.out1->fft__Butterfly$spec_11505259727820113654.fft__Butterfly$spec_17640631431051100303.5.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2085, %outputPort_2086 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_11505259727820113654.fft__Butterfly$spec_11505259727820113654.fft__Butterfly$spec_17640631431051100303.4.out0->merge.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2087, %outputPort_2088 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_11505259727820113654.fft__Butterfly$spec_11505259727820113654.fft__Butterfly$spec_17640631431051100303.5.out0->merge.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    cal.create_instance @fft__Split__v__N_dyn "split" (%c64_i32 : i32)
        ports_in (%outputPort_2072 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2075, %inputPort_2077 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @__fanout_complex_f32__2 "fft__Butterfly$spec_11505259727820113654.__fanout_complex_f32__2.6" device_affinity="cpu0" ()
        ports_in (%outputPort_36 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2071, %inputPort_2073 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    %inputPort_2089, %outputPort_2090 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_17640631431051100303.fft__Butterfly$spec_17640631431051100303.__fanout_complex_f32__2.6.out0->split.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2091, %outputPort_2092 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_17640631431051100303.fft__Butterfly$spec_17640631431051100303.__fanout_complex_f32__2.6.out1->twiddles.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2093, %outputPort_2094 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_17640631431051100303.split.out0->r2cell.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2095, %outputPort_2096 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_17640631431051100303.split.out1->r2cell.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2097, %outputPort_2098 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_17640631431051100303.twiddles.out0->r2cell.in2"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2099, %outputPort_2100 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_17640631431051100303.r2cell.out0->fft__Butterfly$spec_17640631431051100303.fft__Butterfly$spec_3035977640463470463.4.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2101, %outputPort_2102 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_17640631431051100303.r2cell.out1->fft__Butterfly$spec_17640631431051100303.fft__Butterfly$spec_3035977640463470463.5.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2103, %outputPort_2104 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_17640631431051100303.fft__Butterfly$spec_17640631431051100303.fft__Butterfly$spec_3035977640463470463.4.out0->merge.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2105, %outputPort_2106 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_17640631431051100303.fft__Butterfly$spec_17640631431051100303.fft__Butterfly$spec_3035977640463470463.5.out0->merge.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    cal.create_instance @fft__Merge "merge" device_affinity="cpu0" ()
        ports_in (%outputPort_2104, %outputPort_2106 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2085 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Split__v__N_dyn "split" (%c32_i32 : i32)
        ports_in (%outputPort_2090 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2093, %inputPort_2095 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    %inputPort_2107, %outputPort_2108 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_3035977640463470463.fft__Butterfly$spec_3035977640463470463.__fanout_complex_f32__2.6.out0->split.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2109, %outputPort_2110 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_3035977640463470463.fft__Butterfly$spec_3035977640463470463.__fanout_complex_f32__2.6.out1->twiddles.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2111, %outputPort_2112 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_3035977640463470463.split.out0->r2cell.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2113, %outputPort_2114 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_3035977640463470463.split.out1->r2cell.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2115, %outputPort_2116 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_3035977640463470463.twiddles.out0->r2cell.in2"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2117, %outputPort_2118 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_3035977640463470463.r2cell.out0->fft__Butterfly$spec_3035977640463470463.fft__Butterfly$spec_16755419077516047831.4.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2119, %outputPort_2120 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_3035977640463470463.r2cell.out1->fft__Butterfly$spec_3035977640463470463.fft__Butterfly$spec_16755419077516047831.5.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2121, %outputPort_2122 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_3035977640463470463.fft__Butterfly$spec_3035977640463470463.fft__Butterfly$spec_16755419077516047831.4.out0->merge.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2123, %outputPort_2124 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_3035977640463470463.fft__Butterfly$spec_3035977640463470463.fft__Butterfly$spec_16755419077516047831.5.out0->merge.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    cal.create_instance @fft__TwiddleGenerator__v__N_dyn "twiddles" (%c16_i32 : i32)
        ports_in (%outputPort_2110 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2115 : !fifo.input_port<complex<f32>>)
    %inputPort_2125, %outputPort_2126 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_16755419077516047831.fft__Butterfly$spec_16755419077516047831.__fanout_complex_f32__2.6.out0->split.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2127, %outputPort_2128 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_16755419077516047831.fft__Butterfly$spec_16755419077516047831.__fanout_complex_f32__2.6.out1->twiddles.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2129, %outputPort_2130 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_16755419077516047831.split.out0->r2cell.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2131, %outputPort_2132 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_16755419077516047831.split.out1->r2cell.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2133, %outputPort_2134 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_16755419077516047831.twiddles.out0->r2cell.in2"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2135, %outputPort_2136 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_16755419077516047831.r2cell.out0->fft__Butterfly$spec_16755419077516047831.fft__Butterfly$spec_9935405952460034831.4.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2137, %outputPort_2138 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_16755419077516047831.r2cell.out1->fft__Butterfly$spec_16755419077516047831.fft__Butterfly$spec_9935405952460034831.5.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2139, %outputPort_2140 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_16755419077516047831.fft__Butterfly$spec_16755419077516047831.fft__Butterfly$spec_9935405952460034831.4.out0->merge.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2141, %outputPort_2142 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_16755419077516047831.fft__Butterfly$spec_16755419077516047831.fft__Butterfly$spec_9935405952460034831.5.out0->merge.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    cal.create_instance @__fanout_complex_f32__2 "fft__Butterfly$spec_16755419077516047831.__fanout_complex_f32__2.6" device_affinity="cpu0" ()
        ports_in (%outputPort_2120 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2125, %inputPort_2127 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Merge "merge" device_affinity="cpu0" ()
        ports_in (%outputPort_2140, %outputPort_2142 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2123 : !fifo.input_port<complex<f32>>)
    %inputPort_2143, %outputPort_2144 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.fft__Butterfly$spec_9935405952460034831.__fanout_complex_f32__2.6.out0->split.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2145, %outputPort_2146 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.fft__Butterfly$spec_9935405952460034831.__fanout_complex_f32__2.6.out1->twiddles.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2147, %outputPort_2148 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.split.out0->r2cell.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2149, %outputPort_2150 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.split.out1->r2cell.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2151, %outputPort_2152 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.twiddles.out0->r2cell.in2"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2153, %outputPort_2154 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.r2cell.out0->fft__Butterfly$spec_9935405952460034831.fft__Butterfly$spec_1916938481276772234.4.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2155, %outputPort_2156 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.r2cell.out1->fft__Butterfly$spec_9935405952460034831.fft__Butterfly$spec_1916938481276772234.5.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2157, %outputPort_2158 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.fft__Butterfly$spec_9935405952460034831.fft__Butterfly$spec_1916938481276772234.4.out0->merge.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2159, %outputPort_2160 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.fft__Butterfly$spec_9935405952460034831.fft__Butterfly$spec_1916938481276772234.5.out0->merge.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    cal.create_instance @fft__Radix2Cell "r2cell" device_affinity="cpu0" ()
        ports_in (%outputPort_2148, %outputPort_2150, %outputPort_2152 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2153, %inputPort_2155 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Split__v__N_dyn "split" (%c4_i32 : i32)
        ports_in (%outputPort_2144 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2147, %inputPort_2149 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Merge "merge" device_affinity="cpu0" ()
        ports_in (%outputPort_2158, %outputPort_2160 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2141 : !fifo.input_port<complex<f32>>)
    cal.create_instance @__fanout_complex_f32__2 "fft__Butterfly$spec_9935405952460034831.__fanout_complex_f32__2.6" device_affinity="cpu0" ()
        ports_in (%outputPort_2138 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2143, %inputPort_2145 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__TwiddleGenerator__v__N_dyn "twiddles" (%c4_i32 : i32)
        ports_in (%outputPort_2146 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2151 : !fifo.input_port<complex<f32>>)
    %inputPort_2161, %outputPort_2162 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_1916938481276772234.__fanout_complex_f32__2.6.out0->split.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2163, %outputPort_2164 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_1916938481276772234.__fanout_complex_f32__2.6.out1->twiddles.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2165, %outputPort_2166 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.split.out0->r2cell.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2167, %outputPort_2168 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.split.out1->r2cell.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2169, %outputPort_2170 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.twiddles.out0->r2cell.in2"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2171, %outputPort_2172 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.r2cell.out0->fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_15446289516955298258.4.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2173, %outputPort_2174 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.r2cell.out1->fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_15446289516955298258.5.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2175, %outputPort_2176 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_15446289516955298258.4.out0->merge.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2177, %outputPort_2178 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_15446289516955298258.5.out0->merge.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    cal.create_instance @fft__Radix2Cell "r2cell" device_affinity="cpu0" ()
        ports_in (%outputPort_2166, %outputPort_2168, %outputPort_2170 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2171, %inputPort_2173 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__TwiddleGenerator__v__N_dyn "twiddles" (%c2_i32 : i32)
        ports_in (%outputPort_2164 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2169 : !fifo.input_port<complex<f32>>)
    cal.create_instance @__fanout_complex_f32__2 "fft__Butterfly$spec_1916938481276772234.__fanout_complex_f32__2.6" device_affinity="cpu0" ()
        ports_in (%outputPort_2156 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2161, %inputPort_2163 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Split__v__N_dyn "split" (%c2_i32 : i32)
        ports_in (%outputPort_2162 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2165, %inputPort_2167 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    %inputPort_2179, %outputPort_2180 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4.out0->split.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2181, %outputPort_2182 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4.out1->twiddles.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2183, %outputPort_2184 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.split.out0->r2cell.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2185, %outputPort_2186 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.split.out1->r2cell.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2187, %outputPort_2188 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.twiddles.out0->r2cell.in2"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2189, %outputPort_2190 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.r2cell.out0->merge.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2191, %outputPort_2192 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.r2cell.out1->merge.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    cal.create_instance @fft__Merge "merge" device_affinity="cpu0" ()
        ports_in (%outputPort_2190, %outputPort_2192 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2175 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__TwiddleGenerator__v__N_dyn "twiddles" (%c1_i32 : i32)
        ports_in (%outputPort_2182 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2187 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Split__v__N_dyn "split" (%c1_i32 : i32)
        ports_in (%outputPort_2180 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2183, %inputPort_2185 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @__fanout_complex_f32__2 "fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4" device_affinity="cpu0" ()
        ports_in (%outputPort_2172 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2179, %inputPort_2181 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Radix2Cell "r2cell" device_affinity="cpu0" ()
        ports_in (%outputPort_2184, %outputPort_2186, %outputPort_2188 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2189, %inputPort_2191 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    %inputPort_2193, %outputPort_2194 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4.out0->split.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2195, %outputPort_2196 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4.out1->twiddles.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2197, %outputPort_2198 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.split.out0->r2cell.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2199, %outputPort_2200 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.split.out1->r2cell.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2201, %outputPort_2202 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.twiddles.out0->r2cell.in2"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2203, %outputPort_2204 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.r2cell.out0->merge.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2205, %outputPort_2206 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.r2cell.out1->merge.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    cal.create_instance @fft__Merge "merge" device_affinity="cpu0" ()
        ports_in (%outputPort_2204, %outputPort_2206 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2177 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__TwiddleGenerator__v__N_dyn "twiddles" (%c1_i32 : i32)
        ports_in (%outputPort_2196 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2201 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Split__v__N_dyn "split" (%c1_i32 : i32)
        ports_in (%outputPort_2194 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2197, %inputPort_2199 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @__fanout_complex_f32__2 "fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4" device_affinity="cpu0" ()
        ports_in (%outputPort_2174 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2193, %inputPort_2195 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Radix2Cell "r2cell" device_affinity="cpu0" ()
        ports_in (%outputPort_2198, %outputPort_2200, %outputPort_2202 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2203, %inputPort_2205 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Merge "merge" device_affinity="cpu0" ()
        ports_in (%outputPort_2176, %outputPort_2178 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2159 : !fifo.input_port<complex<f32>>)
    %inputPort_2207, %outputPort_2208 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_1916938481276772234.__fanout_complex_f32__2.6.out0->split.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2209, %outputPort_2210 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_1916938481276772234.__fanout_complex_f32__2.6.out1->twiddles.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2211, %outputPort_2212 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.split.out0->r2cell.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2213, %outputPort_2214 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.split.out1->r2cell.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2215, %outputPort_2216 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.twiddles.out0->r2cell.in2"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2217, %outputPort_2218 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.r2cell.out0->fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_15446289516955298258.4.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2219, %outputPort_2220 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.r2cell.out1->fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_15446289516955298258.5.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2221, %outputPort_2222 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_15446289516955298258.4.out0->merge.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2223, %outputPort_2224 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_15446289516955298258.5.out0->merge.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    cal.create_instance @fft__Radix2Cell "r2cell" device_affinity="cpu0" ()
        ports_in (%outputPort_2212, %outputPort_2214, %outputPort_2216 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2217, %inputPort_2219 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__TwiddleGenerator__v__N_dyn "twiddles" (%c2_i32 : i32)
        ports_in (%outputPort_2210 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2215 : !fifo.input_port<complex<f32>>)
    cal.create_instance @__fanout_complex_f32__2 "fft__Butterfly$spec_1916938481276772234.__fanout_complex_f32__2.6" device_affinity="cpu0" ()
        ports_in (%outputPort_2154 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2207, %inputPort_2209 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Split__v__N_dyn "split" (%c2_i32 : i32)
        ports_in (%outputPort_2208 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2211, %inputPort_2213 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    %inputPort_2225, %outputPort_2226 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4.out0->split.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2227, %outputPort_2228 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4.out1->twiddles.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2229, %outputPort_2230 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.split.out0->r2cell.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2231, %outputPort_2232 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.split.out1->r2cell.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2233, %outputPort_2234 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.twiddles.out0->r2cell.in2"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2235, %outputPort_2236 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.r2cell.out0->merge.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2237, %outputPort_2238 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.r2cell.out1->merge.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    cal.create_instance @fft__Merge "merge" device_affinity="cpu0" ()
        ports_in (%outputPort_2236, %outputPort_2238 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2221 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__TwiddleGenerator__v__N_dyn "twiddles" (%c1_i32 : i32)
        ports_in (%outputPort_2228 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2233 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Split__v__N_dyn "split" (%c1_i32 : i32)
        ports_in (%outputPort_2226 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2229, %inputPort_2231 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @__fanout_complex_f32__2 "fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4" device_affinity="cpu0" ()
        ports_in (%outputPort_2218 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2225, %inputPort_2227 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Radix2Cell "r2cell" device_affinity="cpu0" ()
        ports_in (%outputPort_2230, %outputPort_2232, %outputPort_2234 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2235, %inputPort_2237 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    %inputPort_2239, %outputPort_2240 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4.out0->split.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2241, %outputPort_2242 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4.out1->twiddles.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2243, %outputPort_2244 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.split.out0->r2cell.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2245, %outputPort_2246 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.split.out1->r2cell.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2247, %outputPort_2248 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.twiddles.out0->r2cell.in2"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2249, %outputPort_2250 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.r2cell.out0->merge.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2251, %outputPort_2252 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.r2cell.out1->merge.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    cal.create_instance @fft__Merge "merge" device_affinity="cpu0" ()
        ports_in (%outputPort_2250, %outputPort_2252 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2223 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__TwiddleGenerator__v__N_dyn "twiddles" (%c1_i32 : i32)
        ports_in (%outputPort_2242 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2247 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Split__v__N_dyn "split" (%c1_i32 : i32)
        ports_in (%outputPort_2240 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2243, %inputPort_2245 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @__fanout_complex_f32__2 "fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4" device_affinity="cpu0" ()
        ports_in (%outputPort_2220 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2239, %inputPort_2241 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Radix2Cell "r2cell" device_affinity="cpu0" ()
        ports_in (%outputPort_2244, %outputPort_2246, %outputPort_2248 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2249, %inputPort_2251 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Merge "merge" device_affinity="cpu0" ()
        ports_in (%outputPort_2222, %outputPort_2224 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2157 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__TwiddleGenerator__v__N_dyn "twiddles" (%c8_i32 : i32)
        ports_in (%outputPort_2128 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2133 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Radix2Cell "r2cell" device_affinity="cpu0" ()
        ports_in (%outputPort_2130, %outputPort_2132, %outputPort_2134 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2135, %inputPort_2137 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    %inputPort_2253, %outputPort_2254 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.fft__Butterfly$spec_9935405952460034831.__fanout_complex_f32__2.6.out0->split.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2255, %outputPort_2256 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.fft__Butterfly$spec_9935405952460034831.__fanout_complex_f32__2.6.out1->twiddles.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2257, %outputPort_2258 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.split.out0->r2cell.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2259, %outputPort_2260 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.split.out1->r2cell.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2261, %outputPort_2262 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.twiddles.out0->r2cell.in2"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2263, %outputPort_2264 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.r2cell.out0->fft__Butterfly$spec_9935405952460034831.fft__Butterfly$spec_1916938481276772234.4.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2265, %outputPort_2266 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.r2cell.out1->fft__Butterfly$spec_9935405952460034831.fft__Butterfly$spec_1916938481276772234.5.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2267, %outputPort_2268 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.fft__Butterfly$spec_9935405952460034831.fft__Butterfly$spec_1916938481276772234.4.out0->merge.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2269, %outputPort_2270 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.fft__Butterfly$spec_9935405952460034831.fft__Butterfly$spec_1916938481276772234.5.out0->merge.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    cal.create_instance @fft__Radix2Cell "r2cell" device_affinity="cpu0" ()
        ports_in (%outputPort_2258, %outputPort_2260, %outputPort_2262 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2263, %inputPort_2265 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Split__v__N_dyn "split" (%c4_i32 : i32)
        ports_in (%outputPort_2254 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2257, %inputPort_2259 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Merge "merge" device_affinity="cpu0" ()
        ports_in (%outputPort_2268, %outputPort_2270 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2139 : !fifo.input_port<complex<f32>>)
    cal.create_instance @__fanout_complex_f32__2 "fft__Butterfly$spec_9935405952460034831.__fanout_complex_f32__2.6" device_affinity="cpu0" ()
        ports_in (%outputPort_2136 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2253, %inputPort_2255 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__TwiddleGenerator__v__N_dyn "twiddles" (%c4_i32 : i32)
        ports_in (%outputPort_2256 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2261 : !fifo.input_port<complex<f32>>)
    %inputPort_2271, %outputPort_2272 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_1916938481276772234.__fanout_complex_f32__2.6.out0->split.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2273, %outputPort_2274 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_1916938481276772234.__fanout_complex_f32__2.6.out1->twiddles.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2275, %outputPort_2276 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.split.out0->r2cell.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2277, %outputPort_2278 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.split.out1->r2cell.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2279, %outputPort_2280 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.twiddles.out0->r2cell.in2"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2281, %outputPort_2282 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.r2cell.out0->fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_15446289516955298258.4.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2283, %outputPort_2284 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.r2cell.out1->fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_15446289516955298258.5.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2285, %outputPort_2286 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_15446289516955298258.4.out0->merge.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2287, %outputPort_2288 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_15446289516955298258.5.out0->merge.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    cal.create_instance @fft__Radix2Cell "r2cell" device_affinity="cpu0" ()
        ports_in (%outputPort_2276, %outputPort_2278, %outputPort_2280 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2281, %inputPort_2283 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__TwiddleGenerator__v__N_dyn "twiddles" (%c2_i32 : i32)
        ports_in (%outputPort_2274 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2279 : !fifo.input_port<complex<f32>>)
    cal.create_instance @__fanout_complex_f32__2 "fft__Butterfly$spec_1916938481276772234.__fanout_complex_f32__2.6" device_affinity="cpu0" ()
        ports_in (%outputPort_2266 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2271, %inputPort_2273 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Split__v__N_dyn "split" (%c2_i32 : i32)
        ports_in (%outputPort_2272 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2275, %inputPort_2277 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    %inputPort_2289, %outputPort_2290 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4.out0->split.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2291, %outputPort_2292 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4.out1->twiddles.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2293, %outputPort_2294 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.split.out0->r2cell.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2295, %outputPort_2296 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.split.out1->r2cell.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2297, %outputPort_2298 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.twiddles.out0->r2cell.in2"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2299, %outputPort_2300 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.r2cell.out0->merge.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2301, %outputPort_2302 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.r2cell.out1->merge.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    cal.create_instance @fft__Merge "merge" device_affinity="cpu0" ()
        ports_in (%outputPort_2300, %outputPort_2302 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2285 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__TwiddleGenerator__v__N_dyn "twiddles" (%c1_i32 : i32)
        ports_in (%outputPort_2292 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2297 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Split__v__N_dyn "split" (%c1_i32 : i32)
        ports_in (%outputPort_2290 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2293, %inputPort_2295 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @__fanout_complex_f32__2 "fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4" device_affinity="cpu0" ()
        ports_in (%outputPort_2282 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2289, %inputPort_2291 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Radix2Cell "r2cell" device_affinity="cpu0" ()
        ports_in (%outputPort_2294, %outputPort_2296, %outputPort_2298 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2299, %inputPort_2301 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    %inputPort_2303, %outputPort_2304 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4.out0->split.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2305, %outputPort_2306 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4.out1->twiddles.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2307, %outputPort_2308 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.split.out0->r2cell.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2309, %outputPort_2310 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.split.out1->r2cell.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2311, %outputPort_2312 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.twiddles.out0->r2cell.in2"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2313, %outputPort_2314 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.r2cell.out0->merge.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2315, %outputPort_2316 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.r2cell.out1->merge.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    cal.create_instance @fft__Merge "merge" device_affinity="cpu0" ()
        ports_in (%outputPort_2314, %outputPort_2316 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2287 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__TwiddleGenerator__v__N_dyn "twiddles" (%c1_i32 : i32)
        ports_in (%outputPort_2306 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2311 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Split__v__N_dyn "split" (%c1_i32 : i32)
        ports_in (%outputPort_2304 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2307, %inputPort_2309 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @__fanout_complex_f32__2 "fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4" device_affinity="cpu0" ()
        ports_in (%outputPort_2284 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2303, %inputPort_2305 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Radix2Cell "r2cell" device_affinity="cpu0" ()
        ports_in (%outputPort_2308, %outputPort_2310, %outputPort_2312 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2313, %inputPort_2315 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Merge "merge" device_affinity="cpu0" ()
        ports_in (%outputPort_2286, %outputPort_2288 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2269 : !fifo.input_port<complex<f32>>)
    %inputPort_2317, %outputPort_2318 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_1916938481276772234.__fanout_complex_f32__2.6.out0->split.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2319, %outputPort_2320 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_1916938481276772234.__fanout_complex_f32__2.6.out1->twiddles.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2321, %outputPort_2322 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.split.out0->r2cell.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2323, %outputPort_2324 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.split.out1->r2cell.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2325, %outputPort_2326 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.twiddles.out0->r2cell.in2"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2327, %outputPort_2328 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.r2cell.out0->fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_15446289516955298258.4.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2329, %outputPort_2330 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.r2cell.out1->fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_15446289516955298258.5.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2331, %outputPort_2332 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_15446289516955298258.4.out0->merge.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2333, %outputPort_2334 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_15446289516955298258.5.out0->merge.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    cal.create_instance @fft__Radix2Cell "r2cell" device_affinity="cpu0" ()
        ports_in (%outputPort_2322, %outputPort_2324, %outputPort_2326 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2327, %inputPort_2329 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__TwiddleGenerator__v__N_dyn "twiddles" (%c2_i32 : i32)
        ports_in (%outputPort_2320 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2325 : !fifo.input_port<complex<f32>>)
    cal.create_instance @__fanout_complex_f32__2 "fft__Butterfly$spec_1916938481276772234.__fanout_complex_f32__2.6" device_affinity="cpu0" ()
        ports_in (%outputPort_2264 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2317, %inputPort_2319 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Split__v__N_dyn "split" (%c2_i32 : i32)
        ports_in (%outputPort_2318 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2321, %inputPort_2323 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    %inputPort_2335, %outputPort_2336 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4.out0->split.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2337, %outputPort_2338 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4.out1->twiddles.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2339, %outputPort_2340 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.split.out0->r2cell.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2341, %outputPort_2342 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.split.out1->r2cell.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2343, %outputPort_2344 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.twiddles.out0->r2cell.in2"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2345, %outputPort_2346 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.r2cell.out0->merge.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2347, %outputPort_2348 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.r2cell.out1->merge.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    cal.create_instance @fft__Merge "merge" device_affinity="cpu0" ()
        ports_in (%outputPort_2346, %outputPort_2348 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2331 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__TwiddleGenerator__v__N_dyn "twiddles" (%c1_i32 : i32)
        ports_in (%outputPort_2338 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2343 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Split__v__N_dyn "split" (%c1_i32 : i32)
        ports_in (%outputPort_2336 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2339, %inputPort_2341 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @__fanout_complex_f32__2 "fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4" device_affinity="cpu0" ()
        ports_in (%outputPort_2328 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2335, %inputPort_2337 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Radix2Cell "r2cell" device_affinity="cpu0" ()
        ports_in (%outputPort_2340, %outputPort_2342, %outputPort_2344 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2345, %inputPort_2347 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    %inputPort_2349, %outputPort_2350 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4.out0->split.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2351, %outputPort_2352 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4.out1->twiddles.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2353, %outputPort_2354 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.split.out0->r2cell.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2355, %outputPort_2356 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.split.out1->r2cell.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2357, %outputPort_2358 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.twiddles.out0->r2cell.in2"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2359, %outputPort_2360 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.r2cell.out0->merge.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2361, %outputPort_2362 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.r2cell.out1->merge.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    cal.create_instance @fft__Merge "merge" device_affinity="cpu0" ()
        ports_in (%outputPort_2360, %outputPort_2362 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2333 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__TwiddleGenerator__v__N_dyn "twiddles" (%c1_i32 : i32)
        ports_in (%outputPort_2352 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2357 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Split__v__N_dyn "split" (%c1_i32 : i32)
        ports_in (%outputPort_2350 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2353, %inputPort_2355 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @__fanout_complex_f32__2 "fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4" device_affinity="cpu0" ()
        ports_in (%outputPort_2330 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2349, %inputPort_2351 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Radix2Cell "r2cell" device_affinity="cpu0" ()
        ports_in (%outputPort_2354, %outputPort_2356, %outputPort_2358 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2359, %inputPort_2361 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Merge "merge" device_affinity="cpu0" ()
        ports_in (%outputPort_2332, %outputPort_2334 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2267 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Split__v__N_dyn "split" (%c8_i32 : i32)
        ports_in (%outputPort_2126 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2129, %inputPort_2131 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Radix2Cell "r2cell" device_affinity="cpu0" ()
        ports_in (%outputPort_2112, %outputPort_2114, %outputPort_2116 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2117, %inputPort_2119 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Merge "merge" device_affinity="cpu0" ()
        ports_in (%outputPort_2122, %outputPort_2124 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2103 : !fifo.input_port<complex<f32>>)
    cal.create_instance @__fanout_complex_f32__2 "fft__Butterfly$spec_3035977640463470463.__fanout_complex_f32__2.6" device_affinity="cpu0" ()
        ports_in (%outputPort_2100 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2107, %inputPort_2109 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    %inputPort_2363, %outputPort_2364 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_16755419077516047831.fft__Butterfly$spec_16755419077516047831.__fanout_complex_f32__2.6.out0->split.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2365, %outputPort_2366 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_16755419077516047831.fft__Butterfly$spec_16755419077516047831.__fanout_complex_f32__2.6.out1->twiddles.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2367, %outputPort_2368 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_16755419077516047831.split.out0->r2cell.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2369, %outputPort_2370 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_16755419077516047831.split.out1->r2cell.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2371, %outputPort_2372 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_16755419077516047831.twiddles.out0->r2cell.in2"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2373, %outputPort_2374 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_16755419077516047831.r2cell.out0->fft__Butterfly$spec_16755419077516047831.fft__Butterfly$spec_9935405952460034831.4.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2375, %outputPort_2376 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_16755419077516047831.r2cell.out1->fft__Butterfly$spec_16755419077516047831.fft__Butterfly$spec_9935405952460034831.5.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2377, %outputPort_2378 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_16755419077516047831.fft__Butterfly$spec_16755419077516047831.fft__Butterfly$spec_9935405952460034831.4.out0->merge.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2379, %outputPort_2380 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_16755419077516047831.fft__Butterfly$spec_16755419077516047831.fft__Butterfly$spec_9935405952460034831.5.out0->merge.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    cal.create_instance @__fanout_complex_f32__2 "fft__Butterfly$spec_16755419077516047831.__fanout_complex_f32__2.6" device_affinity="cpu0" ()
        ports_in (%outputPort_2118 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2363, %inputPort_2365 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Merge "merge" device_affinity="cpu0" ()
        ports_in (%outputPort_2378, %outputPort_2380 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2121 : !fifo.input_port<complex<f32>>)
    %inputPort_2381, %outputPort_2382 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.fft__Butterfly$spec_9935405952460034831.__fanout_complex_f32__2.6.out0->split.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2383, %outputPort_2384 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.fft__Butterfly$spec_9935405952460034831.__fanout_complex_f32__2.6.out1->twiddles.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2385, %outputPort_2386 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.split.out0->r2cell.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2387, %outputPort_2388 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.split.out1->r2cell.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2389, %outputPort_2390 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.twiddles.out0->r2cell.in2"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2391, %outputPort_2392 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.r2cell.out0->fft__Butterfly$spec_9935405952460034831.fft__Butterfly$spec_1916938481276772234.4.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2393, %outputPort_2394 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.r2cell.out1->fft__Butterfly$spec_9935405952460034831.fft__Butterfly$spec_1916938481276772234.5.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2395, %outputPort_2396 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.fft__Butterfly$spec_9935405952460034831.fft__Butterfly$spec_1916938481276772234.4.out0->merge.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2397, %outputPort_2398 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.fft__Butterfly$spec_9935405952460034831.fft__Butterfly$spec_1916938481276772234.5.out0->merge.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    cal.create_instance @fft__Radix2Cell "r2cell" device_affinity="cpu0" ()
        ports_in (%outputPort_2386, %outputPort_2388, %outputPort_2390 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2391, %inputPort_2393 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Split__v__N_dyn "split" (%c4_i32 : i32)
        ports_in (%outputPort_2382 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2385, %inputPort_2387 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Merge "merge" device_affinity="cpu0" ()
        ports_in (%outputPort_2396, %outputPort_2398 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2379 : !fifo.input_port<complex<f32>>)
    cal.create_instance @__fanout_complex_f32__2 "fft__Butterfly$spec_9935405952460034831.__fanout_complex_f32__2.6" device_affinity="cpu0" ()
        ports_in (%outputPort_2376 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2381, %inputPort_2383 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__TwiddleGenerator__v__N_dyn "twiddles" (%c4_i32 : i32)
        ports_in (%outputPort_2384 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2389 : !fifo.input_port<complex<f32>>)
    %inputPort_2399, %outputPort_2400 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_1916938481276772234.__fanout_complex_f32__2.6.out0->split.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2401, %outputPort_2402 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_1916938481276772234.__fanout_complex_f32__2.6.out1->twiddles.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2403, %outputPort_2404 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.split.out0->r2cell.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2405, %outputPort_2406 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.split.out1->r2cell.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2407, %outputPort_2408 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.twiddles.out0->r2cell.in2"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2409, %outputPort_2410 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.r2cell.out0->fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_15446289516955298258.4.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2411, %outputPort_2412 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.r2cell.out1->fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_15446289516955298258.5.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2413, %outputPort_2414 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_15446289516955298258.4.out0->merge.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2415, %outputPort_2416 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_15446289516955298258.5.out0->merge.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    cal.create_instance @fft__Radix2Cell "r2cell" device_affinity="cpu0" ()
        ports_in (%outputPort_2404, %outputPort_2406, %outputPort_2408 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2409, %inputPort_2411 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__TwiddleGenerator__v__N_dyn "twiddles" (%c2_i32 : i32)
        ports_in (%outputPort_2402 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2407 : !fifo.input_port<complex<f32>>)
    cal.create_instance @__fanout_complex_f32__2 "fft__Butterfly$spec_1916938481276772234.__fanout_complex_f32__2.6" device_affinity="cpu0" ()
        ports_in (%outputPort_2394 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2399, %inputPort_2401 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Split__v__N_dyn "split" (%c2_i32 : i32)
        ports_in (%outputPort_2400 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2403, %inputPort_2405 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    %inputPort_2417, %outputPort_2418 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4.out0->split.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2419, %outputPort_2420 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4.out1->twiddles.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2421, %outputPort_2422 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.split.out0->r2cell.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2423, %outputPort_2424 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.split.out1->r2cell.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2425, %outputPort_2426 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.twiddles.out0->r2cell.in2"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2427, %outputPort_2428 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.r2cell.out0->merge.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2429, %outputPort_2430 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.r2cell.out1->merge.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    cal.create_instance @fft__Merge "merge" device_affinity="cpu0" ()
        ports_in (%outputPort_2428, %outputPort_2430 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2413 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__TwiddleGenerator__v__N_dyn "twiddles" (%c1_i32 : i32)
        ports_in (%outputPort_2420 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2425 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Split__v__N_dyn "split" (%c1_i32 : i32)
        ports_in (%outputPort_2418 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2421, %inputPort_2423 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @__fanout_complex_f32__2 "fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4" device_affinity="cpu0" ()
        ports_in (%outputPort_2410 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2417, %inputPort_2419 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Radix2Cell "r2cell" device_affinity="cpu0" ()
        ports_in (%outputPort_2422, %outputPort_2424, %outputPort_2426 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2427, %inputPort_2429 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    %inputPort_2431, %outputPort_2432 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4.out0->split.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2433, %outputPort_2434 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4.out1->twiddles.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2435, %outputPort_2436 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.split.out0->r2cell.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2437, %outputPort_2438 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.split.out1->r2cell.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2439, %outputPort_2440 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.twiddles.out0->r2cell.in2"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2441, %outputPort_2442 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.r2cell.out0->merge.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2443, %outputPort_2444 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.r2cell.out1->merge.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    cal.create_instance @fft__Merge "merge" device_affinity="cpu0" ()
        ports_in (%outputPort_2442, %outputPort_2444 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2415 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__TwiddleGenerator__v__N_dyn "twiddles" (%c1_i32 : i32)
        ports_in (%outputPort_2434 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2439 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Split__v__N_dyn "split" (%c1_i32 : i32)
        ports_in (%outputPort_2432 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2435, %inputPort_2437 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @__fanout_complex_f32__2 "fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4" device_affinity="cpu0" ()
        ports_in (%outputPort_2412 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2431, %inputPort_2433 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Radix2Cell "r2cell" device_affinity="cpu0" ()
        ports_in (%outputPort_2436, %outputPort_2438, %outputPort_2440 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2441, %inputPort_2443 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Merge "merge" device_affinity="cpu0" ()
        ports_in (%outputPort_2414, %outputPort_2416 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2397 : !fifo.input_port<complex<f32>>)
    %inputPort_2445, %outputPort_2446 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_1916938481276772234.__fanout_complex_f32__2.6.out0->split.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2447, %outputPort_2448 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_1916938481276772234.__fanout_complex_f32__2.6.out1->twiddles.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2449, %outputPort_2450 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.split.out0->r2cell.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2451, %outputPort_2452 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.split.out1->r2cell.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2453, %outputPort_2454 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.twiddles.out0->r2cell.in2"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2455, %outputPort_2456 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.r2cell.out0->fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_15446289516955298258.4.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2457, %outputPort_2458 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.r2cell.out1->fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_15446289516955298258.5.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2459, %outputPort_2460 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_15446289516955298258.4.out0->merge.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2461, %outputPort_2462 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_15446289516955298258.5.out0->merge.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    cal.create_instance @fft__Radix2Cell "r2cell" device_affinity="cpu0" ()
        ports_in (%outputPort_2450, %outputPort_2452, %outputPort_2454 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2455, %inputPort_2457 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__TwiddleGenerator__v__N_dyn "twiddles" (%c2_i32 : i32)
        ports_in (%outputPort_2448 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2453 : !fifo.input_port<complex<f32>>)
    cal.create_instance @__fanout_complex_f32__2 "fft__Butterfly$spec_1916938481276772234.__fanout_complex_f32__2.6" device_affinity="cpu0" ()
        ports_in (%outputPort_2392 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2445, %inputPort_2447 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Split__v__N_dyn "split" (%c2_i32 : i32)
        ports_in (%outputPort_2446 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2449, %inputPort_2451 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    %inputPort_2463, %outputPort_2464 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4.out0->split.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2465, %outputPort_2466 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4.out1->twiddles.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2467, %outputPort_2468 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.split.out0->r2cell.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2469, %outputPort_2470 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.split.out1->r2cell.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2471, %outputPort_2472 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.twiddles.out0->r2cell.in2"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2473, %outputPort_2474 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.r2cell.out0->merge.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2475, %outputPort_2476 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.r2cell.out1->merge.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    cal.create_instance @fft__Merge "merge" device_affinity="cpu0" ()
        ports_in (%outputPort_2474, %outputPort_2476 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2459 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__TwiddleGenerator__v__N_dyn "twiddles" (%c1_i32 : i32)
        ports_in (%outputPort_2466 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2471 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Split__v__N_dyn "split" (%c1_i32 : i32)
        ports_in (%outputPort_2464 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2467, %inputPort_2469 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @__fanout_complex_f32__2 "fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4" device_affinity="cpu0" ()
        ports_in (%outputPort_2456 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2463, %inputPort_2465 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Radix2Cell "r2cell" device_affinity="cpu0" ()
        ports_in (%outputPort_2468, %outputPort_2470, %outputPort_2472 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2473, %inputPort_2475 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    %inputPort_2477, %outputPort_2478 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4.out0->split.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2479, %outputPort_2480 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4.out1->twiddles.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2481, %outputPort_2482 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.split.out0->r2cell.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2483, %outputPort_2484 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.split.out1->r2cell.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2485, %outputPort_2486 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.twiddles.out0->r2cell.in2"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2487, %outputPort_2488 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.r2cell.out0->merge.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2489, %outputPort_2490 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.r2cell.out1->merge.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    cal.create_instance @fft__Merge "merge" device_affinity="cpu0" ()
        ports_in (%outputPort_2488, %outputPort_2490 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2461 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__TwiddleGenerator__v__N_dyn "twiddles" (%c1_i32 : i32)
        ports_in (%outputPort_2480 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2485 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Split__v__N_dyn "split" (%c1_i32 : i32)
        ports_in (%outputPort_2478 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2481, %inputPort_2483 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @__fanout_complex_f32__2 "fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4" device_affinity="cpu0" ()
        ports_in (%outputPort_2458 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2477, %inputPort_2479 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Radix2Cell "r2cell" device_affinity="cpu0" ()
        ports_in (%outputPort_2482, %outputPort_2484, %outputPort_2486 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2487, %inputPort_2489 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Merge "merge" device_affinity="cpu0" ()
        ports_in (%outputPort_2460, %outputPort_2462 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2395 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__TwiddleGenerator__v__N_dyn "twiddles" (%c8_i32 : i32)
        ports_in (%outputPort_2366 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2371 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Radix2Cell "r2cell" device_affinity="cpu0" ()
        ports_in (%outputPort_2368, %outputPort_2370, %outputPort_2372 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2373, %inputPort_2375 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    %inputPort_2491, %outputPort_2492 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.fft__Butterfly$spec_9935405952460034831.__fanout_complex_f32__2.6.out0->split.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2493, %outputPort_2494 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.fft__Butterfly$spec_9935405952460034831.__fanout_complex_f32__2.6.out1->twiddles.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2495, %outputPort_2496 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.split.out0->r2cell.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2497, %outputPort_2498 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.split.out1->r2cell.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2499, %outputPort_2500 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.twiddles.out0->r2cell.in2"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2501, %outputPort_2502 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.r2cell.out0->fft__Butterfly$spec_9935405952460034831.fft__Butterfly$spec_1916938481276772234.4.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2503, %outputPort_2504 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.r2cell.out1->fft__Butterfly$spec_9935405952460034831.fft__Butterfly$spec_1916938481276772234.5.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2505, %outputPort_2506 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.fft__Butterfly$spec_9935405952460034831.fft__Butterfly$spec_1916938481276772234.4.out0->merge.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2507, %outputPort_2508 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.fft__Butterfly$spec_9935405952460034831.fft__Butterfly$spec_1916938481276772234.5.out0->merge.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    cal.create_instance @fft__Radix2Cell "r2cell" device_affinity="cpu0" ()
        ports_in (%outputPort_2496, %outputPort_2498, %outputPort_2500 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2501, %inputPort_2503 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Split__v__N_dyn "split" (%c4_i32 : i32)
        ports_in (%outputPort_2492 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2495, %inputPort_2497 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Merge "merge" device_affinity="cpu0" ()
        ports_in (%outputPort_2506, %outputPort_2508 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2377 : !fifo.input_port<complex<f32>>)
    cal.create_instance @__fanout_complex_f32__2 "fft__Butterfly$spec_9935405952460034831.__fanout_complex_f32__2.6" device_affinity="cpu0" ()
        ports_in (%outputPort_2374 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2491, %inputPort_2493 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__TwiddleGenerator__v__N_dyn "twiddles" (%c4_i32 : i32)
        ports_in (%outputPort_2494 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2499 : !fifo.input_port<complex<f32>>)
    %inputPort_2509, %outputPort_2510 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_1916938481276772234.__fanout_complex_f32__2.6.out0->split.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2511, %outputPort_2512 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_1916938481276772234.__fanout_complex_f32__2.6.out1->twiddles.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2513, %outputPort_2514 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.split.out0->r2cell.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2515, %outputPort_2516 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.split.out1->r2cell.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2517, %outputPort_2518 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.twiddles.out0->r2cell.in2"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2519, %outputPort_2520 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.r2cell.out0->fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_15446289516955298258.4.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2521, %outputPort_2522 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.r2cell.out1->fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_15446289516955298258.5.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2523, %outputPort_2524 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_15446289516955298258.4.out0->merge.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2525, %outputPort_2526 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_15446289516955298258.5.out0->merge.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    cal.create_instance @fft__Radix2Cell "r2cell" device_affinity="cpu0" ()
        ports_in (%outputPort_2514, %outputPort_2516, %outputPort_2518 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2519, %inputPort_2521 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__TwiddleGenerator__v__N_dyn "twiddles" (%c2_i32 : i32)
        ports_in (%outputPort_2512 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2517 : !fifo.input_port<complex<f32>>)
    cal.create_instance @__fanout_complex_f32__2 "fft__Butterfly$spec_1916938481276772234.__fanout_complex_f32__2.6" device_affinity="cpu0" ()
        ports_in (%outputPort_2504 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2509, %inputPort_2511 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Split__v__N_dyn "split" (%c2_i32 : i32)
        ports_in (%outputPort_2510 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2513, %inputPort_2515 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    %inputPort_2527, %outputPort_2528 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4.out0->split.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2529, %outputPort_2530 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4.out1->twiddles.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2531, %outputPort_2532 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.split.out0->r2cell.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2533, %outputPort_2534 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.split.out1->r2cell.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2535, %outputPort_2536 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.twiddles.out0->r2cell.in2"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2537, %outputPort_2538 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.r2cell.out0->merge.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2539, %outputPort_2540 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.r2cell.out1->merge.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    cal.create_instance @fft__Merge "merge" device_affinity="cpu0" ()
        ports_in (%outputPort_2538, %outputPort_2540 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2523 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__TwiddleGenerator__v__N_dyn "twiddles" (%c1_i32 : i32)
        ports_in (%outputPort_2530 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2535 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Split__v__N_dyn "split" (%c1_i32 : i32)
        ports_in (%outputPort_2528 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2531, %inputPort_2533 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @__fanout_complex_f32__2 "fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4" device_affinity="cpu0" ()
        ports_in (%outputPort_2520 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2527, %inputPort_2529 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Radix2Cell "r2cell" device_affinity="cpu0" ()
        ports_in (%outputPort_2532, %outputPort_2534, %outputPort_2536 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2537, %inputPort_2539 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    %inputPort_2541, %outputPort_2542 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4.out0->split.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2543, %outputPort_2544 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4.out1->twiddles.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2545, %outputPort_2546 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.split.out0->r2cell.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2547, %outputPort_2548 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.split.out1->r2cell.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2549, %outputPort_2550 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.twiddles.out0->r2cell.in2"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2551, %outputPort_2552 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.r2cell.out0->merge.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2553, %outputPort_2554 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.r2cell.out1->merge.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    cal.create_instance @fft__Merge "merge" device_affinity="cpu0" ()
        ports_in (%outputPort_2552, %outputPort_2554 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2525 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__TwiddleGenerator__v__N_dyn "twiddles" (%c1_i32 : i32)
        ports_in (%outputPort_2544 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2549 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Split__v__N_dyn "split" (%c1_i32 : i32)
        ports_in (%outputPort_2542 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2545, %inputPort_2547 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @__fanout_complex_f32__2 "fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4" device_affinity="cpu0" ()
        ports_in (%outputPort_2522 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2541, %inputPort_2543 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Radix2Cell "r2cell" device_affinity="cpu0" ()
        ports_in (%outputPort_2546, %outputPort_2548, %outputPort_2550 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2551, %inputPort_2553 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Merge "merge" device_affinity="cpu0" ()
        ports_in (%outputPort_2524, %outputPort_2526 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2507 : !fifo.input_port<complex<f32>>)
    %inputPort_2555, %outputPort_2556 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_1916938481276772234.__fanout_complex_f32__2.6.out0->split.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2557, %outputPort_2558 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_1916938481276772234.__fanout_complex_f32__2.6.out1->twiddles.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2559, %outputPort_2560 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.split.out0->r2cell.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2561, %outputPort_2562 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.split.out1->r2cell.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2563, %outputPort_2564 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.twiddles.out0->r2cell.in2"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2565, %outputPort_2566 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.r2cell.out0->fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_15446289516955298258.4.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2567, %outputPort_2568 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.r2cell.out1->fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_15446289516955298258.5.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2569, %outputPort_2570 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_15446289516955298258.4.out0->merge.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2571, %outputPort_2572 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_15446289516955298258.5.out0->merge.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    cal.create_instance @fft__Radix2Cell "r2cell" device_affinity="cpu0" ()
        ports_in (%outputPort_2560, %outputPort_2562, %outputPort_2564 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2565, %inputPort_2567 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__TwiddleGenerator__v__N_dyn "twiddles" (%c2_i32 : i32)
        ports_in (%outputPort_2558 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2563 : !fifo.input_port<complex<f32>>)
    cal.create_instance @__fanout_complex_f32__2 "fft__Butterfly$spec_1916938481276772234.__fanout_complex_f32__2.6" device_affinity="cpu0" ()
        ports_in (%outputPort_2502 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2555, %inputPort_2557 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Split__v__N_dyn "split" (%c2_i32 : i32)
        ports_in (%outputPort_2556 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2559, %inputPort_2561 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    %inputPort_2573, %outputPort_2574 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4.out0->split.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2575, %outputPort_2576 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4.out1->twiddles.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2577, %outputPort_2578 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.split.out0->r2cell.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2579, %outputPort_2580 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.split.out1->r2cell.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2581, %outputPort_2582 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.twiddles.out0->r2cell.in2"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2583, %outputPort_2584 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.r2cell.out0->merge.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2585, %outputPort_2586 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.r2cell.out1->merge.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    cal.create_instance @fft__Merge "merge" device_affinity="cpu0" ()
        ports_in (%outputPort_2584, %outputPort_2586 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2569 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__TwiddleGenerator__v__N_dyn "twiddles" (%c1_i32 : i32)
        ports_in (%outputPort_2576 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2581 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Split__v__N_dyn "split" (%c1_i32 : i32)
        ports_in (%outputPort_2574 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2577, %inputPort_2579 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @__fanout_complex_f32__2 "fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4" device_affinity="cpu0" ()
        ports_in (%outputPort_2566 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2573, %inputPort_2575 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Radix2Cell "r2cell" device_affinity="cpu0" ()
        ports_in (%outputPort_2578, %outputPort_2580, %outputPort_2582 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2583, %inputPort_2585 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    %inputPort_2587, %outputPort_2588 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4.out0->split.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2589, %outputPort_2590 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4.out1->twiddles.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2591, %outputPort_2592 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.split.out0->r2cell.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2593, %outputPort_2594 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.split.out1->r2cell.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2595, %outputPort_2596 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.twiddles.out0->r2cell.in2"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2597, %outputPort_2598 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.r2cell.out0->merge.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2599, %outputPort_2600 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.r2cell.out1->merge.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    cal.create_instance @fft__Merge "merge" device_affinity="cpu0" ()
        ports_in (%outputPort_2598, %outputPort_2600 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2571 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__TwiddleGenerator__v__N_dyn "twiddles" (%c1_i32 : i32)
        ports_in (%outputPort_2590 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2595 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Split__v__N_dyn "split" (%c1_i32 : i32)
        ports_in (%outputPort_2588 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2591, %inputPort_2593 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @__fanout_complex_f32__2 "fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4" device_affinity="cpu0" ()
        ports_in (%outputPort_2568 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2587, %inputPort_2589 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Radix2Cell "r2cell" device_affinity="cpu0" ()
        ports_in (%outputPort_2592, %outputPort_2594, %outputPort_2596 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2597, %inputPort_2599 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Merge "merge" device_affinity="cpu0" ()
        ports_in (%outputPort_2570, %outputPort_2572 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2505 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Split__v__N_dyn "split" (%c8_i32 : i32)
        ports_in (%outputPort_2364 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2367, %inputPort_2369 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Split__v__N_dyn "split" (%c16_i32 : i32)
        ports_in (%outputPort_2108 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2111, %inputPort_2113 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Radix2Cell "r2cell" device_affinity="cpu0" ()
        ports_in (%outputPort_2094, %outputPort_2096, %outputPort_2098 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2099, %inputPort_2101 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__TwiddleGenerator__v__N_dyn "twiddles" (%c32_i32 : i32)
        ports_in (%outputPort_2092 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2097 : !fifo.input_port<complex<f32>>)
    cal.create_instance @__fanout_complex_f32__2 "fft__Butterfly$spec_17640631431051100303.__fanout_complex_f32__2.6" device_affinity="cpu0" ()
        ports_in (%outputPort_2082 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2089, %inputPort_2091 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    %inputPort_2601, %outputPort_2602 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_3035977640463470463.fft__Butterfly$spec_3035977640463470463.__fanout_complex_f32__2.6.out0->split.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2603, %outputPort_2604 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_3035977640463470463.fft__Butterfly$spec_3035977640463470463.__fanout_complex_f32__2.6.out1->twiddles.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2605, %outputPort_2606 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_3035977640463470463.split.out0->r2cell.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2607, %outputPort_2608 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_3035977640463470463.split.out1->r2cell.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2609, %outputPort_2610 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_3035977640463470463.twiddles.out0->r2cell.in2"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2611, %outputPort_2612 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_3035977640463470463.r2cell.out0->fft__Butterfly$spec_3035977640463470463.fft__Butterfly$spec_16755419077516047831.4.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2613, %outputPort_2614 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_3035977640463470463.r2cell.out1->fft__Butterfly$spec_3035977640463470463.fft__Butterfly$spec_16755419077516047831.5.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2615, %outputPort_2616 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_3035977640463470463.fft__Butterfly$spec_3035977640463470463.fft__Butterfly$spec_16755419077516047831.4.out0->merge.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2617, %outputPort_2618 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_3035977640463470463.fft__Butterfly$spec_3035977640463470463.fft__Butterfly$spec_16755419077516047831.5.out0->merge.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    cal.create_instance @fft__TwiddleGenerator__v__N_dyn "twiddles" (%c16_i32 : i32)
        ports_in (%outputPort_2604 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2609 : !fifo.input_port<complex<f32>>)
    %inputPort_2619, %outputPort_2620 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_16755419077516047831.fft__Butterfly$spec_16755419077516047831.__fanout_complex_f32__2.6.out0->split.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2621, %outputPort_2622 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_16755419077516047831.fft__Butterfly$spec_16755419077516047831.__fanout_complex_f32__2.6.out1->twiddles.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2623, %outputPort_2624 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_16755419077516047831.split.out0->r2cell.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2625, %outputPort_2626 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_16755419077516047831.split.out1->r2cell.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2627, %outputPort_2628 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_16755419077516047831.twiddles.out0->r2cell.in2"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2629, %outputPort_2630 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_16755419077516047831.r2cell.out0->fft__Butterfly$spec_16755419077516047831.fft__Butterfly$spec_9935405952460034831.4.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2631, %outputPort_2632 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_16755419077516047831.r2cell.out1->fft__Butterfly$spec_16755419077516047831.fft__Butterfly$spec_9935405952460034831.5.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2633, %outputPort_2634 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_16755419077516047831.fft__Butterfly$spec_16755419077516047831.fft__Butterfly$spec_9935405952460034831.4.out0->merge.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2635, %outputPort_2636 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_16755419077516047831.fft__Butterfly$spec_16755419077516047831.fft__Butterfly$spec_9935405952460034831.5.out0->merge.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    cal.create_instance @__fanout_complex_f32__2 "fft__Butterfly$spec_16755419077516047831.__fanout_complex_f32__2.6" device_affinity="cpu0" ()
        ports_in (%outputPort_2614 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2619, %inputPort_2621 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Merge "merge" device_affinity="cpu0" ()
        ports_in (%outputPort_2634, %outputPort_2636 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2617 : !fifo.input_port<complex<f32>>)
    %inputPort_2637, %outputPort_2638 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.fft__Butterfly$spec_9935405952460034831.__fanout_complex_f32__2.6.out0->split.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2639, %outputPort_2640 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.fft__Butterfly$spec_9935405952460034831.__fanout_complex_f32__2.6.out1->twiddles.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2641, %outputPort_2642 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.split.out0->r2cell.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2643, %outputPort_2644 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.split.out1->r2cell.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2645, %outputPort_2646 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.twiddles.out0->r2cell.in2"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2647, %outputPort_2648 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.r2cell.out0->fft__Butterfly$spec_9935405952460034831.fft__Butterfly$spec_1916938481276772234.4.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2649, %outputPort_2650 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.r2cell.out1->fft__Butterfly$spec_9935405952460034831.fft__Butterfly$spec_1916938481276772234.5.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2651, %outputPort_2652 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.fft__Butterfly$spec_9935405952460034831.fft__Butterfly$spec_1916938481276772234.4.out0->merge.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2653, %outputPort_2654 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.fft__Butterfly$spec_9935405952460034831.fft__Butterfly$spec_1916938481276772234.5.out0->merge.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    cal.create_instance @fft__Radix2Cell "r2cell" device_affinity="cpu0" ()
        ports_in (%outputPort_2642, %outputPort_2644, %outputPort_2646 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2647, %inputPort_2649 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Split__v__N_dyn "split" (%c4_i32 : i32)
        ports_in (%outputPort_2638 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2641, %inputPort_2643 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Merge "merge" device_affinity="cpu0" ()
        ports_in (%outputPort_2652, %outputPort_2654 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2635 : !fifo.input_port<complex<f32>>)
    cal.create_instance @__fanout_complex_f32__2 "fft__Butterfly$spec_9935405952460034831.__fanout_complex_f32__2.6" device_affinity="cpu0" ()
        ports_in (%outputPort_2632 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2637, %inputPort_2639 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__TwiddleGenerator__v__N_dyn "twiddles" (%c4_i32 : i32)
        ports_in (%outputPort_2640 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2645 : !fifo.input_port<complex<f32>>)
    %inputPort_2655, %outputPort_2656 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_1916938481276772234.__fanout_complex_f32__2.6.out0->split.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2657, %outputPort_2658 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_1916938481276772234.__fanout_complex_f32__2.6.out1->twiddles.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2659, %outputPort_2660 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.split.out0->r2cell.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2661, %outputPort_2662 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.split.out1->r2cell.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2663, %outputPort_2664 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.twiddles.out0->r2cell.in2"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2665, %outputPort_2666 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.r2cell.out0->fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_15446289516955298258.4.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2667, %outputPort_2668 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.r2cell.out1->fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_15446289516955298258.5.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2669, %outputPort_2670 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_15446289516955298258.4.out0->merge.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2671, %outputPort_2672 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_15446289516955298258.5.out0->merge.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    cal.create_instance @fft__Radix2Cell "r2cell" device_affinity="cpu0" ()
        ports_in (%outputPort_2660, %outputPort_2662, %outputPort_2664 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2665, %inputPort_2667 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__TwiddleGenerator__v__N_dyn "twiddles" (%c2_i32 : i32)
        ports_in (%outputPort_2658 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2663 : !fifo.input_port<complex<f32>>)
    cal.create_instance @__fanout_complex_f32__2 "fft__Butterfly$spec_1916938481276772234.__fanout_complex_f32__2.6" device_affinity="cpu0" ()
        ports_in (%outputPort_2650 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2655, %inputPort_2657 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Split__v__N_dyn "split" (%c2_i32 : i32)
        ports_in (%outputPort_2656 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2659, %inputPort_2661 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    %inputPort_2673, %outputPort_2674 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4.out0->split.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2675, %outputPort_2676 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4.out1->twiddles.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2677, %outputPort_2678 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.split.out0->r2cell.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2679, %outputPort_2680 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.split.out1->r2cell.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2681, %outputPort_2682 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.twiddles.out0->r2cell.in2"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2683, %outputPort_2684 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.r2cell.out0->merge.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2685, %outputPort_2686 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.r2cell.out1->merge.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    cal.create_instance @fft__Merge "merge" device_affinity="cpu0" ()
        ports_in (%outputPort_2684, %outputPort_2686 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2669 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__TwiddleGenerator__v__N_dyn "twiddles" (%c1_i32 : i32)
        ports_in (%outputPort_2676 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2681 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Split__v__N_dyn "split" (%c1_i32 : i32)
        ports_in (%outputPort_2674 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2677, %inputPort_2679 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @__fanout_complex_f32__2 "fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4" device_affinity="cpu0" ()
        ports_in (%outputPort_2666 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2673, %inputPort_2675 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Radix2Cell "r2cell" device_affinity="cpu0" ()
        ports_in (%outputPort_2678, %outputPort_2680, %outputPort_2682 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2683, %inputPort_2685 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    %inputPort_2687, %outputPort_2688 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4.out0->split.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2689, %outputPort_2690 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4.out1->twiddles.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2691, %outputPort_2692 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.split.out0->r2cell.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2693, %outputPort_2694 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.split.out1->r2cell.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2695, %outputPort_2696 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.twiddles.out0->r2cell.in2"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2697, %outputPort_2698 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.r2cell.out0->merge.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2699, %outputPort_2700 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.r2cell.out1->merge.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    cal.create_instance @fft__Merge "merge" device_affinity="cpu0" ()
        ports_in (%outputPort_2698, %outputPort_2700 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2671 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__TwiddleGenerator__v__N_dyn "twiddles" (%c1_i32 : i32)
        ports_in (%outputPort_2690 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2695 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Split__v__N_dyn "split" (%c1_i32 : i32)
        ports_in (%outputPort_2688 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2691, %inputPort_2693 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @__fanout_complex_f32__2 "fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4" device_affinity="cpu0" ()
        ports_in (%outputPort_2668 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2687, %inputPort_2689 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Radix2Cell "r2cell" device_affinity="cpu0" ()
        ports_in (%outputPort_2692, %outputPort_2694, %outputPort_2696 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2697, %inputPort_2699 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Merge "merge" device_affinity="cpu0" ()
        ports_in (%outputPort_2670, %outputPort_2672 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2653 : !fifo.input_port<complex<f32>>)
    %inputPort_2701, %outputPort_2702 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_1916938481276772234.__fanout_complex_f32__2.6.out0->split.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2703, %outputPort_2704 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_1916938481276772234.__fanout_complex_f32__2.6.out1->twiddles.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2705, %outputPort_2706 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.split.out0->r2cell.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2707, %outputPort_2708 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.split.out1->r2cell.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2709, %outputPort_2710 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.twiddles.out0->r2cell.in2"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2711, %outputPort_2712 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.r2cell.out0->fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_15446289516955298258.4.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2713, %outputPort_2714 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.r2cell.out1->fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_15446289516955298258.5.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2715, %outputPort_2716 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_15446289516955298258.4.out0->merge.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2717, %outputPort_2718 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_15446289516955298258.5.out0->merge.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    cal.create_instance @fft__Radix2Cell "r2cell" device_affinity="cpu0" ()
        ports_in (%outputPort_2706, %outputPort_2708, %outputPort_2710 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2711, %inputPort_2713 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__TwiddleGenerator__v__N_dyn "twiddles" (%c2_i32 : i32)
        ports_in (%outputPort_2704 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2709 : !fifo.input_port<complex<f32>>)
    cal.create_instance @__fanout_complex_f32__2 "fft__Butterfly$spec_1916938481276772234.__fanout_complex_f32__2.6" device_affinity="cpu0" ()
        ports_in (%outputPort_2648 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2701, %inputPort_2703 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Split__v__N_dyn "split" (%c2_i32 : i32)
        ports_in (%outputPort_2702 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2705, %inputPort_2707 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    %inputPort_2719, %outputPort_2720 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4.out0->split.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2721, %outputPort_2722 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4.out1->twiddles.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2723, %outputPort_2724 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.split.out0->r2cell.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2725, %outputPort_2726 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.split.out1->r2cell.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2727, %outputPort_2728 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.twiddles.out0->r2cell.in2"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2729, %outputPort_2730 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.r2cell.out0->merge.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2731, %outputPort_2732 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.r2cell.out1->merge.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    cal.create_instance @fft__Merge "merge" device_affinity="cpu0" ()
        ports_in (%outputPort_2730, %outputPort_2732 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2715 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__TwiddleGenerator__v__N_dyn "twiddles" (%c1_i32 : i32)
        ports_in (%outputPort_2722 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2727 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Split__v__N_dyn "split" (%c1_i32 : i32)
        ports_in (%outputPort_2720 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2723, %inputPort_2725 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @__fanout_complex_f32__2 "fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4" device_affinity="cpu0" ()
        ports_in (%outputPort_2712 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2719, %inputPort_2721 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Radix2Cell "r2cell" device_affinity="cpu0" ()
        ports_in (%outputPort_2724, %outputPort_2726, %outputPort_2728 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2729, %inputPort_2731 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    %inputPort_2733, %outputPort_2734 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4.out0->split.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2735, %outputPort_2736 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4.out1->twiddles.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2737, %outputPort_2738 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.split.out0->r2cell.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2739, %outputPort_2740 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.split.out1->r2cell.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2741, %outputPort_2742 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.twiddles.out0->r2cell.in2"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2743, %outputPort_2744 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.r2cell.out0->merge.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2745, %outputPort_2746 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.r2cell.out1->merge.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    cal.create_instance @fft__Merge "merge" device_affinity="cpu0" ()
        ports_in (%outputPort_2744, %outputPort_2746 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2717 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__TwiddleGenerator__v__N_dyn "twiddles" (%c1_i32 : i32)
        ports_in (%outputPort_2736 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2741 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Split__v__N_dyn "split" (%c1_i32 : i32)
        ports_in (%outputPort_2734 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2737, %inputPort_2739 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @__fanout_complex_f32__2 "fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4" device_affinity="cpu0" ()
        ports_in (%outputPort_2714 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2733, %inputPort_2735 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Radix2Cell "r2cell" device_affinity="cpu0" ()
        ports_in (%outputPort_2738, %outputPort_2740, %outputPort_2742 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2743, %inputPort_2745 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Merge "merge" device_affinity="cpu0" ()
        ports_in (%outputPort_2716, %outputPort_2718 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2651 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__TwiddleGenerator__v__N_dyn "twiddles" (%c8_i32 : i32)
        ports_in (%outputPort_2622 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2627 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Radix2Cell "r2cell" device_affinity="cpu0" ()
        ports_in (%outputPort_2624, %outputPort_2626, %outputPort_2628 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2629, %inputPort_2631 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    %inputPort_2747, %outputPort_2748 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.fft__Butterfly$spec_9935405952460034831.__fanout_complex_f32__2.6.out0->split.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2749, %outputPort_2750 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.fft__Butterfly$spec_9935405952460034831.__fanout_complex_f32__2.6.out1->twiddles.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2751, %outputPort_2752 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.split.out0->r2cell.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2753, %outputPort_2754 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.split.out1->r2cell.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2755, %outputPort_2756 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.twiddles.out0->r2cell.in2"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2757, %outputPort_2758 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.r2cell.out0->fft__Butterfly$spec_9935405952460034831.fft__Butterfly$spec_1916938481276772234.4.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2759, %outputPort_2760 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.r2cell.out1->fft__Butterfly$spec_9935405952460034831.fft__Butterfly$spec_1916938481276772234.5.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2761, %outputPort_2762 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.fft__Butterfly$spec_9935405952460034831.fft__Butterfly$spec_1916938481276772234.4.out0->merge.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2763, %outputPort_2764 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.fft__Butterfly$spec_9935405952460034831.fft__Butterfly$spec_1916938481276772234.5.out0->merge.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    cal.create_instance @fft__Radix2Cell "r2cell" device_affinity="cpu0" ()
        ports_in (%outputPort_2752, %outputPort_2754, %outputPort_2756 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2757, %inputPort_2759 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Split__v__N_dyn "split" (%c4_i32 : i32)
        ports_in (%outputPort_2748 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2751, %inputPort_2753 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Merge "merge" device_affinity="cpu0" ()
        ports_in (%outputPort_2762, %outputPort_2764 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2633 : !fifo.input_port<complex<f32>>)
    cal.create_instance @__fanout_complex_f32__2 "fft__Butterfly$spec_9935405952460034831.__fanout_complex_f32__2.6" device_affinity="cpu0" ()
        ports_in (%outputPort_2630 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2747, %inputPort_2749 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__TwiddleGenerator__v__N_dyn "twiddles" (%c4_i32 : i32)
        ports_in (%outputPort_2750 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2755 : !fifo.input_port<complex<f32>>)
    %inputPort_2765, %outputPort_2766 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_1916938481276772234.__fanout_complex_f32__2.6.out0->split.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2767, %outputPort_2768 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_1916938481276772234.__fanout_complex_f32__2.6.out1->twiddles.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2769, %outputPort_2770 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.split.out0->r2cell.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2771, %outputPort_2772 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.split.out1->r2cell.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2773, %outputPort_2774 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.twiddles.out0->r2cell.in2"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2775, %outputPort_2776 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.r2cell.out0->fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_15446289516955298258.4.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2777, %outputPort_2778 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.r2cell.out1->fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_15446289516955298258.5.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2779, %outputPort_2780 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_15446289516955298258.4.out0->merge.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2781, %outputPort_2782 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_15446289516955298258.5.out0->merge.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    cal.create_instance @fft__Radix2Cell "r2cell" device_affinity="cpu0" ()
        ports_in (%outputPort_2770, %outputPort_2772, %outputPort_2774 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2775, %inputPort_2777 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__TwiddleGenerator__v__N_dyn "twiddles" (%c2_i32 : i32)
        ports_in (%outputPort_2768 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2773 : !fifo.input_port<complex<f32>>)
    cal.create_instance @__fanout_complex_f32__2 "fft__Butterfly$spec_1916938481276772234.__fanout_complex_f32__2.6" device_affinity="cpu0" ()
        ports_in (%outputPort_2760 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2765, %inputPort_2767 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Split__v__N_dyn "split" (%c2_i32 : i32)
        ports_in (%outputPort_2766 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2769, %inputPort_2771 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    %inputPort_2783, %outputPort_2784 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4.out0->split.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2785, %outputPort_2786 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4.out1->twiddles.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2787, %outputPort_2788 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.split.out0->r2cell.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2789, %outputPort_2790 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.split.out1->r2cell.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2791, %outputPort_2792 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.twiddles.out0->r2cell.in2"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2793, %outputPort_2794 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.r2cell.out0->merge.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2795, %outputPort_2796 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.r2cell.out1->merge.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    cal.create_instance @fft__Merge "merge" device_affinity="cpu0" ()
        ports_in (%outputPort_2794, %outputPort_2796 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2779 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__TwiddleGenerator__v__N_dyn "twiddles" (%c1_i32 : i32)
        ports_in (%outputPort_2786 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2791 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Split__v__N_dyn "split" (%c1_i32 : i32)
        ports_in (%outputPort_2784 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2787, %inputPort_2789 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @__fanout_complex_f32__2 "fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4" device_affinity="cpu0" ()
        ports_in (%outputPort_2776 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2783, %inputPort_2785 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Radix2Cell "r2cell" device_affinity="cpu0" ()
        ports_in (%outputPort_2788, %outputPort_2790, %outputPort_2792 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2793, %inputPort_2795 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    %inputPort_2797, %outputPort_2798 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4.out0->split.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2799, %outputPort_2800 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4.out1->twiddles.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2801, %outputPort_2802 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.split.out0->r2cell.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2803, %outputPort_2804 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.split.out1->r2cell.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2805, %outputPort_2806 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.twiddles.out0->r2cell.in2"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2807, %outputPort_2808 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.r2cell.out0->merge.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2809, %outputPort_2810 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.r2cell.out1->merge.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    cal.create_instance @fft__Merge "merge" device_affinity="cpu0" ()
        ports_in (%outputPort_2808, %outputPort_2810 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2781 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__TwiddleGenerator__v__N_dyn "twiddles" (%c1_i32 : i32)
        ports_in (%outputPort_2800 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2805 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Split__v__N_dyn "split" (%c1_i32 : i32)
        ports_in (%outputPort_2798 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2801, %inputPort_2803 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @__fanout_complex_f32__2 "fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4" device_affinity="cpu0" ()
        ports_in (%outputPort_2778 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2797, %inputPort_2799 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Radix2Cell "r2cell" device_affinity="cpu0" ()
        ports_in (%outputPort_2802, %outputPort_2804, %outputPort_2806 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2807, %inputPort_2809 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Merge "merge" device_affinity="cpu0" ()
        ports_in (%outputPort_2780, %outputPort_2782 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2763 : !fifo.input_port<complex<f32>>)
    %inputPort_2811, %outputPort_2812 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_1916938481276772234.__fanout_complex_f32__2.6.out0->split.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2813, %outputPort_2814 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_1916938481276772234.__fanout_complex_f32__2.6.out1->twiddles.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2815, %outputPort_2816 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.split.out0->r2cell.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2817, %outputPort_2818 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.split.out1->r2cell.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2819, %outputPort_2820 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.twiddles.out0->r2cell.in2"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2821, %outputPort_2822 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.r2cell.out0->fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_15446289516955298258.4.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2823, %outputPort_2824 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.r2cell.out1->fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_15446289516955298258.5.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2825, %outputPort_2826 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_15446289516955298258.4.out0->merge.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2827, %outputPort_2828 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_15446289516955298258.5.out0->merge.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    cal.create_instance @fft__Radix2Cell "r2cell" device_affinity="cpu0" ()
        ports_in (%outputPort_2816, %outputPort_2818, %outputPort_2820 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2821, %inputPort_2823 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__TwiddleGenerator__v__N_dyn "twiddles" (%c2_i32 : i32)
        ports_in (%outputPort_2814 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2819 : !fifo.input_port<complex<f32>>)
    cal.create_instance @__fanout_complex_f32__2 "fft__Butterfly$spec_1916938481276772234.__fanout_complex_f32__2.6" device_affinity="cpu0" ()
        ports_in (%outputPort_2758 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2811, %inputPort_2813 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Split__v__N_dyn "split" (%c2_i32 : i32)
        ports_in (%outputPort_2812 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2815, %inputPort_2817 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    %inputPort_2829, %outputPort_2830 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4.out0->split.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2831, %outputPort_2832 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4.out1->twiddles.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2833, %outputPort_2834 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.split.out0->r2cell.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2835, %outputPort_2836 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.split.out1->r2cell.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2837, %outputPort_2838 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.twiddles.out0->r2cell.in2"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2839, %outputPort_2840 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.r2cell.out0->merge.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2841, %outputPort_2842 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.r2cell.out1->merge.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    cal.create_instance @fft__Merge "merge" device_affinity="cpu0" ()
        ports_in (%outputPort_2840, %outputPort_2842 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2825 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__TwiddleGenerator__v__N_dyn "twiddles" (%c1_i32 : i32)
        ports_in (%outputPort_2832 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2837 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Split__v__N_dyn "split" (%c1_i32 : i32)
        ports_in (%outputPort_2830 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2833, %inputPort_2835 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @__fanout_complex_f32__2 "fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4" device_affinity="cpu0" ()
        ports_in (%outputPort_2822 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2829, %inputPort_2831 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Radix2Cell "r2cell" device_affinity="cpu0" ()
        ports_in (%outputPort_2834, %outputPort_2836, %outputPort_2838 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2839, %inputPort_2841 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    %inputPort_2843, %outputPort_2844 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4.out0->split.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2845, %outputPort_2846 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4.out1->twiddles.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2847, %outputPort_2848 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.split.out0->r2cell.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2849, %outputPort_2850 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.split.out1->r2cell.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2851, %outputPort_2852 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.twiddles.out0->r2cell.in2"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2853, %outputPort_2854 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.r2cell.out0->merge.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2855, %outputPort_2856 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.r2cell.out1->merge.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    cal.create_instance @fft__Merge "merge" device_affinity="cpu0" ()
        ports_in (%outputPort_2854, %outputPort_2856 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2827 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__TwiddleGenerator__v__N_dyn "twiddles" (%c1_i32 : i32)
        ports_in (%outputPort_2846 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2851 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Split__v__N_dyn "split" (%c1_i32 : i32)
        ports_in (%outputPort_2844 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2847, %inputPort_2849 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @__fanout_complex_f32__2 "fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4" device_affinity="cpu0" ()
        ports_in (%outputPort_2824 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2843, %inputPort_2845 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Radix2Cell "r2cell" device_affinity="cpu0" ()
        ports_in (%outputPort_2848, %outputPort_2850, %outputPort_2852 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2853, %inputPort_2855 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Merge "merge" device_affinity="cpu0" ()
        ports_in (%outputPort_2826, %outputPort_2828 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2761 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Split__v__N_dyn "split" (%c8_i32 : i32)
        ports_in (%outputPort_2620 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2623, %inputPort_2625 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Radix2Cell "r2cell" device_affinity="cpu0" ()
        ports_in (%outputPort_2606, %outputPort_2608, %outputPort_2610 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2611, %inputPort_2613 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Merge "merge" device_affinity="cpu0" ()
        ports_in (%outputPort_2616, %outputPort_2618 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2105 : !fifo.input_port<complex<f32>>)
    cal.create_instance @__fanout_complex_f32__2 "fft__Butterfly$spec_3035977640463470463.__fanout_complex_f32__2.6" device_affinity="cpu0" ()
        ports_in (%outputPort_2102 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2601, %inputPort_2603 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    %inputPort_2857, %outputPort_2858 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_16755419077516047831.fft__Butterfly$spec_16755419077516047831.__fanout_complex_f32__2.6.out0->split.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2859, %outputPort_2860 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_16755419077516047831.fft__Butterfly$spec_16755419077516047831.__fanout_complex_f32__2.6.out1->twiddles.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2861, %outputPort_2862 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_16755419077516047831.split.out0->r2cell.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2863, %outputPort_2864 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_16755419077516047831.split.out1->r2cell.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2865, %outputPort_2866 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_16755419077516047831.twiddles.out0->r2cell.in2"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2867, %outputPort_2868 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_16755419077516047831.r2cell.out0->fft__Butterfly$spec_16755419077516047831.fft__Butterfly$spec_9935405952460034831.4.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2869, %outputPort_2870 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_16755419077516047831.r2cell.out1->fft__Butterfly$spec_16755419077516047831.fft__Butterfly$spec_9935405952460034831.5.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2871, %outputPort_2872 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_16755419077516047831.fft__Butterfly$spec_16755419077516047831.fft__Butterfly$spec_9935405952460034831.4.out0->merge.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2873, %outputPort_2874 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_16755419077516047831.fft__Butterfly$spec_16755419077516047831.fft__Butterfly$spec_9935405952460034831.5.out0->merge.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    cal.create_instance @__fanout_complex_f32__2 "fft__Butterfly$spec_16755419077516047831.__fanout_complex_f32__2.6" device_affinity="cpu0" ()
        ports_in (%outputPort_2612 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2857, %inputPort_2859 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Merge "merge" device_affinity="cpu0" ()
        ports_in (%outputPort_2872, %outputPort_2874 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2615 : !fifo.input_port<complex<f32>>)
    %inputPort_2875, %outputPort_2876 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.fft__Butterfly$spec_9935405952460034831.__fanout_complex_f32__2.6.out0->split.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2877, %outputPort_2878 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.fft__Butterfly$spec_9935405952460034831.__fanout_complex_f32__2.6.out1->twiddles.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2879, %outputPort_2880 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.split.out0->r2cell.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2881, %outputPort_2882 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.split.out1->r2cell.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2883, %outputPort_2884 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.twiddles.out0->r2cell.in2"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2885, %outputPort_2886 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.r2cell.out0->fft__Butterfly$spec_9935405952460034831.fft__Butterfly$spec_1916938481276772234.4.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2887, %outputPort_2888 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.r2cell.out1->fft__Butterfly$spec_9935405952460034831.fft__Butterfly$spec_1916938481276772234.5.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2889, %outputPort_2890 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.fft__Butterfly$spec_9935405952460034831.fft__Butterfly$spec_1916938481276772234.4.out0->merge.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2891, %outputPort_2892 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.fft__Butterfly$spec_9935405952460034831.fft__Butterfly$spec_1916938481276772234.5.out0->merge.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    cal.create_instance @fft__Radix2Cell "r2cell" device_affinity="cpu0" ()
        ports_in (%outputPort_2880, %outputPort_2882, %outputPort_2884 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2885, %inputPort_2887 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Split__v__N_dyn "split" (%c4_i32 : i32)
        ports_in (%outputPort_2876 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2879, %inputPort_2881 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Merge "merge" device_affinity="cpu0" ()
        ports_in (%outputPort_2890, %outputPort_2892 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2873 : !fifo.input_port<complex<f32>>)
    cal.create_instance @__fanout_complex_f32__2 "fft__Butterfly$spec_9935405952460034831.__fanout_complex_f32__2.6" device_affinity="cpu0" ()
        ports_in (%outputPort_2870 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2875, %inputPort_2877 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__TwiddleGenerator__v__N_dyn "twiddles" (%c4_i32 : i32)
        ports_in (%outputPort_2878 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2883 : !fifo.input_port<complex<f32>>)
    %inputPort_2893, %outputPort_2894 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_1916938481276772234.__fanout_complex_f32__2.6.out0->split.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2895, %outputPort_2896 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_1916938481276772234.__fanout_complex_f32__2.6.out1->twiddles.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2897, %outputPort_2898 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.split.out0->r2cell.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2899, %outputPort_2900 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.split.out1->r2cell.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2901, %outputPort_2902 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.twiddles.out0->r2cell.in2"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2903, %outputPort_2904 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.r2cell.out0->fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_15446289516955298258.4.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2905, %outputPort_2906 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.r2cell.out1->fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_15446289516955298258.5.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2907, %outputPort_2908 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_15446289516955298258.4.out0->merge.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2909, %outputPort_2910 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_15446289516955298258.5.out0->merge.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    cal.create_instance @fft__Radix2Cell "r2cell" device_affinity="cpu0" ()
        ports_in (%outputPort_2898, %outputPort_2900, %outputPort_2902 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2903, %inputPort_2905 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__TwiddleGenerator__v__N_dyn "twiddles" (%c2_i32 : i32)
        ports_in (%outputPort_2896 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2901 : !fifo.input_port<complex<f32>>)
    cal.create_instance @__fanout_complex_f32__2 "fft__Butterfly$spec_1916938481276772234.__fanout_complex_f32__2.6" device_affinity="cpu0" ()
        ports_in (%outputPort_2888 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2893, %inputPort_2895 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Split__v__N_dyn "split" (%c2_i32 : i32)
        ports_in (%outputPort_2894 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2897, %inputPort_2899 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    %inputPort_2911, %outputPort_2912 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4.out0->split.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2913, %outputPort_2914 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4.out1->twiddles.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2915, %outputPort_2916 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.split.out0->r2cell.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2917, %outputPort_2918 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.split.out1->r2cell.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2919, %outputPort_2920 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.twiddles.out0->r2cell.in2"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2921, %outputPort_2922 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.r2cell.out0->merge.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2923, %outputPort_2924 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.r2cell.out1->merge.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    cal.create_instance @fft__Merge "merge" device_affinity="cpu0" ()
        ports_in (%outputPort_2922, %outputPort_2924 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2907 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__TwiddleGenerator__v__N_dyn "twiddles" (%c1_i32 : i32)
        ports_in (%outputPort_2914 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2919 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Split__v__N_dyn "split" (%c1_i32 : i32)
        ports_in (%outputPort_2912 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2915, %inputPort_2917 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @__fanout_complex_f32__2 "fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4" device_affinity="cpu0" ()
        ports_in (%outputPort_2904 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2911, %inputPort_2913 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Radix2Cell "r2cell" device_affinity="cpu0" ()
        ports_in (%outputPort_2916, %outputPort_2918, %outputPort_2920 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2921, %inputPort_2923 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    %inputPort_2925, %outputPort_2926 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4.out0->split.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2927, %outputPort_2928 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4.out1->twiddles.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2929, %outputPort_2930 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.split.out0->r2cell.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2931, %outputPort_2932 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.split.out1->r2cell.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2933, %outputPort_2934 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.twiddles.out0->r2cell.in2"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2935, %outputPort_2936 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.r2cell.out0->merge.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2937, %outputPort_2938 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.r2cell.out1->merge.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    cal.create_instance @fft__Merge "merge" device_affinity="cpu0" ()
        ports_in (%outputPort_2936, %outputPort_2938 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2909 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__TwiddleGenerator__v__N_dyn "twiddles" (%c1_i32 : i32)
        ports_in (%outputPort_2928 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2933 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Split__v__N_dyn "split" (%c1_i32 : i32)
        ports_in (%outputPort_2926 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2929, %inputPort_2931 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @__fanout_complex_f32__2 "fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4" device_affinity="cpu0" ()
        ports_in (%outputPort_2906 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2925, %inputPort_2927 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Radix2Cell "r2cell" device_affinity="cpu0" ()
        ports_in (%outputPort_2930, %outputPort_2932, %outputPort_2934 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2935, %inputPort_2937 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Merge "merge" device_affinity="cpu0" ()
        ports_in (%outputPort_2908, %outputPort_2910 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2891 : !fifo.input_port<complex<f32>>)
    %inputPort_2939, %outputPort_2940 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_1916938481276772234.__fanout_complex_f32__2.6.out0->split.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2941, %outputPort_2942 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_1916938481276772234.__fanout_complex_f32__2.6.out1->twiddles.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2943, %outputPort_2944 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.split.out0->r2cell.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2945, %outputPort_2946 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.split.out1->r2cell.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2947, %outputPort_2948 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.twiddles.out0->r2cell.in2"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2949, %outputPort_2950 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.r2cell.out0->fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_15446289516955298258.4.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2951, %outputPort_2952 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.r2cell.out1->fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_15446289516955298258.5.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2953, %outputPort_2954 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_15446289516955298258.4.out0->merge.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2955, %outputPort_2956 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_15446289516955298258.5.out0->merge.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    cal.create_instance @fft__Radix2Cell "r2cell" device_affinity="cpu0" ()
        ports_in (%outputPort_2944, %outputPort_2946, %outputPort_2948 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2949, %inputPort_2951 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__TwiddleGenerator__v__N_dyn "twiddles" (%c2_i32 : i32)
        ports_in (%outputPort_2942 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2947 : !fifo.input_port<complex<f32>>)
    cal.create_instance @__fanout_complex_f32__2 "fft__Butterfly$spec_1916938481276772234.__fanout_complex_f32__2.6" device_affinity="cpu0" ()
        ports_in (%outputPort_2886 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2939, %inputPort_2941 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Split__v__N_dyn "split" (%c2_i32 : i32)
        ports_in (%outputPort_2940 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2943, %inputPort_2945 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    %inputPort_2957, %outputPort_2958 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4.out0->split.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2959, %outputPort_2960 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4.out1->twiddles.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2961, %outputPort_2962 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.split.out0->r2cell.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2963, %outputPort_2964 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.split.out1->r2cell.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2965, %outputPort_2966 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.twiddles.out0->r2cell.in2"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2967, %outputPort_2968 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.r2cell.out0->merge.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2969, %outputPort_2970 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.r2cell.out1->merge.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    cal.create_instance @fft__Merge "merge" device_affinity="cpu0" ()
        ports_in (%outputPort_2968, %outputPort_2970 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2953 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__TwiddleGenerator__v__N_dyn "twiddles" (%c1_i32 : i32)
        ports_in (%outputPort_2960 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2965 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Split__v__N_dyn "split" (%c1_i32 : i32)
        ports_in (%outputPort_2958 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2961, %inputPort_2963 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @__fanout_complex_f32__2 "fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4" device_affinity="cpu0" ()
        ports_in (%outputPort_2950 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2957, %inputPort_2959 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Radix2Cell "r2cell" device_affinity="cpu0" ()
        ports_in (%outputPort_2962, %outputPort_2964, %outputPort_2966 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2967, %inputPort_2969 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    %inputPort_2971, %outputPort_2972 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4.out0->split.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2973, %outputPort_2974 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4.out1->twiddles.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2975, %outputPort_2976 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.split.out0->r2cell.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2977, %outputPort_2978 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.split.out1->r2cell.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2979, %outputPort_2980 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.twiddles.out0->r2cell.in2"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2981, %outputPort_2982 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.r2cell.out0->merge.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2983, %outputPort_2984 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.r2cell.out1->merge.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    cal.create_instance @fft__Merge "merge" device_affinity="cpu0" ()
        ports_in (%outputPort_2982, %outputPort_2984 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2955 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__TwiddleGenerator__v__N_dyn "twiddles" (%c1_i32 : i32)
        ports_in (%outputPort_2974 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2979 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Split__v__N_dyn "split" (%c1_i32 : i32)
        ports_in (%outputPort_2972 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2975, %inputPort_2977 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @__fanout_complex_f32__2 "fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4" device_affinity="cpu0" ()
        ports_in (%outputPort_2952 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2971, %inputPort_2973 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Radix2Cell "r2cell" device_affinity="cpu0" ()
        ports_in (%outputPort_2976, %outputPort_2978, %outputPort_2980 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2981, %inputPort_2983 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Merge "merge" device_affinity="cpu0" ()
        ports_in (%outputPort_2954, %outputPort_2956 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2889 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__TwiddleGenerator__v__N_dyn "twiddles" (%c8_i32 : i32)
        ports_in (%outputPort_2860 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2865 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Radix2Cell "r2cell" device_affinity="cpu0" ()
        ports_in (%outputPort_2862, %outputPort_2864, %outputPort_2866 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2867, %inputPort_2869 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    %inputPort_2985, %outputPort_2986 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.fft__Butterfly$spec_9935405952460034831.__fanout_complex_f32__2.6.out0->split.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2987, %outputPort_2988 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.fft__Butterfly$spec_9935405952460034831.__fanout_complex_f32__2.6.out1->twiddles.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2989, %outputPort_2990 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.split.out0->r2cell.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2991, %outputPort_2992 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.split.out1->r2cell.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2993, %outputPort_2994 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.twiddles.out0->r2cell.in2"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2995, %outputPort_2996 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.r2cell.out0->fft__Butterfly$spec_9935405952460034831.fft__Butterfly$spec_1916938481276772234.4.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2997, %outputPort_2998 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.r2cell.out1->fft__Butterfly$spec_9935405952460034831.fft__Butterfly$spec_1916938481276772234.5.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_2999, %outputPort_3000 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.fft__Butterfly$spec_9935405952460034831.fft__Butterfly$spec_1916938481276772234.4.out0->merge.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3001, %outputPort_3002 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.fft__Butterfly$spec_9935405952460034831.fft__Butterfly$spec_1916938481276772234.5.out0->merge.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    cal.create_instance @fft__Radix2Cell "r2cell" device_affinity="cpu0" ()
        ports_in (%outputPort_2990, %outputPort_2992, %outputPort_2994 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2995, %inputPort_2997 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Split__v__N_dyn "split" (%c4_i32 : i32)
        ports_in (%outputPort_2986 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2989, %inputPort_2991 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Merge "merge" device_affinity="cpu0" ()
        ports_in (%outputPort_3000, %outputPort_3002 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2871 : !fifo.input_port<complex<f32>>)
    cal.create_instance @__fanout_complex_f32__2 "fft__Butterfly$spec_9935405952460034831.__fanout_complex_f32__2.6" device_affinity="cpu0" ()
        ports_in (%outputPort_2868 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2985, %inputPort_2987 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__TwiddleGenerator__v__N_dyn "twiddles" (%c4_i32 : i32)
        ports_in (%outputPort_2988 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2993 : !fifo.input_port<complex<f32>>)
    %inputPort_3003, %outputPort_3004 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_1916938481276772234.__fanout_complex_f32__2.6.out0->split.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3005, %outputPort_3006 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_1916938481276772234.__fanout_complex_f32__2.6.out1->twiddles.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3007, %outputPort_3008 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.split.out0->r2cell.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3009, %outputPort_3010 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.split.out1->r2cell.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3011, %outputPort_3012 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.twiddles.out0->r2cell.in2"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3013, %outputPort_3014 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.r2cell.out0->fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_15446289516955298258.4.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3015, %outputPort_3016 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.r2cell.out1->fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_15446289516955298258.5.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3017, %outputPort_3018 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_15446289516955298258.4.out0->merge.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3019, %outputPort_3020 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_15446289516955298258.5.out0->merge.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    cal.create_instance @fft__Radix2Cell "r2cell" device_affinity="cpu0" ()
        ports_in (%outputPort_3008, %outputPort_3010, %outputPort_3012 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3013, %inputPort_3015 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__TwiddleGenerator__v__N_dyn "twiddles" (%c2_i32 : i32)
        ports_in (%outputPort_3006 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3011 : !fifo.input_port<complex<f32>>)
    cal.create_instance @__fanout_complex_f32__2 "fft__Butterfly$spec_1916938481276772234.__fanout_complex_f32__2.6" device_affinity="cpu0" ()
        ports_in (%outputPort_2998 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3003, %inputPort_3005 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Split__v__N_dyn "split" (%c2_i32 : i32)
        ports_in (%outputPort_3004 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3007, %inputPort_3009 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    %inputPort_3021, %outputPort_3022 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4.out0->split.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3023, %outputPort_3024 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4.out1->twiddles.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3025, %outputPort_3026 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.split.out0->r2cell.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3027, %outputPort_3028 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.split.out1->r2cell.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3029, %outputPort_3030 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.twiddles.out0->r2cell.in2"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3031, %outputPort_3032 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.r2cell.out0->merge.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3033, %outputPort_3034 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.r2cell.out1->merge.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    cal.create_instance @fft__Merge "merge" device_affinity="cpu0" ()
        ports_in (%outputPort_3032, %outputPort_3034 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3017 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__TwiddleGenerator__v__N_dyn "twiddles" (%c1_i32 : i32)
        ports_in (%outputPort_3024 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3029 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Split__v__N_dyn "split" (%c1_i32 : i32)
        ports_in (%outputPort_3022 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3025, %inputPort_3027 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @__fanout_complex_f32__2 "fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4" device_affinity="cpu0" ()
        ports_in (%outputPort_3014 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3021, %inputPort_3023 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Radix2Cell "r2cell" device_affinity="cpu0" ()
        ports_in (%outputPort_3026, %outputPort_3028, %outputPort_3030 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3031, %inputPort_3033 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    %inputPort_3035, %outputPort_3036 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4.out0->split.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3037, %outputPort_3038 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4.out1->twiddles.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3039, %outputPort_3040 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.split.out0->r2cell.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3041, %outputPort_3042 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.split.out1->r2cell.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3043, %outputPort_3044 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.twiddles.out0->r2cell.in2"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3045, %outputPort_3046 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.r2cell.out0->merge.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3047, %outputPort_3048 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.r2cell.out1->merge.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    cal.create_instance @fft__Merge "merge" device_affinity="cpu0" ()
        ports_in (%outputPort_3046, %outputPort_3048 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3019 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__TwiddleGenerator__v__N_dyn "twiddles" (%c1_i32 : i32)
        ports_in (%outputPort_3038 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3043 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Split__v__N_dyn "split" (%c1_i32 : i32)
        ports_in (%outputPort_3036 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3039, %inputPort_3041 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @__fanout_complex_f32__2 "fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4" device_affinity="cpu0" ()
        ports_in (%outputPort_3016 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3035, %inputPort_3037 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Radix2Cell "r2cell" device_affinity="cpu0" ()
        ports_in (%outputPort_3040, %outputPort_3042, %outputPort_3044 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3045, %inputPort_3047 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Merge "merge" device_affinity="cpu0" ()
        ports_in (%outputPort_3018, %outputPort_3020 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3001 : !fifo.input_port<complex<f32>>)
    %inputPort_3049, %outputPort_3050 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_1916938481276772234.__fanout_complex_f32__2.6.out0->split.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3051, %outputPort_3052 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_1916938481276772234.__fanout_complex_f32__2.6.out1->twiddles.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3053, %outputPort_3054 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.split.out0->r2cell.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3055, %outputPort_3056 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.split.out1->r2cell.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3057, %outputPort_3058 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.twiddles.out0->r2cell.in2"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3059, %outputPort_3060 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.r2cell.out0->fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_15446289516955298258.4.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3061, %outputPort_3062 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.r2cell.out1->fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_15446289516955298258.5.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3063, %outputPort_3064 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_15446289516955298258.4.out0->merge.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3065, %outputPort_3066 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_15446289516955298258.5.out0->merge.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    cal.create_instance @fft__Radix2Cell "r2cell" device_affinity="cpu0" ()
        ports_in (%outputPort_3054, %outputPort_3056, %outputPort_3058 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3059, %inputPort_3061 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__TwiddleGenerator__v__N_dyn "twiddles" (%c2_i32 : i32)
        ports_in (%outputPort_3052 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3057 : !fifo.input_port<complex<f32>>)
    cal.create_instance @__fanout_complex_f32__2 "fft__Butterfly$spec_1916938481276772234.__fanout_complex_f32__2.6" device_affinity="cpu0" ()
        ports_in (%outputPort_2996 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3049, %inputPort_3051 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Split__v__N_dyn "split" (%c2_i32 : i32)
        ports_in (%outputPort_3050 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3053, %inputPort_3055 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    %inputPort_3067, %outputPort_3068 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4.out0->split.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3069, %outputPort_3070 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4.out1->twiddles.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3071, %outputPort_3072 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.split.out0->r2cell.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3073, %outputPort_3074 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.split.out1->r2cell.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3075, %outputPort_3076 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.twiddles.out0->r2cell.in2"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3077, %outputPort_3078 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.r2cell.out0->merge.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3079, %outputPort_3080 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.r2cell.out1->merge.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    cal.create_instance @fft__Merge "merge" device_affinity="cpu0" ()
        ports_in (%outputPort_3078, %outputPort_3080 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3063 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__TwiddleGenerator__v__N_dyn "twiddles" (%c1_i32 : i32)
        ports_in (%outputPort_3070 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3075 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Split__v__N_dyn "split" (%c1_i32 : i32)
        ports_in (%outputPort_3068 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3071, %inputPort_3073 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @__fanout_complex_f32__2 "fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4" device_affinity="cpu0" ()
        ports_in (%outputPort_3060 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3067, %inputPort_3069 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Radix2Cell "r2cell" device_affinity="cpu0" ()
        ports_in (%outputPort_3072, %outputPort_3074, %outputPort_3076 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3077, %inputPort_3079 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    %inputPort_3081, %outputPort_3082 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4.out0->split.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3083, %outputPort_3084 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4.out1->twiddles.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3085, %outputPort_3086 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.split.out0->r2cell.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3087, %outputPort_3088 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.split.out1->r2cell.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3089, %outputPort_3090 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.twiddles.out0->r2cell.in2"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3091, %outputPort_3092 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.r2cell.out0->merge.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3093, %outputPort_3094 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.r2cell.out1->merge.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    cal.create_instance @fft__Merge "merge" device_affinity="cpu0" ()
        ports_in (%outputPort_3092, %outputPort_3094 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3065 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__TwiddleGenerator__v__N_dyn "twiddles" (%c1_i32 : i32)
        ports_in (%outputPort_3084 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3089 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Split__v__N_dyn "split" (%c1_i32 : i32)
        ports_in (%outputPort_3082 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3085, %inputPort_3087 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @__fanout_complex_f32__2 "fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4" device_affinity="cpu0" ()
        ports_in (%outputPort_3062 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3081, %inputPort_3083 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Radix2Cell "r2cell" device_affinity="cpu0" ()
        ports_in (%outputPort_3086, %outputPort_3088, %outputPort_3090 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3091, %inputPort_3093 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Merge "merge" device_affinity="cpu0" ()
        ports_in (%outputPort_3064, %outputPort_3066 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2999 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Split__v__N_dyn "split" (%c8_i32 : i32)
        ports_in (%outputPort_2858 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2861, %inputPort_2863 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Split__v__N_dyn "split" (%c16_i32 : i32)
        ports_in (%outputPort_2602 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2605, %inputPort_2607 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Radix2Cell "r2cell" device_affinity="cpu0" ()
        ports_in (%outputPort_2076, %outputPort_2078, %outputPort_2080 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2081, %inputPort_2083 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__TwiddleGenerator__v__N_dyn "twiddles" (%c64_i32 : i32)
        ports_in (%outputPort_2074 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2079 : !fifo.input_port<complex<f32>>)
    %inputPort_3095, %outputPort_3096 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_17640631431051100303.fft__Butterfly$spec_17640631431051100303.__fanout_complex_f32__2.6.out0->split.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3097, %outputPort_3098 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_17640631431051100303.fft__Butterfly$spec_17640631431051100303.__fanout_complex_f32__2.6.out1->twiddles.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3099, %outputPort_3100 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_17640631431051100303.split.out0->r2cell.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3101, %outputPort_3102 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_17640631431051100303.split.out1->r2cell.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3103, %outputPort_3104 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_17640631431051100303.twiddles.out0->r2cell.in2"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3105, %outputPort_3106 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_17640631431051100303.r2cell.out0->fft__Butterfly$spec_17640631431051100303.fft__Butterfly$spec_3035977640463470463.4.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3107, %outputPort_3108 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_17640631431051100303.r2cell.out1->fft__Butterfly$spec_17640631431051100303.fft__Butterfly$spec_3035977640463470463.5.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3109, %outputPort_3110 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_17640631431051100303.fft__Butterfly$spec_17640631431051100303.fft__Butterfly$spec_3035977640463470463.4.out0->merge.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3111, %outputPort_3112 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_17640631431051100303.fft__Butterfly$spec_17640631431051100303.fft__Butterfly$spec_3035977640463470463.5.out0->merge.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    cal.create_instance @fft__Merge "merge" device_affinity="cpu0" ()
        ports_in (%outputPort_3110, %outputPort_3112 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_2087 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Split__v__N_dyn "split" (%c32_i32 : i32)
        ports_in (%outputPort_3096 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3099, %inputPort_3101 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    %inputPort_3113, %outputPort_3114 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_3035977640463470463.fft__Butterfly$spec_3035977640463470463.__fanout_complex_f32__2.6.out0->split.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3115, %outputPort_3116 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_3035977640463470463.fft__Butterfly$spec_3035977640463470463.__fanout_complex_f32__2.6.out1->twiddles.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3117, %outputPort_3118 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_3035977640463470463.split.out0->r2cell.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3119, %outputPort_3120 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_3035977640463470463.split.out1->r2cell.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3121, %outputPort_3122 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_3035977640463470463.twiddles.out0->r2cell.in2"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3123, %outputPort_3124 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_3035977640463470463.r2cell.out0->fft__Butterfly$spec_3035977640463470463.fft__Butterfly$spec_16755419077516047831.4.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3125, %outputPort_3126 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_3035977640463470463.r2cell.out1->fft__Butterfly$spec_3035977640463470463.fft__Butterfly$spec_16755419077516047831.5.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3127, %outputPort_3128 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_3035977640463470463.fft__Butterfly$spec_3035977640463470463.fft__Butterfly$spec_16755419077516047831.4.out0->merge.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3129, %outputPort_3130 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_3035977640463470463.fft__Butterfly$spec_3035977640463470463.fft__Butterfly$spec_16755419077516047831.5.out0->merge.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    cal.create_instance @fft__TwiddleGenerator__v__N_dyn "twiddles" (%c16_i32 : i32)
        ports_in (%outputPort_3116 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3121 : !fifo.input_port<complex<f32>>)
    %inputPort_3131, %outputPort_3132 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_16755419077516047831.fft__Butterfly$spec_16755419077516047831.__fanout_complex_f32__2.6.out0->split.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3133, %outputPort_3134 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_16755419077516047831.fft__Butterfly$spec_16755419077516047831.__fanout_complex_f32__2.6.out1->twiddles.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3135, %outputPort_3136 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_16755419077516047831.split.out0->r2cell.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3137, %outputPort_3138 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_16755419077516047831.split.out1->r2cell.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3139, %outputPort_3140 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_16755419077516047831.twiddles.out0->r2cell.in2"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3141, %outputPort_3142 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_16755419077516047831.r2cell.out0->fft__Butterfly$spec_16755419077516047831.fft__Butterfly$spec_9935405952460034831.4.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3143, %outputPort_3144 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_16755419077516047831.r2cell.out1->fft__Butterfly$spec_16755419077516047831.fft__Butterfly$spec_9935405952460034831.5.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3145, %outputPort_3146 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_16755419077516047831.fft__Butterfly$spec_16755419077516047831.fft__Butterfly$spec_9935405952460034831.4.out0->merge.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3147, %outputPort_3148 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_16755419077516047831.fft__Butterfly$spec_16755419077516047831.fft__Butterfly$spec_9935405952460034831.5.out0->merge.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    cal.create_instance @__fanout_complex_f32__2 "fft__Butterfly$spec_16755419077516047831.__fanout_complex_f32__2.6" device_affinity="cpu0" ()
        ports_in (%outputPort_3126 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3131, %inputPort_3133 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Merge "merge" device_affinity="cpu0" ()
        ports_in (%outputPort_3146, %outputPort_3148 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3129 : !fifo.input_port<complex<f32>>)
    %inputPort_3149, %outputPort_3150 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.fft__Butterfly$spec_9935405952460034831.__fanout_complex_f32__2.6.out0->split.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3151, %outputPort_3152 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.fft__Butterfly$spec_9935405952460034831.__fanout_complex_f32__2.6.out1->twiddles.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3153, %outputPort_3154 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.split.out0->r2cell.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3155, %outputPort_3156 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.split.out1->r2cell.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3157, %outputPort_3158 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.twiddles.out0->r2cell.in2"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3159, %outputPort_3160 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.r2cell.out0->fft__Butterfly$spec_9935405952460034831.fft__Butterfly$spec_1916938481276772234.4.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3161, %outputPort_3162 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.r2cell.out1->fft__Butterfly$spec_9935405952460034831.fft__Butterfly$spec_1916938481276772234.5.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3163, %outputPort_3164 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.fft__Butterfly$spec_9935405952460034831.fft__Butterfly$spec_1916938481276772234.4.out0->merge.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3165, %outputPort_3166 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.fft__Butterfly$spec_9935405952460034831.fft__Butterfly$spec_1916938481276772234.5.out0->merge.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    cal.create_instance @fft__Radix2Cell "r2cell" device_affinity="cpu0" ()
        ports_in (%outputPort_3154, %outputPort_3156, %outputPort_3158 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3159, %inputPort_3161 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Split__v__N_dyn "split" (%c4_i32 : i32)
        ports_in (%outputPort_3150 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3153, %inputPort_3155 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Merge "merge" device_affinity="cpu0" ()
        ports_in (%outputPort_3164, %outputPort_3166 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3147 : !fifo.input_port<complex<f32>>)
    cal.create_instance @__fanout_complex_f32__2 "fft__Butterfly$spec_9935405952460034831.__fanout_complex_f32__2.6" device_affinity="cpu0" ()
        ports_in (%outputPort_3144 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3149, %inputPort_3151 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__TwiddleGenerator__v__N_dyn "twiddles" (%c4_i32 : i32)
        ports_in (%outputPort_3152 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3157 : !fifo.input_port<complex<f32>>)
    %inputPort_3167, %outputPort_3168 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_1916938481276772234.__fanout_complex_f32__2.6.out0->split.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3169, %outputPort_3170 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_1916938481276772234.__fanout_complex_f32__2.6.out1->twiddles.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3171, %outputPort_3172 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.split.out0->r2cell.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3173, %outputPort_3174 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.split.out1->r2cell.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3175, %outputPort_3176 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.twiddles.out0->r2cell.in2"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3177, %outputPort_3178 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.r2cell.out0->fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_15446289516955298258.4.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3179, %outputPort_3180 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.r2cell.out1->fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_15446289516955298258.5.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3181, %outputPort_3182 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_15446289516955298258.4.out0->merge.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3183, %outputPort_3184 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_15446289516955298258.5.out0->merge.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    cal.create_instance @fft__Radix2Cell "r2cell" device_affinity="cpu0" ()
        ports_in (%outputPort_3172, %outputPort_3174, %outputPort_3176 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3177, %inputPort_3179 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__TwiddleGenerator__v__N_dyn "twiddles" (%c2_i32 : i32)
        ports_in (%outputPort_3170 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3175 : !fifo.input_port<complex<f32>>)
    cal.create_instance @__fanout_complex_f32__2 "fft__Butterfly$spec_1916938481276772234.__fanout_complex_f32__2.6" device_affinity="cpu0" ()
        ports_in (%outputPort_3162 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3167, %inputPort_3169 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Split__v__N_dyn "split" (%c2_i32 : i32)
        ports_in (%outputPort_3168 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3171, %inputPort_3173 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    %inputPort_3185, %outputPort_3186 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4.out0->split.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3187, %outputPort_3188 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4.out1->twiddles.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3189, %outputPort_3190 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.split.out0->r2cell.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3191, %outputPort_3192 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.split.out1->r2cell.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3193, %outputPort_3194 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.twiddles.out0->r2cell.in2"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3195, %outputPort_3196 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.r2cell.out0->merge.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3197, %outputPort_3198 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.r2cell.out1->merge.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    cal.create_instance @fft__Merge "merge" device_affinity="cpu0" ()
        ports_in (%outputPort_3196, %outputPort_3198 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3181 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__TwiddleGenerator__v__N_dyn "twiddles" (%c1_i32 : i32)
        ports_in (%outputPort_3188 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3193 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Split__v__N_dyn "split" (%c1_i32 : i32)
        ports_in (%outputPort_3186 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3189, %inputPort_3191 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @__fanout_complex_f32__2 "fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4" device_affinity="cpu0" ()
        ports_in (%outputPort_3178 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3185, %inputPort_3187 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Radix2Cell "r2cell" device_affinity="cpu0" ()
        ports_in (%outputPort_3190, %outputPort_3192, %outputPort_3194 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3195, %inputPort_3197 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    %inputPort_3199, %outputPort_3200 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4.out0->split.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3201, %outputPort_3202 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4.out1->twiddles.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3203, %outputPort_3204 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.split.out0->r2cell.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3205, %outputPort_3206 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.split.out1->r2cell.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3207, %outputPort_3208 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.twiddles.out0->r2cell.in2"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3209, %outputPort_3210 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.r2cell.out0->merge.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3211, %outputPort_3212 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.r2cell.out1->merge.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    cal.create_instance @fft__Merge "merge" device_affinity="cpu0" ()
        ports_in (%outputPort_3210, %outputPort_3212 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3183 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__TwiddleGenerator__v__N_dyn "twiddles" (%c1_i32 : i32)
        ports_in (%outputPort_3202 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3207 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Split__v__N_dyn "split" (%c1_i32 : i32)
        ports_in (%outputPort_3200 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3203, %inputPort_3205 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @__fanout_complex_f32__2 "fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4" device_affinity="cpu0" ()
        ports_in (%outputPort_3180 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3199, %inputPort_3201 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Radix2Cell "r2cell" device_affinity="cpu0" ()
        ports_in (%outputPort_3204, %outputPort_3206, %outputPort_3208 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3209, %inputPort_3211 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Merge "merge" device_affinity="cpu0" ()
        ports_in (%outputPort_3182, %outputPort_3184 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3165 : !fifo.input_port<complex<f32>>)
    %inputPort_3213, %outputPort_3214 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_1916938481276772234.__fanout_complex_f32__2.6.out0->split.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3215, %outputPort_3216 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_1916938481276772234.__fanout_complex_f32__2.6.out1->twiddles.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3217, %outputPort_3218 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.split.out0->r2cell.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3219, %outputPort_3220 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.split.out1->r2cell.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3221, %outputPort_3222 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.twiddles.out0->r2cell.in2"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3223, %outputPort_3224 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.r2cell.out0->fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_15446289516955298258.4.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3225, %outputPort_3226 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.r2cell.out1->fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_15446289516955298258.5.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3227, %outputPort_3228 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_15446289516955298258.4.out0->merge.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3229, %outputPort_3230 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_15446289516955298258.5.out0->merge.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    cal.create_instance @fft__Radix2Cell "r2cell" device_affinity="cpu0" ()
        ports_in (%outputPort_3218, %outputPort_3220, %outputPort_3222 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3223, %inputPort_3225 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__TwiddleGenerator__v__N_dyn "twiddles" (%c2_i32 : i32)
        ports_in (%outputPort_3216 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3221 : !fifo.input_port<complex<f32>>)
    cal.create_instance @__fanout_complex_f32__2 "fft__Butterfly$spec_1916938481276772234.__fanout_complex_f32__2.6" device_affinity="cpu0" ()
        ports_in (%outputPort_3160 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3213, %inputPort_3215 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Split__v__N_dyn "split" (%c2_i32 : i32)
        ports_in (%outputPort_3214 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3217, %inputPort_3219 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    %inputPort_3231, %outputPort_3232 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4.out0->split.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3233, %outputPort_3234 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4.out1->twiddles.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3235, %outputPort_3236 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.split.out0->r2cell.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3237, %outputPort_3238 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.split.out1->r2cell.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3239, %outputPort_3240 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.twiddles.out0->r2cell.in2"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3241, %outputPort_3242 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.r2cell.out0->merge.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3243, %outputPort_3244 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.r2cell.out1->merge.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    cal.create_instance @fft__Merge "merge" device_affinity="cpu0" ()
        ports_in (%outputPort_3242, %outputPort_3244 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3227 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__TwiddleGenerator__v__N_dyn "twiddles" (%c1_i32 : i32)
        ports_in (%outputPort_3234 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3239 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Split__v__N_dyn "split" (%c1_i32 : i32)
        ports_in (%outputPort_3232 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3235, %inputPort_3237 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @__fanout_complex_f32__2 "fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4" device_affinity="cpu0" ()
        ports_in (%outputPort_3224 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3231, %inputPort_3233 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Radix2Cell "r2cell" device_affinity="cpu0" ()
        ports_in (%outputPort_3236, %outputPort_3238, %outputPort_3240 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3241, %inputPort_3243 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    %inputPort_3245, %outputPort_3246 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4.out0->split.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3247, %outputPort_3248 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4.out1->twiddles.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3249, %outputPort_3250 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.split.out0->r2cell.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3251, %outputPort_3252 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.split.out1->r2cell.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3253, %outputPort_3254 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.twiddles.out0->r2cell.in2"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3255, %outputPort_3256 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.r2cell.out0->merge.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3257, %outputPort_3258 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.r2cell.out1->merge.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    cal.create_instance @fft__Merge "merge" device_affinity="cpu0" ()
        ports_in (%outputPort_3256, %outputPort_3258 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3229 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__TwiddleGenerator__v__N_dyn "twiddles" (%c1_i32 : i32)
        ports_in (%outputPort_3248 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3253 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Split__v__N_dyn "split" (%c1_i32 : i32)
        ports_in (%outputPort_3246 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3249, %inputPort_3251 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @__fanout_complex_f32__2 "fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4" device_affinity="cpu0" ()
        ports_in (%outputPort_3226 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3245, %inputPort_3247 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Radix2Cell "r2cell" device_affinity="cpu0" ()
        ports_in (%outputPort_3250, %outputPort_3252, %outputPort_3254 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3255, %inputPort_3257 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Merge "merge" device_affinity="cpu0" ()
        ports_in (%outputPort_3228, %outputPort_3230 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3163 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__TwiddleGenerator__v__N_dyn "twiddles" (%c8_i32 : i32)
        ports_in (%outputPort_3134 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3139 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Radix2Cell "r2cell" device_affinity="cpu0" ()
        ports_in (%outputPort_3136, %outputPort_3138, %outputPort_3140 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3141, %inputPort_3143 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    %inputPort_3259, %outputPort_3260 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.fft__Butterfly$spec_9935405952460034831.__fanout_complex_f32__2.6.out0->split.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3261, %outputPort_3262 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.fft__Butterfly$spec_9935405952460034831.__fanout_complex_f32__2.6.out1->twiddles.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3263, %outputPort_3264 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.split.out0->r2cell.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3265, %outputPort_3266 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.split.out1->r2cell.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3267, %outputPort_3268 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.twiddles.out0->r2cell.in2"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3269, %outputPort_3270 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.r2cell.out0->fft__Butterfly$spec_9935405952460034831.fft__Butterfly$spec_1916938481276772234.4.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3271, %outputPort_3272 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.r2cell.out1->fft__Butterfly$spec_9935405952460034831.fft__Butterfly$spec_1916938481276772234.5.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3273, %outputPort_3274 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.fft__Butterfly$spec_9935405952460034831.fft__Butterfly$spec_1916938481276772234.4.out0->merge.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3275, %outputPort_3276 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.fft__Butterfly$spec_9935405952460034831.fft__Butterfly$spec_1916938481276772234.5.out0->merge.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    cal.create_instance @fft__Radix2Cell "r2cell" device_affinity="cpu0" ()
        ports_in (%outputPort_3264, %outputPort_3266, %outputPort_3268 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3269, %inputPort_3271 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Split__v__N_dyn "split" (%c4_i32 : i32)
        ports_in (%outputPort_3260 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3263, %inputPort_3265 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Merge "merge" device_affinity="cpu0" ()
        ports_in (%outputPort_3274, %outputPort_3276 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3145 : !fifo.input_port<complex<f32>>)
    cal.create_instance @__fanout_complex_f32__2 "fft__Butterfly$spec_9935405952460034831.__fanout_complex_f32__2.6" device_affinity="cpu0" ()
        ports_in (%outputPort_3142 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3259, %inputPort_3261 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__TwiddleGenerator__v__N_dyn "twiddles" (%c4_i32 : i32)
        ports_in (%outputPort_3262 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3267 : !fifo.input_port<complex<f32>>)
    %inputPort_3277, %outputPort_3278 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_1916938481276772234.__fanout_complex_f32__2.6.out0->split.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3279, %outputPort_3280 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_1916938481276772234.__fanout_complex_f32__2.6.out1->twiddles.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3281, %outputPort_3282 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.split.out0->r2cell.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3283, %outputPort_3284 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.split.out1->r2cell.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3285, %outputPort_3286 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.twiddles.out0->r2cell.in2"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3287, %outputPort_3288 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.r2cell.out0->fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_15446289516955298258.4.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3289, %outputPort_3290 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.r2cell.out1->fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_15446289516955298258.5.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3291, %outputPort_3292 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_15446289516955298258.4.out0->merge.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3293, %outputPort_3294 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_15446289516955298258.5.out0->merge.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    cal.create_instance @fft__Radix2Cell "r2cell" device_affinity="cpu0" ()
        ports_in (%outputPort_3282, %outputPort_3284, %outputPort_3286 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3287, %inputPort_3289 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__TwiddleGenerator__v__N_dyn "twiddles" (%c2_i32 : i32)
        ports_in (%outputPort_3280 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3285 : !fifo.input_port<complex<f32>>)
    cal.create_instance @__fanout_complex_f32__2 "fft__Butterfly$spec_1916938481276772234.__fanout_complex_f32__2.6" device_affinity="cpu0" ()
        ports_in (%outputPort_3272 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3277, %inputPort_3279 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Split__v__N_dyn "split" (%c2_i32 : i32)
        ports_in (%outputPort_3278 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3281, %inputPort_3283 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    %inputPort_3295, %outputPort_3296 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4.out0->split.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3297, %outputPort_3298 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4.out1->twiddles.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3299, %outputPort_3300 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.split.out0->r2cell.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3301, %outputPort_3302 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.split.out1->r2cell.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3303, %outputPort_3304 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.twiddles.out0->r2cell.in2"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3305, %outputPort_3306 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.r2cell.out0->merge.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3307, %outputPort_3308 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.r2cell.out1->merge.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    cal.create_instance @fft__Merge "merge" device_affinity="cpu0" ()
        ports_in (%outputPort_3306, %outputPort_3308 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3291 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__TwiddleGenerator__v__N_dyn "twiddles" (%c1_i32 : i32)
        ports_in (%outputPort_3298 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3303 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Split__v__N_dyn "split" (%c1_i32 : i32)
        ports_in (%outputPort_3296 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3299, %inputPort_3301 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @__fanout_complex_f32__2 "fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4" device_affinity="cpu0" ()
        ports_in (%outputPort_3288 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3295, %inputPort_3297 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Radix2Cell "r2cell" device_affinity="cpu0" ()
        ports_in (%outputPort_3300, %outputPort_3302, %outputPort_3304 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3305, %inputPort_3307 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    %inputPort_3309, %outputPort_3310 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4.out0->split.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3311, %outputPort_3312 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4.out1->twiddles.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3313, %outputPort_3314 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.split.out0->r2cell.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3315, %outputPort_3316 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.split.out1->r2cell.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3317, %outputPort_3318 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.twiddles.out0->r2cell.in2"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3319, %outputPort_3320 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.r2cell.out0->merge.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3321, %outputPort_3322 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.r2cell.out1->merge.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    cal.create_instance @fft__Merge "merge" device_affinity="cpu0" ()
        ports_in (%outputPort_3320, %outputPort_3322 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3293 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__TwiddleGenerator__v__N_dyn "twiddles" (%c1_i32 : i32)
        ports_in (%outputPort_3312 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3317 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Split__v__N_dyn "split" (%c1_i32 : i32)
        ports_in (%outputPort_3310 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3313, %inputPort_3315 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @__fanout_complex_f32__2 "fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4" device_affinity="cpu0" ()
        ports_in (%outputPort_3290 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3309, %inputPort_3311 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Radix2Cell "r2cell" device_affinity="cpu0" ()
        ports_in (%outputPort_3314, %outputPort_3316, %outputPort_3318 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3319, %inputPort_3321 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Merge "merge" device_affinity="cpu0" ()
        ports_in (%outputPort_3292, %outputPort_3294 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3275 : !fifo.input_port<complex<f32>>)
    %inputPort_3323, %outputPort_3324 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_1916938481276772234.__fanout_complex_f32__2.6.out0->split.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3325, %outputPort_3326 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_1916938481276772234.__fanout_complex_f32__2.6.out1->twiddles.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3327, %outputPort_3328 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.split.out0->r2cell.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3329, %outputPort_3330 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.split.out1->r2cell.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3331, %outputPort_3332 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.twiddles.out0->r2cell.in2"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3333, %outputPort_3334 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.r2cell.out0->fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_15446289516955298258.4.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3335, %outputPort_3336 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.r2cell.out1->fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_15446289516955298258.5.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3337, %outputPort_3338 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_15446289516955298258.4.out0->merge.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3339, %outputPort_3340 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_15446289516955298258.5.out0->merge.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    cal.create_instance @fft__Radix2Cell "r2cell" device_affinity="cpu0" ()
        ports_in (%outputPort_3328, %outputPort_3330, %outputPort_3332 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3333, %inputPort_3335 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__TwiddleGenerator__v__N_dyn "twiddles" (%c2_i32 : i32)
        ports_in (%outputPort_3326 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3331 : !fifo.input_port<complex<f32>>)
    cal.create_instance @__fanout_complex_f32__2 "fft__Butterfly$spec_1916938481276772234.__fanout_complex_f32__2.6" device_affinity="cpu0" ()
        ports_in (%outputPort_3270 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3323, %inputPort_3325 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Split__v__N_dyn "split" (%c2_i32 : i32)
        ports_in (%outputPort_3324 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3327, %inputPort_3329 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    %inputPort_3341, %outputPort_3342 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4.out0->split.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3343, %outputPort_3344 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4.out1->twiddles.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3345, %outputPort_3346 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.split.out0->r2cell.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3347, %outputPort_3348 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.split.out1->r2cell.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3349, %outputPort_3350 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.twiddles.out0->r2cell.in2"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3351, %outputPort_3352 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.r2cell.out0->merge.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3353, %outputPort_3354 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.r2cell.out1->merge.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    cal.create_instance @fft__Merge "merge" device_affinity="cpu0" ()
        ports_in (%outputPort_3352, %outputPort_3354 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3337 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__TwiddleGenerator__v__N_dyn "twiddles" (%c1_i32 : i32)
        ports_in (%outputPort_3344 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3349 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Split__v__N_dyn "split" (%c1_i32 : i32)
        ports_in (%outputPort_3342 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3345, %inputPort_3347 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @__fanout_complex_f32__2 "fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4" device_affinity="cpu0" ()
        ports_in (%outputPort_3334 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3341, %inputPort_3343 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Radix2Cell "r2cell" device_affinity="cpu0" ()
        ports_in (%outputPort_3346, %outputPort_3348, %outputPort_3350 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3351, %inputPort_3353 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    %inputPort_3355, %outputPort_3356 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4.out0->split.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3357, %outputPort_3358 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4.out1->twiddles.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3359, %outputPort_3360 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.split.out0->r2cell.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3361, %outputPort_3362 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.split.out1->r2cell.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3363, %outputPort_3364 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.twiddles.out0->r2cell.in2"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3365, %outputPort_3366 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.r2cell.out0->merge.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3367, %outputPort_3368 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.r2cell.out1->merge.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    cal.create_instance @fft__Merge "merge" device_affinity="cpu0" ()
        ports_in (%outputPort_3366, %outputPort_3368 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3339 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__TwiddleGenerator__v__N_dyn "twiddles" (%c1_i32 : i32)
        ports_in (%outputPort_3358 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3363 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Split__v__N_dyn "split" (%c1_i32 : i32)
        ports_in (%outputPort_3356 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3359, %inputPort_3361 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @__fanout_complex_f32__2 "fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4" device_affinity="cpu0" ()
        ports_in (%outputPort_3336 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3355, %inputPort_3357 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Radix2Cell "r2cell" device_affinity="cpu0" ()
        ports_in (%outputPort_3360, %outputPort_3362, %outputPort_3364 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3365, %inputPort_3367 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Merge "merge" device_affinity="cpu0" ()
        ports_in (%outputPort_3338, %outputPort_3340 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3273 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Split__v__N_dyn "split" (%c8_i32 : i32)
        ports_in (%outputPort_3132 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3135, %inputPort_3137 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Radix2Cell "r2cell" device_affinity="cpu0" ()
        ports_in (%outputPort_3118, %outputPort_3120, %outputPort_3122 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3123, %inputPort_3125 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Merge "merge" device_affinity="cpu0" ()
        ports_in (%outputPort_3128, %outputPort_3130 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3109 : !fifo.input_port<complex<f32>>)
    cal.create_instance @__fanout_complex_f32__2 "fft__Butterfly$spec_3035977640463470463.__fanout_complex_f32__2.6" device_affinity="cpu0" ()
        ports_in (%outputPort_3106 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3113, %inputPort_3115 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    %inputPort_3369, %outputPort_3370 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_16755419077516047831.fft__Butterfly$spec_16755419077516047831.__fanout_complex_f32__2.6.out0->split.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3371, %outputPort_3372 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_16755419077516047831.fft__Butterfly$spec_16755419077516047831.__fanout_complex_f32__2.6.out1->twiddles.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3373, %outputPort_3374 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_16755419077516047831.split.out0->r2cell.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3375, %outputPort_3376 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_16755419077516047831.split.out1->r2cell.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3377, %outputPort_3378 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_16755419077516047831.twiddles.out0->r2cell.in2"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3379, %outputPort_3380 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_16755419077516047831.r2cell.out0->fft__Butterfly$spec_16755419077516047831.fft__Butterfly$spec_9935405952460034831.4.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3381, %outputPort_3382 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_16755419077516047831.r2cell.out1->fft__Butterfly$spec_16755419077516047831.fft__Butterfly$spec_9935405952460034831.5.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3383, %outputPort_3384 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_16755419077516047831.fft__Butterfly$spec_16755419077516047831.fft__Butterfly$spec_9935405952460034831.4.out0->merge.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3385, %outputPort_3386 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_16755419077516047831.fft__Butterfly$spec_16755419077516047831.fft__Butterfly$spec_9935405952460034831.5.out0->merge.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    cal.create_instance @__fanout_complex_f32__2 "fft__Butterfly$spec_16755419077516047831.__fanout_complex_f32__2.6" device_affinity="cpu0" ()
        ports_in (%outputPort_3124 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3369, %inputPort_3371 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Merge "merge" device_affinity="cpu0" ()
        ports_in (%outputPort_3384, %outputPort_3386 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3127 : !fifo.input_port<complex<f32>>)
    %inputPort_3387, %outputPort_3388 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.fft__Butterfly$spec_9935405952460034831.__fanout_complex_f32__2.6.out0->split.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3389, %outputPort_3390 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.fft__Butterfly$spec_9935405952460034831.__fanout_complex_f32__2.6.out1->twiddles.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3391, %outputPort_3392 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.split.out0->r2cell.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3393, %outputPort_3394 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.split.out1->r2cell.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3395, %outputPort_3396 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.twiddles.out0->r2cell.in2"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3397, %outputPort_3398 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.r2cell.out0->fft__Butterfly$spec_9935405952460034831.fft__Butterfly$spec_1916938481276772234.4.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3399, %outputPort_3400 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.r2cell.out1->fft__Butterfly$spec_9935405952460034831.fft__Butterfly$spec_1916938481276772234.5.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3401, %outputPort_3402 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.fft__Butterfly$spec_9935405952460034831.fft__Butterfly$spec_1916938481276772234.4.out0->merge.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3403, %outputPort_3404 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.fft__Butterfly$spec_9935405952460034831.fft__Butterfly$spec_1916938481276772234.5.out0->merge.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    cal.create_instance @fft__Radix2Cell "r2cell" device_affinity="cpu0" ()
        ports_in (%outputPort_3392, %outputPort_3394, %outputPort_3396 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3397, %inputPort_3399 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Split__v__N_dyn "split" (%c4_i32 : i32)
        ports_in (%outputPort_3388 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3391, %inputPort_3393 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Merge "merge" device_affinity="cpu0" ()
        ports_in (%outputPort_3402, %outputPort_3404 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3385 : !fifo.input_port<complex<f32>>)
    cal.create_instance @__fanout_complex_f32__2 "fft__Butterfly$spec_9935405952460034831.__fanout_complex_f32__2.6" device_affinity="cpu0" ()
        ports_in (%outputPort_3382 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3387, %inputPort_3389 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__TwiddleGenerator__v__N_dyn "twiddles" (%c4_i32 : i32)
        ports_in (%outputPort_3390 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3395 : !fifo.input_port<complex<f32>>)
    %inputPort_3405, %outputPort_3406 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_1916938481276772234.__fanout_complex_f32__2.6.out0->split.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3407, %outputPort_3408 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_1916938481276772234.__fanout_complex_f32__2.6.out1->twiddles.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3409, %outputPort_3410 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.split.out0->r2cell.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3411, %outputPort_3412 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.split.out1->r2cell.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3413, %outputPort_3414 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.twiddles.out0->r2cell.in2"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3415, %outputPort_3416 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.r2cell.out0->fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_15446289516955298258.4.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3417, %outputPort_3418 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.r2cell.out1->fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_15446289516955298258.5.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3419, %outputPort_3420 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_15446289516955298258.4.out0->merge.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3421, %outputPort_3422 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_15446289516955298258.5.out0->merge.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    cal.create_instance @fft__Radix2Cell "r2cell" device_affinity="cpu0" ()
        ports_in (%outputPort_3410, %outputPort_3412, %outputPort_3414 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3415, %inputPort_3417 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__TwiddleGenerator__v__N_dyn "twiddles" (%c2_i32 : i32)
        ports_in (%outputPort_3408 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3413 : !fifo.input_port<complex<f32>>)
    cal.create_instance @__fanout_complex_f32__2 "fft__Butterfly$spec_1916938481276772234.__fanout_complex_f32__2.6" device_affinity="cpu0" ()
        ports_in (%outputPort_3400 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3405, %inputPort_3407 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Split__v__N_dyn "split" (%c2_i32 : i32)
        ports_in (%outputPort_3406 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3409, %inputPort_3411 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    %inputPort_3423, %outputPort_3424 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4.out0->split.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3425, %outputPort_3426 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4.out1->twiddles.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3427, %outputPort_3428 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.split.out0->r2cell.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3429, %outputPort_3430 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.split.out1->r2cell.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3431, %outputPort_3432 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.twiddles.out0->r2cell.in2"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3433, %outputPort_3434 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.r2cell.out0->merge.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3435, %outputPort_3436 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.r2cell.out1->merge.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    cal.create_instance @fft__Merge "merge" device_affinity="cpu0" ()
        ports_in (%outputPort_3434, %outputPort_3436 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3419 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__TwiddleGenerator__v__N_dyn "twiddles" (%c1_i32 : i32)
        ports_in (%outputPort_3426 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3431 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Split__v__N_dyn "split" (%c1_i32 : i32)
        ports_in (%outputPort_3424 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3427, %inputPort_3429 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @__fanout_complex_f32__2 "fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4" device_affinity="cpu0" ()
        ports_in (%outputPort_3416 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3423, %inputPort_3425 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Radix2Cell "r2cell" device_affinity="cpu0" ()
        ports_in (%outputPort_3428, %outputPort_3430, %outputPort_3432 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3433, %inputPort_3435 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    %inputPort_3437, %outputPort_3438 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4.out0->split.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3439, %outputPort_3440 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4.out1->twiddles.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3441, %outputPort_3442 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.split.out0->r2cell.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3443, %outputPort_3444 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.split.out1->r2cell.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3445, %outputPort_3446 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.twiddles.out0->r2cell.in2"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3447, %outputPort_3448 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.r2cell.out0->merge.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3449, %outputPort_3450 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.r2cell.out1->merge.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    cal.create_instance @fft__Merge "merge" device_affinity="cpu0" ()
        ports_in (%outputPort_3448, %outputPort_3450 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3421 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__TwiddleGenerator__v__N_dyn "twiddles" (%c1_i32 : i32)
        ports_in (%outputPort_3440 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3445 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Split__v__N_dyn "split" (%c1_i32 : i32)
        ports_in (%outputPort_3438 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3441, %inputPort_3443 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @__fanout_complex_f32__2 "fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4" device_affinity="cpu0" ()
        ports_in (%outputPort_3418 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3437, %inputPort_3439 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Radix2Cell "r2cell" device_affinity="cpu0" ()
        ports_in (%outputPort_3442, %outputPort_3444, %outputPort_3446 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3447, %inputPort_3449 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Merge "merge" device_affinity="cpu0" ()
        ports_in (%outputPort_3420, %outputPort_3422 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3403 : !fifo.input_port<complex<f32>>)
    %inputPort_3451, %outputPort_3452 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_1916938481276772234.__fanout_complex_f32__2.6.out0->split.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3453, %outputPort_3454 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_1916938481276772234.__fanout_complex_f32__2.6.out1->twiddles.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3455, %outputPort_3456 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.split.out0->r2cell.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3457, %outputPort_3458 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.split.out1->r2cell.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3459, %outputPort_3460 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.twiddles.out0->r2cell.in2"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3461, %outputPort_3462 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.r2cell.out0->fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_15446289516955298258.4.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3463, %outputPort_3464 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.r2cell.out1->fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_15446289516955298258.5.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3465, %outputPort_3466 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_15446289516955298258.4.out0->merge.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3467, %outputPort_3468 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_15446289516955298258.5.out0->merge.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    cal.create_instance @fft__Radix2Cell "r2cell" device_affinity="cpu0" ()
        ports_in (%outputPort_3456, %outputPort_3458, %outputPort_3460 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3461, %inputPort_3463 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__TwiddleGenerator__v__N_dyn "twiddles" (%c2_i32 : i32)
        ports_in (%outputPort_3454 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3459 : !fifo.input_port<complex<f32>>)
    cal.create_instance @__fanout_complex_f32__2 "fft__Butterfly$spec_1916938481276772234.__fanout_complex_f32__2.6" device_affinity="cpu0" ()
        ports_in (%outputPort_3398 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3451, %inputPort_3453 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Split__v__N_dyn "split" (%c2_i32 : i32)
        ports_in (%outputPort_3452 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3455, %inputPort_3457 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    %inputPort_3469, %outputPort_3470 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4.out0->split.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3471, %outputPort_3472 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4.out1->twiddles.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3473, %outputPort_3474 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.split.out0->r2cell.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3475, %outputPort_3476 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.split.out1->r2cell.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3477, %outputPort_3478 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.twiddles.out0->r2cell.in2"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3479, %outputPort_3480 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.r2cell.out0->merge.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3481, %outputPort_3482 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.r2cell.out1->merge.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    cal.create_instance @fft__Merge "merge" device_affinity="cpu0" ()
        ports_in (%outputPort_3480, %outputPort_3482 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3465 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__TwiddleGenerator__v__N_dyn "twiddles" (%c1_i32 : i32)
        ports_in (%outputPort_3472 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3477 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Split__v__N_dyn "split" (%c1_i32 : i32)
        ports_in (%outputPort_3470 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3473, %inputPort_3475 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @__fanout_complex_f32__2 "fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4" device_affinity="cpu0" ()
        ports_in (%outputPort_3462 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3469, %inputPort_3471 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Radix2Cell "r2cell" device_affinity="cpu0" ()
        ports_in (%outputPort_3474, %outputPort_3476, %outputPort_3478 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3479, %inputPort_3481 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    %inputPort_3483, %outputPort_3484 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4.out0->split.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3485, %outputPort_3486 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4.out1->twiddles.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3487, %outputPort_3488 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.split.out0->r2cell.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3489, %outputPort_3490 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.split.out1->r2cell.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3491, %outputPort_3492 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.twiddles.out0->r2cell.in2"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3493, %outputPort_3494 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.r2cell.out0->merge.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3495, %outputPort_3496 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.r2cell.out1->merge.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    cal.create_instance @fft__Merge "merge" device_affinity="cpu0" ()
        ports_in (%outputPort_3494, %outputPort_3496 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3467 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__TwiddleGenerator__v__N_dyn "twiddles" (%c1_i32 : i32)
        ports_in (%outputPort_3486 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3491 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Split__v__N_dyn "split" (%c1_i32 : i32)
        ports_in (%outputPort_3484 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3487, %inputPort_3489 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @__fanout_complex_f32__2 "fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4" device_affinity="cpu0" ()
        ports_in (%outputPort_3464 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3483, %inputPort_3485 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Radix2Cell "r2cell" device_affinity="cpu0" ()
        ports_in (%outputPort_3488, %outputPort_3490, %outputPort_3492 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3493, %inputPort_3495 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Merge "merge" device_affinity="cpu0" ()
        ports_in (%outputPort_3466, %outputPort_3468 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3401 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__TwiddleGenerator__v__N_dyn "twiddles" (%c8_i32 : i32)
        ports_in (%outputPort_3372 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3377 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Radix2Cell "r2cell" device_affinity="cpu0" ()
        ports_in (%outputPort_3374, %outputPort_3376, %outputPort_3378 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3379, %inputPort_3381 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    %inputPort_3497, %outputPort_3498 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.fft__Butterfly$spec_9935405952460034831.__fanout_complex_f32__2.6.out0->split.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3499, %outputPort_3500 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.fft__Butterfly$spec_9935405952460034831.__fanout_complex_f32__2.6.out1->twiddles.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3501, %outputPort_3502 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.split.out0->r2cell.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3503, %outputPort_3504 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.split.out1->r2cell.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3505, %outputPort_3506 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.twiddles.out0->r2cell.in2"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3507, %outputPort_3508 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.r2cell.out0->fft__Butterfly$spec_9935405952460034831.fft__Butterfly$spec_1916938481276772234.4.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3509, %outputPort_3510 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.r2cell.out1->fft__Butterfly$spec_9935405952460034831.fft__Butterfly$spec_1916938481276772234.5.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3511, %outputPort_3512 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.fft__Butterfly$spec_9935405952460034831.fft__Butterfly$spec_1916938481276772234.4.out0->merge.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3513, %outputPort_3514 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.fft__Butterfly$spec_9935405952460034831.fft__Butterfly$spec_1916938481276772234.5.out0->merge.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    cal.create_instance @fft__Radix2Cell "r2cell" device_affinity="cpu0" ()
        ports_in (%outputPort_3502, %outputPort_3504, %outputPort_3506 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3507, %inputPort_3509 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Split__v__N_dyn "split" (%c4_i32 : i32)
        ports_in (%outputPort_3498 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3501, %inputPort_3503 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Merge "merge" device_affinity="cpu0" ()
        ports_in (%outputPort_3512, %outputPort_3514 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3383 : !fifo.input_port<complex<f32>>)
    cal.create_instance @__fanout_complex_f32__2 "fft__Butterfly$spec_9935405952460034831.__fanout_complex_f32__2.6" device_affinity="cpu0" ()
        ports_in (%outputPort_3380 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3497, %inputPort_3499 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__TwiddleGenerator__v__N_dyn "twiddles" (%c4_i32 : i32)
        ports_in (%outputPort_3500 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3505 : !fifo.input_port<complex<f32>>)
    %inputPort_3515, %outputPort_3516 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_1916938481276772234.__fanout_complex_f32__2.6.out0->split.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3517, %outputPort_3518 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_1916938481276772234.__fanout_complex_f32__2.6.out1->twiddles.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3519, %outputPort_3520 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.split.out0->r2cell.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3521, %outputPort_3522 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.split.out1->r2cell.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3523, %outputPort_3524 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.twiddles.out0->r2cell.in2"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3525, %outputPort_3526 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.r2cell.out0->fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_15446289516955298258.4.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3527, %outputPort_3528 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.r2cell.out1->fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_15446289516955298258.5.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3529, %outputPort_3530 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_15446289516955298258.4.out0->merge.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3531, %outputPort_3532 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_15446289516955298258.5.out0->merge.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    cal.create_instance @fft__Radix2Cell "r2cell" device_affinity="cpu0" ()
        ports_in (%outputPort_3520, %outputPort_3522, %outputPort_3524 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3525, %inputPort_3527 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__TwiddleGenerator__v__N_dyn "twiddles" (%c2_i32 : i32)
        ports_in (%outputPort_3518 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3523 : !fifo.input_port<complex<f32>>)
    cal.create_instance @__fanout_complex_f32__2 "fft__Butterfly$spec_1916938481276772234.__fanout_complex_f32__2.6" device_affinity="cpu0" ()
        ports_in (%outputPort_3510 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3515, %inputPort_3517 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Split__v__N_dyn "split" (%c2_i32 : i32)
        ports_in (%outputPort_3516 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3519, %inputPort_3521 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    %inputPort_3533, %outputPort_3534 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4.out0->split.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3535, %outputPort_3536 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4.out1->twiddles.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3537, %outputPort_3538 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.split.out0->r2cell.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3539, %outputPort_3540 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.split.out1->r2cell.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3541, %outputPort_3542 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.twiddles.out0->r2cell.in2"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3543, %outputPort_3544 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.r2cell.out0->merge.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3545, %outputPort_3546 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.r2cell.out1->merge.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    cal.create_instance @fft__Merge "merge" device_affinity="cpu0" ()
        ports_in (%outputPort_3544, %outputPort_3546 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3529 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__TwiddleGenerator__v__N_dyn "twiddles" (%c1_i32 : i32)
        ports_in (%outputPort_3536 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3541 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Split__v__N_dyn "split" (%c1_i32 : i32)
        ports_in (%outputPort_3534 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3537, %inputPort_3539 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @__fanout_complex_f32__2 "fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4" device_affinity="cpu0" ()
        ports_in (%outputPort_3526 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3533, %inputPort_3535 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Radix2Cell "r2cell" device_affinity="cpu0" ()
        ports_in (%outputPort_3538, %outputPort_3540, %outputPort_3542 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3543, %inputPort_3545 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    %inputPort_3547, %outputPort_3548 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4.out0->split.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3549, %outputPort_3550 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4.out1->twiddles.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3551, %outputPort_3552 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.split.out0->r2cell.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3553, %outputPort_3554 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.split.out1->r2cell.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3555, %outputPort_3556 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.twiddles.out0->r2cell.in2"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3557, %outputPort_3558 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.r2cell.out0->merge.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3559, %outputPort_3560 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.r2cell.out1->merge.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    cal.create_instance @fft__Merge "merge" device_affinity="cpu0" ()
        ports_in (%outputPort_3558, %outputPort_3560 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3531 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__TwiddleGenerator__v__N_dyn "twiddles" (%c1_i32 : i32)
        ports_in (%outputPort_3550 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3555 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Split__v__N_dyn "split" (%c1_i32 : i32)
        ports_in (%outputPort_3548 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3551, %inputPort_3553 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @__fanout_complex_f32__2 "fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4" device_affinity="cpu0" ()
        ports_in (%outputPort_3528 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3547, %inputPort_3549 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Radix2Cell "r2cell" device_affinity="cpu0" ()
        ports_in (%outputPort_3552, %outputPort_3554, %outputPort_3556 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3557, %inputPort_3559 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Merge "merge" device_affinity="cpu0" ()
        ports_in (%outputPort_3530, %outputPort_3532 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3513 : !fifo.input_port<complex<f32>>)
    %inputPort_3561, %outputPort_3562 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_1916938481276772234.__fanout_complex_f32__2.6.out0->split.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3563, %outputPort_3564 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_1916938481276772234.__fanout_complex_f32__2.6.out1->twiddles.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3565, %outputPort_3566 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.split.out0->r2cell.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3567, %outputPort_3568 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.split.out1->r2cell.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3569, %outputPort_3570 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.twiddles.out0->r2cell.in2"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3571, %outputPort_3572 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.r2cell.out0->fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_15446289516955298258.4.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3573, %outputPort_3574 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.r2cell.out1->fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_15446289516955298258.5.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3575, %outputPort_3576 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_15446289516955298258.4.out0->merge.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3577, %outputPort_3578 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_15446289516955298258.5.out0->merge.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    cal.create_instance @fft__Radix2Cell "r2cell" device_affinity="cpu0" ()
        ports_in (%outputPort_3566, %outputPort_3568, %outputPort_3570 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3571, %inputPort_3573 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__TwiddleGenerator__v__N_dyn "twiddles" (%c2_i32 : i32)
        ports_in (%outputPort_3564 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3569 : !fifo.input_port<complex<f32>>)
    cal.create_instance @__fanout_complex_f32__2 "fft__Butterfly$spec_1916938481276772234.__fanout_complex_f32__2.6" device_affinity="cpu0" ()
        ports_in (%outputPort_3508 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3561, %inputPort_3563 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Split__v__N_dyn "split" (%c2_i32 : i32)
        ports_in (%outputPort_3562 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3565, %inputPort_3567 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    %inputPort_3579, %outputPort_3580 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4.out0->split.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3581, %outputPort_3582 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4.out1->twiddles.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3583, %outputPort_3584 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.split.out0->r2cell.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3585, %outputPort_3586 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.split.out1->r2cell.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3587, %outputPort_3588 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.twiddles.out0->r2cell.in2"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3589, %outputPort_3590 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.r2cell.out0->merge.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3591, %outputPort_3592 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.r2cell.out1->merge.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    cal.create_instance @fft__Merge "merge" device_affinity="cpu0" ()
        ports_in (%outputPort_3590, %outputPort_3592 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3575 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__TwiddleGenerator__v__N_dyn "twiddles" (%c1_i32 : i32)
        ports_in (%outputPort_3582 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3587 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Split__v__N_dyn "split" (%c1_i32 : i32)
        ports_in (%outputPort_3580 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3583, %inputPort_3585 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @__fanout_complex_f32__2 "fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4" device_affinity="cpu0" ()
        ports_in (%outputPort_3572 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3579, %inputPort_3581 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Radix2Cell "r2cell" device_affinity="cpu0" ()
        ports_in (%outputPort_3584, %outputPort_3586, %outputPort_3588 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3589, %inputPort_3591 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    %inputPort_3593, %outputPort_3594 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4.out0->split.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3595, %outputPort_3596 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4.out1->twiddles.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3597, %outputPort_3598 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.split.out0->r2cell.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3599, %outputPort_3600 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.split.out1->r2cell.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3601, %outputPort_3602 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.twiddles.out0->r2cell.in2"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3603, %outputPort_3604 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.r2cell.out0->merge.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3605, %outputPort_3606 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.r2cell.out1->merge.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    cal.create_instance @fft__Merge "merge" device_affinity="cpu0" ()
        ports_in (%outputPort_3604, %outputPort_3606 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3577 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__TwiddleGenerator__v__N_dyn "twiddles" (%c1_i32 : i32)
        ports_in (%outputPort_3596 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3601 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Split__v__N_dyn "split" (%c1_i32 : i32)
        ports_in (%outputPort_3594 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3597, %inputPort_3599 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @__fanout_complex_f32__2 "fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4" device_affinity="cpu0" ()
        ports_in (%outputPort_3574 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3593, %inputPort_3595 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Radix2Cell "r2cell" device_affinity="cpu0" ()
        ports_in (%outputPort_3598, %outputPort_3600, %outputPort_3602 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3603, %inputPort_3605 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Merge "merge" device_affinity="cpu0" ()
        ports_in (%outputPort_3576, %outputPort_3578 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3511 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Split__v__N_dyn "split" (%c8_i32 : i32)
        ports_in (%outputPort_3370 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3373, %inputPort_3375 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Split__v__N_dyn "split" (%c16_i32 : i32)
        ports_in (%outputPort_3114 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3117, %inputPort_3119 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Radix2Cell "r2cell" device_affinity="cpu0" ()
        ports_in (%outputPort_3100, %outputPort_3102, %outputPort_3104 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3105, %inputPort_3107 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__TwiddleGenerator__v__N_dyn "twiddles" (%c32_i32 : i32)
        ports_in (%outputPort_3098 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3103 : !fifo.input_port<complex<f32>>)
    cal.create_instance @__fanout_complex_f32__2 "fft__Butterfly$spec_17640631431051100303.__fanout_complex_f32__2.6" device_affinity="cpu0" ()
        ports_in (%outputPort_2084 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3095, %inputPort_3097 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    %inputPort_3607, %outputPort_3608 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_3035977640463470463.fft__Butterfly$spec_3035977640463470463.__fanout_complex_f32__2.6.out0->split.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3609, %outputPort_3610 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_3035977640463470463.fft__Butterfly$spec_3035977640463470463.__fanout_complex_f32__2.6.out1->twiddles.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3611, %outputPort_3612 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_3035977640463470463.split.out0->r2cell.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3613, %outputPort_3614 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_3035977640463470463.split.out1->r2cell.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3615, %outputPort_3616 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_3035977640463470463.twiddles.out0->r2cell.in2"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3617, %outputPort_3618 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_3035977640463470463.r2cell.out0->fft__Butterfly$spec_3035977640463470463.fft__Butterfly$spec_16755419077516047831.4.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3619, %outputPort_3620 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_3035977640463470463.r2cell.out1->fft__Butterfly$spec_3035977640463470463.fft__Butterfly$spec_16755419077516047831.5.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3621, %outputPort_3622 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_3035977640463470463.fft__Butterfly$spec_3035977640463470463.fft__Butterfly$spec_16755419077516047831.4.out0->merge.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3623, %outputPort_3624 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_3035977640463470463.fft__Butterfly$spec_3035977640463470463.fft__Butterfly$spec_16755419077516047831.5.out0->merge.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    cal.create_instance @fft__TwiddleGenerator__v__N_dyn "twiddles" (%c16_i32 : i32)
        ports_in (%outputPort_3610 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3615 : !fifo.input_port<complex<f32>>)
    %inputPort_3625, %outputPort_3626 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_16755419077516047831.fft__Butterfly$spec_16755419077516047831.__fanout_complex_f32__2.6.out0->split.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3627, %outputPort_3628 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_16755419077516047831.fft__Butterfly$spec_16755419077516047831.__fanout_complex_f32__2.6.out1->twiddles.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3629, %outputPort_3630 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_16755419077516047831.split.out0->r2cell.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3631, %outputPort_3632 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_16755419077516047831.split.out1->r2cell.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3633, %outputPort_3634 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_16755419077516047831.twiddles.out0->r2cell.in2"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3635, %outputPort_3636 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_16755419077516047831.r2cell.out0->fft__Butterfly$spec_16755419077516047831.fft__Butterfly$spec_9935405952460034831.4.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3637, %outputPort_3638 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_16755419077516047831.r2cell.out1->fft__Butterfly$spec_16755419077516047831.fft__Butterfly$spec_9935405952460034831.5.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3639, %outputPort_3640 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_16755419077516047831.fft__Butterfly$spec_16755419077516047831.fft__Butterfly$spec_9935405952460034831.4.out0->merge.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3641, %outputPort_3642 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_16755419077516047831.fft__Butterfly$spec_16755419077516047831.fft__Butterfly$spec_9935405952460034831.5.out0->merge.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    cal.create_instance @__fanout_complex_f32__2 "fft__Butterfly$spec_16755419077516047831.__fanout_complex_f32__2.6" device_affinity="cpu0" ()
        ports_in (%outputPort_3620 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3625, %inputPort_3627 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Merge "merge" device_affinity="cpu0" ()
        ports_in (%outputPort_3640, %outputPort_3642 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3623 : !fifo.input_port<complex<f32>>)
    %inputPort_3643, %outputPort_3644 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.fft__Butterfly$spec_9935405952460034831.__fanout_complex_f32__2.6.out0->split.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3645, %outputPort_3646 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.fft__Butterfly$spec_9935405952460034831.__fanout_complex_f32__2.6.out1->twiddles.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3647, %outputPort_3648 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.split.out0->r2cell.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3649, %outputPort_3650 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.split.out1->r2cell.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3651, %outputPort_3652 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.twiddles.out0->r2cell.in2"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3653, %outputPort_3654 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.r2cell.out0->fft__Butterfly$spec_9935405952460034831.fft__Butterfly$spec_1916938481276772234.4.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3655, %outputPort_3656 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.r2cell.out1->fft__Butterfly$spec_9935405952460034831.fft__Butterfly$spec_1916938481276772234.5.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3657, %outputPort_3658 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.fft__Butterfly$spec_9935405952460034831.fft__Butterfly$spec_1916938481276772234.4.out0->merge.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3659, %outputPort_3660 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.fft__Butterfly$spec_9935405952460034831.fft__Butterfly$spec_1916938481276772234.5.out0->merge.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    cal.create_instance @fft__Radix2Cell "r2cell" device_affinity="cpu0" ()
        ports_in (%outputPort_3648, %outputPort_3650, %outputPort_3652 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3653, %inputPort_3655 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Split__v__N_dyn "split" (%c4_i32 : i32)
        ports_in (%outputPort_3644 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3647, %inputPort_3649 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Merge "merge" device_affinity="cpu0" ()
        ports_in (%outputPort_3658, %outputPort_3660 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3641 : !fifo.input_port<complex<f32>>)
    cal.create_instance @__fanout_complex_f32__2 "fft__Butterfly$spec_9935405952460034831.__fanout_complex_f32__2.6" device_affinity="cpu0" ()
        ports_in (%outputPort_3638 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3643, %inputPort_3645 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__TwiddleGenerator__v__N_dyn "twiddles" (%c4_i32 : i32)
        ports_in (%outputPort_3646 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3651 : !fifo.input_port<complex<f32>>)
    %inputPort_3661, %outputPort_3662 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_1916938481276772234.__fanout_complex_f32__2.6.out0->split.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3663, %outputPort_3664 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_1916938481276772234.__fanout_complex_f32__2.6.out1->twiddles.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3665, %outputPort_3666 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.split.out0->r2cell.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3667, %outputPort_3668 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.split.out1->r2cell.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3669, %outputPort_3670 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.twiddles.out0->r2cell.in2"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3671, %outputPort_3672 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.r2cell.out0->fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_15446289516955298258.4.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3673, %outputPort_3674 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.r2cell.out1->fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_15446289516955298258.5.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3675, %outputPort_3676 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_15446289516955298258.4.out0->merge.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3677, %outputPort_3678 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_15446289516955298258.5.out0->merge.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    cal.create_instance @fft__Radix2Cell "r2cell" device_affinity="cpu0" ()
        ports_in (%outputPort_3666, %outputPort_3668, %outputPort_3670 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3671, %inputPort_3673 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__TwiddleGenerator__v__N_dyn "twiddles" (%c2_i32 : i32)
        ports_in (%outputPort_3664 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3669 : !fifo.input_port<complex<f32>>)
    cal.create_instance @__fanout_complex_f32__2 "fft__Butterfly$spec_1916938481276772234.__fanout_complex_f32__2.6" device_affinity="cpu0" ()
        ports_in (%outputPort_3656 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3661, %inputPort_3663 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Split__v__N_dyn "split" (%c2_i32 : i32)
        ports_in (%outputPort_3662 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3665, %inputPort_3667 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    %inputPort_3679, %outputPort_3680 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4.out0->split.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3681, %outputPort_3682 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4.out1->twiddles.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3683, %outputPort_3684 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.split.out0->r2cell.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3685, %outputPort_3686 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.split.out1->r2cell.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3687, %outputPort_3688 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.twiddles.out0->r2cell.in2"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3689, %outputPort_3690 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.r2cell.out0->merge.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3691, %outputPort_3692 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.r2cell.out1->merge.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    cal.create_instance @fft__Merge "merge" device_affinity="cpu0" ()
        ports_in (%outputPort_3690, %outputPort_3692 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3675 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__TwiddleGenerator__v__N_dyn "twiddles" (%c1_i32 : i32)
        ports_in (%outputPort_3682 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3687 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Split__v__N_dyn "split" (%c1_i32 : i32)
        ports_in (%outputPort_3680 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3683, %inputPort_3685 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @__fanout_complex_f32__2 "fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4" device_affinity="cpu0" ()
        ports_in (%outputPort_3672 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3679, %inputPort_3681 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Radix2Cell "r2cell" device_affinity="cpu0" ()
        ports_in (%outputPort_3684, %outputPort_3686, %outputPort_3688 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3689, %inputPort_3691 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    %inputPort_3693, %outputPort_3694 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4.out0->split.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3695, %outputPort_3696 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4.out1->twiddles.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3697, %outputPort_3698 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.split.out0->r2cell.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3699, %outputPort_3700 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.split.out1->r2cell.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3701, %outputPort_3702 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.twiddles.out0->r2cell.in2"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3703, %outputPort_3704 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.r2cell.out0->merge.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3705, %outputPort_3706 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.r2cell.out1->merge.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    cal.create_instance @fft__Merge "merge" device_affinity="cpu0" ()
        ports_in (%outputPort_3704, %outputPort_3706 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3677 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__TwiddleGenerator__v__N_dyn "twiddles" (%c1_i32 : i32)
        ports_in (%outputPort_3696 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3701 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Split__v__N_dyn "split" (%c1_i32 : i32)
        ports_in (%outputPort_3694 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3697, %inputPort_3699 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @__fanout_complex_f32__2 "fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4" device_affinity="cpu0" ()
        ports_in (%outputPort_3674 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3693, %inputPort_3695 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Radix2Cell "r2cell" device_affinity="cpu0" ()
        ports_in (%outputPort_3698, %outputPort_3700, %outputPort_3702 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3703, %inputPort_3705 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Merge "merge" device_affinity="cpu0" ()
        ports_in (%outputPort_3676, %outputPort_3678 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3659 : !fifo.input_port<complex<f32>>)
    %inputPort_3707, %outputPort_3708 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_1916938481276772234.__fanout_complex_f32__2.6.out0->split.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3709, %outputPort_3710 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_1916938481276772234.__fanout_complex_f32__2.6.out1->twiddles.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3711, %outputPort_3712 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.split.out0->r2cell.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3713, %outputPort_3714 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.split.out1->r2cell.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3715, %outputPort_3716 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.twiddles.out0->r2cell.in2"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3717, %outputPort_3718 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.r2cell.out0->fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_15446289516955298258.4.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3719, %outputPort_3720 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.r2cell.out1->fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_15446289516955298258.5.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3721, %outputPort_3722 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_15446289516955298258.4.out0->merge.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3723, %outputPort_3724 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_15446289516955298258.5.out0->merge.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    cal.create_instance @fft__Radix2Cell "r2cell" device_affinity="cpu0" ()
        ports_in (%outputPort_3712, %outputPort_3714, %outputPort_3716 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3717, %inputPort_3719 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__TwiddleGenerator__v__N_dyn "twiddles" (%c2_i32 : i32)
        ports_in (%outputPort_3710 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3715 : !fifo.input_port<complex<f32>>)
    cal.create_instance @__fanout_complex_f32__2 "fft__Butterfly$spec_1916938481276772234.__fanout_complex_f32__2.6" device_affinity="cpu0" ()
        ports_in (%outputPort_3654 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3707, %inputPort_3709 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Split__v__N_dyn "split" (%c2_i32 : i32)
        ports_in (%outputPort_3708 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3711, %inputPort_3713 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    %inputPort_3725, %outputPort_3726 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4.out0->split.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3727, %outputPort_3728 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4.out1->twiddles.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3729, %outputPort_3730 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.split.out0->r2cell.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3731, %outputPort_3732 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.split.out1->r2cell.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3733, %outputPort_3734 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.twiddles.out0->r2cell.in2"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3735, %outputPort_3736 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.r2cell.out0->merge.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3737, %outputPort_3738 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.r2cell.out1->merge.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    cal.create_instance @fft__Merge "merge" device_affinity="cpu0" ()
        ports_in (%outputPort_3736, %outputPort_3738 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3721 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__TwiddleGenerator__v__N_dyn "twiddles" (%c1_i32 : i32)
        ports_in (%outputPort_3728 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3733 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Split__v__N_dyn "split" (%c1_i32 : i32)
        ports_in (%outputPort_3726 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3729, %inputPort_3731 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @__fanout_complex_f32__2 "fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4" device_affinity="cpu0" ()
        ports_in (%outputPort_3718 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3725, %inputPort_3727 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Radix2Cell "r2cell" device_affinity="cpu0" ()
        ports_in (%outputPort_3730, %outputPort_3732, %outputPort_3734 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3735, %inputPort_3737 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    %inputPort_3739, %outputPort_3740 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4.out0->split.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3741, %outputPort_3742 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4.out1->twiddles.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3743, %outputPort_3744 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.split.out0->r2cell.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3745, %outputPort_3746 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.split.out1->r2cell.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3747, %outputPort_3748 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.twiddles.out0->r2cell.in2"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3749, %outputPort_3750 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.r2cell.out0->merge.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3751, %outputPort_3752 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.r2cell.out1->merge.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    cal.create_instance @fft__Merge "merge" device_affinity="cpu0" ()
        ports_in (%outputPort_3750, %outputPort_3752 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3723 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__TwiddleGenerator__v__N_dyn "twiddles" (%c1_i32 : i32)
        ports_in (%outputPort_3742 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3747 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Split__v__N_dyn "split" (%c1_i32 : i32)
        ports_in (%outputPort_3740 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3743, %inputPort_3745 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @__fanout_complex_f32__2 "fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4" device_affinity="cpu0" ()
        ports_in (%outputPort_3720 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3739, %inputPort_3741 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Radix2Cell "r2cell" device_affinity="cpu0" ()
        ports_in (%outputPort_3744, %outputPort_3746, %outputPort_3748 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3749, %inputPort_3751 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Merge "merge" device_affinity="cpu0" ()
        ports_in (%outputPort_3722, %outputPort_3724 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3657 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__TwiddleGenerator__v__N_dyn "twiddles" (%c8_i32 : i32)
        ports_in (%outputPort_3628 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3633 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Radix2Cell "r2cell" device_affinity="cpu0" ()
        ports_in (%outputPort_3630, %outputPort_3632, %outputPort_3634 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3635, %inputPort_3637 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    %inputPort_3753, %outputPort_3754 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.fft__Butterfly$spec_9935405952460034831.__fanout_complex_f32__2.6.out0->split.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3755, %outputPort_3756 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.fft__Butterfly$spec_9935405952460034831.__fanout_complex_f32__2.6.out1->twiddles.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3757, %outputPort_3758 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.split.out0->r2cell.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3759, %outputPort_3760 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.split.out1->r2cell.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3761, %outputPort_3762 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.twiddles.out0->r2cell.in2"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3763, %outputPort_3764 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.r2cell.out0->fft__Butterfly$spec_9935405952460034831.fft__Butterfly$spec_1916938481276772234.4.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3765, %outputPort_3766 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.r2cell.out1->fft__Butterfly$spec_9935405952460034831.fft__Butterfly$spec_1916938481276772234.5.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3767, %outputPort_3768 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.fft__Butterfly$spec_9935405952460034831.fft__Butterfly$spec_1916938481276772234.4.out0->merge.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3769, %outputPort_3770 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.fft__Butterfly$spec_9935405952460034831.fft__Butterfly$spec_1916938481276772234.5.out0->merge.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    cal.create_instance @fft__Radix2Cell "r2cell" device_affinity="cpu0" ()
        ports_in (%outputPort_3758, %outputPort_3760, %outputPort_3762 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3763, %inputPort_3765 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Split__v__N_dyn "split" (%c4_i32 : i32)
        ports_in (%outputPort_3754 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3757, %inputPort_3759 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Merge "merge" device_affinity="cpu0" ()
        ports_in (%outputPort_3768, %outputPort_3770 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3639 : !fifo.input_port<complex<f32>>)
    cal.create_instance @__fanout_complex_f32__2 "fft__Butterfly$spec_9935405952460034831.__fanout_complex_f32__2.6" device_affinity="cpu0" ()
        ports_in (%outputPort_3636 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3753, %inputPort_3755 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__TwiddleGenerator__v__N_dyn "twiddles" (%c4_i32 : i32)
        ports_in (%outputPort_3756 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3761 : !fifo.input_port<complex<f32>>)
    %inputPort_3771, %outputPort_3772 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_1916938481276772234.__fanout_complex_f32__2.6.out0->split.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3773, %outputPort_3774 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_1916938481276772234.__fanout_complex_f32__2.6.out1->twiddles.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3775, %outputPort_3776 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.split.out0->r2cell.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3777, %outputPort_3778 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.split.out1->r2cell.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3779, %outputPort_3780 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.twiddles.out0->r2cell.in2"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3781, %outputPort_3782 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.r2cell.out0->fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_15446289516955298258.4.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3783, %outputPort_3784 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.r2cell.out1->fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_15446289516955298258.5.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3785, %outputPort_3786 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_15446289516955298258.4.out0->merge.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3787, %outputPort_3788 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_15446289516955298258.5.out0->merge.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    cal.create_instance @fft__Radix2Cell "r2cell" device_affinity="cpu0" ()
        ports_in (%outputPort_3776, %outputPort_3778, %outputPort_3780 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3781, %inputPort_3783 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__TwiddleGenerator__v__N_dyn "twiddles" (%c2_i32 : i32)
        ports_in (%outputPort_3774 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3779 : !fifo.input_port<complex<f32>>)
    cal.create_instance @__fanout_complex_f32__2 "fft__Butterfly$spec_1916938481276772234.__fanout_complex_f32__2.6" device_affinity="cpu0" ()
        ports_in (%outputPort_3766 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3771, %inputPort_3773 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Split__v__N_dyn "split" (%c2_i32 : i32)
        ports_in (%outputPort_3772 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3775, %inputPort_3777 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    %inputPort_3789, %outputPort_3790 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4.out0->split.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3791, %outputPort_3792 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4.out1->twiddles.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3793, %outputPort_3794 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.split.out0->r2cell.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3795, %outputPort_3796 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.split.out1->r2cell.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3797, %outputPort_3798 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.twiddles.out0->r2cell.in2"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3799, %outputPort_3800 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.r2cell.out0->merge.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3801, %outputPort_3802 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.r2cell.out1->merge.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    cal.create_instance @fft__Merge "merge" device_affinity="cpu0" ()
        ports_in (%outputPort_3800, %outputPort_3802 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3785 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__TwiddleGenerator__v__N_dyn "twiddles" (%c1_i32 : i32)
        ports_in (%outputPort_3792 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3797 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Split__v__N_dyn "split" (%c1_i32 : i32)
        ports_in (%outputPort_3790 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3793, %inputPort_3795 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @__fanout_complex_f32__2 "fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4" device_affinity="cpu0" ()
        ports_in (%outputPort_3782 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3789, %inputPort_3791 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Radix2Cell "r2cell" device_affinity="cpu0" ()
        ports_in (%outputPort_3794, %outputPort_3796, %outputPort_3798 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3799, %inputPort_3801 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    %inputPort_3803, %outputPort_3804 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4.out0->split.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3805, %outputPort_3806 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4.out1->twiddles.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3807, %outputPort_3808 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.split.out0->r2cell.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3809, %outputPort_3810 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.split.out1->r2cell.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3811, %outputPort_3812 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.twiddles.out0->r2cell.in2"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3813, %outputPort_3814 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.r2cell.out0->merge.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3815, %outputPort_3816 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.r2cell.out1->merge.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    cal.create_instance @fft__Merge "merge" device_affinity="cpu0" ()
        ports_in (%outputPort_3814, %outputPort_3816 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3787 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__TwiddleGenerator__v__N_dyn "twiddles" (%c1_i32 : i32)
        ports_in (%outputPort_3806 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3811 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Split__v__N_dyn "split" (%c1_i32 : i32)
        ports_in (%outputPort_3804 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3807, %inputPort_3809 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @__fanout_complex_f32__2 "fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4" device_affinity="cpu0" ()
        ports_in (%outputPort_3784 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3803, %inputPort_3805 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Radix2Cell "r2cell" device_affinity="cpu0" ()
        ports_in (%outputPort_3808, %outputPort_3810, %outputPort_3812 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3813, %inputPort_3815 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Merge "merge" device_affinity="cpu0" ()
        ports_in (%outputPort_3786, %outputPort_3788 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3769 : !fifo.input_port<complex<f32>>)
    %inputPort_3817, %outputPort_3818 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_1916938481276772234.__fanout_complex_f32__2.6.out0->split.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3819, %outputPort_3820 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_1916938481276772234.__fanout_complex_f32__2.6.out1->twiddles.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3821, %outputPort_3822 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.split.out0->r2cell.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3823, %outputPort_3824 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.split.out1->r2cell.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3825, %outputPort_3826 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.twiddles.out0->r2cell.in2"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3827, %outputPort_3828 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.r2cell.out0->fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_15446289516955298258.4.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3829, %outputPort_3830 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.r2cell.out1->fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_15446289516955298258.5.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3831, %outputPort_3832 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_15446289516955298258.4.out0->merge.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3833, %outputPort_3834 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_15446289516955298258.5.out0->merge.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    cal.create_instance @fft__Radix2Cell "r2cell" device_affinity="cpu0" ()
        ports_in (%outputPort_3822, %outputPort_3824, %outputPort_3826 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3827, %inputPort_3829 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__TwiddleGenerator__v__N_dyn "twiddles" (%c2_i32 : i32)
        ports_in (%outputPort_3820 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3825 : !fifo.input_port<complex<f32>>)
    cal.create_instance @__fanout_complex_f32__2 "fft__Butterfly$spec_1916938481276772234.__fanout_complex_f32__2.6" device_affinity="cpu0" ()
        ports_in (%outputPort_3764 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3817, %inputPort_3819 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Split__v__N_dyn "split" (%c2_i32 : i32)
        ports_in (%outputPort_3818 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3821, %inputPort_3823 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    %inputPort_3835, %outputPort_3836 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4.out0->split.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3837, %outputPort_3838 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4.out1->twiddles.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3839, %outputPort_3840 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.split.out0->r2cell.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3841, %outputPort_3842 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.split.out1->r2cell.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3843, %outputPort_3844 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.twiddles.out0->r2cell.in2"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3845, %outputPort_3846 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.r2cell.out0->merge.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3847, %outputPort_3848 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.r2cell.out1->merge.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    cal.create_instance @fft__Merge "merge" device_affinity="cpu0" ()
        ports_in (%outputPort_3846, %outputPort_3848 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3831 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__TwiddleGenerator__v__N_dyn "twiddles" (%c1_i32 : i32)
        ports_in (%outputPort_3838 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3843 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Split__v__N_dyn "split" (%c1_i32 : i32)
        ports_in (%outputPort_3836 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3839, %inputPort_3841 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @__fanout_complex_f32__2 "fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4" device_affinity="cpu0" ()
        ports_in (%outputPort_3828 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3835, %inputPort_3837 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Radix2Cell "r2cell" device_affinity="cpu0" ()
        ports_in (%outputPort_3840, %outputPort_3842, %outputPort_3844 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3845, %inputPort_3847 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    %inputPort_3849, %outputPort_3850 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4.out0->split.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3851, %outputPort_3852 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4.out1->twiddles.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3853, %outputPort_3854 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.split.out0->r2cell.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3855, %outputPort_3856 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.split.out1->r2cell.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3857, %outputPort_3858 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.twiddles.out0->r2cell.in2"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3859, %outputPort_3860 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.r2cell.out0->merge.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3861, %outputPort_3862 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.r2cell.out1->merge.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    cal.create_instance @fft__Merge "merge" device_affinity="cpu0" ()
        ports_in (%outputPort_3860, %outputPort_3862 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3833 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__TwiddleGenerator__v__N_dyn "twiddles" (%c1_i32 : i32)
        ports_in (%outputPort_3852 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3857 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Split__v__N_dyn "split" (%c1_i32 : i32)
        ports_in (%outputPort_3850 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3853, %inputPort_3855 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @__fanout_complex_f32__2 "fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4" device_affinity="cpu0" ()
        ports_in (%outputPort_3830 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3849, %inputPort_3851 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Radix2Cell "r2cell" device_affinity="cpu0" ()
        ports_in (%outputPort_3854, %outputPort_3856, %outputPort_3858 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3859, %inputPort_3861 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Merge "merge" device_affinity="cpu0" ()
        ports_in (%outputPort_3832, %outputPort_3834 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3767 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Split__v__N_dyn "split" (%c8_i32 : i32)
        ports_in (%outputPort_3626 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3629, %inputPort_3631 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Radix2Cell "r2cell" device_affinity="cpu0" ()
        ports_in (%outputPort_3612, %outputPort_3614, %outputPort_3616 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3617, %inputPort_3619 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Merge "merge" device_affinity="cpu0" ()
        ports_in (%outputPort_3622, %outputPort_3624 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3111 : !fifo.input_port<complex<f32>>)
    cal.create_instance @__fanout_complex_f32__2 "fft__Butterfly$spec_3035977640463470463.__fanout_complex_f32__2.6" device_affinity="cpu0" ()
        ports_in (%outputPort_3108 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3607, %inputPort_3609 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    %inputPort_3863, %outputPort_3864 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_16755419077516047831.fft__Butterfly$spec_16755419077516047831.__fanout_complex_f32__2.6.out0->split.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3865, %outputPort_3866 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_16755419077516047831.fft__Butterfly$spec_16755419077516047831.__fanout_complex_f32__2.6.out1->twiddles.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3867, %outputPort_3868 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_16755419077516047831.split.out0->r2cell.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3869, %outputPort_3870 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_16755419077516047831.split.out1->r2cell.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3871, %outputPort_3872 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_16755419077516047831.twiddles.out0->r2cell.in2"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3873, %outputPort_3874 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_16755419077516047831.r2cell.out0->fft__Butterfly$spec_16755419077516047831.fft__Butterfly$spec_9935405952460034831.4.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3875, %outputPort_3876 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_16755419077516047831.r2cell.out1->fft__Butterfly$spec_16755419077516047831.fft__Butterfly$spec_9935405952460034831.5.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3877, %outputPort_3878 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_16755419077516047831.fft__Butterfly$spec_16755419077516047831.fft__Butterfly$spec_9935405952460034831.4.out0->merge.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3879, %outputPort_3880 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_16755419077516047831.fft__Butterfly$spec_16755419077516047831.fft__Butterfly$spec_9935405952460034831.5.out0->merge.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    cal.create_instance @__fanout_complex_f32__2 "fft__Butterfly$spec_16755419077516047831.__fanout_complex_f32__2.6" device_affinity="cpu0" ()
        ports_in (%outputPort_3618 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3863, %inputPort_3865 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Merge "merge" device_affinity="cpu0" ()
        ports_in (%outputPort_3878, %outputPort_3880 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3621 : !fifo.input_port<complex<f32>>)
    %inputPort_3881, %outputPort_3882 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.fft__Butterfly$spec_9935405952460034831.__fanout_complex_f32__2.6.out0->split.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3883, %outputPort_3884 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.fft__Butterfly$spec_9935405952460034831.__fanout_complex_f32__2.6.out1->twiddles.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3885, %outputPort_3886 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.split.out0->r2cell.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3887, %outputPort_3888 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.split.out1->r2cell.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3889, %outputPort_3890 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.twiddles.out0->r2cell.in2"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3891, %outputPort_3892 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.r2cell.out0->fft__Butterfly$spec_9935405952460034831.fft__Butterfly$spec_1916938481276772234.4.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3893, %outputPort_3894 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.r2cell.out1->fft__Butterfly$spec_9935405952460034831.fft__Butterfly$spec_1916938481276772234.5.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3895, %outputPort_3896 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.fft__Butterfly$spec_9935405952460034831.fft__Butterfly$spec_1916938481276772234.4.out0->merge.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3897, %outputPort_3898 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.fft__Butterfly$spec_9935405952460034831.fft__Butterfly$spec_1916938481276772234.5.out0->merge.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    cal.create_instance @fft__Radix2Cell "r2cell" device_affinity="cpu0" ()
        ports_in (%outputPort_3886, %outputPort_3888, %outputPort_3890 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3891, %inputPort_3893 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Split__v__N_dyn "split" (%c4_i32 : i32)
        ports_in (%outputPort_3882 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3885, %inputPort_3887 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Merge "merge" device_affinity="cpu0" ()
        ports_in (%outputPort_3896, %outputPort_3898 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3879 : !fifo.input_port<complex<f32>>)
    cal.create_instance @__fanout_complex_f32__2 "fft__Butterfly$spec_9935405952460034831.__fanout_complex_f32__2.6" device_affinity="cpu0" ()
        ports_in (%outputPort_3876 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3881, %inputPort_3883 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__TwiddleGenerator__v__N_dyn "twiddles" (%c4_i32 : i32)
        ports_in (%outputPort_3884 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3889 : !fifo.input_port<complex<f32>>)
    %inputPort_3899, %outputPort_3900 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_1916938481276772234.__fanout_complex_f32__2.6.out0->split.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3901, %outputPort_3902 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_1916938481276772234.__fanout_complex_f32__2.6.out1->twiddles.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3903, %outputPort_3904 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.split.out0->r2cell.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3905, %outputPort_3906 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.split.out1->r2cell.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3907, %outputPort_3908 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.twiddles.out0->r2cell.in2"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3909, %outputPort_3910 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.r2cell.out0->fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_15446289516955298258.4.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3911, %outputPort_3912 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.r2cell.out1->fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_15446289516955298258.5.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3913, %outputPort_3914 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_15446289516955298258.4.out0->merge.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3915, %outputPort_3916 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_15446289516955298258.5.out0->merge.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    cal.create_instance @fft__Radix2Cell "r2cell" device_affinity="cpu0" ()
        ports_in (%outputPort_3904, %outputPort_3906, %outputPort_3908 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3909, %inputPort_3911 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__TwiddleGenerator__v__N_dyn "twiddles" (%c2_i32 : i32)
        ports_in (%outputPort_3902 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3907 : !fifo.input_port<complex<f32>>)
    cal.create_instance @__fanout_complex_f32__2 "fft__Butterfly$spec_1916938481276772234.__fanout_complex_f32__2.6" device_affinity="cpu0" ()
        ports_in (%outputPort_3894 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3899, %inputPort_3901 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Split__v__N_dyn "split" (%c2_i32 : i32)
        ports_in (%outputPort_3900 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3903, %inputPort_3905 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    %inputPort_3917, %outputPort_3918 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4.out0->split.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3919, %outputPort_3920 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4.out1->twiddles.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3921, %outputPort_3922 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.split.out0->r2cell.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3923, %outputPort_3924 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.split.out1->r2cell.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3925, %outputPort_3926 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.twiddles.out0->r2cell.in2"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3927, %outputPort_3928 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.r2cell.out0->merge.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3929, %outputPort_3930 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.r2cell.out1->merge.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    cal.create_instance @fft__Merge "merge" device_affinity="cpu0" ()
        ports_in (%outputPort_3928, %outputPort_3930 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3913 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__TwiddleGenerator__v__N_dyn "twiddles" (%c1_i32 : i32)
        ports_in (%outputPort_3920 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3925 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Split__v__N_dyn "split" (%c1_i32 : i32)
        ports_in (%outputPort_3918 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3921, %inputPort_3923 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @__fanout_complex_f32__2 "fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4" device_affinity="cpu0" ()
        ports_in (%outputPort_3910 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3917, %inputPort_3919 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Radix2Cell "r2cell" device_affinity="cpu0" ()
        ports_in (%outputPort_3922, %outputPort_3924, %outputPort_3926 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3927, %inputPort_3929 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    %inputPort_3931, %outputPort_3932 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4.out0->split.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3933, %outputPort_3934 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4.out1->twiddles.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3935, %outputPort_3936 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.split.out0->r2cell.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3937, %outputPort_3938 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.split.out1->r2cell.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3939, %outputPort_3940 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.twiddles.out0->r2cell.in2"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3941, %outputPort_3942 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.r2cell.out0->merge.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3943, %outputPort_3944 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.r2cell.out1->merge.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    cal.create_instance @fft__Merge "merge" device_affinity="cpu0" ()
        ports_in (%outputPort_3942, %outputPort_3944 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3915 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__TwiddleGenerator__v__N_dyn "twiddles" (%c1_i32 : i32)
        ports_in (%outputPort_3934 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3939 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Split__v__N_dyn "split" (%c1_i32 : i32)
        ports_in (%outputPort_3932 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3935, %inputPort_3937 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @__fanout_complex_f32__2 "fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4" device_affinity="cpu0" ()
        ports_in (%outputPort_3912 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3931, %inputPort_3933 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Radix2Cell "r2cell" device_affinity="cpu0" ()
        ports_in (%outputPort_3936, %outputPort_3938, %outputPort_3940 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3941, %inputPort_3943 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Merge "merge" device_affinity="cpu0" ()
        ports_in (%outputPort_3914, %outputPort_3916 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3897 : !fifo.input_port<complex<f32>>)
    %inputPort_3945, %outputPort_3946 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_1916938481276772234.__fanout_complex_f32__2.6.out0->split.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3947, %outputPort_3948 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_1916938481276772234.__fanout_complex_f32__2.6.out1->twiddles.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3949, %outputPort_3950 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.split.out0->r2cell.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3951, %outputPort_3952 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.split.out1->r2cell.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3953, %outputPort_3954 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.twiddles.out0->r2cell.in2"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3955, %outputPort_3956 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.r2cell.out0->fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_15446289516955298258.4.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3957, %outputPort_3958 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.r2cell.out1->fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_15446289516955298258.5.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3959, %outputPort_3960 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_15446289516955298258.4.out0->merge.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3961, %outputPort_3962 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_15446289516955298258.5.out0->merge.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    cal.create_instance @fft__Radix2Cell "r2cell" device_affinity="cpu0" ()
        ports_in (%outputPort_3950, %outputPort_3952, %outputPort_3954 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3955, %inputPort_3957 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__TwiddleGenerator__v__N_dyn "twiddles" (%c2_i32 : i32)
        ports_in (%outputPort_3948 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3953 : !fifo.input_port<complex<f32>>)
    cal.create_instance @__fanout_complex_f32__2 "fft__Butterfly$spec_1916938481276772234.__fanout_complex_f32__2.6" device_affinity="cpu0" ()
        ports_in (%outputPort_3892 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3945, %inputPort_3947 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Split__v__N_dyn "split" (%c2_i32 : i32)
        ports_in (%outputPort_3946 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3949, %inputPort_3951 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    %inputPort_3963, %outputPort_3964 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4.out0->split.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3965, %outputPort_3966 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4.out1->twiddles.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3967, %outputPort_3968 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.split.out0->r2cell.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3969, %outputPort_3970 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.split.out1->r2cell.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3971, %outputPort_3972 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.twiddles.out0->r2cell.in2"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3973, %outputPort_3974 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.r2cell.out0->merge.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3975, %outputPort_3976 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.r2cell.out1->merge.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    cal.create_instance @fft__Merge "merge" device_affinity="cpu0" ()
        ports_in (%outputPort_3974, %outputPort_3976 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3959 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__TwiddleGenerator__v__N_dyn "twiddles" (%c1_i32 : i32)
        ports_in (%outputPort_3966 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3971 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Split__v__N_dyn "split" (%c1_i32 : i32)
        ports_in (%outputPort_3964 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3967, %inputPort_3969 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @__fanout_complex_f32__2 "fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4" device_affinity="cpu0" ()
        ports_in (%outputPort_3956 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3963, %inputPort_3965 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Radix2Cell "r2cell" device_affinity="cpu0" ()
        ports_in (%outputPort_3968, %outputPort_3970, %outputPort_3972 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3973, %inputPort_3975 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    %inputPort_3977, %outputPort_3978 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4.out0->split.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3979, %outputPort_3980 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4.out1->twiddles.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3981, %outputPort_3982 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.split.out0->r2cell.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3983, %outputPort_3984 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.split.out1->r2cell.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3985, %outputPort_3986 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.twiddles.out0->r2cell.in2"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3987, %outputPort_3988 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.r2cell.out0->merge.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3989, %outputPort_3990 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.r2cell.out1->merge.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    cal.create_instance @fft__Merge "merge" device_affinity="cpu0" ()
        ports_in (%outputPort_3988, %outputPort_3990 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3961 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__TwiddleGenerator__v__N_dyn "twiddles" (%c1_i32 : i32)
        ports_in (%outputPort_3980 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3985 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Split__v__N_dyn "split" (%c1_i32 : i32)
        ports_in (%outputPort_3978 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3981, %inputPort_3983 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @__fanout_complex_f32__2 "fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4" device_affinity="cpu0" ()
        ports_in (%outputPort_3958 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3977, %inputPort_3979 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Radix2Cell "r2cell" device_affinity="cpu0" ()
        ports_in (%outputPort_3982, %outputPort_3984, %outputPort_3986 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3987, %inputPort_3989 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Merge "merge" device_affinity="cpu0" ()
        ports_in (%outputPort_3960, %outputPort_3962 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3895 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__TwiddleGenerator__v__N_dyn "twiddles" (%c8_i32 : i32)
        ports_in (%outputPort_3866 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3871 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Radix2Cell "r2cell" device_affinity="cpu0" ()
        ports_in (%outputPort_3868, %outputPort_3870, %outputPort_3872 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3873, %inputPort_3875 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    %inputPort_3991, %outputPort_3992 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.fft__Butterfly$spec_9935405952460034831.__fanout_complex_f32__2.6.out0->split.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3993, %outputPort_3994 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.fft__Butterfly$spec_9935405952460034831.__fanout_complex_f32__2.6.out1->twiddles.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3995, %outputPort_3996 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.split.out0->r2cell.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3997, %outputPort_3998 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.split.out1->r2cell.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_3999, %outputPort_4000 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.twiddles.out0->r2cell.in2"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_4001, %outputPort_4002 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.r2cell.out0->fft__Butterfly$spec_9935405952460034831.fft__Butterfly$spec_1916938481276772234.4.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_4003, %outputPort_4004 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.r2cell.out1->fft__Butterfly$spec_9935405952460034831.fft__Butterfly$spec_1916938481276772234.5.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_4005, %outputPort_4006 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.fft__Butterfly$spec_9935405952460034831.fft__Butterfly$spec_1916938481276772234.4.out0->merge.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_4007, %outputPort_4008 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_9935405952460034831.fft__Butterfly$spec_9935405952460034831.fft__Butterfly$spec_1916938481276772234.5.out0->merge.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    cal.create_instance @fft__Radix2Cell "r2cell" device_affinity="cpu0" ()
        ports_in (%outputPort_3996, %outputPort_3998, %outputPort_4000 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_4001, %inputPort_4003 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Split__v__N_dyn "split" (%c4_i32 : i32)
        ports_in (%outputPort_3992 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3995, %inputPort_3997 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Merge "merge" device_affinity="cpu0" ()
        ports_in (%outputPort_4006, %outputPort_4008 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3877 : !fifo.input_port<complex<f32>>)
    cal.create_instance @__fanout_complex_f32__2 "fft__Butterfly$spec_9935405952460034831.__fanout_complex_f32__2.6" device_affinity="cpu0" ()
        ports_in (%outputPort_3874 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3991, %inputPort_3993 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__TwiddleGenerator__v__N_dyn "twiddles" (%c4_i32 : i32)
        ports_in (%outputPort_3994 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3999 : !fifo.input_port<complex<f32>>)
    %inputPort_4009, %outputPort_4010 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_1916938481276772234.__fanout_complex_f32__2.6.out0->split.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_4011, %outputPort_4012 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_1916938481276772234.__fanout_complex_f32__2.6.out1->twiddles.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_4013, %outputPort_4014 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.split.out0->r2cell.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_4015, %outputPort_4016 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.split.out1->r2cell.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_4017, %outputPort_4018 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.twiddles.out0->r2cell.in2"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_4019, %outputPort_4020 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.r2cell.out0->fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_15446289516955298258.4.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_4021, %outputPort_4022 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.r2cell.out1->fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_15446289516955298258.5.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_4023, %outputPort_4024 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_15446289516955298258.4.out0->merge.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_4025, %outputPort_4026 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_15446289516955298258.5.out0->merge.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    cal.create_instance @fft__Radix2Cell "r2cell" device_affinity="cpu0" ()
        ports_in (%outputPort_4014, %outputPort_4016, %outputPort_4018 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_4019, %inputPort_4021 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__TwiddleGenerator__v__N_dyn "twiddles" (%c2_i32 : i32)
        ports_in (%outputPort_4012 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_4017 : !fifo.input_port<complex<f32>>)
    cal.create_instance @__fanout_complex_f32__2 "fft__Butterfly$spec_1916938481276772234.__fanout_complex_f32__2.6" device_affinity="cpu0" ()
        ports_in (%outputPort_4004 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_4009, %inputPort_4011 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Split__v__N_dyn "split" (%c2_i32 : i32)
        ports_in (%outputPort_4010 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_4013, %inputPort_4015 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    %inputPort_4027, %outputPort_4028 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4.out0->split.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_4029, %outputPort_4030 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4.out1->twiddles.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_4031, %outputPort_4032 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.split.out0->r2cell.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_4033, %outputPort_4034 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.split.out1->r2cell.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_4035, %outputPort_4036 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.twiddles.out0->r2cell.in2"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_4037, %outputPort_4038 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.r2cell.out0->merge.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_4039, %outputPort_4040 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.r2cell.out1->merge.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    cal.create_instance @fft__Merge "merge" device_affinity="cpu0" ()
        ports_in (%outputPort_4038, %outputPort_4040 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_4023 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__TwiddleGenerator__v__N_dyn "twiddles" (%c1_i32 : i32)
        ports_in (%outputPort_4030 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_4035 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Split__v__N_dyn "split" (%c1_i32 : i32)
        ports_in (%outputPort_4028 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_4031, %inputPort_4033 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @__fanout_complex_f32__2 "fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4" device_affinity="cpu0" ()
        ports_in (%outputPort_4020 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_4027, %inputPort_4029 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Radix2Cell "r2cell" device_affinity="cpu0" ()
        ports_in (%outputPort_4032, %outputPort_4034, %outputPort_4036 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_4037, %inputPort_4039 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    %inputPort_4041, %outputPort_4042 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4.out0->split.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_4043, %outputPort_4044 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4.out1->twiddles.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_4045, %outputPort_4046 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.split.out0->r2cell.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_4047, %outputPort_4048 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.split.out1->r2cell.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_4049, %outputPort_4050 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.twiddles.out0->r2cell.in2"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_4051, %outputPort_4052 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.r2cell.out0->merge.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_4053, %outputPort_4054 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.r2cell.out1->merge.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    cal.create_instance @fft__Merge "merge" device_affinity="cpu0" ()
        ports_in (%outputPort_4052, %outputPort_4054 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_4025 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__TwiddleGenerator__v__N_dyn "twiddles" (%c1_i32 : i32)
        ports_in (%outputPort_4044 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_4049 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Split__v__N_dyn "split" (%c1_i32 : i32)
        ports_in (%outputPort_4042 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_4045, %inputPort_4047 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @__fanout_complex_f32__2 "fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4" device_affinity="cpu0" ()
        ports_in (%outputPort_4022 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_4041, %inputPort_4043 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Radix2Cell "r2cell" device_affinity="cpu0" ()
        ports_in (%outputPort_4046, %outputPort_4048, %outputPort_4050 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_4051, %inputPort_4053 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Merge "merge" device_affinity="cpu0" ()
        ports_in (%outputPort_4024, %outputPort_4026 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_4007 : !fifo.input_port<complex<f32>>)
    %inputPort_4055, %outputPort_4056 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_1916938481276772234.__fanout_complex_f32__2.6.out0->split.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_4057, %outputPort_4058 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_1916938481276772234.__fanout_complex_f32__2.6.out1->twiddles.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_4059, %outputPort_4060 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.split.out0->r2cell.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_4061, %outputPort_4062 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.split.out1->r2cell.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_4063, %outputPort_4064 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.twiddles.out0->r2cell.in2"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_4065, %outputPort_4066 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.r2cell.out0->fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_15446289516955298258.4.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_4067, %outputPort_4068 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.r2cell.out1->fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_15446289516955298258.5.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_4069, %outputPort_4070 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_15446289516955298258.4.out0->merge.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_4071, %outputPort_4072 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_1916938481276772234.fft__Butterfly$spec_15446289516955298258.5.out0->merge.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    cal.create_instance @fft__Radix2Cell "r2cell" device_affinity="cpu0" ()
        ports_in (%outputPort_4060, %outputPort_4062, %outputPort_4064 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_4065, %inputPort_4067 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__TwiddleGenerator__v__N_dyn "twiddles" (%c2_i32 : i32)
        ports_in (%outputPort_4058 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_4063 : !fifo.input_port<complex<f32>>)
    cal.create_instance @__fanout_complex_f32__2 "fft__Butterfly$spec_1916938481276772234.__fanout_complex_f32__2.6" device_affinity="cpu0" ()
        ports_in (%outputPort_4002 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_4055, %inputPort_4057 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Split__v__N_dyn "split" (%c2_i32 : i32)
        ports_in (%outputPort_4056 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_4059, %inputPort_4061 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    %inputPort_4073, %outputPort_4074 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4.out0->split.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_4075, %outputPort_4076 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4.out1->twiddles.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_4077, %outputPort_4078 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.split.out0->r2cell.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_4079, %outputPort_4080 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.split.out1->r2cell.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_4081, %outputPort_4082 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.twiddles.out0->r2cell.in2"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_4083, %outputPort_4084 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.r2cell.out0->merge.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_4085, %outputPort_4086 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.r2cell.out1->merge.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    cal.create_instance @fft__Merge "merge" device_affinity="cpu0" ()
        ports_in (%outputPort_4084, %outputPort_4086 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_4069 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__TwiddleGenerator__v__N_dyn "twiddles" (%c1_i32 : i32)
        ports_in (%outputPort_4076 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_4081 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Split__v__N_dyn "split" (%c1_i32 : i32)
        ports_in (%outputPort_4074 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_4077, %inputPort_4079 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @__fanout_complex_f32__2 "fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4" device_affinity="cpu0" ()
        ports_in (%outputPort_4066 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_4073, %inputPort_4075 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Radix2Cell "r2cell" device_affinity="cpu0" ()
        ports_in (%outputPort_4078, %outputPort_4080, %outputPort_4082 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_4083, %inputPort_4085 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    %inputPort_4087, %outputPort_4088 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4.out0->split.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_4089, %outputPort_4090 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4.out1->twiddles.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_4091, %outputPort_4092 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.split.out0->r2cell.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_4093, %outputPort_4094 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.split.out1->r2cell.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_4095, %outputPort_4096 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.twiddles.out0->r2cell.in2"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_4097, %outputPort_4098 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.r2cell.out0->merge.in0"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    %inputPort_4099, %outputPort_4100 = fifo.create<complex<f32>> (4096) {cal.name = "fft__Butterfly$spec_15446289516955298258.r2cell.out1->merge.in1"} : !fifo.input_port<complex<f32>>, !fifo.output_port<complex<f32>>
    cal.create_instance @fft__Merge "merge" device_affinity="cpu0" ()
        ports_in (%outputPort_4098, %outputPort_4100 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_4071 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__TwiddleGenerator__v__N_dyn "twiddles" (%c1_i32 : i32)
        ports_in (%outputPort_4090 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_4095 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Split__v__N_dyn "split" (%c1_i32 : i32)
        ports_in (%outputPort_4088 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_4091, %inputPort_4093 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @__fanout_complex_f32__2 "fft__Butterfly$spec_15446289516955298258.__fanout_complex_f32__2.4" device_affinity="cpu0" ()
        ports_in (%outputPort_4068 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_4087, %inputPort_4089 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Radix2Cell "r2cell" device_affinity="cpu0" ()
        ports_in (%outputPort_4092, %outputPort_4094, %outputPort_4096 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_4097, %inputPort_4099 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Merge "merge" device_affinity="cpu0" ()
        ports_in (%outputPort_4070, %outputPort_4072 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_4005 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Split__v__N_dyn "split" (%c8_i32 : i32)
        ports_in (%outputPort_3864 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3867, %inputPort_3869 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Split__v__N_dyn "split" (%c16_i32 : i32)
        ports_in (%outputPort_3608 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_3611, %inputPort_3613 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Merge "merge" device_affinity="cpu0" ()
        ports_in (%outputPort_2086, %outputPort_2088 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_39 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Radix2Cell "r2cell" device_affinity="cpu0" ()
        ports_in (%outputPort_28, %outputPort_30, %outputPort_32 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_33, %inputPort_35 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Split__v__N_dyn "split" (%c128_i32 : i32)
        ports_in (%outputPort_24 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_27, %inputPort_29 : !fifo.input_port<complex<f32>>, !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__Merge "merge" device_affinity="cpu0" ()
        ports_in (%outputPort_38, %outputPort_40 : !fifo.output_port<complex<f32>>, !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_21 : !fifo.input_port<complex<f32>>)
    cal.create_instance @fft__TwiddleGenerator__v__N_dyn "twiddles" (%c128_i32 : i32)
        ports_in (%outputPort_26 : !fifo.output_port<complex<f32>>)
        ports_out (%inputPort_31 : !fifo.input_port<complex<f32>>)
  }
  
  cal.actor @fft__Add()
    ports_in (
      %arg0: !fifo.output_port<complex<f32>>, 
      %arg1: !fifo.output_port<complex<f32>>
    )
    ports_out (
      %arg2: !fifo.input_port<complex<f32>>
    )
  {
    cal.action "$untagged0" priority=0
    {
      %0 = fifo.pop(%arg0 : !fifo.output_port<complex<f32>>) : complex<f32>
      %1 = fifo.pop(%arg1 : !fifo.output_port<complex<f32>>) : complex<f32>
      %2 = complex.add %0, %1 : complex<f32>
      fifo.push(%arg2 : !fifo.input_port<complex<f32>>, %2 : complex<f32>)
    }
    
  }
  
  cal.actor @fft__Merge()
    ports_in (
      %arg0: !fifo.output_port<complex<f32>>, 
      %arg1: !fifo.output_port<complex<f32>>
    )
    ports_out (
      %arg2: !fifo.input_port<complex<f32>>
    )
  {
    %c1_i32 = arith.constant 1 : i32
    %c0_i32 = arith.constant 0 : i32
    %0 = cal.create_state_var<i32> : !cal.state_ref<i32>
    cal.set(%0 : !cal.state_ref<i32>, %c0_i32 : i32)
    cal.action "A" priority=1
    {
      cal.predicate {
        %2 = cal.get(%0 : !cal.state_ref<i32>) : i32
        %3 = arith.cmpi eq, %2, %c0_i32 : i32
        cal.predicate_result %3 : i1
      }
      %1 = fifo.pop(%arg0 : !fifo.output_port<complex<f32>>) : complex<f32>
      cal.set(%0 : !cal.state_ref<i32>, %c1_i32 : i32)
      fifo.push(%arg2 : !fifo.input_port<complex<f32>>, %1 : complex<f32>)
    }
    
    cal.action "B" priority=1
    {
      cal.predicate {
        %2 = cal.get(%0 : !cal.state_ref<i32>) : i32
        %3 = arith.cmpi eq, %2, %c1_i32 : i32
        cal.predicate_result %3 : i1
      }
      %1 = fifo.pop(%arg1 : !fifo.output_port<complex<f32>>) : complex<f32>
      cal.set(%0 : !cal.state_ref<i32>, %c0_i32 : i32)
      fifo.push(%arg2 : !fifo.input_port<complex<f32>>, %1 : complex<f32>)
    }
    
  }
  
  cal.actor @fft__Radix2Cell()
    ports_in (
      %arg0: !fifo.output_port<complex<f32>>, 
      %arg1: !fifo.output_port<complex<f32>>, 
      %arg2: !fifo.output_port<complex<f32>>
    )
    ports_out (
      %arg3: !fifo.input_port<complex<f32>>, 
      %arg4: !fifo.input_port<complex<f32>>
    )
  {
    cal.action "$untagged0" priority=0
    {
      %0 = fifo.pop(%arg0 : !fifo.output_port<complex<f32>>) : complex<f32>
      %1 = fifo.pop(%arg1 : !fifo.output_port<complex<f32>>) : complex<f32>
      %2 = fifo.pop(%arg2 : !fifo.output_port<complex<f32>>) : complex<f32>
      %3 = complex.add %0, %1 : complex<f32>
      fifo.push(%arg3 : !fifo.input_port<complex<f32>>, %3 : complex<f32>)
      %4 = complex.sub %0, %1 : complex<f32>
      %5 = complex.mul %4, %2 : complex<f32>
      fifo.push(%arg4 : !fifo.input_port<complex<f32>>, %5 : complex<f32>)
    }
    
  }
  
  cal.actor @fft__Trigger__v__N_256(%arg0: i32)
    ports_out (
      %arg1: !fifo.input_port<i32>
    )
  {
    %c1_i32 = arith.constant 1 : i32
    %c0_i32 = arith.constant 0 : i32
    %0 = cal.create_state_var<i32> : !cal.state_ref<i32>
    cal.set(%0 : !cal.state_ref<i32>, %c0_i32 : i32)
    cal.action "$untagged0" priority=0
    {
      cal.predicate {
        %4 = cal.get(%0 : !cal.state_ref<i32>) : i32
        %5 = arith.cmpi ult, %4, %arg0 : i32
        cal.predicate_result %5 : i1
      }
      %1 = cal.get(%0 : !cal.state_ref<i32>) : i32
      %2 = arith.addi %1, %c1_i32 : i32
      cal.set(%0 : !cal.state_ref<i32>, %2 : i32)
      %3 = cal.get(%0 : !cal.state_ref<i32>) : i32
      fifo.push(%arg1 : !fifo.input_port<i32>, %3 : i32)
    }
    
  }
  
  cal.actor @fft__Sine__v__d_dyn(%arg0: f32)
    ports_in (
      %arg1: !fifo.output_port<i32>
    )
    ports_out (
      %arg2: !fifo.input_port<complex<f32>>
    )
  {
    %cst = arith.constant 0.000000e+00 : f32
    %0 = cal.create_state_var<complex<f32>> : !cal.state_ref<complex<f32>>
    %1 = complex.create %cst, %cst : complex<f32>
    cal.set(%0 : !cal.state_ref<complex<f32>>, %1 : complex<f32>)
    cal.action "$untagged0" priority=0
    {
      %2 = fifo.pop(%arg1 : !fifo.output_port<i32>) : i32
      %3 = cal.get(%0 : !cal.state_ref<complex<f32>>) : complex<f32>
      %4 = complex.create %arg0, %cst : complex<f32>
      %5 = complex.add %3, %4 : complex<f32>
      cal.set(%0 : !cal.state_ref<complex<f32>>, %5 : complex<f32>)
      %6 = cal.get(%0 : !cal.state_ref<complex<f32>>) : complex<f32>
      %7 = complex.sin %6 : complex<f32>
      fifo.push(%arg2 : !fifo.input_port<complex<f32>>, %7 : complex<f32>)
    }
    
  }
  
  func.func @fft__Butterfly__fn_pow2(%arg0: i32) -> i32 attributes {cal.ns = "fft", cal.owner = "Butterfly", jit.engine_ready, jit.isolation_built, jit.isolation_func_count = 1 : i32, jit.lower_to_llvm.funcs = 1 : i32, jit.lower_to_llvm.ok} {
    %c2_i32 = arith.constant 2 : i32
    %c1_i32 = arith.constant 1 : i32
    %c0_i32 = arith.constant 0 : i32
    %0 = arith.cmpi eq, %arg0, %c0_i32 : i32
    %1 = scf.if %0 -> (i32) {
      scf.yield %c1_i32 : i32
    } else {
      %2 = arith.subi %arg0, %c1_i32 : i32
      %3 = func.call @fft__Butterfly__fn_pow2(%2) : (i32) -> i32
      %4 = arith.muli %3, %c2_i32 : i32
      scf.yield %4 : i32
    }
    return %1 : i32
  }
  cal.actor @fft__ConstantMultiply__v__c_dyn(%arg0: f32)
    ports_in (
      %arg1: !fifo.output_port<complex<f32>>
    )
    ports_out (
      %arg2: !fifo.input_port<complex<f32>>
    )
  {
    %cst = arith.constant 0.000000e+00 : f32
    cal.action "$untagged0" priority=0
    {
      %0 = fifo.pop(%arg1 : !fifo.output_port<complex<f32>>) : complex<f32>
      %1 = complex.create %arg0, %cst : complex<f32>
      %2 = complex.mul %1, %0 : complex<f32>
      fifo.push(%arg2 : !fifo.input_port<complex<f32>>, %2 : complex<f32>)
    }
    
  }
  
  cal.actor @fft__Split__v__N_dyn(%arg0: i32)
    ports_in (
      %arg1: !fifo.output_port<complex<f32>>
    )
    ports_out (
      %arg2: !fifo.input_port<complex<f32>>, 
      %arg3: !fifo.input_port<complex<f32>>
    )
  {
    %false = arith.constant false
    %c1_i32 = arith.constant 1 : i32
    %c0_i32 = arith.constant 0 : i32
    %true = arith.constant true
    %0 = cal.create_state_var<i1> : !cal.state_ref<i1>
    cal.set(%0 : !cal.state_ref<i1>, %true : i1)
    %1 = cal.create_state_var<i32> : !cal.state_ref<i32>
    cal.set(%1 : !cal.state_ref<i32>, %c0_i32 : i32)
    cal.action "$untagged0" priority=1
    {
      cal.predicate {
        %7 = cal.get(%0 : !cal.state_ref<i1>) : i1
        cal.predicate_result %7 : i1
      }
      %2 = fifo.pop(%arg1 : !fifo.output_port<complex<f32>>) : complex<f32>
      %3 = cal.get(%1 : !cal.state_ref<i32>) : i32
      %4 = arith.addi %3, %c1_i32 : i32
      cal.set(%1 : !cal.state_ref<i32>, %4 : i32)
      %5 = cal.get(%1 : !cal.state_ref<i32>) : i32
      %6 = arith.cmpi uge, %5, %arg0 : i32
      scf.if %6 {
        cal.set(%1 : !cal.state_ref<i32>, %c0_i32 : i32)
        cal.set(%0 : !cal.state_ref<i1>, %false : i1)
      }
      fifo.push(%arg2 : !fifo.input_port<complex<f32>>, %2 : complex<f32>)
    }
    
    cal.action "$untagged1" priority=1
    {
      cal.predicate {
        %7 = cal.get(%0 : !cal.state_ref<i1>) : i1
        %8 = arith.xori %7, %true : i1
        cal.predicate_result %8 : i1
      }
      %2 = fifo.pop(%arg1 : !fifo.output_port<complex<f32>>) : complex<f32>
      %3 = cal.get(%1 : !cal.state_ref<i32>) : i32
      %4 = arith.addi %3, %c1_i32 : i32
      cal.set(%1 : !cal.state_ref<i32>, %4 : i32)
      %5 = cal.get(%1 : !cal.state_ref<i32>) : i32
      %6 = arith.cmpi uge, %5, %arg0 : i32
      scf.if %6 {
        cal.set(%1 : !cal.state_ref<i32>, %c0_i32 : i32)
        cal.set(%0 : !cal.state_ref<i1>, %true : i1)
      }
      fifo.push(%arg3 : !fifo.input_port<complex<f32>>, %2 : complex<f32>)
    }
    
  }
  
  cal.actor @fft__TwiddleGenerator__v__N_dyn(%arg0: i32)
    ports_in (
      %arg1: !fifo.output_port<complex<f32>>
    )
    ports_out (
      %arg2: !fifo.input_port<complex<f32>>
    )
  {
    %cst = arith.constant 0.000000e+00 : f32
    %c0 = arith.constant 0 : index
    %cst_0 = arith.constant -3.14159274 : f32
    %c1 = arith.constant 1 : index
    %c1_i32 = arith.constant 1 : i32
    %c0_i32 = arith.constant 0 : i32
    %0 = cal.create_state_var<i32> : !cal.state_ref<i32>
    cal.set(%0 : !cal.state_ref<i32>, %c0_i32 : i32)
    %1 = cal.create_state_var<f32> : !cal.state_ref<f32>
    cal.set(%1 : !cal.state_ref<f32>, %cst_0 : f32)
    %2 = arith.index_cast %arg0 : i32 to index
    %3 = cal.create_state_var<memref<?xcomplex<f32>>> (%2 : index) : !cal.state_ref<memref<?xcomplex<f32>>>
    %4 = cal.get(%3 : !cal.state_ref<memref<?xcomplex<f32>>>) : memref<?xcomplex<f32>>
    %5 = arith.subi %arg0, %c1_i32 : i32
    %6 = arith.index_cast %5 : i32 to index
    %7 = arith.addi %6, %c1 : index
    scf.for %arg3 = %c0 to %7 step %c1 {
      %8 = arith.index_cast %arg3 : index to i32
      %9 = cal.get(%1 : !cal.state_ref<f32>) : f32
      %10 = arith.negf %9 : f32
      %11 = arith.fptosi %10 : f32 to i32
      %12 = arith.muli %11, %8 : i32
      %13 = arith.divui %12, %arg0 : i32
      %14 = arith.sitofp %13 : i32 to f32
      %15 = complex.create %cst, %14 : complex<f32>
      %16 = complex.exp %15 : complex<f32>
      memref.store %16, %4[%arg3] : memref<?xcomplex<f32>>
    }
    cal.action "$untagged0" priority=0
    {
      %8 = fifo.pop(%arg1 : !fifo.output_port<complex<f32>>) : complex<f32>
      %9 = fifo.pop(%arg1 : !fifo.output_port<complex<f32>>) : complex<f32>
      %10 = cal.get(%0 : !cal.state_ref<i32>) : i32
      %11 = arith.addi %10, %c1_i32 : i32
      cal.set(%0 : !cal.state_ref<i32>, %11 : i32)
      %12 = cal.get(%0 : !cal.state_ref<i32>) : i32
      %13 = arith.cmpi uge, %12, %arg0 : i32
      scf.if %13 {
        cal.set(%0 : !cal.state_ref<i32>, %c0_i32 : i32)
      }
      %14 = cal.get(%3 : !cal.state_ref<memref<?xcomplex<f32>>>) : memref<?xcomplex<f32>>
      %15 = cal.get(%0 : !cal.state_ref<i32>) : i32
      %16 = arith.index_cast %15 : i32 to index
      %17 = memref.load %14[%16] : memref<?xcomplex<f32>>
      fifo.push(%arg2 : !fifo.input_port<complex<f32>>, %17 : complex<f32>)
    }
    
  }
  
  cal.actor @fft__ConstantMultiply__v__c_dyn$spec_8169147697905524375(%arg0: f32)
    ports_in (
      %arg1: !fifo.output_port<complex<f32>>
    )
    ports_out (
      %arg2: !fifo.input_port<complex<f32>>
    )
  {
    %cst = arith.constant 6.250000e-02 : f32
    %cst_0 = arith.constant 0.000000e+00 : f32
    cal.action "$untagged0" priority=0
    {
      %0 = fifo.pop(%arg1 : !fifo.output_port<complex<f32>>) : complex<f32>
      %1 = complex.create %cst, %cst_0 : complex<f32>
      %2 = complex.mul %1, %0 : complex<f32>
      fifo.push(%arg2 : !fifo.input_port<complex<f32>>, %2 : complex<f32>)
    }
    
  }
  
  cal.actor @fft__Sine__v__d_dyn$spec_13554697526108865926(%arg0: f32)
    ports_in (
      %arg1: !fifo.output_port<i32>
    )
    ports_out (
      %arg2: !fifo.input_port<complex<f32>>
    )
  {
    %cst = arith.constant 0.0897142887 : f32
    %cst_0 = arith.constant 0.000000e+00 : f32
    %0 = cal.create_state_var<complex<f32>> : !cal.state_ref<complex<f32>>
    %1 = complex.create %cst_0, %cst_0 : complex<f32>
    cal.set(%0 : !cal.state_ref<complex<f32>>, %1 : complex<f32>)
    cal.action "$untagged0" priority=0
    {
      %2 = fifo.pop(%arg1 : !fifo.output_port<i32>) : i32
      %3 = cal.get(%0 : !cal.state_ref<complex<f32>>) : complex<f32>
      %4 = complex.create %cst, %cst_0 : complex<f32>
      %5 = complex.add %3, %4 : complex<f32>
      cal.set(%0 : !cal.state_ref<complex<f32>>, %5 : complex<f32>)
      %6 = cal.get(%0 : !cal.state_ref<complex<f32>>) : complex<f32>
      %7 = complex.sin %6 : complex<f32>
      fifo.push(%arg2 : !fifo.input_port<complex<f32>>, %7 : complex<f32>)
    }
    
  }
  
  cal.actor @fft__Sine__v__d_dyn$spec_10385615261197223207(%arg0: f32)
    ports_in (
      %arg1: !fifo.output_port<i32>
    )
    ports_out (
      %arg2: !fifo.input_port<complex<f32>>
    )
  {
    %cst = arith.constant 0.209333345 : f32
    %cst_0 = arith.constant 0.000000e+00 : f32
    %0 = cal.create_state_var<complex<f32>> : !cal.state_ref<complex<f32>>
    %1 = complex.create %cst_0, %cst_0 : complex<f32>
    cal.set(%0 : !cal.state_ref<complex<f32>>, %1 : complex<f32>)
    cal.action "$untagged0" priority=0
    {
      %2 = fifo.pop(%arg1 : !fifo.output_port<i32>) : i32
      %3 = cal.get(%0 : !cal.state_ref<complex<f32>>) : complex<f32>
      %4 = complex.create %cst, %cst_0 : complex<f32>
      %5 = complex.add %3, %4 : complex<f32>
      cal.set(%0 : !cal.state_ref<complex<f32>>, %5 : complex<f32>)
      %6 = cal.get(%0 : !cal.state_ref<complex<f32>>) : complex<f32>
      %7 = complex.sin %6 : complex<f32>
      fifo.push(%arg2 : !fifo.input_port<complex<f32>>, %7 : complex<f32>)
    }
    
  }
  
  cal.actor @fft__Sine__v__d_dyn$spec_15203075921786301832(%arg0: f32)
    ports_in (
      %arg1: !fifo.output_port<i32>
    )
    ports_out (
      %arg2: !fifo.input_port<complex<f32>>
    )
  {
    %cst = arith.constant 3.140000e-01 : f32
    %cst_0 = arith.constant 0.000000e+00 : f32
    %0 = cal.create_state_var<complex<f32>> : !cal.state_ref<complex<f32>>
    %1 = complex.create %cst_0, %cst_0 : complex<f32>
    cal.set(%0 : !cal.state_ref<complex<f32>>, %1 : complex<f32>)
    cal.action "$untagged0" priority=0
    {
      %2 = fifo.pop(%arg1 : !fifo.output_port<i32>) : i32
      %3 = cal.get(%0 : !cal.state_ref<complex<f32>>) : complex<f32>
      %4 = complex.create %cst, %cst_0 : complex<f32>
      %5 = complex.add %3, %4 : complex<f32>
      cal.set(%0 : !cal.state_ref<complex<f32>>, %5 : complex<f32>)
      %6 = cal.get(%0 : !cal.state_ref<complex<f32>>) : complex<f32>
      %7 = complex.sin %6 : complex<f32>
      fifo.push(%arg2 : !fifo.input_port<complex<f32>>, %7 : complex<f32>)
    }
    
  }
  
  cal.actor @fft__Trigger__v__N_256$spec_17870807604530591867(%arg0: i32)
    ports_out (
      %arg1: !fifo.input_port<i32>
    )
  {
    %c256_i32 = arith.constant 256 : i32
    %c1_i32 = arith.constant 1 : i32
    %c0_i32 = arith.constant 0 : i32
    %0 = cal.create_state_var<i32> : !cal.state_ref<i32>
    cal.set(%0 : !cal.state_ref<i32>, %c0_i32 : i32)
    cal.action "$untagged0" priority=0
    {
      cal.predicate {
        %4 = cal.get(%0 : !cal.state_ref<i32>) : i32
        %5 = arith.cmpi ult, %4, %c256_i32 : i32
        cal.predicate_result %5 : i1
      }
      %1 = cal.get(%0 : !cal.state_ref<i32>) : i32
      %2 = arith.addi %1, %c1_i32 : i32
      cal.set(%0 : !cal.state_ref<i32>, %2 : i32)
      %3 = cal.get(%0 : !cal.state_ref<i32>) : i32
      fifo.push(%arg1 : !fifo.input_port<i32>, %3 : i32)
    }
    
  }
  
}

