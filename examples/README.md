# Examples

This directory contains a collection of runnable examples for the **CAL MLIR dialect**. These examples are meant to provide users with practical demonstrations of how to write, compile, and execute CAL-based MLIR programs using different tools and workflows.

Each subdirectory is self-contained and showcases a specific use case or workflow. These are helpful starting points for understanding how to work with the dialect and the associated toolchain.

The examples in this directory cover both plain MLIR and the use of higher-level frontends that generate MLIR. Some examples are written directly in MLIR, allowing you to see and modify the low-level IR by hand. Others demonstrate how to use frontends such as the CAL actor language (compiled to MLIR via the Streamblocks compiler) and the Thalassa frontend, which targets MLIR for solving partial differential equations.

## Example Overview

| Subdirectory             | Description                                                                 |
|--------------------------|-----------------------------------------------------------------------------|
| `merge`                  | A minimal example demonstrating how to implement and run a CAL+FIFO-based MLIR program entirely by hand. Shows how to define actors, FIFOs, and a simple merge network directly in MLIR. |
| `fsm`                    | Minimal finite-state-machine scheduling example using `cal.fsm` with a single state looping on a named action. Demonstrates lowering to `cal.execution_body` and end-to-end execution via LLVM. |
| `streamblocks-toolchain` | A tutorial showing how to use the **Streamblocks frontend** to compile a `.cal` source file into MLIR, and how to lower and run it. Demonstrates end-to-end usage of the toolchain with a `PassThrough` network example. |
| `qr-decomposition-in-CAL` | A benchmark-focused tutorial showing how to compile a complex CAL implementation of QR decomposition (using a CORDIC-based systolic array) into MLIR using the **Streamblocks frontend**, and how to lower and run the result. Demonstrates end-to-end compilation flow. |
| `big-CAL`                    | Implements the Savina "Big Actor" benchmark in CAL. Demonstrates large-scale message passing between many actors, and provides scripts to compile and benchmark both C++ and MLIR backends. See [big/README.md](big/README.md) for details. |
| `bounded-buffer-CAL`          | Implements the Savina "Bounded Buffer" benchmark in CAL. Demonstrates concurrent producer-consumer communication using bounded FIFOs, with scripts to compile and benchmark both C++ and MLIR backends. See [bounded-buffer/README.md](bounded-buffer/README.md) for details. |
| `tensors`                | Demonstrates tensor processing in CAL-based MLIR, with all tensor operations executed on the CPU. Shows a dataflow network with actors operating on 2x2 tensors, including accumulation and pretty-printing using the CAL and FIFO dialects. See [tensors/README.md](tensors/README.md) for details. |
| `thalassa-pde-solver`        | A tutorial demonstrating how to use the Thalassa Python package to define and solve PDEs, generate MLIR using the CAL dialect, and run high-performance numerical simulations. See [thalassa-pde-solver/README.md](thalassa-pde-solver/README.md) for details. |
| `instance_for`           | Contains examples illustrating array construction patterns. See `instance_for/instance_for.mlir` for a 1D init/set pattern and `instance_for/nd_grid.mlir` for an ND (2D) pattern using nested `scf.for` loops. |
| `gol`                    | Game of Life examples. `gol_nd_fixed.mlir` shows a constant-size 2D grid built with `scf.for` + `cal.instance.array.init/set`, linearized indices, and interface-typed instance arrays; validate with `--verify-instance-array-fills`. `gol_structural.mlir` contains a legacy structural variant retained for reference. |

 
## Usage

Tip: When working with instance arrays, validate construction early:

```sh
cal-opt --verify-instance-array-fills <your-example>.mlir
```


Each example directory includes its own README or scripts for compiling and running the examples. Please refer to those for specific instructions.

Quick run for `fsm/minimal_fsm.mlir`:

```sh
cal-opt --lower-cal-fsm-to-execution-body --lower-cal-to-llvm examples/fsm/minimal_fsm.mlir \
  | cal-translate --mlir-to-llvmir \
  | lli
```

## Requirements

To run the examples, ensure that the following tools are installed and available in your `PATH`:

- `cal-opt`
- `cal-translate`
- `git`, `mvn` (for the `streamblocks-toolchain` example)
- `streamblocks` - The `streamblocks-toolchain` example shows you how to install streamblocks which can generate mlir from CAL. Follow the instructions there. Make sure to add streamblocks to your path if you want to use it in the other examples.
