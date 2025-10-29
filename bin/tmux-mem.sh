#!/usr/bin/env bash
# Approximate btop's "used" memory using vm_stat on macOS

mem_stats=$(vm_stat)
page_size=$(sysctl -n hw.pagesize)
total_bytes=$(sysctl -n hw.memsize)

# Extract page counts
pages_free=$(echo "$mem_stats" | awk '/Pages free/ {print $3}' | tr -d '.')
pages_inactive=$(echo "$mem_stats" | awk '/Pages inactive/ {print $3}' | tr -d '.')
pages_speculative=$(echo "$mem_stats" | awk '/Pages speculative/ {print $3}' | tr -d '.')
pages_compressed=$(echo "$mem_stats" | awk '/Pages occupied by compressor/ {print $5}' | tr -d '.')

# Calculate available memory similar to how btop does it
# (free + speculative are the most easily reclaimable)
available_bytes=$(( (pages_free + pages_inactive + pages_speculative + pages_compressed ) * page_size ))

# Everything else — including compressed and inactive — is treated as "used"
used_bytes=$(( total_bytes - available_bytes ))

# Convert to GB (1 decimal place)
used_gb=$(echo "scale=1; $used_bytes/1024/1024/1024" | bc)

echo "${used_gb} GB"
