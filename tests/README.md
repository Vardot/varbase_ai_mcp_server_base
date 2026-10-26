# Varbase functional testing suite

Playwright and Cucumber through [`@vardot/varbase-e2e`](https://www.npmjs.com/package/@vardot/varbase-e2e), on a
Varbase 11 site with this recipe applied.

| Feature | Covers |
| --- | --- |
| `01-01-ai-mcp-server-base-endpoint.feature` | The MCP endpoint asks an unknown client to sign in; its OAuth 2.1 discovery offers read and draft scopes and no publish scope |
| `01-02-ai-mcp-server-base-setup.feature` | Publishing stays a human action: the scopes say so and the MCP agent role drafts but cannot publish; the OAuth 2.1 dashboard and its settings pages open |
| `01-03-ai-mcp-server-base-access.feature` | Editorial roles and visitors cannot change what MCP exposes |
| `01-04-ai-mcp-server-base-accessibility.feature` | The MCP tools page gives every field a label and every link a name |

## Run it

```bash
npm install
LAUNCH_URL=https://your-site.ddev.site npm test
```

The site needs the webmaster (`webmaster`) and one user per role, named after the role (`content_editor`,
`content_admin`, `seo_admin`, `site_admin`), all with the password in `LOGIN_PASS` (default `dD.123123ddd`).
`.gitlab-ci.yml` shows the whole setup.

## AI provider

CI applies Drupal CMS AI before the recipe. It sets up an amazee.ai trial as the default provider, so no key
is needed. The suite makes no AI calls of its own: MCP clients bring their own model.
