add_mlir_dialect_library(ConstJITResolvePass
  ConstJITResolve.cpp

  DEPENDS
    CalGenericTransformationsPassesIncGen

  LINK_COMPONENTS
    Core
    Support
    nativecodegen
    X86AsmParser

  LINK_LIBS PUBLIC
    MLIRIR
    MLIRSupport
    MLIRPass
    MLIRFuncDialect
    MLIRArithDialect
    MLIRSCFDialect
    MLIRControlFlowDialect
    MLIRLLVMDialect
    MLIRUBDialect
    MLIRExecutionEngine
    MLIRTargetLLVMIRExport
    MLIRSCFToControlFlow
  MLIRControlFlowToLLVM
    MLIRFuncToLLVM
    MLIRArithToLLVM
    MLIRMathToLLVM
    MLIRMemRefToLLVM
    MLIRReconcileUnrealizedCasts
)
