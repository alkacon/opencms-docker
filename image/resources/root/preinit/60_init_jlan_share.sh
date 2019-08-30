#!/bin/bash

if [ "${ENABLE_JLAN}" == "true" ]; then
	echo "Enabling default Jlan SMB Share for OpenCms"
	mv -v ${OPENCMS_HOME}/WEB-INF/config/jlanConfig.xml.linux ${OPENCMS_HOME}/WEB-INF/config/jlanConfig.xml
else
	echo "Jlan SMB Share remains disabled. Start the container with \"-e ENABLE_JLAN=true\" to enable it."
fi
