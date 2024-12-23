#!/usr/bin/env bash

battery=(
	update_freq=120
	script="$PLUGIN_DIR/battery.sh"
	label.font="$FONT:Black:12.0"
	icon.font="$FONT:Black:16.0"
)

sketchybar --add item battery right --set battery "${battery[@]}" --subscribe battery system_woke power_source_change

