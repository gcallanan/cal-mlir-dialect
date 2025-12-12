// RUN: cal-opt %s | FileCheck %s

// =============================================================================
// Tests for algebraic types: !cal.variant and !cal.product
// =============================================================================

// CHECK-LABEL: func.func @test_variant_create_some
func.func @test_variant_create_some() -> !cal.variant<"Maybe", [("Some", [i32]), ("None", [])]> {
  // CHECK: %[[VAL:.*]] = arith.constant 42 : i32
  // CHECK: cal.variant.create "Some"(%[[VAL]])
  %value = arith.constant 42 : i32
  %some = cal.variant.create "Some"(%value) : !cal.variant<"Maybe", [("Some", [i32]), ("None", [])]> (i32)
  return %some : !cal.variant<"Maybe", [("Some", [i32]), ("None", [])]>
}

// CHECK-LABEL: func.func @test_variant_create_none
func.func @test_variant_create_none() -> !cal.variant<"Maybe", [("Some", [i32]), ("None", [])]> {
  // CHECK: cal.variant.create "None"()
  %none = cal.variant.create "None"() : !cal.variant<"Maybe", [("Some", [i32]), ("None", [])]>
  return %none : !cal.variant<"Maybe", [("Some", [i32]), ("None", [])]>
}

// CHECK-LABEL: func.func @test_variant_get_tag
func.func @test_variant_get_tag(%maybe: !cal.variant<"Maybe", [("Some", [i32]), ("None", [])]>) -> index {
  // CHECK: cal.variant.get_tag %{{.*}}
  %tag = cal.variant.get_tag %maybe : !cal.variant<"Maybe", [("Some", [i32]), ("None", [])]> -> index
  return %tag : index
}

// CHECK-LABEL: func.func @test_variant_get_field
func.func @test_variant_get_field(%maybe: !cal.variant<"Maybe", [("Some", [i32]), ("None", [])]>) -> i32 {
  // CHECK: cal.variant.get_field %{{.*}}["Some", 0]
  %value = cal.variant.get_field %maybe["Some", 0] : !cal.variant<"Maybe", [("Some", [i32]), ("None", [])]> -> i32
  return %value : i32
}

// CHECK-LABEL: func.func @test_product_create
func.func @test_product_create() -> !cal.product<"Vec2", [("x", i32), ("y", i32)]> {
  // CHECK: %[[X:.*]] = arith.constant 10 : i32
  // CHECK: %[[Y:.*]] = arith.constant 20 : i32
  // CHECK: cal.product.create(%[[X]], %[[Y]])
  %x = arith.constant 10 : i32
  %y = arith.constant 20 : i32
  %vec = cal.product.create(%x, %y) : !cal.product<"Vec2", [("x", i32), ("y", i32)]> : (i32, i32)
  return %vec : !cal.product<"Vec2", [("x", i32), ("y", i32)]>
}

// CHECK-LABEL: func.func @test_product_get_field
func.func @test_product_get_field(%vec: !cal.product<"Vec2", [("x", i32), ("y", i32)]>) -> i32 {
  // CHECK: cal.product.get_field %{{.*}}["x"]
  %x = cal.product.get_field %vec["x"] : !cal.product<"Vec2", [("x", i32), ("y", i32)]> -> i32
  return %x : i32
}

// Test with multiple fields in variant
// CHECK-LABEL: func.func @test_result_variant
func.func @test_result_variant(%val: i64, %msg: i32) -> !cal.variant<"Result", [("Ok", [i64]), ("Err", [i32])]> {
  // CHECK: cal.variant.create "Ok"(%{{.*}})
  %ok = cal.variant.create "Ok"(%val) : !cal.variant<"Result", [("Ok", [i64]), ("Err", [i32])]> (i64)
  return %ok : !cal.variant<"Result", [("Ok", [i64]), ("Err", [i32])]>
}

// Test with nested types in product
// CHECK-LABEL: func.func @test_product_with_tensor
func.func @test_product_with_tensor(%data: tensor<2x2xf32>, %label: i32) -> !cal.product<"LabeledData", [("data", tensor<2x2xf32>), ("label", i32)]> {
  // CHECK: cal.product.create(%{{.*}}, %{{.*}})
  %labeled = cal.product.create(%data, %label) : !cal.product<"LabeledData", [("data", tensor<2x2xf32>), ("label", i32)]> : (tensor<2x2xf32>, i32)
  return %labeled : !cal.product<"LabeledData", [("data", tensor<2x2xf32>), ("label", i32)]>
}
