#!/bin/sh
# Install the quiet LaTeX build tooling into a project.
#
# Usage: install.sh [--commit] [target-dir]   (default: current directory)
#   Copies build.sh and .latexmkrc into the target project, and installs a
#   managed LaTeX .gitignore block. An existing build.sh/.latexmkrc that
#   differs is backed up to <file>.bak first. Re-run any time to update a
#   project to the latest tooling.
#
#   In an Overleaf clone (origin on git.overleaf.com) build.sh and .latexmkrc
#   are kept local: listed in the clone's .git/info/exclude so they never sync
#   to collaborators. Pass --commit to leave them committable instead.
set -e
src=$(cd "$(dirname "$0")" && pwd)
commit=0
if [ "$1" = "--commit" ]; then commit=1; shift; fi
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

# Keep the tooling out of Overleaf clones via .git/info/exclude (per-clone,
# never pushed), as a managed block so re-running is idempotent. --commit
# removes the block.
local_exclude() {
  git -C "$dst" rev-parse --git-dir >/dev/null 2>&1 || return 0
  case $(git -C "$dst" remote get-url origin 2>/dev/null) in
    *git.overleaf.com*) ;;
    *) return 0 ;;
  esac
  excl=$(cd "$dst" && git rev-parse --path-format=absolute --git-path info/exclude)
  prefix=$(git -C "$dst" rev-parse --show-prefix)
  begin='# >>> latex-build local tooling >>>'
  end='# <<< latex-build local tooling <<<'
  mkdir -p "$(dirname "$excl")"
  touch "$excl"
  awk -v b="$begin" -v e="$end" '
    $0==b { inb=1; next }
    inb && $0==e { inb=0; next }
    inb { next }
    { print }
  ' "$excl" > "$excl.tmp" && mv "$excl.tmp" "$excl"
  if [ "$commit" = 1 ]; then
    echo "--commit: build.sh/.latexmkrc left committable"
    return 0
  fi
  printf '%s\n/%sbuild.sh\n/%s.latexmkrc\n%s\n' \
    "$begin" "$prefix" "$prefix" "$end" >> "$excl"
  echo "Overleaf clone: build.sh/.latexmkrc kept local (.git/info/exclude)"
  tracked=$(git -C "$dst" ls-files build.sh .latexmkrc)
  if [ -n "$tracked" ]; then
    echo "warning: already tracked, exclude has no effect until untracked:" >&2
    echo "  (cd \"$dst\" && git rm --cached $(echo $tracked))" >&2
  fi
}
local_exclude

echo "done. build with:  (cd \"$dst\" && ./build.sh)"
