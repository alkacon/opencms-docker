#!/bin/bash

set -euo pipefail

readonly configset_dir="/opt/opencms-configset"
readonly image_fingerprint="/opt/opencms-configset.sha256"
readonly volume_fingerprint="/var/solr/opencms-configset.sha256"

if [[ -f "${volume_fingerprint}" ]] && ! cmp -s "${image_fingerprint}" "${volume_fingerprint}"; then
    echo "The persisted Solr cores were created with a different OpenCms ConfigSet or Solr version." >&2
    echo "Remove the Solr volume and rebuild both OpenCms search indexes before starting this image." >&2
    exit 1
fi

precreate-core Solr-Online "${configset_dir}"
precreate-core Solr-Offline "${configset_dir}"

install -m 0644 "${image_fingerprint}" "${volume_fingerprint}"
