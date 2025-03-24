###

Ignore this: vim llvm-project/mlir/include/mlir/Dialect/Mesh/IR/MeshOps.td

TODO: What is this repository

# Installation Instructions:

1. Install the MLIR dialect by running the [install_mlir.sh](./install_mlir.sh) script. It will pull and install the LLVM repo with MLIR into a new directory titled `llvm-project` in this repository. It will take many hours to install, but you should only need to install it once.
2. Once the above step is complete, install this CAL dialect using the [install_cal_dialect.sh](./install_cal_dialect.sh) script. Every time you modify the code in this repo, you will need to run this script again.

# Generated Binaries:

# Testing:

Whenever you install, regression tests will be run. These tests are all located in [test/](test/)

MLIR and LLVM have a specific way of running regression tests. I have written a bit more in one of the tests found at: [test/Cal/1_example_to_start.mlir](test/Cal/1_example_to_start.mlir). Read it if you want more details on how ro write tests.

# Usage:

## 1. Produce an image of a simple DAG graph

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
cal-opt --view-op-graph  temp.mlir 2>&1 >/dev/null | dot -Tpng -o dag.png
```
