#!/bin/bash

set -e

# CSV header
echo "OptLevel,NumProducers,Backend,RunNumber,TimeInSeconds" > results.csv

# Number of runs per configuration
RUNS=3

# Number of items produced by each producer
ITEMS=1000000

# Number of consumers
C=1

# Sweep through optimization levels
for O in {0..3}; do
    # Sweep through number of messengers (powers of 2)
    for P in 1 2 3 4 5 6 7 8 9 10; do
        echo "Testing O=$O P=$P"
        
        # Compile both versions
        bash compile_to_cpp_to_binary.sh -O "$O" -P "$P" -C "$C" -N "$ITEMS"
        bash compile_to_mlir_to_binary.sh -O "$O" -P "$P" -C "$C" -N "$ITEMS"

        # Compare outputs
        ./main_executable_from_cpp > cpp_output.txt
        ./main_executable_from_mlir > mlir_output.txt

        # Remove lines about non-empty FIFOs before comparing
        grep -v "Not all fifos are empty at exit:" cpp_output.txt | grep -v "contains [0-9]\+ tokens (capacity: [0-9]\+)" | tr -d '\n' > cpp_output_filtered.txt
        grep -v "Not all fifos are empty at exit:" mlir_output.txt | grep -v "contains [0-9]\+ tokens (capacity: [0-9]\+)" | tr -d '\n' > mlir_output_filtered.txt

        if ! diff -q cpp_output_filtered.txt mlir_output_filtered.txt > /dev/null; then
            echo "Output mismatch detected for O=$O P=$P"
            exit 1
        fi

        rm -f cpp_output.txt mlir_output.txt cpp_output_filtered.txt mlir_output_filtered.txt
        
        # Run each version multiple times to get timing information
        for run in $(seq 1 $RUNS); do
            # Time CPP version
            cpp_time=$( { time ./main_executable_from_cpp; } 2>&1 | grep real | awk '{print $2}' )
            echo "$O,$P,CPP,$run,$cpp_time" >> results.csv

            sleep 5
            
            # Time MLIR version
            mlir_time=$( { time ./main_executable_from_mlir; } 2>&1 | grep real | awk '{print $2}' )
            echo "$O,$P,MLIR,$run,$mlir_time" >> results.csv

            sleep 5
        done
    done
done

echo "Performance comparison completed. Results saved in results.csv"
