#ifndef CYCLO_STATIC_DATAFLOW_ANALYSIS_H
#define CYCLO_STATIC_DATAFLOW_ANALYSIS_H

#include "mlir/IR/Operation.h"
#include "mlir/IR/Value.h"
#include "mlir/Support/LLVM.h"
#include "llvm/ADT/DenseMap.h"
#include "llvm/Support/raw_ostream.h"
#include <optional>

namespace mlir {

struct PredicateInfo {
  mlir::arith::CmpIPredicate predicate;
  mlir::Value stateVar;
  int64_t constant;
};

// Forward declare operator<<
llvm::raw_ostream &operator<<(llvm::raw_ostream &, const PredicateInfo &);

struct CycloStaticDataflowAnalysis {
  MLIR_DEFINE_EXPLICIT_INTERNAL_INLINE_TYPE_ID(CycloStaticDataflowAnalysis)

public:
  explicit CycloStaticDataflowAnalysis(Operation *op);

private:
  llvm::DenseMap<mlir::cal::Predicate, PredicateInfo> predicateStateVariables;
  std::optional<int64_t> tryGetConstantValue(Value val);
  std::optional<int64_t> evaluateConstantValue(Value val);
  std::optional<PredicateInfo> validPredicate(cal::Predicate predicateOp);
};

} // namespace mlir

#endif // CYCLO_STATIC_DATAFLOW_ANALYSIS_H
