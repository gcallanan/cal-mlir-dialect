LLVM_BUILD_DIR="$PWD/llvm-project/build"

echo "Installing CAL dialect"
echo "    Assuming that the llvm project with MLIR has been installed and built in $LLVM_BUILD_DIR"
echo ""

mkdir -p build && cd build
cmake -G Ninja .. -DMLIR_DIR=$LLVM_BUILD_DIR/lib/cmake/mlir -DLLVM_EXTERNAL_LIT=$LLVM_BUILD_DIR/bin/llvm-lit
cmake --build . --target check-cal