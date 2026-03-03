#!/bin/bash

# Script to add CPU affinity attributes to cal.create_instance operations
# Usage: ./add_cpu_affinity.sh

INPUT_FILE="myproject/code-gen/main.mlir"
OUTPUT_FILE="myproject/code-gen/main_multicore.mlir"

# Check if input file exists
if [ ! -f "$INPUT_FILE" ]; then
    echo "Error: $INPUT_FILE not found!"
    exit 1
fi

# Initialize CPU counter
cpu_count=0

# Process the file
while IFS= read -r line; do
    # Check if line contains cal.create_instance
    if echo "$line" | grep -q "cal.create_instance"; then
        # Determine current CPU affinity
        cpu_affinity="cpu${cpu_count}"
        
        # Add device_affinity attribute after the instance name but before the opening parenthesis
        # This handles lines like: cal.create_instance @actor "name" (...
        modified_line=$(echo "$line" | sed -E "s/(cal\.create_instance\s+@[^ ]+\s+\"[^\"]+\")/\1 device_affinity=\"${cpu_affinity}\"/")
        
        echo "$modified_line"
        
        # Increment and wrap CPU counter (0-3)
        cpu_count=$(( (cpu_count + 1) % 4 ))
    else
        # Output line as-is
        echo "$line"
    fi
done < "$INPUT_FILE" > "$OUTPUT_FILE"

echo "Created $OUTPUT_FILE with CPU affinity attributes"
echo "Instances distributed across cpu0, cpu1, cpu2, cpu3 in round-robin fashion"