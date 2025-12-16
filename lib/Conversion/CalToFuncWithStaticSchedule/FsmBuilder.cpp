#include "Conversion/CalToFuncWithStaticSchedule/CycloStaticDataflowAnalysis.h"
#include "Dialect/Cal/CalOps.h"
#include "mlir/Dialect/Arith/IR/Arith.h"
#include "mlir/IR/OpImplementation.h"
#include "llvm/ADT/DenseSet.h"
#include <queue>

namespace mlir {

CycloStaticDataflowAnalysis::FsmBuilder::FsmBuilder(
    cal::ActorOp actorOp)
    : actorOp(actorOp) {}

Fsm CycloStaticDataflowAnalysis::FsmBuilder::generateFsm() {
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
        auto stateIncrementPatternList =
            getStateUpdatePatternList(predicateInfo->stateVar, actionOp);
        if (stateIncrementPatternList.size() > 0) {
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
    Fsm Fsm;
    Fsm.actor = actorOp;
    Fsm.type = FsmType::Dynamic;
    return Fsm;
  }

  // STEP 2: Analyse the inequalities and state updates for the common state
  // variable across all actions to see if we can construct a Fsm.

  // What do I have to do here?
  // 1. Construct a map of actions and SchedulingVariableInfoForAction objects
  // 2. Pass this map to the Fsm constructor which will attempt to
  //    construct a Fsm based on the information provided.
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
    auto stateUpdatePatternList =
        getStateUpdatePatternList(commonStateVar, actionOp);

    SchedulingVariableInfoForAction infoForAction;
    infoForAction.stateVar = commonStateVar;
    infoForAction.predicateInequalities = std::move(predicateInfos);
    infoForAction.updatePatternList = stateUpdatePatternList;
    actionInfoMap[actionOp] = infoForAction;
  }

  int initialStateValue = findInitialAssignment(commonStateVar);

  if (auto fsm =
          constructActorFsmFromActionInfo(actionInfoMap, initialStateValue)) {
    return *fsm;
  } else {
    Fsm fsmObj;
    fsmObj.actor = actorOp;
    fsmObj.type = FsmType::Dynamic;
    return fsmObj;
  }
}

std::optional<int64_t>
CycloStaticDataflowAnalysis::FsmBuilder::tryGetConstantValue(
    Value val) {
  if (auto constantOp = val.getDefiningOp<mlir::arith::ConstantOp>()) {
    if (auto intAttr = llvm::dyn_cast<IntegerAttr>(constantOp.getValue())) {
      return intAttr.getValue().getSExtValue(); // or getZExtValue() if needed
    }
  }
  return std::nullopt;
}

std::optional<int64_t>
CycloStaticDataflowAnalysis::FsmBuilder::evaluateConstantValue(
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
CycloStaticDataflowAnalysis::FsmBuilder::candidatePredicateOrNull(
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

std::list<StateVarUpdatePattern>
CycloStaticDataflowAnalysis::FsmBuilder::getStateUpdatePatternList(
    mlir::Value stateVar, cal::ActionOp actionOp) {
  llvm::SmallVector<mlir::cal::StateSetOp, 4> setOps;

  actionOp->walk([&](mlir::cal::StateSetOp ss) {
    if (ss.getStateRef() == stateVar) {
      setOps.push_back(ss);
    }
  });

  if (setOps.empty()) {
    return {};
  }

  std::list<StateVarUpdatePattern> patterns;

  // Process each StateSetOp to extract its pattern
  for (auto setOp : setOps) {
    std::optional<StateVarUpdatePattern> pattern;

    // Case 1: Direct constant assignment
    if (auto assignedValue = evaluateConstantValue(setOp.getStateValue())) {
      pattern = StateVarUpdatePattern{
          stateVar, StateVarUpdateKind::ConstantAssignment, *assignedValue};
    }
    // Case 2: Check for modulo pattern (x = (x + increment) % K)
    else if (auto modPattern = detectModKPattern(
                 setOp.getStateValue().getDefiningOp(), setOp.getStateRef())) {
      int64_t increment = modPattern->first;
      int64_t modK = modPattern->second;
      pattern = StateVarUpdatePattern{
          stateVar, StateVarUpdateKind::IncrementAndModK, increment, modK};
    }
    // Case 3: Simple increment pattern
    else if (auto increment = getIncrementAmount(setOp.getStateValue(),
                                                 setOp.getStateRef())) {
      pattern = StateVarUpdatePattern{stateVar, StateVarUpdateKind::Increment,
                                      *increment};
    }

    // If we found a valid pattern, add it to the list
    if (pattern) {
      patterns.push_back(*pattern);
    } else {
      // If any pattern is not one of the three valid types, return empty list
      return {};
    }
  }

  return patterns;
}

bool CycloStaticDataflowAnalysis::FsmBuilder::isStateModifiedEarlier(
    cal::StateGetOp getOp, Value targetStateVar) {
  // Create a worklist of blocks to process
  llvm::SmallVector<Block *, 8> worklist;
  llvm::SmallPtrSet<Block *, 8> visited;

  // Start with the parent block containing the getOp
  Block *parentBlock = getOp.getOperation()->getBlock();
  worklist.push_back(parentBlock);

  while (!worklist.empty()) {
    Block *currentBlock = worklist.pop_back_val();

    // Skip if already visited
    if (!visited.insert(currentBlock).second)
      continue;

    // Walk the current block up to (but not including) getOp to find any
    // earlier cal.set
    for (Operation &op : *currentBlock) {
      // If we're in the original parent block, stop at getOp
      if (currentBlock == parentBlock && &op == getOp.getOperation())
        break;

      if (auto setOp = dyn_cast<cal::StateSetOp>(op)) {
        if (setOp.getStateRef() == targetStateVar) {
          return true; // State variable is modified earlier
        }
      }

      // If this operation contains nested regions/blocks, enqueue those blocks
      if (op.getNumRegions() > 0) {
        for (Region &region : op.getRegions()) {
          for (Block &childBlock : region) {
            if (!visited.count(&childBlock))
              worklist.push_back(&childBlock);
          }
        }
      }

      // Add predecessor blocks to the worklist so we can search earlier blocks
      for (Block *pred : currentBlock->getPredecessors()) {
        if (!pred)
          continue;
        // Only add if we haven't visited it yet
        if (!visited.count(pred))
          worklist.push_back(pred);
      }
    }
  }
  return false;
}

std::optional<int64_t>
CycloStaticDataflowAnalysis::FsmBuilder::getIncrementAmount(
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

      if (!isStateModifiedEarlier(getOp, targetStateVar)) {
        continue; // Valid dependency on target state var
      } else {
        return std::nullopt; // State variable modified earlier in action
      }

      continue;
    }

    // Anything else — reject
    return std::nullopt;
  }

  if (!foundMatchingState)
    return std::nullopt; // No dependence on target state var

  return delta;
}

std::optional<Fsm> CycloStaticDataflowAnalysis::FsmBuilder::
    constructActorFsmFromActionInfo(
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

  std::vector<FsmNode> FsmNodes;
  // Step 2: Ensure the vector is large enough to hold the initial state index.
  // This prepares the FsmNOdes vector so that we can index into it by
  // state value.
  FsmNodes.resize(
      std::max<size_t>(FsmNodes.size(), initialStateValue + 1));

  // Step 3: Use breadth-first search to construct the Fsm.
  // We use a queue to process states in order, and track visited states.
  std::queue<int> stateQueue;
  llvm::DenseSet<int> visitedStates;

  stateQueue.push(initialStateValue);
  visitedStates.insert(initialStateValue);

  while (!stateQueue.empty()) {
    int currentStateValue = stateQueue.front();
    stateQueue.pop();

    // Step 3.1: For the current state value, find the action that should be
    // executed.
    auto currentAction =
        getActionForStateValue(currentStateValue, actionInfoMap);

    if (!currentAction) {
      // No action found for this state value, skip this state
      continue;
    }

    const auto &infoForAction = actionInfoMap.lookup(*currentAction);

    // Step 3.2: Create a FsmNode for the current state value.
    // Ensure the vector is large enough to hold this state index.
    if (FsmNodes.size() <= static_cast<size_t>(currentStateValue))
      FsmNodes.resize(currentStateValue + 1);

    FsmNode node;
    node.action = *currentAction;

    // Step 3.3: Iterate through all update patterns and create an edge for each
    for (const auto &updatePattern : infoForAction.updatePatternList) {
      // Compute the next state value based on the update pattern
      int nextStateValue;
      if (updatePattern.kind == StateVarUpdateKind::ConstantAssignment) {
        nextStateValue = updatePattern.value;
      } else if (updatePattern.kind == StateVarUpdateKind::Increment) {
        nextStateValue = currentStateValue + updatePattern.value;
      } else if (updatePattern.kind == StateVarUpdateKind::IncrementAndModK) {
        nextStateValue =
            (currentStateValue + updatePattern.value) % updatePattern.modK;
      }

      // Ensure the vector is large enough for the next state
      if (FsmNodes.size() <= static_cast<size_t>(nextStateValue))
        FsmNodes.resize(nextStateValue + 1);

      // Create an edge to the next state value
      FsmEdge edge;
      edge.nextNodeIndex = nextStateValue;

      // If the next state has already been visited, mark this edge as a
      // wrap-around (cycle) edge. Otherwise, mark it as a regular Next edge
      // and add the next state to the queue for processing.
      if (!visitedStates.count(nextStateValue)) {
        stateQueue.push(nextStateValue);
        visitedStates.insert(nextStateValue);
      }

      node.edges.push_back(edge);
    }

    FsmNodes[currentStateValue] = node;
  }

  // Step 4: After simulating the schedule, construct and return the
  // Fsm object. The Fsm contains the actor, its type, and the
  // constructed Fsm nodes.
  Fsm Fsm;
  Fsm.actor = actorOp;
  Fsm.type = determineFsmType(FsmNodes, initialStateValue);
  Fsm.nodes = std::move(FsmNodes);
  Fsm.initialStateValue = initialStateValue;
  return Fsm;
}


FsmType
CycloStaticDataflowAnalysis::FsmBuilder::determineFsmType(
    std::vector<FsmNode> &FsmNodes, int initialStateValue) {
      
    // We currently classify Fsms only as SimpleLoop or Unclassified.
    // To detect a SimpleLoop, traverse edges starting from the initial state
    // and locate the first cycle. If that cycle returns to the initial state,
    // the Fsm is a SimpleLoop; otherwise it is Unclassified.
    llvm::DenseSet<int> visitedNodes;
    visitedNodes.insert(initialStateValue);
    FsmNode node = FsmNodes[initialStateValue];
    while (true) {
      if (node.edges.size() != 1) {
        return FsmType::FSM_Unclassified;
      }
      int nextIndex = node.edges.front().nextNodeIndex;
      if (visitedNodes.count(nextIndex)) {
        if(nextIndex != initialStateValue) {
          return FsmType::FSM_Unclassified;
        }else {
          return FsmType::FSM_SimpleLoop;
        }
      }
      visitedNodes.insert(nextIndex);
      node = FsmNodes[nextIndex]; 
    }
}

int CycloStaticDataflowAnalysis::FsmBuilder::findInitialAssignment(
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
CycloStaticDataflowAnalysis::FsmBuilder::getActionForStateValue(
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

bool CycloStaticDataflowAnalysis::FsmBuilder::
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

bool CycloStaticDataflowAnalysis::FsmBuilder::hasPositiveInfinity(
    const SchedulingVariableInfoForAction &info) {

  // Check if the pattern is always incrementing the state variable
  // by a positive value, which is necessary to lead to positive infinity.
  if (info.updatePatternList.size() == 0 &&
      info.updatePatternList.size() <= 1) {
    return false;
  }

  auto updatePattern = info.updatePatternList.front();

  // IncrementAndModK cannot lead to positive infinity because it wraps around
  if (updatePattern.kind == StateVarUpdateKind::IncrementAndModK) {
    return false;
  }

  // Only consider incrementing operations without bounds
  if (!(updatePattern.kind == StateVarUpdateKind::Increment &&
        updatePattern.value > 0)) {
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
CycloStaticDataflowAnalysis::FsmBuilder::detectModKPattern(
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

bool CycloStaticDataflowAnalysis::FsmBuilder::predicateRegionsEqual(
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