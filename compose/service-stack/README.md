# OpenCms service-stack demo

This Docker Compose showcase demonstrates a service-oriented deployment with S3-compatible media storage, cache-accelerated content delivery and standalone search services.

This demo requires OpenCms 22.0 or newer.

> **This is a technical showcase, not a production-ready deployment.** It uses demo credentials,
> floating container tags, plain HTTP, a single instance of every service and no backup,
> monitoring, high-availability or hardened network configuration. Do not expose it to an
> untrusted network without adapting it.

## Architecture

```text
                                      +--> MariaDB
Browser --> NGINX --> OpenCms --------+--> Solr
              |                       +--> RustFS (data)
              |                       +--> RustFS (imagecache)
              |
              +--> disk-backed media cache
```

## Starting the demo

From this directory, run:

```bash
docker compose up -d --build
docker compose logs -f opencms solr nginx rustfs-init
```

The initial OpenCms setup and module import can take several minutes. Afterwards, the services are
available at:

| Service | URL |
| --- | --- |
| OpenCms through NGINX | <http://localhost/> |
| OpenCms direct, bypassing NGINX | <http://localhost:8080/> |
| Solr administration (local diagnostics only) | <http://localhost:8983/> |
| RustFS S3 API | <http://localhost:9000/> |
| RustFS console | <http://localhost:9001/> |

The default OpenCms login is `Admin` / `admin`. The RustFS console uses `opencms` /
`opencms-demo-secret`.

To test Workplace and the demo website with independent sessions, use these loopback subdomains:

| Use | URL |
| --- | --- |
| Workplace session | <http://workplace.localhost/workplace> |
| Demo website session | <http://demo.localhost/mercury-demo/> |


## Configuration details

The scripts in [`opencms`](opencms) apply the service-stack-specific OpenCms configuration.

### RustFS data storage

[`20_configure_storage.sh`](opencms/20_configure_storage.sh) configures RustFS as the active backend
for binary VFS data. By default, binary and image resources are stored in the `opencms-data` bucket.

[`opencms-vfs_storage.xslt`](opencms/opencms-vfs_storage.xslt) installs the corresponding storage
policy. The demo externalizes every non-empty binary and image resource.

### Shared-cache delivery

[`opencms-importexport_storage.xslt`](opencms/opencms-importexport_storage.xslt) disables
stored-content delivery from local files and enables shared-cache delivery. Resources retain their
regular `/export/` URLs, while OpenCms delivers them dynamically and provides HTTP cache information
such as `Cache-Control`, `ETag` and `Last-Modified`.

### External Solr

[`opencms-search_external-solr.xslt`](opencms/opencms-search_external-solr.xslt) points OpenCms to
the standalone Solr service configured through `SOLR_URL`. The Online and Offline indexes are stored
in the `solr-data` volume; OpenCms does not maintain internal indexes below `WEB-INF/index` in this
setup.

### Image-cache storage

[`20_configure_storage.sh`](opencms/20_configure_storage.sh) stores generated image derivatives in
the separate `opencms-imagecache` RustFS bucket. OpenCms does not maintain image derivatives below
`WEB-INF/imagecache` in this setup. 

[`opencms-system_imagecache.xslt`](opencms/opencms-system_imagecache.xslt) configures a fixed
60-day retention period for these derivatives.

### Environment variables

| Environment variable | Default |
| --- | --- |
| `SOLR_URL` | `http://solr:8983/solr` |
| `STORAGE_ENDPOINT` | `http://rustfs:9000` |
| `STORAGE_ACCESS_KEY` | `opencms` |
| `STORAGE_SECRET_KEY` | `opencms-demo-secret` |
| `STORAGE_DATA_BUCKET` | `opencms-data` |
| `STORAGE_IMAGE_BUCKET` | `opencms-imagecache` |
| `STORAGE_THRESHOLD` | `0` |
| `STORAGE_MAX_CONNECTIONS` | `50` |

## Removing the example

To stop and remove all demo containers while keeping all five named volumes, use this command.

```bash
docker compose down
```

To delete the database, installed OpenCms web application, RustFS objects, Solr indexes and NGINX
cache as well, use the destructive command only when that data is no longer needed:

```bash
docker compose down --volumes
```
