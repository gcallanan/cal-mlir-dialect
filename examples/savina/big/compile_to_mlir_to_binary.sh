#!/bin/bash

echo "Compiling big actor network to MLIR -> LLVM -> Binary"
echo "This script takes in command line arguments:"
echo " -O (default 3) Set the llvm optimisation level, valid values between 0 and 3."
echo " -M (default 8) Set the number of messenger actors in the network."
echo " -P (default 10000) Set the number of ping messages sent by each Messenger actor"
echo " -m (default false) Enable multi-threaded actor execution"
echo
set -e

# 1. Interpret command line arguments
O=3
M=8
P=10000
m=false

while getopts O:M:P:m flag
do
    case "${flag}" in
        O) O=${OPTARG};;
        M) M=${OPTARG};;
        P) P=${OPTARG};;
        m) m=true;;
    esac
done

if [ "$m" = true ]; then
    parallel="multithread-cal-actors"
else
    parallel="''"
fi

set -e

echo "namespace big:
    uint numMessengers = $M;
    uint numPingPongs = $P;
end
" > config.cal

PATH="../../llvm-project/build/bin:$PATH"
PATH="$PATH:../../build/bin"

rm -fr myproject

echo "1. Generating MLIR from .cal files"
echo 

streamblocks mlir --set generate-single-declaration-per-actor=off --set experimental-network-elaboration=on --source-path config.cal:BigNetwork.cal:Messenger.cal:Sink.cal --target-path myproject big.BigNetwork

echo "2. Generating a binary from the mlir file"

mkdir myproject/generated

if [ "$m" = true ]; then
    output_binary="main_executable_from_mlir_multicore"
    bash roughwork/assign_mlir_cpu_affinities.sh
    i=myproject/code-gen/main_multicore.mlir
else
    output_binary="main_executable_from_mlir"
    i=myproject/code-gen/main.mlir
fi

cal-opt --lower-cal-to-llvm="$parallel" "$i" | cal-translate --mlir-to-llvmir > myproject/generated/main.ll
clang -O3 myproject/generated/main.ll -o "$output_binary" -L"../../../llvm-project/build/lib" -lmlir_async_runtime -lmlir_runner_utils -lmlir_c_runner_utils -lpthread

echo "3. Binary '$output_binary' Generated succesfully"