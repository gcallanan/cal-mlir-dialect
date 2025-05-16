// Currently this is not a very useful test. This is because cal.network
// has not defined in a useful way yet. This is an outstanding TODO.
// RUN: cal-opt %s | FileCheck %s

cal.network {
}

// CHECK: cal.network {
// CHECK: }