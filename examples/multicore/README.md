# Multi-Core Execution Example

This example demonstrates how to compile and execute CAL actor networks across multiple CPU cores using the `--actor-partitioning-mode` flag.

## Overview

The CAL dialect supports two execution modes for actor networks:

1. **Single-threaded mode** (`single-threaded`): All actors execute sequentially in a round-robin scheduler on a single thread
2. **Multi-threaded mode** (`one-actor-per-thread`): Each actor instance runs on its own dedicated thread, enabling true parallel execution

This example shows how to use the multi-threaded mode to achieve parallel execution of actors.

## Files

- [build-and-run-multithreaded.sh](build-and-run-multithreaded.sh) — Builds the MLIR example with the multithreaded actor partitioning option, translates to LLVM IR, links the runtime libraries, and runs the resulting multithreaded executable while timing execution.
- [build-and-run-single-thread.sh](build-and-run-single-thread.sh) — Builds and runs the single-threaded version of the example (round-robin scheduler), producing and running a single-threaded executable and reporting elapsed time.
- [busy-chain.mlir](busy-chain.mlir) — The CAL network MLIR example: a six-stage pipeline (src → forward* → sink). The source generates M tokens, the forward actors perform heavy computation to simulate load, and the sink prints every Nth token. Used to compare single-threaded and one-actor-per-thread execution modes.

## How to run:

In order to run, execute `bash build-and-run-multithreaded.sh` or `bash build-and-run-singlethreaded.sh` depending on which type of build you want to perform.