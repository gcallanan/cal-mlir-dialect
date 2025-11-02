#include "Transforms/Passes.h"
#include "mlir/Pass/PassManager.h"
#include "mlir/Pass/Pass.h"
#include "mlir/Pass/PassRegistry.h"

namespace mlir {

// A simple structural elaboration pipeline:
//  1) cal-const-eval
//  2) resolve-instance-if
//  3) lower-instance-for
//  4) elaborate-scf-structures
static void buildCalStructuralElabPipeline(OpPassManager &pm) {
  pm.addPass(createCalConstEvalPass());
  pm.addPass(createResolveInstanceIfPass());
  pm.addPass(createLowerInstanceForPass());
  pm.addPass(createElaborateScfStructuresPass());
  // Bounds and basic completeness verification for instance arrays
  pm.addPass(createVerifyInstanceArrayFillsPass());
  // Late verification: ensure connect port names match entity/interface ports
  pm.addPass(createVerifyConnectPortsPass());
}

void registerCalGenericTransformationsPipelines() {
  PassPipelineRegistration<> calStructElab(
      "cal-structural-elaboration",
      "Const-evaluate and elaborate structural scf constructs in CAL networks",
      [](OpPassManager &pm) { buildCalStructuralElabPipeline(pm); });
}

} // namespace mlir
