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
#include <queue>

namespace mlir::cal {
#define GEN_PASS_DEF_MERGESIMPLECALACTORS
#include "Dialect/Cal/CalPasses.h.inc"

// An edge in the actor graph, from src to dst.
struct Edge {
  cal::CreateInstanceOp src;
  cal::CreateInstanceOp dst;
};

// A chain of simple actors to be merged.
struct Chain {
  std::vector<cal::CreateInstanceOp> nodes;
};

// This function analyzes a cal.create_instance operation to discover all
// outgoing edges (connections) from the given source instance to other
// actor instances in the network. It traverses the FIFO connections by
// examining the source instance's input port operands, following the
// corresponding FIFO create operations to their output ports, and then
// identifying which other create_instance operations consume from those
// output ports.
//
// Input example:
//   cal.network {
//     %in1, %out1 = fifo.create<i32> (3) : !fifo.input_port<i32>,
//     !fifo.output_port<i32> %in2, %out2 = fifo.create<i32> (3) :
//     !fifo.input_port<i32>, !fifo.output_port<i32> cal.create_instance @actorA
//     "instA" () ports_out (%in1 : !fifo.input_port<i32>) cal.create_instance
//     @actorB "instB" (%out1 : !fifo.output_port<i32>) ports_out (%in2 :
//     !fifo.input_port<i32>) cal.create_instance @actorC "instC" (%out2 :
//     !fifo.output_port<i32>)
//   }
//
// For sourceInstance "instB", this function would return:
//   Edge{src: instB, dst: instC} - representing the connection from instB to
//   instC via the FIFO
std::vector<Edge> getOutputEdges(cal::CreateInstanceOp sourceInstance) {
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

// NetworkAnalysis is an analysis that constructs a graph representation of
// actor instances and their FIFO connections within a cal.network operation,
// and provides algorithms to identify chains of simple actors that can be
// merged for optimization.
//
// It performs two primary functions:
//
// 1. Graph Construction: The constructor traverses the network to collect all
//    cal.create_instance operations as nodes and builds a complete edge list
//    representing FIFO connections between actor instances. Each edge
//    represents a data flow path from one actor's output port to another
//    actor's input port via FIFO operations.
//
// 2. Chain Detection: The `generateChains()` method analyzes the constructed
//    graph to identify sequential chains of "simple" actors that can be merged.
//    Simple actors are defined as having a single action, single input port,
//    and single output port. The algorithm finds maximal chains of such actors
//    that are connected in sequence, which can then be fused into single
//    merged actors to reduce network complexity and improve performance.
//
// The analysis supports both linear chains (simple actors connected in
// sequence) and cyclic chains (simple actors forming closed loops), enabling
// comprehensive optimization of dataflow networks with predictable
// communication patterns.
//
// This analysis is used by the MergeSimpleCalActors transformation pass to
// guide actor fusion optimizations.
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
      auto outputEdges = getOutputEdges(createInstanceOp);
      edges.insert(edges.end(), outputEdges.begin(), outputEdges.end());
    }
  }

  // This method analyzes the constructed graph to identify maximal chains of
  // "simple" actors that can be merged for optimization. Simple actors are
  // defined as having a single action, single input port, and single output
  // port. The algorithm finds both linear chains (sequences of simple actors)
  // and cyclic chains (closed loops of simple actors).
  //
  // The algorithm works in two phases:
  //
  // Phase 1: Linear Chain Detection
  // - Starts from non-simple actors (branch points or endpoints)
  // - Follows outgoing edges to identify sequences of connected simple actors
  // - Terminates chains when reaching another non-simple actor or a cycle
  // - Each chain represents a sequence that can be fused into a single actor
  //
  // Phase 2: Cyclic Chain Detection
  // - Identifies remaining unvisited edges that form pure cycles of simple
  // actors
  // - These cycles have no non-simple entry points, so they're detected
  // separately
  // - Handles the case where simple actors form closed loops
  //
  // Input example network:
  //   NonSimpleA -> SimpleB -> SimpleC -> SimpleD -> NonSimpleE
  //
  // This would generate:
  //   Chain 1: [SimpleB, SimpleC, SimpleD] (linear chain)
  //
  // Returns a vector of Chain objects, each containing a sequence of
  // cal::CreateInstanceOp nodes that can be merged into a single actor.
  std::vector<Chain> generateChains() {
    const int num_nodes = static_cast<int>(nodes.size());
    const int m = static_cast<int>(edges.size());

    // 1. Give each node an integer ID.
    llvm::DenseMap<cal::CreateInstanceOp, int> id;
    id.reserve(num_nodes * 2);
    for (int i = 0; i < num_nodes; ++i) {
      id[nodes[i]] = i;
    }

    // 2. Build a list of edges with integer IDs and adjaceny matrix by edge
    // index.
    std::vector<std::pair<int, int>> edgesList_int;
    edgesList_int.reserve(m);
    std::vector<std::vector<int>> adjacency_matrix(num_nodes);
    for (int i = 0; i < m; ++i) {
      auto src = id.find(edges[i].src);
      auto dst = id.find(edges[i].dst);
      assert(src != id.end() && dst != id.end() &&
             "edge endpoint not found in nodes[]");
      const int u = src->second;
      const int v = dst->second;
      edgesList_int.emplace_back(u, v);
      adjacency_matrix[u].push_back(i);
    }

    auto isSimpleActor = [&](int v) -> bool {
      return nodes[v].getActor().isSimpleActor();
    };
    // The degree of outgoing edges for a node
    auto degreeOutgoingEdges = [&](int v) -> int {
      return nodes[v].getActor().outDegree();
    };

    // 4. Generate list of chains. We generate chains starting from non-simple
    // nodes as any simple node at the start of the chains must have a
    // non-simple predecessor.
    std::vector<bool> used(m, 0); // mark edges when consumed
    std::vector<Chain> result;

    for (int u = 0; u < num_nodes; ++u) {
      // 4.1 Determine if this is an actor to start from
      if (degreeOutgoingEdges(u) == 0)
        continue;
      if (isSimpleActor(u))
        continue; // start only from branch/dead-end nodes

      // 4.2 Explore each outgoing edge
      // from this non-simple actor to find chains of simple actors.
      // Each edge is the start of a potential chain.
      for (int edge_i : adjacency_matrix[u]) {
        if (used[edge_i])
          continue;

        std::vector<int> chainOfNodes; // simple nodes only
        int currentEdge = edge_i;

        // 4.2.1 Follow the edge to the next node, building the chain until
        // reaching a non-simple actor or a previously visited edge.
        while (true) {
          used[currentEdge] = true;
          int destinationNode = edgesList_int[currentEdge].second;

          if (isSimpleActor(destinationNode)) {
            chainOfNodes.push_back(destinationNode);

            // simple => exactly one outgoing edge
            assert(degreeOutgoingEdges(destinationNode) == 1 &&
                   "simple node should have outDegree==1");
            assert(!adjacency_matrix[destinationNode].empty() &&
                   "adjacency must have the unique outgoing edge");
            int nextEdge = adjacency_matrix[destinationNode][0];
            if (used[nextEdge])
              break; // already traversed elsewhere (safety)
            currentEdge = nextEdge;
          } else {
            // Hit a non-simple endpoint; do not include it.
            break;
          }
        }

        // 4.3 If we found a chain, add it to the result.
        if (!chainOfNodes.empty()) {
          Chain chain;
          chain.nodes.reserve(chainOfNodes.size());
          for (int idv : chainOfNodes)
            chain.nodes.push_back(nodes[idv]);
          result.push_back(std::move(chain));
        }
      }
    }

    // 4. After step 3, we’ve already walked from every non-simple node (branch
    // or dead-end) and collected the simple runs that follow them. What remains
    // unvisited can only be edges whose endpoints are all simple (1-in,1-out),
    // which implies they form one or more pure directed cycles (rings). Those
    // cycles have no non-simple “entry” node to start from, so we detect them
    // explicitly. I am not sure if this is useful in practice.
    for (int s = 0; s < num_nodes; ++s) {
      if (!isSimpleActor(s) || degreeOutgoingEdges(s) == 0)
        continue;
      assert(!adjacency_matrix[s].empty() &&
             "simple node should have one outgoing edge in adjacency");
      int e0 = adjacency_matrix[s][0];
      if (used[e0])
        continue;

      std::vector<int> cycIds;
      int v = s;
      while (true) {
        cycIds.push_back(v); // all nodes here are simple
        int edge = adjacency_matrix[v][0];
        used[edge] = 1;
        v = edgesList_int[edge].second;

        if (v == s)
          break; // closed the loop
        if (!isSimpleActor(v))
          break;
        if (adjacency_matrix[v].empty())
          break;
        if (used[adjacency_matrix[v][0]])
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

  // Debugging helpers to print the graph structure
  void printEdges() {
    llvm::outs() << "Network edges:\n";
    for (auto &edge : edges) {
      llvm::outs() << "  " << edge.src.getInstanceNameAttr().getValue()
                   << " -> " << edge.dst.getInstanceNameAttr().getValue()
                   << "\n";
    }
  }

  // Print the detected chains of simple actors
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

// Create a unique name for the merged actor based on the names of the actors
// in the chain.
std::string createMergedActorName(Chain &chain) {
  std::string mergedActorName = "merged_actor_";
  for (size_t i = 0; i < chain.nodes.size(); ++i) {
    if (i > 0)
      mergedActorName += "_";
    mergedActorName += chain.nodes[i].getInstanceNameAttr().getValue().str();
  }
  return mergedActorName;
}

// This transformation creates new merged actor definitions for each chain of
// simple actors identified by NetworkAnalysis. It combines the functionality
// of multiple simple actors into single, optimized actors that eliminate
// intermediate FIFO operations and reduce network complexity.
//
// Input: A module containing individual simple actors (each with single action,
// single input port, and single output port) that have been identified as part
// of mergeable chains by the NetworkAnalysis.
//
// Output: New merged actor definitions are added to the module. Each merged
// actor consolidates the initialization code and action logic from all actors
// in its chain, creating a single actor that performs the equivalent
// computation without intermediate FIFO operations.
//
// Transformation Details:
//   1. For each chain of 2+ simple actors, create a new merged actor definition
//   2. Combine argument lists: include input ports from the first actor,
//      output ports from the last actor, and non-port arguments from all actors
//   3. Merge initialization code: clone all non-action operations from each
//      actor in sequence order
//   4. Merge action logic: create a single action that chains the computations,
//      using a token store to pass intermediate values between actor stages
//   5. Handle FIFO operations: eliminate intermediate push/pop pairs by
//   directly
//      passing tokens through the computation chain
//
// Example Input (from chain detection):
//   Chain: [cat_and_broadcast_2, f_0_5, cat_and_boundary_3, integrate_4]
//
//   cal.actor @cat_and_broadcast() ports_in(%arg0:
//   !fifo.output_port<tensor<1x1000000xf64>>)
//                                   ports_out(%arg1:
//                                   !fifo.input_port<tensor<1x1000000xf64>>) {
//     %state = cal.create_state_var<i32> : !cal.state_ref<i32>
//     cal.action {
//         %0 = fifo.pop(%arg0);
//         %concat = tensor.concat dim(0) %0
//         fifo.push(%arg1, %concat)
//     }
//   }
//   // ... similar definitions for f_0_5, cat_and_boundary_3, integrate_4
//
// Example Output:
//   cal.actor
//   @merged_actor_cat_and_broadcast_2_f_0_5_cat_and_boundary_3_integrate_4()
//     ports_in(%arg0: !fifo.output_port<tensor<1x1000000xf64>>)
//     ports_out(%arg1: !fifo.input_port<tensor<1x1000000xf64>>) {
//     %0 = cal.create_state_var<i32> : !cal.state_ref<i32>  // from first actor
//     %1 = cal.create_state_var<i32> : !cal.state_ref<i32>  // from second
//     actor cal.action "merged_action" priority=0 {
//       %2 = fifo.pop(%arg0)                    // from first actor
//       %concat = tensor.concat dim(0) %2       // from first actor
//       // intermediate fifo.push/pop eliminated - token passed directly
//       %concat_0 = tensor.concat dim(0) %concat // from second actor
//       %padded = tensor.pad %concat_0 ...      // from third actor
//       %5 = linalg.conv_1d_ncw_fcw ...         // from fourth actor
//       %collapsed = tensor.collapse_shape %5   // from fourth actor
//       fifo.push(%arg1, %collapsed)           // to final output
//     }
//   }
//
// NOTE: This implementation was created with the aid of ChatGPT-5.
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
        /*priority=*/builder.getI32IntegerAttr(0));
    Block *mergedActionBody = &mergedAction.getBody().emplaceBlock();
    builder.setInsertionPointToStart(mergedActionBody);
    std::queue<Value> tokenStore;
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
              tokenStore.push(mappedToken);
            } else if (!isFirst && isPop) {
              fifo::Pop popOp = llvm::dyn_cast<fifo::Pop>(&bodyOp);
              Value poppedToken = tokenStore.front();
              tokenStore.pop();
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

// This transformation replaces chains of simple actor instances in a network
// with single merged actor instances, and removes the intermediate FIFO
// connections that are no longer needed. It works in conjunction with
// `createMergedActors` to complete the actor fusion optimization by updating
// the network topology.
//
// Input: A `cal.network` containing chains of simple actor instances connected
// by FIFO operations, where the merged actor definitions have already been
// created by `createMergedActors`.
//
// Output: The network is updated to replace each chain of simple actor
// instances with a single `cal.create_instance` operation that references the
// corresponding merged actor. All intermediate FIFO operations between actors
// in the chain are removed, leaving only the external connections (input to
// first actor, output from last actor).
//
// Transformation Details:
//   1. For each detected chain, create a new `cal.create_instance` operation
//      that references the merged actor definition
//   2. Combine operand lists: include input connections to the first actor,
//      output connections from the last actor, and non-port operands from all
//      actors in the chain
//   3. Remove intermediate FIFO operations: delete `fifo.create` operations
//      that connected actors within the chain
//   4. Remove original actor instances: delete all `cal.create_instance`
//      operations that were part of the merged chain
//
// Example Input (from test case):
//   cal.network {
//     %inputPort_8, %outputPort_9 = fifo.create<tensor<1x1000000xf64>>(1) : ...
//     %inputPort_6, %outputPort_7 = fifo.create<tensor<1x1000000xf64>>(1) : ...
//     %inputPort_4, %outputPort_5 = fifo.create<tensor<1x1000002xf64>>(1) : ...
//     %inputPort_2, %outputPort_3 = fifo.create<tensor<1x1000002xf64>>(1) : ...
//     %inputPort_0, %outputPort_1 = fifo.create<tensor<1x1000000xf64>>(1) : ...
//
//     cal.create_instance @cat_and_broadcast "cat_and_broadcast_2" ()
//         ports_in (%outputPort_1 : !fifo.output_port<tensor<1x1000000xf64>>)
//         ports_out (%inputPort_2 : !fifo.input_port<tensor<1x1000000xf64>>)
//     cal.create_instance @f_0 "f_0_5" ()
//         ports_in (%outputPort_3 : !fifo.output_port<tensor<1x1000000xf64>>)
//         ports_out (%inputPort_4 : !fifo.input_port<tensor<1x1000000xf64>>)
//     cal.create_instance @cat_and_boundary "cat_and_boundary_3" ()
//         ports_in (%outputPort_5 : !fifo.output_port<tensor<1x1000000xf64>>)
//         ports_out (%inputPort_6 : !fifo.input_port<tensor<1x1000002xf64>>)
//     cal.create_instance @integrate "integrate_4" ()
//         ports_in (%outputPort_7 : !fifo.output_port<tensor<1x1000002xf64>>)
//         ports_out (%inputPort_8 : !fifo.input_port<tensor<1x1000000xf64>>)
//   }
//
// Example Output:
//   cal.network {
//     %inputPort_8, %outputPort_9 = fifo.create<tensor<1x1000000xf64>>(1) : ...
//     %inputPort_0, %outputPort_1 = fifo.create<tensor<1x1000000xf64>>(1) : ...
//     // intermediate FIFOs removed
//
//     cal.create_instance
//     @merged_actor_cat_and_broadcast_2_f_0_5_cat_and_boundary_3_integrate_4
//     "merged_instance_0" ()
//         ports_in (%outputPort_1 : !fifo.output_port<tensor<1x1000000xf64>>)
//         ports_out (%inputPort_8 : !fifo.input_port<tensor<1x1000000xf64>>)
//     // original chain instances removed
//   }
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
    builder.create<cal::CreateInstanceOp>(
        builder.getUnknownLoc(), builder.getStringAttr(mergedActorName),
        /*instanceName=*/builder.getStringAttr(instanceName), mergedOperands);

    // 4. Delete all fifos and nodes in the chain
    // 4.1 Get list of fifos to delete
    // We defer the deletion as they are referenced by the nodes which we need
    // to delete first.
    std::vector<fifo::CreateOp> createFifoOpsToDelete;
    for (size_t i = 0; i + 1 < chain.nodes.size(); ++i) {
      auto &node = chain.nodes[i];
      for (auto operand : node.getOperands()) {
        if (mlir::isa<fifo::InputPortType>(operand.getType())) {
          if (auto createOp = operand.getDefiningOp<fifo::CreateOp>()) {
            createFifoOpsToDelete.push_back(createOp);
          }
        }
      }
    }

    // 4.2 Delete all CreateInstanceOps that are part of the chain
    for (auto &node : chain.nodes) {
      node.erase();
    }

    // 4.3 Delete all fifo create operations
    for (auto createOp : createFifoOpsToDelete) {
      createOp.erase();
    }
  }
}

// This transformation pass optimizes Cal dataflow networks by identifying and
// merging chains of simple actors into single, more efficient merged actors.
// Simple actors are defined as having exactly one action, one input port, and
// one output port. The pass eliminates intermediate FIFO operations between
// chained simple actors, reducing network complexity and improving performance.
//
// Input: A Cal module containing actor definitions and a `cal.network` with
// multiple `cal.create_instance` operations connected by FIFO channels. Some
// of these actor instances may form chains of simple actors that can be merged.
//
// Output: The module is updated with new merged actor definitions, and the
// network topology is simplified by replacing chains of simple actor instances
// with single merged instances. Intermediate FIFO operations are removed.
//
// Transformation Details:
//   1. Analyze the network topology using NetworkAnalysis to identify chains
//      of simple actors connected in sequence
//   2. Create new merged actor definitions that combine the functionality of
//      entire chains into single actors
//   3. Replace chains of actor instances in the network with single merged
//      instances
//   4. Remove intermediate FIFO operations that are no longer needed
//   5. Preserve external connections (inputs to first actor, outputs from
//      last actor in each chain)
//
// The pass operates in two main phases:
//   - Actor Creation Phase: `createMergedActors()` generates new actor
//     definitions by combining initialization code and action logic from
//     all actors in each detected chain
//   - Network Update Phase: `replaceChainInstancesWithMerged()` updates the
//     network topology by replacing chain instances with merged instances
//     and removing intermediate FIFOs
//
// Example transformation:
//   Input network with chain: actorA -> actorB -> actorC -> actorD -> actorE
//   Output network: actorA -> merged_actor_B_C_D (single instance) -> actorE
//
//   This reduces the number of actor instances from 5 to 3 and eliminates
//   2 intermediate FIFO operations, while preserving the same computational
//   semantics.
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