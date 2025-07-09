#!/bin/bash

echo "Compiling big actor network to MLIR -> LLVM -> Binary"
echo "This script takes in command line arguments:"
echo " -O (default 3) Set the llvm optimisation level, valid values between 0 and 3."
echo " -M (default 8) Set the number of messenger actors in the network."
echo " -P (default 10000) Set the number of ping messages sent by each Messenger actor"
echo
set -e

# 1. Interpret command line arguments
O=3
M=8
P=10000

while getopts O:M:P: flag
do
    case "${flag}" in
        O) O=${OPTARG};;
        M) M=${OPTARG};;
        P) P=${OPTARG};;
    esac
done

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

streamblocks mlir --set generate-single-declaration-per-actor=off --set experimental-network-elaboration=on --set bypass-AM-generation=on --source-path config.cal:BigNetwork.cal:Messenger.cal:Sink.cal --target-path myproject big.BigNetwork

echo "2. Generating a binary from the mlir file"

mkdir myproject/generated

cal-opt --lower-cal-to-llvm myproject/code-gen/main.mlir | cal-translate --mlir-to-llvmir > myproject/generated/main.ll
opt -O$O myproject/generated/main.ll -o myproject/generated/main.opt.ll
llc -relocation-model=pic myproject/generated/main.opt.ll -filetype=obj -o myproject/generated/main.o
clang myproject/generated/main.o -o main_executable_from_mlir

echo "3. Binary 'main_executable_from_mlir' Generated succesfully"