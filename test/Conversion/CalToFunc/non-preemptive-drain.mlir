// RUN: cal-opt --convert-cal-to-func='non-preemptive-default' %s | FileCheck %s

// A trivial actor that always reports it executed.
cal.actor @tick() {
  cal.execution_body {
    %t = arith.constant true
    cal.action_done %t : i1
  }
}

// A network with two instances ensures the scheduler loop will consider both.
cal.network @N() {
  cal.create_instance @tick "t0" ()
  cal.create_instance @tick "t1" ()
}

// CHECK: func.func @main
// CHECK: scf.while
// CHECK: scf.while
