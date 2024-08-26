# find version
get_cluster_version() {
  local clusterdir=${__clustersdir}/${INSTALLOPTS[name]}.${INSTALLOPTS[domain]}

  if [[ ! -z ${INSTALLOPTS[version]} ]]; then
    verbose "Version already defined with --version parameter to ${INSTALLOPTS[version]}. Skipping version detection..."
    return
  fi

  out "→ Finding version in cluster directory..."
  verbose "  Directory: ${clusterdir}"
  INSTALLOPTS[version]=$(grep '="OpenShift Installer ' ${clusterdir}/.openshift_install.log 2>/dev/null |head -1 |tr -d '"'|awk '{ print $(NF) }')
  success "Version detected: ${INSTALLOPTS[version]}."

  [[ -z ${INSTALLOPTS[version]} ]] && die "Error: Can't find the installer version in the directory ${clusterdir}. Aborting." || true
}

