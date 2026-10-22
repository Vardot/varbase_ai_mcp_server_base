[![Varbase](https://raw.githubusercontent.com/Vardot/varbase/11.0.x/images/varbase-logo.png)](https://www.drupal.org/project/varbase)

# Varbase AI MCP Server Base
[![CI](https://github.com/Vardot/varbase_ai_mcp_server_base/actions/workflows/ci.yml/badge.svg?branch=1.0.x)](https://github.com/Vardot/varbase_ai_mcp_server_base/actions/workflows/ci.yml)
[![Varbase AI MCP Server Base](https://img.shields.io/badge/Varbase%20AI%20MCP%20Server%20Base-1.0.5-0d6efc?labelColor=001d38&style=flat-square)](https://github.com/Vardot/varbase_ai_mcp_server_base/releases/tag/1.0.5)

A private, **opt-in** Drupal recipe that lets external assistants (Claude.ai, Claude Desktop, other MCP clients)
read a Varbase 11 site and **draft** blog posts and pages over the [Model Context Protocol](https://modelcontextprotocol.io):
an MCP server on `/mcp`, OAuth 2.1, eight read tools and four draft-writing tools. Nothing it writes is ever published:
publishing stays a human action in Drupal.

Varbase never applies it by default.

**Experimental.** The whole stack is pre-stable (`drupal/mcp` 2.0.x-dev, MCP Server 2.0 beta, MCP Server OAuth 1.0
alpha, Tool Belt 1.0 alpha), so it is not covered by the Drupal security advisory policy. There is **no custom PHP
and no custom shell code** in the recipe. Its no-key checks run inline in CI, so the repository holds no PHP file at all.

## What it adds

| Part | What it does |
|---|---|
| Modules | MCP Server, Tool Bridge, MCP Server OAuth, Simple OAuth 6 with Simple OAuth 2.1 (discovery metadata, PKCE, dynamic client registration), Tool API, Tool Belt (entity, content) and the `drupal/mcp` umbrella module. Each is justified in `recipe.yml`. |
| Scopes | `mcp:read` (read) and `mcp:write` (draft) allow the authorization-code, refresh-token and client-credentials grants, bounded by the `mcp_agent` role. `mcp:publish` exists with **every grant disabled**: no token can carry it. |
| Role `mcp_agent` | `access mcp server`, `access content`, `grant simple_oauth codes`, `use text format content_format`, and drafts only: create and edit own `blog` and `page` content, view own unpublished content, and the `create_new_draft` transition of `varbase_editorial_workflow`. No delete, review, publish or archive. |
| Eight read tools | `entity_type_list`, `entity_bundle_field_definitions`, `entity_field_value_definitions`, `entity_metadata` (explain the site) and `entity_list`, `entity_load_by_id`, `entity_load_by_property`, `entity_field_values` (read content). Each requires `mcp:read`. |
| Four draft tools | `entity_stub`, `entity_revision_add`, `field_set_value`, `entity_save`. Each requires `mcp:write`. On the wire every tool is `tool_api__tool_belt_<name>`. |
| PKCE settings | Mandatory, S256 only (OAuth 2.1 drops `plain`). See Known issues for what this does and does not change. |
| Server instructions | Which tools to start with; every write is a draft or a new non-default revision; show the user a diff before saving; never publish. |

### What an assistant can do

- **Read** (`mcp:read`): explain the content model and read content the person may see.
- **Draft** (`mcp:write`): create a blog post or page (`entity_stub` -> `field_set_value` -> `entity_save`), saved
  unpublished in the `draft` state; or edit one the person owns (`entity_load_by_id` -> `entity_revision_add` ->
  `field_set_value`, with `moderation_state` `draft` -> `entity_save`), which adds a pending revision and leaves the
  live version unchanged.
- **Never**: publish, archive, delete, or change the content model.

### The safety model

Four independent layers, each enough on its own to stop a publish:

1. **No publish scope.** `mcp:publish` has every grant disabled; a token request for it answers `invalid_scope`.
2. **No publish permission.** `mcp_agent` has only the `create_new_draft` transition, so setting `moderation_state`
   to `published` fails validation.
3. **The publish guard** (`drupal/mcp`): over MCP, saving a published entity without `mcp:publish` is refused, and
   new content is kept unpublished.
4. **No dangerous tool.** `entity_delete`, `entity_create` and `entity_update` (one-shot writes that skip the stub
   and revision steps), the schema tools and `mcp_publish_content` are not exposed.

The role bounds every token, so an assistant never gets more than both the person and `mcp_agent` allow. A person
reviews and publishes drafts in Drupal as usual.

### Scope names

The recipe keeps `drupal/mcp`'s scope names, because its scope enforcement and `drush mcp:client:create` know only
those. Sites that used project-specific scopes map like this:

| Project-specific scope | Here |
|---|---|
| a content read scope plus a "connect" scope | `mcp:read` (connecting is the `access mcp server` permission on `mcp_agent`) |
| a content write scope | `mcp:write`, drafts only |
| Canvas read or build scopes | not covered: no Canvas tools are exposed |

Search over the vector index (`content_vector`, from [Varbase AI Search Base](https://github.com/Vardot/varbase_ai_search_base))
and a site status tool are not part of this version.

### Why OAuth 2.1

See [docs/decisions/0001](docs/decisions/0001-oauth-2-1-authentication.md). In short: each person connects their own
assistant and approves it once, tokens expire in minutes, one client can be revoked alone, and a token never carries
more than the person behind it. A shared site login (Basic auth) has none of that.

### No dependency on Varbase AI Base

MCP does not use the AI module, a provider or a key, so the recipe stands alone, like Varbase AI Content Review Base.
It works on any Drupal 11.4 site; CI builds Varbase Starter.

## Requirements

- Drupal core `^11.4`, PHP 8.3 or later, Drush 13
- `drupal/mcp` `2.0.x-dev` and the stack it requires (`composer.json` lists them). The root project must allow alpha
  packages; Varbase projects already use `minimum-stability: dev` with `prefer-stable`.
- The PHP `openssl` and `sodium` extensions, for the OAuth signing keys.

## Install and apply

```bash
ddev auth ssh
ddev composer config repositories.varbase_ai_mcp_server_base vcs git@github.com:Vardot/varbase_ai_mcp_server_base.git
ddev composer config --json extra.drupal-recipe-unpack.ignore '["vardot/varbase_ai_mcp_server_base"]'
ddev composer require vardot/varbase_ai_mcp_server_base:~1.0.5 --prefer-source
# Rebuild first: the module list is cached from before the require, and the apply
# stops with "is not a known module" without it.
ddev drush cr
ddev drush recipe ../recipes/varbase_ai_mcp_server_base
ddev drush cr
ddev drush php:eval "$(sed -n "/<<'PHP'/,/^ *PHP\$/p" recipes/varbase_ai_mcp_server_base/.github/workflows/ci.yml | sed '1d;$d')"
```

When the project already ignores other packages, add to the unpack list rather
than replacing it. Re-applying is safe. On a site that applied 1.0.x, re-applying turns the `mcp:write` grants on and
adds the draft permissions and tools. The `blog` and `page` content types and `varbase_editorial_workflow` must
exist (Varbase 11 has them).

## After the apply

Keys and clients are runtime state and never belong in config or Git, so the recipe leaves them to you.

```bash
# 1. Signing keys, outside the docroot, never committed (add /keys/ to .gitignore).
#    On a hosted site the directory must persist across deploys.
ddev exec mkdir -p /var/www/html/keys
ddev drush simple-oauth:generate-keys /var/www/html/keys
ddev drush config:set simple_oauth.settings public_key /var/www/html/keys/public.key -y
ddev drush config:set simple_oauth.settings private_key /var/www/html/keys/private.key -y

# 2. Give the MCP agent role to the people who may connect an assistant.
ddev drush user:role:add mcp_agent <username>

# 3. Check.
ddev drush mcp:status
```

People then add `https://<site>/mcp` as a custom connector in their assistant, log in to Drupal and approve. The
assistant registers itself through `/oauth/register`; no client needs to be created by hand.

A **headless agent** gets a client-credentials client (the secret is printed once). Give it `mcp:read` alone to
read, or `mcp:read,mcp:write` to draft; its service user needs the `mcp_agent` role:

```bash
ddev drush mcp:client:create reporting-agent --scopes=mcp:read --label="Reporting agent"
```

**Do not run `drush mcp:setup` or `drush en mcp` on its own**: setup creates agent clients and exposes the publish
tool. Never enable an `mcp:publish` grant.

## Automated testing

`.github/workflows/ci.yml` runs on every pull request, every push to `1.0.x` and every tag:

1. **Lint**: `composer validate`, every YAML file, and PHP syntax.
2. **Apply on a Varbase 11 site**: `drupal/varbase_project` `11.0.x-dev` installed from Varbase Starter on MariaDB
   11.8, with this checkout required through a path repository. The recipe is applied **twice**, then
   the no-key recipe check runs. The site is served and `curl` checks that the discovery documents answer 200 and that an
   unauthenticated `POST /mcp` answers 401 with a `WWW-Authenticate` challenge.
3. **Functional tests**: Playwright + Cucumber through `@vardot/varbase-e2e` in Chromium: the MCP tools page lists
   the read and draft tools and no delete or publish tool, the scopes page loads, and a content
   editor cannot see the tool configuration.

The CI step "Check the recipe without an AI key" (an inline `drush php:eval` in `.github/workflows/ci.yml`) needs no key and no client. It checks the modules, the three scopes (`mcp:publish` with every grant
disabled), that the role has **exactly** the read and draft permissions, that `create_new_draft` ends in `draft`, each
of the twelve tools and its scope, that **no other tool and no delete or publish tool is enabled**, PKCE, and the
server instructions. Keys and clients are INFO lines.

## Checked

By hand on 12 October 2026 on a fresh Varbase 11.0.x-dev build (DDEV, Drupal 11.4.x, PHP 8.4, `drupal/mcp`
2.0.x-dev `ad2b2a0`, MCP Server 2.0.0-beta5, Tool Bridge 1.0.0-beta3, MCP Server OAuth 1.0.0-alpha1, Simple OAuth
6.1.1, Simple OAuth 2.1 1.13.1, Tool Belt 1.0.0-alpha6):

- Applied twice, the recipe check PASS, `drush mcp:status` as expected (keys and the write scopes missing until the
  runtime steps).
- The three discovery documents answer 200 JSON; `POST /mcp` without a token answers 401 with a Bearer challenge
  pointing at `/.well-known/oauth-protected-resource/mcp`.
- With a client-credentials token for `mcp:read`: `initialize` returns the read-only instructions, `tools/list`
  returns the six tools, `entity_list` returns content, and an unexposed write tool answers "Tool not found".
- **Save path:** with write tools exposed temporarily behind `mcp:write` (removed afterwards), the `mcp:read` token
  got HTTP 403 `insufficient_scope` on `entity_stub`, `field_set_value` and `entity_save`, and no node was created.
  That enforcement comes from the `drupal/mcp` module; without it `mcp_server_oauth` 1.0.0-alpha1 enforces nothing
  on Tool Bridge tools.

Draft writes (1.0.4), by hand on 12 October 2026 on a Varbase 11.0.x-dev DDEV site that had 1.0.3 applied
(`drupal/mcp` 2.0.x-dev), applied twice over it, inline checks PASS, with temporary client-credentials clients:

- An `mcp:read` token got HTTP 403 `insufficient_scope` on `entity_stub`.
- An `mcp:write` token created a blog post (stub, `field_content`, save) that ended unpublished in `draft`.
- Editing a published post the user owns: saved without a state change, the publish guard refused it; with
  `moderation_state` `draft`, it saved a pending non-default revision and the live version stayed unchanged.
- Setting `moderation_state` to `published` was refused ("no access to transition from Draft to Published").
- A token request for `mcp:publish` answered `invalid_scope`.

**Not checked:** a connection from Claude.ai itself, Educare, Horizon Aid and The Rightup, and Upsun (where the
keys directory needs a writable mount).

## Known issues

- **PKCE `plain` is still advertised.** `simple_oauth_server_metadata` 1.13.1 hardcodes `["S256", "plain"]` in the
  discovery documents, and `simple_oauth_pkce` settings enforce nothing by themselves (PKCE is demanded by each
  consumer's `pkce` field, which `drupal/mcp` forces on for public clients). Whether the token endpoint refuses a
  `plain` challenge was not tested.
- `mcp_server_oauth` 1.0.0-alpha1 does not match Tool Bridge tool names, so its own scope check never fires.
  `drupal/mcp`'s subscriber enforces the scopes instead, which is why the `mcp` module is installed.
- `/oauth/register` is open to anonymous POSTs with no rate limit (see the decision record).
- User 1 bypasses every scope. Connect with a real account.
- Access tokens last 300 seconds per client by default (the consumer's `access_token_expiration`).

## Related recipes

| Recipe | What it does |
|---|---|
| [Varbase AI Search Base](https://github.com/Vardot/varbase_ai_search_base) | A vector index of the site's content. |
| [Varbase AI Content Review Base](https://github.com/Vardot/varbase_ai_content_review_base) | AI review of content against the site's style guide. |
| [`drupal/mcp`](https://www.drupal.org/project/mcp) `recipes/agent_ready` | The upstream read, write and publish setup this recipe trims to read and draft. |

## License

GPL-2.0-or-later. See [LICENSE](LICENSE). Maintained by [Vardot](https://www.vardot.com).
