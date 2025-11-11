//===- FlattenNetworks.cpp - Flatten hierarchical cal.networks ------------===//
// This file is licensed under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//===----------------------------------------------------------------------===//

#include "Dialect/Cal/CalDialect.h"
#include "Dialect/Cal/CalOps.h"
#include "Dialect/Cal/CalTypes.h"
#include "Dialect/Fifo/FifoOps.h"
#include "Dialect/Fifo/FifoTypes.h"
#include "mlir/Dialect/Arith/IR/Arith.h"
#include "mlir/IR/IRMapping.h"
#include "mlir/IR/SymbolTable.h"
#include "mlir/Pass/Pass.h"
#include "mlir/Dialect/SCF/IR/SCF.h" // Needed for dependent dialect registration in Passes.td
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
    // Compatibility shim: Users sometimes pass comma-separated options inside
    // the pass braces, e.g. `{top=Foo,emit-stats=true}`. MLIR's pass pipeline
    // grammar expects space-separated options inside braces. If we detect a
    // comma in the 'top' option value (a common failure mode where the entire
    // string gets parsed into 'top'), split and re-parse here to set the
    // corresponding flags and clean up 'top'. Emit a gentle remark to steer
    // users toward the space-separated form.
    if (!top.empty()) {
      StringRef topRef(top);
      if (topRef.contains(',')) {
        SmallVector<StringRef, 4> parts;
        topRef.split(parts, ',');
        std::string newTop;
        auto parseBool = [](StringRef v) -> std::optional<bool> {
          StringRef t = v.trim();
          if (t.empty()) return true; // flag form treated as true
          if (t.equals_insensitive("true") || t == "1") return true;
          if (t.equals_insensitive("false") || t == "0") return false;
          return std::nullopt;
        };
        auto parseKV = [&](StringRef kv) {
          StringRef k = kv, v;
          size_t eq = kv.find('=');
          if (eq != StringRef::npos) {
            k = kv.take_front(eq);
            v = kv.drop_front(eq + 1);
          }
          k = k.trim(); v = v.trim();
          if (k.empty()) return;
          if (k == "top") {
            if (!v.empty()) newTop = v.str();
            return;
          }
          if (k == "emit-stats") {
            auto b = parseBool(v); emitStats = b ? *b : true; return;
          }
          if (k == "disable-pruning") {
            auto b = parseBool(v); disablePruning = b ? *b : true; return;
          }
          if (k == "allow-partial-connectivity") {
            auto b = parseBool(v); allowPartialConnectivity = b ? *b : true; return;
          }
          if (k == "allow-dynamic-indices") {
            auto b = parseBool(v); allowDynamicIndices = b ? *b : true; return;
          }

          // Unknown key: ignore silently.
        };
        if (!parts.empty()) {
          // First piece may be "Foo" (bare top value) or a k=v pair.
          if (parts[0].contains('=')) parseKV(parts[0]);
          else newTop = parts[0].trim().str();
          for (size_t i = 1; i < parts.size(); ++i)
            parseKV(parts[i]);
          if (!newTop.empty()) top = newTop;
          module.emitRemark() << "flatten-cal-networks: parsed comma-separated options inside braces; prefer space-separated form (e.g., {top=Foo emit-stats})";
        }
      }
    }
    // Precompute interface conformance map: entity -> set of interfaces it implements.
    // Store by StringRef for lightweight lookups using symbol names from ops.
    DenseMap<StringRef, SmallVector<StringRef>> entityImplements;
    module.walk([&](cal::ImplementsOp impl){
      auto iface = impl.getIfaceRefAttr().getRootReference().getValue();
      auto ent = impl.getEntityRefAttr().getRootReference().getValue();
      entityImplements[ent].push_back(iface);
    });
  // Statistics (conditionally reported when emitStats option is set)
  uint64_t statFlattenedInstances = 0;
  uint64_t statPrunedNetworks = 0;
  uint64_t statIterations = 0;
  // Additional diagnostics for skipped materialization/edges (reported when emitStats is set)
  uint64_t statSkippedConnectDynamicIndex = 0;      // connects skipped due to dynamic indices when allowed
  uint64_t statSkippedConnectUnresolved = 0;        // connects skipped due to unresolved endpoints when allowed
  uint64_t statSkippedConnectInterfaceTyped = 0;    // connects skipped due to interface-typed endpoints
  uint64_t statSkippedPartialInstance = 0;          // instances skipped due to partial connectivity when allowed

    // 1. Build StringAttr-based call graph of network -> referenced networks.
    DenseMap<StringAttr, SmallVector<StringAttr>> adjacency;
    // Also build an instantiate-only adjacency that only considers symbolic
    // cal.instantiate and cal.instantiate_array ops (not cal.create_instance).
    // This is used to derive a stricter "actually used from top" set for
    // enforcing connectivity, preferring specialized clones selected by
    // upstream passes.
    DenseMap<StringAttr, SmallVector<StringAttr>> instOnlyAdjacency;
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
    // Also record symbolic instantiation edges prior to elaboration.
    module.walk([&](InstantiateOp inst) {
      if (auto target = symbolTable.lookupNearestSymbolFrom<NetworkOp>(inst, inst.getActorRefAttr())) {
        if (auto parentNet = dyn_cast_or_null<NetworkOp>(inst->getParentOp())) {
          auto parentName = StringAttr::get(parentNet.getContext(), parentNet.getSymName());
          auto childName = StringAttr::get(target.getContext(), target.getSymName());
          adjacency[parentName].push_back(childName);
          instOnlyAdjacency[parentName].push_back(childName);
        }
      }
    });
    module.walk([&](InstantiateArrayOp instArr) {
      if (auto target = symbolTable.lookupNearestSymbolFrom<NetworkOp>(instArr, instArr.getActorRefAttr())) {
        if (auto parentNet = dyn_cast_or_null<NetworkOp>(instArr->getParentOp())) {
          auto parentName = StringAttr::get(parentNet.getContext(), parentNet.getSymName());
          auto childName = StringAttr::get(target.getContext(), target.getSymName());
          // Only the instantiate-only graph should record array-based edges.
          instOnlyAdjacency[parentName].push_back(childName);
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

    // If a 'top' network is specified, compute the set of networks reachable
    // from it and restrict elaboration/flattening to that set. This avoids
    // failing on unrelated (possibly partially wired) library networks.
    llvm::SmallDenseSet<StringAttr, 16> reachable;
    // Additionally, compute a stricter set of networks that are reachable
    // from 'top' following only symbolic instantiate edges. This set better
    // reflects the networks actually used after specialization (e.g., $spec
    // clones) and is used to gate strict connectivity errors.
    llvm::SmallDenseSet<StringAttr, 16> instReachable;
    if (!top.empty()) {
      StringAttr topName = StringAttr::get(module.getContext(), top);
      if (nameToOp.count(topName)) {
        SmallVector<StringAttr, 16> worklist;
        worklist.push_back(topName);
        reachable.insert(topName);
        while (!worklist.empty()) {
          StringAttr cur = worklist.pop_back_val();
          for (StringAttr child : adjacency[cur]) {
            if (reachable.insert(child).second)
              worklist.push_back(child);
          }
        }
        // Instantiate-only traversal
        SmallVector<StringAttr, 16> wl2;
        wl2.push_back(topName);
        instReachable.insert(topName);
        while (!wl2.empty()) {
          StringAttr cur = wl2.pop_back_val();
          for (StringAttr child : instOnlyAdjacency[cur]) {
            if (instReachable.insert(child).second)
              wl2.push_back(child);
          }
        }
      } else {
        module.emitRemark() << "flatten-cal-networks: top='" << top
                            << "' not found; proceeding without reachability filter";
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
        // Always initialize wrapper ops to null to avoid accidental deref of garbage.
        ActorOp actor = nullptr;
        NetworkOp network = nullptr;
        cal::InterfaceOp iface = nullptr;       // Optional: interface symbol when plan is interface-typed
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

  // Track arrays constructed via cal.instance.array.init/set for ND support.
  // We keep a lightweight map from array SSA to element plans (non-owning),
  // derived from existing singlePlans created for cal.instantiate handles.
  // Map arrays (built via instance.array.init/set) to element plans indexed by
  // a serialized ND index key "i0,i1,...". This avoids requiring static shapes.
  DenseMap<Value, llvm::StringMap<InstPlan*>> arrayElemPlans;

  for (Operation &op : llvm::make_early_inc_range(body.getOperations())) {
        if (auto inst = dyn_cast<InstantiateOp>(&op)) {
          ActorOp actor = symbolTable.lookupNearestSymbolFrom<ActorOp>(&op, inst.getActorRefAttr());
          NetworkOp net  = symbolTable.lookupNearestSymbolFrom<NetworkOp>(&op, inst.getActorRefAttr());
          if (!actor && !net)
            return op.emitOpError("instantiate references unknown cal.actor or cal.network");
          auto plan = std::make_unique<InstPlan>();
          plan->actor = actor;
          plan->network = net;
          plan->defOp = &op;
          plan->name = inst.getInstanceNameAttr();
          plan->params.assign(inst.getParams().begin(), inst.getParams().end());
          if (actor) {
            plan->inPorts.resize(actor.inDegree());
            plan->outPorts.resize(actor.outDegree());
          } else if (net) {
            plan->inPorts.resize(net.inDegree());
            plan->outPorts.resize(net.outDegree());
          }
          singlePlans[inst.getHandle()] = std::move(plan);
          continue;
        }
        if (auto arr = dyn_cast<InstantiateArrayOp>(&op)) {
          ActorOp actor = symbolTable.lookupNearestSymbolFrom<ActorOp>(&op, arr.getActorRefAttr());
          NetworkOp net  = symbolTable.lookupNearestSymbolFrom<NetworkOp>(&op, arr.getActorRefAttr());
          if (!actor && !net)
            return op.emitOpError("instantiate_array references unknown cal.actor or cal.network");
          unsigned count = 0;
          // Prefer the op attribute 'count' for instantiate_array (1D arrays).
          count = static_cast<unsigned>(arr.getCount());
          SmallVector<std::unique_ptr<InstPlan>> plans;
          plans.reserve(count);
          for (unsigned i = 0; i < count; ++i) {
            auto plan = std::make_unique<InstPlan>();
            plan->actor = actor;
            plan->network = net;
            plan->defOp = &op;
            if (auto base = arr.getBaseNameAttr()) {
              std::string n = (base.getValue() + StringRef("[") + Twine(i).str() + "]").str();
              plan->name = StringAttr::get(ctx, n);
            }
            plan->params.assign(arr.getParams().begin(), arr.getParams().end());
            if (actor) {
              plan->inPorts.resize(actor.inDegree());
              plan->outPorts.resize(actor.outDegree());
            } else if (net) {
              plan->inPorts.resize(net.inDegree());
              plan->outPorts.resize(net.outDegree());
            }
            plans.push_back(std::move(plan));
          }
          arrayPlans[arr.getHandlesArray()] = std::move(plans);
          continue;
        }
        if (auto arrIf = dyn_cast<InstantiateArrayIfaceOp>(&op)) {
          cal::InterfaceOp iface = symbolTable.lookupNearestSymbolFrom<cal::InterfaceOp>(&op, arrIf.getIfaceRefAttr());
          if (!iface)
            return op.emitOpError("instantiate_array.iface references unknown cal.interface");
          unsigned count = static_cast<unsigned>(arrIf.getCount());
          auto inTypes = iface.getInPortTypesAttr();
          auto outTypes = iface.getOutPortTypesAttr();
          auto inNames = iface.getInPortNamesAttr();
          auto outNames = iface.getOutPortNamesAttr();
          unsigned inCount = 0, outCount = 0;
          if (inTypes && !inTypes.empty()) inCount = inTypes.size();
          else if (inNames && !inNames.empty()) inCount = inNames.size();
          if (outTypes && !outTypes.empty()) outCount = outTypes.size();
          else if (outNames && !outNames.empty()) outCount = outNames.size();

          SmallVector<std::unique_ptr<InstPlan>> plans;
          plans.reserve(count);
          for (unsigned i = 0; i < count; ++i) {
            auto plan = std::make_unique<InstPlan>();
            plan->iface = iface;
            plan->defOp = &op;
            if (auto base = arrIf.getBaseNameAttr()) {
              std::string n = (base.getValue() + StringRef("[") + Twine(i).str() + "]").str();
              plan->name = StringAttr::get(ctx, n);
            }
            plan->params.assign(arrIf.getParams().begin(), arrIf.getParams().end());
            plan->inPorts.resize(inCount);
            plan->outPorts.resize(outCount);
            plans.push_back(std::move(plan));
          }
          arrayPlans[arrIf.getHandlesArray()] = std::move(plans);
          continue;
        }
        if (auto at = dyn_cast<InstanceAtOp>(&op)) {
          instanceAtOps.push_back(at);
          continue;
        }
        // ND array construction: cal.instance.array.init
        if (auto arrInit = dyn_cast<InstanceArrayInitOp>(&op)) {
          Value arrVal = arrInit.getArray();
          arrayElemPlans[arrVal] = llvm::StringMap<InstPlan*>();
          continue;
        }
        // ND array element set: cal.instance.array.set %arr[idxs], %h
        if (auto arrSet = dyn_cast<InstanceArraySetOp>(&op)) {
          Value inArr = arrSet.getArray();
          // Propagate existing vector to result by value, then assign element when possible.
          llvm::StringMap<InstPlan*> mapCopy;
          if (auto it = arrayElemPlans.find(inArr); it != arrayElemPlans.end())
            mapCopy = it->second;

          // Compute linearized index only when indices are a single constant or when we can derive strides from static shape.
          SmallVector<Value> idxVals(arrSet.getIndices().begin(), arrSet.getIndices().end());
          std::optional<std::string> key;
          // Helper to extract constant index value
          auto constIndex = [&](Value v) -> std::optional<int64_t> {
            if (auto c = v.getDefiningOp<arith::ConstantOp>())
              if (auto a = dyn_cast<IntegerAttr>(c.getValue())) return a.getInt();
            return std::nullopt;
          };

          if (!idxVals.empty()) {
            SmallVector<int64_t, 4> idxs; idxs.reserve(idxVals.size());
            bool allConst = true;
            for (Value v : idxVals) {
              auto c = constIndex(v);
              if (!c) { allConst = false; break; }
              idxs.push_back(*c);
            }
            if (allConst) {
              std::string s;
              for (size_t i = 0; i < idxs.size(); ++i) {
                if (i) s += ",";
                s += Twine(idxs[i]).str();
              }
              key = std::move(s);
            }
          }

          // If we can compute a key and we have a plan for the value, assign.
          if (key) {
            Value h = arrSet.getValue();
            // Chase interface cast to its concrete handle, if present.
            if (auto castOp = h.getDefiningOp<cal::InstanceCastOp>())
              h = castOp.getInput();
            if (auto itPlan = singlePlans.find(h); itPlan != singlePlans.end()) {
              mapCopy[*key] = itPlan->second.get();
            }
          }
          // Map the result array value to the updated vector state (may be empty when unknown).
          arrayElemPlans[arrSet.getResult()] = std::move(mapCopy);
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
            auto indices = at.getIndices();
            if (indices.size() != 1) {
                if (!allowDynamicIndices) {
                  at.emitOpError("only a single constant index is supported for instance_at during elaboration");
                  return failure();
                } else {
                  at.emitRemark("skipping instance_at with non-1D indices during elaboration");
                  continue;
                }
              }
              auto c = indices.front().getDefiningOp<arith::ConstantOp>();
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

      // Also resolve instance_at uses for arrays built via array.init/set when indices are constant and vector populated.
      for (auto &kv : arrayElemPlans) {
        Value arrVal = kv.first; auto &ptrs = kv.second;
        if (ptrs.empty()) continue; // unknown or no entries recorded yet
        for (Operation *user : arrVal.getUsers()) {
          if (auto at = dyn_cast<InstanceAtOp>(user)) {
            auto indices = at.getIndices();
            // Build key "i0,i1,..." from constant indices
            std::string s; bool allConst = true;
            for (size_t i = 0; i < indices.size(); ++i) {
              if (auto c = indices[i].getDefiningOp<arith::ConstantOp>()) {
                if (auto ia = dyn_cast<IntegerAttr>(c.getValueAttr())) {
                  if (i) s += ",";
                  s += Twine(ia.getInt()).str();
                  continue;
                }
              }
              allConst = false; break;
            }
            if (!allConst) {
              if (!allowDynamicIndices) { at.emitOpError("dynamic ND index not supported during elaboration"); return failure(); }
              at.emitRemark("skipping instance_at with dynamic ND index during elaboration");
              continue;
            }
            if (auto it = ptrs.find(s); it != ptrs.end())
              if (InstPlan *p = it->second)
                handleToPlan[at.getHandle()] = p;
          }
        }
      }

      // Process connects in two phases: collect edges, then materialize depending on
      // fully-wired instances and options.
      struct PendingEdge {
        ConnectOp conn;
        // Endpoints can be either a plan+index (actor instance) or a network port SSA.
        InstPlan *srcPlan = nullptr;   // when non-null, use srcOutIdx
        InstPlan *dstPlan = nullptr;   // when non-null, use dstInIdx
        unsigned srcOutIdx = 0;
        unsigned dstInIdx = 0;
        Value srcNetPort;              // !fifo.output_port<...> when used as network source
        Value dstNetPort;              // !fifo.input_port<...> when used as network destination
        Type elemTy;                   // element type for fifo.create when both endpoints are plans
      };
  SmallVector<PendingEdge> edges;
      SmallVector<Operation*> toErase;

  // Per-plan connectivity trackers to detect duplicates and completeness.
  DenseMap<InstPlan*, SmallVector<bool>> seenOut, seenIn;
  // Track the first connect op that wired a given port to produce a helpful note on duplicates.
  DenseMap<InstPlan*, SmallVector<Operation*>> firstOutConn, firstInConn;

      // Track capacity per logical channel to detect conflicts. A channel is uniquely
      // identified by (srcPlan, srcOutIdx, dstPlan, dstInIdx) when both endpoints are plans.
      struct ChannelKey {
        InstPlan *s; unsigned so; InstPlan *d; unsigned di;
      };
      struct ChannelKeyInfo {
        static inline ChannelKey getEmptyKey() { return ChannelKey{nullptr, 0u, nullptr, 0u}; }
        static inline ChannelKey getTombstoneKey() { return ChannelKey{reinterpret_cast<InstPlan*>(1), 0u, reinterpret_cast<InstPlan*>(1), 0u}; }
        static unsigned getHashValue(const ChannelKey &k) {
          return llvm::hash_combine(k.s, k.so, k.d, k.di);
        }
        static bool isEqual(const ChannelKey &a, const ChannelKey &b) {
          return a.s == b.s && a.so == b.so && a.d == b.d && a.di == b.di;
        }
      };
      llvm::DenseMap<ChannelKey, std::pair<uint64_t, Operation*>, ChannelKeyInfo> channelCaps;

      // Additionally, record capacity hints attached to connects that involve
      // a network boundary port on one side. These will be consulted when the
      // channel is ultimately materialized between two concrete instance ports.
      struct PortKey { InstPlan *p; unsigned idx; };
      struct PortKeyInfo {
        static inline PortKey getEmptyKey() { return PortKey{nullptr, 0u}; }
        static inline PortKey getTombstoneKey() { return PortKey{reinterpret_cast<InstPlan*>(1), 0u}; }
        static unsigned getHashValue(const PortKey &k) { return llvm::hash_combine(k.p, k.idx); }
        static bool isEqual(const PortKey &a, const PortKey &b) { return a.p == b.p && a.idx == b.idx; }
      };
      llvm::DenseMap<PortKey, std::pair<uint64_t, Operation*>, PortKeyInfo> srcPortHints;
      llvm::DenseMap<PortKey, std::pair<uint64_t, Operation*>, PortKeyInfo> dstPortHints;

      auto ensureTrackers = [&](InstPlan *p) {
        if (!seenOut.count(p)) seenOut[p] = SmallVector<bool>(p->outPorts.size(), false);
        if (!seenIn.count(p))  seenIn[p]  = SmallVector<bool>(p->inPorts.size(),  false);
        if (!firstOutConn.count(p)) firstOutConn[p] = SmallVector<Operation*>(p->outPorts.size(), nullptr);
        if (!firstInConn.count(p))  firstInConn[p]  = SmallVector<Operation*>(p->inPorts.size(),  nullptr);
      };

      for (Operation *op : connectOps) {
        auto conn = cast<ConnectOp>(op);
        // Canonicalizer may have already lowered sugar. If indices remain on
        // the connect, attempt to resolve constant indices here so users don't
        // have to run -canonicalize explicitly. When dynamic and not allowed,
        // fail with a clear diagnostic; when allowed, skip this connect.
        // Classify endpoints: plan handle/array (resolved) or network port SSA values.
        // Resolve endpoints: allow raw handle, handle behind cal.instance.cast,
        // or network SSA ports.
        Value rawSrc = conn.getSrc();
        Value rawDst = conn.getDst();

        // Handle array-index sugar directly if present on connect.
        auto resolveArrayEndpoint = [&](Value &rawVal, OperandRange idxVals, bool isDst) -> FailureOr<InstPlan*> {
          if (idxVals.empty())
            return FailureOr<InstPlan*>(nullptr);
          // Expect the raw value to be an instance array (concrete or iface-typed).
          if (!isa<InstanceArrayType, InterfaceInstanceArrayType>(rawVal.getType())) {
            return conn.emitOpError(isDst ? "destination index provided but destination is not an array"
                                          : "source index provided but source is not an array");
          }
          // Gather indices; require constants unless allowDynamicIndices is set.
          SmallVector<int64_t, 4> idxs;
          idxs.reserve(idxVals.size());
          for (Value v : idxVals) {
            if (auto c = v.getDefiningOp<arith::ConstantOp>()) {
              if (auto ia = dyn_cast<IntegerAttr>(c.getValueAttr())) { idxs.push_back(ia.getInt()); continue; }
            }
            if (!allowDynamicIndices)
              return conn.emitOpError("dynamic ND index not supported during elaboration");
            conn.emitRemark("skipping connect with dynamic ND array index during elaboration");
            return FailureOr<InstPlan*>(nullptr);
          }
          // If this came from a 1D instantiate_array, we only support a single index here.
          if (auto it = arrayPlans.find(rawVal); it != arrayPlans.end()) {
            auto &vec = it->second;
            if (idxs.size() != 1)
              return conn.emitOpError(isDst ? "destination has multiple indices; only single index supported for 1D instance arrays"
                                            : "source has multiple indices; only single index supported for 1D instance arrays");
            int64_t idx = idxs.front();
            if (idx < 0 || static_cast<unsigned>(idx) >= vec.size())
              return conn.emitOpError("index out of bounds for instance array on connect");
            return vec[static_cast<unsigned>(idx)].get();
          }
          // Otherwise, use ND key lookup for arrays built via init/set.
          if (auto it2 = arrayElemPlans.find(rawVal); it2 != arrayElemPlans.end()) {
            auto &ptrs = it2->second;
            std::string keyStr;
            for (size_t i = 0; i < idxs.size(); ++i) {
              if (i) keyStr += ",";
              keyStr += Twine(idxs[i]).str();
            }
            if (auto itp = ptrs.find(keyStr); itp != ptrs.end())
              return itp->second;
            return conn.emitOpError("no element recorded at ND index for array on connect");
          }
          return conn.emitOpError("internal error: array endpoint has no plan table");
        };

        // If indices exist on the connect, resolve to plans before chasing casts below.
        InstPlan *srcPlanIdx = nullptr;
        if (!conn.getSrcIndices().empty()) {
          auto res = resolveArrayEndpoint(rawSrc, conn.getSrcIndices(), /*isDst=*/false);
          if (failed(res)) return failure();
          srcPlanIdx = *res;
          if (!srcPlanIdx && !conn.getSrcIndices().empty()) {
            // Dynamic case with allowDynamicIndices: skip this connect entirely.
            ++statSkippedConnectDynamicIndex;
            continue;
          }
        }
        InstPlan *dstPlanIdx = nullptr;
        if (!conn.getDstIndices().empty()) {
          auto res = resolveArrayEndpoint(rawDst, conn.getDstIndices(), /*isDst=*/true);
          if (failed(res)) return failure();
          dstPlanIdx = *res;
          if (!dstPlanIdx && !conn.getDstIndices().empty()) {
            // Dynamic case with allowDynamicIndices: skip this connect entirely.
            ++statSkippedConnectDynamicIndex;
            continue;
          }
        }
  // Track if the endpoint is interface-typed (so we can use interface names)
  // and whether a cast was present to validate conformance later.
  cal::InterfaceOp srcIfaceSym = nullptr;
  cal::InterfaceOp dstIfaceSym = nullptr;
  bool srcHadCast = false;
  bool dstHadCast = false;
        // If value is produced by cal.instance.cast, chase to the concrete handle
        // and record the interface symbol for port-name lookup.
        if (auto castSrc = rawSrc.getDefiningOp<cal::InstanceCastOp>()) {
          rawSrc = castSrc.getInput();
          if (auto ifTy = dyn_cast_if_present<cal::InterfaceInstanceType>(castSrc.getOutput().getType())) {
            srcIfaceSym = symbolTable.lookupNearestSymbolFrom<cal::InterfaceOp>(castSrc, ifTy.getIfaceRef());
            srcHadCast = true;
          }
        }
        if (auto castDst = rawDst.getDefiningOp<cal::InstanceCastOp>()) {
          rawDst = castDst.getInput();
          if (auto ifTy = dyn_cast_if_present<cal::InterfaceInstanceType>(castDst.getOutput().getType())) {
            dstIfaceSym = symbolTable.lookupNearestSymbolFrom<cal::InterfaceOp>(castDst, ifTy.getIfaceRef());
            dstHadCast = true;
          }
        }

  InstPlan *srcPlan = srcPlanIdx ? srcPlanIdx : handleToPlan.lookup(rawSrc);
  InstPlan *dstPlan = dstPlanIdx ? dstPlanIdx : handleToPlan.lookup(rawDst);
        bool srcIsNet = isa<fifo::OutputPortType>(conn.getSrc().getType());
        bool dstIsNet = isa<fifo::InputPortType>(conn.getDst().getType());
        if (!srcPlan && !srcIsNet) {
          if (allowDynamicIndices) { conn.emitRemark("skipping connect with unresolved source during elaboration"); ++statSkippedConnectUnresolved; continue; }
          return conn.emitOpError("unable to resolve source to instance plan or network port");
        }
        if (!dstPlan && !dstIsNet) {
          if (allowDynamicIndices) { conn.emitRemark("skipping connect with unresolved destination during elaboration"); ++statSkippedConnectUnresolved; continue; }
          return conn.emitOpError("unable to resolve destination to instance plan or network port");
        }
        if (srcIsNet && dstIsNet) {
          return conn.emitOpError("network-to-network connect not supported during elaboration");
        }

        // Now that plans are known, validate that any instance.cast conforms to the declared interface.
        if (srcPlan && srcHadCast && srcIfaceSym) {
          StringRef entName = srcPlan->actor ? srcPlan->actor.getSymName() : (srcPlan->network ? srcPlan->network.getSymName() : (srcPlan->iface ? srcPlan->iface.getSymName() : StringRef("<unknown>")));
          StringRef ifaceName = srcIfaceSym.getSymName();
          bool ok = false;
          if (auto it = entityImplements.find(entName); it != entityImplements.end())
            ok = llvm::is_contained(it->second, ifaceName);
          if (!ok) {
            return conn.emitOpError("invalid instance.cast on source: entity '") << entName
                   << "' does not implement interface '" << ifaceName << "'";
          }
        }
        if (dstPlan && dstHadCast && dstIfaceSym) {
          StringRef entName = dstPlan->actor ? dstPlan->actor.getSymName() : (dstPlan->network ? dstPlan->network.getSymName() : (dstPlan->iface ? dstPlan->iface.getSymName() : StringRef("<unknown>")));
          StringRef ifaceName = dstIfaceSym.getSymName();
          bool ok = false;
          if (auto it = entityImplements.find(entName); it != entityImplements.end())
            ok = llvm::is_contained(it->second, ifaceName);
          if (!ok) {
            return conn.emitOpError("invalid instance.cast on destination: entity '") << entName
                   << "' does not implement interface '" << ifaceName << "'";
          }
        }

        FailureOr<unsigned> srcOutIdx; FailureOr<unsigned> dstInIdx;
        ActorOp srcActor = nullptr, dstActor = nullptr;
        NetworkOp srcNetwork = nullptr, dstNetwork = nullptr;
        unsigned outCount = 0, inCount = 0;
        ArrayAttr srcDeclared, dstDeclared;
        ArrayAttr srcIfaceDeclared, dstIfaceDeclared;
        if (srcPlan) {
          srcActor = srcPlan->actor;
          srcNetwork = srcPlan->network;
          if (srcActor) {
            outCount = static_cast<unsigned>(srcActor.outDegree());
            srcDeclared = srcActor->getAttrOfType<ArrayAttr>("outPortNames");
          } else if (srcNetwork) {
            outCount = static_cast<unsigned>(srcNetwork.outDegree());
            srcDeclared = srcNetwork->getAttrOfType<ArrayAttr>("outPortNames");
          } else if (srcPlan->iface) {
            auto outTypes = srcPlan->iface.getOutPortTypesAttr();
            auto outNames = srcPlan->iface.getOutPortNamesAttr();
            if (outTypes && !outTypes.empty()) outCount = outTypes.size();
            else if (outNames && !outNames.empty()) outCount = outNames.size();
          }
          // Try actor-declared names first; if that fails and we have an interface, try interface-declared out names.
          srcOutIdx = parsePortIndex(conn.getSrcPortAttr().getValue(), outCount, /*isDst=*/false, srcDeclared);
          if (failed(srcOutIdx)) {
            if (srcIfaceSym)
              srcIfaceDeclared = srcIfaceSym.getOutPortNamesAttr();
            else if (srcPlan->iface)
              srcIfaceDeclared = srcPlan->iface.getOutPortNamesAttr();
            if (srcIfaceDeclared)
              srcOutIdx = parsePortIndex(conn.getSrcPortAttr().getValue(), outCount, /*isDst=*/false, srcIfaceDeclared);
          }
        }
        if (dstPlan) {
          dstActor = dstPlan->actor;
          dstNetwork = dstPlan->network;
          if (dstActor) {
            inCount = static_cast<unsigned>(dstActor.inDegree());
            dstDeclared = dstActor->getAttrOfType<ArrayAttr>("inPortNames");
          } else if (dstNetwork) {
            inCount = static_cast<unsigned>(dstNetwork.inDegree());
            dstDeclared = dstNetwork->getAttrOfType<ArrayAttr>("inPortNames");
          } else if (dstPlan->iface) {
            auto inTypes = dstPlan->iface.getInPortTypesAttr();
            auto inNames = dstPlan->iface.getInPortNamesAttr();
            if (inTypes && !inTypes.empty()) inCount = inTypes.size();
            else if (inNames && !inNames.empty()) inCount = inNames.size();
          }
          dstInIdx  = parsePortIndex(conn.getDstPortAttr().getValue(),  inCount,  /*isDst=*/true,  dstDeclared);
          if (failed(dstInIdx)) {
            if (dstIfaceSym)
              dstIfaceDeclared = dstIfaceSym.getInPortNamesAttr();
            else if (dstPlan->iface)
              dstIfaceDeclared = dstPlan->iface.getInPortNamesAttr();
            if (dstIfaceDeclared)
              dstInIdx  = parsePortIndex(conn.getDstPortAttr().getValue(),  inCount,  /*isDst=*/true,  dstIfaceDeclared);
          }
        }
        if (srcPlan && failed(srcOutIdx)) {
          SmallVector<StringRef> choices; choices.reserve(outCount + (srcDeclared ? srcDeclared.size() : 0));
          for (unsigned i = 0; i < outCount; ++i)
            choices.push_back(StringRef((Twine("out") + Twine(i)).str()));
          if (srcDeclared)
            for (Attribute a : srcDeclared)
              if (auto s = dyn_cast<StringAttr>(a)) choices.push_back(s.getValue());
          if (srcIfaceDeclared)
            for (Attribute a : srcIfaceDeclared)
              if (auto s = dyn_cast<StringAttr>(a)) choices.push_back(s.getValue());
          std::string hint = suggestClosest(conn.getSrcPortAttr().getValue(), choices);
          auto err = conn.emitOpError("cannot resolve source port '") << conn.getSrcPortAttr().getValue() << "'";
          bool hasDeclared = srcDeclared && !srcDeclared.empty();
          bool hasIfaceDeclared = srcIfaceDeclared && !srcIfaceDeclared.empty();
          if (hasDeclared || hasIfaceDeclared)
            err << " (expected 'out<idx>' or one of declared names: ";
          else
            err << " (expected 'out'/'out<idx>'";
          if (hasDeclared) {
            bool first = true;
            for (Attribute a : srcDeclared) if (auto s = dyn_cast<StringAttr>(a)) {
              if (!first) err << ", "; first = false; err << "'" << s.getValue() << "'";
            }
          }
          if (hasIfaceDeclared) {
            if (srcDeclared && !srcDeclared.empty()) err << ", ";
            bool first2 = true;
            for (Attribute a : srcIfaceDeclared) if (auto s = dyn_cast<StringAttr>(a)) {
              if (!first2) err << ", "; first2 = false; err << "'" << s.getValue() << "'";
            }
          }
          err << ")" << hint;
          return err;
        }
        if (dstPlan && failed(dstInIdx)) {
          SmallVector<StringRef> choices; choices.reserve(inCount + (dstDeclared ? dstDeclared.size() : 0));
          for (unsigned i = 0; i < inCount; ++i)
            choices.push_back(StringRef((Twine("in") + Twine(i)).str()));
          if (dstDeclared)
            for (Attribute a : dstDeclared)
              if (auto s = dyn_cast<StringAttr>(a)) choices.push_back(s.getValue());
          if (dstIfaceDeclared)
            for (Attribute a : dstIfaceDeclared)
              if (auto s = dyn_cast<StringAttr>(a)) choices.push_back(s.getValue());
          std::string hint = suggestClosest(conn.getDstPortAttr().getValue(), choices);
          auto err = conn.emitOpError("cannot resolve destination port '") << conn.getDstPortAttr().getValue() << "'";
          bool hasDeclared = dstDeclared && !dstDeclared.empty();
          bool hasIfaceDeclared = dstIfaceDeclared && !dstIfaceDeclared.empty();
          if (hasDeclared || hasIfaceDeclared)
            err << " (expected 'in<idx>' or one of declared names: ";
          else
            err << " (expected 'in'/'in<idx>'";
          if (hasDeclared) {
            bool first = true;
            for (Attribute a : dstDeclared) if (auto s = dyn_cast<StringAttr>(a)) {
              if (!first) err << ", "; first = false; err << "'" << s.getValue() << "'";
            }
          }
          if (hasIfaceDeclared) {
            if (dstDeclared && !dstDeclared.empty()) err << ", ";
            bool first2 = true;
            for (Attribute a : dstIfaceDeclared) if (auto s = dyn_cast<StringAttr>(a)) {
              if (!first2) err << ", "; first2 = false; err << "'" << s.getValue() << "'";
            }
          }
          err << ")" << hint;
          return err;
        }

        // Compute element type and wire endpoints/track seen ports.
        Type elemTy = nullptr;
        if (srcPlan) {
          if (srcActor) {
            Block &abody = srcActor.getBody().front();
            SmallVector<Type> formals; for (Value a : abody.getArguments()) formals.push_back(a.getType());
            unsigned numParamsSrc = 0, numInSrcCount = 0;
            for (Type t : formals) {
              if (isa<fifo::OutputPortType>(t)) ++numInSrcCount;
              else if (isa<fifo::InputPortType>(t)) {/*count only*/}
              else ++numParamsSrc;
            }
            unsigned portsOutStart = numParamsSrc + numInSrcCount;
            auto fifoInTy = dyn_cast<fifo::InputPortType>(formals[portsOutStart + *srcOutIdx]);
            if (!fifoInTy)
              return conn.emitOpError("internal error resolving source port type");
            elemTy = fifoInTy.getElementType();
          } else if (srcNetwork) {
            Block &nbody = srcNetwork.getBody().front();
            SmallVector<Type> formals; for (Value a : nbody.getArguments()) formals.push_back(a.getType());
            unsigned numParamsSrc = 0, numInSrcCount = 0;
            for (Type t : formals) {
              if (isa<fifo::OutputPortType>(t)) ++numInSrcCount; // ports_in
              else if (isa<fifo::InputPortType>(t)) {/* ports_out */}
              else ++numParamsSrc; // params
            }
            unsigned portsOutStart = numParamsSrc + numInSrcCount; // start of ports_out
            auto fifoInTy = dyn_cast<fifo::InputPortType>(formals[portsOutStart + *srcOutIdx]);
            if (!fifoInTy)
              return conn.emitOpError("internal error resolving source network port type");
            elemTy = fifoInTy.getElementType();
          } else if (srcPlan->iface) {
            auto outTypes = srcPlan->iface.getOutPortTypesAttr();
            if (outTypes && *srcOutIdx < outTypes.size()) {
              if (auto tyAttr = dyn_cast<TypeAttr>(outTypes[*srcOutIdx])) {
                if (auto inPT = dyn_cast<fifo::InputPortType>(tyAttr.getValue()))
                  elemTy = inPT.getElementType();
              }
            }
            if (!elemTy)
              return conn.emitOpError("unable to resolve element type from interface out port");
          }
        }
        if (srcIsNet) {
          auto netOutTy = dyn_cast<fifo::OutputPortType>(conn.getSrc().getType());
          if (!netOutTy) return conn.emitOpError("expected source network port to be fifo.output_port");
          elemTy = netOutTy.getElementType();
        }

        // Capacity conflict detection: if both endpoints are plans and capacity is set,
        // ensure no conflicting capacity was previously recorded for this channel.
        if (srcPlan && dstPlan) {
          if (auto capAttr = conn.getCapacityAttr()) {
            ChannelKey key{srcPlan, *srcOutIdx, dstPlan, *dstInIdx};
            auto it = channelCaps.find(key);
            uint64_t capVal = static_cast<uint64_t>(capAttr.getInt());
            if (it == channelCaps.end()) {
              channelCaps.insert({key, {capVal, conn}});
            } else if (it->second.first != capVal) {
              auto err = conn.emitOpError("conflicting capacity for channel: existing=") << it->second.first
                        << ", new=" << capVal;
              if (it->second.second)
                it->second.second->emitRemark("first capacity specified here");
              return failure();
            }
          }
        } else {
          // If one endpoint is a network port and a capacity is specified, record it
          // as a hint on the concrete instance port side so it can be propagated to
          // the eventual fifo.create when the channel is materialized.
          if (auto capAttr = conn.getCapacityAttr()) {
            uint64_t capVal = static_cast<uint64_t>(capAttr.getInt());
            if (srcPlan && !dstPlan) {
              PortKey pk{srcPlan, *srcOutIdx};
              auto it = srcPortHints.find(pk);
              if (it == srcPortHints.end()) {
                srcPortHints.insert({pk, {capVal, conn}});
              } else if (it->second.first != capVal) {
                auto diag = conn.emitOpError("conflicting capacity hints on source port: existing=")
                            << it->second.first << ", new=" << capVal;
                if (it->second.second)
                  it->second.second->emitRemark("first capacity specified here");
                return failure();
              }
            } else if (!srcPlan && dstPlan) {
              PortKey pk{dstPlan, *dstInIdx};
              auto it = dstPortHints.find(pk);
              if (it == dstPortHints.end()) {
                dstPortHints.insert({pk, {capVal, conn}});
              } else if (it->second.first != capVal) {
                auto diag = conn.emitOpError("conflicting capacity hints on destination port: existing=")
                            << it->second.first << ", new=" << capVal;
                if (it->second.second)
                  it->second.second->emitRemark("first capacity specified here");
                return failure();
              }
            }
          }
        }

        // Track duplicate port connections early.
        PendingEdge e; e.conn = conn; e.elemTy = elemTy;
        if (srcPlan) {
          ensureTrackers(srcPlan);
          // Multiple connections from the same source port are permitted when
          // auto-fanout insertion is enabled. Otherwise, emit a duplicate-source
          // diagnostic (legacy behavior).
          if (seenOut[srcPlan][*srcOutIdx]) {
            auto diag = conn.emitOpError("source port already connected");
            std::string entityLabel;
            std::string entityName;
            if (srcPlan->actor) { entityLabel = "actor"; entityName = srcPlan->actor.getSymName().str(); }
            else if (srcPlan->network) { entityLabel = "network"; entityName = srcPlan->network.getSymName().str(); }
            else if (srcPlan->iface) { entityLabel = "interface"; entityName = srcPlan->iface.getSymName().str(); }
            else { entityLabel = "entity"; entityName = "<unknown>"; }
            std::string ctxMsg = " (" + entityLabel + "=@" + entityName + ", instance=";
            if (srcPlan->name && !srcPlan->name.getValue().empty())
              ctxMsg += '"' + srcPlan->name.getValue().str() + '"';
            else
              ctxMsg += "<unnamed>";
            ctxMsg += ", port=out" + Twine(*srcOutIdx).str() + ")";
            diag << ctxMsg;
            if (Operation *first = firstOutConn[srcPlan][*srcOutIdx])
              first->emitRemark("first connection to this port was here");
            return failure();
          } else {
            seenOut[srcPlan][*srcOutIdx] = true;
            firstOutConn[srcPlan][*srcOutIdx] = conn;
          }
          e.srcPlan = srcPlan; e.srcOutIdx = *srcOutIdx;
        } else {
          e.srcNetPort = conn.getSrc();
        }
        if (dstPlan) {
          ensureTrackers(dstPlan);
          if (seenIn[dstPlan][*dstInIdx]) {
            auto diag = conn.emitOpError("destination port already connected");
            std::string entityLabel2;
            std::string entityName2;
            if (dstPlan->actor) { entityLabel2 = "actor"; entityName2 = dstPlan->actor.getSymName().str(); }
            else if (dstPlan->network) { entityLabel2 = "network"; entityName2 = dstPlan->network.getSymName().str(); }
            else if (dstPlan->iface) { entityLabel2 = "interface"; entityName2 = dstPlan->iface.getSymName().str(); }
            else { entityLabel2 = "entity"; entityName2 = "<unknown>"; }
            std::string ctxMsg = " (" + entityLabel2 + "=@" + entityName2 + ", instance=";
            if (dstPlan->name && !dstPlan->name.getValue().empty())
              ctxMsg += '"' + dstPlan->name.getValue().str() + '"';
            else
              ctxMsg += "<unnamed>";
            ctxMsg += ", port=in" + Twine(*dstInIdx).str() + ")";
            diag << ctxMsg;
            if (Operation *first = firstInConn[dstPlan][*dstInIdx])
              first->emitRemark("first connection to this port was here");
            return failure();
          }
          seenIn[dstPlan][*dstInIdx] = true;
          firstInConn[dstPlan][*dstInIdx] = conn;
          e.dstPlan = dstPlan; e.dstInIdx = *dstInIdx;
        } else {
          e.dstNetPort = conn.getDst();
        }
        edges.push_back(std::move(e));
      }
        
  // Determine fully-wired plans.
      DenseSet<InstPlan*> fullyWired;
      // We'll also assign deterministic sequence numbers within this network
      // to enable stable instance and fifo naming independent of hash maps.
      struct PlanOrder {
        InstPlan *plan;
        Operation *def;
        unsigned arrayIdx; // UINT_MAX when not from an array
      };
      SmallVector<PlanOrder> allPlansForOrder;
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
      for (auto &kv : singlePlans) {
        InstPlan *p = kv.second.get();
        if (isFullyWired(p))
          fullyWired.insert(p);
        // Collect for deterministic ordering regardless of wiring, but
        // we'll filter when assigning sequence ids.
        allPlansForOrder.push_back(PlanOrder{p, p->defOp, /*arrayIdx=*/std::numeric_limits<unsigned>::max()});
      }
      for (auto &kv : arrayPlans) {
        unsigned idx = 0;
        for (auto &ptr : kv.second) {
          InstPlan *p = ptr.get();
          if (isFullyWired(p))
            fullyWired.insert(p);
          allPlansForOrder.push_back(PlanOrder{p, p->defOp, idx});
          ++idx;
        }
      }


      // Sort plans deterministically: by defining op position in block, then by array index.
      llvm::sort(allPlansForOrder, [&](const PlanOrder &a, const PlanOrder &b){
        if (a.def != b.def)
          return a.def->isBeforeInBlock(b.def);
        return a.arrayIdx < b.arrayIdx;
      });

      // Assign sequence numbers to fully-wired plans and synthesize names if missing.
      DenseMap<InstPlan*, unsigned> planSeq;
      unsigned seqCounter = 0;
      for (const auto &po : allPlansForOrder) {
        if (!fullyWired.contains(po.plan))
          continue;
        planSeq[po.plan] = seqCounter++;
        if (!po.plan->name) {
          Twine entityName = po.plan->actor ? Twine(po.plan->actor.getSymName())
                                            : (po.plan->network ? Twine(po.plan->network.getSymName())
                                                                : (po.plan->iface ? Twine(po.plan->iface.getSymName()) : Twine("unknown")));
          std::string autoName = (Twine(net.getSymName()) + "." + entityName + "." + Twine(planSeq[po.plan])).str();
          po.plan->name = StringAttr::get(ctx, autoName);
        }
      }

  if (!allowPartialConnectivity && !allowDynamicIndices) {
        // In strict mode, require all plans to be fully wired.
        // However, if a 'top' filter is provided and this network is not in
        // the instantiate-only reachable set from 'top', downgrade the failure to a remark so
        // unrelated library networks do not abort the pipeline.
        auto requireOrSkip = [&](Operation *offender, bool isArray) -> LogicalResult {
          if (instReachable.empty()) {
            offender->emitRemark(isArray ? "skipping materialization for partially-connected instance in array"
                                        : "skipping materialization for partially-connected instance");
            return success();
          }
          StringAttr curName = StringAttr::get(net.getContext(), net.getSymName());
          // When instantiate-only reachability is available, prefer enforcing
          // strictness only on specialized clones (symbol names typically
          // contain "$spec_") that are actually used from top. Generic base
          // definitions may remain partially wired and should not abort.
          if (!instReachable.empty()) {
            bool isSpec = curName.getValue().contains("$spec_");
            if (!isSpec) {
              offender->emitRemark(isArray ? "skipping materialization for partially-connected instance in array (base definition, specialized clones in use)"
                                           : "skipping materialization for partially-connected instance (base definition, specialized clones in use)");
              return success();
            }
            if (instReachable.contains(curName)) {
              offender->emitRemark(isArray ? "skipping materialization for partially-connected instance in array (specialized, reachable)"
                                          : "skipping materialization for partially-connected instance (specialized, reachable)");
              return success();
            }
          }
          // Unreachable from top: emit remark and continue.
          offender->emitRemark(isArray ? "skipping materialization for partially-connected instance in array (unreachable from top)"
                                       : "skipping materialization for partially-connected instance (unreachable from top)");
          return success();
        };

        for (auto &kv : singlePlans) {
            if (!fullyWired.contains(kv.second.get())) {
              // Emit a brief diagnostic to help pinpoint which plan is considered incomplete.
              InstPlan *p = kv.second.get();
              auto diag = p->defOp->emitRemark("plan not fully wired; attempting strict check");
              // Attach a small summary of seen ports vs required when available.
              auto itOutDbg = seenOut.find(p);
              auto itInDbg  = seenIn.find(p);
              unsigned needOut = p->outPorts.size();
              unsigned needIn  = p->inPorts.size();
              unsigned haveOut = 0, haveIn = 0;
              if (itOutDbg != seenOut.end())
                for (bool v : itOutDbg->second) if (v) ++haveOut;
              if (itInDbg  != seenIn.end())
                for (bool v : itInDbg->second) if (v) ++haveIn;
              (void)diag; // keep clang tidy happy in release builds
              p->defOp->emitRemark() << "  in-ports: " << haveIn << "/" << needIn << ", out-ports: " << haveOut << "/" << needOut;
              if (failed(requireOrSkip(kv.second->defOp, /*isArray=*/false))) return failure();
            }
        }
          for (auto &kv : arrayPlans)
            for (auto &ptr : kv.second) {
              if (!fullyWired.contains(ptr.get())) {
                InstPlan *p = ptr.get();
                auto diag = p->defOp->emitRemark("array element plan not fully wired; attempting strict check");
                auto itOutDbg = seenOut.find(p);
                auto itInDbg  = seenIn.find(p);
                unsigned needOut = p->outPorts.size();
                unsigned needIn  = p->inPorts.size();
                unsigned haveOut = 0, haveIn = 0;
                if (itOutDbg != seenOut.end())
                  for (bool v : itOutDbg->second) if (v) ++haveOut;
                if (itInDbg  != seenIn.end())
                  for (bool v : itInDbg->second) if (v) ++haveIn;
                (void)diag;
                p->defOp->emitRemark() << "  in-ports: " << haveIn << "/" << needIn << ", out-ports: " << haveOut << "/" << needOut;
                if (failed(requireOrSkip(ptr->defOp, /*isArray=*/true))) return failure();
              }
            }
      }

      // Materialize edges: if both endpoints are plans, create fifo and assign;
      // if one endpoint is a network port, wire the plan port directly to it.
      for (auto &e : edges) {
        if (e.srcPlan && e.dstPlan) {
          // Skip materialization if either endpoint is interface-typed.
          if ((!e.srcPlan->actor && e.srcPlan->iface) || (!e.dstPlan->actor && e.dstPlan->iface)) {
            e.conn.emitRemark("skipping materialization for interface-typed endpoint; requires resolution to a concrete entity");
            ++statSkippedConnectInterfaceTyped;
            continue;
          }
          // Eagerly materialize channels even if the endpoint instances are not yet
          // considered fully wired. This enables a fixed-point elaboration where
          // ports become available across iterations and instances can be created later.
          // Previous behavior required both endpoints to be fully wired here.
          // Insert near the original connect when available; otherwise append to the network body.
          if (e.conn)
            builder.setInsertionPoint(e.conn);
          else
            builder.setInsertionPointToEnd(&body);
          // Determine capacity with propagation:
          // Priority: explicit on this connect > per-port hints (src/dst) > channel-level record > default 1.
          uint64_t capVal = 1u;
          bool haveCap = false;
          if (e.conn) {
            if (auto capAttr = e.conn.getCapacityAttr()) {
              capVal = static_cast<uint64_t>(capAttr.getInt());
              haveCap = true;
            }
          }
          if (!haveCap) {
            // Per-port hints
            if (auto itS = srcPortHints.find(PortKey{e.srcPlan, e.srcOutIdx}); itS != srcPortHints.end()) {
              capVal = itS->second.first; haveCap = true;
            }
            if (auto itD = dstPortHints.find(PortKey{e.dstPlan, e.dstInIdx}); itD != dstPortHints.end()) {
              if (!haveCap) { capVal = itD->second.first; haveCap = true; }
              else if (capVal != itD->second.first) {
                auto err = (e.conn ? e.conn.emitOpError("") : net.emitOpError(""));
                err << "conflicting propagated capacities from endpoints: src="
                    << capVal << ", dst=" << itD->second.first;
                if (srcPortHints.count(PortKey{e.srcPlan, e.srcOutIdx}))
                  srcPortHints[PortKey{e.srcPlan, e.srcOutIdx}].second->emitRemark("source capacity hint specified here");
                if (dstPortHints.count(PortKey{e.dstPlan, e.dstInIdx}))
                  dstPortHints[PortKey{e.dstPlan, e.dstInIdx}].second->emitRemark("destination capacity hint specified here");
                return failure();
              }
            }
            // Channel-level record (from another explicit plan-plan connect of the same channel)
            if (!haveCap) {
              if (auto itC = channelCaps.find(ChannelKey{e.srcPlan, e.srcOutIdx, e.dstPlan, e.dstInIdx}); itC != channelCaps.end()) {
                capVal = itC->second.first; haveCap = true;
              }
            }
          }
          Type inPortTy = fifo::InputPortType::get(ctx, e.elemTy);
          Type outPortTy = fifo::OutputPortType::get(ctx, e.elemTy);
          auto create = builder.create<fifo::CreateOp>(e.conn ? e.conn.getLoc() : net.getLoc(), TypeRange{inPortTy, outPortTy}, e.elemTy, capVal);
          // Attach a deterministic name attribute to this fifo for stable testing/logging.
          if (planSeq.count(e.srcPlan) && planSeq.count(e.dstPlan)) {
            std::string fifoName = (Twine(net.getSymName()) + "." +
                                    e.srcPlan->name.getValue() + ".out" + Twine(e.srcOutIdx) +
                                    "->" + e.dstPlan->name.getValue() + ".in" + Twine(e.dstInIdx)).str();
            create->setAttr("cal.name", StringAttr::get(ctx, fifoName));
          }
          e.srcPlan->outPorts[e.srcOutIdx] = create.getInputPort();
          e.dstPlan->inPorts[e.dstInIdx] = create.getOutputPort();
          if (e.conn)
            toErase.push_back(e.conn);
          continue;
        }
        // Network-to-plan: wire directly and erase connect.
        if (e.srcNetPort && e.dstPlan) {
          // If destination is interface-typed, surface a remark and still thread the SSA value.
          if (!e.dstPlan->actor && e.dstPlan->iface)
            if (e.conn) {
              e.conn.emitRemark("skipping materialization for interface-typed endpoint; requires resolution to a concrete entity");
              ++statSkippedConnectInterfaceTyped;
            }
          e.dstPlan->inPorts[e.dstInIdx] = e.srcNetPort;
          if (e.conn)
            toErase.push_back(e.conn);
          continue;
        }
        if (e.srcPlan && e.dstNetPort) {
          // If source is interface-typed, surface a remark and still thread the SSA value.
          if (!e.srcPlan->actor && e.srcPlan->iface)
            if (e.conn) {
              e.conn.emitRemark("skipping materialization for interface-typed endpoint; requires resolution to a concrete entity");
              ++statSkippedConnectInterfaceTyped;
            }
          e.srcPlan->outPorts[e.srcOutIdx] = e.dstNetPort;
          if (e.conn)
            toErase.push_back(e.conn);
          continue;
        }
      }

      // Create cal.create_instance ops for each plan (optionally partial-only when flagged).
  auto materializeInstance = [&](InstPlan &plan) -> FailureOr<CreateInstanceOp> {
        if (!plan.actor && !plan.network && plan.iface) {
          // Do not materialize interface-typed instances at this stage; defer with no remark.
          return failure();
        }
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
  StringRef sym = plan.actor ? plan.actor.getSymName() : plan.network.getSymName();
  FlatSymbolRefAttr targetSym = FlatSymbolRefAttr::get(builder.getContext(), sym);
  auto inst = builder.create<CreateInstanceOp>(plan.defOp->getLoc(), targetSym, plan.name, all);
        // Also mirror the chosen instance name into a generic attribute for convenience.
        if (plan.name)
          inst->setAttr("cal.name", plan.name);
        return inst;
      };

      SmallVector<Operation*> defsToErase;
      for (auto &it : singlePlans) {
        if (fullyWired.contains(it.second.get())) {
          auto res = materializeInstance(*it.second);
          if (succeeded(res))
            defsToErase.push_back(it.second->defOp);
          else {
            // Interface-typed instance skipped; keep symbolic def.
          }
        } else if (allowPartialConnectivity) {
          it.second->defOp->emitRemark("skipping materialization of partially-connected instance");
          ++statSkippedPartialInstance;
        } else {
          // Strict mode already errored above.
        }
      }
      for (auto &kv : arrayPlans) {
        bool allMat = true;
        for (auto &ptr : kv.second) {
          if (fullyWired.contains(ptr.get())) {
            if (failed(materializeInstance(*ptr))) {
              // interface-typed instance skipped; keep array def
              allMat = false;
            }
          } else {
            allMat = false;
            if (allowPartialConnectivity) {
              ptr->defOp->emitRemark("skipping materialization of partially-connected instance in array");
              ++statSkippedPartialInstance;
            }
          }
        }
        if (allMat)
          defsToErase.push_back(kv.first.getDefiningOp());
      }

      // Second-chance materialization: some plans may have had their port SSA values
      // populated via eager channel materialization (above) without being marked as
      // fully-wired in the seenIn/seenOut trackers (e.g., when connects targeted
      // network boundary ports across earlier iterations). To improve fixpoint
      // progress, attempt to materialize any remaining non-interface plans whose
      // in/out port vectors are completely populated.
      auto isPortsPopulated = [&](InstPlan *p) -> bool {
        if (!p) return false;
        if (p->iface && !p->actor && !p->network) return false; // interface only
        for (Value v : p->inPorts) if (!v) return false;
        for (Value v : p->outPorts) if (!v) return false;
        return true;
      };
      for (auto &it : singlePlans) {
        InstPlan *p = it.second.get();
        if (fullyWired.contains(p)) continue;
        if (!isPortsPopulated(p)) continue;
        if (succeeded(materializeInstance(*p)))
          defsToErase.push_back(p->defOp);
      }
      for (auto &kv : arrayPlans) {
        for (auto &ptr : kv.second) {
          InstPlan *p = ptr.get();
          if (fullyWired.contains(p)) continue;
          if (!isPortsPopulated(p)) continue;
          (void)materializeInstance(*p);
        }
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

    // Elaborate networks with a small fixed-point: newly materialized FIFOs and
    // instances can make additional instantiates fully wired. Iterate up to 3
    // times or until no new create_instance ops are introduced.
    auto countCreateInstancesIn = [&](NetworkOp net) -> unsigned {
      unsigned c = 0;
      net.walk([&](CreateInstanceOp) { ++c; });
      return c;
    };

    for (int iter = 0; iter < 3; ++iter) {
      bool anyChange = false;
      for (NetworkOp net : llvm::make_early_inc_range(module.getOps<NetworkOp>())) {
        if (!reachable.empty() || !instReachable.empty()) {
          StringAttr n = StringAttr::get(net.getContext(), net.getSymName());
          // Prefer the instantiate-only reachability when available since it
          // reflects the actually used networks after specialization.
          if (!instReachable.empty()) {
            if (!instReachable.contains(n))
              continue;
          } else if (!reachable.empty()) {
            if (!reachable.contains(n))
              continue;
          }
        }
        unsigned before = countCreateInstancesIn(net);
        if (failed(elaborateNetwork(net))) {
          signalPassFailure();
          return;
        }
        unsigned after = countCreateInstancesIn(net);
        if (after > before)
          anyChange = true;
      }
      if (!anyChange)
        break;
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

        // If 'top' is set, only inline instances whose target is reachable.
        if (!reachable.empty()) {
          StringAttr tName = StringAttr::get(target.getContext(), target.getSymName());
          if (!reachable.contains(tName))
            continue;
        }

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
          // Preserve networks with unresolved symbolic operations (including interface arrays)
          net.walk([&](Operation *op) {
            if (isa<InstantiateOp, InstantiateArrayOp, InstantiateArrayIfaceOp, ConnectOp, InstanceAtOp>(op))
              hasSymbolicOps = true;
          });
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
    //
    // Important: When running multiple flatten-cal-networks passes in a single
    // pipeline, pruning to only 'top' too early can remove specialized
    // networks (e.g., $spec_* clones) that subsequent passes still reference
    // via symbolic cal.instantiate handles. To avoid symbol resolution issues
    // in later passes, we only perform this aggressive pruning when no
    // symbolic construction ops remain in the module.
    if (!top.empty()) {
      bool hasSymbolic = false;
      module.walk([&](Operation *op) {
        if (isa<cal::InstantiateOp, cal::InstantiateArrayOp, cal::InstantiateArrayIfaceOp, cal::InstanceAtOp, cal::ConnectOp>(op)) {
          hasSymbolic = true;
          return WalkResult::interrupt();
        }
        return WalkResult::advance();
      });
      if (hasSymbolic) {
        module.emitRemark()
            << "flatten-cal-networks: deferring top-only pruning because symbolic ops remain; a later pass can prune to top='"
            << top << "' once elaboration completes";
      } else {
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
    }

    // 7. Final cleanup: erase any remaining symbolic construction ops that are
    // now dead (no users). This commonly removes stray cal.instantiate handles
    // that were skipped due to partial connectivity on base defs but are no
    // longer referenced after specialization and pruning.
    {
      SmallVector<Operation *, 16> toErase;
      module.walk([&](Operation *op) {
        if (!isa<cal::InstantiateOp, cal::InstantiateArrayOp, cal::InstantiateArrayIfaceOp, cal::InstanceAtOp>(op))
          return WalkResult::advance();
        if (op->use_empty())
          toErase.push_back(op);
        return WalkResult::advance();
      });
      for (Operation *op : toErase)
        op->erase();
    }

    if (emitStats) {
      // Residual symbolic ops summary
      uint64_t cntInstantiate = 0, cntInstArray = 0, cntInstArrayIface = 0, cntConnect = 0, cntInstanceAt = 0;
      module.walk([&](Operation *op){
        if (isa<cal::InstantiateOp>(op)) ++cntInstantiate;
        else if (isa<cal::InstantiateArrayOp>(op)) ++cntInstArray;
        else if (isa<cal::InstantiateArrayIfaceOp>(op)) ++cntInstArrayIface;
        else if (isa<cal::ConnectOp>(op)) ++cntConnect;
        else if (isa<cal::InstanceAtOp>(op)) ++cntInstanceAt;
        return WalkResult::advance();
      });

      module.emitRemark() << "flatten-cal-networks stats: iterations=" << statIterations
                          << ", flattened_instances=" << statFlattenedInstances
                          << ", pruned_networks=" << statPrunedNetworks
                          << (disablePruning ? " (pruning disabled)" : "")
                          << "; residual: instantiate=" << cntInstantiate
                          << ", instantiate_array=" << cntInstArray
                          << ", instantiate_array.iface=" << cntInstArrayIface
                          << ", instance_at=" << cntInstanceAt
                          << ", connect=" << cntConnect
                          << "; skipped: dynIndexConnects=" << statSkippedConnectDynamicIndex
                          << ", unresolvedConnects=" << statSkippedConnectUnresolved
                          << ", ifaceEndpointConnects=" << statSkippedConnectInterfaceTyped
                          << ", partialInstances=" << statSkippedPartialInstance;
    }
  }
};
} // namespace

// Factory is generated by TableGen; registering the pass class above is enough.
// (No out-of-line factory definition to avoid duplicate symbol.)

} // namespace mlir
