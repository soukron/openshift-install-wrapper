# verify cloud credentials
verify_cloud_credentials() {
  local platform=${INSTALLOPTS[platform]}
  local credentials=${CONFIGFILES[${platform}]%%;*}

  verbose "  Credentials file: ${credentials}."
  if [[ ! -f ${credentials} ]]; then
    die "Error: Missing credentials file (${credentials})."
  fi
}

# create cloud credentials
create_cloud_credentials() {
  local platform=${INSTALLOPTS[platform]}
  local credentials=${CONFIGFILES[${platform}]%%;*}
  local content=${CONFIGFILES[${platform}]#*;}

  out "→ Creating target directory..."
  mkdir -p $( dirname ${credentials} )
  verbose "  Directory: $( dirname ${credentials} )."

  out "→ Creating sample cloud credentials file for ${platform}..."
  if [[ -f ${credentials} ]]; then
    if [[ ${FORCE} -eq 0 ]]; then
      die "Credentials file is already present. Use --force to overwrite it (use with caution) or remove it manually before trying again."
    else
      out "→ Cleaning up existing credentials file..."
      rm -fr ${credentials}
    fi
  fi

  echo ${content} | base64 -d > ${credentials}
  success "Created sample file ${credentials}. Please edit it to add the proper credentials for each provider before trying to install any cluster or it will fail."
}

