# AGENTS.md

Guidance for AI coding agents working on the Varbase AI MCP Server recipe.

This is a **private** recipe on GitHub (`Vardot/varbase_ai_mcp_server_base`), not a drupal.org project. Issues, pull
requests and CI all live on GitHub. Its default branch is `1.0.x`.

## Before you start

- **`CHANGELOG.md`**: what changed in each release, newest first, and where it was checked.
- **`README.md`**: what the recipe adds, what it deliberately leaves out, the runtime steps and the known issues.
- **`docs/decisions/0001-oauth-2-1-authentication.md`**: why OAuth 2.1 and not a shared login.

## When you make a change

- One issue and one pull request per change. The PR says `Closes #<issue>` and ends with the Checkpoints list from
  `.github/pull_request_template.md`.
- Add an entry under `## [Unreleased]` in `CHANGELOG.md`.
- CI must be green before merging: it applies the recipe twice on a real Varbase 11 site, runs the no-key recipe check,
  checks the discovery documents and the 401 on `/mcp`, then runs the functional tests.
- **Draft, never publish, is the contract.** Read tools sit behind `mcp:read`; the four draft tools (`entity_stub`,
  `entity_revision_add`, `field_set_value`, `entity_save`) behind `mcp:write`. Never enable an `mcp:publish` grant,
  never expose `entity_delete`, `entity_create`, `entity_update`, a schema tool or `mcp_publish_content`, and never
  grant `mcp_agent` a publish, archive, review, delete, bypass or admin permission without an issue that decides it.
  The CI check fails on any tool or permission outside the allowed lists.
- Never put signing keys, client secrets or tokens in config, `recipe.yml`, tests, CI or docs. They are runtime state.
- Never apply `drupal/mcp`'s `agent_ready` recipe or call its setup from here: both add write and publish.
- No PHP in the repository at all: no `.php`, `.module`, `.install` or `.inc` file. The no-key checks run inline in
  `.github/workflows/ci.yml` (`drush php:eval`), and the lint job fails on any PHP file.
- No client or place names anywhere in the repository.
- Never bump the version or tag a release without explicit maintainer approval. Tags are three-segment (`1.0.0`)
  and are never moved once pushed.
