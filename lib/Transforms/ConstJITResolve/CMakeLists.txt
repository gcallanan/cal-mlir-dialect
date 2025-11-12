add_mlir_dialect_library(ConstJITResolvePass
  ConstJITResolve.cpp

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
