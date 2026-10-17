import XCTest

final class HomeAssistantUITests: XCTestCase {
    func testTwelveButtonAssignment() throws { try checkAssignment(sixteen: false) }
    func testSixteenButtonAssignment() throws { try checkAssignment(sixteen: true) }
    func testLocalizedLayouts() throws {
        XCUIDevice.shared.orientation = .portrait
        for language in ["de", "ar"] {
            let app = XCUIApplication()
            app.launchEnvironment["HA_TEST_URL"] = try XCTUnwrap(ProcessInfo.processInfo.environment["HA_TEST_URL"])
            app.launchArguments = ["--ha-ui-test", "--ha-ui-preview", "-TT:language", language, "-AppleLanguages", "(\(language))"]
            app.launch()
            XCTAssertTrue(app.tables.staticTexts["Evening"].waitForExistence(timeout: 15))
            XCTAssertTrue(app.buttons["ha-save"].isEnabled)
            let screenshot = XCTAttachment(screenshot: app.screenshot()); screenshot.name = "Home Assistant \(language)"; screenshot.lifetime = .keepAlways; add(screenshot)
            app.buttons["ha-menu"].tap()
            // Menu labels are localized; use the destructive action's locale-specific title.
            app.buttons[language == "de" ? "Trennen" : "قطع الاتصال"].tap()
            XCTAssertTrue(app.buttons["ha-sign-in"].waitForExistence(timeout: 5))
            let signedOut = XCTAttachment(screenshot: app.screenshot()); signedOut.name = "Home Assistant sign in \(language)"; signedOut.lifetime = .keepAlways; add(signedOut)
            app.terminate()
        }
    }
    private func checkAssignment(sixteen: Bool) throws {
        continueAfterFailure = false
        XCUIDevice.shared.orientation = .portrait
        let app = XCUIApplication()
        app.launchArguments = ["--ha-ui-test"] + (sixteen ? ["--ha-ui-sixteen"] : [])
        app.launch()
        addUIInterruptionMonitor(withDescription: "Local network") { alert in
            let allow = alert.buttons["Allow"]; if allow.exists { allow.tap(); return true }; return false
        }
        XCTAssertTrue(app.buttons["ha-sign-in"].waitForExistence(timeout: 10))
        app.buttons["ha-sign-in"].tap()
        XCTAssertTrue(app.textFields["Home Assistant address"].waitForExistence(timeout: 3))
        app.buttons["Home Assistant menu"].tap()
        app.buttons["Use access token…"].tap()
        let address = app.textFields["Home Assistant address"]
        XCTAssertTrue(address.waitForExistence(timeout: 3))
        address.tap(); address.press(forDuration: 1.2)
        if app.menuItems["Select All"].waitForExistence(timeout: 2) { app.menuItems["Select All"].tap() }
        // Select all with keyboard shortcut when a hardware keyboard is attached too.
        address.typeText(String(repeating: XCUIKeyboardKey.delete.rawValue, count: 80))
        address.typeText(try XCTUnwrap(ProcessInfo.processInfo.environment["HA_TEST_URL"], "Run Scripts/test_home_assistant_device.py with --server"))
        app.secureTextFields["Access token"].tap(); app.secureTextFields["Access token"].typeText("fixture-token")
        app.buttons["Connect"].tap()
        let evening = app.tables.staticTexts["Evening"]
        XCTAssertTrue(evening.waitForExistence(timeout: 15))
        evening.tap()
        XCTAssertFalse(app.textViews.firstMatch.isHittable)
        let test = app.buttons["ha-test"]
        for _ in 0..<4 where !test.isHittable { app.swipeUp() }
        test.tap()
        XCTAssertTrue(app.staticTexts["Home Assistant accepted the action."].waitForExistence(timeout: 10))
        let save = app.buttons["ha-save"]
        for _ in 0..<4 where !save.isHittable { app.swipeUp() }
        save.tap()
        XCTAssertTrue(app.staticTexts[sixteen ? "✓ North · Home Assistant now runs “Evening”." : "✓ North · Single tap now runs “Evening”."].waitForExistence(timeout: 5))
        let screenshot = XCTAttachment(screenshot: app.screenshot()); screenshot.name = "Home Assistant assignment"; screenshot.lifetime = .keepAlways; add(screenshot)
        app.terminate(); app.launch()
        XCTAssertTrue(app.tables.staticTexts["Evening"].waitForExistence(timeout: 15))
        XCTAssertTrue(app.buttons["ha-save"].isEnabled)
        app.buttons["Action settings"].tap()
        XCTAssertTrue(app.buttons["Activate scene"].waitForExistence(timeout: 3))
        app.buttons["Home Assistant menu"].tap(); app.buttons["Disconnect"].tap()
    }
}
