This test verify bundling of real package `odoc` with compiler version 4.02.3 and opam version 2.0.

  $ export OPAMNOENVNOTICE=1
  $ export OPAMYES=1
  $ export OPAMROOT=$PWD/OPAMROOT
  $ export OPAMSTATUSLINE=never
  $ export OPAMVERBOSE=-1
  $ opam --version
  2.1.4
  $ opam-bundle odoc --ocaml=4.02.3 --opam=2.0 --self --yes 2>&1 | sed 's/arch =.*/arch = $ARCH/;s/os =.*/os = $OS/;s/os-distribution =.*/os-distribution = $OSDISTRIB/;s/os-version =.*/os-version = $OSVERSION/;s/os-family =.*/os-family = $OSFAMILLY/'
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
  [ERROR] Opam archive at https://github.com/ocaml/opam/releases/download/2.0/opam-full-2.0.tar.gz could not be obtained: curl error code 404
  $ sh ./odoc-bundle.sh -y
  sh: 0: cannot open ./odoc-bundle.sh: No such file
  [2]
  $ sh ./odoc-bundle/compile.sh ../ODOC
  sh: 0: cannot open ./odoc-bundle/compile.sh: No such file
  [2]
  $ ODOC/bin/odoc
  ODOC/bin/odoc: not found
  [127]
