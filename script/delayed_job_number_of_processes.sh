#!/bin/bash

# Find all delayed job pids
PIDS=$(pgrep -f jobs:work)
# Return count
echo ${#PIDS[@]}
