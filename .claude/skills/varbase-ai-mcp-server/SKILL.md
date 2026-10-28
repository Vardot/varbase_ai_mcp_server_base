---
name: varbase-ai-mcp-server
description: "Apply, repair and verify Varbase AI MCP Server on a Varbase 11 site: the MCP server at /mcp with OAuth 2.1, so external assistants read the site and save drafts (Varbase AI MCP Server Base). Install and apply commands, inputs, config, post-apply steps, browser checks, traps and versions, read from the recipe code. Use when adding, fixing or checking Varbase AI MCP Server."
---

# Varbase AI MCP Server

Read from `recipe.yml`, `composer.json`, README, CHANGELOG and `git log` at the latest tag, 28 October 2026. Re-check versions on drupal.org before relying on them. For the full Varbase AI apply order, see the Varbase AI recipes docs page.

## Recipes

| Recipe | Latest | Stability | Require |
|---|---|---|---|
| `varbase_ai_mcp_server_base` | 1.0.0-alpha1 | alpha | `drupal/varbase_ai_mcp_server_base:~1` |

Docs (the code wins where they differ):
- https://docs.varbase.vardot.com/developers/understanding-varbase/varbase-ai-recipes/varbase-ai-mcp-server-base

## What it does

- Installs `serialization`, `consumers`, `simple_oauth`, `simple_oauth_21`, `simple_oauth_server_metadata`, `simple_oauth_pkce`, `simple_oauth_client_registration`, `tool`, `mcp_server`, `mcp_server_tool_bridge`, `mcp_server_oauth`, `tool_belt`, `tool_belt_entity`, `tool_belt_content`, `mcp`.
- Creates role `mcp_agent`, scopes `mcp:read`, `mcp:write`, `mcp:publish` (every grant off), and bridges 12 tools: 8 read (`tool_belt_entity_type_list`, `_bundle_field_definitions`, `_field_value_definitions`, `_entity_list`, `_load_by_property`, `_metadata`, `_load_by_id`, `_field_values`) and 4 write (`tool_belt_entity_stub`, `_revision_add`, `tool_belt_field_set_value`, `tool_belt_entity_save`), bounded to drafts of `blog` and `page`.
- Composer: `php >=8.3`, `mcp 2.0.x-dev`, `mcp_server ^2.0@beta`, `mcp_server_oauth ^1.0@alpha`, `mcp_server_tool_bridge ^1.0@beta`, `simple_oauth ^6.1`, `e0ipso/simple_oauth_21 ^1.13`, `consumers ^1.24`, `tool ^1.0@beta`, `tool_belt ^1.0@alpha`. Needs PHP `openssl` and `sodium`, and `varbase_editorial_workflow`. No inputs. Needs no AI provider. Still 1.0.0-alpha1 (no beta1 on 27 Oct).

## Apply

All commands in DDEV, from the project root; recipes are applied from the docroot path `../recipes/<name>`. Take a snapshot first: `ddev snapshot --name before-varbase-ai-mcp-server`. Add each recipe to `extra.drupal-recipe-unpack.ignore` in `composer.json` before requiring it (read the list first: `composer config --json` replaces it).

```bash
ddev composer require drupal/varbase_ai_mcp_server_base:~1
ddev drush cr                                   # before the apply
ddev drush recipe ../recipes/varbase_ai_mcp_server_base -y
ddev exec mkdir -p /var/www/html/keys
ddev drush simple-oauth:generate-keys /var/www/html/keys
ddev drush cset simple_oauth.settings public_key /var/www/html/keys/public.key -y
ddev drush cset simple_oauth.settings private_key /var/www/html/keys/private.key -y
ddev drush user:role:add mcp_agent <user>
```

Keep `/keys/` out of git.

## After the apply

- Drafts only: in the editorial workflow give `mcp_agent` only the `create_new_draft` transition, then prove a publish through MCP is refused.
- After a database copy between environments, `simple_oauth_server_metadata.settings:registration_endpoint` points at the old host: `ddev drush cset simple_oauth_server_metadata.settings registration_endpoint '' -y`.

## Verify

- `/mcp` answers; the OAuth discovery metadata names this host, not an old one (exact path unverified: read it from the README).
- Connect an MCP client as a real `mcp_agent` user (user 1 bypasses scopes), read a page, save a draft, try to publish: refused.

Test as a real editor or visitor, not user 1: a superuser bypasses permissions.

## Traps

- "is not a known module" when the module list is cached: `drush cr` first.
- The save tools are exposed: drafts-only depends on the moderation permissions, not the recipe alone.

## History

Started 22 Oct 2026, 1.0.0-alpha1 24 Oct.
