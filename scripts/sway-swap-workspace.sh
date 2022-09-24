#!/usr/bin/env zsh

if [ $# -ne 1 ]; then
  echo "usage: $0 [workspace]"
  exit 1
fi

current=$(swaymsg -t get_workspaces | jq '.[] | select(.focused==true).name')
tmp=$(echo $RANDOM | md5sum)

swaymsg "rename workspace $current to $1"
if [ $? -ne 0 ]; then
  swaymsg "rename workspace $1 to $tmp, \
           rename workspace $current to $1, \
           rename workspace $tmp to $current"
fi
