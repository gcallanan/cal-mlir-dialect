# Producer-Consumer Benchmark in CAL

This example implements and evaluates the Producer-Consumer benchmark from the Savina Actor benchmark suite using CAL. The benchmark evaluates buffer-based communication performance by creating a network of producer actors that send data through a bounded buffer actor to consumer actors. The implementation is derived from the `5p2_producerConsumer` benchmark in the [savina-apps-in-cal](https://github.com/gcallanan/savina-apps-in-cal) repository.

> **Reference**: Imam, Shams M., and Vivek Sarkar. "Savina-an actor benchmark suite: Enabling empirical evaluation of actor libraries." Proceedings of the 4th International Workshop on Programming Based on Actors Agents & Decentralized Control. 2014.

## Directory Contents

| File/Directory | Description |
|---------------|-------------|
| `ProducerConsumerNetwork.cal` | The top-level network that instantiates and connects the actors |
| `Producer.cal` | Implementation of producer actors that generate messages |
| `Consumer.cal` | Implementation of consumer actors that receive messages |
| `Buffer.cal` | The bounded buffer actor that manages message passing |
| `config.cal` | Configuration file defining network parameters (auto-generated) |
| `compile_to_cpp_then_to_binary.sh` | Compiles the CAL code to C++ and then to a binary |
| `compile_to_mlir_then_to_binary.sh` | Compiles the CAL code to MLIR and then to a binary |
| `compile_to_c_then_to_binary.sh` | This uses the original Tÿcho compiler to generate C code and then a binary from CAL. Unless you are very interested, you do not need to worry about this, as it is not used by default in the other scripts. |
| `compare_streamblocks_mlir_to_cpp_backends.sh` | Script to benchmark both compilation paths |

## Parameters

The benchmark can be configured with the following parameters:

- `-O` : LLVM optimization level (0-3)
- `-P` : Number of producer actors in the network
- `-C` : Number of consumer actors in the network
- `-B` : Size of the bounded buffer
- `-N` : Number of items sent by each producer

## How to Run

### 1. Compile and Run Individual Backends

To compile using the C++ backend:
```bash
./compile_to_cpp_then_to_binary.sh -O 3 -P 4 -C 4 -B 32 -N 10000
./main_executable_from_cpp
```

To compile using the MLIR backend:
```bash
./compile_to_mlir_then_to_binary.sh -O 3 -P 4 -C 4 -B 32 -N 10000
./main_executable_from_mlir
```

To compile using the Tÿcho C backend (note, you will need to have installed the streamblocks-tycho compiler and have the `tychoc` binary in your path):
```bash
./compile_to_c_then_to_binary.sh -O 3 -P 4 -C 4 -B 32 -N 10000
./main_executable_from_c
```

### 2. Run Performance Comparison

To compare the performance of both backends across different parameters:
```bash
./compare_streamblocks_mlir_to_cpp_backends.sh
```

This will:
- Sweep through different optimization levels (O0-O3)
- Test different numbers of producer/consumer actors
- Test different buffer sizes
- Run multiple iterations for each configuration
- Generate a CSV file with timing results

## Prerequisites

The same tools are required as listed in the main README:
- `streamblocks` The [streamblocks-toolchain](../streamblocks-toolchain/) example discusses how to install streamblocks. Make sure to add the `streamblocks` binary to your PATH
- `cal-opt`
- `cal-translate`
- `llc`
- `clang`
- `opt`
