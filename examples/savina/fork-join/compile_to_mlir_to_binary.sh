#!/bin/bash

echo "Compiling ForkJoin network to MLIR -> LLVM -> Binary"
echo "This script takes in command line arguments:"
echo " -O (default 3) Set the llvm optimisation level, valid values between 0 and 3."
echo " -m (default false) Enable multi-threaded actor execution"
echo
set -e

# 1. Interpret command line arguments
O=3
static_schedule=false
m=false

while getopts "O:sm" flag
do
    case "${flag}" in
        O) O=${OPTARG};;
        s) static_schedule=true;;
        m) m=true;;
    esac
done

if [ "$m" = true ]; then
    parallel="multithread-cal-actors"
else
    parallel="''"
fi

set -e

PATH="../../../llvm-project/build/bin:$PATH"
PATH="$PATH:../../../build/bin"

rm -fr myproject

echo "1. Generating MLIR from .cal files"
echo 

streamblocks mlir --set generate-single-declaration-per-actor=off --set experimental-network-elaboration=on --source-path ForkJoin.cal --target-path myproject forkjoin.ForkJoinNetwork

echo "2. Generating a binary from the mlir file"

mkdir myproject/generated

if [ "$static_schedule" = false ]; then
    cal-opt --lower-cal-to-llvm="$parallel" myproject/code-gen/main.mlir | cal-translate --mlir-to-llvmir > myproject/generated/main.ll
else
    cal-opt --lower-cal-to-llvm-with-static-schedule myproject/code-gen/main.mlir | cal-translate --mlir-to-llvmir > myproject/generated/main.ll
fi
if [ "$static_schedule" = false ]; then
    clang myproject/generated/main.ll -O$O -o main_executable_from_mlir -L"../../../llvm-project/build/lib" -lmlir_async_runtime -lmlir_runner_utils -lmlir_c_runner_utils -lpthread
else
    clang myproject/generated/main.ll -O$O -o main_executable_from_mlir_static -L"../../../llvm-project/build/lib" -lmlir_async_runtime -lmlir_runner_utils -lmlir_c_runner_utils -lpthread
fi

echo "3. Binary 'main_executable_from_mlir' Generated succesfully"