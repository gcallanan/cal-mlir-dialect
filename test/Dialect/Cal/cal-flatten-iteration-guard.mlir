// RUN: not cal-opt --flatten-cal-networks %s 2>&1 | FileCheck %s
// Construct a long chain of networks that ends in a small cycle X->Y->X.
// The static cycle detection should already catch this; if it failed,
// the iteration limit would eventually trigger. We accept either primary
// cycle message or iteration limit message; check for one of them.
// CHECK: cycle detected in cal.network hierarchy

cal.network @X(){
  cal.create_instance @Y ()
}
cal.network @Y(){
  cal.create_instance @X ()
}

// Long tail referencing X so that the graph is larger.
cal.network @N10(){ cal.create_instance @X () }
cal.network @N9(){ cal.create_instance @N10 () }
cal.network @N8(){ cal.create_instance @N9 () }
cal.network @N7(){ cal.create_instance @N8 () }
cal.network @N6(){ cal.create_instance @N7 () }
cal.network @N5(){ cal.create_instance @N6 () }
cal.network @N4(){ cal.create_instance @N5 () }
cal.network @N3(){ cal.create_instance @N4 () }
cal.network @N2(){ cal.create_instance @N3 () }
cal.network @N1(){ cal.create_instance @N2 () }
