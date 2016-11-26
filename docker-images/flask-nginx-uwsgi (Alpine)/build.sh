#! /bin/bash
#

function do_it() {
  docker build \
    --tag datihein/python3.5.2-flask-nginx-alpine:latest .
}

mkdir tmp
cp ../tmp/python-3.5.2.* tmp
cp ../tmp/python3-gpg.key tmp
cp ../tmp/nginx-1.11.5.* tmp
cp ../tmp/nginx-gpg.key tmp
cp ../tmp/gpg-trust.sh tmp

ls tmp

do_it
rc_=$?

rm -r tmp
exit $rc_
