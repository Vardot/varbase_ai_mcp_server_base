[![Varbase](https://raw.githubusercontent.com/Vardot/varbase/11.0.x/images/varbase-logo.png)](https://www.drupal.org/project/varbase)

# Varbase AI MCP Server Base
[![Varbase AI MCP Server Base](https://img.shields.io/badge/Varbase%20AI%20MCP%20Server%20Base-1.0.0--alpha1-0d6efc?labelColor=001d38&style=flat-square)](https://www.drupal.org/project/varbase_ai_mcp_server_base)

An **opt-in** Drupal recipe that lets external assistants (Claude.ai, Claude Desktop, other MCP clients)
read a Varbase 11 site and **draft** blog posts and pages over the [Model Context Protocol](https://modelcontextprotocol.io):
an MCP server on `/mcp`, OAuth 2.1, eight read tools and four draft-writing tools. Nothing it writes is ever published:
publishing stays a human action in Drupal.

## Documentation

Read the [Varbase AI MCP Server Base documentation](https://docs.varbase.vardot.com/developers/understanding-varbase/varbase-ai-recipes/varbase-ai-mcp-server-base) on the Varbase docs site.

## Install and apply

```bash
ddev composer config --json extra.drupal-recipe-unpack.ignore '["drupal/varbase_ai_mcp_server_base"]'
ddev composer require drupal/varbase_ai_mcp_server_base:~1
# Rebuild first: the module list is cached from before the require, and the apply
# stops with "is not a known module" without it.
ddev drush cr
ddev drush recipe ../recipes/varbase_ai_mcp_server_base
ddev drush cr
```

When the project already ignores other packages, add to the unpack list rather
than replacing it. Re-applying is safe. On a site that applied 1.0.x, re-applying turns the `mcp:write` grants on and
adds the draft permissions and tools. The `blog` and `page` content types and `varbase_editorial_workflow` must
exist (Varbase 11 has them).

## Automated testing

GitLab CI on [git.drupalcode.org](https://git.drupalcode.org/project/varbase_ai_mcp_server_base) (`.gitlab-ci.yml`) builds
a Varbase 11 site, applies this recipe twice and runs the Varbase functional testing suite in `tests/` on it. See
[tests/README.md](tests/README.md) to run it against a site of your own.

## License

GPL-2.0-or-later. See [LICENSE](LICENSE). Maintained by [Vardot](https://www.vardot.com).
