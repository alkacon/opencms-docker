#!/bin/bash 
# -vx
#
# Build a selected Alkacon docker image.
# Configuration read from JSON file parsed with JQ
#

##################
#
# Display usage info.
#
showUsage() {
    echo ""
    echo "${red}Usage: `basename "${0}"` ${bold}[IMAGE] [JSON-CONFIG] [OPTION]...${normal}"
    echo ""
    echo "Builds the specified Docker ${bold}[IMAGE]${normal} with the options provided by input file ${bold}[JSON-CONFIG]${normal}."
    echo ""
    echo "Supported command line ${bold}[OPTION]${normal}s:"
    echo "${bold}  --depends      ${normal}Also build all required upstream images"
    echo "${bold}  --use-cache    ${normal}Enables the docker cache for this build"
    echo "${bold}  --verbose      ${normal}More verbose output (for debugging)"
    echo "${bold}  --keep         ${normal}Don't remove old docker images after the build." 
    echo "${bold}  --push [repo]  ${normal}Push the build image to the [repo] repository."
    echo "${bold}                 ${normal}If no repository is specified, push to default repository."
    echo "${bold}  --env name value ${normal} Set the environment variable to the provided value." 
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
# Compose absolute path for mounting ${3} (webapps folder or VFS).
# ${1} is the variable holding the absolute or relative path specified for the container.
# ${2} is the prefix for relative paths specified once in the config file.
#
# The function acts as follows:
# If ${1} is an absolute path, ignore ${2}.
# If ${1} is a relative path, prepend it by ${2}.
# Then check if the resulting path exists.
# Return the final path in ${1}
# ${3} can be used for log messages.
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
        echoError "You did not specify a valid absolute path for ${3}"
        eval ${__RESULT}=""
        return 0
    fi
    # check if the final path exists or only the last folder is missing (create it, if so)
    if [ ! -d "${__PATH}" ]; then
        echoError "The folder \"${__PATH}\" specified for ${3} does not exist."
    fi
    eval ${__RESULT}="${__PATH}" 
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
# Set env variable ${1} from .Image[] JSON part with value defined by key ${2}.
#
readConfig() {
    local __RESULT=${1}
    local __JSON=$(echo ${JSON} | jq ".Image[] | select(.Name == \"${IM_NAME}\") | .${2}")
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
# Set env variable ${1} with array defined by ${2} in JSON, if ${3} is set file array with this key values.
#
readArray() {
    local __RESULT=${1}
    local __ARRAY=$(echo ${JSON} | jq -r ".Image[] | select(.Name == \"${IM_NAME}\") | .${2}")
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
            --use-cache )
                OPT_USECACHE="true"
                echoVerbose "Activated option: --use-cache"
                shift ;;
            --no-cache )
                echo "${yellow}${bold}DEPRECATED: Option --no-cache is now default behavior. Use --use-cache to enable caching.${normal}"
                shift ;;
            --depends )
                OPT_DEPENDS="true"
                echoVerbose "Activated option: --depends"
                shift ;;
            --keep )
                OPT_KEEP="true"
                echoVerbose "Activated option: --keep"
                shift ;;
            --push )
                OPT_PUSH="true"
                echoVerbose "Activated option: --push"
                shift
                if [ "${1:0:2}" != "--" ]; then
                    OPT_PUSH_TO="${1}"
                    echoVerbose "Will push to ${1}"
                else
                    echoVerbose "Will push to default repository."
                fi
                shift ;;
            --env )
            	shift
            	if [ "${1:0:2}" != "--" ]; then
                    _VAR_NAME="${1}"
                    shift
                    if [ "${1:0:2}" != "--" ]; then
                    	eval $_VAR_NAME=$1
                    	echoVerbose "Set environment variable \"${_VAR_NAME}\" to \"${!_VAR_NAME}\"."
                	else
                		echoErro "You did not specify a value for the environment variable \"${__VAR_VALUE}\"."
                	fi
                else
                    echoError "Wrong usage of '--var'. Use it with '--var name value' to set an environment variable."
                fi
                shift ;;
            "" ) break ;;
            * )
                echoError "Invalid [OPTION] \"${1}\" provided!"
                showUsage
                break ;;
        esac
    done
}

##################
#
# Creates a temporary Dockerfile with adjusted content.
#
createTmpDockerfile() {

    TMP_DOCKERFILE="Dockerfile.${IM_NAME}"
    echoVerbose "Copying default Dockerfile to \"${IM_FOLDER}/${TMP_DOCKERFILE}\""
    
    # Copy the standard Dockerfile
    cp ${CMD_OPTS} "${IM_FOLDER}/Dockerfile" "${IM_FOLDER}/${TMP_DOCKERFILE}"
    
    # Adjust FROM line 
    if [ -n "${IM_FROM}" ]; then
        sed -i "/FROM/c\FROM ${IM_FROM}" "${IM_FOLDER}/${TMP_DOCKERFILE}"
    fi    
    
    # Do additional sed replacements
    for sedcmd in ${IM_SED[@]} 
    do
        SED_ARGS=( ${sedcmd//|/ } )
        _REPLACEMENT=$(eval echo "${SED_ARGS[1]}")
        echoVerbose "Replacing \"${SED_ARGS[0]}\" with \"${_REPLACEMENT}/\" in ${TMP_DOCKERFILE}"
        sed -i "s/${SED_ARGS[0]}/${_REPLACEMENT}/" "${IM_FOLDER}/${TMP_DOCKERFILE}"
    done    
    
    if [ -n "$OPT_VERBOSE" ]; then
        echo ""
        echo "The modified Dockerfile:"
        echo "------------------------${yellow}"            
        cat "${IM_FOLDER}/${TMP_DOCKERFILE}"
        echo "${normal}------------------------"            
        echo ""
    fi
}

##################
#
# Initialize image ${1} from JSON input.
#
# This sets all required global env variables for the selected image.
#
initImage() {
    IM_NAME=${1}
    
    readConfig IM_IMAGE "Image"    
    if [ -z "${IM_IMAGE}" ]; then
        echoError "Missing \"Image:\" node for image \"${IM_NAME}\" in JSON file!" 2
    fi
    
    readConfig IM_FOLDER "Folder" 
    
    composeAbsolutePath IM_FOLDER "${ImageBase}" ".Folder"
    
    checkFolder "${IM_FOLDER}" ".Folder"
    
    readArray IM_DEPENDS "Depends"

    readConfig IM_FROM "From"    
    
    readArray IM_SED "Sed"
    
    if [ -n "${IM_FROM}" ] || [ -n "${IM_SED}" ]; then
        createTmpDockerfile
    else
        TMP_DOCKERFILE=""        
    fi        
}

##################
#
# Builds the image defined by the current global variables.
#
buildImage() {    
    echo ""
    echo ""
    echo "${green}Building image ${cyan}\"${IM_IMAGE}\"${normal}"
    if [ -z "${IM_FROM}" ]; then    
        echo "${green}Using Dockerfile located in ${cyan}\"${IM_FOLDER}\"${normal}"
    else
        echo "${green}Using upstream image FROM ${cyan}\"${IM_FROM}\" in temporary Dockerfile \"${TMP_DOCKERFILE}\"${normal}"
    fi 
    
    # combine the image build parameters in BUILD_CMD environment variable
    createImageParameters

    # the command to execute
    DOCKER_CMD="docker ${BUILD_CMD}"
    
    echo ""
    echo "${green}${bold}Executing: ${cyan}${DOCKER_CMD}${normal}"
    echo ""
    bash -c "${DOCKER_CMD}"
    
    if [ -n "${TMP_DOCKERFILE}" ] && [ -f "${IM_FOLDER}/${TMP_DOCKERFILE}" ]; then
        echoVerbose ""       
        echoVerbose "Deleting temporary Dockerfile \"${TMP_DOCKERFILE}\""
        rm ${CMD_OPTS} "${IM_FOLDER}/${TMP_DOCKERFILE}"
    fi
}

##################
#
# Combine the container parameter variables in ${BUILD_CMD}. 
#
createImageParameters() {
    BUILD_CMD="build -t \"${IM_IMAGE}\""
    if [ "${OPT_USECACHE}" != "true" ]; then             
        BUILD_CMD="${BUILD_CMD} --no-cache" 
    fi
    if [ -n "${TMP_DOCKERFILE}" ]; then             
        BUILD_CMD="${BUILD_CMD} -f \"${IM_FOLDER}/${TMP_DOCKERFILE}\"" 
    fi   
    BUILD_CMD="${BUILD_CMD} \"${IM_FOLDER}\"" 
}


##################
#
# Main Script starts here.
#
SECONDS=0
WORKDIR=$(dirname $(readlink -f ${0}))

# Check if called with the correct number of parameters
if [ -z "${2}" ]; then
    showUsage
fi

if [ ! -f "${2}" ]; then
    echoError "JSON CONFIG input file \"${2}\" not found!"
    showUsage
fi

# Initialize optional parameters
setOptions "${@:3}"

echo ""
echoVerbose "${cyan}=== START DOCKER BUILD SCRIPT ==="

# read the JSON input into an environment variable
JSON=$(<${2})

readJson ImageBase ".ImageBase"
readJson ImageRepository  ".ImageRepository"
if [ -n "${ImageRepository}" ]; then
    echo "Using image repository \"${ImageRepository}\"."
else
    echo "Using docker.io default image repository."
fi

# init the selected image
initImage ${1}

if [ "${OPT_DEPENDS}" == "true" ] && [ ! -z "${IM_DEPENDS}" ] && [ ${#IM_DEPENDS[@]} > 0 ]; then
    # Build all required upstream dependencies
    for DEP in ${IM_DEPENDS[@]} 
    do
        echo "Building upstream dependency \"${DEP}\"" 
        initImage ${DEP}
        buildImage
    done
    echo "Dependency building finished, now building \"${1}\""
    initImage ${1}
fi

# build the image
buildImage

# remove old images
if [ "${OPT_KEEP}" != "true" ]; then
    echo ""	
    echo "${green}Removing all stale images that have 'none' as name:${normal}"

    STALE_IMAGES=$(docker images | grep "^<none>" | awk '{ print $3; }')
    COUNT=$(echo "$STALE_IMAGES" | wc -m)
    
    if [ $COUNT -gt 1 ]; then
        docker rmi $STALE_IMAGES
    else
        echo "${green}- No stale images found.${normal}"    
    fi
fi

# push image if configured
if [ -n "${OPT_PUSH_TO}" ]; then
    echo ""
    echo "Tagging image as \"${OPT_PUSH_TO}/${IM_IMAGE}\""
    docker tag -f "$IM_IMAGE" "${OPT_PUSH_TO}/${IM_IMAGE}"
    echo "Pushing \"${OPT_PUSH_TO}/${IM_IMAGE}\""
    docker push "${OPT_PUSH_TO}/${IM_IMAGE}"
else
    if [ "${OPT_PUSH}" == "true" ]; then
        echo "Pushing \"${IM_IMAGE}\""
        docker push "${IM_IMAGE}"
    fi
fi

duration=${SECONDS}
echo ""    
echo "${green}${bold}Total build time: ${cyan}$(($duration / 60))m:$(($duration % 60))s${normal}"
echo ""
echoVerbose "${cyan}=== END DOCKER BUILD SCRIPT ==="
