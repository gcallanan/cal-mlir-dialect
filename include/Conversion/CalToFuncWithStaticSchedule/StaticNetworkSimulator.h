#ifndef CAL_TO_FUNC_WITH_STATIC_SCHEDULE_STATIC_NETWORK_SIMULATOR_H
#define CAL_TO_FUNC_WITH_STATIC_SCHEDULE_STATIC_NETWORK_SIMULATOR_H

#include "Conversion/CalToFuncWithStaticSchedule/CycloStaticDataflowAnalysis.h"
#include "Dialect/Cal/CalOps.h"
#include "Dialect/Fifo/FifoOps.h"
#include "mlir/IR/Value.h"
#include "llvm/ADT/MapVector.h"

/// @file StaticNetworkSimulator.h
/// @brief Contains data structures and function declarations for simulating a
/// static network of CAL actors with static scheduling.
///
/// This header defines the core structures and functions used to simulate the
/// execution of a CAL network where actors are scheduled statically. It
/// includes representations for channels and actors, as well as utility
/// functions for firing actors, managing worklists, and simulating the network.
///
/// Structures:
/// - Channel: Represents a FIFO channel between two actors, including the
/// source and destination actors,
///   the operation that created the channel, and the current token count.
/// - Actor: Represents an actor in the network, including its operation,
/// current state, remaining firings,
///   scheduling graph, and input/output port mappings.
///
/// Functions:
/// - canFire: Determines if the given actor is ready to fire based on its
/// current state and channel tokens.
/// - fire: Fires the specified actor, updating its state and the network
/// accordingly.
/// - queueFollowOnActorsToWorklist: Adds actors that are enabled as a result of
/// the current actor's firing
///   to the worklist for further simulation.
/// - simulateNetwork: Simulates the execution of the entire network for a given
/// number of firings per actor
///   and according to the provided scheduling graphs.
/// - getActorAndPort: Helper function to extract the actor and port from a FIFO
/// endpoint value.
namespace mlir {

struct Channel {
  cal::ActorOp srcActor;
  cal::ActorOp dstActor;
  fifo::CreateOp createOp; // The create operation that created this channel
  int tokens;
};

struct Actor {
  cal::ActorOp actorOp;
  int currentState;
  int numFiringsLeft;
  Fsm fsm;
  llvm::MapVector<mlir::Value, Channel *> portsIn;
  llvm::MapVector<mlir::Value, Channel *> portsOut;
};

// Function declarations

/// \brief Determines if the specified actor is ready to fire.
///
/// Checks whether the given actor meets all the necessary conditions to fire
/// its next action. This typically involves verifying that the actor is in a
/// valid state, has sufficient input tokens on its input channels, and has
/// remaining firings allowed (if applicable).
///
/// \param actor Pointer to the Actor to be checked.
/// \return True if the actor can fire; false otherwise.
bool canFire(Actor *actor);

/// \brief Fires the next enabled action of the specified actor.
///
/// Executes the next action for the given actor, updating its state and
/// consuming/producing tokens on its associated channels as specified by the
/// action's semantics. This function assumes that the actor is ready to fire
/// (i.e., canFire has returned true). The actor's internal state, including
/// its current state and the number of firings left, will be updated
/// accordingly.
///
/// \param actor Pointer to the Actor to fire.
/// \return The cal::ActionOp representing the action that was fired.
cal::ActionOp fire(Actor *actor);


/// Adds the follow-on actors of the given currentActor to the worklist for further processing.
/// 
/// This function examines the currentActor and identifies any actors that should be scheduled
/// to execute after it (i.e., its follow-on actors). These follow-on actors are then added to
/// the provided worklist if they have not already been scheduled. The actorsMap is used to
/// look up Actor instances based on their corresponding cal::ActorOp.
/// 
/// @param currentActor The actor whose follow-on actors are to be added to the worklist.
/// @param worklist The list of actors pending processing; follow-on actors will be appended here.
/// @param actorsMap A mapping from cal::ActorOp to Actor, used to resolve actor instances.
void queueFollowOnActorsToWorklist(
    Actor &currentActor, std::vector<Actor *> &worklist,
    llvm::MapVector<cal::ActorOp, Actor> &actorsMap);

    std::vector<cal::ActionOp> simulateNetwork(
    cal::NetworkOp networkOp,
    const llvm::MapVector<cal::ActorOp, int> &actorFiringsPerCycle,
    const llvm::MapVector<cal::ActorOp, Fsm> &actorFsmMap);

} // namespace mlir

#endif // CAL_TO_FUNC_WITH_STATIC_SCHEDULE_STATIC_NETWORK_SIMULATOR_H