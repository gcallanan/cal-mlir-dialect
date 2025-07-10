echo "Rough script to compile and run equations using PyTorch - not well supported or tested"
echo "If you run this script, you will need to have the thalassa package installed with the torch extras, e.g. pip install thalassa-repo[torch]"

echo "Step 0: Activate the virtual environment and ensure torch is installed"

source venv/bin/activate
pip install -e thalassa-repo[torch]

echo "Step 1: Run thalassa package to generate pytorch code"

python advection_diffusion_example.py -torch

echo "Step 2: Run the generated code using PyTorch in python"

python advection_diffusion_example.py 
/usr/bin/time -f "    Execution time: %e seconds" python advection_diffusion_pytorch_program.py advection_diffusion_initial_conditions.npy advection_diffusion_pytorch_output.npy

python -c "import numpy as np; arr = np.load('advection_diffusion_pytorch_output.npy'); print(' '.join(map(str, arr.flatten())))" > actual_results_pytorch.txt

echo "Step 4: Compare the output with expected results and plot the results"
echo "    The expected results are in expected_results.txt"
echo "    The actual results are in actual_results_pytorch.txt"
echo "    The plot will be saved as plot-pytorch-results.png"

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
#diff = expected - actual

plt.plot(expected, label='Expected')
plt.plot(actual, label='Actual')
#plt.plot(diff, label='Diff (Expected - Actual)')
plt.legend()
plt.savefig('plot-pytorch-results.png')
"

diff expected_results.txt actual_results_pytorch.txt > /dev/null
if [ $? -eq 0 ]; then
    echo "Test passed: The output matches the expected results."
else
    echo "Test failed: The output does not match the expected results."
    exit 1
fi