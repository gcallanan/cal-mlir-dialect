// By running lli, this test compiles the MLIR code to LLVM IR and then runs it
// using the LLVM interpreter. This allows the output of the program to be
// checked against the expected output.
//RUN: cal-opt --lower-cal-to-llvm %s | \
//RUN: cal-translate --mlir-to-llvmir | \
//RUN: lli | FileCheck %s
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
    // CHECK: Result: 171

    func.return %constant0 : i32
  }
}