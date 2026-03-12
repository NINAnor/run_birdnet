#!/bin/bash

set -euo pipefail
source .env

# Parameters
echo "Running with the following parameters:"
echo "RCLONE_REMOTE: $RCLONE_REMOTE"
echo "REMOTE_PATH: $REMOTE_PATH"
echo "OUTPUT: $OUTPUT"
echo "START_TIME: $START_TIME"
echo "END_TIME: $END_TIME"
echo "JOBS: $JOBS"
echo "SPECIES LIST: $SPECIES_LIST"

# Create output directory if it doesn't exist
mkdir -p "$OUTPUT"

# Function to process a single file from remote storage
process_file_remote() {
    local REMOTE_FILE="$1"
    local OUTPUT="$2"
    local SPECIES_LIST="$3"
    local RCLONE_REMOTE="$4"

    local FILENAME=$(basename "$REMOTE_FILE")
    local TEMP_FILE="/tmp/birdnet_$$_$FILENAME"

    echo "Processing: $FILENAME"

    # Download file using rclone (copyto saves to a specific filename)
    if rclone copyto "$RCLONE_REMOTE:$REMOTE_FILE" "$TEMP_FILE" --no-traverse --quiet; then
        # Process the file
        uv run birdnet-analyze "$TEMP_FILE" --slist "$SPECIES_LIST" -o "$OUTPUT"

        # Clean up
        rm -f "$TEMP_FILE"
    else
        echo "Error downloading $REMOTE_FILE" >&2
        return 1
    fi
}
export -f process_file_remote

# Function to find files matching time range
find_files_remote() {
    local RCLONE_REMOTE="$1"
    local REMOTE_PATH="$2"
    local START_TIME="$3"
    local END_TIME="$4"

    # List all audio files (.wav, .mp3, .flac) using rclone
    rclone lsf "$RCLONE_REMOTE:$REMOTE_PATH" --recursive --files-only | \
    grep -Ei '\.(wav|mp3|flac)$' | \
    while read -r file; do
        FILENAME=$(basename "$file")
        TIME=""

        # Pattern 1: SITE_YYYYMMDD_HHMMSS.{ext}
        if [[ $FILENAME =~ _([0-9]{8})_([0-9]{6})\.(wav|mp3|flac)$ ]]; then
            TIME="${BASH_REMATCH[2]}"
        # Pattern 2: YYYY-MM-DDTHH_MM_SS.mmmZ.{ext}  (ISO 8601)
        elif [[ $FILENAME =~ ([0-9]{4})-([0-9]{2})-([0-9]{2})T([0-9]{2})_([0-9]{2})_([0-9]{2})\.[0-9]+Z\.(wav|mp3|flac)$ ]]; then
            TIME="${BASH_REMATCH[4]}${BASH_REMATCH[5]}${BASH_REMATCH[6]}"
        fi

        # Check if time is within range
        if [ -n "$TIME" ] && [ "$TIME" -ge "$START_TIME" ] && [ "$TIME" -le "$END_TIME" ]; then
            echo "$REMOTE_PATH/$file"
        fi
    done
}

# Process files in parallel
echo "Using GNU parallel with $JOBS jobs"
echo "Scanning remote storage for files..."

find_files_remote "$RCLONE_REMOTE" "$REMOTE_PATH" "$START_TIME" "$END_TIME" | \
parallel --joblog birdnet_rclone_parallel.log --resume --progress -j "$JOBS" \
    process_file_remote {} "$OUTPUT" "$SPECIES_LIST" "$RCLONE_REMOTE"

echo "Analysis complete!"
