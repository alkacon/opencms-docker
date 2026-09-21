ARG OPENCMS_IMAGE=alkacon/opencms-docker:22.0
ARG SOLR_VERSION=10.0.0

FROM ${OPENCMS_IMAGE} AS opencms-configset

RUN set -eu; \
    mkdir -p /opt; \
    unzip -q /artifacts/opencms.war 'WEB-INF/solr/configsets/default/*' -d /tmp/opencms; \
    mv /tmp/opencms/WEB-INF/solr/configsets/default /opt/opencms-configset

FROM solr:${SOLR_VERSION}

ARG SOLR_VERSION

USER root

# Extract the matching OpenCms ConfigSet from the WAR bundled with the official OpenCms image.
COPY --from=opencms-configset /opt/opencms-configset /opt/opencms-configset
COPY 10-create-opencms-cores.sh /docker-entrypoint-initdb.d/10-create-opencms-cores.sh

RUN set -eu; \
    chown -R "${SOLR_USER}:${SOLR_USER}" /opt/opencms-configset; \
    chmod 0755 /docker-entrypoint-initdb.d/10-create-opencms-cores.sh; \
    { \
        printf 'solr=%s\n' "${SOLR_VERSION}"; \
        find /opt/opencms-configset -type f -print0 \
            | sort -z \
            | xargs -0 sha256sum; \
    } | sha256sum | awk '{print $1}' > /opt/opencms-configset.sha256; \
    chown "${SOLR_USER}:${SOLR_USER}" /opt/opencms-configset.sha256

USER ${SOLR_USER}
