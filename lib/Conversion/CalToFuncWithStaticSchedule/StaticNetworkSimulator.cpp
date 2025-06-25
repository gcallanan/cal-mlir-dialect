#include "Conversion/CalToFuncWithStaticSchedule/StaticNetworkSimulator.h"

namespace mlir {

// Returns true if the actor can fire its current action (enough tokens, firings
// left)
bool canFire(Actor *actor) {

  if (actor->numFiringsLeft <= 0)
    return false;

  // llvm::outs() << "Checking if actor can fire: " <<
  // actor->actorOp.getSymName()
  //              << " in state: " << actor->currentState << "\n";

  auto actionOp = actor->fsm.nodes[actor->currentState].action;
  auto portRates = actionOp.getPortRates();

  // Check if there are enough tokens on input ports
  for (auto &portRate : portRates) {
    auto port = portRate.first;

    // A negative port rate means that data is consumed
    if (portRate.second < 0) {
      int rate = std::abs(portRate.second);

      // If there are not enough tokens in the channel to consume
      // Then it cannot fire
      Channel *channel = actor->portsIn[port];
      if (channel->tokens < rate) {
        return false;
      }
    }
  }

  return true;
}

cal::ActionOp fire(Actor *actor) {
  auto actionOp = actor->fsm.nodes[actor->currentState].action;
  auto portRates = actionOp.getPortRates();

  // Consume tokens from input ports
  for (auto &portRate : portRates) {
    auto port = portRate.first;
    int rate = std::abs(portRate.second);
    if (auto it = actor->portsIn.find(port); it != actor->portsIn.end()) {
      Channel *channel = it->second;
      if (channel->tokens < rate) {
        llvm::errs() << "Error: Not enough tokens on input port "
                     << port.getAsOpaquePointer() << " to fire action "
                     << actionOp.getActionNameAttr().getValue() << "\n";
      }
      channel->tokens -= rate; // Consume tokens
    }
  }

  // Produce tokens on output ports
  for (auto &portRate : portRates) {
    auto port = portRate.first;
    int rate = std::abs(portRate.second);
    if (auto it = actor->portsOut.find(port); it != actor->portsOut.end()) {
      Channel *channel = it->second;
      channel->tokens += rate; // Produce tokens
    }
  }

  // Advance the actors internal state machine
  ScheduleNode fsmNode = actor->fsm.nodes[actor->currentState];
  if (fsmNode.edgeTypeToNextNode == ScheduleEdgeType::WrapAround) {
    actor->numFiringsLeft--;
  }
  actor->currentState = fsmNode.nextNodeIndex;

  return actionOp; // Return the action that was fired
}

void queueFollowOnActorsToWorklist(
    Actor &currentActor, std::vector<Actor *> &worklist,
    llvm::DenseMap<cal::ActorOp, Actor> &actorsMap) {
  std::vector<Actor *> followOnWorklist;

  // For each output port, find the connected channel and destination actor
  for (auto &portOut : currentActor.portsOut) {
    Channel *channel = portOut.second;
    cal::ActorOp dstActorOp = channel->dstActor;
    auto it = actorsMap.find(dstActorOp);
    if (it != actorsMap.end()) {
      Actor &dstActor = it->second;
      if (canFire(&dstActor)) {
        followOnWorklist.push_back(&dstActor);
      }
    }
  }

  // Append followOnWorklist to the end of the current worklist
  worklist.insert(worklist.end(), followOnWorklist.begin(),
                  followOnWorklist.end());
}

std::tuple<cal::ActorOp, mlir::BlockArgument>
getActorAndPort(mlir::Value fifoEnd) {
  SymbolTableCollection symbolTable;
  auto &use = *fifoEnd.getUses().begin();
  auto createInstanceOp = llvm::dyn_cast<cal::CreateInstanceOp>(use.getOwner());
  FlatSymbolRefAttr actorRef = createInstanceOp.getActorRefAttr();
  cal::ActorOp actorOp = symbolTable.lookupNearestSymbolFrom<cal::ActorOp>(
      createInstanceOp, actorRef);

  int operandIndex = 0;
  for (int i = 0, e = createInstanceOp->getNumOperands(); i < e; ++i) {
    if (createInstanceOp->getOperand(i) == use.get()) {
      operandIndex = i;
      break;
    }
  }

  mlir::BlockArgument port =
      actorOp.getBody().front().getArgument(operandIndex);
  return {actorOp, port};
}


} // namespace mlir