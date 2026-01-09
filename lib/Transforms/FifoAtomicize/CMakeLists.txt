add_mlir_dialect_library(MLIRFifoAtomicize
  FifoMemrefAtomicize.cpp

  ADDITIONAL_HEADER_DIRS
  ${MLIR_MAIN_INCLUDE_DIR}/mlir/Transforms/FifoAtomicize

  DEPENDS
  CalGenericTransformationsPassesIncGen

  LINK_LIBS PUBLIC
  MLIRIR
  MLIRArithDialect
  MLIRMemRefDialect
  MLIRPass
  MLIRSupport
  MLIRTransformUtils
)