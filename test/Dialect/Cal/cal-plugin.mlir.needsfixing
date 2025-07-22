// RUN: mlir-opt %s --load-dialect-plugin=%cal_libs/CalPlugin%shlibext --pass-pipeline="builtin.module(lower-fifo-to-memref)" | FileCheck %s

module {
  // CHECK-LABEL: func.func @cal_types(%arg0: tuple<memref<?xi64>, memref<2xi32>, i32>)
  func.func @cal_types(%arg0: !fifo.input_port<i64>) {
    return
  }
}
