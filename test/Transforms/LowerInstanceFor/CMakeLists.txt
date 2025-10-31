set(LLVM_LINK_COMPONENTS Core Support)

add_lit_testsuite(check-cal-lower-instance-for "Running cal lower-instance-for tests"
  ${CMAKE_CURRENT_SOURCE_DIR}
  DEPENDS ${CAL_TEST_DEPENDS}
)
