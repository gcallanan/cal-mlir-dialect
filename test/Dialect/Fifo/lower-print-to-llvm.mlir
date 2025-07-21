// RUN: cal-opt --lower-cal-to-llvm %s | \
// RUN: cal-translate --mlir-to-llvmir | \
// RUN: lli | FileCheck %s

func.func @main() -> i32 {
    %constant0 = arith.constant 0 : i32
    %c234 = arith.constant 234 : i32
    %c694 = arith.constant 698 : i32
    %c53p54 = arith.constant 53.54 : f64
    %c63p56 = arith.constant 63.56 : f32

    fifo.print("A simple print!\0A\00")
    //CHECK: A simple print!

    fifo.print("Value: %d\0A\00", %c234) : (i32)
    //CHECK: Value: 234

    fifo.print("Values: %d %d\0A\00", %c234, %c694) : (i32, i32)
    //CHECK: Values: 234 698

    fifo.print("Value: %.2f\0A\00", %c53p54) : (f64)
    //CHECK: Value: 53.54

    // f32s need to be explicitly cast to f64 or else they are interpreted incorrectly
    fifo.print("Value: %.2f\0A\00", %c63p56) : (f32)
    //CHECK: Value: 63.56

    %vals = arith.constant dense<[[1.0, 2.0], [3.0, 4.0]]> : tensor<2x2xf32>
    fifo.print_tensor(%vals) : tensor<2x2xf32>
    // CHECK: 1.000000 2.000000 
    // CHECK: 3.000000 4.000000 


    func.return %constant0 : i32
}
    
    
