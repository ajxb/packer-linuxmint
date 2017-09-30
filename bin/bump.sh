#!/bin/bash

###############################################################################
# Script to update Packer template version and git repository
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

  subcommand=$1
  template=$2

  # Prompt for box to build if not supplied on the command line
  if [[ "$#" -eq 0 ]]; then
    echo 'Select a basebox to build:'
    select_basebox
  else
    BOX=$1
  fi
  readonly BOX
}


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

args() {
  case $subcommand in
  "" | "-h" | "--help")
    usage
    ;;
  *)
    shift
    ;;
  esac
}

current() {
  echo "Current version: ${CURRENT_VERSION}"
}

tag() {
  TAG_PREFIX="${template%.*}"
  echo "Tagged: ${TAG_PREFIX}_${CURRENT_VERSION}"
  git fetch --all > /dev/null
  git add CHANGELOG.md
  git commit -m "${TAG_PREFIX} ${CURRENT_VERSION} pushed to Vagrant Cloud"
  git tag -a -m "${TAG_PREFIX} ${CURRENT_VERSION} pushed to Vagrant Cloud" "${TAG_PREFIX}_${CURRENT_VERSION}"
  git push --tags || true
}

write_version() {
  NEXT_VERSION=${MAJOR_VERSION}.${MINOR_VERSION}.${PATCH_VERSION}
  echo "Updating ${template} version to ${NEXT_VERSION}"
  jq ".version=\"${NEXT_VERSION}\"" "${template}" > "${template}.tmp"
  mv -f "${template}.tmp" "$template"
  git fetch --all > /dev/null
  git add "${template}"
  git commit -m "Bump ${template} to ${NEXT_VERSION}"
}

major() {
  MAJOR_VERSION=$((MAJOR_VERSION+1))
  MINOR_VERSION=0
  PATCH_VERSION=0
  write_version
}

minor() {
  MAJOR_VERSION=${MAJOR_VERSION}
  MINOR_VERSION=$((MINOR_VERSION+1))
  PATCH_VERSION=0
  write_version
}

patch() {
  MAJOR_VERSION=${MAJOR_VERSION}
  MINOR_VERSION=${MINOR_VERSION}
  PATCH_VERSION=$((PATCH_VERSION+1))
  write_version
}

main() {
  # Ensure we are working in the correct folder
  pushd "${MY_PATH}/.." || exit > /dev/null

  args "$@"
  CURRENT_VERSION=$(jq -r '.version' "${template}")
  IFS="." read -r -a VERSION_LIST <<< "${CURRENT_VERSION}"
  MAJOR_VERSION=${VERSION_LIST[0]}
  MINOR_VERSION=${VERSION_LIST[1]}
  PATCH_VERSION=${VERSION_LIST[2]}
  ${subcommand}

  popd || exit > /dev/null
}

MY_PATH="$(dirname "$0")"
MY_PATH="$(cd "${MY_PATH}" && pwd)"
readonly MY_PATH

main "$@"

exit 0
