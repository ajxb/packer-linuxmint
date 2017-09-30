#!/bin/bash

###############################################################################
# Script to validate a Packer template
#
# Globals:
#   BOX     - The name of the template to validate
#   MY_CWD  - Path script was invoked from
#   MY_PATH - Path to this script
###############################################################################

###############################################################################
# Parse script input for validity and configure global variables for use
# throughout the script
# Globals:
#   BOX
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
  local options=h
  readonly options
  local longoptions=help
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
      -h|--help) usage; exit 0 ;;
      --)          shift; break ;;
      * )          break ;;
    esac
  done

  # Prompt for box to validate if not supplied on the command line
  if [[ "$#" -eq 0 ]]; then
    echo 'Select a basebox definition to validate:'
    # shellcheck disable=SC1091
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
  echo "Validate specified template_file using Packer"
  echo
  echo "OPTIONS:"
  echo "  -h|--help    show help information about ${script_name}"
}

###############################################################################
# Main body of script processing
# Globals:
#   BOX
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

  echo "Validating ${BOX}"
  packer validate -var-file="${BOX}" core_template.json

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
