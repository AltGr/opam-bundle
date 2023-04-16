This test verify bundling of real package `opam-bundle` of version 0.4.

  $ export OPAMNOENVNOTICE=1
  $ export OPAMYES=1
  $ export OPAMROOT=$PWD/OPAMROOT
  $ export OPAMSTATUSLINE=never
  $ export OPAMVERBOSE=-1
  $ opam --version
  2.1.4
  $ opam-bundle "opam-bundle@https://github.com/AltGr/opam-bundle/archive/refs/tags/0.4.tar.gz" opam-client.2.0.10 --self --opam=2.1 --ocaml=4.14.0 --yes 2>&1 | sed 's/arch =.*/arch = $ARCH/;s/os =.*/os = $OS/;s/os-distribution =.*/os-distribution = $OSDISTRIB/;s/os-version =.*/os-version = $OSVERSION/;s/os-family =.*/os-family = $OSFAMILLY/'
  OCaml version is set to 4.14.0.
  Opam version is set to 2.1.4.
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
  
  <><> Building bundle ><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
  Done. Bundle generated as $TESTCASE_ROOT/opam-bundle-bundle.tar.gz
  Self-extracting archive generated as $TESTCASE_ROOT/opam-bundle-bundle.sh
  $ sh ./opam-bundle-bundle.sh -y
  This bundle will compile the application to $TESTCASE_ROOT/opam-bundle-bundle, WITHOUT installing
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
  
  This may take a while. Output is in $TESTCASE_ROOT/opam-bundle-bundle/bootstrap.log
  Uncompressing... done
  Configuring... done
  Compiling... done
  Installing to temp prefix... done
  
  ================ Bootstrap: compiling opam                     ================
  
  This may take a while. Output is in $TESTCASE_ROOT/opam-bundle-bundle/bootstrap.log
  Uncompressing... done
  Configuring... done
  Compiling extra dependencies... done
  Compiling... done
  Installing to temp prefix... done
  
  ================ Configure: initialising opam                  ================
  
  Output is in $TESTCASE_ROOT/opam-bundle-bundle/configure.log
  Initialising... done
  Creating sandbox... done
  
  ================ Compile: installing packages                  ================
  
  Output is in $TESTCASE_ROOT/opam-bundle-bundle/compile.log
  Compiling packages... done
  Cleaning up... done
  
  All compiled within $TESTCASE_ROOT/opam-bundle-bundle. To use the compiled packages:
  
    - either re-run opam-bundle-bundle/compile.sh with a PREFIX argument to install command wrappers
      (it won't recompile everything)
  
    - or run the following to update the environment in the current shell, so that
      they are in your PATH:
        export PATH="$TESTCASE_ROOT/opam-bundle-bundle/bootstrap/bin:$PATH"; eval $(opam env --root "$TESTCASE_ROOT/opam-bundle-bundle/opam" --set-root)
  
  $ sh ./opam-bundle-bundle/compile.sh ../BUNDLE
  This bundle will compile the application to $TESTCASE_ROOT/opam-bundle-bundle, and put wrappers into
  ../BUNDLE/bin. You will need to retain $TESTCASE_ROOT/opam-bundle-bundle for the wrappers to work.
  
  Press enter to continue... 
  ================ Bootstrap: checking for prerequisites         ================
  
  Checking for cc... found
  Checking for make... found
  Checking for wget curl... found
  Checking for patch... found
  Checking for unzip... found
  Checking for bunzip2... found
  Checking for rsync... found
  Already compiled OCaml found
  Already compiled opam found
  Already initialised opam sandbox found
  
  ================ Compile: installing packages                  ================
  
  Output is in $TESTCASE_ROOT/opam-bundle-bundle/compile.log
  Compiling packages... done
  Cleaning up... done
  Wrapper opam-bundle installed successfully.
  $ BUNDLE/bin/opam-bundle
  opam-bundle: required argument PACKAGE is missing
  Usage: opam-bundle [OPTION]… PACKAGE…
  Try 'opam-bundle --help' for more information.
  [1]
