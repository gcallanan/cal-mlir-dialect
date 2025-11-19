add_mlir_dialect_library(CalViewInstancesPass
  CalViewInstances.cpp

  DEPENDS
    CalGenericTransformationsPassesIncGen

  LINK_LIBS PUBLIC
    MLIRIR
    MLIRSupport
    MLIRPass
    MLIRCal
    MLIRFifo
)
