This test verify bundling of real package `opam-bundle` of version 0.4.

  $ export OPAMNOENVNOTICE=1
  $ export OPAMYES=1
  $ export OPAMROOT=$PWD/OPAMROOT
  $ export OPAMSTATUSLINE=never
  $ export OPAMVERBOSE=-1
  $ opam --version
  2.1.4
  $ opam-bundle "opam-bundle@https://github.com/AltGr/opam-bundle/archive/refs/tags/0.4.tar.gz" opam-client.2.0.10 --self --opam=2.1 --ocaml=4.14.0 --yes 2>&1 | sed 's/arch =.*/arch = $ARCH/;s/os =.*/os = $OS/;s/os-distribution =.*/os-distribution = $OSDISTRIB/;s/os-version =.*/os-version = $OSVERSION/;s/os-family =.*/os-family = $OSFAMILLY/'
  No environment specified, will use the following for package resolution (based on the host system):
    - arch = $ARCH
    - os = $OS
    - os-distribution = $OSDISTRIB
    - os-version = $OSVERSION
    - os-family = $OSFAMILLY
  
  <><> Initialising repositories ><><><><><><><><><><><><><><><><><><><><><><><><>
  [opam.ocaml.org] Initialised
  
  <><> Getting external packages ><><><><><><><><><><><><><><><><><><><><><><><><>
  [NOTE] Will use package definition found in source for opam-bundle
  
  <><> Resolving package set ><><><><><><><><><><><><><><><><><><><><><><><><><><>
  The following packages will be included:
    - base-bigarray.base
    - base-bytes.base
    - base-threads.base
    - base-unix.base
    - cmdliner.1.2.0
    - cppo.1.6.9
    - cudf.0.10
    - dose3.5.0.1-2
    - dune.3.7.1
    - extlib.1.7.7-1
    - mccs.1.1+14
    - ocaml.4.14.0
    - ocaml-base-compiler.4.14.0
    - ocaml-bootstrap.4.14.0
    - ocaml-config.2
    - ocaml-options-vanilla.1
    - ocamlbuild.0.14.2
    - ocamlfind.1.9.6
    - ocamlgraph.2.0.0
    - opam-bundle.0.4
    - opam-client.2.0.10
    - opam-core.2.0.10
    - opam-file-format.2.1.6
    - opam-format.2.0.10
    - opam-repository.2.0.10
    - opam-solver.2.0.10
    - opam-state.2.0.10
    - re.1.10.4
    - seq.base
    - stdlib-shims.0.3.0
  The bundle will be installable on systems matching the following: os != "win32"
  [NOTE] Opam system sandboxing (introduced in 2.0) will be disabled in the bundle. You need to trust that the build scripts of the included packages don't write outside of their build directory and dest dir.
  Continue ? [Y/n] y
  
  <><> Getting all archives <><><><><><><><><><><><><><><><><><><><><><><><><><><>
  
  <><> Getting bootstrap packages <><><><><><><><><><><><><><><><><><><><><><><><>
  [ERROR] Opam archive at https://github.com/ocaml/opam/releases/download/2.1/opam-full-2.1.tar.gz could not be obtained: curl error code 404
  $ sh ./opam-bundle-bundle.sh -y
  sh: 0: cannot open ./opam-bundle-bundle.sh: No such file
  [2]
  $ sh ./opam-bundle-bundle/compile.sh ../BUNDLE
  sh: 0: cannot open ./opam-bundle-bundle/compile.sh: No such file
  [2]
  $ BUNDLE/bin/opam-bundle
  BUNDLE/bin/opam-bundle: not found
  [127]
