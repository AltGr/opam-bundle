### 0.3
- ported to opam 2.0.0~beta5 (in particular, for the new `depexts:`)
- use the arch, os, etc. variables inferred by opam

### 0.2
- pass `--with-doc`, `--with-test` along in the generated bootstrap/install
  scripts
- check for bootstrapping prerequisites (`cc`, `make`, etc.) before starting
- fixed calls to `sudo`
- fixed escaping bugs on some versions of dash (and probably other shells too)
- fixed nested error messages
- list inferred system packages for user to take over if automatic installation
  fails
- on generation, print the resulting host system constraints together with the
  package selection
- allow specifying `package@URL` to bundle specific package sources,
  independently of repositories
- worked around camlp4 issues related to our use of the "system" compiler
