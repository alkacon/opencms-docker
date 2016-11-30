#!/bin/bash

# Clean up opencms core installation files not required for a running system
echo "Cleaning up core installation."
rm -v -f ${OPENCMS_HOME_INSTALL}/WEB-INF/setup.*
rm -v -rf ${OPENCMS_HOME_INSTALL}/setup
rm -v -rf ${OPENCMS_HOME_INSTALL}/WEB-INF/setupdata

# Remove superfluous jlan config
rm -v -f ${OPENCMS_HOME_INSTALL}/WEB-INF/config/jlanConfig.xml.windows

# Remove setup configuration file
rm -v ${CONFIG_FILE} 