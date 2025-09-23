// RUN: not cal-opt --flatten-cal-networks %s 2>&1 | FileCheck %s

// Intentional cycle: A -> B -> C -> A
// CHECK: cycle detected in cal.network hierarchy

cal.network @A(){
  cal.create_instance @B ()
}

cal.network @B(){
  cal.create_instance @C ()
}

cal.network @C(){
  cal.create_instance @A ()
}
