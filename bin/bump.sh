#!/bin/bash

###############################################################################
# Script to update Packer template version and git repository
#
# Globals:
#   BOX             - The name of the template to update the version number on
#   CURRENT_VERSION - The current version as read from the given template
#   MAJOR_VERSION   - The major version derived from the CURRENT_VERSION
#   MINOR_VERSION   - The minor version derived from the CURRENT_VERSION
#   MY_CWD          - Path script was invoked from
#   MY_PATH         - Path to this script
#   PATCH_VERSION   - The patch version derived from the CURRENT_VERSION
#   SUBCOMMAND      - The subcommand to execute for the given template
#   TEMPLATE        - The name of the template to use for the command
###############################################################################

###############################################################################
# Parse script input for validity and configure global variables for use
# throughout the script
# Globals:
#   BOX
#   SUBCOMMAND
#   TEMPLATE
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
      --)        shift; break ;;
      * )        break ;;
    esac
  done

  # Check to make sure all args are present
  if [[ $# -lt 1 ]]; then
    usage
    exit 0
  fi

  # Check to see if the first arg is a recognised command
  if [[ ! $1 =~ ^(current|major|minor|patch|tag)$ ]]; then
    usage
    exit 1
  fi

  if [[ ! -f $2 ]]; then
    usage
    exit 1
  fi

  SUBCOMMAND=$1
  TEMPLATE=$2

  # Prompt for template to update if not supplied on the command line
  if [[ "$#" -eq 0 ]]; then
    echo 'Select a basebox for version bump:'
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
  echo "usage: $(basename "$0") <subcommand> template"
  echo
  echo "Available subcommands are:"
  echo "  current    Print current version"
  echo "  major      Bump major version (ex: 1.2.1 -> 2.0.0)"
  echo "  minor      Bump minor version (ex: 1.2.1 -> 1.3.0)"
  echo "  patch      Bump patch version (ex: 1.2.1 -> 1.2.2)"
  echo "  tag        Tag in Git using current version"
}

###############################################################################
# Output the current version of the box template
# Globals:
#   CURRENT_VERSION
# Arguments:
#   None
# Returns:
#   None
###############################################################################
current() {
  echo "Current version: ${CURRENT_VERSION}"
}

###############################################################################
# Tag the repo with the current version of the template, in the format :
#   $TAG_PREFIX_$CURRENT_VERSION
# Where the TAG_PREFIX is the name of the template and the version is the
# version number contained within. E.g. mint-cinnamon-18.2_1.0.0
# Globals:
#   CURRENT_VERSION
#   TEMPLATE
# Arguments:
#   None
# Returns:
#   None
###############################################################################
tag() {
  local tag_prefix
  tag_prefix="${TEMPLATE%.*}"
  readonly tag_prefix

  echo "Tagged: ${tag_prefix}_${CURRENT_VERSION}"
  git fetch --all > /dev/null
  git add CHANGELOG.md
  git commit -m "${tag_prefix} ${CURRENT_VERSION} pushed to Vagrant Cloud"
  git tag -a -m "${tag_prefix} ${CURRENT_VERSION} pushed to Vagrant Cloud" "${tag_prefix}_${CURRENT_VERSION}"
}

###############################################################################
# Commit version number changes to repo
# Globals:
#   MAJOR_VERSION
#   MINOR_VERSION
#   PATCH_VERSION
#   TEMPLATE
# Arguments:
#   None
# Returns:
#   None
###############################################################################
write_version() {
  local next_version
  next_version=${MAJOR_VERSION}.${MINOR_VERSION}.${PATCH_VERSION}
  readonly next_version

  echo "Updating ${TEMPLATE} version to ${next_version}"
  jq ".version=\"${next_version}\"" "${TEMPLATE}" > "${TEMPLATE}.tmp"
  mv -f "${TEMPLATE}.tmp" "${TEMPLATE}"
  git fetch --all > /dev/null
  git add "${TEMPLATE}"
  git commit -m "Bump ${TEMPLATE} to ${next_version}"
}

###############################################################################
# Update the major version
# Globals:
#   MAJOR_VERSION
#   MINOR_VERSION
#   PATCH_VERSION
# Arguments:
#   None
# Returns:
#   None
###############################################################################
major() {
  MAJOR_VERSION=$((MAJOR_VERSION+1))
  MINOR_VERSION=0
  PATCH_VERSION=0
  write_version
}

###############################################################################
# Update the minor version
# Globals:
#   MAJOR_VERSION
#   MINOR_VERSION
#   PATCH_VERSION
# Arguments:
#   None
# Returns:
#   None
###############################################################################
minor() {
  MAJOR_VERSION=${MAJOR_VERSION}
  MINOR_VERSION=$((MINOR_VERSION+1))
  PATCH_VERSION=0
  write_version
}

###############################################################################
# Update the patch version
# Globals:
#   MAJOR_VERSION
#   MINOR_VERSION
#   PATCH_VERSION
# Arguments:
#   None
# Returns:
#   None
###############################################################################
patch() {
  MAJOR_VERSION=${MAJOR_VERSION}
  MINOR_VERSION=${MINOR_VERSION}
  PATCH_VERSION=$((PATCH_VERSION+1))
  write_version
}

###############################################################################
# Main body of script processing
# Globals:
#   CURRENT_VERSION
#   MAJOR_VERSION
#   MINOR_VERSION
#   MY_CWD
#   MY_PATH
#   PATCH_VERSION
#   SUBCOMMAND
# Arguments:
#   $@
# Returns:
#   None
###############################################################################
main() {
  # Ensure we are working in the correct folder
  pushd "${MY_CWD}" || exit > /dev/null

  setup_vars "$@"
  CURRENT_VERSION=$(jq -r '.version' "${TEMPLATE}")
  local version_list
  IFS="." read -r -a version_list <<< "${CURRENT_VERSION}"
  MAJOR_VERSION=${version_list[0]}
  MINOR_VERSION=${version_list[1]}
  PATCH_VERSION=${version_list[2]}
  ${SUBCOMMAND}

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
