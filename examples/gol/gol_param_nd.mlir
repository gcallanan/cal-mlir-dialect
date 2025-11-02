// Parametric Game of Life (GoL) structural wiring demo using ND instance arrays.
// NOTE: This is a structural example intended to illustrate the requested IR
// shape (scf.for + instance array init/set + nested scf.for connects).
// Current toolchain constraints mean this file is not expected to elaborate
// end-to-end without the Dynamic Instance Arrays RFC implemented.
//
// Key points:
// - Parameters (w, h, nSteps) are accepted by the network to match the desired API.
// - Instance array construction uses scf.for with cal.instance.array.init/set.
// - Nested scf.for loops express neighbor connections via cal.connect with
//   array endpoints and SSA indices.
// - We use interface-typed arrays so we do not need concrete port verification now.
// - The array type is fixed [4,4] to keep IR parsable today; dynamic dims will
//   come with the RFC.
//
// Expected status with current passes:
// - Parsing should succeed.
// - Verification/canonicalization passes that require dynamic array dims,
//   array-index connects with SSA indices, or late interface port checks may fail.

cal.interface @CellIface

// Minimal concrete entity just to produce scalar handles we can cast to the
// interface type for array filling. No actions/ports are required for this demo.
cal.actor @Cell() {
}

// Declare that Cell implements the CellIface so casts are valid.
cal.implements @CellIface for @Cell

cal.network @gol(%w: index, %h: index, %nSteps: index) {
  // Constants for a fixed 4x4 grid today; RFC will allow using %w/%h directly
  %c0 = arith.constant 0 : index
  %c1 = arith.constant 1 : index
  %W = arith.constant 4 : index
  %H = arith.constant 4 : index

  // Initialize an interface-typed instance array. Current grammar uses 1D with a static count.
  // We use linear indexing (i*W + j) to emulate 2D until ND iface arrays are supported.
  %cells_init = cal.instance.array.init : !cal.instance.array.iface<@CellIface, 16>

  // Fill the array with concrete instances cast to the interface type.
  %cells = scf.for %i = %c0 to %H step %c1 iter_args(%arr0 = %cells_init) -> (!cal.instance.array.iface<@CellIface, 16>) {
    %arr1 = scf.for %j = %c0 to %W step %c1 iter_args(%arr_in = %arr0) -> (!cal.instance.array.iface<@CellIface, 16>) {
      %hnd = cal.instantiate @Cell : !cal.instance<@Cell>
      %ihnd = cal.instance.cast %hnd : !cal.instance<@Cell> -> !cal.instance.iface<@CellIface>
      %rowOff = arith.muli %i, %W : index
      %lin = arith.addi %rowOff, %j : index
      %arr_out = cal.instance.array.set %arr_in[%lin], %ihnd : !cal.instance.array.iface<@CellIface, 16>, !cal.instance.iface<@CellIface> -> !cal.instance.array.iface<@CellIface, 16>
      scf.yield %arr_out : !cal.instance.array.iface<@CellIface, 16>
    }
    scf.yield %arr1 : !cal.instance.array.iface<@CellIface, 16>
  }

  // Connect 4-neighborhood (E and S directions with symmetric W/N) to avoid duplicates.
  scf.for %i2 = %c0 to %H step %c1 {
    scf.for %j2 = %c0 to %W step %c1 {
      // East neighbor: j+1 < W
      %jp1 = arith.addi %j2, %c1 : index
      %hasE = arith.cmpi slt, %jp1, %W : index
      scf.if %hasE {
        %row = arith.muli %i2, %W : index
        %idxSrc = arith.addi %row, %j2 : index
        %idxDst = arith.addi %row, %jp1 : index
  %srcH = cal.instance_at %cells[%idxSrc] : !cal.instance.array.iface<@CellIface, 16>, index -> !cal.instance.iface<@CellIface>
  %dstH = cal.instance_at %cells[%idxDst] : !cal.instance.array.iface<@CellIface, 16>, index -> !cal.instance.iface<@CellIface>
  cal.connect %srcH : !cal.instance.iface<@CellIface> "E" -> %dstH : !cal.instance.iface<@CellIface> "W" capacity(3)
      }
      // South neighbor: i+1 < H
      %ip1 = arith.addi %i2, %c1 : index
      %hasS = arith.cmpi slt, %ip1, %H : index
      scf.if %hasS {
        %rowSrc = arith.muli %i2, %W : index
        %idxSrc2 = arith.addi %rowSrc, %j2 : index
        %rowDst = arith.muli %ip1, %W : index
        %idxDst2 = arith.addi %rowDst, %j2 : index
  %srcH2 = cal.instance_at %cells[%idxSrc2] : !cal.instance.array.iface<@CellIface, 16>, index -> !cal.instance.iface<@CellIface>
  %dstH2 = cal.instance_at %cells[%idxDst2] : !cal.instance.array.iface<@CellIface, 16>, index -> !cal.instance.iface<@CellIface>
  cal.connect %srcH2 : !cal.instance.iface<@CellIface> "S" -> %dstH2 : !cal.instance.iface<@CellIface> "N" capacity(3)
      }
    }
  }
}
