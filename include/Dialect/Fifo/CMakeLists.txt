add_mlir_dialect(FifoOps fifo)
add_mlir_doc(FifoDialect FifoDialect Fifo/ -gen-dialect-doc)
add_mlir_doc(FifoOps FifoOps Fifo/ -gen-op-doc)

set(LLVM_TARGET_DEFINITIONS FifoPasses.td)
mlir_tablegen(FifoPasses.h.inc --gen-pass-decls)
add_public_tablegen_target(MLIRFifoPassesIncGen)
