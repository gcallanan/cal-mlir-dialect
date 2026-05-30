#!/bin/bash
# A script that generates an OpGraph svg file from the Streamblocks generated main.mlir file. The svg files is stored in project_dir/build/graph
# Requires the Graphviz software program to be installed on your system.

scriptDir=`dirname -- "$( readlink -f -- "$0"; )";`
cd $scriptDir/..
projDir=`pwd`
echo "Building project in directory: $projDir"

# 1. Generate the graph.dot file to be used by Graphviz to generate the software 
mkdir -p build/graph
cd build/graph
dfg-opt ../../code-gen/main.mlir --view-op-graph 2> graph.dot

# 2. Generate the SVG from the .dot file using Graphviz.
dot -Tsvg graph.dot > graph.svg

