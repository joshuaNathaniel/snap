@desktop
Feature: Move the toolbar out of the way
  The toolbar sits at the top of the screen, over what may need marking. A person drags it by its
  handle into a corner, out of the way, and it stays there: Snap keeps it on the screen, so a drag
  past the corner leaves it in the corner.

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

  Scenario: The toolbar is dragged into a corner by its handle
    When the pointer is dragged from 0, 0 to -1600, -100 from the middle of the "Drag to move" element in the snap app
    Then within 5s the snap app looks like the "toolbar-cornered" screenshot
