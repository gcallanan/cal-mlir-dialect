llvm_canonicalize_cmake_booleans(
        MLIR_ENABLE_BINDINGS_PYTHON
)

configure_lit_site_cfg(
        ${CMAKE_CURRENT_SOURCE_DIR}/lit.site.cfg.py.in
        ${CMAKE_CURRENT_BINARY_DIR}/lit.site.cfg.py
        MAIN_CONFIG
        ${CMAKE_CURRENT_SOURCE_DIR}/lit.cfg.py
)

set(CAL_TEST_DEPENDS
        FileCheck count not
        cal-capi-test
        cal-opt
        cal-translate
        CalPlugin
        lli # Add lli as a dependency so that we can run llvm code during testing
        )
if(MLIR_ENABLE_BINDINGS_PYTHON)
  list(APPEND CAL_TEST_DEPENDS CalPythonModules)
endif()

add_lit_testsuite(check-cal "Running the cal regression tests"
        ${CMAKE_CURRENT_BINARY_DIR}
        DEPENDS ${CAL_TEST_DEPENDS}
        )
set_target_properties(check-cal PROPERTIES FOLDER "Tests")

add_lit_testsuites(CAL ${CMAKE_CURRENT_SOURCE_DIR} DEPENDS ${CAL_TEST_DEPENDS})

add_subdirectory(CAPI)
