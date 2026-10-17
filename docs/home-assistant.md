# Home Assistant

Home Assistant is an app in the native action chooser and Settings → Apps & Connections. It uses Home Assistant's existing REST, WebSocket, OAuth, and Bonjour APIs; no custom Home Assistant integration is required.

Choose **Connection…** in the ellipsis menu, select the discovered home (or enter its address), then **Sign in…**. Home Assistant handles the password in its own sign-in page. An access token can also be entered through **Use access token…**. Credentials are stored in Keychain, never in button preferences.

Search by entity, device, or room and filter by category. Select an entity; **Action settings** chooses its operation and contains the optional JSON disclosure. **Test action** executes without assigning. **Set remote button** saves the selection to the specific button and gesture shown above it. Settings provides the same browser without assignment controls. Scenes activate looks, scripts run sequences, and blueprint-created automations appear as automations. Automation triggers check conditions unless explicitly overridden in action data.

Bindings include their server URL and cannot silently run against a different home. Action data cannot override entity targeting. Required service fields are validated. Token refresh is serialized, authenticated redirects are refused, and optional registry failures do not prevent basic entity browsing.

## Validation

- `python3 Scripts/test_home_assistant.py`: 50 checks against the production Objective-C client and a loopback HTTP fixture, including OAuth refresh, exact targets, redirects, malformed JSON, and Keychain restoration/disconnect.
- `python3 Scripts/home_assistant_fixture.py`: start the non-actuating UI-test server on port 18123. Make the Mac reachable from the device.
- `python3 Scripts/test_home_assistant_device.py --device DEVICE_UDID --server http://MAC_LAN_IP:18123`: build and run XCUITests on an unlocked physical device. The test host uses a separate Keychain namespace and unique batch-action keys, preserving the user's home connection and remote assignments. It exercises token entry, browsing, testing, explicit saving, relaunch persistence, and disconnect in both button-bank formats. German and Arabic layouts are also captured and checked. Screenshots are attached to the xcresult.

The DEBUG-only `--home-assistant` launch argument opens the regular connection screen. The isolated `--ha-ui-test` route exists only in development builds. Never use fixture tests as evidence of live-home or Bluetooth remote actuation.

Protocol reference: https://contributors.home-assistant.io/core/internals/auth-api/
