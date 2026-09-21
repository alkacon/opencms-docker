#!/bin/bash

# Select an optional local WAR variant before falling back to the published distribution.
LOCAL_OPENCMS_WAR="${ARTIFACTS_FOLDER}${OPENCMS_WAR_FILE:-opencms.war}"
if [ -s "${LOCAL_OPENCMS_WAR}" ] && [ "${LOCAL_OPENCMS_WAR}" != "${ARTIFACTS_FOLDER}opencms.war" ]; then
	cp "${LOCAL_OPENCMS_WAR}" "${ARTIFACTS_FOLDER}opencms.war"
fi

# Check if a file opencms.war is not available, if so download from the web 
if [ ! -s ${ARTIFACTS_FOLDER}opencms.war ] 
then

	if [ ! -s ${ARTIFACTS_FOLDER}opencms.zip ]
	then
		if [ ! -d ${ARTIFACTS_FOLDER} ]; then
			mkdir -v -p ${ARTIFACTS_FOLDER}
		fi
		echo "Downloading OpenCms from '$OPENCMS_URL'"
		wget -nv $OPENCMS_URL -O ${ARTIFACTS_FOLDER}opencms.zip
		echo "Download complete, unpacking war"
	fi

	if [ -s ${ARTIFACTS_FOLDER}opencms.zip ]
	then
		unzip -q ${ARTIFACTS_FOLDER}opencms.zip opencms.war -d $ARTIFACTS_FOLDER
		echo "Unziped WAR file"
		rm -fv ${ARTIFACTS_FOLDER}opencms.zip
		ls -la ${ARTIFACTS_FOLDER}
	else 
		exit 1
	fi
else
	echo "Using local WAR file"
fi 
 
