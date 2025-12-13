// RUN: cal-opt --convert-cal-memory-to-llvm %s | FileCheck %s

// ============================================================================
// Test recursive RC release for nested types with pointer fields
// ============================================================================
// These tests must come first because the generated release function appears
// at the beginning of the module output.

// For variant types containing pointer fields (like recursive list types),
// the lowering should generate a type-specific release function that:
// 1. Atomically decrements the refcount
// 2. If count reaches zero: switch on variant tag
// 3. For each case with pointer fields, recursively release them
// 4. Free the RC container

// The release function is generated at module level - check it exists somewhere
// CHECK-DAG: llvm.func private @__cal_release_List(%{{.*}}: !llvm.ptr)
// CHECK-DAG: llvm.func private @__cal_release_Tree(%{{.*}}: !llvm.ptr)

// CHECK-LABEL: func.func @test_rc_release_recursive_list
func.func @test_rc_release_recursive_list(
    %rc: !cal.rc<!cal.variant<"List", [("Cons", [i32, !llvm.ptr]), ("Nil", [])]>>) {
  // Should call the generated release function instead of inline free
  // CHECK: llvm.call @__cal_release_List
  cal.rc.release %rc : !cal.rc<!cal.variant<"List", [("Cons", [i32, !llvm.ptr]), ("Nil", [])]>>
  return
}

// ============================================================================
// Test mutual recursion support
// ============================================================================
// For mutual recursion (type A references type B, type B references type A),
// the pointee type can be specified via module attribute cal.pointer_field_types.
// Without this annotation, the default behavior assumes self-recursion.
// 
// When fully implemented, a Forest type with Trees would look like:
//   !cal.variant<"Forest", [("Trees", [!llvm.ptr]), ("Empty", [])]>
// And Tree type with back-reference to Forest:
//   !cal.variant<"Tree", [("Node", [i32, !llvm.ptr]), ("Leaf", [])]>
// 
// The module attribute would specify:
//   module attributes { cal.pointer_field_types = {
//     "Forest::Trees::0" = !cal.variant<"Tree", ...>,
//     "Tree::Node::1" = !cal.variant<"Forest", ...>
//   }}
//
// For now, we test that:
// 1. Self-recursive types generate correct release functions (already tested above)
// 2. Different recursive types generate different release functions

// This tests that two different recursive types get separate release functions
// CHECK-LABEL: func.func @test_different_recursive_types
// CHECK: llvm.call @__cal_release_List
// CHECK: llvm.call @__cal_release_Tree
func.func @test_different_recursive_types(
    %list: !cal.rc<!cal.variant<"List", [("Cons", [i32, !llvm.ptr]), ("Nil", [])]>>,
    %tree: !cal.rc<!cal.variant<"Tree", [("Node", [i32, !llvm.ptr, !llvm.ptr]), ("Leaf", [i32])]>>) {
  // Each type should call its own release function
  cal.rc.release %list : !cal.rc<!cal.variant<"List", [("Cons", [i32, !llvm.ptr]), ("Nil", [])]>>
  cal.rc.release %tree : !cal.rc<!cal.variant<"Tree", [("Node", [i32, !llvm.ptr, !llvm.ptr]), ("Leaf", [i32])]>>
  return
}

// Test that simple types without pointer fields use inline release (not a generated function)
// CHECK-LABEL: func.func @test_rc_release_simple_variant
func.func @test_rc_release_simple_variant(
    %rc: !cal.rc<!cal.variant<"Maybe", [("Some", [i32]), ("None", [])]>>) {
  // Simple variant without pointer fields should use inline atomic decrement + conditional free
  // CHECK: llvm.atomicrmw sub
  // CHECK: llvm.icmp "eq"
  // CHECK: llvm.cond_br
  // CHECK: llvm.call @free
  cal.rc.release %rc : !cal.rc<!cal.variant<"Maybe", [("Some", [i32]), ("None", [])]>>
  return
}

// ============================================================================
// Test arena operations lowering
// ============================================================================
// Note: !cal.arena is lowered to !llvm.ptr (pointer to arena struct in memory)
// The arena struct layout is { ptr base, i64 offset, i64 capacity }

// CHECK-LABEL: func.func @test_arena_create
func.func @test_arena_create() -> !cal.arena {
  // Allocate arena struct header (24 bytes)
  // CHECK: llvm.mlir.constant(24 : i64)
  // CHECK: llvm.call @malloc
  // Allocate backing buffer
  // CHECK: llvm.mlir.constant(4096 : i64)
  // CHECK: llvm.call @malloc
  // Store fields into arena struct (via GEP + store)
  // CHECK: llvm.getelementptr
  // CHECK: llvm.store
  // CHECK: llvm.getelementptr
  // CHECK: llvm.store
  // CHECK: llvm.getelementptr
  // CHECK: llvm.store
  %arena = cal.arena.create : !cal.arena
  return %arena : !cal.arena
}

// CHECK-LABEL: func.func @test_arena_create_with_size
func.func @test_arena_create_with_size() -> !cal.arena {
  // CHECK: llvm.mlir.constant(8192 : i64)
  // CHECK: llvm.call @malloc
  %arena = cal.arena.create size(8192) : !cal.arena
  return %arena : !cal.arena
}

// CHECK-LABEL: func.func @test_arena_destroy
func.func @test_arena_destroy(%arena: !cal.arena) {
  // Load base pointer, then free both buffer and arena struct
  // CHECK: llvm.getelementptr
  // CHECK: llvm.load
  // CHECK: llvm.call @free
  // CHECK: llvm.call @free
  cal.arena.destroy %arena : !cal.arena
  return
}

// CHECK-LABEL: func.func @test_arena_alloc
func.func @test_arena_alloc(%arena: !cal.arena, %size: index, %align: index) -> !llvm.ptr {
  // Load base pointer and current offset from arena struct (via GEP)
  // CHECK: llvm.getelementptr {{.*}}[{{.*}}, 0]
  // CHECK: llvm.load
  // CHECK: llvm.getelementptr {{.*}}[{{.*}}, 1]
  // CHECK: llvm.load
  // Load capacity for bounds checking
  // CHECK: llvm.getelementptr {{.*}}[{{.*}}, 2]
  // CHECK: llvm.load
  // Compute aligned offset
  // CHECK: llvm.sub
  // CHECK: llvm.add
  // CHECK: llvm.xor
  // CHECK: llvm.and
  // Compute new offset: aligned + size
  // CHECK: llvm.add
  // Bounds check: if newOffset > capacity, branch to abort
  // CHECK: llvm.icmp "ugt"
  // CHECK: llvm.cond_br
  // Abort block
  // CHECK: llvm.call @abort
  // CHECK: llvm.unreachable
  // Continuation block: Store new offset back to arena struct
  // CHECK: llvm.store {{.*}} : i64, !llvm.ptr
  // Return result pointer
  // CHECK: llvm.getelementptr
  %ptr = cal.arena.alloc %arena[%size, align %align] : !cal.arena -> !llvm.ptr
  return %ptr : !llvm.ptr
}

// Test RC operations lowering

// CHECK-LABEL: func.func @test_rc_alloc
func.func @test_rc_alloc(%val: i64) -> !cal.rc<i64> {
  // CHECK: llvm.call @malloc
  // CHECK: llvm.mlir.constant(1 : i32)
  // CHECK: llvm.store %{{.*}} : i32, !llvm.ptr
  %rc = cal.rc.alloc %val : i64 -> !cal.rc<i64>
  return %rc : !cal.rc<i64>
}

// CHECK-LABEL: func.func @test_rc_retain
func.func @test_rc_retain(%rc: !cal.rc<i64>) -> !cal.rc<i64> {
  // CHECK: llvm.mlir.constant(1 : i32)
  // CHECK: llvm.atomicrmw add %{{.*}}, %{{.*}} seq_cst
  %rc2 = cal.rc.retain %rc : !cal.rc<i64>
  return %rc2 : !cal.rc<i64>
}

// CHECK-LABEL: func.func @test_rc_release
func.func @test_rc_release(%rc: !cal.rc<i64>) {
  // CHECK: llvm.mlir.constant(1 : i32)
  // CHECK: llvm.atomicrmw sub %{{.*}}, %{{.*}} seq_cst
  // CHECK: llvm.icmp "eq"
  // CHECK: llvm.cond_br
  cal.rc.release %rc : !cal.rc<i64>
  return
}

// CHECK-LABEL: func.func @test_rc_load
func.func @test_rc_load(%rc: !cal.rc<i64>) -> i64 {
  // Payload offset is (4 + align - 1) & ~(align - 1) = 8 for i64 (align 8)
  // CHECK: llvm.mlir.constant(8 : i64)
  // CHECK: llvm.getelementptr
  // CHECK: llvm.load
  %val = cal.rc.load %rc : !cal.rc<i64> -> i64
  return %val : i64
}

// CHECK-LABEL: func.func @test_rc_store
func.func @test_rc_store(%rc: !cal.rc<i64>, %val: i64) {
  // Payload offset is (4 + align - 1) & ~(align - 1) = 8 for i64 (align 8)
  // CHECK: llvm.mlir.constant(8 : i64)
  // CHECK: llvm.getelementptr
  // CHECK: llvm.store
  cal.rc.store %val into %rc : i64 into !cal.rc<i64>
  return
}

// Test token operations lowering

// CHECK-LABEL: func.func @test_token_wrap
func.func @test_token_wrap(%val: i64) -> !cal.token<i64> {
  // CHECK: llvm.call @malloc
  // CHECK: llvm.store
  %tok = cal.token.wrap %val : i64 -> !cal.token<i64>
  return %tok : !cal.token<i64>
}

// CHECK-LABEL: func.func @test_token_unwrap
func.func @test_token_unwrap(%tok: !cal.token<i64>, %arena: !cal.arena) -> i64 {
  // CHECK: llvm.load
  %val = cal.token.unwrap %tok into %arena : !cal.token<i64> -> i64
  return %val : i64
}

// CHECK-LABEL: func.func @test_token_consume
func.func @test_token_consume(%tok: !cal.token<i64>) {
  // CHECK: llvm.call @free
  cal.token.consume %tok : !cal.token<i64>
  return
}

// Test boxing operations

// CHECK-LABEL: func.func @test_box_in_arena
func.func @test_box_in_arena(%val: i64, %arena: !cal.arena) -> !llvm.ptr {
  // Load base pointer and current offset from arena struct
  // CHECK: llvm.getelementptr {{.*}}[{{.*}}, 0]
  // CHECK: llvm.load
  // CHECK: llvm.getelementptr {{.*}}[{{.*}}, 1]
  // CHECK: llvm.load
  // Load capacity for bounds checking
  // CHECK: llvm.getelementptr {{.*}}[{{.*}}, 2]
  // CHECK: llvm.load
  // Align offset
  // CHECK: llvm.sub
  // CHECK: llvm.add
  // CHECK: llvm.xor
  // CHECK: llvm.and
  // Compute new offset
  // CHECK: llvm.add
  // Bounds check: if newOffset > capacity, branch to abort
  // CHECK: llvm.icmp "ugt"
  // CHECK: llvm.cond_br
  // Abort block
  // CHECK: llvm.call @abort
  // CHECK: llvm.unreachable
  // Continuation block: Store new offset back to arena
  // CHECK: llvm.store {{.*}} : i64, !llvm.ptr
  // Compute result pointer
  // CHECK: llvm.getelementptr
  // Store the value
  // CHECK: llvm.store {{.*}} : i64, !llvm.ptr
  %ptr = cal.box.in_arena %val in %arena : i64 -> !llvm.ptr
  return %ptr : !llvm.ptr
}

// CHECK-LABEL: func.func @test_unbox
func.func @test_unbox(%ptr: !llvm.ptr) -> i64 {
  // CHECK: llvm.load %arg0
  %val = cal.unbox %ptr : !llvm.ptr -> i64
  return %val : i64
}

// Test deep copy operation

// CHECK-LABEL: func.func @test_deep_copy
func.func @test_deep_copy(%val: i64, %arena: !cal.arena) -> i64 {
  // Load base pointer and current offset from arena struct
  // CHECK: llvm.getelementptr {{.*}}[{{.*}}, 0]
  // CHECK: llvm.load
  // CHECK: llvm.getelementptr {{.*}}[{{.*}}, 1]
  // CHECK: llvm.load
  // Load capacity for bounds checking
  // CHECK: llvm.getelementptr {{.*}}[{{.*}}, 2]
  // CHECK: llvm.load
  // Align offset
  // CHECK: llvm.sub
  // CHECK: llvm.add
  // CHECK: llvm.xor
  // CHECK: llvm.and
  // Compute new offset
  // CHECK: llvm.add
  // Bounds check: if newOffset > capacity, branch to abort
  // CHECK: llvm.icmp "ugt"
  // CHECK: llvm.cond_br
  // Abort block
  // CHECK: llvm.call @abort
  // CHECK: llvm.unreachable
  // Continuation block: Store new offset back to arena
  // CHECK: llvm.store {{.*}} : i64, !llvm.ptr
  // Compute destination pointer
  // CHECK: llvm.getelementptr
  // Store value to arena
  // CHECK: llvm.store {{.*}} : i64, !llvm.ptr
  // Load back the copied value
  // CHECK: llvm.load {{.*}} -> i64
  %copy = cal.deep_copy %val into %arena : i64 in !cal.arena -> i64
  return %copy : i64
}
