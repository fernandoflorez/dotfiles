#!/bin/sh

alias mongo_start='mongod run --config `brew --prefix mongo`/mongod.conf'

export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
export PATH=$PATH:/usr/local/lib/node_modules
