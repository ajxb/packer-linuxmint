#!/bin/bash

###############################################################################
# Script to build a Packer template and optionally deploy it to Vagrant Cloud
#
# Globals:
#   BOX     - The name of the template to build
#   DEPLOY  - true indicates that the built artefact should be uploaded to
#             Vagrant Cloud
#   MY_CWD  - Path script was invoked from
#   MY_PATH - Path to this script
###############################################################################

###############################################################################
# Parse script input for validity and configure global variables for use
# throughout the script
# Globals:
#   BOX
#   DEPLOY
# Arguments:
#   $@
# Returns:
#   None
###############################################################################
setup_vars() {
  # Test that getopt (gnu enhanced) is installed
  getopt --test > /dev/null
  if [[ $? -ne 4 ]]; then
    echo 'getopt (gnu enhanced) needs to be installed for this script to work'
    exit 1
  fi

  # Evaluate command line options
  local options=dh
  readonly options
  local longoptions=deploy,help
  readonly longoptions

  local parsed_options
  if ! parsed_options=$(getopt --options=${options} --longoptions=${longoptions} --name "$(basename "$0")" -- "$@"); then
    echo "Failed to parse options." >&2
    usage
    exit 1
  fi
  eval set -- "${parsed_options}"

  while true; do
    case "$1" in
      -d|--deploy) readonly DEPLOY=true; shift ;;
      -h|--help)   usage; exit 0 ;;
      --)          shift; break ;;
      * )          break ;;
    esac
  done

  # Prompt for box to build if not supplied on the command line
  if [[ "$#" -eq 0 ]]; then
    echo 'Select a basebox to build:'
    select_basebox
  else
    BOX=$1
  fi
  readonly BOX
}

###############################################################################
# Output usage information for the script to the terminal
# Globals:
#   $0
# Arguments:
#   None
# Returns:
#   None
###############################################################################
usage() {
  local script_name
  script_name="$(basename "$0")"

  echo "usage: ${script_name} <options> template_file"
  echo
  echo "Build specified template_file using Packer"
  echo
  echo "OPTIONS:"
  echo '  -d|--deploy  on successful build deploy to Vagrant Cloud'
  echo "  -h|--help    show help information about ${script_name}"
}

###############################################################################
# Main body of script processing
# Globals:
#   BOX
#   DEPLOY
#   MY_CWD
#   MY_PATH
# Arguments:
#   $@
# Returns:
#   None
###############################################################################
main() {
  # Ensure we are working in the correct folder
  pushd "${MY_CWD}" || exit > /dev/null

  setup_vars "$@"

  START_TIME=$(date +"%s")

  # Remove output_virtualbox-iso if it exists,
  # prevents packer failing on box generation
  if [[ -d output-virtualbox-iso ]]; then
    echo 'output-virtualbox-iso already exists, removing'
    rm -fr output-virtualbox-iso
  fi

  # Build the VM
  if [[ "${DEPLOY}" == 'true' ]]; then
    echo "Building and deploying ${BOX}"
    packer build -var-file="${BOX}" core_template.json
  else
    echo "Building ${BOX}"
    jq '.["post-processors"][0] |= map(select(.type != "vagrant-cloud"))' core_template.json | packer build -var-file="${BOX}" -
  fi

  END_TIME=$(date +"%s")
  TIME_TAKEN=$((END_TIME - START_TIME))

  echo "$((TIME_TAKEN / 60)) minutes and $((TIME_TAKEN % 60)) seconds elapsed."

  popd || exit > /dev/null
}

MY_CWD="$(pwd)"
readonly MY_CWD
MY_PATH="$(dirname "$0")"
MY_PATH="$(cd "${MY_PATH}" && pwd)"
readonly MY_PATH

# shellcheck source=/dev/null
source "${MY_PATH}/select_basebox.sh"

main "$@"

exit 0
