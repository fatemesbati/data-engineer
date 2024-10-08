#!/bin/bash

# Define the main log file and the categorized log files
LOG_FILE="file.log"
INFO_LOG="log-info.log"
WARNING_LOG="log-warning.log"
ERROR_LOG="log-error.log"

# Define the maximum size for each log file (1 MB in bytes)
MAX_SIZE=1048576

# Function to rotate log files if they exceed the maximum size
rotate_log() {
    local log_file=$1
    local base_name=$(basename "$log_file" .log)  # Get the base name of the log file
    local count=1

    # Find the next available suffix for the rotated log file
    while [ -f "${base_name}-${count}.log" ]; do
        ((count++))
    done

    # Move the current log file to a new file with the incremental suffix
    mv "$log_file" "${base_name}-${count}.log"
    touch "$log_file"  # Create a new empty log file
}

# Function to process the main log file and categorize logs
process_log() {
    local log_type=$1
    local log_file=$2

    # Read the main log file from the end using tac and filter lines based on the log type
    while IFS= read -r line; do
        echo "$line" >> "$log_file"  # Append the line to the corresponding log file
        if [ $(stat -c%s "$log_file") -gt $MAX_SIZE ]; then  # Check if the log file exceeds the maximum size
            rotate_log "$log_file"  # Rotate the log file if it exceeds the maximum size
        fi
    done < <(tac "$LOG_FILE" | grep "$log_type")  # Filter lines based on the log type
}

# Process INFO logs
process_log "INFO" "$INFO_LOG"

# Process WARNING logs
process_log "WARNING" "$WARNING_LOG"

# Process ERROR logs
process_log "ERROR" "$ERROR_LOG"

