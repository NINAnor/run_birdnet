#!/bin/bash

set -euo pipefail
source .env

# Parameters
echo "Running with the following parameters:"
echo "DATA_DIR: $DATA_DIR"
echo "OUTPUT: $OUTPUT"
echo "START_TIME: $START_TIME"
echo "END_TIME: $END_TIME"
echo "JOBS: $JOBS"
echo "SPECIES LIST: $SPECIES_LIST"

# Create output directory if it doesn't exist
mkdir -p "$OUTPUT"

# Function to process a single file
process_file() {
    local INPUT="$1"
    local OUTPUT="$2"
    local SPECIES_LIST="$3"
    local FILENAME=$(basename "$INPUT")
    
    echo "Processing: $FILENAME"
    uv run birdnet-analyze "$INPUT" --slist "$SPECIES_LIST" -o "$OUTPUT" 
}
export -f process_file

# Collect files matching the time range
find_files() {
    local DATA_DIR="$1"
    local START_TIME="$2"
    local END_TIME="$3"
    for INPUT in "$DATA_DIR"/*/*/*.wav; do
        FILENAME=$(basename "$INPUT")
        
        if [[ $FILENAME =~ _([0-9]{8})_([0-9]{6})\.wav$ ]]; then
            TIME="${BASH_REMATCH[2]}"
            
            # Check if time is within range
            if [ "$TIME" -ge "$START_TIME" ] && [ "$TIME" -le "$END_TIME" ]; then
                echo "$INPUT"
            fi
        fi
    done
}

# Process files in parallel using GNU parallel or xargs
echo "Using GNU parallel with $JOBS jobs"
find_files "$DATA_DIR" "$START_TIME" "$END_TIME" | parallel --joblog birdnet_parallel.log --resume --progress -j "$JOBS" process_file {} "$OUTPUT" "$SPECIES_LIST"
echo "Analysis complete!"
