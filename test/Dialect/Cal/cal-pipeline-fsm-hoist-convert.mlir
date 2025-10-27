// RUN: cal-opt --lower-cal-fsm-to-execution-body --convert-cal-actions-to-execution-bodies --hoist-cal-state-out-of-actor --convert-cal-to-func %s | FileCheck %s

// A small FSM actor and a network to ensure main() exists.
cal.actor @src_fsm(%limit: i32)
    ports_out(%o: !fifo.input_port<i32>)
{
  %c = cal.create_state_var<i32> : !cal.state_ref<i32>
  %z = arith.constant 0 : i32
  cal.set(%c: !cal.state_ref<i32>, %z: i32)

  cal.fsm {
    cal.state @S { cal.transition action("send") -> @S } { initial }
  }

  cal.action "send" {
    cal.predicate {
      %v = cal.get(%c: !cal.state_ref<i32>) : i32
      %ok = arith.cmpi slt, %v, %limit : i32
      cal.predicate_result %ok : i1
    }
    %v0 = cal.get(%c: !cal.state_ref<i32>) : i32
    %one = arith.constant 1 : i32
    %v1 = arith.addi %v0, %one : i32
    cal.set(%c: !cal.state_ref<i32>, %v1: i32)
    fifo.push(%o: !fifo.input_port<i32>, %v0: i32)
  }
}

cal.actor @sink()
    ports_in(%i: !fifo.output_port<i32>)
{
  cal.action { %t = fifo.pop(%i: !fifo.output_port<i32>) : i32 }
}

cal.network @net() {
  %n = arith.constant 3 : i32
  %iin, %iout = fifo.create<i32>(2) : !fifo.input_port<i32>, !fifo.output_port<i32>
  cal.create_instance @src_fsm "s" (%n : i32) ports_out(%iin : !fifo.input_port<i32>)
  cal.create_instance @sink "k" () ports_in(%iout : !fifo.output_port<i32>)
}

// CHECK: func.func @main() -> i32
// CHECK: return {{.*}} : i32
