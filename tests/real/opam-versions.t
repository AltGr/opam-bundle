This test verifies the compilation of several versions of opam from opam 2.0. A bundle is created with
a dumb package and repo, which needs resolution (solver). We test the bundle creation and its use.
Note: to avoid recompiling an ocaml compiler for each bundle, it is compiled once and added by hand on
each archive extract.

  $ . ../env-vars
Repo initial setup with two packages `foo`, `oof` and `bar` that depends on `foo` & `oof`.
  $ cat > compile << EOF
  > #!/bin/sh
  > echo "I'm launching \$(basename \${0}) \$@!"
  > EOF
  $ chmod +x compile
  $ tar czf compile.tar.gz compile
  $ SHA=`openssl sha256 compile.tar.gz | cut -d ' ' -f 2`
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
  $ mkdir -p REPO/packages/foo/foo.2
  $ cat > REPO/packages/foo/foo.2/opam << EOF
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
Oof package.
  $ mkdir -p REPO/packages/oof/oof.1
  $ cat > REPO/packages/oof/oof.1/opam << EOF
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
  $ mkdir -p REPO/packages/oof/oof.2
  $ cat > REPO/packages/oof/oof.2/opam << EOF
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
  > depends: [ "foo" {< "2"} | "oof" {> "1"}]
  > url {
  >  src: "file://./compile.tar.gz"
  >  checksum: "sha256=$SHA"
  > }
  > EOF


  $ export REPO="--repository ./REPO --repository https://opam.ocaml.org"



Running opam-bundle with sanitized output that contains remplaced platform specific information.


============================== Test 1 ==============================


opam version 2.0

  $ opam-bundle bar.1 $REPO --ocaml=4.14.4 --opam=2.0 -y 2>&1 | sed 's/arch =.*/arch = $ARCH/;s/os =.*/os = $OS/;s/os-distribution =.*/os-distribution = $OSDISTRIB/;s/os-version =.*/os-version = $OSVERSION/;s/os-family =.*/os-family = $OSFAMILLY/'
  OCaml version is set to 4.14.4.
  Opam version is set to 2.0.10.
  No environment specified, will use the following for package resolution (based on the host system):
    - arch = $ARCH
    - os = $OS
    - os-distribution = $OSDISTRIB
    - os-version = $OSVERSION
    - os-family = $OSFAMILLY
  
  <><> Initialising repositories ><><><><><><><><><><><><><><><><><><><><><><><><>
  [home] Initialised
  [opam.ocaml.org] Initialised
  opam.ocaml.org (at https://opam.ocaml.org): 
      [INFO] please ensure to have GNU patch installed as `patch`. Otherwise update may fail silently (since it can't remove files).
  
  opam.ocaml.org (at https://opam.ocaml.org): 
      [WARNING] opam >= 2.5.2 includes important security fixes; please consider upgrading (https://opam.ocaml.org/doc/Install.html)
  
  
  <><> Resolving package set ><><><><><><><><><><><><><><><><><><><><><><><><><><>
  The following packages will be included:
    - bar.1
    - base-bigarray.base
    - base-threads.base
    - base-unix.base
    - ocaml.4.14.4
    - ocaml-base-compiler.4.14.4
    - ocaml-bootstrap.4.14.4
    - ocaml-config.2
    - ocaml-options-vanilla.1
    - oof.2
  The bundle will be installable on systems matching the following: (os != "win32" | sys-ocaml-libc = "msvc") & os != "win32"
  [NOTE] Opam system sandboxing (introduced in 2.0) will be disabled in the bundle. You need to trust that the build scripts of the included packages don't write outside of their build directory and dest dir.
  Continue ? [Y/n] y
  
  <><> Getting all archives <><><><><><><><><><><><><><><><><><><><><><><><><><><>
  
  <><> Getting bootstrap packages <><><><><><><><><><><><><><><><><><><><><><><><>
  
  <><> Building bundle ><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
  Done. Bundle generated as $TESTCASE_ROOT/bar-bundle.tar.gz
  $ tar xf bar-bundle.tar.gz
  $ sh ./bar-bundle/compile.sh
  This bundle will compile the application to $TESTCASE_ROOT/bar-bundle, WITHOUT installing
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
  
  This may take a while. Output is in $TESTCASE_ROOT/bar-bundle/bootstrap.log
  Uncompressing... done
  Configuring... done
  Compiling... done
  Installing to temp prefix... done
  
  ================ Bootstrap: compiling opam                     ================
  
  This may take a while. Output is in $TESTCASE_ROOT/bar-bundle/bootstrap.log
  Uncompressing... done
  Configuring... done
  Compiling extra dependencies... done
  Compiling... done
  Installing to temp prefix... done
  
  ================ Configure: initialising opam                  ================
  
  Output is in $TESTCASE_ROOT/bar-bundle/configure.log
  Initialising... done
  Creating sandbox... done
  
  ================ Compile: installing packages                  ================
  
  Output is in $TESTCASE_ROOT/bar-bundle/compile.log
  Compiling packages... done
  Cleaning up... done
  
  All compiled within $TESTCASE_ROOT/bar-bundle. To use the compiled packages:
  
    - either re-run ./bar-bundle/compile.sh with a PREFIX argument to install command wrappers
      (it won't recompile everything)
  
    - or run the following to update the environment in the current shell, so that
      they are in your PATH:
        export PATH="$TESTCASE_ROOT/bar-bundle/bootstrap/bin:$PATH"; eval $(opam env --root "$TESTCASE_ROOT/bar-bundle/opam" --set-root)
  
  $ test -f bar-bundle/bootstrap/bin/opam
  $ test -f ./bar-bundle/opam/default/bin/bar && ./bar-bundle/opam/default/bin/bar
  I'm launching bar !

Cleaning up
  $ mv bar-bundle/bootstrap bootstrap
  $ rm -r bootstrap/bin/opam bootstrap/bin/opam-installer bootstrap/share/man/man1
  $ rm -r bar-bundle bar-bundle.tar.gz

============================== Test 2 ==============================


opam version 2.1

  $ opam-bundle bar.1 $REPO --ocaml=4.14.4 --opam=2.1 -y 2>&1 | sed 's/arch =.*/arch = $ARCH/;s/os =.*/os = $OS/;s/os-distribution =.*/os-distribution = $OSDISTRIB/;s/os-version =.*/os-version = $OSVERSION/;s/os-family =.*/os-family = $OSFAMILLY/'
  OCaml version is set to 4.14.4.
  Opam version is set to 2.1.4.
  No environment specified, will use the following for package resolution (based on the host system):
    - arch = $ARCH
    - os = $OS
    - os-distribution = $OSDISTRIB
    - os-version = $OSVERSION
    - os-family = $OSFAMILLY
  
  <><> Initialising repositories ><><><><><><><><><><><><><><><><><><><><><><><><>
  [home] Initialised
  [opam.ocaml.org] Initialised
  opam.ocaml.org (at https://opam.ocaml.org): 
      [INFO] opam is out-of-date. Please consider updating (https://opam.ocaml.org/doc/Install.html)
  
  opam.ocaml.org (at https://opam.ocaml.org): 
      [INFO] please ensure to have GNU patch installed as `patch`. Otherwise update may fail silently (since it can't remove files).
  
  opam.ocaml.org (at https://opam.ocaml.org): 
      [WARNING] opam >= 2.5.2 includes important security fixes; please consider upgrading (https://opam.ocaml.org/doc/Install.html)
  
  
  <><> Resolving package set ><><><><><><><><><><><><><><><><><><><><><><><><><><>
  The following packages will be included:
    - bar.1
    - base-bigarray.base
    - base-threads.base
    - base-unix.base
    - ocaml.4.14.4
    - ocaml-base-compiler.4.14.4
    - ocaml-bootstrap.4.14.4
    - ocaml-config.2
    - ocaml-options-vanilla.1
    - oof.2
  The bundle will be installable on systems matching the following: (os != "win32" | sys-ocaml-libc = "msvc") & os != "win32"
  [NOTE] Opam system sandboxing (introduced in 2.0) will be disabled in the bundle. You need to trust that the build scripts of the included packages don't write outside of their build directory and dest dir.
  Continue ? [Y/n] y
  
  <><> Getting all archives <><><><><><><><><><><><><><><><><><><><><><><><><><><>
  
  <><> Getting bootstrap packages <><><><><><><><><><><><><><><><><><><><><><><><>
  
  <><> Building bundle ><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
  Done. Bundle generated as $TESTCASE_ROOT/bar-bundle.tar.gz
  $ tar xf bar-bundle.tar.gz
  $ cp -R bootstrap bar-bundle/
  $ sh ./bar-bundle/compile.sh
  This bundle will compile the application to $TESTCASE_ROOT/bar-bundle, WITHOUT installing
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
  Already compiled OCaml found
  
  ================ Bootstrap: compiling opam                     ================
  
  This may take a while. Output is in $TESTCASE_ROOT/bar-bundle/bootstrap.log
  Uncompressing... done
  Configuring... done
  Compiling extra dependencies... done
  Compiling... done
  Installing to temp prefix... done
  
  ================ Configure: initialising opam                  ================
  
  Output is in $TESTCASE_ROOT/bar-bundle/configure.log
  Initialising... done
  Creating sandbox... done
  
  ================ Compile: installing packages                  ================
  
  Output is in $TESTCASE_ROOT/bar-bundle/compile.log
  Compiling packages... done
  Cleaning up... done
  
  All compiled within $TESTCASE_ROOT/bar-bundle. To use the compiled packages:
  
    - either re-run ./bar-bundle/compile.sh with a PREFIX argument to install command wrappers
      (it won't recompile everything)
  
    - or run the following to update the environment in the current shell, so that
      they are in your PATH:
        export PATH="$TESTCASE_ROOT/bar-bundle/bootstrap/bin:$PATH"; eval $(opam env --root "$TESTCASE_ROOT/bar-bundle/opam" --set-root)
  
  $ test -f bar-bundle/bootstrap/bin/opam
  $ test -f ./bar-bundle/opam/default/bin/bar && ./bar-bundle/opam/default/bin/bar
  I'm launching bar !

Cleaning up
  $ rm -r bar-bundle bar-bundle.tar.gz

============================== Test 3 ==============================


opam version 2.2

  $ opam-bundle bar.1 $REPO --ocaml=4.14.4 --opam=2.2 -y 2>&1 | sed 's/arch =.*/arch = $ARCH/;s/os =.*/os = $OS/;s/os-distribution =.*/os-distribution = $OSDISTRIB/;s/os-version =.*/os-version = $OSVERSION/;s/os-family =.*/os-family = $OSFAMILLY/'
  OCaml version is set to 4.14.4.
  Opam version is set to 2.2.1.
  No environment specified, will use the following for package resolution (based on the host system):
    - arch = $ARCH
    - os = $OS
    - os-distribution = $OSDISTRIB
    - os-version = $OSVERSION
    - os-family = $OSFAMILLY
  
  <><> Initialising repositories ><><><><><><><><><><><><><><><><><><><><><><><><>
  [home] Initialised
  [opam.ocaml.org] Initialised
  opam.ocaml.org (at https://opam.ocaml.org): 
      [WARNING] opam >= 2.5.2 includes important security fixes; please consider upgrading (https://opam.ocaml.org/doc/Install.html)
  
  
  <><> Resolving package set ><><><><><><><><><><><><><><><><><><><><><><><><><><>
  The following packages will be included:
    - bar.1
    - base-bigarray.base
    - base-threads.base
    - base-unix.base
    - ocaml.4.14.4
    - ocaml-base-compiler.4.14.4
    - ocaml-bootstrap.4.14.4
    - ocaml-config.2
    - ocaml-options-vanilla.1
    - oof.2
  The bundle will be installable on systems matching the following: (os != "win32" | sys-ocaml-libc = "msvc") & os != "win32"
  [NOTE] Opam system sandboxing (introduced in 2.0) will be disabled in the bundle. You need to trust that the build scripts of the included packages don't write outside of their build directory and dest dir.
  Continue ? [Y/n] y
  
  <><> Getting all archives <><><><><><><><><><><><><><><><><><><><><><><><><><><>
  
  <><> Getting bootstrap packages <><><><><><><><><><><><><><><><><><><><><><><><>
  
  <><> Building bundle ><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
  Done. Bundle generated as $TESTCASE_ROOT/bar-bundle.tar.gz
  $ tar xf bar-bundle.tar.gz
  $ cp -R bootstrap bar-bundle/
  $ sh ./bar-bundle/compile.sh
  This bundle will compile the application to $TESTCASE_ROOT/bar-bundle, WITHOUT installing
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
  Already compiled OCaml found
  
  ================ Bootstrap: compiling opam                     ================
  
  This may take a while. Output is in $TESTCASE_ROOT/bar-bundle/bootstrap.log
  Uncompressing... done
  Configuring... done
  Compiling extra dependencies... done
  Compiling... done
  Installing to temp prefix... done
  
  ================ Configure: initialising opam                  ================
  
  Output is in $TESTCASE_ROOT/bar-bundle/configure.log
  Initialising... done
  Creating sandbox... done
  
  ================ Compile: installing packages                  ================
  
  Output is in $TESTCASE_ROOT/bar-bundle/compile.log
  Compiling packages... done
  Cleaning up... done
  
  All compiled within $TESTCASE_ROOT/bar-bundle. To use the compiled packages:
  
    - either re-run ./bar-bundle/compile.sh with a PREFIX argument to install command wrappers
      (it won't recompile everything)
  
    - or run the following to update the environment in the current shell, so that
      they are in your PATH:
        export PATH="$TESTCASE_ROOT/bar-bundle/bootstrap/bin:$PATH"; eval $(opam env --root "$TESTCASE_ROOT/bar-bundle/opam" --set-root)
  
  $ test -f bar-bundle/bootstrap/bin/opam
  $ test -f ./bar-bundle/opam/default/bin/bar && ./bar-bundle/opam/default/bin/bar
  I'm launching bar !

Cleaning up
  $ rm -r bar-bundle bar-bundle.tar.gz

============================== Test 4 ==============================


opam version 2.3

  $ opam-bundle bar.1 $REPO --ocaml=4.14.4 --opam=2.3 -y 2>&1 | sed 's/arch =.*/arch = $ARCH/;s/os =.*/os = $OS/;s/os-distribution =.*/os-distribution = $OSDISTRIB/;s/os-version =.*/os-version = $OSVERSION/;s/os-family =.*/os-family = $OSFAMILLY/'
  OCaml version is set to 4.14.4.
  Opam version is set to 2.3.0.
  No environment specified, will use the following for package resolution (based on the host system):
    - arch = $ARCH
    - os = $OS
    - os-distribution = $OSDISTRIB
    - os-version = $OSVERSION
    - os-family = $OSFAMILLY
  
  <><> Initialising repositories ><><><><><><><><><><><><><><><><><><><><><><><><>
  [home] Initialised
  [opam.ocaml.org] Initialised
  
  <><> Resolving package set ><><><><><><><><><><><><><><><><><><><><><><><><><><>
  The following packages will be included:
    - bar.1
    - base-bigarray.base
    - base-threads.base
    - base-unix.base
    - ocaml.4.14.4
    - ocaml-base-compiler.4.14.4
    - ocaml-bootstrap.4.14.4
    - ocaml-config.2
    - ocaml-options-vanilla.1
    - oof.2
  The bundle will be installable on systems matching the following: (os != "win32" | sys-ocaml-libc = "msvc") & os != "win32"
  [NOTE] Opam system sandboxing (introduced in 2.0) will be disabled in the bundle. You need to trust that the build scripts of the included packages don't write outside of their build directory and dest dir.
  Continue ? [Y/n] y
  
  <><> Getting all archives <><><><><><><><><><><><><><><><><><><><><><><><><><><>
  
  <><> Getting bootstrap packages <><><><><><><><><><><><><><><><><><><><><><><><>
  
  <><> Building bundle ><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
  Done. Bundle generated as $TESTCASE_ROOT/bar-bundle.tar.gz
  $ tar xf bar-bundle.tar.gz
  $ cp -R bootstrap bar-bundle/
  $ sh ./bar-bundle/compile.sh
  This bundle will compile the application to $TESTCASE_ROOT/bar-bundle, WITHOUT installing
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
  Already compiled OCaml found
  
  ================ Bootstrap: compiling opam                     ================
  
  This may take a while. Output is in $TESTCASE_ROOT/bar-bundle/bootstrap.log
  Uncompressing... done
  Configuring... done
  Compiling extra dependencies... done
  Compiling... done
  Installing to temp prefix... done
  
  ================ Configure: initialising opam                  ================
  
  Output is in $TESTCASE_ROOT/bar-bundle/configure.log
  Initialising... done
  Creating sandbox... done
  
  ================ Compile: installing packages                  ================
  
  Output is in $TESTCASE_ROOT/bar-bundle/compile.log
  Compiling packages... done
  Cleaning up... done
  
  All compiled within $TESTCASE_ROOT/bar-bundle. To use the compiled packages:
  
    - either re-run ./bar-bundle/compile.sh with a PREFIX argument to install command wrappers
      (it won't recompile everything)
  
    - or run the following to update the environment in the current shell, so that
      they are in your PATH:
        export PATH="$TESTCASE_ROOT/bar-bundle/bootstrap/bin:$PATH"; eval $(opam env --root "$TESTCASE_ROOT/bar-bundle/opam" --set-root)
  
  $ test -f bar-bundle/bootstrap/bin/opam
  $ test -f ./bar-bundle/opam/default/bin/bar && ./bar-bundle/opam/default/bin/bar
  I'm launching bar !

Cleaning up
  $ rm -r bar-bundle bar-bundle.tar.gz

============================== Test 5 ==============================


opam version 2.4

  $ opam-bundle bar.1 $REPO --ocaml=4.14.4 --opam=2.4 -y 2>&1 | sed 's/arch =.*/arch = $ARCH/;s/os =.*/os = $OS/;s/os-distribution =.*/os-distribution = $OSDISTRIB/;s/os-version =.*/os-version = $OSVERSION/;s/os-family =.*/os-family = $OSFAMILLY/'
  OCaml version is set to 4.14.4.
  Opam version is set to 2.4.1.
  No environment specified, will use the following for package resolution (based on the host system):
    - arch = $ARCH
    - os = $OS
    - os-distribution = $OSDISTRIB
    - os-version = $OSVERSION
    - os-family = $OSFAMILLY
  
  <><> Initialising repositories ><><><><><><><><><><><><><><><><><><><><><><><><>
  [home] Initialised
  [opam.ocaml.org] Initialised
  opam.ocaml.org (at https://opam.ocaml.org): 
      [WARNING] opam >= 2.5.2 includes important security fixes; please consider upgrading (https://opam.ocaml.org/doc/Install.html)
  
  
  <><> Resolving package set ><><><><><><><><><><><><><><><><><><><><><><><><><><>
  The following packages will be included:
    - bar.1
    - base-bigarray.base
    - base-threads.base
    - base-unix.base
    - ocaml.4.14.4
    - ocaml-base-compiler.4.14.4
    - ocaml-bootstrap.4.14.4
    - ocaml-config.2
    - ocaml-options-vanilla.1
    - oof.2
  The bundle will be installable on systems matching the following: (os != "win32" | sys-ocaml-libc = "msvc") & os != "win32"
  [NOTE] Opam system sandboxing (introduced in 2.0) will be disabled in the bundle. You need to trust that the build scripts of the included packages don't write outside of their build directory and dest dir.
  Continue ? [Y/n] y
  
  <><> Getting all archives <><><><><><><><><><><><><><><><><><><><><><><><><><><>
  
  <><> Getting bootstrap packages <><><><><><><><><><><><><><><><><><><><><><><><>
  
  <><> Building bundle ><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
  Done. Bundle generated as $TESTCASE_ROOT/bar-bundle.tar.gz
  $ tar xf bar-bundle.tar.gz
  $ cp -R bootstrap bar-bundle/
  $ sh ./bar-bundle/compile.sh
  This bundle will compile the application to $TESTCASE_ROOT/bar-bundle, WITHOUT installing
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
  Already compiled OCaml found
  
  ================ Bootstrap: compiling opam                     ================
  
  This may take a while. Output is in $TESTCASE_ROOT/bar-bundle/bootstrap.log
  Uncompressing... done
  Configuring... done
  Compiling extra dependencies... done
  Compiling... done
  Installing to temp prefix... done
  
  ================ Configure: initialising opam                  ================
  
  Output is in $TESTCASE_ROOT/bar-bundle/configure.log
  Initialising... done
  Creating sandbox... done
  
  ================ Compile: installing packages                  ================
  
  Output is in $TESTCASE_ROOT/bar-bundle/compile.log
  Compiling packages... done
  Cleaning up... done
  
  All compiled within $TESTCASE_ROOT/bar-bundle. To use the compiled packages:
  
    - either re-run ./bar-bundle/compile.sh with a PREFIX argument to install command wrappers
      (it won't recompile everything)
  
    - or run the following to update the environment in the current shell, so that
      they are in your PATH:
        export PATH="$TESTCASE_ROOT/bar-bundle/bootstrap/bin:$PATH"; eval $(opam env --root "$TESTCASE_ROOT/bar-bundle/opam" --set-root)
  
  $ test -f bar-bundle/bootstrap/bin/opam
  $ test -f ./bar-bundle/opam/default/bin/bar && ./bar-bundle/opam/default/bin/bar
  I'm launching bar !

Cleaning up
  $ rm -r bar-bundle bar-bundle.tar.gz

============================== Test 6 ==============================


opam version 2.5

  $ opam-bundle bar.1 $REPO --ocaml=4.14.4 --opam=2.5 -y 2>&1 | sed 's/arch =.*/arch = $ARCH/;s/os =.*/os = $OS/;s/os-distribution =.*/os-distribution = $OSDISTRIB/;s/os-version =.*/os-version = $OSVERSION/;s/os-family =.*/os-family = $OSFAMILLY/'
  OCaml version is set to 4.14.4.
  Opam version is set to 2.5.2.
  No environment specified, will use the following for package resolution (based on the host system):
    - arch = $ARCH
    - os = $OS
    - os-distribution = $OSDISTRIB
    - os-version = $OSVERSION
    - os-family = $OSFAMILLY
  
  <><> Initialising repositories ><><><><><><><><><><><><><><><><><><><><><><><><>
  [home] Initialised
  [opam.ocaml.org] Initialised
  
  <><> Resolving package set ><><><><><><><><><><><><><><><><><><><><><><><><><><>
  The following packages will be included:
    - bar.1
    - base-bigarray.base
    - base-threads.base
    - base-unix.base
    - ocaml.4.14.4
    - ocaml-base-compiler.4.14.4
    - ocaml-bootstrap.4.14.4
    - ocaml-config.2
    - ocaml-options-vanilla.1
    - oof.2
  The bundle will be installable on systems matching the following: (os != "win32" | sys-ocaml-libc = "msvc") & os != "win32"
  [NOTE] Opam system sandboxing (introduced in 2.0) will be disabled in the bundle. You need to trust that the build scripts of the included packages don't write outside of their build directory and dest dir.
  Continue ? [Y/n] y
  
  <><> Getting all archives <><><><><><><><><><><><><><><><><><><><><><><><><><><>
  
  <><> Getting bootstrap packages <><><><><><><><><><><><><><><><><><><><><><><><>
  
  <><> Building bundle ><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
  Done. Bundle generated as $TESTCASE_ROOT/bar-bundle.tar.gz
  $ tar xf bar-bundle.tar.gz
  $ cp -R bootstrap bar-bundle/
  $ sh ./bar-bundle/compile.sh
  This bundle will compile the application to $TESTCASE_ROOT/bar-bundle, WITHOUT installing
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
  Already compiled OCaml found
  
  ================ Bootstrap: compiling opam                     ================
  
  This may take a while. Output is in $TESTCASE_ROOT/bar-bundle/bootstrap.log
  Uncompressing... done
  Configuring... done
  Compiling extra dependencies... done
  Compiling... done
  Installing to temp prefix... done
  
  ================ Configure: initialising opam                  ================
  
  Output is in $TESTCASE_ROOT/bar-bundle/configure.log
  Initialising... done
  Creating sandbox... done
  
  ================ Compile: installing packages                  ================
  
  Output is in $TESTCASE_ROOT/bar-bundle/compile.log
  Compiling packages... done
  Cleaning up... done
  
  All compiled within $TESTCASE_ROOT/bar-bundle. To use the compiled packages:
  
    - either re-run ./bar-bundle/compile.sh with a PREFIX argument to install command wrappers
      (it won't recompile everything)
  
    - or run the following to update the environment in the current shell, so that
      they are in your PATH:
        export PATH="$TESTCASE_ROOT/bar-bundle/bootstrap/bin:$PATH"; eval $(opam env --root "$TESTCASE_ROOT/bar-bundle/opam" --set-root)
  
  $ test -f bar-bundle/bootstrap/bin/opam
  $ test -f ./bar-bundle/opam/default/bin/bar && ./bar-bundle/opam/default/bin/bar
  I'm launching bar !

Cleaning up
  $ rm -r bar-bundle bar-bundle.tar.gz
