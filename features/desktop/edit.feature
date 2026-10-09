@desktop
Feature: Change the marks before saving
  Before saving, a person takes back the last mark or all of them, dims the screen to see the
  marks better, and keeps only a part of what they chose. What they save is what they see,
  without the dimming.

  On the screen is Adjective's home page, 1280 by 800 points, in the middle of the screen, which
  the person drags over just inside its edges. Snap shows it in the middle of the screen too: its
  top left is 640, 400 up and left of the middle of Snap's screenshot.

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
    And the inbox folder with the following properties:
      | owner | app:snap      |
      | path  | ~/.snap/inbox |
    And the backdrop app is launched
    And the snap app is launched
    And the Control+Shift+S key is pressed in the ${sys:hotkey.app} app
    And the pointer is dragged from -639, -399 to 638, 398 from the middle of the "${sys:screen.image}" image in the ${sys:screen.app} app

  Scenario: Undo takes back the last mark
    Given the "Rectangle (R)" button is clicked in the snap app
    And the "Blue" button is clicked in the snap app
    And the pointer is dragged from -608, -220 to -160, 50 from the middle of the "Screenshot" image in the snap app
    And the "Arrow (A)" button is clicked in the snap app
    And the pointer is dragged from 340, -250 to 490, -338 from the middle of the "Screenshot" image in the snap app
    When the "Undo (Ctrl+Z)" button is clicked in the snap app
    And the "Save (Enter)" button is clicked in the snap app
    Then within 5s the "snap-*.json" file in the inbox folder has the following properties:
      | annotations[0].type | rect      |
      | annotations[1]      | undefined |
    And the "snap-*.png" file in the inbox folder looks like the "headline-framed" screenshot

  Scenario: The undo key takes back the last mark
    Given the "Rectangle (R)" button is clicked in the snap app
    And the "Blue" button is clicked in the snap app
    And the pointer is dragged from -608, -220 to -160, 50 from the middle of the "Screenshot" image in the snap app
    And the "Arrow (A)" button is clicked in the snap app
    And the pointer is dragged from 340, -250 to 490, -338 from the middle of the "Screenshot" image in the snap app
    When the ControlOrMeta+Z key is pressed in the snap app
    And the Enter key is pressed in the snap app
    Then within 5s the "snap-*.json" file in the inbox folder has the following properties:
      | annotations[0].type | rect      |
      | annotations[1]      | undefined |

  Scenario: A marker taken back gives its number to the next
    Given the "Marker (N)" button is clicked in the snap app
    And the "Black" button is clicked in the snap app
    And the "Screenshot" image in the snap app is clicked at -110, -334 from its middle
    And the "Screenshot" image in the snap app is clicked at 63, -334 from its middle
    When the "Undo (Ctrl+Z)" button is clicked in the snap app
    And the "Screenshot" image in the snap app is clicked at -19, -334 from its middle
    And the "Screenshot" image in the snap app is clicked at 63, -334 from its middle
    And the "Save (Enter)" button is clicked in the snap app
    Then within 5s the "snap-*.json" file in the inbox folder has the following properties:
      | annotations[1].number | 2         |
      | annotations[2].number | 3         |
      | annotations[3]        | undefined |
    And the "snap-*.png" file in the inbox folder looks like the "menu-numbered" screenshot

  Scenario: Clear takes back every mark
    Given the "Marker (N)" button is clicked in the snap app
    And the "Screenshot" image in the snap app is clicked at -110, -334 from its middle
    And the "Screenshot" image in the snap app is clicked at -19, -334 from its middle
    When the "Clear" button is clicked in the snap app
    And the "Save (Enter)" button is clicked in the snap app
    Then within 5s the "snap-*.json" file in the inbox folder has the following properties:
      | annotations[0] | undefined |
    And the "snap-*.png" file in the inbox folder looks like the "home-page" screenshot

  Scenario: The dimming is only on the screen
    Given the "Dim layer (D)" button is clicked in the snap app
    And the "Rectangle (R)" button is clicked in the snap app
    And the "Blue" button is clicked in the snap app
    When the pointer is dragged from -608, -220 to -160, 50 from the middle of the "Screenshot" image in the snap app
    And the "Save (Enter)" button is clicked in the snap app
    Then within 5s the "snap-*.png" file in the inbox folder looks like the "headline-framed" screenshot

  Scenario: The region tool keeps only a part
    Given the "Select region (S) — drag to choose what to export, click for the whole screen" button is clicked in the snap app
    When the pointer is dragged from -620, -240 to -140, 70 from the middle of the "Screenshot" image in the snap app
    And the "Circle (C)" button is clicked in the snap app
    And the pointer is dragged from -604, -128 to -316, -40 from the middle of the "Screenshot" image in the snap app
    And the "Save (Enter)" button is clicked in the snap app
    Then within 5s the "snap-*.json" file in the inbox folder has the following properties:
      | annotations[0].type | circle |
    And the "snap-*.png" file in the inbox folder looks like the "headline-alone" screenshot

  Scenario: A click with the region tool keeps all of it again
    Given the "Select region (S) — drag to choose what to export, click for the whole screen" button is clicked in the snap app
    And the pointer is dragged from -620, -240 to -140, 70 from the middle of the "Screenshot" image in the snap app
    And the "Select region (S) — drag to choose what to export, click for the whole screen" button is clicked in the snap app
    When the "Screenshot" image in the snap app is clicked at 0, 0 from its middle
    And the "Save (Enter)" button is clicked in the snap app
    Then within 5s the "snap-*.json" file in the inbox folder has the following properties:
      | source.crop | null |

  Scenario: Escape while typing a label drops it
    Given the "Text (T)" button is clicked in the snap app
    And the "Screenshot" image in the snap app is clicked at -592, 178 from its middle
    And the "Type label..." field in the snap app is filled with "Not this one"
    When the Escape key is pressed in the snap app
    And the "Save (Enter)" button is clicked in the snap app
    Then within 5s the "snap-*.json" file in the inbox folder has the following properties:
      | annotations[0] | undefined |
