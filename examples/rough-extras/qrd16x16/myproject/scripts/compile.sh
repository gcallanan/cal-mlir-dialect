#!/bin/bash
# Script that takes the generated MLIR files from the CAL compiler and runs them through the MLIR/CIRCT compiler to generate SV files. The sv files are stored in project_dir/build/sv

scriptDir=`dirname -- "$( readlink -f -- "$0"; )";`
cd $scriptDir/..
projDir=`pwd`
echo "Building project in directory: $projDir"

# 1. Build SV files
# 1.1 Build SV files and mlir files for the actor kernels
mkdir -p build/sv
cd build/sv
dfg-opt ../../code-gen/main.mlir --flatten-memref --handshake-legalize-memrefs --convert-std-to-circt --convert-dfg-to-circt --convert-fsm-to-sv --lower-seq-to-sv --export-split-verilog
#dfg-opt ../../code-gen/main.mlir --convert-std-to-circt --debug-only=wrap-process-ops

# 1.2 Generate the SV files for every actor kernel
#dfg-opt --map-arith-to-comb hls_JoinerRowR_calc.mlir > hls_JoinerRowR_calc_Transformed.mlir
#hlstool hls_JoinerRowR_calc.mlir --buffering-strategy=cycles --dynamic-hw --lowering-options=disallowLocalVariables -o hls_JoinerRowR_calc.sv
mlir-opt --canonicalize hls_JoinerRowR_calc.mlir > temp.mlir
rm hls_JoinerRowR_calc.mlir
mv temp.mlir hls_JoinerRowR_calc.mlir
hlstool hls_JoinerRowR_calc.mlir -o hls_JoinerRowR_calc.sv
#dfg-opt --map-arith-to-comb hls_Cap_Iterations_calc.mlir > hls_Cap_Iterations_calc_Transformed.mlir
#hlstool hls_Cap_Iterations_calc.mlir --buffering-strategy=cycles --dynamic-hw --lowering-options=disallowLocalVariables -o hls_Cap_Iterations_calc.sv
mlir-opt --canonicalize hls_Cap_Iterations_calc.mlir > temp.mlir
rm hls_Cap_Iterations_calc.mlir
mv temp.mlir hls_Cap_Iterations_calc.mlir
hlstool hls_Cap_Iterations_calc.mlir -o hls_Cap_Iterations_calc.sv
#dfg-opt --map-arith-to-comb hls_BoundaryCell_calc.mlir > hls_BoundaryCell_calc_Transformed.mlir
#hlstool hls_BoundaryCell_calc.mlir --buffering-strategy=cycles --dynamic-hw --lowering-options=disallowLocalVariables -o hls_BoundaryCell_calc.sv
mlir-opt --canonicalize hls_BoundaryCell_calc.mlir > temp.mlir
rm hls_BoundaryCell_calc.mlir
mv temp.mlir hls_BoundaryCell_calc.mlir
hlstool hls_BoundaryCell_calc.mlir -o hls_BoundaryCell_calc.sv
#dfg-opt --map-arith-to-comb hls_InnerCell_calc.mlir > hls_InnerCell_calc_Transformed.mlir
#hlstool hls_InnerCell_calc.mlir --buffering-strategy=cycles --dynamic-hw --lowering-options=disallowLocalVariables -o hls_InnerCell_calc.sv
mlir-opt --canonicalize hls_InnerCell_calc.mlir > temp.mlir
rm hls_InnerCell_calc.mlir
mv temp.mlir hls_InnerCell_calc.mlir
hlstool hls_InnerCell_calc.mlir -o hls_InnerCell_calc.sv
#dfg-opt --map-arith-to-comb hls_Source_calc.mlir > hls_Source_calc_Transformed.mlir
#hlstool hls_Source_calc.mlir --buffering-strategy=cycles --dynamic-hw --lowering-options=disallowLocalVariables -o hls_Source_calc.sv
mlir-opt --canonicalize hls_Source_calc.mlir > temp.mlir
rm hls_Source_calc.mlir
mv temp.mlir hls_Source_calc.mlir
hlstool hls_Source_calc.mlir -o hls_Source_calc.sv
#dfg-opt --map-arith-to-comb hls_Cap_calc.mlir > hls_Cap_calc_Transformed.mlir
#hlstool hls_Cap_calc.mlir --buffering-strategy=cycles --dynamic-hw --lowering-options=disallowLocalVariables -o hls_Cap_calc.sv
mlir-opt --canonicalize hls_Cap_calc.mlir > temp.mlir
rm hls_Cap_calc.mlir
mv temp.mlir hls_Cap_calc.mlir
hlstool hls_Cap_calc.mlir -o hls_Cap_calc.sv
#dfg-opt --map-arith-to-comb hls_IGenerator_calc.mlir > hls_IGenerator_calc_Transformed.mlir
#hlstool hls_IGenerator_calc.mlir --buffering-strategy=cycles --dynamic-hw --lowering-options=disallowLocalVariables -o hls_IGenerator_calc.sv
mlir-opt --canonicalize hls_IGenerator_calc.mlir > temp.mlir
rm hls_IGenerator_calc.mlir
mv temp.mlir hls_IGenerator_calc.mlir
hlstool hls_IGenerator_calc.mlir -o hls_IGenerator_calc.sv
#dfg-opt --map-arith-to-comb hls_JoinerRowQ_calc.mlir > hls_JoinerRowQ_calc_Transformed.mlir
#hlstool hls_JoinerRowQ_calc.mlir --buffering-strategy=cycles --dynamic-hw --lowering-options=disallowLocalVariables -o hls_JoinerRowQ_calc.sv
mlir-opt --canonicalize hls_JoinerRowQ_calc.mlir > temp.mlir
rm hls_JoinerRowQ_calc.mlir
mv temp.mlir hls_JoinerRowQ_calc.mlir
hlstool hls_JoinerRowQ_calc.mlir -o hls_JoinerRowQ_calc.sv
