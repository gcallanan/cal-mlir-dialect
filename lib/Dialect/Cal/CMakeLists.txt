add_mlir_dialect_library(MLIRCal
        CalTypes.cpp
        CalDialect.cpp
        CalOps.cpp
        CalPassesMergeSimpleCalActors.cpp
        CalPassesHoistCalStateOutOfActor.cpp
        CalPassesInsertCalPortPredicates.cpp
        CalPassesConvertActionsToExecutionBodies.cpp
        CalPassesLowerFsmToExecutionBody.cpp
        CalPassesInferCalDynamicStateShapes.cpp
        CalPassesDetectRecursiveTypes.cpp
        CalPassesInsertArenas.cpp
        CalPassesInsertRCForState.cpp
        CalPassesMaterializeRCOps.cpp
        BufferizableOpInterfaceImpl.cpp

        ADDITIONAL_HEADER_DIRS
        ${PROJECT_SOURCE_DIR}/include/Cal

        DEPENDS
        MLIRCalOpsIncGen
        MLIRCalPassesIncGen

        LINK_LIBS PUBLIC
        MLIRIR
        MLIRInferTypeOpInterface
        MLIRFuncDialect
        MLIRTransforms
        MLIRBufferizationDialect
        MLIRBufferizationTransforms
        )
