#! /bin/bash
#

function do_it() {
  docker build \
    --tag datihein/rsync-alpine:latest .
}

do_it
rc_=$?

rm -r tmp
exit $rc_
