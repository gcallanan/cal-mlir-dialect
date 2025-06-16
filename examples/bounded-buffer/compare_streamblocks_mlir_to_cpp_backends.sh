#!/bin/bash

echo "Script that compares the performance of the bounded-buffer benchmark with"
echo "different compilation paths and optimisation flags. Primarily compares"
echo "the streamblocks multicore backend and streamblocks mlir backend but"
echo "you can optionally choose to also compare the performance of the original"
echo "tÿcho C backend."
echo " -t Enable the tycho backend."
echo

# Interpret command line arguments
use_tycho=false

while getopts t flag
do
    case "${flag}" in
        t) use_tycho=true;;
    esac
done

# Number of runs per configuration
RUNS=1

# Number of items produced by each producer
ITEMS=30000

# Number of consumers
C=3


# Compares two floating-point numbers a and b for approximate equality
# within a *relative* error tolerance of 1e-5.
#
# Can take these numbers in both decimal format or scientific notations.
# This is why we need relative tolerance, we only have 6 bits of prescision with
# scientific notation
#
# Args:
#     a (float): The first floating-point number to compare.
#     b (float): The second floating-point number to compare.
floats_equal() {
    local a="$1"
    local b="$2"

    LC_NUMERIC=C a_dec=$(printf "%.5f\n" "$a")
    LC_NUMERIC=C b_dec=$(printf "%.5f\n" "$b")

    diff=$(bc -l <<< "define abs(x){if(x<0) return(-x); return(x);} abs($a_dec - $b_dec)")
    max_ab=$(bc -l <<< "define abs(x){if(x<0) return(-x); return(x);} a=abs($a_dec); b=abs($b_dec); if(a>b) a else b")
    rel_error=$(bc -l <<< "scale=10; if($max_ab == 0) 0 else $diff / $max_ab")

    result=$(echo "$rel_error > 0.00001" | bc -l)

    if [[ "$result" == "1" ]]; then
        echo "ERROR: Relative error too large: $rel_error" >&2
        return 1
    fi
}

# Extracts and checks whether the actual output matches the expected output.
#
# Args:
#     lhs_output (Any): The output produced by the first compilation path.
#     rhs_output (Any): The output produced by the second compilation path.
#
# Returns:
#     The function echoes the Producer and Consumer item values for both
#     input files
check_outputs_match() {
    local file1="$1"
    local file2="$2"
    local O="$3"
    local P="$4"

    # Extract values from file1
    local prod1=$(grep "Producers items sum" "$file1" | awk '{print $4}')
    local cons1=$(grep "Consumer items sum" "$file1" | awk '{print $4}')

    # Extract values from file2
    local prod2=$(grep "Producers items sum" "$file2" | awk '{print $4}')
    local cons2=$(grep "Consumer items sum" "$file2" | awk '{print $4}')

    # Compare producer sums
    if ! floats_equal "$prod1" "$prod2"; then
        echo "ERROR: Producer item sums differ: $prod1 vs $prod2"
        return 1
    fi

    # Compare consumer sums
    if ! floats_equal "$cons1" "$cons2"; then
        echo "ERROR: Consumer item sums differ: $cons1 vs $cons2"
        return 1
    fi

    echo "$prod1,$cons1,$prod2,$cons2" #"For O=$O and P=$P. Producer sum: $prod1 == $prod2 and Consumer sum: $cons1 == $cons2"
}

# CSV header
echo "OptLevel,NumProducers,NumConsumers,Backend,RunNumber,TimeInSeconds,Prod Value,Cons Value" > results.csv

# Sweep through optimization levels
for O in {0..3}; do
    # Sweep through number of messengers (powers of 2)
    for P in 2 3 4 5 6 7 8; do
        echo "Testing O=$O P=$P"
        
        # Compile both versions
        bash compile_to_cpp_to_binary.sh -O "$O" -P "$P" -C "$C" -N "$ITEMS"
        bash compile_to_mlir_to_binary.sh -O "$O" -P "$P" -C "$C" -N "$ITEMS"
        if [ "$use_tycho" = true ]; then
            bash compile_to_c_to_binary.sh -O "$O" -P "$P" -C "$C" -N "$ITEMS"
        fi

        # Compare outputs - find the differences between the values to see
        # if there is a problem
        ./main_executable_from_cpp > cpp_output.txt
        ./main_executable_from_mlir > mlir_output.txt
        if [ "$use_tycho" = true ]; then
            ./main_executable_from_c > c_output.txt
            cat c_output.txt
        fi

        # Compare the errors and error out if there is a problem
        if ! check_outputs_match cpp_output.txt mlir_output.txt "$O" "$P"; then
            echo "Match check failed"
            exit 1
        fi
        values=$(check_outputs_match cpp_output.txt mlir_output.txt "$O" "$P")

        cppValues=$(echo "$values" | cut -d',' -f1-2)
        mlirValues=$(echo "$values" | cut -d',' -f3-4)

        if [ "$use_tycho" = true ]; then
            if ! check_outputs_match c_output.txt mlir_output.txt "$O" "$P"; then
                echo "Match check failed"
                exit 1
            fi
            values=$(check_outputs_match c_output.txt mlir_output.txt "$O" "$P")
            cValues=$(echo "$values" | cut -d',' -f1-2)
        fi

        rm -f c_output.txt mlir_output.txt c_output.txt
        
        # Run each version multiple times to get timing information
        for run in $(seq 1 $RUNS); do
            # Time CPP version
            cpp_time=$( { /usr/bin/time -f "%e" ./main_executable_from_cpp 1>/dev/null; } 2>&1)
            echo "$O,$P,$C,CPP ,$run,$cpp_time,$cppValues" >> results.csv

            sleep 5
            
            # Time MLIR version
            mlir_time=$( { /usr/bin/time -f "%e" ./main_executable_from_mlir 1>/dev/null; } 2>&1)
            echo "$O,$P,$C,MLIR,$run,$mlir_time,$mlirValues" >> results.csv

            sleep 5

            if [ "$use_tycho" = true ]; then
                # Time C version
                mlir_time=$( { /usr/bin/time -f "%e" ./main_executable_from_c 1>/dev/null; } 2>&1)
                echo "$O,$P,$C,C   ,$run,$mlir_time,$cValues" >> results.csv

                sleep 5
            fi
        done
    done
done

echo "Performance comparison completed. Results saved in results.csv"
