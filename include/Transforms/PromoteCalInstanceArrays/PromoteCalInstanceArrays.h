#pragma once

#include <memory>

namespace mlir {
class Pass;

// Factory for instance array shape inference (shape-only, no unrolling).
std::unique_ptr<Pass> createInferCalInstanceArrayShapePass();

} // namespace mlir
