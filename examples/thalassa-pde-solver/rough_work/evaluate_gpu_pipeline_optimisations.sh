#!/bin/bash
#===============================================================================
# GPU Pipeline Optimization Evaluation Script for CAL-MLIR PDE Solver
#===============================================================================
# Description:
#   This script evaluates different GPU pipeline optimizations for the 
#   advection-diffusion equation solver across multiple hypercube sizes.
#   It tests various optimization flags including hoisting, async streams,
#   and actor chain merging.
#
# Author: GitHub Copilot
#===============================================================================

echo "=== GPU Pipeline Optimization Evaluation ==="
echo "Testing CAL-MLIR GPU optimizations across different hypercube sizes"
echo

#===============================================================================
# CONFIGURATION
#===============================================================================
sleep_time=5
opt_level=3
NUM_TESTS=3
HYPERCUBE_SIZES=(1000000 3000000 10000000)

#===============================================================================
# DATA STRUCTURES
#===============================================================================
declare -a exec_times
declare -a rms_errors
declare -a backend_names

#===============================================================================
# UTILITY FUNCTIONS
#===============================================================================

# Function to extract last two lines (exec_time and rms_error) from script output
extract_metrics() {
    local output="$1"
    local exec_time=$(echo "$output" | tail -2 | head -1)
    local rms_error=$(echo "$output" | tail -1)
    echo "$exec_time"
    echo "$rms_error"
}

run_benchmark_tests() {
    local command="$1"
    local backend_name="$2"
    local -a all_times
    local -a all_rms_errors
    
    for hypercube_size in "${HYPERCUBE_SIZES[@]}"; do
        echo "    Testing with hypercube size: $hypercube_size"
        local -a times_for_avg=()
        local rms_error=""
        
        for ((test_run=1; test_run<=NUM_TESTS; test_run++)); do
            echo "        Test run ${test_run}/${NUM_TESTS}..."

            # Add hypercube size parameter to command
            local full_command="$command -h $hypercube_size"
            output=$(eval "$full_command" 2>&1)
            exit_code=$?

            if [ $exit_code -eq 0 ]; then
                # Extract metrics from last two lines
                metrics=$(extract_metrics "$output")
                exec_time=$(echo "$metrics" | head -1)
                if [ -z "$rms_error" ]; then
                    rms_error=$(echo "$metrics" | tail -1)
                fi
                echo "            Execution time: ${exec_time}s"
                sleep $sleep_time
                
                times_for_avg+=("$exec_time")
            else
                echo "        Failed with exit code $exit_code"
                all_times+=("FAILED")
                all_rms_errors+=("FAILED")
                continue 2  # Skip to next hypercube size
            fi
        done

        if [ ${#times_for_avg[@]} -eq $NUM_TESTS ]; then
            local avg_time=$(echo "${times_for_avg[@]}" | tr ' ' '\n' | LC_NUMERIC=C awk '{sum+=$1} END {printf "%.4f", sum/NR}')
            all_times+=("$avg_time")
            all_rms_errors+=("$rms_error")
            echo "        Completed successfully (avg time: ${avg_time}s, rms error: ${rms_error})"
        else
            echo "        Some test runs failed, not calculating average time."
            all_times+=("FAILED")
            all_rms_errors+=("FAILED")
        fi
    done
    
    # Store results for all hypercube sizes
    exec_times+=("$(IFS='|'; echo "${all_times[*]}")")
    rms_errors+=("$(IFS='|'; echo "${all_rms_errors[*]}")")
    backend_names+=("$backend_name")
    return 0
}

#===============================================================================
# GPU OPTIMIZATION TESTING
#===============================================================================

echo "Running pytorch backend on the CPU"
run_benchmark_tests "bash rough_work/compile_and_run_equations_using_pytorch.sh" "pytorch |cpu"
echo "Running CAL-MLIR backend on the CPU"
run_benchmark_tests "bash 2_compile_and_run_equations.sh" "cal-mlir|cpu"
echo "Running CAL-MLIR backend on the CPU"
run_benchmark_tests "bash 2_compile_and_run_equations.sh -m" "cal-mlir|cpu|merged"
echo "Running pytorch backend on the GPU"
run_benchmark_tests "bash rough_work/compile_and_run_equations_using_pytorch.sh -g" "pytorch |gpu"
echo "Running CAL-MLIR backend on the GPU"
run_benchmark_tests "bash 2_compile_and_run_equations.sh -g -d" "cal-mlir|gpu"
echo "Running CAL-MLIR backend on the GPU with hoisting"
run_benchmark_tests "bash 2_compile_and_run_equations.sh -g" "cal-mlir|gpu|hoisting"
echo "Running CAL-MLIR backend on the GPU with asynchonous streams"
run_benchmark_tests "bash 2_compile_and_run_equations.sh -g -d -s" "cal-mlir|gpu|async"
echo "Running CAL-MLIR backend on the GPU with hoisting and asynchonous streams"
run_benchmark_tests "bash 2_compile_and_run_equations.sh -g -s" "cal-mlir|gpu|async&hoisting"
echo "Running CAL-MLIR backend on the GPU with actor chains merged"
run_benchmark_tests "bash 2_compile_and_run_equations.sh -g -d -m" "cal-mlir|gpu|merged"
echo "Running CAL-MLIR backend on the GPU with actor chains merged and hoisting"
run_benchmark_tests "bash 2_compile_and_run_equations.sh -g -m" "cal-mlir|gpu|merged&hoisted"
echo "Running CAL-MLIR backend on the GPU with actor chains merged and asynchonous streams"
run_benchmark_tests "bash 2_compile_and_run_equations.sh -g -d -m -s" "cal-mlir|gpu|merged&async"
echo "Running CAL-MLIR backend on the GPU with actor chains merged, hoisting and asynchonous streams"
run_benchmark_tests "bash 2_compile_and_run_equations.sh -g -m -s" "cal-mlir|gpu|merged&async&hoisted"

#===============================================================================
# RESULTS DISPLAY AND ANALYSIS
#===============================================================================

echo
echo "=== Performance Results ==="
echo

# Print table header
hypercube_header=""
for size in "${HYPERCUBE_SIZES[@]}"; do
    hypercube_header+="| $(printf "Size %-13s" "$size") "
done

printf "%-35s %s\n" "Backend" "$hypercube_header"
printf "%-35s-" "-----------------------------------"
for size in "${HYPERCUBE_SIZES[@]}"; do
    printf "+%-20s" "--------------------"
done
printf "\n"

# Print results table
for i in "${!backend_names[@]}"; do
    IFS='|' read -ra times_array <<< "${exec_times[$i]}"
    IFS='|' read -ra rms_array <<< "${rms_errors[$i]}"
    
    printf "%-35s " "${backend_names[$i]}"
    
    for j in "${!times_array[@]}"; do
        time_val="${times_array[$j]}"
        rms_val="${rms_array[$j]}"
        
        if [[ "$time_val" == "FAILED" ]]; then
            printf "| %-20s" "FAILED"
        else
            LC_NUMERIC=C printf "| %-8s(%9.2e)" "$time_val" "$rms_val"
        fi
    done
    printf "\n"
done

#-------------------------------------------------------------------------------
# Save results to CSV file
#-------------------------------------------------------------------------------
csv_file="rough_work/gpu_pipeline_optimization_results.csv"

# Build CSV header
csv_header="Backend"
for size in "${HYPERCUBE_SIZES[@]}"; do
    csv_header+=",Size_${size}_Time(s),Size_${size}_RMS_Error"
done
echo "$csv_header" > "$csv_file"

# Write data rows
for i in "${!backend_names[@]}"; do
    IFS='|' read -ra times_array <<< "${exec_times[$i]}"
    IFS='|' read -ra rms_array <<< "${rms_errors[$i]}"
    
    csv_row="${backend_names[$i]}"
    
    for j in "${!times_array[@]}"; do
        time_val="${times_array[$j]}"
        rms_val="${rms_array[$j]}"
        
        if [[ "$time_val" == "FAILED" ]]; then
            csv_row+=",FAILED,FAILED"
        else
            # Format RMS error to 5 significant figures for CSV
            formatted_rms=$(LC_NUMERIC=C printf "%.5g" "$rms_val")
            csv_row+=",$time_val,$formatted_rms"
        fi
    done
    
    echo "$csv_row" >> "$csv_file"
done

echo "Results saved to $csv_file"


