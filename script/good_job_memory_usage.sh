#!/bin/bash

# Find all good job pids
PIDS=$(pgrep -f good_job)
total_memory_usage=0
for pid in $PIDS
do
  # Find memory usage of the pid and add to total
  process_memory_usage=$(ps -o rss= -p $pid)
  total_memory_usage=$(($total_memory_usage+$process_memory_usage))
done
# Return total memory usage of all good job processes
echo $total_memory_usage
