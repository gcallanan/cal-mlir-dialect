add_mlir_dialect_library(InferCalDynamicStateShapesPass
  InferCalDynamicStateShapes.cpp

  DEPENDS
    CalGenericTransformationsPassesIncGen

  LINK_LIBS PUBLIC
    MLIRIR
    MLIRSupport
    MLIRPass
    MLIRCal
    MLIRArithDialect
    MLIRTensorDialect
    MLIRMemRefDialect
)
