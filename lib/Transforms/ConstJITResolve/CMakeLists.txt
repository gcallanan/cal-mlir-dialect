# Select the appropriate target-specific AsmParser and Disassembler components for the host/toolchain.
# This avoids hard-coding X86 on non-X86 hosts (e.g., Apple Silicon arm64 needs AArch64* components).
set(_HOST_ASMPARSER_COMPONENT "")
set(_HOST_DISASSEMBLER_COMPONENT "")
if(DEFINED LLVM_TARGETS_TO_BUILD)
  if(LLVM_TARGETS_TO_BUILD MATCHES "AArch64")
    set(_HOST_ASMPARSER_COMPONENT AArch64AsmParser)
    set(_HOST_DISASSEMBLER_COMPONENT AArch64Disassembler)
  elseif(LLVM_TARGETS_TO_BUILD MATCHES "X86")
    set(_HOST_ASMPARSER_COMPONENT X86AsmParser)
    set(_HOST_DISASSEMBLER_COMPONENT X86Disassembler)
  endif()
else()
  # Fallback to CMAKE_SYSTEM_PROCESSOR heuristic if LLVM_TARGETS_TO_BUILD is unavailable
  if(CMAKE_SYSTEM_PROCESSOR MATCHES "^(aarch64|arm64)$")
    set(_HOST_ASMPARSER_COMPONENT AArch64AsmParser)
    set(_HOST_DISASSEMBLER_COMPONENT AArch64Disassembler)
  elseif(CMAKE_SYSTEM_PROCESSOR MATCHES "x86_64|AMD64|x86")
    set(_HOST_ASMPARSER_COMPONENT X86AsmParser)
    set(_HOST_DISASSEMBLER_COMPONENT X86Disassembler)
  endif()
endif()

add_mlir_dialect_library(ConstJITResolvePass
  ConstJITResolve.cpp

  DEPENDS
    CalGenericTransformationsPassesIncGen

  LINK_COMPONENTS
    Core
    Support
    nativecodegen
    ${_HOST_ASMPARSER_COMPONENT}
    ${_HOST_DISASSEMBLER_COMPONENT}
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
