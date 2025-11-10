get_property(dialect_libs GLOBAL PROPERTY MLIR_DIALECT_LIBS)
get_property(conversion_libs GLOBAL PROPERTY MLIR_CONVERSION_LIBS)
set(LIBS
        ${dialect_libs}
        ${conversion_libs}
        MLIRArithDialect
        MLIRTensorDialect
        MLIRAsyncDialect
        MLIRAsyncTransforms
        MLIRExecutionEngine
        MLIRExecutionEngineUtils
        MLIROptLib
        MLIRCal
        MLIRFifo
        CalGenericTransformsPipelines
        #MLIRFifoAtomicize
        #FlattenNetworksPass
        )
add_llvm_executable(cal-opt cal-opt.cpp)

llvm_update_compile_flags(cal-opt)
target_link_libraries(cal-opt
        PRIVATE
        MLIRGPUToLLVMIRTranslation
        MLIRLLVMToLLVMIRTranslation
        MLIRNVVMToLLVMIRTranslation
        MLIRExecutionEngine
        MLIRExecutionEngineUtils
        InferCalInstanceArrayShapePass
        ${LIBS}
        )

mlir_check_all_link_libraries(cal-opt)
