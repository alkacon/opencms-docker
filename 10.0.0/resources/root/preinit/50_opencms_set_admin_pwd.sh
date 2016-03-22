#!/bin/bash

echo "Setting the Admin password if a new password is provided"
if [ -z "$OCCO_ADMIN_PASSWD" ]; then
    echo "No password set, keeping default: Admin admin"
    exit 0
fi 

echo "Adjusting OpenCms Admin password to \"$OCCO_ADMIN_PASSWD\"."

SCRIPT_FILE="/config/setup-admin-password.ocsh"
    
OCSH="login Admin admin
setPassword Admin \"$OCCO_ADMIN_PASSWD\"
login Admin \"$OCCO_ADMIN_PASSWD\"
exit"
    
echo "$OCSH" > $SCRIPT_FILE || { echo "Error: Couldn't write to '$SCRIPT_FILE'!" ; exit 1 ; }

java -classpath "${OPENCMS_HOME}/WEB-INF/lib/*:${OPENCMS_HOME}/WEB-INF/classes:/usr/share/${TOMCAT}/lib/*" \
     org.opencms.main.CmsShell -script=${SCRIPT_FILE} -base=${OPENCMS_HOME}/WEB-INF
