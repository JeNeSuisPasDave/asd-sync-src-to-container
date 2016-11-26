# Example: syncing local files with data volume container

_(Built for OS X or macOS; tested on OS X 10.11.6)_

This example shows how to synchronize files in a local directory (on the Mac) with files in a data volume container.

The script `run.sh` will populate the data volume container with a copy of the local files and then launch the container actually doing work with those files. (Note: the intermediate directory should be outside of any VirtualBox _share_.)

The script `refresh.sh` will propogate changes from the local files to the data volume container (and those changes will be visible to the running "work" container launched by `run.sh`).

This sychronization mechanism works by using `rsync` to copy a directory from the Mac to the Docker VM and then using `rsync` again to copy the directory from the Docker VM to the data volume container.

Both scripts will, if necessary, create the intermediate directory on the Docker VM and create the data volume container.
