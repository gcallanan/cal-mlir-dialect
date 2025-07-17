add_mlir_conversion_library(GPUDeallocInterface
    GpuDeallocInterface.cpp

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