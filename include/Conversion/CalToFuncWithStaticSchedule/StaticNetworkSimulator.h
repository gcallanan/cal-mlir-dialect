#ifndef CAL_TO_FUNC_WITH_STATIC_SCHEDULE_STATIC_NETWORK_SIMULATOR_H
#define CAL_TO_FUNC_WITH_STATIC_SCHEDULE_STATIC_NETWORK_SIMULATOR_H

#include "Dialect/Cal/CalOps.h"
#include "Dialect/Fifo/FifoOps.h"
#include "Conversion/CalToFuncWithStaticSchedule/CycloStaticDataflowAnalysis.h"
#include "mlir/IR/Value.h"
#include "llvm/ADT/DenseMap.h"

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
  ScheduleGraph fsm;
  llvm::DenseMap<mlir::Value, Channel *> portsIn;
  llvm::DenseMap<mlir::Value, Channel *> portsOut;
};

// Function declarations
bool canFire(Actor *actor);
cal::ActionOp fire(Actor *actor);
void queueFollowOnActorsToWorklist(Actor &currentActor, 
                                  std::vector<Actor *> &worklist,
                                  llvm::DenseMap<cal::ActorOp, Actor> &actorsMap);

// Static helper methods
static std::tuple<cal::ActorOp, mlir::BlockArgument> 
getActorAndPort(mlir::Value fifoEnd);

} // namespace mlir

#endif // CAL_TO_FUNC_WITH_STATIC_SCHEDULE_STATIC_NETWORK_SIMULATOR_H