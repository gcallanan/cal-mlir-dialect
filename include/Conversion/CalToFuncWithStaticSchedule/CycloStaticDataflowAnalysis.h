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


/**
 * @brief Performs cyclo-static dataflow (CSDF) analysis on CAL actors and networks.
 *
 * The CycloStaticDataflowAnalysis struct provides utilities for analyzing CAL actors and networks
 * to extract their cyclo-static firing patterns, port rates, and to generate balance equations
 * for FIFOs in the network. It supports both single-action and multi-action actors, and can
 * construct schedule graphs representing the firing state machines of actors.
 *
 * Key functionalities include:
 *   - Retrieving the sequence of SDF phases for a given CAL actor, where each phase corresponds
 *     to an action and its associated port rates.
 *   - Generating balance equations for each FIFO in a CAL network, capturing the relationship
 *     between producer and consumer actors and their data rates.
 *   - Printing utilities for debugging and visualization of actor state machines, CSDF phases,
 *     and balance equations.
 *
 * The analysis assumes that the CAL network is well-formed, with each FIFO having exactly one
 * producer and one consumer. Internally, it maintains a mapping from actors to their schedule
 * graphs, and provides helper classes for constructing these graphs from action information.
 */
struct CycloStaticDataflowAnalysis {
  MLIR_DEFINE_EXPLICIT_INTERNAL_INLINE_TYPE_ID(CycloStaticDataflowAnalysis)

public:

  struct SDFPhase {
    mlir::cal::ActionOp actionOp;
    llvm::DenseMap<mlir::Value, int> portRates;
  };

  struct BalanceEquation {
    mlir::cal::ActorOp srcActor;
    mlir::Value srcPort;
    int srcRate;
    mlir::cal::ActorOp dstActor;
    mlir::Value dstPort;
    int dstRate;
  };

  explicit CycloStaticDataflowAnalysis(Operation *op);

  /**
 * @brief Retrieves the cyclo-static dataflow (CSDF) phases for a given CAL actor.
 *
 * This function analyzes the specified CAL actor operation and determines its
 * sequence of SDF phases, where each phase corresponds to an action and its
 * associated port rates. The phases collectively describe the actor's
 * cyclo-static firing pattern, including the number of tokens produced or
 * consumed on each port during each phase.
 *
 * @param actorOp The CAL actor operation to analyze.
 * @return An optional vector of SDFPhase objects, each representing a phase
 *         of the actor's firing schedule. Returns std::nullopt if the phases
 *         cannot be determined.
 */
  std::optional<llvm::SmallVector<SDFPhase, 4>>
  getSDFPhases(cal::ActorOp actorOp);

  /// \brief Generates balance equations for each FIFO in the given CAL network.
  ///
  /// This function analyzes the provided CAL network operation and constructs a
  /// set of balance equations, one for each FIFO (First-In-First-Out) buffer
  /// present in the network. Each balance equation captures the relationship
  /// between the producer and consumer actors connected by the FIFO, including
  /// their respective ports and data rates over all phases.
  ///
  /// The function assumes that each FIFO is created by a `fifo::CreateOp` and
  /// has exactly one producer and one consumer, as expected in a well-formed
  /// network. For each FIFO, it identifies:
  ///   - The source (producer) actor and port, and computes the total
  ///   production rate.
  ///   - The destination (consumer) actor and port, and computes the total
  ///   consumption rate.
  ///
  /// \param networkOp The CAL network operation to analyze.
  /// \return A vector of BalanceEquation objects, each representing the balance
  ///         equation for a FIFO in the network.
  llvm::SmallVector<BalanceEquation, 4>
  generateBalanceEquations(cal::NetworkOp networkOp);

  void printActorStateMachine(cal::ActorOp actorOp);
  void printCSDFPhases(cal::ActorOp actorOp);
  void printBalanceEquations(cal::NetworkOp networkOp);

private:
  llvm::DenseMap<mlir::cal::ActorOp, ScheduleGraph> actorScheduleMap;

  void determineActorSchedule(cal::ActorOp actorOp);
  ScheduleGraph generateSingleActionSchedule(cal::ActorOp actorOp);
  ScheduleGraph generateMultiActionSchedule(cal::ActorOp actorOp);
  int getPortRateOverAllPhases(cal::ActorOp actorOp, mlir::Value port);

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
