#ifndef CYCLO_STATIC_DATAFLOW_ANALYSIS_H
#define CYCLO_STATIC_DATAFLOW_ANALYSIS_H

#include "Dialect/Cal/CalOps.h"
#include "mlir/Dialect/Arith/IR/Arith.h"
#include "mlir/IR/OpImplementation.h"
#include "mlir/IR/Operation.h"
#include "mlir/IR/Value.h"
#include "mlir/Support/LLVM.h"
#include "llvm/ADT/MapVector.h"
#include "llvm/Support/raw_ostream.h"
#include <list>
#include <optional>

namespace mlir {

// ====== Start: Everything we need to store a graph describing an actor's
// schedule
enum class GraphType {
  SingleAction,
  FSM_Unclassified, // Unclassified State Machine Schedule
  FSM_SimpleLoop, // State Machine Schedule with Simple Loop
  Dynamic // Dynamic Dataflow
};

struct ScheduleEdge {
  size_t nextNodeIndex;
};

struct ScheduleNode {
  mlir::cal::ActionOp action;
  std::list<ScheduleEdge> edges;
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

enum class StateVarUpdateKind {
  Increment,
  ConstantAssignment,
  IncrementAndModK
};

// This stores information about how a state variable is updated by an action.
// For example, if the action increments the state variable %5 by 1
// (%5 = %5 + 1), then the update pattern is {%5, Increment, 1}. If the
// action assigns a constant value to the state variable (%5 = 4), then the
// update pattern is {%5, ConstantAssignment, 4}.
struct StateVarUpdatePattern {
  mlir::Value stateVar;
  StateVarUpdateKind kind;
  int64_t value;
  int64_t modK; // Only used if kind is IncrementAndModK
};

struct SchedulingVariableInfoForAction {
  mlir::Value stateVar;
  llvm::SmallVector<PredicateInequalityInfo, 4> predicateInequalities;
  std::list<StateVarUpdatePattern> updatePatternList;
};

// ====== End: Everything we need to store scheduling variable information for
// an action

// Forward declare operator<<
llvm::raw_ostream &operator<<(llvm::raw_ostream &,
                              const PredicateInequalityInfo &);
llvm::raw_ostream &operator<<(llvm::raw_ostream &,
                              const StateVarUpdatePattern &);

/**
 * @brief Performs cyclo-static dataflow (CSDF) analysis and scheduling networks
 * of actors.
 *
 * The CycloStaticDataflowAnalysis struct provides utilities for analyzing CAL
 * actors and networks to extract their cyclo-static firing patterns, port
 * rates, generate and solve balance equations for FIFOs in the network, and
 * simulate execution schedules. It supports both single-action and multi-action
 * actors, and can construct schedule graphs representing the firing state
 * machines of actors.
 *
 * Key functionalities include:
 *   - Retrieving the sequence of SDF phases for a given CAL actor, where each
 *     phase corresponds to an action and its associated port rates.
 *   - Generating balance equations for each FIFO in a CAL network, capturing
 *     the relationship between producer and consumer actors and their data
 * rates.
 *   - Solving the system of balance equations to compute actor firing rates
 *     (repetition vectors) that ensure balanced dataflow.
 *   - Simulating the execution of a CAL network to generate a valid static
 *     schedule of actions that respects cyclo-static dataflow semantics.
 *   - Printing utilities for debugging and visualization of actor state
 *     machines, CSDF phases, balance equations, computed firing rates, and
 *     generated schedules.
 *
 * The analysis assumes that the CAL network is well-formed, with each FIFO
 * having exactly one producer and one consumer. Internally, it maintains a
 * mapping from actors to their schedule graphs, and provides helper classes for
 * constructing these graphs from action information.
 */
struct CycloStaticDataflowAnalysis {
  MLIR_DEFINE_EXPLICIT_INTERNAL_INLINE_TYPE_ID(CycloStaticDataflowAnalysis)

public:
  struct SDFPhase {
    mlir::cal::ActionOp actionOp;
    llvm::MapVector<mlir::Value, int> portRates;
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
   * @brief Retrieves the cyclo-static dataflow (CSDF) phases for a given CAL
   * actor.
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

  /// \brief Solves a set of balance equations for cyclo-static dataflow
  /// analysis.
  ///
  /// Given a collection of balance equations, this function computes the firing
  /// rates for each actor such that the data production and consumption rates
  /// are balanced across the dataflow graph.
  ///
  /// This method formulates the balance equations as a linear system, computes
  /// the nullspace of the incidence matrix using LU decomposition, and extracts
  /// a minimal integer solution representing the actor repetition vector.
  ///
  /// \param equations A vector of balance equations representing the
  /// constraints between actors in the dataflow network.
  ///
  /// \return A map mapping each ActorOp to its computed firing rate (as an
  /// int). The map contains one entry per actor involved in the equations.
  llvm::MapVector<mlir::cal::ActorOp, int>
  solveBalanceEquations(llvm::SmallVector<BalanceEquation, 4> &equations);

  /// @brief Generates a schedule for the given network operation by simulating
  /// its execution.
  ///
  /// This function performs a simulation of the provided `cal::NetworkOp` to
  /// determine a valid execution schedule for its actions. The resulting
  /// schedule is returned as a vector of `cal::ActionOp` objects, representing
  /// the order in which actions should be executed to respect the network's
  /// cyclo-static dataflow semantics.
  ///
  /// @param networkOp The network operation to be simulated and scheduled.
  /// @return A vector of `cal::ActionOp` representing the computed execution
  /// schedule.
  std::vector<cal::ActionOp>
  generateScheduleThroughSimulation(cal::NetworkOp networkOp);

  void printActorStateMachine(cal::ActorOp actorOp);
  void printCSDFPhases(cal::ActorOp actorOp);
  void printBalanceEquations(cal::NetworkOp networkOp);
  void printFiringsPerActorFromSolvedBalanceEquations(cal::NetworkOp networkOp);
  void printStaticSchedule(cal::NetworkOp networkOp);

  std::vector<cal::ActorOp> getNonSchedulableActors(cal::NetworkOp networkOp);

  std::vector<cal::ActorOp> getSchedulableActors(cal::NetworkOp networkOp);

private:
  llvm::MapVector<mlir::cal::ActorOp, ScheduleGraph> actorScheduleMap;

  void determineActorSchedule(cal::ActorOp actorOp);
  ScheduleGraph generateSingleActionSchedule(cal::ActorOp actorOp);
  ScheduleGraph generateMultiActionSchedule(cal::ActorOp actorOp);
  int getPortRateOverAllPhases(cal::ActorOp actorOp, mlir::Value port);

  std::tuple<cal::ActorOp, mlir::BlockArgument>
  getActorAndPort(mlir::Value fifoEnd);

public:
  // Helper class to construct a schedule graph from action information
  class ScheduleGraphBuilder {
  public:
    ScheduleGraphBuilder(cal::ActorOp actorOp);

    ScheduleGraph generateFsm();

  private:
    cal::ActorOp actorOp;

    bool predicateRegionsEqual(cal::Predicate firstPredicate,
                               cal::Predicate secondPredicate);
    GraphType determineFsmType(
        std::vector<ScheduleNode> &scheduleNodes, int initialStateValue);
    std::optional<ScheduleGraph> constructActorFsmFromActionInfo(
        const llvm::MapVector<cal::ActionOp, SchedulingVariableInfoForAction>
            &actionInfoMap,
        int initialStateValue);
    std::optional<int64_t> tryGetConstantValue(Value val);
    std::optional<int64_t> evaluateConstantValue(Value val);
    std::optional<PredicateInequalityInfo>
    candidatePredicateOrNull(cal::Predicate predicateOp);
    std::list<StateVarUpdatePattern>
    getStateUpdatePatternList(mlir::Value stateVar, cal::ActionOp actionOp);
    std::optional<int64_t> getIncrementAmount(Value setValue,
                                              Value targetStateVar);
    std::optional<std::pair<int64_t, int64_t>>
    detectModKPattern(Operation *defOp, Value stateRef);

    /// Determines whether a state variable is modified before a given `cal.get`
    /// operation.
    ///
    /// This function performs a worklist-based traversal of blocks to detect if
    /// any `cal.set` operation modifies the target state variable before the
    /// specified `cal.get` operation is reached. The search includes:
    /// - Operations within the same block that appear before the `cal.get`
    /// - Operations in nested regions/blocks within the current block
    /// - Operations in predecessor blocks (control flow paths leading to the
    /// current block)
    ///
    /// The traversal uses a visited set to avoid processing the same block
    /// multiple times and handles complex control flow structures within CAL
    /// actions.
    ///
    /// @param getOp The `cal.get` operation to check modifications against
    /// @param targetStateVar The state variable to check for modifications
    /// @return true if a `cal.set` operation modifying `targetStateVar` is
    /// found before
    ///         `getOp`, false otherwise
    ///
    /// Example:
    ///   %state = cal.create_state_var<i32> : !cal.state_ref<i32>
    ///   cal.set(%state: !cal.state_ref<i32>, %c0: i32)  // This would be
    ///   detected %val = cal.get(%state: !cal.state_ref<i32>) : i32
    ///
    /// This function is used to validate state update patterns and ensure that
    /// increment calculations don't depend on modified state values within the
    /// same action.
    bool isStateModifiedEarlier(cal::StateGetOp getOp, Value targetStateVar);
    int findInitialAssignment(mlir::Value stateVar);
    std::optional<cal::ActionOp> getActionForStateValue(
        int stateValue,
        const llvm::MapVector<cal::ActionOp, SchedulingVariableInfoForAction>
            &actionInfoMap);
    bool allPredicatesTrueForState(
        int stateValue, const llvm::SmallVectorImpl<PredicateInequalityInfo>
                            &predicateInequalities);
    bool hasPositiveInfinity(const SchedulingVariableInfoForAction &info);
  };
};

} // namespace mlir

#endif // CYCLO_STATIC_DATAFLOW_ANALYSIS_H
