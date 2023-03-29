Repo initial setup with two packages `foo` and `bar` that depends on `foo` and other required packages.
Every package used is a dummy package.
  $ export OPAMNOENVNOTICE=1
  $ export OPAMYES=1
  $ export OPAMROOT=$PWD/OPAMROOT
  $ mkdir -p REPO/packages/
  $ cat > REPO/repo << EOF
  > opam-version: "2.0"
  > EOF
Foo package.
  $ mkdir -p REPO/packages/foo/foo.1
  $ cat > REPO/packages/foo/foo.1/opam << EOF
  > opam-version: "2.0"
  > maintainer: "no"
  > authors: "no"
  > homepage: "no"
  > bug-reports: "no"
  > synopsis: "No"
  > license: "GPL-3-only"
  > build: []
  > EOF
Bar package.
  $ mkdir -p REPO/packages/bar/bar.1
  $ cat > REPO/packages/bar/bar.1/opam << EOF
  > opam-version: "2.0"
  > maintainer: "no"
  > authors: "no"
  > homepage: "no"
  > bug-reports: "no"
  > synopsis: "No"
  > license: "GPL-3-only"
  > depends: [ "foo" ]
  > build: []
  > EOF
Ocaml-system.4.14.0 package.
  $ mkdir -p REPO/packages/ocaml-system/ocaml-system.4.14.0
  $ cat > REPO/packages/ocaml-system/ocaml-system.4.14.0/opam << EOF
  > opam-version: "2.0"
  > maintainer: "no"
  > authors: "no"
  > homepage: "no"
  > bug-reports: "no"
  > synopsis: "No"
  > license: "GPL-3-only"
  > build: []
  > EOF
Ocaml-config.2 package.
  $ mkdir -p REPO/packages/ocaml-config/ocaml-config.2
  $ cat > REPO/packages/ocaml-config/ocaml-config.2/opam << EOF
  > opam-version: "2.0"
  > maintainer: "no"
  > authors: "no"
  > homepage: "no"
  > bug-reports: "no"
  > synopsis: "No"
  > license: "GPL-3-only"
  > build: []
  > EOF
Ocaml.4.14.0 package.
  $ mkdir -p REPO/packages/ocaml/ocaml.4.14.0
  $ cat > REPO/packages/ocaml/ocaml.4.14.0/opam << EOF
  > opam-version: "2.0"
  > maintainer: "no"
  > authors: "no"
  > homepage: "no"
  > bug-reports: "no"
  > synopsis: "No"
  > license: "GPL-3-only"
  > build: []
  > EOF
Ocaml-base-compiler.4.14.0 package.
  $ mkdir -p REPO/packages/ocaml-base-compiler/ocaml-base-compiler.4.14.0
  $ cat > REPO/packages/ocaml-base-compiler/ocaml-base-compiler.4.14.0/opam << EOF
  > opam-version: "2.0"
  > maintainer: "no"
  > authors: "no"
  > homepage: "no"
  > bug-reports: "no"
  > synopsis: "No"
  > license: "GPL-3-only"
  > build: []
  > EOF

Opam setup
  $ mkdir $OPAMROOT
  $ opam init --bare ./REPO --no-setup --bypass-checks
  No configuration file found, using built-in defaults.
  
  <><> Fetching repository information ><><><><><><><><><><><><><><><><><><><><><>
  [default] Initialised
  $ opam switch create one --empty

Running opam-bundle with sanitized output that contains remplaced platform specific information.

===== Test 1 =====
  $ opam-bundle foo.1 --repository ./REPO -y 2>&1 | sed 's/arch =.*/arch = $ARCH/;s/os =.*/os = $OS/;s/os-distribution =.*/os-distribution = $OSDISTRIB/;s/os-version =.*/os-version = $OSVERSION/;s/os-family =.*/os-family = $OSFAMILLY/'
  No OCaml version selected, will use 4.14.0.
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

===== Test 2 =====
  $ opam-bundle bar.1 --repository ./REPO -y 2>&1 | sed 's/arch =.*/arch = $ARCH/;s/os =.*/os = $OS/;s/os-distribution =.*/os-distribution = $OSDISTRIB/;s/os-version =.*/os-version = $OSVERSION/;s/os-family =.*/os-family = $OSFAMILLY/'
  No OCaml version selected, will use 4.14.0.
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
