This test verify different package specifications that could be used with `opam-bundle`.
Every package used is a stub package.

  $ export OPAMNOENVNOTICE=1
  $ export OPAMYES=1
  $ export OPAMROOT=$PWD/OPAMROOT
  $ export OPAMSTATUSLINE=never
  $ export OPAMVERBOSE=-1
  $ opam --version
  2.1.4
Different version of one stub executable
  $ cat > compile << EOF
  > #!/bin/sh
  > echo "I'm launching \$(basename \${0}) \$@!"
  > EOF
  $ chmod +x compile
  $ tar czf compile.tar.gz compile
  $ SHA=`openssl sha256 compile.tar.gz | cut -d ' ' -f 2`
  $ cat > compile1 << EOF
  > #!/bin/sh
  > echo "I'm launching \$(basename \${0}) v.1 \$@!"
  > EOF
  $ chmod +x compile1
  $ tar czf compile1.tar.gz compile1
  $ SHA1=`openssl sha256 compile1.tar.gz | cut -d ' ' -f 2`
  $ cat > compile2 << EOF
  > #!/bin/sh
  > echo "I'm launching \$(basename \${0}) v.2 \$@!"
  > EOF
  $ chmod +x compile2
  $ tar czf compile2.tar.gz compile2
  $ SHA2=`openssl sha256 compile2.tar.gz | cut -d ' ' -f 2`
  $ cat > compile3 << EOF
  > #!/bin/sh
  > echo "I'm launching \$(basename \${0}) v.3 \$@!"
  > EOF
  $ chmod +x compile3
  $ tar czf compile3.tar.gz compile3
  $ SHA3=`openssl sha256 compile3.tar.gz | cut -d ' ' -f 2`
  $ cat > compile4 << EOF
  > #!/bin/sh
  > echo "I'm launching \$(basename \${0}) v.4 \$@!"
  > EOF
  $ chmod +x compile4
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
=== Foo packages ===
Package which isn't included in repository.
  $ mkdir foo.4
  $ cat > foo.4/test.patch << EOF
  > --- foo.4/compile4
  > +++ foo.4/compile4
  > @@ -1 +1 @@
  > -echo "I'm launching \$(basename \${0}) v.4 \$@!"
  > +echo "I'm launching with patch \$(basename \${0}) v.4 \$@!"
  > EOF
  $ cat > foo.4/opam << EOF
  > opam-version: "2.0"
  > version: "4"
  > build: [ "sh" "compile4" name ]
  > install: [
  >  [ "cp" "compile4" "%{bin}%/%{name}%" ]
  > ]
  > depends : [
  >  "ocaml" {>= "4.14.0"}
  > ]
  > extra-source "repo" {
  >  src: "file://./REPO/repo"
  > }
  > patches : ["test.patch"]
  > EOF
  $ cp compile4 foo.4/
Repository packages
  $ mkdir -p REPO/packages/foo/foo.1 REPO/packages/foo/foo.2 REPO/packages/foo/foo.3
  $ cat > REPO/packages/foo/foo.1/opam << EOF
  > opam-version: "2.0"
  > version: "1"
  > build: [ "sh" "compile1" name ]
  > install: [
  >  [ "cp" "compile1" "%{bin}%/%{name}%" ]
  > ]
  > depends : [
  >  "ocaml" {>= "4.12.0"}
  > ]
  > url {
  >  src: "file://./compile1.tar.gz"
  >  checksum: "sha256=$SHA1"
  > }
  > EOF
  $ cat > REPO/packages/foo/foo.2/opam << EOF
  > opam-version: "2.0"
  > version: "2"
  > build: [ "sh" "compile2" name ]
  > install: [
  >  [ "cp" "compile2" "%{bin}%/%{name}%" ]
  > ]
  > depends : [
  >  "ocaml" {>= "4.13.0"}
  > ]
  > url {
  >  src: "file://./compile2.tar.gz"
  >  checksum: "sha256=$SHA2"
  > }
  > EOF
  $ cat > REPO/packages/foo/foo.3/opam << EOF
  > opam-version: "2.0"
  > version: "3"
  > build: [ "sh" "compile3" name ]
  > install: [
  >  [ "cp" "compile3" "%{bin}%/%{name}%" ]
  > ]
  > depends : [
  >  "ocaml" {>= "4.14.0"}
  > ]
  > url {
  >  src: "file://./compile3.tar.gz"
  >  checksum: "sha256=$SHA3"
  > }
  > EOF
Bar packages.
  $ mkdir -p REPO/packages/bar/bar.1 REPO/packages/bar/bar.2 REPO/packages/bar/bar.3/files
  $ cat > REPO/packages/bar/bar.1/opam << EOF
  > opam-version: "2.0"
  > version: "1"
  > build: [ "sh" "compile1" name ]
  > install: [
  >  [ "cp" "compile1" "%{bin}%/%{name}%" ]
  > ]
  > depends : [
  >  "ocaml" {>= "4.14.0"}
  >  "foo" {= "1"}
  > ]
  > url {
  >  src: "file://./compile1.tar.gz"
  >  checksum: "sha256=$SHA1"
  > }
  > EOF
  $ cat > REPO/packages/bar/bar.2/opam << EOF
  > opam-version: "2.0"
  > version: "2"
  > build: [ "sh" "compile2" name ]
  > install: [
  >  [ "cp" "compile2" "%{bin}%/%{name}%" ]
  > ]
  > depends : [
  >  "ocaml" {>= "4.14.0"}
  >  "foo" {<= "2"}
  > ]
  > url {
  >  src: "file://./compile2.tar.gz"
  >  checksum: "sha256=$SHA2"
  > }
  > EOF
  $ cat > REPO/packages/bar/bar.3/files/test.patch << EOF
  > --- bar/compile3
  > +++ bar/compile3
  > @@ -1 +1 @@
  > -echo "I'm launching \$(basename \${0}) v.3 \$@!"
  > +echo "I'm launching with patch \$(basename \${0}) v.3 \$@!"
  > EOF
  $ cat > REPO/packages/bar/bar.3/opam << EOF
  > opam-version: "2.0"
  > version: "3"
  > build: [ "sh" "compile3" name ]
  > install: [
  >  [ "cp" "compile3" "%{bin}%/%{name}%" ]
  > ]
  > depends : [
  >  "ocaml" {>= "4.14.0"}
  >  "foo" {>= "3"}
  > ]
  > patches : ["test.patch"]
  > url {
  >  src: "file://./compile3.tar.gz"
  >  checksum: "sha256=$SHA3"
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



Running opam-bundle with sanitized output that contains replaced platform specific information.


============================== Test 1 ==============================


Bundle single package `bar` of version 2. That implies installation of its dependency `foo` with constraint "<=2".

  $ opam-bundle bar.2 --repository ./REPO --ocaml=4.14.0 -y 2>&1 | sed 's/arch =.*/arch = $ARCH/;s/os =.*/os = $OS/;s/os-distribution =.*/os-distribution = $OSDISTRIB/;s/os-version =.*/os-version = $OSVERSION/;s/os-family =.*/os-family = $OSFAMILLY/'
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
    - bar.2
    - foo.2
    - ocaml.4.14.0
    - ocaml-base-compiler.4.14.0
    - ocaml-bootstrap.4.14.0
    - ocaml-config.2
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
  bar-bundle/opam-full-2.1.0-rc2.tar.gz
  bar-bundle/repo/
  bar-bundle/repo/archives/
  bar-bundle/repo/archives/bar.2/
  bar-bundle/repo/archives/bar.2/compile2.tar.gz
  bar-bundle/repo/archives/foo.2/
  bar-bundle/repo/archives/foo.2/compile2.tar.gz
  bar-bundle/repo/archives/ocaml-base-compiler.4.14.0/
  bar-bundle/repo/archives/ocaml-base-compiler.4.14.0/ocaml.tar.gz
  bar-bundle/repo/archives/ocaml.4.14.0/
  bar-bundle/repo/archives/ocaml.4.14.0/compile.tar.gz
  bar-bundle/repo/cache/
  bar-bundle/repo/packages/
  bar-bundle/repo/packages/bar/
  bar-bundle/repo/packages/bar/bar.2/
  bar-bundle/repo/packages/bar/bar.2/opam
  bar-bundle/repo/packages/foo/
  bar-bundle/repo/packages/foo/foo.2/
  bar-bundle/repo/packages/foo/foo.2/opam
  bar-bundle/repo/packages/ocaml-base-compiler/
  bar-bundle/repo/packages/ocaml-base-compiler/ocaml-base-compiler.4.14.0/
  bar-bundle/repo/packages/ocaml-base-compiler/ocaml-base-compiler.4.14.0/opam
  bar-bundle/repo/packages/ocaml-bootstrap/
  bar-bundle/repo/packages/ocaml-bootstrap/ocaml-bootstrap.4.14.0/
  bar-bundle/repo/packages/ocaml-bootstrap/ocaml-bootstrap.4.14.0/opam
  bar-bundle/repo/packages/ocaml-config/
  bar-bundle/repo/packages/ocaml-config/ocaml-config.2/
  bar-bundle/repo/packages/ocaml-config/ocaml-config.2/opam
  bar-bundle/repo/packages/ocaml/
  bar-bundle/repo/packages/ocaml/ocaml.4.14.0/
  bar-bundle/repo/packages/ocaml/ocaml.4.14.0/opam
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

  $ opam exec --root ./bar-bundle/opam -- foo
  I'm launching foo v.2 !
  $ opam exec --root ./bar-bundle/opam -- bar
  I'm launching bar v.2 !
  $ find BAR | sort
  BAR
  BAR/bin
  BAR/bin/bar
  $ BAR/bin/bar
  I'm launching bar v.2 !

Cleaning up
  $ rm -r BAR bar-bundle bar-bundle.tar.gz


============================== Test 2 ==============================


Bundle two packages `bar` and `foo>2`. Forcing constraint on `foo` implies installation of `bar.3`.
Since `foo` was specified as argument to `opam-bundle` it installs additionally `foo` wrapper.

  $ opam-bundle bar 'foo>2' --repository ./REPO --ocaml=4.14.0 -y 2>&1 | sed 's/arch =.*/arch = $ARCH/;s/os =.*/os = $OS/;s/os-distribution =.*/os-distribution = $OSDISTRIB/;s/os-version =.*/os-version = $OSVERSION/;s/os-family =.*/os-family = $OSFAMILLY/'
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
    - bar.3
    - foo.3
    - ocaml.4.14.0
    - ocaml-base-compiler.4.14.0
    - ocaml-bootstrap.4.14.0
    - ocaml-config.2
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
  bar-bundle/opam-full-2.1.0-rc2.tar.gz
  bar-bundle/repo/
  bar-bundle/repo/archives/
  bar-bundle/repo/archives/bar.3/
  bar-bundle/repo/archives/bar.3/compile3.tar.gz
  bar-bundle/repo/archives/foo.3/
  bar-bundle/repo/archives/foo.3/compile3.tar.gz
  bar-bundle/repo/archives/ocaml-base-compiler.4.14.0/
  bar-bundle/repo/archives/ocaml-base-compiler.4.14.0/ocaml.tar.gz
  bar-bundle/repo/archives/ocaml.4.14.0/
  bar-bundle/repo/archives/ocaml.4.14.0/compile.tar.gz
  bar-bundle/repo/cache/
  bar-bundle/repo/packages/
  bar-bundle/repo/packages/bar/
  bar-bundle/repo/packages/bar/bar.3/
  bar-bundle/repo/packages/bar/bar.3/files/
  bar-bundle/repo/packages/bar/bar.3/files/test.patch
  bar-bundle/repo/packages/bar/bar.3/opam
  bar-bundle/repo/packages/foo/
  bar-bundle/repo/packages/foo/foo.3/
  bar-bundle/repo/packages/foo/foo.3/opam
  bar-bundle/repo/packages/ocaml-base-compiler/
  bar-bundle/repo/packages/ocaml-base-compiler/ocaml-base-compiler.4.14.0/
  bar-bundle/repo/packages/ocaml-base-compiler/ocaml-base-compiler.4.14.0/opam
  bar-bundle/repo/packages/ocaml-bootstrap/
  bar-bundle/repo/packages/ocaml-bootstrap/ocaml-bootstrap.4.14.0/
  bar-bundle/repo/packages/ocaml-bootstrap/ocaml-bootstrap.4.14.0/opam
  bar-bundle/repo/packages/ocaml-config/
  bar-bundle/repo/packages/ocaml-config/ocaml-config.2/
  bar-bundle/repo/packages/ocaml-config/ocaml-config.2/opam
  bar-bundle/repo/packages/ocaml/
  bar-bundle/repo/packages/ocaml/ocaml.4.14.0/
  bar-bundle/repo/packages/ocaml/ocaml.4.14.0/opam
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
  Wrapper foo installed successfully.

  $ opam exec --root ./bar-bundle/opam -- foo
  I'm launching foo v.3 !
  $ opam exec --root ./bar-bundle/opam -- bar
  I'm launching with patch bar v.3 !
  $ find BAR | sort
  BAR
  BAR/bin
  BAR/bin/bar
  BAR/bin/foo
  $ BAR/bin/foo
  I'm launching foo v.3 !
  $ BAR/bin/bar
  I'm launching with patch bar v.3 !

Cleaning up
  $ rm -r BAR bar-bundle bar-bundle.tar.gz


============================== Test 3 ==============================


Bundle two packages `bar` and `foo@foo.4` where "foo.4" is a url to local version of package `foo`. This package
has extra-source (opam-bundle archive 0.4) that should be also bundled. Forcing constraint on `foo` implies
installation of `bar.3`. Since `foo` was specified as argument to `opam-bundle` it installs additionally `foo`
wrapper.

  $ opam-bundle bar 'foo@foo.4' --repository ./REPO --ocaml=4.14.0 -y 2>&1 | sed 's/arch =.*/arch = $ARCH/;s/os =.*/os = $OS/;s/os-distribution =.*/os-distribution = $OSDISTRIB/;s/os-version =.*/os-version = $OSVERSION/;s/os-family =.*/os-family = $OSFAMILLY/;s/md5=.*/md5=$HASH/'
  No environment specified, will use the following for package resolution (based on the host system):
    - arch = $ARCH
    - os = $OS
    - os-distribution = $OSDISTRIB
    - os-version = $OSVERSION
    - os-family = $OSFAMILLY
  
  <><> Initialising repositories ><><><><><><><><><><><><><><><><><><><><><><><><>
  [home] Initialised
  
  <><> Getting external packages ><><><><><><><><><><><><><><><><><><><><><><><><>
  [NOTE] Will use package definition found in source for foo
  
  <><> Resolving package set ><><><><><><><><><><><><><><><><><><><><><><><><><><>
  The following packages will be included:
    - bar.3
    - foo.4
    - ocaml.4.14.0
    - ocaml-base-compiler.4.14.0
    - ocaml-bootstrap.4.14.0
    - ocaml-config.2
  According to the packages' metadata, the bundle should be installable on any arch/OS.
  [NOTE] Opam system sandboxing (introduced in 2.0) will be disabled in the bundle. You need to trust that the build scripts of the included packages don't write outside of their build directory and dest dir.
  Continue ? [Y/n] y
  
  <><> Getting all archives <><><><><><><><><><><><><><><><><><><><><><><><><><><>
  [WARNING] Extra source repo of foo.4 from file://./REPO/repo had no recorded checksum: adding md5=$HASH
  
  <><> Getting bootstrap packages <><><><><><><><><><><><><><><><><><><><><><><><>
  
  <><> Building bundle ><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
  Done. Bundle generated as $TESTCASE_ROOT/bar-bundle.tar.gz

  $ tar xvf bar-bundle.tar.gz | grep -v sha256 | grep -v md5 | sort
  bar-bundle/
  bar-bundle/bootstrap.sh
  bar-bundle/common.sh
  bar-bundle/compile.sh
  bar-bundle/configure.sh
  bar-bundle/opam-full-2.1.0-rc2.tar.gz
  bar-bundle/repo/
  bar-bundle/repo/archives/
  bar-bundle/repo/archives/bar.3/
  bar-bundle/repo/archives/bar.3/compile3.tar.gz
  bar-bundle/repo/archives/foo.4/
  bar-bundle/repo/archives/foo.4/foo.4.tar.gz
  bar-bundle/repo/archives/foo.4/repo
  bar-bundle/repo/archives/ocaml-base-compiler.4.14.0/
  bar-bundle/repo/archives/ocaml-base-compiler.4.14.0/ocaml.tar.gz
  bar-bundle/repo/archives/ocaml.4.14.0/
  bar-bundle/repo/archives/ocaml.4.14.0/compile.tar.gz
  bar-bundle/repo/cache/
  bar-bundle/repo/packages/
  bar-bundle/repo/packages/bar/
  bar-bundle/repo/packages/bar/bar.3/
  bar-bundle/repo/packages/bar/bar.3/files/
  bar-bundle/repo/packages/bar/bar.3/files/test.patch
  bar-bundle/repo/packages/bar/bar.3/opam
  bar-bundle/repo/packages/foo/
  bar-bundle/repo/packages/foo/foo.4/
  bar-bundle/repo/packages/foo/foo.4/opam
  bar-bundle/repo/packages/ocaml-base-compiler/
  bar-bundle/repo/packages/ocaml-base-compiler/ocaml-base-compiler.4.14.0/
  bar-bundle/repo/packages/ocaml-base-compiler/ocaml-base-compiler.4.14.0/opam
  bar-bundle/repo/packages/ocaml-bootstrap/
  bar-bundle/repo/packages/ocaml-bootstrap/ocaml-bootstrap.4.14.0/
  bar-bundle/repo/packages/ocaml-bootstrap/ocaml-bootstrap.4.14.0/opam
  bar-bundle/repo/packages/ocaml-config/
  bar-bundle/repo/packages/ocaml-config/ocaml-config.2/
  bar-bundle/repo/packages/ocaml-config/ocaml-config.2/opam
  bar-bundle/repo/packages/ocaml/
  bar-bundle/repo/packages/ocaml/ocaml.4.14.0/
  bar-bundle/repo/packages/ocaml/ocaml.4.14.0/opam
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
  Wrapper foo installed successfully.

  $ opam exec --root ./bar-bundle/opam -- foo
  I'm launching with patch foo v.4 !
  $ opam exec --root ./bar-bundle/opam -- bar
  I'm launching with patch bar v.3 !
  $ find BAR | sort
  BAR
  BAR/bin
  BAR/bin/bar
  BAR/bin/foo
  $ BAR/bin/foo
  I'm launching with patch foo v.4 !
  $ BAR/bin/bar
  I'm launching with patch bar v.3 !



============================== Test 4 (fail) ==============================


Trying to bundle two packages `bar.3` and `foo.1`. This should fail, because those versions are not compatible.

  $ opam-bundle bar.3 foo.1 --repository ./REPO --ocaml=4.14.0 -y 2>&1 | sed 's/arch =.*/arch = $ARCH/;s/os =.*/os = $OS/;s/os-distribution =.*/os-distribution = $OSDISTRIB/;s/os-version =.*/os-version = $OSVERSION/;s/os-family =.*/os-family = $OSFAMILLY/'
  No environment specified, will use the following for package resolution (based on the host system):
    - arch = $ARCH
    - os = $OS
    - os-distribution = $OSDISTRIB
    - os-version = $OSVERSION
    - os-family = $OSFAMILLY
  
  <><> Initialising repositories ><><><><><><><><><><><><><><><><><><><><><><><><>
  [home] Initialised
  
  <><> Resolving package set ><><><><><><><><><><><><><><><><><><><><><><><><><><>
  [ERROR] No solution for bar.3 & foo.1 & ocaml-bootstrap.4.14.0:   * No agreement on the version of foo:
              - bar >= 3 -> foo >= 3
              - foo < 2
  
  



============================== Test 5 (fail) ==============================


Trying to bundle two packages `bar` and `foo<3@foo.4`. This should fail, because package with url can be constrained only with '.' or '='.

  $ opam-bundle bar 'foo<2@foo.4' --repository ./REPO --ocaml=4.14.0 -y 2>&1 | sed 's/arch =.*/arch = $ARCH/;s/os =.*/os = $OS/;s/os-distribution =.*/os-distribution = $OSDISTRIB/;s/os-version =.*/os-version = $OSVERSION/;s/os-family =.*/os-family = $OSFAMILLY/'
  opam-bundle: PACKAGE… arguments: Only equality version constraints can be
               specified together with a target URL
  Usage: opam-bundle [OPTION]… PACKAGE…
  Try 'opam-bundle --help' for more information.
