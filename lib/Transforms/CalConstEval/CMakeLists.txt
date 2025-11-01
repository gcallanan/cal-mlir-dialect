add_mlir_dialect_library(CalConstEvalPass
  CalConstEval.cpp

  DEPENDS
    CalGenericTransformationsPassesIncGen

  LINK_LIBS PUBLIC
    MLIRIR
    MLIRSupport
    MLIRPass
    MLIRFuncDialect
    MLIRArithDialect
    MLIRSCFDialect
)
