export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
export CFLAGS=-Qunused-arguments
export CPPFLAGS=-Qunused-arguments
export GNUPGHOME="$HOME/.config/gnupg"
export EDITOR="nvim"
export PROJECTS_DIR="$HOME/projects/"
export ZVM_LAZY_KEYBINDINGS=true

typeset -U PATH path

path=(
    "/usr/local/opt/openjdk@11/bin"
    "/opt/homebrew/opt/fzf/bin"
    "$HOME/go/bin"
    /usr/local/bin
    /usr/local/sbin
    $path
)

export PATH

if [[ -x /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi

if command -v fd &>/dev/null; then
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

function _aws-vault-switch() {
  local profile
  profile=$(aws-vault list --profiles | fzf --prompt="AWS~ " --reverse)
  
  if [[ -n "$profile" ]]; then
    BUFFER="aws-vault exec --no-session $profile"
    zle accept-line
  fi
  zle reset-prompt
}
zle -N _aws-vault-switch

gpgconf --launch gpg-agent 2>/dev/null
export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)

alias g='git'
alias gs='git status'
alias cat="bat --theme=rose-pine-moon --style=numbers,changes"
alias docker='podman'
alias vi='nvim'
alias ls='eza --icons auto --group-directories-first'
alias cz='uvx --from=commitizen cz'
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

function zvm_after_init() {
    export ZVM_INSERT_MODE_CURSOR=$ZVM_CURSOR_BLINKING_BLOCK
    bindkey '^P' _aws-vault-switch
    bindkey '^F' _hackon

    if command -v fzf &>/dev/null; then
        source <(fzf --zsh)
    fi
}

source "${zsh_plugins}.zsh"
eval "$(starship init zsh)"
