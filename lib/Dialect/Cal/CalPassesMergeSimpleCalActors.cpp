#include "Dialect/Cal/CalDialect.h"
#include "Dialect/Cal/CalOps.h"
#include "Dialect/Cal/CalPasses.h"
#include "Dialect/Cal/CalTypes.h"
#include "Dialect/Fifo/FifoDialect.h"
#include "Dialect/Fifo/FifoOps.h"
#include "Dialect/Fifo/FifoTypes.h"
#include "mlir/Dialect/Arith/IR/Arith.h"
#include "mlir/Pass/AnalysisManager.h"
#include "mlir/Pass/Pass.h"
#include "mlir/Pass/PassManager.h"
#include "mlir/Transforms/GreedyPatternRewriteDriver.h"

namespace mlir::cal {
#define GEN_PASS_DEF_MERGESIMPLECALACTORS
#include "Dialect/Cal/CalPasses.h.inc"

struct Edge {
  cal::CreateInstanceOp src;
  cal::CreateInstanceOp dst;
};

// Each chain is a sequence of nodes in order (endpoints included).
struct Chain {
  std::vector<cal::CreateInstanceOp> nodes;
};

std::vector<Edge> getOutputEdges(cal::CreateInstanceOp sourceInstance,
                                 cal::NetworkOp networkOp) {
  std::vector<Edge> outputEdges;

  for (Value operand : sourceInstance.getOperands()) {
    Type type = operand.getType();
    if (auto inputPortType = mlir::dyn_cast<fifo::InputPortType>(type)) {
      if (auto connectOp = operand.getDefiningOp<fifo::CreateOp>()) {
        auto outputPort = connectOp.getOutputPort();
        for (auto user : outputPort.getUsers()) {
          if (auto dstInstanceOp = dyn_cast<cal::CreateInstanceOp>(user)) {
            outputEdges.push_back(Edge{sourceInstance, dstInstanceOp});
          }
        }
      }
    }
  }

  return outputEdges;
}

struct NetworkAnalysis {
  MLIR_DEFINE_EXPLICIT_INTERNAL_INLINE_TYPE_ID(NetworkAnalysis)

  std::vector<Edge> edges;
  std::vector<cal::CreateInstanceOp> nodes;

  NetworkAnalysis(Operation *op) {
    cal::NetworkOp networkOp = nullptr;
    auto networkOpsRange = op->getRegion(0).front().getOps<cal::NetworkOp>();

    if (!networkOpsRange.empty()) {
      networkOp = *networkOpsRange.begin();
    } else {
      return;
    }

    // Collect all CreateInstanceOps and generate edges
    for (auto createInstanceOp : networkOp.getOps<cal::CreateInstanceOp>()) {
      nodes.push_back(createInstanceOp);
      auto outputEdges = getOutputEdges(createInstanceOp, networkOp);
      edges.insert(edges.end(), outputEdges.begin(), outputEdges.end());
    }
  }

  std::vector<Chain> generateChains() {
    const int n = static_cast<int>(nodes.size());
    const int m = static_cast<int>(edges.size());

    // 1) Map each node -> compact integer ID
    llvm::DenseMap<cal::CreateInstanceOp, int> id;
    id.reserve(n * 2);
    for (int i = 0; i < n; ++i) {
      id[nodes[i]] = i;
    }

    // 2) Build edge list (u,v) in ID space and adjacency by *edge index*
    std::vector<std::pair<int, int>> E;
    E.reserve(m);
    std::vector<std::vector<int>> adj(n);
    for (int i = 0; i < m; ++i) {
      auto itU = id.find(edges[i].src);
      auto itV = id.find(edges[i].dst);
      assert(itU != id.end() && itV != id.end() &&
             "edge endpoint not found in nodes[]");
      const int u = itU->second;
      const int v = itV->second;
      E.emplace_back(u, v);
      adj[u].push_back(i);
    }

    auto isSimpleIdx = [&](int v) -> bool {
      return nodes[v].getActor().isSimpleActor();
    };
    auto outDegIdx = [&](int v) -> int {
      return nodes[v].getActor().outDegree();
    };

    // 3) Grow from non-simple nodes; collect only the following simple segment
    std::vector<char> used(m, 0); // mark edges when consumed
    std::vector<Chain> result;

    for (int u = 0; u < n; ++u) {
      if (outDegIdx(u) == 0)
        continue;
      if (isSimpleIdx(u))
        continue; // start only from branch/dead-end nodes

      for (int ei : adj[u]) {
        if (used[ei])
          continue;

        std::vector<int> segIds; // simple nodes only
        int curE = ei;

        while (true) {
          used[curE] = 1;
          int v = E[curE].second;

          if (isSimpleIdx(v)) {
            segIds.push_back(v);

            // simple => exactly one outgoing edge
            assert(outDegIdx(v) == 1 && "simple node should have outDegree==1");
            assert(!adj[v].empty() &&
                   "adjacency must have the unique outgoing edge");
            int nextE = adj[v][0];
            if (used[nextE])
              break; // already traversed elsewhere (safety)
            curE = nextE;
          } else {
            // Hit a non-simple endpoint; do not include it.
            break;
          }
        }

        if (!segIds.empty()) {
          Chain chain;
          chain.nodes.reserve(segIds.size());
          for (int idv : segIds)
            chain.nodes.push_back(nodes[idv]);
          result.push_back(std::move(chain));
        }
      }
    }

    // 4) Handle pure cycles consisting only of simple nodes
    for (int s = 0; s < n; ++s) {
      if (!isSimpleIdx(s) || outDegIdx(s) == 0)
        continue;
      assert(!adj[s].empty() &&
             "simple node should have one outgoing edge in adjacency");
      int e0 = adj[s][0];
      if (used[e0])
        continue;

      std::vector<int> cycIds;
      int v = s;
      while (true) {
        cycIds.push_back(v); // all nodes here are simple
        int e = adj[v][0];
        used[e] = 1;
        v = E[e].second;

        if (v == s)
          break; // closed the loop
        if (!isSimpleIdx(v))
          break;
        if (adj[v].empty())
          break;
        if (used[adj[v][0]])
          break;
      }

      if (!cycIds.empty()) {
        Chain chain;
        chain.nodes.reserve(cycIds.size());
        for (int idv : cycIds)
          chain.nodes.push_back(nodes[idv]);
        result.push_back(std::move(chain));
      }
    }

    return result;
  }

  void printEdges() {
    llvm::outs() << "Network edges:\n";
    for (auto &edge : edges) {
      llvm::outs() << "  " << edge.src.getInstanceNameAttr().getValue()
                   << " -> " << edge.dst.getInstanceNameAttr().getValue()
                   << "\n";
    }
  }

  void printChains() {
    llvm::outs() << "Network chains:\n";
    auto chains = generateChains();
    for (auto &chain : chains) {
      llvm::outs() << "  Chain: ";
      for (auto &node : chain.nodes) {
        llvm::outs() << node.getInstanceNameAttr().getValue() << " -> ";
      }
      llvm::outs() << "end\n";
    }
  }
};

class MergeSimpleCalActorsPass
    : public impl::MergeSimpleCalActorsBase<MergeSimpleCalActorsPass> {
public:
  MergeSimpleCalActorsPass(const MergeSimpleCalActorsOptions &options)
      : impl::MergeSimpleCalActorsBase<MergeSimpleCalActorsPass>(options) {}

  MergeSimpleCalActorsPass() {}

  void runOnOperation() final {
    // Get the singular cal::NetworkOp in the module (if any)
    cal::NetworkOp networkOp = nullptr;
    auto networkOpsRange =
        getOperation()->getRegion(0).front().getOps<cal::NetworkOp>();
    if (!networkOpsRange.empty()) {
      networkOp = *networkOpsRange.begin();
    }

    auto &networkAnalysis = getAnalysis<NetworkAnalysis>();

    if (print_edges_for_testing.getValue()) {
      networkAnalysis.printEdges();
    }

    if (print_chains_for_testing.getValue()) {
      networkAnalysis.printChains();
    }

    // RewritePatternSet patterns(&getContext());

    // patterns.add<InsertPredicateInActionOps>(&getContext(), rateAnalysis);

    // if (failed(applyPatternsGreedily(getOperation(), std::move(patterns)))) {
    //   signalPassFailure();
    // }
  }
};

} // namespace mlir::cal