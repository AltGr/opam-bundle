all: opam-bundle opam-bundle.1 opam-bundle.install

opam-bundle: src/opamBundleScripts.ml src/opamBundleMain.ml
	ocamlfind ocamlopt -package cmdliner,opam-repository,opam-client -linkpkg -w A-44 -I src $^ -o $@

opam-bundle.1: opam-bundle
	./$< --help=groff >$@

opam-bundle.install:
	echo 'bin: "opam-bundle"' > $@
	echo 'man: "opam-bundle.1"' >>$@

src/opamBundleScripts.ml: shell/common.sh shell/bootstrap.sh shell/configure.sh shell/compile.sh shell/self_extract.sh
	ocaml crunch.ml $^ > $@

.PHONY:clean distclean install
clean:
	rm -f opamBundleScripts.ml src/*.cm* src/*.o src/*.*a src/*.lib

distclean: clean
	rm -f *.install opam-bundle opam-bundle.1

install: opam-bundle.install opam-bundle opam-bundle.1
	opam-installer opam $<
