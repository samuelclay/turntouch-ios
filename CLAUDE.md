# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Turn Touch iOS is a native Swift app for configuring and controlling the Turn Touch smart wooden remote control. The app connects to the remote via Bluetooth Low Energy (BLE) and allows users to assign actions to the four directional buttons (North, East, West, South).

## Build Commands

```bash
# Install dependencies
pod install

# Build and run
# Open Turn Touch iOS.xcworkspace in Xcode and build (Cmd+B) / run (Cmd+R)
# Must run on a physical device for Bluetooth functionality
```

## Architecture

### Core Components

**AppDelegate** (`Turn Touch iOS/AppDelegate.swift`)
- Entry point, initializes `TTBluetoothMonitor` and `TTModeMap`
- Manages app lifecycle, location services, and network reachability
- Global accessor via `appDelegate()` function

**TTModeMap** (`Turn Touch iOS/Models/TTModeMap.swift`)
- Central hub managing mode/action configuration
- Maps four directions to modes (north/east/west/south)
- Supports two button app modes:
  - `SixteenButtons`: Each direction has its own mode with 4 actions
  - `TwelveButtons`: Single/double/hold tap modes across 4 directions
- Handles batch actions (multiple actions per button press)
- Stores all settings in `UserDefaults` with key pattern: `TT:mode-{direction}:action:{actionDirection}`

**TTBluetoothMonitor** (`Turn Touch iOS/Bluetooth/TTBluetoothMonitor.swift`)
- Manages BLE connections to Turn Touch remotes
- Handles device discovery, pairing, and state restoration
- Maintains `TTDeviceList` of connected remotes
- Button presses routed through `TTButtonTimer`

**TTMode** (`Turn Touch iOS/Models/TTMode.swift`)
- Base class for all modes (apps)
- Defines protocol: `activate()`, `deactivate()`, `title()`, `imageName()`, `subtitle()`, `actions()`
- Actions are methods named `run{ActionName}`, `title{ActionName}`, `image{ActionName}`
- Supports double-tap (`doubleRun{ActionName}`) and hold (`holdRun{ActionName}`) variants
- Options stored per-mode and per-action with defaults in `.plist` files

### Modes (Smart Home Integrations)

Each mode lives in `Turn Touch iOS/Modes/{ModeName}/`:
- `TTModePhone` - Device volume/ringer controls
- `TTModeMusic` - Apple Music playback
- `TTModeHue` - Philips Hue lights
- `TTModeSonos` - Sonos speakers
- `TTModeWemo` - Belkin WeMo devices
- `TTModeNest` - Nest thermostat
- `TTModeBose` - Bose SoundTouch
- `TTModeCamera` - Camera capture
- `TTModeCustom` - Custom URL triggers
- `TTModeIfttt` - IFTTT webhooks
- `TTModeHomeKit` - HomeKit scenes
- `TTModeYoga` - Guided yoga timer

### Adding a New Mode

1. Create directory under `Turn Touch iOS/Modes/{ModeName}/`
2. Create main mode class extending `TTMode`:
   - Override `title()`, `subtitle()`, `imageName()`, `actions()`
   - Implement `run{ActionName}`, `title{ActionName}`, `image{ActionName}` for each action
3. Add mode class name to `availableModes` array in `TTModeMap.swift`
4. Create options views as needed (extend `TTOptionsDetailViewController`)
5. Add default options in `{ModeName}.plist` if needed

### Views Structure

- `Turn Touch iOS/Views/Main/` - Main view controller and layout
- `Turn Touch iOS/Views/Mode Map/` - Mode selection interface
- `Turn Touch iOS/Views/Mode menu/` - Mode switching menu
- `Turn Touch iOS/Views/Action diamond/` - Four-button diamond display
- `Turn Touch iOS/Views/Options/` - Action configuration UI
- `Turn Touch iOS/Views/Batch actions/` - Multiple actions per button

### Key Patterns

- **Direction enum**: `TTModeDirection` (`.north`, `.east`, `.west`, `.south`, `.single`, `.double`, `.hold`, `.no_DIRECTION`)
- **Button moments**: `TTButtonMoment` (`.button_MOMENT_PRESSUP`, `.button_MOMENT_PRESSDOWN`, `.button_MOMENT_DOUBLE`, `.button_MOMENT_HELD`)
- **KVO**: Used extensively for UI updates (observe `selectedModeDirection`, `inspectingModeDirection`, etc.)
- **Preferences**: All user settings stored in `UserDefaults` with `TT:` prefix

### Dependencies (CocoaPods)

- `CocoaAsyncSocket` - TCP/UDP networking (Sonos, Wemo, Bose discovery)
- `AFNetworking` - HTTP networking
- `SWXMLHash` - XML parsing (SOAP/UPnP)
- `ReachabilitySwift` - Network status
- `SwiftyHue` - Philips Hue SDK
- `iOSDFULibrary` - Nordic DFU for firmware updates
- `InAppSettingsKit` - In-app settings UI
- `NestSDK` - Nest thermostat integration

### Firmware Updates

DFU firmware files are in `Turn Touch iOS/DFU/` (nrf51_XX.zip). The app uses Nordic's iOSDFULibrary for over-the-air updates to the Turn Touch remote's nRF51 chip.

## iOS Simulator Testing

**IMPORTANT**: Always use `run_ios.py` for ALL simulator interactions (screenshots, taps, installs). Do NOT use Chrome DevTools MCP server, `xcrun simctl`, or `idb` directly — `run_ios.py` wraps these and handles PATH setup automatically.

The app bundle ID is `com.turntouch.ios-remote`.

### Choosing a Simulator

1. Run `python3 run_ios.py list` to see available simulators
2. Use whichever device is already **Booted** (marked with `<-- BOOTED` in the list)
3. If no device is booted, boot an **iPhone 16e** on the latest available iOS version: `xcrun simctl boot <UDID>`

### Build for Simulator

```bash
xcodebuild -workspace "Turn Touch iOS.xcworkspace" -scheme "Turn Touch iOS" -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 16e' build
```

### run_ios.py - Simulator Control Script

**IMPORTANT: You must specify a simulator UDID.** First run `list` to find the booted device, then pass the UDID via `--udid`:

```bash
# Step 1: Find available simulators and their UDIDs
python3 run_ios.py list

# Step 2: Use --udid with any action
python3 run_ios.py --udid <UDID> tap:<x>,<y>              # Tap at coordinates
python3 run_ios.py --udid <UDID> sleep:<seconds>          # Wait
python3 run_ios.py --udid <UDID> swipe:<x1>,<y1>,<x2>,<y2> # Swipe
python3 run_ios.py --udid <UDID> screenshot:/tmp/shot.png  # Take screenshot
python3 run_ios.py --udid <UDID> launch                    # Launch Turn Touch
python3 run_ios.py --udid <UDID> terminate                 # Kill Turn Touch
python3 run_ios.py --udid <UDID> install                   # Install from DerivedData

# Chain multiple actions
python3 run_ios.py --udid <UDID> launch sleep:2 tap:175,600 sleep:1 screenshot:/tmp/result.png
```

### Screenshot Coordinate Mapping (iPhone 16e)

Screenshots from `run_ios.py` are 1170x2532 pixels, but tap coordinates use the simulator window size (384x824). To convert screenshot pixel coordinates to tap coordinates:

| Dimension | Screenshot | Simulator | Scale Factor |
|-----------|------------|-----------|--------------|
| Width     | 1170       | 384       | 3.047        |
| Height    | 2532       | 824       | 3.073        |

**Conversion formula:**
```
tap_x = screenshot_x / 3.047
tap_y = screenshot_y / 3.073
```

**IMPORTANT:** When viewing screenshots, Claude sees a scaled-down thumbnail (not the full 1170x2532). You must estimate coordinates in the **full resolution screenshot space**, not the displayed thumbnail. Think in terms of the 1170x2532 coordinate system:

- Estimate vertical position by counting UI elements and their approximate pixel heights in a 2532px tall screen
- Status bar: ~100px, headers: ~150px, list rows: ~120px each
- Then apply the division formula to convert to tap coordinates

### Manual Simulator Commands (reference only — prefer run_ios.py)

- **Boot a simulator**: `xcrun simctl boot <UDID>`
- **Stream logs**: `xcrun simctl spawn booted log stream --predicate 'process == "Turn Touch iOS"'`
