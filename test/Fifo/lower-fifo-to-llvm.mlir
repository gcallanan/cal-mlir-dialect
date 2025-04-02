// By running lli, this test compiles the MLIR code to LLVM IR and then runs it
// using the LLVM interpreter. This allows the output of the program to be
// checked against the expected output.
//RUN: cal-opt --lower-cal-to-llvm %s | \
//RUN: cal-translate --mlir-to-llvmir | \
//RUN: lli | FileCheck %s
module {
  llvm.func @printf(!llvm.ptr, ...) -> i32
  llvm.mlir.global internal constant @str0("Result: %d\0A\00")

  func.func @main() -> i32 {
    %constant0 = arith.constant 0 : i32
    %constant672 = arith.constant 672 : i32
    %constant17 = arith.constant 17 : i32

    %in0,%out0 = fifo.create<i32>(10) : !fifo.input_port<i32>, !fifo.output_port<i32>
    fifo.push(%in0: !fifo.input_port<i32>, %constant672: i32)
    %0 = fifo.pull(%out0: !fifo.output_port<i32>) : i32

    %newResult = arith.addi %constant17, %0: i32

    %strPtr = llvm.mlir.addressof @str0 : !llvm.ptr
    %21 = llvm.call @printf(%strPtr, %newResult) vararg(!llvm.func<i32 (ptr, ...)>): (!llvm.ptr, i32) -> i32
    // CHECK: Result: 689

    func.return %constant0 : i32
  }
}