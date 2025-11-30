#include "Dialect/Cal/CalDialect.h"
#include "Dialect/Fifo/FifoDialect.h"
#include "mlir/IR/MLIRContext.h"
#include "mlir/InitAllDialects.h"
#include "mlir/Tools/mlir-lsp-server/MlirLspServerMain.h"

#include "mlir/Dialect/Transform/IR/TransformDialect.h"
#include "mlir/Dialect/Linalg/TransformOps/DialectExtension.h"

using namespace mlir;

static int asMainReturnCode(LogicalResult r)
{
    return r.succeeded() ? EXIT_SUCCESS : EXIT_FAILURE;
}

int main(int argc, char* argv[])
{
    DialectRegistry registry;
    registerAllDialects(registry);
    
    registry.insert<cal::CalDialect>();
    registry.insert<fifo::FifoDialect>();
    registry.insert<mlir::transform::TransformDialect>();
    
    // Register transform dialect extensions for linalg operations
    mlir::linalg::registerTransformDialectExtension(registry);

    return asMainReturnCode(MlirLspServerMain(argc, argv, registry));
}