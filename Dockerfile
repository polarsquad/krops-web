# syntax=docker/dockerfile:1

# Stage 1: build the static site with MkDocs.
FROM docker.io/library/python:3.15-slim@sha256:65a65fc7b30b06cb6df4930fd4650697cb23f4c2698ab81fc87e4b031bc36928 AS build
COPY --from=ghcr.io/astral-sh/uv:0.13.8@sha256:5cc1805e2426484abca4ad46ea783bab281fdb225fd82d8ce6d66a81254bac85 /uv /bin/uv
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
FROM docker.io/nginxinc/nginx-unprivileged:1.31-alpine@sha256:b5047b9b76845eac124358373c6852377c52e4b05834a47647e955dd91cb8f1e
COPY docker/default.conf /etc/nginx/conf.d/default.conf
COPY --from=build /work/build/site/ /usr/share/nginx/html/
EXPOSE 8080
