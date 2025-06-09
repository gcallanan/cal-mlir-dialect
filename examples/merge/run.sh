#!/bin/bash
# Build and run the merge.mlir file

cal-opt --lower-cal-to-llvm merge.mlir | cal-translate --mlir-to-llvmir | lli
