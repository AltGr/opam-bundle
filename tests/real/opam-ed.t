This test verify bundling of real package `opam-ed.0.1` (old version) with compiler version 4.14.2 and opam version 2.0.

Unsetting setup-ocaml variables
  $ unset OPAMPRECISETRACKING
  $ unset OPAMEXTERNALSOLVER
Set some opam variables for the cram test
  $ export OPAMNOENVNOTICE=1
  $ export OPAMYES=1
  $ export OPAMROOT=$PWD/OPAMROOT
  $ export OPAMSTATUSLINE=never
  $ export ARCHIVE_REPO_ARG="--repo git+https://github.com/ocaml/opam-repository-archive"
  $ export ARCHIVE_REPO_ARG="$ARCHIVE_REPO_ARG --repo git+https://github.com/ocaml/opam-repository#c9af4994e07b4a3a2c4b3c5442aabe63dd5d0381"
  $ opam-bundle opam-ed.0.1 --ocaml=4.14.2 --opam=2.0 --self --yes $ARCHIVE_REPO_ARG 2>&1 | sed -f ../arch.sed
  OCaml version is set to 4.14.2.
  Opam version is set to 2.0.10.
  No environment specified, will use the following for package resolution (based on the host system):
    - arch = $ARCH
    - os = $OS
    - os-distribution = $OSDISTRIB
    - os-version = $OSVERSION
    - os-family = $OSFAMILLY
  
  <><> Initialising repositories ><><><><><><><><><><><><><><><><><><><><><><><><>
  [github.com] Initialised
  [github.com1] Initialised
  github.com1 (at git+https://github.com/ocaml/opam-repository#c9af4994e07b4a3a2c4b3c5442aabe63dd5d0381): 
      [INFO] opam 2.1 and 2.2 include many performance and security improvements over 2.0; please consider upgrading (https://opam.ocaml.org/doc/Install.html)
  
  
  <><> Resolving package set ><><><><><><><><><><><><><><><><><><><><><><><><><><>
  The following packages will be included:
    - base-bigarray.base
    - base-threads.base
    - base-unix.base
    - cmdliner.1.3.0
    - ocaml.4.14.2
    - ocaml-base-compiler.4.14.2
    - ocaml-bootstrap.4.14.2
    - ocaml-config.2
    - ocaml-options-vanilla.1
    - ocamlfind.1.9.8
    - opam-ed.0.1
    - opam-file-format.2.0.0~beta3
  The bundle will be installable on systems matching the following: (os != "win32" | sys-ocaml-libc = "msvc") & os != "win32"
  [NOTE] Opam system sandboxing (introduced in 2.0) will be disabled in the bundle. You need to trust that the build scripts of the included packages don't write outside of their build directory and dest dir.
  Continue ? [Y/n] y
  
  <><> Getting all archives <><><><><><><><><><><><><><><><><><><><><><><><><><><>
  
  <><> Getting bootstrap packages <><><><><><><><><><><><><><><><><><><><><><><><>
  
  <><> Building bundle ><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
  Done. Bundle generated as $TESTCASE_ROOT/opam-ed-bundle.tar.gz
  Self-extracting archive generated as $TESTCASE_ROOT/opam-ed-bundle.sh
  $ sh ./opam-ed-bundle.sh -y
  This bundle will compile the application to $TESTCASE_ROOT/opam-ed-bundle, WITHOUT installing
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
  
  This may take a while. Output is in $TESTCASE_ROOT/opam-ed-bundle/bootstrap.log
  Uncompressing... done
  Configuring... done
  Compiling... done
  Installing to temp prefix... done
  
  ================ Bootstrap: compiling opam                     ================
  
  This may take a while. Output is in $TESTCASE_ROOT/opam-ed-bundle/bootstrap.log
  Uncompressing... done
  Configuring... done
  Compiling extra dependencies... done
  Compiling... done
  Installing to temp prefix... done
  
  ================ Configure: initialising opam                  ================
  
  Output is in $TESTCASE_ROOT/opam-ed-bundle/configure.log
  Initialising... done
  Creating sandbox... done
  
  ================ Compile: installing packages                  ================
  
  Output is in $TESTCASE_ROOT/opam-ed-bundle/compile.log
  Compiling packages... done
  Cleaning up... done
  
  All compiled within $TESTCASE_ROOT/opam-ed-bundle. To use the compiled packages:
  
    - either re-run opam-ed-bundle/compile.sh with a PREFIX argument to install command wrappers
      (it won't recompile everything)
  
    - or run the following to update the environment in the current shell, so that
      they are in your PATH:
        export PATH="$TESTCASE_ROOT/opam-ed-bundle/bootstrap/bin:$PATH"; eval $(opam env --root "$TESTCASE_ROOT/opam-ed-bundle/opam" --set-root)
  
  $ sh ./opam-ed-bundle/compile.sh ../OPAMED
  This bundle will compile the application to $TESTCASE_ROOT/opam-ed-bundle, and put wrappers into
  ../OPAMED/bin. You will need to retain $TESTCASE_ROOT/opam-ed-bundle for the wrappers to work.
  
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
  
  Output is in $TESTCASE_ROOT/opam-ed-bundle/compile.log
  Compiling packages... done
  Cleaning up... done
  Wrapper opam-ed installed successfully.
  $ OPAMED/bin/opam-ed --version
  0.1

