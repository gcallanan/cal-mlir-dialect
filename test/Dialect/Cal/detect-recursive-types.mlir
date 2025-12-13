// RUN: cal-opt --cal-detect-recursive-types %s | FileCheck %s

// =============================================================================
// Test 1: Non-recursive type (Maybe/Option)
// =============================================================================

// Maybe<i32> is NOT recursive - Some just holds an i32, not another Maybe

// CHECK-LABEL: func.func @test_non_recursive_maybe
func.func @test_non_recursive_maybe() {
  %c10 = arith.constant 10 : i32
  
  // CHECK: cal.variant.create "Some"
  // CHECK-NOT: cal.recursive_type
  %some = cal.variant.create "Some"(%c10)
          : !cal.variant<"Maybe", [("Some", [i32]), ("None", [])]> (i32)
  
  // CHECK: cal.variant.create "None"
  // CHECK-NOT: cal.recursive_type
  %none = cal.variant.create "None"()
          : !cal.variant<"Maybe", [("Some", [i32]), ("None", [])]>
  
  return
}

// =============================================================================
// Test 2: Non-recursive product type
// =============================================================================

// CHECK-LABEL: func.func @test_non_recursive_product
func.func @test_non_recursive_product() {
  %c1 = arith.constant 1 : i32
  %c2 = arith.constant 2 : i32
  
  // Vec2 is NOT recursive
  // CHECK: cal.product.create
  // CHECK-NOT: cal.recursive_type
  %vec = cal.product.create(%c1, %c2)
         : !cal.product<"Vec2", [("x", i32), ("y", i32)]> : (i32, i32)
  
  return
}

// =============================================================================
// Test 3: State variable with non-recursive type
// =============================================================================

// CHECK-LABEL: func.func @test_state_with_non_recursive_type
func.func @test_state_with_non_recursive_type() {
  // State variable holding Maybe should NOT be marked recursive
  // CHECK: cal.create_state_var
  // CHECK-NOT: cal.recursive_type
  %state = cal.create_state_var<!cal.variant<"Maybe", [("Some", [i32]), ("None", [])]>>
           : !cal.state_ref<!cal.variant<"Maybe", [("Some", [i32]), ("None", [])]>>
  
  return
}

// =============================================================================
// Test 4: Result type - non-recursive with nested types
// =============================================================================

// CHECK-LABEL: func.func @test_result_type
func.func @test_result_type() {
  %c1 = arith.constant 1 : i32
  
  // Result<i32, i32> is not recursive
  // CHECK: cal.variant.create "Ok"
  // CHECK-NOT: cal.recursive_type
  %ok = cal.variant.create "Ok"(%c1)
        : !cal.variant<"Result", [("Ok", [i32]), ("Err", [i32])]> (i32)
  
  return
}

// =============================================================================
// Test 5: Nested variant types (non-recursive composition)
// =============================================================================

// CHECK-LABEL: func.func @test_nested_non_recursive
func.func @test_nested_non_recursive() {
  %c1 = arith.constant 1 : i32
  
  // Outer type contains inner type but neither references itself
  // Inner: Maybe<i32>
  // CHECK: cal.variant.create "Some"
  // CHECK-NOT: cal.recursive_type
  %inner = cal.variant.create "Some"(%c1)
           : !cal.variant<"Maybe", [("Some", [i32]), ("None", [])]> (i32)
  
  // Outer: Wrapper containing Maybe<i32> - not recursive
  // CHECK: cal.variant.create "Wrapped"
  // CHECK-NOT: cal.recursive_type
  %outer = cal.variant.create "Wrapped"(%inner)
           : !cal.variant<"Wrapper", [("Wrapped", [!cal.variant<"Maybe", [("Some", [i32]), ("None", [])]>]), ("Empty", [])]> (!cal.variant<"Maybe", [("Some", [i32]), ("None", [])]>)
  
  return
}
