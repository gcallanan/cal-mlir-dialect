// RUN: mlir-opt %s --load-dialect-plugin=%cal_libs/CalPlugin%shlibext --pass-pipeline="builtin.module(lower-cal-state-to-memref)" | FileCheck %s

module {
  // CHECK-LABEL: func.func @cal_types(%arg0: memref<1xi64>)
  func.func @cal_types(%arg0: !cal.state_ref<i64>) {
    return
  }
}
