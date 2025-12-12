// RUN: cal-opt %s | cal-opt | FileCheck %s

// Test Arena operations
// CHECK-LABEL: func @test_arena
func.func @test_arena() {
  // CHECK: %[[ARENA:.*]] = cal.arena.create : !cal.arena
  %arena = cal.arena.create : !cal.arena
  
  // CHECK: %[[ARENA2:.*]] = cal.arena.create size(4096) : !cal.arena
  %arena2 = cal.arena.create size(4096) : !cal.arena
  
  // CHECK: cal.arena.destroy %[[ARENA]] : !cal.arena
  cal.arena.destroy %arena : !cal.arena
  
  // CHECK: cal.arena.destroy %[[ARENA2]] : !cal.arena
  cal.arena.destroy %arena2 : !cal.arena
  
  return
}

// Test Arena allocation
// CHECK-LABEL: func @test_arena_alloc
func.func @test_arena_alloc() {
  %arena = cal.arena.create : !cal.arena
  %size = arith.constant 64 : index
  %align = arith.constant 8 : index
  
  // CHECK: cal.arena.alloc {{.*}}[{{.*}}, align {{.*}}] : !cal.arena -> !llvm.ptr
  %ptr = cal.arena.alloc %arena[%size, align %align] : !cal.arena -> !llvm.ptr
  
  cal.arena.destroy %arena : !cal.arena
  return
}

// Test RC operations
// CHECK-LABEL: func @test_rc_basic
func.func @test_rc_basic(%val: i32) {
  // CHECK: cal.rc.alloc %{{.*}} : i32 -> <i32>
  %rc = cal.rc.alloc %val : i32 -> !cal.rc<i32>
  
  // CHECK: cal.rc.retain %{{.*}} : <i32>
  %rc2 = cal.rc.retain %rc : !cal.rc<i32>
  
  // CHECK: cal.rc.load %{{.*}} : <i32> -> i32
  %loaded = cal.rc.load %rc : !cal.rc<i32> -> i32
  
  // CHECK: cal.rc.release %{{.*}} : <i32>
  cal.rc.release %rc2 : !cal.rc<i32>
  
  // CHECK: cal.rc.release %{{.*}} : <i32>
  cal.rc.release %rc : !cal.rc<i32>
  
  return
}

// Test RC with variant type
// CHECK-LABEL: func @test_rc_variant
func.func @test_rc_variant() {
  %c42 = arith.constant 42 : i32
  
  // Create a variant value
  // CHECK: cal.variant.create "Some"
  %some = cal.variant.create "Some"(%c42) : !cal.variant<"Maybe", [("Some", [i32]), ("None", [])]> (i32)
  
  // Store variant in RC
  // CHECK: cal.rc.alloc %{{.*}} : !cal.variant<"Maybe", {{.*}}> -> <!cal.variant<"Maybe", {{.*}}>>
  %rc = cal.rc.alloc %some : !cal.variant<"Maybe", [("Some", [i32]), ("None", [])]> -> !cal.rc<!cal.variant<"Maybe", [("Some", [i32]), ("None", [])]>>
  
  // Load from RC
  // CHECK: cal.rc.load %{{.*}} : <!cal.variant<"Maybe", {{.*}}>> -> !cal.variant<"Maybe", {{.*}}>
  %loaded = cal.rc.load %rc : !cal.rc<!cal.variant<"Maybe", [("Some", [i32]), ("None", [])]>> -> !cal.variant<"Maybe", [("Some", [i32]), ("None", [])]>
  
  cal.rc.release %rc : !cal.rc<!cal.variant<"Maybe", [("Some", [i32]), ("None", [])]>>
  return
}

// Test RC store operation
// CHECK-LABEL: func @test_rc_store
func.func @test_rc_store(%val1: i32, %val2: i32) {
  %rc = cal.rc.alloc %val1 : i32 -> !cal.rc<i32>
  
  // CHECK: cal.rc.store %{{.*}} into %{{.*}} : i32 into <i32>
  cal.rc.store %val2 into %rc : i32 into !cal.rc<i32>
  
  cal.rc.release %rc : !cal.rc<i32>
  return
}

// Test Token operations
// CHECK-LABEL: func @test_token_basic
func.func @test_token_basic(%val: i32) {
  %arena = cal.arena.create : !cal.arena
  
  // CHECK: cal.token.wrap %{{.*}} : i32 -> <i32>
  %token = cal.token.wrap %val : i32 -> !cal.token<i32>
  
  // CHECK: cal.token.unwrap %{{.*}} into %{{.*}} : <i32> -> i32
  %unwrapped = cal.token.unwrap %token into %arena : !cal.token<i32> -> i32
  
  cal.arena.destroy %arena : !cal.arena
  return
}

// Test Token with source arena
// CHECK-LABEL: func @test_token_with_arena
func.func @test_token_with_arena(%val: i32) {
  %src_arena = cal.arena.create : !cal.arena
  %dst_arena = cal.arena.create : !cal.arena
  
  // CHECK: cal.token.wrap %{{.*}} from %{{.*}} : i32 -> <i32>
  %token = cal.token.wrap %val from %src_arena : i32 -> !cal.token<i32>
  
  %unwrapped = cal.token.unwrap %token into %dst_arena : !cal.token<i32> -> i32
  
  cal.arena.destroy %src_arena : !cal.arena
  cal.arena.destroy %dst_arena : !cal.arena
  return
}

// Test Token consume (discard)
// CHECK-LABEL: func @test_token_consume
func.func @test_token_consume(%val: i32) {
  %token = cal.token.wrap %val : i32 -> !cal.token<i32>
  
  // CHECK: cal.token.consume %{{.*}} : <i32>
  cal.token.consume %token : !cal.token<i32>
  
  return
}

// Test Token with variant type
// CHECK-LABEL: func @test_token_variant
func.func @test_token_variant() {
  %c42 = arith.constant 42 : i32
  %arena = cal.arena.create : !cal.arena
  
  %some = cal.variant.create "Some"(%c42) : !cal.variant<"Maybe", [("Some", [i32]), ("None", [])]> (i32)
  
  // CHECK: cal.token.wrap %{{.*}} : !cal.variant<"Maybe", {{.*}}> -> <!cal.variant<"Maybe", {{.*}}>>
  %token = cal.token.wrap %some : !cal.variant<"Maybe", [("Some", [i32]), ("None", [])]> -> !cal.token<!cal.variant<"Maybe", [("Some", [i32]), ("None", [])]>>
  
  // CHECK: cal.token.unwrap %{{.*}} into %{{.*}} : <!cal.variant<"Maybe", {{.*}}>> -> !cal.variant<"Maybe", {{.*}}>
  %unwrapped = cal.token.unwrap %token into %arena : !cal.token<!cal.variant<"Maybe", [("Some", [i32]), ("None", [])]>> -> !cal.variant<"Maybe", [("Some", [i32]), ("None", [])]>
  
  cal.arena.destroy %arena : !cal.arena
  return
}

// Test boxing operations
// CHECK-LABEL: func @test_boxing
func.func @test_boxing(%val: i32) {
  %arena = cal.arena.create : !cal.arena
  
  // CHECK: cal.box.in_arena %{{.*}} in %{{.*}} : i32 -> !llvm.ptr
  %boxed = cal.box.in_arena %val in %arena : i32 -> !llvm.ptr
  
  // CHECK: cal.unbox %{{.*}} : !llvm.ptr -> i32
  %unboxed = cal.unbox %boxed : !llvm.ptr -> i32
  
  cal.arena.destroy %arena : !cal.arena
  return
}

// Test deep copy operation
// CHECK-LABEL: func @test_deep_copy
func.func @test_deep_copy() {
  %c42 = arith.constant 42 : i32
  %arena = cal.arena.create : !cal.arena
  
  %some = cal.variant.create "Some"(%c42) : !cal.variant<"Maybe", [("Some", [i32]), ("None", [])]> (i32)
  
  // CHECK: cal.deep_copy %{{.*}} into %{{.*}} : !cal.variant<"Maybe", {{.*}}> in !cal.arena -> !cal.variant<"Maybe", {{.*}}>
  %copy = cal.deep_copy %some into %arena : !cal.variant<"Maybe", [("Some", [i32]), ("None", [])]> in !cal.arena -> !cal.variant<"Maybe", [("Some", [i32]), ("None", [])]>
  
  cal.arena.destroy %arena : !cal.arena
  return
}
