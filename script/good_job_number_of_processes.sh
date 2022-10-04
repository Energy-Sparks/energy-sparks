#!/bin/bash

# Find all delayed job pids
PIDS=$(pgrep -f good_job)
# Return count
echo ${#PIDS[@]}
