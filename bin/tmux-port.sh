#!/usr/bin/env bash
# Print PORT from .env.local or .env, walking up from the active pane's cwd

dir="${1:-$(tmux display-message -p -F '#{pane_current_path}')}"
[ -z "$dir" ] && exit 0

while [ "$dir" != "/" ]; do
  for f in "$dir/.env.local" "$dir/.env"; do
    if [ -f "$f" ]; then
      port=$(grep -m1 '^PORT=' "$f" | cut -d= -f2 | tr -d '[:space:]"'"'")
      if [ -n "$port" ]; then
        echo "󱘖  = $port    "
        exit 0
      fi
    fi
  done
  dir=$(dirname "$dir")
done
