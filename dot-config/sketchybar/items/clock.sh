#!/usr/bin/env bash

clock=(
	update_freq=15
	label.font="$FONT:Black:12.0" \
	label.align=right
	background.padding_left=30
	align=center
	script="$PLUGIN_DIR/clock.sh"
)

sketchybar --add item clock right --set clock "${clock[@]}"

