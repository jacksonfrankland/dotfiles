#!/usr/bin/env bash

DOTFILES=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

rm -rf "$HOME/.config/kitty"
ln -s "$DOTFILES/kitty" "$HOME/.config/kitty"

# Install tmux plugins
if test ! -d "$HOME/.tmux/plugins/tpm"; then
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
fi

rm -rf "$HOME/.tmux.conf"
ln -s "$DOTFILES/tmux/tmux.conf" "$HOME/.tmux.conf"

mkdir -p "$HOME/.local/bin"
rm -rf "$HOME/.local/bin/t"
ln -s "$DOTFILES/scripts/t" "$HOME/.local/bin/t"

rm -rf "$HOME/.config/nvim"
ln -s "$DOTFILES/nvim" "$HOME/.config/nvim"

