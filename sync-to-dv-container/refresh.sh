#! /bin/sh
#

# function data_volume_exists()
#
# Checks whether the source data volume container exists.
#
# Args:
#   1: data volume container name (e.g. "dv-example-src")
#
# Return code is 0 if it exists; otherwise, 1 or, if errors, 2.
#
function data_volume_exists() {
  if (( 1 != $#)); then
    local msg_="ERROR: expecting one and only one argument for"
    msg_="${msg_} data_volume_exists()."
    echo "${msg_}" > /dev/stderr
    return 2
  fi
  local lcs_=( $( docker ps -aq -f name=$1 | wc -l ) )
  local lc_=${lcs_[0]}
  if (( 0 == lc_ )); then
    return 1
  fi
  return 0
}

# function data_volume_exists()
#
# Checks whether the source data volume container exists.
#
# Args:
#   1: image tag (e.g. "datihein/rsync-alpine:latest")
#   2: data volume container name (e.g. "dv-example-src")
#   3: Data volume target directory path (e.g. "/")
#
# Return code is 0 if it exists; otherwise, 1 or, if errors, 2.
#
function create_data_volume_container() {
  if (( 3 != $#)); then
    local msg_="ERROR: expecting three arguments for"
    msg_="${msg_} create_data_volume_container()."
    echo "${msg_}" > /dev/stderr
    return 2
  fi
  local img_="$1"
  local dvname_="$2"
  local tgtdir_="$3"
  docker create -v "${tgtdir_}" --name "${dvname_}" \
    "${img_}" \
    /bin/true
}

# function docker_host_workdir_exists()
#
# Checks whether the Docker VM working directory exists.
#
# Args:
#   1: Docker machine name (e.g. "default")
#   2: Host working directory (e.g. "/xyzzy")
#
# Exit code is 0 if it exists; otherwise, 2 or, if errors, 2.
#
function docker_host_workdir_exists() {
  if (( 2 != $#)); then
    local msg_="ERROR: expecting two arguments for"
    msg_="${msg_} docker_host_workdir_exists()."
    echo "${msg_}" > /dev/stderr
    return 2
  fi
  local dm_="$1"
  local workdir_="$2"
  local cmd_="/bin/sh -c 'if [ -d \"${workdir_}\" ]; "
  cmd_="${cmd_}then echo \"yep\"; else echo \"nope\"; fi'"
  local result_=$( docker-machine ssh ${dm_} ${cmd_} )
  if [ "yep" == "${result_}" ]; then
    return 0
  fi
  return 1
}

# function docker_host_create_workdir()
#
# Args:
#   1: Docker machine name (e.g. "default")
#   2: Host working directory (e.g. "/xyzzy")
#
# Creates the Docker VM working directory
#
function docker_host_create_workdir() {
  if (( 2 != $#)); then
    local msg_="ERROR: expecting two arguments for"
    msg_="${msg_} docker_host_create_workdir()."
    echo "${msg_}" > /dev/stderr
    return 2
  fi
  local dm_="$1"
  local workdir_="$2"
  local cmd_="/bin/sh -c 'sudo mkdir \"${HOST_WK_DIR_}\"; "
  cmd_="${cmd_} sudo chown docker:staff \"${HOST_WK_DIR_}\"'"
  docker-machine ssh ${DKR_MACHINE_} ${cmd_}
  local rc_=$?
  return $rc_
}

# function rsync_src_to_workdir()
#
# Args:
#   1: Docker machine name (e.g. "default")
#   2: Docker machine IP address (e.g. "192.168.99.100")
#   3: Local source directory (e.g. "src")
#   4: Host working directory (e.g. "/xyzzy")
#
# Rsyncs the source director to the working directory
#
function rsync_src_to_workdir() {
  if (( 4 != $#)); then
    local msg_="ERROR: expecting four arguments for"
    msg_="${msg_} rsync_src_to_workdir()."
    echo "${msg_}" > /dev/stderr
    return 2
  fi
  local dm_="$1"
  local ip_="$2"
  local srcdir_="$3"
  local workdir_="$4"
  rsync -e "ssh -i ${HOME}/.docker/machine/machines/${dm_}/id_rsa" \
    -rptv "$srcdir_" "docker@${ip_}:${workdir_}"
  local rc_=$?
  return $rc_
}

# function rsync_workdir_to_dv()
#
# Args:
#   1: Data volume container name (e.g. "dv-example-src")
#   2: Host working directory (e.g. "/xyzzy")
#   3: rsync image tag (e.g. "datihein/rsync-alpine:latest")
#   4: Host source directory path (e.g. "/xyzzy/src")
#   5: Data volume target directory path (e.g. "/")
#
# Rsyncs the source directory to the target directory
#
# Note: 'rsync -rpt "/xyzzy/src" "/"' will create a "/src" directory at the
#       target.
#
function rsync_workdir_to_dv() {
  if (( 5 != $#)); then
    local msg_="ERROR: expecting five arguments for"
    msg_="${msg_} rsync_workdir_to_dv()."
    echo "${msg_}" > /dev/stderr
    return 2
  fi
  local dvname_="$1"
  local workdir_="$2"
  local img_="$3"
  local srcdir_="$4"
  local tgtdir_="$5"
  docker run -i -t --rm  \
    --volumes-from "${dvname_}" \
    -v "${workdir_}:${workdir_}" \
    "${img_}" \
    rsync -rptv "${srcdir_}" "${tgtdir_}"
  local rc_=$?
  echo "rsync to dv rc: $rc_"
  return $rc_
}

# main
#

# initialization
#
SRC_DV_NAME_="dv-example-src"
RSYNC_IMAGE_NAME_="datihein/rsync-alpine"
DKR_IMAGE_NAME_="datihein/python3.5.2-flask-nginx-alpine"
HOST_WK_DIR_="/xyzzy"
SRC_DIR_="src"
DKR_MACHINE_="dev-dkr"
IP_=$( docker-machine ip ${DKR_MACHINE_} )

# Create the Docker VM working directory if necessary
#
docker_host_workdir_exists "${DKR_MACHINE_}" "${HOST_WK_DIR_}"
rc_=$?
if (( 0 != $rc_ )); then
  if (( 2 == $rc_ )); then
    exit 2
  fi
  docker_host_create_workdir "${DKR_MACHINE_}" "${HOST_WK_DIR_}"
fi

# Create the data volume container, if necessary
#
data_volume_exists "${SRC_DV_NAME_}"
rc_=$?
if (( 0 != $rc_ )); then
  if (( 2 == $rc_ )); then
    exit 2
  fi
  create_data_volume_container "${RSYNC_IMAGE_NAME_}" "${SRC_DV_NAME_}" "/src"
fi

# Update the host working directory
#
rsync_src_to_workdir "${DKR_MACHINE_}" "${IP_}" "$PWD/$SRC_DIR_" "${HOST_WK_DIR_}"

# Upate the data volume container
#
rsync_workdir_to_dv "${SRC_DV_NAME_}" "${HOST_WK_DIR_}" \
  "${RSYNC_IMAGE_NAME_}" "${HOST_WK_DIR_}/src" "/"
