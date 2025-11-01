// RUN: cal-opt -pass-pipeline='builtin.module(flatten-cal-networks{allow-dynamic-indices})' -split-input-file %s -verify-diagnostics | FileCheck %s --implicit-check-not=cal.create_instance

// Dynamic-index coverage: interface-typed instance array with non-constant index.
// Expect elaboration to skip materialization, emit clear remarks, and not crash.
cal.interface @PipeLike { inPortNames = ["in"], inPortTypes = [!fifo.output_port<i32>], outPortNames = ["out"], outPortTypes = [!fifo.input_port<i32>] }

cal.network @DynIfaceArrayDynamicIdx() {
  %c0 = arith.constant 0 : index
  %c1 = arith.constant 1 : index
  %in0, %out0 = fifo.create<i32>(2) : !fifo.input_port<i32>, !fifo.output_port<i32>
  %arr = cal.instantiate_array.iface @PipeLike count(2) : !cal.instance.array.iface<@PipeLike, 2>

  // Create a non-constant index value (not defined by arith.constant)
  %i = arith.addi %c0, %c1 : index

  // expected-remark@+1 {{skipping dynamic index during elaboration; leaving symbolic ops intact}}
  %h = cal.instance_at %arr[%i] : !cal.instance.array.iface<@PipeLike, 2>, index -> !cal.instance.iface<@PipeLike>

  // With unresolved handle plan, connects should be skipped with specific remarks.
  // expected-remark@+1 {{skipping connect with unresolved destination during elaboration}}
  cal.connect %out0 : !fifo.output_port<i32> "in" -> %h : !cal.instance.iface<@PipeLike> "in"
  // expected-remark@+1 {{skipping connect with unresolved source during elaboration}}
  cal.connect %h : !cal.instance.iface<@PipeLike> "out" -> %in0 : !fifo.input_port<i32> "out"
}

// CHECK: cal.network @DynIfaceArrayDynamicIdx()
// CHECK: cal.instantiate_array.iface @PipeLike count(2)
// CHECK: cal.instance_at %arr[%i]
// CHECK: cal.connect
