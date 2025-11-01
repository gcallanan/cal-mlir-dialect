add_mlir_dialect_library(VerifyConnectPortsPass
  VerifyConnectPorts.cpp

  DEPENDS
    CalGenericTransformationsPassesIncGen

  LINK_LIBS PUBLIC
    MLIRIR
    MLIRSupport
    MLIRPass
    MLIRArithDialect
    MLIRCal
    MLIRFifo
)
