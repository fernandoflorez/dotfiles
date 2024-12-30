export PYENV_ROOT="$HOME/.pyenv"
export PATH=$PYENV_ROOT/bin:/usr/local/bin:/usr/local/sbin:$HOME/go/bin:$PATH
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
export CFLAGS=-Qunused-arguments
export CPPFLAGS=-Qunused-arguments
export GNUPGHOME=$HOME/.config/gnupg
export EDITOR="nvim"
export PROJECTS_DIR=$HOME/projects/
export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
export ZSH_GIT_PROMPT_SHOW_BEHIND=0
export ZSH_GIT_PROMPT_SHOW_AHEAD=0
export ZSH_GIT_PROMPT_SHOW_REBASE=0
export ZSH_GIT_PROMPT_SHOW_MERGING=0
export ZSH_GIT_PROMPT_SHOW_BISECT=0
export PATH="/usr/local/opt/openjdk@11/bin:$PATH"
if [[ ! "$PATH" == */opt/homebrew/opt/fzf/bin* ]]; then
  PATH="${PATH:+${PATH}:}/opt/homebrew/opt/fzf/bin"
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

if [ -n "${GHOSTTY_RESOURCES_DIR}" ]; then
    builtin source "${GHOSTTY_RESOURCES_DIR}/shell-integration/zsh/ghostty-integration"
fi

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

# init brew shell env
eval $(`brew --prefix`/bin/brew shellenv)

# helpers
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

# GPG Agent
GNUPGCONFIG="${GNUPGHOME:-"$HOME/.config/gnupg"}/gpg-agent.conf"
if ! pgrep -x gpg-agent >/dev/null; then
    gpgconf --launch gpg-agent
fi

autoload -Uz add-zsh-hook
setopt PROMPT_SUBST
DEFAULT_PROMPT='%F{red}%m %F{blue}» %F{yellow}%~%F{white} $(type git_super_status >/dev/null 2>&1 && git_super_status || echo "")\$%f '
TRANSIENT_PROMPT='%F{yellow}\$%f '
DEFAULT_RPROMPT=''
TRANSIENT_RPROMPT='%F{yellow}$(date "+%d/%m %H:%M:%S")%f'

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

# Aliases
alias g='git'
alias gs='git status'
alias mysql="mysql -uroot -h127.0.0.1 --prompt=mysql.local\>\ "
alias cat="bat --theme=rose-pine-moon --style=numbers,changes"
alias docker='podman'
alias vi='nvim'
alias ls='eza --icons auto --group-directories-first'

# antidote
zsh_plugins=${ZDOTDIR:-~}/.zsh_plugins
[[ -f ${zsh_plugins}.txt ]] || touch ${zsh_plugins}.txt
fpath=(`brew --prefix antidote`/share/antidote/functions `brew --prefix`/share/zsh/site-functions $fpath)
autoload -Uz antidote

if [[ ! ${zsh_plugins}.zsh -nt ${zsh_plugins}.txt ]]; then
  antidote bundle <${zsh_plugins}.txt >|${zsh_plugins}.zsh
fi

source ${zsh_plugins}.zsh
