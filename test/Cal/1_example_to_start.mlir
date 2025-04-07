// MLIR and LLVM use a program known as FileCheck to confirm tests are working
// tests. These regression tests typically combine everything into one file.
// Typically you specify three things:
// 1. The command to run.
// 2. The input
// 3. The expected output
// What is sometimes confusing is that the command and expected output are
// both given as commands written in comments in the file. Generally, if
// something in the file is all uppercase, its a command.
// Here is a good link: https://llvm.org/docs/CommandGuide/FileCheck.html#tutorial

// Here is our command (the next line looks like a comment but it is actually run):
// RUN: cal-opt %s | FileCheck %s
// %s is the file name, so we run cal-opt on this file and pipe it to FileCheck
// FileCheck then compares these results to commands embedded in the 

// CHECK: module {

// Here is the input
%input1 = arith.constant 10 : i64
// These check commands now specify the expected output
// CHECK: %c10_i64 = arith.constant 10 : i64
