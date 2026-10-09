@desktop
Feature: Pick a tool with a key
  A person who marks a lot keeps a hand on the keyboard: each tool has a key, and D dims the
  screen. What a key picks is what its button picks.

  On the screen is Adjective's home page, as in the other features, chosen just inside its edges.

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
    And the inbox folder with the following properties:
      | owner | app:snap      |
      | path  | ~/.snap/inbox |
    And the backdrop app is launched
    And the snap app is launched
    And the Control+Shift+S key is pressed in the ${sys:hotkey.app} app
    And the pointer is dragged from -639, -399 to 638, 398 from the middle of the "${sys:screen.image}" image in the ${sys:screen.app} app

  Scenario Outline: The <key> key picks the <tool>
    Given the <key> key is pressed in the snap app
    When the pointer is dragged from -608, -220 to -160, 50 from the middle of the "Screenshot" image in the snap app
    And the Enter key is pressed in the snap app
    Then within 5s the "snap-*.json" file in the inbox folder has the following properties:
      | annotations[0].type | <type>    |
      | annotations[1]      | undefined |

    Examples:
      | key | tool      | type     |
      | C   | circle    | circle   |
      | R   | rectangle | rect     |
      | A   | arrow     | arrow    |
      | F   | stroke    | freehand |

  Scenario: The N key picks the marker
    Given the N key is pressed in the snap app
    When the "Screenshot" image in the snap app is clicked at -110, -334 from its middle
    And the Enter key is pressed in the snap app
    Then within 5s the "snap-*.json" file in the inbox folder has the following properties:
      | annotations[0].type   | marker |
      | annotations[0].number | 1      |

  Scenario: The T key picks the label
    Given the T key is pressed in the snap app
    And the "Screenshot" image in the snap app is clicked at -592, 178 from its middle
    When the "Type label..." field in the snap app is filled with "Say what we build"
    And the Enter key is pressed in the snap app
    And the "Save (Enter)" button is clicked in the snap app
    Then within 5s the "snap-*.json" file in the inbox folder has the following properties:
      | annotations[0].type    | text              |
      | annotations[0].content | Say what we build |

  Scenario: The S key picks the region tool
    Given the S key is pressed in the snap app
    When the pointer is dragged from -620, -240 to -140, 70 from the middle of the "Screenshot" image in the snap app
    And the C key is pressed in the snap app
    And the pointer is dragged from -604, -128 to -316, -40 from the middle of the "Screenshot" image in the snap app
    And the Enter key is pressed in the snap app
    Then within 5s the "snap-*.json" file in the inbox folder has the following properties:
      | annotations[0].type | circle |
    And the "snap-*.png" file in the inbox folder looks like the "headline-alone" screenshot

  Scenario: The D key dims the screen
    When the D key is pressed in the snap app
    Then within 5s the snap app looks like the "dimmed" screenshot
