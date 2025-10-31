add_mlir_dialect_library(LowerInstanceForPass
  LowerInstanceFor.cpp

  DEPENDS
    CalGenericTransformationsPassesIncGen

  LINK_LIBS PUBLIC
    MLIRIR
    MLIRSupport
    MLIRCal
    MLIRArithDialect
    MLIRPass
)
