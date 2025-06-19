#include "mlir/Dialect/Arith/IR/Arith.h"
#include "mlir/IR/OpImplementation.h"
#include "Dialect/Cal/CalOps.h"
#include "Conversion/CalToFuncWithStaticSchedule/CycloStaticDataflowAnalysis.h"

namespace mlir {

llvm::raw_ostream &operator<<(llvm::raw_ostream &os, const PredicateInfo &info) {
  std::string ssaName;
  llvm::raw_string_ostream ss(ssaName);
  info.stateVar.printAsOperand(ss, mlir::OpPrintingFlags().useLocalScope());
  ss.flush();

  os << "PredicateInfo(" << ssaName << " ";
  switch (info.predicate) {
  case mlir::arith::CmpIPredicate::eq:  os << "=="; break;
  case mlir::arith::CmpIPredicate::ne:  os << "!="; break;
  case mlir::arith::CmpIPredicate::slt: os << "<";  break;
  case mlir::arith::CmpIPredicate::sle: os << "<="; break;
  case mlir::arith::CmpIPredicate::sgt: os << ">";  break;
  case mlir::arith::CmpIPredicate::sge: os << ">="; break;
  case mlir::arith::CmpIPredicate::ult: os << "<";  break;
  case mlir::arith::CmpIPredicate::ule: os << "<="; break;
  case mlir::arith::CmpIPredicate::ugt: os << ">";  break;
  case mlir::arith::CmpIPredicate::uge: os << ">="; break;
  }
  os << " " << info.constant << ")\n";
  return os;
}

CycloStaticDataflowAnalysis::CycloStaticDataflowAnalysis(Operation *op) {
  llvm::outs() << "\n\n\nCycloStaticDataflowAnalysis: Analyzing operation: "
               << op->getName() << "\n";

  op->walk([&](mlir::cal::Predicate predicateOp) {
    if (auto predicateInfo = validPredicate(predicateOp)) {
      predicateStateVariables[predicateOp] = *predicateInfo;
    }
  });

  for (const auto &entry : predicateStateVariables) {
    auto predicateOp = entry.first;
    auto predicateInfoOpt = validPredicate(predicateOp);
    if (predicateInfoOpt) {
      const auto &info = *predicateInfoOpt;
      llvm::outs() << "Predicate: " << predicateOp << "\n" << info << "\n";
    }
  }
}

std::optional<int64_t> CycloStaticDataflowAnalysis::tryGetConstantValue(Value val) {
  if (auto constantOp = val.getDefiningOp<mlir::arith::ConstantOp>()) {
    if (auto intAttr = llvm::dyn_cast<IntegerAttr>(constantOp.getValue())) {
      return intAttr.getValue().getSExtValue(); // or getZExtValue() if needed
    }
  }
  return std::nullopt;
}

std::optional<int64_t> CycloStaticDataflowAnalysis::evaluateConstantValue(Value val) {
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

std::optional<PredicateInfo> CycloStaticDataflowAnalysis::validPredicate(cal::Predicate predicateOp) {
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
    return PredicateInfo{pred, stateVar, *constVal};
  }

  return std::nullopt;
}

} // namespace mlir
