#include "Transforms/Passes.h"
#include "mlir/Pass/PassManager.h"
#include "mlir/Pass/Pass.h"
#include "mlir/Pass/PassRegistry.h"
#include "mlir/Transforms/Passes.h"

namespace mlir {

// A simple structural elaboration pipeline:
//  1) cal-const-eval
//  2) resolve-instance-if
//  3) lower-instance-for
//  4) elaborate-scf-structures
static void buildCalStructuralElabPipeline(OpPassManager &pm) {
  pm.addPass(createCalConstEvalPass());
  // Legacy passes (resolve-instance-if, lower-instance-for) removed.
  // Infer static shapes for instance arrays, then elaborate entities
  pm.addPass(createInferCalInstanceArrayShapePass());
  // Elaborate entities (instances/arrays) first to remove loop shells while
  // preserving array SSA, then elaborate structural SCF for connections and sugar.
  pm.addPass(createElaborateCalEntitiesPass());
  // Normalize multi-sink connections early (before structural expansion)
  pm.addPass(createInsertFanoutOnMultiSinkPass());
  pm.addPass(createElaborateScfStructuresPass());
  // Bounds and basic completeness verification for instance arrays
  pm.addPass(createVerifyInstanceArrayFillsPass());
  // Late verification: ensure connect port names match entity/interface ports
  pm.addPass(createVerifyConnectPortsPass());
}

// Stage-1 elaboration pipeline used in fft experiments:
//  cal-const-eval
//  canonicalize
//  elaborate-scf-structures
//  canonicalize
//  flatten-cal-networks
//  canonicalize
//  elaborate-scf-structures
//  canonicalize
//  cal-const-eval   (late const-eval after flatten)
//  cse
//  verify-instance-array-fills, verify-connect-ports (sanity)
static void buildCalElaborateStage1Pipeline(OpPassManager &pm) {
  pm.addPass(createCalConstEvalPass());
  pm.addPass(mlir::createCanonicalizerPass());
  pm.addPass(createInferCalInstanceArrayShapePass());
  pm.addPass(createElaborateCalEntitiesPass());
  pm.addPass(createInsertFanoutOnMultiSinkPass());
  pm.addPass(createElaborateScfStructuresPass());
  pm.addPass(mlir::createCanonicalizerPass());
  pm.addPass(createFlattenCalNetworksPass());
  pm.addPass(mlir::createCanonicalizerPass());
  pm.addPass(createElaborateCalEntitiesPass());
  pm.addPass(createInsertFanoutOnMultiSinkPass());
  pm.addPass(createElaborateScfStructuresPass());
  pm.addPass(mlir::createCanonicalizerPass());
  pm.addPass(createCalConstEvalPass());
  pm.addPass(mlir::createCSEPass());
  pm.addPass(createVerifyInstanceArrayFillsPass());
  pm.addPass(createVerifyConnectPortsPass());
}

void registerCalGenericTransformationsPipelines() {
  PassPipelineRegistration<> calStructElab(
      "cal-structural-elaboration",
      "Const-evaluate and elaborate structural scf constructs in CAL networks",
      [](OpPassManager &pm) { buildCalStructuralElabPipeline(pm); });

  PassPipelineRegistration<> calElabStage1(
      "cal-elaborate-stage1",
      "Parent-aware const-parameter specialization + SCF-first elaboration + flatten + late const-eval (Stage 1)",
      [](OpPassManager &pm) { buildCalElaborateStage1Pipeline(pm); });

  // New unified full elaboration pipeline (WORK IN PROGRESS): cal-network-elab
  // Target ordering (final goal):
  //   A  ConstJITResolvePass          (always JIT – replaces CalConstEval)
  //   B  ParamSpecializePass          (stable cloning of cal.actor/network)
  //   C  NetworkElementsElabPass      (entity/array structuralization: extract arrays from loops, fold const scf.if)
  //   E  NetworkFlattenPass           (symbolic flatten only)
  //   Fanout InsertFanoutAfterFlatten (mandatory symbolic fanout synthesis)
  //   D  NetworkElaboratePass         (materialize fifo.create + cal.create_instance)
  //   F  ReachabilityPruneAndVerify   (pruning + port + connectivity checks)
  //   G  (later conversion pipeline, not part of this transform pipeline)
  // Until the new passes land we approximate with existing ones:
  //   - CalConstEvalPass stands in for A
  //   - (no separate B yet)
  //   - ElaborateScfStructuresPass approximates C
  //   - FlattenCalNetworksPass approximates E (still performs some concrete work today)
  //   - InsertFanoutOnMultiSinkPass acts as Fanout (multi-sink normalization)
  //   - ElaborateCalEntitiesPass approximates D (entity elaboration)
  //   - VerifyConnectPortsPass + VerifyInstanceArrayFillsPass partially cover F
  // NOTE: As refactors land, replace these with the dedicated passes and adjust ordering.
  auto buildCalNetworkElabPipeline = [](OpPassManager &pm) {
    // A: always-JIT const resolution (wrapper over CalConstEval for now)
    pm.addPass(createConstJITResolvePass());
    // B: specialize symbols on constant parameter tuples
    pm.addPass(createParamSpecializePass());
    // C0: early shape inference for instance arrays (static extent upgrade)
    //     This ensures subsequent structural passes (loop unrolling / entity elaboration)
    //     see static shapes and do not mutate array element types themselves.
    pm.addPass(createInferCalInstanceArrayShapePass());
    // C: network elements elaboration placeholder (entities/arrays only)
    pm.addPass(createElaborateScfStructuresPass());
    pm.addPass(createNetworkElementsElabPass());
    // E: flatten (currently also does some elaboration; will be split later)
  pm.addPass(createFlattenCalNetworksPass());
  pm.addPass(createInsertFanoutOnMultiSinkPass());
  // D: concrete entity elaboration placeholder
  pm.addPass(createElaborateCalEntitiesPass());
    // F: verification & basic array fill checks (pruning to be centralized later)
  pm.addPass(createVerifyInstanceArrayFillsPass());
  pm.addPass(createVerifyConnectPortsPass());
  pm.addPass(createVerifyInstanceArrayStaticUsagePass());
    // (G conversion passes come from separate conversion pipeline invocations)
  };

  PassPipelineRegistration<> calNetworkElab(
      "cal-network-elab",
      "Unified full CAL network elaboration (experimental skeleton – will migrate to dedicated passes: ConstJITResolve, ParamSpecialize, StructuralLoopElab, NetworkFlatten, Fanout, NetworkElaborate, ReachabilityPruneAndVerify)",
      buildCalNetworkElabPipeline);
}

} // namespace mlir
