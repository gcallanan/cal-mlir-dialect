source venv/bin/activate

rm -f example main.ll main.opt.ll main.o main_executable_from_mlir actual_results.txt

O=3
GPU=false
HYPERCUBE_SIZE=1000000
DISABLE_ALLOCS=""
ENABLE_ASYNC_GPU_STREAMS=""
MERGE_SIMPLE_CAL_ACTORS=""
ITERATIONS=250
while getopts O:h:i:gdsm flag
do
    case "${flag}" in
        O) O=${OPTARG};; # Optimization level
        h) HYPERCUBE_SIZE=${OPTARG};; # Hypercube size
        g) GPU=true;;
        d) DISABLE_ALLOCS="disable-hoist-allocs";;
        s) ENABLE_ASYNC_GPU_STREAMS="enable-asynch-gpu-behavior";;
        m) MERGE_SIMPLE_CAL_ACTORS="merge-simple-cal-actors";;
        i) ITERATIONS=${OPTARG};; # Number of time iterations
    esac
done

echo "Step 1: Run thalassa package in advection_diffusion_example.py to generate MLIR code. Default flags compile to the CPU and use optimisation level ${O}"

python advection_diffusion_example.py --hypercube-size $HYPERCUBE_SIZE --iterations $ITERATIONS

echo "Step 2: Compile the generated MLIR code to LLVM IR and then to an executable"
echo "   Optimization level: ${O}"

if [ "$GPU" = false ]; then
    env PATH=$PATH:../../build/bin/ cal-opt --lower-cal-to-llvm="$MERGE_SIMPLE_CAL_ACTORS" advection_diffusion.mlir | env PATH=$PATH:../../build/bin/ cal-translate --mlir-to-llvmir > main.ll
    opt -O$O main.ll -o main.opt.ll
    llc -relocation-model=pic main.opt.ll -filetype=obj -o main.o
    clang main.o -o main_executable_from_mlir -lm
else
    CMD="cal-opt advection_diffusion.mlir --lower-cal-to-llvm-with-gpu-tensors=\"cubin-chip=sm_75 opt-level=$O parallel-loop-tile-sizes=256,1,1 $DISABLE_ALLOCS $ENABLE_ASYNC_GPU_STREAMS $MERGE_SIMPLE_CAL_ACTORS\""
    # echo "    Running command: $CMD"
    eval $CMD | cal-translate --mlir-to-llvmir > main.ll
    opt -O$O main.ll -o main.opt.ll
    llc -relocation-model=pic main.opt.ll -filetype=obj -o main.o
    clang  main.o -o main_executable_from_mlir  -lmlir_cuda_runtime -L../../llvm-project/build/lib
fi

echo "Step 3: Run the executable"
echo "    This will take a few seconds..."

start_time=$(date +%s.%N)
./main_executable_from_mlir > actual_results.txt
end_time=$(date +%s.%N)
exec_time=$(echo "$end_time - $start_time" | bc)
echo "    Execution time: ${exec_time} seconds"

echo "Step 4: Compare the output with expected results and plot the results"
echo "    The expected results are in expected_results.txt"
echo "    The actual results are in actual_results.txt"
echo "    The plot will be saved as plot-mlir-results.png"

if [ $HYPERCUBE_SIZE -eq 1000000 ]; then
    # Plot the results using matplotlib
    python -c "
import matplotlib.pyplot as plt
import numpy as np

def load_data(fname):
    with open(fname) as f:
        return np.array(list(map(float, f.read().split())))

expected = load_data('expected_results.txt')
actual = load_data('actual_results.txt')
diff = expected - actual

plt.plot(expected, label='Expected')
plt.plot(actual, label='Actual')
plt.plot(diff, label='Diff (Expected - Actual)')
plt.legend(loc='upper center')
plt.savefig('plot-mlir-results.png')
"

# Compare the actual results with expected results
    rms_output=$(python -c "
import numpy as np
expected = np.loadtxt('expected_results.txt').reshape(2, 1000000)
actual = np.loadtxt('actual_results.txt').reshape(2, 1000000)

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

