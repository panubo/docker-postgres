#!/usr/bin/env bash
# Generates a postgres md5 password

set -e

if [[ "x$(uname -s)" == "xDarwin" ]]; then
  MD5=md5
else
  MD5=md5sum
fi

usage() {
  echo "${0} USER PASSWORD"
}

pg_pass() {
  USER=$1
  PASS=$2
  hash="md5$(echo -n "${PASS}${USER}" | ${MD5} | cut -d' ' -f1)"
  echo "${hash}"
}

if [[ -z "${1}" || -z "${2}" ]]; then
  usage
  exit 1
fi

pg_pass "${1}" "${2}"
