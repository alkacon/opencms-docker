#!/bin/bash

echo "Creating or cleaning webapps folder (it may be present as volume) and moving the webapp-install/ROOT folder into it"

# IMPORTANT: Docker with aufs as storage driver has problems moving many files
# like doing  mv ${OPENCMS_HOME_INSTALL}/* ${OPENCMS_HOME}/
# see https://github.com/docker/docker/issues/4570 for details.

if [ -d ${WEBAPPS_HOME} ]; then
	rm -rf ${WEBAPPS_HOME}/*
else
	mkdir -v -p ${WEBAPPS_HOME}
fi

mv ${OPENCMS_HOME_INSTALL} ${OPENCMS_HOME} 

echo "Removing empty installation dir"
rm -rf ${WEBAPPS_HOME_INSTALL}