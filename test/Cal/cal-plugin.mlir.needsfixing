// RUN: mlir-opt %s --load-dialect-plugin=%cal_libs/CalPlugin%shlibext --pass-pipeline="builtin.module(cal-switch-bar-foo)" | FileCheck %s

module {
  // CHECK-LABEL: func @foo()
  func.func @bar() {
    return
  }

  // CHECK-LABEL: func @cal_types(%arg0: !cal.state_ref<i64>)
  func.func @cal_types(%arg0: !cal.state_ref<i64>) {
    return
  }
}
