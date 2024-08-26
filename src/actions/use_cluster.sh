# use a cluster
use_cluster() {
  local clusterdir=${__clustersdir}/${INSTALLOPTS[name]}.${INSTALLOPTS[domain]}

  echo "export KUBECONFIG=${clusterdir}/auth/kubeconfig"
  echo "export OCP4_VERSION=${INSTALLOPTS[version]}"
}

