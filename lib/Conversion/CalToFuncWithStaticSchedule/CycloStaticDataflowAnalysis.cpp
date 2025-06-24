#include "Conversion/CalToFuncWithStaticSchedule/CycloStaticDataflowAnalysis.h"
#include "Dialect/Cal/CalOps.h"
#include "Dialect/Fifo/FifoOps.h"
#include "mlir/Dialect/Arith/IR/Arith.h"
#include "mlir/IR/OpImplementation.h"

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
    std::sort(portKeys.begin(), portKeys.end(), [](mlir::Value a, mlir::Value b) {
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

} // namespace mlir