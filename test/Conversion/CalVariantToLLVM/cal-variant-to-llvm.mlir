// RUN: cal-opt --convert-cal-variant-to-llvm %s | FileCheck %s

// Test basic variant creation (Maybe<i32> Some case)
// CHECK-LABEL: func.func @test_variant_create_some
func.func @test_variant_create_some() -> !cal.variant<"Maybe", [("Some", [i32]), ("None", [])]> {
  // CHECK: %[[VAL:.*]] = arith.constant 42 : i32
  %value = arith.constant 42 : i32
  // CHECK: %[[UNDEF:.*]] = llvm.mlir.undef : !llvm.struct<(i32, array<4 x i8>)>
  // CHECK: %[[TAG:.*]] = llvm.mlir.constant(0 : i32) : i32
  // CHECK: llvm.insertvalue %[[TAG]], %[[UNDEF]][0]
  // CHECK: llvm.alloca
  // CHECK: llvm.store
  // CHECK: llvm.getelementptr
  // CHECK: llvm.store %[[VAL]]
  // CHECK: llvm.load
  %some = cal.variant.create "Some"(%value) : !cal.variant<"Maybe", [("Some", [i32]), ("None", [])]> (i32)
  return %some : !cal.variant<"Maybe", [("Some", [i32]), ("None", [])]>
}

// Test variant creation (Maybe<i32> None case)
// CHECK-LABEL: func.func @test_variant_create_none
func.func @test_variant_create_none() -> !cal.variant<"Maybe", [("Some", [i32]), ("None", [])]> {
  // CHECK: %[[UNDEF:.*]] = llvm.mlir.undef : !llvm.struct<(i32, array<4 x i8>)>
  // CHECK: %[[TAG:.*]] = llvm.mlir.constant(1 : i32) : i32
  // CHECK: llvm.insertvalue %[[TAG]], %[[UNDEF]][0]
  %none = cal.variant.create "None"() : !cal.variant<"Maybe", [("Some", [i32]), ("None", [])]>
  return %none : !cal.variant<"Maybe", [("Some", [i32]), ("None", [])]>
}

// Test variant get_tag
// CHECK-LABEL: func.func @test_variant_get_tag
func.func @test_variant_get_tag(%v: !cal.variant<"Maybe", [("Some", [i32]), ("None", [])]>) -> index {
  // CHECK: llvm.extractvalue %{{.*}}[0]
  // CHECK: llvm.zext
  %tag = cal.variant.get_tag %v : !cal.variant<"Maybe", [("Some", [i32]), ("None", [])]> -> index
  return %tag : index
}

// Test variant get_field
// CHECK-LABEL: func.func @test_variant_get_field
func.func @test_variant_get_field(%v: !cal.variant<"Maybe", [("Some", [i32]), ("None", [])]>) -> i32 {
  // CHECK: llvm.alloca
  // CHECK: llvm.store
  // CHECK: llvm.getelementptr
  // CHECK: llvm.getelementptr
  // CHECK: llvm.load
  %val = cal.variant.get_field %v["Some", 0] : !cal.variant<"Maybe", [("Some", [i32]), ("None", [])]> -> i32
  return %val : i32
}

// Test product creation
// CHECK-LABEL: func.func @test_product_create
func.func @test_product_create() -> !cal.product<"Vec2", [("x", i32), ("y", i32)]> {
  %x = arith.constant 10 : i32
  %y = arith.constant 20 : i32
  // CHECK: %[[UNDEF:.*]] = llvm.mlir.undef : !llvm.struct<(i32, i32)>
  // CHECK: %[[S1:.*]] = llvm.insertvalue %{{.*}}, %[[UNDEF]][0]
  // CHECK: llvm.insertvalue %{{.*}}, %[[S1]][1]
  %vec = cal.product.create(%x, %y) : !cal.product<"Vec2", [("x", i32), ("y", i32)]> : (i32, i32)
  return %vec : !cal.product<"Vec2", [("x", i32), ("y", i32)]>
}

// Test product get_field
// CHECK-LABEL: func.func @test_product_get_field
func.func @test_product_get_field(%v: !cal.product<"Vec2", [("x", i32), ("y", i32)]>) -> i32 {
  // CHECK: llvm.extractvalue %{{.*}}[0]
  %x = cal.product.get_field %v["x"] : !cal.product<"Vec2", [("x", i32), ("y", i32)]> -> i32
  return %x : i32
}

// Test product get_field (second field)
// CHECK-LABEL: func.func @test_product_get_field_y
func.func @test_product_get_field_y(%v: !cal.product<"Vec2", [("x", i32), ("y", i32)]>) -> i32 {
  // CHECK: llvm.extractvalue %{{.*}}[1]
  %y = cal.product.get_field %v["y"] : !cal.product<"Vec2", [("x", i32), ("y", i32)]> -> i32
  return %y : i32
}
