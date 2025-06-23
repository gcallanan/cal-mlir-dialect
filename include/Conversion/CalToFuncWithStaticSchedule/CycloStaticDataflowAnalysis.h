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

// ====== Start: Everything we need to store a graph describing an actor's
// schedule
enum class GraphType {
  SingleAction,
  StateMachineSchedule,
  Dynamic // Dynamic Dataflow
};

enum class ScheduleEdgeType { Next, WrapAround };

struct ScheduleNode {
  mlir::cal::ActionOp action;
  size_t nextNodeIndex;
  ScheduleEdgeType edgeTypeToNextNode;
};

struct ScheduleGraph {
  GraphType type;
  mlir::cal::ActorOp actor;
  std::vector<ScheduleNode> nodes; // All schedule nodes
};

void printScheduleGraph(const ScheduleGraph &graph);
// ====== End: Everything we need to store a graph describing an actor's
// schedule

struct PredicateInequalityInfo {
  mlir::arith::CmpIPredicate predicate;
  mlir::Value stateVar;
  int64_t constant;
};

enum class StateVarUpdateKind { Increment, ConstantAssignment };

struct StateVarUpdatePattern {
  mlir::Value stateVar;
  StateVarUpdateKind kind;
  int64_t value;
};

struct SchedulingVariableInfoForAction {
  mlir::Value stateVar;
  llvm::SmallVector<PredicateInequalityInfo, 4> predicateInequalities;
  std::optional<StateVarUpdatePattern> updatePattern;
};

// Forward declare operator<<
llvm::raw_ostream &operator<<(llvm::raw_ostream &,
                              const PredicateInequalityInfo &);
llvm::raw_ostream &operator<<(llvm::raw_ostream &,
                              const StateVarUpdatePattern &);

struct CycloStaticDataflowAnalysis {
  MLIR_DEFINE_EXPLICIT_INTERNAL_INLINE_TYPE_ID(CycloStaticDataflowAnalysis)

public:
  explicit CycloStaticDataflowAnalysis(Operation *op);

private:
  llvm::DenseMap<mlir::cal::ActorOp, ScheduleGraph> actorScheduleMap;

  void determineActorSchedule(cal::ActorOp actorOp);
  void generateSingleActionSchedule(cal::ActorOp actorOp);
  void generateMultiActionSchedule(cal::ActorOp actorOp);
  std::optional<ScheduleGraph> constructScheduleGraphFromActionInfo(
      cal::ActorOp actorOp,
      const llvm::DenseMap<cal::ActionOp, SchedulingVariableInfoForAction>
          &actionInfoMap,
      int initialStateValue);

  std::optional<int64_t> tryGetConstantValue(Value val);
  std::optional<int64_t> evaluateConstantValue(Value val);
  std::optional<PredicateInequalityInfo>
  candidatePredicateOrNull(cal::Predicate predicateOp);
  std::optional<StateVarUpdatePattern>
  getStateUpdatePatternOrNull(mlir::Value stateVar, cal::ActionOp actionOp);
  std::optional<int64_t> getIncrementAmount(Value setValue,
                                            Value targetStateVar);
  int findInitialAssignment(mlir::Value stateVar, cal::ActorOp);
  std::optional<cal::ActionOp> getActionForStateValue(
      int stateValue,
      const llvm::DenseMap<cal::ActionOp, SchedulingVariableInfoForAction>
          &actionInfoMap);
  bool
  allPredicatesTrueForState(int stateValue,
                            const llvm::SmallVectorImpl<PredicateInequalityInfo>
                                &predicateInequalities);

  // bool addGraphEdge(ScheduleNode &fromNode,
  //                      ScheduleNode &toNode);
};

} // namespace mlir

#endif // CYCLO_STATIC_DATAFLOW_ANALYSIS_H
