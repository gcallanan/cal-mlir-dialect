set(LLVM_LINK_COMPONENTS Core Support)

add_lit_testsuite(check-cal-resolve-instance-if "Running cal resolve-instance-if tests"
  ${CMAKE_CURRENT_SOURCE_DIR}
  DEPENDS ${CAL_TEST_DEPENDS}
)
