#!/bin/sh
# Install the quiet LaTeX build tooling into a project.
#
# Usage: install.sh [target-dir]      (default: current directory)
#   Copies build.sh and .latexmkrc into the target project, and installs a
#   managed LaTeX .gitignore block. An existing build.sh/.latexmkrc that
#   differs is backed up to <file>.bak first. Re-run any time to update a
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

# .gitignore is merged, not overwritten: our rules live inside a delimited
# managed block so project-specific ignores above/below it are preserved.
# Re-running replaces only the block, keeping it idempotent.
install_gitignore() {
  from=$1; to=$2
  begin='# >>> latex-build managed block >>>'
  end='# <<< latex-build managed block <<<'
  if [ ! -f "$to" ]; then
    { echo "$begin"; cat "$from"; echo "$end"; } > "$to"
    echo "created .gitignore (managed block)"
  elif grep -qF "$begin" "$to"; then
    awk -v b="$begin" -v e="$end" -v blk="$from" '
      BEGIN { while ((getline l < blk) > 0) body = body l ORS }
      $0==b { printf "%s\n%s%s\n", b, body, e; inb=1; next }
      inb && $0==e { inb=0; next }
      inb { next }
      { print }
    ' "$to" > "$to.tmp" && mv "$to.tmp" "$to"
    echo "updated .gitignore (managed block)"
  else
    { echo ""; echo "$begin"; cat "$from"; echo "$end"; } >> "$to"
    echo "appended managed block to existing .gitignore"
  fi
}

install_one "$src/build.sh"  "$dst/build.sh"
chmod +x "$dst/build.sh"
install_one "$src/latexmkrc" "$dst/.latexmkrc"
install_gitignore "$src/gitignore" "$dst/.gitignore"
echo "done. build with:  (cd \"$dst\" && ./build.sh)"
