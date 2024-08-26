# destroy cluster
destroy_cluster() {
  local clusterdir=${__clustersdir}/${INSTALLOPTS[name]}.${INSTALLOPTS[domain]}
  local installer=${__bindir}/openshift-install-${INSTALLOPTS[version]}

  if [[ ${DRY_RUN} -eq 1 ]]; then
    out "→ Dry-run execution detected. Exiting..."
    exit
  fi

  out "→ Running \"openshift-install\" to destroy a cluster..."
  verbose "  Command: \"${installer} destroy cluster --dir=${clusterdir}\""
  if [[ ${VERBOSE} -eq 1 ]]; then
    ${installer} destroy cluster --dir=${clusterdir}
  else
    ${installer} destroy cluster --dir=${clusterdir} &> ${clusterdir}/.openshift_install_wrapper.log
  fi
  success "Cluster destroyed!"

  out "→ Removing directory..."
  verbose "  Directory: ${clusterdir}"
  rm -fr ${clusterdir}
}

