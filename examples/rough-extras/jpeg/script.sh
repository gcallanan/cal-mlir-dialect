#!/usr/bin/env bash

set -e

NAME=Top_JPEG_Decoder_Parallel
LLVM_DIR="/mnt/kingston/gareth/software-repos/mlir-cal/cal-mlir-dialect"
NUM_TESTS=10
SLEEP_SECS=2
RESULTS_FILE="timing_results.txt"

# Build Tycho
# rm -rf myproject
# mkdir myproject
# tychoc --source-path ../../examples/jpeg/ --target-path myproject jpeg.$NAME
# gcc -O3 myproject/*.c -o tycho.out

# Build StreamBlocks
# rm -rf myproject
# streamblocks multicore --source-path ../../examples/jpeg/ --target-path myproject jpeg.$NAME
# cd myproject/build
# cmake .. -DCMAKE_BUILD_TYPE=Release
# cmake --build .
# cd -
# cp myproject/bin/$NAME streamblocks.out

# Generate MLIR (shared across all core counts and configurations)
# rm -f JpegTestbed.mlir JpegTestbed_Flattened_base.mlir
# cd ../..
# node bin/cli.js generate examples/jpeg/$NAME.cal
# cd -
# mv ../$NAME.mlir JpegTestbed.mlir
# cal-opt --cal-network-elab="top=jpeg__$NAME" JpegTestbed.mlir > JpegTestbed_Flattened_base.mlir 2>/dev/null

assign_affinities() {
    local num_cores=$1 src=$2 dst=$3
    if [ "$num_cores" -eq 1 ]; then
        awk '/cal\.create_instance[^"]*"[^"]*" \(/ { sub(/ \(/, " device_affinity=\"cpu0\" (") } { print }' "$src" > "$dst"
    elif [ "$num_cores" -eq 2 ]; then
        python3 assign_affinities.py actor_affinities_2core.csv "$src" "$dst"
    elif [ "$num_cores" -eq 4 ]; then
        python3 assign_affinities.py actor_affinities_4core.csv "$src" "$dst"
    fi
}

echo "Timing Results - $(date)" > "$RESULTS_FILE"

NUM_ACTORS=$(grep -c 'cal\.create_instance' JpegTestbed_Flattened_base.mlir)
echo "Actors: $NUM_ACTORS"
echo "Actors: $NUM_ACTORS" >> "$RESULTS_FILE"

declare -A MLIR_AVG MLIR_MIN MLIR_MAX MLIR_LAST

for GROUPED_POP in n y; do
    for GROUPED_PUSH in n y; do
        COMBO="${GROUPED_POP}${GROUPED_PUSH}"
        echo ""
        echo "  --- MLIR: pop=$GROUPED_POP push=$GROUPED_PUSH ---"
        echo "" >> "$RESULTS_FILE"
        echo "  MLIR pop=$GROUPED_POP push=$GROUPED_PUSH:" >> "$RESULTS_FILE"

        for NUM_CORES in 1 2 4; do
            echo "    NUM_CORES=$NUM_CORES"

            MULTITHREAD_CAL_ACTORS=n
            [ "$NUM_CORES" -gt 1 ] && MULTITHREAD_CAL_ACTORS=y

            assign_affinities "$NUM_CORES" JpegTestbed_Flattened_base.mlir JpegTestbed_Flattened.mlir

            LOWER_OPTS=""
            [ "$MULTITHREAD_CAL_ACTORS" = "y" ] && LOWER_OPTS="$LOWER_OPTS multithread-cal-actors"
            [ "$GROUPED_POP"  = "y" ] && LOWER_OPTS="$LOWER_OPTS fifo-extract-pop-view"
            [ "$GROUPED_PUSH" = "y" ] && LOWER_OPTS="$LOWER_OPTS fifo-extract-push-view"

            cal-opt JpegTestbed_Flattened.mlir --lower-cal-to-llvm="$LOWER_OPTS" > lowered.mlir
            cal-translate --mlir-to-llvmir lowered.mlir -o lowered.ll
            clang -O3 lowered.ll -o multithreaded.out -L"$LLVM_DIR/llvm-project/build/lib" \
                -funroll-loops -lmlir_async_runtime -lmlir_runner_utils -lmlir_c_runner_utils \
                -lpthread -lm -march=native

            sleep "$SLEEP_SECS"

            TOTAL_TIME=0
            MIN_TIME=-1
            MAX_TIME=0
            for RUN in $(seq 1 "$NUM_TESTS"); do
                START=$(date +%s%N)
                OUTPUT=$(taskset -c 0-$((NUM_CORES-1)) ./multithreaded.out 2>/dev/null | tail -1 || true)
                END=$(date +%s%N)
                echo "      run $RUN: $OUTPUT"
                sleep "$SLEEP_SECS"
                RUN_TIME=$(( (END - START) / 1000000 ))
                TOTAL_TIME=$(( TOTAL_TIME + RUN_TIME ))
                if [ "$MIN_TIME" -eq -1 ] || [ "$RUN_TIME" -lt "$MIN_TIME" ]; then MIN_TIME=$RUN_TIME; fi
                if [ "$RUN_TIME" -gt "$MAX_TIME" ]; then MAX_TIME=$RUN_TIME; fi
            done

            KEY="${COMBO}-${NUM_CORES}"
            MLIR_AVG["$KEY"]=$(( TOTAL_TIME / NUM_TESTS ))ms
            MLIR_MIN["$KEY"]=${MIN_TIME}ms
            MLIR_MAX["$KEY"]=${MAX_TIME}ms
            MLIR_LAST["$KEY"]=$OUTPUT
        done
    done
done

declare -A SB_AVG SB_MIN SB_MAX SB_LAST

run_sb() {
    local label=$1; shift
    echo ""
    echo "  --- Streamblocks $label ---"
    local TOTAL_TIME=0 MIN_TIME=-1 MAX_TIME=0 RUN START END OUTPUT RUN_TIME
    for RUN in $(seq 1 "$NUM_TESTS"); do
        START=$(date +%s%N)
        OUTPUT=$(./streamblocks.out "$@" --d=65536 2>/dev/null | tail -1 || true)
        END=$(date +%s%N)
        echo "    run $RUN: $OUTPUT"
        sleep "$SLEEP_SECS"
        RUN_TIME=$(( (END - START) / 1000000 ))
        TOTAL_TIME=$(( TOTAL_TIME + RUN_TIME ))
        if [ "$MIN_TIME" -eq -1 ] || [ "$RUN_TIME" -lt "$MIN_TIME" ]; then MIN_TIME=$RUN_TIME; fi
        if [ "$RUN_TIME" -gt "$MAX_TIME" ]; then MAX_TIME=$RUN_TIME; fi
    done
    SB_AVG["$label"]=$(( TOTAL_TIME / NUM_TESTS ))ms
    SB_MIN["$label"]=${MIN_TIME}ms
    SB_MAX["$label"]=${MAX_TIME}ms
    SB_LAST["$label"]=$OUTPUT
}

run_sb "1core"
run_sb "2core" --cfile=schedule_2core.xml
run_sb "4core" --cfile=schedule_4core.xml

echo ""
echo "  --- Tycho ---"
TOTAL_TIME=0
TYCHO_MIN=-1
TYCHO_MAX=0
for RUN in $(seq 1 "$NUM_TESTS"); do
    START=$(date +%s%N)
    OUTPUT=$(taskset -c 0 ./tycho.out 2>/dev/null | tail -1 || true)
    END=$(date +%s%N)
    echo "    run $RUN: $OUTPUT"
    sleep "$SLEEP_SECS"
    RUN_TIME=$(( (END - START) / 1000000 ))
    TOTAL_TIME=$(( TOTAL_TIME + RUN_TIME ))
    if [ "$TYCHO_MIN" -eq -1 ] || [ "$RUN_TIME" -lt "$TYCHO_MIN" ]; then TYCHO_MIN=$RUN_TIME; fi
    if [ "$RUN_TIME" -gt "$TYCHO_MAX" ]; then TYCHO_MAX=$RUN_TIME; fi
done
TYCHO_TIME="avg=$(( TOTAL_TIME / NUM_TESTS ))ms min=${TYCHO_MIN}ms max=${TYCHO_MAX}ms"
TYCHO_LAST=$OUTPUT

echo ""
echo "=== Timing Results (Actors: $NUM_ACTORS) ==="
echo "" >> "$RESULTS_FILE"
echo "=== Timing Results (Actors: $NUM_ACTORS) ===" >> "$RESULTS_FILE"

LINE="  tycho.out: ${TYCHO_TIME}: ${TYCHO_LAST}"
echo "$LINE"; echo "$LINE" >> "$RESULTS_FILE"

for label in 1core 2core 4core; do
    LINE="  streamblocks $label: avg=${SB_AVG[$label]} min=${SB_MIN[$label]} max=${SB_MAX[$label]}: ${SB_LAST[$label]}"
    echo "$LINE"; echo "$LINE" >> "$RESULTS_FILE"
done

for GROUPED_POP in n y; do
    for GROUPED_PUSH in n y; do
        COMBO="${GROUPED_POP}${GROUPED_PUSH}"
        echo "  MLIR pop=$GROUPED_POP push=$GROUPED_PUSH:"
        echo "  MLIR pop=$GROUPED_POP push=$GROUPED_PUSH:" >> "$RESULTS_FILE"
        for NUM_CORES in 1 2 4; do
            KEY="${COMBO}-${NUM_CORES}"
            LINE="    NUM_CORES=$NUM_CORES: avg=${MLIR_AVG[$KEY]} min=${MLIR_MIN[$KEY]} max=${MLIR_MAX[$KEY]}: ${MLIR_LAST[$KEY]}"
            echo "$LINE"; echo "$LINE" >> "$RESULTS_FILE"
        done
    done
done

echo ""
echo "Results written to $RESULTS_FILE"

rm -f lowered.mlir lowered.ll JpegTestbed_Flattened.mlir
