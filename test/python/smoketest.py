# RUN: %python %s pybind11 | FileCheck %s
# RUN: %python %s nanobind | FileCheck %s

import sys
from mlir_cal.ir import *
from mlir_cal.dialects import builtin as builtin_d

if sys.argv[1] == "pybind11":
    from mlir_cal.dialects import cal_pybind11 as cal_d
elif sys.argv[1] == "nanobind":
    from mlir_cal.dialects import cal_nanobind as cal_d
else:
    raise ValueError("Expected either pybind11 or nanobind as arguments")


with Context():
    cal_d.register_dialect()
    module = Module.parse(
        """
    %0 = arith.constant 2 : i32
    %1 = cal.foo %0 : i32
    """
    )
    # CHECK: %[[C:.*]] = arith.constant 2 : i32
    # CHECK: cal.foo %[[C]] : i32
    print(str(module))
