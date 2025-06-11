#!/bin/bash

set -e

PATH="../../llvm-project/build/bin:$PATH"
PATH="$PATH:../../build/bin"

rm -fr myproject
streamblocks mlir --set generate-single-declaration-per-actor=off --set experimental-network-elaboration=on --set bypass-AM-generation=on --source-path qrd_systolic_cordic_fixedpoint.cal --target-path myproject qrd.Top