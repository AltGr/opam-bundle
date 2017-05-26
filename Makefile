all: opam-bundle opam-bundle.install

opam-bundle: opamBundleScripts.ml opamBundleMain.ml
	ocamlfind ocamlopt -package cmdliner,opam-repository,opam-client -linkpkg -w A-44 $^ -o $@

opam-bundle.install:
	echo 'bin: "opam-bundle"' >$@

opamBundleScripts.ml: shell/common.sh shell/bootstrap.sh shell/configure.sh shell/compile.sh
	ocaml ./crunch.ml $^ > $@

.PHONY:clean install
clean:
	rm -f opamBundleScripts.ml *.cm* *.o *.a *.lib *.install opam-bundle

install: opam-bundle.install opam-bundle
	opam-installer opam $<
