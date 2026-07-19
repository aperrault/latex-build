# latex-build --- quiet LaTeX build tooling

Canonical source for the `build.sh` + `.latexmkrc` used across LaTeX papers and
proposals. This file is meant to be `@`-imported into research/proposal
contexts so agents know how to build without flooding their context.

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

## Source of truth
Edit the tooling here in `~/Sites/software/latex-build/`, then re-run
`install.sh` in each project to propagate. Projects keep committed **copies**
(not symlinks), so they stay portable to Overleaf, collaborators, and clusters
that never see `~/Sites/software`.
