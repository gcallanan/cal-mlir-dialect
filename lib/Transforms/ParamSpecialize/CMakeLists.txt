add_mlir_dialect_library(ParamSpecializePass
  ParamSpecialize.cpp

  DEPENDS
    CalGenericTransformationsPassesIncGen

  LINK_LIBS PUBLIC
    MLIRIR
    MLIRSupport
    MLIRPass
    MLIRFuncDialect
    MLIRArithDialect
    MLIRSCFDialect
    MLIRCal
    MLIRFifo
)
