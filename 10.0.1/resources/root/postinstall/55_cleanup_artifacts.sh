#!/bin/bash

# Clean up artifacts and other installation files not required for a running system
echo "Cleaning up artifact downloads."
rm -v -rf /artifacts/
rm -v -f ${OPENCMS_HOME_INSTALL}/WEB-INF/packages/modules/*.zip
rm -v -f ${OPENCMS_HOME_INSTALL}/WEB-INF/logs/*