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
   ln -sf "$PREFIX/lib/ocaml" "$(opam config var lib)/ocaml"
fi

title "Configure: bootstrapping auxiliary utilities"

echo "Output is in $LOG"
logged_cmd "Compiling bootstrap utilities" opam install opam-depext --yes

title "Configure: getting system dependencies"

echo "You may be asked for 'sudo' access to install required system dependencies"
echo "through your package system"
echo
if opam depext %{install_packages}%; then
  touch has_depexts
  finished
else
  REQUIRED=$(opam depext %{install_packages}% --list --short)
  if [ -z "$REQUIRED" ]; then touch has_depexts; finished; exit 0; fi
  echo "These required system dependencies could not be automatically installed:"
  for p in $REQUIRED; do echo "  - $p"; done
  echo
  echo "Please install them and retry this script.";
  finished
  exit 1
fi
