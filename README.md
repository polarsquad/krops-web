# krops-web (deprecated)

> **This repository is deprecated and will be archived.**
>
> The documentation site it built now builds from
> [`polarsquad/krops`](https://github.com/polarsquad/krops) itself: the MkDocs
> tooling (assembler, config, and site assets) was folded into that repo in
> [polarsquad/krops#229](https://github.com/polarsquad/krops/pull/229). The
> site deploys to GitHub Pages at <https://krops.build>, and
> `krops.biggs.dog` redirects there.
>
> The `ghcr.io/polarsquad/krops-web` image is no longer built or updated; its
> CI and publish workflows have been removed.

## What this repository was

A standalone MkDocs site for krops. It contained no documentation prose: the
content was the `README.md` and `docs/` directory of `polarsquad/krops`, pinned
as the git submodule `deps/krops` (bumped by Renovate), assembled by
`tools/assemble_docs.py`, rendered with MkDocs Material, and shipped as an
nginx container image for the biggs.dog cluster.

Keeping the site with the content it documents removed the submodule and the
Renovate bump chain; the krops repo's own CI now builds and deploys the site.
