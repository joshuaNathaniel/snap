@mcp @read
Feature: Read saved annotation metadata
  An agent receives the user's instructions and coordinates in saved-image pixels.
  Ordering follows capture filenames, even when files arrive in a different order.

  Background:
    Given the snap mcp server with the following properties:
      | url | http://127.0.0.1:${sys:snap.port}/mcp |
    And the data folder with the following properties:
      | path | .axx/snap-mcp |
    And the inbox folder with the following properties:
      | path | .axx/snap-mcp/inbox |
    And the data folder is emptied

  Scenario: The latest capture preserves instructions and image coordinates
    Given the snap-20990102-100000-101.png file in the inbox folder is a copy of the acceptance/fixtures/capture.png file
    And the snap-20990102-100000-101.json file in the inbox folder has the content:
      """json
      {
        "timestamp": "2099-01-02T10:00:00Z",
        "source": {
          "window_title": "Snap acceptance fixture",
          "session_type": "x11",
          "capture_size": [320, 180],
          "crop": null
        },
        "image_filename": "snap-20990102-100000-101.png",
        "image_size": [320, 180],
        "coordinate_space": "image_pixels",
        "annotations": [
          {
            "type": "text",
            "position": [40, 60],
            "content": "Align the checkout button",
            "font_size": 16,
            "color": "#FF3B30"
          }
        ]
      }
      """
    And the snap-20990101-100000-101.png file in the inbox folder is a copy of the acceptance/fixtures/capture.png file
    And the snap-20990101-100000-101.json file in the inbox folder has the content:
      """json
      {"image_filename": "snap-20990101-100000-101.png", "annotations": [{"type": "text", "content": "An older instruction"}]}
      """
    When the get_latest_annotation tool is called on the snap mcp server
    Then the get_latest_annotation tool's result is not an error
    And the get_latest_annotation tool's result has the following properties:
      | filename                   | snap-20990102-100000-101     |
      | image_filename             | snap-20990102-100000-101.png |
      | image_size[0]              | 320                          |
      | image_size[1]              | 180                          |
      | coordinate_space           | image_pixels                 |
      | source.capture_size[0]     | 320                          |
      | source.capture_size[1]     | 180                          |
      | source.crop                | null                         |
      | source.window_title        | Snap acceptance fixture      |
      | annotations[0].type        | text                         |
      | annotations[0].content     | Align the checkout button    |
      | annotations[0].position[0] | 40                           |
      | annotations[0].position[1] | 60                           |
      | annotations[0].font_size   | 16                           |
      | annotations[0].color       | #FF3B30                      |
      | image_warning              | undefined                    |
      | image_base64               | undefined                    |
    And the snap-20990102-100000-101.png file in the inbox folder is identical to the acceptance/fixtures/capture.png file

  Scenario: Recent annotations are returned newest first up to the requested limit
    Given the snap-20990103-100000-102.png file in the inbox folder is a copy of the acceptance/fixtures/capture.png file
    And the snap-20990103-100000-102.json file in the inbox folder has the content:
      """json
      {"image_filename": "snap-20990103-100000-102.png", "annotations": [{"type": "text", "content": "Third capture"}]}
      """
    And the snap-20990101-100000-102.png file in the inbox folder is a copy of the acceptance/fixtures/capture.png file
    And the snap-20990101-100000-102.json file in the inbox folder has the content:
      """json
      {"image_filename": "snap-20990101-100000-102.png", "annotations": [{"type": "text", "content": "First capture"}]}
      """
    And the snap-20990102-100000-102.png file in the inbox folder is a copy of the acceptance/fixtures/capture.png file
    And the snap-20990102-100000-102.json file in the inbox folder has the content:
      """json
      {"image_filename": "snap-20990102-100000-102.png", "annotations": [{"type": "text", "content": "Second capture"}]}
      """
    When the list_annotations tool is called on the snap mcp server with the following arguments:
      | last_n | 2 |
    Then the list_annotations tool's result is not an error
    And the list_annotations tool's result has the following properties:
      | count                                 | 2                        |
      | annotations[0].filename               | snap-20990103-100000-102 |
      | annotations[0].annotations[0].content | Third capture            |
      | annotations[1].filename               | snap-20990102-100000-102 |
      | annotations[1].annotations[0].content | Second capture           |
      | annotations[2]                        | undefined                |

  Scenario: The default listing returns only the five most recent captures
    Given the snap-20990101-100000-103.png file in the inbox folder is a copy of the acceptance/fixtures/capture.png file
    And the snap-20990101-100000-103.json file in the inbox folder has the content:
      """json
      {"image_filename": "snap-20990101-100000-103.png", "annotations": [{"type": "text", "content": "One"}]}
      """
    And the snap-20990102-100000-103.png file in the inbox folder is a copy of the acceptance/fixtures/capture.png file
    And the snap-20990102-100000-103.json file in the inbox folder has the content:
      """json
      {"image_filename": "snap-20990102-100000-103.png", "annotations": [{"type": "text", "content": "Two"}]}
      """
    And the snap-20990103-100000-103.png file in the inbox folder is a copy of the acceptance/fixtures/capture.png file
    And the snap-20990103-100000-103.json file in the inbox folder has the content:
      """json
      {"image_filename": "snap-20990103-100000-103.png", "annotations": [{"type": "text", "content": "Three"}]}
      """
    And the snap-20990104-100000-103.png file in the inbox folder is a copy of the acceptance/fixtures/capture.png file
    And the snap-20990104-100000-103.json file in the inbox folder has the content:
      """json
      {"image_filename": "snap-20990104-100000-103.png", "annotations": [{"type": "text", "content": "Four"}]}
      """
    And the snap-20990105-100000-103.png file in the inbox folder is a copy of the acceptance/fixtures/capture.png file
    And the snap-20990105-100000-103.json file in the inbox folder has the content:
      """json
      {"image_filename": "snap-20990105-100000-103.png", "annotations": [{"type": "text", "content": "Five"}]}
      """
    And the snap-20990106-100000-103.png file in the inbox folder is a copy of the acceptance/fixtures/capture.png file
    And the snap-20990106-100000-103.json file in the inbox folder has the content:
      """json
      {"image_filename": "snap-20990106-100000-103.png", "annotations": [{"type": "text", "content": "Six"}]}
      """
    When the list_annotations tool is called on the snap mcp server
    Then the list_annotations tool's result has the following properties:
      | count                   | 5                        |
      | annotations[0].filename | snap-20990106-100000-103 |
      | annotations[4].filename | snap-20990102-100000-103 |
      | annotations[5]          | undefined                |

  Scenario: An agent can retrieve an older annotation by its exact filename
    Given the snap-20990101-100000-104.png file in the inbox folder is a copy of the acceptance/fixtures/capture.png file
    And the snap-20990101-100000-104.json file in the inbox folder has the content:
      """json
      {"image_filename": "snap-20990101-100000-104.png", "coordinate_space": "image_pixels", "annotations": [{"type": "text", "content": "Fix the original layout"}]}
      """
    And the snap-20990102-100000-104.png file in the inbox folder is a copy of the acceptance/fixtures/capture.png file
    And the snap-20990102-100000-104.json file in the inbox folder has the content:
      """json
      {"image_filename": "snap-20990102-100000-104.png", "annotations": [{"type": "text", "content": "A different issue"}]}
      """
    When the get_annotation tool is called on the snap mcp server with the following arguments:
      | filename | snap-20990101-100000-104 |
    Then the get_annotation tool's result is not an error
    And the get_annotation tool's result has the following properties:
      | filename               | snap-20990101-100000-104 |
      | annotations[0].content | Fix the original layout  |
      | coordinate_space       | image_pixels             |

  Scenario: A missing screenshot still leaves usable instructions and a warning
    Given the snap-20990101-100000-105.json file in the inbox folder has the content:
      """json
      {"image_filename": "snap-20990101-100000-105.png", "annotations": [{"type": "text", "content": "Repair the navigation"}]}
      """
    When the get_latest_annotation tool is called on the snap mcp server
    Then the get_latest_annotation tool's result is not an error
    And the get_latest_annotation tool's result has the following properties:
      | filename               | snap-20990101-100000-105 |
      | annotations[0].content | Repair the navigation    |
      | image_path             | null                     |
      | warning                | image file missing       |

  Scenario: Unreadable metadata is reported without crashing the server
    Given the snap-20990101-100000-106.png file in the inbox folder is a copy of the acceptance/fixtures/capture.png file
    And the snap-20990101-100000-106.json file in the inbox folder has the content:
      """
      {broken JSON
      """
    When the get_latest_annotation tool is called on the snap mcp server
    Then the get_latest_annotation tool's result is not an error
    And the get_latest_annotation tool's result contains 'corrupt or unreadable'
    And the get_latest_annotation tool's result has the following properties:
      | filename   | snap-20990101-100000-106 |
      | image_path | null                     |

  Scenario: An image above the requested size limit explains how to access it
    Given the snap-20990101-100000-107.png file in the inbox folder is a copy of the acceptance/fixtures/capture.png file
    And the snap-20990101-100000-107.json file in the inbox folder has the content:
      """json
      {"image_filename": "snap-20990101-100000-107.png", "annotations": [{"type": "text", "content": "Keep the instructions"}]}
      """
    When the get_latest_annotation tool is called on the snap mcp server with the following arguments:
      | max_image_bytes | 1 |
    Then the get_latest_annotation tool's result is not an error
    And the get_latest_annotation tool's result contains 'exceeds max_image_bytes=1'
    And the get_latest_annotation tool's result contains 'read it from image_path instead'
    And the get_latest_annotation tool's result has the following properties:
      | filename               | snap-20990101-100000-107 |
      | annotations[0].content | Keep the instructions    |

  Scenario: Metadata-only reads do not attempt to attach an oversized image
    Given the snap-20990101-100000-108.png file in the inbox folder is a copy of the acceptance/fixtures/capture.png file
    And the snap-20990101-100000-108.json file in the inbox folder has the content:
      """json
      {"image_filename": "snap-20990101-100000-108.png", "annotations": [{"type": "text", "content": "Read without vision"}]}
      """
    When the get_latest_annotation tool is called on the snap mcp server with the following arguments:
      | include_image   | false |
      | max_image_bytes | 1     |
    Then the get_latest_annotation tool's result is not an error
    And the get_latest_annotation tool's result has the following properties:
      | filename               | snap-20990101-100000-108 |
      | annotations[0].content | Read without vision      |
      | image_warning          | undefined                |

  Scenario: One damaged sidecar does not hide other captures in the listing
    Given the snap-20990101-100000-109.png file in the inbox folder is a copy of the acceptance/fixtures/capture.png file
    And the snap-20990101-100000-109.json file in the inbox folder has the content:
      """json
      {"image_filename": "snap-20990101-100000-109.png", "annotations": [{"type": "text", "content": "Still actionable"}]}
      """
    And the snap-20990102-100000-109.png file in the inbox folder is a copy of the acceptance/fixtures/capture.png file
    And the snap-20990102-100000-109.json file in the inbox folder has the content:
      """
      {broken JSON
      """
    When the list_annotations tool is called on the snap mcp server
    Then the list_annotations tool's result is not an error
    And the list_annotations tool's result contains 'corrupt or unreadable'
    And the list_annotations tool's result has the following properties:
      | count                                 | 2                        |
      | annotations[0].filename               | snap-20990102-100000-109 |
      | annotations[0].image_path             | null                     |
      | annotations[1].filename               | snap-20990101-100000-109 |
      | annotations[1].annotations[0].content | Still actionable         |
