export PYENV_ROOT="$HOME/.pyenv"
export PATH=$PYENV_ROOT/bin:/usr/local/bin:/usr/local/sbin:$HOME/go/bin:$PATH
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
export CFLAGS=-Qunused-arguments
export CPPFLAGS=-Qunused-arguments
export GNUPGHOME=$HOME/.config/gnupg
export EDITOR="nvim"
export PROJECTS_DIR=$HOME/projects/
export PATH="/usr/local/opt/openjdk@11/bin:$PATH"

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
        autoload -Uz add-zsh-hook

        zstyle ':completion:*' special-dirs true

        if [ -r `brew --prefix fzf`/shell/completion.zsh ]
        then
            source `brew --prefix fzf`/shell/completion.zsh
            eval "$(fzf --zsh)"
        fi

        if [ -r `brew --prefix zsh-autosuggestions`/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]
        then
            source `brew --prefix zsh-autosuggestions`/share/zsh-autosuggestions/zsh-autosuggestions.zsh
        fi

        if [ -r `brew --prefix zsh-syntax-highlighting`/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]
        then
            source `brew --prefix zsh-syntax-highlighting`/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
        fi

    fi
fi

if [ -r `brew --prefix git`/etc/bash_completion.d/git-prompt.sh ]
then
    source `brew --prefix git`/etc/bash_completion.d/git-prompt.sh
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
    DEFAULT_PROMPT='%F{red}%m %F{blue}» %F{yellow}%~%F{white} $(declare -F __git_ps1 &>/dev/null && __git_ps1 "(%s) ")\$%f '
    TRANSIENT_PROMPT='%F{blue}\$%f '
    DEFAULT_RPROMPT=''
    TRANSIENT_RPROMPT='%F{blue}$(date "+%d/%m %H:%M:%S")%f'


    function precmd() { 
        PROMPT=$TRANSIENT_PROMPT
        RPROMPT=$TRANSIENT_RPROMPT
    }

    add-zsh-hook precmd precmd

    _reset_prompt() {
        STORED_PROMPT=$PROMPT
        STORED_RPROMPT=$RPROMPT
        PROMPT=$DEFAULT_PROMPT
        RPROMPT=$DEFAULT_RPROMPT
    }

    zle-line-finish() {
        PROMPT=$STORED_PROMPT
        RPROMPT=$STORED_RPROMPT
        zle reset-prompt
    }
    zle -N zle-line-finish
    add-zsh-hook precmd _reset_prompt

    # hackon
    function _hackon() {
        local project=`find $PROJECTS_DIR -type d -mindepth 1 -maxdepth 1 -exec basename {} \; | sort -Vk1 --ignore-case | fzf --layout reverse --prompt="hackon~ "`
        if [ -n "$project" ]; then
            BUFFER="cd $PROJECTS_DIR$project"
            zle accept-line
        fi
        zle reset-prompt
    }
    zle -N _hackon
    bindkey "^f" _hackon

    # aws
    function _set_aws_profile() {
        local profile=`aws --no-cli-pager configure list-profiles | fzf --layout reverse --prompt="aws profile~ "`
        if [ -n "$profile" ]; then
            export AWS_DEFAULT_PROFILE=$profile
            export AWS_PROFILE=$profile
            export AWS_PROFILE_REGION=$(aws configure get region)
            DEFAULT_RPROMPT="%BAWS - %F{blue}$AWS_PROFILE %F{red}($AWS_PROFILE_REGION)%b%f"
            zle accept-line
        fi
        zle reset-prompt
    }
    zle -N _set_aws_profile

    function _unset_aws_profile() {
        DEFAULT_RPROMPT=''
        unset AWS_DEFAULT_PROFILE AWS_PROFILE AWS_PROFILE_REGION
        zle accept-line
        zle reset-prompt
    }
    zle -N _unset_aws_profile
    bindkey "^p" _set_aws_profile
    bindkey "^o" _unset_aws_profile

fi

function _current_git_branch() {
    local ref
    ref=$(git symbolic-ref HEAD 2> /dev/null) || return
    echo ${ref#refs/heads/}
}

function gpull() {
    git pull $1 $([[ $2 ]] && echo $2 || echo $(_current_git_branch))
}

function gpush() {
    git push $1 $([[ $2 ]] && echo $2 || echo $(_current_git_branch))
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
alias mysql="mysql -uroot -h127.0.0.1 --prompt=mysql.local\>\ "
alias cat="bat --theme=rose-pine-moon --style=numbers,changes"
alias docker='podman'
alias vi='nvim'
alias ls='eza --icons auto --group-directories-first'

# GPG Agent
export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
gpgconf --launch gpg-agent

GNUPGCONFIG="${GNUPGHOME:-"$HOME/.config/gnupg"}/gpg-agent.conf"

# auto-start tmux
if command -v tmux &> /dev/null && [ -z "$TMUX" ]; then
    tmux attach -t default || tmux new -s default
fi
