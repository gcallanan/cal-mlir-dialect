#!/bin/bash
# filepath: /mnt/kingston/gareth/software-repos/mlir-cal/cal-mlir-dialect/partition_xml.sh

# Script to redistribute actor instances across multiple partitions in round-robin fashion
# Takes config.xml as input and generates config_partitioned.xml

INPUT_FILE="config.xml"
OUTPUT_FILE="config_partitioned.xml"
NUM_PARTITIONS=4

if [ ! -f "$INPUT_FILE" ]; then
    echo "Error: $INPUT_FILE not found!"
    exit 1
fi

echo "Redistributing instances across $NUM_PARTITIONS partitions..."

# Extract instance IDs from the input XML
INSTANCES=($(grep '<instance id=' "$INPUT_FILE" | sed 's/.*id="\([^"]*\)".*/\1/'))

if [ ${#INSTANCES[@]} -eq 0 ]; then
    echo "Error: No instances found in $INPUT_FILE"
    exit 1
fi

echo "Found ${#INSTANCES[@]} instances: ${INSTANCES[@]}"

# Separate sink and messenger instances
SINK_INSTANCES=()
MESSENGER_INSTANCES=()

for instance in "${INSTANCES[@]}"; do
    if [[ "$instance" == "sink"* ]]; then
        SINK_INSTANCES+=("$instance")
    elif [[ "$instance" == "messengers_"* ]]; then
        MESSENGER_INSTANCES+=("$instance")
    else
        # For any other instances, treat as messenger-like for round-robin
        MESSENGER_INSTANCES+=("$instance")
    fi
done

echo "Sink instances: ${SINK_INSTANCES[@]}"
echo "Messenger instances: ${MESSENGER_INSTANCES[@]}"

# Start writing the output XML
cat > "$OUTPUT_FILE" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<configuration>
    <partitioning>
EOF

# Create partitions and distribute instances
for ((partition=0; partition<NUM_PARTITIONS; partition++)); do
    echo "        <partition id=\"$partition\" scheduling=\"ROUND_ROBIN\">" >> "$OUTPUT_FILE"
    
    # Always put sink instances in partition 0
    if [ $partition -eq 0 ]; then
        for sink_instance in "${SINK_INSTANCES[@]}"; do
            echo "            <instance id=\"$sink_instance\"/>" >> "$OUTPUT_FILE"
        done
    fi
    
    # Distribute messenger instances in round-robin fashion across all partitions
    for ((i=partition; i<${#MESSENGER_INSTANCES[@]}; i+=NUM_PARTITIONS)); do
        echo "            <instance id=\"${MESSENGER_INSTANCES[$i]}\"/>" >> "$OUTPUT_FILE"
    done
    
    echo "        </partition>" >> "$OUTPUT_FILE"
done

# Close the partitioning section
echo "    </partitioning>" >> "$OUTPUT_FILE"

# Extract and copy the connections section unchanged
echo "    <connections>" >> "$OUTPUT_FILE"
sed -n '/<connections>/,/<\/connections>/p' "$INPUT_FILE" | grep '<fifo-connection' >> "$OUTPUT_FILE"
echo "    </connections>" >> "$OUTPUT_FILE"

# Close the configuration
echo "</configuration>" >> "$OUTPUT_FILE"

echo "Successfully created $OUTPUT_FILE with $NUM_PARTITIONS partitions:"
echo "  Partition 0 (sink): ${SINK_INSTANCES[@]}"
for ((partition=0; partition<NUM_PARTITIONS; partition++)); do
    echo -n "  Partition $partition (messengers): "
    messenger_instances_in_partition=""
    for ((i=partition; i<${#MESSENGER_INSTANCES[@]}; i+=NUM_PARTITIONS)); do
        messenger_instances_in_partition+="${MESSENGER_INSTANCES[$i]} "
    done
    echo "$messenger_instances_in_partition"
done