#!/bin/sh -ue

. "$(dirname "$0")/common.sh"

apply_patches() {
    for patch in $(ls ../patches/*.patch | sort); do
        patch -p1 < $patch
    done
}

logged_cmd "Uncompressing" tar xzf repo/archives/ocaml-base-compiler."%{ocamlv}%"/*.tar.gz
cd "ocaml-%{ocamlv}%"
if [ "$(ls -A ../patches)"  ]; then
    logged_cmd "Applying patches" apply_patches
fi