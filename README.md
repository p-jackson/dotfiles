# `dotfiles/`

## Installation

```bash
# Install Homebrew
$ /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install dependencies
$ brew install fd fzf git lazygit neovim ripgrep starship stow tmux

# Create config home ourselves so that it's not "owned" by stow
$ mkdir ~/.config

# Link our dotfiles into place using stow
$ cd ~/dev/dotfiles
$ stow . -t ~ --dotfiles

# Install Alacritty theme (after Alacritty config dir has been linked)
$ git clone https://github.com/alacritty/alacritty-theme ~/.config/alacritty/themes
```

