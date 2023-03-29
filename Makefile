all: build

build:
	dune build
	cp _build/install/default/bin/opam-bundle .

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

distclean: clean
	rm -rf _build
	rm opam-bundle
