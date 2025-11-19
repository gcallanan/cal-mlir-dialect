add_mlir_conversion_library(CalLoweringPipelines
    CalLoweringPipelines.cpp

    DEPENDS
        CalConversionIncGen

    LINK_COMPONENTS
        Core

    LINK_LIBS PUBLIC
        MLIRDialectUtils
        MLIRTransformUtils
        MLIRFuncDialect
        MLIRControlFlowDialect
        # Ensure static resolution of pass factory symbols referenced here
        # by linking the corresponding pass libraries explicitly.
        VerifyConnectPortsPass
        FlattenNetworksPass
        ElaborateCalEntitiesPass
        ParamSpecializePass
        ConstJITResolvePass
        NetworkElementsElabPass
        InferCalInstanceArrayShapePass
        InsertFanoutOnMultiSinkPass
        NormalizeConnectsPass
        MLIRVerifyInstanceArrayFills
        PruneUnusedNetworksPass
)