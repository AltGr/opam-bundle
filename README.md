<!-- language: lang-none -->

opam-bundle(1)                Opam-bundle Manual                opam-bundle(1)

NAME
       opam-bundle - Creates standalone source bundle from opam packages

SYNOPSIS
       opam-bundle [OPTION]... PACKAGE...

DESCRIPTION
       This utility can extract a set of packages from opam repositories, and
       bundle them together in a comprehensive source archive, with the
       scripts needed to bootstrap OCaml, opam, and install the packages on a
       fresh, network-less system.

       The opam-depext plugin is included to try and get the required system
       dependencies on the target system (which might, in this case, require
       network, depending on the system configuration).

       The generated bundle includes three scripts, each one calling the
       previous ones if necessary:

       bootstrap.sh
           Compiles OCaml and opam and gets them ready in a local prefix

       configure.sh
           Initialises an opam root within the bundle directory, and gets the
           required system depdendencies

       compile.sh
           Compiles the required packages using the bootstrapped opam. If a
           prefix was specified, and for packages listed on the command-line
           of opam-bundle, wrappers are installed to the prefix for installed
           binaries. These execute the programs within the in-bundle opam
           root, with the proper opam environment.

       For example, assuming foo is a package that installs a bar binary, from
       a bundle generated using opam-bundle foo, a user on a fresh system
       could run tar xzf foo-bundle.tar.gz && ./foo-bundle/compile.sh ~/local
       to get a usable bar binary within ~/local/bin (if the user does not
       have write permission to the given prefix, the script will use sudo).

       Note that the extracted bundle itself should not be moved for the
       wrappers to keep working. Besides the wrappers, nothing is written
       outside of the directory where the bundle was untarred.

ARGUMENTS
       PACKAGE (required)
           List of packages to include in the bundle. Their dependencies will
           be included as well, but only listed packages will have wrappers
           installed. Packages can be specified as NAME[CONSTRAINT][@URL],
           where CONSTRAINT is an optional version constraint starting with
           one of . or =, !=, >, >=, < or <=, and @URL can be specified to use
           the package source from the given URL (in which case, the
           constraint, if any, must be . or =).

OPTIONS
       -d, --with-doc
           Include the packages' doc-only dependencies in the bundle, and make
           the bundle generate their documentation.

       --debug
           Display debug information about what's going on.

       --environment[=VAL] (default=)
           Use the given opam environment, in the form of a list of
           comma-separated 'var=value' bindings, when resolving variables.
           This is used when computing the set of available packages, where
           opam uses variables arch, os, os-distribution, os-version and
           os-family: if undefined, the variables are inferred from the
           current system. If set without argument, an empty environment is
           used: this can be used to ensure the generated bundle won't have
           arch or OS constraints.

       --help[=FMT] (default=auto)
           Show this help in format FMT. The value FMT must be one of `auto',
           `pager', `groff' or `plain'. With `auto', the format is `pager` or
           `plain' whenever the TERM env var is `dumb' or undefined.

       -o VAL, --output=VAL
           Output the bundle to the given file.

       --ocaml=VAL
           Select a version of OCaml to include. It will be used for
           bootstrapping, and must be able to compile opam.

       --opam=VAL
           Select a version of opam to include. That version must be released
           with an upstream "full-archive" available online, and be at least
           2.0.0~rc2, to support all the required features.

       --repository=URL
           URLs of the repositories to use (highest priority first). Note that
           it is required that the OCaml package at the selected version is
           included (see --ocaml), with the hierarchy and alternatives as on
           the default repository ('ocaml-base-compiler', 'ocaml-system' and
           'ocaml-config' packages, with the 'ocaml' wrapper virtual package).
           This makes it possible to bootstrap opam and compile the requested
           packages with a single compilation of OCaml.

       --self
           Generate a self-extracting script besides the .tar.gz bundle

       -t, --with-test
           Include the packages' test-only dependencies in the bundle, and
           make the bundle run the tests on installation.

       -y, --yes
           Confirm all prompts without asking.

Opam-bundle                                                     opam-bundle(1)
