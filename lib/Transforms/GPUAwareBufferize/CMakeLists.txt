add_mlir_conversion_library(GPUAwareBufferize
    GPUAwareBufferize.cpp

    DEPENDS
        CalGenericTransformationsIncGen

    LINK_COMPONENTS
        Core

    LINK_LIBS PUBLIC
        MLIRDialectUtils
        MLIRTransformUtils
        MLIRFuncDialect
        MLIRControlFlowDialect
)