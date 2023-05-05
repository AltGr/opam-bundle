This test verify basic functionalities of `opam-bundle`. Every package used is a stub package.
More complex tests on various options could be found in *stub* directory. Tests with real repositories
and packages are under *complex* directory.

Repo initial setup with two packages `foo` and `bar` that depends on `foo` and other required packages.
  $ export OPAMNOENVNOTICE=1
  $ export OPAMYES=1
  $ export OPAMROOT=$PWD/OPAMROOT
  $ export OPAMSTATUSLINE=never
  $ export OPAMVERBOSE=-1
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
Foo package.
  $ mkdir -p REPO/packages/foo/foo.1
  $ cat > REPO/packages/foo/foo.1/opam << EOF
  > opam-version: "2.0"
  > build: [ "sh" "compile" name ]
  > install: [
  >  [ "cp" "compile" "%{bin}%/%{name}%" ]
  > ]
  > url {
  >  src: "file://./compile.tar.gz"
  >  checksum: "sha256=$SHA"
  > }
  > EOF
Bar package.
  $ mkdir -p REPO/packages/bar/bar.1
  $ cat > REPO/packages/bar/bar.1/opam << EOF
  > opam-version: "2.0"
  > build: [ "sh" "compile" name ]
  > install: [
  >  [ "cp" "compile" "%{bin}%/%{name}%" ]
  > ]
  > depends: [ "foo" ]
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



Running opam-bundle with sanitized output that contains remplaced platform specific information.


============================== Test 1 ==============================


Bundle single package `foo`.

  $ opam-bundle foo.1 --repository ./REPO --ocaml=4.14.0 -y 2>&1 | sed 's/arch =.*/arch = $ARCH/;s/os =.*/os = $OS/;s/os-distribution =.*/os-distribution = $OSDISTRIB/;s/os-version =.*/os-version = $OSVERSION/;s/os-family =.*/os-family = $OSFAMILLY/'
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
    - foo.1
    - ocaml-base-compiler.4.14.0
    - ocaml-bootstrap.4.14.0
  According to the packages' metadata, the bundle should be installable on any arch/OS.
  [NOTE] Opam system sandboxing (introduced in 2.0) will be disabled in the bundle. You need to trust that the build scripts of the included packages don't write outside of their build directory and dest dir.
  Continue ? [Y/n] y
  
  <><> Getting all archives <><><><><><><><><><><><><><><><><><><><><><><><><><><>
  
  <><> Getting bootstrap packages <><><><><><><><><><><><><><><><><><><><><><><><>
  
  <><> Building bundle ><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
  Done. Bundle generated as $TESTCASE_ROOT/foo-bundle.tar.gz
  $ tar xvf foo-bundle.tar.gz | grep -v sha256 | sort
  foo-bundle/
  foo-bundle/bootstrap.sh
  foo-bundle/common.sh
  foo-bundle/compile.sh
  foo-bundle/configure.sh
  foo-bundle/opam-full-2.1.4.tar.gz
  foo-bundle/repo/
  foo-bundle/repo/archives/
  foo-bundle/repo/archives/foo.1/
  foo-bundle/repo/archives/foo.1/compile.tar.gz
  foo-bundle/repo/archives/ocaml-base-compiler.4.14.0/
  foo-bundle/repo/archives/ocaml-base-compiler.4.14.0/ocaml.tar.gz
  foo-bundle/repo/cache/
  foo-bundle/repo/packages/
  foo-bundle/repo/packages/foo/
  foo-bundle/repo/packages/foo/foo.1/
  foo-bundle/repo/packages/foo/foo.1/opam
  foo-bundle/repo/packages/ocaml-base-compiler/
  foo-bundle/repo/packages/ocaml-base-compiler/ocaml-base-compiler.4.14.0/
  foo-bundle/repo/packages/ocaml-base-compiler/ocaml-base-compiler.4.14.0/opam
  foo-bundle/repo/packages/ocaml-bootstrap/
  foo-bundle/repo/packages/ocaml-bootstrap/ocaml-bootstrap.4.14.0/
  foo-bundle/repo/packages/ocaml-bootstrap/ocaml-bootstrap.4.14.0/opam
  foo-bundle/repo/repo
  $ sh ./foo-bundle/compile.sh
  This bundle will compile the application to $TESTCASE_ROOT/foo-bundle, WITHOUT installing
  wrappers anywhere else.
  
  Press enter to continue... 
  ================ Bootstrap: checking for prerequisites         ================
  
  Checking for cc... found
  Checking for make... found
  Checking for wget curl... found
  Checking for patch... found
  Checking for unzip... found
  Checking for bunzip2... found
  Checking for rsync... found
  
  ================ Bootstrap: compiling OCaml                    ================
  
  This may take a while. Output is in $TESTCASE_ROOT/foo-bundle/bootstrap.log
  Uncompressing... done
  Configuring... done
  Compiling... done
  Installing to temp prefix... done
  Already compiled opam found
  
  ================ Configure: initialising opam                  ================
  
  Output is in $TESTCASE_ROOT/foo-bundle/configure.log
  Initialising... done
  Creating sandbox... done
  
  ================ Compile: installing packages                  ================
  
  Output is in $TESTCASE_ROOT/foo-bundle/compile.log
  Compiling packages... done
  Cleaning up... done
  
  All compiled within $TESTCASE_ROOT/foo-bundle. To use the compiled packages:
  
    - either re-run ./foo-bundle/compile.sh with a PREFIX argument to install command wrappers
      (it won't recompile everything)
  
    - or run the following to update the environment in the current shell, so that
      they are in your PATH:
        export PATH="$TESTCASE_ROOT/foo-bundle/bootstrap/bin:$PATH"; eval $(opam env --root "$TESTCASE_ROOT/foo-bundle/opam" --set-root)
  
  $ opam exec --root ./foo-bundle/opam -- foo
  I'm launching foo !


============================== Test 2 ==============================


Bundle package `bar` that depends on `foo`.

  $ opam-bundle bar.1 --repository ./REPO --ocaml=4.14.0 -y 2>&1 | sed 's/arch =.*/arch = $ARCH/;s/os =.*/os = $OS/;s/os-distribution =.*/os-distribution = $OSDISTRIB/;s/os-version =.*/os-version = $OSVERSION/;s/os-family =.*/os-family = $OSFAMILLY/'
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
    - foo.1
    - ocaml-base-compiler.4.14.0
    - ocaml-bootstrap.4.14.0
  According to the packages' metadata, the bundle should be installable on any arch/OS.
  [NOTE] Opam system sandboxing (introduced in 2.0) will be disabled in the bundle. You need to trust that the build scripts of the included packages don't write outside of their build directory and dest dir.
  Continue ? [Y/n] y
  
  <><> Getting all archives <><><><><><><><><><><><><><><><><><><><><><><><><><><>
  
  <><> Getting bootstrap packages <><><><><><><><><><><><><><><><><><><><><><><><>
  
  <><> Building bundle ><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
  Done. Bundle generated as $TESTCASE_ROOT/bar-bundle.tar.gz
  $ tar xvf bar-bundle.tar.gz | grep -v sha256 | sort
  bar-bundle/
  bar-bundle/bootstrap.sh
  bar-bundle/common.sh
  bar-bundle/compile.sh
  bar-bundle/configure.sh
  bar-bundle/opam-full-2.1.4.tar.gz
  bar-bundle/repo/
  bar-bundle/repo/archives/
  bar-bundle/repo/archives/bar.1/
  bar-bundle/repo/archives/bar.1/compile.tar.gz
  bar-bundle/repo/archives/foo.1/
  bar-bundle/repo/archives/foo.1/compile.tar.gz
  bar-bundle/repo/archives/ocaml-base-compiler.4.14.0/
  bar-bundle/repo/archives/ocaml-base-compiler.4.14.0/ocaml.tar.gz
  bar-bundle/repo/cache/
  bar-bundle/repo/packages/
  bar-bundle/repo/packages/bar/
  bar-bundle/repo/packages/bar/bar.1/
  bar-bundle/repo/packages/bar/bar.1/opam
  bar-bundle/repo/packages/foo/
  bar-bundle/repo/packages/foo/foo.1/
  bar-bundle/repo/packages/foo/foo.1/opam
  bar-bundle/repo/packages/ocaml-base-compiler/
  bar-bundle/repo/packages/ocaml-base-compiler/ocaml-base-compiler.4.14.0/
  bar-bundle/repo/packages/ocaml-base-compiler/ocaml-base-compiler.4.14.0/opam
  bar-bundle/repo/packages/ocaml-bootstrap/
  bar-bundle/repo/packages/ocaml-bootstrap/ocaml-bootstrap.4.14.0/
  bar-bundle/repo/packages/ocaml-bootstrap/ocaml-bootstrap.4.14.0/opam
  bar-bundle/repo/repo
  $ sh ./bar-bundle/compile.sh ../BAR
  This bundle will compile the application to $TESTCASE_ROOT/bar-bundle, and put wrappers into
  ../BAR/bin. You will need to retain $TESTCASE_ROOT/bar-bundle for the wrappers to work.
  
  Press enter to continue... 
  ================ Bootstrap: checking for prerequisites         ================
  
  Checking for cc... found
  Checking for make... found
  Checking for wget curl... found
  Checking for patch... found
  Checking for unzip... found
  Checking for bunzip2... found
  Checking for rsync... found
  
  ================ Bootstrap: compiling OCaml                    ================
  
  This may take a while. Output is in $TESTCASE_ROOT/bar-bundle/bootstrap.log
  Uncompressing... done
  Configuring... done
  Compiling... done
  Installing to temp prefix... done
  Already compiled opam found
  
  ================ Configure: initialising opam                  ================
  
  Output is in $TESTCASE_ROOT/bar-bundle/configure.log
  Initialising... done
  Creating sandbox... done
  
  ================ Compile: installing packages                  ================
  
  Output is in $TESTCASE_ROOT/bar-bundle/compile.log
  Compiling packages... done
  Cleaning up... done
  Wrapper bar installed successfully.
  $ opam exec --root ./bar-bundle/opam -- bar
  I'm launching bar !
  $ opam exec --root ./bar-bundle/opam -- foo
  I'm launching foo !
  $ find BAR | sort
  BAR
  BAR/bin
  BAR/bin/bar
  $ BAR/bin/bar
  I'm launching bar !

Cleaning up
  $ rm -r BAR bar-bundle bar-bundle.tar.gz



============================== Test 3 ==============================


Bundle package `bar` that depends on `foo` with self-extracting script.

  $ opam-bundle bar.1 --self --repository ./REPO --ocaml=4.14.0 -y 2>&1 | sed 's/arch =.*/arch = $ARCH/;s/os =.*/os = $OS/;s/os-distribution =.*/os-distribution = $OSDISTRIB/;s/os-version =.*/os-version = $OSVERSION/;s/os-family =.*/os-family = $OSFAMILLY/'
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
    - foo.1
    - ocaml-base-compiler.4.14.0
    - ocaml-bootstrap.4.14.0
  According to the packages' metadata, the bundle should be installable on any arch/OS.
  [NOTE] Opam system sandboxing (introduced in 2.0) will be disabled in the bundle. You need to trust that the build scripts of the included packages don't write outside of their build directory and dest dir.
  Continue ? [Y/n] y
  
  <><> Getting all archives <><><><><><><><><><><><><><><><><><><><><><><><><><><>
  
  <><> Getting bootstrap packages <><><><><><><><><><><><><><><><><><><><><><><><>
  
  <><> Building bundle ><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
  Done. Bundle generated as $TESTCASE_ROOT/bar-bundle.tar.gz
  Self-extracting archive generated as $TESTCASE_ROOT/bar-bundle.sh

  $ sh ./bar-bundle.sh -y
  This bundle will compile the application to $TESTCASE_ROOT/bar-bundle, WITHOUT installing
  wrappers anywhere else.
  
  ================ Bootstrap: checking for prerequisites         ================
  
  Checking for cc... found
  Checking for make... found
  Checking for wget curl... found
  Checking for patch... found
  Checking for unzip... found
  Checking for bunzip2... found
  Checking for rsync... found
  
  ================ Bootstrap: compiling OCaml                    ================
  
  This may take a while. Output is in $TESTCASE_ROOT/bar-bundle/bootstrap.log
  Uncompressing... done
  Configuring... done
  Compiling... done
  Installing to temp prefix... done
  Already compiled opam found
  
  ================ Configure: initialising opam                  ================
  
  Output is in $TESTCASE_ROOT/bar-bundle/configure.log
  Initialising... done
  Creating sandbox... done
  
  ================ Compile: installing packages                  ================
  
  Output is in $TESTCASE_ROOT/bar-bundle/compile.log
  Compiling packages... done
  Cleaning up... done
  
  All compiled within $TESTCASE_ROOT/bar-bundle. To use the compiled packages:
  
    - either re-run bar-bundle/compile.sh with a PREFIX argument to install command wrappers
      (it won't recompile everything)
  
    - or run the following to update the environment in the current shell, so that
      they are in your PATH:
        export PATH="$TESTCASE_ROOT/bar-bundle/bootstrap/bin:$PATH"; eval $(opam env --root "$TESTCASE_ROOT/bar-bundle/opam" --set-root)
  

  $ opam exec --root ./bar-bundle/opam -- bar
  I'm launching bar !
  $ opam exec --root ./bar-bundle/opam -- foo
  I'm launching foo !
