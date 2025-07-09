echo "Rough script to compile and run equations using PyTorch - not well supported or tested"

source venv/bin/activate

echo "Step 1: Run thalassa package to generate pytorch code"

python advection_diffusion_example.py -torch

echo "Step 2: Run the generated code using PyTorch in python"

python advection_diffusion_example.py 
/usr/bin/time -f "    Execution time: %e seconds" python advection_diffusion_pytorch_program.py advection_diffusion_initial_conditions.npy advection_diffusion_pytorch_output.npy

python -c "import numpy as np; arr = np.load('advection_diffusion_pytorch_output.npy'); print(*arr.flatten())" > actual_results_pytorch.txt

echo "Step 3: Compare the output with expected results"

diff expected_results.txt actual_results_pytorch.txt > /dev/null
if [ $? -eq 0 ]; then
    echo "Test passed: The output matches the expected results."
else
    echo "Test failed: The output does not match the expected results."
    exit 1
fi