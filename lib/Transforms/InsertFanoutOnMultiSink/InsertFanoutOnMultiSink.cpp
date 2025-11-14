//===- InsertFanoutOnMultiSink.cpp - Fanout insertion pass -------*- C++ -*-===//
// This file is licensed under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//===----------------------------------------------------------------------===//

#include "mlir/Pass/Pass.h"
#include "Transforms/Passes.h"
#include "Dialect/Cal/CalOps.h"
#include "Dialect/Cal/CalTypes.h"
#include "Dialect/Fifo/FifoOps.h"
#include "Dialect/Fifo/FifoTypes.h"
#include "mlir/Dialect/Arith/IR/Arith.h"
#include "mlir/Dialect/SCF/IR/SCF.h"

namespace mlir {
namespace {
/// InsertFanoutOnMultiSinkPass
///
/// This pass normalizes groups of multiple cal.connect operations that share
/// the same source instance+port and target distinct sink ports by inserting
/// a synthesized fanout actor. The original pattern:
///   src.OUT -> sink0.IN  capacity(C)
///   src.OUT -> sink1.IN  capacity(C)
///   ...
/// becomes:
///   (fifo.create for each sink) OR (reuse original capacities)
///   src.OUT -> fan.in  capacity(C)    // one fifo from source to fanout
///   fan.out0 -> sink0.IN
///   fan.out1 -> sink1.IN
/// with a newly created cal.actor @__fanout_T_N (T element type, N fanouts)
/// having one input port and N output ports that pop once and push the same
/// value to all outputs each firing. For now we generate a simple action:
///   cal.action { %v = fifo.pop(in); fifo.push(out0,%v); ... fifo.push(outN,%v); }
///
/// Reuse: if a suitable fanout actor symbol already exists in the module we
/// do not recreate it. Instances are named "fanout_srcPort_N" for readability.
///
/// Capacity propagation: We keep the smallest capacity among all original
/// connects for the new single fifo from src to fan.in (if capacities differ)
/// and drop capacities on sink connects (they will be created by later
/// elaboration passes). If all capacities identical we preserve that value.
///
/// Preconditions: shape inference & entity elaboration have run so indices
/// are explicit and source/destination handles are scalar (not arrays) or
/// array indexing has been resolved by ConnectOp sugar into explicit indices.
struct InsertFanoutOnMultiSinkPass
    : public PassWrapper<InsertFanoutOnMultiSinkPass, OperationPass<ModuleOp>> {
  MLIR_DEFINE_EXPLICIT_INTERNAL_INLINE_TYPE_ID(InsertFanoutOnMultiSinkPass)
  StringRef getArgument() const final { return "insert-fanout-on-multisink"; }
  StringRef getDescription() const final { return "Insert fanout actor for multi-sink groups of cal.connect"; }

  void runOnOperation() override {
    ModuleOp module = getOperation();
    // Walk each network independently so we keep symbols localized.
    SmallVector<cal::NetworkOp> networks;
    module.walk([&](cal::NetworkOp net){ networks.push_back(net); });
    if (networks.empty()) return;

    MLIRContext *ctx = module.getContext();
    OpBuilder modBuilder(module.getBodyRegion());

    // Helper for locating/creating a fanout actor.
    auto getOrCreateFanoutActor = [&](Type elemType, unsigned numSinks) -> cal::ActorOp {
      // Build a symbol name encoding element type and sink count. We only use the element type mnemonic.
      std::string typeStr;
      { // crude stable type string
        llvm::raw_string_ostream os(typeStr);
        elemType.print(os);
      }
      // Sanitize type string to be symbol friendly (replace disallowed chars with '_').
      for (char &c : typeStr) {
        if (!(llvm::isAlnum(c) || c=='_')) c = '_';
      }
      std::string symName = "__fanout_" + typeStr + "_" + std::to_string(numSinks);
      if (auto existing = module.lookupSymbol<cal::ActorOp>(symName)) return existing;

    OpBuilder actorBuilder(module.getBodyRegion());
    auto loc = UnknownLoc::get(ctx);
    // Create actor with one input port and numSinks output ports.
    // Build with required attributes (symbol name; no port name attrs at build time).
    // Prepare explicit port names so downstream connect-by-name verification succeeds.
    SmallVector<Attribute> inNamesAttrs;
    inNamesAttrs.push_back(StringAttr::get(ctx, "in"));
    SmallVector<Attribute> outNamesAttrs;
    outNamesAttrs.reserve(numSinks);
    for (unsigned i = 0; i < numSinks; ++i) {
      outNamesAttrs.push_back(StringAttr::get(ctx, ("out" + std::to_string(i)).c_str()));
    }
    auto inNames = ArrayAttr::get(ctx, inNamesAttrs);
    auto outNames = ArrayAttr::get(ctx, outNamesAttrs);

    auto actor = actorBuilder.create<cal::ActorOp>(
      loc,
      actorBuilder.getStringAttr(symName), /*inPortNames*/ inNames,
      /*outPortNames*/ outNames, /*nonPreemptive*/ UnitAttr());
      // Construct entry block with ports.
      // Ports are region block arguments; pattern: [standard params][ports_in][ports_out]. We have only ports.
      Block &bodyBlock = actor.getBody().emplaceBlock();
      // Add the input port (fifo.output_port<T>) and N output ports (fifo.input_port<T>)
      auto outPortType = mlir::fifo::InputPortType::get(ctx, elemType);
      auto inPortType = mlir::fifo::OutputPortType::get(ctx, elemType);
      // ports_in first
      bodyBlock.addArgument(inPortType, loc);
      for (unsigned i=0;i<numSinks;++i) bodyBlock.addArgument(outPortType, loc);

      OpBuilder actionBuilder(&bodyBlock, bodyBlock.begin());
      // Create an action with no name/priority (optional attrs can be null).
      auto action = actionBuilder.create<cal::ActionOp>(loc, StringAttr(), IntegerAttr());
      Block &actionBlock = action.getBody().emplaceBlock();
      // Build inside the action's region.
      OpBuilder ab(&actionBlock, actionBlock.begin());
      // Inside action: pop from first block argument then push to all outputs.
      Value inPort = bodyBlock.getArgument(0);
      auto token = ab.create<fifo::Pop>(loc, elemType, inPort);
      // After creating token, push to each sink.
      for (unsigned i=0;i<numSinks;++i) {
        Value outPort = bodyBlock.getArgument(1 + i);
        // fifo.push has no results; operands: inputToken, inputPort
        ab.create<fifo::Push>(loc, token.getResult(), outPort);
      }
      return actor;
    };

    // Process each network.
    for (cal::NetworkOp net : networks) {
      // Collect connect ops grouped by (src value, srcPort attr).
      llvm::DenseMap<std::pair<Value,StringAttr>, SmallVector<cal::ConnectOp>> groups;
      net.walk([&](cal::ConnectOp c){
        Value src = c.getSrc();
        // Only consider scalar sources (no array indexing) to avoid grouping unrelated connects.
        if (!c.getSrcIndices().empty()) return;
        // Allow both instance handles and network ports as sources.
        if (!(mlir::isa<cal::InstanceType>(src.getType()) || mlir::isa<cal::InterfaceInstanceType>(src.getType()) ||
              mlir::isa<mlir::fifo::OutputPortType>(src.getType()))) return;
        groups[{src, c.getSrcPortAttr()}].push_back(c);
      });

      // Identify multi-sink groups.
      SmallVector<SmallVector<cal::ConnectOp>> multiSinkGroups;
      for (auto &kv : groups) {
        if (kv.second.size() > 1) multiSinkGroups.push_back(kv.second);
      }
      if (multiSinkGroups.empty()) continue;

  OpBuilder builder(net.getContext());
  builder.setInsertionPointToStart(&net.getBody().front());

      for (auto &connects : multiSinkGroups) {
        // All connects share same source & srcPort. Verify element types and collect sinks.
        Value src = connects.front().getSrc();
        StringAttr srcPort = connects.front().getSrcPortAttr();
        // Determine element type T for the channel carried by srcPort.
        auto inferElemType = [&](Value srcV, StringAttr sPort, Value dstV, StringAttr dPort) -> Type {
          // 1) If src is a network fifo output port, use its element type directly.
          if (auto opt = mlir::dyn_cast<mlir::fifo::OutputPortType>(srcV.getType()))
            return opt.getElementType();
          // 2) If src is an instance handle, look up its actor and match the named out port.
          if (auto instTy = mlir::dyn_cast<cal::InstanceType>(srcV.getType())) {
            if (auto actor = module.lookupSymbol<cal::ActorOp>(instTy.getActorRef().getValue())) {
              if (auto namesAttr = actor.getOutPortNamesAttr()) {
                SmallVector<Value> outArgs;
                for (Value arg : actor.getBody().front().getArguments())
                  if (mlir::isa<mlir::fifo::InputPortType>(arg.getType())) outArgs.push_back(arg);
                auto arr = namesAttr.getValue();
                for (auto en : llvm::enumerate(arr)) {
                  if (auto nameAttr = mlir::dyn_cast<StringAttr>(en.value())) {
                    if (nameAttr == sPort) {
                      if (en.index() < outArgs.size())
                        return mlir::cast<mlir::fifo::InputPortType>(outArgs[en.index()].getType()).getElementType();
                    }
                  }
                }
              }
            }
          }
          // 3) If dst is an instance handle/array, look up its actor and match the named in port.
          auto getActorFromDst = [&](Value v) -> cal::ActorOp {
            if (auto it = mlir::dyn_cast<cal::InstanceType>(v.getType()))
              return module.lookupSymbol<cal::ActorOp>(it.getActorRef().getValue());
            if (auto arr = mlir::dyn_cast<cal::InstanceArrayType>(v.getType()))
              return module.lookupSymbol<cal::ActorOp>(arr.getActorRef().getValue());
            return nullptr;
          };
          if (auto dstActor = getActorFromDst(dstV)) {
            if (auto inNames = dstActor.getInPortNamesAttr()) {
              SmallVector<Value> inArgs;
              for (Value arg : dstActor.getBody().front().getArguments())
                if (mlir::isa<mlir::fifo::OutputPortType>(arg.getType())) inArgs.push_back(arg);
              auto arr = inNames.getValue();
              for (auto en : llvm::enumerate(arr)) {
                if (auto nm = mlir::dyn_cast<StringAttr>(en.value())) {
                  if (nm == dPort) {
                    if (en.index() < inArgs.size())
                      return mlir::cast<mlir::fifo::OutputPortType>(inArgs[en.index()].getType()).getElementType();
                  }
                }
              }
            }
          }
          // 4) Fallback: if either side is already a concrete fifo port type.
          if (auto ipt = mlir::dyn_cast<mlir::fifo::InputPortType>(dstV.getType())) return ipt.getElementType();
          if (auto opt2 = mlir::dyn_cast<mlir::fifo::OutputPortType>(dstV.getType())) return opt2.getElementType();
          return Type();
        };

        Type elemType = Type();
        for (cal::ConnectOp c : connects) {
          elemType = inferElemType(src, srcPort, c.getDst(), c.getDstPortAttr());
          if (elemType) break;
        }
        if (!elemType) continue; // cannot resolve type; skip gracefully

        unsigned numSinks = connects.size();
        // Capacity aggregation.
        int64_t cap = -1;
        for (cal::ConnectOp c : connects) if (auto attr = c.getCapacityAttr()) { if (cap<0) cap = attr.getInt(); else cap = std::min<int64_t>(cap, attr.getInt()); }

        // Create fanout actor if needed.
        cal::ActorOp fanoutActor = getOrCreateFanoutActor(elemType, numSinks);

        // Instantiate fanout actor inside the network (symbolic instantiate -> instance handle for now).
        // We create an explicit instantiate op (pre-elaboration) then connections.
        // CRITICAL: choose an insertion point that (a) comes after the src definition and
        // (b) dominates all sink connects. If connects are spread across different blocks,
        // conservatively skip this group to avoid SSA dominance issues; a later pass can revisit.
        Operation *defOp = src.getDefiningOp();
        Block *defBlock = defOp ? defOp->getBlock() : &net.getBody().front();
        bool sameBlock = llvm::all_of(connects, [&](cal::ConnectOp c){ return c->getBlock() == defBlock; });
        if (!sameBlock) {
          // Skip groups that span multiple blocks; avoid introducing cross-block dominance bugs.
          continue;
        }
        // Find earliest connect in the defining block.
        Operation *anchor = connects.front();
        for (cal::ConnectOp c : connects) {
          if (c->getBlock() == defBlock && c->isBeforeInBlock(anchor)) anchor = c;
        }
        // Ensure we insert after the source definition if present.
        auto loc = anchor->getLoc();
        if (defOp && anchor->isBeforeInBlock(defOp)) {
          builder.setInsertionPointAfter(defOp);
        } else {
          builder.setInsertionPoint(anchor);
        }
  // Build a !cal.instance<@fan> handle result type for instantiate
  auto fanSymRef = FlatSymbolRefAttr::get(ctx, fanoutActor.getSymName());
  auto fanHandleTy = cal::InstanceType::get(ctx, fanSymRef);
  auto fanHandle = builder.create<cal::InstantiateOp>(loc, fanHandleTy, fanSymRef, /*instanceName*/ StringAttr(), /*params*/ ValueRange{});

        // Connect src -> fan.in (port name is "in") inserted before the earliest connect.
        StringAttr fanInName = StringAttr::get(ctx, "in");
        IntegerAttr capAttr = (cap >= 0) ? builder.getI64IntegerAttr(cap) : IntegerAttr();
        builder.create<cal::ConnectOp>(loc,
                                       /*src*/ src, /*srcIndices*/ ValueRange{}, srcPort,
                                       /*dst*/ fanHandle.getResult(), /*dstIndices*/ ValueRange{}, fanInName,
                                       capAttr);

        // Insert new fanout -> sink connects at each original connect location to satisfy dominance.
        SmallVector<cal::ConnectOp> toErase;
        for (auto it : llvm::enumerate(connects)) {
          cal::ConnectOp oldC = it.value();
          builder.setInsertionPoint(oldC);
          StringAttr fanOutName = StringAttr::get(ctx, ("out" + std::to_string(it.index())).c_str());
          builder.create<cal::ConnectOp>(oldC.getLoc(),
                                         /*src*/ fanHandle.getResult(), /*srcIdx*/ ValueRange{}, fanOutName,
                                         /*dst*/ oldC.getDst(), /*dstIdx*/ oldC.getDstIndices(), oldC.getDstPortAttr(),
                                         /*capacity*/ IntegerAttr());
          toErase.push_back(oldC);
        }
        for (cal::ConnectOp old : toErase) old.erase();
      }
    }
  }
};
} // namespace

std::unique_ptr<Pass> createInsertFanoutOnMultiSinkPass() {
  return std::make_unique<InsertFanoutOnMultiSinkPass>();
}
} // namespace mlir
