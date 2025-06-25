#include "Conversion/CalToFuncWithStaticSchedule/CycloStaticDataflowAnalysis.h"
#include "Dialect/Cal/CalOps.h"
#include "Dialect/Fifo/FifoOps.h"
#include "mlir/Dialect/Arith/IR/Arith.h"
#include "mlir/IR/OpImplementation.h"

#include <Eigen/Dense>
#include <cassert>
#include <iostream>
#include <numeric>
#include <unordered_map>
#include <vector>

namespace mlir {

void printScheduleGraph(ScheduleGraph &graph) {
  std::string scheduleType;
  switch (graph.type) {
  case GraphType::SingleAction:
    scheduleType = "SingleAction";
    break;
  case GraphType::StateMachineSchedule:
    scheduleType = "StateMachineSchedule";
    break;
  case GraphType::Dynamic:
    scheduleType = "Dynamic";
    break;
  }
  llvm::outs() << "ScheduleGraph for actor: " << graph.actor.getSymName()
               << ". Type: " << scheduleType << "\n";

  for (size_t i = 0; i < graph.nodes.size(); ++i) {
    auto &node = graph.nodes[i];
    llvm::outs() << "  Node " << i << ": "
                 << node.action.getActionNameAttr().getValue() << "\n";

    llvm::outs() << "    -> Next: Node " << node.nextNodeIndex;

    switch (node.edgeTypeToNextNode) {
    case ScheduleEdgeType::Next:
      llvm::outs() << " (Next)";
      break;
    case ScheduleEdgeType::WrapAround:
      llvm::outs() << " (WrapAround)";
      break;
    }

    llvm::outs() << "\n";
  }
}

llvm::raw_ostream &operator<<(llvm::raw_ostream &os,
                              const PredicateInequalityInfo &info) {
  std::string ssaName;
  llvm::raw_string_ostream ss(ssaName);
  info.stateVar.printAsOperand(ss, mlir::OpPrintingFlags().useLocalScope());
  ss.flush();

  os << "PredicateInequalityInfo(" << ssaName << " ";
  switch (info.predicate) {
  case mlir::arith::CmpIPredicate::eq:
    os << "==";
    break;
  case mlir::arith::CmpIPredicate::ne:
    os << "!=";
    break;
  case mlir::arith::CmpIPredicate::slt:
    os << "<";
    break;
  case mlir::arith::CmpIPredicate::sle:
    os << "<=";
    break;
  case mlir::arith::CmpIPredicate::sgt:
    os << ">";
    break;
  case mlir::arith::CmpIPredicate::sge:
    os << ">=";
    break;
  case mlir::arith::CmpIPredicate::ult:
    os << "<";
    break;
  case mlir::arith::CmpIPredicate::ule:
    os << "<=";
    break;
  case mlir::arith::CmpIPredicate::ugt:
    os << ">";
    break;
  case mlir::arith::CmpIPredicate::uge:
    os << ">=";
    break;
  }
  os << " " << info.constant << ")";
  return os;
}

llvm::raw_ostream &operator<<(llvm::raw_ostream &os,
                              const StateVarUpdatePattern &info) {
  std::string ssaName;
  llvm::raw_string_ostream ss(ssaName);
  info.stateVar.printAsOperand(ss, mlir::OpPrintingFlags().useLocalScope());
  ss.flush();

  os << "StateVarUpdatePattern(" << ssaName << " ";
  switch (info.kind) {
  case StateVarUpdateKind::ConstantAssignment:
    os << "=";
    break;
  case StateVarUpdateKind::Increment:
    os << "= " << ssaName << " + ";
    break;
  }
  os << " " << info.value << ")";
  return os;
}

CycloStaticDataflowAnalysis::CycloStaticDataflowAnalysis(Operation *op) {
  op->walk([&](mlir::cal::ActorOp actor) { determineActorSchedule(actor); });
}

void CycloStaticDataflowAnalysis::printActorStateMachine(cal::ActorOp actorOp) {
  printScheduleGraph(actorScheduleMap[actorOp]);
}

void CycloStaticDataflowAnalysis::printCSDFPhases(cal::ActorOp actorOp) {
  llvm::outs() << "CSDF Phases for actor: " << actorOp.getSymName() << "\n";
  auto phases = getSDFPhases(actorOp);
  if (!phases) {
    llvm::outs() << "\tNo CSDF phases available for this actor.\n";
    return;
  }

  for (auto &phase : *phases) {
    llvm::outs() << "\tAction: " << phase.actionOp.getActionNameAttr() << "\n";
    // Print ports in deterministic order
    std::vector<mlir::Value> portKeys;
    for (const auto &portRate : phase.portRates) {
      portKeys.push_back(portRate.first);
    }
    std::sort(portKeys.begin(), portKeys.end(),
              [](mlir::Value a, mlir::Value b) {
                return a.getAsOpaquePointer() < b.getAsOpaquePointer();
              });
    for (const auto &port : portKeys) {
      llvm::outs() << "\t\tPort: ";
      port.print(llvm::outs());
      llvm::outs() << " Rate: " << phase.portRates.lookup(port) << "\n";
    }
  }
}

void CycloStaticDataflowAnalysis::determineActorSchedule(cal::ActorOp actorOp) {
  int actionCount = 0;
  actorOp.walk([&](cal::ActionOp actionOp) { ++actionCount; });

  if (actionCount == 1) {
    actorScheduleMap[actorOp] = generateSingleActionSchedule(actorOp);
  } else {
    actorScheduleMap[actorOp] = generateMultiActionSchedule(actorOp);
  }
}

ScheduleGraph CycloStaticDataflowAnalysis::generateSingleActionSchedule(
    cal::ActorOp actorOp) {
  ScheduleGraph graph;
  graph.actor = actorOp;
  graph.type = GraphType::SingleAction;
  graph.initialStateValue = 0; // Single action, so initial state is 0

  // Find the single action
  cal::ActionOp singleAction = nullptr;
  actorOp.walk([&](cal::ActionOp actionOp) { singleAction = actionOp; });

  // Create a single node for the action
  ScheduleNode node;
  node.action = singleAction;
  node.nextNodeIndex = 0;
  node.edgeTypeToNextNode = ScheduleEdgeType::WrapAround;

  graph.nodes.push_back(node);

  // Store or process the graph as needed (not shown)
  return graph;
}

ScheduleGraph
CycloStaticDataflowAnalysis::generateMultiActionSchedule(cal::ActorOp actorOp) {
  ScheduleGraphBuilder builder(actorOp);
  return builder.generateFsm();
}

std::optional<llvm::SmallVector<CycloStaticDataflowAnalysis::SDFPhase, 4>>
CycloStaticDataflowAnalysis::getSDFPhases(cal::ActorOp actorOp) {

  ScheduleGraph &graph = actorScheduleMap[actorOp];

  if (graph.type == GraphType::Dynamic) {
    return std::nullopt;
  }

  if (graph.type == GraphType::SingleAction) {
    llvm::SmallVector<SDFPhase, 4> phases;
    SDFPhase phase;
    phase.actionOp = graph.nodes[0].action;
    phase.portRates = phase.actionOp.getPortRates();
    phases.push_back(phase);
    return phases;
  }

  if (graph.type == GraphType::StateMachineSchedule) {
    llvm::SmallVector<SDFPhase, 4> phases;

    ScheduleNode node = graph.nodes[graph.initialStateValue];
    while (node.edgeTypeToNextNode != ScheduleEdgeType::WrapAround) {
      SDFPhase phase;
      phase.actionOp = node.action;
      phase.portRates = phase.actionOp.getPortRates();
      phases.push_back(phase);
      node = graph.nodes[node.nextNodeIndex];
    }
    SDFPhase phase;
    phase.actionOp = node.action;
    phase.portRates = phase.actionOp.getPortRates();
    phases.push_back(phase);

    return phases;
  }

  return std::nullopt;
}

llvm::SmallVector<CycloStaticDataflowAnalysis::BalanceEquation, 4>
CycloStaticDataflowAnalysis::generateBalanceEquations(
    cal::NetworkOp networkOp) {
  llvm::SmallVector<BalanceEquation, 4> equations;

  for (auto createOp : networkOp.getOps<fifo::CreateOp>()) {
    BalanceEquation eq;

    // Source side (FIFO output)
    auto [srcActor, srcPort] = getActorAndPort(createOp->getResult(0));
    eq.srcActor = srcActor;
    eq.srcPort = srcPort;
    eq.srcRate = getPortRateOverAllPhases(srcActor, srcPort);

    // Destination side (FIFO input)
    auto [dstActor, dstPort] = getActorAndPort(createOp->getResult(1));
    eq.dstActor = dstActor;
    eq.dstPort = dstPort;
    eq.dstRate = getPortRateOverAllPhases(dstActor, dstPort);

    equations.push_back(eq);
  }

  return equations;
}

void CycloStaticDataflowAnalysis::printBalanceEquations(
    cal::NetworkOp networkOp) {
  llvm::outs() << "Balance Equations for network: "
               << "\n";

  auto equations = generateBalanceEquations(networkOp);
  int index = 0;
  for (auto &eq : equations) {
    llvm::outs() << "  Equation " << index++ << ": ";
    llvm::outs() << eq.srcActor.getSymName() << ":";
    llvm::outs() << " p_c * " << eq.srcRate << " == ";
    llvm::outs() << eq.dstActor.getSymName() << ":";
    llvm::outs() << " c_c * " << eq.dstRate;
    llvm::outs() << "\n";
  }
}

int CycloStaticDataflowAnalysis::getPortRateOverAllPhases(cal::ActorOp actorOp,
                                                          mlir::Value port) {
  auto phasesOpt = getSDFPhases(actorOp);
  if (!phasesOpt)
    return 0;

  int totalRate = 0;
  for (const auto &phase : *phasesOpt) {
    auto it = phase.portRates.find(port);
    if (it != phase.portRates.end())
      totalRate += it->second;
  }
  return totalRate;
}

// ---- Main solver ----
llvm::DenseMap<mlir::cal::ActorOp, int>
CycloStaticDataflowAnalysis::solveBalanceEquations(
    llvm::SmallVector<CycloStaticDataflowAnalysis::BalanceEquation, 4>
        &equations) {
  // Step 1: Map actors to indices
  std::unordered_map<mlir::Operation *, int> actorIndex;
  int index = 0;

  // Map each actor to a unique index
  for (auto &eq : equations) {
    auto *src = eq.srcActor.getOperation();
    auto *dst = eq.dstActor.getOperation();
    if (!actorIndex.count(src))
      actorIndex[src] = index++;
    if (!actorIndex.count(dst))
      actorIndex[dst] = index++;
  }

  int numActors = index;
  int numEqs = equations.size();
  Eigen::MatrixXd B = Eigen::MatrixXd::Zero(numEqs, numActors);

  // Fill incidence matrix: srcRate * q[src] = dstRate * q[dst]
  for (int i = 0; i < numEqs; ++i) {
    auto &eq = equations[i];
    int srcIdx = actorIndex[eq.srcActor.getOperation()];
    int dstIdx = actorIndex[eq.dstActor.getOperation()];
    B(i, srcIdx) = static_cast<double>(eq.srcRate);
    B(i, dstIdx) = static_cast<double>(eq.dstRate);
  }

  // Compute nullspace using rational LU
  Eigen::FullPivLU<Eigen::MatrixXd> lu(B);
  Eigen::MatrixXd nullSpace = lu.kernel(); // Floating-point nullspace

  if (nullSpace.cols() == 0) {
    llvm::errs() << "Error: No nontrivial solution for balance equations!\n";
    std::abort();
  }

  // Convert first column to vector and scale to integers
  Eigen::VectorXd v = nullSpace.col(0);
  std::vector<int> result(numActors);

  for (int i = 0; i < v.size(); ++i) {
    // Scale to nearest rational number
    result[i] = std::round(v[i] * 10000);
  }

  // Normalize to smallest integers (divide by GCD)
  int g = std::abs(result[0]);
  for (int i = 1; i < static_cast<int>(result.size()); ++i)
    g = std::gcd(g, std::abs(result[i]));
  for (int &x : result)
    x /= g;

  llvm::DenseMap<mlir::cal::ActorOp, int> repetitionMap;
  for (const auto &pair : actorIndex) {
    mlir::Operation *op = pair.first;
    mlir::cal::ActorOp actorOp = llvm::dyn_cast<mlir::cal::ActorOp>(op);
    if (actorOp)
      repetitionMap[actorOp] = result[pair.second];
  }
  return repetitionMap;
}

void CycloStaticDataflowAnalysis::
    printFiringsPerActorFromSolvedBalanceEquations(cal::NetworkOp networkOp) {

  llvm::SmallVector<BalanceEquation, 4> equations =
      generateBalanceEquations(networkOp);

  auto results = solveBalanceEquations(equations);

  // Output result
  llvm::outs() << "Number of firings of the all the CSDF phases per actor:\n";
  // Collect results into a vector for sorting
  std::vector<std::pair<std::string, int>> sortedResults;
  for (auto &pair : results) {
    sortedResults.emplace_back(pair.first.getSymName().str(), pair.second);
  }
  std::sort(sortedResults.begin(), sortedResults.end(),
            [](const auto &a, const auto &b) { return a.first < b.first; });

  for (const auto &entry : sortedResults) {
    llvm::outs() << "  " << entry.first << ": " << entry.second << "\n";
  }
}

std::tuple<cal::ActorOp, mlir::BlockArgument>
CycloStaticDataflowAnalysis::getActorAndPort(mlir::Value fifoEnd) {
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

void CycloStaticDataflowAnalysis::printStaticSchedule(
    cal::NetworkOp networkOp) {
  llvm::outs() << "Static Schedule:\n";
  auto schedule = generateScheduleThroughSimulation(networkOp);
  for (auto actionOp : schedule) {
    auto actorOp = actionOp->getParentOfType<cal::ActorOp>();
    llvm::outs() << "  Actor: " << actorOp.getSymName()
                 << ", Action: " << actionOp.getActionNameAttr() << "\n";
  }
}

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

std::vector<cal::ActionOp>
CycloStaticDataflowAnalysis::generateScheduleThroughSimulation(
    cal::NetworkOp networkOp) {

  // 1. Initialise system - create actors and channels and solve balance
  // equations

  // 1.1 Solve Balance Equations
  auto balanceEquations = generateBalanceEquations(networkOp);
  auto actorFiringsPerCycle = solveBalanceEquations(balanceEquations);

  // 1.2 Create actors
  llvm::DenseMap<cal::ActorOp, Actor> actorOpToActorStructMap;
  std::vector<Actor *> actors;
  for (auto &pair : actorFiringsPerCycle) {
    actorOpToActorStructMap[pair.first] = Actor{
        .actorOp = pair.first,
        .currentState = actorScheduleMap[pair.first].initialStateValue,
        .numFiringsLeft = pair.second,
        .fsm = actorScheduleMap[pair.first]
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

  // 1.3 Create channels
  std::vector<Channel> channels;
  for (auto createOp : networkOp.getOps<fifo::CreateOp>()) {
    auto [srcActor, srcPort] = getActorAndPort(createOp->getResult(0));
    auto [dstActor, dstPort] = getActorAndPort(createOp->getResult(1));

    Channel channel;
    channel.srcActor = srcActor;
    channel.dstActor = dstActor;
    channel.createOp = createOp;
    channel.tokens = 0; // Initialize tokens as needed

    channels.push_back(channel);
  }

  // 1.3.1 Point actors to channels once allocation is complete
  // This is done to handle the case where channel addresses are changed during
  // vector resizing
  for (size_t i = 0; i < channels.size(); ++i) {
    auto &channel = channels[i];

    // Find the corresponding ports for this channel
    auto createOp = channel.createOp;
    auto [srcActor, srcPort] = getActorAndPort(createOp->getResult(0));
    auto [dstActor, dstPort] = getActorAndPort(createOp->getResult(1));

    actorOpToActorStructMap[channel.srcActor].portsOut[srcPort] = &channel;
    actorOpToActorStructMap[channel.dstActor].portsIn[dstPort] = &channel;
  }

  // 2. Simulate the schedule - find one actor that can fire, fire it and
  // then trace the destinations of all tokens produced and consumed from
  // this firing in a worklist. Once this worklist is empty, we try find
  // another actor that can fire and repeat until all actors have fired.
  // By having this worklist, I hope to keep buffer sizes small.

  std::vector<cal::ActionOp> schedule;
  std::vector<Actor *> worklist;

  do {
    while (!worklist.empty()) {
      Actor *currentActor = worklist.front();
      worklist.erase(worklist.begin());

      if (canFire(currentActor)) {
        cal::ActionOp firedAction = fire(currentActor);
        schedule.push_back(firedAction);
        queueFollowOnActorsToWorklist(*currentActor, worklist,
                                      actorOpToActorStructMap);
      }
    }

    for (auto *actor : actors) {
      if (canFire(actor)) {
        worklist.push_back(actor);
      }
    }
  } while (!worklist.empty());

  // llvm::outs() << "Remaining tokens in channels after simulation:\n";
  // for (auto &channel : channels) {
  //   llvm::outs() << "  " << channel.srcActor.getSymName() << " -> "
  //                << channel.dstActor.getSymName() << ": " << channel.tokens
  //                << " tokens\n";
  // }

  // do {

  //   llvm::outs() << "Process Worklist\n";

  //   // Process worklist first
  //   while (!worklist.empty()) {
  //     Actor *currentActor = worklist.back();
  //     worklist.pop_back();

  //     if (canFire(*currentActor)) {
  //       cal::ActionOp firedAction = fire(*currentActor);
  //       schedule.push_back(firedAction);
  //       // queueFollowOnActorsToWorklist(*currentActor, worklist, actors);
  //     }
  //   }

  //   llvm::outs() << "Add to worklist actors that can fire\n";

  //   // If worklist is empty, scan all actors
  //   if (worklist.empty()) {
  //     for (auto &pair : actors) {
  //       if (canFire(pair.second)) {
  //         llvm::outs() << "  Actor: " << pair.second.actorOp.getSymName()
  //                      << " can fire\n";
  //         worklist.push_back(&pair.second);
  //       }
  //     }
  //   }

  // } while (!worklist.empty());

  return schedule;
}

} // namespace mlir