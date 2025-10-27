//===- FlattenNetworks.cpp - Flatten hierarchical cal.networks ------------===//
// NOTE(diag): Edited on pass-fix to verify rebuild picks up this line.
// This file is licensed under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//===----------------------------------------------------------------------===//

#include "Dialect/Cal/CalDialect.h"
#include "Dialect/Cal/CalOps.h"
#include "Dialect/Fifo/FifoOps.h"
#include "Dialect/Fifo/FifoTypes.h"
#include "mlir/Dialect/Arith/IR/Arith.h"
#include "mlir/IR/SymbolTable.h"
#include "mlir/IR/IRMapping.h"
#include "mlir/Pass/Pass.h"
// STL
#include <algorithm>
#include <climits>
#include <numeric>

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

    // 3. Elaborate symbolic network ops inside each cal.network into
    //    concrete fifo.create + cal.create_instance wiring, so the subsequent
    //    flattening only needs to inline nested networks. This step replaces
    //    the following ops within network bodies:
    //      - cal.instantiate            -> materialized via cal.create_instance
    //      - cal.instantiate_array      -> expanded to N create_instance ops
    //      - cal.instance_at            -> resolved to a specific instance
    //      - cal.connect                -> fifo.create + operand threading
    //    Current limitation: instance_at indices must be constant. Dynamic
    //    indices will cause a pass failure with a diagnostic.

    auto suggestClosest = [&](StringRef input, ArrayRef<StringRef> choices) -> std::string {
      // Simple Levenshtein distance (bounded) for small sets; fallback to prefix match.
      auto dist = [](StringRef a, StringRef b) -> unsigned {
        SmallVector<unsigned> prev(b.size() + 1), cur(b.size() + 1);
        std::iota(prev.begin(), prev.end(), 0u);
        for (size_t i = 1; i <= a.size(); ++i) {
          cur[0] = i;
          for (size_t j = 1; j <= b.size(); ++j) {
            unsigned cost = (a[i - 1] == b[j - 1]) ? 0u : 1u;
            cur[j] = std::min({prev[j] + 1, cur[j - 1] + 1, prev[j - 1] + cost});
          }
          std::swap(prev, cur);
        }
        return prev.back();
      };
      unsigned bestD = UINT_MAX; StringRef best;
      for (auto c : choices) {
        unsigned d = dist(input, c);
        if (d < bestD) { bestD = d; best = c; }
      }
      if (!best.empty() && bestD <= 2)
        return (" Did you mean '" + best.str() + "'? ");
      return std::string();
    };

    auto parsePortIndex = [&](StringRef name, unsigned max, bool isDst /*true=in, false=out*/, ArrayAttr declaredNames)
                              -> FailureOr<unsigned> {
      // Accepted forms:
      //  - Ordinals: "in<idx>" / "out<idx>" with 0-based index.
      //  - Group alias: "in" / "out" when there is exactly one port in that group AND no declared names.
      //  - Declared names: any string present in the actor's inPortNames/outPortNames ArrayAttr.
      StringRef prefix = isDst ? StringRef("in") : StringRef("out");

      // 1) Ordinal or alias forms starting with the group prefix.
      if (name.starts_with(prefix)) {
        StringRef tail = name.drop_front(prefix.size());
        if (tail.empty()) {
          // Only accept generic alias ("in"/"out") for single-port groups when there are no declared names.
          if (max == 1 && (!declaredNames || declaredNames.empty()))
            return 0u; // single-port alias permitted (no declared names to conflict)
          // Otherwise, treat as ambiguous/disallowed; fall through.
        } else {
          unsigned idx = 0;
          if (!tail.getAsInteger(10, idx) && idx < max)
            return idx;
        }
        // Fall through to declared-name matching for non-matching ordinal/alias.
      }

      // 2) Declared symbolic names.
      if (declaredNames) {
        unsigned i = 0;
        for (Attribute a : declaredNames) {
          if (auto s = dyn_cast<StringAttr>(a)) {
            if (s.getValue() == name)
              return i;
          }
          ++i;
        }
      }

      // 3) As a final convenience, accept the group alias for single-port groups even
      // if it wasn't written with the prefix — but only when there are no declared names.
      if (max == 1 && (!declaredNames || declaredNames.empty()) && (name == (isDst ? "in" : "out")))
        return 0u;

      return failure();
    };

    auto elaborateNetwork = [&](NetworkOp net) -> LogicalResult {
      Block &body = net.getBody().front();
      MLIRContext *ctx = net.getContext();
      OpBuilder builder(ctx);

      // Plans for instances (single) and arrays.
      struct InstPlan {
        ActorOp actor;
        SmallVector<Value> params;
        SmallVector<Value> inPorts;  // fifo.output_port<elem>
        SmallVector<Value> outPorts; // fifo.input_port<elem>
        StringAttr name;             // optional instance name
        Operation *defOp = nullptr;  // instantiate/instantiate_array
      };

      // For arrays, map defining value to vector of element plans.
      DenseMap<Value, SmallVector<std::unique_ptr<InstPlan>>> arrayPlans;
      // For single handles, map value to plan.
      DenseMap<Value, std::unique_ptr<InstPlan>> singlePlans;

      // Collect instantiate ops to create plans and determine port counts.
      SmallVector<Operation*> connectOps;
      // Also collect instance_at for index resolution checks.
      SmallVector<InstanceAtOp> instanceAtOps;

      for (Operation &op : llvm::make_early_inc_range(body.getOperations())) {
        if (auto inst = dyn_cast<InstantiateOp>(&op)) {
          ActorOp actor = symbolTable.lookupNearestSymbolFrom<ActorOp>(&op, inst.getActorRefAttr());
          if (!actor)
            return op.emitOpError("instantiate references unknown cal.actor");
          auto plan = std::make_unique<InstPlan>();
          plan->actor = actor;
          plan->defOp = &op;
          plan->name = inst.getInstanceNameAttr();
          plan->params.assign(inst.getParams().begin(), inst.getParams().end());
          plan->inPorts.resize(actor.inDegree());
          plan->outPorts.resize(actor.outDegree());
          singlePlans[inst.getHandle()] = std::move(plan);
          continue;
        }
        if (auto arr = dyn_cast<InstantiateArrayOp>(&op)) {
          ActorOp actor = symbolTable.lookupNearestSymbolFrom<ActorOp>(&op, arr.getActorRefAttr());
          if (!actor)
            return op.emitOpError("instantiate_array references unknown cal.actor");
          unsigned count = 0;
          if (auto arrTy = dyn_cast_if_present<InstanceArrayType>(arr.getHandlesArray().getType()))
            count = static_cast<unsigned>(arrTy.getCount());
          else
            count = static_cast<unsigned>(arr.getCount());
          SmallVector<std::unique_ptr<InstPlan>> plans;
          plans.reserve(count);
          for (unsigned i = 0; i < count; ++i) {
            auto plan = std::make_unique<InstPlan>();
            plan->actor = actor;
            plan->defOp = &op;
            if (auto base = arr.getBaseNameAttr()) {
              std::string n = (base.getValue() + StringRef("[") + Twine(i).str() + "]").str();
              plan->name = StringAttr::get(ctx, n);
            }
            plan->params.assign(arr.getParams().begin(), arr.getParams().end());
            plan->inPorts.resize(actor.inDegree());
            plan->outPorts.resize(actor.outDegree());
            plans.push_back(std::move(plan));
          }
          arrayPlans[arr.getHandlesArray()] = std::move(plans);
          continue;
        }
        if (auto at = dyn_cast<InstanceAtOp>(&op)) {
          instanceAtOps.push_back(at);
          continue;
        }
        if (isa<ConnectOp>(&op)) {
          connectOps.push_back(&op);
          continue;
        }
      }

      // Resolve instance_at indices; optionally allow dynamic indices to be skipped.
      DenseMap<Value, InstPlan*> handleToPlan;
      for (auto &it : singlePlans)
        handleToPlan[it.first] = it.second.get();
      for (auto &kv : arrayPlans) {
        Value arrVal = kv.first;
        auto &vec = kv.second;
        for (Operation *user : arrVal.getUsers()) {
          if (auto at = dyn_cast<InstanceAtOp>(user)) {
            auto c = at.getIndex().getDefiningOp<arith::ConstantOp>();
            if (!c) {
              if (!allowDynamicIndices) {
                at.emitOpError("dynamic index not supported in elaboration; pass --allow-dynamic-indices to skip materialization and defer to later passes");
                return failure();
              } else {
                at.emitRemark("skipping dynamic index during elaboration; leaving symbolic ops intact");
                continue;
              }
            }
            auto intAttr = dyn_cast<IntegerAttr>(c.getValueAttr());
            if (!intAttr) {
              at.emitOpError("unsupported index attribute");
              return failure();
            }
            int64_t idx = intAttr.getInt();
            if (idx < 0 || static_cast<unsigned>(idx) >= vec.size()) {
              at.emitOpError("index out of bounds for instance array");
              return failure();
            }
            handleToPlan[at.getHandle()] = vec[static_cast<unsigned>(idx)].get();
          }
        }
      }

      // Process connects in two phases: collect edges, then materialize depending on
      // fully-wired instances and options.
      struct PendingEdge {
        ConnectOp conn;
        InstPlan *srcPlan;
        InstPlan *dstPlan;
        unsigned srcOutIdx;
        unsigned dstInIdx;
        Type elemTy;
      };
      SmallVector<PendingEdge> edges;
      SmallVector<Operation*> toErase;

      // Per-plan connectivity trackers to detect duplicates and completeness.
      DenseMap<InstPlan*, SmallVector<bool>> seenOut, seenIn;

      auto ensureTrackers = [&](InstPlan *p) {
        if (!seenOut.count(p)) seenOut[p] = SmallVector<bool>(p->outPorts.size(), false);
        if (!seenIn.count(p))  seenIn[p]  = SmallVector<bool>(p->inPorts.size(),  false);
      };

      for (Operation *op : connectOps) {
        auto conn = cast<ConnectOp>(op);
        // Canonicalizer may have already lowered sugar; ensure indices are resolved.
        if (conn.getSrcIndex() || conn.getDstIndex()) {
          conn.emitOpError("array-index connect form not fully canonicalized; run -canonicalize first");
          return failure();
        }
        InstPlan *srcPlan = handleToPlan.lookup(conn.getSrc());
        InstPlan *dstPlan = handleToPlan.lookup(conn.getDst());
        if (!srcPlan || !dstPlan) {
          if (allowDynamicIndices) {
            conn.emitRemark("skipping connect with unresolved dynamic handle during elaboration");
            continue;
          }
          return conn.emitOpError("unable to resolve instance handle to plan; missing cal.instantiate or cal.instance_at");
        }

        ActorOp srcActor = srcPlan->actor;
        ActorOp dstActor = dstPlan->actor;
        unsigned outCount = static_cast<unsigned>(srcActor.outDegree());
        unsigned inCount = static_cast<unsigned>(dstActor.inDegree());
        // Retrieve declared port names if present on the actors.
        ArrayAttr srcDeclared = srcActor->getAttrOfType<ArrayAttr>("outPortNames");
        ArrayAttr dstDeclared = dstActor->getAttrOfType<ArrayAttr>("inPortNames");
        FailureOr<unsigned> srcOutIdx = parsePortIndex(conn.getSrcPortAttr().getValue(), outCount, /*isDst=*/false, srcDeclared);
        FailureOr<unsigned> dstInIdx  = parsePortIndex(conn.getDstPortAttr().getValue(),  inCount,  /*isDst=*/true,  dstDeclared);
        if (failed(srcOutIdx)) {
          SmallVector<StringRef> choices; choices.reserve(outCount + (srcDeclared ? srcDeclared.size() : 0));
          for (unsigned i = 0; i < outCount; ++i)
            choices.push_back(StringRef((Twine("out") + Twine(i)).str()));
          if (srcDeclared)
            for (Attribute a : srcDeclared)
              if (auto s = dyn_cast<StringAttr>(a)) choices.push_back(s.getValue());
          std::string hint = suggestClosest(conn.getSrcPortAttr().getValue(), choices);
          auto err = conn.emitOpError("cannot resolve source port '") << conn.getSrcPortAttr().getValue() << "'";
          bool hasDeclared = srcDeclared && !srcDeclared.empty();
          if (hasDeclared)
            err << " (expected 'out<idx>' or one of declared names: ";
          else
            err << " (expected 'out'/'out<idx>'";
          if (hasDeclared) {
            bool first = true;
            for (Attribute a : srcDeclared) if (auto s = dyn_cast<StringAttr>(a)) {
              if (!first) err << ", "; first = false; err << "'" << s.getValue() << "'";
            }
          }
          err << ")" << hint;
          return err;
        }
        if (failed(dstInIdx)) {
          SmallVector<StringRef> choices; choices.reserve(inCount + (dstDeclared ? dstDeclared.size() : 0));
          for (unsigned i = 0; i < inCount; ++i)
            choices.push_back(StringRef((Twine("in") + Twine(i)).str()));
          if (dstDeclared)
            for (Attribute a : dstDeclared)
              if (auto s = dyn_cast<StringAttr>(a)) choices.push_back(s.getValue());
          std::string hint = suggestClosest(conn.getDstPortAttr().getValue(), choices);
          auto err = conn.emitOpError("cannot resolve destination port '") << conn.getDstPortAttr().getValue() << "'";
          bool hasDeclared = dstDeclared && !dstDeclared.empty();
          if (hasDeclared)
            err << " (expected 'in<idx>' or one of declared names: ";
          else
            err << " (expected 'in'/'in<idx>'";
          if (hasDeclared) {
            bool first = true;
            for (Attribute a : dstDeclared) if (auto s = dyn_cast<StringAttr>(a)) {
              if (!first) err << ", "; first = false; err << "'" << s.getValue() << "'";
            }
          }
          err << ")" << hint;
          return err;
        }

        // Retrieve element type for channel based on actor formal arg types.
        Block &abody = srcActor.getBody().front();
        SmallVector<Type> formals;
        for (Value a : abody.getArguments()) formals.push_back(a.getType());
        unsigned numParamsSrc = 0, numInSrc = 0;
        for (Type t : formals) {
          if (isa<fifo::OutputPortType>(t)) ++numInSrc;
          else if (isa<fifo::InputPortType>(t)) {/* count only */}
          else ++numParamsSrc;
        }
        unsigned portsOutStart = numParamsSrc + numInSrc;
        auto fifoInTy = dyn_cast<fifo::InputPortType>(formals[portsOutStart + *srcOutIdx]);
        if (!fifoInTy)
          return conn.emitOpError("internal error resolving source port type");
        Type elemTy = fifoInTy.getElementType();

        // Track duplicate port connections early.
        ensureTrackers(srcPlan);
        ensureTrackers(dstPlan);
        if (seenOut[srcPlan][*srcOutIdx])
          return conn.emitOpError("source port already connected");
        if (seenIn[dstPlan][*dstInIdx])
          return conn.emitOpError("destination port already connected");
        seenOut[srcPlan][*srcOutIdx] = true;
        seenIn[dstPlan][*dstInIdx] = true;

        edges.push_back(PendingEdge{conn, srcPlan, dstPlan, *srcOutIdx, *dstInIdx, elemTy});
      }

      // Determine fully-wired plans.
      DenseSet<InstPlan*> fullyWired;
      auto isFullyWired = [&](InstPlan *p) -> bool {
        // All in/out ports must be seen exactly once.
        auto itOut = seenOut.find(p);
        auto itIn = seenIn.find(p);
        if (itOut == seenOut.end() || itIn == seenIn.end()) return false;
        if (itOut->second.size() != p->outPorts.size() || itIn->second.size() != p->inPorts.size())
          return false; // size mismatch shouldn't happen
        return llvm::all_of(itOut->second, [](bool v){return v;}) &&
               llvm::all_of(itIn->second,  [](bool v){return v;});
      };
      for (auto &kv : singlePlans)
        if (isFullyWired(kv.second.get())) fullyWired.insert(kv.second.get());
      for (auto &kv : arrayPlans)
        for (auto &ptr : kv.second)
          if (isFullyWired(ptr.get())) fullyWired.insert(ptr.get());

  if (!allowPartialConnectivity && !allowDynamicIndices) {
        // In strict mode, require all plans to be fully wired.
        for (auto &kv : singlePlans)
          if (!fullyWired.contains(kv.second.get()))
            return kv.second->defOp->emitOpError("not all ports connected for instance; connect all ports before elaboration");
        for (auto &kv : arrayPlans)
          for (auto &ptr : kv.second)
            if (!fullyWired.contains(ptr.get()))
              return ptr->defOp->emitOpError("not all ports connected for instance in array; connect all ports before elaboration");
      }

      // Materialize only edges where both endpoints will be materialized.
      for (auto &e : edges) {
        bool useEdge = fullyWired.contains(e.srcPlan) && fullyWired.contains(e.dstPlan);
        if (!useEdge) continue;
        builder.setInsertionPoint(e.conn);
        uint64_t capVal = e.conn.getCapacityAttr() ? static_cast<uint64_t>(e.conn.getCapacityAttr().getInt()) : 1u;
        Type inPortTy = fifo::InputPortType::get(ctx, e.elemTy);
        Type outPortTy = fifo::OutputPortType::get(ctx, e.elemTy);
        auto create = builder.create<fifo::CreateOp>(e.conn.getLoc(), TypeRange{inPortTy, outPortTy}, e.elemTy, capVal);
        e.srcPlan->outPorts[e.srcOutIdx] = create.getInputPort();
        e.dstPlan->inPorts[e.dstInIdx] = create.getOutputPort();
        toErase.push_back(e.conn);
      }

      // Create cal.create_instance ops for each plan (optionally partial-only when flagged).
  auto materializeInstance = [&](InstPlan &plan) -> FailureOr<CreateInstanceOp> {
        // Ensure all ports are connected.
        for (unsigned i = 0, e = plan.inPorts.size(); i < e; ++i)
          if (!plan.inPorts[i])
            return failure();
        for (unsigned i = 0, e = plan.outPorts.size(); i < e; ++i)
          if (!plan.outPorts[i])
            return failure();

        SmallVector<Value> all;
        all.reserve(plan.params.size() + plan.inPorts.size() + plan.outPorts.size());
        all.append(plan.params);
        all.append(plan.inPorts);
        all.append(plan.outPorts);
  // Insert after all fifo.create ops to ensure dominance of operands.
  builder.setInsertionPointToEnd(&body);
  auto inst = builder.create<CreateInstanceOp>(plan.defOp->getLoc(), plan.actor.getSymNameAttr(), plan.name, all);
        return inst;
      };

      SmallVector<Operation*> defsToErase;
      for (auto &it : singlePlans) {
        if (fullyWired.contains(it.second.get())) {
          if (failed(materializeInstance(*it.second)))
            return it.second->defOp->emitOpError("internal error: expected fully-wired instance to materialize");
          defsToErase.push_back(it.second->defOp);
  } else if (allowPartialConnectivity) {
          it.second->defOp->emitRemark("skipping materialization of partially-connected instance");
        } else {
          // Strict mode already errored above.
        }
      }
      for (auto &kv : arrayPlans) {
        bool allMat = true;
        for (auto &ptr : kv.second) {
          if (fullyWired.contains(ptr.get())) {
            if (failed(materializeInstance(*ptr)))
              return ptr->defOp->emitOpError("internal error: expected fully-wired instance to materialize (array)");
          } else {
            allMat = false;
            if (allowPartialConnectivity)
              ptr->defOp->emitRemark("skipping materialization of partially-connected instance in array");
          }
        }
        if (allMat)
          defsToErase.push_back(kv.first.getDefiningOp());
      }

      // Erase symbolic ops: remove only connects we elaborated and defs we replaced.
      for (Operation *op : toErase)
        op->erase();
      for (InstanceAtOp at : instanceAtOps)
        if (at.use_empty()) at.erase();
      for (Operation *op : defsToErase)
        if (op && op->use_empty()) op->erase();

      return success();
    };

    // Elaborate all networks. Abort on first failure.
    for (NetworkOp net : llvm::make_early_inc_range(module.getOps<NetworkOp>())) {
      if (failed(elaborateNetwork(net))) {
        signalPassFailure();
        return;
      }
    }

    // 4. Perform iterative flattening once confirmed acyclic.
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

  // 5. Dead network pruning (unless disabled by option)
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
          bool hasSymbolicOps = false;
          net.walk([&](CreateInstanceOp ci) {
            if (symbolTable.lookupNearestSymbolFrom<ActorOp>(ci, ci.getActorRefAttr()))
              hasActorInstance = true;
          });
          // When dynamic indices are allowed, preserve networks with unresolved symbolic operations
          if (allowDynamicIndices) {
            net.walk([&](Operation *op) {
              if (isa<InstantiateOp, InstantiateArrayOp, ConnectOp, InstanceAtOp>(op))
                hasSymbolicOps = true;
            });
          }
          if (!hasActorInstance && !hasSymbolicOps)
            toErase.push_back(net);
        }
      });
      statPrunedNetworks = toErase.size();
      for (auto n : toErase)
        n.erase();
    }

    // 6. Optional aggressive pruning: keep only the designated top network.
    // If the 'top' option is provided (non-empty), erase all cal.network
    // symbols whose name does not match. This is stronger than the default
    // dead network pruning above and is intended for users who want to
    // retain exactly one (top) network definition in the module after
    // flattening.
    if (!top.empty()) {
      SmallVector<NetworkOp> eraseOthers;
      module.walk([&](NetworkOp net) {
        if (net.getSymName() != top)
          eraseOthers.push_back(net);
      });
      // Update stats if enabled.
      if (emitStats)
        statPrunedNetworks += eraseOthers.size();
      for (auto n : eraseOthers)
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
