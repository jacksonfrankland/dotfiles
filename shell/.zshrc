eval "$(starship init zsh)"

source $HOME/.aliases

alias dh='dirs -v'
for index ({1..99}) alias "$index"="cd +${index}"; unset index

setopt AUTO_PUSHD           # Push the current directory visited on the stack.
setopt PUSHD_IGNORE_DUPS    # Do not store duplicates in the stack.
setopt PUSHD_SILENT         # Do not print the directory stack after pushd or popd.

# Setup a custom completions directory
fpath=($HOME/.local/share/zsh/completions $fpath)
autoload -U compinit; compinit
_comp_options+=(globdots) # With hidden files

source $HOME/.functions
source $HOME/.exports

if type brew &>/dev/null
then
  HOMEBREW_PREFIX="$(brew --prefix)"
  if [[ -r "${HOMEBREW_PREFIX}/etc/profile.d/bash_completion.sh" ]]
  then
    source "${HOMEBREW_PREFIX}/etc/profile.d/bash_completion.sh"
  else
    for COMPLETION in "${HOMEBREW_PREFIX}/etc/bash_completion.d/"*
    do
      [[ -r "${COMPLETION}" ]] && source "${COMPLETION}"
    done
  fi
fi

# fastfetch

# Herd injected PHP 8.3 configuration.
export HERD_PHP_83_INI_SCAN_DIR="/Users/jacksonfrankland/Library/Application Support/Herd/config/php/83/"


# Herd injected PHP binary.
export PATH="/Users/jacksonfrankland/Library/Application Support/Herd/bin/":$PATH


# Herd injected PHP 8.4 configuration.
export HERD_PHP_84_INI_SCAN_DIR="/Users/jacksonfrankland/Library/Application Support/Herd/config/php/84/"

# The following lines were added by compinstall
zstyle :compinstall filename '/Users/jacksonfrankland/.zshrc'

autoload -Uz compinit
compinit
# End of lines added by compinstall
