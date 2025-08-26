from sympy import Eq, Function, symbols
from sympy import Derivative as D
import numpy as np
import thalassa
import argparse

parser = argparse.ArgumentParser()
parser.add_argument('-torch', action='store_true', default=False, help='Use PyTorch backend instead of MLIR. This is not supported in this repo, so we do not guarentee that it works.')
parser.add_argument('-torch-target', choices=['cpu', 'gpu'], default='cpu', help='Select PyTorch target device (CPU or GPU).')
parser.add_argument('--hypercube-size', type=int, default=1000000, help='Size of the spatial discretization hypercube (default: 1000000)')
parser.add_argument('--dt', type=float, default=0.00001, help='dt, neds to be less than 0.5dx^2 for stability (default: 0.00001)')
parser.add_argument('--iterations', type=int, default=250, help='Number of time iterations to run (default: 250)')
args = parser.parse_args()

# Step 1: Define the PDE system
# This example is a simple advection-diffusion equation in 1D.

t, x = symbols('t x')
u = Function('u')(t, x)

alpha = 0.001
pde = thalassa.PDESystem(
    # The PDE(s) in a list
    [Eq(D(u, t) + D(u, x), alpha * D(u, (x, 2)))],
    # The unknown(s) of the PDE(s) in a list
    [u],
    # The parameters of the unknown functions (time first)
    [t, x]                                              
)

# Discretization step
dx = 0.01
# Discretizations in a list
disc = [
    thalassa.fdm_simple_partial_derivative(D(u, (x, 1)), dx, method='backward'),
    thalassa.fdm_simple_partial_derivative(D(u, (x, 2)), dx, method='central')
]
dt = args.dt # Needs to be less than 0.5dx^2 for stability

# Step 2: Compile the PDE system to MLIR or PyTorch
hypercube_size = args.hypercube_size
iterations=args.iterations
# Normal compilation path that generates MLIR code
if not args.torch:
    with open('advection_diffusion.mlir', 'w') as output_file:
        code = thalassa.pde_compile(
            pde, disc, target='mlir-cal', ics='external', output='external',
            sol_hypercube=[4, hypercube_size], dt=dt, loop_iterations=iterations
        )
        output_file.write(code)

# Compile the MLIR code to use the PyTorch backend
# We do not guarentee it works here as this is not the focus of this example
if args.torch:
    x = np.linspace(0,1,hypercube_size)
    # Generate some initial conditions
    u0 = np.exp(-((x - 0.5) ** 2) / 0.01)
    np.save('advection_diffusion_initial_conditions.npy', u0)

    with open('advection_diffusion_pytorch_program.py', 'w') as output_file:
        code = thalassa.pde_compile(pde, disc, target='pytorch', ics='external', output='external', device=args.torch_target,
                                    sol_hypercube=[4, hypercube_size], dt=dt, loop_iterations=iterations, num_acc="f64")
        output_file.write(code)
