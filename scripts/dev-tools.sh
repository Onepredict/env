#!/usr/bin/env bash

# set -e 

################################################## Written by bliss ##################################################
# This script will provide good experience for python service development
# Run : source $PATH/updateEnv.sh
######################################################################################################################

###################################################### Funtions ######################################################
function checking_default_library()
{
    # checking brew installation
    packages=`apt list --installed git curl | cut -d '/' -f 1`
    for package in ${packages[*]}; do
        message "$package"
    done
    # sudo apt-get -y install build-essential curl file git libbz2-dev libreadline-dev
    return 0
}

function get_os_type()
{
    local ret=`uname -s`    
    echo "${ret}"
}

function command_exists(){
    command -v "$@" >/dev/null 2>&1
}

function error(){
    echo ${RED}"Error: $@"${RESET} >&2
}

function divider(){
    printf "$GREEN"
    printf -v sep '%*s' 99 ; echo "${sep// /+}"    
    printf "$RESET"
}

function message(){
    printf "$GREEN"    
    printf "+ %-96s+\n" "$@"    
    printf "$RESET"
}

function title(){    
    len=100
    string=$@

    # ${#string} expands to the length of $string
    n_pad=$(( (len - ${#string} - 2) / 2 ))
    printf "$GREEN"

    printf "%${n_pad}s" | tr ' ' +
    printf ' %s ' "$string"
    printf "%${n_pad}s\n" | tr ' ' +

    printf "$RESET"
}

function setup_color(){
  # Only use colors if connected to a terminal
  if [ -t 1 ]; then
    RED=$(printf '\033[31m')
    GREEN=$(printf '\033[32m')
    YELLOW=$(printf '\033[33m')
    BLUE=$(printf '\033[34m')
    BOLD=$(printf '\033[1m')
    RESET=$(printf '\033[m')
  else
    RED=""
    GREEN=""
    YELLOW=""
    BLUE=""
    BOLD=""
    RESET=""
  fi
}

function install_brew()
{    
    if [ ! -d ~/.linuxbrew ];
    then
        message "Installing brew (https://docs.brew.sh/Homebrew-on-Linux)"           
        # https://docs.brew.sh/Homebrew-on-Linux
        git clone https://github.com/Homebrew/brew ~/.linuxbrew/Homebrew
        mkdir ~/.linuxbrew/bin
        ln -s ~/.linuxbrew/Homebrew/bin/brew ~/.linuxbrew/bin
        echo 'eval $($HOME/.linuxbrew/bin/brew shellenv)' >> ~/.zshrc   
        eval $($HOME/.linuxbrew/bin/brew shellenv)
    else
        message "brew is already installed"
    fi    
}

function install_oh_my_zsh()
{
    if [ ! -d ~/.oh-my-zsh ];
    then
        message "Installing oh-my-zsh (https://github.com/ohmyzsh/ohmyzsh)"
        # https://github.com/ohmyzsh/ohmyzsh 
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" install-zsh --unattended
    else
        message "oh_my_zsh is already installed"
    fi    
}

function check_brew_package_installed()
{
    local package_name=$1
    local ret=1

    # echo "package name : ${package_name}"
    local package_list=($(brew list --formula))
    

    for pkg in "${package_list[@]}"
    do        
        if [ "${pkg}" == "${package_name}" ]; then
            ret=0
            # echo "${package_name} is installed"
            return $ret
        fi
    done

    # echo "${package_name} is not installed"
    return $ret
}

function install_pyenv()
{
    # echo "install pyenv"
    check_brew_package_installed "pyenv"
    local exist=$?
    if [ $exist -eq 0 ]; then        
        message "pyenv is already installed."
    else
        message "Installing pyenv"
        brew install pyenv
        PERL_MM_OPT="INSTALL_BASE=$HOME/perl5" cpan local::lib
        echo 'eval "$(perl -I$HOME/perl5/lib/perl5 -Mlocal::lib=$HOME/perl5)"' >> ~/.zshrc
        echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.zshrc
        echo 'export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.zshrc
        echo -e 'if command -v pyenv 1>/dev/null 2>&1; then\n  eval "$(pyenv init -)"\nfi' >> ~/.zshrc        
    fi
    return 0
}

function install_virtualenv()
{    
    check_brew_package_installed "pyenv-virtualenv"
    local exist=$?
    if [ $exist -eq 0 ]; then        
        message "pyenv-virtualenv is already installed."
    else
        message "Installing pyenv-virtualenv"

        brew install pyenv-virtualenv        

        echo -e 'if which pyenv-virtualenv-init > /dev/null; then eval "$(pyenv virtualenv-init -)"; fi' >> ~/.zshrc
        pyenv virtualenv $1 dev
    fi
    return 0
}

function check_python_version()
{
    message "checking python version : $1"
    
    # Python installation check
    target_version=$1
    local installed_versions=($(pyenv versions --bare))
    
    for version in "${installed_versions[@]}"
    do        
        if [ $version == "$1" ];
        then
            # echo "found python : $version"
            return 0
        fi        
    done
    return 1
}
function install_python()
{    
    check_python_version $1

    local exist=$?
    if [ $exist -eq 0 ]; then        
        message "python $1 is already installed."
    else
        message "Installing python $1"
        pyenv install $1        
    fi

    # If installed, set default version
}

########################## Main ##########################
function MAIN()
{
    local ret=0    
    # if not installed default package, it should be installed via admin
    # install_oh_my_zsh
    # install_brew    
    # install_pyenv
    install_python 3.7.7
    return $ret
}

# MAIN $@
