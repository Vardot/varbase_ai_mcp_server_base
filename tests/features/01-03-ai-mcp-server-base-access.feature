@varbase-ai-mcp-server-base @ai @recipes @access @local @development @staging @production
Feature: Varbase AI Recipe - AI MCP Server Base - Who can change what MCP exposes
  As a site owner
  I want only the super administrator to change the MCP tools and scopes
  So that what an outside assistant can reach is decided in one place

  Scenario Outline: Check the "<user>" user cannot change the MCP tools
    Given I am a logged in user with the "<user>" user
     When I go to "/admin/config/services/mcp-server/tools"
     Then the response status code should be 403
      And I should see "Access denied"

    Examples:
      | user           |
      | Content editor |
      | Content admin  |
      | Site admin     |

  Scenario: Check an anonymous visitor cannot change the MCP tools
    Given I am an anonymous user
     When I go to "/admin/config/services/mcp-server/tools"
     Then the response status code should be 403
      And I should not see "MCP Wire Name"
