#!/usr/bin/env bash

# Allow running early init scripts as root following similar convention
# as upstream docker image

set -e

for f in /entry-init.d/*; do
  case "$f" in
    *.sh)
      if [ -x "$f" ]; then
        echo "$0: running $f"
        "$f"
      else
        echo "$0: sourcing $f"
        . "$f"
      fi
      ;;
    *)
      echo "$0: ignoring $f" ;;
  esac
  echo
done

exec "$@"
