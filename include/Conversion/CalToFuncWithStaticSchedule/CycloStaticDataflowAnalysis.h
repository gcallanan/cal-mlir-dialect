#ifndef CYCLO_STATIC_DATAFLOW_ANALYSIS_H
#define CYCLO_STATIC_DATAFLOW_ANALYSIS_H

#include "Dialect/Cal/CalOps.h"
#include "mlir/Dialect/Arith/IR/Arith.h"
#include "mlir/IR/OpImplementation.h"
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

enum class StateVarUpdateKind { Increment, ConstantAssignment };

struct StateVarPattern {
  mlir::Value stateVar;
  StateVarUpdateKind kind;
  int64_t value;
};

// Forward declare operator<<
llvm::raw_ostream &operator<<(llvm::raw_ostream &, const PredicateInfo &);
llvm::raw_ostream &operator<<(llvm::raw_ostream &, const StateVarPattern &);

struct CycloStaticDataflowAnalysis {
  MLIR_DEFINE_EXPLICIT_INTERNAL_INLINE_TYPE_ID(CycloStaticDataflowAnalysis)

public:
  explicit CycloStaticDataflowAnalysis(Operation *op);

private:
  llvm::DenseMap<mlir::cal::Predicate, PredicateInfo> predicateStateVariables;
  std::optional<int64_t> tryGetConstantValue(Value val);
  std::optional<int64_t> evaluateConstantValue(Value val);
  std::optional<PredicateInfo>
  candidatePredicateOrNull(cal::Predicate predicateOp);
  std::optional<StateVarPattern>
  getStateIncrementPatternOrNull(mlir::Value stateVar, cal::ActionOp actionOp);
  std::optional<int64_t> getIncrementAmount(Value setValue,
                                            Value targetStateVar);
};

} // namespace mlir

#endif // CYCLO_STATIC_DATAFLOW_ANALYSIS_H
