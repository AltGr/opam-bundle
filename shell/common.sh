DIR=$( cd $(dirname "$0") && pwd )
PREFIX="$DIR/bootstrap"
OPAMROOT="$DIR/opam"
LOG="$DIR/$(basename "$0").log"

title() {
  printf "\n\e[33m================\e[m %-45s \e[33m================\e[m\n\n" "$*"
}
logged_cmd() {
  printf "$1... "
  shift
  echo "+ [ $1 ] $*" >>$LOG
  "$@" >>$LOG 2>&1
  echo >>$LOG
  printf "\e[32mdone\e[m\n"
}

trap "if [ $? -ne 0 ]; then printf '\nSomething went wrong, see log in $LOG\n'; fi" EXIT

export PATH="$PREFIX/bin:$PATH"
export CAML_LD_LIBRARY_PATH="$PREFIX/lib/ocaml/stublibs"
export OPAMROOT
cd $DIR
