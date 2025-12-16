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

echo "1. Generating C from .cal files"
echo 

mkdir myproject
tychoc --set experimental-network-elaboration=on --set reduction-algorithm=ordered-condition-checking --source-path config.cal:BigNetwork.cal:Messenger.cal:Sink.cal --target-path myproject big.BigNetwork

echo "2. Generating a binary from the C files"

clang myproject/*.c -O$O -o main_executable_from_c

echo "3. Binary 'main_executable_from_c' Generated succesfully"