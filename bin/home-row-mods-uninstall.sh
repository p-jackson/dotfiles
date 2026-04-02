#!/bin/bash

# 1. Stop Kanata first
sudo launchctl bootout system /Library/LaunchDaemons/com.kanata.service.plist 2>/dev/null

# 2. Stop Karabiner HID Daemon second
sudo launchctl bootout system /Library/LaunchDaemons/org.pqrs.Karabiner-VirtualHIDDevice-Daemon.plist 2>/dev/null

# 3. Remove the plists
sudo rm -f /Library/LaunchDaemons/com.kanata.service.plist
sudo rm -f /Library/LaunchDaemons/org.pqrs.Karabiner-VirtualHIDDevice-Daemon.plist

echo "Done. Plists removed."
echo "Now manually disable both in System Settings > General > Login Items if they appear."
