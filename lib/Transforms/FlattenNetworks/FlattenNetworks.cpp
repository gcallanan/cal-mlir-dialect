//===- FlattenNetworks.cpp - Flatten hierarchical cal.networks ------------===//
// NOTE(diag): Edited on pass-fix to verify rebuild picks up this line.
// This file is licensed under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//===----------------------------------------------------------------------===//

#include "Dialect/Cal/CalDialect.h"
#include "Dialect/Cal/CalOps.h"
#include "mlir/IR/PatternMatch.h"
#include "mlir/IR/SymbolTable.h"
#include "mlir/IR/IRMapping.h"
#include "mlir/Pass/Pass.h"

#include "Transforms/FlattenNetworks/FlattenNetworks.h"
#include "Transforms/Passes.h"

using namespace mlir;
using namespace mlir::cal;

namespace mlir {

#define GEN_PASS_DEF_FLATTENCALNETWORKSPASS
#include "Transforms/Passes.h.inc"

namespace {
class FlattenCalNetworksPass
    : public impl::FlattenCalNetworksPassBase<FlattenCalNetworksPass> {
public:
  using Base = impl::FlattenCalNetworksPassBase<FlattenCalNetworksPass>;
  FlattenCalNetworksPass() = default;
  FlattenCalNetworksPass(const FlattenCalNetworksPass &other) = default;
  // Constructor required by generated createFlattenCalNetworksPass(options) (correct non-impl qualified options type)
  explicit FlattenCalNetworksPass(FlattenCalNetworksPassOptions options)
    : Base(std::move(options)) {}
  void runOnOperation() override {
    ModuleOp module = getOperation();
    SymbolTableCollection symbolTable;
    // Statistics (conditionally reported when emitStats option is set)
    uint64_t statFlattenedInstances = 0;
    uint64_t statPrunedNetworks = 0;
    uint64_t statIterations = 0;

    // 1. Build StringAttr-based call graph of network -> referenced networks.
    DenseMap<StringAttr, SmallVector<StringAttr>> adjacency;
    DenseMap<StringAttr, NetworkOp> nameToOp;
    module.walk([&](NetworkOp net) {
      nameToOp[StringAttr::get(net.getContext(), net.getSymName())] = net;
    });
    module.walk([&](CreateInstanceOp inst) {
      if (auto target = symbolTable.lookupNearestSymbolFrom<NetworkOp>(
              inst, inst.getActorRefAttr())) {
        if (auto parentNet = dyn_cast_or_null<NetworkOp>(inst->getParentOp())) {
          auto parentName = StringAttr::get(parentNet.getContext(), parentNet.getSymName());
          auto childName = StringAttr::get(target.getContext(), target.getSymName());
            adjacency[parentName].push_back(childName);
        }
      }
    });

    // 2. Detect cycles via DFS.
    enum class VisitState { NotVisited, Visiting, Visited };
    DenseMap<StringAttr, VisitState> visit;
    SmallVector<StringAttr> stack;
    bool cycleFound = false;
    std::function<void(StringAttr)> dfs = [&](StringAttr cur) {
      if (cycleFound)
        return;
      VisitState &st = visit[cur];
      if (st == VisitState::Visiting) {
        // produce cycle path from first occurrence
        auto it = llvm::find(stack, cur);
        std::string msg = "cycle detected in cal.network hierarchy: [";
        bool first = true;
        for (auto cycIt = it; cycIt != stack.end(); ++cycIt) {
          if (!first) msg += " -> ";
          msg += cycIt->str();
          first = false;
        }
        msg += " -> ";
        msg += cur.str();
        msg += "]";
        if (auto it2 = nameToOp.find(cur); it2 != nameToOp.end())
          it2->second.emitOpError(msg);
        else
          module.emitError(msg);
        cycleFound = true;
        return;
      }
      if (st == VisitState::Visited)
        return;
      st = VisitState::Visiting;
      stack.push_back(cur);
      for (auto child : adjacency[cur])
        dfs(child);
      stack.pop_back();
      st = VisitState::Visited;
    };
    for (auto &kv : nameToOp) {
      if (visit[kv.first] == VisitState::NotVisited)
        dfs(kv.first);
      if (cycleFound) {
        signalPassFailure();
        return; // abort flattening
      }
    }

    // 3. Perform iterative flattening once confirmed acyclic.
    bool changed = true;
    unsigned iteration = 0;
    // Soft limit: if we iterate more than (number_of_networks * 8) we likely
    // missed a cyclic pattern (e.g. dynamic pattern not in initial static graph).
    unsigned softLimit = std::max<unsigned>(nameToOp.size() * 8, 32);
    while (changed) {
      changed = false;
      if (++iteration > softLimit) {
        module.emitError("flatten-cal-networks exceeded iteration limit (" +
                         Twine(softLimit) +
                         ") – possible undetected network cycle");
        signalPassFailure();
        return;
      }
      statIterations = iteration;

      // Collect all network instances to inline this iteration.
      SmallVector<CreateInstanceOp> networkInstances;
      module.walk([&](CreateInstanceOp inst) {
        if (symbolTable.lookupNearestSymbolFrom<NetworkOp>(inst, inst.getActorRefAttr()))
          networkInstances.push_back(inst);
      });
      if (networkInstances.empty())
        break; // Nothing left to flatten.

      // Deterministic ordering: sort by referenced symbol name (and insertion order fallback via pointer address).
      llvm::sort(networkInstances, [](CreateInstanceOp a, CreateInstanceOp b) {
        auto an = a.getActorRefAttr().getRootReference().getValue();
        auto bn = b.getActorRefAttr().getRootReference().getValue();
        if (an == bn)
          return a.getOperation() < b.getOperation();
        return an < bn;
      });

      for (CreateInstanceOp inst : networkInstances) {
        auto target = symbolTable.lookupNearestSymbolFrom<NetworkOp>(
            inst, inst.getActorRefAttr());
        if (!target)
          continue; // Not a network.
        auto parentNetwork = dyn_cast<NetworkOp>(inst->getParentOp());
        if (!parentNetwork)
          continue; // Only flatten inside networks.

        // Guard against self-recursive instantiation which indicates a cycle
        // missed by earlier static detection (should be very rare).
        if (target == parentNetwork) {
          inst.emitOpError(
              "self-recursive network instantiation detected (cycle)");
          signalPassFailure();
          return;
        }

        // Map operands to formal arguments.
        IRMapping mapping;
        auto operands = inst.getOperands();
        auto formalArgs = target.getBody().getArguments();
        if (operands.size() != formalArgs.size()) {
          inst.emitOpError(
              "cannot inline network: operand/formal arity mismatch after prior verification");
          signalPassFailure();
          return;
        }
        for (auto it : llvm::zip(formalArgs, operands))
          mapping.map(std::get<0>(it), std::get<1>(it));

        // Clone the target body operations (skip nested networks/actors)
        Block &targetBody = target.getBody().front();
        OpBuilder builder(inst);
        for (Operation &op : targetBody.getOperations()) {
          if (isa<NetworkOp>(op) || isa<ActorOp>(op))
            continue;
          builder.clone(op, mapping);
        }
        inst.erase();
        changed = true;
        ++statFlattenedInstances;
      }
    }

    // 4. Dead network pruning (unless disabled by option)
    if (!disablePruning) {
      llvm::SmallDenseSet<StringAttr, 16> referenced;
      module.walk([&](CreateInstanceOp inst) {
        if (symbolTable.lookupNearestSymbolFrom<NetworkOp>(inst, inst.getActorRefAttr()))
          referenced.insert(StringAttr::get(module.getContext(),
                                            inst.getActorRefAttr().getRootReference().getValue()));
      });
      SmallVector<NetworkOp> toErase;
      module.walk([&](NetworkOp net) {
        auto name = StringAttr::get(net.getContext(), net.getSymName());
        if (!referenced.contains(name)) {
          bool hasActorInstance = false;
          net.walk([&](CreateInstanceOp ci) {
            if (symbolTable.lookupNearestSymbolFrom<ActorOp>(ci, ci.getActorRefAttr()))
              hasActorInstance = true;
          });
          if (!hasActorInstance)
            toErase.push_back(net);
        }
      });
      statPrunedNetworks = toErase.size();
      for (auto n : toErase)
        n.erase();
    }

    if (emitStats) {
      module.emitRemark() << "flatten-cal-networks stats: iterations=" << statIterations
                          << ", flattened_instances=" << statFlattenedInstances
                          << ", pruned_networks=" << statPrunedNetworks
                          << (disablePruning ? " (pruning disabled)" : "");
    }
  }
};
} // namespace

// Factory is generated by TableGen; registering the pass class above is enough.
// (No out-of-line factory definition to avoid duplicate symbol.)

} // namespace mlir
