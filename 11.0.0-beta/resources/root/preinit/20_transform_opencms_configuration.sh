#!/bin/bash

CONFIG_FOLDER="${OPENCMS_HOME}/WEB-INF/config/"
XSLT_DIR="/root/preinit/xml-transformations"
echo "Executing XSL transformation of OpenCms config files."
if [ -d "${XSLT_DIR}" ]; then
    for XSLT in ${XSLT_DIR}/*.xslt; do
        echo "."
        echo "Executing XSL transformation: ${XSLT}"
        echo "---------------------------------------------------"
        XSLT_NAME=${XSLT##*/}
        CONFIG_NAME=$(echo $XSLT_NAME| cut -d'_' -f 1)
        if [[ $CONFIG_NAME == "solr-schema" ]]; then
        	# transformation of the SOLR schema
        	XML_CONFIG_FILE="${OPENCMS_HOME}/WEB-INF/solr/configsets/default/conf/schema.xml"
        else
        	XML_CONFIG_FILE="${CONFIG_FOLDER}${CONFIG_NAME}.xml"
        fi
        if [ -f "${XML_CONFIG_FILE}" ]; then
        	cat "${XSLT}" | xsltproc --novalid --nonet --output "${XML_CONFIG_FILE}" - "${XML_CONFIG_FILE}"
    	else
    		echo "XML config file ${XML_CONFIG_FILE} does not exist"
    	fi
        echo "---------------------------------------------------"   
    done
else
    echo "Directory ${XSLT_DIR} not available, ignoring!"
fi