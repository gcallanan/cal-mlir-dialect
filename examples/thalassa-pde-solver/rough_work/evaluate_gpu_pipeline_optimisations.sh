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
sleep_time=1
opt_level=3
NUM_TESTS=3
iterations=2000
HYPERCUBE_SIZES=(1000000 3000000 10000000)
#HYPERCUBE_SIZES=(1000000)

#===============================================================================
# DATA STRUCTURES
#===============================================================================
declare -a exec_times
declare -a rms_errors
declare -a backend_names
declare -a gpu_memcpy_times
declare -a gpu_kernel_times

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

#mem_time_ns=$(nsys stats --report cuda_gpu_mem_time_sum --force-export=true timeline.nsys-rep --format csv 2>/dev/null | awk -F',' 'NR>1 {sum += $2} END {print sum}')
#kern_ns_ns=$(nsys stats --report cuda_gpu_kern_sum --format csv timeline.nsys-rep 2>/dev/null | awk -F',' '/^[0-9]/ {sum += $2} END {print sum}')

run_benchmark_tests() {
    local command="$1"
    local backend_name="$2"
    local prof_enabled=false
    if [[ "$3" == *"-gpu_prof"* ]]; then
        prof_enabled=true
    fi
    local -a all_times
    local -a all_rms_errors
    local -a all_gpu_memcpy_times
    local -a all_gpu_kernel_times
    
    for hypercube_size in "${HYPERCUBE_SIZES[@]}"; do
        echo "    Testing with hypercube size: $hypercube_size"
        local -a times_for_avg=()
        local -a times_for_avg_gpu_memcpy=()
        local -a times_for_avg_gpu_kern=()
        local rms_error=""
        
        for ((test_run=1; test_run<=NUM_TESTS; test_run++)); do
            echo "        Test run ${test_run}/${NUM_TESTS}..."

            # Add hypercube size parameter to command
            local full_command="$command -h $hypercube_size -i $iterations"
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

            if [ "$prof_enabled" = true ]; then
                # Run GPU profiling and extract memcpy and kernel times using nsys
                nsys_command="nsys profile --trace-fork-before-exec true --force-overwrite true --trace=cuda,nvtx --output=timeline --stats=true ${full_command}"
                eval "$nsys_command" > /dev/null 2>&1
                mem_time_ns=$(nsys stats --report cuda_gpu_mem_time_sum --force-export=true timeline.nsys-rep --format csv 2>/dev/null | awk -F',' 'NR>1 {sum += $2} END {printf "%.0f", sum}')
                kern_time_ns=$(nsys stats --report cuda_gpu_kern_sum --force-export=true --format csv timeline.nsys-rep 2>/dev/null | awk -F',' '/^[0-9]/ {sum += $2} END {printf "%.0f", sum}')
                sleep $sleep_time
            else
                mem_time_ns="-1"
                kern_time_ns="-1"
            fi
            times_for_avg_gpu_memcpy+=("$mem_time_ns")
            times_for_avg_gpu_kern+=("$kern_time_ns")
            echo "            GPU MemCpy Time: ${mem_time_ns}ns"
            echo "            GPU Kernel Time: ${kern_time_ns}ns"
            echo "${backend_name},${hypercube_size},${exec_time},${rms_error},${mem_time_ns},${kern_time_ns},$((mem_time_ns + kern_time_ns))" >> rough_work/gpu_pipeline_optimization_log.csv
        done

        if [ ${#times_for_avg[@]} -eq $NUM_TESTS ]; then
            local avg_time=$(echo "${times_for_avg[@]}" | tr ' ' '\n' | LC_NUMERIC=C awk '{sum+=$1} END {printf "%.4f", sum/NR}')
            all_times+=("$avg_time")
            all_rms_errors+=("$rms_error")
            local avg_mem_time_ns=$(echo "${times_for_avg_gpu_memcpy[@]}" | tr ' ' '\n' | awk '{sum+=$1} END {printf "%.0f", sum/NR}')
            local avg_kern_time_ns=$(echo "${times_for_avg_gpu_kern[@]}" | tr ' ' '\n' | awk '{sum+=$1} END {printf "%.0f", sum/NR}')
            all_gpu_memcpy_times+=("$avg_mem_time_ns")
            all_gpu_kernel_times+=("$avg_kern_time_ns")
            echo "        Completed successfully (avg time: ${avg_time}s, rms error: ${rms_error})"
        else
            echo "        Some test runs failed, not calculating average time."
            all_times+=("FAILED")
            all_rms_errors+=("FAILED")
            all_gpu_memcpy_times+=("FAILED")
            all_gpu_kernel_times+=("FAILED")
        fi
    done
    
    # Store results for all hypercube sizes
    exec_times+=("$(IFS='|'; echo "${all_times[*]}")")
    rms_errors+=("$(IFS='|'; echo "${all_rms_errors[*]}")")
    gpu_kernel_times+=("$(IFS='|'; echo "${all_gpu_kernel_times[*]}")")
    gpu_memcpy_times+=("$(IFS='|'; echo "${all_gpu_memcpy_times[*]}")")
    backend_names+=("$backend_name")
    return 0
}

#===============================================================================
# GPU OPTIMIZATION TESTING
#===============================================================================

echo "Log generated at: $(date)" >> rough_work/gpu_pipeline_optimization_log.csv
echo "backend,hypercube_size,exec_time,rms_error,memcpy_time_ns,kernel_time_ns,gpu_total_ns" >> rough_work/gpu_pipeline_optimization_log.csv

echo "Running pytorch backend on the CPU"
run_benchmark_tests "bash rough_work/compile_and_run_equations_using_pytorch.sh" "pytorch |cpu"
echo "Running CAL-MLIR backend on the CPU"
run_benchmark_tests "bash 2_compile_and_run_equations.sh" "cal-mlir|cpu"
echo "Running CAL-MLIR backend on the CPU"
run_benchmark_tests "bash 2_compile_and_run_equations.sh -m" "cal-mlir|cpu|merged"
echo "Running pytorch backend on the GPU"
run_benchmark_tests "bash rough_work/compile_and_run_equations_using_pytorch.sh -g" "pytorch |gpu" -gpu_prof
echo "Running cuda implementation on the GPU"
run_benchmark_tests "bash rough_work/compile_and_run_cuda.sh" "cuda |gpu" -gpu_prof
echo "Running CAL-MLIR backend on the GPU"
run_benchmark_tests "bash 2_compile_and_run_equations.sh -g -d" "cal-mlir|gpu" -gpu_prof
echo "Running CAL-MLIR backend on the GPU with hoisting"
run_benchmark_tests "bash 2_compile_and_run_equations.sh -g" "cal-mlir|gpu|hoisting" -gpu_prof
echo "Running CAL-MLIR backend on the GPU with asynchonous streams"
run_benchmark_tests "bash 2_compile_and_run_equations.sh -g -d -s" "cal-mlir|gpu|async" -gpu_prof
echo "Running CAL-MLIR backend on the GPU with hoisting and asynchonous streams"
run_benchmark_tests "bash 2_compile_and_run_equations.sh -g -s" "cal-mlir|gpu|async&hoisting" -gpu_prof
echo "Running CAL-MLIR backend on the GPU with actor chains merged"
run_benchmark_tests "bash 2_compile_and_run_equations.sh -g -d -m" "cal-mlir|gpu|merged" -gpu_prof
echo "Running CAL-MLIR backend on the GPU with actor chains merged and hoisting"
run_benchmark_tests "bash 2_compile_and_run_equations.sh -g -m" "cal-mlir|gpu|merged&hoisted" -gpu_prof
# #echo "Running CAL-MLIR backend on the GPU with actor chains merged and asynchonous streams"
# #run_benchmark_tests "bash 2_compile_and_run_equations.sh -g -d -m -s" "cal-mlir|gpu|merged&async" -gpu_prof
# #echo "Running CAL-MLIR backend on the GPU with actor chains merged, hoisting and asynchonous streams"
# #run_benchmark_tests "bash 2_compile_and_run_equations.sh -g -m -s" "cal-mlir|gpu|merged&async&hoisted" -gpu_prof

#===============================================================================
# RESULTS DISPLAY AND ANALYSIS
#===============================================================================

echo
echo "=== Performance Results ==="
echo

# Print table header
hypercube_header=""
subheading_row=""
for size in "${HYPERCUBE_SIZES[@]}"; do
    hypercube_header+="|| $(printf "Size %-35s" "$size") "
    subheading_row+="|| Time   |RMS      |MemCpy |Kern   |GPU_Tot"
done

printf "%-35s %s\n" "Backend" "$hypercube_header"
printf "%-35s %s\n" "" "$subheading_row"
printf "%-35s-" "-----------------------------------"
for size in "${HYPERCUBE_SIZES[@]}"; do
    printf "++%-42s" "------------------------------------------"
done
printf "\n"


# Print results table
for i in "${!backend_names[@]}"; do
    IFS='|' read -ra times_array <<< "${exec_times[$i]}"
    IFS='|' read -ra rms_array <<< "${rms_errors[$i]}"
    IFS='|' read -ra memcpy_array <<< "${gpu_memcpy_times[$i]}"
    IFS='|' read -ra kernel_array <<< "${gpu_kernel_times[$i]}"
    
    printf "%-35s " "${backend_names[$i]}"
    
    for j in "${!times_array[@]}"; do
        time_val="${times_array[$j]}"
        rms_val="${rms_array[$j]}"
        memcpy_val="${memcpy_array[$j]}"
        # Convert from nanoseconds to seconds with max 3 decimal places
        if [[ "$memcpy_val" =~ ^[0-9]+$ ]]; then
            memcpy_val=$(LC_NUMERIC=C awk "BEGIN {printf \"%.3f\", $memcpy_val / 1000000000}")
        fi
        kernel_val="${kernel_array[$j]}"
        # Convert from nanoseconds to seconds with max 3 decimal places
        if [[ "$kernel_val" =~ ^[0-9]+$ ]]; then
            kernel_val=$(LC_NUMERIC=C awk "BEGIN {printf \"%.3f\", $kernel_val / 1000000000}")
        fi
        
        if [[ "$time_val" == "FAILED" ]]; then
            printf "|| %-20s" "FAILED"
        else
            # Calculate GPU total if both memcpy and kernel are integers
            if [[ "$memcpy_val" =~ ^[0-9.]+$ ]] && [[ "$kernel_val" =~ ^[0-9.]+$ ]]; then
                gpu_total=$(LC_NUMERIC=C awk "BEGIN {printf \"%.3f\", $memcpy_val + $kernel_val}")
            else
                gpu_total=0
            fi
            # Format RMS value properly with scientific notation using awk to avoid locale issues
            formatted_rms=$(LC_NUMERIC=C awk "BEGIN {printf \"%.2e\", $rms_val}")
            LC_NUMERIC=C printf "|| %7s|%9s|%7s|%7s|%7s" "$time_val" "$formatted_rms" "$memcpy_val" "$kernel_val" "$gpu_total"
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
    csv_header+=",Size_${size}_Time(s),Size_${size}_RMS_Error,Size_${size}_GPU_MemCopy(ns),Size_${size}_GPU_Kernel(ns),Size_${size}_GPU_Total(ns)"
done
echo "$csv_header" > "$csv_file"

# Write data rows
for i in "${!backend_names[@]}"; do
    IFS='|' read -ra times_array <<< "${exec_times[$i]}"
    IFS='|' read -ra rms_array <<< "${rms_errors[$i]}"
    IFS='|' read -ra memcpy_array <<< "${gpu_memcpy_times[$i]}"
    IFS='|' read -ra kernel_array <<< "${gpu_kernel_times[$i]}"
    
    csv_row="${backend_names[$i]}"
    
    for j in "${!times_array[@]}"; do
        time_val="${times_array[$j]}"
        rms_val="${rms_array[$j]}"
        memcpy_val="${memcpy_array[$j]}"
        kernel_val="${kernel_array[$j]}"
        
        if [[ "$time_val" == "FAILED" ]]; then
            csv_row+=",FAILED,FAILED,FAILED,FAILED,FAILED"
        else
            # Format RMS error to 5 significant figures for CSV
            formatted_rms=$(LC_NUMERIC=C printf "%.5g" "$rms_val")
            # Calculate GPU total if both memcpy and kernel are integers
            if [[ "$memcpy_val" =~ ^[0-9]+$ ]] && [[ "$kernel_val" =~ ^[0-9]+$ ]]; then
                gpu_total=$((memcpy_val + kernel_val))
            else
                gpu_total=0
            fi
            csv_row+=",$time_val,$formatted_rms,$memcpy_val,$kernel_val,$gpu_total"
        fi
    done
    
    echo "$csv_row" >> "$csv_file"
done

echo "Results saved to $csv_file"


