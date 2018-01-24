# shell-env
For saving and sharing my shell setup files


# Security
The included scripts install some tools from 3rd parties. You should always exercise
extreme caution when installing packages from unsigned / unvalidated sources.


# Scripts
### scripts/macos-setup.sh
In the absence of any configuration management environment, this script fetches,
installs, and (eventually) configures a mac workstation for general development
tasks.

Currently, it installs the following:
* [XCode CLI Tools](https://developer.apple.com/library/content/technotes/tn2339/_index.html)
* [Homebrew](https://brew.sh/)
  * [wget](https://www.gnu.org/software/wget/)
  * [awscli](https://github.com/aws/aws-cli)
  * [macvim](https://github.com/macvim-dev) 
  * [unbound](https://www.unbound.net/)
  * [zsh](https://github.com/robbyrussell/oh-my-zsh/wiki/Installing-ZSH)
  * [zsh-completions](https://github.com/zsh-users/zsh-completions)
* [Pip (Python Package Manager)](https://pip.pypa.io/en/stable/)
  * [virtualenvwrapper](https://pypi.python.org/pypi/virtualenvwrapper/)
* [oh-my-zsh Zsh Management Framework](https://github.com/robbyrussell/oh-my-zsh) 


# Configs
### Unbound DNS Proxy Config
### ZSH RC
### VIM RC

