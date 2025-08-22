#include "Dialect/Cal/CalDialect.h"
#include "Dialect/Cal/CalOps.h"
#include "Dialect/Cal/CalPasses.h"
#include "Dialect/Cal/CalTypes.h"
#include "Dialect/Fifo/FifoDialect.h"
#include "Dialect/Fifo/FifoOps.h"
#include "Dialect/Fifo/FifoTypes.h"
#include "mlir/Dialect/Arith/IR/Arith.h"
#include "mlir/IR/IRMapping.h"
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

std::string createMergedActorName(Chain &chain) {
  std::string mergedActorName = "merged_actor_";
  for (size_t i = 0; i < chain.nodes.size(); ++i) {
    if (i > 0)
      mergedActorName += "_";
    mergedActorName += chain.nodes[i].getInstanceNameAttr().getValue().str();
  }
  return mergedActorName;
}

void createMergedActors(Operation *moduleOp, NetworkAnalysis &networkAnalysis) {
  // Get the chains to merge
  auto chains = networkAnalysis.generateChains();

  // Get the parent module to add new actors
  OpBuilder builder(moduleOp->getContext());

  builder.setInsertionPointToStart(&moduleOp->getRegion(0).front());

  for (auto &chain : chains) {
    if (chain.nodes.size() < 2) {
      continue; // Skip chains with less than 2 nodes
    }

    // 1. Create a unique name for the merged actor
    std::string mergedActorName = createMergedActorName(chain);

    // 2. Create the merged actor
    auto mergedActor = builder.create<cal::ActorOp>(
        builder.getUnknownLoc(), builder.getStringAttr(mergedActorName));
    Block *actorBody = &mergedActor.getBody().emplaceBlock();

    // 3. Create the arguments for the merged actor, these arguments are the
    // combination of all the arguments of the chain nodes, exluding the input
    // connections from all but the first actor and the output connections from
    // all but the last actor
    IRMapping mapping;
    SmallVector<Type> mergedArgTypes;
    SmallVector<BlockArgument> mergedArgs;

    for (size_t i = 0; i < chain.nodes.size(); ++i) {
      auto &node = chain.nodes[i];
      auto actor = node.getActor();
      auto args = actor.getBody().getArguments();
      for (auto arg : args) {

        // For the first node, include connections in.
        // For intermediate nodes, exclude connections.
        // For the last node, include connections out.
        bool isFirst = (i == 0);
        bool isLast = (i == chain.nodes.size() - 1);

        Type argType = arg.getType();
        bool isPortIn = mlir::isa<mlir::fifo::OutputPortType>(argType);
        bool isPortOut = mlir::isa<mlir::fifo::InputPortType>(argType);

        if ((isFirst && isPortIn) || (isLast && isPortOut) ||
            (!isPortIn && !isPortOut)) {
          auto newArg = actorBody->addArgument(argType, mergedActor.getLoc());
          mergedArgTypes.push_back(argType);
          mergedArgs.push_back(newArg);
          mapping.map(arg, newArg);
        }
      }
    }

    // 4. Create the body of the merged actor
    builder.setInsertionPointToStart(actorBody);

    // 4.1 Insert all initialisation code from each actor in the chain
    for (auto &node : chain.nodes) {
      auto actor = node.getActor();
      for (auto &op : actor.getBody().getOps()) {
        if (mlir::isa<cal::ExecutionBody>(op) || mlir::isa<cal::ActionOp>(op)) {
          // Skip execution body and action operations, they will be handled
          // separately.
          continue;
        }
        // Clone the operation into the merged actor body
        builder.clone(op, mapping);
      }
    }

    // 4.2 Create a single cal.action operation and merge the cal.action
    // operations from each actor in the chain This handles the action
    // operations and their fifo push/pop operations. We need to ensure that the
    // tokens are correctly mapped between the actors in the chain. We will use
    // a vector to store the tokens for push/pop operations. This is a simple
    // implementation that assumes the tokens are used in a first-in-first-out
    // manner.
    
    auto mergedAction = builder.create<cal::ActionOp>(
        builder.getUnknownLoc(),
        /*actionName=*/builder.getStringAttr("merged_action"),
        /*priority=*/builder.getI32IntegerAttr(0)
    );
    Block *mergedActionBody = &mergedAction.getBody().emplaceBlock();
    builder.setInsertionPointToStart(mergedActionBody);
    std::vector<Value> tokenStore;
    for (size_t i = 0; i < chain.nodes.size(); ++i) {
      auto &node = chain.nodes[i];
      auto actor = node.getActor();
      bool isFirst = (i == 0);
      bool isLast = (i == chain.nodes.size() - 1);
      for (auto &op : actor.getBody().getOps()) {
        if (auto actionOp = mlir::dyn_cast<cal::ActionOp>(op)) {
          // Clone the action operation into the merged actor body
          auto &actionBody = actionOp.getBody();
          for (auto &bodyOp : actionBody.getOps()) {
            bool isPush = mlir::isa<mlir::fifo::Push>(bodyOp);
            bool isPop = mlir::isa<mlir::fifo::Pop>(bodyOp);

            if (!isLast && isPush) {
              fifo::Push pushOp = llvm::dyn_cast<fifo::Push>(&bodyOp);
              Value mappedToken = mapping.lookup(pushOp.getInputToken());
              tokenStore.push_back(mappedToken);
            } else if (!isFirst && isPop) {
              fifo::Pop popOp = llvm::dyn_cast<fifo::Pop>(&bodyOp);
              Value poppedToken = tokenStore.front();
              tokenStore.erase(tokenStore.begin());
              mapping.map(popOp.getOutputToken(), poppedToken);
            } else {
              builder.clone(bodyOp, mapping);
            }
          }
        }
      }
    }
  }
}

void replaceChainInstancesWithMerged(cal::NetworkOp networkOp,
                                     NetworkAnalysis &networkAnalysis) {
  auto chains = networkAnalysis.generateChains();

  // Get the parent module to add new actors
  OpBuilder builder(networkOp->getContext());

  builder.setInsertionPointToEnd(&networkOp.getBody().front());

  int chainIndex = -1;
  for (auto &chain : chains) {
    if (chain.nodes.size() < 2) {
      continue; // Skip chains with less than 2 nodes
    }

    chainIndex++;

    // 1. Get unique name for the merged actor
    std::string mergedActorName = createMergedActorName(chain);

    // 2. Generate a list of arguments for the createInstance operation of the
    // merged actor
    std::vector<Value> mergedOperands;
    for (size_t i = 0; i < chain.nodes.size(); ++i) {
      auto &node = chain.nodes[i];
      for (auto inputOps : node.getOperands()) {

        // For the first node, include connections in.
        // For intermediate nodes, exclude connections.
        // For the last node, include connections out.
        bool isFirst = (i == 0);
        bool isLast = (i == chain.nodes.size() - 1);

        Type inputOpsType = inputOps.getType();
        bool isPortIn = mlir::isa<mlir::fifo::OutputPortType>(inputOpsType);
        bool isPortOut = mlir::isa<mlir::fifo::InputPortType>(inputOpsType);

        if ((isFirst && isPortIn) || (isLast && isPortOut) ||
            (!isPortIn && !isPortOut)) {
          // Add logic here for handling the selected operands
          mergedOperands.push_back(inputOps);
        }
      }
    }

    // 3. Create the CreateInstanceOp for the merged actor
    std::string instanceName = "merged_instance_" + std::to_string(chainIndex);
    auto mergedInstance = builder.create<cal::CreateInstanceOp>(
        builder.getUnknownLoc(), builder.getStringAttr(mergedActorName),
        /*instanceName=*/builder.getStringAttr(instanceName), mergedOperands);

    // 4. Delete all fifos and nodes in the chain
    // 4.1 Get list of fifos to delete
    // We defer the deletion as they are referenced by the nodes which we need
    // to delete first.
    std::vector<fifo::CreateOp> createOpsToDelete;
    for (size_t i = 0; i + 1 < chain.nodes.size(); ++i) {
      auto &node = chain.nodes[i];
      for (auto operand : node.getOperands()) {
        if (mlir::isa<fifo::InputPortType>(operand.getType())) {
          if (auto createOp = operand.getDefiningOp<fifo::CreateOp>()) {
            createOpsToDelete.push_back(createOp);
          }
        }
      }
    }

    // 4.2 Delete all CreateInstanceOps that are part of the chain
    for (auto &node : chain.nodes) {
      node.erase();
    }

    // 4.3 Delete all fifo create operations
    for (auto createOp : createOpsToDelete) {
      createOp.erase();
    }
  }
}

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

    createMergedActors(getOperation(), networkAnalysis);
    if (networkOp) {
      replaceChainInstancesWithMerged(networkOp, networkAnalysis);
    }
  }
};

} // namespace mlir::cal