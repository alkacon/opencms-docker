#!/bin/bash 
# -vx
#
# Start a selected Alkacon docker container.
# Configuration read from JSON file parsed with JQ
#

##################
#
# Display usage info.
#
showUsage() {
    echo ""
    echo "${red}Usage: `basename "${0}"` ${bold}[CONTAINER] [JSON-CONFIG] [OPTION]...${normal}"
    echo ""
    echo "Starts the specified Docker ${bold}[CONTAINER]${normal} with the options provided by input file ${bold}[JSON-CONFIG]${normal}."
    echo ""
    echo "Supported command line ${bold}[OPTION]${normal}s:"
    echo "${bold}  --verbose     ${normal}More verbose output (for debugging)"
    echo "${bold}  --pull        ${normal}Pull the image before running it (force an update of the local image)"
    echo "${bold}  --keep        ${normal}Don't remove old containers after the container was started." 
    echo "${bold}  --stop        ${normal}Just stop (and unmount, remove) the container, don't run it"
    echo ""
    exit 1
}

##################
#
# Display error message ${1} and then exit the script with code ${2}.
# If ${2} is not provided then do not exit.
#
echoError() {
    echo ""
    echo -e "${red}ERROR: ${bold}${1}${normal}"
    if [ -n "${2}" ]; then
        echo ""
        exit ${2}
    fi
}

##################
#
# Display message ${1} only if --verbose is enabled.
#
echoVerbose() {
    if [ -n "${OPT_VERBOSE}" ]; then
        echo "${1}${normal}"
    fi
}

##################
#
# Checks if the specified folder ${1} is an absolute path and exists.
# The ${2} option should reference the JSON node for log messages.
#
checkFolder() {
    if [ -z "${1}" ]; then
        echoError "No ${2} node in JSON file, or value expands to empty string." 1
    else
        if [ "${1:0:1}" != "/" ]; then
            echoError "Configured ${2} \"${1}\" is not an absolute path!" 1
        else
            if [ ! -d "${1}" ]; then
                echoError "Configured ${2} \"${1}\" does not exist!" 1
            fi
        fi
    fi
}

##################
#
# Set env variable ${1} with value defined by ${2} in JSON.
#
readJson() {
    local __RESULT=${1}
    local __JSON=$(echo ${JSON} | jq "${2}")
    if [ "${__JSON}" == "null" ] || [ "${__JSON}" = "\"\"" ] || [ -z "${__JSON}" ] ; then
        # null or zero strings in JSON will have the String value "null"
        eval ${__RESULT}=""
    else 
        eval eval ${__RESULT}="'${__JSON}'"
    fi
    eval local __RES=\${${__RESULT}} 
    echoVerbose "Value for ${1} is: \"${__RES}\"" 
}

##################
#
# Set env variable ${1} from .Container[] JSON part with value defined by key ${2}.
# If the variable is not defined or empty, then return set ${1} to ${3} (default value).
#
readConfig() {
    local __RESULT=${1}
    local __JSON=$(echo ${JSON} | jq ".Container[] | select(.Name == \"${CO_NAME}\") | .${2}")
    if [ "${__JSON}" == "null" ] || [ "${__JSON}" = "\"\"" ] || [ -z "${__JSON}" ] ; then
        # null or zero strings in JSON will have the String value "null"
        eval ${__RESULT}="${3}"
    else 
        eval eval ${__RESULT}="'${__JSON}'"
    fi
    eval local __RES=\${${__RESULT}} 
    echoVerbose "Value for ${1} is: \"${__RES}\""
}

##################
#
# Set env variable ${1} with array defined by ${2} in JSON, if ${3} is set file array with this key values.
#
readArray() {
    local __RESULT=${1}
    local __ARRAY=$(echo ${JSON} | jq -r ".Container[] | select(.Name == \"${CO_NAME}\") | .${2}")
    if [ "${__ARRAY}" != "null" ]; then
        # echo "Array data for ${1}: ${__ARRAY}"
        local __JSON=""
        if [ -z $3 ]; then
            __JSON=( $(echo ${__ARRAY} | jq -r ".[]") )
        else
            __JSON=( $(echo ${__ARRAY} | jq -r ".[].$3") )
        fi
        echoVerbose "Array for ${1} is: ${__JSON[@]}"
        eval ${__RESULT}="\${__JSON[@]}"
    else 
        echoVerbose "Array for ${1} not found!"
    fi 
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

    while true; do
        case "${1}" in
            --verbose ) 
                OPT_VERBOSE="true"
                CMD_OPTS=" -v "
                echoVerbose "Activated option: --verbose"
                shift ;;
            --pull )
                OPT_PULL="true"
                echoVerbose "Activated option: --pull"
                shift ;;
            "" ) break ;;
            --keep )
                OPT_KEEP="true"
                echoVerbose "Activated option: --keep"
                shift ;;            
            --stop )
                OPT_STOP="true"
                echoVerbose "Activated option: --stop"
                shift ;;
            "" ) break ;;            * )
                echoError "Invalid [OPTION] \"${1}\" provided!"
                showUsage
                break ;;
        esac
    done 
}

##################
#
# Compose absolute path for mounting ${3} (webapps folder or VFS).
# ${1} is the variable holding the absolute or relative path specified for the container.
# ${2} is the prefix for relative paths specified once in the config file.
#
# The function acts as follows:
# If ${1} is an absolute path, ignore ${2}.
# If ${1} is a relative path, prepend it by ${2}.
# Then check if the resulting path exists at least up to the last folder.
# If only the last folder is missing, create it.
# Return the final path in ${1}
#
composeAbsolutePath() {
    local __RESULT=${1}
    local __PREFIX=${2}
    local __PATH=${!__RESULT}
    # check if path was set in JSON, if not no absolute path needs to be checked
    if [ -z "${__PATH}" ]; then
        return 0
    fi
    # prepend prefix if path is not absolute
    if [ "${__PATH:0:1}" != "/" -a -n "${__PREFIX}" ]; then
        __PATH="${__PREFIX%/}/${__PATH}"
    fi
    # check if the final path is absolute
    if [ "${__PATH:0:1}" != "/" ]; then
        echoError "You did not specify a valid absolute path for the ${3} mount point. ${3} will not be mounted. The path (with optional prefix) is ${__PATH}."
        eval ${__RESULT}=""
        return 0
    fi
    # check if the final path exists or only the last folder is missing (create it, if so)
    if [ ! -d "${__PATH}" ]; then
        echoVerbose "${cyan}Creating directory ${__PATH} as ${3} mount point."
        mkdir ${__PATH} 2> /dev/null
        if [ ! -d "${__PATH}" ]; then
            echoError "The path \"${__PATH}\" could not be created as ${3} mount point. Verify if it was present up to the last folder already. ${3} will not be mounted."
            eval ${__RESULT}=""
            return 0
        fi
    fi
    echoVerbose "${cyan}Absolute path to ${3} mount point is ${__PATH}"
    eval ${__RESULT}="${__PATH}" 
}

##################
#
# Check if the network named ${1} is up, set ${NET_STATUS} accordingly.
#
checkNetworkStatus() {
    NET_STATUS_JSON=$(docker network inspect ${1} 2> /dev/null)
    NET_STATUS="unknown"
    if [ "${NET_STATUS_JSON}" != "[]" ] && [ "${NET_STATUS_JSON}" != "null" ]; then
#        echoVerbose "Raw docker network status: ${NET_STATUS_JSON}"
        local __RUNNING=$(echo ${NET_STATUS_JSON} | jq -r ".[].Scope")
        NET_STATUS=${__RUNNING}
    fi 
    echo "${green}Docker network ${cyan}\"${1}\"${green} selected${normal}" 
}

##################
#
# Initialize the network named ${1}, create if not already up.
#
initNetwork() {
    checkNetworkStatus ${1}
    if [ "${NET_STATUS}" == "unknown" ]; then
        echo "Docker network \"${1}\" not available, creating it in bridged mode" 
        docker network create -d bridge ${1}
    else
        if [ "${NET_STATUS}" == "local" ]; then
            echoVerbose "Docker network \"${1}\" already configured, using it"
        else
            echoError "Invalid docker network scope ${NET_STATUS} for network ${1}, exiting!" 3
        fi    
    fi
}

##################
#
# Check if container ${1} is up, set ${CO_STATUS} accordingly-
#
checkContainerStatus() {
    CO_STATUS_JSON=$(docker inspect ${1} 2> /dev/null)
    CO_STATUS="unknown";
    if [ "${CO_STATUS_JSON}" != "[]" ]; then
        local __RUNNING=$(echo ${CO_STATUS_JSON} | jq -r ".[].State.Running")
        if [ ${__RUNNING} == "true" ]; then
            CO_STATUS="running"
        else
            CO_STATUS="stopped"
        fi
    fi 
    echoVerbose "Container \"${1}\" status is: \"${CO_STATUS}\""
}


##################
#
# Check if the docker container with ip address ${1} exposes the SMB share.
# 
checkSmbPort() {
    local __RESULT=${1}
    echo ""
    echo "Waiting until network share becomes available for IP ${2}:"
    COUNT=0
    POINTS="";
    while ! nc -z ${2} 1445; do
        if [ $COUNT -eq 60 ]; then
            break
        fi
        POINTS+="."
        echo "Waiting ${cyan}${bold}${POINTS}${normal}"
        COUNT=$[$COUNT+1]
        sleep 1
    done
    if [ $COUNT -gt 59 ]; then
        eval ${__RESULT}="false"
    else
        eval ${__RESULT}="true"
    fi
}

##################
#
# Mounting the SMB network share of container with name ${CO_CONTAINER} at path ${CO_VFS_MOUNT_POINT} if it is exposed by the container.
#
mountVfs() {
    if ! command -v nc ; then
        echoError "nc (netcat) is not installed, unable to mount the VFS."
        return
    fi

    echo ""
    echo "${cyan}Mounting the VFS for container \"${CO_CONTAINER}\" to \"${CO_VFS_MOUNT_POINT}\"${normal}"
    echoVerbose "Waiting for container to be ready ..."
    sleep 5

    local __DOCKER_IP=$(docker inspect --format "{{ .NetworkSettings.Networks.${NET_NAME}.IPAddress }}" ${CO_CONTAINER})
    echoVerbose "Retrieved IP ${__DOCKER_IP} for docker ${CO_CONTAINER}"
    local __HAS_SHARE
    checkSmbPort "__HAS_SHARE" "${__DOCKER_IP}"
    if [  "${__HAS_SHARE}" == "true" ]; then
        #create credentials file to deal with special characters in user name and password
        local __CREDENTIALS_FILE="/tmp/vfsmount.credentials"
        echo "username=${CO_VFS_MOUNT_OC_USER}" > ${__CREDENTIALS_FILE}
        echo "password=${CO_VFS_MOUNT_OC_PASSWORD}" >> ${__CREDENTIALS_FILE}
        local __MOUNT_CMD="sudo mount -t cifs //${__DOCKER_IP}/OPENCMS \"${CO_VFS_MOUNT_POINT}\" -o credentials=${__CREDENTIALS_FILE},port=1445,file_mode=${CO_VFS_MOUNT_FILE_MODE},dir_mode=${CO_VFS_MOUNT_DIR_MODE},uid=${CO_VFS_MOUNT_USER_ID},gid=${CO_VFS_MOUNT_GROUP_ID}"
        echo ""
        echo "${green}${bold}Executing: ${cyan}${__MOUNT_CMD}${normal}"
        echoVerbose "Using credentials file:"
        echoVerbose "${yellow}$(cat "${__CREDENTIALS_FILE}")${normal}"
        bash -c "${__MOUNT_CMD}"
        rm "${__CREDENTIALS_FILE}"
    else
        echoError "Could not mount VFS for container \"${CO_CONTAINER}\""
    fi
}

##################
#
# Unmount the SMB network share of container with name ${1} before stopping the container.
#
umountVfs() {
    local __DOCKER_IP=$(docker inspect --format "{{ .NetworkSettings.Networks.${NET_NAME}.IPAddress }}" ${1})
    if [ -n "${__DOCKER_IP}" ]; then
        echoVerbose "Unmounting possible network shares of the VFS from running container ${1} ..."
        local __MOUNT_NAME="//${__DOCKER_IP}/OPENCMS "
        while mount | grep -q "${__MOUNT_NAME}" 
        do
            echoVerbose "Unmounting a share ..."
            sudo umount ${__MOUNT_NAME}
        done
    fi
}

##################
#
# Do docker stop and rm for ${1}.
#
dropContainer() {
    checkContainerStatus ${1}

    if  [ -z "${OPT_STOP}" ] && [ -n "${DOCKER_RUN_SAFEMODE}" ]; then
        # In safe mode we don't want to just kill the container
        if [ ${CO_STATUS} == "stopped" ] || [ ${CO_STATUS} == "running" ]; then
            echo ""
            echo "${red}${bold}Container \"${1}\" still running or loaded!${normal}"
            echo ""
            echo "${red}Stop and remove the container using:${normal}"
            echo "${yellow}${bold}docker-run --stop${normal}"
            echoError "Exiting" 4
        fi
    fi  
    if [ ${CO_STATUS} == "running" ]; then
        echo "${green}Container ${cyan}\"${1}\"${green} is running, unmounting possible VFS mounts and stopping it${normal}"
        umountVfs "${1}"
        echoVerbose "Stopping container \"${1}\"..."
        docker stop "${1}"
    else
        if [ -n "${OPT_STOP}" ]; then
            echo "Container \"${1}\" is not running, no need to stop it"
        fi
    fi
    if [ ${CO_STATUS} == "stopped" ] || [ ${CO_STATUS} == "running" ]; then
        echoVerbose "Container \"${1}\" is loaded, removing it"
        docker rm "${1}"
    fi
}

##################
#
# Initialize container ${1} from JSON input.
#
# This sets all required global env variables for the selected container.
#
initContainer() {
    CO_NAME=${1}

    readConfig CO_CONTAINER "Container"
    CO_CONTAINER=${CO_CONTAINER:-$CO_NAME}
    echo ""

    if [ -z "${OPT_STOP}" ]; then
        echo "${green}Running container ${cyan}\"${CO_CONTAINER}\"${normal}"
    else
        echo "${red}STOPPING container ${cyan}\"${CO_CONTAINER}\"${normal}"
    fi

    readConfig CO_IMAGE "Image"

    if [ -z "${CO_IMAGE}" ]; then
        echoError "Could not find configuration for \"${CO_NAME}\" in JSON file!" 2
    fi

    readConfig CO_PROXY "Proxy"
    readConfig CO_SERVER_NAME "ServerName"
    CO_SERVER_NAME=${CO_SERVER_NAME:-"http://${CO_CONTAINER}"}

    echoVerbose "Container \"${CO_CONTAINER}\" uses server name \"${CO_SERVER_NAME}\""

    readConfig CO_SERVER_ALIAS "ServerAlias"
    readConfig CO_PASSWORD "Password" "admin"

    if [ -n "${MountFolderBase}" ]; then
        readConfig CO_WEBAPP_MOUNT_POINT "WebappMountPoint"
        composeAbsolutePath CO_WEBAPP_MOUNT_POINT "${MountFolderBase}" "Webapps"
        readConfig CO_VFS_MOUNT_POINT "VfsMount.MountPoint"
        composeAbsolutePath CO_VFS_MOUNT_POINT "${MountFolderBase}" "VFS"
        readConfig CO_VFS_MOUNT_GROUP_ID "VfsMount.GroupId" "1000"
        readConfig CO_VFS_MOUNT_USER_ID "VfsMount.UserId" "1000"
        readConfig CO_VFS_MOUNT_OC_USER "VfsMount.OCUser" "Admin"
        readConfig CO_VFS_MOUNT_OC_PASSWORD "VfsMount.OCPassword" "${CO_PASSWORD}"
        readConfig CO_VFS_MOUNT_FILE_MODE "VfsMount.FileMode" "0644"
        readConfig CO_VFS_MOUNT_DIR_MODE "VfsMount.DirMode" "0775"
    fi

    readConfig CO_DEBUG "Debug"    
    readConfig CO_EXTRA_PARAMS "ExtraParams"
    readArray CO_LINKS "Links"
}

##################
#
# Run container ${1}, set ${CO_STATUS} accordingly.
#
runLinkedContainer() {
    echo "Checking for linked container: ${1}"
    checkContainerStatus ${1}
    if [ "${CO_STATUS}" != "running"  ]; then
        echo "Linked container ${1} not running, starting it"
        initContainer ${1}
    fi
}

##################
#
# Combine the container parameter variables in ${RUN_CMD}. 
#
createContainerParameters() {
    CO_HOSTNAME="${CO_CONTAINER//[._]/-}"
    RUN_CMD="run -d --name=\"${CO_CONTAINER}\" --net=\"${NET_NAME}\" -h \"${CO_HOSTNAME}\""
    if [ -n "${CO_SERVER_NAME}" ] && [ "-" != "${CO_SERVER_NAME}" ] ; then 
        RUN_CMD="${RUN_CMD} -e \"OCCO_SERVER_NAME=${CO_SERVER_NAME}\"" 
    fi
    if [ -n "${CO_SERVER_ALIAS}" ]; then 
        RUN_CMD="${RUN_CMD} -e \"OCCO_SERVER_ALIAS=${CO_SERVER_ALIAS}\"" 
    fi    
    if [ -n "${CO_PASSWORD}" ] && [ "-" != "${CO_PASSWORD}" ]; then 
        RUN_CMD="${RUN_CMD} -e \"OCCO_ADMIN_PASSWD=${CO_PASSWORD}\"" 
    fi
    if [ "${CO_PROXY}" == "true" ]; then 
        RUN_CMD="${RUN_CMD} -e \"OCCO_USEPROXY=true\"" 
    fi    
    if [ -n "${CO_VFS_MOUNT_POINT}" ]; then
        RUN_CMD="${RUN_CMD} -e \"OCCO_ENABLE_JLAN=true\""
    fi
    if [ "${CO_DEBUG}" == "true" ]; then
        RUN_CMD="${RUN_CMD} -e \"OCCO_DEBUG=true\""
    fi
    if [ -n "${CO_WEBAPP_MOUNT_POINT}" ]; then
        local __WEBAPPS_HOME=$(docker inspect -f "{{range .Config.Env }}{{println .}}{{end}}" ${CO_IMAGE} | grep "WEBAPPS_HOME=")
        # set variable WEBAPPS_HOME
        eval "${__WEBAPPS_HOME}"        
        if [ -n "${WEBAPPS_HOME}" ]; then
            RUN_CMD="${RUN_CMD} -v \"${CO_WEBAPP_MOUNT_POINT}\":\"${WEBAPPS_HOME}\""
        else
            echoError "Unable to determine WEBAPPS_HOME from container configuration, skipping mount parameter!" 
        fi
    fi
    if [ -n "${CO_EXTRA_PARAMS}" ]; then 
        RUN_CMD="${RUN_CMD} ${CO_EXTRA_PARAMS}" 
    fi
}

##################
#
# Main Script starts here.
#
WORKDIR=$(dirname $(readlink -f ${0}))

JSON_INPUT="${DOCKER_RUN_CONFIG:-$2}"
CONTAINER_NAME="${DOCKER_RUN_NAME:-$1}"

# Check if called with the correct number of parameters
if [ -z "${JSON_INPUT}" ] || [ -z "${CONTAINER_NAME}" ]; then
    showUsage
fi

# Initialize optional parameters
if [ -z "${DOCKER_RUN_CONFIG}" ]; then
    setOptions "${@:3}"
else
    if [ -z "${DOCKER_RUN_NAME}" ]; then
        setOptions "${@:2}"
    else
        setOptions "${@:1}"
    fi
fi

echo ""
echo "${green}Using JSON input from: ${cyan}\"${JSON_INPUT}\"${normal}"
echo "${green}Running container    : ${cyan}\"${CONTAINER_NAME}\"${normal}"

if [ ! -f "${JSON_INPUT}" ]; then
    echoError "JSON CONFIG input file \"${JSON_INPUT}\" not found!"
    showUsage
fi

echo ""
echoVerbose "${cyan}=== START DOCKER RUN SCRIPT ==="

# read the JSON input into an environment variable
JSON=$(<${JSON_INPUT})

readJson MountFolderBase ".MountFolderBase"
if [ -z "${MountFolderBase}" ]; then
    echoError "No mount folder base set, VFS mounting is disabled!"
else
    checkFolder "${MountFolderBase}" ".MountFolderBase"
fi

readJson ImageRepository  ".ImageRepository"
if [ -n "${ImageRepository}" ]; then
    echo "${green}Using image repository ${cyan}\"${ImageRepository}\"${normal}"
else
    echo "${green}Using docker.io default image repository${normal}"
fi

readJson NET_NAME ".NetworkName"
if [ -z "${NET_NAME}" ]; then
    echoError "Could not read required .NetworkName node in JSON file, or value expands to empty string!" 1
fi

# init the selected container
initContainer "${CONTAINER_NAME}"

# init the network
initNetwork ${NET_NAME}

# drop the container if it currently running
dropContainer ${CO_CONTAINER}

if [ -z "${OPT_STOP}" ] ; then

    # Make sure we have write permissions on the mounted folder
    if [ -n "${DOCKER_RUN_FORCEWRITE}" ]; then
        # Test if sudo permissions are already available
        CAN_I_RUN_SUDO=$(sudo -n uptime 2>&1|grep "load"|wc -l)
        if ! [ ${CAN_I_RUN_SUDO} -gt 0 ]; then
            echo ""
            echo "${red}sudo / root permissions required: Plase enter password.${normal}"
            echo ""
            sudo whoami 
        fi
    fi

    # build the container parameters in RUN_CMD environment variable
    createContainerParameters

    # pull image if option is activated
    if [ -n "${OPT_PULL}" ] ; then
        PULL_CMD="docker pull ${CO_IMAGE}"
        echo ""
        echo "Pulling image via: ${PULL_CMD}"
        echo ""
        bash -c "${PULL_CMD}"
        echo ""
    fi

    # the command to execute
    DOCKER_CMD="docker ${RUN_CMD} ${CO_IMAGE}"

    echo ""
    echo "${green}${bold}Executing: ${cyan}${DOCKER_CMD}${normal}"
    echo ""

    if ! bash -c "${DOCKER_CMD}" ; then
        echoError "Failed to start the docker container. See the error message directly above." 5
    fi 

    # Mount the VFS if a mount point is given
    if [ -n "${CO_VFS_MOUNT_POINT}" ]; then
        mountVfs
    fi

    # Make sure we have write permissions on the mounted folder
    if [ -n "${DOCKER_RUN_FORCEWRITE}" ] && [ -n "${CO_WEBAPP_MOUNT_POINT}" ]; then
        echo ""
        echo "Forcing a+w on mounted folder: ${CO_WEBAPP_MOUNT_POINT}"
        echo ""    
        sudo chmod -R a+w "${CO_WEBAPP_MOUNT_POINT}"
    fi
fi

# remove old containers
if [ "${OPT_KEEP}" != "true" ]; then
    echo ""    
    echo "${green}Removing all stale containers:${normal}"
    STALE_CONTAINERS=$(docker ps -a | grep "Exited " | awk '{ print $1; }')
    COUNT=$(echo "$STALE_CONTAINERS" | wc -m)

    if [ $COUNT -gt 1 ]; then
        docker rm $STALE_CONTAINERS
    else
        echo "${green}- No stale containers found.${normal}"
    fi
fi

echo ""
echoVerbose "${cyan}=== END DOCKER RUN SCRIPT ==="
