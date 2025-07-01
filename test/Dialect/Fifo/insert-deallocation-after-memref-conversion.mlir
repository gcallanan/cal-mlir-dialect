// Tests if the FIFO lowering pass correctly lowers to fifo.create, fifo.push
// and fifo.pop operations to the memref dialect.

// RUN: cal-opt --lower-fifo-to-memref --decompose-fifo-tuples  --buffer-deallocation %s | FileCheck %s

func.func @temp1() {

    %in0,%out0 = fifo.create<i32>(10) : !fifo.input_port<i32>, !fifo.output_port<i32>
    %constant672 = arith.constant 672 : i32 
    fifo.push(%in0: !fifo.input_port<i32>, %constant672: i32)
    %0 = fifo.pop(%out0: !fifo.output_port<i32>) : i32
    %constant17 = arith.constant 17 : i32
    %newResult = arith.addi %constant17, %0: i32
    fifo.push(%in0: !fifo.input_port<i32>, %newResult: i32)
    return

    // CHECK: %alloc = memref.alloc() : memref<11xi32>
    // CHECK: %alloc_0 = memref.alloc() : memref<2xi32>
    // CHECK: memref.store %c0_i32, %alloc_0[%c0] : memref<2xi32>
    // CHECK: memref.store %c0_i32, %alloc_0[%c1] : memref<2xi32>
    // CHECK: memref.store %c672_i32, %alloc[%1] : memref<11xi32>
    // CHECK: memref.store %3, %alloc_0[%c1] : memref<2xi32>
    // CHECK: memref.store %8, %alloc_0[%c0] : memref<2xi32>
    // CHECK: memref.store %9, %alloc[%11] : memref<11xi32>
    // CHECK: memref.dealloc %alloc : memref<11xi32>
    // CHECK: memref.store %13, %alloc_0[%c1] : memref<2xi32>
    // CHECK: memref.dealloc %alloc_0 : memref<2xi32>

}

func.func @my_func (%c5: !fifo.input_port<i32>, %c6: !fifo.output_port<i32>){
    return
}

func.func @temp2() { 

    %in1,%out1 = fifo.create<i32>(10) : !fifo.input_port<i32>, !fifo.output_port<i32>
    func.call @my_func(%in1, %out1) : (!fifo.input_port<i32>, !fifo.output_port<i32>) -> ()
    return

    //CHECK: %c1 = arith.constant 1 : index
    //CHECK-NEXT: %c0 = arith.constant 0 : index
    //CHECK-NEXT: %c0_i32 = arith.constant 0 : i32
    //CHECK-NEXT: %c11_i32 = arith.constant 11 : i32
    //CHECK-NEXT: %alloc = memref.alloc() : memref<11xi32>
    //CHECK-NEXT: %alloc_0 = memref.alloc() : memref<2xi32>
    //CHECK-NEXT: %cast = memref.cast %alloc : memref<11xi32> to memref<?xi32>
    //CHECK-NEXT: memref.store %c0_i32, %alloc_0[%c0] : memref<2xi32>
    //CHECK-NEXT: memref.store %c0_i32, %alloc_0[%c1] : memref<2xi32>
    //CHECK-NEXT: call @my_func(%cast, %alloc_0, %c11_i32, %cast, %alloc_0, %c11_i32) : (memref<?xi32>, memref<2xi32>, i32, memref<?xi32>, memref<2xi32>, i32) -> ()
    //CHECK-NEXT: memref.dealloc %alloc_0 : memref<2xi32>
    //CHECK-NEXT: memref.dealloc %alloc : memref<11xi32>

}