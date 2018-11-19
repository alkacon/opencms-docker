#!/bin/bash

echo "=== START OPENCMS SHELL ==="
echo "Installing modules from ${1} using OpenCms home ${2}"

# Install Modules using the OpenCms Shell
java -classpath "${2}/WEB-INF/classes:${2}/WEB-INF/lib/*:${TOMCAT_LIB}/*" \
    org.opencms.main.CmsShell -script=${1}
        
echo "=== END OPENCMS SHELL ==="