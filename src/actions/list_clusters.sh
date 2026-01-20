# list clusters
list_clusters() {
  LISTFIELDS_VALUE="${LISTFIELDS:-NAME,VERSION,PLATFORM,STATUS,ADMINPWD,CONSOLE}"
  verbose "Listing fields: ${LISTFIELDS_VALUE}"

  IFS=',' read -ra list_fields <<< "${LISTFIELDS_VALUE}"
  for i in "${!list_fields[@]}"; do
    list_fields[$i]=$(echo "${list_fields[$i]}" | tr '[:lower:]' '[:upper:]')
  done
  header=""
  for field in "${list_fields[@]}"; do
    header="${header:+${header};}${field}"
  done
  echo "${header}" > /tmp/list.$$

  for cluster in $(ls ${__clustersdir} );do
    clusterdir=${__clustersdir}/${cluster}

    APISERVER="https://api.${cluster}:6443"
    CONSOLE="https://console-openshift-console.apps.${cluster}"
    PLATFORM=$((cut -d, -f4 ${clusterdir}/metadata.json 2> /dev/null || echo "Unknown") |cut -d: -f1 |sed s/"[{,},\"]"//g)
    if [[ -z "${PLATFORM}" || "${PLATFORM}" == "Unknown" ]]; then
      PLATFORM=$(awk '
        $0 == "platform:" {
          if (getline) {
            gsub(/^[[:space:]]+/, "", $0)
            gsub(/:$/, "", $0)
            print $0
          }
          exit
        }
      ' ${clusterdir}/install-config.yaml.orig 2> /dev/null || echo "Unknown")
    fi
    NAME=$((cut -d, -f1 ${clusterdir}/metadata.json 2> /dev/null || echo "Unknown") |cut -d: -f2 |sed s/"[{,},\"]"//g)
    if [[ -z "${NAME}" || "${NAME}" == "Unknown" ]]; then
      NAME=$(awk '
        $1 == "metadata:" { in_metadata=1; next }
        in_metadata && $1 == "name:" { print $2; exit }
        in_metadata && $1 ~ /^[^ ]/ { exit }
      ' ${clusterdir}/install-config.yaml.orig 2> /dev/null || echo "Unknown")
    fi
    ADMINPWD=$(cat ${clusterdir}/auth/kubeadmin-password 2> /dev/null || echo "Unknown" )
    STATUS=$(curl -m 5 -k ${APISERVER}/healthz 2> /dev/null || echo "Unhealthy")
    VERSION=$(grep -Po '(?<=OpenShift Installer )[v0-9.]*' ${clusterdir}/.openshift_install.log 2>/dev/null| head -n 1 | tr -d v)
    row=""
    for field in "${list_fields[@]}"; do
      if [[ "${field}" =~ ^[A-Z_][A-Z0-9_]*$ ]]; then
        value="${!field}"
      else
        value=""
      fi
      row="${row:+${row};}${value}"
    done
    echo "${row}" >> /tmp/list.$$
  done
  if [[ ${LISTFORMAT} == "csv" ]]; then
    cat /tmp/list.$$
  else
    column -t -s ';' /tmp/list.$$
  fi
  rm -fr /tmp/list.$$
}

