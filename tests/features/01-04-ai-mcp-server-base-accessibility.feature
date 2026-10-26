@varbase-ai-mcp-server-base @ai @recipes @a11y @local @development @staging @production
Feature: Varbase AI Recipe - AI MCP Server Base - Accessible MCP settings
  As a site administrator who uses assistive technology
  I want the MCP tools page to work with a keyboard and a screen reader
  So that I can manage what AI clients may do like anyone else

  Scenario: Check the MCP tools page gives every field a label and every link a name
    Given I am a logged in user with the "Webmaster" user
     When I go to "/admin/config/services/mcp-server/tools"
     Then every form field should have an accessible label
      And every link should have an accessible name
      And every ARIA role should be valid
