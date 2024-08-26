# oc helper to run commands in a cluster
oc() {
  if [[ ${VERBOSE} -eq 1 ]]; then
    ${client} --kubeconfig ${clusterdir}/auth/kubeconfig "$@" -v=6
  else
    if [[ ${QUIET} -eq 1 ]]; then
      ${client} --kubeconfig ${clusterdir}/auth/kubeconfig "$@" &>/dev/null
    else
      ${client} --kubeconfig ${clusterdir}/auth/kubeconfig "$@"
    fi
  fi
}

