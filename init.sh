#!/bin/bash

DOTFILES_HOME=$(cd `dirname $0`; pwd)

command_exists () {
  type "$1" &> /dev/null ;
}
link_dotfiles_if_necessary () {
  [ -e "$HOME/$1" ] || ln -s "$DOTFILES_HOME/$1" "$HOME/$1"
}

set -x
install_emacs() {
  # https://github.com/d12frosted/homebrew-emacs-plus
  brew tap d12frosted/emacs-plus
  brew install emacs-plus --without-spacemacs-icon
}
install_java() {
  brew cask install adoptopenjdk8 intellij-idea-ce
  brew install jenv maven clojure leiningen
}
install_cpp() {
  # http://www.gnu.org/software/global/
  brew install global
}
install_python() {
  brew install pyenv  pyenv-virtualenvwrapper pyenv-virtualenv
}
install_node() {
  brew install nvm
}
install_ruby() {
  curl -sSL https://get.rvm.io | bash -s stable
}
install_ocaml() {
  brew install opam ocaml
  # https://opam.ocaml.org/doc/Install.html
  # opam init
}
install_go() {
  brew install go dep
}

install_ss() {
  brew install shadowsocks-libev privoxy
  cat << EOF > /usr/local/etc/shadowsocks-libev.json
{
    "server": "server-ip",
    "server_port": 443,
    "local_port": 1080,
    "password": "mypassword",
    "timeout": 600,
    "method": "aes-256-cfb"
}
EOF
  echo -e 'listen-address 0.0.0.0:8118\nforward-socks5 / localhost:1080 .' >> /usr/local/etc/privoxy/config
  brew services start privoxy
}

install_dbgui() {
  brew cask install sequel-pro robo-3t
}

install_vm() {
  brew cask install vagrant docker
  vagrant plugin install vagrant-disksize
  vagrant box add https://mirrors.tuna.tsinghua.edu.cn/ubuntu-cloud-images/vagrant/trusty/current/trusty-server-cloudimg-amd64-vagrant-disk1.box --name tsing/trusty

}

install_life() {
  brew cask install iterm2 tmux firefox google-chrome chromium  licecap the-unarchiver
}
case $1 in
  "link")
    link_dotfiles_if_necessary ".bashrc"
    link_dotfiles_if_necessary ".bash_profile"
    link_dotfiles_if_necessary ".emacs.d"
    link_dotfiles_if_necessary ".vim"
    link_dotfiles_if_necessary ".vimrc"
    link_dotfiles_if_necessary ".gitconfig"
    link_dotfiles_if_necessary ".tmux.conf"
    link_dotfiles_if_necessary ".lein"
    link_dotfiles_if_necessary ".pip"
    link_dotfiles_if_necessary ".npmrc"
    link_dotfiles_if_necessary ".cargo"
    ;;
  "brew")
    # https://lug.ustc.edu.cn/wiki/mirrors/help/brew.git
    command_exists brew || ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
    ;;
  "sm")
    git submodule update --init
    ;;
  *)
    CMD=install_$1
    declare -F $CMD && $CMD || echo "$CMD not exists!"
    ;;
esac
