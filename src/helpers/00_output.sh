# output helpers
out() {
  [[ ${QUIET} -eq 1 ]] && return

  local message="$@"
  if ((PIPED)); then
    message=$(echo $message | sed '
      s/\\[0-9]\{3\}\[[0-9]\(;[0-9]\{2\}\)\?m//g;
      s/✖/Error:/g;
      s/✔/Success:/g;
    ')
  fi
  printf '%b\n' "$message";
}
die() { err "$@ Exiting..."; exit 1; } >&2
err() { out " \033[1;31m✖\033[0m  $@"; } >&2
success() { out " \033[1;32m✔\033[0m  $@"; }
verbose() { [[ ${VERBOSE} -eq 1 ]] && out "$@" || true; }

