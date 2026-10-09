@mcp @contract
Feature: Discover the annotation inbox through MCP
  Coding agents can discover Snap's tools and understand an empty inbox.

  Background:
    Given the snap mcp server with the following properties:
      | url | http://127.0.0.1:${sys:snap.port}/mcp |
    And the data folder with the following properties:
      | path | .axx/snap-mcp |
    And the inbox folder with the following properties:
      | path | .axx/snap-mcp/inbox |
    And the data folder is emptied

  Scenario: An agent discovers all five tools and their argument defaults
    Then the snap mcp server has the check_new_annotations tool
    And the snap mcp server has the get_latest_annotation tool with the following properties:
      | inputSchema.properties.include_image.default   | true    |
      | inputSchema.properties.max_image_bytes.default | 5000000 |
    And the snap mcp server has the list_annotations tool with the following properties:
      | inputSchema.properties.last_n.default        | 5     |
      | inputSchema.properties.include_image.default | false |
    And the snap mcp server has the get_annotation tool with the following properties:
      | inputSchema.required[0]              | filename |
      | inputSchema.properties.filename.type | string   |
    And the snap mcp server has the clear_inbox tool

  Scenario: A fresh inbox has no unread annotations
    When the check_new_annotations tool is called on the snap mcp server
    Then the check_new_annotations tool's result is not an error
    And the check_new_annotations tool's result has the following properties:
      | new_count          | 0         |
      | has_new            | false     |
      | total_in_inbox     | 0         |
      | new_annotations[0] | undefined |

  Scenario: Asking for the latest annotation explains that the inbox is empty
    When the get_latest_annotation tool is called on the snap mcp server
    Then the get_latest_annotation tool's result has the following properties:
      | error | No annotations in inbox |

  Scenario: Listing an empty inbox returns an empty collection
    When the list_annotations tool is called on the snap mcp server
    Then the list_annotations tool's result is not an error
    And the list_annotations tool's result has the following properties:
      | count          | 0         |
      | annotations[0] | undefined |

  Scenario: A missing annotation is identified by its requested name
    When the get_annotation tool is called on the snap mcp server with the following arguments:
      | filename | snap-20990101-100000-404 |
    Then the get_annotation tool's result has the following properties:
      | error | Annotation 'snap-20990101-100000-404' not found |
