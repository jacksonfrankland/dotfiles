autoload -U promptinit; promptinit
prompt pure

alias updatebrewfile='brew bundle dump -f'
alias ll='exa --long --header --git -a'
alias cat='bat'
alias sshgen='ssh-keygen -t rsa'
alias sshkey='pbcopy < ~/.ssh/id_rsa.pub'
alias s='kitty +kitten ssh'
alias showhidden='echo "Use \"shift+cmd+.\" instead."'
alias hidehidden='echo "Use \"shift+cmd+.\" instead."'
alias forceempty='sudo rm -rf ~/.Trash; sudo rm -rf /Volumes/*/.Trashes;'
alias fixjs='rm -rf node_modules/;npm cache clear --force && npm install'
alias pn='pnpm'
alias updatexcode='xcode-select --install'
alias zj='zellij'
alias zja='zellij a -c'
alias flashkeyboard='make idank/sweeq:via:flash -e USER_NAME=idank -e POINTING_DEVICE=trackball -e TRACKBALL_RGB_RAINBOW=yes -e POINTING_DEVICE_POSITION=left -e CONVERT_TO=rp2040_ce -j8'
alias dh='dirs -v'
for index ({1..99}) alias "$index"="cd +${index}"; unset index

setopt AUTO_PUSHD           # Push the current directory visited on the stack.
setopt PUSHD_IGNORE_DUPS    # Do not store duplicates in the stack.
setopt PUSHD_SILENT         # Do not print the directory stack after pushd or popd.

# Setup a custom completions directory
fpath=($HOME/.local/share/zsh/completions $fpath)
autoload -U compinit; compinit
_comp_options+=(globdots) # With hidden files

# Refresh completions
function refreshcompletions() {
	local DIR=$HOME/.local/share/zsh/completions

	zellij setup --generate-completion zsh > $DIR/_zellij
}

function dockspace {
	# default - add space tile to dock
	defaults write com.apple.dock persistent-apps -array-add '{"tile-type"="spacer-tile";}'
	killall Dock
}

function killport () {
    [ $# -eq 1 ] && kill $(lsof -t -i4TCP:$1) && echo 'done'
}

function sshrem() {
	# TODO : look at ssh-keyscan -H for another option
	if [ $# -lt 1 ]; then
		echo -e "missing argument: host[s]"
		return 1;
	fi
	for s in $@
	do
	echo -e "\n>> removing '$s'";
	for khfile in $(find ~/.ssh -regex '.*known_hosts[0-9]*$')
		do
            if [[ $ip =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
                # ip-address
                ssh-keygen -R "${s}" -f ${khfile} &>/dev/null && echo "success removed $target_server" || echo "problem removing $target_server"
            else
                target_server="${s}"
                target_server_ip=$(dig +search +short ${target_server})
                target_server_shortname=$(echo ${target_server} | cut -d. -f1)

                echo "Scanning : ${khfile} for '${target_server}'"

                ssh-keygen -R ${target_server} -f ${khfile} &>/dev/null && echo "success removed $target_server" || echo "problem removing $target_server"
                if [ ! -z "$target_server_ip" ]; then
                    ssh-keygen -R ${target_server_ip} -f ${khfile} &>/dev/null && echo "success removed $target_server_ip" || echo "problem removing $target_server_ip"
                fi
                if [ ! -z "$target_server_ip" ]; then
                    ssh-keygen -R ${target_server_shortname} -f ${khfile} &>/dev/null && echo "success removed $target_server_shortname" || echo "problem removing $target_server_shortname"
                fi
            fi
		done
	done
}

# remove all node_module foders within a directory
function remove_node_modules () {
	find . -name "node_modules" -type d -prune -exec rm -rf '{}' +
}

function d () {
	if [[ $# -eq 1 ]]; then
    selected=$1
	else
    items="$(find ~/Code -maxdepth 1 -mindepth 1 \( -type l -o -type d \))"
    selected="$(echo "$items" | fzf)"
	fi

	dirname="$(basename "$selected" | sed 's/\./_/g')"

	cd "$selected"
}

function a () {
	if [[ $# -eq 1 ]]; then
    selected=$1
	else
    items="$(find ~/Code -maxdepth 1 -mindepth 1 \( -type l -o -type d \))"
    selected="$(echo "$items" | fzf)"
	fi

	dirname="$(basename "$selected" | sed 's/\./_/g')"

	cd "$selected"
	zja "$dirname"
}

export EDITOR='hx'
export VISUAL='hx'
export BAT_THEME="Catppuccin-frappe"

export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/usr/local/bin:$PATH"
export PATH="$HOME/go/bin:$PATH"

export PNPM_HOME="$HOME/Library/pnpm"
export PATH="$HOME/Library/pnpm:$PATH"
export FZF_DEFAULT_OPTS=" \
--color=bg+:#414559,bg:#303446,spinner:#f2d5cf,hl:#e78284 \
--color=fg:#c6d0f5,header:#e78284,info:#ca9ee6,pointer:#f2d5cf \
--color=marker:#f2d5cf,fg+:#c6d0f5,prompt:#ca9ee6,hl+:#e78284"

