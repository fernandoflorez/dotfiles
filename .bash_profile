#!/bin/sh

alias ls='ls -G'
alias mongo_start='mongod run --config `brew --prefix mongo`/mongod.conf'

export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
export PATH=$PATH:/usr/local/lib/node_modules
export ANDROID_SDK_ROOT=/usr/local/Cellar/android-sdk/r16
export CLICOLOR=1
export LSCOLORS=gxfxcxdxbxegedabagacad
