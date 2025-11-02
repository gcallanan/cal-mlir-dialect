// Recreated parametric GoL structural network using SCF + instance arrays.
// This matches the requested shape:
//   network GoL(w, h, init, nSteps) ==> Display
// Entities array a is (h+2)x(w+2) with Edge() on borders and Cell(...) inside.
// Structure connects 8-neighborhood with bufferSize=3 and forwards Display.
// Note: Uses a 1D interface-typed instance array of size 36 (6x6) to emulate 2D
//       with linear indexing. Replace 4/6/36 with dynamic dims once RFC lands.

cal.interface @CellIface
cal.interface @DisplayIface

// Minimal actor stubs; behavior is not required for structural IR.
cal.actor @Edge() {
}

// Cell will accept init bit, x, y, and nSteps as parameters (used structurally here).
cal.actor @Cell(%initVal: i1, %x: index, %y: index, %nSteps: index) {
}

cal.actor @Display() {
}

// Declare interface implementations so instance.cast verifies.
cal.implements @CellIface for @Edge
cal.implements @CellIface for @Cell
cal.implements @DisplayIface for @Display

// GoL network with parameters (w, h, init, nSteps) -> Display
// For now the Display is modeled as an internal actor instance to keep
// the structural IR self-contained.
cal.network @GoL(%w: index, %h: index, %init: tensor<?x?xi1>, %nSteps: index) {
  // Dynamic extents from inputs; we clamp to a fixed 6x6 backing array for now.
  %c0 = arith.constant 0 : index
  %c1 = arith.constant 1 : index
  %c6 = arith.constant 6 : index
  %Wext1 = arith.addi %w, %c1 : index      // w+1
  %Wext  = arith.addi %Wext1, %c1 : index  // w+2
  %Hext1 = arith.addi %h, %c1 : index      // h+1
  %Hext  = arith.addi %Hext1, %c1 : index  // h+2
  // Clamp to 6 to avoid overrun of the 36-slot array (demonstration-only cap).
  %wlt = arith.cmpi slt, %Wext, %c6 : index
  %hlt = arith.cmpi slt, %Hext, %c6 : index
  %WextC = arith.select %wlt, %Wext, %c6 : index
  %HextC = arith.select %hlt, %Hext, %c6 : index

  // Capacity (buffer size) = 3 for all connections
  // The capacity is an attribute on cal.connect, so no SSA needed.

  // Single display sink handle (interface-typed)
  %disp = cal.instantiate @Display : !cal.instance<@Display>
  %dispH = cal.instance.cast %disp : !cal.instance<@Display> -> !cal.instance.iface<@DisplayIface>

  // Instance array 'a' with parametric length (HextC * WextC). Use a dynamic
  // 1D iface-typed array instead of a fixed 36.
  %len = arith.muli %HextC, %WextC : index
  %a0 = cal.instance.array.init(%len : index) : !cal.instance.array.iface<@CellIface, [?]>

  // Fill the (H+2)x(W+2) grid with Edge at borders, Cell inside.
  // Linear index: idx = i * Wext + j
  %a = scf.for %i = %c0 to %HextC step %c1 iter_args(%arr = %a0) -> (!cal.instance.array.iface<@CellIface, [?]>) {
    %arr2 = scf.for %j = %c0 to %WextC step %c1 iter_args(%arr_in = %arr) -> (!cal.instance.array.iface<@CellIface, [?]>) {
      %i0 = arith.cmpi eq, %i, %c0 : index
  %iLast = arith.cmpi eq, %i, %HextC : index // false (exclusive upper); keep code simple
  %Hextm1a = arith.addi %HextC, %c0 : index
  %Hextm1 = arith.subi %Hextm1a, %c1 : index
      %iEnd = arith.cmpi eq, %i, %Hextm1 : index
      %j0 = arith.cmpi eq, %j, %c0 : index
  %Wextm1a = arith.addi %WextC, %c0 : index
  %Wextm1 = arith.subi %Wextm1a, %c1 : index
      %jEnd = arith.cmpi eq, %j, %Wextm1 : index

      %isBorderTmp = arith.ori %i0, %iEnd : i1
      %isBorderTmp2 = arith.ori %j0, %jEnd : i1
      %isBorder = arith.ori %isBorderTmp, %isBorderTmp2 : i1

  %row = arith.muli %i, %WextC : index
      %idx = arith.addi %row, %j : index

      %arr_out = scf.if %isBorder -> (!cal.instance.array.iface<@CellIface, [?]>) {
        %e = cal.instantiate @Edge : !cal.instance<@Edge>
        %eh = cal.instance.cast %e : !cal.instance<@Edge> -> !cal.instance.iface<@CellIface>
        %set = cal.instance.array.set %arr_in[%idx], %eh : !cal.instance.array.iface<@CellIface, [?]>, !cal.instance.iface<@CellIface> -> !cal.instance.array.iface<@CellIface, [?]>
        scf.yield %set : !cal.instance.array.iface<@CellIface, [?]>
      } else {
        // Cell(init=init[i-1][j-1], x=i-1, y=j-1, nSteps)
        %im1 = arith.subi %i, %c1 : index
        %jm1 = arith.subi %j, %c1 : index
        %init_ij = tensor.extract %init[%im1, %jm1] : tensor<?x?xi1>
        %cell = cal.instantiate @Cell (%init_ij, %im1, %jm1, %nSteps : i1, index, index, index) : !cal.instance<@Cell>
        %ch = cal.instance.cast %cell : !cal.instance<@Cell> -> !cal.instance.iface<@CellIface>
        %set2 = cal.instance.array.set %arr_in[%idx], %ch : !cal.instance.array.iface<@CellIface, [?]>, !cal.instance.iface<@CellIface> -> !cal.instance.array.iface<@CellIface, [?]>
        scf.yield %set2 : !cal.instance.array.iface<@CellIface, [?]>
      }

      scf.yield %arr_out : !cal.instance.array.iface<@CellIface, [?]>
    }
    scf.yield %arr2 : !cal.instance.array.iface<@CellIface, [?]>
  }

  // Connect neighborhood for interior cells: i in 1..H, j in 1..W
  %one = arith.addi %c0, %c1 : index
  scf.for %ii = %one to %h step %c1 {
    scf.for %jj = %one to %w step %c1 {
      // Linear indices (with +1 padding offset)
      %ip1 = arith.addi %ii, %c1 : index
      %jp1 = arith.addi %jj, %c1 : index
      %rowC = arith.muli %ip1, %WextC : index
      %idxC = arith.addi %rowC, %jp1 : index

      // Neighbor indices
      %rowN0 = arith.muli %ip1, %WextC : index
      %jp1p1 = arith.addi %jp1, %c1 : index
      %jp1m1 = arith.subi %jp1, %c1 : index
      %idxE = arith.addi %rowN0, %jp1p1 : index // (i+1, j+2)
      %idxW = arith.addi %rowN0, %jp1m1 : index // (i+1, j)

      %ip1p1 = arith.addi %ip1, %c1 : index
      %rowS = arith.muli %ip1p1, %WextC : index // (i+2, *)
      %idxSE = arith.addi %rowS, %jp1p1 : index
      %idxS  = arith.addi %rowS, %jp1 : index
      %idxSW = arith.addi %rowS, %jp1m1 : index

      %ip1m1 = arith.subi %ip1, %c1 : index
      %rowN = arith.muli %ip1m1, %WextC : index // (i, *)
      %idxNE = arith.addi %rowN, %jp1p1 : index
      %idxN  = arith.addi %rowN, %jp1 : index
      %idxNW = arith.addi %rowN, %jp1m1 : index

      // Extract handles
      %hC  = cal.instance_at %a[%idxC] : !cal.instance.array.iface<@CellIface, [?]> -> !cal.instance.iface<@CellIface>
      %hE  = cal.instance_at %a[%idxE] : !cal.instance.array.iface<@CellIface, [?]> -> !cal.instance.iface<@CellIface>
      %hW  = cal.instance_at %a[%idxW] : !cal.instance.array.iface<@CellIface, [?]> -> !cal.instance.iface<@CellIface>
      %hSE = cal.instance_at %a[%idxSE] : !cal.instance.array.iface<@CellIface, [?]> -> !cal.instance.iface<@CellIface>
      %hS  = cal.instance_at %a[%idxS]  : !cal.instance.array.iface<@CellIface, [?]> -> !cal.instance.iface<@CellIface>
      %hSW = cal.instance_at %a[%idxSW] : !cal.instance.array.iface<@CellIface, [?]> -> !cal.instance.iface<@CellIface>
      %hNE = cal.instance_at %a[%idxNE] : !cal.instance.array.iface<@CellIface, [?]> -> !cal.instance.iface<@CellIface>
      %hN  = cal.instance_at %a[%idxN]  : !cal.instance.array.iface<@CellIface, [?]> -> !cal.instance.iface<@CellIface>
      %hNW = cal.instance_at %a[%idxNW] : !cal.instance.array.iface<@CellIface, [?]> -> !cal.instance.iface<@CellIface>

      // Connect neighbor Out -> cell direction port (capacity=3)
      cal.connect %hSE : !cal.instance.iface<@CellIface> "Out" -> %hC : !cal.instance.iface<@CellIface> "SE" capacity(3)
      cal.connect %hS  : !cal.instance.iface<@CellIface> "Out" -> %hC : !cal.instance.iface<@CellIface> "S"  capacity(3)
      cal.connect %hSW : !cal.instance.iface<@CellIface> "Out" -> %hC : !cal.instance.iface<@CellIface> "SW" capacity(3)
      cal.connect %hE  : !cal.instance.iface<@CellIface> "Out" -> %hC : !cal.instance.iface<@CellIface> "E"  capacity(3)
      cal.connect %hW  : !cal.instance.iface<@CellIface> "Out" -> %hC : !cal.instance.iface<@CellIface> "W"  capacity(3)
      cal.connect %hNE : !cal.instance.iface<@CellIface> "Out" -> %hC : !cal.instance.iface<@CellIface> "NE" capacity(3)
      cal.connect %hN  : !cal.instance.iface<@CellIface> "Out" -> %hC : !cal.instance.iface<@CellIface> "N"  capacity(3)
      cal.connect %hNW : !cal.instance.iface<@CellIface> "Out" -> %hC : !cal.instance.iface<@CellIface> "NW" capacity(3)

      // Display connection
      cal.connect %hC : !cal.instance.iface<@CellIface> "Display" -> %dispH : !cal.instance.iface<@DisplayIface> "in" capacity(3)
    }
  }
}
