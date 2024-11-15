# use zsh bash directly as its called from both
DOTFILES=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

if test ! $(which brew); then
    echo 'Installing homebrew...'
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
    echo 'Done installing homebrew.'
fi

rm -rf "$HOME/Brewfile"
ln -s "$DOTFILES/Brewfile" "$HOME/Brewfile"
brew bundle install

rm -rf "$HOME/.config/kitty"
ln -s "$DOTFILES/kitty" "$HOME/.config/kitty"

if test ! -d "$HOME/.tmux/plugins/tpm"; then
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
fi

rm -rf "$HOME/.tmux.conf"
ln -s "$DOTFILES/tmux/tmux.conf" "$HOME/.tmux.conf"

rm -rf "$HOME/.aerospace.toml"
ln -s "$DOTFILES/aerospace/.aerospace.toml" "$HOME/.aerospace.toml"

rm -rf "$HOME/.ideavimrc"
ln -s "$DOTFILES/jetbrains/.ideavimrc" "$HOME/.ideavimrc"

mkdir -p "$HOME/.local/bin"
rm -rf "$HOME/.local/bin/t"
ln -s "$DOTFILES/scripts/t" "$HOME/.local/bin/t"

mkdir -p "$HOME/.local/bin"
rm -rf "$HOME/.local/bin/lf-pick"
ln -s "$DOTFILES/scripts/lf-pick" "$HOME/.local/bin/lf-pick"

mkdir -p "$HOME/.local/bin"
rm -rf "$HOME/.local/bin/vuelsp"
ln -s "$DOTFILES/scripts/vuelsp" "$HOME/.local/bin/vuelsp"

mkdir -p "$HOME/.config/borders"
rm -rf "$HOME/.config/borders/bordersrc"
ln -s "$DOTFILES/borders/bordersrc" "$HOME/.config/borders/bordersrc"
brew services start borders

rm -rf "$HOME/.config/starship.toml"
ln -s "$DOTFILES/starship/starship.toml" "$HOME/.config/starship.toml"

rm -rf "$HOME/.config/nvim"
ln -s "$DOTFILES/nvim" "$HOME/.config/nvim"

rm -rf "$HOME/.config/helix"
ln -s "$DOTFILES/helix" "$HOME/.config/helix"

rm -rf "$HOME/.aliases"
ln -s "$DOTFILES/shell/.aliases" "$HOME/.aliases"

rm -rf "$HOME/.exports"
ln -s "$DOTFILES/shell/.exports" "$HOME/.exports"

rm -rf "$HOME/.functions"
ln -s "$DOTFILES/shell/.functions" "$HOME/.functions"

#rm -rf "$HOME/.config/zellij"
#ln -s "$DOTFILES/zellij" "$HOME/.config/zellij"

rm -rf "$(bat --config-dir)/themes"
mkdir -p "$(bat --config-dir)"
ln -s "$DOTFILES/bat/themes" "$(bat --config-dir)/themes"
bat cache --build

if [ "$SHELL" = "/bin/zsh" ]; then
    echo "zsh section"
    rm -rf "$HOME/.zshrc"
    ln -s "$DOTFILES/shell/.zshrc" "$HOME/.zshrc"
    source "$HOME/.zshrc"

    mkdir -p "$HOME/.local/share/zsh/completions"
    refreshcompletions

    mkdir -p "$HOME/Library/pnpm"
    pnpm add -g svelte-language-server typescript typescript-language-server
    pnpm self-update
#    You may need to run this for zsh completions
#    autoload -Uz zsh-newuser-install && zsh-newuser-install -f
fi

if [ "$SHELL" = "/bin/bash" ]; then
    echo "bash section"
    rm -rf "$HOME/.bash_profile"
    ln -s "$DOTFILES/shell/.bash_profile" "$HOME/.bash_profile"
    source "$HOME/.bash_profile"
fi

