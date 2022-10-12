#!/bin/bash

# Find all good job pids
PIDS=$(pgrep -f good_job)
# Return count
echo ${#PIDS[@]}
