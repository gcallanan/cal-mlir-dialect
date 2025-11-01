add_mlir_dialect_library(ResolveInstanceIfPass
  ResolveInstanceIf.cpp

  DEPENDS
    CalGenericTransformationsPassesIncGen

  LINK_LIBS PUBLIC
    MLIRIR
    MLIRSupport
    MLIRCal
    MLIRArithDialect
    MLIRPass
)
