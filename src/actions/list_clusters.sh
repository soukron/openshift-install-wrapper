# list clusters
list_clusters() {
  echo "NAME;VERSION;PLATFORM;STATUS;KUBEADMIN_PASSWORD;CONSOLE" > /tmp/list.$$
  for cluster in $(ls ${__clustersdir} );do
    clusterdir=${__clustersdir}/${cluster}

    APISERVER="api.${cluster}"
    CONSOLE="https://console-openshift-console.apps.${cluster}"
    PLATFORM=$((cut -d, -f4 ${clusterdir}/metadata.json 2> /dev/null || echo "Unknown") |cut -d: -f1 |sed s/"[{,},\"]"//g)
    NAME=$((cut -d, -f1 ${clusterdir}/metadata.json 2> /dev/null || echo "Unknown") |cut -d: -f2 |sed s/"[{,},\"]"//g)
    ADMINPWD=$(cat ${clusterdir}/auth/kubeadmin-password 2> /dev/null || echo "Unknown" )
    STATUS=$(curl -m 5 -k https://${APISERVER}:6443/healthz 2> /dev/null || echo "Unhealthy")
    CLUSTER_VERSION=$(grep -Po '(?<=OpenShift Installer )[v0-9.]*' ${clusterdir}/.openshift_install.log 2>/dev/null| head -n 1 | tr -d v)
    echo "${NAME};${CLUSTER_VERSION};${PLATFORM};${STATUS};${ADMINPWD};${CONSOLE}" >> /tmp/list.$$
  done
  if [[ ${LISTFORMAT} == "csv" ]]; then
    cat /tmp/list.$$
  else
    column -t -s ';' /tmp/list.$$
  fi
  rm -fr /tmp/list.$$
}

