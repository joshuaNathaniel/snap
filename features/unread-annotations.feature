@mcp @unread
Feature: Track whether the agent has read the inbox
  Checking for feedback is non-destructive. Reading the latest capture or listing
  captures marks the inbox read; retrieving one named capture does not.

  Background:
    Given the snap mcp server with the following properties:
      | url | http://127.0.0.1:${sys:snap.port}/mcp |
    And the data folder with the following properties:
      | path | .axx/snap-mcp |
    And the inbox folder with the following properties:
      | path | .axx/snap-mcp/inbox |
    And the data folder is emptied

  Scenario: New captures are announced newest first
    Given the snap-20990101-100000-201.png file in the inbox folder is a copy of the acceptance/fixtures/capture.png file
    And the snap-20990101-100000-201.json file in the inbox folder has the content:
      """json
      {"image_filename": "snap-20990101-100000-201.png", "annotations": [{"type": "text", "content": "First unread issue"}]}
      """
    And the snap-20990102-100000-201.png file in the inbox folder is a copy of the acceptance/fixtures/capture.png file
    And the snap-20990102-100000-201.json file in the inbox folder has the content:
      """json
      {"image_filename": "snap-20990102-100000-201.png", "annotations": [{"type": "text", "content": "Second unread issue"}]}
      """
    When the check_new_annotations tool is called on the snap mcp server
    Then the check_new_annotations tool's result has the following properties:
      | new_count          | 2                        |
      | total_in_inbox     | 2                        |
      | has_new            | true                     |
      | new_annotations[0] | snap-20990102-100000-201 |
      | new_annotations[1] | snap-20990101-100000-201 |

  Scenario: Checking for annotations does not mark them read
    Given the snap-20990101-100000-202.png file in the inbox folder is a copy of the acceptance/fixtures/capture.png file
    And the snap-20990101-100000-202.json file in the inbox folder has the content:
      """json
      {"image_filename": "snap-20990101-100000-202.png", "annotations": [{"type": "text", "content": "Pending feedback"}]}
      """
    And the check_new_annotations tool is called on the snap mcp server
    When the check_new_annotations tool is called on the snap mcp server
    Then the check_new_annotations tool's result has the following properties:
      | new_count          | 1                        |
      | has_new            | true                     |
      | new_annotations[0] | snap-20990101-100000-202 |
    And the data folder has no file named .last_read

  Scenario: Reading the latest capture marks existing feedback read without deleting it
    Given the snap-20990101-100000-203.png file in the inbox folder is a copy of the acceptance/fixtures/capture.png file
    And the snap-20990101-100000-203.json file in the inbox folder has the content:
      """json
      {"image_filename": "snap-20990101-100000-203.png", "annotations": [{"type": "text", "content": "Read this feedback"}]}
      """
    And the get_latest_annotation tool is called on the snap mcp server
    When the check_new_annotations tool is called on the snap mcp server
    Then the check_new_annotations tool's result has the following properties:
      | new_count      | 0     |
      | has_new        | false |
      | total_in_inbox | 1     |
    And the inbox folder has a file named snap-20990101-100000-203.json
    And the inbox folder has a file named snap-20990101-100000-203.png

  Scenario: Listing captures marks the inbox read
    Given the snap-20990101-100000-204.png file in the inbox folder is a copy of the acceptance/fixtures/capture.png file
    And the snap-20990101-100000-204.json file in the inbox folder has the content:
      """json
      {"image_filename": "snap-20990101-100000-204.png", "annotations": [{"type": "text", "content": "List this feedback"}]}
      """
    And the list_annotations tool is called on the snap mcp server
    When the check_new_annotations tool is called on the snap mcp server
    Then the check_new_annotations tool's result has the following properties:
      | new_count      | 0     |
      | has_new        | false |
      | total_in_inbox | 1     |

  Scenario: Opening a named capture does not consume the unread queue
    Given the snap-20990101-100000-205.png file in the inbox folder is a copy of the acceptance/fixtures/capture.png file
    And the snap-20990101-100000-205.json file in the inbox folder has the content:
      """json
      {"image_filename": "snap-20990101-100000-205.png", "annotations": [{"type": "text", "content": "Keep pending"}]}
      """
    And the get_annotation tool is called on the snap mcp server with the following arguments:
      | filename | snap-20990101-100000-205 |
    When the check_new_annotations tool is called on the snap mcp server
    Then the check_new_annotations tool's result has the following properties:
      | new_count          | 1                        |
      | has_new            | true                     |
      | new_annotations[0] | snap-20990101-100000-205 |
    And the data folder has no file named .last_read

  Scenario: A corrupt read marker recovers by treating existing captures as unread
    Given the snap-20990101-100000-206.png file in the inbox folder is a copy of the acceptance/fixtures/capture.png file
    And the snap-20990101-100000-206.json file in the inbox folder has the content:
      """json
      {"image_filename": "snap-20990101-100000-206.png", "annotations": [{"type": "text", "content": "Recover this feedback"}]}
      """
    And the .last_read file in the data folder has the content:
      """
      not-a-timestamp
      """
    When the check_new_annotations tool is called on the snap mcp server
    Then the check_new_annotations tool's result is not an error
    And the check_new_annotations tool's result has the following properties:
      | new_count          | 1                        |
      | total_in_inbox     | 1                        |
      | has_new            | true                     |
      | new_annotations[0] | snap-20990101-100000-206 |
