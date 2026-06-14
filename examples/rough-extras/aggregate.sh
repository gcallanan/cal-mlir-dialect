#!/usr/bin/env bash
set -e

OUTPUT="aggregated_results.csv"
DIRS=(idct qrd16x16 fft jpeg)

# Write header from first available CSV
HEADER_WRITTEN=false
for DIR in "${DIRS[@]}"; do
    CSV="$DIR/timing_results.csv"
    if [ -f "$CSV" ]; then
        head -1 "$CSV" > "$OUTPUT"
        HEADER_WRITTEN=true
        break
    fi
done

if [ "$HEADER_WRITTEN" = false ]; then
    echo "No timing_results.csv files found." >&2
    exit 1
fi

# Append data rows from each CSV, skipping headers
for DIR in "${DIRS[@]}"; do
    CSV="$DIR/timing_results.csv"
    if [ -f "$CSV" ]; then
        tail -n +2 "$CSV" >> "$OUTPUT"
    else
        echo "Warning: $CSV not found, skipping." >&2
    fi
done

echo "Aggregated results written to $OUTPUT"
