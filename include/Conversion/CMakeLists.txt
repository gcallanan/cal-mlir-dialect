add_custom_target(CalConversionIncGen)

set(LLVM_TARGET_DEFINITIONS Passes.td)
mlir_tablegen(Passes.h.inc --gen-pass-decls -name CalConversion)
add_public_tablegen_target(CalConversionPassesIncGen)
add_dependencies(CalConversionIncGen CalConversionPassesIncGen)