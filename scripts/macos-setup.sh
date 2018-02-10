#!/bin/bash

# This script is intended to configure a clean Mac
# the way I need it for development... :)

# These packages are what I consider to be "Universal"
# for the given package manager. i.e. If I *explicitly* install
# Homebrew, then I'm going to install 'wget' always.
HOMEBREW_PKGS=( wget )
PIP_PKGS=( virtualenvwrapper )
__DEBUG=1

function print_debug() {
  if [ ${__DEBUG} -ne 0 ]; then
    echo "$1"
  fi
}

is_xcode_cli_installed=$((command -v "yacc" >/dev/null 2>&1 && echo 0) || echo 1)
function install_xcode_cli_tools() {
  # Install XCode CLI Tools
  if [ ! ${is_xcode_cli_installed} ]; then
    xcode-select --install
    if [ $? -ne 0 ]; then
        echo "XCode CLI Tools Install Failed!"
        return 1
    fi
  else
    print_debug "XCode CLI Tools Already Installed!"
  fi
  return 0
}

is_homebrew_installed=$((command -v "brew" >/dev/null 2>&1 && echo 0) || echo 1)
function install_homebrew() {
  # Install Homebrew
  if [ ! ${is_homebrew_installed} ]; then
    /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
    if [ $? -ne 0 ]; then
      echo "Homebrew Install Failed!"
      return 1
    fi
  else
    print_debug "Homebrew Already Installed!"
  fi
  is_homebrew_installed=0
  return 0
}

function install_homebrew_package() {
  # Install Homebrew
  install_homebrew
  if [ $? -ne 0 ]; then
    exit 1
  fi

  # Install Homebrew Packages
  local pkg_name=$1
  if [ ! "$(brew list ${pkg_name})" ]; then
    echo "Homebrew Installing '${pkg_name}'"
    brew install "${pkg_name}"
    if [ $? -ne 0 ]; then
      echo "Homebrew Install of '${pkg_name}' Failed!"
      return 1
    else
      print_debug "Homebrew Install of '${pkg_name}' Complete!"
    fi
  else
    print_debug "Homebrew Package '${pkg_name}' Already Installed"
  fi
  return 0
}

is_pip_installed=$((command -v "pip" >/dev/null 2>&1 && echo 0) || echo 1)
function install_pip() {
  # Install Pip
  if [ ! ${is_pip_installed} ]; then
    echo "Enter your password when prompted (for sudo)."
    curl https://bootstrap.pypa.io/ez_setup.py -o - | sudo python
    if [ $? -ne 0 ]; then
      echo "PIP Install Failed!"
      return 1
    fi
  else
    print_debug "PIP Already Installed"
  fi
  is_pip_installed=0
  return 0
}

function install_pip_package() {
  # Install pip
  install_pip
  if [ $? -ne 0 ]; then
    exit 1
  fi

  # Install Pip Packages
  # Note: These are global packages, so use this sparingly
  local pkg_name=$1
  if [ "$(pip show ${pkg_name})" ]; then
    print_debug "Pip Package '${pkg_name}' Already Installed!"
  else
    echo "Pip Installing '${pkg_name}'"
    echo "Enter your password when prompted (for sudo)."
    # the '--ignore-installed six' is to prevent pip from uninstalling the
    # distro-included version of 'six'.
    sudo pip install --ignore-installed six "${pkg_name}"
    if [ $? -ne 0 ]; then
      echo "Pip Install of '${pkg_name}' Failed!"
      return 1
    else
      echo "Pip Install of '${pkg_name}' Complete!"
    fi
  fi
  return 0
}

is_zsh_installed=$((command -v "zsh" >/dev/null 2>&1 && echo 0) || echo 1)
function install_oh_my_zsh() {
  # Install zsh
  if [ ! ${is_zsh_installed} ]; then
    install_homebrew_package "zsh"
    if [ $? -ne 0 ]; then
      exit 1
    fi

    install_homebrew_package "zsh-completions"
    if [ $? -ne 0 ]; then
      exit 1
    fi
  fi

  # Copy over zshrc template
  zsh_file="$HOME/.zshrc"
  zsh_template="configs/home/macos-zshrc"
  if [ -f "${zsh_file}" ]; then
    local todays_date=$(date +"%Y%m%d")
    cp "${zsh_file}" "${zsh_file}-${todays_date}.bak"
    if [ $? -ne 0 ]; then
      echo "Error Backing Up ZSHRC File '${zsh_file}'"
      exit 1
    fi
  fi
  cp "${zsh_template}" "${zsh_file}"
  if [ $? -ne 0 ]; then
    echo "Error Copying ZSHRC Template '${zsh_template}'"
    exit 1
  fi

  # Install oh-my-zsh
  if [ -d "$HOME/.oh-my-zsh" ]; then
    print_debug "Oh-My-Zsh Already Installed!"
  else
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
    if [ $? -ne 0 ]; then
      echo "Oh-My-Zsh Install Failed!"
      return 1
    fi
  fi
  return 0
}

function install_awscli() {
  # Install AwsCLI
  install_homebrew_package "awscli"
  if [ $? -ne 0 ]; then
    exit 1
  fi
  return 0
}

function install_pathogen() {
  # Install MacVim
  install_homebrew_package "macvim"
  if [ $? -ne 0 ]; then
    exit 1
  fi

  # Copy over the vimrc template
  vimrc_file="$HOME/.vimrc"
  vimrc_template="configs/home/vimrc"
  if [ ! -f "${vimrc_file}" ]; then
    print_debug "Install VIM Pathogen: Copying vimrc"
    cp "${vimrc_file}" "${vimrc_template}"
  fi

  # Install Pathogen (VIM Plugins)
  if [ ! -d "$HOME/.vim/autoload" ]; then
    print_debug "Install VIM Pathogen: Creating VIM Plugin Dirs"
    mkdir -p "$HOME/.vim/autoload" "$HOME/.vim/bundle"
  fi

  if [ ! -f "$HOME/.vim/autoload/pathogen.vim" ]; then
    curl -LSso "$HOME/.vim/autoload/pathogen.vim" https://tpo.pe/pathogen.vim
    if [ $? -ne 0 ]; then
      echo "VIM Pathogen Install Failed!"
      return 1
    fi
  else
    print_debug "VIM Pathogen Already Installed!"
  fi
  return 0
}

is_unbound_installed=$((command -v "unbound-control" >/dev/null 2>&1 && echo 0) || echo 1)
function install_unbound_dns_proxy() {
  
  if [ ${is_unbound_installed} ]; then
    print_debug "Unbound Already Installed!"
    return 0
  fi

  # Install Unbound
  install_homebrew_package "unbound"
  if [ $? -ne 0 ]; then
    exit 1
  fi

  # Copy over our config template
  conf_file="/usr/local/etc/unbound/unbound.conf"
  conf_template="configs/macos/usr/local/etc/unbound/unbound.conf"
  if [ ! -f "${conf_file}" ]; then
    echo "Enter your password if prompted (for sudo)."
    sudo cp "${conf_template}" "${conf_file}"
  fi

  # Copy over the launchctl template
  launchctl_file="/Library/LaunchDaemons/net.unbound.plist"
  launchctl_template="configs/macos/Library/LaunchDaemons/net.unbound.plist"
  if [ ! -f "${launchctl_file}" ]; then
    echo "Enter your password if prompted (for sudo)."
    sudo cp "${launchctl_template}" "${launchctl_file}"
  fi

  # Tell launchctl to load the service
  echo "Enter your password if prompted (for sudo)."
  sudo launchctl load -w /Library/LaunchDaemons/net.unbound.plist
  if [ $? -ne 0 ]; then
    echo "Error Starting Unbound Daemon!"
    exit 1
  fi

  return 0  
}

case "$1" in

  xcodecli)
    install_xcode_cli_tools
    if [ $? -ne 0 ]; then
      exit 1
    fi
    ;;

  homebrew)
    for pkg_name in ${HOMEBREW_PKGS[@]}; do
      install_homebrew_package "${pkg_name}"
      if [ $? -ne 0 ]; then
        exit 1
      fi
    done
    ;;

  pip)
    for pkg_name in ${PIP_PKGS[@]}; do
      install_pip_package "${pkg_name}"
      if [ $? -ne 0 ]; then
        exit 1
      fi
    done
    ;;

  zsh)
    install_oh_my_zsh
    if [ $? -ne 0 ]; then
      exit 1
    fi
    ;;

  awscli)
    install_awscli
    if [ $? -ne 0 ]; then
      exit 1
    fi
    ;;

  pathogen)
    install_pathogen
    if [ $? -ne 0 ]; then
      exit 1
    fi
    ;;

  unbound)
    # Note: this function needs validation...
    install_unbound_dns_proxy
    if [ $? -ne 0 ]; then
      exit 1
    fi
    ;;

  all)
    install_xcode_cli_tools
    if [ $? -ne 0 ]; then
      exit 1
    fi

    install_homebrew
    if [ $? -ne 0 ]; then
      exit 1
    fi
    for pkg_name in ${HOMEBREW_PKGS[@]}; do
      install_homebrew_package "${pkg_name}"
      if [ $? -ne 0 ]; then
        exit 1
      fi
    done

    install_pip
    if [ $? -ne 0 ]; then
      exit 1
    fi
    for pkg_name in ${PIP_PKGS[@]}; do
      install_pip_package "${pkg_name}"
      if [ $? -ne 0 ]; then
        exit 1
      fi
    done

    install_oh_my_zsh
    if [ $? -ne 0 ]; then
      exit 1
    fi

    install_awscli
    if [ $? -ne 0 ]; then
      exit 1
    fi

    install_pathogen
    if [ $? -ne 0 ]; then
      exit 1
    fi
    ;;

  *)
    echo $"Usage: $0 {pip|homebrew|xcodecli|zsh|awscli|pathogen|all}"
    exit 1
esac



## Next Steps
# Setup unbound DNS Proxy (for DNSSEC)
# Setup the user home env
# Install fonts
# 

