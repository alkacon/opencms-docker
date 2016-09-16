#!/bin/bash 
#
# Mount OpenCms with SAMBA.
#


##################
#
# Display usage info.
#
showUsage() {
    echo ""
    echo "${red}Usage: `basename "${0}"` ${bold}[OPTIONS]${normal}"
    echo ""
    echo "Supported command line ${bold}[OPTION]${normal}s:"
    echo "${bold} -f FILENAME   ${normal}Process given file for parameters, e.g. '~/docker-1'."
    echo "${bold} -t TARGET     ${normal}Mount on the given target folder '/mnt/mymount/' (${OCMOUNT_TARGET})."
    echo "${bold} -s SOURCE     ${normal}Mount the given remote folter, e.g. '//docker-1/OCMOUNTS' (${OCMOUNT_SOURCE})."
    echo "${bold} -u USER       ${normal}Username to use for login, eg. 'Admin' (${OCMOUNT_USER})." 
    echo "${bold} -p PASSWORD   ${normal}Password to use for login, eg. 'admin' (${OCMOUNT_PWD})." 
    echo "${bold} -i ID         ${normal}Used as user and group name for local mounting, e.g. 'root' (${OCMOUNT_ID})."
    echo "${bold} -o PORT       ${normal}Port to connect to, eg. '1445' (${OCMOUNT_PORT})." 
    echo "${normal}"    
    exit 1
}

##################
#
# Check for empty parameter.
#
checkEmpty() {
    for i in "$@"; do
        eval local PARAM="\${${i}}"
        if [ -z "${PARAM}" ]; then
            showUsage 
        fi
        shift
    done
}

##################
#
# Set env variable for options.
#
setOptions() {
    
    # check if stdout is a terminal...
    if test -t 1; then
        # see if it supports colors...
        NCOLORS=$(tput colors)
        if test -n "${NCOLORS}" && test ${NCOLORS} -ge 8; then
            bold="$(tput bold)"
            underline="$(tput smul)"
            standout="$(tput smso)"
            normal="$(tput sgr0)"
            black="$(tput setaf 0)"
            red="$(tput setaf 1)"
            green="$(tput setaf 2)"
            yellow="$(tput setaf 3)"
            blue="$(tput setaf 4)"
            magenta="$(tput setaf 5)"
            cyan="$(tput setaf 6)"
            white="$(tput setaf 7)"
        fi
    fi

#    OCMOUNT_TARGET="${OCMOUNT_TARGET:-/mnt/opencms/vfs/}"
#    OCMOUNT_SOURCE="${OCMOUNT_SOURCE:-//localhost/OPENCMS}"
    OCMOUNT_USER="${OCMOUNT_USER:-Admin}"
    OCMOUNT_PWD="${OCMOUNT_PWD:-admin}"
    OCMOUNT_ID="${OCMOUNT_ID:-$USER}"
    OCMOUNT_PORT="${OCMOUNT_PORT:-445}"

    while true; do
        case "${1}" in
        -f | --file ) 
                OCMOUNT_PARAMFILE="${2}"
                source ${OCMOUNT_PARAMFILE}
                shift 2 ;;
            -t | --target ) 
                OCMOUNT_TARGET="${2}"
                shift 2 ;;
            -s | --source )
                OCMOUNT_SOURCE="${2}"
                shift 2 ;;
            -u | --user )
                OCMOUNT_USER="${2}"
                shift 2 ;;
            -p | --pwd | --password )
                OCMOUNT_PWD="${2}"
                shift 2 ;;                
            -i | --id )
                OCMOUNT_ID="${2}"
                shift 2 ;;
            -o | --port )
                OCMOUNT_PORT="${2}"
                shift 2 ;;
            "" ) break ;;                
            * )
                echo "Invalid [OPTION] \"${1}\" provided!"
                showUsage
                break ;;
        esac
    done
    
	checkEmpty "OCMOUNT_TARGET" "OCMOUNT_SOURCE" "OCMOUNT_USER" "OCMOUNT_PWD" "OCMOUNT_ID" "OCMOUNT_PORT"
}

setOptions "${@}"

MNT_PARAM="-v -t cifs -o uid=${OCMOUNT_ID},gid=${OCMOUNT_ID},username=${OCMOUNT_USER},password=${OCMOUNT_PWD},port=${OCMOUNT_PORT} ${OCMOUNT_SOURCE} ${OCMOUNT_TARGET}"

# the command to execute
MNT_CMD="sudo mount ${MNT_PARAM}"
    
echo ""
echo "${green}${bold}Executing: ${cyan}"
echo "sudo umount -v -l -f ${OCMOUNT_TARGET}"
echo "${MNT_CMD}"
echo "ls -la ${OCMOUNT_TARGET}"
echo "${normal}"

sudo umount -v -l -f ${OCMOUNT_TARGET}
bash -c "${MNT_CMD}"
ls -la ${OCMOUNT_TARGET}
