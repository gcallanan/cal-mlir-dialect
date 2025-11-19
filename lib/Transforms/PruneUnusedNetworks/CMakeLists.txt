add_mlir_library(PruneUnusedNetworksPass
  PruneUnusedNetworks.cpp

  LINK_COMPONENTS
  Core

  LINK_LIBS PUBLIC
  MLIRIR
  MLIRSupport
  MLIRCal
)
