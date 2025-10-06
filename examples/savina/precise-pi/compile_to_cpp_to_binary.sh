#!/bin/bash
echo "Compiling PrecisePi network to CPP -> LLVM -> Binary"
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

#PATH="../../llvm-project/build/bin:$PATH"
#PATH="$PATH:../../build/bin"

rm -fr myproject

echo "1. Generating MLIR from .cal files"
echo 

streamblocks multicore --set experimental-network-elaboration=on --set reduction-algorithm=ordered-condition-checking --source-path PrecisePi.cal --target-path myproject precisepi.PrecisePiNetwork

echo "2. Generating a binary from the C++ files"

mkdir -p  myproject/build/
cd myproject/build/
cmake .. -DCMAKE_C_COMPILER=clang -DCMAKE_CXX_COMPILER=clang++ -DCMAKE_CXX_FLAGS="-O$O" 2> /dev/null
cmake --build . -j24 2> /dev/null
cd ../..
cp myproject/bin/PrecisePiNetwork main_executable_from_cpp

echo "3. Binary 'main_executable_from_cpp' Generated succesfully"