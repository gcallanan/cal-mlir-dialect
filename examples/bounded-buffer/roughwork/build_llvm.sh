P=3
C=3
O=3

# Build and Run CPP project

rm -rf myproject
bash compile_to_cpp_to_binary.sh -C $C -O $O -P $P

echo "Time taken to execute CPP binary:"
time ./main_executable_from_cpp

#cp myproject/generated/main.ll roughwork/main_MLIR_C${C}_P${P}_O${O}.ll

# Build and Run MLIR project

rm -rf myproject
bash compile_to_mlir_to_binary.sh -C $C -O $O -P $P

echo "Time taken to execute MLIR binary:"
time ./main_executable_from_mlir

#cp myproject/generated/main.ll roughwork/main_MLIR_C${C}_P${P}_O${O}.ll

# Build and Run C project using Tycho

rm -r myproject
mkdir myproject
tychoc --set experimental-network-elaboration=on --set reduction-algorithm=ordered-condition-checking --source-path config.cal:BndBufferNetwork.cal:Buffer.cal:Sink.cal:Producer.cal:Consumer.cal:helperFunctions.cal --target-path myproject bndBuffer.BndBufferNetwork

gcc myproject/*.c -O$O -march=native -o main_executable_from_c
#clang myproject/*.c -march=native -o main_executable_from_c
#clang -S -emit-llvm myproject/*.c -o myproject/output.ll
echo "Time taken to execute C binary:"
time ./main_executable_from_c