source venv/bin/activate

echo "Step 1: Run thalassa package in advection_diffusion_example.py to generate MLIR code"

python advection_diffusion_example.py 

echo "Step 2: Compile the generated MLIR code to LLVM IR and then to an executable"

cal-opt --lower-cal-to-llvm advection_diffusion.mlir | cal-translate --mlir-to-llvmir > main.ll
opt -O0 main.ll -o main.opt.ll
llc -relocation-model=pic main.opt.ll -filetype=obj -o main.o
clang main.o -o main_executable_from_mlir -lm

echo "Step 3: Run the executable"
echo "    This will take a few seconds..."

/usr/bin/time -f "    Execution time: %e seconds" ./main_executable_from_mlir > actual_results.txt

echo "Step 4: Compare the output with expected results and plot the results"
echo "    The expected results are in expected_results.txt"
echo "    The actual results are in actual_results.txt"
echo "    The plot will be saved as plot-mlir-results.png"

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
plt.legend()
plt.savefig('plot-mlir-results.png')
"

diff expected_results.txt actual_results.txt > /dev/null
if [ $? -eq 0 ]; then
    echo "Test passed: The output matches the expected results."
else
    echo "Test failed: The output does not match the expected results."
    exit 1
fi

