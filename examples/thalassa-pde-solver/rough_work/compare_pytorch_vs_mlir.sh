#!/bin/bash
#===============================================================================
# Performance comparison script for MLIR vs PyTorch PDE solver backends
#===============================================================================
# Description:
#   This script runs the advection-diffusion equation solver with different
#   optimization levels and compares execution times and numerical accuracy
#   between MLIR and PyTorch backends.
#
# Author: ChatGPT (vibe-coded)
#===============================================================================

echo "=== Thalassa PDE Solver Performance Comparison ==="
echo "Running advection-diffusion equation solver with MLIR (O0-O3) and PyTorch backends"
echo

#===============================================================================
# CONFIGURATION
#===============================================================================
NUM_TESTS=5  # Number of times to run each test for averaging execution time (default 20)
sleep_time=3  # Sleep time between runs to avoid system overload (default 5)
iterations=2000  # Number of iterations for the solver (default 1000)

echo "Iterations: $iterations"
#===============================================================================
# DATA STRUCTURES
#===============================================================================
# Arrays to store results for final comparison table
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

#===============================================================================
# MLIR BACKEND TESTING - No Optimisations
#===============================================================================

echo "Running MLIR backend with different optimization levels and CPU/GPU targets..."

# Run MLIR backend with optimization levels 0-3 and CPU/GPU targets
for opt_level in 0 1 2 3; do
    # Test CPU compilation
    echo "  Running MLIR with -O${opt_level} (CPU) (${NUM_TESTS} times for averaging)..."
    
    # Initialize arrays and variables for current optimization level
    declare -a times_for_avg
    rms_error=""
    
    # Run multiple times for averaging
    for ((test_run=1; test_run<=NUM_TESTS; test_run++)); do
        echo "    Test run ${test_run}/${NUM_TESTS}..."
        
        # Execute MLIR solver and capture output (CPU)
        output=$(bash 2_compile_and_run_equations.sh -O ${opt_level} -i $iterations 2>&1)
        exit_code=$?
        
        if [ $exit_code -eq 0 ]; then
            # Extract metrics from last two lines
            metrics=$(extract_metrics "$output")
            exec_time=$(echo "$metrics" | head -1)
            if [ -z "$rms_error" ]; then
                rms_error=$(echo "$metrics" | tail -1)
            fi
            echo "        Execution time: ${exec_time}s"
            sleep $sleep_time
            
            times_for_avg+=("$exec_time")
        else
            echo "    Failed with exit code $exit_code"
            break
        fi
    done
    
    # Calculate average execution time if all tests passed
    if [ ${#times_for_avg[@]} -eq $NUM_TESTS ]; then
        avg_time=$(echo "${times_for_avg[@]}" | tr ' ' '\n' | LC_NUMERIC=C awk '{sum+=$1} END {printf "%.4f", sum/NR}')
        
        backend_names+=("MLIR-O${opt_level}-CPU")
        exec_times+=("$avg_time")
        rms_errors+=("$rms_error")
        
        echo "    Completed successfully (avg time: ${avg_time}s, rms error: ${rms_error})"
    else
        backend_names+=("MLIR-O${opt_level}-CPU")
        exec_times+=("FAILED")
        rms_errors+=("FAILED")
    fi
    
    # Clean up array for next iteration
    unset times_for_avg
    
    # Test GPU compilation
    echo "  Running MLIR with -O${opt_level} -g (GPU) (${NUM_TESTS} times for averaging)..."
    
    # Initialize arrays and variables for current optimization level (GPU)
    declare -a times_for_avg
    rms_error=""
    
    # Run multiple times for averaging
    for ((test_run=1; test_run<=NUM_TESTS; test_run++)); do
        echo "    Test run ${test_run}/${NUM_TESTS}..."
        
        # Execute MLIR solver and capture output (GPU)
        output=$(bash 2_compile_and_run_equations.sh -O ${opt_level} -i $iterations -g 2>&1)
        exit_code=$?
        
        if [ $exit_code -eq 0 ]; then
            # Extract metrics from last two lines
            metrics=$(extract_metrics "$output")
            exec_time=$(echo "$metrics" | head -1)
            if [ -z "$rms_error" ]; then
                rms_error=$(echo "$metrics" | tail -1)
            fi
            echo "        Execution time: ${exec_time}s"
            sleep $sleep_time
            
            times_for_avg+=("$exec_time")
        else
            echo "    Failed with exit code $exit_code"
            break
        fi
    done
    
    # Calculate average execution time if all tests passed
    if [ ${#times_for_avg[@]} -eq $NUM_TESTS ]; then
        avg_time=$(echo "${times_for_avg[@]}" | tr ' ' '\n' | LC_NUMERIC=C awk '{sum+=$1} END {printf "%.4f", sum/NR}')
        
        backend_names+=("MLIR-O${opt_level}-GPU")
        exec_times+=("$avg_time")
        rms_errors+=("$rms_error")
        
        echo "    Completed successfully (avg time: ${avg_time}s, rms error: ${rms_error})"
    else
        backend_names+=("MLIR-O${opt_level}-GPU")
        exec_times+=("FAILED")
        rms_errors+=("FAILED")
    fi
    
    # Clean up array for next iteration
    unset times_for_avg
done

#===============================================================================
# MLIR BACKEND TESTING - Merging Pass Enabled
#===============================================================================

echo "Running MLIR backend with different optimization levels and CPU/GPU targets..."

# Run MLIR backend with optimization levels 0-3 and CPU/GPU targets
for opt_level in 0 1 2 3; do
    # Test CPU compilation
    echo "  Running MLIR with -O${opt_level} (CPU) and merging (${NUM_TESTS} times for averaging)..."
    
    # Initialize arrays and variables for current optimization level
    declare -a times_for_avg
    rms_error=""
    
    # Run multiple times for averaging
    for ((test_run=1; test_run<=NUM_TESTS; test_run++)); do
        echo "    Test run ${test_run}/${NUM_TESTS}..."
        
        # Execute MLIR solver and capture output (CPU)
        output=$(bash 2_compile_and_run_equations.sh -O ${opt_level} -m -i $iterations 2>&1)
        exit_code=$?
        
        if [ $exit_code -eq 0 ]; then
            # Extract metrics from last two lines
            metrics=$(extract_metrics "$output")
            exec_time=$(echo "$metrics" | head -1)
            if [ -z "$rms_error" ]; then
                rms_error=$(echo "$metrics" | tail -1)
            fi
            echo "        Execution time: ${exec_time}s"
            sleep $sleep_time
            
            times_for_avg+=("$exec_time")
        else
            echo "    Failed with exit code $exit_code"
            break
        fi
    done
    
    # Calculate average execution time if all tests passed
    if [ ${#times_for_avg[@]} -eq $NUM_TESTS ]; then
        avg_time=$(echo "${times_for_avg[@]}" | tr ' ' '\n' | LC_NUMERIC=C awk '{sum+=$1} END {printf "%.4f", sum/NR}')
        
        backend_names+=("MLIR-O${opt_level}-CPU-m")
        exec_times+=("$avg_time")
        rms_errors+=("$rms_error")
        
        echo "    Completed successfully (avg time: ${avg_time}s, rms error: ${rms_error})"
    else
        backend_names+=("MLIR-O${opt_level}-CPU-m")
        exec_times+=("FAILED")
        rms_errors+=("FAILED")
    fi
    
    # Clean up array for next iteration
    unset times_for_avg
    
    # Test GPU compilation
    echo "  Running MLIR with -O${opt_level} -g (GPU) and merging (${NUM_TESTS} times for averaging)..."
    
    # Initialize arrays and variables for current optimization level (GPU)
    declare -a times_for_avg
    rms_error=""
    
    # Run multiple times for averaging
    for ((test_run=1; test_run<=NUM_TESTS; test_run++)); do
        echo "    Test run ${test_run}/${NUM_TESTS}..."
        
        # Execute MLIR solver and capture output (GPU)
        output=$(bash 2_compile_and_run_equations.sh -O ${opt_level} -m -i $iterations -g 2>&1)
        exit_code=$?
        
        if [ $exit_code -eq 0 ]; then
            # Extract metrics from last two lines
            metrics=$(extract_metrics "$output")
            exec_time=$(echo "$metrics" | head -1)
            if [ -z "$rms_error" ]; then
                rms_error=$(echo "$metrics" | tail -1)
            fi
            echo "        Execution time: ${exec_time}s"
            sleep $sleep_time
            
            times_for_avg+=("$exec_time")
        else
            echo "    Failed with exit code $exit_code"
            break
        fi
    done
    
    # Calculate average execution time if all tests passed
    if [ ${#times_for_avg[@]} -eq $NUM_TESTS ]; then
        avg_time=$(echo "${times_for_avg[@]}" | tr ' ' '\n' | LC_NUMERIC=C awk '{sum+=$1} END {printf "%.4f", sum/NR}')
        
        backend_names+=("MLIR-O${opt_level}-GPU-m")
        exec_times+=("$avg_time")
        rms_errors+=("$rms_error")
        
        echo "    Completed successfully (avg time: ${avg_time}s, rms error: ${rms_error})"
    else
        backend_names+=("MLIR-O${opt_level}-GPU-m")
        exec_times+=("FAILED")
        rms_errors+=("FAILED")
    fi
    
    # Clean up array for next iteration
    unset times_for_avg
done

#===============================================================================
# PYTORCH BACKEND TESTING
#===============================================================================

echo
echo "Running PyTorch backend..."

# Run PyTorch backend (CPU)
echo "  Running PyTorch (CPU) (${NUM_TESTS} times for averaging)..."

# Initialize arrays and variables for PyTorch CPU testing
declare -a times_for_avg
rms_error=""

# Run multiple times for averaging
for ((test_run=1; test_run<=NUM_TESTS; test_run++)); do
    echo "    Test run ${test_run}/${NUM_TESTS}..."
    
    # Execute PyTorch solver and capture output (CPU)
    output=$(bash rough_work/compile_and_run_equations_using_pytorch.sh -i $iterations 2>&1)
    exit_code=$?
    
    if [ $exit_code -eq 0 ]; then
        # Extract metrics from last two lines
        metrics=$(extract_metrics "$output")
        exec_time=$(echo "$metrics" | head -1)
        if [ -z "$rms_error" ]; then
            rms_error=$(echo "$metrics" | tail -1)
        fi
        echo "        Execution time: ${exec_time}s"
        sleep $sleep_time
        
        times_for_avg+=("$exec_time")
    else
        echo "    Failed with exit code $exit_code"
        break
    fi
done

# Calculate average execution time if all tests passed
if [ ${#times_for_avg[@]} -eq $NUM_TESTS ]; then
    avg_time=$(echo "${times_for_avg[@]}" | tr ' ' '\n' | LC_NUMERIC=C awk '{sum+=$1} END {printf "%.4f", sum/NR}')
    
    backend_names+=("PyTorch-CPU")
    exec_times+=("$avg_time")
    rms_errors+=("$rms_error")
    
    echo "    Completed successfully (avg time: ${avg_time}s, rms error: ${rms_error})"
else
    backend_names+=("PyTorch-CPU")
    exec_times+=("FAILED")
    rms_errors+=("FAILED")
fi

# Clean up array
unset times_for_avg

# Run PyTorch backend (GPU)
echo "  Running PyTorch (GPU) (${NUM_TESTS} times for averaging)..."

# Initialize arrays and variables for PyTorch GPU testing
declare -a times_for_avg
rms_error=""

# Run multiple times for averaging
for ((test_run=1; test_run<=NUM_TESTS; test_run++)); do
    echo "    Test run ${test_run}/${NUM_TESTS}..."
    
    # Execute PyTorch solver and capture output (GPU)
    output=$(bash rough_work/compile_and_run_equations_using_pytorch.sh -i $iterations -g 2>&1)
    exit_code=$?
    
    if [ $exit_code -eq 0 ]; then
        # Extract metrics from last two lines
        metrics=$(extract_metrics "$output")
        exec_time=$(echo "$metrics" | head -1)
        if [ -z "$rms_error" ]; then
            rms_error=$(echo "$metrics" | tail -1)
        fi
        echo "        Execution time: ${exec_time}s"
        sleep $sleep_time
        
        times_for_avg+=("$exec_time")
    else
        echo "    Failed with exit code $exit_code"
        break
    fi
done

# Calculate average execution time if all tests passed
if [ ${#times_for_avg[@]} -eq $NUM_TESTS ]; then
    avg_time=$(echo "${times_for_avg[@]}" | tr ' ' '\n' | LC_NUMERIC=C awk '{sum+=$1} END {printf "%.4f", sum/NR}')
    
    backend_names+=("PyTorch-GPU")
    exec_times+=("$avg_time")
    rms_errors+=("$rms_error")
    
    echo "    Completed successfully (avg time: ${avg_time}s, rms error: ${rms_error})"
else
    backend_names+=("PyTorch-GPU")
    exec_times+=("FAILED")
    rms_errors+=("FAILED")
fi

# Clean up array
unset times_for_avg

#===============================================================================
# CUDA KERNEL TESTING
#===============================================================================

echo "Running CUDA kernel with different optimisation levels..."

# Run MLIR backend with optimization levels 0-3 and CPU/GPU targets
for opt_level in 0 1 2 3; do
    # Test CPU compilation
    echo "  Running CUDA with -O${opt_level} (${NUM_TESTS} times for averaging)..."
    
    # Initialize arrays and variables for current optimization level
    declare -a times_for_avg
    rms_error=""
    
    # Run multiple times for averaging
    for ((test_run=1; test_run<=NUM_TESTS; test_run++)); do
        echo "    Test run ${test_run}/${NUM_TESTS}..."
        
        # Execute MLIR solver and capture output (GPU)
        output=$(bash rough_work/compile_and_run_cuda.sh -O ${opt_level} -i $iterations 2>&1)
        exit_code=$?
        
        if [ $exit_code -eq 0 ]; then
            # Extract metrics from last two lines
            metrics=$(extract_metrics "$output")
            exec_time=$(echo "$metrics" | head -1)
            if [ -z "$rms_error" ]; then
                rms_error=$(echo "$metrics" | tail -1)
            fi
            echo "        Execution time: ${exec_time}s"
            sleep $sleep_time
            
            times_for_avg+=("$exec_time")
        else
            echo "    Failed with exit code $exit_code"
            break
        fi
    done
    
    # Calculate average execution time if all tests passed
    if [ ${#times_for_avg[@]} -eq $NUM_TESTS ]; then
        avg_time=$(echo "${times_for_avg[@]}" | tr ' ' '\n' | LC_NUMERIC=C awk '{sum+=$1} END {printf "%.4f", sum/NR}')
        
        backend_names+=("CUDA-O${opt_level}")
        exec_times+=("$avg_time")
        rms_errors+=("$rms_error")
        
        echo "    Completed successfully (avg time: ${avg_time}s, rms error: ${rms_error})"
    else
        backend_names+=("CUDA-O${opt_level}")
        exec_times+=("FAILED")
        rms_errors+=("FAILED")
    fi
    
    # Clean up array for next iteration
    unset times_for_avg
done

#===============================================================================
# RESULTS DISPLAY AND ANALYSIS
#===============================================================================

echo
echo "=== Performance Comparison Results ==="
echo

# Print table header
printf "%-12s | %-10s | %-15s | %-15s\n" "Backend" "Num Tests" "Exec Time (s)" "RMS Error"
printf "%-12s-+-%-10s-+-%-15s-+-%-15s\n" "------------" "----------" "---------------" "---------------"

# Print results table
for i in "${!backend_names[@]}"; do
    # Format RMS error to 5 significant figures
    if [[ "${rms_errors[$i]}" != "FAILED" ]]; then
        formatted_rms=$(LC_NUMERIC=C printf "%.5g" "${rms_errors[$i]}")
    else
        formatted_rms="${rms_errors[$i]}"
    fi
    printf "%-12s | %-10s | %-15s | %-15s\n" "${backend_names[$i]}" "$NUM_TESTS" "${exec_times[$i]}" "$formatted_rms"
done

#-------------------------------------------------------------------------------
# Save results to CSV file
#-------------------------------------------------------------------------------
csv_file="rough_work/comparison_results.csv"
echo "Backend,Num Tests,Exec Time (s),RMS Error" > "$csv_file"
for i in "${!backend_names[@]}"; do
    # Format RMS error to 5 significant figures for CSV
    if [[ "${rms_errors[$i]}" != "FAILED" ]]; then
        formatted_rms=$(LC_NUMERIC=C printf "%.5g" "${rms_errors[$i]}")
    else
        formatted_rms="${rms_errors[$i]}"
    fi
    echo "${backend_names[$i]},$NUM_TESTS,${exec_times[$i]},$formatted_rms" >> "$csv_file"
done
echo "Results saved to $csv_file"

#===============================================================================
# SUMMARY AND ANALYSIS
#===============================================================================

echo
echo "=== Summary ==="

# Find fastest successful run
fastest_time=""
fastest_backend=""
for i in "${!backend_names[@]}"; do
    if [[ "${exec_times[$i]}" != "FAILED" ]]; then
        if [[ -z "$fastest_time" ]] || (( $(echo "${exec_times[$i]} < $fastest_time" | bc -l) )); then
            fastest_time="${exec_times[$i]}"
            fastest_backend="${backend_names[$i]}"
        fi
    fi
done

if [[ -n "$fastest_backend" ]]; then
    echo "Fastest execution: $fastest_backend with ${fastest_time}s"
else
    echo "No successful runs completed"
fi

# Check if all RMS errors are similar (indicating numerical consistency)
echo
echo "Note: All successful runs should have similar RMS errors, indicating numerical consistency across backends."
echo "Large differences in RMS error may indicate implementation issues or numerical instability."