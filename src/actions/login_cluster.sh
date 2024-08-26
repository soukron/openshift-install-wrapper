# login into a cluster with default kubeadmin
login_cluster() {
  local clusterdir=${__clustersdir}/${INSTALLOPTS[name]}.${INSTALLOPTS[domain]}
  local password=$( cat ${clusterdir}/auth/kubeadmin-password )
  local client=${__bindir}/oc-${INSTALLOPTS[version]}

  export OCP4_VERSION=${INSTALLOPTS[version]}
  ${client} login --insecure-skip-tls-verify=false --username kubeadmin --password ${password} --server https://api.${INSTALLOPTS[name]}.${INSTALLOPTS[domain]}:6443
}

