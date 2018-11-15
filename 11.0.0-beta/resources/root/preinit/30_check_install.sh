#!/bin/bash
CONFIG_CMSSETUP=/config/cmssetup.txt
if [ ! -z "$ADMIN_PASSWD" ]; then
	echo "Changing Admin password"
	sed -i -- "s/Admin admin/\"Admin\" \"${ADMIN_PASSWD}\"/g" /config/update*
	sed -i -- "s/login \"Admin\" \"admin\"/login \"Admin\" \"admin\"\nsetPassword \"Admin\" \"$ADMIN_PASSWD\"\nlogin \"Admin\" \"$ADMIN_PASSWD\"/g" $CONFIG_CMSSETUP 
fi

if [ -f "${OPENCMS_HOME}/WEB-INF/lib/opencms.jar" ]
then
	TARGET=$(<${OPENCMS_HOME}/WEB-INF/run_target)
	echo "Creating backup of opencms-modules.xml at ${OPENCMS_HOME}/WEB-INF/config/backups/opencms-modules-preinst.xml"
	if [ ! -d ${OPENCMS_HOME}/WEB-INF/config/backups ]; then
		mkdir -v -p ${OPENCMS_HOME}/WEB-INF/config/backups
	fi
	cp -f -v ${OPENCMS_HOME}/WEB-INF/config/opencms-modules.xml ${OPENCMS_HOME}/WEB-INF/config/backups/opencms-modules-preinst.xml
	echo "Update modules core"
	bash /root/update-opencms-modules.sh /config/import-core-modules.ocsh ${OPENCMS_HOME}
else
	echo "OpenCms not installed yet, running setup"
	if [ ! -d ${WEBAPPS_HOME} ]; then
		mkdir -v -p ${WEBAPPS_HOME}
	fi
	
	if [ ! -d ${OPENCMS_HOME} ]; then
		mkdir -v -p ${OPENCMS_HOME}
	fi
	
	echo "Unzip the .war"
	
	unzip -q -d ${OPENCMS_HOME} ${ARTIFACTS_FOLDER}opencms.war

	cp -v "${CONFIG_CMSSETUP}" "${OPENCMS_HOME}/WEB-INF/setupdata/"
	echo "Install OpenCms using org.opencms.setup.CmsAutoSetup with properties \"${CONFIG_FILE}\"" && \
	java -classpath "${OPENCMS_HOME}/WEB-INF/lib/*:${OPENCMS_HOME}/WEB-INF/classes:${TOMCAT_LIB}/*" org.opencms.setup.CmsAutoSetup -path ${CONFIG_FILE}
fi