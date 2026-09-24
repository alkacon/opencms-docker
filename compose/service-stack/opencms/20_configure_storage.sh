#!/bin/bash

set -euo pipefail

properties_file="${OPENCMS_HOME}/WEB-INF/config/opencms.properties"

if [ ! -f "${properties_file}" ]; then
    echo "OpenCms properties file not found: ${properties_file}" >&2
    exit 1
fi

if [ "${STORAGE_DATA_BUCKET}" = "${STORAGE_IMAGE_BUCKET}" ]; then
    echo "STORAGE_IMAGE_BUCKET must differ from STORAGE_DATA_BUCKET; the image cache requires a dedicated bucket." >&2
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

# The image cache is configured directly and requires its own bucket.
# Both buckets use the same RustFS service in this example.
set_property "storage.imagecache.type" "s3"
set_property "storage.imagecache.endpoint" "${STORAGE_ENDPOINT}"
set_property "storage.imagecache.bucket" "${STORAGE_IMAGE_BUCKET}"
set_property "storage.imagecache.accessKey" "${STORAGE_ACCESS_KEY}"
set_property "storage.imagecache.secretKey" "${STORAGE_SECRET_KEY}"
set_property "storage.imagecache.pathStyle" "true"
set_property "storage.imagecache.region" "us-east-1"
set_property "storage.imagecache.maxConnections" "${STORAGE_MAX_CONNECTIONS}"

echo "Configured RustFS data and image-cache backends in ${properties_file}."
