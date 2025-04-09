git clone --branch llvmorg-20.1.0 https://github.com/llvm/llvm-project.git

mkdir llvm-project/build
cd llvm-project/build

CUDA_RUNNER=OFF
if [ "$1" == "--enable-gpu" ]; then
    CUDA_RUNNER=ON
fi
if [ "$CUDA_RUNNER" == "OFF" ]; then
   echo "Optional GPU support is not enabled. If you want to enable it, run the script with the '--enable-gpu' flag."
fi

# We include NVPTX and AMDGPU targets because we hope to compile to GPUs
# one day in the future
# -DLLVM_CCACHE_BUILD=ON should speed up future compiles, you can leave it out
#     if you don't have ccache installed
# -DMLIR_ENABLE_CUDA_RUNNER=ON builds the cuda_runner library which is needed
#     for executing GPU programs
# -DCMAKE_C_COMPILER=clang -DCMAKE_CXX_COMPILER=clang++ -DLLVM_ENABLE_LLD=ON
#     are suggested flags for speeding up the builds
cmake -G Ninja ../llvm \
   -DLLVM_ENABLE_PROJECTS="mlir;clang" \
   -DLLVM_BUILD_EXAMPLES=ON \
   -DLLVM_TARGETS_TO_BUILD="Native;NVPTX;AMDGPU" \
   -DCMAKE_BUILD_TYPE=Release \
   -DLLVM_ENABLE_ASSERTIONS=ON \
   -DCMAKE_C_COMPILER=clang -DCMAKE_CXX_COMPILER=clang++ -DLLVM_ENABLE_LLD=ON \
   -DLLVM_CCACHE_BUILD=ON \
   -DLLVM_INSTALL_UTILS=ON \
   -DLLVM_BUILD_TOOLS=ON \
   -DMLIR_ENABLE_CUDA_RUNNER=${CUDA_RUNNER}

# We build the following targets:
#   - check-mlir: This results in all MLIR binaries being build and runs the 
#                 tests.
#   - lli: LLVM interpreter - we use this in some of our tests to ensure that
#          the MLIR can be transformed to LLVMIR and produces correct results.
#   - clang: The clang compiler is used for building and compiling some GPU
#            kernels created using the GPU dialect
cmake --build . --target "lli;check-mlir;clang"

# # We need to update the path and LD_LIBRARY_PATH to include the newly built libraries
echo "LLVM and MLIR built successfully"
echo ""
echo "Add binaries to your PATH with:"
echo "export PATH=\$PATH:$(pwd)/llvm-project/build/bin"
echo ""
echo "Add the library files to your LD_LIBRARY_PATH with:"
echo "export LD_LIBRARY_PATH=\$LD_LIBRARY_PATH:$(pwd)/llvm-project/build/lib"