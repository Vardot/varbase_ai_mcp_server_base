@varbase-ai-mcp-server-base @ai @recipes @api @local @development @staging @production
Feature: Varbase AI Recipe - AI MCP Server Base - The MCP endpoint and its OAuth 2.1 discovery
  As an external AI assistant, such as an MCP client
  I want the site to answer on /mcp and tell me where to authorize
  So that I can connect with OAuth 2.1 and only read or draft what my account may

  Background:
    Given the API base URL is "/"

  Scenario: Check the MCP endpoint asks an unknown client to authenticate
     When I send a GET request to "mcp"
     Then the API response code should be 401
      And the API response should contain "Authentication required"
      And the response header "WWW-Authenticate" should contain "resource_metadata"

  Scenario: Check the MCP resource offers read and draft scopes, and no publish scope
     When I send a GET request to ".well-known/oauth-protected-resource/mcp"
     Then the API response code should be 200
      And the response should be valid JSON
      And the API response should contain "mcp:read"
      And the API response should contain "mcp:write"
      And the API response should not contain "mcp:publish"

  Scenario: Check the authorization server publishes its endpoints and PKCE
     When I send a GET request to ".well-known/oauth-authorization-server"
     Then the API response code should be 200
      And the JSON response should have property "token_endpoint"
      And the JSON response should have property "registration_endpoint"
      And the API response should contain "S256"
