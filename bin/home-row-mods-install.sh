#!/bin/bash

set -e

KANATA_BIN=$(command -v kanata || true)
USERNAME=$(whoami)
CONFIG_PATH="/Users/$USERNAME/.config/kanata/kanata.kbd"

# kanata 1.12 talks the VirtualHIDDevice v6 protocol; v8 (shipped by current
# Karabiner-Elements) fails with "connect_failed asio.system:2".
REQUIRED_DRIVER_MAJOR=6
REQUIRED_DRIVER_VERSION="6.2.0"
DRIVER_URL="https://github.com/pqrs-org/Karabiner-DriverKit-VirtualHIDDevice/releases/tag/v${REQUIRED_DRIVER_VERSION}"
VHID_MANAGER="/Applications/.Karabiner-VirtualHIDDevice-Manager.app/Contents/MacOS/Karabiner-VirtualHIDDevice-Manager"

KARABINER_DAEMON_BIN="/Library/Application Support/org.pqrs/Karabiner-DriverKit-VirtualHIDDevice/Applications/Karabiner-VirtualHIDDevice-Daemon.app/Contents/MacOS/Karabiner-VirtualHIDDevice-Daemon"
KARABINER_PLIST="/Library/LaunchDaemons/org.pqrs.Karabiner-VirtualHIDDevice-Daemon.plist"
KANATA_PLIST="/Library/LaunchDaemons/com.kanata.service.plist"

# --- Preflight checks ---

if [ -z "$KANATA_BIN" ]; then
  echo "Error: kanata binary not found in PATH. Is it installed?"
  exit 1
fi

if [ ! -f "$CONFIG_PATH" ]; then
  echo "Error: Kanata config not found at $CONFIG_PATH"
  exit 1
fi

if [ ! -f "$KARABINER_DAEMON_BIN" ]; then
  echo "Error: Karabiner-VirtualHIDDevice-Daemon binary not found."
  echo "Please install v${REQUIRED_DRIVER_VERSION} from ${DRIVER_URL}"
  echo "Then run: sudo '${VHID_MANAGER}' activate"
  exit 1
fi

DRIVER_VERSION=$(defaults read "${KARABINER_DAEMON_BIN%/MacOS/*}/Info.plist" CFBundleShortVersionString 2>/dev/null || echo unknown)
if [ "${DRIVER_VERSION%%.*}" != "$REQUIRED_DRIVER_MAJOR" ]; then
  echo "Error: Karabiner-DriverKit-VirtualHIDDevice is v${DRIVER_VERSION}, but kanata needs v${REQUIRED_DRIVER_MAJOR}.x."
  echo "Uninstall Karabiner-Elements if present, then run: sudo '${VHID_MANAGER}' deactivate"
  echo "Install v${REQUIRED_DRIVER_VERSION} from ${DRIVER_URL}"
  echo "Then run: sudo '${VHID_MANAGER}' activate"
  exit 1
fi

if [ -d "/Applications/Karabiner-Elements.app" ]; then
  echo "Warning: Karabiner-Elements is installed. It ships a newer driver that breaks kanata and"
  echo "         grabs the keyboard itself. Uninstall it (Settings > Misc > Uninstall)."
fi

# --- Karabiner VirtualHIDDevice Daemon ---

echo "Setting up Karabiner-VirtualHIDDevice-Daemon..."

sudo tee "$KARABINER_PLIST" > /dev/null <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
  "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>org.pqrs.Karabiner-VirtualHIDDevice-Daemon</string>

    <key>ProgramArguments</key>
    <array>
        <string>${KARABINER_DAEMON_BIN}</string>
    </array>

    <key>ProcessType</key>
    <string>Interactive</string>

    <key>RunAtLoad</key>
    <true/>

    <key>KeepAlive</key>
    <true/>

    <key>StandardOutPath</key>
    <string>/var/log/karabiner-hid-daemon.log</string>

    <key>StandardErrorPath</key>
    <string>/var/log/karabiner-hid-daemon.error.log</string>
</dict>
</plist>
EOF

sudo chown root:wheel "$KARABINER_PLIST"
sudo chmod 644 "$KARABINER_PLIST"
sudo launchctl bootout system "$KARABINER_PLIST" 2>/dev/null || true
sudo launchctl enable system/org.pqrs.Karabiner-VirtualHIDDevice-Daemon
sudo launchctl bootstrap system "$KARABINER_PLIST"

if ! sudo launchctl list | grep -q "org.pqrs.Karabiner-VirtualHIDDevice-Daemon"; then
  echo "Error: Karabiner-VirtualHIDDevice-Daemon failed to start. Aborting Kanata setup."
  exit 1
fi

echo "Karabiner-VirtualHIDDevice-Daemon is running."

# --- Kanata ---

echo "Setting up Kanata..."

sudo tee "$KANATA_PLIST" > /dev/null <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
  "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.kanata.service</string>

    <key>ProgramArguments</key>
    <array>
        <string>${KANATA_BIN}</string>
        <string>--cfg</string>
        <string>${CONFIG_PATH}</string>
    </array>

    <key>RunAtLoad</key>
    <true/>

    <key>KeepAlive</key>
    <true/>

    <key>ThrottleInterval</key>
    <integer>1</integer>

    <key>StandardOutPath</key>
    <string>/var/log/kanata.log</string>

    <key>StandardErrorPath</key>
    <string>/var/log/kanata.error.log</string>
</dict>
</plist>
EOF

sudo chown root:wheel "$KANATA_PLIST"
sudo chmod 644 "$KANATA_PLIST"
sudo launchctl bootout system "$KANATA_PLIST" 2>/dev/null || true
sudo launchctl enable system/com.kanata.service
sudo launchctl bootstrap system "$KANATA_PLIST"

# macOS pins permissions to the resolved binary path, not the Homebrew symlink,
# so this needs redoing after every `brew upgrade kanata`.
KANATA_REAL_BIN=$(realpath "$KANATA_BIN")

echo "Done. Both services are loaded."
echo
echo "Now grant kanata permissions in System Settings > Privacy & Security, under BOTH:"
echo "  - Input Monitoring"
echo "  - Accessibility"
echo "Click +, press Cmd+Shift+G and add: $KANATA_REAL_BIN"
echo "(Remove any stale kanata entries pointing at an old path first.)"
echo
echo "launchd restarts kanata every few seconds, so it picks up permissions on its own."
echo "Check it with: tail -f /var/log/kanata.log /var/log/kanata.error.log"
