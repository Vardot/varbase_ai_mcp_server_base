@varbase-ai @mcp-server @access
Feature: Only administrators manage the MCP tools
  As a site owner
  I want editors kept out of the MCP tool configuration
  So that nobody widens what assistants can do by accident

  Scenario: A content editor cannot see the MCP tool configuration
    Given I am a logged in user with the "Content editor" user
    When I navigate to "/admin/config/services/mcp-server/tools"
    Then I should not see "tool_api__tool_belt_entity_list"
     And I the page should not have PHP errors
