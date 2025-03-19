// RUN: mlir-opt %s --load-dialect-plugin=%cal_libs/CalPlugin%shlibext --pass-pipeline="builtin.module(cal-switch-bar-foo)" | FileCheck %s

module {
  // CHECK-LABEL: func @foo()
  func.func @bar() {
    return
  }

  // CHECK-LABEL: func @cal_types(%arg0: !cal.custom<"10">)
  func.func @cal_types(%arg0: !cal.custom<"10">) {
    return
  }
}
