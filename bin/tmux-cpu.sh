#!/usr/bin/env bash
# Prints total CPU usage (all cores) on macOS

cores=$(sysctl -n hw.ncpu)
usage=$(ps -A -o %cpu | awk -v cores="$cores" '{s+=$1} END {printf "%.0f%%", s / cores}')
echo "$usage"
