---
name: latex-build
description: Build LaTeX papers and proposals token-efficiently (quiet build.sh wrapper around latexmk, bibtex-forcing .latexmkrc, managed LaTeX .gitignore) and clone/sync Overleaf projects over git with token auth. Use for any task that compiles a .tex file, touches an Overleaf project, or sets up a new paper repo.
---

# LaTeX build + Overleaf sync

Scripts live next to this file (`~/.claude/skills/latex-build/` when installed as a skill).

## Building

- **Always `./build.sh`** (or `./build.sh <main.tex>`), never raw `latexmk` /
  `pdflatex` — the raw output is hundreds of lines and floods context. The
  script prints only exit status, undefined refs/citations, overfull boxes and
  page count; the full log is `<main>.log`.
- `.latexmkrc` forces a bibtex pass, so a new `\cite{}` resolves on a normal build.
- **If a project lacks `build.sh` / `.latexmkrc` / a LaTeX `.gitignore`**, install them:

      ~/.claude/skills/latex-build/install.sh [project-dir]

  Idempotent; re-run to update. It writes the `.gitignore` as a managed block
  (project-specific lines preserved), never blanket-ignores `*.pdf` (figures
  stay tracked), and does **not** untrack artifacts already committed — clear
  those once with `git rm --cached <file>...`. If the main file is not
  `main.tex`, add its root `.pdf` to the project `.gitignore` by hand.
- Projects get *copies*, not symlinks. In an Overleaf clone (origin on
  `git.overleaf.com`) `build.sh` and `.latexmkrc` are kept local via the
  clone's `.git/info/exclude`, so they never sync to collaborators; a fresh
  clone therefore needs `install.sh` again. `install.sh --commit` keeps them
  committable instead. Other repos commit them. Don't copy `build.sh` between
  paper repos; the installer is the source of truth.

## Overleaf projects

- Paper repos are plain git clones of `https://git.overleaf.com/<project-id>`.
  **Every push syncs to Overleaf** and is visible to collaborators — edit freely,
  commit/push deliberately, never push build artifacts.
- **Auth:** an Overleaf git token, expected in the environment as
  `OVERLEAF_API_KEY`. Use it as the *password* with username `git`. A
  `-c credential.helper=...` is *appended* to the configured helper list, so a
  system helper (osxkeychain, Git Credential Manager) still runs first and pops
  a login dialog (`fatal: User cancelled dialog` on macOS). Always reset the
  list with an empty helper first, then supply the env-token helper. Clone
  token-free, so the token never lands in the remote URL:

      OVERLEAF_HELPER='!f(){ echo username=git; echo password=$OVERLEAF_API_KEY; };f'
      git -c credential.helper= -c credential.helper="$OVERLEAF_HELPER" clone https://git.overleaf.com/<project-id> <dir>

  Then make it permanent for that clone (stores the helper script, which reads
  the env var — not the token), so plain `git pull` / `git push` work:

      git -C <dir> config --local --replace-all credential.helper ''
      git -C <dir> config --local --add credential.helper "$OVERLEAF_HELPER"

  For a one-off on a clone without that config:

      git -c credential.helper= -c credential.helper="$OVERLEAF_HELPER" pull

  Never echo a remote URL that embeds the token; pipe through the same `sed`.
- A fresh clone has no build tooling — run `install.sh` on it before building.
