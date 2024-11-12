source $HOME/.aliases
source $HOME/.functions
source $HOME/.exports

# Mcfly - https://github.com/cantino/mcfly
type mcfly &>/dev/null && eval "$(mcfly init bash)"

eval "$(starship init bash)"

if ! echo "$PROMPT_COMMAND" | grep 'enter_directory'; then # add enter_directory once.
    export PROMPT_COMMAND="$PROMPT_COMMAND; enter_directory"
fi

# Use bash-completion, if available
[[ $PS1 && -f /usr/share/bash-completion/bash_completion ]] && \
    . /usr/share/bash-completion/bash_completion

# Node Version Manager
if test -s "/usr/local/opt/nvm/nvm.sh"; then
    mkdir -p "${NVM_HOME:-$HOME/.nvm}" || true
    source "/usr/local/opt/nvm/nvm.sh" # This loads nvm
fi

# Jave Env - http://www.jenv.be/ - install multiple java environments
if test -r "$HOME/.jenv"; then
    eval "$(jenv init -)" || echo "jenv failed to initialise"
fi

# Python Versions - https://github.com/pyenv/pyenv
if test -r "$PYENV_ROOT"; then
    command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
    eval "$(pyenv init -)" || echo "pyenv failed to initialise"
fi

# Override default macOs Ruby with Brew's version.
export PATH="/usr/local/opt/ruby/bin:$PATH"
if eval false; then
    ## For compilers to find ruby you may need to set:
    export LDFLAGS="-L/usr/local/opt/ruby/lib"
    export CPPFLAGS="-I/usr/local/opt/ruby/include"
    ## For pkg-config to find ruby you may need to set:
    export PKG_CONFIG_PATH="/usr/local/opt/ruby/lib/pkgconfig"
fi

function enter_directory() {
    # use this function in the PROMPT_COMMAND to auto execute when changing into a directory.
    # e.g. export PROMPT_COMMAND="$PROMPT_COMMAND; enter_directory"
	if [[ $PWD == $PREV_PWD ]]; then
		return
	fi
	PREV_PWD=$PWD
	if [ -f .enter ]; then
	    # look in current directory for a .enter script to run and return
	    source .enter
	    return
    fi
    # default behaviour when
    # Use correct node version AND use latest compatible NPM
	[[ -f ".nvmrc" ]] && nvm use || true
    [ -f "package.json" -o -f ".nvmrc" ] && {
        [ "$(npm -v | cut -d. -f1)" -lt 8 ] && echo "Suggest: upgrade npm with 'npm install -g npm@latest'"
    }
}

# Added by OrbStack: command-line tools and integration
# Comment this line if you don't want it to be added again.
source ~/.orbstack/shell/init.bash 2>/dev/null || :

# Herd injected PHP 8.2 configuration.
export HERD_PHP_82_INI_SCAN_DIR="/Users/jacksonfrankland/Library/Application Support/Herd/config/php/82/"

# Herd injected PHP 8.1 configuration.
export HERD_PHP_81_INI_SCAN_DIR="/Users/jacksonfrankland/Library/Application Support/Herd/config/php/81/"

# Herd injected PHP 8.0 configuration.
export HERD_PHP_80_INI_SCAN_DIR="/Users/jacksonfrankland/Library/Application Support/Herd/config/php/80/"

# Herd injected PHP 7.4 configuration.
export HERD_PHP_74_INI_SCAN_DIR="/Users/jacksonfrankland/Library/Application Support/Herd/config/php/74/"

# Herd injected PHP binary.
export PATH="/Users/jacksonfrankland/Library/Application Support/Herd/bin/":$PATH
