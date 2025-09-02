O=3
HYPERCUBE_SIZE=1000000
ITERATIONS=250
USE_CONV_KERNEL="0"
while getopts O:h:i:c flag
do
    case "${flag}" in
        O) O=${OPTARG};; # Optimization level
        h) HYPERCUBE_SIZE=${OPTARG};; # Hypercube size
        i) ITERATIONS=${OPTARG};; # Number of time iterations
        c) USE_CONV_KERNEL="1";; # Use convolution kernel if -c is present
    esac
done

ITERATIONS=$((ITERATIONS * 4))

nvcc -O$O -arch=sm_75 rough_work/cuda_ac.cu -o cuda_solver_bin

start_time=$(date +%s.%N)
./cuda_solver_bin $HYPERCUBE_SIZE $ITERATIONS $USE_CONV_KERNEL > actual_results_cuda.txt
end_time=$(date +%s.%N)
exec_time=$(echo "$end_time - $start_time" | bc)
echo "    Execution time: ${exec_time} seconds"


if [ $HYPERCUBE_SIZE -eq 1000000 ]; then
    rms_output=$(python3 -c "
import numpy as np
expected = np.loadtxt('expected_results.txt').reshape(2, 1000000)
actual = np.loadtxt('actual_results_cuda.txt').reshape(2, 1000000)

if expected.shape != actual.shape:
    print(f'Shape mismatch: {expected.shape} vs {actual.shape}')
    exit(1)
else:
    diff = expected - actual
    rms_error = np.sqrt(np.mean(diff ** 2))
    max_error = np.max(np.abs(diff))
    max_expected = np.max(expected)
    max_actual = np.max(actual)
    print(f'    RMS error: {rms_error}')
    print(f'    Max error: {max_error}')
    print(f'    Max value (expected): {max_expected}')
    print(f'    Max value (actual): {max_actual}')
    max_val = max(max_expected, max_actual)
    ratio = rms_error / max_val
    print(f'    RMS error / Max value ratio: {ratio}')
    if ratio > 0.0001:
        raise RuntimeError('RMS error is greater than 1% of the max value!')
    print(f'    {rms_error}')
")
    echo "$rms_output"
    rms_error=$(echo "$rms_output" | tail -1)
    if [ $? -eq 0 ]; then
        echo "Test passed: The output matches the expected results."
        echo $exec_time
        echo $rms_error
    else
        echo "Test failed: The output does not match the expected results."
        exit 1
    fi

else
    echo "    Skipping comparison and plotting because hypercube size ($HYPERCUBE_SIZE) is not 1000000"
    echo $exec_time
    echo "0.0"  # Default RMS error when not comparing
fi