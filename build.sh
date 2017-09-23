#!/bin/bash

# Prompt for box to build if not supplied on the command line
if [[ "$#" -eq 0 ]]; then
  echo "Select a basebox to build:"
  . ./select-basebox.sh
else
  BOX=$1
fi

START_TIME=$(date +"%s")

# Remove output_virtualbox-iso if it exists,
# prevents packer failing on box generation
if [[ -d output-virtualbox-iso ]]; then
  echo "output-virtualbox-iso already exists, removing"
  rm -fr output-virtualbox-iso
fi

echo "Building ${BOX}"

# Build the VM
packer build -var-file=${BOX}.json core_template.json

END_TIME=$(date +"%s")
TIME_TAKEN=$((${END_TIME}-${START_TIME}))

echo "$((${TIME_TAKEN} / 60)) minutes and $((${TIME_TAKEN} % 60)) seconds elapsed."
