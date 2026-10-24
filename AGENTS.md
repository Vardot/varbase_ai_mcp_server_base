# AGENTS.md

Guidance for AI coding agents working on the Varbase AI MCP Server recipe.

This is a drupal.org project: [drupal.org/project/varbase_ai_mcp_server_base](https://www.drupal.org/project/varbase_ai_mcp_server_base).
Issues live in its [issue queue](https://www.drupal.org/project/issues/varbase_ai_mcp_server_base) and merge requests on
[git.drupalcode.org](https://git.drupalcode.org/project/varbase_ai_mcp_server_base). Its default branch is `1.0.x`; the
GitHub repository is a mirror and takes no issues or pull requests.

## Before you start

- **`CHANGELOG.md`**: what changed in each release, newest first, and where it was checked.
- **`README.md`**: what the recipe adds, what it deliberately leaves out, the runtime steps and the known issues.
- **`docs/decisions/0001-oauth-2-1-authentication.md`**: why OAuth 2.1 and not a shared login.

## When you make a change

- One drupal.org issue and one issue-fork merge request per change, titled `<type>: #<issue> Summary`. The MR
  description ends with the Checkpoints list from `.gitlab/merge_request_templates/default.md`.
- CI must be green before merging: `.gitlab-ci.yml` on git.drupalcode.org validates `composer.json` and lints
  every YAML file.
- No PHP in the repository at all: no `.php`, `.module`, `.install` or `.inc` file.
- All configuration lives in `recipe.yml` and the recipe's own `config/`, never in `config/install` or `config/optional`.
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
- No client or place names anywhere in the repository.
- Never bump the version or tag a release without explicit maintainer approval. Tags are three-segment (`1.0.0`)
  and are never moved once pushed.
