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

    os << "/* Enhanced CAL instance connectivity DOT (HTML labels) */\n";
    os << "digraph cal_net {\n";
    os << "  rankdir=LR;\n";
    os << "  node [shape=none];\n"; // we use HTML-like labels with tables
    os << "  edge [penwidth=4];\n";
    
    // Helper to produce deterministic edge colors similar to Java version.
    auto hashColor = [&](const void *ptr) -> std::string {
      uintptr_t h = reinterpret_cast<uintptr_t>(ptr);
      int r = 0xff - (int)((h + 1) % 0xce);
      int g = 0xff - (int)((h + 1) % 0xdd);
      int b = 0xff - (int)((h + 1) % 0xec);
      char buf[16];
      snprintf(buf, sizeof(buf), "#%02x%02x%02x", r & 0xff, g & 0xff, b & 0xff);
      return std::string(buf);
    };

    // Walk each network independently; produce grouped IN/OUT nodes plus instances.
    module.walk([&](cal::NetworkOp net) {
      // Build maps for instance nodes and port associations.
      Block &body = net.getBody().front();

      // Collect external network port names if present.
      SmallVector<std::string> netInNames;
      SmallVector<std::string> netOutNames;
      if (auto arr = net.getInPortNamesAttr()) {
        for (Attribute a : arr) netInNames.push_back(cast<StringAttr>(a).getValue().str());
      }
      if (auto arr = net.getOutPortNamesAttr()) {
        for (Attribute a : arr) netOutNames.push_back(cast<StringAttr>(a).getValue().str());
      }

      // The block arguments: params, then ports_in (output_port type), then ports_out (input_port type).
      // We collect them by filtering types.
      SmallVector<Value> netInputPorts;  // logical network inputs (fifo.output_port) sources
      SmallVector<Value> netOutputPorts; // logical network outputs (fifo.input_port) sinks
      for (Value arg : body.getArguments()) {
        if (arg.getType().isa<fifo::OutputPortType>()) {
          netInputPorts.push_back(arg);
        } else if (arg.getType().isa<fifo::InputPortType>()) {
          netOutputPorts.push_back(arg);
        }
      }

      // Emit synthetic INs node if any.
      if (!netInputPorts.empty()) {
        os << "  __INs [label=<\n";
        os << "    <table border=\"0\" cellborder=\"1\" cellspacing=\"0\">\n";
        os << "      <tr><td bgcolor=\"#7ba79d\"><font point-size=\"25\" color=\"#ffffff\"> INPUTS </font></td></tr>\n";
        os << "      <tr><td>\n";
        os << "        <table border=\"0\" cellborder=\"0\" cellspacing=\"0\">\n";
        for (size_t i = 0; i < netInputPorts.size(); ++i) {
          std::string name = i < netInNames.size() ? netInNames[i] : ("in" + std::to_string(i));
          os << "          <tr><td align=\"right\" port=\"" << name << "\"><font point-size=\"15\"> " << name << " </font></td></tr>\n";
        }
        os << "        </table>\n";
        os << "      </td></tr>\n";
        os << "    </table>\n";
        os << "  >];\n";
      }

      // Node name allocation for instances.
      unsigned nextNodeId = 0;
      DenseMap<Operation *, std::string> instanceNodeNames;
      auto getNodeName = [&](Operation *instOp) -> std::string {
        auto it = instanceNodeNames.find(instOp);
        if (it != instanceNodeNames.end()) return it->second;
        std::string name = ("n" + Twine(nextNodeId++)).str();
        instanceNodeNames[instOp] = name;
        return name;
      };

      // For each instance build HTML label capturing ports.
      for (Operation &op : body) {
        auto ci = dyn_cast<cal::CreateInstanceOp>(&op);
        if (!ci) continue;

        cal::ActorOp actor = ci.getActor();
        // Gather actor port names (fallback to numeric if missing).
        SmallVector<std::string> actorInNames;
        SmallVector<std::string> actorOutNames;
        if (actor) {
          if (auto arr = actor.getInPortNamesAttr()) {
            for (Attribute a : arr) actorInNames.push_back(cast<StringAttr>(a).getValue().str());
          }
          if (auto arr = actor.getOutPortNamesAttr()) {
            for (Attribute a : arr) actorOutNames.push_back(cast<StringAttr>(a).getValue().str());
          }
        }
        // Count ports by operand types (skip non-fifo operands assumed to be params).
        SmallVector<Value> inPortOperands;  // fifo.output_port -> actor input
        SmallVector<Value> outPortOperands; // fifo.input_port -> actor output
        for (Value v : ci.getOperands()) {
          if (v.getType().isa<fifo::OutputPortType>()) inPortOperands.push_back(v);
          else if (v.getType().isa<fifo::InputPortType>()) outPortOperands.push_back(v);
        }
        // Ensure default names if missing.
        if (actorInNames.size() < inPortOperands.size()) {
          for (size_t i = actorInNames.size(); i < inPortOperands.size(); ++i)
            actorInNames.push_back("in" + std::to_string(i));
        }
        if (actorOutNames.size() < outPortOperands.size()) {
          for (size_t i = actorOutNames.size(); i < outPortOperands.size(); ++i)
            actorOutNames.push_back("out" + std::to_string(i));
        }

        std::string nodeName = getNodeName(ci);
        std::string instLabel = ci.getInstanceName().has_value()
                  ? ci.getInstanceName()->str()
                  : ci.getActorRef().str();

        // Build rows aligning inputs and outputs similar to Java version.
        size_t rows = std::max(inPortOperands.size(), outPortOperands.size());
        os << "  " << nodeName << " [label=<\n";
        os << "    <table border=\"0\" cellborder=\"1\" cellspacing=\"0\">\n";
        os << "      <tr><td bgcolor=\"black\"><font point-size=\"30\" color=\"#ffffff\"> " << instLabel << " </font></td></tr>\n";
        os << "      <tr><td>\n";
        os << "        <table border=\"1\" cellborder=\"0\" cellspacing=\"0\">\n";
        os << "          <tr><td colspan=\"2\"><font point-size=\"15\">[" << (actor ? actor.getSymName() : instLabel) << "]</font></td></tr>\n";
        for (size_t i = 0; i < rows; ++i) {
          std::string inName = i < actorInNames.size() ? actorInNames[i] : "";
          std::string outName = i < actorOutNames.size() ? actorOutNames[i] : "";
          os << "          <tr><td align=\"left\" port=\"" << inName << "\"> " << inName << " </td><td align=\"right\" port=\"" << outName << "\"><font point-size=\"15\"> " << outName << " </font></td></tr>\n";
        }
        os << "        </table>\n";
        os << "      </td></tr>\n";
        os << "    </table>\n";
        os << "  >];\n";
      }

      // Emit synthetic OUTs node if any.
      if (!netOutputPorts.empty()) {
        os << "  __OUTs [label=<\n";
        os << "    <table border=\"0\" cellborder=\"1\" cellspacing=\"0\">\n";
        os << "      <tr><td bgcolor=\"#7ba79d\"><font point-size=\"25\" color=\"#ffffff\"> OUTPUTS </font></td></tr>\n";
        os << "      <tr><td>\n";
        os << "        <table border=\"0\" cellborder=\"0\" cellspacing=\"0\">\n";
        for (size_t i = 0; i < netOutputPorts.size(); ++i) {
          std::string name = i < netOutNames.size() ? netOutNames[i] : ("out" + std::to_string(i));
          os << "          <tr><td align=\"left\" port=\"" << name << "\"><font point-size=\"15\"> " << name << " </font></td></tr>\n";
        }
        os << "        </table>\n";
        os << "      </td></tr>\n";
        os << "    </table>\n";
        os << "  >];\n";
      }

      // Map port Values to instance + port names for edge construction.
      struct PortInfo { cal::CreateInstanceOp inst; std::string name; bool isOutputFromInstance; };
      DenseMap<Value, PortInfo> valueToPortInfo;
      for (Operation &op2 : body) {
        auto ci = dyn_cast<cal::CreateInstanceOp>(&op2);
        if (!ci) continue;
        cal::ActorOp actor = ci.getActor();
        SmallVector<std::string> actorInNames;
        SmallVector<std::string> actorOutNames;
        if (actor) {
          if (auto arr = actor.getInPortNamesAttr()) for (Attribute a : arr) actorInNames.push_back(cast<StringAttr>(a).getValue().str());
          if (auto arr = actor.getOutPortNamesAttr()) for (Attribute a : arr) actorOutNames.push_back(cast<StringAttr>(a).getValue().str());
        }
        size_t inIdx = 0, outIdx = 0;
        for (Value v : ci.getOperands()) {
          if (v.getType().isa<fifo::OutputPortType>()) {
            std::string nm = inIdx < actorInNames.size() ? actorInNames[inIdx] : ("in" + std::to_string(inIdx));
            valueToPortInfo[v] = {ci, nm, false}; // consumed by instance
            ++inIdx;
          } else if (v.getType().isa<fifo::InputPortType>()) {
            std::string nm = outIdx < actorOutNames.size() ? actorOutNames[outIdx] : ("out" + std::to_string(outIdx));
            valueToPortInfo[v] = {ci, nm, true}; // produced by instance
            ++outIdx;
          }
        }
      }
      // Network external ports.
      for (size_t i = 0; i < netInputPorts.size(); ++i) {
        Value v = netInputPorts[i];
        std::string nm = i < netInNames.size() ? netInNames[i] : ("in" + std::to_string(i));
        // External source producing tokens -> treat as producer (isOutputFromInstance=true for styling edge tail side).
        valueToPortInfo[v] = {cal::CreateInstanceOp(), nm, true};
      }
      for (size_t i = 0; i < netOutputPorts.size(); ++i) {
        Value v = netOutputPorts[i];
        std::string nm = i < netOutNames.size() ? netOutNames[i] : ("out" + std::to_string(i));
        // External sink consuming tokens -> not producer.
        valueToPortInfo[v] = {cal::CreateInstanceOp(), nm, false};
      }

      // Create edges for each fifo.create.
      for (Operation &op3 : body) {
        auto fc = dyn_cast<fifo::CreateOp>(&op3);
        if (!fc) continue;
        Value inPort = fc.getInputPort();   // used by producer (push)
        Value outPort = fc.getOutputPort(); // used by consumer (pop)

        auto srcInfoIt = valueToPortInfo.find(inPort);
        auto dstInfoIt = valueToPortInfo.find(outPort);
        if (srcInfoIt == valueToPortInfo.end() || dstInfoIt == valueToPortInfo.end())
          continue;

        PortInfo srcInfo = srcInfoIt->second;
        PortInfo dstInfo = dstInfoIt->second;
        std::string srcNode;
        std::string dstNode;
        std::string srcPortName = srcInfo.name;
        std::string dstPortName = dstInfo.name;
        if (srcInfo.inst) {
          srcNode = instanceNodeNames.lookup(srcInfo.inst.getOperation());
        } else {
          srcNode = "__INs"; // external network input
        }
        if (dstInfo.inst) {
          dstNode = instanceNodeNames.lookup(dstInfo.inst.getOperation());
        } else {
          dstNode = "__OUTs"; // external network output
        }

        std::string color = hashColor(fc.getOperation());
        int capacity = (int)fc.getBufferSize();
        os << "  " << srcNode << ":" << srcPortName << ":e -> " << dstNode << ":" << dstPortName
           << ":w [color=\"" << color << "\", label=\"sz=" << capacity << "\"];\n";
      }
    });

    os << "}\n";
  }
};

} // namespace

std::unique_ptr<mlir::Pass> mlir::createCalViewInstancesPass() {
  return std::make_unique<CalViewInstancesPass>();
}
