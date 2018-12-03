#!/bin/bash

#set -x

PKGS=`opam search | awk '!/^#/{print $1}'`

if which par > /dev/null; then
    # par: https://github.com/UnixJunkie/PAR
    for pkg in `echo $PKGS`; do
        echo opam-bundle -y $pkg
    done > for_par.sh
    par -i for_par.sh -v -o log.txt
else
  for pkg in `echo $PKGS`; do
      (opam-bundle -y $pkg 2>&1) > ${pkg}.log || echo "KO: "$pkg
  done
fi
