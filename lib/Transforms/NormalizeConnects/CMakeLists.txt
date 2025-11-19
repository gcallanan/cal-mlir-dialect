add_mlir_library(NormalizeConnectsPass
  NormalizeConnects.cpp

  LINK_COMPONENTS
  Core

  LINK_LIBS PUBLIC
  MLIRIR
  MLIRArithDialect
  MLIRSupport
  MLIRCal
)
