add_mlir_library(InsertFanoutOnMultiSinkPass
  InsertFanoutOnMultiSink.cpp

  LINK_COMPONENTS
  Core

  LINK_LIBS PUBLIC
  MLIRIR
  MLIRArithDialect
  MLIRSCFDialect
  MLIRFuncDialect
  MLIRSupport
  MLIRCal
  MLIRFifo
)
