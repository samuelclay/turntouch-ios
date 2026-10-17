# Turn Touch iOS 3.1 store assets

21 languages, with genuine app captures at three sizes:

- `iphone-medium`: 1206 × 2622, the required Dynamic Island medium-display slot.
- `iphone`: 1320 × 2868, the optional large-display slot and artwork source.
- `ipad`: 2064 × 2752, the required 13-inch iPad slot.

Each language includes remote controls, Settings with Language first, and the app chooser. Captures use launch-only language overrides. The simulator cannot connect to Bluetooth hardware, so these images show configuration UI without claiming a connected remote.

`artwork/exports/<language>/` contains an opaque RGB PNG header (3840 × 1646) and JPEG search-results image (3840 × 2560). These are suitable for the App Store Connect Asset Library and the corresponding localized product-page slots. The unchanged Turn Touch product photograph comes from `turntouch-web/static/images/media-kit/studio/studio-single-mahogany.jpg`; a copy is in `artwork/assets/remote.jpg`. The layout uses translated store copy and a real localized app screenshot. No app UI was synthesized.

## Regenerate

1. Update `localization/store-source.json`, then run the documented localization extraction/translation/check workflow.
2. Install the simulator build using `run_ios.py`. Device IDs in `Scripts/capture_store.py` identify the capture devices used for this release; update them for another machine.
3. Run `python3 Scripts/capture_store.py --devices iphone-medium iphone ipad`. Capture controls are found by accessibility identifier and translated label. The script verifies the Language setting is visible and rejects duplicate scene files. `--languages es fr` limits a run; `--resume` skips complete sets, so omit it when refreshing screenshots.
4. If the installed idb companion needs an alternate compatible SDK, set `IDB_DEVELOPER_DIR` for its SDK directory. This applies only to idb, not Xcode builds. `run_ios.py restart-input` resets only the selected simulator's input companion.
5. Run `swiftc -O Scripts/render_store.swift -o /tmp/turntouch-store-render && /tmp/turntouch-store-render` from the repo root. Optional language arguments limit artwork regeneration.
6. Inspect every language in the galleries, validate dimensions, and run `python3 Scripts/index_store.py` to refresh `manifest.json` and `localized-gallery.html` before upload. Use locale-prefixed upload names to distinguish assets in App Store Connect.

App Store specifications: [creative assets](https://developer.apple.com/help/app-store-connect/reference/app-information/creative-assets-specifications) and [screenshots](https://developer.apple.com/help/app-store-connect/reference/app-information/screenshot-specifications).

Uploaded assets and uploaded builds are separate from App Review submission and public release. See release status evidence for the final submission state.

Run `python3 Scripts/index_store.py` after changing assets to refresh the [gallery](localized-gallery.html) and SHA-256 manifest (uses macOS `sips`).
