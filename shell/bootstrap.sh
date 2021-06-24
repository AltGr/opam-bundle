#!/bin/sh -ue

. "$(dirname "$0")/common.sh"

start

title "Bootstrap: checking for prerequisites"

# Avoid interference from an existing opam installation
eval $(opam env --revert 2>/dev/null) >/dev/null 2>&1 || true
unset OPAMSWITCH

MISSING=
check_prereq() {
    NAME="$1"
    printf "Checking for $*... "
    while [ $# -gt 0 ]; do
        if type "$1" >/dev/null 2>&1 ; then break; fi
        shift
    done
    if [ $# -gt 0 ]; then
        printf "\033[32mfound\033[m\n"
    else
        printf "\033[31mnot found\033[m\n"
        MISSING="$MISSING $NAME"
    fi
}
check_prereq cc
check_prereq make
check_prereq wget curl
check_prereq patch
check_prereq unzip
check_prereq bunzip2
check_prereq rsync

if [ -n "$MISSING" ]; then
    printf "This source bundle requires the following tools to bootstrap, and they are\n"
    printf "absent from this system. Please install them first:\n   $MISSING\n\n"
    finished
    exit 10
fi

if [ -x "$PREFIX/bin/ocamlc" ]; then
   echo "Already compiled OCaml found"
else
   title "Bootstrap: compiling OCaml"

   echo "This may take a while. Output is in $LOG"
   logged_cmd "Uncompressing" tar xzf repo/archives/ocaml-base-compiler."%{ocamlv}%"/*
   cd "ocaml-%{ocamlv}%"
   logged_cmd "Configuring" ./configure -prefix "$PREFIX"
   logged_cmd "Compiling" make world world.opt
   logged_cmd "Installing to temp prefix" make install
   cd "$DIR"
   rm -rf "ocaml-%{ocamlv}%"
fi

if [ -x "$PREFIX/bin/opam" ]; then
   echo "Already compiled opam found"
else
   title "Bootstrap: compiling opam"

   echo "This may take a while. Output is in $LOG"
   logged_cmd "Uncompressing" tar xzf "%{opam_archive}%"
   cd $(basename "%{opam_archive}%" .tar.gz)
   logged_cmd "Configuring" ./configure --prefix "$PREFIX"
   logged_cmd "Compiling extra dependencies" make lib-ext
   logged_cmd "Compiling" make
   logged_cmd "Installing to temp prefix" make install
   cd "$DIR"
   rm -rf $(basename "%{opam_archive}%" .tar.gz)
fi

finished
