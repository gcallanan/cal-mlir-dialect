module {
  cal.actor @A() {
    cal.fsm {
      cal.state @S0 {
        cal.transition action("do") -> @S1
      }
      cal.state @S1 {
        cal.transition action("do") -> @S0
      }
    } { live_states = [@S0, @S1] }
    cal.action "do" {
    }
  }
}
