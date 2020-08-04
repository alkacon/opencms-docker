#!/bin/bash

CONFIG_WEBXML="${OPENCMS_HOME}/WEB-INF/web.xml"
CONFIG_TMPFILE="/tmp/webxml.txt"

# Optimize web.xml configuration
if ! grep -q "ExpiresFilter" "$CONFIG_WEBXML" ; then
read -r -d '' REPLACE_WEBXML << EOM

    <!--
    =====================================================================
    Add "max-age" header for all exported resources
    =====================================================================
    -->

    <filter>
        <filter-name>ExpiresFilter</filter-name>
        <filter-class>org.apache.catalina.filters.ExpiresFilter</filter-class>
        <init-param>
            <param-name>ExpiresByType text/css</param-name>
            <param-value>access plus 24 hours</param-value>
        </init-param>
        <init-param>
            <param-name>ExpiresByType application/javascript</param-name>
            <param-value>access plus 24 hours</param-value>
        </init-param>
        <init-param>
            <param-name>ExpiresDefault</param-name>
            <param-value>access plus 365 days</param-value>
        </init-param>
    </filter>

    <filter-mapping>
        <filter-name>ExpiresFilter</filter-name>
        <url-pattern>/export/*</url-pattern>
        <dispatcher>REQUEST</dispatcher>
    </filter-mapping>

EOM

echo "${REPLACE_WEBXML}" > "${CONFIG_TMPFILE}"

sed -i "/<display-name>OpenCms<\/display-name>/ r ${CONFIG_TMPFILE}" "${CONFIG_WEBXML}"

echo ""
echo "Modified web.xml configuration looks like this:"
echo "================================================================================================="
cat "${CONFIG_WEBXML}"
echo ""
else
echo "web.xml is already modified. Skipping repeated optimization."
fi