// RUN: mlir-opt %s --load-pass-plugin=%cal_libs/CalPlugin%shlibext --pass-pipeline="builtin.module(cal-switch-bar-foo)" | FileCheck %s

module {
  // CHECK-LABEL: func @foo()
  func.func @bar() {
    return
  }

  // CHECK-LABEL: func @abar()
  func.func @abar() {
    return
  }
}
