@mcp @clear
Feature: Clear processed annotation pairs
  Clearing removes saved screenshots and their metadata, resets unread tracking,
  and preserves files that are not part of an annotation pair.

  Background:
    Given the snap mcp server with the following properties:
      | url | http://127.0.0.1:${sys:snap.port}/mcp |
    And the data folder with the following properties:
      | path | .axx/snap-mcp |
    And the inbox folder with the following properties:
      | path | .axx/snap-mcp/inbox |
    And the data folder is emptied

  Scenario: Clearing removes both files for every capture and resets the read marker
    Given the snap-20990101-100000-301.png file in the inbox folder is a copy of the acceptance/fixtures/capture.png file
    And the snap-20990101-100000-301.json file in the inbox folder has the content:
      """json
      {"image_filename": "snap-20990101-100000-301.png", "annotations": [{"type": "text", "content": "Processed first"}]}
      """
    And the snap-20990102-100000-301.png file in the inbox folder is a copy of the acceptance/fixtures/capture.png file
    And the snap-20990102-100000-301.json file in the inbox folder has the content:
      """json
      {"image_filename": "snap-20990102-100000-301.png", "annotations": [{"type": "text", "content": "Processed second"}]}
      """
    And the list_annotations tool is called on the snap mcp server
    When the clear_inbox tool is called on the snap mcp server
    Then the clear_inbox tool's result is not an error
    And the clear_inbox tool's result has the following properties:
      | deleted_json | 2         |
      | deleted_png  | 2         |
      | errors       | undefined |
    And the inbox folder is empty
    And the data folder has no file named .last_read

  Scenario: Clearing preserves unrelated files and PNGs without matching sidecars
    Given the snap-20990101-100000-302.png file in the inbox folder is a copy of the acceptance/fixtures/capture.png file
    And the snap-20990101-100000-302.json file in the inbox folder has the content:
      """json
      {"image_filename": "snap-20990101-100000-302.png", "annotations": [{"type": "text", "content": "Processed capture"}]}
      """
    And the notes.txt file in the inbox folder has the content:
      """
      Keep my notes
      """
    And the settings.json file in the inbox folder has the content:
      """
      {}
      """
    And the snap-orphan-302.png file in the inbox folder has the content:
      """
      No matching sidecar
      """
    When the clear_inbox tool is called on the snap mcp server
    Then the clear_inbox tool's result has the following properties:
      | deleted_json | 1 |
      | deleted_png  | 1 |
    And the inbox folder has no file named snap-20990101-100000-302.json
    And the inbox folder has no file named snap-20990101-100000-302.png
    And the inbox folder has a file named snap-orphan-302.png
    And the notes.txt file in the inbox folder contains 'Keep my notes'
    And the settings.json file in the inbox folder contains '{}'

  Scenario: A missing PNG does not prevent its sidecar from being cleared
    Given the snap-20990101-100000-303.json file in the inbox folder has the content:
      """json
      {"image_filename": "snap-20990101-100000-303.png", "annotations": [{"type": "text", "content": "Already missing image"}]}
      """
    When the clear_inbox tool is called on the snap mcp server
    Then the clear_inbox tool's result is not an error
    And the clear_inbox tool's result has the following properties:
      | deleted_json | 1         |
      | deleted_png  | 0         |
      | errors       | undefined |
    And the inbox folder is empty

  Scenario: Clearing an already cleared inbox succeeds without reporting extra deletions
    Given the snap-20990101-100000-304.png file in the inbox folder is a copy of the acceptance/fixtures/capture.png file
    And the snap-20990101-100000-304.json file in the inbox folder has the content:
      """json
      {"image_filename": "snap-20990101-100000-304.png", "annotations": [{"type": "text", "content": "Clear once"}]}
      """
    And the clear_inbox tool is called on the snap mcp server
    When the clear_inbox tool is called on the snap mcp server
    Then the clear_inbox tool's result is not an error
    And the clear_inbox tool's result has the following properties:
      | deleted_json | 0         |
      | deleted_png  | 0         |
      | errors       | undefined |
    And the inbox folder is empty
