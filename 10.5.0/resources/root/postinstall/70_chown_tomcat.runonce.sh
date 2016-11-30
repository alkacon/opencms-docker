#!/bin/bash

echo "Ensuring ${TOMCAT} is the owner of everything in the the OpenCms webapp install folder"
chown -v -R ${TOMCAT}:${TOMCAT} ${OPENCMS_HOME_INSTALL}
