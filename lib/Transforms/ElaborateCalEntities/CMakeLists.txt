add_mlir_dialect_library(ElaborateCalEntitiesPass
  ElaborateCalEntities.cpp

  DEPENDS
    CalGenericTransformationsPassesIncGen

  LINK_LIBS PUBLIC
    MLIRIR
    MLIRSupport
    MLIRPass
    MLIRArithDialect
    MLIRSCFDialect
    MLIRFuncDialect
    MLIRCal
)
