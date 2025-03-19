include(AddMLIRPython)

# Specifies that all MLIR packages are co-located under the `mlir_cal`
# top level package (the API has been embedded in a relocatable way).
# TODO: Add an upstream cmake param for this vs having a global here.
add_compile_definitions("MLIR_PYTHON_PACKAGE_PREFIX=mlir_cal.")


################################################################################
# Sources
################################################################################

declare_mlir_python_sources(CalPythonSources)

declare_mlir_dialect_python_bindings(
  ADD_TO_PARENT CalPythonSources
  ROOT_DIR "${CMAKE_CURRENT_SOURCE_DIR}/mlir_cal"
  TD_FILE dialects/CalOps.td
  SOURCES
    dialects/cal_pybind11.py
    dialects/cal_nanobind.py
  DIALECT_NAME cal)


declare_mlir_python_extension(CalPythonSources.Pybind11Extension
  MODULE_NAME _calDialectsPybind11
  ADD_TO_PARENT CalPythonSources
  SOURCES
    CalExtensionPybind11.cpp
  EMBED_CAPI_LINK_LIBS
    CalCAPI
  PYTHON_BINDINGS_LIBRARY pybind11
)

declare_mlir_python_extension(CalPythonSources.NanobindExtension
  MODULE_NAME _calDialectsNanobind
  ADD_TO_PARENT CalPythonSources
  SOURCES
    CalExtensionNanobind.cpp
  EMBED_CAPI_LINK_LIBS
    CalCAPI
  PYTHON_BINDINGS_LIBRARY nanobind
)


################################################################################
# Common CAPI
################################################################################

add_mlir_python_common_capi_library(CalPythonCAPI
  INSTALL_COMPONENT CalPythonModules
  INSTALL_DESTINATION python_packages/cal/mlir_cal/_mlir_libs
  OUTPUT_DIRECTORY "${MLIR_BINARY_DIR}/python_packages/cal/cal/_mlir_libs"
  RELATIVE_INSTALL_ROOT "../../../.."
  DECLARED_SOURCES
    CalPythonSources
    # TODO: Remove this in favor of showing fine grained registration once
    # available.
    MLIRPythonExtension.RegisterEverything
    MLIRPythonSources.Core
)

################################################################################
# Instantiation of all Python modules
################################################################################

add_mlir_python_modules(CalPythonModules
  ROOT_PREFIX "${MLIR_BINARY_DIR}/python_packages/cal/mlir_cal"
  INSTALL_PREFIX "python_packages/cal/mlir_cal"
  DECLARED_SOURCES
    CalPythonSources
    # TODO: Remove this in favor of showing fine grained registration once
    # available.
    MLIRPythonExtension.RegisterEverything
    MLIRPythonSources
  COMMON_CAPI_LINK_LIBS
    CalPythonCAPI
  )
