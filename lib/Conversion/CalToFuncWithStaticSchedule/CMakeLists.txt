add_mlir_conversion_library(CalToFuncWithStaticSchedule
        CalToFuncWithStaticSchedule.cpp
        CycloStaticDataflowAnalysis.cpp
        FsmBuilder.cpp
        StaticNetworkSimulator.cpp

    DEPENDS
        CalConversionIncGen

    LINK_COMPONENTS
        Core

    LINK_LIBS PUBLIC
        MLIRDialectUtils
        MLIRTransformUtils
        MLIRFuncDialect
        MLIRControlFlowDialect
        Eigen3::Eigen
)