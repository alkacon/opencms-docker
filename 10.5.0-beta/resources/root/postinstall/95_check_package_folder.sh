#!/bin/bash

# Check if package directory exists after the post installation script was run
PACKAGE_DIR=${OPENCMS_HOME_INSTALL}/WEB-INF/packages
if [ -d ${PACKAGE_DIR} ]; then
    echo "Package directory '${PACKAGE_DIR}' found (this is good)!"
else
    echo "ISSUE: Package directory '${PACKAGE_DIR}' NOT found (this is bad)!"
fi
