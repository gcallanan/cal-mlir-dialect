; ModuleID = 'myproject/actor_consumers_0.c'
source_filename = "myproject/actor_consumers_0.c"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

%struct.channel_list_float_1 = type { ptr }
%struct.consumers_0_state = type { i32, ptr, %struct.channel_list_float_1, %struct.envt_f_processRxItem_64_0, i32, float, %struct._S3_N2_fn_N4_void_S2_N4_real_N2_32 }
%struct.envt_f_processRxItem_64_0 = type { ptr }
%struct._S3_N2_fn_N4_void_S2_N4_real_N2_32 = type { ptr, ptr }
%struct.channel_float_1 = type { i64, i64, ptr }

; Function Attrs: noinline nounwind optnone uwtable
define dso_local void @consumers_0_init_actor(ptr noundef %self, ptr noundef %In_channel, ptr %Out_channels.coerce) #0 {
entry:
  %Out_channels = alloca %struct.channel_list_float_1, align 8
  %self.addr = alloca ptr, align 8
  %In_channel.addr = alloca ptr, align 8
  %coerce.dive = getelementptr inbounds nuw %struct.channel_list_float_1, ptr %Out_channels, i32 0, i32 0
  store ptr %Out_channels.coerce, ptr %coerce.dive, align 8
  store ptr %self, ptr %self.addr, align 8
  store ptr %In_channel, ptr %In_channel.addr, align 8
  %0 = load ptr, ptr %self.addr, align 8
  %program_counter = getelementptr inbounds nuw %struct.consumers_0_state, ptr %0, i32 0, i32 0
  store i32 0, ptr %program_counter, align 8
  %1 = load ptr, ptr %In_channel.addr, align 8
  %2 = load ptr, ptr %self.addr, align 8
  %In_channel1 = getelementptr inbounds nuw %struct.consumers_0_state, ptr %2, i32 0, i32 1
  store ptr %1, ptr %In_channel1, align 8
  %3 = load ptr, ptr %self.addr, align 8
  %Out_channels2 = getelementptr inbounds nuw %struct.consumers_0_state, ptr %3, i32 0, i32 2
  call void @llvm.memcpy.p0.p0.i64(ptr align 8 %Out_channels2, ptr align 8 %Out_channels, i64 8, i1 false)
  %4 = load ptr, ptr %self.addr, align 8
  call void @consumers_0_init_scope_0(ptr noundef %4)
  ret void
}

; Function Attrs: nocallback nofree nounwind willreturn memory(argmem: readwrite)
declare void @llvm.memcpy.p0.p0.i64(ptr noalias nocapture writeonly, ptr noalias nocapture readonly, i64, i1 immarg) #1

; Function Attrs: noinline nounwind optnone uwtable
define internal void @consumers_0_init_scope_0(ptr noundef %self) #0 {
entry:
  %self.addr = alloca ptr, align 8
  %t_117 = alloca %struct._S3_N2_fn_N4_void_S2_N4_real_N2_32, align 8
  store ptr %self, ptr %self.addr, align 8
  %0 = load ptr, ptr %self.addr, align 8
  %a_request__token__62 = getelementptr inbounds nuw %struct.consumers_0_state, ptr %0, i32 0, i32 4
  store i32 1, ptr %a_request__token__62, align 8
  %1 = load ptr, ptr %self.addr, align 8
  %a_consItem__63 = getelementptr inbounds nuw %struct.consumers_0_state, ptr %1, i32 0, i32 5
  store float 0.000000e+00, ptr %a_consItem__63, align 4
  %2 = load ptr, ptr %self.addr, align 8
  %a_consItem__631 = getelementptr inbounds nuw %struct.consumers_0_state, ptr %2, i32 0, i32 5
  %3 = load ptr, ptr %self.addr, align 8
  %env_f_processRxItem_64_0 = getelementptr inbounds nuw %struct.consumers_0_state, ptr %3, i32 0, i32 3
  %a_consItem__632 = getelementptr inbounds nuw %struct.envt_f_processRxItem_64_0, ptr %env_f_processRxItem_64_0, i32 0, i32 0
  store ptr %a_consItem__631, ptr %a_consItem__632, align 8
  %f = getelementptr inbounds nuw %struct._S3_N2_fn_N4_void_S2_N4_real_N2_32, ptr %t_117, i32 0, i32 0
  store ptr @f_processRxItem_64_0, ptr %f, align 8
  %env = getelementptr inbounds nuw %struct._S3_N2_fn_N4_void_S2_N4_real_N2_32, ptr %t_117, i32 0, i32 1
  %4 = load ptr, ptr %self.addr, align 8
  %env_f_processRxItem_64_03 = getelementptr inbounds nuw %struct.consumers_0_state, ptr %4, i32 0, i32 3
  store ptr %env_f_processRxItem_64_03, ptr %env, align 8
  %5 = load ptr, ptr %self.addr, align 8
  %a_processRxItem__64 = getelementptr inbounds nuw %struct.consumers_0_state, ptr %5, i32 0, i32 6
  call void @llvm.memcpy.p0.p0.i64(ptr align 8 %a_processRxItem__64, ptr align 8 %t_117, i64 16, i1 false)
  ret void
}

; Function Attrs: noinline nounwind optnone uwtable
define dso_local void @consumers_0_free_actor(ptr noundef %self) #0 {
entry:
  %self.addr = alloca ptr, align 8
  store ptr %self, ptr %self.addr, align 8
  %0 = load ptr, ptr %self.addr, align 8
  call void @consumers_0_free_scope_0(ptr noundef %0)
  ret void
}

; Function Attrs: noinline nounwind optnone uwtable
define internal void @consumers_0_free_scope_0(ptr noundef %self) #0 {
entry:
  %self.addr = alloca ptr, align 8
  store ptr %self, ptr %self.addr, align 8
  ret void
}

; Function Attrs: noinline nounwind optnone uwtable
define dso_local zeroext i1 @consumers_0_run(ptr noundef %self) #0 {
entry:
  %self.addr = alloca ptr, align 8
  %progress = alloca i8, align 1
  store ptr %self, ptr %self.addr, align 8
  store i8 0, ptr %progress, align 1
  %0 = load ptr, ptr %self.addr, align 8
  %program_counter = getelementptr inbounds nuw %struct.consumers_0_state, ptr %0, i32 0, i32 0
  %1 = load i32, ptr %program_counter, align 8
  switch i32 %1, label %sw.epilog [
    i32 0, label %sw.bb
  ]

sw.bb:                                            ; preds = %entry
  br label %S0

sw.epilog:                                        ; preds = %entry
  br label %S0

S0:                                               ; preds = %S6, %S3, %sw.epilog, %sw.bb
  %2 = load ptr, ptr %self.addr, align 8
  %call = call zeroext i1 @consumers_0_condition_3(ptr noundef %2)
  br i1 %call, label %if.then, label %if.else

if.then:                                          ; preds = %S0
  br label %S1

if.else:                                          ; preds = %S0
  br label %S2

S1:                                               ; preds = %if.then
  %3 = load ptr, ptr %self.addr, align 8
  %call1 = call zeroext i1 @consumers_0_condition_2(ptr noundef %3)
  br i1 %call1, label %if.then2, label %if.else3

if.then2:                                         ; preds = %S1
  br label %S3

if.else3:                                         ; preds = %S1
  br label %S2

S2:                                               ; preds = %if.else3, %if.else
  %4 = load ptr, ptr %self.addr, align 8
  %call4 = call zeroext i1 @consumers_0_condition_1(ptr noundef %4)
  br i1 %call4, label %if.then5, label %if.else6

if.then5:                                         ; preds = %S2
  br label %S4

if.else6:                                         ; preds = %S2
  br label %S5

S3:                                               ; preds = %if.then2
  %5 = load ptr, ptr %self.addr, align 8
  call void @consumers_0_transition_1(ptr noundef %5)
  store i8 1, ptr %progress, align 1
  br label %S0

S4:                                               ; preds = %if.then5
  %6 = load ptr, ptr %self.addr, align 8
  %call7 = call zeroext i1 @consumers_0_condition_0(ptr noundef %6)
  br i1 %call7, label %if.then8, label %if.else9

if.then8:                                         ; preds = %S4
  br label %S6

if.else9:                                         ; preds = %S4
  br label %S5

S5:                                               ; preds = %if.else9, %if.else6
  %7 = load ptr, ptr %self.addr, align 8
  %program_counter10 = getelementptr inbounds nuw %struct.consumers_0_state, ptr %7, i32 0, i32 0
  store i32 0, ptr %program_counter10, align 8
  %8 = load i8, ptr %progress, align 1
  %loadedv = trunc i8 %8 to i1
  ret i1 %loadedv

S6:                                               ; preds = %if.then8
  %9 = load ptr, ptr %self.addr, align 8
  call void @consumers_0_transition_0(ptr noundef %9)
  store i8 1, ptr %progress, align 1
  br label %S0
}

; Function Attrs: noinline nounwind optnone uwtable
define internal zeroext i1 @consumers_0_condition_3(ptr noundef %self) #0 {
entry:
  %self.addr = alloca ptr, align 8
  %t_123 = alloca i8, align 1
  store ptr %self, ptr %self.addr, align 8
  %0 = load ptr, ptr %self.addr, align 8
  %a_request__token__62 = getelementptr inbounds nuw %struct.consumers_0_state, ptr %0, i32 0, i32 4
  %1 = load i32, ptr %a_request__token__62, align 8
  %cmp = icmp eq i32 %1, 0
  %storedv = zext i1 %cmp to i8
  store i8 %storedv, ptr %t_123, align 1
  %2 = load i8, ptr %t_123, align 1
  %loadedv = trunc i8 %2 to i1
  ret i1 %loadedv
}

; Function Attrs: noinline nounwind optnone uwtable
define internal zeroext i1 @consumers_0_condition_2(ptr noundef %self) #0 {
entry:
  %self.addr = alloca ptr, align 8
  %t_122 = alloca i8, align 1
  store ptr %self, ptr %self.addr, align 8
  %0 = load ptr, ptr %self.addr, align 8
  %In_channel = getelementptr inbounds nuw %struct.consumers_0_state, ptr %0, i32 0, i32 1
  %1 = load ptr, ptr %In_channel, align 8
  %call = call zeroext i1 @channel_has_data_float_1(ptr noundef %1, i64 noundef 1)
  %storedv = zext i1 %call to i8
  store i8 %storedv, ptr %t_122, align 1
  %2 = load i8, ptr %t_122, align 1
  %loadedv = trunc i8 %2 to i1
  ret i1 %loadedv
}

; Function Attrs: noinline nounwind optnone uwtable
define internal zeroext i1 @consumers_0_condition_1(ptr noundef %self) #0 {
entry:
  %self.addr = alloca ptr, align 8
  %t_121 = alloca i8, align 1
  store ptr %self, ptr %self.addr, align 8
  %0 = load ptr, ptr %self.addr, align 8
  %a_request__token__62 = getelementptr inbounds nuw %struct.consumers_0_state, ptr %0, i32 0, i32 4
  %1 = load i32, ptr %a_request__token__62, align 8
  %cmp = icmp eq i32 %1, 1
  %storedv = zext i1 %cmp to i8
  store i8 %storedv, ptr %t_121, align 1
  %2 = load i8, ptr %t_121, align 1
  %loadedv = trunc i8 %2 to i1
  ret i1 %loadedv
}

; Function Attrs: noinline nounwind optnone uwtable
define internal void @consumers_0_transition_1(ptr noundef %self) #0 {
entry:
  %self.addr = alloca ptr, align 8
  %l_dataItem__66 = alloca float, align 4
  %t_119 = alloca float, align 4
  store ptr %self, ptr %self.addr, align 8
  store float 0.000000e+00, ptr %l_dataItem__66, align 4
  store float 0.000000e+00, ptr %t_119, align 4
  %0 = load ptr, ptr %self.addr, align 8
  %In_channel = getelementptr inbounds nuw %struct.consumers_0_state, ptr %0, i32 0, i32 1
  %1 = load ptr, ptr %In_channel, align 8
  %call = call float @channel_peek_first_float_1(ptr noundef %1)
  store float %call, ptr %t_119, align 4
  %2 = load float, ptr %t_119, align 4
  store float %2, ptr %l_dataItem__66, align 4
  %3 = load ptr, ptr %self.addr, align 8
  %a_request__token__62 = getelementptr inbounds nuw %struct.consumers_0_state, ptr %3, i32 0, i32 4
  store i32 1, ptr %a_request__token__62, align 8
  %4 = load ptr, ptr %self.addr, align 8
  %a_processRxItem__64 = getelementptr inbounds nuw %struct.consumers_0_state, ptr %4, i32 0, i32 6
  %f = getelementptr inbounds nuw %struct._S3_N2_fn_N4_void_S2_N4_real_N2_32, ptr %a_processRxItem__64, i32 0, i32 0
  %5 = load ptr, ptr %f, align 8
  %6 = load ptr, ptr %self.addr, align 8
  %a_processRxItem__641 = getelementptr inbounds nuw %struct.consumers_0_state, ptr %6, i32 0, i32 6
  %env = getelementptr inbounds nuw %struct._S3_N2_fn_N4_void_S2_N4_real_N2_32, ptr %a_processRxItem__641, i32 0, i32 1
  %7 = load ptr, ptr %env, align 8
  %8 = load float, ptr %l_dataItem__66, align 4
  call void %5(ptr noundef %7, float noundef %8)
  %9 = load ptr, ptr %self.addr, align 8
  %In_channel2 = getelementptr inbounds nuw %struct.consumers_0_state, ptr %9, i32 0, i32 1
  %10 = load ptr, ptr %In_channel2, align 8
  call void @channel_consume_float_1(ptr noundef %10, i64 noundef 1)
  ret void
}

; Function Attrs: noinline nounwind optnone uwtable
define internal zeroext i1 @consumers_0_condition_0(ptr noundef %self) #0 {
entry:
  %self.addr = alloca ptr, align 8
  %t_120 = alloca i8, align 1
  store ptr %self, ptr %self.addr, align 8
  %0 = load ptr, ptr %self.addr, align 8
  %Out_channels = getelementptr inbounds nuw %struct.consumers_0_state, ptr %0, i32 0, i32 2
  %coerce.dive = getelementptr inbounds nuw %struct.channel_list_float_1, ptr %Out_channels, i32 0, i32 0
  %1 = load ptr, ptr %coerce.dive, align 8
  %call = call zeroext i1 @channel_has_space_float_1(ptr %1, i64 noundef 1)
  %storedv = zext i1 %call to i8
  store i8 %storedv, ptr %t_120, align 1
  %2 = load i8, ptr %t_120, align 1
  %loadedv = trunc i8 %2 to i1
  ret i1 %loadedv
}

; Function Attrs: noinline nounwind optnone uwtable
define internal void @consumers_0_transition_0(ptr noundef %self) #0 {
entry:
  %self.addr = alloca ptr, align 8
  %t_118 = alloca float, align 4
  store ptr %self, ptr %self.addr, align 8
  %0 = load ptr, ptr %self.addr, align 8
  %a_request__token__62 = getelementptr inbounds nuw %struct.consumers_0_state, ptr %0, i32 0, i32 4
  store i32 0, ptr %a_request__token__62, align 8
  %1 = load ptr, ptr %self.addr, align 8
  %a_consItem__63 = getelementptr inbounds nuw %struct.consumers_0_state, ptr %1, i32 0, i32 5
  %2 = load float, ptr %a_consItem__63, align 4
  store float %2, ptr %t_118, align 4
  %3 = load ptr, ptr %self.addr, align 8
  %Out_channels = getelementptr inbounds nuw %struct.consumers_0_state, ptr %3, i32 0, i32 2
  %4 = load float, ptr %t_118, align 4
  %coerce.dive = getelementptr inbounds nuw %struct.channel_list_float_1, ptr %Out_channels, i32 0, i32 0
  %5 = load ptr, ptr %coerce.dive, align 8
  call void @channel_write_one_float_1(ptr %5, float noundef %4)
  ret void
}

declare void @f_processRxItem_64_0(ptr noundef, float noundef) #2

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

attributes #0 = { noinline nounwind optnone uwtable "frame-pointer"="all" "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #1 = { nocallback nofree nounwind willreturn memory(argmem: readwrite) }
attributes #2 = { "frame-pointer"="all" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }

!llvm.module.flags = !{!0, !1, !2, !3, !4}
!llvm.ident = !{!5}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{i32 8, !"PIC Level", i32 2}
!2 = !{i32 7, !"PIE Level", i32 2}
!3 = !{i32 7, !"uwtable", i32 2}
!4 = !{i32 7, !"frame-pointer", i32 2}
!5 = !{!"clang version 20.1.0 (https://github.com/llvm/llvm-project.git 24a30daaa559829ad079f2ff7f73eb4e18095f88)"}
