#!/bin/sh
# Install the quiet LaTeX build tooling into a project.
#
# Usage: install.sh [target-dir]      (default: current directory)
#   Copies build.sh and .latexmkrc into the target project. An existing file
#   that differs is backed up to <file>.bak first. Re-run any time to update a
#   project to the latest tooling.
set -e
src=$(cd "$(dirname "$0")" && pwd)
dst=${1:-$(pwd)}
[ -d "$dst" ] || { echo "install.sh: no such directory: $dst" >&2; exit 1; }

install_one() {
  from=$1; to=$2
  if [ -f "$to" ] && ! cmp -s "$from" "$to"; then
    cp "$to" "$to.bak"
    echo "backed up $(basename "$to") -> $(basename "$to").bak"
  fi
  cp "$from" "$to"
  echo "installed $(basename "$to")"
}

install_one "$src/build.sh"  "$dst/build.sh"
chmod +x "$dst/build.sh"
install_one "$src/latexmkrc" "$dst/.latexmkrc"
echo "done. build with:  (cd \"$dst\" && ./build.sh)"
