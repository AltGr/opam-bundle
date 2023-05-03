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
  [ERROR] No solution for odoc & ocaml-bootstrap.4.02.3:   * Incompatible packages:
              - ocaml-bootstrap
              - ocaml-bootstrap -> ocaml -> ocaml-config -> ocaml-base-compiler >= 3.08.0~
            * Missing dependency:
              - ocaml-bootstrap -> ocaml -> ocaml-config -> ocaml-base-compiler < 3.08 -> ocaml < 4.02.3
              no matching version
            * Missing dependency:
              - ocaml-bootstrap -> ocaml -> ocaml-config -> ocaml-base-compiler >= 3.08.0~ -> ocaml < 4.02.3
              no matching version
            * Missing dependency:
              - ocaml-bootstrap -> ocaml -> ocaml-config -> ocaml-base-compiler >= 3.08.0~ -> ocaml >= 4.03.0
              no matching version
            * Missing dependency:
              - ocaml-bootstrap -> ocaml -> ocaml-config -> ocaml-base-compiler >= 3.08.0~ -> ocaml >= 4.04.0
              no matching version
            * Missing dependency:
              - ocaml-bootstrap -> ocaml -> ocaml-config -> ocaml-base-compiler >= 3.08.0~ -> ocaml >= 4.04.1
              no matching version
            * Missing dependency:
              - ocaml-bootstrap -> ocaml -> ocaml-config -> ocaml-base-compiler >= 3.08.0~ -> ocaml >= 4.04.2
              no matching version
            * Missing dependency:
              - ocaml-bootstrap -> ocaml -> ocaml-config -> ocaml-base-compiler >= 3.08.0~ -> ocaml >= 4.05.0
              no matching version
            * Missing dependency:
              - ocaml-bootstrap -> ocaml -> ocaml-config -> ocaml-base-compiler >= 3.08.0~ -> ocaml >= 4.06.0
              no matching version
            * Missing dependency:
              - ocaml-bootstrap -> ocaml -> ocaml-config -> ocaml-base-compiler >= 3.08.0~ -> ocaml >= 4.06.1
              no matching version
            * Missing dependency:
              - ocaml-bootstrap -> ocaml -> ocaml-config -> ocaml-base-compiler >= 3.08.0~ -> ocaml >= 4.07.0
              no matching version
            * Missing dependency:
              - ocaml-bootstrap -> ocaml -> ocaml-config -> ocaml-base-compiler >= 3.08.0~ -> ocaml >= 4.07.1
              no matching version
            * Missing dependency:
              - ocaml-bootstrap -> ocaml -> ocaml-config -> ocaml-base-compiler >= 3.08.0~ -> ocaml >= 4.08.0
              no matching version
            * Missing dependency:
              - ocaml-bootstrap -> ocaml -> ocaml-config -> ocaml-base-compiler >= 3.08.0~ -> ocaml >= 4.08.1
              no matching version
            * Missing dependency:
              - ocaml-bootstrap -> ocaml -> ocaml-config -> ocaml-base-compiler >= 3.08.0~ -> ocaml >= 4.09.0
              no matching version
            * Missing dependency:
              - ocaml-bootstrap -> ocaml -> ocaml-config -> ocaml-base-compiler >= 3.08.0~ -> ocaml >= 4.09.1
              no matching version
            * Missing dependency:
              - ocaml-bootstrap -> ocaml -> ocaml-config -> ocaml-base-compiler >= 3.08.0~ -> ocaml >= 4.10.0
              no matching version
            * Missing dependency:
              - ocaml-bootstrap -> ocaml -> ocaml-config -> ocaml-base-compiler >= 3.08.0~ -> ocaml >= 4.10.1
              no matching version
            * Missing dependency:
              - ocaml-bootstrap -> ocaml -> ocaml-config -> ocaml-base-compiler >= 3.08.0~ -> ocaml >= 4.10.2
              no matching version
            * Missing dependency:
              - ocaml-bootstrap -> ocaml -> ocaml-config -> ocaml-base-compiler >= 3.08.0~ -> ocaml >= 4.11.0
              no matching version
            * Missing dependency:
              - ocaml-bootstrap -> ocaml -> ocaml-config -> ocaml-base-compiler >= 3.08.0~ -> ocaml >= 4.11.1
              no matching version
            * Missing dependency:
              - ocaml-bootstrap -> ocaml -> ocaml-config -> ocaml-base-compiler >= 3.08.0~ -> ocaml >= 4.11.2
              no matching version
            * Missing dependency:
              - ocaml-bootstrap -> ocaml -> ocaml-config -> ocaml-base-compiler >= 3.08.0~ -> ocaml >= 4.12.0
              no matching version
            * Missing dependency:
              - ocaml-bootstrap -> ocaml -> ocaml-config -> ocaml-base-compiler >= 3.08.0~ -> ocaml >= 4.12.1
              no matching version
            * Missing dependency:
              - ocaml-bootstrap -> ocaml -> ocaml-config -> ocaml-base-compiler >= 3.08.0~ -> ocaml >= 4.13.0
              no matching version
            * Missing dependency:
              - ocaml-bootstrap -> ocaml -> ocaml-config -> ocaml-base-compiler >= 3.08.0~ -> ocaml >= 4.13.1
              no matching version
            * Missing dependency:
              - ocaml-bootstrap -> ocaml -> ocaml-config -> ocaml-base-compiler >= 3.08.0~ -> ocaml >= 4.14.0
              no matching version
            * Missing dependency:
              - ocaml-bootstrap -> ocaml -> ocaml-config -> ocaml-base-compiler >= 3.08.0~ -> ocaml >= 4.14.1
              no matching version
            * Missing dependency:
              - ocaml-bootstrap -> ocaml -> ocaml-config -> ocaml-base-compiler >= 3.08.0~ -> ocaml >= 5.0.0
              no matching version
            * Missing dependency:
              - ocaml-bootstrap -> ocaml -> ocaml-config -> ocaml-base-compiler >= 3.08.0~ -> ocaml >= 5.01.0
              no matching version
  
  
  $ sh ./odoc-bundle.sh -y
  sh: 0: cannot open ./odoc-bundle.sh: No such file
  [2]
  $ sh ./odoc-bundle/compile.sh ../ODOC
  sh: 0: cannot open ./odoc-bundle/compile.sh: No such file
  [2]
  $ ODOC/bin/odoc
  ODOC/bin/odoc: not found
  [127]
