#!/bin/bash

# linkbash finds files starting with a "bash" prefix and link them to the user
# $HOME/.bashrc.d/ folder, removing the "bash" prefix.

set -eux

function setup_link {
  ln -s $@ || true
}

export -f setup_link

mkdir -p $HOME/.bashrc.d

find ./bash* -type f \
  | sed 's|\./bash||' \
  | awk -v P=$(pwd) -v H=$HOME '{print P"/bash"$1, H"/.bashrc.d/"$1}' \
  | xargs -n 2 bash -c 'setup_link $@' _
