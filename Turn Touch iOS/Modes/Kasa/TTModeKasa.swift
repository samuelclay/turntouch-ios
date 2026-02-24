//
//  TTModeKasa.swift
//  Turn Touch iOS
//
//  Created by Samuel Clay on 12/30/25.
//  Copyright © 2025 Turn Touch. All rights reserved.
//

import Foundation
import Security

enum TTKasaState {
    case disconnected
    case connecting
    case connected
}

protocol TTModeKasaDelegate {
    func changeState(_ state: TTKasaState, mode: TTModeKasa)
    func discoveryStatusUpdate(_ status: String)
}

class TTModeKasa: TTMode, TTModeKasaDiscoveryDelegate, TTModeKasaDeviceDelegate {

    var delegate: TTModeKasaDelegate?

    static var kasaState = TTKasaState.disconnected
    static var discovery = TTModeKasaDiscovery()
    static var foundDevices: [TTModeKasaDevice] = []
    static var failedDevices: [TTModeKasaDevice] = []
    static var recentlyFoundDevices: [TTModeKasaDevice] = []

    // Keychain keys
    private static let keychainService = "com.turntouch.ios.kasa"

    // MARK: - Initialization

    required init() {
        super.init()

        NSLog(" ---> Kasa: INIT CALLED")

        TTModeKasa.discovery.delegate = self

        if TTModeKasa.foundDevices.isEmpty {
            NSLog(" ---> Kasa: foundDevices is empty, assembling...")
            assembleFoundDevices()
        }

        NSLog(" ---> Kasa: After assemble, foundDevices count = \(TTModeKasa.foundDevices.count)")

        if TTModeKasa.foundDevices.isEmpty {
            NSLog(" ---> Kasa: Still empty, starting discovery")
            TTModeKasa.kasaState = .connecting
            beginConnectingToKasa()
        } else {
            NSLog(" ---> Kasa: Have devices, setting connected")
            TTModeKasa.kasaState = .connected
            // Apply credentials to KLAP devices
            applyCredentialsToDevices()
        }

        delegate?.changeState(TTModeKasa.kasaState, mode: self)
    }

    // MARK: - Mode Info

    override class func title() -> String {
        return "TP-Link Kasa"
    }

    override class func subtitle() -> String {
        let count = foundDevices.count
        if count == 0 {
            return "Smart plugs and switches"
        } else if count == 1 {
            return "1 device"
        } else {
            return "\(count) devices"
        }
    }

    override class func imageName() -> String {
        return "mode_wemo.png" // Reuse Wemo icon for now
    }

    // MARK: - Actions

    override class func actions() -> [String] {
        return [
            "TTModeKasaDeviceOn",
            "TTModeKasaDeviceOff",
            "TTModeKasaDeviceToggle"
        ]
    }

    // MARK: - Action Titles

    func titleTTModeKasaDeviceOn() -> String {
        return "Turn on"
    }

    func titleTTModeKasaDeviceOff() -> String {
        return "Turn off"
    }

    func titleTTModeKasaDeviceToggle() -> String {
        return "Toggle device"
    }

    // MARK: - Action Images

    func imageTTModeKasaDeviceOn() -> String {
        return "electrical_connected"
    }

    func imageTTModeKasaDeviceOff() -> String {
        return "electrical_disconnected"
    }

    func imageTTModeKasaDeviceToggle() -> String {
        return "electrical"
    }

    // MARK: - Defaults

    override func defaultNorth() -> String {
        return "TTModeKasaDeviceOn"
    }

    override func defaultEast() -> String {
        return "TTModeKasaDeviceToggle"
    }

    override func defaultWest() -> String {
        return "TTModeKasaDeviceToggle"
    }

    override func defaultSouth() -> String {
        return "TTModeKasaDeviceOff"
    }

    // MARK: - Activation

    override func activate() {
        delegate?.changeState(TTModeKasa.kasaState, mode: self)
    }

    override func deactivate() {
        TTModeKasa.discovery.deactivate()
    }

    // MARK: - Action Methods

    func runTTModeKasaDeviceOn(direction: NSNumber) {
        let devices = selectedDevices(TTModeDirection(rawValue: direction.intValue)!)
        for device in devices {
            device.changeDeviceState(.on)
        }
    }

    func runTTModeKasaDeviceOff(direction: NSNumber) {
        let devices = selectedDevices(TTModeDirection(rawValue: direction.intValue)!)
        for device in devices {
            device.changeDeviceState(.off)
        }
    }

    func runTTModeKasaDeviceToggle(direction: NSNumber) {
        let devices = selectedDevices(TTModeDirection(rawValue: direction.intValue)!)
        for device in devices {
            device.requestDeviceState {
                if device.deviceState == .on {
                    device.changeDeviceState(.off)
                } else {
                    device.changeDeviceState(.on)
                }
            }
        }
    }

    // MARK: - Device Selection

    func selectedDevices(_ direction: TTModeDirection) -> [TTModeKasaDevice] {
        ensureDevicesSelected()
        var devices: [TTModeKasaDevice] = []

        if TTModeKasa.foundDevices.isEmpty {
            return devices
        }

        if let selectedIds = action.optionValue(KasaConstants.kKasaSelectedSerials) as? [String] {
            for foundDevice in TTModeKasa.foundDevices {
                if let deviceId = foundDevice.deviceId, selectedIds.contains(deviceId) {
                    devices.append(foundDevice)
                } else if let mac = foundDevice.macAddress, selectedIds.contains(mac) {
                    devices.append(foundDevice)
                }
            }
        }

        return devices
    }

    func ensureDevicesSelected() {
        if TTModeKasa.foundDevices.isEmpty {
            return
        }

        let selectedIds = action.optionValue(KasaConstants.kKasaSelectedSerials) as? [String]
        if let selectedIds = selectedIds, !selectedIds.isEmpty {
            return
        }

        // Nothing selected, select all devices
        let ids = TTModeKasa.foundDevices.compactMap { device -> String? in
            return device.deviceId ?? device.macAddress
        }
        action.changeActionOption(KasaConstants.kKasaSelectedSerials, to: ids)
    }

    // MARK: - Connection

    func refreshDevices() {
        TTModeKasa.recentlyFoundDevices = []
        beginConnectingToKasa()
    }

    func beginConnectingToKasa() {
        NSLog(" ---> Kasa: beginConnectingToKasa CALLED, delegate = \(String(describing: delegate))")
        TTModeKasa.kasaState = .connecting

        // Ensure UI update happens on main thread
        DispatchQueue.main.async {
            self.delegate?.changeState(TTModeKasa.kasaState, mode: self)
        }

        TTModeKasa.discovery.delegate = self
        TTModeKasa.discovery.beginDiscovery()
    }

    func cancelConnectingToKasa() {
        TTModeKasa.kasaState = .connected

        DispatchQueue.main.async {
            self.delegate?.changeState(TTModeKasa.kasaState, mode: self)
        }

        TTModeKasa.discovery.stopDiscovery()
    }

    func resetKnownDevices() {
        let prefs = UserDefaults.standard
        prefs.removeObject(forKey: KasaConstants.kKasaFoundDevices)
        prefs.synchronize()

        TTModeKasa.foundDevices = []
        assembleFoundDevices()
    }

    // MARK: - Device Persistence

    func assembleFoundDevices() {
        let prefs = UserDefaults.standard
        TTModeKasa.foundDevices = []

        if let savedDevices = prefs.array(forKey: KasaConstants.kKasaFoundDevices) as? [[String: Any]] {
            for deviceDict in savedDevices {
                if let device = TTModeKasaDevice.fromDictionary(deviceDict) {
                    device.delegate = self
                    TTModeKasa.foundDevices.append(device)
                    print(" ---> Kasa: Loaded device: \(device)")
                }
            }
        }

        applyCredentialsToDevices()
    }

    func storeFoundDevices() {
        TTModeKasa.foundDevices.sort { (a, b) -> Bool in
            return (a.deviceName?.lowercased() ?? "") < (b.deviceName?.lowercased() ?? "")
        }

        var savedDevices: [[String: Any]] = []
        var savedIds: Set<String> = []

        for device in TTModeKasa.foundDevices {
            guard device.deviceName != nil else { continue }

            let id = device.deviceId ?? device.macAddress ?? device.location()
            guard !savedIds.contains(id) else { continue }
            savedIds.insert(id)

            // Remove from failed list if it's now working
            TTModeKasa.failedDevices.removeAll { $0.isSameDeviceDifferentLocation(device) }

            savedDevices.append(device.toDictionary())
        }

        let prefs = UserDefaults.standard
        prefs.set(savedDevices, forKey: KasaConstants.kKasaFoundDevices)
        prefs.synchronize()
    }

    // MARK: - Credentials

    static func saveCredentials(username: String, password: String) {
        saveToKeychain(key: "username", value: username)
        saveToKeychain(key: "password", value: password)
    }

    static func loadCredentials() -> (username: String, password: String)? {
        guard let username = loadFromKeychain(key: "username"),
              let password = loadFromKeychain(key: "password") else {
            return nil
        }
        return (username, password)
    }

    static func hasCredentials() -> Bool {
        return loadCredentials() != nil
    }

    static func clearCredentials() {
        deleteFromKeychain(key: "username")
        deleteFromKeychain(key: "password")
    }

    private func applyCredentialsToDevices() {
        guard let creds = TTModeKasa.loadCredentials() else { return }

        for device in TTModeKasa.foundDevices where device.protocolType == .klap {
            device.setCredentials(username: creds.username, password: creds.password)
        }
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

    // MARK: - Discovery Delegate

    func discoveryFoundDevice(ipAddress: String, port: UInt16, protocolType: KasaProtocolType,
                              name: String?, deviceId: String?, macAddress: String?) -> TTModeKasaDevice {
        let device = TTModeKasaDevice(ipAddress: ipAddress, port: port, protocolType: protocolType)
        device.delegate = self
        device.deviceName = name
        device.deviceId = deviceId
        device.macAddress = macAddress

        // Check for duplicates
        for existingDevice in TTModeKasa.foundDevices {
            if existingDevice.isEqualToDevice(device) {
                // Update IP if changed
                if existingDevice.isSameDeviceDifferentLocation(device) {
                    print(" ---> Kasa: Device moved from \(existingDevice.location()) to \(device.location())")
                    existingDevice.ipAddress = device.ipAddress
                    existingDevice.port = device.port
                }
                return existingDevice
            }
        }

        for existingDevice in TTModeKasa.recentlyFoundDevices {
            if existingDevice.isEqualToDevice(device) {
                return existingDevice
            }
        }

        TTModeKasa.recentlyFoundDevices.append(device)

        // Apply credentials if KLAP
        if protocolType == .klap, let creds = TTModeKasa.loadCredentials() {
            device.setCredentials(username: creds.username, password: creds.password)
        }

        // Request full device info
        device.requestDeviceInfo()

        return device
    }

    func discoveryFinishedScanning() {
        TTModeKasa.kasaState = .connected
        delegate?.changeState(TTModeKasa.kasaState, mode: self)
    }

    func discoveryStatusUpdate(_ status: String) {
        DispatchQueue.main.async {
            self.delegate?.discoveryStatusUpdate(status)
        }
    }

    // MARK: - Device Delegate

    func deviceReady(_ device: TTModeKasaDevice) {
        var replaceDevice: TTModeKasaDevice?

        for foundDevice in TTModeKasa.foundDevices {
            if foundDevice.isSameAddress(device) {
                return
            } else if foundDevice.isEqualToDevice(device) && foundDevice.isSameDeviceDifferentLocation(device) {
                replaceDevice = foundDevice
                break
            }
        }

        if let oldDevice = replaceDevice {
            print(" ---> Kasa: Re-assigning device from \(oldDevice.location()) to \(device.location())")
            oldDevice.ipAddress = device.ipAddress
            oldDevice.port = device.port
        } else {
            TTModeKasa.foundDevices.append(device)
        }

        storeFoundDevices()

        TTModeKasa.kasaState = .connected
        delegate?.changeState(TTModeKasa.kasaState, mode: self)
    }

    func deviceFailed(_ device: TTModeKasaDevice) {
        print(" ---> Kasa: Device failed, searching for new IP...")

        if !TTModeKasa.failedDevices.contains(where: { $0.isEqualToDevice(device) }) {
            TTModeKasa.failedDevices.append(device)

            DispatchQueue.main.async {
                appDelegate().modeMap.recordUsageMoment("kasaDeviceFailed")
                self.refreshDevices()
            }
        }
    }

    func deviceNeedsAuthentication(_ device: TTModeKasaDevice) {
        print(" ---> Kasa: Device needs authentication")
        delegate?.changeState(TTModeKasa.kasaState, mode: self)
    }
}
