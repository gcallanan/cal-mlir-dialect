#!/bin/bash
# Build and run the merge.mlir file

PATH="../../llvm-project/build/bin:$PATH"
PATH="$PATH:../../build/bin"

cal-opt --lower-cal-to-llvm merge.mlir | cal-translate --mlir-to-llvmir | lli
