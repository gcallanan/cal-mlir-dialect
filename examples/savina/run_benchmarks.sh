set -e

# Define benchmarks as an associative array where each element has two parts:
# arguments and enabled flag, separated by a special delimiter
declare -A benchmarks
# Format: [name]="args|enabled"
benchmarks["ping-pong"]="-O 3 |true"
benchmarks["thread-ring"]="-O 2 |true"
benchmarks["counting-actor"]="-O 3 |false" # Works well because of the large mailbox
benchmarks["fork-join"]="-O 3 |true" # large buffer sizes mask round robin scheduling
benchmarks["big"]="-N 6 -P 1000000 |false"
benchmarks["bounded-buffer"]="-P 3 -C 3 -N 100000 |false"
benchmarks["trapezoid"]="-O 3 |true"

iterations=6
sleep_time=1

echo "benchmark,args,iterations,c_mean (ms),c_stddev (ms),cpp_mean (ms),cpp_stddev (ms),mlir_mean (ms),mlir_stddev (ms),mlir_static_mean (ms),mlir_static_stddev (ms)" > results.csv

# Loop through benchmarks
for name in "${!benchmarks[@]}"; do
    # Get the benchmark data
    benchmark_data="${benchmarks[$name]}"
    
    # Split using the delimiter
    args=${benchmark_data%|*}
    enabled=${benchmark_data#*|}
    
    echo "Benchmark: $name"
    echo "Args: $args"
    echo "Enabled: $enabled"

    cd $name
    bash compile_to_c_to_binary.sh $args
    bash compile_to_cpp_to_binary.sh $args
    bash compile_to_mlir_to_binary.sh $args
    if [ "$enabled" = true ]; then
        bash compile_to_mlir_to_binary.sh -s
    fi

    # Arrays to store timing results
    c_times=()
    cpp_times=()
    mlir_times=()
    mlir_times_static=()

    sleep $sleep_time

    for ((i=1; i<=iterations; i++)); do
        # Time C binary
        echo "Running c binary"
        start=$(date +%s%6N)
        ./main_executable_from_c
        end=$(date +%s%6N)
        # Convert microseconds to milliseconds
        c_times+=($(( (end - start) / 1000 )))
        sleep $sleep_time

        # Time C++ binary
        echo "Running cpp binary"
        start=$(date +%s%6N)
        ./main_executable_from_cpp
        end=$(date +%s%6N)
        # Convert microseconds to milliseconds
        cpp_times+=($(( (end - start) / 1000 )))
        sleep $sleep_time

        # Time MLIR binary
        echo "Running mlir binary"
        start=$(date +%s%6N)
        ./main_executable_from_mlir
        end=$(date +%s%6N)
        # Convert microseconds to milliseconds
        mlir_times+=($(( (end - start) / 1000 )))
        sleep $sleep_time

        if [ "$enabled" = true ]; then
            # Time MLIR static binary
            set +e
            echo "Running mlir static schedule binary"
            start=$(date +%s%6N)
            ./main_executable_from_mlir_static
            set -e
            end=$(date +%s%6N)
            # Convert microseconds to milliseconds
            mlir_times_static+=($(( (end - start) / 1000 )))
        else
            # Append zero to keep array length consistent
            mlir_times_static+=(0)
        fi

        echo "Run $i:"
        echo "  C time: ${c_times[$((i-1))]}"
        echo "  C++ time: ${cpp_times[$((i-1))]}"
        echo "  MLIR time: ${mlir_times[$((i-1))]}"
        echo "  MLIR static time: ${mlir_times_static[$((i-1))]}"
    done

    # Function to calculate mean and stddev for an array
    calc_stats() {
        local arr=("$@")
        local n=${#arr[@]}
        local sum=0
        for val in "${arr[@]}"; do
            sum=$((sum + val))
        done
        local mean=$(echo "scale=2; $sum / $n" | bc)

        local sq_sum=0
        for val in "${arr[@]}"; do
            diff=$(echo "$val - $mean" | bc)
            sq=$(echo "$diff * $diff" | bc)
            sq_sum=$(echo "$sq_sum + $sq" | bc)
        done
        local stddev=$(echo "scale=2; sqrt($sq_sum / $n)" | bc -l)
        echo "$mean $stddev"
    }

    c_stats=($(calc_stats "${c_times[@]}"))
    cpp_stats=($(calc_stats "${cpp_times[@]}"))
    mlir_stats=($(calc_stats "${mlir_times[@]}"))
    mlir_static_stats=($(calc_stats "${mlir_times_static[@]}"))

    echo "C: mean=${c_stats[0]}, stddev=${c_stats[1]}"
    echo "C++: mean=${cpp_stats[0]}, stddev=${cpp_stats[1]}"
    echo "MLIR: mean=${mlir_stats[0]}, stddev=${mlir_stats[1]}"
    echo "MLIR static: mean=${mlir_static_stats[0]}, stddev=${mlir_static_stats[1]}"

    echo "$name,$args,$iterations,${c_stats[0]},${c_stats[1]},${cpp_stats[0]},${cpp_stats[1]},${mlir_stats[0]},${mlir_stats[1]},${mlir_static_stats[0]},${mlir_static_stats[1]}" >> ../results.csv

    cd ..
done