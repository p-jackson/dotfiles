# `dotfiles/`

## Installation

```bash
# Install Homebrew
$ /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install dependencies
$ brew install acsandmann/tap/rift awscli FelixKratz/formulae/borders fd fzf font-hack-nerd-font git hostctl kanata neovim pipx ripgrep rustup starship stow tmux trash tree-sitter-cli
$ brew install --cask sf-symbols
$ brew install --cask font-cascadia-code

# Create config home ourselves so that it's not "owned" by stow
$ mkdir ~/.config

# Link our dotfiles into place using stow
$ cd ~/dev/dotfiles
$ stow . -t ~ --dotfiles
$ source ~/.zshrc

# Window manager setup
$ rift service install
$ rift service start

# Home-row mods (with Karabiner and Kanata) - see "Home-row mods" below
$ home-row-mods-install.sh

# Rust scripts setup
$ rustup default stable
$ cargo install rust-script
```


## Home-row mods

Kanata (`dot-config/kanata/kanata.kbd`) runs as a root launchd daemon and sends
keystrokes through the Karabiner DriverKit virtual keyboard.

1. **Install the v6 driver, not the latest.** Kanata 1.12 only speaks the
   VirtualHIDDevice v6 protocol; v8+ fails with `connect_failed asio.system:2`
   in `/var/log/kanata.log`. Don't install Karabiner-Elements either, as it
   ships the newer driver (and grabs the keyboard itself).
   - Download and install `Karabiner-DriverKit-VirtualHIDDevice-6.2.0.pkg` from
     https://github.com/pqrs-org/Karabiner-DriverKit-VirtualHIDDevice/releases/tag/v6.2.0
   - Activate it, then approve the system extension in System Settings if asked:
     ```bash
     $ sudo '/Applications/.Karabiner-VirtualHIDDevice-Manager.app/Contents/MacOS/Karabiner-VirtualHIDDevice-Manager' activate
     ```
   - If a newer version is already installed, uninstall Karabiner-Elements and run
     the same command with `deactivate` first.
2. **Install the services:** `home-row-mods-install.sh` (checks the driver version
   and sets up both launchd daemons).
3. **Grant permissions.** In System Settings > Privacy & Security, add kanata
   under **both Input Monitoring and Accessibility**. Add the real binary
   (`realpath $(which kanata)`, e.g. `/opt/homebrew/Cellar/kanata/1.12.0/bin/kanata`),
   not the Homebrew symlink: click +, press Cmd+Shift+G and paste the path.
   macOS pins the permission to that path, so **redo this after every
   `brew upgrade kanata`** and remove the old entries.

launchd restarts kanata every few seconds until it works, so no restart is needed
after granting permissions. To troubleshoot:

```bash
$ tail -f /var/log/kanata.log /var/log/kanata.error.log
$ sudo launchctl kickstart -k system/com.kanata.service   # restart
$ kanata --list                                           # device names for macos-dev-names-include
```

To remove everything: `home-row-mods-uninstall.sh`.
