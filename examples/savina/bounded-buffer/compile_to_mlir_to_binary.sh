#!/bin/bash

echo "Compiling producer consumer with bounded buffer network to MLIR -> LLVM -> Binary"
echo "This script takes in command line arguments:"
echo " -O (default 3) Set the llvm optimisation level, valid values between 0 and 3."
echo " -C (default 3) The number of consumers."
echo " -P (default 3) The number of producers"
echo " -B (default 50) The amount of slots in the buffer actors"
echo " -m (default false) Enable multi-threaded actor execution"
echo
set -e

# 1. Interpret command line arguments
O=3
C=3
P=3
B=50
N=3
m=false

while getopts O:C:P:B:N:m flag
do
    case "${flag}" in
        O) O=${OPTARG};;
        C) C=${OPTARG};;
        P) P=${OPTARG};;
        B) B=${OPTARG};;
        N) N=${OPTARG};;
        m) m=true;;
    esac
done

if [ "$m" = true ]; then
    parallel="multithread-cal-actors"
else
    parallel="''"
fi

set -e

echo "namespace bndBuffer:
    uint B = $B; // Buffer size
    uint P = $P; // Number of producers
    uint C = $C; // Number of consumers
    uint numItemsPerProducer = $N;
    uint prodCost = 50; // Cost to perform action by producer
    uint consCost = 50; // Cost to perform action by consumer
end

" > config.cal

PATH="../../llvm-project/build/bin:$PATH"
PATH="$PATH:../../build/bin"

rm -fr myproject

echo "1. Generating MLIR from .cal files"
echo 

streamblocks mlir --set generate-single-declaration-per-actor=off --set experimental-network-elaboration=on --source-path config.cal:BndBufferNetwork.cal:Buffer.cal:Sink.cal:Producer.cal:Consumer.cal:helperFunctions.cal --target-path myproject bndBuffer.BndBufferNetwork

echo "2. Generating a binary from the mlir file"

mkdir myproject/generated

echo $parallel
cal-opt --lower-cal-to-llvm="$parallel" myproject/code-gen/main.mlir | cal-translate --mlir-to-llvmir > myproject/generated/main.ll
clang -O$O myproject/generated/main.ll -o main_executable_from_mlir -L"../../../llvm-project/build/lib" -lmlir_async_runtime -lmlir_runner_utils -lmlir_c_runner_utils -lpthread

echo "3. Binary 'main_executable_from_mlir' Generated succesfully"