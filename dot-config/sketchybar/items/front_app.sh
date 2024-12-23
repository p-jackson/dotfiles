#!/usr/bin/env bash

chevron=(
	icon=$CHEVRON
	icon.font="Hack Nerd Font:Regular:16.0"
	label.drawing=off
	icon.color=$WHITE
	background.padding_left=30
	background.padding_right=15
)

sketchybar \
	--add item chevron left \
	--set chevron "${chevron[@]}" \
	--add item front_app left \
	--set front_app \
		icon.drawing=off \
		background.padding_left=0 \
		label.color=$WHITE \
		label.font="$FONT:Black:12.0" \
		script="$PLUGIN_DIR/front_app.sh" \
	--subscribe front_app front_app_switched

