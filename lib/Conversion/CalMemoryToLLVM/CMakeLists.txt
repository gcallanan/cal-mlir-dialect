add_mlir_conversion_library(CalMemoryToLLVM
        CalMemoryToLLVM.cpp

    DEPENDS
        CalConversionIncGen

    LINK_COMPONENTS
        Core

    LINK_LIBS PUBLIC
        MLIRDialectUtils
        MLIRTransformUtils
        MLIRLLVMDialect
        MLIRLLVMCommonConversion
        MLIRCal
)
