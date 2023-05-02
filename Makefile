all: build

build:
	dune build
	cp _build/install/default/bin/opam-bundle .

.PHONY: clean
clean:
	dune clean

distclean: clean
	rm -rf _build
	rm opam-bundle
