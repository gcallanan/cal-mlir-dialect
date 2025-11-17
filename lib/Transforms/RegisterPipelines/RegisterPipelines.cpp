#include "Transforms/Passes.h"
#include "Dialect/Cal/CalOps.h"
#include "mlir/IR/SymbolTable.h"
#include "mlir/Pass/Pass.h"
#include "mlir/Pass/PassManager.h"
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


    auto buildCalNetworkElabPipeline = [](OpPassManager &pm) {
    // Ensure initial ordering up to network-elements-elab as requested:
    // const-jit-resolve, cal-param-specialize, canonicalize,
    // const-jit-resolve, canonicalize,
    // infer-cal-instance-array-shape, canonicalize,
    // network-elements-elab
    // A: always-JIT const resolution (wrapper over CalConstEval for now)
    pm.addPass(createConstJITResolvePass());
    // B: specialize symbols on constant parameter tuples
    pm.addPass(createParamSpecializePass());
    pm.addPass(mlir::createCanonicalizerPass());
    // Re-run const evaluation after specialization to expose new constants
    pm.addPass(createConstJITResolvePass());
    pm.addPass(mlir::createCanonicalizerPass());
    // Infer static shapes for instance arrays before structural elaboration
    pm.addPass(createInferCalInstanceArrayShapePass());
    pm.addPass(mlir::createCanonicalizerPass());
    // C: network elements elaboration (entities/arrays only)
    pm.addPass(createNetworkElementsElabPass());
    pm.addPass(createInsertFanoutOnMultiSinkPass());
    // D: elaborate concrete entities prior to flatten so pruning can proceed
    //pm.addPass(createElaborateCalEntitiesPass());
    pm.addPass(mlir::createCanonicalizerPass());
    // E: flatten (now on elaborated IR) with forwarded options
    // Forward top selection from environment (set by cal-opt when users pass
    // --cal-network-elab=top=<sym> or --cal-network-elab-top=<sym>).
    // This avoids adding RTTI/CL opts to the pipeline lib and keeps a simple UX.
    FlattenCalNetworksPassOptions flOpts; // defaults unless env provided
    if (const char *topEnv = ::getenv("CAL_NETWORK_ELAB_TOP")) {
      if (topEnv && *topEnv) {
        flOpts.top = std::string(topEnv);
      }
    }
    pm.addPass(createFlattenCalNetworksPass(std::move(flOpts)));
    // NOTE: Force pruning of non-top networks removed due to build issues.
    // TODO: Reintroduce via a dedicated pass source file with proper cloning semantics.
    // Post-flatten cleanup to remove dead arrays/symbols
    pm.addPass(mlir::createCanonicalizerPass());
    //pm.addPass(mlir::createSymbolDCEPass());
    // Fanout synthesis and verification
    pm.addPass(createInsertFanoutOnMultiSinkPass());
    // F: verification & basic array fill checks
    pm.addPass(createVerifyInstanceArrayFillsPass());
    pm.addPass(createVerifyConnectPortsPass());
    pm.addPass(createVerifyInstanceArrayStaticUsagePass());
    //pm.addPass(mlir::createCanonicalizerPass());
    // (G conversion passes come from separate conversion pipeline invocations)
  };

    PassPipelineRegistration<> calNetworkElab(
      "cal-network-elab",
      "Unified full CAL network elaboration (experimental skeleton – options removed to avoid RTTI; configure individual passes directly)",
      buildCalNetworkElabPipeline);
}

} // namespace mlir
