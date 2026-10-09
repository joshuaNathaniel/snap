@desktop @hotkey-again
Feature: Put a picture away without saving
  A person who changes their mind closes Snap with Escape or its close button. Nothing is
  saved, and the hotkey opens Snap again for the next picture.

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
    And the "Marker (N)" button is clicked in the snap app
    And the "Screenshot" image in the snap app is clicked at 63, -334 from its middle

  Scenario: Escape puts the picture away unsaved
    When the Escape key is pressed in the snap app
    And the Control+Shift+S key is pressed in the ${sys:hotkey.app} app
    And the pointer is dragged from -639, -399 to 638, 398 from the middle of the "${sys:screen.image}" image in the ${sys:screen.app} app
    And the "Marker (N)" button is clicked in the snap app
    And the "Screenshot" image in the snap app is clicked at -110, -334 from its middle
    And the "Save (Enter)" button is clicked in the snap app
    Then within 5s the "snap-*.json" file in the inbox folder has the following properties:
      | annotations[0].number | 1         |
      | annotations[1]        | undefined |

  Scenario: The close button puts the picture away unsaved
    When the "Close (Esc)" button is clicked in the snap app
    And the Control+Shift+S key is pressed in the ${sys:hotkey.app} app
    And the pointer is dragged from -639, -399 to 638, 398 from the middle of the "${sys:screen.image}" image in the ${sys:screen.app} app
    And the "Marker (N)" button is clicked in the snap app
    And the "Screenshot" image in the snap app is clicked at -110, -334 from its middle
    And the "Save (Enter)" button is clicked in the snap app
    Then within 5s the "snap-*.json" file in the inbox folder has the following properties:
      | annotations[0].number | 1         |
      | annotations[1]        | undefined |
