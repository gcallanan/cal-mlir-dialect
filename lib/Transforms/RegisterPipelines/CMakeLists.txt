add_library(CalGenericTransformsPipelines STATIC
  RegisterPipelines.cpp
)

target_link_libraries(CalGenericTransformsPipelines
  PUBLIC
  MLIROptLib
  MLIRCal
  MLIRFifo
  MLIRVerifyInstanceArrayFills
  VerifyConnectPortsPass
  InferCalInstanceArrayShapePass
)
