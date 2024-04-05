#!/bin/bash

if [ "${SERVLET_CONTAINER}" != "jetty" ] ; then
    echo "Skipping $0 because we are not using Jetty."
    exit
fi

WEB_XML=${OPENCMS_HOME}/WEB-INF/web.xml
xsltproc --stringparam cookie_name "JSESSIONID_$HOSTNAME" -o "$WEB_XML" /root/jetty-webxml.xsl "$WEB_XML"

echo ""
echo "Modified web.xml configuration looks like this:"
echo "================================================================================================="
cat "$WEB_XML"
echo ""
