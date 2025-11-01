add_mlir_dialect_library(ElaborateScfStructuresPass
  ElaborateScfStructures.cpp

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
