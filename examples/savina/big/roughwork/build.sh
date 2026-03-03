M=4
O=3
P=10000000
NUM_TESTS=8

M_values=(2 3 4 5 6 7 8 9)
#M_values=(2 3 4 5 6)
#M_values=(3)
M_values_mlir=("${M_values[@]}" 10 12 14 16 18 20 22 24 26 28 30 32)
#M_values_mlir=("${M_values[@]}" 7 8)

cpp_times=()
cpp_times_multicore=()
mlir_times=()
mlir_times_multicore=()
c_times=()

cpp_stddev=()
cpp_stddev_multicore=()
mlir_stddev=()
mlir_stddev_multicore=()
c_stddev=()

RESULTS_FILE="results.txt"
> "$RESULTS_FILE"  # Clear/create the file at the start

RAW_TIMES_FILE="raw_times.csv"
echo "M,P,Command,Iteration,Time" > "$RAW_TIMES_FILE"

# Helper: print to stdout and append to results file
tee_results() {
  echo "$@" | tee -a "$RESULTS_FILE"
}

# Helper: run a command NUM_TESTS times, store average and stddev into named variables
# Usage: run_timed_experiment <avg_var> <stddev_var> <M> <P> <command...>
run_timed_experiment() {
  local avg_var="$1"
  local stddev_var="$2"
  local m_val="$3"
  local p_val="$4"
  shift 4
  local cmd=("$@")
  local times=()

  for (( i=0; i<NUM_TESTS; i++ )); do
    local t
    t=$(/usr/bin/time -f "%e" "${cmd[@]}" 2>&1 1>/dev/null)
    echo "M=$m_val P=$p_val Command: ${cmd[*]}, Iteration: $i, Time: $t" 
    echo "$m_val,$p_val,${cmd[*]},$i,$t" >> "$RAW_TIMES_FILE"
    times+=("$t")
    sleep 1
  done

  # Force C locale to ensure dot is used as decimal separator
  local stats
  stats=$(printf '%s\n' "${times[@]}" | LC_ALL=C awk '
    { sum += $1; sumsq += $1*$1; n++ }
    END {
      avg = sum / n
      stddev = sqrt(sumsq/n - avg*avg)
      printf "%.6f %.6f", avg, stddev
    }
  ')
  local avg stddev
  avg=$(echo "$stats" | LC_ALL=C awk '{print $1}')
  stddev=$(echo "$stats" | LC_ALL=C awk '{print $2}')

  printf -v "$avg_var" '%s' "$avg"
  printf -v "$stddev_var" '%s' "$stddev"
}

# Build and Run Cpp project using Streamblocks multicore
for M in "${M_values[@]}"; do
  echo "M: $M" 
  rm -rf myproject
  bash compile_to_cpp_to_binary.sh -M $M -O $O -P $P

  mkdir -p myproject/build/
  cd myproject/build/
  cmake .. -DCMAKE_C_COMPILER=clang -DCMAKE_CXX_COMPILER=clang++ -DCMAKE_CXX_FLAGS="-O$O"
  cmake --build . -j24 2> /dev/null
  cd ../..
  cp myproject/bin/BigNetwork main_executable_from_cpp
  sleep 3

  echo "Running CPP binary ($NUM_TESTS times)..."
  run_timed_experiment cpp_avg cpp_sd "$M" "$P" ./main_executable_from_cpp --generate=config.xml
  echo "CPP avg: $cpp_avg s, stddev: $cpp_sd s"
  cpp_times+=("$cpp_avg")
  cpp_stddev+=("$cpp_sd")

  sleep 3
  bash roughwork/assign_streamblocks_cpu_affinitites.sh
  echo "Running CPP multicore binary ($NUM_TESTS times)..."
  run_timed_experiment cpp_mc_avg cpp_mc_sd "$M" "$P" taskset -c 0-3 ./main_executable_from_cpp --cfile=config_partitioned.xml
  echo "CPP multicore avg: $cpp_mc_avg s, stddev: $cpp_mc_sd s"
  cpp_times_multicore+=("$cpp_mc_avg")
  cpp_stddev_multicore+=("$cpp_mc_sd")
done

# Build and Run MLIR project
for M in "${M_values_mlir[@]}"; do
  echo "M: $M"
  rm -rf myproject
  bash compile_to_mlir_to_binary.sh -M $M -O $O -P $P
  bash compile_to_mlir_to_binary.sh -M $M -O $O -P $P -m
  sleep 3

  echo "Running MLIR binary ($NUM_TESTS times)..."
  run_timed_experiment mlir_avg mlir_sd "$M" "$P" ./main_executable_from_mlir
  echo "MLIR avg: $mlir_avg s, stddev: $mlir_sd s"
  mlir_times+=("$mlir_avg")
  mlir_stddev+=("$mlir_sd")

  sleep 3
  echo "Running MLIR multicore binary ($NUM_TESTS times)..."
  run_timed_experiment mlir_mc_avg mlir_mc_sd "$M" "$P" taskset -c 0-3 ./main_executable_from_mlir_multicore
  echo "MLIR multicore avg: $mlir_mc_avg s, stddev: $mlir_mc_sd s"
  mlir_times_multicore+=("$mlir_mc_avg")
  mlir_stddev_multicore+=("$mlir_mc_sd")
done

# Build and Run C project using Tycho
echo "2. Generating a binary from the C files"

for M in "${M_values[@]}"; do
  echo "M: $M"
  echo "namespace big:
      uint numMessengers = $M;
      uint numPingPongs = $P;
  end
  " > config.cal
  rm -rf myproject
  mkdir myproject
  tychoc --set experimental-network-elaboration=on --set reduction-algorithm=ordered-condition-checking --source-path config.cal:BigNetwork.cal:Messenger.cal:Sink.cal --target-path myproject big.BigNetwork

  clang myproject/*.c -O$O -o main_executable_from_c
  sleep 3

  echo "Running C binary ($NUM_TESTS times)..."
  run_timed_experiment c_avg c_sd "$M" "$P" ./main_executable_from_c
  echo "C avg: $c_avg s, stddev: $c_sd s"
  c_times+=("$c_avg")
  c_stddev+=("$c_sd")
done

# Print header
tee_results -n "M,"
printf "%s," "${M_values_mlir[@]}" | tee -a "$RESULTS_FILE"
tee_results

join_by_comma() {
  local IFS=","
  echo "$*"
}

# Print results (averages)
tee_results -n "CPP,"
join_by_comma "${cpp_times[@]}" | tee -a "$RESULTS_FILE"

tee_results -n "CPP_STDDEV,"
join_by_comma "${cpp_stddev[@]}" | tee -a "$RESULTS_FILE"

tee_results -n "CPP_MULTICORE,"
join_by_comma "${cpp_times_multicore[@]}" | tee -a "$RESULTS_FILE"

tee_results -n "CPP_MULTICORE_STDDEV,"
join_by_comma "${cpp_stddev_multicore[@]}" | tee -a "$RESULTS_FILE"

tee_results -n "MLIR,"
join_by_comma "${mlir_times[@]}" | tee -a "$RESULTS_FILE"

tee_results -n "MLIR_STDDEV,"
join_by_comma "${mlir_stddev[@]}" | tee -a "$RESULTS_FILE"

tee_results -n "MLIR_MULTICORE,"
join_by_comma "${mlir_times_multicore[@]}" | tee -a "$RESULTS_FILE"

tee_results -n "MLIR_MULTICORE_STDDEV,"
join_by_comma "${mlir_stddev_multicore[@]}" | tee -a "$RESULTS_FILE"

tee_results -n "C,"
join_by_comma "${c_times[@]}" | tee -a "$RESULTS_FILE"

tee_results -n "C_STDDEV,"
join_by_comma "${c_stddev[@]}" | tee -a "$RESULTS_FILE"