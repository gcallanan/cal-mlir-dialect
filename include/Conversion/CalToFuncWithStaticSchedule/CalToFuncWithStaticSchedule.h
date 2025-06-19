#ifndef CAL_TO_FUNC_WITH_STATIC_SCHEDULE_H
#define CAL_TO_FUNC_WITH_STATIC_SCHEDULE_H

#include "mlir/Pass/Pass.h"
#include "mlir/Transforms/DialectConversion.h"

namespace mlir {

std::unique_ptr<mlir::Pass> createConvertCalToFuncWithStaticSchedulePass();

#define GEN_PASS_DECL_CONVERTCALTOFUNCWITHSTATICSCHEDULE
#include "Conversion/Passes.h.inc"

} // namespace mlir

#endif