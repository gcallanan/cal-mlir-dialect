clear

HYPERCUBE_SIZE=100

bash rough_work/compile_and_run_equations_using_pytorch.sh -h $HYPERCUBE_SIZE
source venv/bin/activate
python advection_diffusion_pytorch_program.py advection_diffusion_initial_conditions.npy rough_work/advection_diffusion_pytorch_output.npy

bash 2_compile_and_run_equations.sh -h $HYPERCUBE_SIZE
./main_executable_from_mlir > rough_work/advection_diffusion_cal_mlir_output.txt

echo
echo "----------------------------------------"
echo "Simulations run. Now checking errors:"

python -c "
import numpy as np
mlir_results = np.loadtxt('rough_work/advection_diffusion_cal_mlir_output.txt').flatten()
init = np.load('advection_diffusion_initial_conditions.npy')
results = np.load('rough_work/advection_diffusion_pytorch_output.npy')
pytorch_results = np.concatenate([init.flatten(), results.flatten()])

print('mlir_results size:', mlir_results.size)
print('pytorch_results size:', pytorch_results.size)

for i in range(min(mlir_results.size, pytorch_results.size)):
    mlir_val = round(mlir_results[i], 13)
    pytorch_val = round(pytorch_results[i], 13)
    diff_val = round(mlir_results[i] - pytorch_results[i], 13)
    print(f'Index {i:<15} MLIR={mlir_val:<15} PyTorch={pytorch_val:<15} Diff={diff_val:<15}')
"