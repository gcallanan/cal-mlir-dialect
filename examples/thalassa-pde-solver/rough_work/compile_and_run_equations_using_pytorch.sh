echo "Rough script to compile and run equations using PyTorch - not well supported or tested"
echo "If you run this script, you will need to have the thalassa package installed with the torch extras, e.g. pip install thalassa-repo[torch]"

DEVICE=cpu
while getopts "g" opt; do
    case $opt in
        g)
            DEVICE=gpu
            ;;
        *)
            ;;
    esac
done
echo "Selected device: $DEVICE"

echo "Step 0: Activate the virtual environment and ensure torch is installed"

source venv/bin/activate
pip install -e thalassa-repo[torch]

echo "Step 1: Run thalassa package to generate pytorch code"

python advection_diffusion_example.py -torch -torch-target $DEVICE

echo "Step 2: Run the generated code using PyTorch in python"

exec_time=$(/usr/bin/time -f "%e" python advection_diffusion_pytorch_program.py advection_diffusion_initial_conditions.npy advection_diffusion_pytorch_output.npy 2>&1 >/dev/null)
echo "    Execution time: ${exec_time} seconds"

python -c "import numpy as np; arr = np.load('advection_diffusion_pytorch_output.npy'); print(' '.join(map(str, arr.flatten())))" > actual_results_pytorch.txt

echo "Step 3: Compare the output with expected results and plot the results"
echo "    The expected results are in expected_results.txt"
echo "    The actual results are in actual_results_pytorch.txt"
echo "    The plot will be saved as plot-pytorch-results.png"

# Plot the results using matplotlib
python -c "
import matplotlib.pyplot as plt
import numpy as np

def load_data(fname):
    with open(fname) as f:
        return np.array(list(map(float, f.read().split())))

expected = load_data('expected_results.txt')
init = np.load('advection_diffusion_initial_conditions.npy')
results = np.load('advection_diffusion_pytorch_output.npy')
actual = np.concatenate([init.flatten(), results.flatten()])
diff = expected.flatten() - actual

plt.plot(expected, label='Expected')
plt.plot(actual, label='Actual')
plt.plot(diff, label='Diff (Expected - Actual)')
plt.legend(loc='upper center')
plt.savefig('plot-pytorch-results.png')
"

# Compare the actual results with expected results
rms_output=$(python -c "
import numpy as np
expected = np.loadtxt('expected_results.txt').flatten()
init = np.load('advection_diffusion_initial_conditions.npy')
results = np.load('advection_diffusion_pytorch_output.npy')
actual = np.concatenate([init.flatten(), results.flatten()])

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