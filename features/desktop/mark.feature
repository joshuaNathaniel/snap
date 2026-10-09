@desktop
Feature: Mark what matters on the screen
  A person presses Snap's hotkey, drags over the part of the screen they mean, marks what
  matters on it, and saves. Snap keeps the picture with the marks drawn on it, and a sidecar
  that lists each mark in the picture's pixels, for an agent to read.

  On the screen is a known picture, Adjective's home page, 1280 by 800 points, in the middle of
  the screen. The person drags over it, just inside its edges, and Snap shows it in the middle of
  the screen too, so the marks are placed from the middle of Snap's screenshot: the picture's top
  left is 640, 400 up and left of it.

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

  Scenario: A blue rectangle frames the headline
    When the "Rectangle (R)" button is clicked in the snap app
    And the "Blue" button is clicked in the snap app
    And the pointer is dragged from -608, -220 to -160, 50 from the middle of the "Screenshot" image in the snap app
    And the "Save (Enter)" button is clicked in the snap app
    Then within 5s the "snap-*.json" file in the inbox folder has the following properties:
      | coordinate_space     | image_pixels |
      | annotations[0].type  | rect         |
      | annotations[0].color | #007AFF      |
      | annotations[1]       | undefined    |
    And the "snap-*.png" file in the inbox folder looks like the "headline-framed" screenshot

  Scenario: A thick green circle rings the briefing button
    When the "Circle (C)" button is clicked in the snap app
    And the "Green" button is clicked in the snap app
    And the "Thick" button is clicked in the snap app
    And the pointer is dragged from -604, 196 to -308, 276 from the middle of the "Screenshot" image in the snap app
    And the "Save (Enter)" button is clicked in the snap app
    Then within 5s the "snap-*.json" file in the inbox folder has the following properties:
      | annotations[0].type  | circle  |
      | annotations[0].color | #34C759 |
    And the "snap-*.png" file in the inbox folder looks like the "briefing-ringed" screenshot

  Scenario: A thin red arrow points at Contact
    When the "Arrow (A)" button is clicked in the snap app
    And the "Thin" button is clicked in the snap app
    And the pointer is dragged from 340, -250 to 490, -338 from the middle of the "Screenshot" image in the snap app
    And the "Save (Enter)" button is clicked in the snap app
    Then within 5s the "snap-*.json" file in the inbox folder has the following properties:
      | annotations[0].type  | arrow   |
      | annotations[0].color | #FF3B30 |
    And the "snap-*.png" file in the inbox folder looks like the "contact-pointed" screenshot

  Scenario: A thick yellow stroke underlines a word
    When the "Freehand (F)" button is clicked in the snap app
    And the "Yellow" button is clicked in the snap app
    And the "Thick" button is clicked in the snap app
    And the pointer is dragged from -588, -38 to -334, -38 from the middle of the "Screenshot" image in the snap app
    And the "Save (Enter)" button is clicked in the snap app
    Then within 5s the "snap-*.json" file in the inbox folder has the following properties:
      | annotations[0].type  | freehand |
      | annotations[0].color | #FFCC00  |
    And the "snap-*.png" file in the inbox folder looks like the "agentic-underlined" screenshot

  Scenario: A white label says what to change under the paragraph
    When the "Text (T)" button is clicked in the snap app
    And the "White" button is clicked in the snap app
    And the "Screenshot" image in the snap app is clicked at -592, 178 from its middle
    And the "Type label..." field in the snap app is filled with "Make this easier to read"
    And the Enter key is pressed in the snap app
    And the "Save (Enter)" button is clicked in the snap app
    Then within 5s the "snap-*.json" file in the inbox folder has the following properties:
      | annotations[0].type    | text                     |
      | annotations[0].content | Make this easier to read |
      | annotations[0].color   | #FFFFFF                  |
    And the "snap-*.png" file in the inbox folder looks like the "paragraph-labelled" screenshot

  Scenario: Black markers number the menu in order
    When the "Marker (N)" button is clicked in the snap app
    And the "Black" button is clicked in the snap app
    And the "Screenshot" image in the snap app is clicked at -110, -334 from its middle
    And the "Screenshot" image in the snap app is clicked at -19, -334 from its middle
    And the "Screenshot" image in the snap app is clicked at 63, -334 from its middle
    And the "Save (Enter)" button is clicked in the snap app
    Then within 5s the "snap-*.json" file in the inbox folder has the following properties:
      | annotations[0].type   | marker  |
      | annotations[0].number | 1       |
      | annotations[0].color  | #000000 |
      | annotations[1].number | 2       |
      | annotations[2].number | 3       |
    And the "snap-*.png" file in the inbox folder looks like the "menu-numbered" screenshot

  Scenario: The picture keeps the window it was taken from
    When the "Marker (N)" button is clicked in the snap app
    And the "Screenshot" image in the snap app is clicked at 328, 25 from its middle
    And the "Save (Enter)" button is clicked in the snap app
    Then within 5s the "snap-*.json" file in the inbox folder has the following properties:
      | source.window_title | ${sys:picture.title} |
      | source.window_class | ${sys:picture.class} |
      | source.display      | primary              |
