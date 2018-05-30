#!/bin/bash

CONFIG_FOLDER="${OPENCMS_HOME}/WEB-INF/config/"

echo "Setting test query for db pool (to avoid server error 500 on first request)"
sed -i "s/db.pool.default.testQuery=/db.pool.default.testQuery=SELECT 1/" ${CONFIG_FOLDER}opencms.properties

# Remove /opencms prefix for created links if proxy is used
if [ "${OCCO_USEPROXY}" == "true" ]; then
    # Configure OpenCms link substitution to remove the /opencms servlet name.
    echo "Configuring for Proxy: OpenCms link substitution will remove the /opencms servlet name - your proxy must add it."
    sed -i 's/${CONTEXT_NAME}${SERVLET_NAME}/${CONTEXT_NAME}/g' ${CONFIG_FOLDER}opencms-importexport.xml
fi
