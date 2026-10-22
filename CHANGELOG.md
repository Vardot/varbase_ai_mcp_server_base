# Changelog

All notable changes to the Varbase AI MCP Server Base recipe are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.0.5] - 2026-10-12
### Changed
- Renamed the repository and the package from `varbase_ai_mcp_server` to `varbase_ai_mcp_server_base`, and the recipe
  title to "Varbase AI MCP Server Base", to match the other Varbase AI base recipes. The recipe contents are
  unchanged. Projects change the Composer requirement to `vardot/varbase_ai_mcp_server_base`, the repository URL to
  `git@github.com:Vardot/varbase_ai_mcp_server_base.git` and the recipe path to
  `recipes/varbase_ai_mcp_server_base` (#7).

## [1.0.4] - 2026-10-12
### Added
- Draft writes (#6): `mcp:write` grants enabled (authorization code, refresh token, client credentials), bounded by
  `mcp_agent`; `entity_stub`, `entity_revision_add`, `field_set_value` and `entity_save` exposed behind `mcp:write`;
  `mcp_agent` may create and edit its own `blog` and `page` drafts, view its own unpublished content and use the
  `create_new_draft` transition only.

### Changed
- `mcp:publish` keeps every grant disabled and re-applying now enforces it. Server instructions: writes are drafts or
  pending revisions, show a diff before saving, never publish. CI checks the exact permission and tool lists, and
  that no delete or publish tool is exposed (#6).

### Checked
- 12 October 2026, by hand on a Varbase 11.0.x-dev DDEV site upgraded from 1.0.3 (applied twice, inline checks
  PASS): an `mcp:read` token got 403 `insufficient_scope` on a write tool; an `mcp:write` token created a blog post
  that ended unpublished in `draft`; editing a published post left the live version unchanged with a pending draft;
  setting `published` was refused; an `mcp:publish` token request answered `invalid_scope`.

## [1.0.3] - 2026-10-12
### Added
- `entity_load_by_property` and `entity_metadata` read tools, each requiring `mcp:read` (#5).

### Fixed
- Body fields could not be read: `entity_field_values` failed on every node because `mcp_agent` could not use
  `content_format`. The role now has `use text format content_format` (#5).

## [1.0.2] - 2026-10-12
### Changed
- Removed `tests/verify.php`: the repository now holds no PHP file. CI runs the same no-key checks inline
  (`drush php:eval` in `.github/workflows/ci.yml`), and the lint job fails on any `.php`, `.module`, `.install` or
  `.inc` file (#4).

### Checked
- CI on 1.0.x (https://github.com/Vardot/varbase_ai_mcp_server_base/actions/runs/38238509990): the lint job found no PHP file, the recipe applied twice, the inline
  check printed `RESULT: PASS` and the functional tests passed.

## [1.0.1] - 2026-10-12
### Changed
- Create the `mcp:write` and `mcp:publish` scopes with every grant disabled, so `drush mcp:status` and the status
  report no longer show them as missing, and no token can carry them (#3).

## [1.0.0] - 2026-10-12
### Added
- The recipe: MCP Server 2.x on `/mcp` with OAuth 2.1 (Simple OAuth 6, Simple OAuth 2.1 discovery,
  PKCE and dynamic client registration, MCP Server OAuth) and the `drupal/mcp` module for scope enforcement, without
  running its setup. One scope, `mcp:read`, bounded by a new `mcp_agent` role that can only read and connect. Six
  read-only Tool Belt tools, each requiring `mcp:read`. PKCE settings S256 only. Read-only server instructions.
- `docs/decisions/0001-oauth-2-1-authentication.md`: OAuth 2.1 against a shared site login (Basic auth).
- `tests/verify.php`: checks the modules, scope, role, the six tools and that every enabled tool on `/mcp` is a read
  tool requiring only `mcp:read`, with no key and no client.
- GitHub Actions CI: lint, then a Varbase 11 site (Varbase Starter, MariaDB 11.8) that applies the recipe twice,
  runs `tests/verify.php`, checks the discovery documents and the 401 on `/mcp`, and runs the functional tests.
- README, `AGENTS.md`, `LICENSE`, `logo.png`, composer metadata, and the Vardot issue and pull request templates.

### Checked
- 12 October 2026, by hand on a fresh Varbase 11.0.x-dev build in DDEV: applied twice, `tests/verify.php` PASS,
  discovery 200, `/mcp` 401 without a token, read tools work with an `mcp:read` token, and write tools exposed
  temporarily behind `mcp:write` were refused with 403 `insufficient_scope` on the save path.
- 12 October 2026, on a second fresh Varbase 11.0.x-dev build in DDEV (a local copy of this recipe, applied twice, with
  `tests/verify.php` PASS): a headless client limited to `mcp:read` listed the six read tools and read content, and
  `entity_save` and the publish tool answered "Tool not found". In a real browser a content editor holding the
  `mcp_agent` role saw a consent screen asking only to read content and site structure, and the resulting token listed
  the six read tools, read content and could not call a write tool.

[Unreleased]: https://github.com/Vardot/varbase_ai_mcp_server_base/compare/1.0.5...1.0.x
[1.0.5]: https://github.com/Vardot/varbase_ai_mcp_server_base/compare/1.0.4...1.0.5
[1.0.4]: https://github.com/Vardot/varbase_ai_mcp_server_base/compare/1.0.3...1.0.4
[1.0.3]: https://github.com/Vardot/varbase_ai_mcp_server_base/compare/1.0.2...1.0.3
[1.0.2]: https://github.com/Vardot/varbase_ai_mcp_server_base/compare/1.0.1...1.0.2
[1.0.1]: https://github.com/Vardot/varbase_ai_mcp_server_base/compare/1.0.0...1.0.1
[1.0.0]: https://github.com/Vardot/varbase_ai_mcp_server_base/releases/tag/1.0.0
