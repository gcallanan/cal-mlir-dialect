#!/bin/bash

set -e

PATH="../../llvm-project/build/bin:$PATH"
PATH="$PATH:../../build/bin"

cal-opt --lower-cal-to-llvm myproject/code-gen/main.mlir | cal-translate --mlir-to-llvmir | lli