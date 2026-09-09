from assemble_docs import rewrite_doc_links, rewrite_readme_links

GH = "https://github.com/polarsquad/krops"


def test_readme_docs_links_become_site_relative():
    assert rewrite_readme_links("[a](docs/architecture.md)") == "[a](architecture.md)"


def test_readme_docs_links_keep_anchors():
    assert (
        rewrite_readme_links("[a](docs/operations.md#pivot-recovery)")
        == "[a](operations.md#pivot-recovery)"
    )


def test_readme_image_links_become_site_relative():
    assert rewrite_readme_links("![l](docs/aws-infra.svg)") == "![l](aws-infra.svg)"


def test_readme_root_file_links_point_at_github():
    assert rewrite_readme_links("[l](LICENSE)") == f"[l]({GH}/blob/main/LICENSE)"
    assert rewrite_readme_links("[r](renovate.json5)") == f"[r]({GH}/blob/main/renovate.json5)"


def test_readme_external_and_anchor_links_untouched():
    text = "[f](https://fluxcd.io/) [m](mailto:x@y.z) [s](#quickstart)"
    assert rewrite_readme_links(text) == text


def test_doc_parent_file_links_point_at_github():
    assert rewrite_doc_links("[b](../bootstrap.toml)") == f"[b]({GH}/blob/main/bootstrap.toml)"
    assert rewrite_doc_links("[a](../AGENTS.md)") == f"[a]({GH}/blob/main/AGENTS.md)"


def test_doc_parent_directory_links_point_at_github_tree():
    assert rewrite_doc_links("[c](../bootstrap-rs/)") == f"[c]({GH}/tree/main/bootstrap-rs)"


def test_doc_sibling_links_untouched():
    text = "[o](./operations.md#pivot-recovery) [s](secrets.md) ![d](air-gap-infra.svg) [x](#write-back)"
    assert rewrite_doc_links(text) == text
