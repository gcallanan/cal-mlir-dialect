// RUN: cal-opt -split-input-file %s -verify-diagnostics

//===----------------------------------------------------------------------===//
// Positive: interface decl, implements for actor and network, and instance.cast
//===----------------------------------------------------------------------===//

cal.interface @I0

cal.actor @A0() {
}

cal.network @N0() {
  %c0 = arith.constant 0 : i32
}

// Both actor and network can declare they implement the interface
cal.implements @I0 for @A0
cal.implements @I0 for @N0

// Also check parsing/printing of instance.cast using a handle created inside a
// network. No semantic verification for cast yet; this is a syntax smoke test.
cal.network @CastNet() {
  %h = cal.instantiate @A0 : !cal.instance<@A0>
  %i = cal.instance.cast %h : !cal.instance<@A0> -> !cal.instance.iface<@I0>
}

// -----

//===----------------------------------------------------------------------===//
// Negative: missing interface symbol
//===----------------------------------------------------------------------===//

cal.actor @A1() {
}

// expected-error @+1 {{interface 'I_MISSING' not found}}
cal.implements @I_MISSING for @A1

// -----

//===----------------------------------------------------------------------===//
// Negative: missing entity symbol
//===----------------------------------------------------------------------===//

cal.interface @I2

// expected-error @+1 {{entity 'E_MISSING' does not reference a cal.actor or cal.network}}
cal.implements @I2 for @E_MISSING

// -----

//===----------------------------------------------------------------------===//
// Negative: entity is not an actor or network (uses interface as entity)
//===----------------------------------------------------------------------===//

cal.interface @I3

// expected-error @+1 {{does not reference a cal.actor or cal.network}}
cal.implements @I3 for @I3
