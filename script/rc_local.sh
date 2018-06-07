#!/bin/bash -eux

echo '==> Reinstating default rc.local file'

if [[ -e /etc/rc.local.orig ]]; then
  echo '==> Reinstating rc.local file'
  mv -f /etc/rc.local.orig /etc/rc.local
else
  echo '==> Removing rc.local file'
  rm -f /etc/rc.local
fi
