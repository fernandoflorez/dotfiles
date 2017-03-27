# Added git auto-completion from brew installation
if hash brew 2> /dev/null; then
    source `brew --prefix git`/etc/bash_completion.d/git-completion.bash
# latest versions of git includes an extra file
    __git_prompt_file=`brew --prefix git`/etc/bash_completion.d/git-prompt.sh
else
    source /etc/bash_completion.d/git
    __git_prompt_file=/usr/share/git-core/contrib/completion/git-prompt.sh
fi

if [ -f "$__git_prompt_file" ]
then
    source $__git_prompt_file
fi


# Reset
Color_Off="\[\033[0m\]"       # Text Reset

# High Intensty
IBlack="\[\033[0;90m\]"       # Black
IRed="\[\033[0;91m\]"         # Red
IGreen="\[\033[0;92m\]"       # Green
IYellow="\[\033[0;93m\]"      # Yellow

# Various variables you might want for your PS1 prompt instead
Time12h="\T"
PathShort="\w"

export GIT_PS1_SHOWDIRTYSTATE=true
export GIT_PS1_SHOWUNTRACKEDFILES=true
export GIT_PS1_SHOWSTASHSTATE=true
export PS1="${IBlack}${Time12h}${Color_Off} \$(declare -F __git_ps1 &>/dev/null && __git_ps1 '(%s) ')${IYellow}${PathShort}${Color_Off} ${IGreen}\$${Color_Off} "
export PATH=/usr/local/bin:/usr/local/sbin:$PATH
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
export CFLAGS=-Qunused-arguments
export CPPFLAGS=-Qunused-arguments

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

function _hackon() {
    local opts cur prev
    opts=`ls -l $HOME/projects/ | egrep '^d' | awk '{print $9}'`
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"
    COMPREPLY=($(compgen -W "${opts}" -- ${cur}))
    return 0
}

function hackon() {
    if [[ "$VIRTUAL_ENV" != "" ]]; then
        deactivate
    fi
    if [ -d "$HOME/projects/$1" ]; then
        if [ -f "$HOME/projects/$1/bin/activate" ]; then
            source "$HOME/projects/$1/bin/activate"
        fi
        if [ -d "$HOME/projects/$1/src" ]; then
            cd "$HOME/projects/$1/src"
        else
            cd "$HOME/projects/$1"
        fi
    fi
}
complete -F _hackon hackon

# Aliases
alias activate='source bin/activate'
alias g='git'
# Autocomplete g command too
complete -o default -o nospace -F _git g

alias gs='git status'
alias gss='git status -s'
alias pyclean='find . -name "*.pyc" -exec rm -rf {} \;'
alias redis_start='redis-server /usr/local/etc/redis.conf'
alias aws-get-instances='aws ec2 describe-instances --query "Reservations[].Instances[].[Tags[0].Value,State.Name,InstanceType,InstanceId,PrivateIpAddress,PublicDnsName,PublicIpAddress]" --output table'
alias aws-get-images='aws ec2 describe-images --owner=self --query "Images[].[Name,ImageId,State,CreationDate]" --output table'
