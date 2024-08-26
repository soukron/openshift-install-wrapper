# download tools (if required)
download_tools() {
  local tool=${1}

  if [[ $(echo ${INSTALLOPTS[version]} |grep -E "latest|stable|candidate|fast") ]];then
    INSTALLOPTS[version]=$( curl -s ${__baseurl}/${INSTALLOPTS[version]}/release.txt | grep "Release Metadata:" -A1 | grep Version | cut -d\: -f 2 | tr -d " " )
    [[ ${INSTALLOPTS[version]} == "" ]] && die "Invalid version, check the version and retry."
    success "Version resolved to ${INSTALLOPTS[version]}."
  fi
  local version=${INSTALLOPTS[version]}

  case ${tool} in
    installer)
      out "→ Checking if installer for ${version} is already present..."
      verbose "  File: ${__bindir}/openshift-install-${version}"
      if [ ! -f ${__bindir}/openshift-install-${version} ]; then
        err "Installer not found. Downloading it..."
        if [[ ${VERBOSE} -eq 1 ]]; then
          wget ${__baseurl}/${version}/openshift-install-linux-${version}.tar.gz -O ${TMPDIR}/openshift-install-linux-${version}.tar.gz
        else
          wget ${__baseurl}/${version}/openshift-install-linux-${version}.tar.gz -O ${TMPDIR}/openshift-install-linux-${version}.tar.gz &>/dev/null
        fi
        success "Installer downloaded successfully."

        out "→ Extracting openshift-install file..."
        tar xfa ${TMPDIR}/openshift-install-linux-${version}.tar.gz -C ${TMPDIR}
        mv -f ${TMPDIR}/openshift-install "${__bindir}/openshift-install-${version}"

        success "Successfuly downloaded installer for ${version}."
      else
        success "Installer for ${version} found. Continuing."
      fi
      ;;

    client)
      out "→ Checking if client binaries for ${version} are already present..."
      verbose "  File: ${__bindir}/oc-${version}"
      if [ ! -f ${__bindir}/oc-${version} ]; then
        err "Client has not found. Downloading it..."
        if [[ ${VERBOSE} -eq 1 ]]; then
          wget ${__baseurl}/${version}/openshift-client-linux-${version}.tar.gz -O ${TMPDIR}/openshift-client-linux-${version}.tar.gz
        else
          wget ${__baseurl}/${version}/openshift-client-linux-${version}.tar.gz -O ${TMPDIR}/openshift-client-linux-${version}.tar.gz &>/dev/null
        fi
        success "Client downloaded successfully."

        echo "→ Extracting oc and kubectl files..."
        tar xfa ${TMPDIR}/openshift-client-linux-${version}.tar.gz -C ${TMPDIR}
        mv -f ${TMPDIR}/oc "${__bindir}/oc-${version}"
        mv -f ${TMPDIR}/kubectl "${__bindir}/kubectl-${version}"

        success "Successfuly downloaded client binaries for ${version}."
      else
        success "Client binaries for ${version} are found. Continuing."
      fi
      ;;
  esac
}

