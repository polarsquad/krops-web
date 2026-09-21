# syntax=docker/dockerfile:1

# Stage 1: build the static site with MkDocs.
FROM docker.io/library/python:3.14-slim@sha256:caaf356f40667c496d405780745b9ac25771c189a51dfcc42430d531ea09f8a2 AS build
COPY --from=ghcr.io/astral-sh/uv:0.12.17@sha256:10787c682e4184e4f290de1171fd4703dc63de99221f10fe1c99002ce7fa9acc /uv /bin/uv
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
FROM docker.io/nginxinc/nginx-unprivileged:1.31-alpine@sha256:e75f89810bf5bfbcf58a1cfb32a1a11de55b7623d732e67735d513b720d7436a
COPY docker/default.conf /etc/nginx/conf.d/default.conf
COPY --from=build /work/build/site/ /usr/share/nginx/html/
EXPOSE 8080
