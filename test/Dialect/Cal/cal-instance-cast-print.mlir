// RUN: cal-opt %s | FileCheck %s

// Check printing/parsing of cal.instance.cast

cal.interface @IFace

cal.actor @Actor() {
}

cal.network @Net() {
  %h = cal.instantiate @Actor : !cal.instance<@Actor>
  %i = cal.instance.cast %h : !cal.instance<@Actor> -> !cal.instance.iface<@IFace>
}

// CHECK-LABEL: cal.network @Net()
// CHECK: cal.instantiate @Actor
// CHECK: cal.instance.cast %
