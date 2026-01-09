#!/usr/bin/env bash
set -e

echo "Building multicore CAL example"

cal-opt busy-chain.mlir --lower-cal-to-llvm="multithread-cal-actors" > lowered.mlir
cal-translate --mlir-to-llvmir lowered.mlir -o lowered.ll
clang -O3 lowered.ll -o multithreaded.out -L"../../llvm-project/build/lib" -lmlir_async_runtime -lmlir_runner_utils -lmlir_c_runner_utils -lpthread

echo
echo "Running multicore CAL example (multithreaded)"

start=$(date +%s.%N)
./multithreaded.out
ret=$?
end=$(date +%s.%N)

elapsed=$(awk -v s="$start" -v e="$end" 'BEGIN { printf "%.3f", e - s }')

echo
echo "Elapsed time: ${elapsed}s"

exit $ret