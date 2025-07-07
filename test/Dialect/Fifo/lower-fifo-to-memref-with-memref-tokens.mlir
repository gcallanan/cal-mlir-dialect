// Tests if the FIFO lowering pass correctly lowers to fifo.create, fifo.push
// and fifo.pop operations to the memref dialect.

// RUN: cal-opt --lower-fifo-to-memref %s | FileCheck %s

func.func @temp1() {
    %in0,%out0 = fifo.create<memref<2x2xi32>>(10) : !fifo.input_port<memref<2x2xi32>>, !fifo.output_port<memref<2x2xi32>>
    // CHECK: %alloc = memref.alloc() : memref<11x2x2xi32>

    %0 = fifo.pop(%out0: !fifo.output_port<memref<2x2xi32>>) : memref<2x2xi32>
    // CHECK: %1 = fifo.get_tuple_element %0[0] : tuple<memref<11x2x2xi32>, memref<2xi32>, i32> -> memref<11x2x2xi32>
    // CHECK: %subview = memref.subview %1[%5, 0, 0] [1, 2, 2] [1, 1, 1] : memref<11x2x2xi32> to memref<1x2x2xi32, strided<[4, 2, 1], offset: ?>>
    // CHECK: %collapse_shape = memref.collapse_shape %subview {{\[}}[0, 1], [2]{{\]}} : memref<1x2x2xi32, strided<[4, 2, 1], offset: ?>> into memref<2x2xi32, strided<[2, 1], offset: ?>>


    fifo.push(%in0: !fifo.input_port<memref<2x2xi32>>, %0: memref<2x2xi32>)
    // CHECK: %subview_3 = memref.subview %8[%12, 0, 0] [1, 2, 2] [1, 1, 1] : memref<11x2x2xi32> to memref<1x2x2xi32, strided<[4, 2, 1], offset: ?>>
    // CHECK: %collapse_shape_4 = memref.collapse_shape %subview_3 {{\[}}[0, 1], [2]{{\]}} : memref<1x2x2xi32, strided<[4, 2, 1], offset: ?>> into memref<2x2xi32, strided<[2, 1], offset: ?>>
    // CHECK: memref.copy %collapse_shape, %collapse_shape_4 : memref<2x2xi32, strided<[2, 1], offset: ?>> to memref<2x2xi32, strided<[2, 1], offset: ?>>



    return
}

// CHECK: func.func @my_func(%arg0: tuple<memref<?x2x2xi32>, memref<2xi32>, i32>, %arg1: tuple<memref<?x2x2xi32>, memref<2xi32>, i32>)
func.func @my_func (%c5: !fifo.input_port<memref<2x2xi32>>, %c6: !fifo.output_port<memref<2x2xi32>>){
    return
}

func.func @temp2() { 
    %in1,%out1 = fifo.create<memref<2x2xi32>>(10) : !fifo.input_port<memref<2x2xi32>>, !fifo.output_port<memref<2x2xi32>>
    // CHECK: %cast = memref.cast %1 : memref<11x2x2xi32> to memref<?x2x2xi32>
    // CHECK: %4 = fifo.make_tuple(%cast, %2, %3) : memref<?x2x2xi32>, memref<2xi32>, i32 -> tuple<memref<?x2x2xi32>, memref<2xi32>, i32>
    // CHECK: call @my_func(%4, %4) : (tuple<memref<?x2x2xi32>, memref<2xi32>, i32>, tuple<memref<?x2x2xi32>, memref<2xi32>, i32>) -> ()
    func.call @my_func(%in1, %out1) : (!fifo.input_port<memref<2x2xi32>>, !fifo.output_port<memref<2x2xi32>>) -> ()
    return
}