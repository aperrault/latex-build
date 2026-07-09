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

## If a project lacks build.sh / .latexmkrc
Install them:

    ~/Sites/software/latex-build/install.sh [project-dir]

(defaults to the current directory; re-run any time to update a project to the
latest tooling --- it backs up differing files to `<file>.bak`).

## Source of truth
Edit the tooling here in `~/Sites/software/latex-build/`, then re-run
`install.sh` in each project to propagate. Projects keep committed **copies**
(not symlinks), so they stay portable to Overleaf, collaborators, and clusters
that never see `~/Sites/software`.
