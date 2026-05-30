#!/usr/bin/env bash
set -e

# rm -fr myproject
# mkdir myproject
# cd ../..
# streamblocks multicore --source-path examples/idct --target-path generated/idct/myproject idct.TopIDCT
# cd -
# cd myproject/build/
# cmake ..
# make
# cd -
# mv myproject/bin/TopIDCT streamblocks.out

# rm -fr myproject
# mkdir myproject
# cd ../..
# tychoc --source-path examples/idct --target-path generated/idct/myproject idct.TopIDCT
# cd -
# gcc -O3 myproject/*.c -o tycho.out

# cd ../..
# node bin/cli.js generate examples/idct/TopIDCT.cal
# cd -
# mv ../TopIDCT.mlir .

LLVM_DIR="/mnt/kingston/gareth/software-repos/mlir-cal/cal-mlir-dialect"

cal-opt --cal-network-elab="top=idct__TopIDCT" TopIDCT.mlir > IDCT_Flattened.mlir

declare -A TIMES
declare -A MIN_TIMES
declare -A MAX_TIMES
RESULTS_FILE="timing_results.txt"
echo "Timing Results - $(date)" > "$RESULTS_FILE"

NUM_ACTORS=$(grep -c 'cal\.create_instance' IDCT_Flattened.mlir)
echo "Actors: $NUM_ACTORS"
echo "Actors: $NUM_ACTORS" >> "$RESULTS_FILE"

cp IDCT_Flattened.mlir IDCT_Flattened_clean.mlir

for ASSIGNMENT_MODE in "round-robin" "block"; do
    echo ""
    echo "  --- Mode: $ASSIGNMENT_MODE ---"
    echo "" >> "$RESULTS_FILE"
    echo "  $ASSIGNMENT_MODE:" >> "$RESULTS_FILE"

    for NUM_CORES in 1 2 3 4; do
        echo "    NUM_CORES=$NUM_CORES"

        cp IDCT_Flattened_clean.mlir IDCT_Flattened.mlir

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
{ print }' IDCT_Flattened.mlir IDCT_Flattened.mlir > IDCT_Flattened.tmp && mv IDCT_Flattened.tmp IDCT_Flattened.mlir

        cal-opt IDCT_Flattened.mlir --lower-cal-to-llvm="multithread-cal-actors" > lowered.mlir
        cal-translate --mlir-to-llvmir lowered.mlir -o lowered.ll
        clang -O3 lowered.ll -o multithreaded.out -L"$LLVM_DIR/llvm-project/build/lib" -lmlir_async_runtime -lmlir_runner_utils -lmlir_c_runner_utils -lpthread -lm

        sleep 10

        TOTAL_TIME=0
        MIN_TIME=-1
        MAX_TIME=0
        for RUN in $(seq 1 10); do
            START=$(date +%s%N)
            taskset -c 0-$((NUM_CORES-1)) ./multithreaded.out 2>&1 | tail -1 || true
            sleep 10
            END=$(date +%s%N)
            RUN_TIME=$(( (END - START) / 1000000 ))
            TOTAL_TIME=$(( TOTAL_TIME + RUN_TIME ))
            if [ $MIN_TIME -eq -1 ] || [ $RUN_TIME -lt $MIN_TIME ]; then MIN_TIME=$RUN_TIME; fi
            if [ $RUN_TIME -gt $MAX_TIME ]; then MAX_TIME=$RUN_TIME; fi
        done
        TIMES["$ASSIGNMENT_MODE-$NUM_CORES"]=$(( TOTAL_TIME / 10 ))ms
        MIN_TIMES["$ASSIGNMENT_MODE-$NUM_CORES"]=${MIN_TIME}ms
        MAX_TIMES["$ASSIGNMENT_MODE-$NUM_CORES"]=${MAX_TIME}ms

        LINE="    NUM_CORES=$NUM_CORES: avg=${TIMES[$ASSIGNMENT_MODE-$NUM_CORES]} min=${MIN_TIMES[$ASSIGNMENT_MODE-$NUM_CORES]} max=${MAX_TIMES[$ASSIGNMENT_MODE-$NUM_CORES]}"
        echo "$LINE"
        echo "$LINE" >> "$RESULTS_FILE"
    done
done

TOTAL_TIME=0
SB_MIN=-1
SB_MAX=0
for RUN in $(seq 1 10); do
    START=$(date +%s%N)
    taskset -c 0 ./streamblocks.out 2>&1 | tail -1
    sleep 10
    END=$(date +%s%N)
    RUN_TIME=$(( (END - START) / 1000000 ))
    TOTAL_TIME=$(( TOTAL_TIME + RUN_TIME ))
    if [ $SB_MIN -eq -1 ] || [ $RUN_TIME -lt $SB_MIN ]; then SB_MIN=$RUN_TIME; fi
    if [ $RUN_TIME -gt $SB_MAX ]; then SB_MAX=$RUN_TIME; fi
done
STREAMBLOCKS_TIME="avg=$(( TOTAL_TIME / 10 ))ms min=${SB_MIN}ms max=${SB_MAX}ms"
echo "Streamblocks execution time: $STREAMBLOCKS_TIME"

TOTAL_TIME=0
TYCHO_MIN=-1
TYCHO_MAX=0
for RUN in $(seq 1 10); do
    START=$(date +%s%N)
    taskset -c 0 ./tycho.out 2>&1 | tail -1
    sleep 10
    END=$(date +%s%N)
    RUN_TIME=$(( (END - START) / 1000000 ))
    TOTAL_TIME=$(( TOTAL_TIME + RUN_TIME ))
    if [ $TYCHO_MIN -eq -1 ] || [ $RUN_TIME -lt $TYCHO_MIN ]; then TYCHO_MIN=$RUN_TIME; fi
    if [ $RUN_TIME -gt $TYCHO_MAX ]; then TYCHO_MAX=$RUN_TIME; fi
done
TYCHO_TIME="avg=$(( TOTAL_TIME / 10 ))ms min=${TYCHO_MIN}ms max=${TYCHO_MAX}ms"
echo "Tycho execution time: $TYCHO_TIME"

echo ""
echo "=== Timing Results (Actors: $NUM_ACTORS) ==="
echo "" >> "$RESULTS_FILE"
echo "=== Timing Results (Actors: $NUM_ACTORS) ===" >> "$RESULTS_FILE"
LINE="  tycho.out: ${TYCHO_TIME}"
echo "$LINE"
echo "$LINE" >> "$RESULTS_FILE"
LINE="  streamblocks.out: ${STREAMBLOCKS_TIME}"
echo "$LINE"
echo "$LINE" >> "$RESULTS_FILE"
for ASSIGNMENT_MODE in "round-robin" "block"; do
    echo "  $ASSIGNMENT_MODE:"
    echo "  $ASSIGNMENT_MODE:" >> "$RESULTS_FILE"
    for NUM_CORES in 1 2 3 4; do
        LINE="    NUM_CORES=$NUM_CORES: avg=${TIMES[$ASSIGNMENT_MODE-$NUM_CORES]} min=${MIN_TIMES[$ASSIGNMENT_MODE-$NUM_CORES]} max=${MAX_TIMES[$ASSIGNMENT_MODE-$NUM_CORES]}"
        echo "$LINE"
        echo "$LINE" >> "$RESULTS_FILE"
    done
done
echo ""
echo "Results written to $RESULTS_FILE"

rm IDCT_Flattened.mlir IDCT_Flattened_clean.mlir lowered.mlir lowered.ll multithreaded.out
