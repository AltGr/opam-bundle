This test verify bundling of real package `odoc` with compiler version 4.02.3 and opam version 2.0.

  $ export OPAMNOENVNOTICE=1
  $ export OPAMYES=1
  $ export OPAMROOT=$PWD/OPAMROOT
  $ export OPAMSTATUSLINE=never
  $ export OPAMVERBOSE=-1
  $ opam-bundle odoc --ocaml=4.02.3 --opam=2.0 --self --yes 2>&1 | sed 's/arch =.*/arch = $ARCH/;s/os =.*/os = $OS/;s/os-distribution =.*/os-distribution = $OSDISTRIB/;s/os-version =.*/os-version = $OSVERSION/;s/os-family =.*/os-family = $OSFAMILLY/'
  OCaml version is set to 4.02.3.
  Opam version is set to 2.0.10.
  No environment specified, will use the following for package resolution (based on the host system):
    - arch = $ARCH
    - os = $OS
    - os-distribution = $OSDISTRIB
    - os-version = $OSVERSION
    - os-family = $OSFAMILLY
  
  <><> Initialising repositories ><><><><><><><><><><><><><><><><><><><><><><><><>
  [opam.ocaml.org] Initialised
  
  <><> Resolving package set ><><><><><><><><><><><><><><><><><><><><><><><><><><>
  The following packages will be included:
    - astring.0.8.3
    - base-bigarray.base
    - base-bytes.base
    - base-ocamlbuild.base
    - base-threads.base
    - base-unix.base
    - camlp-streams.5.0.1
    - cmdliner.1.0.2
    - cppo.1.6.9
    - dune.3.7.1
    - fmt.0.8.5
    - fpath.0.7.2
    - ocaml.4.02.3
    - ocaml-base-compiler.4.02.3
    - ocaml-bootstrap.4.02.3
    - ocaml-config.1
    - ocaml-secondary-compiler.4.08.1-1
    - ocamlbuild.0
    - ocamlfind.1.9.1
    - ocamlfind-secondary.1.9.1
    - odoc.2.2.0
    - odoc-parser.2.0.0
    - re.1.10.3
    - result.1.4
    - seq.0.3.1
    - topkg.1.0.0
    - tyxml.4.5.0
    - uchar.0.0.2
    - uutf.1.0.2
  The bundle will be installable on systems matching the following: !(os = $OS
  [NOTE] Opam system sandboxing (introduced in 2.0) will be disabled in the bundle. You need to trust that the build scripts of the included packages don't write outside of their build directory and dest dir.
  Continue ? [Y/n] y
  
  <><> Getting all archives <><><><><><><><><><><><><><><><><><><><><><><><><><><>
  
  <><> Getting bootstrap packages <><><><><><><><><><><><><><><><><><><><><><><><>
  
  <><> Building bundle ><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
  Done. Bundle generated as $TESTCASE_ROOT/odoc-bundle.tar.gz
  Self-extracting archive generated as $TESTCASE_ROOT/odoc-bundle.sh
  $ sh ./odoc-bundle.sh -y
  This bundle will compile the application to $TESTCASE_ROOT/odoc-bundle, WITHOUT installing
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
  
  This may take a while. Output is in $TESTCASE_ROOT/odoc-bundle/bootstrap.log
  Uncompressing... 
  
  Something went wrong, see log in $TESTCASE_ROOT/odoc-bundle/bootstrap.log
  [2]
  $ sh ./odoc-bundle/compile.sh ../ODOC
  This bundle will compile the application to $TESTCASE_ROOT/odoc-bundle, and put wrappers into
  ../ODOC/bin. You will need to retain $TESTCASE_ROOT/odoc-bundle for the wrappers to work.
  
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
  
  This may take a while. Output is in $TESTCASE_ROOT/odoc-bundle/bootstrap.log
  Uncompressing... 
  
  Something went wrong, see log in $TESTCASE_ROOT/odoc-bundle/bootstrap.log
  
  ================ Compile: installing packages                  ================
  
  Output is in $TESTCASE_ROOT/odoc-bundle/compile.log
  ./odoc-bundle/compile.sh: 59: cannot create $TESTCASE_ROOT/odoc-bundle/bootstrap/bin/sudo: Directory nonexistent
  chmod: cannot access '$TESTCASE_ROOT/odoc-bundle/bootstrap/bin/sudo': No such file or directory
  Compiling packages... 
  
  Something went wrong, see log in $TESTCASE_ROOT/odoc-bundle/compile.log
  [50]
  $ ODOC/bin/odoc
  ODOC/bin/odoc: not found
  [127]
