// RUN: cal-opt %s --gpu-aware-bufferize | FileCheck %s

module {
  func.func @main() -> tensor<2x2xf32> {
    %c1 = arith.constant 1.0 : f32
    %c2 = arith.constant 2.0 : f32

    // Allocate two 2x2 tensors and fill them
    %tA = tensor.empty() : tensor<2x2xf32>
    %tB = tensor.empty() : tensor<2x2xf32>
    // CHECK: %memref = gpu.alloc  host_shared () : memref<2x2xf32>
    // CHECK: %memref_1 = gpu.alloc  host_shared () : memref<2x2xf32>
    
    %A = linalg.fill ins(%c1 : f32) outs(%tA : tensor<2x2xf32>) -> tensor<2x2xf32>
    %B = linalg.fill ins(%c2 : f32) outs(%tB : tensor<2x2xf32>) -> tensor<2x2xf32>
    // CHECK: linalg.fill ins(%cst : f32) outs(%memref : memref<2x2xf32>)
    // CHECK: linalg.fill ins(%cst_0 : f32) outs(%memref_1 : memref<2x2xf32>)

    // Add the tensors together
    %C = linalg.add ins(%A, %B : tensor<2x2xf32>, tensor<2x2xf32>) 
               outs(%tA : tensor<2x2xf32>) -> tensor<2x2xf32>
    // CHECK: linalg.add ins(%memref, %memref_1 : memref<2x2xf32>, memref<2x2xf32>) outs(%memref : memref<2x2xf32>)
    // CHECK: %cast = memref.cast %memref : memref<2x2xf32> to memref<2x2xf32, strided<[?, ?], offset: ?>>

    return %C : tensor<2x2xf32>
  }
}