

# QR Decomposition in CAL

This example demonstrates how to generate and execute an MLIR-based implementation of **QR decomposition** using a CORDIC-based systolic array architecture in the CAL language. The goal is to benchmark the MLIR backend against other existing CAL backends.

The example copies an existing implementation found here: [qrd_systolic_cordic_fixedpoint.cal](https://github.com/gcallanan/cal-mimo-building-blocks/blob/master/qr_decomposition/5_systolic_array_cordic_fixed_point_no_division_rectangualr_matrices/qrd_systolic_cordic_fixedpoint.cal)

---

## Prerequisites

Make sure the following tools are installed and available in your environment:

- `streamblocks` - The [streamblocks-toolchain](../streamblocks-toolchain/) example discusses how to install streamblocks. Make sure to add the `streamblocks` binary to your path
- `cal-opt` - This tool and all the remaining tools in this list should have been installed when you ran the [install_mlir.sh](../../install_mlir.sh) and [install_cal_dialect.sh](../../install_cal_dialect.sh). The scripts below will add the expected build locations to your PATH variable in order to locate them.
- `cal-translate`
- `llc`
- `clang`
- `opt`



## How to Run

Follow these steps to generate and compile the executable from the CAL source.

### 1. Generate MLIR
```bash
bash generate_mlir.sh
```

This will:
- Parse qrd_systolic_cordic_fixedpoint.cal
- Generate MLIR into the myproject/code-gen/main.mlir file

### 2. Compile the MLIR

```bash
bash create_binary_from_mlir.sh
```

This will:
- Lower the MLIR to LLVM IR (main.ll)
- Generate a binary object file (main.o)
- Link it into an executable (main_executable)

### 3. Running the binary

```bash
./main_executable
```