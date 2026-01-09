#!/bin/bash

echo "Compiling producer consumer with bounded buffer network to MLIR -> LLVM -> Binary"
echo "This script takes in command line arguments:"
echo " -O (default 3) Set the llvm optimisation level, valid values between 0 and 3."
echo " -C (default 3) The number of consumers."
echo " -P (default 3) The number of producers"
echo " -B (default 50) The amount of slots in the buffer actors"
echo " -N (default 10000) The number of items produced by each producer"
echo
set -e

# 1. Interpret command line arguments
O=3
C=3
P=3
B=50
N=10000

while getopts O:C:P:B:N: flag
do
    case "${flag}" in
        O) O=${OPTARG};;
        C) C=${OPTARG};;
        P) P=${OPTARG};;
        B) B=${OPTARG};;
        N) N=${OPTARG};;
    esac
done

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

cal-opt --lower-cal-to-llvm myproject/code-gen/main.mlir | cal-translate --mlir-to-llvmir > myproject/generated/main.ll
opt -O$O myproject/generated/main.ll -o myproject/generated/main.opt.ll
llc -relocation-model=pic myproject/generated/main.opt.ll -filetype=obj -o myproject/generated/main.o
clang myproject/generated/main.o -o main_executable_from_mlir

echo "3. Binary 'main_executable_from_mlir' Generated succesfully"