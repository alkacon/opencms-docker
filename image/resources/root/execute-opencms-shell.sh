#!/bin/bash

echo "=== START OPENCMS SHELL ==="
echo "Installing modules from ${1}"

source /root/common.sh

# Install Modules using the OpenCms Shell
java -classpath "$(shell_classpath)" \
    org.opencms.main.CmsShell -script=${1} -base=${OPENCMS_HOME}/WEB-INF

echo "=== END OPENCMS SHELL ==="