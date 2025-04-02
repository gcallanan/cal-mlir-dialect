# CAL Actor Language Dialect for the MLIR Compilation Framework

## Introduction and Motivation 

### Dialects

### Transformation Passes

### Optimisation Passes

## Installation

### 1. Installation Requirements

### 2. Installation Instructions:

1. Install the MLIR dialect by running the [install_mlir.sh](./install_mlir.sh) script. It will pull and install the LLVM repo with MLIR into a new directory titled `llvm-project` in this repository. It will take many hours to install, but you should only need to install it once.
2. Once the above step is complete, install this CAL dialect using the [install_cal_dialect.sh](./install_cal_dialect.sh) script. Every time you modify the code in this repo, you will need to run this script again.

## Usage Examples:

You should be able to run these examples from the top level directory in the repository after having followed the installation instructions.

### 1. Convert CAL to LLVM

In the [cal-opt.cpp](cal-opt/cal-opt.cpp) we define a simple pass pipeline called `lower-cal-to-llvm`. This pipeline transforms the CAL and FIFO dialects to the LLVM dialect by transitioning through the a number of intermediary pipeline passes.

This is then transformed from the mlir version of LLVM to the actual version of LLVM expected by other tools using the [cal-translate.cpp](cal-translate/cal-translate.cpp) tool.

From there it can be run using the LLVM interpreter tool `lli` which interprets the values and generates a result. Ensure that you use `lli` built in this repository as often you will have a version of `lli` on your linux machine that can be old and incompatible with this version.

Here is the code to run it:
```
echo '
// Simple example that creates a FIFO, pushes 672 to it, pops this 672 from it, adds
// 17 to it and then prints the result.
module {
  llvm.func @printf(!llvm.ptr, ...) -> i32
  llvm.mlir.global internal constant @str0("Result: %d\0A\00")

  func.func @main() -> i32 {
    %constant0 = arith.constant 0 : i32

    %in0,%out0 = fifo.create<i32>(10) : !fifo.input_port<i32>, !fifo.output_port<i32>
    %constant672 = arith.constant 672 : i32

    fifo.push(%in0: !fifo.input_port<i32>, %constant672: i32)
    %0 = fifo.pull(%out0: !fifo.output_port<i32>) : i32

    %constant17 = arith.constant 17 : i32
    %newResult = arith.addi %constant17, %0: i32
    %strPtr = llvm.mlir.addressof @str0 : !llvm.ptr
    %21 = llvm.call @printf(%strPtr, %newResult) vararg(!llvm.func<i32 (ptr, ...)>): (!llvm.ptr, i32) -> i32

    func.return %constant0 : i32
  }
}' > temp.mlir
./build/bin/cal-opt --lower-cal-to-llvm -o lowered.mlir temp.mlir
./build/bin/cal-translate --mlir-to-llvmir -o llvm-ir.ll lowered.mlir
./llvm-project/build/bin/lli llvm-ir.ll
```

Alternativly, once you have created temp.mlir, you can generate these commands in a single command: `cal-opt --lower-cal-to-llvm temp.mlir | cal-translate --mlir-to-llvmir | ./llvm-project/build/bin/lli llvm-ir.ll`

The expected output here is "Result: 689"

Alternativly the valid LLVM-IR in llvm-ir.ll can be compiled using `llvm-as` and turned into an executable with `clang`. How to do this is left as an exercise to the reader

### 2. Produce an image of a simple DAG graph

If you want a simple visualisation of the CFG of MLIR code, run the following code:

```
# Create the file
echo '
    %c32 = arith.constant 32 : i32
    %in0,%out0 = fifo.create<i32>(5) : !fifo.input_port<i32>, !fifo.output_port<i32>
    %0 = fifo.pull(%out0: !fifo.output_port<i32>) : i32
    fifo.push(%in0: !fifo.input_port<i32>, %c32: i32)
' > temp.mlir
# Generate a png of the graph
./build/bin/cal-opt --view-op-graph  temp.mlir 2>&1 >/dev/null | dot -Tpng -o dag.png
```

## Testing:

Whenever you install the CAL-MLIR-DIALECT project, regression tests will be run. These tests are all located in [test/](test/)

MLIR and LLVM have a specific way of running regression tests. I have written a bit more in one of the tests found at: [test/Cal/1_example_to_start.mlir](test/Cal/1_example_to_start.mlir). Read it if you want more details on how ro write tests. This is a very simple example. Looking at the other .mlir files in the
[test](./test) directory can show you different transformations and dialect examples.

This README can sometimes be out of date, but typically, the tests should always be working, so if
some commands listed here are not working in the README, look at the tests instead.