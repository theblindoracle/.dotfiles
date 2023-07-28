#!/usr/bin/env bash

languages=$(echo "typescript js csharp " | tr " " "\n")
core_utils=$(echo "find xargs sed awk git" | tr " " "\n")
selected=$(echo -e "$languages\n$core_utils" | fzf)

read -p "Query: " query

if echo "$languages" | grep -qs $selected; then
  tmux split-window -p 32 -h bash -c "curl cht.sh/$selected/$(echo "$query" | tr " " "+") | less"
else
  tmux split-window -p 32 -h bash -c "curl cht.sh/$selected~$query | less"
fi
