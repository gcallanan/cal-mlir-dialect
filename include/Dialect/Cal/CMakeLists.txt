add_mlir_dialect(CalOps cal)
add_mlir_doc(CalDialect CalDialect Cal/ -gen-dialect-doc)
add_mlir_doc(CalOps CalOps Cal/ -gen-op-doc)

set(LLVM_TARGET_DEFINITIONS CalPasses.td)
mlir_tablegen(CalPasses.h.inc --gen-pass-decls)
add_public_tablegen_target(MLIRCalPassesIncGen)
