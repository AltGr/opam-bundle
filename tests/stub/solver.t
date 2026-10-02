This test verify solver requests of opam lib

  $ . ../env-vars
Repo initial setup with two packages `foo` and `bar` that depends on `foo` and other required packages.
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
Foo packages.
  $ mkdir -p REPO/packages/foo/foo.1
  $ cat > REPO/packages/foo/foo.1/opam << EOF
  > opam-version: "2.0"
  > EOF
  $ mkdir -p REPO/packages/foo/foo.2
  $ cp REPO/packages/foo/foo.1/opam REPO/packages/foo/foo.2/opam
  $ mkdir -p REPO/packages/foo/foo.3
  $ cp REPO/packages/foo/foo.1/opam REPO/packages/foo/foo.3/opam
  $ mkdir -p REPO/packages/foo/foo.4
  $ cp REPO/packages/foo/foo.1/opam REPO/packages/foo/foo.4/opam
Bar package.
  $ mkdir -p REPO/packages/bar/bar.1
  $ cat > REPO/packages/bar/bar.1/opam << EOF
  > opam-version: "2.0"
  > EOF
  $ mkdir -p REPO/packages/bar/bar.2
  $ cp REPO/packages/bar/bar.1/opam REPO/packages/bar/bar.2/opam
  $ mkdir -p REPO/packages/bar/bar.3
  $ cp REPO/packages/bar/bar.1/opam REPO/packages/bar/bar.3/opam
  $ mkdir -p REPO/packages/bar/bar.4
  $ cp REPO/packages/bar/bar.1/opam REPO/packages/bar/bar.4/opam
Baz package.
  $ mkdir -p REPO/packages/baz/baz.1
  $ cat > REPO/packages/baz/baz.1/opam << EOF
  > opam-version: "2.0"
  > depends: [ ("foo" { < "6"} | "bar" { > "2"}) "ocaml" { > "4.14.2" } ]
  > EOF
  $ mkdir -p REPO/packages/baz/baz.2
  $ cp REPO/packages/baz/baz.1/opam REPO/packages/baz/baz.2/opam
  $ mkdir -p REPO/packages/baz/baz.3
  $ cp REPO/packages/baz/baz.1/opam REPO/packages/baz/baz.3/opam
  $ mkdir -p REPO/packages/baz/baz.4
  $ cp REPO/packages/baz/baz.1/opam REPO/packages/baz/baz.4/opam
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
Copy all
  $ cat > copy-all.sh << EOF
  > for n in ocaml ocaml-base-compiler ocaml-system ; do
  >   for v in 4.14.1 4.14.3 5.02.3 5.4.1 6.0.1 ; do
  >     mkdir -p REPO/packages/\$n/\$n.\$v/
  >     cp REPO/packages/\$n/\$n.4.14.0/opam REPO/packages/\$n/\$n.\$v/opam
  >   done
  > done
  > EOF
  $ sh copy-all.sh


============================== Test 1 ==============================


Bundle single package `baz`.
  $ opam-bundle baz --repository ./REPO --ocaml=4.14.3 --debug 2>debug | sed -f ../arch.sed
  OCaml version is set to 4.14.3.
  No opam version selected, will use 2.6.0.
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
    - baz.4
    - foo.4
    - ocaml.4.14.3
    - ocaml-base-compiler.4.14.3
    - ocaml-bootstrap.4.14.3
    - ocaml-config.2
  According to the packages' metadata, the bundle should be installable on any arch/OS.
  Continue ? [Y/n] n
  $ grep SOLVER debug
  SOLVER                          resolve request=install:baz & ocaml-bootstrap (= 4.14.3) remove:() upgrade:()
  SOLVER                          Load cudf universe (depopts:false, build:true, post:true)
  SOLVER                          Load cudf universe (depopts:false, build:true, post:true)
  SOLVER                          Calling solver builtin-0install with criteria -count[avoid-version,solution]
  SOLVER                          External solver took 0.000s
  SOLVER                          Load cudf universe (depopts:true, build:false, post:false)
  SOLVER                          Load cudf universe (depopts:true, build:false, post:false)
  SOLVER                          Load cudf universe (depopts:true, build:true, post:false)
  SOLVER                          Load cudf universe (depopts:true, build:true, post:false)
  SOLVER                          resolve request=install:ocaml-base-compiler (= 4.14.3) remove:() upgrade:()
  SOLVER                          Load cudf universe (depopts:false, build:true, post:true)
  SOLVER                          Load cudf universe (depopts:false, build:true, post:true)
  SOLVER                          Calling solver builtin-0install with criteria -count[avoid-version,solution]
  SOLVER                          External solver took 0.000s
  SOLVER                          Load cudf universe (depopts:true, build:false, post:false)
  SOLVER                          Load cudf universe (depopts:true, build:false, post:false)
  SOLVER                          Load cudf universe (depopts:true, build:true, post:false)
  SOLVER                          Load cudf universe (depopts:true, build:true, post:false)
