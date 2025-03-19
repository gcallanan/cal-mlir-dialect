# maybe this release: https://github.com/llvm/llvm-project/releases/tag/llvmorg-20.1.1

git clone --branch llvmorg-20.1.0 https://github.com/llvm/llvm-project.git

mkdir llvm-project/build
cd llvm-project/build

cmake -G Ninja ../llvm \
   -DLLVM_ENABLE_PROJECTS=mlir \
   -DLLVM_BUILD_EXAMPLES=ON \
   -DLLVM_TARGETS_TO_BUILD="Native" \
   -DCMAKE_BUILD_TYPE=Release \
   -DLLVM_ENABLE_ASSERTIONS=ON \
   -DCMAKE_C_COMPILER=clang -DCMAKE_CXX_COMPILER=clang++ -DLLVM_ENABLE_LLD=ON \
   -DLLVM_CCACHE_BUILD=ON \
   -DLLVM_INSTALL_UTILS=ON

cmake --build . --target check-mlir