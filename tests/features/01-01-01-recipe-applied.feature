@varbase-ai @mcp-server @recipe
Feature: The Varbase AI MCP Server recipe exposes read and draft tools, never publish
  As a Varbase site builder
  I want the recipe to expose read tools and draft-writing tools on /mcp, each behind OAuth
  So that external assistants can read and draft content but never delete or publish it

  Scenario: The read and draft tools are exposed and no delete or publish tool is
    Given I am a logged in user with the "Webmaster" user
    When I navigate to "/admin/config/services/mcp-server/tools"
    Then I should see "tool_api__tool_belt_entity_type_list"
     And I should see "tool_api__tool_belt_entity_bundle_field_definitions"
     And I should see "tool_api__tool_belt_entity_field_value_definitions"
     And I should see "tool_api__tool_belt_entity_list"
     And I should see "tool_api__tool_belt_entity_load_by_id"
     And I should see "tool_api__tool_belt_entity_field_values"
     And I should see "tool_api__tool_belt_entity_load_by_property"
     And I should see "tool_api__tool_belt_entity_metadata"
     And I should see "tool_api__tool_belt_entity_stub"
     And I should see "tool_api__tool_belt_entity_revision_add"
     And I should see "tool_api__tool_belt_field_set_value"
     And I should see "tool_api__tool_belt_entity_save"
     And I should not see "tool_api__tool_belt_entity_delete"
     And I should not see "tool_api__tool_belt_entity_create"
     And I should not see "tool_api__tool_belt_entity_update"
     And I should not see "tool_api__mcp_publish_content"
     And I the page should not have PHP errors

  Scenario: The OAuth scopes page loads
    Given I am a logged in user with the "Webmaster" user
    When I navigate to "/admin/config/people/simple_oauth/oauth2_scope"
    Then I the page should not have PHP errors
