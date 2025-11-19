#include "Transforms/Passes.h"
#include "Dialect/Cal/CalOps.h"
#include "Dialect/Cal/CalTypes.h"
#include "Dialect/Fifo/FifoTypes.h"
#include "Dialect/Fifo/FifoOps.h"
#include "mlir/IR/BuiltinOps.h"
#include "mlir/Pass/Pass.h"
#include "llvm/ADT/DenseMap.h"
#include "llvm/ADT/SmallVector.h"
#include "llvm/Support/FileSystem.h"
#include "llvm/Support/raw_ostream.h"

using namespace mlir;
using namespace mlir::cal;

namespace {

struct CalViewInstancesPass
    : public PassWrapper<CalViewInstancesPass, OperationPass<ModuleOp>> {
  MLIR_DEFINE_EXPLICIT_INTERNAL_INLINE_TYPE_ID(CalViewInstancesPass)

  CalViewInstancesPass() = default;
  // Explicit copy-ctor to satisfy PassWrapper::clonePass with non-copyable Option members.
  CalViewInstancesPass(const CalViewInstancesPass &other) {}

  StringRef getArgument() const final { return "cal-view-instances"; }
  StringRef getDescription() const final {
    return "Emit Graphviz DOT for instance-level connectivity in cal.networks";
  }

  // Match the option name from Passes.td (dotFile).
  Option<std::string> dotFile{*this, "dot-file", llvm::cl::init("op.dot"),
                              llvm::cl::desc("DOT output filename")};

  void runOnOperation() final {
    ModuleOp module = getOperation();

    std::error_code ec;
    llvm::raw_fd_ostream os(dotFile, ec, llvm::sys::fs::OF_Text);
    if (ec) {
      module.emitError() << "cannot open DOT file '" << dotFile
                         << "': " << ec.message();
      signalPassFailure();
      return;
    }

    os << "digraph cal_net {\n";
    os << "  rankdir=LR;\n";
    os << "  node [shape=box];\n";

    unsigned nextNodeId = 0;
    DenseMap<Operation *, std::string> instanceNodeNames;

    auto getNodeName = [&](Operation *instOp) -> std::string {
      auto it = instanceNodeNames.find(instOp);
      if (it != instanceNodeNames.end())
        return it->second;
      std::string name = ("n" + Twine(nextNodeId++)).str();
      instanceNodeNames[instOp] = name;
      return name;
    };

    // For each network, connect the instance that uses a fifo.create input port
    // (producer) to the instance that uses its output port (consumer).
    module.walk([&](cal::NetworkOp net) {
      Block &body = net.getBody().front();

      DenseMap<Value, cal::CreateInstanceOp> portUser;
      for (Operation &op : body) {
        if (auto ci = dyn_cast<cal::CreateInstanceOp>(&op)) {
          for (Value v : ci.getOperands()) {
            // Record only the first seen user for clarity; multiple users of the
            // same port value are atypical in well-formed networks.
            portUser.try_emplace(v, ci);
          }
        }
      }

      for (Operation &op : body) {
        if (auto fc = dyn_cast<fifo::CreateOp>(&op)) {
          Value inPort = fc.getInputPort();
          Value outPort = fc.getOutputPort();
          auto srcIt = portUser.find(inPort);
          auto dstIt = portUser.find(outPort);
          if (srcIt == portUser.end() || dstIt == portUser.end())
            continue;

          Operation *srcInst = srcIt->second.getOperation();
          Operation *dstInst = dstIt->second.getOperation();
          std::string srcNode = getNodeName(srcInst);
          std::string dstNode = getNodeName(dstInst);

          auto srcCreate = cast<cal::CreateInstanceOp>(srcInst);
          auto dstCreate = cast<cal::CreateInstanceOp>(dstInst);
          Twine srcLabel = srcCreate.getInstanceName().has_value()
                               ? Twine(srcCreate.getInstanceName().value())
                               : Twine(srcCreate.getActorRef());
          Twine dstLabel = dstCreate.getInstanceName().has_value()
                               ? Twine(dstCreate.getInstanceName().value())
                               : Twine(dstCreate.getActorRef());

          os << "  " << srcNode << " [label=\"" << srcLabel << "\"];\n";
          os << "  " << dstNode << " [label=\"" << dstLabel << "\"];\n";
          os << "  " << srcNode << " -> " << dstNode << ";\n";
        }
      }
    });

    os << "}\n";
  }
};

} // namespace

std::unique_ptr<mlir::Pass> mlir::createCalViewInstancesPass() {
  return std::make_unique<CalViewInstancesPass>();
}
