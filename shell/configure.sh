#!/bin/sh -ue

. "$(dirname "$0")/common.sh"

"$DIR/bootstrap.sh"

start

if [ -d "$OPAMROOT/default" ]; then
   echo "Already initialised opam sandbox found"
else
   title "Configure: initialising opam"

   echo "Output is in $LOG"

   if [ ! -f "$OPAMROOT/config" ]; then
      logged_cmd "Initialising" opam init --bare --no-setup --yes --disable-sandboxing $DIR/repo
   fi
   logged_cmd "Creating sandbox" opam switch create default ocaml-bootstrap
   ln -sf "$PREFIX/lib/ocaml" "$(opam var lib)/ocaml"
fi

finished
