#!/bin/bash
if [ ! -d ${ARTIFACTS_FOLDER}libs ]; then
	mkdir -v -p ${ARTIFACTS_FOLDER}libs
fi

echo "Writing properties file to contain list of JARs used by the OpenCms core, to be used in later updates."
JAR_NAMES=$( zipinfo -1 ${ARTIFACTS_FOLDER}opencms.war *.jar | tr '\n' ',' )
JAR_NAMES_PROPERTIES="OPENCMS_CORE_LIBS=$JAR_NAMES"
JAR_NAMES_PROPERTIES_FILE=${ARTIFACTS_FOLDER}libs/core-libs.properties
echo "$JAR_NAMES_PROPERTIES" > $JAR_NAMES_PROPERTIES_FILE

if [ -f "${OPENCMS_HOME}/WEB-INF/lib/opencms.jar" ]
then
	echo "OpenCms already installed, updating modules and libs"

	if [ ! -z "$ADMIN_PASSWD" ]; then
		echo "Changing Admin password for update"
		sed -i -- "s/Admin admin/\"Admin\" \"${ADMIN_PASSWD}\"/g" /config/update*
	fi

	echo "Extract modules and libs"
	unzip -q -d ${ARTIFACTS_FOLDER}TEMP ${ARTIFACTS_FOLDER}opencms.war WEB-INF/packages/modules/*.zip WEB-INF/lib/*.jar
	mv ${ARTIFACTS_FOLDER}TEMP/WEB-INF/packages/modules/* ${ARTIFACTS_FOLDER}

	mv ${ARTIFACTS_FOLDER}TEMP/WEB-INF/lib/* ${ARTIFACTS_FOLDER}libs
	echo "Renaming modules to remove version number"
	for file in ${ARTIFACTS_FOLDER}*.zip
	do
   		mv $file ${file%-*}".zip"
	done

	echo "Creating backup of opencms-modules.xml at ${OPENCMS_HOME}/WEB-INF/config/backups/opencms-modules-preinst.xml"
	if [ ! -d ${OPENCMS_HOME}/WEB-INF/config/backups ]; then
		mkdir -v -p ${OPENCMS_HOME}/WEB-INF/config/backups
	fi
	cp -f -v ${OPENCMS_HOME}/WEB-INF/config/opencms-modules.xml ${OPENCMS_HOME}/WEB-INF/config/backups/opencms-modules-preinst.xml
	
	echo "Updating config files with the version from the OpenCms WAR"
	unzip -q -d ${OPENCMS_HOME} ${ARTIFACTS_FOLDER}opencms.war WEB-INF/packages/modules/*.zip WEB-INF/lib/*.jar
	for FILENAME in ${FILES[@]}
	do
		if [ -f "${OPENCMS_HOME}${FILENAME}" ]
		then
			rm -rf "${OPENCMS_HOME}${FILENAME}"
		fi
		echo "Moving file from \"${OPENCMS_HOME_INSTALL}${FILENAME}\" to \"${OPENCMS_HOME}${FILENAME}\" ..."
		mv "${OPENCMS_HOME_INSTALL}${FILENAME}" "${OPENCMS_HOME}${FILENAME}"
	done

	echo "Updating OpenCms core JARs"
	if [ -f ${OPENCMS_HOME}/WEB-INF/lib/core-libs.properties ]; then
		echo "Deleting old JARs first"
		while IFS='=' read -r key value
		do
			key=$(echo $key | tr '.' '_')
			eval ${key}=\${value}
		done < "${OPENCMS_HOME}/WEB-INF/lib/core-libs.properties"

		IFS=',' read -r -a CORE_LIBS <<< "$OPENCMS_CORE_LIBS"
		for CORE_LIB in ${CORE_LIBS[@]}
		do
			rm -f -v ${OPENCMS_HOME}/${CORE_LIB}
		done
	fi
	echo "Moving new JARs"
	mv ${ARTIFACTS_FOLDER}libs/* ${OPENCMS_HOME}/WEB-INF/lib/

	echo "Update modules core"
	bash /root/execute-opencms-shell.sh /config/update-core-modules.ocsh ${OPENCMS_HOME}
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
	mv ${ARTIFACTS_FOLDER}libs/core-libs.properties ${OPENCMS_HOME}/WEB-INF/lib
	if [ ! -z "$ADMIN_PASSWD" ]; then
		echo "Changing Admin password for setup"
		sed -i -- "s/login \"Admin\" \"admin\"/login \"Admin\" \"admin\"\nsetPassword \"Admin\" \"$ADMIN_PASSWD\"\nlogin \"Admin\" \"$ADMIN_PASSWD\"/g" "${OPENCMS_HOME}/WEB-INF/setupdata/cmssetup.txt"
	fi
	echo "Install OpenCms using org.opencms.setup.CmsAutoSetup with properties \"${CONFIG_FILE}\"" && \
	java -classpath "${OPENCMS_HOME}/WEB-INF/lib/*:${OPENCMS_HOME}/WEB-INF/classes:${TOMCAT_LIB}/*" org.opencms.setup.CmsAutoSetup -path ${CONFIG_FILE}

	echo "Deleting no longer  used files"
	rm -rf ${OPENCMS_HOME}/setup
	rm -rf ${OPENCMS_HOME}/WEB-INF/packages/modules/*.zip
fi

echo "Deleting artifacts folder"
rm -rf ${ARTIFACTS_FOLDER}
rm -rf ${OPENCMS_HOME}/setup