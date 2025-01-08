# download tools (if required)
# extracts a binary from an image
extract_from_image() {
  local command="$1"
  local target="$2"
  local image_url="$3"
  local quiet="$4"

  if [[ ${quiet} -eq 1 ]]; then
    command oc adm -a ${__configdir}/pull-secret.json release extract --command=${command} ${image_url} --to=${target} &>/dev/null
  else
    command oc adm -a ${__configdir}/pull-secret.json release extract --command=${command} ${image_url} --to=${target}
  fi
}

# downloads the binary from a url
download_from_url() {
  local tool="$1"
  local version="$2"
  local target="$3"
  local quiet="$4"

  local tarfile="${tool}-linux-${version}.tar.gz"
  
  if [[ ${quiet} -eq 1 ]]; then
    wget ${__baseurl}/${version}/${tarfile} -O ${target}/${tarfile} &>/dev/null
  else
    wget ${__baseurl}/${version}/${tarfile} -O ${target}/${tarfile}
  fi
  
  tar xfa ${target}/${tarfile} -C ${target}
}

# download tools (if required)
download_tools() {
  local tool=${1}

  if [[ $(echo ${INSTALLOPTS[version]} |grep -E "latest|stable|candidate|fast") ]];then
    INSTALLOPTS[version]=$( curl -s ${__baseurl}/${INSTALLOPTS[version]}/release.txt | grep "Release Metadata:" -A1 | grep Version | cut -d\: -f 2 | tr -d " " )
    [[ ${INSTALLOPTS[version]} == "" ]] && die "Invalid version, check the version and retry."
    success "Version resolved to ${INSTALLOPTS[version]}."
  fi
  local version=${INSTALLOPTS[version]}
  local quiet=$(( ! ${VERBOSE} ))

  case ${tool} in
    installer)
      out "→ Checking if installer for ${version} is already present..."
      verbose "  File: ${__bindir}/openshift-install-${version}"
      if [ ! -f ${__bindir}/openshift-install-${version} ]; then
        err "Installer not found. Downloading it..."
        
        if [[ -n "${INSTALLOPTS[custom-release-image]}" ]]; then
          extract_from_image "openshift-install" "${TMPDIR}" "${INSTALLOPTS[custom-release-image]}" ${quiet}
        else
          download_from_url "openshift-install" "${version}" "${TMPDIR}" ${quiet}
        fi

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

        if [[ -n "${INSTALLOPTS[custom-release-image]}" ]]; then
          extract_from_image "oc" "${TMPDIR}" "${INSTALLOPTS[custom-release-image]}" ${quiet}
        else
          download_from_url "openshift-client" "${version}" "${TMPDIR}" ${quiet}
        fi

        mv -f ${TMPDIR}/oc "${__bindir}/oc-${version}"
        success "Successfuly downloaded client binaries for ${version}."
      else
        success "Client binaries for ${version} are found. Continuing."
      fi
      ;;
  esac
}
