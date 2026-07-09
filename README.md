# latex-build

Quiet LaTeX build tooling for papers and proposals.

- **`build.sh`** — compile the main `.tex` with `latexmk` and print only a short
  summary (errors, undefined refs/citations, badly overfull boxes, page count).
  The full log stays in `<main>.log`. Auto-detects the main file, or pass one:
  `./build.sh paper.tex`.
- **`latexmkrc`** — installed as `.latexmkrc`; forces a `bibtex` pass so a newly
  added `\cite{}` resolves on a normal build (no manual `bibtex` step).
- **`install.sh [dir]`** — copy both into a project (defaults to the current
  directory). Committed *copies*, not symlinks, so a project stays portable to
  Overleaf, collaborators, and clusters. Re-run to update.

## Use

```sh
./install.sh /path/to/latex/project
cd /path/to/latex/project && ./build.sh
```

Requires `latexmk` (TeX Live / MacTeX).
