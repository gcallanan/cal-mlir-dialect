#!/bin/bash
# Build and run the tensors.mlir file

PATH="../../llvm-project/build/bin:$PATH"
PATH="$PATH:../../build/bin"

cal-opt --lower-cal-to-llvm tensors.mlir | cal-translate --mlir-to-llvmir | lli
