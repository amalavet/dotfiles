#!/bin/bash
set -euo pipefail

file=$(realpath "$1")
cd "$(dirname "$file")"
root=$(git rev-parse --show-toplevel)
exclude=$(git rev-parse --path-format=absolute --git-path info/exclude)
entry="/${file#"$root"/}"

mkdir -p "$(dirname "$exclude")"
touch "$exclude"

if grep -qxF "$entry" "$exclude"; then
	grep -vxF "$entry" "$exclude" >"$exclude.tmp" || true
	mv "$exclude.tmp" "$exclude"
	echo "Unexcluded $entry"
else
	echo "$entry" >>"$exclude"
	echo "Excluded $entry"
fi
