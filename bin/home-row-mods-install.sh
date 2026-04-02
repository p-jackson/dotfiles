#!/bin/bash

set -e

KANATA_BIN=$(which kanata)
USERNAME=$(whoami)
CONFIG_PATH="/Users/$USERNAME/.config/kanata/kanata.kbd"

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
  echo "Please install from https://github.com/pqrs-org/Karabiner-DriverKit-VirtualHIDDevice/releases"
  echo "Then run: /Applications/.Karabiner-VirtualHIDDevice-Manager.app/Contents/MacOS/Karabiner-VirtualHIDDevice-Manager activate"
  exit 1
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
sudo launchctl bootstrap system "$KANATA_PLIST"

echo "Done. Both services are running."
