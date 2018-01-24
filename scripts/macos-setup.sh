#!/bin/bash

# This script is intended to configure a clean Mac
# the way I need it for development... :)


# Install XCode CLI Tools
if [ "$(command -v yacc)" ]; then
    echo "XCode CLI Tools Already Installed!"
else
    xcode-select --install
    if [ $? -ne 0 ]; then
        echo "XCode CLI Tools Install Failed!"
    fi
fi

# Install Homebrew
if [ "$(command -v brew)" ]; then
    echo "Homebrew Already Installed!"
else
    /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
    if [ $? -ne 0 ]; then
        echo "Homebrew Install Failed!"
    fi
fi

# Install Homebrew Packages
HOMEBREW_PKGS=( wget awscli macvim unbound zsh zsh-completions )
for pkg_name in ${HOMEBREW_PKGS[@]}; do
    if [ "$(brew list ${pkg_name})" ]; then
        echo "Homebrew Package '${pkg_name}' Already Installed!"
    else
        echo "Homebrew Installing '${pkg_name}'"
        brew install "${pkg_name}"
        if [ $? -ne 0 ]; then
            echo "Homebrew Install of '${pkg_name}' Failed!"
        else
            echo "Homebrew Install of '${pkg_name}' Complete!"
        fi
    fi
done

# Install Pip
if [ "$(command -v pip)" ]; then
    echo "PIP Already Installed!"
else
    echo "Enter your password when prompted (for sudo)."
    curl https://bootstrap.pypa.io/ez_setup.py -o - | sudo python
    if [ $? -ne 0 ]; then
        echo "PIP Install Failed!"
    fi
fi

# Install Pip Packages
# Note: These are global packages, so use this sparingly
PIP_PKGS=( virtualenvwrapper )
for pkg_name in ${PIP_PKGS[@]}; do
    if [ "$(pip show ${pkg_name})" ]; then
        echo "Pip Package '${pkg_name}' Already Installed!"
    else
        echo "Pip Installing '${pkg_name}'"
        echo "Enter your password when prompted (for sudo)."
        # the '--ignore-installed six' is to prevent pip from uninstalling the
        # distro-included version of 'six'.
        sudo pip install --ignore-installed six "${pkg_name}"
        if [ $? -ne 0 ]; then
            echo "Pip Install of '${pkg_name}' Failed!"
        else
            echo "Pip Install of '${pkg_name}' Complete!"
        fi
    fi
done

# Install oh-my-zsh
if [ -d "$HOME/.oh-my-zsh" ]; then
    echo "Oh-My-Zsh Already Installed!"
else
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
    if [ $? -ne 0 ]; then
        echo "Oh-My-Zsh Install Failed!"
    fi
fi

# Install Pathogen (VIM Plugins)
if [ ! -d "$HOME/.vim/autoload" ]; then
    echo "Install VIM Pathogen: Creating VIM Plugin Dirs"
    mkdir -p "$HOME/.vim/autoload" "$HOME/.vim/bundle"
fi
if [ -f "$HOME/.vim/autoload/pathogen.vim" ]; then
    echo "VIM Pathogen Already Installed!"
else
    curl -LSso "$HOME/.vim/autoload/pathogen.vim" https://tpo.pe/pathogen.vim
    if [ $? -ne 0 ]; then
        echo "VIM Pathogen Install Failed!"
    fi
fi

## Next Steps
# Setup unbound DNS Proxy (for DNSSEC)
# Setup the user home env
# Install fonts
# 

