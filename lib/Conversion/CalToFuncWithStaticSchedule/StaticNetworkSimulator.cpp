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
  FsmNode fsmNode = actor->fsm.nodes[actor->currentState];
  actor->currentState = fsmNode.edges.front().nextNodeIndex;
  // We have looped back to the start state
  if(actor->fsm.initialStateValue == actor->currentState) {
    actor->numFiringsLeft--;
  }

  return actionOp; // Return the action that was fired
}

void queueFollowOnActorsToWorklist(
    Actor &currentActor, std::vector<Actor *> &worklist,
    llvm::MapVector<cal::ActorOp, Actor> &actorsMap) {
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

std::vector<cal::ActionOp> simulateNetwork(
    cal::NetworkOp networkOp,
    const llvm::MapVector<cal::ActorOp, int> &actorFiringsPerCycle,
    const llvm::MapVector<cal::ActorOp, Fsm> &actorFsmMap) {
  // Step 1: Create actors structs for each actor
  llvm::MapVector<cal::ActorOp, Actor> actorOpToActorStructMap;
  std::vector<Actor *> actors;
  for (auto &pair : actorFiringsPerCycle) {
    actorOpToActorStructMap[pair.first] = Actor{
        .actorOp = pair.first,
        .currentState = static_cast<int>(actorFsmMap.find(pair.first)->second.initialStateValue),
        .numFiringsLeft = pair.second,
        .fsm = actorFsmMap.find(pair.first)->second
    };
  }

  // Collect actor pointers and sort by actor name for deterministic order
  std::vector<std::pair<std::string, Actor *>> sortedActors;
  for (auto &pair : actorOpToActorStructMap) {
    sortedActors.emplace_back(pair.first.getSymName().str(), &pair.second);
  }
  std::sort(sortedActors.begin(), sortedActors.end(),
            [](const auto &a, const auto &b) { return a.first < b.first; });
  for (const auto &entry : sortedActors) {
    actors.push_back(entry.second);
  }

  // Step 2: Create channels and link them to actors
  std::vector<Channel> channels;
  for (auto createOp : networkOp.getOps<fifo::CreateOp>()) {
    auto [srcActor, srcPort] = getActorAndPort(createOp->getResult(0));
    auto [dstActor, dstPort] = getActorAndPort(createOp->getResult(1));

    Channel channel;
    channel.srcActor = srcActor;
    channel.dstActor = dstActor;
    channel.createOp = createOp;
    channel.tokens = 0;

    channels.push_back(channel);
  }

  // Link actors to channels
  for (size_t i = 0; i < channels.size(); ++i) {
    auto &channel = channels[i];
    auto createOp = channel.createOp;
    auto [srcActor, srcPort] = getActorAndPort(createOp->getResult(0));
    auto [dstActor, dstPort] = getActorAndPort(createOp->getResult(1));

    actorOpToActorStructMap[channel.srcActor].portsOut[srcPort] = &channel;
    actorOpToActorStructMap[channel.dstActor].portsIn[dstPort] = &channel;
  }

  // Step 3: Execute the simulation
  std::vector<cal::ActionOp> schedule;
  std::vector<Actor *> worklist;

  do {

    // Step 3.1 Execute all actors that can fire on the worklist
    // Trace the actors that they send tokens to and add them to the worklist
    // If they can fire to - this will exhaust all actions that can fire
    while (!worklist.empty()) {
      Actor *currentActor = worklist.front();
      worklist.erase(worklist.begin());

      if (canFire(currentActor)) {
        cal::ActionOp firedAction = fire(currentActor);
        schedule.push_back(firedAction);
        queueFollowOnActorsToWorklist(*currentActor, worklist, actorOpToActorStructMap);
      }
    }

    // Step 3.2 Once the worklist is empty, find all actors that can fire
    // and add them to the worklist. These are typically source actors
    // that can fire without any dependencies. We keep them seperate to prevent
    // the source actors from all firing first
    for (auto *actor : actors) {
      if (canFire(actor)) {
        worklist.push_back(actor);
      }
    }
  } while (!worklist.empty());
  return schedule;
}

} // namespace mlir