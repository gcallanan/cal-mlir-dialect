# CAL Actor Language Dialect for the MLIR Compilation Framework

## Quick Start

1. Install the MLIR project with `bash install_mlir.sh` (this may take a long time).
2. Install this project with `bash install_cal_dialect.sh`.
3. Navigate to the simple [merge](examples/merge/): `cd examples/merge`
3. Run [run.sh](examples/merge/run.sh) to compile and run the example: `bash run.sh`.

## Table of Contents

- [Quick Start](#quick-start)
- [Table of Contents](#table-of-contents)
- [Introduction and Motivation](#introduction-and-motivation)
- [Dialects](#dialects)
- [Transformation Pipelines](#transformation-pipelines)
- [Frontends](#frontends)
- [Getting Started](#getting-started)
  - [Installation Requirements](#1-installation-requirements)
  - [Installation Instructions](#2-installation-instructions)
  - [GPU Support](#3-gpu-support)
  - [Examples](#4-examples)
- [License](#license)
- [Acknowledgement](#acknowledgement)

## Introduction and Motivation

This repository provides a way to express programs as networks of independent computing units (called "actors") that communicate by sending data through channels. Think of actors as small programs that can run independently and communicate only by sending and receiving messages.

**What is CAL?** CAL (CAL Actor Language) is a programming model where computation happens through independent actors exchanging data through First-In-First-Out (FIFO) channels. Unlike traditional programming, where instructions execute sequentially, in actor models:
- Each actor operates independently
- Actors communicate only by sending/receiving messages
- Processing happens when data is available

```
   +--------+     message     +--------+     message     +--------+
   | Actor1 |---------------->| Actor2 |---------------->| Actor3 |
   +--------+     (FIFO)      +--------+     (FIFO)      +--------+
       |                                                      |
       |              message (FIFO feedback)                 |
       +------------------------------------------------------+
```

Our MLIR dialect makes it possible to represent CAL programs in the MLIR compiler framework, allowing powerful optimizations while maintaining the actor model's simplicity. We provide tools to:
- Convert CAL programs into our MLIR dialect
- Perform some simple optimizations on the network
- Generate efficient code for CPUs and GPUs

This approach separates the actor language from the optimization process, making it easier to target different hardware platforms with the same high-level program description.

If you want to reference this work or read a more detailed explanation, please see the following paper:

TODO: Add reference

If you want to use this project, learn more about it, or modify it, please do not hesitate to get in touch. I am happy to answer your questions and help you get started.

### Dialects

This repository defines two dialects: a FIFO dialect for creating and performing operations on FIFOs, and a CAL dialect for creating and defining actors. Actors defined in the CAL dialect are connected by FIFOs defined in the FIFO dialect. Below is a very simple example of the dialect, where a source actor sends 20 tokens to a destination actor that prints them. The `cal.network` operation defines how they fit together.

```
cal.actor @source(%arg0: i32) ports_out (%arg1: !fifo.input_port<i32>) {
	%c1_i32 = arith.constant 1 : i32
	%c0_i32 = arith.constant 0 : i32
	%0 = cal.create_state_var<i32> : !cal.state_ref<i32>
	cal.set(%0 : !cal.state_ref<i32>, %c0_i32 : i32)
	
	cal.action "tx" priority=0 {
		cal.predicate {
			%3 = cal.get(%0 : !cal.state_ref<i32>) : i32
			%4 = arith.cmpi slt , %3, %arg0 : i32 // signed less than (<)
			cal.predicate_result %4 : i1
		}
		%1 = cal.get(%0 : !cal.state_ref<i32>) : i32
		%2 = arith.addi %1, %c1_i32 : i32
		cal.set(%0 : !cal.state_ref<i32>, %2 : i32)
		fifo.push(%arg1 : !fifo.input_port<i32>, %2 : i32)
	}
}

cal.actor @sink() ports_in (%arg0: !fifo.output_port<i32>) {
	cal.action "rx" priority=0 {
		%0 = fifo.pop(%arg0 : !fifo.output_port<i32>) : i32
		fifo.print("Rx: %i\n", %0 ) : (i32)
	}
}

cal.network {
	%c20_i32 = arith.constant 20 : i32
	%inputPort, %outputPort = fifo.create<i32> (10) : !fifo.input_port<i32>,  !fifo.output_port<i32>
	cal.create_instance @source "source" (%c20_i32 : i32)
		ports_out (%inputPort : !fifo.input_port<i32>)
	cal.create_instance @sink "sink" ()
		ports_in (%outputPort : !fifo.output_port<i32>)
}
```

### Transformation Pipelines

MLIR enables transformation through a series of passes that gradually lower high-level dialects into lower-level representations like LLVM IR for execution. These passes can be grouped into pipelines that can be invoked with a single command line argument. We provide specialized pipelines:
1. **lower-cal-to-llvm** - The standard pipeline for lowering CAL and FIFO dialects to LLVM IR. It creates a dynamic, data-dependent execution schedule that works with all actors. This is the recommended default pipeline.
2. **lower-cal-to-llvm-with-static-schedule** - This pipeline attempts to generate a static schedule for actors, which can significantly improve performance. It requires that your actors conform to Synchronous Dataflow (SDF) or Cyclo-Static Dataflow (CSDF) models, where token production and consumption rates are predictable. Use this pipeline when your network fits these models and you want to optimize throughput.
3. **lower-cal-to-llvm-with-gpu-tensors** - This specialized pipeline targets GPU acceleration by lowering tensor operations to NVIDIA GPU kernels. It's ideal for computationally intensive applications that manipulate tensors and perform linear algebra operations that can benefit from GPU parallelism.

Additionally, for source that uses structural CAL constructs (e.g., cal.instance_if / cal.instance_for and SCF used structurally under cal.network), we provide a compact elaboration pipeline that exposes compile-time constants and erases structural control:

- **cal-structural-elaboration** – Runs constant evaluation, resolves cal.instance_if, lowers cal.instance_for, and elaborates constant scf.if/scf.for under cal.network. This is useful before flattening networks or lowering to functions. Invoke it via the composite fixed-point pass:

Optional command (useful when you have structural constructs to elaborate):

- cal-opt --composite-fixed-point-pass="pipeline=cal-structural-elaboration" input.mlir

Each pipeline applies a different sequence of transformation passes. The complete pipeline definitions can be found in [CalLoweringPipelines.h](include/Conversion/CalLoweringPipelines/CalLoweringPipelines.h) and [CalLoweringPipelines.cpp](lib/Conversion/CalLoweringPipelines/CalLoweringPipelines.cpp).

To use a lowering pipeline with cal-opt, run: `cal-opt --<pipeline-name> input.mlir`

### Frontends

We have provided two frontends for generating this dialect (examples on how to use them are provided):

1. StreamBlocks frontend for CAL - StreamBlocks is a CAL compiler that can target different platforms. We added a new platform that can take CAL code and generate this dialect. See [streamblocks-toolchain](examples/streamblocks-toolchain/) for details on how to install and use StreamBlocks for this purpose.
2. Thalassa PDE Solver Framework - Thalassa is a tool for taking a system of PDE equations and generating a solver for them. We provide a target for Thalassa that generates a network in this dialect while passing tensor types around. It is a nice example for demonstrating GPU acceleration using the GPU pipeline. See [thalassa-pde-solver](examples/thalassa-pde-solver/) for details on how to install and use it.

## Getting Started

### 1. Installation Requirements
Before installing, ensure you have:
- A C++17 compatible compiler
- CMake (version 3.13.4 or higher)
- Ninja build system
- Python 3.6 or higher
- (eigen3) libeigen3-dev (for solving systems of linear equations)

### 2. Installation Instructions:

1. Install the MLIR dialect by running the [install_mlir.sh](./install_mlir.sh) script with `bash install_mlir.sh`. It will pull and install the LLVM repo with MLIR into a new directory titled `llvm-project` in this repository. It will take many hours to install, but you should only need to install it once.
    - Optionally update your PATH with the `llvm-project/build/bin` directory
    - Optionally update your LD_LIBRARY_PATH with the `llvm-project/build/lib` directory
2. Once the above step is complete, install this CAL dialect using the [install_cal_dialect.sh](./install_cal_dialect.sh) script with `bash install_cal_dialect.sh`. Every time you modify the code in this repo, you will need to run this script again.
    - Optionally update your PATH with the `build/bin` directory

### 3. GPU Support

To enable the pipeline for lowering tensor operations to the GPU and for using MLIR dialects with GPU support in general, ensure that you install MLIR with GPU support by using the `--enable-gpu` flag in the [install_mlir.sh](./install_mlir.sh) script: `bash install_mlir.sh --enable-gpu`. For more details on using NVIDIA GPUs with MLIR, refer to the [README.md](./extras/using-nvidia-gpus/README.md) file in the [extras/using-nvidia-gpus](./extras/using-nvidia-gpus) directory.

NOTE: This is an optional step and it's often simpler to skip it if you do not want to struggle with the CUDA installation.

### 4. Examples

To help you get started, we provide a number of example programs in [examples](examples/). These examples also contain scripts and instructions on how to build and run them.

The [merge](examples/merge/) example is the simplest example and the best place to get started.

The [streamblocks-toolchain](examples/streamblocks-toolchain/) is a good second step as it shows you how to install the StreamBlocks frontend for transforming CAL into this dialect. It is much simpler to write CAL code than generate this dialect yourself.

The [tensors](examples/tensors/) example shows how the tensor types and related operations can be used in CAL.

Descriptions of all the different examples can be found in [examples/README.md](examples/README.md).

## License

This project is licensed under the Apache License v2.0. Please see [LICENSE](LICENSE) for license information.

## Acknowledgement

This repository was created and is maintained by Gareth Callanan. Some portions of the documentation were generated with the assistance of AI tools (specifically ChatGPT) to improve accessibility and reduce documentation overhead. All AI-generated content has been reviewed and verified for accuracy.
