//===- CalDialect.td - Cal dialect -----------*- tablegen -*-===//
//
// This file is licensed under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#ifndef CAL_DIALECT
#define CAL_DIALECT

include "mlir/IR/OpBase.td"

//===----------------------------------------------------------------------===//
// Cal dialect definition.
//===----------------------------------------------------------------------===//

def Cal_Dialect : Dialect {
    let name = "cal";
    let summary = "A dialect representing actor-based dataflow computations with FIFO communication.";
    let description = [{
    The CAL dialect provides an IR for modeling actor-based applications within MLIR,
    based on the CAL actor language. It represents computation as a network of actors
    communicating via FIFO channels, following the Dataflow-with-Firing model.

    This dialect includes constructs for defining actors (`cal.actor`), actions within
    actors (`cal.action`), predicates for conditional execution, and the overall network
    structure (`cal.network`). It supports modeling dataflow control and stateful
    computations through explicit state variables and FIFO communication operations.

    The dialect serves as a foundation for CAL compilers and analyses, enabling
    transformations and lowering passes that convert high-level actor semantics
    into executable code or other intermediate representations.

    Key features include:
    - Explicit modeling of actors and their actions, including priorities and state updates.
    - Support for conditional execution via predicates.
    - Representation of FIFO channels for inter-actor communication.
    - Facilities for composing multiple actions into unified execution bodies.

    Example:
        cal.actor @my_actor()
            ports_in(%in0: !fifo.output_port<i32>)
            ports_out(%out0: !fifo.input_port<i32>)
        {
            // Create a state variable - run once off at the start
            %c1 = arith.constant 1 : i32
            %s1 = cal.create_state_var<i32> : !cal.state_ref<i32>
            cal.set(%s1: !cal.state_ref<i32>, %c1: i32)

            // Action that increments state and outputs the old value
            // Executes as lone as the state is less than 100
            cal.action {
                cal.predicate {
                    %state_val = cal.get(%s1: !cal.state_ref<i32>) : i32
                    %limit = arith.constant 100 : i32
                    %cond = arith.cmpi slt, %state_val, %limit : i32
                    cal.predicate_result %cond : i1
                }
                %0 = cal.get(%s1: !cal.state_ref<i32>) : i32
                %1 = arith.addi %0, %c1 : i32
                cal.set(%s1: !cal.state_ref<i32>, %1: i32)
                fifo.push(%out0: !fifo.input_port<i32>, %0: i32)
            }
        }
    }];
    let cppNamespace = "::mlir::cal";

    let useDefaultTypePrinterParser = 1;
    let extraClassDeclaration = [{
        void registerTypes();
    }];
}

//===----------------------------------------------------------------------===//
// Base cal operation definition.
//===----------------------------------------------------------------------===//

class Cal_Op<string mnemonic, list<Trait> traits = []> :
        Op<Cal_Dialect, mnemonic, traits>;

#endif // CAL_DIALECT
