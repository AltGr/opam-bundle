This test verify different environment specifications that could be used with `opam-bundle`.
Every package used is a stub package.

Repo initial setup with three packages `foo`, `bar`, and `baz`, with specific availabilities
  $ export OPAMNOENVNOTICE=1
  $ export OPAMYES=1
  $ export OPAMROOT=$PWD/OPAMROOT
  $ export OPAMSTATUSLINE=never
  $ export OPAMVERBOSE=-1
Stub executable
  $ cat > compile << EOF
  > #!/bin/sh
  > echo "I'm launching \$(basename \${0}) \$@!"
  > EOF
  $ chmod +x compile
  $ tar czf compile.tar.gz compile
  $ SHA=`openssl sha256 compile.tar.gz | cut -d ' ' -f 2`
OCaml archive setup
  $ mkdir ocaml-4.14.0
  $ cat > ocaml-4.14.0/configure << EOF
  > set -uex
  > sed -i "s:PREFIX:\$2:g" Makefile
  > echo "configured"
  > EOF
  $ chmod +x ocaml-4.14.0/configure
  $ cat > ocaml-4.14.0/Makefile << EOF
  > world:
  > 	echo "make world"
  > world.opt:
  > 	echo "world opt"
  > install:
  > 	mkdir -p PREFIX/bin/
  > 	cp ocaml PREFIX/bin/
  > 	cp ocamlc PREFIX/bin/
  > 	cp ocamlopt PREFIX/bin/
  > 	cp $(which opam) PREFIX/bin/
  > EOF
  $ cat > ocaml-4.14.0/ocaml << EOF
  > echo "I'm compiling \$1!"
  > EOF
  $ cp ocaml-4.14.0/ocaml ocaml-4.14.0/ocamlc
  $ cp ocaml-4.14.0/ocaml ocaml-4.14.0/ocamlopt
  $ tar czf ocaml.tar.gz ocaml-4.14.0
  $ OCAMLSHA=`openssl sha256 ocaml.tar.gz | cut -d ' ' -f 2`
Repo setup
  $ mkdir -p REPO/packages/
  $ cat > REPO/repo << EOF
  > opam-version: "2.0"
  > EOF
=== Foo package (not available on linux) ===
  $ mkdir -p REPO/packages/foo/foo.1
  $ cat > REPO/packages/foo/foo.1/opam << EOF
  > opam-version: "2.0"
  > version: "1"
  > available: (os != "linux")
  > build: [ "sh" "compile" name ]
  > install: [
  >  [ "cp" "compile" "%{bin}%/%{name}%" ]
  > ]
  > depends : [
  >  "ocaml" {>= "4.12.0"}
  > ]
  > url {
  >  src: "file://./compile.tar.gz"
  >  checksum: "sha256=$SHA"
  > }
  > EOF
=== Bar package (not available on cygwin) ===
  $ mkdir -p REPO/packages/bar/bar.1
  $ cat > REPO/packages/bar/bar.1/opam << EOF
  > opam-version: "2.0"
  > version: "1"
  > available: (os != "cygwin")
  > build: [ "sh" "compile" name ]
  > install: [
  >  [ "cp" "compile" "%{bin}%/%{name}%" ]
  > ]
  > depends : [
  >  "ocaml" {>= "4.14.0"}
  > ]
  > url {
  >  src: "file://./compile.tar.gz"
  >  checksum: "sha256=$SHA"
  > }
  > EOF
=== Baz packages (available on both) ===
  $ mkdir -p REPO/packages/baz/baz.1
  $ cat > REPO/packages/baz/baz.1/opam << EOF
  > opam-version: "2.0"
  > version: "1"
  > build: [ "sh" "compile" name ]
  > install: [
  >  [ "cp" "compile" "%{bin}%/%{name}%" ]
  > ]
  > depends : [
  >  "ocaml" {>= "4.14.0"}
  >  "foo" { os != "linux" }
  >  "bar" { os != "cygwin" }
  > ]
  > url {
  >  src: "file://./compile.tar.gz"
  >  checksum: "sha256=$SHA"
  > }
  > EOF
Ocaml-system.4.14.0 package.
  $ mkdir -p REPO/packages/ocaml-system/ocaml-system.4.14.0
  $ cat > REPO/packages/ocaml-system/ocaml-system.4.14.0/opam << EOF
  > opam-version: "2.0"
  > EOF
Ocaml-config.2 package.
  $ mkdir -p REPO/packages/ocaml-config/ocaml-config.2
  $ cat > REPO/packages/ocaml-config/ocaml-config.2/opam << EOF
  > opam-version: "2.0"
  > EOF
Ocaml.4.14.0 package.
  $ mkdir -p REPO/packages/ocaml/ocaml.4.14.0
  $ cat > REPO/packages/ocaml/ocaml.4.14.0/opam << EOF
  > opam-version: "2.0"
  > depends: [
  >   ("ocaml-system" | "ocaml-base-compiler")
  >   "ocaml-config"
  > ]
  > url {
  >  src: "file://./compile.tar.gz"
  >  checksum: "sha256=$SHA"
  > }
  > EOF
Ocaml-base-compiler.4.14.0 package.
  $ mkdir -p REPO/packages/ocaml-base-compiler/ocaml-base-compiler.4.14.0
  $ cat > REPO/packages/ocaml-base-compiler/ocaml-base-compiler.4.14.0/opam << EOF
  > opam-version: "2.0"
  > build: [ "sh" "compile" name ]
  > install: [
  >  [ "chmod" "+x" "compile" ]
  >  [ "cp" "compile" "%{bin}%/ocaml" ]
  > ]
  > url {
  >  src: "file://./ocaml.tar.gz"
  >  checksum: "sha256=$OCAMLSHA"
  > }
  > EOF
Opam setup
  $ mkdir $OPAMROOT
  $ opam init --bare ./REPO --no-setup --bypass-checks
  No configuration file found, using built-in defaults.
  
  <><> Fetching repository information ><><><><><><><><><><><><><><><><><><><><><>
  [default] Initialised
  $ opam switch create one --empty



Running opam-bundle with sanitized output that contains replaced platform specific information.


============================== Test 1 ==============================


Bundle package `baz`, without '--environment' option. That should lookup current platform (that should be linux), and filter packages in dependencies that
are available on linux os (`foo` not included).

  $ opam-bundle baz --repository ./REPO --ocaml=4.14.0 -y 2>&1 | sed 's/arch =.*/arch = $ARCH/;s/os =.*/os = $OS/;s/os-distribution =.*/os-distribution = $OSDISTRIB/;s/os-version =.*/os-version = $OSVERSION/;s/os-family =.*/os-family = $OSFAMILLY/'
  OCaml version is set to 4.14.0.
  No opam version selected, will use 2.1.4.
  No environment specified, will use the following for package resolution (based on the host system):
    - arch = $ARCH
    - os = $OS
    - os-distribution = $OSDISTRIB
    - os-version = $OSVERSION
    - os-family = $OSFAMILLY
  
  <><> Initialising repositories ><><><><><><><><><><><><><><><><><><><><><><><><>
  [home] Initialised
  
  <><> Resolving package set ><><><><><><><><><><><><><><><><><><><><><><><><><><>
  The following packages will be included:
    - bar.1
    - baz.1
    - ocaml.4.14.0
    - ocaml-base-compiler.4.14.0
    - ocaml-bootstrap.4.14.0
    - ocaml-config.2
  The bundle will be installable on systems matching the following: os != "cygwin"
  [NOTE] Opam system sandboxing (introduced in 2.0) will be disabled in the bundle. You need to trust that the build scripts of the included packages don't write outside of their build directory and dest dir.
  Continue ? [Y/n] y
  
  <><> Getting all archives <><><><><><><><><><><><><><><><><><><><><><><><><><><>
  
  <><> Getting bootstrap packages <><><><><><><><><><><><><><><><><><><><><><><><>
  
  <><> Building bundle ><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
  Done. Bundle generated as $TESTCASE_ROOT/baz-bundle.tar.gz
  $ tar --list -f baz-bundle.tar.gz | grep -v sha256 | sort
  baz-bundle/
  baz-bundle/bootstrap.sh
  baz-bundle/common.sh
  baz-bundle/compile.sh
  baz-bundle/configure.sh
  baz-bundle/opam-full-2.1.4.tar.gz
  baz-bundle/repo/
  baz-bundle/repo/archives/
  baz-bundle/repo/archives/bar.1/
  baz-bundle/repo/archives/bar.1/compile.tar.gz
  baz-bundle/repo/archives/baz.1/
  baz-bundle/repo/archives/baz.1/compile.tar.gz
  baz-bundle/repo/archives/ocaml-base-compiler.4.14.0/
  baz-bundle/repo/archives/ocaml-base-compiler.4.14.0/ocaml.tar.gz
  baz-bundle/repo/archives/ocaml.4.14.0/
  baz-bundle/repo/archives/ocaml.4.14.0/compile.tar.gz
  baz-bundle/repo/cache/
  baz-bundle/repo/packages/
  baz-bundle/repo/packages/bar/
  baz-bundle/repo/packages/bar/bar.1/
  baz-bundle/repo/packages/bar/bar.1/opam
  baz-bundle/repo/packages/baz/
  baz-bundle/repo/packages/baz/baz.1/
  baz-bundle/repo/packages/baz/baz.1/opam
  baz-bundle/repo/packages/ocaml-base-compiler/
  baz-bundle/repo/packages/ocaml-base-compiler/ocaml-base-compiler.4.14.0/
  baz-bundle/repo/packages/ocaml-base-compiler/ocaml-base-compiler.4.14.0/opam
  baz-bundle/repo/packages/ocaml-bootstrap/
  baz-bundle/repo/packages/ocaml-bootstrap/ocaml-bootstrap.4.14.0/
  baz-bundle/repo/packages/ocaml-bootstrap/ocaml-bootstrap.4.14.0/opam
  baz-bundle/repo/packages/ocaml-config/
  baz-bundle/repo/packages/ocaml-config/ocaml-config.2/
  baz-bundle/repo/packages/ocaml-config/ocaml-config.2/opam
  baz-bundle/repo/packages/ocaml/
  baz-bundle/repo/packages/ocaml/ocaml.4.14.0/
  baz-bundle/repo/packages/ocaml/ocaml.4.14.0/opam
  baz-bundle/repo/repo

Cleaning up
  $ rm baz-bundle.tar.gz



============================== Test 2 ==============================


Bundle package `baz`, with os="cygwin" constraint specified in '--environment' option. That should filter packages in dependencies that
are available on cygwin os (`bar` not included).

  $ opam-bundle baz --environment os="cygwin" --repository ./REPO --ocaml=4.14.0 -y 2>&1
  OCaml version is set to 4.14.0.
  No opam version selected, will use 2.1.4.
  
  <><> Initialising repositories ><><><><><><><><><><><><><><><><><><><><><><><><>
  [home] Initialised
  
  <><> Resolving package set ><><><><><><><><><><><><><><><><><><><><><><><><><><>
  The following packages will be included:
    - baz.1
    - foo.1
    - ocaml.4.14.0
    - ocaml-base-compiler.4.14.0
    - ocaml-bootstrap.4.14.0
    - ocaml-config.2
  The bundle will be installable on systems matching the following: os != "linux"
  [NOTE] Opam system sandboxing (introduced in 2.0) will be disabled in the bundle. You need to trust that the build scripts of the included packages don't write outside of their build directory and dest dir.
  Continue ? [Y/n] y
  
  <><> Getting all archives <><><><><><><><><><><><><><><><><><><><><><><><><><><>
  
  <><> Getting bootstrap packages <><><><><><><><><><><><><><><><><><><><><><><><>
  
  <><> Building bundle ><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
  Done. Bundle generated as $TESTCASE_ROOT/baz-bundle.tar.gz


  $ tar --list -f baz-bundle.tar.gz | grep -v sha256 | sort
  baz-bundle/
  baz-bundle/bootstrap.sh
  baz-bundle/common.sh
  baz-bundle/compile.sh
  baz-bundle/configure.sh
  baz-bundle/opam-full-2.1.4.tar.gz
  baz-bundle/repo/
  baz-bundle/repo/archives/
  baz-bundle/repo/archives/baz.1/
  baz-bundle/repo/archives/baz.1/compile.tar.gz
  baz-bundle/repo/archives/foo.1/
  baz-bundle/repo/archives/foo.1/compile.tar.gz
  baz-bundle/repo/archives/ocaml-base-compiler.4.14.0/
  baz-bundle/repo/archives/ocaml-base-compiler.4.14.0/ocaml.tar.gz
  baz-bundle/repo/archives/ocaml.4.14.0/
  baz-bundle/repo/archives/ocaml.4.14.0/compile.tar.gz
  baz-bundle/repo/cache/
  baz-bundle/repo/packages/
  baz-bundle/repo/packages/baz/
  baz-bundle/repo/packages/baz/baz.1/
  baz-bundle/repo/packages/baz/baz.1/opam
  baz-bundle/repo/packages/foo/
  baz-bundle/repo/packages/foo/foo.1/
  baz-bundle/repo/packages/foo/foo.1/opam
  baz-bundle/repo/packages/ocaml-base-compiler/
  baz-bundle/repo/packages/ocaml-base-compiler/ocaml-base-compiler.4.14.0/
  baz-bundle/repo/packages/ocaml-base-compiler/ocaml-base-compiler.4.14.0/opam
  baz-bundle/repo/packages/ocaml-bootstrap/
  baz-bundle/repo/packages/ocaml-bootstrap/ocaml-bootstrap.4.14.0/
  baz-bundle/repo/packages/ocaml-bootstrap/ocaml-bootstrap.4.14.0/opam
  baz-bundle/repo/packages/ocaml-config/
  baz-bundle/repo/packages/ocaml-config/ocaml-config.2/
  baz-bundle/repo/packages/ocaml-config/ocaml-config.2/opam
  baz-bundle/repo/packages/ocaml/
  baz-bundle/repo/packages/ocaml/ocaml.4.14.0/
  baz-bundle/repo/packages/ocaml/ocaml.4.14.0/opam
  baz-bundle/repo/repo

Cleaning up
  $ rm baz-bundle.tar.gz



============================== Test 3 ==============================


Bundle package `baz`, with empty constraint specified in '--environment' option. That shouldn't filter any packages (considering 'any' constraint) and install
all dependencies.

  $ opam-bundle baz --environment --repository ./REPO --ocaml=4.14.0 -y 2>&1
  OCaml version is set to 4.14.0.
  No opam version selected, will use 2.1.4.
  [NOTE] Empty environment
  
  <><> Initialising repositories ><><><><><><><><><><><><><><><><><><><><><><><><>
  [home] Initialised
  
  <><> Resolving package set ><><><><><><><><><><><><><><><><><><><><><><><><><><>
  The following packages will be included:
    - bar.1
    - baz.1
    - foo.1
    - ocaml.4.14.0
    - ocaml-base-compiler.4.14.0
    - ocaml-bootstrap.4.14.0
    - ocaml-config.2
  The bundle will be installable on systems matching the following: os != "cygwin" & os != "linux"
  [NOTE] Opam system sandboxing (introduced in 2.0) will be disabled in the bundle. You need to trust that the build scripts of the included packages don't write outside of their build directory and dest dir.
  Continue ? [Y/n] y
  
  <><> Getting all archives <><><><><><><><><><><><><><><><><><><><><><><><><><><>
  
  <><> Getting bootstrap packages <><><><><><><><><><><><><><><><><><><><><><><><>
  
  <><> Building bundle ><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
  Done. Bundle generated as $TESTCASE_ROOT/baz-bundle.tar.gz


  $ tar --list -f baz-bundle.tar.gz | grep -v sha256 | sort
  baz-bundle/
  baz-bundle/bootstrap.sh
  baz-bundle/common.sh
  baz-bundle/compile.sh
  baz-bundle/configure.sh
  baz-bundle/opam-full-2.1.4.tar.gz
  baz-bundle/repo/
  baz-bundle/repo/archives/
  baz-bundle/repo/archives/bar.1/
  baz-bundle/repo/archives/bar.1/compile.tar.gz
  baz-bundle/repo/archives/baz.1/
  baz-bundle/repo/archives/baz.1/compile.tar.gz
  baz-bundle/repo/archives/foo.1/
  baz-bundle/repo/archives/foo.1/compile.tar.gz
  baz-bundle/repo/archives/ocaml-base-compiler.4.14.0/
  baz-bundle/repo/archives/ocaml-base-compiler.4.14.0/ocaml.tar.gz
  baz-bundle/repo/archives/ocaml.4.14.0/
  baz-bundle/repo/archives/ocaml.4.14.0/compile.tar.gz
  baz-bundle/repo/cache/
  baz-bundle/repo/packages/
  baz-bundle/repo/packages/bar/
  baz-bundle/repo/packages/bar/bar.1/
  baz-bundle/repo/packages/bar/bar.1/opam
  baz-bundle/repo/packages/baz/
  baz-bundle/repo/packages/baz/baz.1/
  baz-bundle/repo/packages/baz/baz.1/opam
  baz-bundle/repo/packages/foo/
  baz-bundle/repo/packages/foo/foo.1/
  baz-bundle/repo/packages/foo/foo.1/opam
  baz-bundle/repo/packages/ocaml-base-compiler/
  baz-bundle/repo/packages/ocaml-base-compiler/ocaml-base-compiler.4.14.0/
  baz-bundle/repo/packages/ocaml-base-compiler/ocaml-base-compiler.4.14.0/opam
  baz-bundle/repo/packages/ocaml-bootstrap/
  baz-bundle/repo/packages/ocaml-bootstrap/ocaml-bootstrap.4.14.0/
  baz-bundle/repo/packages/ocaml-bootstrap/ocaml-bootstrap.4.14.0/opam
  baz-bundle/repo/packages/ocaml-config/
  baz-bundle/repo/packages/ocaml-config/ocaml-config.2/
  baz-bundle/repo/packages/ocaml-config/ocaml-config.2/opam
  baz-bundle/repo/packages/ocaml/
  baz-bundle/repo/packages/ocaml/ocaml.4.14.0/
  baz-bundle/repo/packages/ocaml/ocaml.4.14.0/opam
  baz-bundle/repo/repo

Cleaning up
  $ rm baz-bundle.tar.gz



============================== Test 4 (fail) ==============================

Trying bundle package `bar` on cygwin. That will fail, since this package isn't available on cygwin.


  $ opam-bundle bar --environment os="cygwin" --repository ./REPO --ocaml=4.14.0 -y 2>&1
  OCaml version is set to 4.14.0.
  No opam version selected, will use 2.1.4.
  
  <><> Initialising repositories ><><><><><><><><><><><><><><><><><><><><><><><><>
  [home] Initialised
  
  <><> Resolving package set ><><><><><><><><><><><><><><><><><><><><><><><><><><>
  [ERROR] The following packages do not exist in the specified repositories, or are not available with the given configuration:
            - bar: unmet availability conditions: 'os != "cygwin"'
  
  [5]
