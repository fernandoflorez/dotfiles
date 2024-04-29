export PYENV_ROOT="$HOME/.pyenv"
export PATH=$PYENV_ROOT/bin:/usr/local/bin:/usr/local/sbin:$HOME/go/bin:$PATH
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
export CFLAGS=-Qunused-arguments
export CPPFLAGS=-Qunused-arguments
export GNUPGHOME=$HOME/.config/gnupg
export EDITOR="nvim"
export PROJECTS_DIR=$HOME/projects/

# init brew shell env
if [[ "$(/usr/bin/uname -m)" == "arm64" ]]
then
    HOMEBREW_PREFIX="/opt/homebrew"
else
    HOMEBREW_PREFIX="/usr/local"
fi

eval $(${HOMEBREW_PREFIX}/bin/brew shellenv)

if [[ ! "$PATH" == */opt/homebrew/opt/fzf/bin* ]]; then
  PATH="${PATH:+${PATH}:}/opt/homebrew/opt/fzf/bin"
fi

if hash brew 2> /dev/null
then
    if [ -n "${ZSH_VERSION:-}" ]
    then
        FPATH=$(brew --prefix)/share/zsh/site-functions:$FPATH

        autoload -U +X bashcompinit && bashcompinit
        autoload -U +X compinit && compinit

        zstyle ':completion:*' special-dirs true
    fi
fi

if [ -r `brew --prefix git`/etc/bash_completion.d/git-prompt.sh ]
then
    source `brew --prefix git`/etc/bash_completion.d/git-prompt.sh
fi

if [ -r `brew --prefix zsh-autosuggestions`/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]
then
    source `brew --prefix zsh-autosuggestions`/share/zsh-autosuggestions/zsh-autosuggestions.zsh
fi

if [ -r `brew --prefix zsh-syntax-highlighting`/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]
then
    source `brew --prefix zsh-syntax-highlighting`/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi

if [ -r `brew --prefix fzf`/shell/completion.zsh ]
then
    source `brew --prefix fzf`/shell/completion.zsh
    eval "$(fzf --zsh)"
fi

if [ -r `brew --prefix z`/etc/profile.d/z.sh ]
then
    source `brew --prefix z`/etc/profile.d/z.sh
fi

if hash fd 2> /dev/null
then
    export FZF_DEFAULT_COMMAND="fd --hidden --strip-cwd-prefix --exclude .git"
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
    export FZF_ALT_C_COMMAND="fd --type=d --hidden --strip-cwd-prefix --exclude .git"
    _fzf_compgen_path() {
      fd --hidden --exclude .git . "$1"
    }

    _fzf_compgen_dir() {
      fd --type=d --hidden --exclude .git . "$1"
    }
fi

export GIT_PS1_SHOWDIRTYSTATE=true
export GIT_PS1_SHOWUNTRACKEDFILES=true
export GIT_PS1_SHOWSTASHSTATE=true

if [ -n "${ZSH_VERSION:-}" ]
then

    setopt PROMPT_SUBST
    export PROMPT='%B%F{red}%m %F{blue}» %F{yellow}%~%F{white} $(declare -F __git_ps1 &>/dev/null && __git_ps1 "(%s) ")\$%b%f '

fi

function current_branch() {
    local ref
    ref=$(git symbolic-ref HEAD 2> /dev/null) || return
    echo ${ref#refs/heads/}
}

function gpull() {
    git pull $1 $([[ $2 ]] && echo $2 || echo $(current_branch))
}

function gpush() {
    git push $1 $([[ $2 ]] && echo $2 || echo $(current_branch))
}

function change_gpg() {
    for key in $(gpg-connect-agent 'keyinfo --list' /bye 2> /dev/null | grep -v OK | awk '{if ($4 == "T") { print $3 ".key" }}'); do
        rm -v ~/.config/gnupg/private-keys-v1.d/$key
    done
    gpg --card-status 2> /dev/null 1> /dev/null
}

# Aliases
alias g='git'
# Autocomplete g command
complete -o default -o nospace -F _git g

alias gs='git status'
alias aws-get-instances='aws ec2 describe-instances --query "Reservations[].Instances[].[Tags[0].Value,State.Name,InstanceType,InstanceId,PrivateIpAddress,PublicDnsName,PublicIpAddress]" --output table'
alias aws-get-repositories='aws codecommit list-repositories --query "repositories[].repositoryName" --output table'
alias mysql="mysql -uroot -h127.0.0.1 --prompt=mysql.local\>\ "
alias cat="bat --theme=OneHalfDark"
alias docker='podman'
alias vi='nvim'
alias ls='eza --icons auto --group-directories-first'
alias hackon='cd $PROJECTS_DIR/`find $PROJECTS_DIR/ -type d -mindepth 1 -maxdepth 1 -exec basename {} \; | sort -Vk1 --ignore-case | fzf`'

# GPG Agent
export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
gpgconf --launch gpg-agent

GNUPGCONFIG="${GNUPGHOME:-"$HOME/.config/gnupg"}/gpg-agent.conf"

bindkey -s ^f "hackon"


# auto-start tmux
if command -v tmux &> /dev/null && [ -z "$TMUX" ]; then
    tmux attach -t default || tmux new -s default
fi
