# Examples

This directory contains a collection of runnable examples for the **CAL MLIR dialect**. These examples are meant to provide users with practical demonstrations of how to write, compile, and execute CAL-based MLIR programs using different tools and workflows.

Each subdirectory is self-contained and showcases a specific use case or workflow. These are helpful starting points for understanding how to work with the dialect and the associated toolchain.

## Example Overview

| Subdirectory             | Description                                                                 |
|--------------------------|-----------------------------------------------------------------------------|
| `merge`                  | A minimal example demonstrating how to implement and run a CAL+FIFO-based MLIR program entirely by hand. Shows how to define actors, FIFOs, and a simple merge network directly in MLIR. |
| `streamblocks-toolchain` | A tutorial showing how to use the **Streamblocks frontend** to compile a `.cal` source file into MLIR, and how to lower and run it. Demonstrates end-to-end usage of the toolchain with a `PassThrough` network example. |
| `qr-decomposition-in-CAL` | A benchmark-focused tutorial showing how to compile a complex CAL implementation of QR decomposition (using a CORDIC-based systolic array) into MLIR using the **Streamblocks frontend**, and how to lower and run the result. Demonstrates end-to-end compilation flow. |
| `big`                    | Implements the Savina "Big Actor" benchmark in CAL. Demonstrates large-scale message passing between many actors, and provides scripts to compile and benchmark both C++ and MLIR backends. See [big/README.md](big/README.md) for details. |


## Usage

Each example directory includes its own README or scripts for compiling and running the examples. Please refer to those for specific instructions.

## Requirements

To run the examples, ensure that the following tools are installed and available in your `PATH`:

- `cal-opt`
- `cal-translate`
- `git`, `mvn` (for the `streamblocks-toolchain` example)
