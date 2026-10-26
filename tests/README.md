# Varbase functional testing suite

Playwright and Cucumber through [`@vardot/varbase-e2e`](https://www.npmjs.com/package/@vardot/varbase-e2e), on a
Varbase 11 site with this recipe applied.

| Feature | Covers |
| --- | --- |
| `01-01-ai-mcp-server-base-endpoint.feature` | /mcp asks for OAuth, the resource offers mcp:read and mcp:write and no publish scope, the authorization server metadata |
| `01-02-ai-mcp-server-base-setup.feature` | The read and draft tools, the scopes, and the MCP agent role that drafts and cannot publish |
| `01-03-ai-mcp-server-base-access.feature` | Only the webmaster changes what MCP exposes |

## Run it

```bash
npm install
LAUNCH_URL=https://your-site.ddev.site npm test
```

The site needs the webmaster (`webmaster`) and one user per role, named after the role (`content_editor`,
`content_admin`, `seo_admin`, `site_admin`), all with the password in `LOGIN_PASS` (default `dD.123123ddd`).
`.gitlab-ci.yml` shows the whole setup.

## AI provider

The suite needs no AI provider and no key: it checks the MCP endpoint and its OAuth discovery documents with
plain HTTP requests, and the tools, scopes and role in the admin pages. Signing keys and OAuth clients are not
created, so no token is issued here.

The scenario tagged `@wip` opens the Simple OAuth 2.1 dashboard pages. They answer HTTP 500 today
(`Route "simple_oauth_native_apps.settings" does not exist`), because the dashboard links to a submodule the
recipe does not install.
