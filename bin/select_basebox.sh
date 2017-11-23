###############################################################################
# List available Packer templates and allow the user to select one
# Globals:
#   BOX     - The name of the template selected
#   MY_CWD  - Path script was invoked from
# Arguments:
#   None
# Returns:
#   None
###############################################################################
select_basebox() {
  # Base boxes available for build
  PS3='Select machine : '
  local readonly list="$(find ${MY_CWD} -maxdepth 1 -type f -name '*.json' -printf '%f\n' | grep -v ^core_template.json$)"
  local option
  select option in ${list}; do
    if [[ -n "${option}" ]]; then
      # shellcheck disable=SC2034
      BOX="${option}"
      break
    else
      echo "Invalid basebox selected."
      exit 1
    fi
  done
}
