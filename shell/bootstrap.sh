#!/bin/sh -ue

. "$(dirname "$0")/common.sh"

start

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
