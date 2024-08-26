# parse a string to export variables defined on it
parse_args_as_variables() {
  if [[ ${1} == *"="* ]]; then
    IFS=':' read -r -a args <<< $( echo "${1}" | cut -d= -f2- )
    for index in "${!args[@]}"; do
      export ${args[$index]%%=*}=${args[$index]##*=}
    done
  fi
}

