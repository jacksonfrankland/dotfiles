autoload -U promptinit; promptinit
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

# fastfetch