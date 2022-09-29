#!/bin/bash

# Find all delayed job pids
PIDS=$(pgrep -f jobs:work)
total_memory_usage=0
for pid in $PIDS
do
  # Find memory usage of the pid and add to total
  process_memory_usage=$(ps -o rss= -p $pid)
  total_memory_usage=$(($total_memory_usage+$process_memory_usage))
done
# Return total memory usage of all delayed job processes
echo $total_memory_usage
