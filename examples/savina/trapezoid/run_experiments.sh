set -e

bash compile_to_c_to_binary.sh
bash compile_to_cpp_to_binary.sh
bash compile_to_mlir_to_binary.sh

for i in {1..1}; do
    echo "Experiment run $i"
    time ./main_executable_from_mlir
    time ./main_executable_from_c
    time ./main_executable_from_cpp
done
