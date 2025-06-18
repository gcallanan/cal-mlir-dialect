M=4
O=0
P=1000000


opt_levels=(0 1 2 3)
cpp_times=()
mlir_times=()
c_times=()

# Build and Run Cpp project using Streamblocks multicore
rm -rf myproject
bash compile_to_cpp_then_to_binary.sh -M $M -O $O -P $P
for O in "${opt_levels[@]}"; do

  mkdir -p  myproject/build/
  cd myproject/build/
  cmake .. -DCMAKE_C_COMPILER=clang -DCMAKE_CXX_COMPILER=clang++ -DCMAKE_CXX_FLAGS="-O$O" # 2> /dev/null
  cmake --build . -j24 2> /dev/null
  cd ../..
  cp myproject/bin/BigNetwork main_executable_from_cpp
  sleep 10

  echo "Running CPP binary..."
  cpp_time=$(/usr/bin/time -f "%e" ./main_executable_from_cpp 2>&1 1>/dev/null)
  echo "CPP time: $cpp_time seconds"
  cpp_times+=("$cpp_time")

done

# Build and Run MLIR project

for O in "${opt_levels[@]}"; do

  rm -rf myproject
  bash compile_to_mlir_then_to_binary.sh -M $M -O $O -P $P
  sleep 10

  echo "Time taken to execute MLIR binary:"
  echo "Running MLIR binary..."
  mlir_time=$(/usr/bin/time -f "%e" ./main_executable_from_mlir 2>&1 1>/dev/null)
  echo "MLIR time: $mlir_time seconds"
  mlir_times+=("$mlir_time")

done

#cp myproject/generated/main.ll roughwork/main_MLIR_M${M}_O${O}_P${P}.ll

# Build and Run C project using Tycho

rm -rf myproject
mkdir myproject
tychoc --set experimental-network-elaboration=on --set reduction-algorithm=ordered-condition-checking --source-path config.cal:BigNetwork.cal:Messenger.cal:Sink.cal --target-path myproject big.BigNetwork

echo "2. Generating a binary from the C files"

for O in "${opt_levels[@]}"; do
  clang myproject/*.c -O$O -o main_executable_from_c
  sleep 10

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