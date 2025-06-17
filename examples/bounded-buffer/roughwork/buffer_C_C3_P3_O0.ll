; ModuleID = 'myproject/actor_bufferActor.c'
source_filename = "myproject/actor_bufferActor.c"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

%struct.channel_list_uint8_t_1 = type { ptr }
%struct.channel_list_float_1 = type { ptr }
%struct.channel_list_uint32_t_1 = type { ptr }
%struct.bufferActor_state = type { i32, ptr, ptr, ptr, ptr, ptr, ptr, %struct.channel_list_uint8_t_1, %struct.channel_list_uint8_t_1, %struct.channel_list_uint8_t_1, %struct.channel_list_float_1, %struct.channel_list_float_1, %struct.channel_list_float_1, %struct.channel_list_float_1, %struct.channel_list_float_1, %struct.channel_list_uint32_t_1, %struct.channel_list_uint32_t_1, %struct._S3_N4_list_N2_u1_N1_3, %struct._S3_N4_list_N2_u1_N1_3, %struct._S3_N4_list_S2_N4_real_N2_32_N2_50, i32, i32, i32, i32, i32, float, float }
%struct._S3_N4_list_N2_u1_N1_3 = type { [3 x i8] }
%struct._S3_N4_list_S2_N4_real_N2_32_N2_50 = type { [50 x float] }
%struct.channel_uint8_t_1 = type { i64, i64, ptr }
%struct.channel_float_1 = type { i64, i64, ptr }
%struct.channel_uint32_t_1 = type { i64, i64, ptr }

@"g_bndBuffer_$eval6" = external global i32, align 4
@"g_bndBuffer_$eval7" = external global i32, align 4
@"g_bndBuffer_$eval8" = external global i32, align 4

; Function Attrs: noinline nounwind optnone uwtable
define dso_local void @bufferActor_init_actor(ptr noundef %self, ptr noundef %FromProducer_array_0_x_channel, ptr noundef %FromProducer_array_1_x_channel, ptr noundef %FromProducer_array_2_x_channel, ptr noundef %FromConsumer_array_0_x_channel, ptr noundef %FromConsumer_array_1_x_channel, ptr noundef %FromConsumer_array_2_x_channel, i64 %ToProducer_array_0_x_channels.coerce, i64 %ToProducer_array_1_x_channels.coerce, i64 %ToProducer_array_2_x_channels.coerce, i64 %ToConsumer_array_0_x_channels.coerce, i64 %ToConsumer_array_1_x_channels.coerce, i64 %ToConsumer_array_2_x_channels.coerce, i64 %sumProducersPort_channels.coerce, i64 %sumConsumersPort_channels.coerce, i64 %totalItemsFromProducers_channels.coerce, i64 %totalItemsFromConsumers_channels.coerce) #0 {
entry:
  %ToProducer_array_0_x_channels = alloca %struct.channel_list_uint8_t_1, align 8
  %ToProducer_array_1_x_channels = alloca %struct.channel_list_uint8_t_1, align 8
  %ToProducer_array_2_x_channels = alloca %struct.channel_list_uint8_t_1, align 8
  %ToConsumer_array_0_x_channels = alloca %struct.channel_list_float_1, align 8
  %ToConsumer_array_1_x_channels = alloca %struct.channel_list_float_1, align 8
  %ToConsumer_array_2_x_channels = alloca %struct.channel_list_float_1, align 8
  %sumProducersPort_channels = alloca %struct.channel_list_float_1, align 8
  %sumConsumersPort_channels = alloca %struct.channel_list_float_1, align 8
  %totalItemsFromProducers_channels = alloca %struct.channel_list_uint32_t_1, align 8
  %totalItemsFromConsumers_channels = alloca %struct.channel_list_uint32_t_1, align 8
  %self.addr = alloca ptr, align 8
  %FromProducer_array_0_x_channel.addr = alloca ptr, align 8
  %FromProducer_array_1_x_channel.addr = alloca ptr, align 8
  %FromProducer_array_2_x_channel.addr = alloca ptr, align 8
  %FromConsumer_array_0_x_channel.addr = alloca ptr, align 8
  %FromConsumer_array_1_x_channel.addr = alloca ptr, align 8
  %FromConsumer_array_2_x_channel.addr = alloca ptr, align 8
  %coerce.dive = getelementptr inbounds nuw %struct.channel_list_uint8_t_1, ptr %ToProducer_array_0_x_channels, i32 0, i32 0
  %coerce.val.ip = inttoptr i64 %ToProducer_array_0_x_channels.coerce to ptr
  store ptr %coerce.val.ip, ptr %coerce.dive, align 8
  %coerce.dive1 = getelementptr inbounds nuw %struct.channel_list_uint8_t_1, ptr %ToProducer_array_1_x_channels, i32 0, i32 0
  %coerce.val.ip2 = inttoptr i64 %ToProducer_array_1_x_channels.coerce to ptr
  store ptr %coerce.val.ip2, ptr %coerce.dive1, align 8
  %coerce.dive3 = getelementptr inbounds nuw %struct.channel_list_uint8_t_1, ptr %ToProducer_array_2_x_channels, i32 0, i32 0
  %coerce.val.ip4 = inttoptr i64 %ToProducer_array_2_x_channels.coerce to ptr
  store ptr %coerce.val.ip4, ptr %coerce.dive3, align 8
  %coerce.dive5 = getelementptr inbounds nuw %struct.channel_list_float_1, ptr %ToConsumer_array_0_x_channels, i32 0, i32 0
  %coerce.val.ip6 = inttoptr i64 %ToConsumer_array_0_x_channels.coerce to ptr
  store ptr %coerce.val.ip6, ptr %coerce.dive5, align 8
  %coerce.dive7 = getelementptr inbounds nuw %struct.channel_list_float_1, ptr %ToConsumer_array_1_x_channels, i32 0, i32 0
  %coerce.val.ip8 = inttoptr i64 %ToConsumer_array_1_x_channels.coerce to ptr
  store ptr %coerce.val.ip8, ptr %coerce.dive7, align 8
  %coerce.dive9 = getelementptr inbounds nuw %struct.channel_list_float_1, ptr %ToConsumer_array_2_x_channels, i32 0, i32 0
  %coerce.val.ip10 = inttoptr i64 %ToConsumer_array_2_x_channels.coerce to ptr
  store ptr %coerce.val.ip10, ptr %coerce.dive9, align 8
  %coerce.dive11 = getelementptr inbounds nuw %struct.channel_list_float_1, ptr %sumProducersPort_channels, i32 0, i32 0
  %coerce.val.ip12 = inttoptr i64 %sumProducersPort_channels.coerce to ptr
  store ptr %coerce.val.ip12, ptr %coerce.dive11, align 8
  %coerce.dive13 = getelementptr inbounds nuw %struct.channel_list_float_1, ptr %sumConsumersPort_channels, i32 0, i32 0
  %coerce.val.ip14 = inttoptr i64 %sumConsumersPort_channels.coerce to ptr
  store ptr %coerce.val.ip14, ptr %coerce.dive13, align 8
  %coerce.dive15 = getelementptr inbounds nuw %struct.channel_list_uint32_t_1, ptr %totalItemsFromProducers_channels, i32 0, i32 0
  %coerce.val.ip16 = inttoptr i64 %totalItemsFromProducers_channels.coerce to ptr
  store ptr %coerce.val.ip16, ptr %coerce.dive15, align 8
  %coerce.dive17 = getelementptr inbounds nuw %struct.channel_list_uint32_t_1, ptr %totalItemsFromConsumers_channels, i32 0, i32 0
  %coerce.val.ip18 = inttoptr i64 %totalItemsFromConsumers_channels.coerce to ptr
  store ptr %coerce.val.ip18, ptr %coerce.dive17, align 8
  store ptr %self, ptr %self.addr, align 8
  store ptr %FromProducer_array_0_x_channel, ptr %FromProducer_array_0_x_channel.addr, align 8
  store ptr %FromProducer_array_1_x_channel, ptr %FromProducer_array_1_x_channel.addr, align 8
  store ptr %FromProducer_array_2_x_channel, ptr %FromProducer_array_2_x_channel.addr, align 8
  store ptr %FromConsumer_array_0_x_channel, ptr %FromConsumer_array_0_x_channel.addr, align 8
  store ptr %FromConsumer_array_1_x_channel, ptr %FromConsumer_array_1_x_channel.addr, align 8
  store ptr %FromConsumer_array_2_x_channel, ptr %FromConsumer_array_2_x_channel.addr, align 8
  %0 = load ptr, ptr %self.addr, align 8
  %program_counter = getelementptr inbounds nuw %struct.bufferActor_state, ptr %0, i32 0, i32 0
  store i32 0, ptr %program_counter, align 8
  %1 = load ptr, ptr %FromProducer_array_0_x_channel.addr, align 8
  %2 = load ptr, ptr %self.addr, align 8
  %FromProducer_array_0_x_channel19 = getelementptr inbounds nuw %struct.bufferActor_state, ptr %2, i32 0, i32 1
  store ptr %1, ptr %FromProducer_array_0_x_channel19, align 8
  %3 = load ptr, ptr %FromProducer_array_1_x_channel.addr, align 8
  %4 = load ptr, ptr %self.addr, align 8
  %FromProducer_array_1_x_channel20 = getelementptr inbounds nuw %struct.bufferActor_state, ptr %4, i32 0, i32 2
  store ptr %3, ptr %FromProducer_array_1_x_channel20, align 8
  %5 = load ptr, ptr %FromProducer_array_2_x_channel.addr, align 8
  %6 = load ptr, ptr %self.addr, align 8
  %FromProducer_array_2_x_channel21 = getelementptr inbounds nuw %struct.bufferActor_state, ptr %6, i32 0, i32 3
  store ptr %5, ptr %FromProducer_array_2_x_channel21, align 8
  %7 = load ptr, ptr %FromConsumer_array_0_x_channel.addr, align 8
  %8 = load ptr, ptr %self.addr, align 8
  %FromConsumer_array_0_x_channel22 = getelementptr inbounds nuw %struct.bufferActor_state, ptr %8, i32 0, i32 4
  store ptr %7, ptr %FromConsumer_array_0_x_channel22, align 8
  %9 = load ptr, ptr %FromConsumer_array_1_x_channel.addr, align 8
  %10 = load ptr, ptr %self.addr, align 8
  %FromConsumer_array_1_x_channel23 = getelementptr inbounds nuw %struct.bufferActor_state, ptr %10, i32 0, i32 5
  store ptr %9, ptr %FromConsumer_array_1_x_channel23, align 8
  %11 = load ptr, ptr %FromConsumer_array_2_x_channel.addr, align 8
  %12 = load ptr, ptr %self.addr, align 8
  %FromConsumer_array_2_x_channel24 = getelementptr inbounds nuw %struct.bufferActor_state, ptr %12, i32 0, i32 6
  store ptr %11, ptr %FromConsumer_array_2_x_channel24, align 8
  %13 = load ptr, ptr %self.addr, align 8
  %ToProducer_array_0_x_channels25 = getelementptr inbounds nuw %struct.bufferActor_state, ptr %13, i32 0, i32 7
  call void @llvm.memcpy.p0.p0.i64(ptr align 8 %ToProducer_array_0_x_channels25, ptr align 8 %ToProducer_array_0_x_channels, i64 8, i1 false)
  %14 = load ptr, ptr %self.addr, align 8
  %ToProducer_array_1_x_channels26 = getelementptr inbounds nuw %struct.bufferActor_state, ptr %14, i32 0, i32 8
  call void @llvm.memcpy.p0.p0.i64(ptr align 8 %ToProducer_array_1_x_channels26, ptr align 8 %ToProducer_array_1_x_channels, i64 8, i1 false)
  %15 = load ptr, ptr %self.addr, align 8
  %ToProducer_array_2_x_channels27 = getelementptr inbounds nuw %struct.bufferActor_state, ptr %15, i32 0, i32 9
  call void @llvm.memcpy.p0.p0.i64(ptr align 8 %ToProducer_array_2_x_channels27, ptr align 8 %ToProducer_array_2_x_channels, i64 8, i1 false)
  %16 = load ptr, ptr %self.addr, align 8
  %ToConsumer_array_0_x_channels28 = getelementptr inbounds nuw %struct.bufferActor_state, ptr %16, i32 0, i32 10
  call void @llvm.memcpy.p0.p0.i64(ptr align 8 %ToConsumer_array_0_x_channels28, ptr align 8 %ToConsumer_array_0_x_channels, i64 8, i1 false)
  %17 = load ptr, ptr %self.addr, align 8
  %ToConsumer_array_1_x_channels29 = getelementptr inbounds nuw %struct.bufferActor_state, ptr %17, i32 0, i32 11
  call void @llvm.memcpy.p0.p0.i64(ptr align 8 %ToConsumer_array_1_x_channels29, ptr align 8 %ToConsumer_array_1_x_channels, i64 8, i1 false)
  %18 = load ptr, ptr %self.addr, align 8
  %ToConsumer_array_2_x_channels30 = getelementptr inbounds nuw %struct.bufferActor_state, ptr %18, i32 0, i32 12
  call void @llvm.memcpy.p0.p0.i64(ptr align 8 %ToConsumer_array_2_x_channels30, ptr align 8 %ToConsumer_array_2_x_channels, i64 8, i1 false)
  %19 = load ptr, ptr %self.addr, align 8
  %sumProducersPort_channels31 = getelementptr inbounds nuw %struct.bufferActor_state, ptr %19, i32 0, i32 13
  call void @llvm.memcpy.p0.p0.i64(ptr align 8 %sumProducersPort_channels31, ptr align 8 %sumProducersPort_channels, i64 8, i1 false)
  %20 = load ptr, ptr %self.addr, align 8
  %sumConsumersPort_channels32 = getelementptr inbounds nuw %struct.bufferActor_state, ptr %20, i32 0, i32 14
  call void @llvm.memcpy.p0.p0.i64(ptr align 8 %sumConsumersPort_channels32, ptr align 8 %sumConsumersPort_channels, i64 8, i1 false)
  %21 = load ptr, ptr %self.addr, align 8
  %totalItemsFromProducers_channels33 = getelementptr inbounds nuw %struct.bufferActor_state, ptr %21, i32 0, i32 15
  call void @llvm.memcpy.p0.p0.i64(ptr align 8 %totalItemsFromProducers_channels33, ptr align 8 %totalItemsFromProducers_channels, i64 8, i1 false)
  %22 = load ptr, ptr %self.addr, align 8
  %totalItemsFromConsumers_channels34 = getelementptr inbounds nuw %struct.bufferActor_state, ptr %22, i32 0, i32 16
  call void @llvm.memcpy.p0.p0.i64(ptr align 8 %totalItemsFromConsumers_channels34, ptr align 8 %totalItemsFromConsumers_channels, i64 8, i1 false)
  %23 = load ptr, ptr %self.addr, align 8
  call void @bufferActor_init_scope_0(ptr noundef %23)
  ret void
}

; Function Attrs: nocallback nofree nounwind willreturn memory(argmem: readwrite)
declare void @llvm.memcpy.p0.p0.i64(ptr noalias nocapture writeonly, ptr noalias nocapture readonly, i64, i1 immarg) #1

; Function Attrs: noinline nounwind optnone uwtable
define internal void @bufferActor_init_scope_0(ptr noundef %self) #0 {
entry:
  %self.addr = alloca ptr, align 8
  %t_131 = alloca %struct._S3_N4_list_N2_u1_N1_3, align 1
  %t_132 = alloca %struct._S3_N4_list_N2_u1_N1_3, align 1
  %t_133 = alloca %struct._S3_N4_list_S2_N4_real_N2_32_N2_50, align 4
  store ptr %self, ptr %self.addr, align 8
  call void @llvm.memset.p0.i64(ptr align 1 %t_131, i8 0, i64 3, i1 false)
  %0 = load ptr, ptr %self.addr, align 8
  %a_busyProducers__9 = getelementptr inbounds nuw %struct.bufferActor_state, ptr %0, i32 0, i32 17
  call void @llvm.memcpy.p0.p0.i64(ptr align 8 %a_busyProducers__9, ptr align 1 %t_131, i64 3, i1 false)
  call void @llvm.memset.p0.i64(ptr align 1 %t_132, i8 0, i64 3, i1 false)
  %1 = load ptr, ptr %self.addr, align 8
  %a_freeConsumers__10 = getelementptr inbounds nuw %struct.bufferActor_state, ptr %1, i32 0, i32 18
  call void @llvm.memcpy.p0.p0.i64(ptr align 1 %a_freeConsumers__10, ptr align 1 %t_132, i64 3, i1 false)
  call void @llvm.memset.p0.i64(ptr align 4 %t_133, i8 0, i64 200, i1 false)
  %2 = load ptr, ptr %self.addr, align 8
  %a_buffer__11 = getelementptr inbounds nuw %struct.bufferActor_state, ptr %2, i32 0, i32 19
  call void @llvm.memcpy.p0.p0.i64(ptr align 8 %a_buffer__11, ptr align 4 %t_133, i64 200, i1 false)
  %3 = load ptr, ptr %self.addr, align 8
  %a_itemsOnBuffer__12 = getelementptr inbounds nuw %struct.bufferActor_state, ptr %3, i32 0, i32 20
  store i32 0, ptr %a_itemsOnBuffer__12, align 8
  %4 = load ptr, ptr %self.addr, align 8
  %a_bufferFrontLocation__13 = getelementptr inbounds nuw %struct.bufferActor_state, ptr %4, i32 0, i32 21
  store i32 0, ptr %a_bufferFrontLocation__13, align 4
  %5 = load ptr, ptr %self.addr, align 8
  %a_pendingItems__14 = getelementptr inbounds nuw %struct.bufferActor_state, ptr %5, i32 0, i32 22
  store i32 0, ptr %a_pendingItems__14, align 8
  %6 = load ptr, ptr %self.addr, align 8
  %a_totalItemsFromConsumers__15 = getelementptr inbounds nuw %struct.bufferActor_state, ptr %6, i32 0, i32 23
  store i32 0, ptr %a_totalItemsFromConsumers__15, align 4
  %7 = load ptr, ptr %self.addr, align 8
  %a_totalItemsFromProducers__16 = getelementptr inbounds nuw %struct.bufferActor_state, ptr %7, i32 0, i32 24
  store i32 0, ptr %a_totalItemsFromProducers__16, align 8
  %8 = load ptr, ptr %self.addr, align 8
  %a_sumProducers__17 = getelementptr inbounds nuw %struct.bufferActor_state, ptr %8, i32 0, i32 25
  store float 0.000000e+00, ptr %a_sumProducers__17, align 4
  %9 = load ptr, ptr %self.addr, align 8
  %a_sumConsumers__18 = getelementptr inbounds nuw %struct.bufferActor_state, ptr %9, i32 0, i32 26
  store float 0.000000e+00, ptr %a_sumConsumers__18, align 8
  ret void
}

; Function Attrs: noinline nounwind optnone uwtable
define dso_local void @bufferActor_free_actor(ptr noundef %self) #0 {
entry:
  %self.addr = alloca ptr, align 8
  store ptr %self, ptr %self.addr, align 8
  %0 = load ptr, ptr %self.addr, align 8
  call void @bufferActor_free_scope_0(ptr noundef %0)
  ret void
}

; Function Attrs: noinline nounwind optnone uwtable
define internal void @bufferActor_free_scope_0(ptr noundef %self) #0 {
entry:
  %self.addr = alloca ptr, align 8
  %i = alloca i64, align 8
  %i1 = alloca i64, align 8
  %i8 = alloca i64, align 8
  store ptr %self, ptr %self.addr, align 8
  store i64 0, ptr %i, align 8
  br label %for.cond

for.cond:                                         ; preds = %for.inc, %entry
  %0 = load i64, ptr %i, align 8
  %cmp = icmp ult i64 %0, 3
  br i1 %cmp, label %for.body, label %for.end

for.body:                                         ; preds = %for.cond
  br label %for.inc

for.inc:                                          ; preds = %for.body
  %1 = load i64, ptr %i, align 8
  %inc = add i64 %1, 1
  store i64 %inc, ptr %i, align 8
  br label %for.cond, !llvm.loop !6

for.end:                                          ; preds = %for.cond
  store i64 0, ptr %i1, align 8
  br label %for.cond2

for.cond2:                                        ; preds = %for.inc5, %for.end
  %2 = load i64, ptr %i1, align 8
  %cmp3 = icmp ult i64 %2, 3
  br i1 %cmp3, label %for.body4, label %for.end7

for.body4:                                        ; preds = %for.cond2
  br label %for.inc5

for.inc5:                                         ; preds = %for.body4
  %3 = load i64, ptr %i1, align 8
  %inc6 = add i64 %3, 1
  store i64 %inc6, ptr %i1, align 8
  br label %for.cond2, !llvm.loop !8

for.end7:                                         ; preds = %for.cond2
  store i64 0, ptr %i8, align 8
  br label %for.cond9

for.cond9:                                        ; preds = %for.inc12, %for.end7
  %4 = load i64, ptr %i8, align 8
  %cmp10 = icmp ult i64 %4, 50
  br i1 %cmp10, label %for.body11, label %for.end14

for.body11:                                       ; preds = %for.cond9
  br label %for.inc12

for.inc12:                                        ; preds = %for.body11
  %5 = load i64, ptr %i8, align 8
  %inc13 = add i64 %5, 1
  store i64 %inc13, ptr %i8, align 8
  br label %for.cond9, !llvm.loop !9

for.end14:                                        ; preds = %for.cond9
  ret void
}

; Function Attrs: noinline nounwind optnone uwtable
define dso_local zeroext i1 @bufferActor_run(ptr noundef %self) #0 {
entry:
  %self.addr = alloca ptr, align 8
  %progress = alloca i8, align 1
  store ptr %self, ptr %self.addr, align 8
  store i8 0, ptr %progress, align 1
  %0 = load ptr, ptr %self.addr, align 8
  %program_counter = getelementptr inbounds nuw %struct.bufferActor_state, ptr %0, i32 0, i32 0
  %1 = load i32, ptr %program_counter, align 8
  switch i32 %1, label %sw.epilog [
    i32 0, label %sw.bb
  ]

sw.bb:                                            ; preds = %entry
  br label %S0

sw.epilog:                                        ; preds = %entry
  br label %S0

S0:                                               ; preds = %S35, %S28, %S26, %S24, %S22, %S21, %S20, %S18, %S16, %S14, %S12, %S10, %S7, %sw.epilog, %sw.bb
  %2 = load ptr, ptr %self.addr, align 8
  %call = call zeroext i1 @bufferActor_condition_14(ptr noundef %2)
  br i1 %call, label %if.then, label %if.else

if.then:                                          ; preds = %S0
  br label %S1

if.else:                                          ; preds = %S0
  br label %S2

S1:                                               ; preds = %if.then
  %3 = load ptr, ptr %self.addr, align 8
  %call1 = call zeroext i1 @bufferActor_condition_20(ptr noundef %3)
  br i1 %call1, label %if.then2, label %if.else3

if.then2:                                         ; preds = %S1
  br label %S3

if.else3:                                         ; preds = %S1
  br label %S4

S2:                                               ; preds = %if.else33, %if.else24, %if.else
  %4 = load ptr, ptr %self.addr, align 8
  %call4 = call zeroext i1 @bufferActor_condition_7(ptr noundef %4)
  br i1 %call4, label %if.then5, label %if.else6

if.then5:                                         ; preds = %S2
  br label %S5

if.else6:                                         ; preds = %S2
  br label %S6

S3:                                               ; preds = %if.then2
  %5 = load ptr, ptr %self.addr, align 8
  %call7 = call zeroext i1 @bufferActor_condition_19(ptr noundef %5)
  br i1 %call7, label %if.then8, label %if.else9

if.then8:                                         ; preds = %S3
  br label %S7

if.else9:                                         ; preds = %S3
  br label %S4

S4:                                               ; preds = %if.else9, %if.else3
  %6 = load ptr, ptr %self.addr, align 8
  %call10 = call zeroext i1 @bufferActor_condition_17(ptr noundef %6)
  br i1 %call10, label %if.then11, label %if.else12

if.then11:                                        ; preds = %S4
  br label %S8

if.else12:                                        ; preds = %S4
  br label %S9

S5:                                               ; preds = %if.then5
  %7 = load ptr, ptr %self.addr, align 8
  %call13 = call zeroext i1 @bufferActor_condition_11(ptr noundef %7)
  br i1 %call13, label %if.then14, label %if.else15

if.then14:                                        ; preds = %S5
  br label %S10

if.else15:                                        ; preds = %S5
  br label %S11

S6:                                               ; preds = %if.else36, %if.else6
  %8 = load ptr, ptr %self.addr, align 8
  %call16 = call zeroext i1 @bufferActor_condition_21(ptr noundef %8)
  br i1 %call16, label %if.then17, label %if.else18

if.then17:                                        ; preds = %S6
  br label %S12

if.else18:                                        ; preds = %S6
  br label %S13

S7:                                               ; preds = %if.then8
  %9 = load ptr, ptr %self.addr, align 8
  call void @bufferActor_transition_11(ptr noundef %9)
  store i8 1, ptr %progress, align 1
  br label %S0

S8:                                               ; preds = %if.then11
  %10 = load ptr, ptr %self.addr, align 8
  %call19 = call zeroext i1 @bufferActor_condition_16(ptr noundef %10)
  br i1 %call19, label %if.then20, label %if.else21

if.then20:                                        ; preds = %S8
  br label %S14

if.else21:                                        ; preds = %S8
  br label %S9

S9:                                               ; preds = %if.else21, %if.else12
  %11 = load ptr, ptr %self.addr, align 8
  %call22 = call zeroext i1 @bufferActor_condition_13(ptr noundef %11)
  br i1 %call22, label %if.then23, label %if.else24

if.then23:                                        ; preds = %S9
  br label %S15

if.else24:                                        ; preds = %S9
  br label %S2

S10:                                              ; preds = %if.then14
  %12 = load ptr, ptr %self.addr, align 8
  call void @bufferActor_transition_6(ptr noundef %12)
  store i8 1, ptr %progress, align 1
  br label %S0

S11:                                              ; preds = %if.else15
  %13 = load ptr, ptr %self.addr, align 8
  %call25 = call zeroext i1 @bufferActor_condition_9(ptr noundef %13)
  br i1 %call25, label %if.then26, label %if.else27

if.then26:                                        ; preds = %S11
  br label %S16

if.else27:                                        ; preds = %S11
  br label %S17

S12:                                              ; preds = %if.then17
  %14 = load ptr, ptr %self.addr, align 8
  call void @bufferActor_transition_12(ptr noundef %14)
  store i8 1, ptr %progress, align 1
  br label %S0

S13:                                              ; preds = %if.else18
  %15 = load ptr, ptr %self.addr, align 8
  %call28 = call zeroext i1 @bufferActor_condition_18(ptr noundef %15)
  br i1 %call28, label %if.then29, label %if.else30

if.then29:                                        ; preds = %S13
  br label %S18

if.else30:                                        ; preds = %S13
  br label %S19

S14:                                              ; preds = %if.then20
  %16 = load ptr, ptr %self.addr, align 8
  call void @bufferActor_transition_9(ptr noundef %16)
  store i8 1, ptr %progress, align 1
  br label %S0

S15:                                              ; preds = %if.then23
  %17 = load ptr, ptr %self.addr, align 8
  %call31 = call zeroext i1 @bufferActor_condition_12(ptr noundef %17)
  br i1 %call31, label %if.then32, label %if.else33

if.then32:                                        ; preds = %S15
  br label %S20

if.else33:                                        ; preds = %S15
  br label %S2

S16:                                              ; preds = %if.then26
  %18 = load ptr, ptr %self.addr, align 8
  call void @bufferActor_transition_4(ptr noundef %18)
  store i8 1, ptr %progress, align 1
  br label %S0

S17:                                              ; preds = %if.else27
  %19 = load ptr, ptr %self.addr, align 8
  %call34 = call zeroext i1 @bufferActor_condition_6(ptr noundef %19)
  br i1 %call34, label %if.then35, label %if.else36

if.then35:                                        ; preds = %S17
  br label %S21

if.else36:                                        ; preds = %S17
  br label %S6

S18:                                              ; preds = %if.then29
  %20 = load ptr, ptr %self.addr, align 8
  call void @bufferActor_transition_10(ptr noundef %20)
  store i8 1, ptr %progress, align 1
  br label %S0

S19:                                              ; preds = %if.else30
  %21 = load ptr, ptr %self.addr, align 8
  %call37 = call zeroext i1 @bufferActor_condition_15(ptr noundef %21)
  br i1 %call37, label %if.then38, label %if.else39

if.then38:                                        ; preds = %S19
  br label %S22

if.else39:                                        ; preds = %S19
  br label %S23

S20:                                              ; preds = %if.then32
  %22 = load ptr, ptr %self.addr, align 8
  call void @bufferActor_transition_7(ptr noundef %22)
  store i8 1, ptr %progress, align 1
  br label %S0

S21:                                              ; preds = %if.then35
  %23 = load ptr, ptr %self.addr, align 8
  call void @bufferActor_transition_2(ptr noundef %23)
  store i8 1, ptr %progress, align 1
  br label %S0

S22:                                              ; preds = %if.then38
  %24 = load ptr, ptr %self.addr, align 8
  call void @bufferActor_transition_8(ptr noundef %24)
  store i8 1, ptr %progress, align 1
  br label %S0

S23:                                              ; preds = %if.else39
  %25 = load ptr, ptr %self.addr, align 8
  %call40 = call zeroext i1 @bufferActor_condition_10(ptr noundef %25)
  br i1 %call40, label %if.then41, label %if.else42

if.then41:                                        ; preds = %S23
  br label %S24

if.else42:                                        ; preds = %S23
  br label %S25

S24:                                              ; preds = %if.then41
  %26 = load ptr, ptr %self.addr, align 8
  call void @bufferActor_transition_5(ptr noundef %26)
  store i8 1, ptr %progress, align 1
  br label %S0

S25:                                              ; preds = %if.else42
  %27 = load ptr, ptr %self.addr, align 8
  %call43 = call zeroext i1 @bufferActor_condition_8(ptr noundef %27)
  br i1 %call43, label %if.then44, label %if.else45

if.then44:                                        ; preds = %S25
  br label %S26

if.else45:                                        ; preds = %S25
  br label %S27

S26:                                              ; preds = %if.then44
  %28 = load ptr, ptr %self.addr, align 8
  call void @bufferActor_transition_3(ptr noundef %28)
  store i8 1, ptr %progress, align 1
  br label %S0

S27:                                              ; preds = %if.else45
  %29 = load ptr, ptr %self.addr, align 8
  %call46 = call zeroext i1 @bufferActor_condition_5(ptr noundef %29)
  br i1 %call46, label %if.then47, label %if.else48

if.then47:                                        ; preds = %S27
  br label %S28

if.else48:                                        ; preds = %S27
  br label %S29

S28:                                              ; preds = %if.then47
  %30 = load ptr, ptr %self.addr, align 8
  call void @bufferActor_transition_1(ptr noundef %30)
  store i8 1, ptr %progress, align 1
  br label %S0

S29:                                              ; preds = %if.else48
  %31 = load ptr, ptr %self.addr, align 8
  %call49 = call zeroext i1 @bufferActor_condition_4(ptr noundef %31)
  br i1 %call49, label %if.then50, label %if.else51

if.then50:                                        ; preds = %S29
  br label %S30

if.else51:                                        ; preds = %S29
  br label %S31

S30:                                              ; preds = %if.then50
  %32 = load ptr, ptr %self.addr, align 8
  %call52 = call zeroext i1 @bufferActor_condition_3(ptr noundef %32)
  br i1 %call52, label %if.then53, label %if.else54

if.then53:                                        ; preds = %S30
  br label %S32

if.else54:                                        ; preds = %S30
  br label %S31

S31:                                              ; preds = %if.else64, %if.else61, %if.else58, %if.else54, %if.else51
  %33 = load ptr, ptr %self.addr, align 8
  %program_counter55 = getelementptr inbounds nuw %struct.bufferActor_state, ptr %33, i32 0, i32 0
  store i32 0, ptr %program_counter55, align 8
  %34 = load i8, ptr %progress, align 1
  %loadedv = trunc i8 %34 to i1
  ret i1 %loadedv

S32:                                              ; preds = %if.then53
  %35 = load ptr, ptr %self.addr, align 8
  %call56 = call zeroext i1 @bufferActor_condition_2(ptr noundef %35)
  br i1 %call56, label %if.then57, label %if.else58

if.then57:                                        ; preds = %S32
  br label %S33

if.else58:                                        ; preds = %S32
  br label %S31

S33:                                              ; preds = %if.then57
  %36 = load ptr, ptr %self.addr, align 8
  %call59 = call zeroext i1 @bufferActor_condition_1(ptr noundef %36)
  br i1 %call59, label %if.then60, label %if.else61

if.then60:                                        ; preds = %S33
  br label %S34

if.else61:                                        ; preds = %S33
  br label %S31

S34:                                              ; preds = %if.then60
  %37 = load ptr, ptr %self.addr, align 8
  %call62 = call zeroext i1 @bufferActor_condition_0(ptr noundef %37)
  br i1 %call62, label %if.then63, label %if.else64

if.then63:                                        ; preds = %S34
  br label %S35

if.else64:                                        ; preds = %S34
  br label %S31

S35:                                              ; preds = %if.then63
  %38 = load ptr, ptr %self.addr, align 8
  call void @bufferActor_transition_0(ptr noundef %38)
  store i8 1, ptr %progress, align 1
  br label %S0
}

; Function Attrs: noinline nounwind optnone uwtable
define internal zeroext i1 @bufferActor_condition_14(ptr noundef %self) #0 {
entry:
  %self.addr = alloca ptr, align 8
  %t_164 = alloca i8, align 1
  store ptr %self, ptr %self.addr, align 8
  %0 = load ptr, ptr %self.addr, align 8
  %a_pendingItems__14 = getelementptr inbounds nuw %struct.bufferActor_state, ptr %0, i32 0, i32 22
  %1 = load i32, ptr %a_pendingItems__14, align 8
  %2 = load ptr, ptr %self.addr, align 8
  %a_itemsOnBuffer__12 = getelementptr inbounds nuw %struct.bufferActor_state, ptr %2, i32 0, i32 20
  %3 = load i32, ptr %a_itemsOnBuffer__12, align 8
  %add = add i32 %1, %3
  %4 = load i32, ptr @"g_bndBuffer_$eval6", align 4
  %cmp = icmp ult i32 %add, %4
  %storedv = zext i1 %cmp to i8
  store i8 %storedv, ptr %t_164, align 1
  %5 = load i8, ptr %t_164, align 1
  %loadedv = trunc i8 %5 to i1
  ret i1 %loadedv
}

; Function Attrs: noinline nounwind optnone uwtable
define internal zeroext i1 @bufferActor_condition_20(ptr noundef %self) #0 {
entry:
  %self.addr = alloca ptr, align 8
  %t_170 = alloca i8, align 1
  store ptr %self, ptr %self.addr, align 8
  %0 = load ptr, ptr %self.addr, align 8
  %a_busyProducers__9 = getelementptr inbounds nuw %struct.bufferActor_state, ptr %0, i32 0, i32 17
  %data = getelementptr inbounds nuw %struct._S3_N4_list_N2_u1_N1_3, ptr %a_busyProducers__9, i32 0, i32 0
  %arrayidx = getelementptr inbounds [3 x i8], ptr %data, i64 0, i64 2
  %1 = load i8, ptr %arrayidx, align 2
  %conv = zext i8 %1 to i32
  %cmp = icmp eq i32 %conv, 0
  %storedv = zext i1 %cmp to i8
  store i8 %storedv, ptr %t_170, align 1
  %2 = load i8, ptr %t_170, align 1
  %loadedv = trunc i8 %2 to i1
  ret i1 %loadedv
}

; Function Attrs: noinline nounwind optnone uwtable
define internal zeroext i1 @bufferActor_condition_7(ptr noundef %self) #0 {
entry:
  %self.addr = alloca ptr, align 8
  %t_157 = alloca i8, align 1
  store ptr %self, ptr %self.addr, align 8
  %0 = load ptr, ptr %self.addr, align 8
  %a_itemsOnBuffer__12 = getelementptr inbounds nuw %struct.bufferActor_state, ptr %0, i32 0, i32 20
  %1 = load i32, ptr %a_itemsOnBuffer__12, align 8
  %cmp = icmp ugt i32 %1, 0
  %storedv = zext i1 %cmp to i8
  store i8 %storedv, ptr %t_157, align 1
  %2 = load i8, ptr %t_157, align 1
  %loadedv = trunc i8 %2 to i1
  ret i1 %loadedv
}

; Function Attrs: noinline nounwind optnone uwtable
define internal zeroext i1 @bufferActor_condition_19(ptr noundef %self) #0 {
entry:
  %self.addr = alloca ptr, align 8
  %t_169 = alloca i8, align 1
  store ptr %self, ptr %self.addr, align 8
  %0 = load ptr, ptr %self.addr, align 8
  %ToProducer_array_2_x_channels = getelementptr inbounds nuw %struct.bufferActor_state, ptr %0, i32 0, i32 9
  %coerce.dive = getelementptr inbounds nuw %struct.channel_list_uint8_t_1, ptr %ToProducer_array_2_x_channels, i32 0, i32 0
  %1 = load ptr, ptr %coerce.dive, align 8
  %call = call zeroext i1 @channel_has_space_uint8_t_1(ptr %1, i64 noundef 1)
  %storedv = zext i1 %call to i8
  store i8 %storedv, ptr %t_169, align 1
  %2 = load i8, ptr %t_169, align 1
  %loadedv = trunc i8 %2 to i1
  ret i1 %loadedv
}

; Function Attrs: noinline nounwind optnone uwtable
define internal zeroext i1 @bufferActor_condition_17(ptr noundef %self) #0 {
entry:
  %self.addr = alloca ptr, align 8
  %t_167 = alloca i8, align 1
  store ptr %self, ptr %self.addr, align 8
  %0 = load ptr, ptr %self.addr, align 8
  %a_busyProducers__9 = getelementptr inbounds nuw %struct.bufferActor_state, ptr %0, i32 0, i32 17
  %data = getelementptr inbounds nuw %struct._S3_N4_list_N2_u1_N1_3, ptr %a_busyProducers__9, i32 0, i32 0
  %arrayidx = getelementptr inbounds [3 x i8], ptr %data, i64 0, i64 1
  %1 = load i8, ptr %arrayidx, align 1
  %conv = zext i8 %1 to i32
  %cmp = icmp eq i32 %conv, 0
  %storedv = zext i1 %cmp to i8
  store i8 %storedv, ptr %t_167, align 1
  %2 = load i8, ptr %t_167, align 1
  %loadedv = trunc i8 %2 to i1
  ret i1 %loadedv
}

; Function Attrs: noinline nounwind optnone uwtable
define internal zeroext i1 @bufferActor_condition_11(ptr noundef %self) #0 {
entry:
  %self.addr = alloca ptr, align 8
  %t_161 = alloca i8, align 1
  store ptr %self, ptr %self.addr, align 8
  %0 = load ptr, ptr %self.addr, align 8
  %ToConsumer_array_2_x_channels = getelementptr inbounds nuw %struct.bufferActor_state, ptr %0, i32 0, i32 12
  %coerce.dive = getelementptr inbounds nuw %struct.channel_list_float_1, ptr %ToConsumer_array_2_x_channels, i32 0, i32 0
  %1 = load ptr, ptr %coerce.dive, align 8
  %call = call zeroext i1 @channel_has_space_float_1(ptr %1, i64 noundef 1)
  %storedv = zext i1 %call to i8
  store i8 %storedv, ptr %t_161, align 1
  %2 = load i8, ptr %t_161, align 1
  %loadedv = trunc i8 %2 to i1
  ret i1 %loadedv
}

; Function Attrs: noinline nounwind optnone uwtable
define internal zeroext i1 @bufferActor_condition_21(ptr noundef %self) #0 {
entry:
  %self.addr = alloca ptr, align 8
  %t_171 = alloca i8, align 1
  store ptr %self, ptr %self.addr, align 8
  %0 = load ptr, ptr %self.addr, align 8
  %FromProducer_array_2_x_channel = getelementptr inbounds nuw %struct.bufferActor_state, ptr %0, i32 0, i32 3
  %1 = load ptr, ptr %FromProducer_array_2_x_channel, align 8
  %call = call zeroext i1 @channel_has_data_float_1(ptr noundef %1, i64 noundef 1)
  %storedv = zext i1 %call to i8
  store i8 %storedv, ptr %t_171, align 1
  %2 = load i8, ptr %t_171, align 1
  %loadedv = trunc i8 %2 to i1
  ret i1 %loadedv
}

; Function Attrs: noinline nounwind optnone uwtable
define internal void @bufferActor_transition_11(ptr noundef %self) #0 {
entry:
  %self.addr = alloca ptr, align 8
  %t_148 = alloca i8, align 1
  store ptr %self, ptr %self.addr, align 8
  %0 = load ptr, ptr %self.addr, align 8
  %a_busyProducers__9 = getelementptr inbounds nuw %struct.bufferActor_state, ptr %0, i32 0, i32 17
  %data = getelementptr inbounds nuw %struct._S3_N4_list_N2_u1_N1_3, ptr %a_busyProducers__9, i32 0, i32 0
  %arrayidx = getelementptr inbounds [3 x i8], ptr %data, i64 0, i64 2
  store i8 1, ptr %arrayidx, align 2
  %1 = load ptr, ptr %self.addr, align 8
  %a_pendingItems__14 = getelementptr inbounds nuw %struct.bufferActor_state, ptr %1, i32 0, i32 22
  %2 = load i32, ptr %a_pendingItems__14, align 8
  %add = add nsw i32 %2, 1
  %3 = load ptr, ptr %self.addr, align 8
  %a_pendingItems__141 = getelementptr inbounds nuw %struct.bufferActor_state, ptr %3, i32 0, i32 22
  store i32 %add, ptr %a_pendingItems__141, align 8
  store i8 1, ptr %t_148, align 1
  %4 = load ptr, ptr %self.addr, align 8
  %ToProducer_array_2_x_channels = getelementptr inbounds nuw %struct.bufferActor_state, ptr %4, i32 0, i32 9
  %5 = load i8, ptr %t_148, align 1
  %coerce.dive = getelementptr inbounds nuw %struct.channel_list_uint8_t_1, ptr %ToProducer_array_2_x_channels, i32 0, i32 0
  %6 = load ptr, ptr %coerce.dive, align 8
  call void @channel_write_one_uint8_t_1(ptr %6, i8 noundef zeroext %5)
  ret void
}

; Function Attrs: noinline nounwind optnone uwtable
define internal zeroext i1 @bufferActor_condition_16(ptr noundef %self) #0 {
entry:
  %self.addr = alloca ptr, align 8
  %t_166 = alloca i8, align 1
  store ptr %self, ptr %self.addr, align 8
  %0 = load ptr, ptr %self.addr, align 8
  %ToProducer_array_1_x_channels = getelementptr inbounds nuw %struct.bufferActor_state, ptr %0, i32 0, i32 8
  %coerce.dive = getelementptr inbounds nuw %struct.channel_list_uint8_t_1, ptr %ToProducer_array_1_x_channels, i32 0, i32 0
  %1 = load ptr, ptr %coerce.dive, align 8
  %call = call zeroext i1 @channel_has_space_uint8_t_1(ptr %1, i64 noundef 1)
  %storedv = zext i1 %call to i8
  store i8 %storedv, ptr %t_166, align 1
  %2 = load i8, ptr %t_166, align 1
  %loadedv = trunc i8 %2 to i1
  ret i1 %loadedv
}

; Function Attrs: noinline nounwind optnone uwtable
define internal zeroext i1 @bufferActor_condition_13(ptr noundef %self) #0 {
entry:
  %self.addr = alloca ptr, align 8
  %t_163 = alloca i8, align 1
  store ptr %self, ptr %self.addr, align 8
  %0 = load ptr, ptr %self.addr, align 8
  %a_busyProducers__9 = getelementptr inbounds nuw %struct.bufferActor_state, ptr %0, i32 0, i32 17
  %data = getelementptr inbounds nuw %struct._S3_N4_list_N2_u1_N1_3, ptr %a_busyProducers__9, i32 0, i32 0
  %arrayidx = getelementptr inbounds [3 x i8], ptr %data, i64 0, i64 0
  %1 = load i8, ptr %arrayidx, align 8
  %conv = zext i8 %1 to i32
  %cmp = icmp eq i32 %conv, 0
  %storedv = zext i1 %cmp to i8
  store i8 %storedv, ptr %t_163, align 1
  %2 = load i8, ptr %t_163, align 1
  %loadedv = trunc i8 %2 to i1
  ret i1 %loadedv
}

; Function Attrs: noinline nounwind optnone uwtable
define internal void @bufferActor_transition_6(ptr noundef %self) #0 {
entry:
  %self.addr = alloca ptr, align 8
  %l_poppedItem__30 = alloca float, align 4
  %t_143 = alloca float, align 4
  store ptr %self, ptr %self.addr, align 8
  store float 0.000000e+00, ptr %l_poppedItem__30, align 4
  %0 = load ptr, ptr %self.addr, align 8
  %a_buffer__11 = getelementptr inbounds nuw %struct.bufferActor_state, ptr %0, i32 0, i32 19
  %data = getelementptr inbounds nuw %struct._S3_N4_list_S2_N4_real_N2_32_N2_50, ptr %a_buffer__11, i32 0, i32 0
  %1 = load ptr, ptr %self.addr, align 8
  %a_bufferFrontLocation__13 = getelementptr inbounds nuw %struct.bufferActor_state, ptr %1, i32 0, i32 21
  %2 = load i32, ptr %a_bufferFrontLocation__13, align 4
  %idxprom = zext i32 %2 to i64
  %arrayidx = getelementptr inbounds nuw [50 x float], ptr %data, i64 0, i64 %idxprom
  %3 = load float, ptr %arrayidx, align 4
  store float %3, ptr %l_poppedItem__30, align 4
  %4 = load ptr, ptr %self.addr, align 8
  %a_bufferFrontLocation__131 = getelementptr inbounds nuw %struct.bufferActor_state, ptr %4, i32 0, i32 21
  %5 = load i32, ptr %a_bufferFrontLocation__131, align 4
  %add = add i32 %5, 1
  %6 = load i32, ptr @"g_bndBuffer_$eval6", align 4
  %rem = urem i32 %add, %6
  %7 = load ptr, ptr %self.addr, align 8
  %a_bufferFrontLocation__132 = getelementptr inbounds nuw %struct.bufferActor_state, ptr %7, i32 0, i32 21
  store i32 %rem, ptr %a_bufferFrontLocation__132, align 4
  %8 = load ptr, ptr %self.addr, align 8
  %a_itemsOnBuffer__12 = getelementptr inbounds nuw %struct.bufferActor_state, ptr %8, i32 0, i32 20
  %9 = load i32, ptr %a_itemsOnBuffer__12, align 8
  %sub = sub i32 %9, 1
  %10 = load ptr, ptr %self.addr, align 8
  %a_itemsOnBuffer__123 = getelementptr inbounds nuw %struct.bufferActor_state, ptr %10, i32 0, i32 20
  store i32 %sub, ptr %a_itemsOnBuffer__123, align 8
  %11 = load ptr, ptr %self.addr, align 8
  %a_freeConsumers__10 = getelementptr inbounds nuw %struct.bufferActor_state, ptr %11, i32 0, i32 18
  %data4 = getelementptr inbounds nuw %struct._S3_N4_list_N2_u1_N1_3, ptr %a_freeConsumers__10, i32 0, i32 0
  %arrayidx5 = getelementptr inbounds [3 x i8], ptr %data4, i64 0, i64 2
  store i8 0, ptr %arrayidx5, align 1
  %12 = load float, ptr %l_poppedItem__30, align 4
  store float %12, ptr %t_143, align 4
  %13 = load ptr, ptr %self.addr, align 8
  %ToConsumer_array_2_x_channels = getelementptr inbounds nuw %struct.bufferActor_state, ptr %13, i32 0, i32 12
  %14 = load float, ptr %t_143, align 4
  %coerce.dive = getelementptr inbounds nuw %struct.channel_list_float_1, ptr %ToConsumer_array_2_x_channels, i32 0, i32 0
  %15 = load ptr, ptr %coerce.dive, align 8
  call void @channel_write_one_float_1(ptr %15, float noundef %14)
  ret void
}

; Function Attrs: noinline nounwind optnone uwtable
define internal zeroext i1 @bufferActor_condition_9(ptr noundef %self) #0 {
entry:
  %self.addr = alloca ptr, align 8
  %t_159 = alloca i8, align 1
  store ptr %self, ptr %self.addr, align 8
  %0 = load ptr, ptr %self.addr, align 8
  %ToConsumer_array_1_x_channels = getelementptr inbounds nuw %struct.bufferActor_state, ptr %0, i32 0, i32 11
  %coerce.dive = getelementptr inbounds nuw %struct.channel_list_float_1, ptr %ToConsumer_array_1_x_channels, i32 0, i32 0
  %1 = load ptr, ptr %coerce.dive, align 8
  %call = call zeroext i1 @channel_has_space_float_1(ptr %1, i64 noundef 1)
  %storedv = zext i1 %call to i8
  store i8 %storedv, ptr %t_159, align 1
  %2 = load i8, ptr %t_159, align 1
  %loadedv = trunc i8 %2 to i1
  ret i1 %loadedv
}

; Function Attrs: noinline nounwind optnone uwtable
define internal void @bufferActor_transition_12(ptr noundef %self) #0 {
entry:
  %self.addr = alloca ptr, align 8
  %l_item__40 = alloca float, align 4
  %t_149 = alloca float, align 4
  %l_bufferIndexBack__42 = alloca i32, align 4
  store ptr %self, ptr %self.addr, align 8
  store float 0.000000e+00, ptr %l_item__40, align 4
  store float 0.000000e+00, ptr %t_149, align 4
  %0 = load ptr, ptr %self.addr, align 8
  %FromProducer_array_2_x_channel = getelementptr inbounds nuw %struct.bufferActor_state, ptr %0, i32 0, i32 3
  %1 = load ptr, ptr %FromProducer_array_2_x_channel, align 8
  %call = call float @channel_peek_first_float_1(ptr noundef %1)
  store float %call, ptr %t_149, align 4
  %2 = load float, ptr %t_149, align 4
  store float %2, ptr %l_item__40, align 4
  store i32 0, ptr %l_bufferIndexBack__42, align 4
  %3 = load ptr, ptr %self.addr, align 8
  %a_busyProducers__9 = getelementptr inbounds nuw %struct.bufferActor_state, ptr %3, i32 0, i32 17
  %data = getelementptr inbounds nuw %struct._S3_N4_list_N2_u1_N1_3, ptr %a_busyProducers__9, i32 0, i32 0
  %arrayidx = getelementptr inbounds [3 x i8], ptr %data, i64 0, i64 2
  store i8 0, ptr %arrayidx, align 2
  %4 = load ptr, ptr %self.addr, align 8
  %a_pendingItems__14 = getelementptr inbounds nuw %struct.bufferActor_state, ptr %4, i32 0, i32 22
  %5 = load i32, ptr %a_pendingItems__14, align 8
  %sub = sub nsw i32 %5, 1
  %6 = load ptr, ptr %self.addr, align 8
  %a_pendingItems__141 = getelementptr inbounds nuw %struct.bufferActor_state, ptr %6, i32 0, i32 22
  store i32 %sub, ptr %a_pendingItems__141, align 8
  %7 = load ptr, ptr %self.addr, align 8
  %a_bufferFrontLocation__13 = getelementptr inbounds nuw %struct.bufferActor_state, ptr %7, i32 0, i32 21
  %8 = load i32, ptr %a_bufferFrontLocation__13, align 4
  %9 = load ptr, ptr %self.addr, align 8
  %a_itemsOnBuffer__12 = getelementptr inbounds nuw %struct.bufferActor_state, ptr %9, i32 0, i32 20
  %10 = load i32, ptr %a_itemsOnBuffer__12, align 8
  %add = add i32 %8, %10
  %11 = load i32, ptr @"g_bndBuffer_$eval6", align 4
  %rem = urem i32 %add, %11
  store i32 %rem, ptr %l_bufferIndexBack__42, align 4
  %12 = load float, ptr %l_item__40, align 4
  %13 = load ptr, ptr %self.addr, align 8
  %a_buffer__11 = getelementptr inbounds nuw %struct.bufferActor_state, ptr %13, i32 0, i32 19
  %data2 = getelementptr inbounds nuw %struct._S3_N4_list_S2_N4_real_N2_32_N2_50, ptr %a_buffer__11, i32 0, i32 0
  %14 = load i32, ptr %l_bufferIndexBack__42, align 4
  %idxprom = zext i32 %14 to i64
  %arrayidx3 = getelementptr inbounds nuw [50 x float], ptr %data2, i64 0, i64 %idxprom
  store float %12, ptr %arrayidx3, align 4
  %15 = load ptr, ptr %self.addr, align 8
  %a_itemsOnBuffer__124 = getelementptr inbounds nuw %struct.bufferActor_state, ptr %15, i32 0, i32 20
  %16 = load i32, ptr %a_itemsOnBuffer__124, align 8
  %add5 = add i32 %16, 1
  %17 = load ptr, ptr %self.addr, align 8
  %a_itemsOnBuffer__126 = getelementptr inbounds nuw %struct.bufferActor_state, ptr %17, i32 0, i32 20
  store i32 %add5, ptr %a_itemsOnBuffer__126, align 8
  %18 = load ptr, ptr %self.addr, align 8
  %a_sumProducers__17 = getelementptr inbounds nuw %struct.bufferActor_state, ptr %18, i32 0, i32 25
  %19 = load float, ptr %a_sumProducers__17, align 4
  %20 = load float, ptr %l_item__40, align 4
  %add7 = fadd float %19, %20
  %21 = load ptr, ptr %self.addr, align 8
  %a_sumProducers__178 = getelementptr inbounds nuw %struct.bufferActor_state, ptr %21, i32 0, i32 25
  store float %add7, ptr %a_sumProducers__178, align 4
  %22 = load ptr, ptr %self.addr, align 8
  %a_totalItemsFromProducers__16 = getelementptr inbounds nuw %struct.bufferActor_state, ptr %22, i32 0, i32 24
  %23 = load i32, ptr %a_totalItemsFromProducers__16, align 8
  %add9 = add i32 %23, 1
  %24 = load ptr, ptr %self.addr, align 8
  %a_totalItemsFromProducers__1610 = getelementptr inbounds nuw %struct.bufferActor_state, ptr %24, i32 0, i32 24
  store i32 %add9, ptr %a_totalItemsFromProducers__1610, align 8
  %25 = load ptr, ptr %self.addr, align 8
  %FromProducer_array_2_x_channel11 = getelementptr inbounds nuw %struct.bufferActor_state, ptr %25, i32 0, i32 3
  %26 = load ptr, ptr %FromProducer_array_2_x_channel11, align 8
  call void @channel_consume_float_1(ptr noundef %26, i64 noundef 1)
  ret void
}

; Function Attrs: noinline nounwind optnone uwtable
define internal zeroext i1 @bufferActor_condition_18(ptr noundef %self) #0 {
entry:
  %self.addr = alloca ptr, align 8
  %t_168 = alloca i8, align 1
  store ptr %self, ptr %self.addr, align 8
  %0 = load ptr, ptr %self.addr, align 8
  %FromProducer_array_1_x_channel = getelementptr inbounds nuw %struct.bufferActor_state, ptr %0, i32 0, i32 2
  %1 = load ptr, ptr %FromProducer_array_1_x_channel, align 8
  %call = call zeroext i1 @channel_has_data_float_1(ptr noundef %1, i64 noundef 1)
  %storedv = zext i1 %call to i8
  store i8 %storedv, ptr %t_168, align 1
  %2 = load i8, ptr %t_168, align 1
  %loadedv = trunc i8 %2 to i1
  ret i1 %loadedv
}

; Function Attrs: noinline nounwind optnone uwtable
define internal void @bufferActor_transition_9(ptr noundef %self) #0 {
entry:
  %self.addr = alloca ptr, align 8
  %t_146 = alloca i8, align 1
  store ptr %self, ptr %self.addr, align 8
  %0 = load ptr, ptr %self.addr, align 8
  %a_busyProducers__9 = getelementptr inbounds nuw %struct.bufferActor_state, ptr %0, i32 0, i32 17
  %data = getelementptr inbounds nuw %struct._S3_N4_list_N2_u1_N1_3, ptr %a_busyProducers__9, i32 0, i32 0
  %arrayidx = getelementptr inbounds [3 x i8], ptr %data, i64 0, i64 1
  store i8 1, ptr %arrayidx, align 1
  %1 = load ptr, ptr %self.addr, align 8
  %a_pendingItems__14 = getelementptr inbounds nuw %struct.bufferActor_state, ptr %1, i32 0, i32 22
  %2 = load i32, ptr %a_pendingItems__14, align 8
  %add = add nsw i32 %2, 1
  %3 = load ptr, ptr %self.addr, align 8
  %a_pendingItems__141 = getelementptr inbounds nuw %struct.bufferActor_state, ptr %3, i32 0, i32 22
  store i32 %add, ptr %a_pendingItems__141, align 8
  store i8 1, ptr %t_146, align 1
  %4 = load ptr, ptr %self.addr, align 8
  %ToProducer_array_1_x_channels = getelementptr inbounds nuw %struct.bufferActor_state, ptr %4, i32 0, i32 8
  %5 = load i8, ptr %t_146, align 1
  %coerce.dive = getelementptr inbounds nuw %struct.channel_list_uint8_t_1, ptr %ToProducer_array_1_x_channels, i32 0, i32 0
  %6 = load ptr, ptr %coerce.dive, align 8
  call void @channel_write_one_uint8_t_1(ptr %6, i8 noundef zeroext %5)
  ret void
}

; Function Attrs: noinline nounwind optnone uwtable
define internal zeroext i1 @bufferActor_condition_12(ptr noundef %self) #0 {
entry:
  %self.addr = alloca ptr, align 8
  %t_162 = alloca i8, align 1
  store ptr %self, ptr %self.addr, align 8
  %0 = load ptr, ptr %self.addr, align 8
  %ToProducer_array_0_x_channels = getelementptr inbounds nuw %struct.bufferActor_state, ptr %0, i32 0, i32 7
  %coerce.dive = getelementptr inbounds nuw %struct.channel_list_uint8_t_1, ptr %ToProducer_array_0_x_channels, i32 0, i32 0
  %1 = load ptr, ptr %coerce.dive, align 8
  %call = call zeroext i1 @channel_has_space_uint8_t_1(ptr %1, i64 noundef 1)
  %storedv = zext i1 %call to i8
  store i8 %storedv, ptr %t_162, align 1
  %2 = load i8, ptr %t_162, align 1
  %loadedv = trunc i8 %2 to i1
  ret i1 %loadedv
}

; Function Attrs: noinline nounwind optnone uwtable
define internal void @bufferActor_transition_4(ptr noundef %self) #0 {
entry:
  %self.addr = alloca ptr, align 8
  %l_poppedItem__26 = alloca float, align 4
  %t_141 = alloca float, align 4
  store ptr %self, ptr %self.addr, align 8
  store float 0.000000e+00, ptr %l_poppedItem__26, align 4
  %0 = load ptr, ptr %self.addr, align 8
  %a_buffer__11 = getelementptr inbounds nuw %struct.bufferActor_state, ptr %0, i32 0, i32 19
  %data = getelementptr inbounds nuw %struct._S3_N4_list_S2_N4_real_N2_32_N2_50, ptr %a_buffer__11, i32 0, i32 0
  %1 = load ptr, ptr %self.addr, align 8
  %a_bufferFrontLocation__13 = getelementptr inbounds nuw %struct.bufferActor_state, ptr %1, i32 0, i32 21
  %2 = load i32, ptr %a_bufferFrontLocation__13, align 4
  %idxprom = zext i32 %2 to i64
  %arrayidx = getelementptr inbounds nuw [50 x float], ptr %data, i64 0, i64 %idxprom
  %3 = load float, ptr %arrayidx, align 4
  store float %3, ptr %l_poppedItem__26, align 4
  %4 = load ptr, ptr %self.addr, align 8
  %a_bufferFrontLocation__131 = getelementptr inbounds nuw %struct.bufferActor_state, ptr %4, i32 0, i32 21
  %5 = load i32, ptr %a_bufferFrontLocation__131, align 4
  %add = add i32 %5, 1
  %6 = load i32, ptr @"g_bndBuffer_$eval6", align 4
  %rem = urem i32 %add, %6
  %7 = load ptr, ptr %self.addr, align 8
  %a_bufferFrontLocation__132 = getelementptr inbounds nuw %struct.bufferActor_state, ptr %7, i32 0, i32 21
  store i32 %rem, ptr %a_bufferFrontLocation__132, align 4
  %8 = load ptr, ptr %self.addr, align 8
  %a_itemsOnBuffer__12 = getelementptr inbounds nuw %struct.bufferActor_state, ptr %8, i32 0, i32 20
  %9 = load i32, ptr %a_itemsOnBuffer__12, align 8
  %sub = sub i32 %9, 1
  %10 = load ptr, ptr %self.addr, align 8
  %a_itemsOnBuffer__123 = getelementptr inbounds nuw %struct.bufferActor_state, ptr %10, i32 0, i32 20
  store i32 %sub, ptr %a_itemsOnBuffer__123, align 8
  %11 = load ptr, ptr %self.addr, align 8
  %a_freeConsumers__10 = getelementptr inbounds nuw %struct.bufferActor_state, ptr %11, i32 0, i32 18
  %data4 = getelementptr inbounds nuw %struct._S3_N4_list_N2_u1_N1_3, ptr %a_freeConsumers__10, i32 0, i32 0
  %arrayidx5 = getelementptr inbounds [3 x i8], ptr %data4, i64 0, i64 1
  store i8 0, ptr %arrayidx5, align 1
  %12 = load float, ptr %l_poppedItem__26, align 4
  store float %12, ptr %t_141, align 4
  %13 = load ptr, ptr %self.addr, align 8
  %ToConsumer_array_1_x_channels = getelementptr inbounds nuw %struct.bufferActor_state, ptr %13, i32 0, i32 11
  %14 = load float, ptr %t_141, align 4
  %coerce.dive = getelementptr inbounds nuw %struct.channel_list_float_1, ptr %ToConsumer_array_1_x_channels, i32 0, i32 0
  %15 = load ptr, ptr %coerce.dive, align 8
  call void @channel_write_one_float_1(ptr %15, float noundef %14)
  ret void
}

; Function Attrs: noinline nounwind optnone uwtable
define internal zeroext i1 @bufferActor_condition_6(ptr noundef %self) #0 {
entry:
  %self.addr = alloca ptr, align 8
  %t_156 = alloca i8, align 1
  store ptr %self, ptr %self.addr, align 8
  %0 = load ptr, ptr %self.addr, align 8
  %ToConsumer_array_0_x_channels = getelementptr inbounds nuw %struct.bufferActor_state, ptr %0, i32 0, i32 10
  %coerce.dive = getelementptr inbounds nuw %struct.channel_list_float_1, ptr %ToConsumer_array_0_x_channels, i32 0, i32 0
  %1 = load ptr, ptr %coerce.dive, align 8
  %call = call zeroext i1 @channel_has_space_float_1(ptr %1, i64 noundef 1)
  %storedv = zext i1 %call to i8
  store i8 %storedv, ptr %t_156, align 1
  %2 = load i8, ptr %t_156, align 1
  %loadedv = trunc i8 %2 to i1
  ret i1 %loadedv
}

; Function Attrs: noinline nounwind optnone uwtable
define internal void @bufferActor_transition_10(ptr noundef %self) #0 {
entry:
  %self.addr = alloca ptr, align 8
  %l_item__36 = alloca float, align 4
  %t_147 = alloca float, align 4
  %l_bufferIndexBack__38 = alloca i32, align 4
  store ptr %self, ptr %self.addr, align 8
  store float 0.000000e+00, ptr %l_item__36, align 4
  store float 0.000000e+00, ptr %t_147, align 4
  %0 = load ptr, ptr %self.addr, align 8
  %FromProducer_array_1_x_channel = getelementptr inbounds nuw %struct.bufferActor_state, ptr %0, i32 0, i32 2
  %1 = load ptr, ptr %FromProducer_array_1_x_channel, align 8
  %call = call float @channel_peek_first_float_1(ptr noundef %1)
  store float %call, ptr %t_147, align 4
  %2 = load float, ptr %t_147, align 4
  store float %2, ptr %l_item__36, align 4
  store i32 0, ptr %l_bufferIndexBack__38, align 4
  %3 = load ptr, ptr %self.addr, align 8
  %a_busyProducers__9 = getelementptr inbounds nuw %struct.bufferActor_state, ptr %3, i32 0, i32 17
  %data = getelementptr inbounds nuw %struct._S3_N4_list_N2_u1_N1_3, ptr %a_busyProducers__9, i32 0, i32 0
  %arrayidx = getelementptr inbounds [3 x i8], ptr %data, i64 0, i64 1
  store i8 0, ptr %arrayidx, align 1
  %4 = load ptr, ptr %self.addr, align 8
  %a_pendingItems__14 = getelementptr inbounds nuw %struct.bufferActor_state, ptr %4, i32 0, i32 22
  %5 = load i32, ptr %a_pendingItems__14, align 8
  %sub = sub nsw i32 %5, 1
  %6 = load ptr, ptr %self.addr, align 8
  %a_pendingItems__141 = getelementptr inbounds nuw %struct.bufferActor_state, ptr %6, i32 0, i32 22
  store i32 %sub, ptr %a_pendingItems__141, align 8
  %7 = load ptr, ptr %self.addr, align 8
  %a_bufferFrontLocation__13 = getelementptr inbounds nuw %struct.bufferActor_state, ptr %7, i32 0, i32 21
  %8 = load i32, ptr %a_bufferFrontLocation__13, align 4
  %9 = load ptr, ptr %self.addr, align 8
  %a_itemsOnBuffer__12 = getelementptr inbounds nuw %struct.bufferActor_state, ptr %9, i32 0, i32 20
  %10 = load i32, ptr %a_itemsOnBuffer__12, align 8
  %add = add i32 %8, %10
  %11 = load i32, ptr @"g_bndBuffer_$eval6", align 4
  %rem = urem i32 %add, %11
  store i32 %rem, ptr %l_bufferIndexBack__38, align 4
  %12 = load float, ptr %l_item__36, align 4
  %13 = load ptr, ptr %self.addr, align 8
  %a_buffer__11 = getelementptr inbounds nuw %struct.bufferActor_state, ptr %13, i32 0, i32 19
  %data2 = getelementptr inbounds nuw %struct._S3_N4_list_S2_N4_real_N2_32_N2_50, ptr %a_buffer__11, i32 0, i32 0
  %14 = load i32, ptr %l_bufferIndexBack__38, align 4
  %idxprom = zext i32 %14 to i64
  %arrayidx3 = getelementptr inbounds nuw [50 x float], ptr %data2, i64 0, i64 %idxprom
  store float %12, ptr %arrayidx3, align 4
  %15 = load ptr, ptr %self.addr, align 8
  %a_itemsOnBuffer__124 = getelementptr inbounds nuw %struct.bufferActor_state, ptr %15, i32 0, i32 20
  %16 = load i32, ptr %a_itemsOnBuffer__124, align 8
  %add5 = add i32 %16, 1
  %17 = load ptr, ptr %self.addr, align 8
  %a_itemsOnBuffer__126 = getelementptr inbounds nuw %struct.bufferActor_state, ptr %17, i32 0, i32 20
  store i32 %add5, ptr %a_itemsOnBuffer__126, align 8
  %18 = load ptr, ptr %self.addr, align 8
  %a_sumProducers__17 = getelementptr inbounds nuw %struct.bufferActor_state, ptr %18, i32 0, i32 25
  %19 = load float, ptr %a_sumProducers__17, align 4
  %20 = load float, ptr %l_item__36, align 4
  %add7 = fadd float %19, %20
  %21 = load ptr, ptr %self.addr, align 8
  %a_sumProducers__178 = getelementptr inbounds nuw %struct.bufferActor_state, ptr %21, i32 0, i32 25
  store float %add7, ptr %a_sumProducers__178, align 4
  %22 = load ptr, ptr %self.addr, align 8
  %a_totalItemsFromProducers__16 = getelementptr inbounds nuw %struct.bufferActor_state, ptr %22, i32 0, i32 24
  %23 = load i32, ptr %a_totalItemsFromProducers__16, align 8
  %add9 = add i32 %23, 1
  %24 = load ptr, ptr %self.addr, align 8
  %a_totalItemsFromProducers__1610 = getelementptr inbounds nuw %struct.bufferActor_state, ptr %24, i32 0, i32 24
  store i32 %add9, ptr %a_totalItemsFromProducers__1610, align 8
  %25 = load ptr, ptr %self.addr, align 8
  %FromProducer_array_1_x_channel11 = getelementptr inbounds nuw %struct.bufferActor_state, ptr %25, i32 0, i32 2
  %26 = load ptr, ptr %FromProducer_array_1_x_channel11, align 8
  call void @channel_consume_float_1(ptr noundef %26, i64 noundef 1)
  ret void
}

; Function Attrs: noinline nounwind optnone uwtable
define internal zeroext i1 @bufferActor_condition_15(ptr noundef %self) #0 {
entry:
  %self.addr = alloca ptr, align 8
  %t_165 = alloca i8, align 1
  store ptr %self, ptr %self.addr, align 8
  %0 = load ptr, ptr %self.addr, align 8
  %FromProducer_array_0_x_channel = getelementptr inbounds nuw %struct.bufferActor_state, ptr %0, i32 0, i32 1
  %1 = load ptr, ptr %FromProducer_array_0_x_channel, align 8
  %call = call zeroext i1 @channel_has_data_float_1(ptr noundef %1, i64 noundef 1)
  %storedv = zext i1 %call to i8
  store i8 %storedv, ptr %t_165, align 1
  %2 = load i8, ptr %t_165, align 1
  %loadedv = trunc i8 %2 to i1
  ret i1 %loadedv
}

; Function Attrs: noinline nounwind optnone uwtable
define internal void @bufferActor_transition_7(ptr noundef %self) #0 {
entry:
  %self.addr = alloca ptr, align 8
  %t_144 = alloca i8, align 1
  store ptr %self, ptr %self.addr, align 8
  %0 = load ptr, ptr %self.addr, align 8
  %a_busyProducers__9 = getelementptr inbounds nuw %struct.bufferActor_state, ptr %0, i32 0, i32 17
  %data = getelementptr inbounds nuw %struct._S3_N4_list_N2_u1_N1_3, ptr %a_busyProducers__9, i32 0, i32 0
  %arrayidx = getelementptr inbounds [3 x i8], ptr %data, i64 0, i64 0
  store i8 1, ptr %arrayidx, align 8
  %1 = load ptr, ptr %self.addr, align 8
  %a_pendingItems__14 = getelementptr inbounds nuw %struct.bufferActor_state, ptr %1, i32 0, i32 22
  %2 = load i32, ptr %a_pendingItems__14, align 8
  %add = add nsw i32 %2, 1
  %3 = load ptr, ptr %self.addr, align 8
  %a_pendingItems__141 = getelementptr inbounds nuw %struct.bufferActor_state, ptr %3, i32 0, i32 22
  store i32 %add, ptr %a_pendingItems__141, align 8
  store i8 1, ptr %t_144, align 1
  %4 = load ptr, ptr %self.addr, align 8
  %ToProducer_array_0_x_channels = getelementptr inbounds nuw %struct.bufferActor_state, ptr %4, i32 0, i32 7
  %5 = load i8, ptr %t_144, align 1
  %coerce.dive = getelementptr inbounds nuw %struct.channel_list_uint8_t_1, ptr %ToProducer_array_0_x_channels, i32 0, i32 0
  %6 = load ptr, ptr %coerce.dive, align 8
  call void @channel_write_one_uint8_t_1(ptr %6, i8 noundef zeroext %5)
  ret void
}

; Function Attrs: noinline nounwind optnone uwtable
define internal void @bufferActor_transition_2(ptr noundef %self) #0 {
entry:
  %self.addr = alloca ptr, align 8
  %l_poppedItem__22 = alloca float, align 4
  %t_139 = alloca float, align 4
  store ptr %self, ptr %self.addr, align 8
  store float 0.000000e+00, ptr %l_poppedItem__22, align 4
  %0 = load ptr, ptr %self.addr, align 8
  %a_buffer__11 = getelementptr inbounds nuw %struct.bufferActor_state, ptr %0, i32 0, i32 19
  %data = getelementptr inbounds nuw %struct._S3_N4_list_S2_N4_real_N2_32_N2_50, ptr %a_buffer__11, i32 0, i32 0
  %1 = load ptr, ptr %self.addr, align 8
  %a_bufferFrontLocation__13 = getelementptr inbounds nuw %struct.bufferActor_state, ptr %1, i32 0, i32 21
  %2 = load i32, ptr %a_bufferFrontLocation__13, align 4
  %idxprom = zext i32 %2 to i64
  %arrayidx = getelementptr inbounds nuw [50 x float], ptr %data, i64 0, i64 %idxprom
  %3 = load float, ptr %arrayidx, align 4
  store float %3, ptr %l_poppedItem__22, align 4
  %4 = load ptr, ptr %self.addr, align 8
  %a_bufferFrontLocation__131 = getelementptr inbounds nuw %struct.bufferActor_state, ptr %4, i32 0, i32 21
  %5 = load i32, ptr %a_bufferFrontLocation__131, align 4
  %add = add i32 %5, 1
  %6 = load i32, ptr @"g_bndBuffer_$eval6", align 4
  %rem = urem i32 %add, %6
  %7 = load ptr, ptr %self.addr, align 8
  %a_bufferFrontLocation__132 = getelementptr inbounds nuw %struct.bufferActor_state, ptr %7, i32 0, i32 21
  store i32 %rem, ptr %a_bufferFrontLocation__132, align 4
  %8 = load ptr, ptr %self.addr, align 8
  %a_itemsOnBuffer__12 = getelementptr inbounds nuw %struct.bufferActor_state, ptr %8, i32 0, i32 20
  %9 = load i32, ptr %a_itemsOnBuffer__12, align 8
  %sub = sub i32 %9, 1
  %10 = load ptr, ptr %self.addr, align 8
  %a_itemsOnBuffer__123 = getelementptr inbounds nuw %struct.bufferActor_state, ptr %10, i32 0, i32 20
  store i32 %sub, ptr %a_itemsOnBuffer__123, align 8
  %11 = load ptr, ptr %self.addr, align 8
  %a_freeConsumers__10 = getelementptr inbounds nuw %struct.bufferActor_state, ptr %11, i32 0, i32 18
  %data4 = getelementptr inbounds nuw %struct._S3_N4_list_N2_u1_N1_3, ptr %a_freeConsumers__10, i32 0, i32 0
  %arrayidx5 = getelementptr inbounds [3 x i8], ptr %data4, i64 0, i64 0
  store i8 0, ptr %arrayidx5, align 1
  %12 = load float, ptr %l_poppedItem__22, align 4
  store float %12, ptr %t_139, align 4
  %13 = load ptr, ptr %self.addr, align 8
  %ToConsumer_array_0_x_channels = getelementptr inbounds nuw %struct.bufferActor_state, ptr %13, i32 0, i32 10
  %14 = load float, ptr %t_139, align 4
  %coerce.dive = getelementptr inbounds nuw %struct.channel_list_float_1, ptr %ToConsumer_array_0_x_channels, i32 0, i32 0
  %15 = load ptr, ptr %coerce.dive, align 8
  call void @channel_write_one_float_1(ptr %15, float noundef %14)
  ret void
}

; Function Attrs: noinline nounwind optnone uwtable
define internal void @bufferActor_transition_8(ptr noundef %self) #0 {
entry:
  %self.addr = alloca ptr, align 8
  %l_item__32 = alloca float, align 4
  %t_145 = alloca float, align 4
  %l_bufferIndexBack__34 = alloca i32, align 4
  store ptr %self, ptr %self.addr, align 8
  store float 0.000000e+00, ptr %l_item__32, align 4
  store float 0.000000e+00, ptr %t_145, align 4
  %0 = load ptr, ptr %self.addr, align 8
  %FromProducer_array_0_x_channel = getelementptr inbounds nuw %struct.bufferActor_state, ptr %0, i32 0, i32 1
  %1 = load ptr, ptr %FromProducer_array_0_x_channel, align 8
  %call = call float @channel_peek_first_float_1(ptr noundef %1)
  store float %call, ptr %t_145, align 4
  %2 = load float, ptr %t_145, align 4
  store float %2, ptr %l_item__32, align 4
  store i32 0, ptr %l_bufferIndexBack__34, align 4
  %3 = load ptr, ptr %self.addr, align 8
  %a_busyProducers__9 = getelementptr inbounds nuw %struct.bufferActor_state, ptr %3, i32 0, i32 17
  %data = getelementptr inbounds nuw %struct._S3_N4_list_N2_u1_N1_3, ptr %a_busyProducers__9, i32 0, i32 0
  %arrayidx = getelementptr inbounds [3 x i8], ptr %data, i64 0, i64 0
  store i8 0, ptr %arrayidx, align 8
  %4 = load ptr, ptr %self.addr, align 8
  %a_pendingItems__14 = getelementptr inbounds nuw %struct.bufferActor_state, ptr %4, i32 0, i32 22
  %5 = load i32, ptr %a_pendingItems__14, align 8
  %sub = sub nsw i32 %5, 1
  %6 = load ptr, ptr %self.addr, align 8
  %a_pendingItems__141 = getelementptr inbounds nuw %struct.bufferActor_state, ptr %6, i32 0, i32 22
  store i32 %sub, ptr %a_pendingItems__141, align 8
  %7 = load ptr, ptr %self.addr, align 8
  %a_bufferFrontLocation__13 = getelementptr inbounds nuw %struct.bufferActor_state, ptr %7, i32 0, i32 21
  %8 = load i32, ptr %a_bufferFrontLocation__13, align 4
  %9 = load ptr, ptr %self.addr, align 8
  %a_itemsOnBuffer__12 = getelementptr inbounds nuw %struct.bufferActor_state, ptr %9, i32 0, i32 20
  %10 = load i32, ptr %a_itemsOnBuffer__12, align 8
  %add = add i32 %8, %10
  %11 = load i32, ptr @"g_bndBuffer_$eval6", align 4
  %rem = urem i32 %add, %11
  store i32 %rem, ptr %l_bufferIndexBack__34, align 4
  %12 = load float, ptr %l_item__32, align 4
  %13 = load ptr, ptr %self.addr, align 8
  %a_buffer__11 = getelementptr inbounds nuw %struct.bufferActor_state, ptr %13, i32 0, i32 19
  %data2 = getelementptr inbounds nuw %struct._S3_N4_list_S2_N4_real_N2_32_N2_50, ptr %a_buffer__11, i32 0, i32 0
  %14 = load i32, ptr %l_bufferIndexBack__34, align 4
  %idxprom = zext i32 %14 to i64
  %arrayidx3 = getelementptr inbounds nuw [50 x float], ptr %data2, i64 0, i64 %idxprom
  store float %12, ptr %arrayidx3, align 4
  %15 = load ptr, ptr %self.addr, align 8
  %a_itemsOnBuffer__124 = getelementptr inbounds nuw %struct.bufferActor_state, ptr %15, i32 0, i32 20
  %16 = load i32, ptr %a_itemsOnBuffer__124, align 8
  %add5 = add i32 %16, 1
  %17 = load ptr, ptr %self.addr, align 8
  %a_itemsOnBuffer__126 = getelementptr inbounds nuw %struct.bufferActor_state, ptr %17, i32 0, i32 20
  store i32 %add5, ptr %a_itemsOnBuffer__126, align 8
  %18 = load ptr, ptr %self.addr, align 8
  %a_sumProducers__17 = getelementptr inbounds nuw %struct.bufferActor_state, ptr %18, i32 0, i32 25
  %19 = load float, ptr %a_sumProducers__17, align 4
  %20 = load float, ptr %l_item__32, align 4
  %add7 = fadd float %19, %20
  %21 = load ptr, ptr %self.addr, align 8
  %a_sumProducers__178 = getelementptr inbounds nuw %struct.bufferActor_state, ptr %21, i32 0, i32 25
  store float %add7, ptr %a_sumProducers__178, align 4
  %22 = load ptr, ptr %self.addr, align 8
  %a_totalItemsFromProducers__16 = getelementptr inbounds nuw %struct.bufferActor_state, ptr %22, i32 0, i32 24
  %23 = load i32, ptr %a_totalItemsFromProducers__16, align 8
  %add9 = add i32 %23, 1
  %24 = load ptr, ptr %self.addr, align 8
  %a_totalItemsFromProducers__1610 = getelementptr inbounds nuw %struct.bufferActor_state, ptr %24, i32 0, i32 24
  store i32 %add9, ptr %a_totalItemsFromProducers__1610, align 8
  %25 = load ptr, ptr %self.addr, align 8
  %FromProducer_array_0_x_channel11 = getelementptr inbounds nuw %struct.bufferActor_state, ptr %25, i32 0, i32 1
  %26 = load ptr, ptr %FromProducer_array_0_x_channel11, align 8
  call void @channel_consume_float_1(ptr noundef %26, i64 noundef 1)
  ret void
}

; Function Attrs: noinline nounwind optnone uwtable
define internal zeroext i1 @bufferActor_condition_10(ptr noundef %self) #0 {
entry:
  %self.addr = alloca ptr, align 8
  %t_160 = alloca i8, align 1
  store ptr %self, ptr %self.addr, align 8
  %0 = load ptr, ptr %self.addr, align 8
  %FromConsumer_array_2_x_channel = getelementptr inbounds nuw %struct.bufferActor_state, ptr %0, i32 0, i32 6
  %1 = load ptr, ptr %FromConsumer_array_2_x_channel, align 8
  %call = call zeroext i1 @channel_has_data_float_1(ptr noundef %1, i64 noundef 1)
  %storedv = zext i1 %call to i8
  store i8 %storedv, ptr %t_160, align 1
  %2 = load i8, ptr %t_160, align 1
  %loadedv = trunc i8 %2 to i1
  ret i1 %loadedv
}

; Function Attrs: noinline nounwind optnone uwtable
define internal void @bufferActor_transition_5(ptr noundef %self) #0 {
entry:
  %self.addr = alloca ptr, align 8
  %l_token__28 = alloca float, align 4
  %t_142 = alloca float, align 4
  store ptr %self, ptr %self.addr, align 8
  store float 0.000000e+00, ptr %l_token__28, align 4
  store float 0.000000e+00, ptr %t_142, align 4
  %0 = load ptr, ptr %self.addr, align 8
  %FromConsumer_array_2_x_channel = getelementptr inbounds nuw %struct.bufferActor_state, ptr %0, i32 0, i32 6
  %1 = load ptr, ptr %FromConsumer_array_2_x_channel, align 8
  %call = call float @channel_peek_first_float_1(ptr noundef %1)
  store float %call, ptr %t_142, align 4
  %2 = load float, ptr %t_142, align 4
  store float %2, ptr %l_token__28, align 4
  %3 = load ptr, ptr %self.addr, align 8
  %a_sumConsumers__18 = getelementptr inbounds nuw %struct.bufferActor_state, ptr %3, i32 0, i32 26
  %4 = load float, ptr %a_sumConsumers__18, align 8
  %5 = load float, ptr %l_token__28, align 4
  %add = fadd float %4, %5
  %6 = load ptr, ptr %self.addr, align 8
  %a_sumConsumers__181 = getelementptr inbounds nuw %struct.bufferActor_state, ptr %6, i32 0, i32 26
  store float %add, ptr %a_sumConsumers__181, align 8
  %7 = load ptr, ptr %self.addr, align 8
  %a_totalItemsFromConsumers__15 = getelementptr inbounds nuw %struct.bufferActor_state, ptr %7, i32 0, i32 23
  %8 = load i32, ptr %a_totalItemsFromConsumers__15, align 4
  %add2 = add i32 %8, 1
  %9 = load ptr, ptr %self.addr, align 8
  %a_totalItemsFromConsumers__153 = getelementptr inbounds nuw %struct.bufferActor_state, ptr %9, i32 0, i32 23
  store i32 %add2, ptr %a_totalItemsFromConsumers__153, align 4
  %10 = load ptr, ptr %self.addr, align 8
  %a_freeConsumers__10 = getelementptr inbounds nuw %struct.bufferActor_state, ptr %10, i32 0, i32 18
  %data = getelementptr inbounds nuw %struct._S3_N4_list_N2_u1_N1_3, ptr %a_freeConsumers__10, i32 0, i32 0
  %arrayidx = getelementptr inbounds [3 x i8], ptr %data, i64 0, i64 2
  store i8 1, ptr %arrayidx, align 1
  %11 = load ptr, ptr %self.addr, align 8
  %FromConsumer_array_2_x_channel4 = getelementptr inbounds nuw %struct.bufferActor_state, ptr %11, i32 0, i32 6
  %12 = load ptr, ptr %FromConsumer_array_2_x_channel4, align 8
  call void @channel_consume_float_1(ptr noundef %12, i64 noundef 1)
  ret void
}

; Function Attrs: noinline nounwind optnone uwtable
define internal zeroext i1 @bufferActor_condition_8(ptr noundef %self) #0 {
entry:
  %self.addr = alloca ptr, align 8
  %t_158 = alloca i8, align 1
  store ptr %self, ptr %self.addr, align 8
  %0 = load ptr, ptr %self.addr, align 8
  %FromConsumer_array_1_x_channel = getelementptr inbounds nuw %struct.bufferActor_state, ptr %0, i32 0, i32 5
  %1 = load ptr, ptr %FromConsumer_array_1_x_channel, align 8
  %call = call zeroext i1 @channel_has_data_float_1(ptr noundef %1, i64 noundef 1)
  %storedv = zext i1 %call to i8
  store i8 %storedv, ptr %t_158, align 1
  %2 = load i8, ptr %t_158, align 1
  %loadedv = trunc i8 %2 to i1
  ret i1 %loadedv
}

; Function Attrs: noinline nounwind optnone uwtable
define internal void @bufferActor_transition_3(ptr noundef %self) #0 {
entry:
  %self.addr = alloca ptr, align 8
  %l_token__24 = alloca float, align 4
  %t_140 = alloca float, align 4
  store ptr %self, ptr %self.addr, align 8
  store float 0.000000e+00, ptr %l_token__24, align 4
  store float 0.000000e+00, ptr %t_140, align 4
  %0 = load ptr, ptr %self.addr, align 8
  %FromConsumer_array_1_x_channel = getelementptr inbounds nuw %struct.bufferActor_state, ptr %0, i32 0, i32 5
  %1 = load ptr, ptr %FromConsumer_array_1_x_channel, align 8
  %call = call float @channel_peek_first_float_1(ptr noundef %1)
  store float %call, ptr %t_140, align 4
  %2 = load float, ptr %t_140, align 4
  store float %2, ptr %l_token__24, align 4
  %3 = load ptr, ptr %self.addr, align 8
  %a_sumConsumers__18 = getelementptr inbounds nuw %struct.bufferActor_state, ptr %3, i32 0, i32 26
  %4 = load float, ptr %a_sumConsumers__18, align 8
  %5 = load float, ptr %l_token__24, align 4
  %add = fadd float %4, %5
  %6 = load ptr, ptr %self.addr, align 8
  %a_sumConsumers__181 = getelementptr inbounds nuw %struct.bufferActor_state, ptr %6, i32 0, i32 26
  store float %add, ptr %a_sumConsumers__181, align 8
  %7 = load ptr, ptr %self.addr, align 8
  %a_totalItemsFromConsumers__15 = getelementptr inbounds nuw %struct.bufferActor_state, ptr %7, i32 0, i32 23
  %8 = load i32, ptr %a_totalItemsFromConsumers__15, align 4
  %add2 = add i32 %8, 1
  %9 = load ptr, ptr %self.addr, align 8
  %a_totalItemsFromConsumers__153 = getelementptr inbounds nuw %struct.bufferActor_state, ptr %9, i32 0, i32 23
  store i32 %add2, ptr %a_totalItemsFromConsumers__153, align 4
  %10 = load ptr, ptr %self.addr, align 8
  %a_freeConsumers__10 = getelementptr inbounds nuw %struct.bufferActor_state, ptr %10, i32 0, i32 18
  %data = getelementptr inbounds nuw %struct._S3_N4_list_N2_u1_N1_3, ptr %a_freeConsumers__10, i32 0, i32 0
  %arrayidx = getelementptr inbounds [3 x i8], ptr %data, i64 0, i64 1
  store i8 1, ptr %arrayidx, align 1
  %11 = load ptr, ptr %self.addr, align 8
  %FromConsumer_array_1_x_channel4 = getelementptr inbounds nuw %struct.bufferActor_state, ptr %11, i32 0, i32 5
  %12 = load ptr, ptr %FromConsumer_array_1_x_channel4, align 8
  call void @channel_consume_float_1(ptr noundef %12, i64 noundef 1)
  ret void
}

; Function Attrs: noinline nounwind optnone uwtable
define internal zeroext i1 @bufferActor_condition_5(ptr noundef %self) #0 {
entry:
  %self.addr = alloca ptr, align 8
  %t_155 = alloca i8, align 1
  store ptr %self, ptr %self.addr, align 8
  %0 = load ptr, ptr %self.addr, align 8
  %FromConsumer_array_0_x_channel = getelementptr inbounds nuw %struct.bufferActor_state, ptr %0, i32 0, i32 4
  %1 = load ptr, ptr %FromConsumer_array_0_x_channel, align 8
  %call = call zeroext i1 @channel_has_data_float_1(ptr noundef %1, i64 noundef 1)
  %storedv = zext i1 %call to i8
  store i8 %storedv, ptr %t_155, align 1
  %2 = load i8, ptr %t_155, align 1
  %loadedv = trunc i8 %2 to i1
  ret i1 %loadedv
}

; Function Attrs: noinline nounwind optnone uwtable
define internal void @bufferActor_transition_1(ptr noundef %self) #0 {
entry:
  %self.addr = alloca ptr, align 8
  %l_token__20 = alloca float, align 4
  %t_138 = alloca float, align 4
  store ptr %self, ptr %self.addr, align 8
  store float 0.000000e+00, ptr %l_token__20, align 4
  store float 0.000000e+00, ptr %t_138, align 4
  %0 = load ptr, ptr %self.addr, align 8
  %FromConsumer_array_0_x_channel = getelementptr inbounds nuw %struct.bufferActor_state, ptr %0, i32 0, i32 4
  %1 = load ptr, ptr %FromConsumer_array_0_x_channel, align 8
  %call = call float @channel_peek_first_float_1(ptr noundef %1)
  store float %call, ptr %t_138, align 4
  %2 = load float, ptr %t_138, align 4
  store float %2, ptr %l_token__20, align 4
  %3 = load ptr, ptr %self.addr, align 8
  %a_sumConsumers__18 = getelementptr inbounds nuw %struct.bufferActor_state, ptr %3, i32 0, i32 26
  %4 = load float, ptr %a_sumConsumers__18, align 8
  %5 = load float, ptr %l_token__20, align 4
  %add = fadd float %4, %5
  %6 = load ptr, ptr %self.addr, align 8
  %a_sumConsumers__181 = getelementptr inbounds nuw %struct.bufferActor_state, ptr %6, i32 0, i32 26
  store float %add, ptr %a_sumConsumers__181, align 8
  %7 = load ptr, ptr %self.addr, align 8
  %a_totalItemsFromConsumers__15 = getelementptr inbounds nuw %struct.bufferActor_state, ptr %7, i32 0, i32 23
  %8 = load i32, ptr %a_totalItemsFromConsumers__15, align 4
  %add2 = add i32 %8, 1
  %9 = load ptr, ptr %self.addr, align 8
  %a_totalItemsFromConsumers__153 = getelementptr inbounds nuw %struct.bufferActor_state, ptr %9, i32 0, i32 23
  store i32 %add2, ptr %a_totalItemsFromConsumers__153, align 4
  %10 = load ptr, ptr %self.addr, align 8
  %a_freeConsumers__10 = getelementptr inbounds nuw %struct.bufferActor_state, ptr %10, i32 0, i32 18
  %data = getelementptr inbounds nuw %struct._S3_N4_list_N2_u1_N1_3, ptr %a_freeConsumers__10, i32 0, i32 0
  %arrayidx = getelementptr inbounds [3 x i8], ptr %data, i64 0, i64 0
  store i8 1, ptr %arrayidx, align 1
  %11 = load ptr, ptr %self.addr, align 8
  %FromConsumer_array_0_x_channel4 = getelementptr inbounds nuw %struct.bufferActor_state, ptr %11, i32 0, i32 4
  %12 = load ptr, ptr %FromConsumer_array_0_x_channel4, align 8
  call void @channel_consume_float_1(ptr noundef %12, i64 noundef 1)
  ret void
}

; Function Attrs: noinline nounwind optnone uwtable
define internal zeroext i1 @bufferActor_condition_4(ptr noundef %self) #0 {
entry:
  %self.addr = alloca ptr, align 8
  %t_154 = alloca i8, align 1
  store ptr %self, ptr %self.addr, align 8
  %0 = load i32, ptr @"g_bndBuffer_$eval7", align 4
  %1 = load i32, ptr @"g_bndBuffer_$eval8", align 4
  %mul = mul i32 %0, %1
  %2 = load i32, ptr @"g_bndBuffer_$eval7", align 4
  %add = add i32 %mul, %2
  %3 = load ptr, ptr %self.addr, align 8
  %a_totalItemsFromConsumers__15 = getelementptr inbounds nuw %struct.bufferActor_state, ptr %3, i32 0, i32 23
  %4 = load i32, ptr %a_totalItemsFromConsumers__15, align 4
  %cmp = icmp eq i32 %add, %4
  %storedv = zext i1 %cmp to i8
  store i8 %storedv, ptr %t_154, align 1
  %5 = load i8, ptr %t_154, align 1
  %loadedv = trunc i8 %5 to i1
  ret i1 %loadedv
}

; Function Attrs: noinline nounwind optnone uwtable
define internal zeroext i1 @bufferActor_condition_3(ptr noundef %self) #0 {
entry:
  %self.addr = alloca ptr, align 8
  %t_153 = alloca i8, align 1
  store ptr %self, ptr %self.addr, align 8
  %0 = load ptr, ptr %self.addr, align 8
  %totalItemsFromConsumers_channels = getelementptr inbounds nuw %struct.bufferActor_state, ptr %0, i32 0, i32 16
  %coerce.dive = getelementptr inbounds nuw %struct.channel_list_uint32_t_1, ptr %totalItemsFromConsumers_channels, i32 0, i32 0
  %1 = load ptr, ptr %coerce.dive, align 8
  %call = call zeroext i1 @channel_has_space_uint32_t_1(ptr %1, i64 noundef 1)
  %storedv = zext i1 %call to i8
  store i8 %storedv, ptr %t_153, align 1
  %2 = load i8, ptr %t_153, align 1
  %loadedv = trunc i8 %2 to i1
  ret i1 %loadedv
}

; Function Attrs: noinline nounwind optnone uwtable
define internal zeroext i1 @bufferActor_condition_2(ptr noundef %self) #0 {
entry:
  %self.addr = alloca ptr, align 8
  %t_152 = alloca i8, align 1
  store ptr %self, ptr %self.addr, align 8
  %0 = load ptr, ptr %self.addr, align 8
  %totalItemsFromProducers_channels = getelementptr inbounds nuw %struct.bufferActor_state, ptr %0, i32 0, i32 15
  %coerce.dive = getelementptr inbounds nuw %struct.channel_list_uint32_t_1, ptr %totalItemsFromProducers_channels, i32 0, i32 0
  %1 = load ptr, ptr %coerce.dive, align 8
  %call = call zeroext i1 @channel_has_space_uint32_t_1(ptr %1, i64 noundef 1)
  %storedv = zext i1 %call to i8
  store i8 %storedv, ptr %t_152, align 1
  %2 = load i8, ptr %t_152, align 1
  %loadedv = trunc i8 %2 to i1
  ret i1 %loadedv
}

; Function Attrs: noinline nounwind optnone uwtable
define internal zeroext i1 @bufferActor_condition_1(ptr noundef %self) #0 {
entry:
  %self.addr = alloca ptr, align 8
  %t_151 = alloca i8, align 1
  store ptr %self, ptr %self.addr, align 8
  %0 = load ptr, ptr %self.addr, align 8
  %sumConsumersPort_channels = getelementptr inbounds nuw %struct.bufferActor_state, ptr %0, i32 0, i32 14
  %coerce.dive = getelementptr inbounds nuw %struct.channel_list_float_1, ptr %sumConsumersPort_channels, i32 0, i32 0
  %1 = load ptr, ptr %coerce.dive, align 8
  %call = call zeroext i1 @channel_has_space_float_1(ptr %1, i64 noundef 1)
  %storedv = zext i1 %call to i8
  store i8 %storedv, ptr %t_151, align 1
  %2 = load i8, ptr %t_151, align 1
  %loadedv = trunc i8 %2 to i1
  ret i1 %loadedv
}

; Function Attrs: noinline nounwind optnone uwtable
define internal zeroext i1 @bufferActor_condition_0(ptr noundef %self) #0 {
entry:
  %self.addr = alloca ptr, align 8
  %t_150 = alloca i8, align 1
  store ptr %self, ptr %self.addr, align 8
  %0 = load ptr, ptr %self.addr, align 8
  %sumProducersPort_channels = getelementptr inbounds nuw %struct.bufferActor_state, ptr %0, i32 0, i32 13
  %coerce.dive = getelementptr inbounds nuw %struct.channel_list_float_1, ptr %sumProducersPort_channels, i32 0, i32 0
  %1 = load ptr, ptr %coerce.dive, align 8
  %call = call zeroext i1 @channel_has_space_float_1(ptr %1, i64 noundef 1)
  %storedv = zext i1 %call to i8
  store i8 %storedv, ptr %t_150, align 1
  %2 = load i8, ptr %t_150, align 1
  %loadedv = trunc i8 %2 to i1
  ret i1 %loadedv
}

; Function Attrs: noinline nounwind optnone uwtable
define internal void @bufferActor_transition_0(ptr noundef %self) #0 {
entry:
  %self.addr = alloca ptr, align 8
  %t_134 = alloca float, align 4
  %t_135 = alloca float, align 4
  %t_136 = alloca i32, align 4
  %t_137 = alloca i32, align 4
  store ptr %self, ptr %self.addr, align 8
  %0 = load ptr, ptr %self.addr, align 8
  %a_totalItemsFromConsumers__15 = getelementptr inbounds nuw %struct.bufferActor_state, ptr %0, i32 0, i32 23
  %1 = load i32, ptr %a_totalItemsFromConsumers__15, align 4
  %add = add i32 %1, 1
  %2 = load ptr, ptr %self.addr, align 8
  %a_totalItemsFromConsumers__151 = getelementptr inbounds nuw %struct.bufferActor_state, ptr %2, i32 0, i32 23
  store i32 %add, ptr %a_totalItemsFromConsumers__151, align 4
  %3 = load ptr, ptr %self.addr, align 8
  %a_sumProducers__17 = getelementptr inbounds nuw %struct.bufferActor_state, ptr %3, i32 0, i32 25
  %4 = load float, ptr %a_sumProducers__17, align 4
  store float %4, ptr %t_134, align 4
  %5 = load ptr, ptr %self.addr, align 8
  %sumProducersPort_channels = getelementptr inbounds nuw %struct.bufferActor_state, ptr %5, i32 0, i32 13
  %6 = load float, ptr %t_134, align 4
  %coerce.dive = getelementptr inbounds nuw %struct.channel_list_float_1, ptr %sumProducersPort_channels, i32 0, i32 0
  %7 = load ptr, ptr %coerce.dive, align 8
  call void @channel_write_one_float_1(ptr %7, float noundef %6)
  %8 = load ptr, ptr %self.addr, align 8
  %a_sumConsumers__18 = getelementptr inbounds nuw %struct.bufferActor_state, ptr %8, i32 0, i32 26
  %9 = load float, ptr %a_sumConsumers__18, align 8
  store float %9, ptr %t_135, align 4
  %10 = load ptr, ptr %self.addr, align 8
  %sumConsumersPort_channels = getelementptr inbounds nuw %struct.bufferActor_state, ptr %10, i32 0, i32 14
  %11 = load float, ptr %t_135, align 4
  %coerce.dive2 = getelementptr inbounds nuw %struct.channel_list_float_1, ptr %sumConsumersPort_channels, i32 0, i32 0
  %12 = load ptr, ptr %coerce.dive2, align 8
  call void @channel_write_one_float_1(ptr %12, float noundef %11)
  %13 = load ptr, ptr %self.addr, align 8
  %a_totalItemsFromProducers__16 = getelementptr inbounds nuw %struct.bufferActor_state, ptr %13, i32 0, i32 24
  %14 = load i32, ptr %a_totalItemsFromProducers__16, align 8
  store i32 %14, ptr %t_136, align 4
  %15 = load ptr, ptr %self.addr, align 8
  %totalItemsFromProducers_channels = getelementptr inbounds nuw %struct.bufferActor_state, ptr %15, i32 0, i32 15
  %16 = load i32, ptr %t_136, align 4
  %coerce.dive3 = getelementptr inbounds nuw %struct.channel_list_uint32_t_1, ptr %totalItemsFromProducers_channels, i32 0, i32 0
  %17 = load ptr, ptr %coerce.dive3, align 8
  call void @channel_write_one_uint32_t_1(ptr %17, i32 noundef %16)
  %18 = load ptr, ptr %self.addr, align 8
  %a_totalItemsFromConsumers__154 = getelementptr inbounds nuw %struct.bufferActor_state, ptr %18, i32 0, i32 23
  %19 = load i32, ptr %a_totalItemsFromConsumers__154, align 4
  %sub = sub i32 %19, 1
  store i32 %sub, ptr %t_137, align 4
  %20 = load ptr, ptr %self.addr, align 8
  %totalItemsFromConsumers_channels = getelementptr inbounds nuw %struct.bufferActor_state, ptr %20, i32 0, i32 16
  %21 = load i32, ptr %t_137, align 4
  %coerce.dive5 = getelementptr inbounds nuw %struct.channel_list_uint32_t_1, ptr %totalItemsFromConsumers_channels, i32 0, i32 0
  %22 = load ptr, ptr %coerce.dive5, align 8
  call void @channel_write_one_uint32_t_1(ptr %22, i32 noundef %21)
  ret void
}

; Function Attrs: nocallback nofree nounwind willreturn memory(argmem: write)
declare void @llvm.memset.p0.i64(ptr nocapture writeonly, i8, i64, i1 immarg) #2

; Function Attrs: noinline nounwind optnone uwtable
define internal zeroext i1 @channel_has_space_uint8_t_1(ptr %channel_list.coerce, i64 noundef %tokens) #0 {
entry:
  %retval = alloca i1, align 1
  %channel_list = alloca %struct.channel_list_uint8_t_1, align 8
  %tokens.addr = alloca i64, align 8
  %coerce.dive = getelementptr inbounds nuw %struct.channel_list_uint8_t_1, ptr %channel_list, i32 0, i32 0
  store ptr %channel_list.coerce, ptr %coerce.dive, align 8
  store i64 %tokens, ptr %tokens.addr, align 8
  %channel_0 = getelementptr inbounds nuw %struct.channel_list_uint8_t_1, ptr %channel_list, i32 0, i32 0
  %0 = load ptr, ptr %channel_0, align 8
  %write = getelementptr inbounds nuw %struct.channel_uint8_t_1, ptr %0, i32 0, i32 1
  %1 = load i64, ptr %write, align 8
  %channel_01 = getelementptr inbounds nuw %struct.channel_list_uint8_t_1, ptr %channel_list, i32 0, i32 0
  %2 = load ptr, ptr %channel_01, align 8
  %read = getelementptr inbounds nuw %struct.channel_uint8_t_1, ptr %2, i32 0, i32 0
  %3 = load i64, ptr %read, align 8
  %sub = sub i64 %1, %3
  %sub2 = sub i64 1, %sub
  %4 = load i64, ptr %tokens.addr, align 8
  %cmp = icmp ult i64 %sub2, %4
  br i1 %cmp, label %if.then, label %if.end

if.then:                                          ; preds = %entry
  store i1 false, ptr %retval, align 1
  br label %return

if.end:                                           ; preds = %entry
  store i1 true, ptr %retval, align 1
  br label %return

return:                                           ; preds = %if.end, %if.then
  %5 = load i1, ptr %retval, align 1
  ret i1 %5
}

; Function Attrs: noinline nounwind optnone uwtable
define internal zeroext i1 @channel_has_space_float_1(ptr %channel_list.coerce, i64 noundef %tokens) #0 {
entry:
  %retval = alloca i1, align 1
  %channel_list = alloca %struct.channel_list_float_1, align 8
  %tokens.addr = alloca i64, align 8
  %coerce.dive = getelementptr inbounds nuw %struct.channel_list_float_1, ptr %channel_list, i32 0, i32 0
  store ptr %channel_list.coerce, ptr %coerce.dive, align 8
  store i64 %tokens, ptr %tokens.addr, align 8
  %channel_0 = getelementptr inbounds nuw %struct.channel_list_float_1, ptr %channel_list, i32 0, i32 0
  %0 = load ptr, ptr %channel_0, align 8
  %write = getelementptr inbounds nuw %struct.channel_float_1, ptr %0, i32 0, i32 1
  %1 = load i64, ptr %write, align 8
  %channel_01 = getelementptr inbounds nuw %struct.channel_list_float_1, ptr %channel_list, i32 0, i32 0
  %2 = load ptr, ptr %channel_01, align 8
  %read = getelementptr inbounds nuw %struct.channel_float_1, ptr %2, i32 0, i32 0
  %3 = load i64, ptr %read, align 8
  %sub = sub i64 %1, %3
  %sub2 = sub i64 1, %sub
  %4 = load i64, ptr %tokens.addr, align 8
  %cmp = icmp ult i64 %sub2, %4
  br i1 %cmp, label %if.then, label %if.end

if.then:                                          ; preds = %entry
  store i1 false, ptr %retval, align 1
  br label %return

if.end:                                           ; preds = %entry
  store i1 true, ptr %retval, align 1
  br label %return

return:                                           ; preds = %if.end, %if.then
  %5 = load i1, ptr %retval, align 1
  ret i1 %5
}

; Function Attrs: noinline nounwind optnone uwtable
define internal zeroext i1 @channel_has_data_float_1(ptr noundef %channel, i64 noundef %tokens) #0 {
entry:
  %channel.addr = alloca ptr, align 8
  %tokens.addr = alloca i64, align 8
  store ptr %channel, ptr %channel.addr, align 8
  store i64 %tokens, ptr %tokens.addr, align 8
  %0 = load ptr, ptr %channel.addr, align 8
  %write = getelementptr inbounds nuw %struct.channel_float_1, ptr %0, i32 0, i32 1
  %1 = load i64, ptr %write, align 8
  %2 = load ptr, ptr %channel.addr, align 8
  %read = getelementptr inbounds nuw %struct.channel_float_1, ptr %2, i32 0, i32 0
  %3 = load i64, ptr %read, align 8
  %sub = sub i64 %1, %3
  %4 = load i64, ptr %tokens.addr, align 8
  %cmp = icmp uge i64 %sub, %4
  ret i1 %cmp
}

; Function Attrs: noinline nounwind optnone uwtable
define internal void @channel_write_one_uint8_t_1(ptr %channel_list.coerce, i8 noundef zeroext %data) #0 {
entry:
  %channel_list = alloca %struct.channel_list_uint8_t_1, align 8
  %data.addr = alloca i8, align 1
  %chan = alloca ptr, align 8
  %coerce.dive = getelementptr inbounds nuw %struct.channel_list_uint8_t_1, ptr %channel_list, i32 0, i32 0
  store ptr %channel_list.coerce, ptr %coerce.dive, align 8
  store i8 %data, ptr %data.addr, align 1
  %channel_0 = getelementptr inbounds nuw %struct.channel_list_uint8_t_1, ptr %channel_list, i32 0, i32 0
  %0 = load ptr, ptr %channel_0, align 8
  store ptr %0, ptr %chan, align 8
  %1 = load i8, ptr %data.addr, align 1
  %2 = load ptr, ptr %chan, align 8
  %buffer = getelementptr inbounds nuw %struct.channel_uint8_t_1, ptr %2, i32 0, i32 2
  %3 = load ptr, ptr %buffer, align 8
  %4 = load ptr, ptr %chan, align 8
  %write = getelementptr inbounds nuw %struct.channel_uint8_t_1, ptr %4, i32 0, i32 1
  %5 = load i64, ptr %write, align 8
  %rem = urem i64 %5, 1
  %arrayidx = getelementptr inbounds nuw i8, ptr %3, i64 %rem
  store i8 %1, ptr %arrayidx, align 1
  %6 = load ptr, ptr %chan, align 8
  %write1 = getelementptr inbounds nuw %struct.channel_uint8_t_1, ptr %6, i32 0, i32 1
  %7 = load i64, ptr %write1, align 8
  %inc = add i64 %7, 1
  store i64 %inc, ptr %write1, align 8
  ret void
}

; Function Attrs: noinline nounwind optnone uwtable
define internal void @channel_write_one_float_1(ptr %channel_list.coerce, float noundef %data) #0 {
entry:
  %channel_list = alloca %struct.channel_list_float_1, align 8
  %data.addr = alloca float, align 4
  %chan = alloca ptr, align 8
  %coerce.dive = getelementptr inbounds nuw %struct.channel_list_float_1, ptr %channel_list, i32 0, i32 0
  store ptr %channel_list.coerce, ptr %coerce.dive, align 8
  store float %data, ptr %data.addr, align 4
  %channel_0 = getelementptr inbounds nuw %struct.channel_list_float_1, ptr %channel_list, i32 0, i32 0
  %0 = load ptr, ptr %channel_0, align 8
  store ptr %0, ptr %chan, align 8
  %1 = load float, ptr %data.addr, align 4
  %2 = load ptr, ptr %chan, align 8
  %buffer = getelementptr inbounds nuw %struct.channel_float_1, ptr %2, i32 0, i32 2
  %3 = load ptr, ptr %buffer, align 8
  %4 = load ptr, ptr %chan, align 8
  %write = getelementptr inbounds nuw %struct.channel_float_1, ptr %4, i32 0, i32 1
  %5 = load i64, ptr %write, align 8
  %rem = urem i64 %5, 1
  %arrayidx = getelementptr inbounds nuw float, ptr %3, i64 %rem
  store float %1, ptr %arrayidx, align 4
  %6 = load ptr, ptr %chan, align 8
  %write1 = getelementptr inbounds nuw %struct.channel_float_1, ptr %6, i32 0, i32 1
  %7 = load i64, ptr %write1, align 8
  %inc = add i64 %7, 1
  store i64 %inc, ptr %write1, align 8
  ret void
}

; Function Attrs: noinline nounwind optnone uwtable
define internal float @channel_peek_first_float_1(ptr noundef %channel) #0 {
entry:
  %channel.addr = alloca ptr, align 8
  store ptr %channel, ptr %channel.addr, align 8
  %0 = load ptr, ptr %channel.addr, align 8
  %buffer = getelementptr inbounds nuw %struct.channel_float_1, ptr %0, i32 0, i32 2
  %1 = load ptr, ptr %buffer, align 8
  %2 = load ptr, ptr %channel.addr, align 8
  %read = getelementptr inbounds nuw %struct.channel_float_1, ptr %2, i32 0, i32 0
  %3 = load i64, ptr %read, align 8
  %rem = urem i64 %3, 1
  %arrayidx = getelementptr inbounds nuw float, ptr %1, i64 %rem
  %4 = load float, ptr %arrayidx, align 4
  ret float %4
}

; Function Attrs: noinline nounwind optnone uwtable
define internal void @channel_consume_float_1(ptr noundef %channel, i64 noundef %tokens) #0 {
entry:
  %channel.addr = alloca ptr, align 8
  %tokens.addr = alloca i64, align 8
  store ptr %channel, ptr %channel.addr, align 8
  store i64 %tokens, ptr %tokens.addr, align 8
  %0 = load i64, ptr %tokens.addr, align 8
  %1 = load ptr, ptr %channel.addr, align 8
  %read = getelementptr inbounds nuw %struct.channel_float_1, ptr %1, i32 0, i32 0
  %2 = load i64, ptr %read, align 8
  %add = add i64 %2, %0
  store i64 %add, ptr %read, align 8
  ret void
}

; Function Attrs: noinline nounwind optnone uwtable
define internal zeroext i1 @channel_has_space_uint32_t_1(ptr %channel_list.coerce, i64 noundef %tokens) #0 {
entry:
  %retval = alloca i1, align 1
  %channel_list = alloca %struct.channel_list_uint32_t_1, align 8
  %tokens.addr = alloca i64, align 8
  %coerce.dive = getelementptr inbounds nuw %struct.channel_list_uint32_t_1, ptr %channel_list, i32 0, i32 0
  store ptr %channel_list.coerce, ptr %coerce.dive, align 8
  store i64 %tokens, ptr %tokens.addr, align 8
  %channel_0 = getelementptr inbounds nuw %struct.channel_list_uint32_t_1, ptr %channel_list, i32 0, i32 0
  %0 = load ptr, ptr %channel_0, align 8
  %write = getelementptr inbounds nuw %struct.channel_uint32_t_1, ptr %0, i32 0, i32 1
  %1 = load i64, ptr %write, align 8
  %channel_01 = getelementptr inbounds nuw %struct.channel_list_uint32_t_1, ptr %channel_list, i32 0, i32 0
  %2 = load ptr, ptr %channel_01, align 8
  %read = getelementptr inbounds nuw %struct.channel_uint32_t_1, ptr %2, i32 0, i32 0
  %3 = load i64, ptr %read, align 8
  %sub = sub i64 %1, %3
  %sub2 = sub i64 1, %sub
  %4 = load i64, ptr %tokens.addr, align 8
  %cmp = icmp ult i64 %sub2, %4
  br i1 %cmp, label %if.then, label %if.end

if.then:                                          ; preds = %entry
  store i1 false, ptr %retval, align 1
  br label %return

if.end:                                           ; preds = %entry
  store i1 true, ptr %retval, align 1
  br label %return

return:                                           ; preds = %if.end, %if.then
  %5 = load i1, ptr %retval, align 1
  ret i1 %5
}

; Function Attrs: noinline nounwind optnone uwtable
define internal void @channel_write_one_uint32_t_1(ptr %channel_list.coerce, i32 noundef %data) #0 {
entry:
  %channel_list = alloca %struct.channel_list_uint32_t_1, align 8
  %data.addr = alloca i32, align 4
  %chan = alloca ptr, align 8
  %coerce.dive = getelementptr inbounds nuw %struct.channel_list_uint32_t_1, ptr %channel_list, i32 0, i32 0
  store ptr %channel_list.coerce, ptr %coerce.dive, align 8
  store i32 %data, ptr %data.addr, align 4
  %channel_0 = getelementptr inbounds nuw %struct.channel_list_uint32_t_1, ptr %channel_list, i32 0, i32 0
  %0 = load ptr, ptr %channel_0, align 8
  store ptr %0, ptr %chan, align 8
  %1 = load i32, ptr %data.addr, align 4
  %2 = load ptr, ptr %chan, align 8
  %buffer = getelementptr inbounds nuw %struct.channel_uint32_t_1, ptr %2, i32 0, i32 2
  %3 = load ptr, ptr %buffer, align 8
  %4 = load ptr, ptr %chan, align 8
  %write = getelementptr inbounds nuw %struct.channel_uint32_t_1, ptr %4, i32 0, i32 1
  %5 = load i64, ptr %write, align 8
  %rem = urem i64 %5, 1
  %arrayidx = getelementptr inbounds nuw i32, ptr %3, i64 %rem
  store i32 %1, ptr %arrayidx, align 4
  %6 = load ptr, ptr %chan, align 8
  %write1 = getelementptr inbounds nuw %struct.channel_uint32_t_1, ptr %6, i32 0, i32 1
  %7 = load i64, ptr %write1, align 8
  %inc = add i64 %7, 1
  store i64 %inc, ptr %write1, align 8
  ret void
}

attributes #0 = { noinline nounwind optnone uwtable "frame-pointer"="all" "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #1 = { nocallback nofree nounwind willreturn memory(argmem: readwrite) }
attributes #2 = { nocallback nofree nounwind willreturn memory(argmem: write) }

!llvm.module.flags = !{!0, !1, !2, !3, !4}
!llvm.ident = !{!5}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{i32 8, !"PIC Level", i32 2}
!2 = !{i32 7, !"PIE Level", i32 2}
!3 = !{i32 7, !"uwtable", i32 2}
!4 = !{i32 7, !"frame-pointer", i32 2}
!5 = !{!"clang version 20.1.0 (https://github.com/llvm/llvm-project.git 24a30daaa559829ad079f2ff7f73eb4e18095f88)"}
!6 = distinct !{!6, !7}
!7 = !{!"llvm.loop.mustprogress"}
!8 = distinct !{!8, !7}
!9 = distinct !{!9, !7}
