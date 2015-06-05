#!/bin/bash

set -eux

# ---- variables ---------------------------------------------------------------

APPS=$HOME/Applications
BASHEXTRA=./bashrcextra


# ---- first things first ------------------------------------------------------

xcode-select --install || echo "xcode dev tools installed"

ruby --version | grep "ruby 2." || echo "no ruby 2+" || exit 1

[ -d $HOME/.bashrc.d ] || {
  mkdir -p $HOME/.bashrc.d
  cat ./load_bashrc.d.sh >> ~/.profile
}

# ---- brew --------------------------------------------------------------------

brewpackages="wget tree rlwrap git tmux icdiff httpie ack ctags unrar "\
"hg binutils graphviz cmake"

brewdl=https://raw.githubusercontent.com/Homebrew/install/master/install

brew --version || ruby -e "$(curl -fsSL $brewdl)"

for p in $brewpackages; do brew list $p || brew install $p; done

# cask is an extension for installing binary packages
brew list brew-cask || brew install caskroom/cask/brew-cask


# ---- wine --------------------------------------------------------------------

brew cask list xquartz || brew install Caskroom/cask/xquartz
brew list wine || brew install wine


# ---- ruby gems --------------------------------------------------------------

#gem list --local | grep "chef" || sudo gem install chef
#gem list --local | grep "kitchenplan" || gem install -i $HOME/.gem/ kitchenplan


# ---- vim pathogen ------------------------------------------------------------

[ -e $HOME/.vim/autoload/pathogen.vim ] || {
  mkdir -p $HOME/.vim/autoload $HOME/.vim/bundle
  curl -LSso $HOME/.vim/autoload/pathogen.vim https://tpo.pe/pathogen.vim
}

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

  # these exports seem necessary for brew install
  export GOPATH=$HOME/Go
  export GOROOT=/usr/local/opt/go/libexec
  export PATH=$PATH:$GOPATH/bin
  export PATH=$PATH:$GOROOT/bin

  brew install go
}

gotools="godoc goimports cover callgraph oracle"
for t in $gotools; do
  [ -e $HOME/Go/bin/$t ] || {
    export GOPATH=$HOME/Go
    go get golang.org/x/tools/cmd/$t
  }
done

[ -e $HOME/Go/bin/gocode ] || {
  export GOPATH=$HOME/Go
  go get -u github.com/nsf/gocode
}

[ -e $HOME/.vim/bundle/vim-go ] || {
  git clone https://github.com/fatih/vim-go.git $HOME/.vim/bundle/vim-go
}

# --- ocaml --------------------------------------------------------------------


brew list opam || {
  brew install opam
  opam init -a # use non-interactive auto setup.
}

opam install -y core
opam install -y batteries

# ---- prolog ------------------------------------------------------------------

brew list gnu-prolog || brew install gnu-prolog

# ---- ntfs setup --------------------------------------------------------------

brew cask list osxfuse || brew install Caskroom/cask/osxfuse
brew list ntfs-3g || {
  brew install ntfs-3g
  sudo mv /sbin/mount_ntfs{,.orig}
  sudo ln -s /usr/local/Cellar/ntfs-3g/2014.2.15/sbin/mount_ntfs /sbin/mount_ntfs

  # comes from $ brew info osxfuse
  #sudo /bin/cp -RfX /usr/local/opt/osxfuse/Library/Filesystems/osxfusefs.fs /Library/Filesystems/
  #sudo chmod +s /Library/Filesystems/osxfusefs.fs/Support/load_osxfusefs
}

# ------------------------------------------------------------------------------
