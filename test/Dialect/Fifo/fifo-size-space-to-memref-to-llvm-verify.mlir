// Verify the fifo.size and fifo.space operations report the correct values
// when executed in LLVM.
// RUN: cal-opt --lower-cal-to-llvm %s | \
// RUN: mlir-runner --entry-point-result=i32 | \
// RUN: FileCheck %s

func.func @main() -> i32 {
    %constant0 = arith.constant 0 : i32
    %constant672 = arith.constant 672 : i32
    %constant17 = arith.constant 17 : i32

    %in0,%out0 = fifo.create<i32>(10) : !fifo.input_port<i32>, !fifo.output_port<i32>
    
    %0 = fifo.size(%out0: !fifo.output_port<i32>) : index
    %space0 = fifo.space(%in0: !fifo.input_port<i32>) : index
    
    %i32_0 = arith.index_cast %0 : index to i32
    %i32_space0 = arith.index_cast %space0 : index to i32
    fifo.print("Size: %d, Space %d\0A\00", %i32_0, %i32_space0) : (i32, i32)
    // CHECK: Size: 0, Space 10

    fifo.push(%in0: !fifo.input_port<i32>, %constant672: i32)

    %1 = fifo.size(%out0: !fifo.output_port<i32>) : index
    %space1 = fifo.space(%in0: !fifo.input_port<i32>) : index
    %i32_1 = arith.index_cast %1 : index to i32
    %i32_space1 = arith.index_cast %space1 : index to i32
    fifo.print("Size: %d, Space %d\0A\00", %i32_1, %i32_space1) : (i32, i32)
    // CHECK: Size: 1, Space 9

    fifo.push(%in0: !fifo.input_port<i32>, %constant17: i32)

    %2 = fifo.size(%out0: !fifo.output_port<i32>) : index
    %i32_2 = arith.index_cast %2 : index to i32
    %space2 = fifo.space(%in0: !fifo.input_port<i32>) : index
    %i32_space2 = arith.index_cast %space2 : index to i32
    fifo.print("Size: %d, Space %d\0A\00", %i32_2, %i32_space2) : (i32, i32)
    // CHECK: Size: 2, Space 8

    %t0 = fifo.pop(%out0: !fifo.output_port<i32>) : i32
    
    %4 = fifo.size(%out0: !fifo.output_port<i32>) : index
    %i32_4 = arith.index_cast %4 : index to i32
    %space4 = fifo.space(%in0: !fifo.input_port<i32>) : index
    %i32_space4 = arith.index_cast %space4 : index to i32
    fifo.print("Size: %d, Space %d\0A\00", %i32_4, %i32_space4) : (i32, i32)
    // CHECK: Size: 1, Space 9

    fifo.push(%in0: !fifo.input_port<i32>, %constant17: i32)
    fifo.push(%in0: !fifo.input_port<i32>, %constant17: i32)
    fifo.push(%in0: !fifo.input_port<i32>, %constant17: i32)
    fifo.push(%in0: !fifo.input_port<i32>, %constant17: i32)
    fifo.push(%in0: !fifo.input_port<i32>, %constant17: i32)

    %5 = fifo.size(%out0: !fifo.output_port<i32>) : index
    %i32_5 = arith.index_cast %5 : index to i32
    %space5 = fifo.space(%in0: !fifo.input_port<i32>) : index
    %i32_space5 = arith.index_cast %space5 : index to i32
    fifo.print("Size: %d, Space %d\0A\00", %i32_5, %i32_space5) : (i32, i32)
    // CHECK: Size: 6, Space 4

    %t1 = fifo.pop(%out0: !fifo.output_port<i32>) : i32
    %t2 = fifo.pop(%out0: !fifo.output_port<i32>) : i32
    %t3 = fifo.pop(%out0: !fifo.output_port<i32>) : i32
    fifo.push(%in0: !fifo.input_port<i32>, %constant17: i32)
    fifo.push(%in0: !fifo.input_port<i32>, %constant17: i32)
    fifo.push(%in0: !fifo.input_port<i32>, %constant17: i32)
    fifo.push(%in0: !fifo.input_port<i32>, %constant17: i32)
    fifo.push(%in0: !fifo.input_port<i32>, %constant17: i32)

    %6 = fifo.size(%out0: !fifo.output_port<i32>) : index
    %i32_6 = arith.index_cast %6 : index to i32
    %space6 = fifo.space(%in0: !fifo.input_port<i32>) : index
    %i32_space6 = arith.index_cast %space6 : index to i32
    fifo.print("Size: %d, Space %d\0A\00", %i32_6, %i32_space6) : (i32, i32)
    // CHECK: Size: 8, Space 2

    func.return %constant0 : i32
}