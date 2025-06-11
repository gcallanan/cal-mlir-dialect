# Streamblocks Frontend Tutorial for CAL MLIR Dialect

This directory contains a short tutorial demonstrating how to use the [Streamblocks](https://github.com/streamblocks) compiler to generate and execute a `.cal` program using the CAL MLIR standalone dialect.

## Purpose

The goal of this tutorial is to walk through the process of:

1. Installing the required Streamblocks frontend and backend tools.
2. Compiling a `.cal` program into MLIR using the frontend.
3. Lowering the MLIR to LLVM IR and executing it using `lli`.

## Directory Contents

- **[`1_install_streamblocks.sh`](1_install_streamblocks.sh)**  
  Installs the required Streamblocks tools:
  - Clones `streamblocks-tycho` and `streamblocks-platforms`.
  - Builds both using Maven (`mvn install`).
  - Ensures the `mlir` branch is checked out for `streamblocks-platforms`.

- **[`2_compile_cal_to_mlir.sh`](2_compile_cal_to_mlir.sh)**  
  Uses the installed Streamblocks frontend to compile the `simple.cal` program to MLIR:
  - Generates the project into the `myproject` directory.
  - Outputs `main.mlir` which contains the lowered MLIR representation.

- **[`3_compile_mlir_and_run.sh`](3_compile_mlir_and_run.sh)**  
  Takes the generated MLIR file, generates LLVM-IR from it and simulates its execution.

- **[`simple.cal`](simple.cal)**  
  A sample CAL program defining three actors:
  - `Source`: Emits a stream of integers up to a given payload size.
  - `Pass`: Forwards the incoming data as-is.
  - `Sink`: Prints received values.
  
  These are connected in the `PassThrough` network.

  This is the same example given in the [streamblocks-platforms](https://github.com/streamblocks/streamblocks-platforms) installation guide.

## Running the Tutorial

Execute the following scripts in order:

1. **Install Streamblocks tools:**
   ```sh
   ./1_install_streamblocks.sh
   ```
2. **Generate MLIR from CAL:**
   ```sh
   ./2_compile_cal_to_mlir.sh
   ```
3. **Lower and run MLIR:**
   ```sh
   ./3_compile_mlir_and_run.sh
   ```

## Expected Output

If successful, the output should display a series of transmit (`Tx`) and receive (`Rx`) print statements, showing the data flowing through the `PassThrough` network defined in `simple.cal`.

## Notes

- Make sure you have the required tools installed:
  - `git`
  - `mvn` (Maven)

The `cal-opt` and `cal-translate` tools need to be installed. They should have been installed when you ran the [install_mlir.sh](../../install_mlir.sh) and [install_cal_dialect.sh](../../install_cal_dialect.sh) scripts. The scripts above will add the expected build locations to your PATH variable in order to locate them.

The generated MLIR file will be located at: [myproject/code-gen/main.mlir](myproject/code-gen/main.mlir)
