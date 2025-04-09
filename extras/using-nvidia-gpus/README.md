# MLIR to GPU Compilation Guide (Experimental)

This directory provides basic tips and an example for compiling MLIR code to run on a GPU. Please note that **this setup is experimental** and **not officially supported or guaranteed to work**.

## Prerequisites

We assume that you have installed MLIR with CUDA support, specifically with the **CUDA runner enabled**. If you are using the provided `install_mlir.sh` script, this can be done by passing the `--enable-gpu` flag:

`bash cal-mlir-dialect/install_mlir.sh --enable-gpu`

This requires the you have CUDA correctly installed. A guide to doing this can be found here: [cuda_installation_guide.md](./cuda_installation_guide.md)

## Example

An example MLIR program is provided in [`example.mlir`](./example.mlir). You can build and run it using the script: [`build_and_run.mlir`](./build_and_run.mlir)

## Notes on MLIR GPU Support

Setting up MLIR to correctly lower to GPU dialects and compile with Clang is still a developing area, and official documentation is limited. The following threads provide helpful context and troubleshooting advice:

- [How to properly lower MLIR to PTX for GPU execution](https://discourse.llvm.org/t/how-to-properly-lower-mlir-to-ptx-for-gpu-execution/84552/2)
- [Building with CUDA support — not sure if working](https://discourse.llvm.org/t/building-with-cuda-support-not-sure-if-working/83070)
- [How to generate NVIDIA CUDA bin (cubin) from MLIR](https://discourse.llvm.org/t/how-to-generate-nvidia-cuda-bin-cubin-from-mlir/75434/5)

## Disclaimer

This example is intended as a starting point for experimentation. You may need to tweak paths, flags, and versions to match your local setup.

