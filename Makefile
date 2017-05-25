all: opam-bundle opam-bundle.install

opam-bundle: opamBundleMain.ml
	ocamlfind ocamlopt -package cmdliner,opam-repository,opam-client -linkpkg -w A-44 $^ -o $@

opam-bundle.install:
	echo 'bin: "opam-bundle"' >$@

.PHONY:clean install
clean:
	rm -f *.cm* *.o *.a *.lib *.install opam-bundle

install: opam-bundle.install opam-bundle
	opam-installer opam $<
