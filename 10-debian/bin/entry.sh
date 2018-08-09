#!/usr/bin/env bash

set -e

# Allow running init scripts as root following same convention
# as upstream docker image
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
