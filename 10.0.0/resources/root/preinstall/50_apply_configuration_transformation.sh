#!/bin/bash

CONFIG_XSLT=/config/opencms-configuration.xslt

if [ -f "${CONFIG_XSLT}" ]; then
    echo "Applying OpenCms configuration adjustment ${CONFIG_XSLT}"
    mv -v "${CONFIG_XSLT}" "${WEBAPPS_HOME_INSTALL}/ROOT/WEB-INF/config/"
else 
    echo "No OpenCms configuration adjustment found!"
fi  
