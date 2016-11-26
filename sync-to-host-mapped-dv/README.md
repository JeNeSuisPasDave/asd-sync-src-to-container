# Example: syncing local files with transient data volume

_(Built for OS X or macOS; tested on OS X 10.11.6)_

This example shows how to synchronize files in a local directory (on the Mac) with files in a transient data volume (one mapped to a host directory).

The script `run.sh` will populate an intermediate directory on the Docker VM host with a copy of the local files and then launch the container actually doing work with those files. (Note: the intermediate directory should be outside of any VirtualBox _share_.)

The script `refresh.sh` will propogate changes from the local files to the intermediate directory (and those changes will be visible to the running "work" container launched by `run.sh`).

This sychronization mechanism works by using `rsync` to copy a directory from the Mac to the Docker VM.

Both scripts will, if necessary, create the intermediate directory on the Docker VM.

**Note:** Although it can be expedient to used host-mapped data volumes, it is safer to use data volume containers---because data volume containers provide an anti-corruption mechanism that prevents a misbehaving container from modifying host files in unexpected ways.
