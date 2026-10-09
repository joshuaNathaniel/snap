@desktop @tray-menu
Feature: Snap waits in the tray
  Snap runs in the background with an icon of its own in the tray (the menu bar on macOS),
  waiting for its hotkey. The icon's menu opens Snap's folder, where its log is, in the file
  manager the system has (Finder, File Explorer, GNOME Files), and quits it.

  Background:
    Given the snap macos app with the following properties:
      | app | app/src-tauri/target/release/bundle/macos/snap.app |
    And the snap windows app with the following properties:
      | app               | app/src-tauri/target/release/snap.exe |
      | env.SNAP_DATA_DIR | .axx/desktop/windows/snap/.snap       |
    And the snap linux app with the following properties:
      | app | app/src-tauri/target/release/snap |
    And the data folder with the following properties:
      | owner | app:snap |
      | path  | ~/.snap  |
    And the snap app is launched

  Scenario: Snap quits from its icon's menu
    When the "${sys:tray.icon}" menu is clicked in the snap app
    And the "Quit Snap" menu item is clicked in the snap app
    Then within 5s the "snap.log" file in the data folder contains "quit from tray"

  Scenario: Snap's folder opens from its icon's menu
    Given the files macos app with the following properties:
      | app   | com.apple.finder |
      | owner | system           |
    And the files windows app with the following properties:
      | app   | explorer.exe |
      | owner | system       |
    And the files linux app with the following properties:
      | app   | nautilus |
      | owner | system   |
    When the "${sys:tray.icon}" menu is clicked in the snap app
    And the "Open Logs" menu item is clicked in the snap app
    Then within 10s the files app shows ".snap"
