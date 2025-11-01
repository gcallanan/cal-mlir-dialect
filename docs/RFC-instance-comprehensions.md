<!-- markdownlint-disable MD032 MD033 MD007 MD029 -->
# RFC: Array-first instance conditionals and comprehensions in CAL IR

This RFC proposes two new high-level structural ops to model entity selection and replication directly in CAL IR without forcing frontend network flattening, with an array-first collection model that avoids MLIR tuples. It also specifies hierarchical network flattening semantics so that instances may be either actors or networks and the entire design can be fully elaborated into a flat network of actor instances and FIFO channels.

- `cal.instance_if`: a structural conditional that selects between two instance-producing regions (scalar handle or array handle).
- `cal.instance_for`: a structural comprehension that builds an array of instances from a (static or dynamic) loop.

Both ops work uniformly for actors and networks, using instance handle types and first-class instance array types. Tuples are not used for collections in this design.

## Goals

- Allow frontends to express conditional choice of entity (actor or network) and replicate entities in IR.
- Keep types homogeneous and flattenable.
- Preserve symbolic structure until an elaboration pipeline resolves it.

## Types and containers (array-first)

- Scalar handle (concrete): `!cal.instance<@Entity>` — a handle to an instance of `@Entity`, where `@Entity` is a `cal.actor` or `cal.network` symbol.
- Scalar handle (by interface): `!cal.instance<iface:@Iface>` — a handle to any entity that implements interface `@Iface`.
- Array (fixed-length, concrete): `!cal.instance.array<@Entity, N>` — homogeneous array of N handles of the same entity symbol.
- Array (fixed-length, by interface): `!cal.instance.array<iface:@Iface, N>` — homogeneous array of N handles that all implement `@Iface` (elements may be different entities, as long as they implement `@Iface`).
- Array (unknown-length): `!cal.instances<@Entity>` or `!cal.instances<iface:@Iface>` — homogeneous collection with size not yet known; resolved by a later pass.

Notes:
- Arrays are homogeneous by construction, but “homogeneous by interface” supports mixing different concrete entities provided they share the required interface.
- We do not use MLIR tuples for collections; all collection operations work on array types above.

Entity kinds:
- Actor entity: `cal.actor` symbol with optional `ports_in/ports_out` and parameters.
- Network entity: `cal.network` symbol with optional parameters and `ports_in/ports_out` that expose its boundary ports; networks may also implement interfaces.

### Entity interfaces (prerequisite)

We introduce a symbolic interface that describes the port shape an entity exposes, decoupling users from a specific actor/network symbol.

- Declare an interface:

  cal.interface @PipeLike {
    ports_in(%in : !fifo.output_port<i32>)
    ports_out(%out : !fifo.input_port<i32>)
  }

- Mark an entity as implementing an interface (as an attribute or a separate op):

  cal.actor @A() attributes { cal.implements = [@PipeLike] } ...
  cal.actor @B() attributes { cal.implements = [@PipeLike] } ...

  Alternatively, a dedicated op form can be used if preferred:

  cal.implements @PipeLike for @A
  cal.implements @PipeLike for @B

- Cast a concrete handle to an interface handle (explicit when types differ):

  %hA = cal.instantiate @A : !cal.instance<@A>
  %iA = cal.instance.cast %hA : !cal.instance<@A> -> !cal.instance<iface:@PipeLike>

  Cast succeeds only if @A implements @PipeLike. The cast is a no-op at runtime and can canonicalize away when statically typed by interface.

## New ops

### cal.instance_if

Structural conditional producing either a single instance handle or an instance array handle from two regions.

Signature (handle version):

  cal.instance_if %cond {
    // then-region
    // ... build %h_then : !cal.instance<@Entity>
    cal.instance_yield %h_then : !cal.instance<@Entity>
  } else {
    // else-region
    // ... build %h_else : !cal.instance<@Entity>
    cal.instance_yield %h_else : !cal.instance<@Entity>
  } : !cal.instance<@Entity>

Array version (fixed-length or unknown-length):

  cal.instance_if %cond {
    ... cal.instance_yield %a_then : !cal.instance.array<@Entity, N>
  } else {
    ... cal.instance_yield %a_else : !cal.instance.array<@Entity, N>
  } : !cal.instance.array<@Entity, N>

  // Unknown length variant
  cal.instance_if %cond {
    ... cal.instance_yield %u_then : !cal.instances<@Entity>
  } else {
    ... cal.instance_yield %u_else : !cal.instances<@Entity>
  } : !cal.instances<@Entity>

Interface-typed variant, enabling heterogeneous concrete branches:

  cal.instance_if %cond {
    %hA = cal.instantiate @A : !cal.instance<@A>
    %iA = cal.instance.cast %hA : !cal.instance<@A> -> !cal.instance<iface:@PipeLike>
    cal.instance_yield %iA : !cal.instance<iface:@PipeLike>
  } else {
    %hB = cal.instantiate @B : !cal.instance<@B>
    %iB = cal.instance.cast %hB : !cal.instance<@B> -> !cal.instance<iface:@PipeLike>
    cal.instance_yield %iB : !cal.instance<iface:@PipeLike>
  } : !cal.instance<iface:@PipeLike>

- Regions are single-block and terminate with `cal.instance_yield`.
- Branch result types must match exactly.
- For flattening, `%cond` should be structurally constant; otherwise a resolution pass must run before flattening.

### cal.instance_for

Builds a homogeneous array of instances with scf.for-like range syntax. The body yields exactly one scalar handle per iteration.

Signature (array result):

  %arr = cal.instance_for (%iv = %lb to %ub step %step) with @Entity ( %params : types ) {
    // %iv : index in [%lb, %ub) with step %step
    %h = cal.instantiate @Entity ( %params ) : !cal.instance<@Entity>
    cal.instance_yield %h : !cal.instance<@Entity>
  } : !cal.instance.array<@Entity, N>

Notes:
- If `%lb`, `%ub`, `%step` are constant with `step > 0`, then `N = ceildiv(max(ub - lb, 0), step)` must be used for the result length.
- If the trip count is not statically known, the result type is `!cal.instances<@Entity>`; a later pass `cal-resolve-instance-sizes` must compute the size (when possible) and refine the type to a fixed-length array.
- Nested comprehensions yield nested arrays (e.g., `!cal.instance.array<!cal.instance.array<@E, M>, N>`). An optional `cal.instances.flatten` can convert nested arrays to 1-D when that is desired.

Interface-typed array comprehension (allows mixing @A and @B):

  %arr = cal.instance_for (%iv = %lb to %ub step %step) with @PipeLike () {
    // Choose a concrete implementation per iteration
    %chooseA = arith.cmpi slt, %iv, %split : index
    %i = cal.instance_if %chooseA {
      %hA = cal.instantiate @A : !cal.instance<@A>
      %iA = cal.instance.cast %hA : !cal.instance<@A> -> !cal.instance<iface:@PipeLike>
      cal.instance_yield %iA : !cal.instance<iface:@PipeLike>
    } else {
      %hB = cal.instantiate @B : !cal.instance<@B>
      %iB = cal.instance.cast %hB : !cal.instance<@B> -> !cal.instance<iface:@PipeLike>
      cal.instance_yield %iB : !cal.instance<iface:@PipeLike>
    } : !cal.instance<iface:@PipeLike>
    cal.instance_yield %i : !cal.instance<iface:@PipeLike>
  } : !cal.instance.array<iface:@PipeLike, N>

TableGen sketch:

- Op: Cal_InstanceForOp with operands lb/ub/step (index), variadic params, and 1 region with block argument %iv:index.
- Result: `!cal.instance.array<@Entity, N>` or `!cal.instances<@Entity>`
- Terminator: Cal_InstanceYieldOp yielding a `!cal.instance<@Entity>`.

### Supporting utilities

- `cal.instance_array.concat %a, %b : !cal.instance.array<@E,N>, !cal.instance.array<@E,M> -> !cal.instance.array<@E,N+M>`
- `cal.instance_array.literal(%h0, %h1, ...) : (!cal.instance<@E>, ...) -> !cal.instance.array<@E, K>`
- `cal.instance_at %arr[%i] : !cal.instance.array<@E,N>, index -> !cal.instance<@E>`
- `cal.instances.flatten %nested : !cal.instance.array<!cal.instance.array<@E,M>,N> -> !cal.instance.array<@E, N*M>` (optional)

These enable building arrays from scalars and composing/reshaping arrays without relying on tuples.

Verifier notes (implemented):
- `cal.instance_array.literal` requires all inputs to be scalar instance handles of the same element kind:
  - For entity-typed results: all inputs must be `!cal.instance<@E>` with the same `@E`, and the result type must be `!cal.instance.array<@E, K>` where `K = #inputs`.
  - For interface-typed results: all inputs must be `!cal.instance.iface<@I>` with the same `@I`, and the result type must be `!cal.instance.array.iface<@I, K>` where `K = #inputs`.
- `cal.instance_array.concat` requires LHS and RHS to be instance arrays with matching element handle type (same `@E` or same `@I`). The result count must equal `lhs.count + rhs.count`.
- Both ops accept only homogeneous collections; mixing entity and interface element kinds is rejected.

Interface utilities:
- `cal.instance.cast %h : !cal.instance<@E> -> !cal.instance<iface:@I>`
- The array literal and concat ops accept interface-typed operands/results as long as all operands implement the target interface.

## Interop with existing ops

- `cal.instantiate(_array)`: remains valid. `cal.instance_for` can lower to repeated `cal.instantiate` plus `cal.instance_array.literal` or a series of `cal.instance_array.concat`s.
- `cal.instance_at`: defined above for arrays.
- `cal.connect`: endpoints can be concrete or interface-typed handles (scalar or arrays) or network SSA ports.
  - For interface-typed handles, port names and types are verified against the interface definition.
  - Element-wise array connect requires equal length (or unknown lengths refined later); mixing concrete and interface sides is allowed if the concrete implements the interface.
  - Scalar-to-array fan-out or array-to-scalar fan-in require explicit ops (`cal.fanout`, `cal.gather`).
  - When connecting to a network instance handle, the port names are resolved against the network’s declared `ports_in/ports_out` (or implemented interface), exactly like for actors.

## Verifier rules (summary)

- `cal.instance_if`:
  - Branch result types must match exactly.
  - Regions must end with `cal.instance_yield`.
- `cal.instance_for`:
  - Body must end with `cal.instance_yield` of type `!cal.instance<@Entity>`.
  - If result is `!cal.instance.array<@Entity,N>`, require static lb/ub/step and verify that `N = ceildiv(max(ub - lb, 0), step)`.
  - If result is `!cal.instances<@Entity>`, no static size requirement; passes that require static sizing must check and diagnose.
- Arrays must be homogeneous.

- Interfaces:
  - `cal.interface` defines a set of named ports (in/out) with types.
  - `cal.implements @Iface for @Entity` (or an equivalent attribute) requires the entity to provide a superset-compatible mapping of ports (same names/types; additional ports may be allowed with explicit rules).
  - `cal.instance.cast` is valid only if the concrete implements the interface.
  - `cal.connect` against an interface-typed handle must reference ports defined in the interface.

## Flattening pipeline

1) Resolve structural conditionals
  - Pass `cal-resolve-instance-if`: constant-fold `cal.instance_if` when possible; optionally specialize when condition depends only on `%iv` in a known way by splitting and concatenating.

2) Expand comprehensions
  - Pass `cal-lower-instance-for`: when the trip count is static, unroll the loop into repeated `cal.instantiate` and build an `cal.instance_array.literal`. When unknown, keep `!cal.instances<@Entity>` until `cal-resolve-instance-sizes`.

3) Resolve instance sizes (for unknown-length arrays)
  - Pass `cal-resolve-instance-sizes`: propagate static counts from constants/params and conditional pruning to refine `!cal.instances<@E>` to `!cal.instance.array<@E,N>` where possible.

4) Elaborate connections
  - Extend `flatten-cal-networks` to handle array endpoints and expand element-wise connects.

5) Inline network instances (hierarchical flattening)
  - Pass `cal-inline-network-instances`: inline nested `cal.network` instances into the parent network until only actor instances remain. See the new section “Hierarchical networks and inlining” for exact semantics.

6) Interface conformance and specialization (throughout)
  - Ensure all interface-typed handles are backed by entities that implement the interface where materialization requires it.
  - Elide `cal.instance.cast` once types are proven; report diagnostics if an interface handle is used without a conforming implementation in scope.

## Examples

### Conditional entity selection (actors or networks)

  %use_pipe = arith.constant true
  %h = cal.instance_if %use_pipe {
    %p = cal.instantiate @Pipe ( %cap : i32 ) : !cal.instance<@Pipe>
    cal.instance_yield %p : !cal.instance<@Pipe>
  } else {
    %q = cal.instantiate @Pipe ( %cap_slow : i32 ) : !cal.instance<@Pipe>
    cal.instance_yield %q : !cal.instance<@Pipe>
  } : !cal.instance<@Pipe>

### Comprehension over networks (array form)

  %stages = cal.instance_for (%iv = %c0 to %c4 step %c1) with @Stage (%param : i32) {
    %s = cal.instantiate @Stage ( %param : i32 ) : !cal.instance<@Stage>
    cal.instance_yield %s : !cal.instance<@Stage>
  } : !cal.instance.array<@Stage, 4>

  %i0 = arith.constant 0 : index
  %i1 = arith.constant 1 : index
  %s0 = cal.instance_at %stages[%i0] : !cal.instance.array<@Stage,4>, index -> !cal.instance<@Stage>
  %s1 = cal.instance_at %stages[%i1] : !cal.instance.array<@Stage,4>, index -> !cal.instance<@Stage>
  cal.connect %s0 "out" -> %s1 "in"

### Mixing entities via interface

  // @A and @B both implement @PipeLike
  %N = arith.constant 4 : index
  %split = arith.constant 2 : index
  %pipes = cal.instance_for (%iv = %c0 to %N step %c1) with @PipeLike () {
    %useA = arith.cmpi slt, %iv, %split : index
    %h = cal.instance_if %useA {
      %a = cal.instantiate @A : !cal.instance<@A>
      %ia = cal.instance.cast %a : !cal.instance<@A> -> !cal.instance<iface:@PipeLike>
      cal.instance_yield %ia : !cal.instance<iface:@PipeLike>
    } else {
      %b = cal.instantiate @B : !cal.instance<@B>
      %ib = cal.instance.cast %b : !cal.instance<@B> -> !cal.instance<iface:@PipeLike>
      cal.instance_yield %ib : !cal.instance<iface:@PipeLike>
    } : !cal.instance<iface:@PipeLike>
    cal.instance_yield %h : !cal.instance<iface:@PipeLike>
  } : !cal.instance.array<iface:@PipeLike, 4>

### List literal equivalent

  %a0 = cal.instantiate @A : !cal.instance<@A>
  %a1 = cal.instantiate @A : !cal.instance<@A>
  %a2 = cal.instantiate @A : !cal.instance<@A>
  %as = cal.instance_array.literal(%a0, %a1, %a2) : (!cal.instance<@A>, !cal.instance<@A>, !cal.instance<@A>) -> !cal.instance.array<@A, 3>

## Diagnostics and constraints

- Dynamic structure: if counts/conditions aren’t statically decidable, flattening fails with a precise diagnostic and source location.
- Heterogeneous element types in arrays are disallowed; use partitioning + concat instead, or a future interface-based handle.
- Recursive networks must be rejected or guarded with depth bounds.

## Migration and implementation plan

- Add `Cal_InstanceIfOp`, `Cal_InstanceYieldOp`, `Cal_InstanceForOp`, `Cal_InstanceAtOp`, `Cal_InstanceArrayLiteralOp`, and `Cal_InstanceArrayConcatOp` to TableGen with printers/parsers and verifiers.
- Implement `cal-resolve-instance-if`, `cal-lower-instance-for`, `cal-resolve-instance-sizes` passes.
- Extend `flatten-cal-networks` to support array endpoints and element-wise connect expansion; add `cal-inline-network-instances`.
- Keep `cal.instantiate_array` as sugar for constant counts; internally lower it to `cal.instance_for` producing an instance array.

## Handling heterogeneous collections (multiple entity types)

Problem: A single list may conceptually contain instances of different entities (actors or networks). MLIR types are nominal and arrays must be homogeneous, so `!cal.instance.array<@Entity, N>` cannot mix symbols.

Recommended approaches:

1) Partition into homogeneous arrays (simple and flattenable)
- Build one `!cal.instance.array<@A, Na>` per entity symbol and carry them as multiple SSA values.
- Maintain an auxiliary static tag/index map if a single conceptual order must be preserved.
- Connect by iterating each homogeneous array separately; order-sensitive topologies can be reconstructed with the tag map if truly needed.

2) Future: interface-based instance handles (existential/union)
- Introduce an interface/shape description of ports, e.g., `!cal.port.iface<in:[(name,T)...], out:[...]>` and a handle `!cal.instance<iface:Name>` implemented by multiple entities.
- `cal.connect` would verify against the interface rather than a specific symbol.
- This increases expressiveness but complicates verification and elaboration; we keep it as future work unless we see repeated need.

Non-goals for now:
- A single `!cal.instance.array<…>` holding mixed symbols without an interface is not supported; it weakens type guarantees and complicates connect verification.

## Hierarchical networks and inlining (flattening semantics)

This section defines how instances of networks are elaborated and inlined into their parent networks, enabling a fully flat network consisting only of actor instances, FIFO channels, and connections.

### Network public shape

- A `cal.network @N` may declare `ports_in(...)` and `ports_out(...)` with symbolic names and FIFO port types. These form the public boundary of the network and can be referenced by instance connections in parent networks via `cal.connect` using the port names.
- Networks may optionally implement interfaces via `cal.implements @Iface for @N`; when connecting to a network instance through an interface-typed handle, port names and types are checked against the interface.

### Instantiating an actor vs a network

- `cal.instantiate` and `cal.instantiate_array` produce handles to either actor or network symbols. The handle type encodes the symbol (`!cal.instance<@Actor>` or `!cal.instance<@Network>`), or an interface type.
- `cal.create_instance` materialization step (performed by elaboration) accepts both actor and network handles. For actor handles it emits a `cal.create_instance` targeting the actor. For network handles it triggers inlining of the referenced network (see below) and does not emit a `cal.create_instance` for the network itself.

### Inlining algorithm (cal-inline-network-instances)

Given a parent `cal.network` P with an instance of child `cal.network` C:

1. Preconditions
   - No recursion: the instance graph must be acyclic. Detect and diagnose cycles with a clear chain of symbols.
   - The trip counts and array sizes used to replicate C (via `cal.instantiate_array` or `cal.instance_for`) must be statically known before inlining, or a previous pass must have resolved them.
   - Interface conformance: if the handle is interface-typed, resolve it to a concrete symbol that implements the interface before inlining (via `cal.instance.cast` or verifier lookups).

2. Clone internals
   - Clone all operations in C’s body into P, excluding C’s region entry block and any symbolic structural ops already resolved (e.g., comprehensions), preserving relative order.
   - Use an SSA capture map to remap C’s region block arguments to the actual operands passed at the instance site (parameters and public ports).
   - Apply name mangling for symbol-like attributes (instance names) to ensure uniqueness, e.g., `parent.childX.*`.

3. Parameter and argument materialization
   - Parameters to C are plain SSA values; they can be constants (`arith.constant`), computed expressions inside P, or results of `func.call`.
   - Elaboration is structural: it does not execute code. It substitutes arguments by wiring SSA uses. Constants remain constants; function calls remain calls and are not evaluated at compile time.
   - Dominance and placement: if an argument value is defined after the instance site, move-or-clone pure producers (constants, arithmetic) before the inlined region as needed. Side-effecting ops (including unknown `func.call`s) are not moved; instead, require correct dominance at the call site and diagnose when violated.
   - Optional constant-folding can run as a separate pass before/after inlining.

4. Port rewiring
   - Internal connects inside C are cloned verbatim.
   - Connections that target C’s public ports are rewired to P’s endpoints:
     - For an internal source connected to C’s `ports_out` port “out0”, replace the endpoint with the corresponding endpoint that was connected to the network instance “out0” in P.
     - For an internal destination connected to C’s `ports_in` port “in0”, replace that endpoint with the corresponding endpoint that was connected to the network instance “in0” in P.
   - No intermediate `fifo.create` is introduced for network boundary rewiring; existing capacity on connects is preserved. If P connects a producer to the network instance input port with a capacity override, that capacity is applied to the materialized channel (diagnose multiple conflicting capacities).

5. Instance arrays
   - When inlining an array of network instances, apply the algorithm element-wise, using the element index to mangle names. All rewiring is element-wise; array fan-in/fan-out requires explicit ops.

6. Cleanup
   - Erase the network instance handle and its structural connects at P’s level once all inlined content is wired.
   - Repeat until no network instances remain under P.

### Constants and function calls in network arguments

- Constants: remain as `arith.constant` values captured and substituted. They may be constant-folded by general MLIR canonicalization/const-prop.
- Function calls:
  - Allowed as argument producers. They remain as `func.call` in P and feed the inlined uses through SSA substitution.
  - Side effects: elaboration does not reorder or duplicate side-effecting calls. If duplication would be required (e.g., multiple array elements reading the same call result but dominance forbids sharing), the pass will diagnose and request an explicit hoist or explicit replication by the user/frontend.
  - Structural requirements: any value used to form structural counts (array sizes, capacities) must be proven constant before the structural pass that requires it. Otherwise, emit a diagnostic that the structure is not statically decidable.

### Symbol resolution and scope

- Symbol lookup for actor/network/interface names follows MLIR’s nested symbol tables. When inlining, inner references are resolved relative to the nearest enclosing symbol table of C before cloning; after cloning, references are updated to point to P-local clones where applicable.
- Name mangling strategy should be deterministic and reversible enough for diagnostics, e.g., `@P::C[i]::A::instName`.

### Diagnostics (non-exhaustive)

- Recursive or cyclic network instantiation: error with instance chain.
- Unknown port name on network boundary: error lists available names.
- Multiple conflicting capacities on a single materialized channel: error with all sites listed.
- Dynamic structure (non-constant sizes or indices) where a static decision is required for inlining: precise error indicating the offending operand.

### Example: Network-in-Network with constants and call arguments

 cal.actor @leaf(%p: i32) ports_in(%i: !fifo.output_port<i32>) ports_out(%o: !fifo.input_port<i32>) {
   cal.execution_body {
     %tok = fifo.pop(%i : !fifo.output_port<i32>) : i32
     %sum = arith.addi %tok, %p : i32
     fifo.push(%o : !fifo.input_port<i32>, %sum : i32)
     %t = arith.constant true
     cal.action_done %t : i1
   }
 }

 cal.network @child(%bias: i32)
   ports_in(%in: !fifo.output_port<i32>)
   ports_out(%out: !fifo.input_port<i32>) {
   %in0, %out0 = fifo.create<i32>(2) : !fifo.input_port<i32>, !fifo.output_port<i32>
   cal.create_instance @leaf "L" (%bias : i32)
     ports_in(%out : !fifo.output_port<i32>)
     ports_out(%in0 : !fifo.input_port<i32>)
   cal.connect %out0 "out" -> %out "out" capacity(2)
 }

 cal.network @top() {
   %c10 = arith.constant 10 : i32
   %arg = func.call @producer() : () -> i32
   %inA, %outA = fifo.create<i32>(4) : !fifo.input_port<i32>, !fifo.output_port<i32>
   %inB, %outB = fifo.create<i32>(4) : !fifo.input_port<i32>, !fifo.output_port<i32>

   // Instantiate network @child with argument (%c10 + %arg)
   %sum = arith.addi %c10, %arg : i32
   %h = cal.instantiate @child (%sum : i32) : !cal.instance<@child>
   cal.connect %outA "out" -> %h "in"
   cal.connect %h "out" -> %inB "in" capacity(4)
 }

Flattening inlines @child into @top, rewires ports, preserves the capacity(4), and leaves the `func.call @producer` in place as the SSA producer for `%sum`.
