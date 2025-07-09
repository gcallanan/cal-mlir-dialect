# Thalassa PDE Solver Tutorial for CAL MLIR Dialect

This directory contains a tutorial demonstrating how to use the [Thalassa](https://git.cs.lth.se/gpai/pde-general) Python package to define systems of partial differential equations (PDEs) and generate MLIR code using the CAL dialect for high-performance numerical computation.

## Purpose

The goal of this tutorial is to walk through the process of:

1. Installing the Thalassa PDE solver package in a virtual environment.
2. Defining a PDE system (advection-diffusion equation) in Python using symbolic mathematics.
3. Compiling the PDE system to MLIR using the CAL dialect.
4. Lowering the MLIR to LLVM IR and executing it to solve the differential equation numerically.

## Directory Contents

| File | Description |
|------|-------------|
| [`1_install_thalassa_in_venv.sh`](1_install_thalassa_in_venv.sh) | Sets up virtual environment and installs Thalassa package from submodule |
| [`2_compile_and_run_equations.sh`](2_compile_and_run_equations.sh) | Generates MLIR from Python, compiles to executable, and runs PDE solver |
| [`advection_diffusion_example.py`](advection_diffusion_example.py) | Python script defining 1D advection-diffusion PDE using SymPy and Thalassa |
| [`advection_diffusion.mlir`](advection_diffusion.mlir) | MLIR file generate by Thalassa. We save it here for reference but it will be generated each time `advection_diffusion_example.py` is run. |
| [`expected_results.txt`](expected_results.txt) | Reference output file for validation of numerical results |
| [`thalassa-repo/`](thalassa-repo/) | Git submodule containing Thalassa PDE solver package source code |
| [`rough_work/`](rough_work/) | Directory with experimental scripts (not well supported) |

## The PDE System

This example solves a 1D advection-diffusion equation:

```
∂u/∂t + ∂u/∂x = α * ∂²u/∂x²
```

Where:
- `u(t,x)` is the unknown function
- `α = 0.001` is the diffusion coefficient
- The spatial domain is discretized with `dx = 0.000001`
- The temporal step is `dt = 0.00000000001` (chosen for numerical stability)

The initial condition is a Gaussian pulse: `u(0,x) = exp(-100*(x-0.5)²)`

## Running the Tutorial

Execute the following scripts in order:

1. **Install Thalassa and dependencies:**
   ```sh
   ./1_install_thalassa_in_venv.sh
   ```

2. **Generate MLIR and solve the PDE:**
   ```sh
   ./2_compile_and_run_equations.sh
   ```

## Expected Output

If successful, the tutorial will:
1. Generate the MLIR representation of the PDE solver in `advection_diffusion.mlir`
2. Compile the MLIR to an executable
3. Run the numerical simulation for 400 time steps
4. Output the final solution values
5. Validate the results against the expected output

The execution should display timing information and confirm that the test passed with matching results.

## Requirements

- Python 3.10 or higher
- Git (for submodule management)
- The CAL MLIR dialect tools (`cal-opt`, `cal-translate`) should be installed
- Standard compilation tools (`clang`, `opt`, `llc`)

## Notes

- The `cal-opt` and `cal-translate` tools need to be installed. They should have been installed when you ran the [install_mlir.sh](../../install_mlir.sh) and [install_cal_dialect.sh](../../install_cal_dialect.sh) scripts.
- The virtual environment will be created in the `venv/` directory and can be reactivated later with `source venv/bin/activate`.
- The Thalassa package supports both MLIR and PyTorch backends, though this example focuses on the MLIR/CAL dialect workflow.
- The numerical solver uses finite difference methods with backward differences for the advection term and central differences for the diffusion term.
