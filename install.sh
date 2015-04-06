#!/bin/bash

set -eux

function err {
  echo $1
  exit 1
}

# ---- variables ---------------------------------------------------------------

APPS=$HOME/Applications
BASHEXTRA=./bashrcextra


# ---- first things first ------------------------------------------------------

# install xcode first before anything else
# set up custom folder structure
# check ruby version 2

xcode-select --install || echo "xcode dev tools installed"

mkdir -p $HOME/runtime

ruby --version | grep "ruby 2." || err "no ruby 2+"


# ---- brew --------------------------------------------------------------------

brewpackages="wget tree rlwrap git opam tmux icdiff httpie ack ctags unrar"
brewdl=https://raw.githubusercontent.com/Homebrew/install/master/install

brew --version || ruby -e "$(curl -fsSL $brewdl)"

for p in $brewpackages; do brew list $p || brew install $p; done

# cask for binary packages
brew list brew-cask || brew install caskroom/cask/brew-cask


# ---- ruby gems --------------------------------------------------------------

#gem list --local | grep "chef" || sudo gem install chef 
#gem list --local | grep "kitchenplan" || gem install -i $HOME/.gem/ kitchenplan


# ---- manual install ----------------------------------------------------------

[ -e $APPS/iTerm.app ] || {
  wget https://iterm2.com/downloads/stable/iTerm2_v2_0.zip -O /tmp/iterm2.zip
  unzip -q /tmp/iterm2.zip -d $APPS
  echo alias iterm=$APPS/iTerm.app/Contents/MacOS >> $BASHEXTRA
}


# ---- vagrant -----------------------------------------------------------------

command -v vagrant 2>&1 >/dev/null || {
  for p in "virtualbox vagrant vagrant-manager"
  do
    brew cask list $p || brew cask install $p
  done

  #vagrant box add precise64 http://files.vagrantup.com/precise64.bo
}


# ---- java --------------------------------------------------------------------

brew cask list java || brew cask install java

# ---- scala -------------------------------------------------------------------

for p in "scala sbt"
do
  brew list $p || brew install $p
done

# ---- clojure -----------------------------------------------------------------

brew list leiningen || {
  brew install leiningen
  lein new foo_lein && cd foo_lein/ && lein compile
  cd -
  rm -r foo_lein
}

# ---- go ----------------------------------------------------------------------

brew list go || {
  mkdir -p $HOME/Go
  mkdir -p $HOME/Go/src/github.com/user

  # seems necessary for brew install
  # todo: add these to bashrcextra
  export GOPATH=$HOME/Go
  export GOROOT=/usr/local/opt/go/libexec
  export PATH=$PATH:$GOPATH/bin
  export PATH=$PATH:$GOROOT/bin

  brew install hg go

  go get code.google.com/p/go.tools/cmd/godoc
  go get code.google.com/p/go.tools/cmd/vet
}

# --- ocaml --------------------------------------------------------------------

#OPAM uses ~/.opam by default for its package database, so you need to
#initialize it first by running (as a normal user):
#
#$  opam init
#
#Run the following to initialize your environment variables:
#
#$  eval `opam config env`
#
#To export the needed variables every time, add them to your dotfiles.
#  * On Bash, add them to `~/.bash_profile`.
#  * On Zsh, add them to `~/.zprofile` instead.
#
#Documentation and tutorials are available at https://opam.ocaml.org, or
#via 'man opam' and 'opam --help'.
#
#Bash completion has been installed to:
#  /usr/local/etc/bash_completion.d
#
#zsh completion has been installed to:
#  /usr/local/share/zsh/site-function

find $HOME/.ocamlinit || opam init

# need to wrap ocaml with rlwrap TODO: this should go into bash extra actually
alias ocaml="rlwrap /usr/local/bin/ocaml"

# ---- racket ------------------------------------------------------------------

# ---- prolog ------------------------------------------------------------------

brew list gnu-prolog || brew install gnu-prolog

# ------------------------------------------------------------------------------
