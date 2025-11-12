add_library(CalGenericTransformsPipelines STATIC
  RegisterPipelines.cpp
)

target_link_libraries(CalGenericTransformsPipelines
  PUBLIC
  MLIROptLib
  MLIRCal
  MLIRFifo
  ConstJITResolvePass
  ParamSpecializePass
  MLIRVerifyInstanceArrayFills
  VerifyConnectPortsPass
  InferCalInstanceArrayShapePass
  InsertFanoutOnMultiSinkPass
)
