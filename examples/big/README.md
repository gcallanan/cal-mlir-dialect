# Big Actor Benchmark in CAL

This example implements and evaluates the Big actor benchmark from the Savina Actor benchmark suite using CAL. The benchmark evaluates message-passing performance by creating a network of messenger actors that ping messages between each other. The implementation is derived from the `4p8_big_v2` benchmark in the [savina-apps-in-cal](https://github.com/gcallanan/savina-apps-in-cal) repository.

> **Reference**: Imam, Shams M., and Vivek Sarkar. "Savina-an actor benchmark suite: Enabling empirical evaluation of actor libraries." Proceedings of the 4th International Workshop on Programming Based on Actors Agents & Decentralized Control. 2014.

## Directory Contents

| File/Directory | Description |
|---------------|-------------|
| `BigNetwork.cal` | The top-level network that instantiates and connects the messenger actors |
| `Messenger.cal` | Implementation of the messenger actor that sends/receives ping messages |
| `Sink.cal` | A sink actor that collects completion messages |
| `config.cal` | Configuration file defining network parameters (auto-generated) |
| `compile_to_cpp_then_to_binary.sh` | Compiles the CAL code to C++ and then to a binary |
| `compile_to_mlir_then_to_binary.sh` | Compiles the CAL code to MLIR and then to a binary |
| `compare_streamblocks_mlir_to_cpp_backends.sh` | Script to benchmark both compilation paths |

## Parameters

The benchmark can be configured with the following parameters:

- `-O` : LLVM optimization level (0-3)
- `-M` : Number of messenger actors in the network
- `-P` : Number of ping messages sent by each messenger actor

## How to Run

### 1. Compile and Run Individual Backends

To compile using the C++ backend:
```bash
./compile_to_cpp_then_to_binary.sh -O 3 -M 8 -P 10000
./main_executable_from_cpp
```

To compile using the MLIR backend:
```bash
./compile_to_mlir_then_to_binary.sh -O 3 -M 8 -P 10000
./main_executable_from_mlir
```

### 2. Run Performance Comparison

To compare the performance of both backends across different parameters:
```bash
./compare_streamblocks_mlir_to_cpp_backends.sh
```

This will:
- Sweep through different optimization levels (O0-O3)
- Test different numbers of messenger actors
- Run multiple iterations for each configuration
- Generate a CSV file with timing results

## Prerequisites

The same tools are required as listed in the main README:
- `streamblocks` - The [streamblocks-toolchain](../streamblocks-toolchain/) example discusses how to install streamblocks. Make sure to add the `streamblocks` binary to your PATH
- `cal-opt`
- `cal-translate`
- `llc`
- `clang`
- `opt`
