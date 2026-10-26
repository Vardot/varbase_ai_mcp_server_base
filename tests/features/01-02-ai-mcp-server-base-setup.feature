@varbase-ai-mcp-server-base @ai @recipes @local @development @staging @production
Feature: Varbase AI Recipe - AI MCP Server Base - Read tools, draft tools and the MCP agent role
  As a site owner
  I want MCP clients to read content and write drafts, while publishing stays a human action
  So that an assistant can help with content without being able to publish anything

  Background:
    Given I am a logged in user with the "Webmaster" user

  Scenario: Check the read and draft-writing tools are exposed over MCP
     When I go to "/admin/config/services/mcp-server/tools"
     Then I should see "tool_belt:entity_list"
      And I should see "tool_belt:entity_load_by_id"
      And I should see "tool_belt:entity_revision_add"
      And I should see "tool_belt:field_set_value"
      And I should not see "tool_belt:entity_delete"

  Scenario: Check the publish scope says publishing is a human action
     When I go to "/admin/config/people/simple_oauth/oauth2_scope/dynamic"
     Then I should see "mcp:read"
      And I should see "Create and edit drafts through MCP. Never publishes."
      And I should see "Not available: publishing is a human action on this site."

  Scenario: Check the MCP agent role creates drafts and cannot publish
     When I go to "/admin/people/permissions/mcp_agent"
     Then the checkbox labeled "MCP agent: Blog post: Create new content" should be checked
      And the checkbox labeled "MCP agent: Editorial workflow: Use Create new draft transition." should be checked
      And the checkbox labeled "MCP agent: Editorial workflow: Use Publish transition." should be unchecked

  Scenario: Check the OAuth 2.1 dashboard opens
     When I go to "/admin/config/people/simple_oauth/oauth-21"
     Then the response status code should be 200
      And I should see "Compliance"
      And I should see "Native Apps"

  Scenario Outline: Check the OAuth 2.1 "<settings>" page opens
     When I go to "<path>"
     Then the response status code should be 200
      And I should see "<settings> Settings"

    Examples:
      | settings            | path                                                             |
      | PKCE                | /admin/config/people/simple_oauth/oauth-21/pkce                  |
      | Server Metadata     | /admin/config/people/simple_oauth/oauth-21/server-metadata       |
      | Client Registration | /admin/config/services/simple-oauth/oauth-21/client-registration |
      | Native Apps         | /admin/config/people/simple_oauth/oauth-21/native-apps           |
