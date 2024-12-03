#!/bin/bash

# Path to the log files directory
LOG_DIR="/var/log"

# The Graylog input port (e.g., port 12201 for Raw/Plaintext TCP input)
GRAYLOG_PORT="5555"

# Directory to store sent log markers (to avoid re-sending)
SENT_LOGS_DIR="/tmp/sent_logs"
mkdir -p "$SENT_LOGS_DIR"

# Function to send the entire log file to Graylog
send_entire_log() {
  local log_file="$1"
  echo "Sending entire log file: $log_file"
  cat "$log_file" | nc -w 1 localhost "$GRAYLOG_PORT"
}

# Function to send new log lines to Graylog
send_new_log_lines() {
  local temp_file="$1"
  echo "Sending new lines from temporary file"
  cat "$temp_file" | nc -w 1 localhost "$GRAYLOG_PORT"
}

# Loop through each log file in /var/log directory
find "$LOG_DIR" -type f -name "*.log" | while read -r log_file; do
  # Check if the log file has already been processed
  if [ -f "$SENT_LOGS_DIR/$(basename "$log_file")" ]; then
    echo "Skipping already processed file: $log_file"
    continue
  fi

  echo "Processing file: $log_file"

  # Step 1: Send the entire log file to Graylog
  send_entire_log "$log_file"

  # Initialize a temporary file to store new lines
  temp_file=$(mktemp)

  # Step 2: Use tail -F to follow new lines in the log file
  tail -F "$log_file" | while read -r new_line; do
    # Append the new line to the temporary file
    echo "$new_line" >> "$temp_file"

    # Send the new log lines to Graylog whenever a new line is added
    send_new_log_lines "$temp_file"

    # Clear the temporary file after sending the lines
    > "$temp_file"
  done &

  # Mark the file as processed by creating a marker file
  touch "$SENT_LOGS_DIR/$(basename "$log_file")"

done
