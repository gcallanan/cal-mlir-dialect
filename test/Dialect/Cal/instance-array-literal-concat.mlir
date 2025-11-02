// RUN: cal-opt %s | FileCheck %s

module {
  cal.actor @A() {}
  cal.network @N() {
    %a0 = cal.instantiate @A : !cal.instance<@A>
    %a1 = cal.instantiate @A : !cal.instance<@A>
    %a2 = cal.instantiate @A : !cal.instance<@A>

  %arr = "cal.instance_array.literal"(%a0, %a1, %a2) : (!cal.instance<@A>, !cal.instance<@A>, !cal.instance<@A>) -> (!cal.instance.array<@A, [3]>)

    %b0 = cal.instantiate @A : !cal.instance<@A>
    %b1 = cal.instantiate @A : !cal.instance<@A>
  %arr2 = "cal.instance_array.literal"(%b0, %b1) : (!cal.instance<@A>, !cal.instance<@A>) -> (!cal.instance.array<@A, [2]>)

  %cat = "cal.instance_array.concat"(%arr, %arr2) : (!cal.instance.array<@A, [3]>, !cal.instance.array<@A, [2]>) -> (!cal.instance.array<@A, [5]>)

    // CHECK: cal.instance_array.literal
    // CHECK: cal.instance_array.concat
  }
}
