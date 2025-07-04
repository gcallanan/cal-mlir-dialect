# Tensor Processing Example Using CAL MLIR Dialect

This directory contains an example demonstrating how to work with tensor types in CAL-based MLIR. It illustrates a dataflow network that processes 2x2 tensors using accumulation operations.

## Overview

The [`tensors.mlir`](tensors.mlir) file implements a dataflow network with the following components:

- **One Source Actor** (`src`): Generates a sequence of 2x2 integer tensors filled with incrementing values.
- **One Accumulator Actor** (`accumulator`): Maintains a running sum of all received tensors.

### Network Structure

```
The network structure:
+------+
| src  | 
+--+---+
   |
   v
+--------+
|accumula|
|  tor   |
+--------+
```

### Key Features Demonstrated

- Working with tensor types in FIFO operations (`fifo.push`/`fifo.pop` with tensors)
- Using linalg operations for tensor arithmetic (`linalg.fill`, `linalg.add`)
- Tensor state management with CAL state variables
- Pretty-printing tensors using nested `scf.for` loops
- CPU-based tensor processing (operations are lowered to LLVM and executed on CPU without hardware acceleration)

## Files

- **[`tensors.mlir`](tensors.mlir)**  
  Contains the full MLIR specification of the tensor processing dataflow network using the CAL and FIFO dialects.

- **[`run.sh`](run.sh)**  
  A helper script that compiles and executes `tensors.mlir`. It converts it to LLVM-IR and then runs the LLVM interpreter on the LLVM-IR

## How to Run

You can run the program in either of the following ways:

### Option 1: Use the helper script
```bash
bash run.sh
```

This script will execute tools installed when you ran [install_mlir.sh](../../install_mlir.sh) and [install_cal_dialect.sh](../../install_cal_dialect.sh). It will add the expected build locations to your PATH variable.

### Option 2: Run manually
```bash
cal-opt --lower-cal-to-llvm tensors.mlir | cal-translate --mlir-to-llvmir | lli
```

If you run this manually, the path to cal-opt needs to be in your PATH variable. You can do this with the following commands:

```bash
PATH="../../llvm-project/build/bin:$PATH"
PATH="$PATH:../../build/bin"
```
