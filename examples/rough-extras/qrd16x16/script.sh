#!/usr/bin/env bash

set -e

LLVM_DIR="/mnt/kingston/gareth/software-repos/mlir-cal/cal-mlir-dialect"
NUM_TESTS=10
SLEEP_SECS=5

# Build streamblocks.out
# rm -fr myproject
# mkdir myproject
# streamblocks multicore --set experimental-network-elaboration=on --source-path qrd_systolic_cordic_fixedpoint.cal --target-path myproject qrd.Top
# cd myproject/build/
# cmake .. -DCMAKE_BUILD_TYPE=Release
# make
# cd ../..
# cp myproject/bin/Top streamblocks.out

# Build tycho.out
# rm -fr myproject
# mkdir myproject
# tychoc --set experimental-network-elaboration=on --source-path qrd_systolic_cordic_fixedpoint.cal --target-path myproject qrd.Top
# cc -O3 myproject/*.c -o tycho.out

# Build qrd_clean.mlir for multithreaded runs
rm -fr myproject
streamblocks mlir --set generate-single-declaration-per-actor=off --set experimental-network-elaboration=on --source-path qrd_systolic_cordic_fixedpoint.cal --target-path myproject qrd.Top
cp myproject/code-gen/main.mlir qrd_clean.mlir
sed -i 's/cal\.network$/cal.network @Top()/' qrd_clean.mlir
rm -r myproject

sleep $SLEEP_SECS

declare -A TIMES
declare -A MIN_TIMES
declare -A MAX_TIMES
declare -A LAST_OUTPUTS
RESULTS_FILE="timing_results.txt"
echo "Timing Results - $(date)" > "$RESULTS_FILE"

CSV_FILE="timing_results.csv"
echo "application,backend,num_actors,num_cores,assignment_mode,other_parameters,num_experiments,avg_ms,min_ms,max_ms,last_line" > "$CSV_FILE"

NUM_ACTORS=$(grep -c 'cal\.create_instance' qrd_clean.mlir)
echo "Actors: $NUM_ACTORS"
echo "Actors: $NUM_ACTORS" >> "$RESULTS_FILE"

for ASSIGNMENT_MODE in "round-robin" "block"; do
    echo ""
    echo "  --- Mode: $ASSIGNMENT_MODE ---"
    echo "" >> "$RESULTS_FILE"
    echo "  $ASSIGNMENT_MODE:" >> "$RESULTS_FILE"

    for NUM_CORES in 1 2 4; do
        echo "    NUM_CORES=$NUM_CORES"

        cp qrd_clean.mlir qrd_current.mlir

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
{ print }' qrd_current.mlir qrd_current.mlir > qrd_current.tmp && mv qrd_current.tmp qrd_current.mlir

        cal-opt qrd_current.mlir --lower-cal-to-llvm="multithread-cal-actors" > lowered.mlir
        cal-translate --mlir-to-llvmir lowered.mlir -o lowered.ll
        clang -O3 lowered.ll -o multithreaded.out -L"$LLVM_DIR/llvm-project/build/lib" -lmlir_async_runtime -lmlir_runner_utils -lmlir_c_runner_utils -lpthread -lm -march=native

        sleep $SLEEP_SECS

        TOTAL_TIME=0
        MIN_TIME=-1
        MAX_TIME=0
        for RUN in $(seq 1 $NUM_TESTS); do
            START=$(date +%s%N)
            OUTPUT=$(taskset -c 0-$((NUM_CORES-1)) ./multithreaded.out 2>&1 | tail -1 || true)
            END=$(date +%s%N)
            echo "      run $RUN: $OUTPUT"
            sleep $SLEEP_SECS
            RUN_TIME=$(( (END - START) / 1000000 ))
            TOTAL_TIME=$(( TOTAL_TIME + RUN_TIME ))
            if [ $MIN_TIME -eq -1 ] || [ $RUN_TIME -lt $MIN_TIME ]; then MIN_TIME=$RUN_TIME; fi
            if [ $RUN_TIME -gt $MAX_TIME ]; then MAX_TIME=$RUN_TIME; fi
        done
        TIMES["$ASSIGNMENT_MODE-$NUM_CORES"]=$(( TOTAL_TIME / NUM_TESTS ))ms
        MIN_TIMES["$ASSIGNMENT_MODE-$NUM_CORES"]=${MIN_TIME}ms
        MAX_TIMES["$ASSIGNMENT_MODE-$NUM_CORES"]=${MAX_TIME}ms
        LAST_OUTPUTS["$ASSIGNMENT_MODE-$NUM_CORES"]=$OUTPUT

        ESCAPED_OUTPUT="${OUTPUT//\"/\"\"}"
        echo "qrd,mlir,$NUM_ACTORS,$NUM_CORES,$ASSIGNMENT_MODE,,$NUM_TESTS,$(( TOTAL_TIME / NUM_TESTS )),$MIN_TIME,$MAX_TIME,\"$ESCAPED_OUTPUT\"" >> "$CSV_FILE"

        LINE="    NUM_CORES=$NUM_CORES: avg=${TIMES[$ASSIGNMENT_MODE-$NUM_CORES]} min=${MIN_TIMES[$ASSIGNMENT_MODE-$NUM_CORES]} max=${MAX_TIMES[$ASSIGNMENT_MODE-$NUM_CORES]}: $OUTPUT"
        echo "$LINE"
        echo "$LINE" >> "$RESULTS_FILE"
    done
done

declare -A SB_TIMES SB_MIN_TIMES SB_MAX_TIMES SB_LAST

for ASSIGNMENT_MODE in "round-robin" "block"; do
    echo ""
    echo "  --- Streamblocks: $ASSIGNMENT_MODE ---"
    echo "" >> "$RESULTS_FILE"
    echo "  streamblocks $ASSIGNMENT_MODE:" >> "$RESULTS_FILE"

    for NUM_CORES in 1 2 4; do
        echo "    NUM_CORES=$NUM_CORES"
        python3 generate_partition.py streamblocks_partition.xml streamblocks_partition_temp.xml "$NUM_CORES" "$ASSIGNMENT_MODE"

        sleep $SLEEP_SECS

        TOTAL_TIME=0
        MIN_TIME=-1
        MAX_TIME=0
        for RUN in $(seq 1 $NUM_TESTS); do
            START=$(date +%s%N)
            SB_OUTPUT=$(taskset -c 0-$((NUM_CORES-1)) ./streamblocks.out --d=131072 --cfile=streamblocks_partition_temp.xml 2>&1 | tail -1 || true)
            END=$(date +%s%N)
            echo "      run $RUN: $SB_OUTPUT"
            sleep $SLEEP_SECS
            RUN_TIME=$(( (END - START) / 1000000 ))
            TOTAL_TIME=$(( TOTAL_TIME + RUN_TIME ))
            if [ $MIN_TIME -eq -1 ] || [ $RUN_TIME -lt $MIN_TIME ]; then MIN_TIME=$RUN_TIME; fi
            if [ $RUN_TIME -gt $MAX_TIME ]; then MAX_TIME=$RUN_TIME; fi
        done
        SB_TIMES["$ASSIGNMENT_MODE-$NUM_CORES"]=$(( TOTAL_TIME / NUM_TESTS ))ms
        SB_MIN_TIMES["$ASSIGNMENT_MODE-$NUM_CORES"]=${MIN_TIME}ms
        SB_MAX_TIMES["$ASSIGNMENT_MODE-$NUM_CORES"]=${MAX_TIME}ms
        SB_LAST["$ASSIGNMENT_MODE-$NUM_CORES"]=$SB_OUTPUT

        ESCAPED_SB_OUTPUT="${SB_OUTPUT//\"/\"\"}"
        echo "qrd,streamblocks,$NUM_ACTORS,$NUM_CORES,$ASSIGNMENT_MODE,,$NUM_TESTS,$(( TOTAL_TIME / NUM_TESTS )),$MIN_TIME,$MAX_TIME,\"$ESCAPED_SB_OUTPUT\"" >> "$CSV_FILE"

        LINE="    NUM_CORES=$NUM_CORES: avg=${SB_TIMES[$ASSIGNMENT_MODE-$NUM_CORES]} min=${SB_MIN_TIMES[$ASSIGNMENT_MODE-$NUM_CORES]} max=${SB_MAX_TIMES[$ASSIGNMENT_MODE-$NUM_CORES]}: $SB_OUTPUT"
        echo "$LINE"
        echo "$LINE" >> "$RESULTS_FILE"
    done
done

TOTAL_TIME=0
TYCHO_MIN=-1
TYCHO_MAX=0
for RUN in $(seq 1 $NUM_TESTS); do
    START=$(date +%s%N)
    TYCHO_OUTPUT=$(taskset -c 0 ./tycho.out 2>&1 | tail -1 || true)
    END=$(date +%s%N)
    echo "    run $RUN: $TYCHO_OUTPUT"
    sleep $SLEEP_SECS
    RUN_TIME=$(( (END - START) / 1000000 ))
    TOTAL_TIME=$(( TOTAL_TIME + RUN_TIME ))
    if [ $TYCHO_MIN -eq -1 ] || [ $RUN_TIME -lt $TYCHO_MIN ]; then TYCHO_MIN=$RUN_TIME; fi
    if [ $RUN_TIME -gt $TYCHO_MAX ]; then TYCHO_MAX=$RUN_TIME; fi
done
TYCHO_AVG=$(( TOTAL_TIME / NUM_TESTS ))
TYCHO_TIME="avg=${TYCHO_AVG}ms min=${TYCHO_MIN}ms max=${TYCHO_MAX}ms"
echo "Tycho execution time: $TYCHO_TIME"

ESCAPED_TYCHO_OUTPUT="${TYCHO_OUTPUT//\"/\"\"}"
echo "qrd,tycho,$NUM_ACTORS,NA,NA,,$NUM_TESTS,$TYCHO_AVG,$TYCHO_MIN,$TYCHO_MAX,\"$ESCAPED_TYCHO_OUTPUT\"" >> "$CSV_FILE"

echo ""
echo "=== Timing Results (Actors: $NUM_ACTORS) ==="
echo "" >> "$RESULTS_FILE"
echo "=== Timing Results (Actors: $NUM_ACTORS) ===" >> "$RESULTS_FILE"
LINE="  tycho.out: ${TYCHO_TIME}: ${TYCHO_OUTPUT}"
echo "$LINE"
echo "$LINE" >> "$RESULTS_FILE"
for ASSIGNMENT_MODE in "round-robin" "block"; do
    echo "  streamblocks $ASSIGNMENT_MODE:"
    echo "  streamblocks $ASSIGNMENT_MODE:" >> "$RESULTS_FILE"
    for NUM_CORES in 1 2 4; do
        LINE="    NUM_CORES=$NUM_CORES: avg=${SB_TIMES[$ASSIGNMENT_MODE-$NUM_CORES]} min=${SB_MIN_TIMES[$ASSIGNMENT_MODE-$NUM_CORES]} max=${SB_MAX_TIMES[$ASSIGNMENT_MODE-$NUM_CORES]}: ${SB_LAST[$ASSIGNMENT_MODE-$NUM_CORES]}"
        echo "$LINE"
        echo "$LINE" >> "$RESULTS_FILE"
    done
done
for ASSIGNMENT_MODE in "round-robin" "block"; do
    echo "  MLIR $ASSIGNMENT_MODE:"
    echo "  MLIR $ASSIGNMENT_MODE:" >> "$RESULTS_FILE"
    for NUM_CORES in 1 2 4; do
        LINE="    NUM_CORES=$NUM_CORES: avg=${TIMES[$ASSIGNMENT_MODE-$NUM_CORES]} min=${MIN_TIMES[$ASSIGNMENT_MODE-$NUM_CORES]} max=${MAX_TIMES[$ASSIGNMENT_MODE-$NUM_CORES]}: ${LAST_OUTPUTS[$ASSIGNMENT_MODE-$NUM_CORES]}"
        echo "$LINE"
        echo "$LINE" >> "$RESULTS_FILE"
    done
done
echo ""
echo "Results written to $RESULTS_FILE and $CSV_FILE"

rm -f qrd_current.mlir qrd_current.tmp lowered.mlir lowered.ll streamblocks_partition_temp.xml
