#!/bin/bash

# 1. Interpret command line arguments
O=0

while getopts O: flag
do
    case "${flag}" in
        O) O=${OPTARG};;
    esac
done

set -e 


PATH="../../llvm-project/build/bin:$PATH"
PATH="$PATH:../../build/bin"

rm -f main.ll main.o main_executable main.opt.ll

cal-opt --lower-cal-to-llvm myproject/code-gen/main.mlir | cal-translate --mlir-to-llvmir > main.ll
opt -O$O main.ll -o main.opt.ll
llc -relocation-model=pic main.opt.ll -filetype=obj -o main.o
clang main.o -o main_executable