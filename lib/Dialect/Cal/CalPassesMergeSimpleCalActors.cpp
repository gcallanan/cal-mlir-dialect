//===- CalPassesMergeSimpleCalActors.cpp ----------------------*- C++ -*-===//
// Deprecated no-op pass to preserve the legacy flag --merge-simple-cal-actors.
//===----------------------------------------------------------------------===//

#include "mlir/IR/BuiltinOps.h"
#include "mlir/Pass/Pass.h"

using namespace mlir;

namespace mlir::cal {

struct MergeSimpleCalActorsPass
		: public PassWrapper<MergeSimpleCalActorsPass, OperationPass<ModuleOp>> {
	MLIR_DEFINE_EXPLICIT_INTERNAL_INLINE_TYPE_ID(MergeSimpleCalActorsPass)
	StringRef getArgument() const final { return "merge-simple-cal-actors"; }
	StringRef getDescription() const final {
		return "Deprecated: no-op; superseded by the static scheduling pass.";
	}
	void runOnOperation() override {}
};

// A no-op symbol to force-link this translation unit when referenced
void forceRegisterLegacyMergeSimpleCalActorsPass() {}

} // namespace mlir::cal

namespace {
PassRegistration<mlir::cal::MergeSimpleCalActorsPass> reg;
} // namespace