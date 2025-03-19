// RUN: cal-opt %s | cal-opt | FileCheck %s

module {
    // CHECK-LABEL: func @bar()
    func.func @bar() {
        %0 = arith.constant 1 : i32
        // CHECK: %{{.*}} = cal.foo %{{.*}} : i32
        %res = cal.foo %0 : i32
        return
    }

    // CHECK-LABEL: func @cal_types(%arg0: !cal.custom<"10">)
    func.func @cal_types(%arg0: !cal.custom<"10">) {
        return
    }
}
