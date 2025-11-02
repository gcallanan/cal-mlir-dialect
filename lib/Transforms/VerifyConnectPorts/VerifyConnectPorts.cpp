#include "Transforms/Passes.h"
#include "Dialect/Cal/CalOps.h"
#include "Dialect/Cal/CalTypes.h"
#include "mlir/Dialect/Arith/IR/Arith.h"
#include "mlir/IR/BuiltinTypes.h"
#include "mlir/IR/SymbolTable.h"
#include "mlir/Pass/Pass.h"

using namespace mlir;
using namespace mlir::cal;

namespace {

static bool isNetworkBlockArg(Value v) {
  if (auto ba = dyn_cast<BlockArgument>(v)) {
    if (auto *parentOp = ba.getOwner()->getParentOp())
      return isa<cal::NetworkOp>(parentOp);
  }
  return false;
}


// Try to get a human-readable instance label from a handle value.
static std::string describeInstance(Value handle) {
  if (!handle)
    return std::string("<null>");
  if (auto *def = handle.getDefiningOp()) {
    if (auto inst = dyn_cast_or_null<cal::InstantiateOp>(def)) {
      if (auto name = inst.getInstanceName())
        return (Twine("inst::") + name.value()).str();
      return std::string("inst");
    }
    if (auto instArr = dyn_cast_or_null<cal::InstantiateArrayOp>(def)) {
      if (auto base = instArr.getBaseName())
        return (Twine("arr::") + base.value() + "[]").str();
      return std::string("arr[]");
    }
    if (auto at = dyn_cast_or_null<cal::InstanceAtOp>(def)) {
      // Recurse to array and append indices (use '?' for non-constants).
      std::string arr = describeInstance(at.getArray());
      std::string idxStr;
      bool first = true;
      for (Value iv : at.getIndices()) {
        if (!first) idxStr += ", ";
        first = false;
        if (auto cstIdx = iv.getDefiningOp<mlir::arith::ConstantOp>()) {
          if (auto ia = dyn_cast_or_null<IntegerAttr>(cstIdx.getValue())) {
            idxStr += std::to_string(ia.getInt());
            continue;
          }
        }
        idxStr += "?";
      }
      return arr + "[" + idxStr + "]";
    }
    if (auto castOp = dyn_cast_or_null<cal::InstanceCastOp>(def)) {
      return describeInstance(castOp.getInput());
    }
  }
  // Fallback on type info.
  Type ty = handle.getType();
  if (auto instTy = dyn_cast<cal::InstanceType>(ty))
    return std::string("@entity");
  if (auto ifTy = dyn_cast<cal::InterfaceInstanceType>(ty))
    return std::string("@iface");
  return std::string("<value>");
}

static bool portExistsOnActor(cal::ActorOp actor, StringRef portName, bool isSrc) {
  auto attr = isSrc ? actor->getAttrOfType<ArrayAttr>("outPortNames")
                    : actor->getAttrOfType<ArrayAttr>("inPortNames");
  if (!attr)
    return false;
  for (Attribute a : attr) {
    if (auto str = dyn_cast<StringAttr>(a)) {
      if (str.getValue() == portName)
        return true;
    }
  }
  return false;
}

static bool portExistsOnNetwork(cal::NetworkOp net, StringRef portName, bool isSrc) {
  auto attr = isSrc ? net->getAttrOfType<ArrayAttr>("outPortNames")
                    : net->getAttrOfType<ArrayAttr>("inPortNames");
  if (!attr)
    return false;
  for (Attribute a : attr) {
    if (auto str = dyn_cast<StringAttr>(a)) {
      if (str.getValue() == portName)
        return true;
    }
  }
  return false;
}

static bool portExistsOnInterface(cal::InterfaceOp iface, StringRef portName, bool isSrc) {
  auto attr = isSrc ? iface.getOutPortNamesAttr() : iface.getInPortNamesAttr();
  if (!attr)
    return false;
  for (Attribute a : attr) {
    if (auto str = dyn_cast<StringAttr>(a)) {
      if (str.getValue() == portName)
        return true;
    }
  }
  return false;
}

static void collectPorts(ArrayAttr names, SmallVectorImpl<StringRef> &out) {
  if (!names) return;
  for (Attribute a : names) if (auto s = dyn_cast<StringAttr>(a)) out.push_back(s.getValue());
}

struct VerifyConnectPortsPass
    : public PassWrapper<VerifyConnectPortsPass, OperationPass<ModuleOp>> {
  MLIR_DEFINE_EXPLICIT_INTERNAL_INLINE_TYPE_ID(VerifyConnectPortsPass)
  StringRef getArgument() const final { return "verify-connect-ports"; }
  StringRef getDescription() const final {
    return "Verify that cal.connect names ports that exist on entities or interfaces";
  }
  void runOnOperation() final {
    ModuleOp mod = getOperation();
    SymbolTableCollection symTables;

    WalkResult wr = mod.walk([&](cal::ConnectOp conn) {
      bool ok = true;
      // Check source side unless it is a network SSA port.
      if (!isNetworkBlockArg(conn.getSrc())) {
        ok &= checkOneSide(conn, /*isSrc=*/true, symTables);
      }
      // Check destination side unless it is a network SSA port.
      if (!isNetworkBlockArg(conn.getDst())) {
        ok &= checkOneSide(conn, /*isSrc=*/false, symTables);
      }
      if (!ok)
        return WalkResult::interrupt();
      return WalkResult::advance();
    });

    if (wr.wasInterrupted())
      signalPassFailure();
  }

  bool checkOneSide(cal::ConnectOp conn, bool isSrc, SymbolTableCollection &syms) {
    Value h = isSrc ? conn.getSrc() : conn.getDst();
    StringRef port = isSrc ? conn.getSrcPort() : conn.getDstPort();

    // Strip cal.instance.cast
    if (auto castOp = h.getDefiningOp<cal::InstanceCastOp>())
      h = castOp.getInput();
    // Strip cal.instance_at (we rely on the handle type, which is scalar).
    if (auto at = h.getDefiningOp<cal::InstanceAtOp>())
      h = at.getHandle();

    Type ty = h.getType();
    // Interface-typed handle: verify against the interface symbol.
    if (auto ifTy = dyn_cast<cal::InterfaceInstanceType>(ty)) {
      auto iface = syms.lookupNearestSymbolFrom<cal::InterfaceOp>(conn, ifTy.getIfaceRef());
      if (!iface) return true; // defer if missing; another verifier should catch
      if (!portExistsOnInterface(iface, port, isSrc)) {
        SmallVector<StringRef, 8> avail;
        collectPorts(isSrc ? iface.getOutPortNamesAttr() : iface.getInPortNamesAttr(), avail);
        std::string availStr;
        for (size_t i = 0; i < avail.size(); ++i) {
          if (i) availStr += ", ";
          availStr += avail[i].str();
        }
        conn.emitError()
            << "invalid port '" << port << "' on interface for "
            << (isSrc ? "source" : "destination") << "; available: " << availStr
            << ". At instance " << describeInstance(h);
        return false;
      }
      return true;
    }

    // Concrete entity-typed handle: look up actor or network and check.
    if (auto instTy = dyn_cast<cal::InstanceType>(ty)) {
      auto sym = instTy.getActorRef();
      // Try actor first.
      if (auto actor = syms.lookupNearestSymbolFrom<cal::ActorOp>(conn, sym)) {
        if (!portExistsOnActor(actor, port, isSrc)) {
          SmallVector<StringRef, 8> avail;
          collectPorts(isSrc ? actor->getAttrOfType<ArrayAttr>("outPortNames")
                             : actor->getAttrOfType<ArrayAttr>("inPortNames"),
                       avail);
          std::string availStr;
          for (size_t i = 0; i < avail.size(); ++i) {
            if (i) availStr += ", ";
            availStr += avail[i].str();
          }
          conn.emitError()
              << "invalid port '" << port << "' on actor '" << sym.getValue()
              << "' for " << (isSrc ? "source" : "destination") << "; available: " << availStr
              << ". At instance " << describeInstance(h);
          return false;
        }
        return true;
      }
      // Or a network symbol (when connecting to a network instance boundary)
      if (auto net = syms.lookupNearestSymbolFrom<cal::NetworkOp>(conn, sym)) {
        if (!portExistsOnNetwork(net, port, isSrc)) {
          SmallVector<StringRef, 8> avail;
          collectPorts(isSrc ? net->getAttrOfType<ArrayAttr>("outPortNames")
                             : net->getAttrOfType<ArrayAttr>("inPortNames"),
                       avail);
          std::string availStr;
          for (size_t i = 0; i < avail.size(); ++i) {
            if (i) availStr += ", ";
            availStr += avail[i].str();
          }
          conn.emitError()
              << "invalid port '" << port << "' on network '" << sym.getValue()
              << "' for " << (isSrc ? "source" : "destination") << "; available: " << availStr
              << ". At instance " << describeInstance(h);
          return false;
        }
        return true;
      }
      // Unknown symbol; defer to other verifiers.
      return true;
    }

    // If it's neither an instance handle nor an interface handle (e.g., a FIFO port SSA), skip.
    return true;
  }
};

} // namespace

std::unique_ptr<mlir::Pass> mlir::createVerifyConnectPortsPass() {
  return std::make_unique<VerifyConnectPortsPass>();
}
