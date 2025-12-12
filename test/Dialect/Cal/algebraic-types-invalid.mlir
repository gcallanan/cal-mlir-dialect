// RUN: cal-opt %s -split-input-file -verify-diagnostics

// Test: variant name not found
func.func @test_invalid_variant_name() -> !cal.variant<"Maybe", [("Some", [i32]), ("None", [])]> {
  %value = arith.constant 42 : i32
  // expected-error @+1 {{variant 'Unknown' not found in type 'Maybe'}}
  %bad = cal.variant.create "Unknown"(%value) : !cal.variant<"Maybe", [("Some", [i32]), ("None", [])]> (i32)
  return %bad : !cal.variant<"Maybe", [("Some", [i32]), ("None", [])]>
}

// -----

// Test: wrong number of fields for variant
func.func @test_wrong_field_count() -> !cal.variant<"Maybe", [("Some", [i32]), ("None", [])]> {
  %value = arith.constant 42 : i32
  // expected-error @+1 {{variant 'None' expects 0 field(s), but got 1}}
  %bad = cal.variant.create "None"(%value) : !cal.variant<"Maybe", [("Some", [i32]), ("None", [])]> (i32)
  return %bad : !cal.variant<"Maybe", [("Some", [i32]), ("None", [])]>
}

// -----

// Test: wrong field type for variant
func.func @test_wrong_field_type() -> !cal.variant<"Maybe", [("Some", [i32]), ("None", [])]> {
  %value = arith.constant 42.0 : f32
  // expected-error @+1 {{variant 'Some' field 0 expects type 'i32', but got 'f32'}}
  %bad = cal.variant.create "Some"(%value) : !cal.variant<"Maybe", [("Some", [i32]), ("None", [])]> (f32)
  return %bad : !cal.variant<"Maybe", [("Some", [i32]), ("None", [])]>
}

// -----

// Test: variant.get_field with invalid variant name
func.func @test_get_field_invalid_variant(%maybe: !cal.variant<"Maybe", [("Some", [i32]), ("None", [])]>) -> i32 {
  // expected-error @+1 {{variant 'Bad' not found in type 'Maybe'}}
  %value = cal.variant.get_field %maybe["Bad", 0] : !cal.variant<"Maybe", [("Some", [i32]), ("None", [])]> -> i32
  return %value : i32
}

// -----

// Test: variant.get_field with out-of-bounds index
func.func @test_get_field_oob(%maybe: !cal.variant<"Maybe", [("Some", [i32]), ("None", [])]>) -> i32 {
  // expected-error @+1 {{field index 5 out of bounds for variant 'Some' which has 1 field(s)}}
  %value = cal.variant.get_field %maybe["Some", 5] : !cal.variant<"Maybe", [("Some", [i32]), ("None", [])]> -> i32
  return %value : i32
}

// -----

// Test: variant.get_field with wrong result type
func.func @test_get_field_wrong_type(%maybe: !cal.variant<"Maybe", [("Some", [i32]), ("None", [])]>) -> f32 {
  // expected-error @+1 {{result type 'f32' does not match field 0 type 'i32' in variant 'Some'}}
  %value = cal.variant.get_field %maybe["Some", 0] : !cal.variant<"Maybe", [("Some", [i32]), ("None", [])]> -> f32
  return %value : f32
}

// -----

// Test: product.create with wrong number of fields
func.func @test_product_wrong_count() -> !cal.product<"Vec2", [("x", i32), ("y", i32)]> {
  %x = arith.constant 10 : i32
  // expected-error @+1 {{product type 'Vec2' expects 2 field(s), but got 1}}
  %bad = cal.product.create(%x) : !cal.product<"Vec2", [("x", i32), ("y", i32)]> : (i32)
  return %bad : !cal.product<"Vec2", [("x", i32), ("y", i32)]>
}

// -----

// Test: product.create with wrong field type
func.func @test_product_wrong_type() -> !cal.product<"Vec2", [("x", i32), ("y", i32)]> {
  %x = arith.constant 10 : i32
  %y = arith.constant 20.0 : f32
  // expected-error @+1 {{field 'y' (index 1) expects type 'i32', but got 'f32'}}
  %bad = cal.product.create(%x, %y) : !cal.product<"Vec2", [("x", i32), ("y", i32)]> : (i32, f32)
  return %bad : !cal.product<"Vec2", [("x", i32), ("y", i32)]>
}

// -----

// Test: product.get_field with invalid field name
func.func @test_product_get_invalid_field(%vec: !cal.product<"Vec2", [("x", i32), ("y", i32)]>) -> i32 {
  // expected-error @+1 {{field 'z' not found in product type 'Vec2'}}
  %z = cal.product.get_field %vec["z"] : !cal.product<"Vec2", [("x", i32), ("y", i32)]> -> i32
  return %z : i32
}

// -----

// Test: product.get_field with wrong result type
func.func @test_product_get_wrong_type(%vec: !cal.product<"Vec2", [("x", i32), ("y", i32)]>) -> f32 {
  // expected-error @+1 {{result type 'f32' does not match field 'x' type 'i32'}}
  %x = cal.product.get_field %vec["x"] : !cal.product<"Vec2", [("x", i32), ("y", i32)]> -> f32
  return %x : f32
}
