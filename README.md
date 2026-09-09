# krops-web

Documentation website for [krops](https://github.com/polarsquad/krops),
served at <https://krops.biggs.dog>.

This repository contains no documentation prose. The content is the
`README.md` and `docs/` directory of `polarsquad/krops`, pinned as the git
submodule `deps/krops` and bumped by Renovate. `tools/assemble_docs.py`
copies that content into `build/docs/`, rewriting repository-relative links,
and MkDocs Material renders it with the krops colour scheme. The Dockerfile
builds the site and serves it from `nginx-unprivileged` on port 8080.

## Local development

```sh
git submodule update --init
uv sync
uv run pytest
uv run python tools/assemble_docs.py
uv run mkdocs serve          # http://127.0.0.1:8000
docker build -t krops-web:dev .
docker run --rm -p 8080:8080 krops-web:dev
```

## Publishing

Every push to `main` publishes `ghcr.io/polarsquad/krops-web:sha-<short>`
and `:latest`, signed with cosign (keyless, workflow identity) with an SPDX
SBOM attestation. The biggs.dog cluster pins the image by digest; Renovate
there opens digest-bump PRs.

## Container

`Dockerfile` stage 1 (`python:3.13-slim` + uv) assembles and strict-builds the
site; stage 2 copies `build/site/` into `nginxinc/nginx-unprivileged` (uid
101, port 8080, pid and cache under `/tmp`). The image runs with a read-only
root filesystem given a writable `/tmp`:

```sh
docker run --rm --read-only --tmpfs /tmp -p 8080:8080 krops-web:dev
curl http://127.0.0.1:8080/healthz
```

`/healthz` returns `200 ok` and is the Kubernetes probe endpoint.
