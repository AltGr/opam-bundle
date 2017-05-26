#!/bin/sh -ue

. $(dirname $0)/common.sh

if [ $# -ne 1 ] || [ "X${1#-}" != "X$1" ] ; then
   echo "Usage: $0 PREFIX"
   echo "  Bootstraps and compiles %{install_packages}%, then installs to the given prefix"
   exit 2
fi
DESTDIR="$1"

if [ ! -e has_depexts ]; then "$DIR/configure.sh"; fi

title "Compile: installing packages"

opam install --yes --destdir "$DESTDIR" %{install_packages}%
