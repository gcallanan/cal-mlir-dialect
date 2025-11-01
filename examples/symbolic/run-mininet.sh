#!/usr/bin/env bash
set -euo pipefail

# Ensure project and LLVM build bins are in PATH if needed
export PATH="${PWD}/build/bin:${PATH}"

input_dir="$(cd "$(dirname "$0")" && pwd)"
input_file="${input_dir}/mininet.mlir"

# Elaborate/flatten then lower and run
cal-opt -pass-pipeline='builtin.module(flatten-cal-networks)' "${input_file}" \
  | cal-opt --lower-cal-to-llvm \
  | mlir-runner -e main -entry-point-result=i32
