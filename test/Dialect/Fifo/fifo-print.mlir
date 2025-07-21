//RUN: cal-opt %s | FileCheck %s

// cal-opt fifo-print.mlir --lower-cal-to-llvm | cal-translate --mlir-to-llvmir | /home/gareth/software-repos/mlir-cal/cal-mlir-dialect/llvm-project/build/bin/lli

func.func @main() -> i32 {
    %constant0 = arith.constant 0 : i32
    %c234 = arith.constant 234 : i32
    %c694 = arith.constant 698 : i32

    fifo.print("A simple print!\0A\00")
    //CHECK: fifo.print("A simple print!\0A\00")

    fifo.print("Value: %d\0A\00", %c234) : (i32)
    //CHECK: fifo.print("Value: %d\0A\00", %c234_i32) : (i32)

    fifo.print("Values: %d %d\0A\00", %c234, %c694) : (i32, i32)
    //CHECK: fifo.print("Values: %d %d\0A\00", %c234_i32, %c698_i32) : (i32, i32)

    %vals = arith.constant dense<[[1.0, 2.0], [3.0, 4.0]]> : tensor<2x2xf32>
    fifo.print_tensor(%vals) : tensor<2x2xf32>
    // CHECK: %cst = arith.constant dense<
    // CHECK: fifo.print_tensor(%cst) : tensor<2x2xf32>

    func.return %constant0 : i32
}
    
    
