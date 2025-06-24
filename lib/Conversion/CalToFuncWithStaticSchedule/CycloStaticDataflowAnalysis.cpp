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
    phase.portRates = generatePortRates(phase.actionOp);
    phases.push_back(phase);
    return phases;
  }

  if (graph.type == GraphType::StateMachineSchedule) {
    llvm::SmallVector<SDFPhase, 4> phases;

    ScheduleNode node = graph.nodes[graph.initialStateValue];
    while (node.edgeTypeToNextNode != ScheduleEdgeType::WrapAround) {
      SDFPhase phase;
      phase.actionOp = node.action;
      phase.portRates = generatePortRates(phase.actionOp);
      phases.push_back(phase);
      node = graph.nodes[node.nextNodeIndex];
    }
    SDFPhase phase;
    phase.actionOp = node.action;
    phase.portRates = generatePortRates(phase.actionOp);
    phases.push_back(phase);

    return phases;
  }

  return std::nullopt;
}

llvm::DenseMap<mlir::Value, int>
CycloStaticDataflowAnalysis::generatePortRates(mlir::cal::ActionOp actionOp) {

  llvm::DenseMap<mlir::Value, int> portRates;
  for (auto pushOp : actionOp.getOps<fifo::Push>()) {
    portRates[pushOp.getInputPort()] += 1;
  }

  for (auto popOp : actionOp.getOps<fifo::Pop>()) {
    portRates[popOp.getOutputPort()] -= 1;
  }
  return portRates;
}

llvm::SmallVector<CycloStaticDataflowAnalysis::BalanceEquation, 4>
CycloStaticDataflowAnalysis::generateBalanceEquations(
    cal::NetworkOp networkOp) {
  llvm::SmallVector<BalanceEquation, 4> equations;
  SymbolTableCollection symbolTable;

  for (auto createOp : networkOp.getOps<fifo::CreateOp>()) {
    BalanceEquation eq;

    /**
     * @brief Helper lambda to retrieve the actor and port corresponding to a
     * FIFO endpoint.
     *
     * Given a FIFO endpoint value, this lambda locates the associated
     * `cal::CreateInstanceOp`, determines the referenced actor, and identifies
     * the specific port (block argument) connected to the FIFO.
     *
     * @param fifoEnd The value representing one end of a FIFO.
     * @return A tuple containing the actor operation and the corresponding
     * block argument (port).
     */
    auto getActorAndPort =
        [&](Value fifoEnd) -> std::tuple<cal::ActorOp, mlir::BlockArgument> {
      auto &use = *fifoEnd.getUses().begin();
      auto createInstanceOp =
          llvm::dyn_cast<cal::CreateInstanceOp>(use.getOwner());
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
    };

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
llvm::DenseMap<mlir::cal::ActorOp, int> CycloStaticDataflowAnalysis::solveBalanceEquations(
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
    std::cerr << "No nontrivial solution for balance equations!\n";
    return {};
  }

  // Convert first column to vector and scale to integers
  Eigen::VectorXd v = nullSpace.col(0);
  double denomLCM = 1.0;
  const double tol = 1e-6;
  std::vector<int> result(numActors);

  for (int i = 0; i < v.size(); ++i) {
    // Scale to nearest rational number
    result[i] = std::round(v[i] * 10000);
  }

  // Normalize to smallest integers (divide by GCD)
  int g = std::abs(result[0]);
  for (int i = 1; i < result.size(); ++i)
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

} // namespace mlir