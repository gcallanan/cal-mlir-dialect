// Verify the fifo.create, fifo.push and fifo.pop operations report the correct
// values when executed in LLVM.
// RUN: cal-opt --lower-cal-to-llvm %s | \
// RUN: cal-translate --mlir-to-llvmir | \
// RUN: lli | FileCheck %s
module {
  func.func @main() -> i32 {
    %c0 = arith.constant 0 : i32
    %c1 = arith.constant 1 : i32
    %c2 = arith.constant 2 : i32
    %c3 = arith.constant 3 : i32
    %c4 = arith.constant 4 : i32
    %c5 = arith.constant 5 : i32
    %c6 = arith.constant 6 : i32
    %c7 = arith.constant 7 : i32
    %c8 = arith.constant 8 : i32
    %c9 = arith.constant 9 : i32
    %c10 = arith.constant 10 : i32

    %in0,%out0 = fifo.create<i32>(5) : !fifo.input_port<i32>, !fifo.output_port<i32>
    %in1,%out1 = fifo.create<i32>(7) : !fifo.input_port<i32>, !fifo.output_port<i32>
    fifo.push(%in0: !fifo.input_port<i32>, %c1: i32)
    fifo.push(%in0: !fifo.input_port<i32>, %c2: i32)
    fifo.push(%in0: !fifo.input_port<i32>, %c3: i32)
    fifo.push(%in0: !fifo.input_port<i32>, %c4: i32)
    fifo.push(%in0: !fifo.input_port<i32>, %c5: i32)
    fifo.push(%in1: !fifo.input_port<i32>, %c5: i32)
    fifo.push(%in1: !fifo.input_port<i32>, %c1: i32)
    fifo.push(%in1: !fifo.input_port<i32>, %c2: i32)
    fifo.push(%in1: !fifo.input_port<i32>, %c3: i32)
    fifo.push(%in1: !fifo.input_port<i32>, %c4: i32)
    %0 = fifo.pop(%out0: !fifo.output_port<i32>) : i32
    %1 = fifo.pop(%out0: !fifo.output_port<i32>) : i32
    %2 = fifo.pop(%out0: !fifo.output_port<i32>) : i32
    %3 = fifo.pop(%out0: !fifo.output_port<i32>) : i32
    %4 = fifo.pop(%out0: !fifo.output_port<i32>) : i32
    %q2_0 = fifo.pop(%out1: !fifo.output_port<i32>) : i32
    %q2_1 = fifo.pop(%out1: !fifo.output_port<i32>) : i32
    %q2_2 = fifo.pop(%out1: !fifo.output_port<i32>) : i32
    %q2_3 = fifo.pop(%out1: !fifo.output_port<i32>) : i32
    %q2_4 = fifo.pop(%out1: !fifo.output_port<i32>) : i32
    fifo.push(%in0: !fifo.input_port<i32>, %c6: i32)
    fifo.push(%in0: !fifo.input_port<i32>, %c7: i32)
    fifo.push(%in0: !fifo.input_port<i32>, %c8: i32)
    fifo.push(%in1: !fifo.input_port<i32>, %c8: i32)
    fifo.push(%in1: !fifo.input_port<i32>, %c6: i32)
    fifo.push(%in1: !fifo.input_port<i32>, %c7: i32)
    %5 = fifo.pop(%out0: !fifo.output_port<i32>) : i32
    %q2_5 = fifo.pop(%out1: !fifo.output_port<i32>) : i32
    fifo.push(%in0: !fifo.input_port<i32>, %c9: i32)
    fifo.push(%in1: !fifo.input_port<i32>, %c9: i32)
    %6 = fifo.pop(%out0: !fifo.output_port<i32>) : i32
    %q2_6 = fifo.pop(%out1: !fifo.output_port<i32>) : i32
    fifo.push(%in0: !fifo.input_port<i32>, %c10: i32)
    fifo.push(%in1: !fifo.input_port<i32>, %c10: i32)
    %7 = fifo.pop(%out0: !fifo.output_port<i32>) : i32
    %8 = fifo.pop(%out0: !fifo.output_port<i32>) : i32
    %9 = fifo.pop(%out0: !fifo.output_port<i32>) : i32
    %q2_7 = fifo.pop(%out1: !fifo.output_port<i32>) : i32
    %q2_8 = fifo.pop(%out1: !fifo.output_port<i32>) : i32
    %q2_9 = fifo.pop(%out1: !fifo.output_port<i32>) : i32
    fifo.push(%in0: !fifo.input_port<i32>, %c2: i32)
    fifo.push(%in0: !fifo.input_port<i32>, %c4: i32)
    fifo.push(%in1: !fifo.input_port<i32>, %c4: i32)
    fifo.push(%in1: !fifo.input_port<i32>, %c2: i32)
    %10 = fifo.pop(%out0: !fifo.output_port<i32>) : i32
    %q2_10 = fifo.pop(%out1: !fifo.output_port<i32>) : i32
    

    fifo.print("Values 0.1: %d %d %d %d %d\0A\00", %0, %1, %2, %3, %4) : (i32, i32 ,i32, i32, i32)
    fifo.print("Values 1.1: %d %d %d %d %d\0A\00", %q2_0, %q2_1, %q2_2, %q2_3, %q2_4) : (i32, i32 ,i32, i32, i32)
    // CHECK: Values 0.1: 1 2 3 4 5
    // CHECK: Values 1.1: 5 1 2 3 4
    fifo.print("Values 0.2: %d %d %d %d %d\0A\00", %5, %6, %7, %8, %9) : (i32, i32 ,i32, i32, i32)
    fifo.print("Values 1.2: %d %d %d %d %d\0A\00", %q2_5, %q2_6, %q2_7, %q2_8, %q2_9) : (i32, i32 ,i32, i32, i32)
    // CHECK: Values 0.2: 6 7 8 9 10
    // CHECK: Values 1.2: 8 6 7 9 10
    fifo.print("Values 0.3: %d\0A\00", %10) : (i32)
    fifo.print("Values 1.3: %d\0A\00", %q2_10) : (i32)
    // CHECK: Values 0.3: 2
    // CHECK: Values 1.3: 4

    func.return %c0 : i32
  }
}