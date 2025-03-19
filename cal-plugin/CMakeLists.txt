add_llvm_library(CalPlugin
        # BUILDTREE_ONLY is only for testing purposes
        MODULE BUILDTREE_ONLY
        cal-plugin.cpp

        DEPENDS
        MLIRCal
        PLUGIN_TOOL
        mlir-opt

        LINK_LIBS
        MLIRCal
        )
target_include_directories(
        CalPlugin
        PRIVATE
        "${CAL_BINARY_DIR}/include"
)
