add_mlir_dialect_library(MLIRCal
        CalTypes.cpp
        CalDialect.cpp
        CalOps.cpp
        CalPassesHoistCalStateOutOfActor.cpp

        ADDITIONAL_HEADER_DIRS
        ${PROJECT_SOURCE_DIR}/include/Cal

        DEPENDS
        MLIRCalOpsIncGen
        MLIRCalPassesIncGen

        LINK_LIBS PUBLIC
        MLIRIR
        MLIRInferTypeOpInterface
        MLIRFuncDialect
        )
