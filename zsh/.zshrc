export PYENV_ROOT="$HOME/.pyenv"
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
export CFLAGS=-Qunused-arguments
export CPPFLAGS=-Qunused-arguments
export GNUPGHOME="$HOME/.config/gnupg"
export EDITOR="nvim"
export PROJECTS_DIR="$HOME/projects/"

export ZSH_GIT_PROMPT_SHOW_BEHIND=0
export ZSH_GIT_PROMPT_SHOW_AHEAD=0
export ZSH_GIT_PROMPT_SHOW_REBASE=0
export ZSH_GIT_PROMPT_SHOW_MERGING=0
export ZSH_GIT_PROMPT_SHOW_BISECT=0

typeset -U PATH path

path=(
    "$PYENV_ROOT/bin"
    "/usr/local/opt/openjdk@11/bin"
    "/opt/homebrew/opt/fzf/bin"
    "$HOME/go/bin"
    "$HOME/.lmstudio/bin"
    /usr/local/bin
    /usr/local/sbin
    $path
)

export PATH

if [[ -x /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi

pyenv() {
    unfunction pyenv
    if command -v pyenv &>/dev/null; then
        eval "$(command pyenv init -)"
    fi
    pyenv "$@"
}

if command -v fd &>/dev/null; then  # [CAMBIO] command -v es más portable que hash
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

# hackon - navegación rápida a proyectos
function _hackon() {
    local project
    project=$(fd . "$PROJECTS_DIR" --type d --exact-depth 1 --exec basename {} | \
              sort -Vk1 --ignore-case | \
              fzf --layout reverse --prompt="hackon~ ")
    
    if [[ -n "$project" ]]; then
        BUFFER="cd \"$PROJECTS_DIR$project\""
        zle accept-line
    fi
    zle reset-prompt
}
zle -N _hackon

# AWS profile selector
function _set_aws_profile() {
    local profile
    profile=$(aws --no-cli-pager configure list-profiles | \
              fzf --layout reverse --prompt="aws profile~ ")
    
    if [[ -n "$profile" ]]; then
        export AWS_DEFAULT_PROFILE="$profile"
        export AWS_PROFILE="$profile"
        export AWS_PROFILE_REGION
        AWS_PROFILE_REGION=$(aws configure get region)
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

function _current_git_branch() {
    local ref
    ref=$(git symbolic-ref HEAD 2>/dev/null) || return
    echo "${ref#refs/heads/}"
}

function gpull() {
    git pull "${1:?'Especifica el remote'}" "${2:-$(_current_git_branch)}"
}

function gpush() {
    git push "${1:?'Especifica el remote'}" "${2:-$(_current_git_branch)}"
}

# GPG key management
function change_gpg() {
    local key
    for key in $(gpg-connect-agent 'keyinfo --list' /bye 2>/dev/null | \
                 grep -v OK | \
                 awk '{if ($4 == "T") { print $3 ".key" }}'); do
        rm -v "$GNUPGHOME/private-keys-v1.d/$key"  # [CAMBIO] Usar variable GNUPGHOME
    done
    gpg --card-status &>/dev/null
}

GNUPGCONFIG="${GNUPGHOME}/gpg-agent.conf"
export SSH_AUTH_SOCK
SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)

gpgconf --launch gpg-agent 2>/dev/null

autoload -Uz add-zsh-hook
setopt PROMPT_SUBST

DEFAULT_PROMPT='%F{blue}» %F{yellow}%~%F{white}$(type gitprompt >/dev/null 2>&1 && echo " $(gitprompt)" || echo "") \$%f '
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

alias g='git'
alias gs='git status'
alias cat="bat --theme=rose-pine-moon --style=numbers,changes"
alias docker='podman'
alias vi='nvim'
alias ls='eza --icons auto --group-directories-first'
alias cz='uvx --from=commitizen cz'
alias tldr='uvx tldr'
alias grep='rg'
alias find='fd'

zsh_plugins="${ZDOTDIR:-$HOME}/.zsh_plugins"

[[ -f "${zsh_plugins}.txt" ]] || touch "${zsh_plugins}.txt"

fpath=(
    "$(brew --prefix antidote)/share/antidote/functions"
    "$(brew --prefix)/share/zsh/site-functions"
    $fpath
)

autoload -Uz antidote

# Regenerar plugins solo si el .txt es más nuevo
if [[ ! "${zsh_plugins}.zsh" -nt "${zsh_plugins}.txt" ]]; then
    antidote bundle <"${zsh_plugins}.txt" >|"${zsh_plugins}.zsh"
fi

source "${zsh_plugins}.zsh"

function zvm_after_init() {
    export ZVM_INSERT_MODE_CURSOR=$ZVM_CURSOR_BLINKING_BLOCK
    bindkey -r '^N'
    bindkey '^P' _set_aws_profile
    bindkey '^O' _unset_aws_profile  # [CAMBIO] Comillas consistentes
    bindkey '^F' _hackon
    
    if command -v fzf &>/dev/null; then
        source <(fzf --zsh)
    fi
}

# Added by LM Studio CLI (lms)
export PATH="$PATH:/Users/fernando/.lmstudio/bin"
# End of LM Studio CLI section

