M=7
O=0
P=1000000

# Build and Run Cpp project using Streamblocks multicore

# rm -rf myproject
# bash compile_to_cpp_then_to_binary.sh -M $M -O $O -P $P

# echo "Time taken to execute CPP binary:"
# time ./main_executable_from_cpp

# Build and Run MLIR project

# rm -rf myproject
# bash compile_to_mlir_then_to_binary.sh -M $M -O $O -P $P

# echo "Time taken to execute MLIR binary:"
# time ./main_executable_from_mlir

#cp myproject/generated/main.ll roughwork/main_MLIR_M${M}_O${O}_P${P}.ll

# Build and Run C project using Tycho

rm -rf myproject
mkdir myproject
tychoc --set experimental-network-elaboration=on --set reduction-algorithm=informative-tests --source-path config.cal:BigNetwork.cal:Messenger.cal:Sink.cal --target-path myproject big.BigNetwork

echo "2. Generating a binary from the C files"

cc myproject/*.c -O$O -o main_executable_from_c
echo "Time taken to execute C binary:"
time ./main_executable_from_c