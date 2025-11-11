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
//  cal-const-eval   (late fold e.g. pow2 after flatten)
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
}

} // namespace mlir
