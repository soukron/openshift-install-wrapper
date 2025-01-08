# check for an option
require_option() {
  [[ ${INSTALLOPTS[${1}]} ]] || die "Error: Missing --${1} parameter, required for ${ACTION}."
}

# validate options depending on the choosen action
validate_options() {
  out "→ Validating environment..."

  case ${ACTION} in
    install)
      require_option name
      require_option domain
      require_option version
      require_option platform
      case ${INSTALLOPTS[platform]} in
        aws)
          require_option region
          verify_cloud_credentials
          ;;
        azure)
          require_option region
          require_option azure-resource-group
          verify_cloud_credentials
          ;;
        vsphere)
          require_option vsphere-vcenter
          require_option vsphere-vcenter-port
          require_option vsphere-username
          require_option vsphere-password
          require_option vsphere-cluster
          require_option vsphere-datacenter
          require_option vsphere-datastore
          require_option vsphere-network
          require_option vsphere-vip-api
          require_option vsphere-vip-ingress
          ;;
        ovirt)
          require_option ovirt-cluster
          require_option ovirt-storagedomain
          require_option ovirt-network
          require_option ovirt-vip-api
          require_option ovirt-vip-ingress
          require_option ovirt-vip-dns
          ;;
        openstack)
          require_option osp-vip-api
          require_option osp-ext-network
          require_option osp-cloud
          ;;
        gcp)
          require_option gcp-project-id
          require_option region
          ;;
        *)
          die "Error: Platform ${INSTALLOPTS[platform]} not yet supported by this script"
          ;;
      esac
      ;;
    destroy)
      require_option name
      require_option domain
      get_cluster_version
      get_cluster_platform
      if [[ ${INSTALLOPTS[platform]} == "aws" ]] ||  [[ ${INSTALLOPTS[platform]} == "azure" ]] ;then
       verify_cloud_credentials
      fi
      ;;
    customize|use|login)
      require_option name
      require_option domain
      get_cluster_version
      get_cluster_platform
      ;;
    list)
      ;;
    init)
      require_option platform
      ;;
    cleantools)
      ;;
    *)
      die "Error: Missing action. Please use --help, --init, --install, --customize, --destroy, --use, --login, --list or --clean-tools."
      ;;
  esac
}

