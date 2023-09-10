#!/usr/bin/env zsh

DOTFILES=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

if test ! $(which brew); then
    echo 'Installing homebrew...'
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
    echo 'Done installing homebrew.'
fi

rm -rf "$HOME/Brewfile"
ln -s "$DOTFILES/Brewfile" "$HOME/Brewfile"
brew bundle install

go install golang.org/x/tools/gopls@latest          # LSP
go install github.com/go-delve/delve/cmd/dlv@latest # Debugger
go install golang.org/x/tools/cmd/goimports@latest  # Formatter

rm -rf "$HOME/.zshrc"
ln -s "$DOTFILES/zsh/.zshrc" "$HOME/.zshrc"
source "$HOME/.zshrc"

rm -rf "$HOME/.config/kitty"
ln -s "$DOTFILES/kitty" "$HOME/.config/kitty"

if test ! -d "$HOME/.tmux/plugins/tpm"; then
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
fi

rm -rf "$HOME/.tmux.conf"
ln -s "$DOTFILES/tmux/tmux.conf" "$HOME/.tmux.conf"

mkdir -p "$HOME/.local/bin"
rm -rf "$HOME/.local/bin/t"
ln -s "$DOTFILES/scripts/t" "$HOME/.local/bin/t"

mkdir -p "$HOME/.local/bin"
rm -rf "$HOME/.local/bin/lf-pick"
ln -s "$DOTFILES/scripts/lf-pick" "$HOME/.local/bin/lf-pick"

mkdir -p "$HOME/.local/bin"
rm -rf "$HOME/.local/bin/vuelsp"
ln -s "$DOTFILES/scripts/vuelsp" "$HOME/.local/bin/vuelsp"

rm -rf "$HOME/.config/nvim"
ln -s "$DOTFILES/nvim" "$HOME/.config/nvim"

rm -rf "$HOME/.config/helix"
ln -s "$DOTFILES/helix" "$HOME/.config/helix"

rm -rf "$HOME/.config/zellij"
ln -s "$DOTFILES/zellij" "$HOME/.config/zellij"

rm -rf "$(bat --config-dir)/themes"
mkdir -p "$(bat --config-dir)"
ln -s "$DOTFILES/bat/themes" "$(bat --config-dir)/themes"
bat cache --build

mkdir -p "$HOME/Library/pnpm"
pnpm add -g svelte-language-server typescript typescript-language-server
