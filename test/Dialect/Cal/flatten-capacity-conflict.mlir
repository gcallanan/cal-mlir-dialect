// RUN: cal-opt --flatten-cal-networks -split-input-file %s -verify-diagnostics

// -----
// Simple capacity conflict on the same logical channel (two connects with differing capacity)
cal.actor @A()
  ports_out(%o: !fifo.input_port<i32>) { }
cal.actor @B()
  ports_in(%i: !fifo.output_port<i32>) { }
cal.network @N() {
  %in, %out = fifo.create<i32>(1) : !fifo.input_port<i32>, !fifo.output_port<i32>
  %ha = cal.instantiate @A : !cal.instance<@A>
  %hb = cal.instantiate @B : !cal.instance<@B>
  // expected-remark @+1 {{first capacity specified here}}
  cal.connect %ha : !cal.instance<@A> "out" -> %hb : !cal.instance<@B> "in" capacity(4)
  // expected-error@+1 {{conflicting capacity for channel: existing=4, new=8}}
  cal.connect %ha : !cal.instance<@A> "out" -> %hb : !cal.instance<@B> "in" capacity(8)
}

// -----
// Capacity on network-to-plan connect is ignored (remark)
cal.actor @C()
  ports_in(%i: !fifo.output_port<i32>) { }
cal.network @N2(%p: i32)
  ports_in(%pi: !fifo.output_port<i32>) {
  %h = cal.instantiate @C : !cal.instance<@C>
  // expected-remark@+1 {{capacity on network-port connect is ignored; specify capacity where FIFO is materialized}}
  cal.connect %pi : !fifo.output_port<i32> "out" -> %h : !cal.instance<@C> "in" capacity(5)
}
