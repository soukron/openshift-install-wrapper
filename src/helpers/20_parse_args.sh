# parse a string to export variables defined on it
parse_args_as_variables() {
  if [[ ${1} == *"="* ]]; then
    IFS=':' read -r -a args <<< $( echo "${1}" | cut -d= -f2- )
    for index in "${!args[@]}"; do
      export ${args[$index]%%=*}=${args[$index]##*=}
    done
  fi
}

# load a file containing INSTALLOPTS definitions
load_installopts_env_file() {
  [[ -n ${INSTALLOPTS_ENV_FILE} ]] || return 0
  [[ -f ${INSTALLOPTS_ENV_FILE} ]] || die "Error: INSTALLOPTS_ENV_FILE not found: ${INSTALLOPTS_ENV_FILE}"

  source "${INSTALLOPTS_ENV_FILE}"
  local installopts_dump
  installopts_dump="$(bash -c 'source "$1"; declare -p INSTALLOPTS 2>/dev/null' bash "${INSTALLOPTS_ENV_FILE}" || true)"
  if [[ -n ${installopts_dump} ]]; then
    eval "${installopts_dump/declare -A/declare -g -A}"
  fi
}
