//
//  TTModeGovee.swift
//  Turn Touch iOS
//
//  Created by Samuel Clay on 2/20/26.
//  Copyright © 2026 Turn Touch. All rights reserved.
//

import Foundation
import Security

enum TTGoveeState {
    case disconnected
    case connecting
    case connected
}

protocol TTModeGoveeDelegate {
    func changeState(_ state: TTGoveeState, mode: TTModeGovee)
    func fetchStatusUpdate(_ status: String)
}

class TTModeGovee: TTMode, GoveeAPIClientDelegate {

    var delegate: TTModeGoveeDelegate?

    static var goveeState = TTGoveeState.disconnected
    static var apiClient = GoveeAPIClient()
    static var foundDevices: [GoveeDevice] = []

    // Keychain keys
    private static let keychainService = "com.turntouch.ios.govee"

    // MARK: - Initialization

    required init() {
        super.init()

        NSLog(" ---> Govee: INIT CALLED")

        TTModeGovee.apiClient.delegate = self

        if TTModeGovee.foundDevices.isEmpty {
            NSLog(" ---> Govee: foundDevices is empty, assembling...")
            assembleFoundDevices()
        }

        NSLog(" ---> Govee: After assemble, foundDevices count = \(TTModeGovee.foundDevices.count)")

        if let apiKey = TTModeGovee.loadApiKey() {
            TTModeGovee.apiClient.setApiKey(apiKey)

            if TTModeGovee.foundDevices.isEmpty {
                NSLog(" ---> Govee: Still empty, fetching from API")
                TTModeGovee.goveeState = .connecting
                beginConnectingToGovee()
            } else {
                NSLog(" ---> Govee: Have devices, setting connected")
                TTModeGovee.goveeState = .connected
            }
        } else {
            NSLog(" ---> Govee: No API key, setting disconnected")
            TTModeGovee.goveeState = .disconnected
        }

        delegate?.changeState(TTModeGovee.goveeState, mode: self)
    }

    // MARK: - Mode Info

    override class func title() -> String {
        return "Govee"
    }

    override class func subtitle() -> String {
        let count = foundDevices.count
        if count == 0 {
            return "Smart lights and devices"
        } else if count == 1 {
            return "1 device"
        } else {
            return "\(count) devices"
        }
    }

    override class func imageName() -> String {
        return "mode_hue.png"
    }

    // MARK: - Actions

    override class func actions() -> [String] {
        return [
            "TTModeGoveeDeviceOn",
            "TTModeGoveeDeviceOff",
            "TTModeGoveeDeviceToggle",
            "TTModeGoveeBrightnessUp",
            "TTModeGoveeBrightnessDown"
        ]
    }

    // MARK: - Action Titles

    func titleTTModeGoveeDeviceOn() -> String {
        return "Turn on"
    }

    func titleTTModeGoveeDeviceOff() -> String {
        return "Turn off"
    }

    func titleTTModeGoveeDeviceToggle() -> String {
        return "Toggle device"
    }

    func titleTTModeGoveeBrightnessUp() -> String {
        return "Brightness up"
    }

    func titleTTModeGoveeBrightnessDown() -> String {
        return "Brightness down"
    }

    // MARK: - Action Images

    func imageTTModeGoveeDeviceOn() -> String {
        return "hue_on"
    }

    func imageTTModeGoveeDeviceOff() -> String {
        return "hue_off"
    }

    func imageTTModeGoveeDeviceToggle() -> String {
        return "electrical"
    }

    func imageTTModeGoveeBrightnessUp() -> String {
        return "hue_brightness"
    }

    func imageTTModeGoveeBrightnessDown() -> String {
        return "hue_brightness"
    }

    // MARK: - Defaults

    override func defaultNorth() -> String {
        return "TTModeGoveeDeviceOn"
    }

    override func defaultEast() -> String {
        return "TTModeGoveeBrightnessUp"
    }

    override func defaultWest() -> String {
        return "TTModeGoveeBrightnessDown"
    }

    override func defaultSouth() -> String {
        return "TTModeGoveeDeviceOff"
    }

    // MARK: - Activation

    override func activate() {
        delegate?.changeState(TTModeGovee.goveeState, mode: self)
    }

    override func deactivate() {
        // No persistent connections to clean up
    }

    // MARK: - Action Methods

    func runTTModeGoveeDeviceOn(direction: NSNumber) {
        let devices = selectedDevices(TTModeDirection(rawValue: direction.intValue)!)
        for device in devices {
            TTModeGovee.apiClient.controlDevice(device, turnOn: true)
            device.deviceState = .on
        }
    }

    func runTTModeGoveeDeviceOff(direction: NSNumber) {
        let devices = selectedDevices(TTModeDirection(rawValue: direction.intValue)!)
        for device in devices {
            TTModeGovee.apiClient.controlDevice(device, turnOn: false)
            device.deviceState = .off
        }
    }

    func runTTModeGoveeDeviceToggle(direction: NSNumber) {
        let devices = selectedDevices(TTModeDirection(rawValue: direction.intValue)!)
        for device in devices {
            TTModeGovee.apiClient.delegate = self
            TTModeGovee.apiClient.fetchDeviceState(device)
        }
    }

    func runTTModeGoveeBrightnessUp(direction: NSNumber) {
        let devices = selectedDevices(TTModeDirection(rawValue: direction.intValue)!)
        for device in devices {
            let newBrightness = min(100, device.brightness + GoveeConstants.brightnessStep)
            TTModeGovee.apiClient.setBrightness(device, brightness: newBrightness)
            device.brightness = newBrightness
        }
    }

    func runTTModeGoveeBrightnessDown(direction: NSNumber) {
        let devices = selectedDevices(TTModeDirection(rawValue: direction.intValue)!)
        for device in devices {
            let newBrightness = max(1, device.brightness - GoveeConstants.brightnessStep)
            TTModeGovee.apiClient.setBrightness(device, brightness: newBrightness)
            device.brightness = newBrightness
        }
    }

    // MARK: - Device Selection

    func selectedDevices(_ direction: TTModeDirection) -> [GoveeDevice] {
        ensureDevicesSelected()
        var devices: [GoveeDevice] = []

        if TTModeGovee.foundDevices.isEmpty {
            return devices
        }

        if let selectedIds = action.optionValue(GoveeConstants.kGoveeSelectedDevices) as? [String] {
            for foundDevice in TTModeGovee.foundDevices {
                if selectedIds.contains(foundDevice.deviceId) {
                    devices.append(foundDevice)
                }
            }
        }

        return devices
    }

    func ensureDevicesSelected() {
        if TTModeGovee.foundDevices.isEmpty {
            return
        }

        let selectedIds = action.optionValue(GoveeConstants.kGoveeSelectedDevices) as? [String]
        if let selectedIds = selectedIds, !selectedIds.isEmpty {
            return
        }

        // Nothing selected, select all devices
        let ids = TTModeGovee.foundDevices.map { $0.deviceId }
        action.changeActionOption(GoveeConstants.kGoveeSelectedDevices, to: ids)
    }

    // MARK: - Connection

    func refreshDevices() {
        beginConnectingToGovee()
    }

    func beginConnectingToGovee() {
        NSLog(" ---> Govee: beginConnectingToGovee CALLED")
        TTModeGovee.goveeState = .connecting

        DispatchQueue.main.async {
            self.delegate?.changeState(TTModeGovee.goveeState, mode: self)
            self.delegate?.fetchStatusUpdate("Fetching devices from Govee...")
        }

        TTModeGovee.apiClient.delegate = self
        TTModeGovee.apiClient.fetchDevices()
    }

    func cancelConnectingToGovee() {
        TTModeGovee.goveeState = .connected

        DispatchQueue.main.async {
            self.delegate?.changeState(TTModeGovee.goveeState, mode: self)
        }
    }

    func resetKnownDevices() {
        let prefs = UserDefaults.standard
        prefs.removeObject(forKey: GoveeConstants.kGoveeFoundDevices)
        prefs.synchronize()

        TTModeGovee.foundDevices = []
    }

    // MARK: - Device Persistence

    func assembleFoundDevices() {
        let prefs = UserDefaults.standard
        TTModeGovee.foundDevices = []

        if let savedDevices = prefs.array(forKey: GoveeConstants.kGoveeFoundDevices) as? [[String: Any]] {
            for deviceDict in savedDevices {
                if let device = GoveeDevice.fromDictionary(deviceDict) {
                    TTModeGovee.foundDevices.append(device)
                    NSLog(" ---> Govee: Loaded device: \(device.deviceName)")
                }
            }
        }
    }

    func storeFoundDevices() {
        TTModeGovee.foundDevices.sort { (a, b) -> Bool in
            return a.deviceName.lowercased() < b.deviceName.lowercased()
        }

        var savedDevices: [[String: Any]] = []
        var savedIds: Set<String> = []

        for device in TTModeGovee.foundDevices {
            guard !savedIds.contains(device.deviceId) else { continue }
            savedIds.insert(device.deviceId)
            savedDevices.append(device.toDictionary())
        }

        let prefs = UserDefaults.standard
        prefs.set(savedDevices, forKey: GoveeConstants.kGoveeFoundDevices)
        prefs.synchronize()
    }

    // MARK: - API Key Management

    static func saveApiKey(_ apiKey: String) {
        saveToKeychain(key: "apiKey", value: apiKey)
    }

    static func loadApiKey() -> String? {
        return loadFromKeychain(key: "apiKey")
    }

    static func hasApiKey() -> Bool {
        return loadApiKey() != nil
    }

    static func clearApiKey() {
        deleteFromKeychain(key: "apiKey")
    }

    // MARK: - Keychain Helpers

    private static func saveToKeychain(key: String, value: String) {
        guard let data = value.data(using: .utf8) else { return }

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecAttrAccount as String: key
        ]

        SecItemDelete(query as CFDictionary)

        var newQuery = query
        newQuery[kSecValueData as String] = data
        SecItemAdd(newQuery as CFDictionary, nil)
    }

    private static func loadFromKeychain(key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status == errSecSuccess, let data = result as? Data else {
            return nil
        }

        return String(data: data, encoding: .utf8)
    }

    private static func deleteFromKeychain(key: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecAttrAccount as String: key
        ]
        SecItemDelete(query as CFDictionary)
    }

    // MARK: - GoveeAPIClientDelegate

    func apiClientDidFetchDevices(_ devices: [GoveeDevice]) {
        NSLog(" ---> Govee: Received \(devices.count) devices from API")

        TTModeGovee.foundDevices = devices
        storeFoundDevices()

        TTModeGovee.goveeState = .connected
        delegate?.changeState(TTModeGovee.goveeState, mode: self)
        delegate?.fetchStatusUpdate("Found \(devices.count) devices")
    }

    func apiClientDidFailWithError(_ error: String) {
        NSLog(" ---> Govee: API error: \(error)")

        if error == "Invalid API key" {
            TTModeGovee.goveeState = .disconnected
        } else {
            TTModeGovee.goveeState = .connected
        }

        delegate?.changeState(TTModeGovee.goveeState, mode: self)
        delegate?.fetchStatusUpdate("Error: \(error)")
    }

    func apiClientDidControlDevice(success: Bool, error: String?) {
        if let error = error {
            NSLog(" ---> Govee: Control failed: \(error)")
        } else {
            NSLog(" ---> Govee: Control succeeded")
        }
    }

    func apiClientDidFetchDeviceState(_ device: GoveeDevice, powerState: GoveeDeviceState?, brightness: Int?) {
        if let powerState = powerState {
            device.deviceState = powerState
            // Toggle: flip the state
            let turnOn = (powerState == .off)
            TTModeGovee.apiClient.controlDevice(device, turnOn: turnOn)
            device.deviceState = turnOn ? .on : .off
        }
        if let brightness = brightness {
            device.brightness = brightness
        }
    }
}
