# usage
usage() {
  cat <<EOF
OpenShift installation wrapper for IPI installations. Version: ${VERSION}

Usage: `basename ${0}` [--init|--install|--destroy|--customize] [options]

Options:
  --name <name>                     - name of the cluster
  --domain <domain>                 - name of the domain for the cluster
  --version <version>               - version to install
  --platform <name>                 - cloud provider

  --region <name>                   - sets the region in the cloud provider
  --master-replicas <number>        - optionally, sets the number of master nodes to deploy (default: 3)
  --worker-replicas <number>        - optionally, sets the number of worker nodes (default: 2)
  --network-type <network type>     - optionally, sets network type: OpenShiftSDN or OVNKubernetes (default: OVNKubernetes)
  --machine-network                 - optionally, sets machineNetwork (default: 10.0.0.0/16)
  --edit-install-config             - optionally, allows to edit the install-config.yaml before starting installation
  --edit-install-manifests          - optionally, allows to edit the install manifests. After generating the manifests, 
                                      the script will stop itself so the user modifies the manifests. 
                                      Once done, user must continue the script with 'fg'.

  --dev-preview                     - required to install any dev-preview release
  --baseurl <url>                   - sets the baseurl to download the binaries (overrides the use of --dev-preview)
                                      default: https://mirror.openshift.com/pub/openshift-v4/x86_64/clients/ocp
  --custom-release-image <url>      - uses a custom release image to extract the binaries from there. 
                                      Requires a working oc binary in the PATH and pull secret with credentials for CI registry.

  --tags <key>=<value>[,key=value]  - optionally, sets tags on the resources it creates (only implemented for platform=aws)
                                      use multiple options for multiple tags or comma-separated key/value pairs

  --azure-resource-group            - provide the ResourceGroup where the domain exists

  --ovirt-cluster <uuid>            - ovirt cluster UUID
  --ovirt-storagedomain <uuid>      - ovirt storage domain UUID
  --ovirt-network <name>            - ovirt network name
  --ovirt-vip-api <ip>              - IP address the cluster's API
  --ovirt-vip-ingress <ip>          - IP address for the cluster's ingress
  --ovirt-vip-dns <ip>              - IP address for the cluster's dns

  --vsphere-vcenter <name>          - fqdn or IP address of vCenter
  --vsphere-vcenter-port <port>     - port of vCenter
  --vsphere-username <username>     - username to login to vCenter
  --vsphere-password <password>     - password to login to vCenter
  --vsphere-cluster <name>          - vCenter cluster name
  --vsphere-datacenter <name>       - vCenter datacenter name
  --vsphere-datastore <name>        - vCenter datastore name
  --vsphere-network <name>          - vCenter network name
  --vsphere-vip-api <ip>            - IP address the cluster's API
  --vsphere-vip-ingress <ip>        - IP address for the cluster's ingress
  --vsphere-disk-size-gb <gb>       - optionally, sets the disk size for the instances

  --osp-vip-api <name>              - floating IP for the cluster's API
  --osp-vip-ingress <name>          - floating IP for the cluster's Ingress
  --osp-cloud <name>                - name of the cloud to use from clouds.yaml
  --osp-ext-network <name>          - name of the external network to be used
  --osp-os-image <name>             - name or location of the RHCOS image to use
  --osp-os-flavor <name>            - name of the flavor to use

  --gcp-project-id <name>           - name of the GCP project

  --init                            - initialize the tool and credentials
  --install                         - install the cluster
  --destroy                         - destroy the cluster
  --customize <actions>             - customize the cluster with some post-install actions
  --use                             - sets KUBECONFIG and/or env vars to use a given cluster
  --login                           - uses the default kubeadmin password to login in a given cluster
  --list                            - lists all existing clusters
  --list-csv                        - lists all existing clusters in CSV format
  --list-fields <fields>            - lists all existing clusters with the given fields only (comma-separated list of fields)
                                      available fields: NAME, VERSION, PLATFORM, STATUS, ADMINPWD, APISERVER, CONSOLE
                                      can be set from running environment by setting LISTFIELDS environment variable
  --clean-tools                     - removes unecessary CLI clients and all installers

  --force                           - force installation (cleanup files if required)
  --dry-run                         - does all the preparation steps but doesn't run the installer to create/destroy a cluster
  --verbose                         - shows more information during the execution
  --quiet                           - quiet mode (no output at all)
  --help|-h                         - shows this message

Environment:
  INSTALLOPTS_ENV_FILE=<path>        - load INSTALLOPTS from a shell file

Available customizations:
#__CUSTOM_SCRIPTS_NAMES__
EOF
  exit 0
}

