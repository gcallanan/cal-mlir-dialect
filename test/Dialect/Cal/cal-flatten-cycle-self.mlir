// RUN: not cal-opt --flatten-cal-networks %s 2>&1 | FileCheck %s
// CHECK: cycle detected in cal.network hierarchy

cal.network @Self(){
  cal.create_instance @Self ()
}
