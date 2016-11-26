# Using rsync to keep containers synchronized with local files

## The problem

When using the Docker Toolbox on OS X (or macOS), it is possible to share local directories with Docker containers running on the VirtualBox Docker VM. **However, any changes made to files in those shared directories _are not seen_ by the containers.** One must reboot the Docker VM to clear cached _inode_ information so the containers can see the updated files.

_Note:_ The root cause of this problem is that VirtualBox does not propogate _inotify_ events from the Mac through to the Docker VM (or any Linux VM).

## The solution

**It is possible to work around this problem, and this repository gives two examples of how to do that using `rsync`.** The workaround involves using a directory on the Docker VM, a directory that is not part of any VirtualBox _share_. The local files are transferred to that VM directory and are then mapped directly to a transient data volume for a container or are copied to a data volume container that is used by other containers.

## Practical examples

The `sync-to-host-mapped-dv` example is for containers that need access to the latest version of a local directory (e.g. a source code directory) using a data volume mapped to a host directory (using the `-v host_dir_path:container_dir_path` syntax).

The `sync-to-dv-container` example is for containers that need access to the latest version of a local directory (e.g. a source code directory) using a data volume container (using the `--volumes-from dv-sourcecode` syntax).

Both examples assume that the container will only be reading the files in the data volumes, but the example could easily be extended to support pulling changes back from the container to the local directory on the Mac.

In both examples the `run.sh` script propogates the local files to the Docker VM and starts the container that will do work on the synchronized files. The `refresh.sh` script propogates any local file changes to the data volumes already attached to the running container.

The scripts assume that the Docker environment variables are configured properly.

### Supporting containers

The examples and example synchronization scripts use some containers. The Dockerfiles used to create those containers are found in the `docker-images` folder.
