opt_levels=(0 1 2 3)
cpp_times=()
mlir_times=()
c_times=()

# Build and Run CPP project

rm -rf myproject
streamblocks multicore --set experimental-network-elaboration=on --set reduction-algorithm=ordered-condition-checking --source-path qrd_systolic_cordic_fixedpoint.cal --target-path myproject qrd.Top
sleep 15

for O in "${opt_levels[@]}"; do

  mkdir -p  myproject/build/
  cd myproject/build/
  cmake .. -DCMAKE_C_COMPILER=clang -DCMAKE_CXX_COMPILER=clang++ -DCMAKE_CXX_FLAGS="-O$O" # 2> /dev/null
  cmake --build . -j24 2> /dev/null
  cd ../..
  cp myproject/bin/Top main_executable_from_cpp
  sleep 10

  echo "Running CPP binary..."
  cpp_time=$(/usr/bin/time -f "%e" ./main_executable_from_cpp 2>&1 1>/dev/null)
  echo "CPP time: $cpp_time seconds"
  cpp_times+=("$cpp_time")
done


# Build and Run MLIR project
rm -rf myproject
bash generate_mlir.sh
for O in "${opt_levels[@]}"; do
    bash create_binary_from_mlir.sh -O $O
    sleep 15

    echo "Running MLIR binary..."
    mlir_time=$(/usr/bin/time -f "%e" ./main_executable 2>&1 1>/dev/null)
    echo "MLIR time: $mlir_time seconds"
    mlir_times+=("$mlir_time")
done

#cp myproject/generated/main.ll roughwork/main_MLIR_C${C}_P${P}_O${O}.ll

# Build and Run C project using Tycho

rm -r myproject
mkdir myproject
tychoc --set experimental-network-elaboration=on --set reduction-algorithm=ordered-condition-checking --source-path qrd_systolic_cordic_fixedpoint.cal --target-path myproject qrd.Top

for O in "${opt_levels[@]}"; do
  clang myproject/*.c -O$O -o main_executable_from_c
  sleep 10
  #clang -S -emit-llvm myproject/*.c -o myproject/output.ll
  echo "Running C binary..."
  c_time=$(/usr/bin/time -f "%e" ./main_executable_from_c 2>&1 1>/dev/null)
  echo "C time: $c_time seconds"
  c_times+=("$c_time")
done


# Print header
echo -n "Opt Level,"
printf "%s," "${opt_levels[@]}"
echo

# Function to join array with commas
join_by_comma() {
  local IFS=","
  echo "$*"
}

# Print results
echo -n "CPP,"
join_by_comma "${cpp_times[@]}"

echo -n "MLIR,"
join_by_comma "${mlir_times[@]}"

echo -n "C,"
join_by_comma "${c_times[@]}"