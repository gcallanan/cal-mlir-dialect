# Here we create a single aggregate shared library with the parts of the CAPI
# that we want to bundle together. Then we link a simple C executable
# against it to demonstrate that it does have the fully self contained
# core MLIR library and our own cal dialect.
add_mlir_aggregate(CalCAPITestLib
  SHARED
  EMBED_LIBS
  MLIRCAPIIR
  # TODO: Remove this in favor of showing fine grained dialect registration
  # (once available).
  MLIRCAPIRegisterEverything
  CalCAPI
)

add_llvm_executable(cal-capi-test
  cal-capi-test.c
)
llvm_update_compile_flags(cal-capi-test)
target_link_libraries(cal-capi-test
  PRIVATE CalCAPITestLib)
