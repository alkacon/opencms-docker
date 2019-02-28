#!/bin/bash

if [ -z "$1" ]; then
   echo "."
   echo "Usage: $0 {SCRIPT_DIR}"
   echo "."
   exit 1
fi

SCRIPT_DIR=$1

echo "."
echo "Executing scripts located in ${SCRIPT_DIR}."

if [ -d "${SCRIPT_DIR}" ]; then
    for SCRIPT in ${SCRIPT_DIR}/*.sh; do
        echo "."
        echo "Executing OpenCms configuration script: ${SCRIPT}"
        echo "---------------------------------------------------"
        bash "${SCRIPT}"
        if [[ ${SCRIPT} = *.runonce.sh ]]; then
            echo "."
            echo "Disabling configuration script: ${SCRIPT}"
            mv -v "${SCRIPT}" "${SCRIPT}.executed"
        fi
        echo "---------------------------------------------------"   
    done
    if [ "$2" = "runonce" ]; then
        echo "."
        echo "Disabling configuration script folder: ${SCRIPT_DIR}"
        mv -v "${SCRIPT_DIR}" "${SCRIPT_DIR}.executed"           
    fi  
else
    echo "Directory ${SCRIPT_DIR} not available, ignoring!"
fi

echo "."