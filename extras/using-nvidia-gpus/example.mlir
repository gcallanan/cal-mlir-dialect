module attributes {gpu.container_module} {
    // These are just used for host side printf, dont really affect how the GPU operates
    llvm.mlir.global internal constant @fmt_string_0("Hello from host thread. Value at index %d: %d \0A") {addr_space = 0 : i32}
    llvm.func @printf(!llvm.ptr, ...) -> i32

    // This module contains the GPU kernel that will be executed on the device
    // This kernel does not do anything useful. It just loads a value from the device
    // array, prints it, increments it by 10 and then stores it back to the device array.
    // This is just to give an example of a basic kernel to build upon
    gpu.module @kernels {
        gpu.func @hello(%arg0: i32, %arg1: memref<15xi32>) kernel {
            %x = gpu.thread_id x
            %val = memref.load %arg1[%x] : memref<15xi32>
            gpu.printf "Hello from gpu %lld, argument val: %d, array_val: %d\n", %x, %arg0, %val : index, i32, i32

            // Increment the value in the array by 10
            %c10_i32 = arith.constant 10 : i32
            %sum = arith.addi %val, %c10_i32 : i32
            memref.store %sum, %arg1[%x] : memref<15xi32>
            gpu.return
        }
    }

    // Host code that will execute on the CPU and initiate the launch of the GPU
    // kernel
    func.func @main() {
        %c3 = arith.constant 676 : i32
        %c2 = arith.constant 3 : index
        %c1 = arith.constant 1 : index
        %c0 = arith.constant 0 : index

        // 1. Create a host array and fill it with values
        %data_host = memref.alloc() : memref<15xi32>
        scf.for %arg1 = %c0 to %c2 step %c1 {
            %index = arith.index_cast %arg1 : index to i32
            memref.store %index, %data_host[%arg1] : memref<15xi32>
        }

        // 2. Create a device array and copy the host array to the device
        %token = gpu.wait async
        %data_device, %t0 = gpu.alloc async [%token] () : memref<15xi32>
        %t1 = gpu.memcpy async [%t0] %data_device, %data_host : memref<15xi32>, memref<15xi32>

        // 3. Launch the kernel on the device. Launch twice to check that it updates the value
        %t2 = gpu.launch_func async [%t1] @kernels::@hello
            blocks in (%c1, %c1, %c1)
            threads in (%c2, %c1, %c1)
            args (%c3: i32, %data_device: memref<15xi32>)

        %t3 = gpu.launch_func async [%t2] @kernels::@hello
            blocks in (%c1, %c1, %c1)
            threads in (%c2, %c1, %c1)
            args (%c3: i32, %data_device: memref<15xi32>)

        // 4. Copy the device array back to the host
        %t4 = gpu.memcpy async [%t3] %data_host, %data_device : memref<15xi32>, memref<15xi32>

        // 5. Print the values in the host array to check if they were updated
        scf.for %arg1 = %c0 to %c2 step %c1 {
            %index_i32 = arith.index_cast %arg1 : index to i32
            %val = memref.load %data_host[%arg1] : memref<15xi32>

            // LLVM printf call
            %0 = llvm.mlir.addressof @fmt_string_0 : !llvm.ptr
            %1 = llvm.mlir.constant(0 : index) : i64
            %2 = llvm.getelementptr %0[%1, %1] : (!llvm.ptr, i64, i64) -> !llvm.ptr, !llvm.array<47 x i8>
            %3 = llvm.call @printf(%2, %index_i32, %val) vararg(!llvm.func<i32 (ptr, ...)>) : (!llvm.ptr, i32, i32) -> i32

        }

        return
    }
}
