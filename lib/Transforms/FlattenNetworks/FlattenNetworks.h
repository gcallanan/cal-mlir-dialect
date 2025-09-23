#ifndef CAL_TRANSFORMS_FLATTENNETWORKS_H
#define CAL_TRANSFORMS_FLATTENNETWORKS_H

#include "mlir/Pass/Pass.h"
#include <memory>

namespace mlir {
std::unique_ptr<Pass> createFlattenCalNetworksPass();
} // namespace mlir

#endif // CAL_TRANSFORMS_FLATTENNETWORKS_H
