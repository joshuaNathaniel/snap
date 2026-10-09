# Snap

**Visual annotation layer for agentic coding.**

Annotate your screen and feed marked-up screenshots directly into Claude Code (or any MCP-compatible AI agent). See a bug? Circle it, label it, hit enter. Your agent sees exactly what you see.

```
You see a bug  -->  Ctrl+Shift+S  -->  Circle it, type "fix this"  -->  Enter
                                                                          |
                                                            ~/.snap/inbox/
                                                         snap-20260409-040216.png
                                                         snap-20260409-040216.json
                                                                          |
                                              Claude Code reads it via MCP  -->  Fix applied
```

---

## How It Works

Snap is two components:

1. **Annotation overlay** (Tauri 2.x, Rust + vanilla JS) — a global-hotkey-triggered fullscreen overlay that captures your screen, lets you draw on it, and saves annotated screenshots + structured metadata to `~/.snap/inbox/`.

2. **MCP server** (Python, fastmcp) — exposes the inbox to AI agents via stdio transport. Claude Code calls `get_latest_annotation()` and sees your marked-up screenshot with structured annotation data.

### The Flow

1. Press `Ctrl+Shift+S` from anywhere
2. Your screen freezes into an annotation canvas
3. Optionally drag to select the region you care about; otherwise the whole screen is kept
4. Circle things, draw arrows, type labels, number issues
5. Hit Enter (or click the green checkmark)
6. Annotated PNG + structured JSON metadata drops into `~/.snap/inbox/`
7. In Claude Code: "check my latest snap annotation"
8. Claude Code reads the image and metadata, understands what you marked, makes the fix

### What Gets Saved

Every save produces a matched pair:

**`snap-{timestamp}.png`** — Your screen capture with all annotations composited directly into the image. What you drew is what the agent sees.

**`snap-{timestamp}.json`** — Structured metadata:
```json
{
  "timestamp": "2026-04-09T04:02:15.897Z",
  "source": {
    "window_title": "localhost:3000/dashboard - Brave",
    "window_class": "Brave-browser",
    "pid": 12345,
    "session_type": "x11",
    "display": "primary",
    "resolution": [3840, 2160],
    "capture_size": [3840, 2160],
    "crop": { "x": 1200, "y": 400, "w": 1600, "h": 900 }
  },
  "image_size": [1600, 900],
  "coordinate_space": "image_pixels",
  "annotations": [
    {
      "type": "circle",
      "center": [340, 220],
      "radius": [45, 45],
      "color": "#FF3B30",
      "label": null
    },
    {
      "type": "text",
      "position": [350, 310],
      "content": "fix this alignment",
      "font_size": 32,
      "color": "#FF3B30"
    }
  ],
  "image_filename": "snap-20260409-040215.png"
}
```

The inbox is `~/.snap/inbox/`, or `inbox/` in `SNAP_DATA_DIR` when that is set (the app and the MCP server both read it).

All annotation coordinates and sizes are in pixels of the saved PNG (`image_size`), so an agent can locate them directly in the image. `capture_size` is the raw screen capture and `crop` is the region of it that was selected (`null` when the whole screen was kept). `session_type` is `x11`, `wayland`, `macos`, or `windows`; on Wayland the window fields are always `null` because the compositor does not expose the focused window.

---

## Annotation Tools

| Tool | Shortcut | Description |
|------|----------|-------------|
| Select region | `S` | Drag to choose the region to export; everything outside is dimmed. Click without dragging to go back to the whole screen. Active when the overlay opens on Linux and Windows; on macOS the part is chosen at macOS's crosshair before the overlay opens. |
| Circle | `C` | Click-drag to draw ellipses. Shift constrains to circle. |
| Rectangle | `R` | Click-drag to draw boxes. Shift constrains to square. 10% fill for visibility. |
| Arrow | `A` | Click start, drag to end. Arrowhead on the endpoint. |
| Freehand | `F` | Click-drag to draw smoothed paths. Quadratic curve interpolation. |
| Text | `T` | Click to place a label. Type your instruction. Enter to confirm. |
| Numbered Marker | `N` | Click to place auto-incrementing circled numbers (1, 2, 3...). |

### Controls

| Key | Action |
|-----|--------|
| `Ctrl+Shift+S` | Open annotation overlay (global, works from any app) |
| `D` | Toggle dim layer (darkens background for contrast) |
| `Ctrl+Z` | Undo last annotation |
| `Enter` | Save annotated screenshot and close |
| `Escape` | Drop the label being typed, or abort the shape or region being dragged; otherwise discard and close |

### Toolbar

- **6 color swatches**: Red (default), Blue, Green, Yellow, White, Black
- **3 stroke widths**: Thin (2px), Medium (4px, default), Thick (6px)
- **Draggable**: Grab the handle on the left to reposition the toolbar
- **Dim toggle**: Adds a dark overlay behind annotations for readability on busy screens
- **Undo / Clear**: Remove the last annotation, or all of them
- **Save**: The green checkmark, same as `Enter`
- **Close**: The ✕ beside it, same as `Escape`: discard and close

---

## Quick Start

One command on Linux or macOS:

```bash
curl -fsSL https://raw.githubusercontent.com/adjective-rob/snap/main/install.sh | bash
```

It clones the repo to `~/.local/share/snap-annotate`, downloads the prebuilt app from the latest [release](https://github.com/adjective-rob/snap/releases) (or builds from source if there is none for your platform), sets up the hotkey, and registers the MCP server with Claude Code, Claude Desktop, Cursor, and Windsurf. Re-run it to update. On Windows, download the installer from the releases page (see [Windows](#windows)).

Or from a clone, step by step:

```bash
# Install system deps (Ubuntu/Debian)
make deps

# Build the app + MCP server, then wire up the hotkey for your session:
#   Wayland (GNOME) -> registers a custom keybinding that runs snap-trigger.sh
#   X11             -> installs the tray app as a user service
make install

# Register with all your AI tools (Claude Code, Claude Desktop, Cursor, Windsurf)
./setup-mcp.sh

# Check the whole install: capture tool, display, hotkey, MCP
./snap-doctor.sh
```

Press `Ctrl+Shift+S`, draw (drag a region first if you only want part of the screen), hit Enter. Then tell your agent: *"check my latest snap annotation"*

To use a different key: `SNAP_HOTKEY='<Super><Shift>s' make hotkey`. Sway and Hyprland users bind a key to `snap-trigger.sh` by hand; `make hotkey` prints the line.

For detailed Linux setup instructions, see **[SETUP.md](SETUP.md)**. macOS and Windows are covered below.

---

## macOS Quick Install

`install.sh` above does all of this for you. By hand:

```bash
# 1) Build app
make build

# 2) Install into /Applications
cp -R app/src-tauri/target/release/bundle/macos/snap.app /Applications/

# 3) Launch
open -a /Applications/snap.app
```

First run:
- Press `Ctrl+Shift+S` once to trigger permission prompts.
- Allow Screen Recording/Automation/Accessibility if asked.

To start Snap on every login, run `make install` after copying the app: it installs a LaunchAgent (`~/Library/LaunchAgents/com.adjective.snap.plist`) that opens `/Applications/snap.app` in the background. Then run `./setup-mcp.sh` to register the MCP server.

If permissions get stuck:

```bash
tccutil reset All com.adjective.snap
open -a /Applications/snap.app
```

---

## Windows

Snap runs as a tray app on Windows with the same `Ctrl+Shift+S` hotkey. There is no `make` flow; build with the Tauri CLI (needs Rust, Node.js, and the WebView2 runtime that ships with Windows 11):

```powershell
cd app
npm install
npx tauri build
```

The NSIS installer lands in `app\src-tauri\target\release\bundle\nsis\`. Each [release](https://github.com/adjective-rob/snap/releases) carries the same installer, built in GitHub Actions.

`setup-mcp.sh` is a bash script, so register the MCP server by hand: install it with `uv venv .venv` and `uv pip install -e .` inside `mcp-server\`, then point your MCP client at `mcp-server\.venv\Scripts\python.exe` with `mcp-server\server.py` as the argument (see [Manual Setup](SETUP.md#manual-setup)).

---

## Example Workflow

You're vibe engineering a web app. You open it in the browser, scroll through, and spot three issues.

**1. Snap the bugs** (takes ~15 seconds total)

```
Ctrl+Shift+S  →  circle the broken button, type "this should be blue"  →  Enter
Ctrl+Shift+S  →  arrow at the spacing gap, type "16px here"            →  Enter
Ctrl+Shift+S  →  number markers 1, 2, 3 on misaligned cards            →  Enter
```

Each save drops a PNG+JSON pair into `~/.snap/inbox/`. Three screenshots, three pairs.

**2. Tell your agent** (one prompt)

```
> fix the frontend issues I just annotated
```

If your CLAUDE.md has the Snap awareness instructions (see [SETUP.md](SETUP.md#add-snap-awareness-to-claudemd)), the agent automatically calls `check_new_annotations()` at the start of any UI task. It sees 3 new annotations, reads all 3 images and metadata, and starts fixing.

Without the CLAUDE.md instructions, just say:

```
> check my snap annotations and fix all of them
```

**3. Agent reads and fixes**

The agent calls `list_annotations(3)`, gets back:
- Screenshot 1: red circle on a button + text "this should be blue"
- Screenshot 2: red arrow at a gap + text "16px here"
- Screenshot 3: numbered markers on 3 misaligned cards

It reads each image, sees exactly what you circled, and applies the fixes.

**4. Clear the inbox**

After verifying the fixes:

```
> looks good, clear the snap inbox
```

The agent calls `clear_inbox()`. The queue is empty, ready for the next round.

**The inbox is a conveyor belt, not a filing cabinet.** Annotations go in, the agent processes them, you clear it.

---

## MCP Tools

The MCP server exposes 5 tools to any MCP-compatible AI agent:

| Tool | Description |
|------|-------------|
| `check_new_annotations()` | Are there new annotations since the agent last checked? Returns count and filenames. |
| `get_latest_annotation(include_image=true)` | Get the most recent annotation's metadata, with the annotated PNG attached as an image content block. |
| `list_annotations(last_n, include_image=false)` | List the N most recent annotations with metadata; optionally attach their images. |
| `get_annotation(filename, include_image=true)` | Get a specific annotation by its filename (without extension). |
| `clear_inbox()` | Delete all processed annotations from the inbox. |

Screenshots are returned as MCP `image` content blocks, which clients pass to the model as vision input at a few thousand tokens per image. Every result also carries `image_path` so agents with file access (Claude Code) can read the PNG directly. Images larger than `max_image_bytes` (default 5 MB) are not attached and a warning says so.

### How Agents Interpret Annotations

The following conventions are documented in your `CLAUDE.md` so agents know the visual language:

- **Red circles/rectangles** = "this area has a problem"
- **Arrows** = "this should move/connect there"
- **Text labels** = literal instructions ("fix this", "16px gap", "wrong color")
- **Numbered markers** = ordered list of issues (fix #1 first, then #2, etc.)
- **Freehand marks** = emphasis, "look at this general area"

---

## Architecture

```
snap/
  app/                      Tauri 2.x annotation overlay
    src/                    Vanilla HTML/CSS/JS frontend
      index.html            Toolbar + canvas markup
      main.js               Drawing engine, save logic, DPI handling
      export-scale.mjs      Window-to-image coordinate math (crop, layout, sidecar)
      export-scale.test.mjs Tests for the above (node --test)
      styles.css            Toolbar styling, animations
    src-tauri/              Rust backend
      src/
        main.rs             App lifecycle (tray mode on X11/macOS/Windows, overlay mode on Wayland)
        lib.rs              Screen capture, window context, save handler, logging
      Cargo.toml            Rust dependencies
      tauri.conf.json       App identifier, frontend path
      Info.plist            macOS usage descriptions, hides the Dock icon
      capabilities/         Tauri 2 permission definitions
      icons/                Tray icon
    package.json            Node dependencies (@tauri-apps/api, @tauri-apps/cli)

  mcp-server/               Python MCP server
    server.py               5 tools: check, get_latest, list, get, clear
    tests/                  Tool-level tests through an in-memory MCP client
    pyproject.toml          Package metadata + fastmcp dependency
    .venv/                  Python virtual environment (created during setup)

  install.sh                One-command installer (Linux, macOS): prebuilt app or source build
  snap-trigger.sh           Hotkey trigger script (Wayland): launches one overlay
  install-hotkey.sh         Registers the GNOME keybinding (keeps other shortcuts)
  setup-mcp.sh              Registers the MCP server with Claude Code, Claude Desktop, Cursor, Windsurf
  snap-doctor.sh            Checks capture tool, display, hotkey, MCP registration
  snap.service              systemd user service (X11 tray mode)
  snap.plist                launchd agent template (macOS, installed by make install)
  .github/workflows/        Release build for Linux, macOS, Windows (v*.*.* tags); acceptance tests (pull requests, main)
  features/                 Acceptance tests (axx): the MCP server, and the desktop app in features/desktop/
  acceptance/               Their fixtures, screenshots, and the Linux desktop image
  axx.yaml, axx-packs.yaml  axx's configuration and packs
  Makefile                  Build, install, hotkey, doctor, start/stop commands
  CLAUDE.md                 Project instructions for Claude Code
  AGENTS.md                 How agents write and run the acceptance tests (axx)
  SETUP.md                  Detailed setup guide (Linux)
  LICENSE                   MIT
```

### Tests

```bash
node --test app/src/export-scale.test.mjs
cd mcp-server && .venv/bin/python -m unittest discover -s tests
```

Acceptance tests use [axx](https://axx.nimbusxr.us/) v0.2.7. From the repository
root, install the MCP server dependencies and run the suite:

```bash
uv venv mcp-server/.venv
uv pip install --python mcp-server/.venv/bin/python -e ./mcp-server
axx run --compact                 # or: make test-acceptance
```

`services.snap` in `axx.yaml` starts the real MCP server using FastMCP's HTTP
transport on `127.0.0.1:8765`, waits for readiness, and stops it after the run.
The normal `snap` executable still uses stdio. For repeated runs against the
same application process:

```bash
axx up
axx run --compact
axx down
```

The scenarios in `features/` cover tool discovery, empty inboxes, annotation
metadata and ordering, unread tracking, missing images, corrupt sidecars, image
size warnings, and clearing screenshot pairs. The app uses `.axx/snap-mcp/` for
its test data. Each scenario resets the inbox and read marker; `run.exclusive`
keeps these scenarios serial even with `--workers`, because they share one inbox.
Personal captures remain in `~/.snap/inbox/`.

The default MCP suite requires no Tauri build, display server, or screen-recording permission.
The desktop acceptance tests run separately as described below. The
existing Python tests also check image content blocks through an in-memory MCP
client.

```bash
axx validate                     # check Gherkin and step definitions
axx run --tags @unread            # run one area
axx run --order random:42         # verify resets in a different order
axx steps show mcp.server        # the MCP pack's server step
```

On Windows, run these commands from the repository root:

```powershell
python -m venv mcp-server/.venv
mcp-server/.venv/Scripts/python.exe -m pip install -e ./mcp-server
axx run --profile windows --compact
```

A different interpreter can be selected with
`-D python=/absolute/path/to/python`, or a different port with `-D snap.port=8766`.
Use the same profile and properties for `axx up` and subsequent runs.

The suite uses axx's `mcp` and `files` packs. Each scenario empties the MCP
server's data folder, puts the captures it needs in the inbox (a PNG and its JSON
sidecar), and checks what the server left there. GitHub Actions runs the suite on
pull requests and pushes to `main`, and uploads JUnit and HTML reports.

`SNAP_DATA_DIR` overrides the data directory for both the desktop app and MCP
server (default `~/.snap`). It includes `inbox/` and `snap.log`, the server's
`.last_read`, and the desktop's capture scratch file and tray lock. The acceptance
configuration gives each app its own directory under `.axx/`.

#### Desktop acceptance tests

The features in `features/desktop/` use the real app as a person does, on
macOS, Windows, and Linux (X11 and Wayland): the hotkey, the overlay's tools,
colors and widths, each tool's key, undo, clear, dimming, the region tool,
closing without saving, moving the toolbar, quitting and opening Snap's folder
from the tray icon's menu, and an agent reading what was saved through the MCP
server, which runs over stdio on the app's own data folder.

On the screen is a known picture, Adjective's home page
(`acceptance/fixtures/backdrop.png`), shown by Preview on macOS, by Microsoft
Edge on Windows (`acceptance/fixtures/backdrop.html`), and by GNOME's image
viewer on Linux. Each saved picture is compared with a screenshot in
`acceptance/screenshots/`, one per platform, and its sidecar is checked. Where
the part of the screen is chosen differs by OS (macOS asks at its crosshair,
Windows and Linux in Snap's own screenshot, Wayland opens Snap as it starts),
so a few steps name their app by a property each profile sets.

macOS, with Node 22+, Rust, the Xcode command-line tools, and a signed-in
desktop:

```bash
(cd app && npx tauri build --bundles app)
axx run --profile desktop-macos
```

Allow Screen Recording for Snap when macOS asks. A build signed with your
identity keeps it (`APPLE_SIGNING_IDENTITY` set for `tauri build`); an unsigned
build needs it again after every build: `tccutil reset ScreenCapture com.adjective.snap`. Leave the mouse and keyboard
alone during the run.

Windows, from the repository root, with the MCP server installed as above:

```powershell
cd app; npx tauri build --no-bundle; cd ..
axx run --profile desktop-windows
```

Linux runs in Docker, in an image with the desktops, the build tools, and the
capture tools (`acceptance/linux/`). It builds Snap from the checkout and runs
the features with the Linux `axx` you mount:

```bash
docker build -t snap-acceptance acceptance/linux
docker run --rm --shm-size=1g --tmpfs /run/systemd \
  -v "$PWD:/src:ro" -v /path/to/linux/axx:/usr/local/bin/axx:ro \
  snap-acceptance snap-acceptance x11      # or wayland
```

In CI (`.github/workflows/acceptance.yml`), the desktop features run on GitHub's
macOS and Windows runners and, in the Linux image, on X11 and Wayland. Each job keeps
its report and an MP4 video of every scenario as an artifact (`desktop-macos`,
`desktop-windows`, `desktop-x11`, `desktop-wayland`), and a failure its traces and
any screenshot it took that `acceptance/screenshots/` has none of (`screenshots/`). On
the macOS runner the job first allows Snap what a person allows it the first time
(the Automation and Screen Recording prompts), as no one is there to answer them.
Locally, `--set packs.desktop-core.videos=always` keeps the videos in
`.axx/desktop/videos/`.

On Linux, `axx` keeps the desktop's tray, so the tray icon's menu is chosen
through it. On Wayland, Snap starts per picture (the desktop's hotkey starts
it), so the scenarios that press Snap's own hotkey again run on the other
platforms only.

### Platform Support

| Platform | Screen Capture | Window Context | Global Hotkey |
|----------|---------------|----------------|---------------|
| Linux X11 | `scrot` | `xdotool` (title, class, PID), `xprop` for the class with older xdotool | Tauri global-shortcut plugin (tray mode) |
| Linux Wayland (GNOME) | XDG desktop portal, then `gnome-screenshot` | Not available | GNOME custom keybinding → `snap-trigger.sh` |
| Linux Wayland (wlroots) | XDG desktop portal, then `grim` | Not available | Compositor keybinding → `snap-trigger.sh` |
| macOS | `screencapture` | AppleScript (title, URL, PID) | Tauri global-shortcut plugin (tray mode) |
| Windows | `screenshots` crate | Win32 `GetForegroundWindow` (title, class, PID) | Tauri global-shortcut plugin (tray mode) |

The capture system tries tools in order of preference and falls back gracefully. On Wayland it asks the XDG desktop portal first, then tries `gnome-screenshot`, `grim`, and `scrot`, each with a timeout. The portal is required on GNOME 50 and later (Ubuntu 26.04), where `gnome-screenshot` is no longer allowed to capture the screen. On Windows, capture goes through the cross-platform `screenshots` crate and window context is read from the Win32 foreground window.

### HiDPI / 4K Display Support

Snap correctly handles high-DPI displays. The canvas renders at physical pixel resolution for crisp annotations, while all drawing coordinates use logical pixels. The capture is shown 1:1 (letterboxed if it is larger than the window) and stays where it is: selecting a region dims everything outside it rather than zooming it, so the screen never jumps or blurs. One transform maps window coordinates onto native capture pixels for both the composited PNG and the sidecar coordinates. The saved PNG is the selected region at the capture's native resolution; selecting a region on a 4K display is the way to keep full pixel detail while staying under the size at which vision models downscale images.

On Linux the overlay starts the screen capture the moment the process launches, in parallel with the webview, and the window is shown only once the capture is decoded, so the first frame you see is your screen.

---

## Data & Privacy

- All data stays local. Screenshots are saved to `~/.snap/inbox/` and nowhere else.
- The MCP server is read-only over stdio. It never writes to the inbox, only reads and deletes.
- No network calls. No telemetry. No cloud.
- The screen capture uses your system's native screenshot path (the XDG desktop portal, `gnome-screenshot`, `scrot`, or `grim` on Linux; `screencapture` on macOS; the `screenshots` crate on Windows).
- Log file at `~/.snap/snap.log` (auto-rotates at 1MB). Contains timestamps and event names only, no image data.

---

## Built By

[Rob Murtha — Adjective LLC](https://adjective.us)

### Contributors

- Alec Lucas — macOS port
- TangoKiloA — Windows support (screen capture, window context, tray)

## License

MIT — see [LICENSE](LICENSE).
