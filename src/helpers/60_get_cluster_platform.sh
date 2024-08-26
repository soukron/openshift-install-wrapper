# find platform
get_cluster_platform() {
  local clusterdir=${__clustersdir}/${INSTALLOPTS[name]}.${INSTALLOPTS[domain]}

  out "→ Finding platform in cluster directory..."
  verbose "  Directory: ${clusterdir}"
  INSTALLOPTS[platform]=$(grep "^platform:" ${clusterdir}/install-config.yaml.orig -A 1 | tr -d "\n" | grep -Po '(?<=^platform:  )[a-z]*')
  success "Platform detected: ${INSTALLOPTS[platform]}."

  [[ -z ${INSTALLOPTS[platform]} ]] && die "Error: Can't find the platform in the directory ${clusterdir}. Aborting." || true
}

