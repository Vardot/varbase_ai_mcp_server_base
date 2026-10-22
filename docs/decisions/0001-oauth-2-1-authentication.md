# 0001: OAuth 2.1 for the MCP endpoint, not Basic auth

- **Status:** Accepted for 1.0.x-dev on 12 October 2026. Maintainer review pending.

## Context

The read-only MCP server this recipe generalises (nine tools, from an earlier project) relied on a shared Drupal
site login, the Basic auth model: one account, used by whoever configured the assistant. The recipe asks for the
same read-only server in Varbase and for a comparison of that auth model with OAuth 2.1.

The callers are external assistants: Claude.ai and other MCP clients run by people, and headless agents.

## Options

| | A. HTTP Basic auth (core `basic_auth`) | B. OAuth 2.1 (`simple_oauth` 6, `simple_oauth_21`, `mcp_server_oauth`, `drupal/mcp`) |
|---|---|---|
| What the client holds | A username and password, sent on every request | A short-lived access token (300 s per client by default) and a refresh token |
| Who a call acts as | Always the one shared account | The person who logged in and approved, or a service user for client credentials |
| Limiting what a client can do | Only by that account's roles | Scope per tool (`mcp:read`), intersected with the person's own permissions and the scope's role |
| Revoking one client | Change the password, which breaks every client | Delete or disable the one consumer, or revoke its tokens |
| Leaked credential | A full site login, valid until changed, usable on `/user/login` too | A token for `/mcp` only, expiring in minutes |
| Interactive clients (Claude.ai, Claude Desktop, MCP Inspector) | Need a static `Authorization` header, which interactive connectors generally do not let a person set | The MCP authorization spec flow: discovery under `/.well-known/`, dynamic registration, login, consent, PKCE |
| Audit | Every call is the same user | Every token names its client and user |
| Moving parts | One core module | Seven modules, all pre-stable; signing keys on disk outside the docroot |

## Decision

**B, OAuth 2.1.** The recipe installs the drupal/mcp stack, exposes only `mcp:read` tools, and makes each tool
require that scope. People connect their own assistant and approve it once; a token is never bigger than the
person behind it or than the `mcp_agent` role.

Basic auth is not installed and not configured on `/mcp`.

## Consequences

- **Runtime steps after the apply.** The signing keys and any client-credentials client are created by a person,
  not by the recipe: keys and secrets must never live in config or in Git. The README lists the commands.
- **Do not run `drush mcp:setup` on a read-only site.** It creates the `mcp:write` and `mcp:publish` scopes, two
  agent clients and five more tools that write or publish. `drush mcp:client:create <id> --scopes=mcp:read` creates
  a read-only client without them.
- **Dynamic client registration is open.** `/oauth/register` accepts anonymous POSTs and cannot be switched off:
  `mcp_server_oauth` depends on the module, and interactive clients need it. A registered client gets nothing until
  a person with the `mcp_agent` role logs in and approves it, and `drupal/mcp` forces PKCE on every public client.
  There is no rate limit on registration; a site that worries about it adds one at the edge (WAF or CDN).
- **User 1 bypasses scopes.** A token approved by user 1 can call every exposed tool with full access. Connect with
  a real account, and consider `$settings['security.enable_super_user'] = FALSE;`.
- **Pre-stable stack.** `mcp_server_oauth` 1.0.0-alpha1 does not match Tool Bridge tool names, so `drupal/mcp`'s
  own subscriber enforces the scopes. That is why the recipe installs the `mcp` module while skipping its setup.
- **Scope enforcement depends on the `mcp` module.** On a scratch site, a token with `mcp:read` was refused (HTTP 403
  `insufficient_scope`) on `entity_stub`, `field_set_value` and `entity_save` exposed behind `mcp:write`. A stack
  without `drupal/mcp`'s subscriber would have let those calls through, so a site that drops the module loses the
  scope model.

## Addendum, 1.0.4: draft writes (12 October 2026)

- **Decision:** `mcp:write` gets its grants, bounded by `mcp_agent`, with four draft tools (`entity_stub`,
  `entity_revision_add`, `field_set_value`, `entity_save`). `mcp:publish` keeps every grant disabled: an assistant
  drafts, a person publishes in Drupal.
- **Why it stays safe:** the role holds only create and edit-own for `blog` and `page`, view own unpublished, and the
  `create_new_draft` transition; `drupal/mcp`'s publish guard refuses a published save without `mcp:publish`; delete,
  one-shot create/update and publish tools are not exposed. Edits to live content become pending revisions.
- **Consequence:** a token can now change content, so a prompt injection in read content could produce an unwanted
  draft. It cannot publish it. The server instructions ask the assistant to show a diff and get agreement first.

## Not checked

- A connection from Claude.ai itself (the interactive login and consent).
- The claim that interactive connectors cannot send a static `Authorization` header. Re-check it against the
  assistant's own connector documentation before relying on it.
