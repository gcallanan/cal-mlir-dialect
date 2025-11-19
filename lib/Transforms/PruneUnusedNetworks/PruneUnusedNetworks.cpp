//===- PruneUnusedNetworks.cpp - Reachability-based network pruning -*- C++ -*-===//
// This file is licensed under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//===----------------------------------------------------------------------===//

#include "mlir/IR/BuiltinOps.h"
#include "mlir/IR/SymbolTable.h"
#include "mlir/Pass/Pass.h"
#include "Transforms/Passes.h"
#include "Dialect/Cal/CalOps.h"
#include "mlir/IR/Diagnostics.h"

using namespace mlir;
using namespace mlir::cal;

namespace {
struct PruneUnusedNetworksPass : PassWrapper<PruneUnusedNetworksPass, OperationPass<ModuleOp>> {
  MLIR_DEFINE_EXPLICIT_INTERNAL_INLINE_TYPE_ID(PruneUnusedNetworksPass)
  StringRef getArgument() const final { return "prune-unused-networks"; }
  StringRef getDescription() const final { return "Prune cal.network symbols unreachable from designated top"; }

  // Command-line / pipeline options.
  Option<bool> emitStats{*this, "emit-stats", llvm::cl::desc("Emit pruning statistics"), llvm::cl::init(false)};
  Option<std::string> top{*this, "top", llvm::cl::desc("Explicit top network symbol name"), llvm::cl::init("")};
  
    // Custom copy constructor required because llvm::cl::opt (used by Option) is non-copyable.
    // Reinitialize the option with this pass instance and copy over the stored value.
    PruneUnusedNetworksPass() = default;
    PruneUnusedNetworksPass(const PruneUnusedNetworksPass &other)
        : PassWrapper(other) {
      emitStats = other.emitStats.getValue();
    }

  void runOnOperation() override {
    ModuleOp module = getOperation();

    // Collect all network symbols.
    SmallVector<NetworkOp, 16> networks;
    module.walk([&](NetworkOp net) { networks.push_back(net); });
    if (networks.empty()) return; // nothing to do

    // Determine top network symbol.
    NetworkOp topNet = nullptr;
    DenseSet<NetworkOp> topAttrNets;
    for (NetworkOp n : networks) {
      // Accept several attribute spellings for robustness.
      if (n->hasAttr("cal.top") || n->hasAttr("top")) topAttrNets.insert(n);
    }

    if (!top.empty()) {
      if (auto byName = module.lookupSymbol<NetworkOp>(top)) {
        topNet = byName;
      } else {
        module.emitError() << "prune-unused-networks: explicit top '" << top << "' not found";
        signalPassFailure();
        return;
      }
    } else if (topAttrNets.size() == 1) {
      topNet = *topAttrNets.begin();
    } else if (topAttrNets.empty()) {
      if (networks.size() == 1) {
        topNet = networks.front();
      } else {
        // Ambiguous; no explicit top specified, multiple networks present.
        // Skip pruning silently (could emit remark for clarity).
        return;
      }
    } else { // >1 top attrs
      module.emitError() << "prune-unused-networks: multiple networks marked as top; cannot decide unique root";
      signalPassFailure();
      return;
    }

    assert(topNet && "Top network must be set at this point");

    // BFS reachability over network instantiation edges.
    llvm::DenseSet<StringAttr> reachable; // symbol names
    SmallVector<NetworkOp, 8> worklist;
    reachable.insert(topNet.getSymNameAttr());
    worklist.push_back(topNet);

    auto enqueueIfNetwork = [&](FlatSymbolRefAttr refAttr) {
      if (!refAttr) return;
      if (auto target = module.lookupSymbol<NetworkOp>(refAttr.getValue())) {
        if (!reachable.contains(target.getSymNameAttr())) {
          reachable.insert(target.getSymNameAttr());
          worklist.push_back(target);
        }
      }
    };

    while (!worklist.empty()) {
      NetworkOp current = worklist.pop_back_val();
      // Scan body for create_instance referencing a network OR symbolic instantiate.
      current.walk([&](Operation *op) {
        if (auto ci = dyn_cast<CreateInstanceOp>(op)) {
          enqueueIfNetwork(ci.getActorRefAttr());
        } else if (auto inst = dyn_cast<InstantiateOp>(op)) {
          enqueueIfNetwork(inst.getActorRefAttr());
        }
      });
    }

    // Identify prune candidates: networks not in reachable set and not the top.
    SmallVector<Operation *, 16> toErase;
    for (NetworkOp n : networks) {
      if (reachable.contains(n.getSymNameAttr())) continue; // keep
      // Defensive: ensure no remaining instantiate op references this network.
      bool referenced = false;
      module.walk([&](InstantiateOp inst) {
        if (inst.getActorRefAttr().getValue() == n.getSymName()) referenced = true; });
      module.walk([&](CreateInstanceOp ci) {
        if (ci.getActorRefAttr().getValue() == n.getSymName()) referenced = true; });
      if (referenced) {
        if (emitStats)
          n.emitRemark() << "prune-unused-networks: retaining network '" << n.getSymName() << "' still referenced symbolically";
        continue;
      }
      toErase.push_back(n.getOperation());
    }

    for (Operation *op : toErase) op->erase();

    if (emitStats) {
      unsigned kept = reachable.size();
      unsigned pruned = toErase.size();
      topNet.emitRemark() << "prune-unused-networks: kept=" << kept << " pruned=" << pruned; 
    }
  }
};
} // namespace

namespace mlir {
std::unique_ptr<Pass> createPruneUnusedNetworksPass() {
  return std::make_unique<PruneUnusedNetworksPass>();
}
} // namespace mlir