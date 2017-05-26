#!/bin/sh -ue

. $(dirname $0)/common.sh

"$DIR/bootstrap.sh"

if [ -d "$OPAMROOT/default" ]; then
   echo "Already initialised opam sandbox found"
else
   title "Configure: initialising opam"

   if [ ! -f "$OPAMROOT/config" ]; then
      logged_cmd "Initialising" opam init --bare --no-setup $DIR/repo
   fi
   logged_cmd "Creating sandbox" opam switch create default ocaml-system
fi

title "Configure: bootstrapping auxiliary utilities"

logged_cmd "Compiling bootstrap utilities" opam install depext --yes

title "Configure: getting system dependencies"

echo "You may be asked for 'sudo' access to install required system dependencies through your package system"
echo
opam depext %{install_packages}%

touch has_depexts
