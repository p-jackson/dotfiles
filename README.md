# `dotfiles/`

## Installation

```bash
# Install Homebrew
$ /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install dependencies
$ brew install acsandmann/tap/rift awscli FelixKratz/formulae/borders fd fzf font-hack-nerd-font git hostctl kanata neovim pipx ripgrep rustup starship stow tmux trash
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

# Home-row mods (with Karabiner and Kanata)
# First, install Karabiner DriverKit manually from https://github.com/pqrs-org/Karabiner-DriverKit-VirtualHIDDevice
$ home-row-mods-install.sh

# Rust scripts setup
$ rustup default stable
$ cargo install rust-script
```

