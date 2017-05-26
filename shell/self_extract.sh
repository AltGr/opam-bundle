#!/bin/sh -ue

dd bs=%{blocksize}% if="$0" skip=%{blocks}% 2>/dev/null | tar xz
exec $(basename $0 .sh)/compile.sh
