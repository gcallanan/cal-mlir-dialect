//===- FifoPsss.td - Fifo dialect passes -------*- tablegen -*-===//
//
// This file is licensed under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#ifndef FIFO_PASS
#define FIFO_PASS

include "mlir/Pass/PassBase.td"

def LowerFifoToMemrefPass: Pass<"lower-fifo-to-memref"> {
  let summary = "Lowers to fifo dialect to memref dialect";
  let description = [{
  }];
}

#endif // FIFO_PASS
