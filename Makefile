all: build

build:
	dune build
	ln -vfs _build/install/default/bin/opam-bundle .

stub-tests: build
	dune runtest tests/stub/

real-tests: build
	dune runtest tests/real/

.PHONY: tests
tests: stub-tests real-tests
test: tests

.PHONY: clean
clean:
	dune clean
	rm opam-bundle

distclean: clean
	rm -rf _build
