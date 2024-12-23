#!/usr/bin/env bash

volume=(
	script="$PLUGIN_DIR/volume.sh"
	label.font="$FONT:Black:12.0"
	icon.font="Hack Nerd Font:Regular:22.0"
	background.padding_left=30
)

sketchybar \
	--add item volume right --set volume "${volume[@]}" --subscribe volume volume_change
