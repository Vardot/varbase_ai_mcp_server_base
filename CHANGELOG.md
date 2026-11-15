# Changelog

All notable changes to the Varbase AI MCP Server Base recipe are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.0.0-rc1] - 2026-11-15
### Added
- Automated functional acceptance tests for the MCP server and its OAuth 2.1 pages, run in CI on a fresh Varbase 11 site, with an accessibility check ([#3633137](https://www.drupal.org/i/3633137)).
- A Claude Code agent and skill for applying and verifying the recipe ([#3633912](https://www.drupal.org/i/3633912)).

### Changed
- Use MCP Server alone and drop the `drupal/mcp` `2.0.x-dev` requirement ([#3633506](https://www.drupal.org/i/3633506)).
- Move the documentation to docs.varbase.vardot.com ([#3633032](https://www.drupal.org/i/3633032)).
- Update Node.js to `>= 24.0` in `package.json` and the GitLab CI ([#3635709](https://www.drupal.org/i/3635709)).
- Disable Drupal CMS telemetry in CI ([#3633855](https://www.drupal.org/i/3633855)).
- Update the version badge to `1.0.0-rc1` in `README.md`.

### Fixed
- Install Simple OAuth Native Apps so the OAuth 2.1 pages open ([#3633137](https://www.drupal.org/i/3633137)).

## [1.0.0-alpha1] - 2026-10-24
### Added
- Initialize Varbase AI MCP Server Base recipe ([#3632429](https://www.drupal.org/i/3632429)).
### Removed
- The GitHub Actions workflows and the `.github` templates: CI runs on git.drupalcode.org.

[Unreleased]: https://git.drupalcode.org/project/varbase_ai_mcp_server_base/-/compare/1.0.0-rc1...1.0.x
[1.0.0-rc1]: https://git.drupalcode.org/project/varbase_ai_mcp_server_base/-/compare/1.0.0-alpha1...1.0.0-rc1
[1.0.0-alpha1]: https://git.drupalcode.org/project/varbase_ai_mcp_server_base/-/tags/1.0.0-alpha1
