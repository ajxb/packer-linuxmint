#!/bin/bash -eu

if [[ "${DEBUG:=false}" = 'true' ]]; then
  set -x
fi

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
  if [[ $# -lt 2 ]]; then
    usage
    exit 0
  fi

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
