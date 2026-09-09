#!/usr/bin/env python3
"""Assemble the MkDocs docs_dir from the polarsquad/krops submodule.

Content is never edited here; only repository-relative links are rewritten so
that the rendered site resolves them (sibling pages) or sends the reader to
GitHub (files that are not part of the documentation).
"""

from __future__ import annotations

import re

GITHUB = "https://github.com/polarsquad/krops"

# Markdown link or image: group 1 = "[text](", group 2 = target, group 3 = ")".
LINK_RE = re.compile(r"(!?\[[^\]]*\]\()([^)\s]+)(\))")


def _is_external(target: str) -> bool:
    return target.startswith(("http://", "https://", "mailto:", "#"))


def github_url(repo_path: str) -> str:
    """URL of a file (blob) or directory (tree, trailing slash) in the krops repo."""
    kind = "tree" if repo_path.endswith("/") else "blob"
    return f"{GITHUB}/{kind}/main/{repo_path.strip('/')}"


def rewrite_readme_links(text: str) -> str:
    """README.md becomes index.md at the docs root, so docs/x -> x; other repo files -> GitHub."""

    def sub(match: re.Match[str]) -> str:
        pre, target, post = match.groups()
        if _is_external(target):
            return match.group(0)
        if target.startswith("docs/"):
            return f"{pre}{target[len('docs/'):]}{post}"
        return f"{pre}{github_url(target)}{post}"

    return LINK_RE.sub(sub, text)
