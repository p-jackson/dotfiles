# `dotfiles/`

## Installation

```bash
# Install Homebrew
$ /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install dependencies
$ brew install awscli FelixKratz/formulae/borders fd fzf font-caskaydia-cove-nerd-font font-hack-nerd-font git lazygit neovim pipx ripgrep rustup FelixKratz/formulae/sketchybar starship stow tmux trash
$ brew install --cask sf-symbols
$ rustup default stable
$ cargo install rust-script

# Create config home ourselves so that it's not "owned" by stow
$ mkdir ~/.config

# Link our dotfiles into place using stow
$ cd ~/dev/dotfiles
$ stow . -t ~ --dotfiles

# Install Alacritty theme (after Alacritty config dir has been linked)
$ git clone https://github.com/alacritty/alacritty-theme ~/.config/alacritty/themes
```

