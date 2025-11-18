#ifndef FLATTENNETWORKS_H
#define FLATTENNETWORKS_H

#include "mlir/Pass/Pass.h"

namespace mlir {

#define GEN_PASS_DECL_ELABORATECALCONNECTIONSPASS
#define GEN_PASS_DECL_FLATTENCALNETWORKSPASS
#include "Transforms/Passes.h.inc"

} // namespace mlir

#endif
