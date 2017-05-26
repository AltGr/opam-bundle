all: opam-bundle opam-bundle.install

opam-bundle: src/opamBundleScripts.ml src/opamBundleMain.ml
	ocamlfind ocamlopt -package cmdliner,opam-repository,opam-client -linkpkg -w A-44 -I src $^ -o $@

opam-bundle.install:
	echo 'bin: "opam-bundle"' > $@

src/opamBundleScripts.ml: shell/common.sh shell/bootstrap.sh shell/configure.sh shell/compile.sh shell/self_extract.sh
	ocaml crunch.ml $^ > $@

.PHONY:clean install
clean:
	rm -f opamBundleScripts.ml *.install opam-bundle src/*.cm* src/*.o src/*.*a src/*.lib

install: opam-bundle.install opam-bundle
	opam-installer opam $<
