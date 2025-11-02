add_mlir_library(MLIRVerifyInstanceArrayFills
  VerifyInstanceArrayFills.cpp

  DEPENDS
  CalGenericTransformationsIncGen

  LINK_LIBS PUBLIC
  MLIRCal
  MLIRArithDialect
  MLIRIR
)
