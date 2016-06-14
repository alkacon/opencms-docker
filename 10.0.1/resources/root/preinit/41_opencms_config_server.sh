#!/bin/bash

CONFIG_XSLT="${OPENCMS_HOME}/WEB-INF/config/opencms-configuration.xslt"

# Set OpenCms server name
if [ -z "${OCCO_SERVER_NAME}" ] && [ -f "${CONFIG_XSLT}" ] ; then

    echo "No custom OpenCms server name provided, keeping default configuration"
else
    echo "Configuring custom OpenCms server name \"${OCCO_SERVER_NAME}\""
    REPLACE_ALIAS=""
    if [ -z "${OCCO_SERVER_ALIAS}" ]; then
        echo "No custom alias server name provided"
    else
        echo "Configuring custom OpenCms server alias \"${OCCO_SERVER_ALIAS}\""
        # Note the leading spaces have been set intentionally for nice output formatting
        REPLACE_ALIAS="\\
            <alias server=\"${OCCO_SERVER_ALIAS}\" />\\
        "
    fi   

REPLACE_SERVER="\\
<!--\\
==================================================\\
Replace server name and add alias\\
==================================================\\
-->\\
<xsl:template match=\"/opencms/system/sites\">\\
    <sites>\\
        <workplace-server>${OCCO_SERVER_NAME}</workplace-server>\\
        <default-uri>/sites/default/</default-uri>\\
        <shared-folder>/shared/</shared-folder>\\
        <site server=\"${OCCO_SERVER_NAME}\" uri=\"/sites/default/\">${REPLACE_ALIAS}</site>\\
    </sites>\\
</xsl:template>\\
"

    echo "${REPLACE_SERVER}"
    sed -i "/<!-- Insert point -->/i ${REPLACE_SERVER}" "${CONFIG_XSLT}"
fi

