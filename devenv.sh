#!/usr/bin/env bash
# set -x

################################################## Written by bliss ##################################################
# This script will provide good experience for python service development
# Run : source $PATH/devenv.sh
######################################################################################################################

###################################################### Funtions ######################################################
function check_location(){
    local repository=`git config --get remote.origin.url 2> /dev/null`
    # get repository name via cloning type
    if [ -n "${repository}" ]; then
        local repository_type=`echo ${repository} | cut -d '/' -f1`        
        if [ "${repository_type}" == "https:" ]; then        
            repository_name=`echo ${repository} | cut -d '/' -f5`
        else
            repository_name=`echo ${repository} | cut -d '/' -f2`
        fi
    fi

    # checkign repository for this script
    if [ "${repository_name}" == "env.git" ]; then
        export ENV_PATH=`git rev-parse --show-toplevel`        
    else
        echo -e "\e[1;32mExecuted in wrong path. Please execute this local git repository. (current repository=$repository)\e[0m"
        return 1
    fi
    return 0
}

######################################################## Main ########################################################
function MAIN()
{
    local ret=0
    local python_version=3.7.7 
    # - setting default tool configuration
    # 1. check execution location
    # 2. check and install default terminal packages (oh-my-zsh, brew)
    # 3. check and install python environments packages
    
    check_location
    ret=$?

    if [ $? = 0 ]; then    
        # Load other tools        
        source $ENV_PATH/scripts/dev-tools.sh      
        
        setup_color
        
        title "Welcome Sunghoon's development world"        

        install_oh_my_zsh
        install_brew
        install_pyenv        
        install_python $python_version
        install_virtualenv $python_version

        divider
    fi

    return $ret
}

MAIN $@