# syntax=docker/dockerfile:1

# Stage 1: build the static site with MkDocs.
FROM docker.io/library/python:3.15-slim@sha256:d802f03223b9e00604cd54574bcac1a4638914c43683d3f0afd6ebee35f25313 AS build
COPY --from=ghcr.io/astral-sh/uv:0.13.1@sha256:4a1f3666816dafadd20ceb71eac9a7d56d7ef30279f7d64048519ab901ada336 /uv /bin/uv
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
FROM docker.io/nginxinc/nginx-unprivileged:1.31-alpine@sha256:378d0c32f6562f7fd9629170797f57d2b953aa09be983b3daaf4809bb039ca00
COPY docker/default.conf /etc/nginx/conf.d/default.conf
COPY --from=build /work/build/site/ /usr/share/nginx/html/
EXPOSE 8080
