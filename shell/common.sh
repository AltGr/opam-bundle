DIR=$( cd $(dirname "$0") && pwd )
PREFIX="$DIR/bootstrap"
OPAMROOT="$DIR/opam"
LOG="$DIR/$(basename "$0" .sh).log"

rm -f "$LOG"

title() {
  printf "\n\033[33m================\033[m %-45s \033[33m================\033[m\n\n" "$*"
}
logged_cmd() {
  local R=0
  printf "$1... "
  shift
  echo "+ [ $1 ] $*" >>$LOG
  "$@" >>$LOG 2>&1 || R=$?
  echo >>$LOG
  if [ $R -eq 0 ]; then printf "\033[32mdone\033[m\n"; return
  else echo; return $R
  fi
}

start() {
  trap "printf '\nSomething went wrong, see log in $LOG\n'" EXIT
}

finished() {
  trap - EXIT
}

export PATH="$PREFIX/bin:$PATH"
export CAML_LD_LIBRARY_PATH="$PREFIX/lib/ocaml/stublibs"
export OPAMROOT
cd $DIR
