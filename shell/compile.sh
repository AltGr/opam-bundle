#!/bin/sh -ue

. "$(dirname "$0")/common.sh"

if [ $# -eq 0 ]; then
    DESTDIR=
elif [ $# -eq 1 ] && [ "X${1#-}" = "X$1" ]; then
    DESTDIR=$1
else
   echo "Usage: $0 PREFIX"
   echo "  Bootstraps and compiles %{install_packages}% within $OPAMROOT,"
   echo "  then installs wrappers to the given prefix"
   exit 2
fi

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
    echo
    echo '  - or run the following to update the environment in the current shell, so that'
    echo '    they are in your PATH:'
    echo "      export PATH=\"$PREFIX/bin:\$PATH\"; eval \$(opam env --root \"$OPAMROOT\")"
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
export PATH=\"$PREFIX/bin:\$PATH\"
exec \"$PREFIX/bin/opam\" exec --root \"$OPAMROOT\" --readonly -- \"\$bin\" \"\\\$@\"
EOF
        chmod a+x \"\$WRAPPER\"
        printf \"Wrapper \\033[1m\$(basename \$bin)\\033[m installed successfully.\\n\"
    fi
  done
"
finished
