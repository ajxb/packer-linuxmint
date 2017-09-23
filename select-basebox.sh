#!/bin/bash

# Base boxes available for build
PS3="Select machine : "
LIST="$(ls *.json | sed 's/\.json//' | grep -v ^core_template$)"
select OPTION in $LIST; do
  if [[ -n "$OPTION" ]]; then
    BOX=$OPTION
    break
  else
    echo "Invalid basebox selected."
    exit 1
  fi
done
