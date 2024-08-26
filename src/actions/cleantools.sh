# Clean tools, only enter here if action  "--clean-tools" selected
# Removes all previously downloaded installers and CLI clients of not installed versions
cleantools() {
  out "→ Showing actual filesystem occupation."
  df -h "${__bindir}"

  out "→ Cleaning up all installer binaries..."
  rm -f ${__bindir}/openshift-install-[0-9]* 2> /dev/null && success "All installer removed!"

  [ $(ls ~/.cache/openshift-installer/image_cache/*.ova 2> /dev/null |wc -l) -ge 1 ] && \
  out "→ Removing OVA images..." && \
  rm -f ~/.cache/openshift-installer/image_cache/*.ova && success "All OVA images removed!"

  # Generate the list
  ls ${__bindir}/{oc,kubectl}-* > /tmp/cli-listxxxxxx.txt

  # Remove versions to maintain from the generated list
  for cluster in $(ls ${__clustersdir});do
    CLUSTER_VERSION="$(grep -Po '(?<=OpenShift Installer )[v0-9.]*' ${__clustersdir}/${cluster}/.openshift_install.log 2>/dev/null| head -n 1 | tr -d v)" 
    grep -v ${CLUSTER_VERSION} /tmp/cli-listxxxxxx.txt > /tmp/cli-listxxxxxxAPPO.txt
    mv -f /tmp/cli-listxxxxxxAPPO.txt /tmp/cli-listxxxxxx.txt
  done
  # Remove all not used versions
  out "→ Cleaning up all unused CLI clients..."
  cat /tmp/cli-listxxxxxx.txt |xargs rm -f > /dev/null 2>&1 && success "CLI clients removed!"

  # Remove the list
  rm -f /tmp/cli-listxxxxxx.txt

  out "→ Showing actual filesystem occupation."
  df -h "${__bindir}"
}

