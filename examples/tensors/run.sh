#!/bin/bash
# Build and run the merge.mlir file
#cal-opt tensors.mlir --canonicalize --hoist-cal-state-out-of-actor --insert-cal-port-predicates --convert-cal-actions-to-execution-bodies --convert-cal-to-func --lower-fifo-to-memref --decompose-fifo-tuples --lower-cal-state-to-memref


PATH="../../llvm-project/build/bin:$PATH"
PATH="$PATH:../../build/bin"

cal-opt --lower-cal-to-llvm tensors.mlir | cal-translate --mlir-to-llvmir | lli
#cal-opt tensors.mlir --canonicalize --hoist-cal-state-out-of-actor --insert-cal-port-predicates --convert-cal-actions-to-execution-bodies --convert-cal-to-func --lower-fifo-to-memref --decompose-fifo-tuples --lower-cal-state-to-memref --canonicalize --one-shot-bufferize --convert-linalg-to-loops --lower-cal-to-llvm | cal-translate --mlir-to-llvmir | lli
#cal-opt tensors.mlir --canonicalize --hoist-cal-state-out-of-actor --insert-cal-port-predicates --convert-cal-actions-to-execution-bodies --convert-cal-to-func --lower-fifo-to-memref --decompose-fifo-tuples --one-shot-bufferize #--lower-cal-state-to-memref --canonicalize --one-shot-bufferize --convert-linalg-to-loops --lower-cal-to-llvm | cal-translate --mlir-to-llvmir | lli
#cal-opt tensors.mlir --canonicalize --one-shot-bufferize  --hoist-cal-state-out-of-actor --insert-cal-port-predicates --convert-cal-actions-to-execution-bodies --convert-cal-to-func --lower-fifo-to-memref --decompose-fifo-tuples --one-shot-bufferize --lower-cal-state-to-memref --canonicalize --convert-linalg-to-loops --lower-cal-to-llvm | cal-translate --mlir-to-llvmir | lli
#cal-opt tensors.mlir --insert-cal-port-predicates --convert-cal-actions-to-execution-bodies --hoist-cal-state-out-of-actor --canonicalize --convert-cal-to-func --lower-cal-state-to-memref
#cal-opt tensors.mlir --insert-cal-port-predicates --convert-cal-actions-to-execution-bodies --hoist-cal-state-out-of-actor --canonicalize --convert-cal-to-func --lower-cal-state-to-memref --one-shot-bufferize="bufferize-function-boundaries" --canonicalize --lower-cal-to-llvm | cal-translate --mlir-to-llvmir | lli
#cal-opt tensors.mlir --insert-cal-port-predicates --convert-cal-actions-to-execution-bodies --hoist-cal-state-out-of-actor --canonicalize --convert-cal-to-func --lower-cal-state-to-memref --lower-fifo-to-memref --decompose-fifo-tuples --one-shot-bufferize --convert-linalg-to-loops --buffer-deallocation --lower-fifo-print-to-llvm --canonicalize --lower-cal-to-llvm | cal-translate --mlir-to-llvmir | lli


