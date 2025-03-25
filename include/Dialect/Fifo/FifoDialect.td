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
    let summary = "A cal out-of-tree MLIR dialect.";
    let description = [{
        This dialect defines the an IR intended for use with CAL compilers. The
        CAL actor language is used to specify applications as a network of actors
        that communicate through FIFO channels (A formal model known as
        Dataflow-with-Firing). The CAL dialect is used to represent the actor
        network in MLIR.
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
