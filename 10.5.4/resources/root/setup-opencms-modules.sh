#!/bin/bash

echo "=== START OPENCMS SETUP ==="
echo "Installing modules from ${1}"

# Start database server
service mysql start

# Install Modules using the OpenCms Shell
java -classpath "${OPENCMS_HOME_INSTALL}/WEB-INF/lib/*:${OPENCMS_HOME_INSTALL}/WEB-INF/classes:/usr/share/${TOMCAT}/lib/*" \
    org.opencms.main.CmsShell -script=${1}
        
echo "=== END OPENCMS SETUP ==="
