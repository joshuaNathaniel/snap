@desktop
Feature: An agent reads what the person marked
  Snap's MCP server gives an agent the pictures a person saved: it hears of new ones, reads
  their marks, and clears the inbox once it has acted on them. The server runs as assistants
  run it, over stdio, on the app's data folder.

  On the screen is Adjective's home page, in the middle of the screen, which the person drags
  over just inside its edges. Snap shows it in the middle of the screen too, where the marks are
  placed from.

  Where the part is chosen differs by OS, so two steps name their app by a property: macOS asks
  at its crosshair, over the backdrop, before Snap shows; on Windows and Linux Snap shows the
  whole screen at once, and the part is chosen in Snap's screenshot; on Wayland Snap opens as it
  starts and takes no hotkey of its own.

  Background:
    Given the backdrop macos app with the following properties:
      | app  | com.apple.Preview                |
      | args | acceptance/fixtures/backdrop.png |
    And the backdrop windows app with the following properties:
      | app  | ${sys:edge}                                                                                                                                                            |
      | args | --kiosk acceptance/fixtures/backdrop.html --edge-kiosk-type=fullscreen --no-first-run --disable-component-update --disable-background-networking --user-data-dir=.axx/desktop/windows/backdrop      |
    And the backdrop linux app with the following properties:
      | app  | eog                                           |
      | args | --fullscreen acceptance/fixtures/backdrop.png |
    And the snap macos app with the following properties:
      | app | app/src-tauri/target/release/bundle/macos/snap.app |
    And the snap windows app with the following properties:
      | app               | app/src-tauri/target/release/snap.exe |
      | env.SNAP_DATA_DIR | .axx/desktop/windows/snap/.snap       |
    And the snap linux app with the following properties:
      | app | app/src-tauri/target/release/snap |
    And the backdrop app is launched
    And the inbox folder with the following properties:
      | owner | app:snap      |
      | path  | ~/.snap/inbox |
    And the snap app is launched
    And the snap mcp server with the following properties:
      | command           | "${sys:python}" mcp-server/server.py |
      | dir               | .                                    |
      | env.SNAP_DATA_DIR | ${sys:snap.data}                     |
    And the Control+Shift+S key is pressed in the ${sys:hotkey.app} app
    And the pointer is dragged from -639, -399 to 638, 398 from the middle of the "${sys:screen.image}" image in the ${sys:screen.app} app

  Scenario: The agent hears of a new picture
    Given the "Marker (N)" button is clicked in the snap app
    And the "Screenshot" image in the snap app is clicked at -110, -334 from its middle
    When the "Save (Enter)" button is clicked in the snap app
    And the inbox folder has a file named snap-*.json
    And the check_new_annotations tool is called on the snap mcp server
    Then the check_new_annotations tool's result has the following properties:
      | new_count      | 1    |
      | has_new        | true |
      | total_in_inbox | 1    |

  Scenario: The agent reads the marks, and they are no longer new
    Given the "Rectangle (R)" button is clicked in the snap app
    And the "Blue" button is clicked in the snap app
    And the pointer is dragged from -608, -220 to -160, 50 from the middle of the "Screenshot" image in the snap app
    And the "Text (T)" button is clicked in the snap app
    And the "Screenshot" image in the snap app is clicked at -592, 178 from its middle
    And the "Type label..." field in the snap app is filled with "Say what we prove"
    And the Enter key is pressed in the snap app
    When the "Save (Enter)" button is clicked in the snap app
    And the inbox folder has a file named snap-*.json
    And the get_latest_annotation tool is called on the snap mcp server
    Then the get_latest_annotation tool's result has the following properties:
      | coordinate_space       | image_pixels      |
      | annotations[0].type    | rect              |
      | annotations[0].color   | #007AFF           |
      | annotations[1].type    | text              |
      | annotations[1].content | Say what we prove |
    And the check_new_annotations tool is called on the snap mcp server
    And the check_new_annotations tool's result has the following properties:
      | new_count | 0     |
      | has_new   | false |

  @hotkey-again
  Scenario: Snap opens again for the next picture
    Given the "Marker (N)" button is clicked in the snap app
    And the "Screenshot" image in the snap app is clicked at -110, -334 from its middle
    And the "Save (Enter)" button is clicked in the snap app
    And the inbox folder has a file named snap-*.json
    And the clear_inbox tool is called on the snap mcp server
    When the Control+Shift+S key is pressed in the ${sys:hotkey.app} app
    And the pointer is dragged from -639, -399 to 638, 398 from the middle of the "${sys:screen.image}" image in the ${sys:screen.app} app
    And the "Arrow (A)" button is clicked in the snap app
    And the pointer is dragged from 340, -250 to 490, -338 from the middle of the "Screenshot" image in the snap app
    And the "Save (Enter)" button is clicked in the snap app
    And the inbox folder has a file named snap-*.json
    And the get_latest_annotation tool is called on the snap mcp server
    Then the get_latest_annotation tool's result has the following properties:
      | annotations[0].type | arrow     |
      | annotations[1]      | undefined |

  Scenario: The agent clears the inbox once it has acted
    Given the "Marker (N)" button is clicked in the snap app
    And the "Screenshot" image in the snap app is clicked at -110, -334 from its middle
    And the "Save (Enter)" button is clicked in the snap app
    And the inbox folder has a file named snap-*.json
    When the clear_inbox tool is called on the snap mcp server
    Then the clear_inbox tool's result has the following properties:
      | deleted_json | 1 |
      | deleted_png  | 1 |
    And the check_new_annotations tool is called on the snap mcp server
    And the check_new_annotations tool's result has the following properties:
      | total_in_inbox | 0 |
