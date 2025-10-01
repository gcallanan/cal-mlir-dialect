#include "Conversion/CalToFuncWithStaticSchedule/CycloStaticDataflowAnalysis.h"
#include "Dialect/Cal/CalOps.h"
#include "mlir/Dialect/Arith/IR/Arith.h"
#include "mlir/IR/OpImplementation.h"

namespace mlir {

CycloStaticDataflowAnalysis::ScheduleGraphBuilder::ScheduleGraphBuilder(
    cal::ActorOp actorOp)
    : actorOp(actorOp) {}

ScheduleGraph CycloStaticDataflowAnalysis::ScheduleGraphBuilder::generateFsm() {
  // We need to find a state variable that is guarded by the equality
  // in a predicate and properly incremented in the corresponding action.
  // If this state variable is used in this way across every action in the
  // actor, then we can consider it a candidate for the scheduling variable.
  // STEP 1: Identify the scheduling variable
  // STEP 1.1: Find all possible candidate scheduling variables, store a list of
  // actions that this variable is a candidate in. We will prune to the correct
  // variable in STEp 1.2

  llvm::MapVector<mlir::Value, llvm::SmallPtrSet<mlir::Operation *, 4>>
      actionToValues;
  size_t numberOfActions = 0;
  for (auto actionOp : actorOp.getOps<cal::ActionOp>()) {
    numberOfActions++;
    for (auto predicateOp : actionOp.getOps<cal::Predicate>()) {
      if (auto predicateInfo = candidatePredicateOrNull(predicateOp)) {
        if (auto stateIncrementPattern = getStateUpdatePatternOrNull(
                predicateInfo->stateVar, actionOp)) {
          actionToValues[predicateInfo->stateVar].insert(predicateOp);
        }
      }
    }
  }

  // STEP 1.2: Remove the conditions where all predicates are the same across
  // the the different actions. This is not a valid scheduling variable.
  for (auto it = actionToValues.begin(); it != actionToValues.end();) {
    bool allPredicatesSame = true;

    // If there's only one action using this state var, it can't be compared
    if (it->second.size() <= 1) {
      ++it;
      continue;
    }

    // Get the first predicate to compare others against
    auto iter = it->second.begin();
    Operation *firstPredicate = *iter;

    // Compare first predicate against all others
    ++iter;
    while (iter != it->second.end() && allPredicatesSame) {
      Operation *otherPredicate = *iter;

      // Compare regions (bodies) of the predicates
      if (!predicateRegionsEqual(cast<cal::Predicate>(firstPredicate),
                                 cast<cal::Predicate>(otherPredicate))) {
        allPredicatesSame = false;
      }
      ++iter;
    }

    // If all predicates are the same, remove this entry
    if (allPredicatesSame) {
      it = actionToValues.erase(it);
    } else {
      ++it;
    }
  }

  // STEP 1.3: Prune the candidate scheduling variables to only those that are
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
    return graph;
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

  llvm::MapVector<cal::ActionOp, SchedulingVariableInfoForAction> actionInfoMap;
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

  int initialStateValue = findInitialAssignment(commonStateVar);

  if (auto scheduleGraph = constructScheduleGraphFromActionInfo(
          actionInfoMap, initialStateValue)) {
    return *scheduleGraph;
  } else {
    ScheduleGraph graph;
    graph.actor = actorOp;
    graph.type = GraphType::Dynamic;
    return graph;
  }
}

std::optional<int64_t>
CycloStaticDataflowAnalysis::ScheduleGraphBuilder::tryGetConstantValue(
    Value val) {
  if (auto constantOp = val.getDefiningOp<mlir::arith::ConstantOp>()) {
    if (auto intAttr = llvm::dyn_cast<IntegerAttr>(constantOp.getValue())) {
      return intAttr.getValue().getSExtValue(); // or getZExtValue() if needed
    }
  }
  return std::nullopt;
}

std::optional<int64_t>
CycloStaticDataflowAnalysis::ScheduleGraphBuilder::evaluateConstantValue(
    Value val) {
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
        mlir::cast<IntegerType>(extui.getIn().getType()).getWidth();
    return static_cast<uint64_t>(*inner) & ((1ULL << sourceWidth) - 1);
  }

  if (auto extsi = llvm::dyn_cast<mlir::arith::ExtSIOp>(defOp)) {
    auto inner = evaluateConstantValue(extsi.getIn());
    if (!inner)
      return std::nullopt;

    unsigned sourceWidth =
        mlir::cast<IntegerType>(extsi.getIn().getType()).getWidth();
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
CycloStaticDataflowAnalysis::ScheduleGraphBuilder::candidatePredicateOrNull(
    cal::Predicate predicateOp) {
  mlir::Value lhs, rhs;
  mlir::arith::CmpIPredicate pred;
  bool invalid = false;

  auto resultOps = predicateOp.getOps<mlir::cal::PredicateResultOp>();
  if (!resultOps.empty()) {
    auto resultOp = *resultOps.begin();
    if (auto cmpOp = resultOp.getEvaluationResult()
                         .getDefiningOp<mlir::arith::CmpIOp>()) {
      lhs = cmpOp.getLhs();
      rhs = cmpOp.getRhs();
      pred = cmpOp.getPredicate();
    } else {
      invalid = true;
    }
  } else {
    invalid = true;
  }

  if (invalid || !lhs || !rhs)
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
CycloStaticDataflowAnalysis::ScheduleGraphBuilder::getStateUpdatePatternOrNull(
    mlir::Value stateVar, cal::ActionOp actionOp) {
  int numSets = 0;
  mlir::cal::StateSetOp setOp = nullptr;
  actionOp->walk([&](mlir::cal::StateSetOp ss) {
    if (ss.getStateRef() == stateVar) {
      setOp = ss;
      numSets++;
    }
  });

  if (numSets != 1 || !setOp) {
    return std::nullopt;
  }

  // Case 1: Direct constant assignment
  if (auto assignedValue = evaluateConstantValue(setOp.getStateValue())) {
    return StateVarUpdatePattern{
        stateVar, StateVarUpdateKind::ConstantAssignment, *assignedValue};
  }

  // Case 2: Check for modulo pattern (x = (x + increment % K) )
  Operation *defOp = setOp.getStateValue().getDefiningOp();
  if (auto modPattern = detectModKPattern(defOp, setOp.getStateRef())) {
    int64_t increment = modPattern->first;
    int64_t modK = modPattern->second;
    return StateVarUpdatePattern{stateVar, StateVarUpdateKind::IncrementAndModK,
                                 increment, modK};
  }

  // Case 3: Simple increment pattern
  if (auto increment =
          getIncrementAmount(setOp.getStateValue(), setOp.getStateRef())) {
    return StateVarUpdatePattern{stateVar, StateVarUpdateKind::Increment,
                                 *increment};
  }

  return std::nullopt; // Could not determine update pattern
}

std::optional<int64_t>
CycloStaticDataflowAnalysis::ScheduleGraphBuilder::getIncrementAmount(
    Value setValue, Value targetStateVar) {
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

      unsigned sourceWidth =
          mlir::cast<IntegerType>(innerVal.getType()).getWidth();
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

      unsigned sourceWidth =
          mlir::cast<IntegerType>(innerVal.getType()).getWidth();
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

std::optional<ScheduleGraph> CycloStaticDataflowAnalysis::ScheduleGraphBuilder::
    constructScheduleGraphFromActionInfo(
        const llvm::MapVector<cal::ActionOp, SchedulingVariableInfoForAction>
            &actionInfoMap,
        int initialStateValue) {

  // Step 1: Verify that no action increments to positive infinity. If it does
  // we cannot generate a schedule
  for (const auto &entry : actionInfoMap) {
    if (hasPositiveInfinity(entry.second)) {
      return std::nullopt;
    }
  }

  std::vector<ScheduleNode> scheduleNodes;
  // Step 2: Ensure the vector is large enough to hold the initial state index.
  // This prepares the scheduleNodes vector so that we can index into it by
  // state value.
  scheduleNodes.resize(
      std::max<size_t>(scheduleNodes.size(), initialStateValue + 1));

  int currentStateValue = initialStateValue;

  // Step 3: Simulate the schedule graph construction by walking through state
  // values. For each state value, determine the corresponding action and the
  // next state, and build up the scheduleNodes vector accordingly.
  do {
    // Step 3.1: For the current state value, find the action that should be
    // executed.
    auto currentAction =
        getActionForStateValue(currentStateValue, actionInfoMap);

    if (!currentAction) {
      return std::nullopt; // No action found for this state value
    }

    const auto &infoForAction = actionInfoMap.lookup(*currentAction);
    auto updatePattern = infoForAction.updatePattern;

    // Step 3.2: Compute the next state value based on the update pattern of the
    // action.
    int nextStateValue;
    if (updatePattern->kind == StateVarUpdateKind::ConstantAssignment) {
      nextStateValue = updatePattern->value;
    } else if (updatePattern->kind == StateVarUpdateKind::Increment) {
      nextStateValue = currentStateValue + updatePattern->value;
    } else if (updatePattern->kind == StateVarUpdateKind::IncrementAndModK) {
      nextStateValue =
          (currentStateValue + updatePattern->value) % updatePattern->modK;
    }

    // Step 3.3: Add a ScheduleNode for the current state value.
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

  // Step 4: After simulating the schedule, construct and return the
  // ScheduleGraph object. The graph contains the actor, its type, and the
  // constructed schedule nodes.
  ScheduleGraph graph;
  graph.actor = actorOp;
  graph.type = GraphType::StateMachineSchedule;
  graph.nodes = std::move(scheduleNodes);
  graph.initialStateValue = initialStateValue;
  return graph;
}

int CycloStaticDataflowAnalysis::ScheduleGraphBuilder::findInitialAssignment(
    mlir::Value stateVar) {
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
CycloStaticDataflowAnalysis::ScheduleGraphBuilder::getActionForStateValue(
    int stateValue,
    const llvm::MapVector<cal::ActionOp, SchedulingVariableInfoForAction>
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
  return std::nullopt;
}

bool CycloStaticDataflowAnalysis::ScheduleGraphBuilder::
    allPredicatesTrueForState(
        int stateValue,
        const llvm::SmallVectorImpl<mlir::PredicateInequalityInfo>
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

bool CycloStaticDataflowAnalysis::ScheduleGraphBuilder::hasPositiveInfinity(
    const SchedulingVariableInfoForAction &info) {

  // Check if the pattern is always incrementing the state variable
  // by a positive value, which is necessary to lead to positive infinity.
  if (!info.updatePattern) {
    return false;
  }

  // IncrementAndModK cannot lead to positive infinity because it wraps around
  if (info.updatePattern->kind == StateVarUpdateKind::IncrementAndModK) {
    return false;
  }

  // Only consider incrementing operations without bounds
  if (!(info.updatePattern->kind == StateVarUpdateKind::Increment &&
        info.updatePattern->value > 0)) {
    return false;
  }

  // Look for a predicate that is ">" or ">=" and there is no corresponding "<"
  // or "<=" that bounds it above.
  bool hasLowerBound = false;
  bool hasUpperBound = false;
  int64_t lowerBound = 0;
  int64_t upperBound = std::numeric_limits<int64_t>::max();

  for (const auto &pred : info.predicateInequalities) {
    switch (pred.predicate) {
    case mlir::arith::CmpIPredicate::sgt:
    case mlir::arith::CmpIPredicate::ugt:
      hasLowerBound = true;
      if (pred.constant > lowerBound)
        lowerBound = pred.constant;
      break;
    case mlir::arith::CmpIPredicate::sge:
    case mlir::arith::CmpIPredicate::uge:
      hasLowerBound = true;
      if (pred.constant - 1 > lowerBound)
        lowerBound = pred.constant - 1;
      break;
    case mlir::arith::CmpIPredicate::slt:
    case mlir::arith::CmpIPredicate::ult:
      hasUpperBound = true;
      if (pred.constant - 1 < upperBound)
        upperBound = pred.constant - 1;
      break;
    case mlir::arith::CmpIPredicate::sle:
    case mlir::arith::CmpIPredicate::ule:
      hasUpperBound = true;
      if (pred.constant < upperBound)
        upperBound = pred.constant;
      break;
    default:
      break;
    }
  }

  // If there is a lower bound but no upper bound, then the increment can go to
  // infinity.
  if (hasLowerBound && !hasUpperBound)
    return true;

  return false;
}

std::optional<std::pair<int64_t, int64_t>>
CycloStaticDataflowAnalysis::ScheduleGraphBuilder::detectModKPattern(
    Operation *defOp, Value stateRef) {
  // First try to find the remainder operation, regardless of any extension
  // operations that might wrap it

  // Start with the top-level operation and traverse through possible extension
  // operations
  Operation *curOp = defOp;
  while (curOp) {
    // If we found a remainder op, we're in business
    if (auto remOp = dyn_cast<arith::RemUIOp>(curOp)) {
      // For modulo operations, we want to interpret the modulus as an unsigned
      // value Get the constant value directly if possible
      int64_t modK = 0;
      if (auto constantOp = remOp.getRhs().getDefiningOp<arith::ConstantOp>()) {
        if (auto intAttr = dyn_cast<IntegerAttr>(constantOp.getValue())) {
          // For modulo, always use unsigned interpretation
          modK = intAttr.getValue().getZExtValue();
        }
      } else {
        auto modKOpt = evaluateConstantValue(remOp.getRhs());
        if (!modKOpt) {
          return std::nullopt;
        }
        modK = *modKOpt;
      }

      // Now work backwards from remOp.getLhs() to find the add operation
      // We need to traverse through possible truncation operations
      Value lhsVal = remOp.getLhs();
      Operation *lhsOp = lhsVal.getDefiningOp();

      // Skip through any truncation operations
      while (lhsOp && isa<arith::TruncIOp>(lhsOp)) {
        lhsVal = cast<arith::TruncIOp>(lhsOp).getIn();
        lhsOp = lhsVal.getDefiningOp();
      }

      // Now check if we have an add operation
      if (auto addOp = dyn_cast_or_null<arith::AddIOp>(lhsOp)) {
        auto increment = getIncrementAmount(addOp.getResult(), stateRef);
        if (!increment) {
          return std::nullopt;
        }
        return std::pair<int64_t, int64_t>(*increment, modK);
      }

      return std::nullopt;
    }

    // If current op is an extension op, continue traversing
    if (auto extOp = dyn_cast<arith::ExtUIOp>(curOp)) {
      curOp = extOp.getIn().getDefiningOp();
    } else if (auto extOp = dyn_cast<arith::ExtSIOp>(curOp)) {
      curOp = extOp.getIn().getDefiningOp();
    } else {
      // Not an extension or remainder op, stop traversal
      break;
    }
  }

  return std::nullopt;
}

bool CycloStaticDataflowAnalysis::ScheduleGraphBuilder::predicateRegionsEqual(
    cal::Predicate firstPredicate, cal::Predicate secondPredicate) {
  // Get predicate inequality information for both predicates
  auto firstPredicateInfo = candidatePredicateOrNull(firstPredicate);
  auto secondPredicateInfo = candidatePredicateOrNull(secondPredicate);

  // If either predicate doesn't have valid inequality info, they can't be
  // compared
  if (!firstPredicateInfo || !secondPredicateInfo)
    return false;

  // Check if they reference the same state variable
  if (firstPredicateInfo->stateVar != secondPredicateInfo->stateVar)
    return false;

  // Check if they have the same predicate type
  if (firstPredicateInfo->predicate != secondPredicateInfo->predicate)
    return false;

  // Check if they compare against the same constant value
  if (firstPredicateInfo->constant != secondPredicateInfo->constant)
    return false;

  // If all checks pass, the predicates are functionally equivalent
  return true;
}

} // namespace mlir