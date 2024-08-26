# customize a cluster based on a list of scripts
customize_cluster() {
  local clusterdir=${__clustersdir}/${INSTALLOPTS[name]}.${INSTALLOPTS[domain]}
  local client=${__bindir}/oc-${INSTALLOPTS[version]}

  for script in $( echo ${SCRIPTS} | tr -s "," " " ); do
    cmd=${script%%=*}
    type ${cmd} &>/dev/null && out "→ Running ${cmd} customization..." || die "${cmd} not found."
    ${cmd} ${script} ${clusterdir} ${client} ${VERBOSE} ${QUIET} ${INSTALLOPTS[*]}
  done
}

