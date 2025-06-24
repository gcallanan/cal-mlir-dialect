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
  size_t initialStateValue;        // The initial state value for the FSM
};

void printScheduleGraph(const ScheduleGraph &graph);
// ====== End: Everything we need to store a graph describing an actor's
// schedule

// ====== Start: Everything we need to store scheduling variable information
// for an action

// This stores information about the predicates of an action of they can
// be turned into an inequality. For example: if predicate equals ==, stateVar
// is %5 and constant equals 10, then the predicate inequality is %5 != 10.
struct PredicateInequalityInfo {
  mlir::arith::CmpIPredicate predicate;
  mlir::Value stateVar;
  int64_t constant;
};

enum class StateVarUpdateKind { Increment, ConstantAssignment };

// This stores information about how a state variable is updated by an action.
// For example, if the action increments the state variable %5 by 1
// (%5 = %5 + 1), then the update pattern is {%5, Increment, 1}. If the
// action assigns a constant value to the state variable (%5 = 4), then the
// update pattern is {%5, ConstantAssignment, 4}.
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

// ====== End: Everything we need to store scheduling variable information for
// an action

// Forward declare operator<<
llvm::raw_ostream &operator<<(llvm::raw_ostream &,
                              const PredicateInequalityInfo &);
llvm::raw_ostream &operator<<(llvm::raw_ostream &,
                              const StateVarUpdatePattern &);

struct CycloStaticDataflowAnalysis {
  MLIR_DEFINE_EXPLICIT_INTERNAL_INLINE_TYPE_ID(CycloStaticDataflowAnalysis)

public:
  struct SDFPhase {
    mlir::cal::ActionOp actionOp;
    llvm::DenseMap<mlir::Value, int> portRates;
  };

  explicit CycloStaticDataflowAnalysis(Operation *op);

  std::optional<llvm::SmallVector<SDFPhase, 4>>
  getSDFPhases(cal::ActorOp actorOp);

  void printActorStateMachine(cal::ActorOp actorOp);
  void printCSDFPhases(cal::ActorOp actorOp);

private:
  llvm::DenseMap<mlir::cal::ActorOp, ScheduleGraph> actorScheduleMap;

  void determineActorSchedule(cal::ActorOp actorOp);
  ScheduleGraph generateSingleActionSchedule(cal::ActorOp actorOp);
  ScheduleGraph generateMultiActionSchedule(cal::ActorOp actorOp);
  
  llvm::DenseMap<mlir::Value, int>
  generatePortRates(mlir::cal::ActionOp actionOp);

public:
  // Helper class to construct a schedule graph from action information
  class ScheduleGraphBuilder {
  public:
    ScheduleGraphBuilder(cal::ActorOp actorOp);
    ScheduleGraph generateFsm();

  private:
    cal::ActorOp actorOp;

    std::optional<ScheduleGraph> constructScheduleGraphFromActionInfo(
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
    int findInitialAssignment(mlir::Value stateVar);
    std::optional<cal::ActionOp> getActionForStateValue(
        int stateValue,
        const llvm::DenseMap<cal::ActionOp, SchedulingVariableInfoForAction>
            &actionInfoMap);
    bool allPredicatesTrueForState(
        int stateValue, const llvm::SmallVectorImpl<PredicateInequalityInfo>
                            &predicateInequalities);
    bool hasPositiveInfinity(const SchedulingVariableInfoForAction &info);
  };
};

} // namespace mlir

#endif // CYCLO_STATIC_DATAFLOW_ANALYSIS_H
