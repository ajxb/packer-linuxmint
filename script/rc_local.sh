#!/bin/bash -eux

echo "==> Reinstating default rc.local file"

mv -f /etc/rc.local.orig /etc/rc.local
