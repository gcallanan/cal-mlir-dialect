#!/bin/bash

# This script builds and runs an MLIR example using NVIDIA GPUs.
# It performs the following steps:
# 1. Applies a series of MLIR passes to optimize and convert the input MLIR file.
# 2. Translates the resulting MLIR file to LLVM IR.
# 3. Compiles the LLVM IR to a binary executable using Clang++.
# 4. Executes the resulting binary.

mlir-opt example.mlir                   \
  --pass-pipeline="builtin.module(      \
    gpu-kernel-outlining,               \
    nvvm-attach-target{chip=sm_75 O=3}, \
    gpu.module(convert-gpu-to-nvvm),    \
    gpu-to-llvm,                        \
    gpu-module-to-binary                \
  )" -o example-nvvm.mlir


mlir-translate example-nvvm.mlir        \
  --mlir-to-llvmir                      \
  -o example.ll

clang++  example.ll -o example  -lmlir_cuda_runtime -L../../llvm-project/build/lib

./example