all: build

build:
	dune build
	ln -vfs _build/install/default/bin/opam-bundle .

stub-tests:
	dune build @runtest tests/stub

real-tests:
	dune build @runtest tests/real

.PHONY: tests
tests: stub-tests real-tests
test: tests

.PHONY: clean
clean:
	dune clean
	rm opam-bundle

distclean: clean
	rm -rf _build
