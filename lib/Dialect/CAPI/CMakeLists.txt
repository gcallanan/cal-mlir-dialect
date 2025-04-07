add_mlir_public_c_api_library(CalCAPI
  Dialects.cpp
  LINK_LIBS PUBLIC
  MLIRCal
  MLIRFifo
)
