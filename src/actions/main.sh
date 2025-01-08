# main function
main() {
  # parse arguments from commandline
  while [[ ${1} = -?* ]]; do
    key="${1}"
    case ${key} in
      --name)                 shift; INSTALLOPTS[name]="${1}";;
      --domain)               shift; INSTALLOPTS[domain]="${1}";;
      --version)              shift; INSTALLOPTS[version]="${1}";;
      --platform)             shift; INSTALLOPTS[platform]="${1}";;

      --region)               shift; INSTALLOPTS[region]="${1}";;
      --master-replicas)      shift; INSTALLOPTS[master-replicas]="${1}";;
      --worker-replicas)      shift; INSTALLOPTS[worker-replicas]="${1}";;
      --network-type)         shift; INSTALLOPTS[network-type]="${1}";;
      --machine-network)      shift; INSTALLOPTS[machine-network]="${1}";;
      --tags)                 shift; INSTALLOPTS[tags]+=",${1}";;
      --edit-install-config)  EDIT_INSTALL_CONFIG=1;;
      --edit-install-manifests) EDIT_INSTALL_MANIFESTS=1;;

      --dev-preview)          __baseurl=${__baseurl/\/ocp/\/ocp-dev-preview};;
      --baseurl)              shift; __baseurl="${1}";;
      --custom-release-image) shift; INSTALLOPTS[custom-release-image]="${1}";;
      
      --azure-resource-group) shift; INSTALLOPTS[azure-resource-group]="${1}";;

      --ovirt-cluster)        shift; INSTALLOPTS[ovirt-cluster]="${1}";;
      --ovirt-storagedomain)  shift; INSTALLOPTS[ovirt-storagedomain]="${1}";;
      --ovirt-network)        shift; INSTALLOPTS[ovirt-network]="${1}";;
      --ovirt-vip-api)        shift; INSTALLOPTS[ovirt-vip-api]="${1}";;
      --ovirt-vip-ingress)    shift; INSTALLOPTS[ovirt-vip-ingress]="${1}";;
      --ovirt-vip-dns)        shift; INSTALLOPTS[ovirt-vip-dns]="${1}";;

      --vsphere-vcenter)      shift; INSTALLOPTS[vsphere-vcenter]="${1}";;
      --vsphere-vcenter-port) shift; INSTALLOPTS[vsphere-vcenter-port]="${1}";;
      --vsphere-username)     shift; INSTALLOPTS[vsphere-username]="${1}";;
      --vsphere-password)     shift; INSTALLOPTS[vsphere-password]="${1}";;
      --vsphere-cluster)      shift; INSTALLOPTS[vsphere-cluster]="${1}";;
      --vsphere-datacenter)   shift; INSTALLOPTS[vsphere-datacenter]="${1}";;
      --vsphere-datastore)    shift; INSTALLOPTS[vsphere-datastore]="${1}";;
      --vsphere-network)      shift; INSTALLOPTS[vsphere-network]="${1}";;
      --vsphere-vip-api)      shift; INSTALLOPTS[vsphere-vip-api]="${1}";;
      --vsphere-vip-ingress)  shift; INSTALLOPTS[vsphere-vip-ingress]="${1}";;
      --vsphere-disk-size-gb) shift; INSTALLOPTS[vsphere-disk-size-gb]="${1}";;

      --osp-vip-api)          shift; INSTALLOPTS[osp-vip-api]="${1}";;
      --osp-vip-ingress)      shift; INSTALLOPTS[osp-vip-ingress]="${1}";;
      --osp-cloud)            shift; INSTALLOPTS[osp-cloud]="${1}";;
      --osp-ext-network)      shift; INSTALLOPTS[osp-ext-network]="${1}";;
      --osp-os-image)         shift; INSTALLOPTS[osp-os-image]="${1}";;
      --osp-os-flavor)        shift; INSTALLOPTS[osp-os-flavor]="${1}";;

      --gcp-project-id)       shift; INSTALLOPTS[gcp-project-id]="${1}";;

      --init)        ACTION=init;;
      --install)     ACTION=install;;
      --destroy)     ACTION=destroy;;
      --customize)   shift; ACTION=customize; SCRIPTS="${1}";;
      --use)         ACTION=use; QUIET=1;;
      --login)       ACTION=login; QUIET=1;;
      --list)        ACTION=list;;
      --list-csv)    ACTION=list; LISTFORMAT="csv";;
      --clean-tools) ACTION=cleantools ;;

      --force)       FORCE=1;;
      --dry-run)     DRY_RUN=1;;
      --verbose)     VERBOSE=1;;
      --quiet)       QUIET=1;;
      --help|-h)     usage >&2; safe_exit;;
      *)
        die "Error: Invalid option ${1}.\n"
        ;;
    esac
    shift
  done

  WRAPPER_EDITOR="${EDITOR:-vi}"
  verbose "Using ${WRAPPER_EDITOR} as interactive editor"

  # create a temporary dir to work
  TMPDIR=$( mktemp -d -p . )
  verbose "Using ${TMPDIR} as temporary directory"

  # create config dir if doesn't exists
  if [[ ! -d ${__configdir} ]]; then
    mkdir -p ${__configdir} &>/dev/null
    verbose "Creating ${__configdir}. You will probably need to add your ssh-key.pub and pull-secret.json files on it."
  fi

  # check if all the required parameters are provided
  validate_options

  # run the actions
  case ${ACTION} in
    install)
      download_tools installer
      download_tools client
      create_install_config
      create_cluster
      ;;
    destroy)
      download_tools installer
      destroy_cluster
      ;;
    customize)
      get_cluster_version
      download_tools client
      customize_cluster
      ;;
    use)
      get_cluster_version
      download_tools client
      use_cluster
      ;;
    login)
      get_cluster_version
      download_tools client
      login_cluster
      ;;
    list)
      list_clusters
      ;;
    init)
      create_cloud_credentials
      ;;
    cleantools)
      cleantools
      ;;
  esac
}

