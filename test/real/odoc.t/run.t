This test verify bundling of real package `odoc` with compiler version 4.02.1 and opam version 2.0.

  $ export OPAMNOENVNOTICE=1
  $ export OPAMYES=1
  $ export OPAMROOT=$PWD/OPAMROOT
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
  Uncompressing... done
  Applying patches... done
  Configuring... done
  Compiling... done
  Installing to temp prefix... done
  
  ================ Bootstrap: compiling opam                     ================
  
  This may take a while. Output is in $TESTCASE_ROOT/odoc-bundle/bootstrap.log
  Uncompressing... done
  Configuring... done
  Compiling extra dependencies... done
  Compiling... done
  Installing to temp prefix... done
  
  ================ Configure: initialising opam                  ================
  
  Output is in $TESTCASE_ROOT/odoc-bundle/configure.log
  Initialising... done
  Creating sandbox... done
  
  ================ Compile: installing packages                  ================
  
  Output is in $TESTCASE_ROOT/odoc-bundle/compile.log
  Compiling packages... done
  Cleaning up... done
  
  All compiled within $TESTCASE_ROOT/odoc-bundle. To use the compiled packages:
  
    - either re-run odoc-bundle/compile.sh with a PREFIX argument to install command wrappers
      (it won't recompile everything)
  
    - or run the following to update the environment in the current shell, so that
      they are in your PATH:
        export PATH="$TESTCASE_ROOT/odoc-bundle/bootstrap/bin:$PATH"; eval $(opam env --root "$TESTCASE_ROOT/odoc-bundle/opam" --set-root)
  
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
  Already compiled OCaml found
  Already compiled opam found
  Already initialised opam sandbox found
  
  ================ Compile: installing packages                  ================
  
  Output is in $TESTCASE_ROOT/odoc-bundle/compile.log
  Compiling packages... done
  Cleaning up... done
  Wrapper odoc installed successfully.
  $ ODOC/bin/odoc
  Available subcommands: compile, link, html-generate, support-files, man-generate, latex-generate, html-url, latex-url, support-files-targets, errors, html-targets, man-targets, latex-targets, compile-deps, compile-targets, html-fragment, html, man, latex, link-deps, css, html-deps
  See --help for more information.
