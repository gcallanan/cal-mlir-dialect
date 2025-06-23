#include "Conversion/CalToFuncWithStaticSchedule/CycloStaticDataflowAnalysis.h"
#include "Dialect/Cal/CalOps.h"
#include "mlir/Dialect/Arith/IR/Arith.h"
#include "mlir/IR/OpImplementation.h"

namespace mlir {

void printScheduleGraph(ScheduleGraph &graph) {
  llvm::outs() << "ScheduleGraph for actor: " << graph.actor.getSymName()
               << "\n";

  for (size_t i = 0; i < graph.nodes.size(); ++i) {
    auto &node = graph.nodes[i];
    llvm::outs() << "  Node " << i << ": "
                 << node.action.getActionNameAttr().getValue() << "\n";

    llvm::outs() << "    → Next: Node " << node.nextNodeIndex;

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
  llvm::outs() << "\n\n\nCycloStaticDataflowAnalysis\n";

  op->walk([&](mlir::cal::ActorOp actor) { determineActorSchedule(actor); });
}

void CycloStaticDataflowAnalysis::determineActorSchedule(cal::ActorOp actorOp) {

  llvm::outs() << "Determining schedule for actor: "
               << actorOp.getNameAttr().getValue() << "\n";

  int actionCount = 0;
  actorOp.walk([&](cal::ActionOp actionOp) { ++actionCount; });

  if (actionCount == 1) {
    generateSingleActionSchedule(actorOp);
  } else {
    generateMultiActionSchedule(actorOp);
  }
}

void CycloStaticDataflowAnalysis::generateSingleActionSchedule(
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

  // Optionally print the schedule graph
  printScheduleGraph(graph);

  // Store or process the graph as needed (not shown)
  actorScheduleMap[actorOp] = graph;
}

void CycloStaticDataflowAnalysis::generateMultiActionSchedule(
    cal::ActorOp actorOp) {

  llvm::outs() << "Generating multi-action schedule for actor: "
               << actorOp.getNameAttr().getValue() << "\n";

  // We need to find a state variable that is guarded by the equality
  // in a predicate and properly incremented in the corresponding action.
  // If this state variable is used in this way across every action in the
  // actor, then we can consider it a candidate for the scheduling variable.
  // STEP 1: Identify the scheduling variable
  // STEP 1.1: Find all possible candidate scheduling variables, store a list of
  // actions that this variable is a candidate in. We will prune to the correct
  // variable in STEp 1.2

  llvm::DenseMap<mlir::Value, llvm::SmallPtrSet<mlir::Operation *, 4>>
      actionToValues;
  int numberOfActions = 0;
  for (auto actionOp : actorOp.getOps<cal::ActionOp>()) {
    numberOfActions++;
    for (auto predicateOp : actionOp.getOps<cal::Predicate>()) {
      if (auto predicateInfo = candidatePredicateOrNull(predicateOp)) {
        if (auto stateIncrementPattern = getStateUpdatePatternOrNull(
                predicateInfo->stateVar, actionOp)) {
          actionToValues[predicateInfo->stateVar].insert(actionOp);
        }
      }
    }
  }

  // STEP 1.2: Prune the candidate scheduling variables to only those that are
  // candidates in every action of the actor.
  Value commonStateVar;
  size_t numCommonStateVar = 0;
  for (const auto &entry : actionToValues) {
    if (entry.second.size() == numberOfActions) {
      commonStateVar = entry.first;
      numCommonStateVar++;
    }
  }

  // If we have more than one common state variable, we cannot proceed, so its
  // a dynamic actor
  if (numCommonStateVar != 1) {
    ScheduleGraph graph;
    graph.actor = actorOp;
    graph.type = GraphType::Dynamic;
    actorScheduleMap[actorOp] = graph;
    return;
  }

  // STEP 2: Analyse the inequalities and state updates for the common state
  // variable across all actions to see if we can construct a
  // schedule graph.

  // What do I have to do here?
  // 1. Construct a map of actions and SchedulingVariableInfoForAction objects
  // 2. Pass this map to the schedule graph constructor which will attempt to
  //    construct a schedule graph based on the information provided.
  // 3. You will need to implement checks to ensure that there is no stepping by
  // +ve or -ve infinity

  llvm::DenseMap<cal::ActionOp, SchedulingVariableInfoForAction> actionInfoMap;
  for (auto actionOp : actorOp.getOps<cal::ActionOp>()) {
    llvm::SmallVector<PredicateInequalityInfo> predicateInfos;
    for (auto predicateOp : actionOp.getOps<cal::Predicate>()) {
      if (auto predicateInfo = candidatePredicateOrNull(predicateOp)) {
        if (predicateInfo->stateVar == commonStateVar) {
          predicateInfos.push_back(*predicateInfo);
        }
      }
    }
    auto stateUpdatePattern =
        getStateUpdatePatternOrNull(commonStateVar, actionOp);

    SchedulingVariableInfoForAction infoForAction;
    infoForAction.stateVar = commonStateVar;
    infoForAction.predicateInequalities = std::move(predicateInfos);
    infoForAction.updatePattern = stateUpdatePattern;
    actionInfoMap[actionOp] = infoForAction;
  }

  int initialStateValue = findInitialAssignment(commonStateVar, actorOp);

  if (auto scheduleGraph = constructScheduleGraphFromActionInfo(
          actorOp, actionInfoMap, initialStateValue)) {
    actorScheduleMap[actorOp] = *scheduleGraph;
  } else {
    ScheduleGraph graph;
    graph.actor = actorOp;
    graph.type = GraphType::Dynamic;
    actorScheduleMap[actorOp] = graph;
  }

  printScheduleGraph(actorScheduleMap[actorOp]);
} // namespace mlir

std::optional<int64_t>
CycloStaticDataflowAnalysis::tryGetConstantValue(Value val) {
  if (auto constantOp = val.getDefiningOp<mlir::arith::ConstantOp>()) {
    if (auto intAttr = llvm::dyn_cast<IntegerAttr>(constantOp.getValue())) {
      return intAttr.getValue().getSExtValue(); // or getZExtValue() if needed
    }
  }
  return std::nullopt;
}

std::optional<int64_t>
CycloStaticDataflowAnalysis::evaluateConstantValue(Value val) {
  if (!val)
    return std::nullopt;

  if (auto constant = tryGetConstantValue(val))
    return constant;

  Operation *defOp = val.getDefiningOp();
  if (!defOp)
    return std::nullopt;

  if (auto extui = llvm::dyn_cast<mlir::arith::ExtUIOp>(defOp)) {
    auto inner = evaluateConstantValue(extui.getIn());
    if (!inner)
      return std::nullopt;

    unsigned sourceWidth =
        extui.getIn().getType().cast<IntegerType>().getWidth();
    return static_cast<uint64_t>(*inner) & ((1ULL << sourceWidth) - 1);
  }

  if (auto extsi = llvm::dyn_cast<mlir::arith::ExtSIOp>(defOp)) {
    auto inner = evaluateConstantValue(extsi.getIn());
    if (!inner)
      return std::nullopt;

    unsigned sourceWidth =
        extsi.getIn().getType().cast<IntegerType>().getWidth();
    int64_t mask = (1ULL << (sourceWidth - 1));
    int64_t val = *inner;
    if (val & mask)
      val |= ~((1ULL << sourceWidth) - 1);
    return val;
  }

  if (auto addOp = llvm::dyn_cast<mlir::arith::AddIOp>(defOp)) {
    auto lhs = evaluateConstantValue(addOp.getLhs());
    auto rhs = evaluateConstantValue(addOp.getRhs());
    if (lhs && rhs)
      return *lhs + *rhs;
    return std::nullopt;
  }

  if (auto subOp = llvm::dyn_cast<mlir::arith::SubIOp>(defOp)) {
    auto lhs = evaluateConstantValue(subOp.getLhs());
    auto rhs = evaluateConstantValue(subOp.getRhs());
    if (lhs && rhs)
      return *lhs - *rhs;
    return std::nullopt;
  }

  if (auto mulOp = llvm::dyn_cast<mlir::arith::MulIOp>(defOp)) {
    auto lhs = evaluateConstantValue(mulOp.getLhs());
    auto rhs = evaluateConstantValue(mulOp.getRhs());
    if (lhs && rhs)
      return *lhs * *rhs;
    return std::nullopt;
  }

  return std::nullopt;
}

std::optional<PredicateInequalityInfo>
CycloStaticDataflowAnalysis::candidatePredicateOrNull(
    cal::Predicate predicateOp) {
  mlir::Value lhs, rhs;
  mlir::arith::CmpIPredicate pred;
  bool inValid = false;

  predicateOp->walk([&](mlir::cal::PredicateResultOp resultOp) {
    if (auto cmpOp = resultOp.getEvaluationResult()
                         .getDefiningOp<mlir::arith::CmpIOp>()) {
      lhs = cmpOp.getLhs();
      rhs = cmpOp.getRhs();
      pred = cmpOp.getPredicate();
    } else {
      inValid = true;
    }
  });

  if (inValid || !lhs || !rhs)
    return std::nullopt;

  auto *lhsOp = lhs.getDefiningOp();
  auto *rhsOp = rhs.getDefiningOp();

  bool lhsIsState = llvm::isa<mlir::cal::StateGetOp>(lhsOp);
  bool rhsIsState = llvm::isa<mlir::cal::StateGetOp>(rhsOp);

  if (lhsIsState == rhsIsState)
    return std::nullopt;

  mlir::Value stateVar =
      lhsIsState ? lhsOp->getOperand(0) : rhsOp->getOperand(0);
  mlir::Value otherVar = lhsIsState ? rhs : lhs;

  if (auto constVal = evaluateConstantValue(otherVar)) {
    return PredicateInequalityInfo{pred, stateVar, *constVal};
  }

  return std::nullopt;
}

std::optional<StateVarUpdatePattern>
CycloStaticDataflowAnalysis::getStateUpdatePatternOrNull(
    mlir::Value stateVar, cal::ActionOp actionOp) {
  int numSets = 0;
  mlir::cal::StateSetOp setOp = nullptr;
  actionOp->walk([&](mlir::cal::StateSetOp ss) {
    if (ss.getStateRef() == stateVar) {
      setOp = ss;
      numSets++;
    }
  });

  if (auto assignedValue = evaluateConstantValue(setOp.getStateValue())) {
    return StateVarUpdatePattern{
        stateVar, StateVarUpdateKind::ConstantAssignment, *assignedValue};
  }

  if (auto increment =
          getIncrementAmount(setOp.getStateValue(), setOp.getStateRef())) {
    return StateVarUpdatePattern{stateVar, StateVarUpdateKind::Increment,
                                 *increment};
  }

  if (numSets != 1) {
    return std::nullopt;
  }

  return std::nullopt; // Placeholder for future implementation
}

std::optional<int64_t>
CycloStaticDataflowAnalysis::getIncrementAmount(Value setValue,
                                                Value targetStateVar) {
  std::optional<int64_t> delta = 0;
  bool foundMatchingState = false;

  llvm::SmallVector<Value, 8> worklist = {setValue};
  llvm::SmallPtrSet<Value, 8> visited;

  while (!worklist.empty()) {
    Value val = worklist.pop_back_val();
    if (!visited.insert(val).second)
      continue;

    Operation *defOp = val.getDefiningOp();
    if (!defOp)
      return std::nullopt; // block argument or something else unexpected

    // Handle constant
    if (auto constOp = dyn_cast<arith::ConstantOp>(defOp)) {
      if (auto intAttr = dyn_cast<IntegerAttr>(constOp.getValue())) {
        delta = *delta + intAttr.getValue().getSExtValue();
        continue;
      }
      return std::nullopt; // Non-integer constant
    }

    // Handle add or sub
    if (auto addOp = dyn_cast<arith::AddIOp>(defOp)) {
      worklist.push_back(addOp.getLhs());
      worklist.push_back(addOp.getRhs());
      continue;
    }
    if (auto subOp = dyn_cast<arith::SubIOp>(defOp)) {
      worklist.push_back(subOp.getLhs());

      auto constVal = evaluateConstantValue(subOp.getRhs());
      if (!constVal)
        return std::nullopt;
      delta = *delta - *constVal;
      continue;
    }

    // Handle zero-extension
    if (auto extui = dyn_cast<arith::ExtUIOp>(defOp)) {
      auto innerVal = extui.getIn();
      auto constVal = evaluateConstantValue(innerVal);
      if (!constVal)
        return std::nullopt;

      unsigned sourceWidth = innerVal.getType().cast<IntegerType>().getWidth();
      uint64_t mask = (1ULL << sourceWidth) - 1;
      delta = *delta + static_cast<int64_t>(*constVal & mask);
      continue;
    }

    // Handle sign-extension
    if (auto extsi = dyn_cast<arith::ExtSIOp>(defOp)) {
      auto innerVal = extsi.getIn();
      auto constVal = evaluateConstantValue(innerVal);
      if (!constVal)
        return std::nullopt;

      unsigned sourceWidth = innerVal.getType().cast<IntegerType>().getWidth();
      int64_t val = *constVal;
      int64_t signBit = 1ULL << (sourceWidth - 1);
      if (val & signBit)
        val |= ~((1ULL << sourceWidth) - 1); // Sign extend
      delta = *delta + val;
      continue;
    }

    // Handle cal.get
    if (auto getOp = dyn_cast<cal::StateGetOp>(defOp)) {
      if (getOp.getStateRef() != targetStateVar)
        return std::nullopt; // Other state var
      foundMatchingState = true;
      continue;
    }

    // Anything else — reject
    return std::nullopt;
  }

  if (!foundMatchingState)
    return std::nullopt; // No dependence on target state var

  return delta;
}

std::optional<ScheduleGraph>
CycloStaticDataflowAnalysis::constructScheduleGraphFromActionInfo(
    cal::ActorOp actorOp,
    const llvm::DenseMap<cal::ActionOp, SchedulingVariableInfoForAction>
        &actionInfoMap,
    int initialStateValue) {

  llvm::outs() << "Constructing schedule graph for actor: "
               << actorOp.getNameAttr().getValue() << "\n";

  llvm::outs() << "Initial Op Value " << initialStateValue << "\n";

  llvm::outs() << "This is where we pick up from\n";

  std::vector<ScheduleNode> scheduleNodes;
  // Step 1: Ensure the vector is large enough to hold the initial state index.
  // This prepares the scheduleNodes vector so that we can index into it by
  // state value.
  scheduleNodes.resize(
      std::max<size_t>(scheduleNodes.size(), initialStateValue + 1));

  int currentStateValue = initialStateValue;

  // Step 2: Simulate the schedule graph construction by walking through state
  // values. For each state value, determine the corresponding action and the
  // next state, and build up the scheduleNodes vector accordingly.
  do {
    // Step 2.1: For the current state value, find the action that should be
    // executed.
    auto currentAction =
        getActionForStateValue(currentStateValue, actionInfoMap);

    if (!currentAction) {
      return std::nullopt; // No action found for this state value
    }

    const auto &infoForAction = actionInfoMap.lookup(*currentAction);
    auto updatePattern = infoForAction.updatePattern;

    // Step 2.2: Compute the next state value based on the update pattern of the
    // action.
    int nextStateValue;
    if (updatePattern->kind == StateVarUpdateKind::ConstantAssignment) {
      nextStateValue = updatePattern->value;
    } else if (updatePattern->kind == StateVarUpdateKind::Increment) {
      nextStateValue = currentStateValue + updatePattern->value;
    }

    // Step 2.3: Add a ScheduleNode for the current state value.
    // If the next state value has already been visited, create a WrapAround
    // edge. Otherwise, create a Next edge to the next state value.
    if (scheduleNodes.size() <= static_cast<size_t>(currentStateValue))
      scheduleNodes.resize(currentStateValue + 1);
    ScheduleNode node;
    node.action = *currentAction;
    node.nextNodeIndex = nextStateValue;

    // Outgoing edge set to WrapAround if we encounter an already visited
    // state value, this is the termination condition
    if (nextStateValue < static_cast<int>(scheduleNodes.size()) &&
        scheduleNodes[nextStateValue].action) {
      // We've already visited this state value, so wrap around
      node.edgeTypeToNextNode = ScheduleEdgeType::WrapAround;
      scheduleNodes[currentStateValue] = node;
      break;
    } else {
      node.edgeTypeToNextNode = ScheduleEdgeType::Next;
    }

    scheduleNodes[currentStateValue] = node;

    currentStateValue = nextStateValue;
  } while (true);

  // Step 3: After simulating the schedule, construct and return the
  // ScheduleGraph object. The graph contains the actor, its type, and the
  // constructed schedule nodes.
  ScheduleGraph graph;
  graph.actor = actorOp;
  graph.type = GraphType::StateMachineSchedule;
  graph.nodes = std::move(scheduleNodes);
  return graph;
}

int CycloStaticDataflowAnalysis::findInitialAssignment(mlir::Value stateVar,
                                                       cal::ActorOp actorOp) {
  mlir::cal::StateSetOp initialSetOp = nullptr;

  for (auto &op : actorOp.getBody().front()) {
    if (auto setOp = llvm::dyn_cast<mlir::cal::StateSetOp>(op)) {
      if (setOp.getStateRef() == stateVar) {
        // Found the first assignment to the state variable
        initialSetOp = setOp;
        break;
      }
    }
  }

  return evaluateConstantValue(initialSetOp.getStateValue())
      .value_or(0); // Return 0 if no initial assignment found
}

std::optional<cal::ActionOp>
CycloStaticDataflowAnalysis::getActionForStateValue(
    int stateValue,
    const llvm::DenseMap<cal::ActionOp, SchedulingVariableInfoForAction>
        &actionInfoMap) {

  cal::ActionOp selectedAction = nullptr;
  int numMatches = 0;

  for (const auto &entry : actionInfoMap) {
    cal::ActionOp actionOp = entry.first;
    const auto &info = entry.second;
    if (allPredicatesTrueForState(stateValue, info.predicateInequalities)) {
      selectedAction = actionOp;
      numMatches++;
    }
  }

  if (numMatches == 1) {
    return selectedAction;
  } else if (numMatches > 1) {
    return std::nullopt;
  }
}

bool CycloStaticDataflowAnalysis::allPredicatesTrueForState(
    int stateValue, const llvm::SmallVectorImpl<mlir::PredicateInequalityInfo>
                        &predicateInequalities) {

  auto compareStateWithPredicate =
      [](int i, const mlir::PredicateInequalityInfo &predicateInfo) {
        switch (predicateInfo.predicate) {
        case mlir::arith::CmpIPredicate::eq:
          return i == predicateInfo.constant;
        case mlir::arith::CmpIPredicate::ne:
          return i != predicateInfo.constant;
        case mlir::arith::CmpIPredicate::slt:
        case mlir::arith::CmpIPredicate::ult:
          return i < predicateInfo.constant;
        case mlir::arith::CmpIPredicate::sle:
        case mlir::arith::CmpIPredicate::ule:
          return i <= predicateInfo.constant;
        case mlir::arith::CmpIPredicate::sgt:
        case mlir::arith::CmpIPredicate::ugt:
          return i > predicateInfo.constant;
        case mlir::arith::CmpIPredicate::sge:
        case mlir::arith::CmpIPredicate::uge:
          return i >= predicateInfo.constant;
        }
        return false;
      };

  for (const auto &predInfo : predicateInequalities) {
    if (!compareStateWithPredicate(stateValue, predInfo)) {
      return false;
    }
  }
  return true;
}

} // namespace mlir