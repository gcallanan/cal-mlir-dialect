#!/bin/bash

# 1. Interpret command line arguments
O=0
generateStaticSchedule=0

while getopts O:s flag
do
    case "${flag}" in
        O) O=${OPTARG};;
        s) generateStaticSchedule=1;;
    esac
done

set -e 


PATH="../../llvm-project/build/bin:$PATH"
PATH="$PATH:../../build/bin"

rm -f main.ll main.o main_executable main.opt.ll

if [ "$generateStaticSchedule" -eq 1 ]; then
    echo "Generating static schedule"
    cal-opt --lower-cal-to-llvm-with-static-schedule myproject/code-gen/main.mlir | cal-translate --mlir-to-llvmir > main.ll
else
    echo "Using dynamic schedule generation."
    cal-opt --lower-cal-to-llvm myproject/code-gen/main.mlir | cal-translate --mlir-to-llvmir > main.ll
fi

opt -O$O main.ll -o main.opt.ll
llc -relocation-model=pic main.opt.ll -filetype=obj -o main.o
clang main.o -o main_executable