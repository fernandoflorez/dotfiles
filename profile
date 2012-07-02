# Added git auto-completion from brew installation
source `brew --prefix git`/etc/bash_completion.d/git-completion.bash

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
export PS1="${IBlack}${Time12h}${Color_Off} \$(declare -F __git_ps1 &>/dev/null && __git_ps1 '(%s) ')${IYellow}${PathShort}${Color_Off} \$ "
export PATH=/usr/local/bin:/usr/local/sbin:$PATH
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8

# Aliases
alias activate='source bin/activate'
alias g='git'
alias gs='git status'
alias gss='git status -s'
alias pyclean='find . -name *.pyc -exec rm -rf ~{} \;'
