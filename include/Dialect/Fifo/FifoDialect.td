//===- FifoDialect.td - Fifo dialect -----------*- tablegen -*-===//
//
// This file is licensed under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#ifndef FIFO_DIALECT
#define FIFO_DIALECT

include "mlir/IR/OpBase.td"

//===----------------------------------------------------------------------===//
// Cal dialect definition.
//===----------------------------------------------------------------------===//

def Fifo_Dialect : Dialect {
    let name = "fifo";
    let summary = "A dialect for creating and using FIFO queues .";
    let description = [{
        This dialect provides operations for creating and using FIFO (First-In-First-Out) queues.
        It is designed to model dataflow systems where actors communicate through FIFO buffers,
        supporting both push and pull operations. The dialect enables the creation of FIFO buffers
        with configurable sizes and element types, as well as manipulation of data within these buffers.

        It is intended for use in applications where data is processed in a sequential and ordered
        manner, such as streaming applications, hardware modeling, and other dataflow-based systems.

        Description originally written by Gareth Callanan and refined using ChatGPT.
    }];
    let cppNamespace = "::mlir::fifo";

    let useDefaultTypePrinterParser = 1;
    let extraClassDeclaration = [{
        void registerTypes();
    }];
}

//===----------------------------------------------------------------------===//
// Base fifo operation definition.
//===----------------------------------------------------------------------===//

class Fifo_Op<string mnemonic, list<Trait> traits = []> :
        Op<Fifo_Dialect, mnemonic, traits>;

#endif // FIFO_DIALECT
