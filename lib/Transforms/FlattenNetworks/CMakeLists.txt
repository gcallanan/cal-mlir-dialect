add_mlir_dialect_library(FlattenNetworksPass
  FlattenNetworks.cpp

  DEPENDS
    CalGenericTransformationsPassesIncGen

  LINK_LIBS PUBLIC
    MLIRIR
    MLIRFuncDialect
    MLIRSupport
    MLIRSCFDialect
    MLIRArithDialect
    MLIRPass
    MLIRCal
)
