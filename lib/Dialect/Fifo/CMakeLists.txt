add_mlir_dialect_library(MLIRFifo
        FifoTypes.cpp
        FifoDialect.cpp
        FifoOps.cpp
        FifoPassesLowerFifoPrintToLLVM.cpp
        FifoPassesExtractFifoPopView.cpp
        FifoPassesExtractFifoPushView.cpp
        BufferizableOpInterfaceImpl.cpp

        ADDITIONAL_HEADER_DIRS
        ${PROJECT_SOURCE_DIR}/include/Fifo

        DEPENDS
        MLIRFifoOpsIncGen
        MLIRFifoPassesIncGen

        LINK_LIBS PUBLIC
        MLIRIR
        MLIRInferTypeOpInterface
        MLIRFuncDialect
        MLIRArithDialect
        MLIRMemRefDialect
        MLIRSCFDialect
        MLIRCal
        )
