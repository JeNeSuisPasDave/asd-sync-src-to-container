# Docker images

Each subfolder contains a recipe---a `Dockerfile` and `build.sh` script---that creates a Docker image that supports the directory synchronization examples:

* `sync-to-dv-container` for data volume containers. Needs both the flask and rsync container images.
* `sync-to-host-mapped-dv` for directory mapped data volumes. Needs only the flask container image.
