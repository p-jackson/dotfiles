set originalFocus to (path to frontmost application as text)

tell application "System Events"
    tell process "AutoProxxy"
        click menu bar item 1 of menu bar 2
        click menu item "Force Reconnection" of menu 1 of menu bar item 1 of menu bar 2
    end tell
end tell

tell application (originalFocus)
		activate
end tell
