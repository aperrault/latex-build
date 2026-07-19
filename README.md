# latex-build

Quiet LaTeX build tooling for papers and proposals.

- **`build.sh`** — compile the main `.tex` with `latexmk` and print only a short
  summary (errors, undefined refs/citations, badly overfull boxes, page count).
  The full log stays in `<main>.log`. Auto-detects the main file, or pass one:
  `./build.sh paper.tex`.
- **`latexmkrc`** — installed as `.latexmkrc`; forces a `bibtex` pass so a newly
  added `\cite{}` resolves on a normal build (no manual `bibtex` step).
- **`gitignore`** — installed as `.gitignore`; a generic LaTeX ignore list for
  build artifacts (`*.aux`, `*.log`, `*.fdb_latexmk`, `*.bbl`, `*.synctex.gz`, …,
  plus the root output `main.pdf`). Never blanket-ignores `*.pdf`, so figures
  stay tracked. Merged as a **managed block**, so project-specific ignore lines
  are preserved and re-running only refreshes our block.
- **`install.sh [dir]`** — copy build tooling into a project and install the
  managed `.gitignore` block (defaults to the current directory). Committed
  *copies*, not symlinks, so a project stays portable to Overleaf, collaborators,
  and clusters. Re-run to update.

## Use

```sh
./install.sh /path/to/latex/project
cd /path/to/latex/project && ./build.sh
```

Requires `latexmk` (TeX Live / MacTeX).
