M=4
O=3
P=10000000
#P=10


#M_values=(2 3 4 5 6 7 8 9)
#M_values=(2 3 4 5 6 7 8 9)
M_values=(2)
M_values_mlir=("${M_values[@]}" 4 8 12 16 20 24)
cpp_times=()
mlir_times=()
mlir_times_multicore=()
c_times=()

# Build and Run Cpp project using Streamblocks multicore
# for M in "${M_values[@]}"; do
#   echo "M: $M" 
#   rm -rf myproject
#   bash compile_to_cpp_to_binary.sh -M $M -O $O -P $P

#   mkdir -p  myproject/build/
#   cd myproject/build/
#   cmake .. -DCMAKE_C_COMPILER=clang -DCMAKE_CXX_COMPILER=clang++ -DCMAKE_CXX_FLAGS="-O$O" # 2> /dev/null
#   cmake --build . -j24 2> /dev/null
#   cd ../..
#   cp myproject/bin/BigNetwork main_executable_from_cpp
#   sleep 3

#   echo "Running CPP binary..."
#   cpp_time=$(/usr/bin/time -f "%e" ./main_executable_from_cpp 2>&1 1>/dev/null)
#   echo "CPP time: $cpp_time seconds"
#   cpp_times+=("$cpp_time")

# done

# Build and Run MLIR project

for M in "${M_values_mlir[@]}"; do
  echo "M: $M"
  rm -rf myproject
  bash compile_to_mlir_to_binary.sh -M $M -O $O -P $P
  #bash compile_to_mlir_to_binary.sh -M $M -O $O -P $P -m # Multicore version with CPU affinities
  sleep 3

  echo "Time taken to execute MLIR binary:"
  echo "Running MLIR binary..."
  mlir_time=$(/usr/bin/time -f "%e" ./main_executable_from_mlir 2>&1 1>/dev/null)
  echo "MLIR time: $mlir_time seconds"
  mlir_times+=("$mlir_time")
  # sleep 3

  # echo "Running MLIR multicore binary..."
  # mlir_time_multicore=$(/usr/bin/time -f "%e" taskset -c 0-3 ./main_executable_from_mlir_multicore 2>&1 1>/dev/null)
  # echo "MLIR multicore time: $mlir_time_multicore seconds"
  # mlir_times_multicore+=("$mlir_time_multicore")

done

#cp myproject/generated/main.ll roughwork/main_MLIR_M${M}_O${O}_P${P}.ll

# Build and Run C project using Tycho



echo "2. Generating a binary from the C files"

# for M in "${M_values[@]}"; do
#   echo "M: $M"
#   echo "namespace big:
#       uint numMessengers = $M;
#       uint numPingPongs = $P;
#   end
#   " > config.cal
#   rm -rf myproject
#   mkdir myproject
#   tychoc --set experimental-network-elaboration=on --set reduction-algorithm=ordered-condition-checking --source-path config.cal:BigNetwork.cal:Messenger.cal:Sink.cal --target-path myproject big.BigNetwork

#   clang myproject/*.c -O$O -o main_executable_from_c
#   sleep 3

#   echo "Running C binary..."
#   c_time=$(/usr/bin/time -f "%e" ./main_executable_from_c 2>&1 1>/dev/null)
#   echo "C time: $c_time seconds"
#   c_times+=("$c_time")
# done

# Print header
echo -n "M,"
printf "%s," "${M_values_mlir[@]}"
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

echo -n "MLIR_MULTICORE,"
join_by_comma "${mlir_times_multicore[@]}"

echo -n "C,"
join_by_comma "${c_times[@]}"