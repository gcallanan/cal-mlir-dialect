
#!/bin/bash

# Clone the LLVM project with the specified release tag (includes MLIR)
git clone --branch llvmorg-20.1.0 https://github.com/llvm/llvm-project.git

# Create and navigate to the build directory
mkdir llvm-project/build
cd llvm-project/build

# Optional: Enable GPU support via CUDA runner
CUDA_RUNNER=OFF
if [ "$1" == "--enable-gpu" ]; then
    CUDA_RUNNER=ON
fi

# Inform the user if GPU support is disabled
if [ "$CUDA_RUNNER" == "OFF" ]; then
   echo "GPU support is disabled. To enable it, run this script with the '--enable-gpu' flag."
fi

# Run CMake to configure the build
# Notes:
# - Enable MLIR and Clang projects.
# - Enable NVPTX and AMDGPU targets for potential GPU backend support.
# - Enable ccache if available for faster incremental builds.
# - Enable the CUDA runner (optional, based on flag).
# - Use Clang and LLD for faster compilation.
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

# Build key targets:
# - check-mlir: Builds MLIR binaries and runs tests.
# - lli: LLVM interpreter used for running JIT-compiled LLVM IR.
# - clang: Required for compiling GPU kernels via MLIR's GPU dialect.
cmake --build . --target "lli;check-mlir;clang"

# Post-build: Recommend environment variable setup to access binaries and libraries
echo ""
echo "LLVM and MLIR built successfully!"
echo ""
echo "To use the built tools, add the following to your shell config:"
echo ""
echo "export PATH=\$PATH:$(pwd)/llvm-project/build/bin"
echo "export LD_LIBRARY_PATH=\$LD_LIBRARY_PATH:$(pwd)/llvm-project/build/lib"
echo ""
echo "Note: Replace '$(pwd)' with the actual path if hardcoding."