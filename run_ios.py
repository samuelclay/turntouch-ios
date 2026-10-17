#!/usr/bin/env python3
"""
iOS Simulator Control Script

Usage:
    python3 run_ios.py list
    python3 run_ios.py --udid <UDID> <action1> <action2> ...

Options:
    --udid <UDID>         - Simulator UDID to target (required for all actions except list)

Actions:
    list                  - List available simulators with UDIDs
    tap:<x>,<y>           - Tap at coordinates
    sleep:<seconds>       - Wait for specified seconds
    swipe:<x1>,<y1>,<x2>,<y2> - Swipe from point to point
    screenshot:<path>     - Take screenshot and save to path
    launch                - Launch the Turn Touch app
    terminate             - Terminate the Turn Touch app
    install               - Install the app from DerivedData
    home                  - Go to the Home Screen
    boot                  - Boot the selected simulator and wait until ready
    describe              - Print the accessibility tree
    tap-id:<identifier>   - Tap an accessibility identifier
    tap-label:<label>     - Tap an exact accessibility label
    assert-label:<label>  - Fail unless the label is visible
    statusbar             - Set a deterministic screenshot status bar
    statusbar-reset       - Clear screenshot status-bar overrides
    restart-input         - Restart only this simulator's idb input connection

Examples:
    python3 run_ios.py list
    python3 run_ios.py --udid 08D78CD0-FA2A-49BF-BF2E-E81EA576CD40 launch sleep:4 screenshot:/tmp/test.png

Environment:
    IOS_SIM_UDID     - Simulator UDID (alternative to --udid flag)
    IOS_BUNDLE_ID    - App bundle identifier (defaults to Turn Touch)
    IOS_APP_PATH     - Path to the built .app for install
    IDB_DEVELOPER_DIR - Optional compatible SDK directory for idb input
"""

import os
import re
import shlex
import subprocess
import sys
import time
import signal
import json

# Configuration
UDID = os.environ.get("IOS_SIM_UDID", "")
BUNDLE_ID = os.environ.get("IOS_BUNDLE_ID", "com.turntouch.ios-remote")
APP_PATH = os.environ.get(
    "IOS_APP_PATH",
    "/Users/sclay/Library/Developer/Xcode/DerivedData/Turn_Touch_iOS-hhlldweafneihnbqxxlftrsforyz/Build/Products/Debug-iphonesimulator/Turn Touch iOS.app",
)

# Add idb to PATH
os.environ["PATH"] = os.environ["PATH"] + ":" + os.path.expanduser("~/Library/Python/3.13/bin")


def run_cmd(cmd, description=None, check=False):
    """Run a shell command and return output."""
    if description:
        print(f"  -> {description}")
    env = os.environ.copy()
    if cmd.startswith("idb ") and env.get("IDB_DEVELOPER_DIR"):
        env["DEVELOPER_DIR"] = env["IDB_DEVELOPER_DIR"]
    result = subprocess.run(cmd, shell=True, capture_output=True, text=True, env=env)
    if result.returncode != 0 and result.stderr:
        print(f"  Warning: {result.stderr.strip()}")
    if check:
        result.check_returncode()
    return result.stdout.strip()


def do_list():
    """List available simulators with UDIDs."""
    output = run_cmd("xcrun simctl list devices available")
    print("Available iOS Simulators:")
    print("-" * 70)
    current_runtime = ""
    for line in output.splitlines():
        line = line.strip()
        if line.startswith("--"):
            current_runtime = line.strip("- ")
        else:
            match = re.match(r"(.+?)\s+\(([A-F0-9-]+)\)\s+\((\w+)\)", line)
            if match:
                name, udid, state = match.groups()
                marker = " <-- BOOTED" if state == "Booted" else ""
                print(f"  {state:<10} {name:<30} {udid}{marker}")
    print("-" * 70)
    print()
    print("Usage: python3 run_ios.py --udid <UDID> <actions...>")
    print("   or: IOS_SIM_UDID=<UDID> python3 run_ios.py <actions...>")


def do_tap(coords):
    """Tap at x,y coordinates."""
    x, y = coords.split(",")
    print(f"  Tap: ({x}, {y})")
    run_cmd(f"idb ui tap --udid {UDID} {x} {y}", check=True)


def do_sleep(seconds):
    """Sleep for specified seconds."""
    secs = float(seconds)
    print(f"  Sleep: {secs}s")
    time.sleep(secs)


def do_swipe(coords):
    """Swipe from x1,y1 to x2,y2."""
    parts = coords.split(",")
    if len(parts) != 4:
        print(f"  Error: swipe requires 4 coordinates (x1,y1,x2,y2)")
        return
    x1, y1, x2, y2 = parts
    print(f"  Swipe: ({x1},{y1}) -> ({x2},{y2})")
    run_cmd(f"idb ui swipe --udid {UDID} {x1} {y1} {x2} {y2}")


def do_screenshot(path):
    """Take screenshot and save to path."""
    print(f"  Screenshot: {path}")
    run_cmd(f"xcrun simctl io {UDID} screenshot {path}", check=True)


def do_launch(language=None, welcome=False):
    """Launch the Turn Touch app."""
    print("  Launching Turn Touch...")
    arguments = ""
    if language:
        import json
        from pathlib import Path
        supported = json.loads((Path(__file__).parent / "localization/languages.json").read_text())
        if language not in supported:
            raise ValueError("Unsupported language: " + language)
        arguments = " " + " ".join(shlex.quote(value) for value in ["-AppleLanguages", "(" + language + ")", "-AppleLocale", language, "-TT:language", language, "-TT:language:welcomed", "NO" if welcome else "YES"])
    result = run_cmd(f"xcrun simctl launch {UDID} {BUNDLE_ID}{arguments}")
    print(f"  {result}")


def do_terminate():
    """Terminate the Turn Touch app."""
    print("  Terminating Turn Touch...")
    run_cmd(f"xcrun simctl terminate {UDID} {BUNDLE_ID} 2>/dev/null")


def do_install():
    """Install the app from DerivedData."""
    print("  Installing Turn Touch...")
    if not os.path.exists(APP_PATH):
        print(f"  Error: APP_PATH does not exist: {APP_PATH}")
        return
    quoted_path = shlex.quote(APP_PATH)
    run_cmd(f"xcrun simctl install {UDID} {quoted_path}")


def parse_and_execute(action):
    """Parse and execute a single action."""
    if ":" in action:
        cmd, arg = action.split(":", 1)
    else:
        cmd = action
        arg = None

    if cmd == "tap":
        do_tap(arg)
    elif cmd == "sleep":
        do_sleep(arg)
    elif cmd == "swipe":
        do_swipe(arg)
    elif cmd == "screenshot":
        do_screenshot(arg)
    elif cmd == "launch":
        do_launch(arg)
    elif cmd == "welcome":
        do_launch(arg, welcome=True)
    elif cmd == "terminate":
        do_terminate()
    elif cmd == "install":
        do_install()
    elif cmd in ["tap-id", "tap-label", "assert-label"]:
        nodes = json.loads(run_cmd(f"idb ui describe-all --udid {UDID}", check=True))
        key = "AXUniqueId" if cmd == "tap-id" else "AXLabel"
        matches = [node for node in nodes if node.get(key) == arg]
        if not matches:
            raise RuntimeError(f"No visible {key}: {arg}")
        if cmd != "assert-label":
            frame = matches[0]["frame"]
            do_tap(f"{round(frame['x'] + frame['width']/2)},{round(frame['y'] + frame['height']/2)}")
    elif cmd == "restart-input":
        for row in subprocess.check_output(["ps", "-axo", "pid=,command="], text=True).splitlines():
            pid, command = row.strip().split(" ", 1)
            if command.startswith("/opt/homebrew/bin/idb_companion --udid " + UDID + " "):
                os.kill(int(pid), signal.SIGTERM)
        run_cmd(f"idb disconnect {UDID}")
    elif cmd == "home":
        run_cmd(f"idb ui button HOME --udid {UDID}", check=True)
    elif cmd == "describe":
        print(run_cmd(f"idb ui describe-all --udid {UDID}"))
    elif cmd == "statusbar-reset":
        run_cmd(f"xcrun simctl status_bar {UDID} clear")
    elif cmd == "boot":
        run_cmd(f"xcrun simctl boot {UDID}")
        run_cmd(f"xcrun simctl bootstatus {UDID} -b")
    elif cmd == "statusbar":
        run_cmd(f"xcrun simctl status_bar {UDID} override --time 9:41 --dataNetwork wifi --wifiMode active --wifiBars 3 --batteryState charged --batteryLevel 100")
    elif cmd == "list":
        do_list()
    else:
        print(f"  Unknown action: {cmd}")


def main():
    global UDID

    if len(sys.argv) < 2:
        print(__doc__)
        sys.exit(1)

    # Parse --udid flag
    args = sys.argv[1:]
    actions = []
    i = 0
    while i < len(args):
        if args[i] == "--udid" and i + 1 < len(args):
            UDID = args[i + 1]
            i += 2
        else:
            actions.append(args[i])
            i += 1

    if not actions:
        print(__doc__)
        sys.exit(1)

    # "list" doesn't require a UDID
    if actions == ["list"]:
        do_list()
        return

    # All other actions require a UDID
    if not UDID:
        print("Error: No simulator UDID specified.\n")
        do_list()
        sys.exit(1)

    print("=" * 60)
    print(f"iOS Simulator Control (UDID: {UDID})")
    print("=" * 60)

    for action in actions:
        parse_and_execute(action)

    print("=" * 60)
    print("Done!")
    print("=" * 60)


if __name__ == "__main__":
    main()
