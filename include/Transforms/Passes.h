#ifndef CAL_GENERIC_TRANSFORM_PASSES
#define CAL_GENERIC_TRANSFORM_PASSES

#include "Dialect/Cal/CalDialect.h"
#include "Dialect/Fifo/FifoDialect.h"
#include "Transforms/DenseConstantsToGPU/DenseConstantsToGPU.h"
#include "Transforms/GPUAwareBufferize/GPUAwareBufferize.h"
#include "Transforms/HoistAllocs/HoistAllocs.h"
#include "Transforms/CalPrepareGpuAsyncRegions/CalPrepareGpuAsyncRegions.h"
#include "Transforms/FifoAtomicize/FifoAtomicize.h"
#include "Transforms/FlattenNetworks/FlattenNetworks.h"
#include "mlir/Pass/Pass.h"

namespace mlir {

//===- Generated passes ---------------------------------------------------===//
// Forward declare constructors that are referenced by registration helpers here
// to avoid double-including the generated header across various pass headers.
// Legacy migration passes removed.
// New pass factories declared in Passes.td; provide prototypes here so
// users including this header can call them without including the generated
// Passes.h.inc in multiple places.
std::unique_ptr<mlir::Pass> createCalConstEvalPass();
std::unique_ptr<mlir::Pass> createConstJITResolvePass();
std::unique_ptr<mlir::Pass> createParamSpecializePass();
std::unique_ptr<mlir::Pass> createElaborateScfStructuresPass();
std::unique_ptr<mlir::Pass> createVerifyConnectPortsPass();
std::unique_ptr<mlir::Pass> createVerifyInstanceArrayFillsPass();
std::unique_ptr<mlir::Pass> createInferCalInstanceArrayShapePass();
std::unique_ptr<mlir::Pass> createInferCalDynamicStateShapesPass();
std::unique_ptr<mlir::Pass> createElaborateCalEntitiesPass();
std::unique_ptr<mlir::Pass> createElaborateCalConnectionsPass();
// Forward declare split elaboration pass option types (generated in Passes.h.inc)
class ElaborateCalConnectionsPrepPassOptions;
class ElaborateCalConnectionsFinalizePassOptions;
// Forward declare factory functions for split elaboration passes so that
// inline registration helpers in Passes.h.inc can reference them before their
// generated definitions.
std::unique_ptr<mlir::Pass> createElaborateCalConnectionsPrepPass();
std::unique_ptr<mlir::Pass> createElaborateCalConnectionsPrepPass(ElaborateCalConnectionsPrepPassOptions options);
std::unique_ptr<mlir::Pass> createElaborateCalConnectionsFinalizePass();
std::unique_ptr<mlir::Pass> createElaborateCalConnectionsFinalizePass(ElaborateCalConnectionsFinalizePassOptions options);
std::unique_ptr<mlir::Pass> createInsertFanoutOnMultiSinkPass();
std::unique_ptr<mlir::Pass> createNetworkElementsElabPass();
std::unique_ptr<mlir::Pass> createVerifyInstanceArrayStaticUsagePass();
std::unique_ptr<mlir::Pass> createPruneUnusedNetworksPass();
std::unique_ptr<mlir::Pass> createNormalizeCalConnectsPass();
std::unique_ptr<mlir::Pass> createCalViewInstancesPass();

// Emit registration functions.
#define GEN_PASS_REGISTRATION
#include "Transforms/Passes.h.inc"

// Register composite pipelines that stitch these passes together.
void registerCalGenericTransformationsPipelines();

//===----------------------------------------------------------------------===//

} // namespace mlir

#endif // CAL_GENERIC_TRANSFORM_PASSES