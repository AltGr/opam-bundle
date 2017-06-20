DIR=$( cd $(dirname "$0") && pwd )
PREFIX="$DIR/bootstrap"
OPAMROOT="$DIR/opam"
LOG="$DIR/$(basename "$0").log"

title() {
  printf "\n\033[33m================\033[m %-45s \033[33m================\033[m\n\n" "$*"
}
logged_cmd() {
  printf "$1... "
  shift
  echo "+ [ $1 ] $*" >>$LOG
  "$@" >>$LOG 2>&1
  echo >>$LOG
  printf "\033[32mdone\033[m\n"
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
