# create cluster
create_cluster() {
  local clusterdir=${__clustersdir}/${INSTALLOPTS[name]}.${INSTALLOPTS[domain]}
  local installer=${__bindir}/openshift-install-${INSTALLOPTS[version]}

  if [[ ${DRY_RUN} -eq 1 ]]; then
    out "→ Dry-run execution detected. Exiting..."
    exit
  fi

  verbose "  Saving a copy of install-config.yaml file."
  cp ${clusterdir}/install-config.yaml ${clusterdir}/install-config.yaml.orig

  if [[ ${EDIT_INSTALL_MANIFESTS} -eq 1 ]]; then
    out "→ Running \"openshift-install\" to create manifests..."
    ${installer} create manifests --dir=${clusterdir}
    success "Manifests created!"
    out "→ Stopping openshift-install-wrapper so you can edit the manifests."
    out "  Manifests have been created at: ${clusterdir}"
    out "  When done, resume openshift-install-wrapper with \"fg\""
    (kill -STOP $$)
    out "→ Resuming openshift-install-wrapper"
  fi

  out "→ Running \"openshift-install\" to create a cluster..."
  verbose "  Command: \"${installer} create cluster --dir=${clusterdir}\""
  if [[ ${VERBOSE} -eq 1 ]]; then
    ${installer} create cluster --dir=${clusterdir}
    success "Cluster created!"
  else
    ${installer} create cluster --dir=${clusterdir} &> ${clusterdir}/.openshift_install_wrapper.log
    success "Cluster created!"
    tail -n 3 ${clusterdir}/.openshift_install_wrapper.log | cut -d \" -f 2- | tr -d "\"$"
  fi
}

