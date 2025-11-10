add_mlir_dialect_library(InferCalInstanceArrayShapePass
  InferCalInstanceArrayShape.cpp

  DEPENDS
    CalGenericTransformationsPassesIncGen

  LINK_LIBS PUBLIC
    MLIRIR
    MLIRSupport
    MLIRPass
    MLIRSCFDialect
    MLIRArithDialect
  MLIRCal
)
