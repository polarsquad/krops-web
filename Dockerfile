# syntax=docker/dockerfile:1

# Stage 1: build the static site with MkDocs.
FROM docker.io/library/python:3.14-slim@sha256:a2b82f3c48559aa0a8446d9af49826b6e2b2016f4cd2afabfe6013ec53729170 AS build
COPY --from=ghcr.io/astral-sh/uv:0.13.0@sha256:cdc6093146eb3ff6a40107b38f008b789e050e77ad87865e381d9917da55a168 /uv /bin/uv
WORKDIR /work
ENV UV_LINK_MODE=copy UV_PYTHON_DOWNLOADS=never
COPY pyproject.toml uv.lock ./
RUN uv sync --locked --no-dev --no-install-project
COPY mkdocs.yml ./
COPY tools/ tools/
COPY src/ src/
COPY deps/krops/README.md deps/krops/README.md
COPY deps/krops/docs/ deps/krops/docs/
RUN uv run --no-sync python tools/assemble_docs.py \
 && uv run --no-sync mkdocs build --strict

# Stage 2: serve it. nginx-unprivileged runs as uid 101, listens on 8080,
# and keeps pid/cache under /tmp, so the root filesystem can be read-only.
FROM docker.io/nginxinc/nginx-unprivileged:1.31-alpine@sha256:b9241c6e7b8e9a862f129d8d4199ab64b10390949a78bdd5603379b32c844083
COPY docker/default.conf /etc/nginx/conf.d/default.conf
COPY --from=build /work/build/site/ /usr/share/nginx/html/
EXPOSE 8080
