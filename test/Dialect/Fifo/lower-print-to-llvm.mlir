// RUN: cal-opt --lower-cal-to-llvm %s | \
// RUN: mlir-runner --entry-point-result=i32 | \
// RUN: FileCheck %s

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

    %row = arith.constant dense<[[5.0, 6.0, 7.0, 8.0]]> : tensor<1x4xf32>
    %col = arith.constant dense<[[9.0], [10.0], [11.0], [12.0]]> : tensor<4x1xf32>
    fifo.print("Row\n")
    fifo.print_tensor(%row) : tensor<1x4xf32>
    fifo.print("Column\n")
    fifo.print_tensor(%col) : tensor<4x1xf32>
    // CHECK: Row
    // CHECK: 5.000000 6.000000 7.000000 8.000000 
    // CHECK: Column
    // CHECK: 9.000000 
    // CHECK: 10.000000 
    // CHECK: 11.000000 
    // CHECK: 12.000000 

    %vals3d = arith.constant dense<[
      [[1.0, 2.0, 3.0], [4.0, 5.0, 6.0], [7.0, 8.0, 9.0]],
      [[10.0, 11.0, 12.0], [13.0, 14.0, 15.0], [16.0, 17.0, 18.0]],
      [[19.0, 20.0, 21.0], [22.0, 23.0, 24.0], [25.0, 26.0, 27.0]]
    ]> : tensor<3x3x3xf32>
    fifo.print("3x3x3 matrix:\n")
    fifo.print_tensor(%vals3d) : tensor<3x3x3xf32>
    // CHECK: 3x3x3 matrix:
    // CHECK: At index [0][][]:
    // CHECK: 1.000000 2.000000 3.000000 
    // CHECK: 4.000000 5.000000 6.000000 
    // CHECK: 7.000000 8.000000 9.000000 
    // CHECK: At index [1][][]:
    // CHECK: 10.000000 11.000000 12.000000 
    // CHECK: 13.000000 14.000000 15.000000 
    // CHECK: 16.000000 17.000000 18.000000 
    // CHECK: At index [2][][]:
    // CHECK: 19.000000 20.000000 21.000000 
    // CHECK: 22.000000 23.000000 24.000000 
    // CHECK: 25.000000 26.000000 27.000000 


    func.return %constant0 : i32
}
    
    
