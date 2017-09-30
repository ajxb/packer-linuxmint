#!/bin/bash -eux

echo '==> Recording box generation date'
date > /etc/vagrant_box_build_date

echo '==> Customizing message of the day'
MOTD_FILE='/etc/motd'
PLATFORM_RELEASE=$(lsb_release -sd)
PLATFORM_MSG=$(printf '%s' "${PLATFORM_RELEASE}")

rm -f "${MOTD_FILE}"
BUILT_MSG="$(printf 'built %s' "$(date +%Y-%m-%d)")"
{
  printf '%0.1s' "-"{1..64}
  printf '\n'
  printf '%2s%-30s%30s\n' " " "${PLATFORM_MSG}" "${BUILT_MSG}"
  printf '%0.1s' "-"{1..64}
  printf '\n'
} >> "${MOTD_FILE}"
