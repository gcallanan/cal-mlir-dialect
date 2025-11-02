module {
  cal.interface @CellIface
  cal.interface @DisplayIface
  cal.actor @Edge()
  {
  }
  
  cal.actor @Cell(%arg0: i1, %arg1: index, %arg2: index, %arg3: index)
  {
  }
  
  cal.actor @Display()
  {
  }
  
  cal.implements @CellIface for @Edge
  cal.implements @CellIface for @Cell
  cal.implements @DisplayIface for @Display
  cal.network @GoL(%arg0: index, %arg1: index, %arg2: tensor<?x?xi1>, %arg3: index)
  {
    %c0 = arith.constant 0 : index
    %c1 = arith.constant 1 : index
    %c6 = arith.constant 6 : index
    %0 = arith.addi %arg0, %c1 : index
    %1 = arith.addi %0, %c1 : index
    %2 = arith.addi %arg1, %c1 : index
    %3 = arith.addi %2, %c1 : index
    %4 = arith.cmpi slt, %1, %c6 : index
    %5 = arith.cmpi slt, %3, %c6 : index
    %6 = arith.select %4, %1, %c6 : index
    %7 = arith.select %5, %3, %c6 : index
    %8 = cal.instantiate @Display : <@Display>
    %9 = cal.instance.cast %8 : !cal.instance<@Display> -> !cal.instance.iface<@DisplayIface>
    %10 = cal.instance.array.init : !cal.instance.array.iface<@CellIface, [36]>
    %11 = scf.for %arg4 = %c0 to %7 step %c1 iter_args(%arg5 = %10) -> (!cal.instance.array.iface<@CellIface, [36]>) {
      %13 = scf.for %arg6 = %c0 to %6 step %c1 iter_args(%arg7 = %arg5) -> (!cal.instance.array.iface<@CellIface, [36]>) {
        %14 = arith.cmpi eq, %arg4, %c0 : index
        %15 = arith.cmpi eq, %arg4, %7 : index
        %16 = arith.addi %7, %c0 : index
        %17 = arith.subi %16, %c1 : index
        %18 = arith.cmpi eq, %arg4, %17 : index
        %19 = arith.cmpi eq, %arg6, %c0 : index
        %20 = arith.addi %6, %c0 : index
        %21 = arith.subi %20, %c1 : index
        %22 = arith.cmpi eq, %arg6, %21 : index
        %23 = arith.ori %14, %18 : i1
        %24 = arith.ori %19, %22 : i1
        %25 = arith.ori %23, %24 : i1
        %26 = arith.muli %arg4, %6 : index
        %27 = arith.addi %26, %arg6 : index
        %28 = scf.if %25 -> (!cal.instance.array.iface<@CellIface, [36]>) {
          %29 = cal.instantiate @Edge : <@Edge>
          %30 = cal.instance.cast %29 : !cal.instance<@Edge> -> !cal.instance.iface<@CellIface>
          %31 = cal.instance.array.set %arg7[%27], %30 : !cal.instance.array.iface<@CellIface, [36]>, !cal.instance.iface<@CellIface> -> !cal.instance.array.iface<@CellIface, [36]>
          scf.yield %31 : !cal.instance.array.iface<@CellIface, [36]>
        } else {
          %29 = arith.subi %arg4, %c1 : index
          %30 = arith.subi %arg6, %c1 : index
          %extracted = tensor.extract %arg2[%29, %30] : tensor<?x?xi1>
          %31 = cal.instantiate @Cell(%extracted, %29, %30, %arg3 : i1, index, index, index) : <@Cell>
          %32 = cal.instance.cast %31 : !cal.instance<@Cell> -> !cal.instance.iface<@CellIface>
          %33 = cal.instance.array.set %arg7[%27], %32 : !cal.instance.array.iface<@CellIface, [36]>, !cal.instance.iface<@CellIface> -> !cal.instance.array.iface<@CellIface, [36]>
          scf.yield %33 : !cal.instance.array.iface<@CellIface, [36]>
        }
        scf.yield %28 : !cal.instance.array.iface<@CellIface, [36]>
      }
      scf.yield %13 : !cal.instance.array.iface<@CellIface, [36]>
    }
    %12 = arith.addi %c0, %c1 : index
    scf.for %arg4 = %12 to %arg1 step %c1 {
      scf.for %arg5 = %12 to %arg0 step %c1 {
        %13 = arith.addi %arg4, %c1 : index
        %14 = arith.addi %arg5, %c1 : index
        %15 = arith.muli %13, %6 : index
        %16 = arith.addi %15, %14 : index
        %17 = arith.muli %13, %6 : index
        %18 = arith.addi %14, %c1 : index
        %19 = arith.subi %14, %c1 : index
        %20 = arith.addi %17, %18 : index
        %21 = arith.addi %17, %19 : index
        %22 = arith.addi %13, %c1 : index
        %23 = arith.muli %22, %6 : index
        %24 = arith.addi %23, %18 : index
        %25 = arith.addi %23, %14 : index
        %26 = arith.addi %23, %19 : index
        %27 = arith.subi %13, %c1 : index
        %28 = arith.muli %27, %6 : index
        %29 = arith.addi %28, %18 : index
        %30 = arith.addi %28, %14 : index
        %31 = arith.addi %28, %19 : index
        %32 = cal.instance_at %11[%16] : !cal.instance.array.iface<@CellIface, [36]> -> !cal.instance.iface<@CellIface>
        %33 = cal.instance_at %11[%20] : !cal.instance.array.iface<@CellIface, [36]> -> !cal.instance.iface<@CellIface>
        %34 = cal.instance_at %11[%21] : !cal.instance.array.iface<@CellIface, [36]> -> !cal.instance.iface<@CellIface>
        %35 = cal.instance_at %11[%24] : !cal.instance.array.iface<@CellIface, [36]> -> !cal.instance.iface<@CellIface>
        %36 = cal.instance_at %11[%25] : !cal.instance.array.iface<@CellIface, [36]> -> !cal.instance.iface<@CellIface>
        %37 = cal.instance_at %11[%26] : !cal.instance.array.iface<@CellIface, [36]> -> !cal.instance.iface<@CellIface>
        %38 = cal.instance_at %11[%29] : !cal.instance.array.iface<@CellIface, [36]> -> !cal.instance.iface<@CellIface>
        %39 = cal.instance_at %11[%30] : !cal.instance.array.iface<@CellIface, [36]> -> !cal.instance.iface<@CellIface>
        %40 = cal.instance_at %11[%31] : !cal.instance.array.iface<@CellIface, [36]> -> !cal.instance.iface<@CellIface>
        cal.connect %11[%24] : !cal.instance.array.iface<@CellIface, [36]> "Out" -> %11[%16] : !cal.instance.array.iface<@CellIface, [36]> "SE" capacity(3)
        cal.connect %11[%25] : !cal.instance.array.iface<@CellIface, [36]> "Out" -> %11[%16] : !cal.instance.array.iface<@CellIface, [36]> "S" capacity(3)
        cal.connect %11[%26] : !cal.instance.array.iface<@CellIface, [36]> "Out" -> %11[%16] : !cal.instance.array.iface<@CellIface, [36]> "SW" capacity(3)
        cal.connect %11[%20] : !cal.instance.array.iface<@CellIface, [36]> "Out" -> %11[%16] : !cal.instance.array.iface<@CellIface, [36]> "E" capacity(3)
        cal.connect %11[%21] : !cal.instance.array.iface<@CellIface, [36]> "Out" -> %11[%16] : !cal.instance.array.iface<@CellIface, [36]> "W" capacity(3)
        cal.connect %11[%29] : !cal.instance.array.iface<@CellIface, [36]> "Out" -> %11[%16] : !cal.instance.array.iface<@CellIface, [36]> "NE" capacity(3)
        cal.connect %11[%30] : !cal.instance.array.iface<@CellIface, [36]> "Out" -> %11[%16] : !cal.instance.array.iface<@CellIface, [36]> "N" capacity(3)
        cal.connect %11[%31] : !cal.instance.array.iface<@CellIface, [36]> "Out" -> %11[%16] : !cal.instance.array.iface<@CellIface, [36]> "NW" capacity(3)
        cal.connect %11[%16] : !cal.instance.array.iface<@CellIface, [36]> "Display" -> %9 : !cal.instance.iface<@DisplayIface> "in" capacity(3)
      }
    }
  }
  
}

