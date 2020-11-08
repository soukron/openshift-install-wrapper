# OpenShift Installer Wrapper
## Index
1. [Description](#description)
2. [Preparation](#preparation)
3. [Usage](#usage)
4. [Adding customizations](#adding-customization-scripts)
5. [TODO](#todo)
6. [Known Issues](#known-issues)

## Description
This is a wrapper for the official `openshift-install` binary to perform IPI (Installer Provided Infrastructure) installations of OpenShift 4.

Features:
 - downloads the installer and client for the desired version
 - creates sample cloud credential files in the right location for each cloud provider
 - creates install-config.yaml for each cloud provider
 - allows customize a previously installed cluster with some pre-made scripts
 
## Preparation
The wrapper leverages in `openshift-install` all the tasks but it requires some pre-requisites:
  - proper credentials for every cloud provider
  - RSA key
  - pull secret

### Script installation
This will copy the script to the default location `$HOME/.local/ocp4`:
```
$ make install         
```

For other locations set `TARGETDIR` at your convenience:
```
$ make TARGETDIR=/opt/ocp4 install         
```

Add the directory to your `$PATH` variable so you can invoke it directly:
```
$ export PATH=$PATH:$HOME/.local/ocp4/bin
```

### Cloud credentials
If you don't have such credentials yet (ie. if you don't use aws-cli at all), you can invoke the wrapper for every platform so it will create the sample file and then proceed to edit it with your own credentials:
```
$ openshift-install-wrapper --init --platform aws
→ Validating environment...
→ Creating target directory...
→ Creating sample cloud credentials file for aws...
 ✔  Created sample file /home/sgarcia/.aws/credentials. Please edit it to add the proper credentials for each provider before trying to install any cluster or it will fail.
``` 

### Other files
- Copy the RSA public key that will be injected in the instances to `$HOME/.config/openshift-install-wrapper/config/ssh-key.pub`
- Copy the pull secret to `$HOME/.config/openshift-install-wrapper/config/pull-secret.json`

## Usage
The list of features and options is increasing as changes are made. Check the `--help` parameter for the newest list.

```
$ openshift-install-wrapper --help
OpenShift installation wrapper for IPI installations. Version: 1.0.0

Usage: openshift-install-wrapper [--init|--install|--destroy|--customize] [options]

Options:
  --name <name>              - name of the cluster
  --domain <domain>          - name of the domain for the cluster
  --version <version>        - version to install
  --platform <name>          - cloud provider (only aws supported for now)
  --region <name>            - cloud provider region

  --force                    - force installation (cleanup files if required)
  --init                     - initialize the tool and credentials
  --install                  - install the cluster
  --destroy                  - destroy the cluster
  --customize                - customize the cluster with some post-install actions
  --list                     - lists all existing clusters

  --verbose                  - shows more information during the execution
  --quiet                    - quiet mode (no output at all)
  --help|-h                  - shows this message
```

### Install a cluster
```
$ openshift-install-wrapper --install \
                            --name sgarcia-ocp447 \
                            --domain aws.gmbros.net \
                            --version 4.4.7 \
                            --platform aws \
                            --region eu-west-1
→ Validating environment...
→ Checking if installer for 4.4.7 is already present...
 ✔  Installer for 4.4.7 found. Continuing.
→ Checking if the cluster directory already exists...
→ Creating install-config.yaml file...
→ Running "openshift-install" to create a cluster...
 ✔  Cluster created!
To access the cluster as the system:admin user when using 'oc', run 'export KUBECONFIG=/home/sgarcia/.local/ocp4/clusters/sgarcia-ocp447-3.aws.gmbros.net/auth/kubeconfig'
Access the OpenShift web-console here: https://console-openshift-console.apps.sgarcia-ocp447.aws.gmbros.net
Login to the console with user: kubeadmin, password: m2MsJ-vKNcn-8zTHM-A9NVU
```

### Destroy a cluster
```
$ openshift-install-wrapper --destroy \
                            --name sgarcia-ocp447 \
                            --domain aws.gmbros.net
→ Validating environment...
→ Finding version in cluster directory...
 ✔  Version detected: 4.4.7.
→ Checking if installer for 4.4.7 is already present...
 ✔  Installer for 4.4.7 found. Continuing.
→ Running "openshift-install" to destroy a cluster...
 ✔  Cluster destroyed!
→ Removing directory...
```

### Customize a cluster
```
$ openshift-install-wrapper --customize delete-kubeadmin-user \
                            --name sgarcia-ocp447 \
                            --domain aws.gmbros.net \
                            --platform aws
→ Validating environment...
→ Finding version in cluster directory...
 ✔  Version detected: 4.4.7.
→ Checking if client binaries for 4.4.7 are already present...
 ✔  Client binaries for 4.4.7 are found. Continuing.
→ Running delete-kubeadmin-user...
secret "kubeadmin" deleted
```

### Troubleshooting
- Use `--verbose` to get extra information during the execution, including the full output of `openshift-install`
- Review `$HOME/.local/ocp4/clusters/<cluster_name>/.openshift_install_wrapper.log` for useful output

## Adding customization scripts
In order to add new scripts, they must meet some requisites:
 - they must be created in the `scripts/` directory
 - they must have a descriptive name and do not overlap with any existing command or function in the system
 - optionally they can have a name and a description (single line)
 - they must contain some markers and a `main()` function. Use any existing script as a baseline or use this one:
   ```sh
   #!/bin/bash

   # Optional fields
   # script name: delete-kubeadmin-user
   # script description: Removes the kubeadmin secret

   # Mandatory function
   # start main - do not remove this line and do not change the function name
   main() {
     oc delete secret kubeadmin -n kube-system \
         && success "Secret kubeadmin successfully deleted." \
         || err "Error deleting kubeadmin secret. It probably doesn't exists anymore. Skipping."
   }
   # end main - do not remove this line

   # Optionally, keep this if you want to run your script manually or for testing.
   main $@
   ```

On the other hand, in order to provide flexibility, every script will receive the next parameters:
| Parameter  | Description  | Example  |
|:----------:|:-------------|:---------|
| `$1` | name of the customization and arguments in the command line | `deploy-rhsso=namespace=rhsso:version=4.2.2` |
| `$2` | full path to the cluster installation directory | `/opt/ocp4/clusters/sgarcia-ocp447/` |
| `$3` | full path to the right `oc` client binary | `/opt/ocp4/bin/oc-4.4.7` |
| `$4` | verbose mode flag (`0` or `1`) | `0` |
| `$5` | quiet mode flag (`0` or `1`) | `0` |
| `$6` | cluster version | `4.4.7` |
| `$7` | cluster name | `sgarcia-ocp447` |
| `$8` | cluster subdomain | `aws.gmbros.net` |
| `$9` | cloud platform | `aws` |

In the same way, there are a few functions ready to be used from the customizations:
 - `oc()`, which runs a command in the cluster with `system:admin` permissions and aligns the output with the `--verbose` flag
 - `success()`, which allows to print a message after succeeding in a command with a check icon
 - `err()`, which allows to print a message after failing in a command with a cross icon
 - `die()`, which allows to print a message after failing in a command with a cross icon and stops the execution
 - `parse_args_as_variables()`, which will parse an string and declare variables based on the content of it

Optionally, your customization can receive extra arguments sent in the commandline. This is useful if you customization is flexible 
in what it does or it allows different actions (like installing different versions of an operator). As an example:
```sh
$ openshift-install-wrapper --customize add-htpasswd-idp 
                            --name sgarciam-ocp447 \
                            --domain aws.gmbros.net \
                            --platform aws
→ Validating environment...
→ Finding version in cluster directory...
 ✔  Version detected: 4.4.7.
→ Checking if client binaries for 4.4.7 are already present...
 ✔  Client binaries for 4.4.7 are found. Continuing.
→ Running add-htpasswd-idp...
 ✔  Adding default users: admin, user and guest.
 ✔  Secret htpasswd-secret created/configured successfully.
 ✔  OAuth/cluster successfully configured.

$ openshift-install-wrapper --customize add-htpasswd-idp=admin=adminpwd:user1=user1pwd
                            --name sgarciam-ocp447 \
                            --domain aws.gmbros.net \
                            --platform aws
→ Validating environment...
→ Finding version in cluster directory...
 ✔  Version detected: 4.4.7.
→ Checking if client binaries for 4.4.7 are already present...
 ✔  Client binaries for 4.4.7 are found. Continuing.
→ Running add-htpasswd-idp...
 ✔  Using custom users.
 ✔  Adding user admin with password adminpwd.
 ✔  Adding user user1 with password user1pwd.
 ✔  Secret htpasswd-secret created/configured successfully.
 ✔  OAuth/cluster successfully configured.
```

Finally, after adding your new script in the directory, remember to run `make install` in order to install a new version of `openshift-install-wrapper` with your script embedded on it.

## TODO
- Read cluster version and cluster platform from install directory for `--customize`, and `--destroy` operations
- Add GCP support
- Improve `--list` output
- Improve console output (ie. include timestamps)
- Implement `--expire` parameter to delete (using cron) a cluster after a certain time

## Known issues
- Error handling when the cloud credentials are invalid or the installation fails
- Lines with # in customization scripts are removed during the merge. This must be fixed.

## Contact
Reach me in [Twitter](http://twitter.com/soukron) or email in soukron _at_ gmbros.net

## License
Licensed under the Apache License, Version 2.0 (the "License"); you may not use
this file except in compliance with the License. You may obtain a copy of the
License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software distributed
under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
CONDITIONS OF ANY KIND, either express or implied. See the License for the
specific language governing permissions and limitations under the License.

[here]:http://gnu.org/licenses/gpl.html
