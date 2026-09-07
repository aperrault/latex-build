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

## As a Claude Code skill

The repo doubles as a [Claude Code skill](https://docs.anthropic.com/en/docs/claude-code/skills)
(`SKILL.md` at the root): Claude builds `.tex` projects through `build.sh` so
the compile output stays small, and clones / syncs Overleaf projects over git
using an `OVERLEAF_API_KEY` token from the environment.

```sh
git clone https://github.com/aperrault/latex-build ~/.claude/skills/latex-build
export OVERLEAF_API_KEY=...   # Overleaf → Account settings → Git integration
```

Requires `latexmk` (TeX Live / MacTeX).
