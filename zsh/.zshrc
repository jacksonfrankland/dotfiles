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

function dockspace {
	# default - add space tile to dock
	defaults write com.apple.dock persistent-apps -array-add '{"tile-type"="spacer-tile";}'
	killall Dock
}

function kill_port () {
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

