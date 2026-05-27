#!/usr/bin/env bash
set -e

echo "Building CAL example for a single thread"

cal-opt busy-chain.mlir --lower-cal-to-llvm > lowered.mlir
cal-translate --mlir-to-llvmir lowered.mlir -o lowered.ll
clang -O3 lowered.ll -o singlethreaded.out -L"../../llvm-project/build/lib" -lmlir_async_runtime -lmlir_runner_utils -lmlir_c_runner_utils -lpthread

echo
echo "Running CAL example (single thread)"

start=$(date +%s.%N)
./singlethreaded.out
ret=$?
end=$(date +%s.%N)

elapsed=$(awk -v s="$start" -v e="$end" 'BEGIN { printf "%.3f", e - s }')

echo
echo "Elapsed time: ${elapsed}s"

exit $ret