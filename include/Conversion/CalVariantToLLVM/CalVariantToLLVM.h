//===- CalVariantToLLVM.h - Convert CAL variant types to LLVM ---*- C++ -*-===//
//
// This file is licensed under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file declares the pass to convert CAL variant and product type
// operations to the LLVM dialect.
//
//===----------------------------------------------------------------------===//

#ifndef CAL_CONVERSION_CALVARIANTTOLLVM_H
#define CAL_CONVERSION_CALVARIANTTOLLVM_H

#include "mlir/Pass/Pass.h"

namespace mlir {

/// Creates a pass to lower CAL variant and product type operations to LLVM.
std::unique_ptr<Pass> createConvertCalVariantToLLVMPass();

} // namespace mlir

#endif // CAL_CONVERSION_CALVARIANTTOLLVM_H
