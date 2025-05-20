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

    %in0,%out0 = fifo.create<i32>(10) : !fifo.input_port<i32>, !fifo.output_port<i32>
    fifo.push(%in0: !fifo.input_port<i32>, %constant672: i32)
    %0 = fifo.pop(%out0: !fifo.output_port<i32>) : i32

    %newResult = arith.addi %constant17, %0: i32

    fifo.print("Result: %d\0A\00", %newResult) : (i32)
    // CHECK: Result: 689

    func.return %constant0 : i32
  }
}