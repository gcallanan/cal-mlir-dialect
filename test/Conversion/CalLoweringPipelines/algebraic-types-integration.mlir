// RUN: cal-opt --convert-cal-variant-to-llvm --convert-cal-memory-to-llvm --reconcile-unrealized-casts %s | FileCheck %s

// This test verifies that algebraic types (variant, product) and memory management
// operations (arena, boxing) work together correctly through the lowering pipeline.

// -----------------------------------------------------------------------------
// Test 1: Create a Maybe<i32> variant and store it in an arena
// -----------------------------------------------------------------------------

// CHECK-LABEL: func.func @test_variant_in_arena
// CHECK: llvm.call @malloc
// CHECK: llvm.mlir.undef : !llvm.struct<(i32, array<4 x i8>)>
// CHECK: llvm.insertvalue
// CHECK: llvm.extractvalue {{.*}}[0]
// CHECK: llvm.load {{.*}} -> i32
// CHECK: llvm.call @free
// CHECK: return {{.*}} : i32
func.func @test_variant_in_arena() -> i32 {
  // Create arena
  %arena = cal.arena.create : !cal.arena

  // Create Some(42) variant
  %val = arith.constant 42 : i32
  %some = cal.variant.create "Some"(%val) : !cal.variant<"Maybe", [("Some", [i32]), ("None", [])]> (i32)

  // Get the tag
  %tag = cal.variant.get_tag %some : !cal.variant<"Maybe", [("Some", [i32]), ("None", [])]> -> index

  // Get the field value
  %result = cal.variant.get_field %some["Some", 0] : !cal.variant<"Maybe", [("Some", [i32]), ("None", [])]> -> i32

  // Destroy arena
  cal.arena.destroy %arena : !cal.arena

  return %result : i32
}

// -----------------------------------------------------------------------------
// Test 2: Deep copy a product type into an arena
// -----------------------------------------------------------------------------

// CHECK-LABEL: func.func @test_product_deep_copy
// CHECK: llvm.call @malloc
// CHECK: llvm.mlir.undef : !llvm.struct<(i32, i32)>
// CHECK: llvm.insertvalue
// CHECK: llvm.insertvalue
// CHECK: llvm.getelementptr {{.*}}[{{.*}}, 0]
// CHECK: llvm.load
// CHECK: llvm.getelementptr {{.*}}[{{.*}}, 1]
// CHECK: llvm.load
// CHECK: llvm.store {{.*}} : i64, !llvm.ptr
// CHECK: llvm.getelementptr
// CHECK: llvm.store {{.*}} : !llvm.struct<(i32, i32)>
// CHECK: llvm.load {{.*}} -> !llvm.struct<(i32, i32)>
// CHECK: llvm.extractvalue {{.*}}[0]
// CHECK: llvm.call @free
// CHECK: return {{.*}} : i32
func.func @test_product_deep_copy() -> i32 {
  // Create arena
  %arena = cal.arena.create : !cal.arena

  // Create a Vec2 product
  %x = arith.constant 10 : i32
  %y = arith.constant 20 : i32
  %vec = cal.product.create(%x, %y) : !cal.product<"Vec2", [("x", i32), ("y", i32)]> : (i32, i32)

  // Deep copy the product into the arena
  %vec_copy = cal.deep_copy %vec into %arena : !cal.product<"Vec2", [("x", i32), ("y", i32)]> in !cal.arena -> !cal.product<"Vec2", [("x", i32), ("y", i32)]>

  // Get the x field from the copy
  %x_val = cal.product.get_field %vec_copy["x"] : !cal.product<"Vec2", [("x", i32), ("y", i32)]> -> i32

  // Destroy arena
  cal.arena.destroy %arena : !cal.arena

  return %x_val : i32
}

// -----------------------------------------------------------------------------
// Test 3: Box a variant value in arena
// -----------------------------------------------------------------------------

// CHECK-LABEL: func.func @test_box_variant_in_arena
// CHECK: llvm.call @malloc
// CHECK: llvm.mlir.undef : !llvm.struct<(i32, array<4 x i8>)>
// CHECK: llvm.mlir.constant(1 : i32)
// CHECK: llvm.insertvalue
// CHECK: llvm.getelementptr {{.*}}[{{.*}}, 0]
// CHECK: llvm.load
// CHECK: llvm.getelementptr {{.*}}[{{.*}}, 1]
// CHECK: llvm.load
// CHECK: llvm.store {{.*}} : i64, !llvm.ptr
// CHECK: llvm.getelementptr
// CHECK: llvm.store {{.*}} : !llvm.struct
// CHECK: llvm.load {{.*}} -> !llvm.struct
// CHECK: llvm.extractvalue {{.*}}[0]
// CHECK: llvm.zext
// CHECK: arith.index_cast
// CHECK: llvm.call @free
// CHECK: return {{.*}} : i32
func.func @test_box_variant_in_arena() -> i32 {
  // Create arena
  %arena = cal.arena.create : !cal.arena

  // Create None variant
  %none = cal.variant.create "None"() : !cal.variant<"Maybe", [("Some", [i32]), ("None", [])]>

  // Box the variant in the arena (returns a pointer)
  %boxed = cal.box.in_arena %none in %arena : !cal.variant<"Maybe", [("Some", [i32]), ("None", [])]> -> !llvm.ptr

  // Unbox the variant
  %unboxed = cal.unbox %boxed : !llvm.ptr -> !cal.variant<"Maybe", [("Some", [i32]), ("None", [])]>

  // Get tag of the unboxed value (should be 1 for None)
  %tag = cal.variant.get_tag %unboxed : !cal.variant<"Maybe", [("Some", [i32]), ("None", [])]> -> index
  %tag_i32 = arith.index_cast %tag : index to i32

  // Destroy arena
  cal.arena.destroy %arena : !cal.arena

  return %tag_i32 : i32
}

// -----------------------------------------------------------------------------
// Test 4: Reference counted variant
// -----------------------------------------------------------------------------

// CHECK-LABEL: func.func @test_rc_variant
// CHECK: llvm.mlir.undef : !llvm.struct<(i32, array<4 x i8>)>
// CHECK: llvm.insertvalue
// CHECK: llvm.call @malloc
// CHECK: llvm.store {{.*}} : i32, !llvm.ptr
// CHECK: llvm.atomicrmw add
// CHECK: llvm.getelementptr
// CHECK: llvm.load
// CHECK: llvm.load {{.*}} -> i32
// CHECK: llvm.atomicrmw sub
// CHECK: llvm.atomicrmw sub
// CHECK: return {{.*}} : i32
func.func @test_rc_variant() -> i32 {
  // Create Some(100) variant
  %val = arith.constant 100 : i32
  %some = cal.variant.create "Some"(%val) : !cal.variant<"Maybe", [("Some", [i32]), ("None", [])]> (i32)

  // Allocate RC container for the variant
  %rc = cal.rc.alloc %some : !cal.variant<"Maybe", [("Some", [i32]), ("None", [])]> -> !cal.rc<!cal.variant<"Maybe", [("Some", [i32]), ("None", [])]>>

  // Retain (increment refcount)
  %rc2 = cal.rc.retain %rc : !cal.rc<!cal.variant<"Maybe", [("Some", [i32]), ("None", [])]>>

  // Load the variant from RC
  %loaded = cal.rc.load %rc : !cal.rc<!cal.variant<"Maybe", [("Some", [i32]), ("None", [])]>> -> !cal.variant<"Maybe", [("Some", [i32]), ("None", [])]>

  // Get field from loaded variant
  %result = cal.variant.get_field %loaded["Some", 0] : !cal.variant<"Maybe", [("Some", [i32]), ("None", [])]> -> i32

  // Release both references
  cal.rc.release %rc : !cal.rc<!cal.variant<"Maybe", [("Some", [i32]), ("None", [])]>>
  cal.rc.release %rc2 : !cal.rc<!cal.variant<"Maybe", [("Some", [i32]), ("None", [])]>>

  return %result : i32
}
