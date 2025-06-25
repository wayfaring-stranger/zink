#!/bin/bash
run_killport() {
  port=$1
  silent=$2

  if [[ -z $port ]]; then
    echo "Please provide a port number as an argument"
    exit 1
  fi

  # Function to echo only if not in silent mode
  log_msg() {
    if [[ "$silent" != "silent" ]]; then
      echo "$1"
    fi
  }

  # Get all processes using the port
  log_msg "Finding processes on port $port..."
  processes=($(lsof -t -i:$port))
  if [[ ${#processes[@]} -eq 0 ]]; then
    log_msg "No processes found running on port $port"
    exit 0
  fi

  # Kill each process individually
  log_msg "Found ${#processes[@]} process(es):"
  for pid in "${processes[@]}"; do
    log_msg "kill-process:[$pid]"
    kill -9 $pid
  done

  log_msg "Port $port cleared"
}

run_killport $@