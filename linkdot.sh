#!/bin/bash

# linkdots finds files starting with a "dot" prefix and link them to the user
# $HOME folder, replacing the dot by a ".".

set -eux

function setup_link {
  ln -s $@ || true
}

export -f setup_link

find ./dot* -type f \
  | awk -v P=$(pwd) -v H=$HOME '{print P"/"$1, H"/."$1}' \
  | sed 's|\.\./dot|\.|' \
  | xargs -n 2 bash -c 'setup_link $@' _
