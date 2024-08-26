# cleanup on exit
cleanup_on_exit() {
  [[ ! -v KEEPTMP ]] && rm -fr ${TMPDIR}
  popd &>/dev/null
  kill 0
}
safe_exit() {
  trap - INT TERM EXIT
  exit
}
trap cleanup_on_exit INT TERM EXIT
main "$@"
