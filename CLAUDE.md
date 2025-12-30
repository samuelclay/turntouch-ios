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
