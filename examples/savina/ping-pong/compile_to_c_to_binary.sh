#!/bin/bash
echo "Compiling pingpong network to C -> LLVM -> Binary"
echo "This script takes in command line arguments:"
echo " -O (default 3) Set the llvm optimisation level, valid values between 0 and 3."

echo
set -e

# 1. Interpret command line arguments
O=3

while getopts O: flag
do
    case "${flag}" in
        O) O=${OPTARG};;
    esac
done

set -e

PATH="../../../llvm-project/build/bin:$PATH"
PATH="$PATH:../../../build/bin"

rm -fr myproject

echo "1. Generating c from .cal files"
echo 

mkdir myproject
tychoc --set experimental-network-elaboration=on --set reduction-algorithm=ordered-condition-checking --source-path PingPong.cal --target-path myproject pingpong.PingPongNetwork

echo "2. Generating a binary from the C files"

clang myproject/*.c -O$O -lm -o main_executable_from_c

echo "3. Binary 'main_executable_from_c' Generated succesfully"