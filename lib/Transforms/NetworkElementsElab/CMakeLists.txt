add_mlir_dialect_library(NetworkElementsElabPass
  NetworkElementsElab.cpp

  DEPENDS
    CalGenericTransformationsPassesIncGen

  LINK_LIBS PUBLIC
    MLIRIR
    MLIRPass
    MLIRArithDialect
    MLIRSCFDialect
    MLIRCal
)
