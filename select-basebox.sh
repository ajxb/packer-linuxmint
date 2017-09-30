#!/bin/bash

# Base boxes available for build
PS3='Select machine : '
LIST="$(find . -maxdepth 1 -type f -name '*.json' -printf '%f\n' | sed 's/\.json//' | grep -v ^core_template$)"
select OPTION in ${LIST}; do
  if [[ -n "${OPTION}" ]]; then
    # shellcheck disable=SC2034
    BOX="${OPTION}"
    break
  else
    echo "Invalid basebox selected."
    exit 1
  fi
done
