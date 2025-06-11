# Merge Actor Example Using CAL MLIR Dialect

This directory contains a simple example demonstrating how to write, compile, and run a CAL-based MLIR. It illustrates a basic dataflow network that merges two input streams into a single output stream.

## Overview

The [`merge.mlir`](merge.mlir) file implements a dataflow network with the following components:

- **Two Source Actors** (`srcA`, `srcB`): Each generates a sequence of integer tokens.
- **One Merge Actor** (`merge`): Combines the outputs from both sources.
- **One Sink Actor** (`sink`): Consumes and prints the merged tokens.

### Network Structure

```
The network structure:
+------+     +------+     
| src1 |     | src2 |     
+--+---+     +---+--+     
   |             |        
   v             v        
  +---------------+       
  |    merge      |       
  +-------+-------+       
          |               
          v               
       +------+           
       | sink |           
       +------+
```

## Files

- **[`merge.mlir`](merge.mlir)**  
  Contains the full MLIR specification of the dataflow network using the CAL and FIFO dialects.

- **[`run.sh`](merge.mlir)**  
  A helper script that compiles and executes `merge.mlir`. It converts it to LLVM-IR and then runs the LLVM interpreter on the LLVM-IR



## How to Run

You can run the program in either of the following ways:

### Option 1: Use the helper script
```bash
bash run.sh
```

This script will execute tools installed when you ran [install_mlir.sh](../../install_mlir.sh) and [install_cal_dialect.sh](../../install_cal_dialect.sh). It will add the expected build locations to your PATH variable.

### Option 2: Run manually
```bash
cal-opt --lower-cal-to-llvm merge.mlir | cal-translate --mlir-to-llvmir | lli
```

If you run this manually, the path to cal-opt needs to be in your PATH variable. You can do this with the following commands:

```bash
PATH="../../llvm-project/build/bin:$PATH"
PATH="$PATH:../../build/bin"
```