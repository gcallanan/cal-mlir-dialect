set -e 

rm -f main.ll main.o main_executable

cal-opt --lower-cal-to-llvm myproject/code-gen/main.mlir | cal-translate --mlir-to-llvmir > main.ll
opt -O3 main.ll -o main.opt.ll
llc -relocation-model=pic main.opt.ll -filetype=obj -o main.o
clang main.o -o main_executable