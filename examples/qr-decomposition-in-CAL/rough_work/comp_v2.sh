opt_levels=(0 1 2 3)
cpp_times=()
mlir_times_dynamic=()
mlir_times_static=()
c_times=()
numTests=3
sleepTime=5

# Build and Run CPP project

rm -rf myproject
streamblocks multicore --set experimental-network-elaboration=on --set reduction-algorithm=ordered-condition-checking --source-path qrd_systolic_cordic_fixedpoint.cal --target-path myproject qrd.Top
sleep $sleepTime

for O in "${opt_levels[@]}"; do

  mkdir -p  myproject/build/
  cd myproject/build/
  cmake .. -DCMAKE_C_COMPILER=clang -DCMAKE_CXX_COMPILER=clang++ -DCMAKE_CXX_FLAGS="-O$O" # 2> /dev/null
  cmake --build . -j24 2> /dev/null
  cd ../..
  cp myproject/bin/Top main_executable_from_cpp
  sleep $sleepTime

  echo "Running CPP binary with -0$O..."
  total_time=0
  for ((i=1; i<=numTests; i++)); do
    run_time=$(/usr/bin/time -f "%e" ./main_executable_from_cpp 2>&1 1>/dev/null)
    total_time=$(echo "$total_time + $run_time" | bc)
    echo "    Test $i: $run_time seconds"
    sleep $sleepTime
  done
  cpp_time=$(echo "scale=3; $total_time / $numTests" | bc)
  echo "Average CPP time: $cpp_time seconds"
  cpp_times+=("$cpp_time")
done


# Build and Run MLIR project with a dynamic schedule
rm -rf myproject
bash generate_mlir.sh
for O in "${opt_levels[@]}"; do
    bash create_binary_from_mlir.sh -O $O
    sleep $sleepTime

    echo "Running MLIR binary with dynamic schedule and -0$O..."
    total_time=0
    for ((i=1; i<=numTests; i++)); do
      run_time=$(/usr/bin/time -f "%e" ./main_executable 2>&1 1>/dev/null)
      total_time=$(echo "$total_time + $run_time" | bc)
      echo "    Test $i: $run_time seconds"
      sleep $sleepTime
    done
    mlir_time=$(echo "scale=3; $total_time / $numTests" | bc)
    echo "MLIR Dynamic Schedule time: $mlir_time seconds"
    mlir_times_dynamic+=("$mlir_time")
done

# Build and Run MLIR project with a static schedule schedule
rm -rf myproject
bash generate_mlir.sh
for O in "${opt_levels[@]}"; do
    bash create_binary_from_mlir.sh -O $O -s
    sleep $sleepTime

    echo "Running MLIR binary with static schedule and -0$O..."
    total_time=0
    for ((i=1; i<=numTests; i++)); do
      run_time=$(/usr/bin/time -f "%e" ./main_executable 2>&1 1>/dev/null)
      total_time=$(echo "$total_time + $run_time" | bc)
      echo "    Test $i: $run_time seconds"
      sleep $sleepTime
    done
    mlir_time=$(echo "scale=3; $total_time / $numTests" | bc)
    echo "MLIR Static Schedule time: $mlir_time seconds"
    mlir_times_static+=("$mlir_time")
done

# Build and Run C project using Tycho

rm -r myproject
mkdir myproject
tychoc --set experimental-network-elaboration=on --set reduction-algorithm=ordered-condition-checking --source-path qrd_systolic_cordic_fixedpoint.cal --target-path myproject qrd.Top

for O in "${opt_levels[@]}"; do
  clang myproject/*.c -O$O -o main_executable_from_c
  sleep $sleepTime
  #clang -S -emit-llvm myproject/*.c -o myproject/output.ll
  echo "Running C binary with -0$O..."
  total_time=0
  for ((i=1; i<=numTests; i++)); do
    run_time=$(/usr/bin/time -f "%e" ./main_executable_from_c 2>&1 1>/dev/null)
    total_time=$(echo "$total_time + $run_time" | bc)
    echo "    Test $i: $run_time seconds"
    sleep $sleepTime
  done
  c_time=$(echo "scale=3; $total_time / $numTests" | bc)
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

echo -n "MLIR with Dynamic Schedule,"
join_by_comma "${mlir_times_dynamic[@]}"

echo -n "MLIR with Static Schedule,"
join_by_comma "${mlir_times_static[@]}"

echo -n "C,"
join_by_comma "${c_times[@]}"