#!/usr/bin/env bash

set -e

# Benchmarks FFT network execution across nine input sizes (256–65536 in powers of 2),
# two actor-to-core assignment strategies (round-robin, block), and 1-4 cores.
# For each combination: elaborates the pre-compiled MLIR, lowers to LLVM, compiles,
# and runs with taskset to pin threads to the target cores. Timing results are
# printed to stdout and written to timing_results.txt.

TOP_DIR="../../.."

# cd ../..
# node bin/cli.js generate examples/fft/Top.cal
# cd -
# mv ../Top.mlir FFT_Top.mlir

declare -A TIMES
declare -A MIN_TIMES
declare -A MAX_TIMES
declare -A ACTOR_COUNTS
RESULTS_FILE="timing_results.txt"
echo "Timing Results - $(date)" > "$RESULTS_FILE"

#for FFT_SIZE in 256 512 1024 2048 4096 8192 16384 32768 65536; do
for FFT_SIZE in 256 512 1024; do
    case $FFT_SIZE in
        256)   LOG2N=8;  SQRTN="16.0"       ;;
        512)   LOG2N=9;  SQRTN="22.627417"  ;;
        1024)  LOG2N=10; SQRTN="32.0"       ;;
        2048)  LOG2N=11; SQRTN="45.254834"  ;;
        4096)  LOG2N=12; SQRTN="64.0"       ;;
        8192)  LOG2N=13; SQRTN="90.509668"  ;;
        16384) LOG2N=14; SQRTN="128.0"      ;;
        32768) LOG2N=15; SQRTN="181.019336" ;;
        65536) LOG2N=16; SQRTN="256.0"      ;;
    esac

    echo ""
    echo "=================================="
    echo "=== FFT Size: $FFT_SIZE ==="
    echo "=================================="
    echo "" >> "$RESULTS_FILE"
    echo "=== FFT Size: $FFT_SIZE (Actors: ${ACTOR_COUNTS[$FFT_SIZE]}) ===" >> "$RESULTS_FILE"

    cp FFT_Top_256.mlir FFT_Top_current.mlir
    sed -i "s/%t3 = arith.constant [0-9]* : i32 loc(#loc3)/%t3 = arith.constant $FFT_SIZE : i32 loc(#loc3)/" FFT_Top_current.mlir
    sed -i "s/%t4 = arith.constant [0-9]* : i32 loc(#loc4)/%t4 = arith.constant $LOG2N : i32 loc(#loc4)/" FFT_Top_current.mlir
    sed -i "s/%t5 = arith.constant [0-9.]* : f32 loc(#loc5)/%t5 = arith.constant $SQRTN : f32 loc(#loc5)/" FFT_Top_current.mlir

    cal-opt --cal-network-elab="top=fft__Top" FFT_Top_current.mlir > FFT_Flattened.mlir

    sed -i '/^[[:space:]]*in_names \[.*\][[:space:]]*$/d; /^[[:space:]]*out_names \[.*\][[:space:]]*$/d' FFT_Flattened.mlir

    ACTOR_COUNTS[$FFT_SIZE]=$(grep -c 'cal\.create_instance' FFT_Flattened.mlir)
    echo "  Actors: ${ACTOR_COUNTS[$FFT_SIZE]}"
    echo "  Actors: ${ACTOR_COUNTS[$FFT_SIZE]}" >> "$RESULTS_FILE"

    cp FFT_Flattened.mlir FFT_Flattened_clean.mlir

    for ASSIGNMENT_MODE in "round-robin" "block"; do
        echo ""
        echo "  --- Mode: $ASSIGNMENT_MODE ---"
        echo "" >> "$RESULTS_FILE"
        echo "  $ASSIGNMENT_MODE:" >> "$RESULTS_FILE"

        for NUM_CORES in 1 2 4; do
            echo "    NUM_CORES=$NUM_CORES"

            cp FFT_Flattened_clean.mlir FFT_Flattened.mlir

            awk -v num_cores="$NUM_CORES" -v mode="$ASSIGNMENT_MODE" '
FNR == NR {
    if (/cal\.create_instance[^"]*"[^"]*" \(/) total++
    next
}
/cal\.create_instance[^"]*"[^"]*" \(/ {
    core = (mode == "block") ? int(n * num_cores / total) : (n % num_cores)
    sub(/ \(/, " device_affinity=\"cpu" core "\" (")
    n++
}
{ print }' FFT_Flattened.mlir FFT_Flattened.mlir > FFT_Flattened.tmp && mv FFT_Flattened.tmp FFT_Flattened.mlir

            cal-opt FFT_Flattened.mlir --lower-cal-to-llvm="multithread-cal-actors" > lowered.mlir
            cal-translate --mlir-to-llvmir lowered.mlir -o lowered.ll
            clang -O3 lowered.ll -o multithreaded.out -L"$TOP_DIR/llvm-project/build/lib" -lmlir_async_runtime -lmlir_runner_utils -lmlir_c_runner_utils -lpthread -lm

            sleep 10

            TOTAL_TIME=0
            MIN_TIME=-1
            MAX_TIME=0
            for RUN in $(seq 1 10); do
                START=$(date +%s%N)
                taskset -c 0-$((NUM_CORES-1)) ./multithreaded.out || true
                END=$(date +%s%N)
		sleep 10
                RUN_TIME=$(( (END - START) / 1000000 ))
                TOTAL_TIME=$(( TOTAL_TIME + RUN_TIME ))
                if [ $MIN_TIME -eq -1 ] || [ $RUN_TIME -lt $MIN_TIME ]; then MIN_TIME=$RUN_TIME; fi
                if [ $RUN_TIME -gt $MAX_TIME ]; then MAX_TIME=$RUN_TIME; fi
            done
            TIMES["$FFT_SIZE-$ASSIGNMENT_MODE-$NUM_CORES"]=$(( TOTAL_TIME / 10 ))ms
            MIN_TIMES["$FFT_SIZE-$ASSIGNMENT_MODE-$NUM_CORES"]=${MIN_TIME}ms
            MAX_TIMES["$FFT_SIZE-$ASSIGNMENT_MODE-$NUM_CORES"]=${MAX_TIME}ms

            LINE="    NUM_CORES=$NUM_CORES: avg=${TIMES[$FFT_SIZE-$ASSIGNMENT_MODE-$NUM_CORES]} min=${MIN_TIMES[$FFT_SIZE-$ASSIGNMENT_MODE-$NUM_CORES]} max=${MAX_TIMES[$FFT_SIZE-$ASSIGNMENT_MODE-$NUM_CORES]}"
            echo "$LINE"
            echo "$LINE" >> "$RESULTS_FILE"
        done
    done
done

echo ""
echo "=== Timing Results ==="
for FFT_SIZE in 256 512 1024 2048 4096 8192 16384 32768 65536; do
    echo ""
    echo "FFT Size: $FFT_SIZE (Actors: ${ACTOR_COUNTS[$FFT_SIZE]})"
    echo "" >> "$RESULTS_FILE"
    echo "FFT Size: $FFT_SIZE (Actors: ${ACTOR_COUNTS[$FFT_SIZE]})" >> "$RESULTS_FILE"
    for ASSIGNMENT_MODE in "round-robin" "block"; do
        echo "  $ASSIGNMENT_MODE:"
        echo "  $ASSIGNMENT_MODE:" >> "$RESULTS_FILE"
        for NUM_CORES in 1 2 4; do
            LINE="    NUM_CORES=$NUM_CORES: avg=${TIMES[$FFT_SIZE-$ASSIGNMENT_MODE-$NUM_CORES]} min=${MIN_TIMES[$FFT_SIZE-$ASSIGNMENT_MODE-$NUM_CORES]} max=${MAX_TIMES[$FFT_SIZE-$ASSIGNMENT_MODE-$NUM_CORES]}"
            echo "$LINE"
            echo "$LINE" >> "$RESULTS_FILE"
        done
    done
done
echo ""
echo "Results written to $RESULTS_FILE"

rm FFT_Top_current.mlir FFT_Flattened.mlir FFT_Flattened_clean.mlir lowered.mlir lowered.ll multithreaded.out
