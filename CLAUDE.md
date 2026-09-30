# latex-build --- quiet LaTeX build tooling

Canonical source for the `build.sh` + `.latexmkrc` used across LaTeX papers and
proposals. This file is meant to be `@`-imported into research/proposal
contexts so agents know how to build without flooding their context.

## Cloning / syncing an Overleaf project
Overleaf's git bridge needs a token, and the interactive credential prompt fails
from a non-interactive subprocess ("User cancelled dialog" / "Device not
configured"). The token is in the environment as **`OVERLEAF_API_KEY`** (set in
`~/.zshrc`); use it as the *password* with username `git`, via a credential
helper so the token never lands in the remote URL or `.git/config`. Reset the
helper list with an empty helper first --- a `-c credential.helper=...` is
otherwise *appended* after any global helpers (osxkeychain, Git Credential
Manager), which run first and can pop a login dialog:

    OVERLEAF_HELPER='!f(){ echo username=git; echo password=$OVERLEAF_API_KEY; };f'
    git -c credential.helper= -c credential.helper="$OVERLEAF_HELPER" clone https://git.overleaf.com/<project-id> <dir>

Then make it permanent for that clone (stores the helper script, not the token):

    git -C <dir> config --local --replace-all credential.helper ''
    git -C <dir> config --local --add credential.helper "$OVERLEAF_HELPER"

Older clones may have the token embedded in the remote URL; never echo such a
remote unredacted --- pipe through `sed "s/${OVERLEAF_API_KEY}/<TOKEN>/g"`.

A fresh Overleaf clone typically has no build tooling --- run `install.sh` on it
(see below) before building.

## Building a project that has these files
- Build with **`./build.sh`** (or `./build.sh <main.tex>` for a non-default
  main file). It runs latexmk quietly and prints only a short summary: exit
  status, undefined refs/citations, overfull boxes, and page count. The full
  log is `<main>.log`.
- **Do not call `latexmk`/`pdflatex` directly** in tool calls --- the raw output
  is hundreds of lines and floods context. `build.sh` exists to keep it small.
- `.latexmkrc` forces a bibtex pass (`$bibtex_use = 2`), so a newly added
  `\cite{}` resolves on a normal build without a manual `bibtex main`.

## If a project lacks build.sh / .latexmkrc / a LaTeX .gitignore
Install them:

    ~/Sites/software/latex-build/install.sh [project-dir]

(defaults to the current directory; re-run any time to update a project to the
latest tooling --- it backs up differing `build.sh`/`.latexmkrc` to `<file>.bak`).

`install.sh` also installs a **generic LaTeX `.gitignore`** (build artifacts:
`*.aux`, `*.log`, `*.out`, `*.fls`, `*.fdb_latexmk`, `*.bbl`, `*.synctex.gz`, …,
plus the root output `main.pdf` and `.DS_Store`). It is written as a **delimited
managed block**, so project-specific ignore lines are preserved and re-running
only refreshes the block (idempotent). Two cautions baked into the file:

- It never blanket-ignores `*.pdf` --- figures (`imgs/*.pdf`) stay tracked. Only
  the conventional root output `/main.pdf` is ignored; if a project's main file
  has another name, add its `.pdf` (root-anchored) to the project `.gitignore`.
- Installing the `.gitignore` does **not** untrack files already committed. If a
  project has build artifacts in git history (they show up as always-"modified"),
  clear them once with `git rm --cached <file>...` after installing.

**When interacting with any Overleaf / LaTeX project that lacks this tooling,
run `install.sh` so it picks up the quiet build + the standard `.gitignore`.**
The canonical `.gitignore` source is `gitignore` in this repo (installed as
`.gitignore`, mirroring how `latexmkrc` installs as `.latexmkrc`).

## Overleaf clones keep the tooling local
In an Overleaf clone (origin on `git.overleaf.com`), `install.sh` lists
`build.sh` and `.latexmkrc` in the clone's `.git/info/exclude` (a managed block,
never pushed), so they don't appear in collaborators' Overleaf file list. A
fresh clone therefore needs `install.sh` again. `install.sh --commit` removes
the block and leaves them committable. If they were already committed, it warns;
untrack them once with `git rm --cached build.sh .latexmkrc`.

## Source of truth
Edit the tooling here in `~/Sites/software/latex-build/`, then re-run
`install.sh` in each project to propagate. Projects get **copies** (not
symlinks); outside Overleaf clones they are committed, so those projects stay
portable to clusters that never see `~/Sites/software`.
