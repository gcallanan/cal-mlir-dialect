add_mlir_conversion_library(CalToFuncWithStaticSchedule
        CalToFuncWithStaticSchedule.cpp
        CycloStaticDataflowAnalysis.cpp

    DEPENDS
        CalConversionIncGen

    LINK_COMPONENTS
        Core

    LINK_LIBS PUBLIC
        MLIRDialectUtils
        MLIRTransformUtils
        MLIRFuncDialect
        MLIRControlFlowDialect
)