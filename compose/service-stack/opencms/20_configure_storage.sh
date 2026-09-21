#!/bin/bash

set -euo pipefail

properties_file="${OPENCMS_HOME}/WEB-INF/config/opencms.properties"

if [ ! -f "${properties_file}" ]; then
    echo "OpenCms properties file not found: ${properties_file}" >&2
    exit 1
fi

set_property() {
    local key="$1"
    local value="$2"
    local temporary_file
    temporary_file="$(mktemp)"

    awk -v key="${key}" -v replacement="${key}=${value}" '
        index($0, key "=") == 1 {
            if (!replaced) {
                print replacement
                replaced = 1
            }
            next
        }
        { print }
        END {
            if (!replaced) {
                print replacement
            }
        }
    ' "${properties_file}" > "${temporary_file}"

    mv "${temporary_file}" "${properties_file}"
}

set_property "setup.storage.schema.update" "auto"
set_property "storage.active" "rustfs"
set_property "storage.legacy" "db"

set_property "storage.backend.rustfs.type" "s3"
set_property "storage.backend.rustfs.endpoint" "${STORAGE_ENDPOINT}"
set_property "storage.backend.rustfs.bucket" "${STORAGE_DATA_BUCKET}"
set_property "storage.backend.rustfs.accessKey" "${STORAGE_ACCESS_KEY}"
set_property "storage.backend.rustfs.secretKey" "${STORAGE_SECRET_KEY}"
set_property "storage.backend.rustfs.pathStyle" "true"
set_property "storage.backend.rustfs.region" "us-east-1"
set_property "storage.backend.rustfs.maxConnections" "${STORAGE_MAX_CONNECTIONS}"

# Image derivatives use a separate bucket to demonstrate that data storage and image-cache
# storage are independent, even though both use the same RustFS service in this example.
set_property "storage.imagecache" "rustfsimages"
set_property "storage.backend.rustfsimages.type" "s3"
set_property "storage.backend.rustfsimages.endpoint" "${STORAGE_ENDPOINT}"
set_property "storage.backend.rustfsimages.bucket" "${STORAGE_IMAGE_BUCKET}"
set_property "storage.backend.rustfsimages.accessKey" "${STORAGE_ACCESS_KEY}"
set_property "storage.backend.rustfsimages.secretKey" "${STORAGE_SECRET_KEY}"
set_property "storage.backend.rustfsimages.pathStyle" "true"
set_property "storage.backend.rustfsimages.region" "us-east-1"
set_property "storage.backend.rustfsimages.maxConnections" "${STORAGE_MAX_CONNECTIONS}"

echo "Configured RustFS data and image-cache backends in ${properties_file}."
