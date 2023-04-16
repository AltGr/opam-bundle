This test verify different repository specifications that could be used with `opam-bundle`.
Every package used is a stub package.

  $ export OPAMNOENVNOTICE=1
  $ export OPAMYES=1
  $ export OPAMROOT=$PWD/OPAMROOT
  $ export OPAMSTATUSLINE=never
  $ export OPAMVERBOSE=-1
  $ opam --version
  2.1.4
Stub executable
  $ cat > compile << EOF
  > #!/bin/sh
  > echo "I'm launching \$(basename \${0}) \$@!"
  > EOF
  $ chmod +x compile
  $ tar czf compile.tar.gz compile
  $ SHA=`openssl sha256 compile.tar.gz | cut -d ' ' -f 2`
OCaml archives setup
4.14
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
  > echo "I'm compiling v.4.14 \$1!"
  > EOF
  $ cp ocaml-4.14.0/ocaml ocaml-4.14.0/ocamlc
  $ cp ocaml-4.14.0/ocaml ocaml-4.14.0/ocamlopt
  $ tar czf ocaml.4.14.tar.gz ocaml-4.14.0
  $ OCAMLSHA414=`openssl sha256 ocaml.4.14.tar.gz | cut -d ' ' -f 2`
4.13
  $ mkdir ocaml-4.13.0
  $ cat > ocaml-4.13.0/configure << EOF
  > set -uex
  > sed -i "s:PREFIX:\$2:g" Makefile
  > echo "configured"
  > EOF
  $ chmod +x ocaml-4.13.0/configure
  $ cat > ocaml-4.13.0/Makefile << EOF
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
  $ cat > ocaml-4.13.0/ocaml << EOF
  > echo "I'm compiling v.4.13 \$1!"
  > EOF
  $ cp ocaml-4.13.0/ocaml ocaml-4.13.0/ocamlc
  $ cp ocaml-4.13.0/ocaml ocaml-4.13.0/ocamlopt
  $ tar czf ocaml.4.13.tar.gz ocaml-4.13.0
  $ OCAMLSHA413=`openssl sha256 ocaml.4.13.tar.gz | cut -d ' ' -f 2`
4.12
  $ mkdir ocaml-4.12.0
  $ cat > ocaml-4.12.0/configure << EOF
  > set -uex
  > sed -i "s:PREFIX:\$2:g" Makefile
  > echo "configured"
  > EOF
  $ chmod +x ocaml-4.12.0/configure
  $ cat > ocaml-4.12.0/Makefile << EOF
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
  $ cat > ocaml-4.12.0/ocaml << EOF
  > echo "I'm compiling v.4.12 \$1!"
  > EOF
  $ cp ocaml-4.12.0/ocaml ocaml-4.12.0/ocamlc
  $ cp ocaml-4.12.0/ocaml ocaml-4.12.0/ocamlopt
  $ tar czf ocaml.4.12.tar.gz ocaml-4.12.0
  $ OCAMLSHA412=`openssl sha256 ocaml.4.12.tar.gz | cut -d ' ' -f 2`
Repos setup
  $ mkdir -p REPO1/packages/ REPO2/packages/ REPO3/packages/
  $ cat > REPO1/repo << EOF
  > opam-version: "2.0"
  > EOF
  $ cat > REPO2/repo << EOF
  > opam-version: "2.0"
  > EOF
  $ cat > REPO3/repo << EOF
  > opam-version: "2.0"
  > EOF
Ocaml-system.4.14.0 package.
  $ mkdir -p REPO1/packages/ocaml-system/ocaml-system.4.14.0
  $ cat > REPO1/packages/ocaml-system/ocaml-system.4.14.0/opam << EOF
  > opam-version: "2.0"
  > EOF
Ocaml.4.14.0 package.
  $ mkdir -p REPO1/packages/ocaml/ocaml.4.14.0
  $ cat > REPO1/packages/ocaml/ocaml.4.14.0/opam << EOF
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
  $ mkdir -p REPO1/packages/ocaml-base-compiler/ocaml-base-compiler.4.14.0
  $ cat > REPO1/packages/ocaml-base-compiler/ocaml-base-compiler.4.14.0/opam << EOF
  > opam-version: "2.0"
  > build: [ "sh" "compile" name ]
  > install: [
  >  [ "chmod" "+x" "compile" ]
  >  [ "cp" "compile" "%{bin}%/ocaml" ]
  > ]
  > url {
  >  src: "file://./ocaml.4.14.tar.gz"
  >  checksum: "sha256=$OCAMLSHA414"
  > }
  > EOF
Ocaml-system.4.13.0 package.
  $ mkdir -p REPO2/packages/ocaml-system/ocaml-system.4.13.0
  $ cat > REPO2/packages/ocaml-system/ocaml-system.4.13.0/opam << EOF
  > opam-version: "2.0"
  > EOF
Ocaml.4.13.0 package.
  $ mkdir -p REPO2/packages/ocaml/ocaml.4.13.0
  $ cat > REPO2/packages/ocaml/ocaml.4.13.0/opam << EOF
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
Ocaml-base-compiler.4.13.0 package.
  $ mkdir -p REPO2/packages/ocaml-base-compiler/ocaml-base-compiler.4.13.0
  $ cat > REPO2/packages/ocaml-base-compiler/ocaml-base-compiler.4.13.0/opam << EOF
  > opam-version: "2.0"
  > build: [ "sh" "compile" name ]
  > install: [
  >  [ "chmod" "+x" "compile" ]
  >  [ "cp" "compile" "%{bin}%/ocaml" ]
  > ]
  > url {
  >  src: "file://./ocaml.4.13.tar.gz"
  >  checksum: "sha256=$OCAMLSHA413"
  > }
  > EOF
Ocaml-system.4.12.0 package.
  $ mkdir -p REPO3/packages/ocaml-system/ocaml-system.4.12.0
  $ cat > REPO3/packages/ocaml-system/ocaml-system.4.12.0/opam << EOF
  > opam-version: "2.0"
  > EOF
Ocaml.4.12.0 package.
  $ mkdir -p REPO3/packages/ocaml/ocaml.4.12.0
  $ cat > REPO3/packages/ocaml/ocaml.4.12.0/opam << EOF
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
Ocaml-base-compiler.4.12.0 package.
  $ mkdir -p REPO3/packages/ocaml-base-compiler/ocaml-base-compiler.4.12.0
  $ cat > REPO3/packages/ocaml-base-compiler/ocaml-base-compiler.4.12.0/opam << EOF
  > opam-version: "2.0"
  > build: [ "sh" "compile" name ]
  > install: [
  >  [ "chmod" "+x" "compile" ]
  >  [ "cp" "compile" "%{bin}%/ocaml" ]
  > ]
  > url {
  >  src: "file://./ocaml.4.12.tar.gz"
  >  checksum: "sha256=$OCAMLSHA412"
  > }
  > EOF
Ocaml-config.2 package.
  $ mkdir -p REPO3/packages/ocaml-config/ocaml-config.2
  $ cat > REPO3/packages/ocaml-config/ocaml-config.2/opam << EOF
  > opam-version: "2.0"
  > EOF
=== Foo package ===
  $ mkdir -p REPO1/packages/foo/foo.1
  $ cat > REPO1/packages/foo/foo.1/opam << EOF
  > opam-version: "2.0"
  > version: "1"
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
  $ mkdir -p REPO2/packages/bar/bar.1
  $ cat > REPO2/packages/bar/bar.1/opam << EOF
  > opam-version: "2.0"
  > version: "1"
  > build: [ "sh" "compile" name ]
  > install: [
  >  [ "cp" "compile" "%{bin}%/%{name}%" ]
  > ]
  > depends : [
  >  "ocaml" {>= "4.13.0"}
  >  "foo"
  > ]
  > url {
  >  src: "file://./compile.tar.gz"
  >  checksum: "sha256=$SHA"
  > }
  > EOF
Opam setup
  $ mkdir $OPAMROOT
  $ opam init --bare repo1 ./REPO1 --no-setup --bypass-checks
  No configuration file found, using built-in defaults.
  
  <><> Fetching repository information ><><><><><><><><><><><><><><><><><><><><><>
  [repo1] Initialised

  $ opam switch create one --empty

  $ opam repo add repo2 ./REPO2 --all-switches
  [repo2] Initialised
  $ opam repo add repo3 ./REPO3 --all-switches
  [repo3] Initialised




Running opam-bundle with sanitized output that contains replaced platform specific information.


============================== Test 1 ==============================


Bundle package foo with and specifyng two repositories with `ocaml.4.12` and second repository containing
only `ocaml.4.14` packages. We are forcing here to use 4.12 from second switch.

  $ opam-bundle foo --repository ./REPO1 --repository ./REPO3 --ocaml=4.12.0 -y 2>&1 | sed 's/arch =.*/arch = $ARCH/;s/os =.*/os = $OS/;s/os-distribution =.*/os-distribution = $OSDISTRIB/;s/os-version =.*/os-version = $OSVERSION/;s/os-family =.*/os-family = $OSFAMILLY/'
  OCaml version is set to 4.12.0.
  No opam version selected, will use 2.1.4.
  No environment specified, will use the following for package resolution (based on the host system):
    - arch = $ARCH
    - os = $OS
    - os-distribution = $OSDISTRIB
    - os-version = $OSVERSION
    - os-family = $OSFAMILLY
  
  <><> Initialising repositories ><><><><><><><><><><><><><><><><><><><><><><><><>
  [home] Initialised
  [home1] Initialised
  
  <><> Resolving package set ><><><><><><><><><><><><><><><><><><><><><><><><><><>
  The following packages will be included:
    - foo.1
    - ocaml.4.12.0
    - ocaml-base-compiler.4.12.0
    - ocaml-bootstrap.4.12.0
    - ocaml-config.2
  According to the packages' metadata, the bundle should be installable on any arch/OS.
  [NOTE] Opam system sandboxing (introduced in 2.0) will be disabled in the bundle. You need to trust that the build scripts of the included packages don't write outside of their build directory and dest dir.
  Continue ? [Y/n] y
  
  <><> Getting all archives <><><><><><><><><><><><><><><><><><><><><><><><><><><>
  
  <><> Getting bootstrap packages <><><><><><><><><><><><><><><><><><><><><><><><>
  
  <><> Building bundle ><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
  Done. Bundle generated as $TESTCASE_ROOT/foo-bundle.tar.gz



============================== Test 2 ==============================



Bundle packages foo and bar with specifying three repositories with `foo` and second repository containing `bar`
package and third containing required ocaml-config.2. We are forcing here to use 4.13 from switch.

  $ opam-bundle foo bar --repository ./REPO1 --repository ./REPO2 --repository ./REPO3 --ocaml=4.13.0 -y 2>&1 | sed 's/arch =.*/arch = $ARCH/;s/os =.*/os = $OS/;s/os-distribution =.*/os-distribution = $OSDISTRIB/;s/os-version =.*/os-version = $OSVERSION/;s/os-family =.*/os-family = $OSFAMILLY/'
  OCaml version is set to 4.13.0.
  No opam version selected, will use 2.1.4.
  No environment specified, will use the following for package resolution (based on the host system):
    - arch = $ARCH
    - os = $OS
    - os-distribution = $OSDISTRIB
    - os-version = $OSVERSION
    - os-family = $OSFAMILLY
  
  <><> Initialising repositories ><><><><><><><><><><><><><><><><><><><><><><><><>
  [home] Initialised
  [home1] Initialised
  [home2] Initialised
  
  <><> Resolving package set ><><><><><><><><><><><><><><><><><><><><><><><><><><>
  The following packages will be included:
    - bar.1
    - foo.1
    - ocaml.4.13.0
    - ocaml-base-compiler.4.13.0
    - ocaml-bootstrap.4.13.0
    - ocaml-config.2
  According to the packages' metadata, the bundle should be installable on any arch/OS.
  [NOTE] Opam system sandboxing (introduced in 2.0) will be disabled in the bundle. You need to trust that the build scripts of the included packages don't write outside of their build directory and dest dir.
  Continue ? [Y/n] y
  
  <><> Getting all archives <><><><><><><><><><><><><><><><><><><><><><><><><><><>
  
  <><> Getting bootstrap packages <><><><><><><><><><><><><><><><><><><><><><><><>
  
  <><> Building bundle ><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
  Done. Bundle generated as $TESTCASE_ROOT/foo-bundle.tar.gz



============================== Test 3 (fail) ==============================



Trying bundle foo package with a repository that hasn't required package (ocaml-config). That should fail.

  $ opam-bundle foo --repository ./REPO1 --ocaml=4.14.0 -y 2>&1 | sed 's/arch =.*/arch = $ARCH/;s/os =.*/os = $OS/;s/os-distribution =.*/os-distribution = $OSDISTRIB/;s/os-version =.*/os-version = $OSVERSION/;s/os-family =.*/os-family = $OSFAMILLY/'
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
  [ERROR] No solution for foo & ocaml-bootstrap.4.14.0:   * Missing dependency:
              - ocaml-config
              unknown package
  
  



============================== Test 4 (fail) ==============================


Trying bundle foo package with a repositories that hasn't required ocaml version. That should fail.

  $ opam-bundle foo --repository ./REPO1 --repository ./REPO3 --ocaml=4.13.0 -y 2>&1 | sed 's/arch =.*/arch = $ARCH/;s/os =.*/os = $OS/;s/os-distribution =.*/os-distribution = $OSDISTRIB/;s/os-version =.*/os-version = $OSVERSION/;s/os-family =.*/os-family = $OSFAMILLY/'
  OCaml version is set to 4.13.0.
  No opam version selected, will use 2.1.4.
  No environment specified, will use the following for package resolution (based on the host system):
    - arch = $ARCH
    - os = $OS
    - os-distribution = $OSDISTRIB
    - os-version = $OSVERSION
    - os-family = $OSFAMILLY
  
  <><> Initialising repositories ><><><><><><><><><><><><><><><><><><><><><><><><>
  [home] Initialised
  [home1] Initialised
  [ERROR] Package ocaml-system.4.13.0 not found in the repositories
