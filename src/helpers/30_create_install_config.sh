# create install_config.yaml
create_install_config() {
  local clusterdir=${__clustersdir}/${INSTALLOPTS[name]}.${INSTALLOPTS[domain]}

  out "→ Checking if the cluster directory already exists..."
  verbose "  Directory: ${clusterdir}"
  if [ -d ${clusterdir} ]; then
    if [[ ${FORCE} -eq 0 ]]; then
      die "Directory is already present. Use --force to overwrite it (use with caution) or remove it manually before trying again."
    else
      out "→ Cleaning up existing directory's content..."
      rm -fr ${clusterdir}
    fi
  fi

  mkdir -p ${clusterdir}
  out "→ Creating install-config.yaml file..."
  key=${INSTALLOPTS[platform]}-${INSTALLOPTS[version]}
  if [[ -n "${INSTALLTEMPLATES[$key]}" ]]; then
    success "Using specific install-config template for ${key}..."
    installtemplate="${INSTALLTEMPLATES[$key]}"
  else
    minor_version="${INSTALLOPTS[version]%.*}"
    key="${INSTALLOPTS[platform]}-${minor_version}"

    if [[ -n "${INSTALLTEMPLATES[$key]}" ]]; then
      success "Using specific install-config template for ${key}..."
      installtemplate="${INSTALLTEMPLATES[$key]}"
    else
      key="${INSTALLOPTS[platform]}-default"

      if [[ -n "${INSTALLTEMPLATES[$key]}" ]]; then
        success "Using default install-config template for ${INSTALLOPTS[platform]}..."
        installtemplate="${INSTALLTEMPLATES[$key]}"
      else
        die "Unable to find a valid install-config template for the given platform/version."
      fi
    fi
  fi

  echo ${installtemplate} | base64 -d > ${clusterdir}/install-config.yaml

  sed -i "s/NAME/${INSTALLOPTS[name]}/g;" ${clusterdir}/install-config.yaml
  sed -i "s/DOMAIN/${INSTALLOPTS[domain]}/g;" ${clusterdir}/install-config.yaml
  sed -i "s/REGION/${INSTALLOPTS[region]}/g;" ${clusterdir}/install-config.yaml
  sed -i "s/WORKER-REPLICAS/${INSTALLOPTS[worker-replicas]:-3}/g;" ${clusterdir}/install-config.yaml
  sed -i "s/MASTER-REPLICAS/${INSTALLOPTS[master-replicas]:-3}/g;" ${clusterdir}/install-config.yaml
  sed -i "s/NETWORK-TYPE/${INSTALLOPTS[network-type]:-OpenShiftSDN}/g;" ${clusterdir}/install-config.yaml
  sed -i "s#MACHINE-NETWORK#${INSTALLOPTS[machine-network]:-10.0.0.0/16}#g;" ${clusterdir}/install-config.yaml
  if [[ ${INSTALLOPTS[platform]} == "aws" ]]; then
    sed -i "/TAGS/ {
                      s/ TAGS/${INSTALLOPTS[tags]:-" {}"}/;
                      s/,/\n      /g;
                      s/=/: /g;
	      }" ${clusterdir}/install-config.yaml
  fi
  if [[ ${INSTALLOPTS[platform]} == "vsphere" ]]; then
    sed -i "s/VSPHERE-VIP-API/${INSTALLOPTS[vsphere-vip-api]}/g;" ${clusterdir}/install-config.yaml
    sed -i "s/VSPHERE-CLUSTER/${INSTALLOPTS[vsphere-cluster]}/g;" ${clusterdir}/install-config.yaml
    sed -i "s/VSPHERE-DATACENTER/${INSTALLOPTS[vsphere-datacenter]}/g;" ${clusterdir}/install-config.yaml
    sed -i "s/VSPHERE-DATASTORE/${INSTALLOPTS[vsphere-datastore]}/g;" ${clusterdir}/install-config.yaml
    sed -i "s/VSPHERE-VIP-INGRESS/${INSTALLOPTS[vsphere-vip-ingress]}/g;" ${clusterdir}/install-config.yaml
    sed -i "s/VSPHERE-NETWORK/${INSTALLOPTS[vsphere-network]}/g;" ${clusterdir}/install-config.yaml
    sed -i "s/VSPHERE-PASSWORD/${INSTALLOPTS[vsphere-password]}/g;" ${clusterdir}/install-config.yaml
    sed -i "s/VSPHERE-USER/${INSTALLOPTS[vsphere-username]}/g;" ${clusterdir}/install-config.yaml
    sed -i "s/VSPHERE-VCENTER-PORT/${INSTALLOPTS[vsphere-vcenter-port]}/g;" ${clusterdir}/install-config.yaml
    sed -i "s/VSPHERE-VCENTER/${INSTALLOPTS[vsphere-vcenter]}/g;" ${clusterdir}/install-config.yaml
    sed -i "s/VSPHERE-DISK-SIZE-GB/${INSTALLOPTS[vsphere-disk-size-gb]:-120}/g;" ${clusterdir}/install-config.yaml
  fi
  if [[ ${INSTALLOPTS[platform]} == "ovirt" ]]; then
    sed -i "s/OVIRT-VIP-API/${INSTALLOPTS[ovirt-vip-api]}/g;" ${clusterdir}/install-config.yaml
    sed -i "s/OVIRT-VIP-DNS/${INSTALLOPTS[ovirt-vip-dns]}/g;" ${clusterdir}/install-config.yaml
    sed -i "s/OVIRT-VIP-INGRESS/${INSTALLOPTS[ovirt-vip-ingress]}/g;" ${clusterdir}/install-config.yaml
    sed -i "s/OVIRT-CLUSTER/${INSTALLOPTS[ovirt-cluster]}/g;" ${clusterdir}/install-config.yaml
    sed -i "s/OVIRT-STORAGEDOMAN/${INSTALLOPTS[ovirt-storagedomain]}/g;" ${clusterdir}/install-config.yaml
    sed -i "s/OVIRT-NETWORK/${INSTALLOPTS[ovirt-network]}/g;" ${clusterdir}/install-config.yaml
  fi
  if [[ ${INSTALLOPTS[platform]} == "openstack" ]]; then
    sed -i "s/OSP-API-FIP/${INSTALLOPTS[osp-vip-api]}/g;" ${clusterdir}/install-config.yaml
    sed -i "s/OSP-INGRESS-FIP/${INSTALLOPTS[osp-vip-ingress]}/g;" ${clusterdir}/install-config.yaml
    sed -i "s/OSP-CLOUD/${INSTALLOPTS[osp-cloud]:-openstack}/g;" ${clusterdir}/install-config.yaml
    sed -i "s/OSP-EXT-NETWORK/${INSTALLOPTS[osp-ext-network]}/g;" ${clusterdir}/install-config.yaml
    sed -i "s/OSP-OS-IMAGE/${INSTALLOPTS[osp-os-image]}/g;" ${clusterdir}/install-config.yaml
    sed -i "s/OSP-OS-FLAVOR/${INSTALLOPTS[osp-os-flavor]:-m1.large}/g;" ${clusterdir}/install-config.yaml
  fi
  if [[ ${INSTALLOPTS[platform]} == "gcp" ]]; then
    sed -i "s/GCP-PROJECT-ID/${INSTALLOPTS[gcp-project-id]}/g;" ${clusterdir}/install-config.yaml
    sed -i "s/REGION/${INSTALLOPTS[region]}/g;" ${clusterdir}/install-config.yaml
  fi

  if [[ ! -f ${__configdir}/pull-secret.json ]]; then
    die "Missing pull secret in ${__configdir}/pull-secret.json. Please create the file before trying again."
  fi
  echo "pullSecret: '$(cat ${__configdir}/pull-secret.json)'" >> ${clusterdir}/install-config.yaml
  if [[ ! -f ${__configdir}/ssh-key.pub ]]; then
    die "Missing public RSA key in ${__configdir}/ssh-key.pub. Please create the file before trying again."
  fi
  echo "sshKey: $(cat ${__configdir}/ssh-key.pub)" >> ${clusterdir}/install-config.yaml

  if [[ ${INSTALLOPTS[platform]} == "azure" ]]; then
    sed -i "s/RESOURCEGROUP/${INSTALLOPTS[azure-resource-group]}/g;" ${clusterdir}/install-config.yaml
  fi

  if [[ ${EDIT_INSTALL_CONFIG} -eq 1 ]]; then
	verbose "Editing install-config with ${WRAPPER_EDITOR}"
	${WRAPPER_EDITOR} "${clusterdir}/install-config.yaml"
  fi
}

