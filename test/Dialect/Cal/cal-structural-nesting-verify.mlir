// RUN: cal-opt -verify-diagnostics %s

// Define a minimal actor symbol to satisfy instantiate_array typing and symbol checks.
cal.actor @A() {
  cal.execution_body {
    %false = arith.constant 0 : i1
    cal.action_done %false : i1
  }
}

// 1) Negative: structural op outside any cal.network must diagnose.
func.func @bad_use() {
  // expected-error@+1 {{'cal.instantiate_array' must be nested within a cal.network (ancestor), potentially under scf.if/scf.for}}
  %arr = cal.instantiate_array @A count(2) : <@A, [2]>
  func.return
}

// 2) Positive: structural ops nested under scf.if within a cal.network are allowed.
cal.network @ok_nesting() {
  %t = arith.constant true
  scf.if %t {
  %arr = cal.instantiate_array @A count(2) : <@A, [2]>
    // Also allow extracting an element via instance_at under the same nest.
    %c0 = arith.constant 0 : index
  %h0 = cal.instance_at %arr[%c0] : !cal.instance.array<@A, [2]> -> !cal.instance<@A>
  } else {
  }
}
