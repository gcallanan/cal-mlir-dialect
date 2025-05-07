//===- CalPsss.td - Cal dialect passes -------*- tablegen -*-===//
//
// This file is licensed under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#ifndef CAL_PASS
#define CAL_PASS

include "mlir/Pass/PassBase.td"

def LowerCalStateToMemref: Pass<"lower-cal-state-to-memref"> {
  let summary = "Lower CAL state operations to MemRef dialect operations";
  let description = [{
    This pass lowers state-related operations from the CAL dialect, specifically
    `cal.state`, `cal.get`, and `cal.set`, to equivalent operations in the MemRef
    dialect. The transformation replaces CAL state definitions with `memref.alloc`
    operations, and rewrites `cal.get` and `cal.set` into `memref.load` and
    `memref.store`, respectively.

    Description originally written by Gareth Callanan and refined using ChatGPT.
  }];
  let constructor = "mlir::cal::lowerCalStateToMemref()";
  let dependentDialects = [
    "cal::CalDialect",
    "index::IndexDialect",
    "arith::ArithDialect",
    "memref::MemRefDialect"
  ];
}

#endif // CAL_PASS
