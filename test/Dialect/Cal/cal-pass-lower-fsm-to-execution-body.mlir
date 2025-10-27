// RUN: cal-opt --lower-cal-fsm-to-execution-body %s | FileCheck %s

// After lowering:
// - The actor should have cal.create_state_var + cal.set for state index init
// - cal.fsm must be gone
// - cal.action bodies are removed (inlined into execution_body) and no cal.action remains
// - cal.execution_body must exist and end with cal.action_done
// CHECK: cal.actor @src_fsm(
// CHECK-NOT: cal.fsm
// CHECK: cal.create_state_var<i32> : !cal.state_ref<i32>
// CHECK: cal.set(
// CHECK: cal.execution_body {
// CHECK: cal.action_done
// CHECK-NOT: cal.action
cal.actor @src_fsm(%max_tokens_to_send: i32, %actor_index: i32)
    ports_out(%out0: !fifo.input_port<i32>)
{
    %num_tokens_sent_state = cal.create_state_var<i32> : !cal.state_ref<i32>
    %c0 = arith.constant 0 : i32
    cal.set(%num_tokens_sent_state: !cal.state_ref<i32>, %c0: i32)

    cal.fsm {
        cal.state @S0 {
            cal.transition action("send") -> @S0
        } { initial }
    }

    cal.action "send" {
        cal.predicate {
            %num_tokens_sent = cal.get(%num_tokens_sent_state: !cal.state_ref<i32>) : i32
            %cmp_sent = arith.cmpi slt, %num_tokens_sent, %max_tokens_to_send : i32
            cal.predicate_result %cmp_sent : i1
        }
        %one_i32 = arith.constant 1 : i32
        %tokens_sent = cal.get(%num_tokens_sent_state: !cal.state_ref<i32>) : i32
        %tokens_sent_plus_one = arith.addi %tokens_sent, %one_i32 : i32
        cal.set(%num_tokens_sent_state: !cal.state_ref<i32>, %tokens_sent_plus_one: i32)
        fifo.push(%out0: !fifo.input_port<i32>, %tokens_sent: i32)
    }
}
