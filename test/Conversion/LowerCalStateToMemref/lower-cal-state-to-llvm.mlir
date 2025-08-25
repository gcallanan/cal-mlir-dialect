//RUN: cal-opt --lower-cal-to-llvm %s | \
//RUN: mlir-runner --entry-point-result=i32 | \
//RUN: FileCheck %s
module {
  func.func @main() -> i32 {
    %constant0 = arith.constant 0 : i32
    %constant672 = arith.constant 672 : i32
    %constant17 = arith.constant 17 : i32

    %ref0 = cal.create_state_var<i32> : !cal.state_ref<i32>
    cal.set(%ref0 : !cal.state_ref<i32>, %constant672 : i32)
    %val0 = cal.get(%ref0 : !cal.state_ref<i32>) : i32
    cal.set(%ref0 : !cal.state_ref<i32>, %constant17 : i32)
    %val1 = cal.get(%ref0 : !cal.state_ref<i32>) : i32

    fifo.print("Result: %d\0A\00", %val0) : (i32)
    // CHECK: Result: 672
    fifo.print("Result: %d\0A\00", %val1) : (i32)
    // CHECK: Result: 17

    func.return %constant0 : i32
  }
}