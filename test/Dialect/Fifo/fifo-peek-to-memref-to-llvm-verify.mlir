// RUN: cal-opt --lower-cal-to-llvm %s | cal-translate --mlir-to-llvmir | lli | FileCheck %s

func.func @main() -> i32 {
    %c0 = arith.constant 0 : i32
    %c234 = arith.constant 234 : i32
    %c694 = arith.constant 698 : i32
    %c773 = arith.constant 773 : i32
    %c843 = arith.constant 843 : i32
    %c912 = arith.constant 912 : i32
    %c943 = arith.constant 943 : i32
    %c999 = arith.constant 999 : i32
    %i0 = arith.constant 0 : index
    %i1 = arith.constant 1 : index
    %i2 = arith.constant 2 : index
    %i3 = arith.constant 3 : index
    %i4 = arith.constant 4 : index
    

    // Check the expected syntax of the fifo.push and fifo.pull commands.
    %in0,%out0 = fifo.create<i32>(5) : !fifo.input_port<i32>, !fifo.output_port<i32>
    fifo.push(%in0: !fifo.input_port<i32>, %c234: i32)
    fifo.push(%in0: !fifo.input_port<i32>, %c694: i32)
    fifo.push(%in0: !fifo.input_port<i32>, %c773: i32)
    fifo.push(%in0: !fifo.input_port<i32>, %c843: i32)
    %0 = fifo.peek(%out0: !fifo.output_port<i32>, %i0: index) : i32
    %1 = fifo.peek(%out0: !fifo.output_port<i32>, %i1: index) : i32
    %2 = fifo.peek(%out0: !fifo.output_port<i32>, %i2: index) : i32
    %3 = fifo.peek(%out0: !fifo.output_port<i32>, %i3: index) : i32
    
    fifo.print("Values: %d %d %d %d\0A\00", %0, %1, %2, %3) : (i32, i32, i32, i32)
    //CHECK: Values: 234 698 773 843

    fifo.push(%in0: !fifo.input_port<i32>, %c943: i32)
    %4 = fifo.pop(%out0: !fifo.output_port<i32>) : i32
    fifo.push(%in0: !fifo.input_port<i32>, %c999: i32)
    %5 = fifo.peek(%out0: !fifo.output_port<i32>, %i3: index) : i32
    %6 = fifo.peek(%out0: !fifo.output_port<i32>, %i4: index) : i32
    fifo.print("Values: %d %d\0A\00", %5, %6) : (i32, i32)
    // CHECK: Values: 943 999


    func.return %c0 : i32
}
    