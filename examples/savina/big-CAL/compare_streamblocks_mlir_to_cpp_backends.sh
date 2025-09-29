#!/bin/bash

set -e

# CSV header
echo "OptLevel,NumMessengers,Backend,RunNumber,TimeInSeconds" > results.csv

# Number of runs per configuration
RUNS=3

# Number of pings sent out by each actor
PINGS=1000000

# Sweep through optimization levels
for O in {0..3}; do
    # Sweep through number of messengers (powers of 2)
    for M in 2 3 4 5 6 7 8 9 10; do
        echo "Testing O=$O M=$M"
        
        # Compile both versions
        bash compile_to_cpp_then_to_binary.sh -O "$O" -M "$M" -P "$PINGS"
        bash compile_to_mlir_then_to_binary.sh -O "$O" -M "$M" -P "$PINGS"
        
        # Run each version multiple times
        for run in $(seq 1 $RUNS); do
            # Time CPP version
            cpp_time=$( { time ./main_executable_from_cpp; } 2>&1 | grep real | awk '{print $2}' )
            echo "$O,$M,CPP,$run,$cpp_time" >> results.csv

            sleep 5
            
            # Time MLIR version
            mlir_time=$( { time ./main_executable_from_mlir; } 2>&1 | grep real | awk '{print $2}' )
            echo "$O,$M,MLIR,$run,$mlir_time" >> results.csv

            sleep 5
        done
    done
done

echo "Performance comparison completed. Results saved in results.csv"
