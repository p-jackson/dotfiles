#!/usr/bin/env bash

sketchybar --add event aerospace_workspace_change

$focused_workspace=$(aerospace list-workspaces --focused)

space_props=(
	background.color=0x40ffffff
	background.corner_radius=5
	background.height=20
	width=30
	align=center
	background.drawing=off
	label.drawing=off
)

for sid in $(aerospace list-workspaces --all); do
	sketchybar \
		--add item "space.$sid" left \
		--subscribe "space.$sid" aerospace_workspace_change \
		--set "space.$sid" \
			icon="$sid" \
			script="$PLUGIN_DIR/aerospace.sh '$sid'" \
			click_script="aerospace workspace '$sid'" \
			"${space_props[@]}"
done

