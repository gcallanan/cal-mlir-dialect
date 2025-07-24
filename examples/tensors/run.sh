#!/bin/bash
# Build and run the tensors.mlir file

PATH="../../llvm-project/build/bin:$PATH"
PATH="$PATH:../../build/bin"

GPU=false
while getopts g flag
do
    case "${flag}" in
        g) GPU=true;;
    esac
done

if [ "$GPU" = false ]; then
    cal-opt --lower-cal-to-llvm tensors.mlir | cal-translate --mlir-to-llvmir | lli
else
    cal-opt tensors.mlir --lower-cal-to-llvm-with-gpu-tensors | cal-translate --mlir-to-llvmir > main.ll
    clang++  main.ll -o tensors_gpu_executable  -lmlir_cuda_runtime -L../../llvm-project/build/lib
    rm main.ll
    ./tensors_gpu_executable
fi
