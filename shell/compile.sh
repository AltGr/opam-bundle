#!/bin/sh -ue

. "$(dirname "$0")/common.sh"

usage() {
   echo "Usage: $0 [OPTIONS] PREFIX"
   echo "  Bootstraps and compiles %{install_packages}% within $DIR,"
   echo "  then installs wrappers to the given PREFIX if specified."
   echo
   echo "Options:"
   echo "  -h --help		show this help"
   echo "  -l --list		list the opam packages included"
   echo "  -y --yes		don't stop for confirmation"
   exit $1
}

DESTDIR=
YES=
while [ $# -gt 0 ]; do
  case "$1" in
    -h|--help) usage 0;;
    -l|--list) echo "%{install_packages}%"; exit 0;;
    -y|--yes) YES=1;;
    -*) usage 2;;
    *)
      if [ -z "$DESTDIR" ]; then DESTDIR=$1
      else usage 2; fi
  esac
  shift
done

if [ "X${DIR#/tmp}" != "X$DIR" ] && [ -z "$YES" ]; then
  echo "ERROR: you are going to install into /tmp. Everything is likely to get wiped"
  echo "       on reboot."
  echo "       Move to a more permanent location, or use '--yes' to force."
  exit 1
fi

if [ -z "$DESTDIR" ]; then
  echo "This bundle will compile the application to $DIR, WITHOUT installing"
  echo "wrappers anywhere else."
else
  echo "This bundle will compile the application to $DIR, and put wrappers into"
  echo "$DESTDIR/bin. You will need to retain $DIR for the wrappers to work."
fi

if [ -z "$YES" ]; then printf "\nPress enter to continue... "; read _; fi

if [ ! -e has_depexts ]; then "$DIR/configure.sh"; fi

start

title "Compile: installing packages"

echo "Output is in $LOG"
logged_cmd "Compiling packages" opam install --yes %{install_packages}% %{doc?--with-doc:}% %{test?--with-test:}%
logged_cmd "Cleaning up" opam clean --yes

if [ -z "$DESTDIR" ]; then
    echo
    echo "All compiled within $DIR. To use the compiled packages:"
    echo
    echo "  - either re-run $0 with a PREFIX argument to install command wrappers"
    echo "    (it won't recompile everything)"
    echo
    echo '  - or run the following to update the environment in the current shell, so that'
    echo '    they are in your PATH:'
    echo "      export PATH=\"$PREFIX/bin:\$PATH\"; eval \$(opam env --root \"$OPAMROOT\" --set-root)"
    echo
    finished
    exit 0
fi

if [ -w "$DESTDIR/bin" ] || mkdir -p "$DESTDIR/bin" >/dev/null 2>&1 && [ -w "$DESTDIR/bin" ]; then
    SUDO=""
else
    echo "No write access to $DESTDIR/bin, will use 'sudo'."
    SUDO="sudo --"
fi
bin_prefix=$(opam var bin)
opam show --list-files %{install_packages}% | grep "^$bin_prefix" | $SUDO sh -uec "
  mkdir -p '$DESTDIR/bin'
  while read -r bin; do
    WRAPPER=\"$DESTDIR/bin/\$(basename \"\$bin\")\"
    if [ -e \"\$WRAPPER\" ]; then
        echo \"Warning: \$WRAPPER exists already, not overwriting.\"
    else
        cat <<EOF >\"\$WRAPPER\"
#!/bin/sh -e
export PATH=\"$PREFIX/bin:\\\$PATH\"
exec \"$PREFIX/bin/opam\" exec --root \"$OPAMROOT\" --readonly -- \"\$bin\" \"\\\$@\"
EOF
        chmod a+x \"\$WRAPPER\"
        printf \"Wrapper \\033[1m\$(basename \$bin)\\033[m installed successfully.\\n\"
    fi
  done
"
finished
