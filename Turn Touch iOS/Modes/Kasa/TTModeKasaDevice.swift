//
//  TTModeKasaDevice.swift
//  Turn Touch iOS
//
//  Created by Samuel Clay on 12/30/25.
//  Copyright © 2025 Turn Touch. All rights reserved.
//

import Foundation

protocol TTModeKasaDeviceDelegate: AnyObject {
    func deviceReady(_ device: TTModeKasaDevice)
    func deviceFailed(_ device: TTModeKasaDevice)
    func deviceNeedsAuthentication(_ device: TTModeKasaDevice)
}

class TTModeKasaDevice: NSObject {

    var deviceName: String?
    var deviceId: String?
    var macAddress: String?
    var ipAddress: String
    var port: UInt16
    var protocolType: KasaProtocolType
    var deviceState: KasaDeviceState = .off
    var needsAuthentication: Bool = false
    var isAuthenticated: Bool = false

    weak var delegate: TTModeKasaDeviceDelegate?

    private var legacyProtocol: TTModeKasaLegacyProtocol?
    private var klapProtocol: TTModeKasaKLAPProtocol?

    // MARK: - Initialization

    init(ipAddress: String, port: UInt16, protocolType: KasaProtocolType) {
        self.ipAddress = ipAddress
        self.port = port
        self.protocolType = protocolType
        super.init()

        setupProtocol()
    }

    private func setupProtocol() {
        switch protocolType {
        case .legacy:
            legacyProtocol = TTModeKasaLegacyProtocol(ipAddress: ipAddress, port: port)
            legacyProtocol?.delegate = self
        case .klap:
            klapProtocol = TTModeKasaKLAPProtocol(ipAddress: ipAddress, port: KasaConstants.klapHttpPort)
            klapProtocol?.delegate = self
            needsAuthentication = true
        }
    }

    // MARK: - Description

    override var description: String {
        let name = deviceName ?? "Unknown"
        let proto = protocolType == .legacy ? "Legacy" : "KLAP"
        return "\(name) (\(location()) - \(proto))"
    }

    func location() -> String {
        return "\(ipAddress):\(port)"
    }

    // MARK: - Comparison

    func isEqualToDevice(_ device: TTModeKasaDevice) -> Bool {
        // Compare by device ID if available, otherwise by MAC
        if let myId = deviceId, let otherId = device.deviceId {
            return myId == otherId
        }
        if let myMac = macAddress, let otherMac = device.macAddress {
            return myMac.lowercased() == otherMac.lowercased()
        }
        return false
    }

    func isSameAddress(_ device: TTModeKasaDevice) -> Bool {
        return ipAddress == device.ipAddress && port == device.port
    }

    func isSameDeviceDifferentLocation(_ device: TTModeKasaDevice) -> Bool {
        return isEqualToDevice(device) && !isSameAddress(device)
    }

    // MARK: - Credentials

    func setCredentials(username: String, password: String) {
        klapProtocol?.setCredentials(username: username, password: password)
    }

    // MARK: - Device Info

    func requestDeviceInfo(attemptsLeft: Int = 5) {
        if attemptsLeft == 0 {
            print(" ---> Kasa Error: Could not get device info for \(location())")
            delegate?.deviceFailed(self)
            return
        }

        switch protocolType {
        case .legacy:
            legacyProtocol?.requestDeviceInfo()
        case .klap:
            klapProtocol?.requestDeviceInfo()
        }
    }

    // MARK: - Device State

    func requestDeviceState(_ callback: @escaping () -> Void) {
        switch protocolType {
        case .legacy:
            legacyProtocol?.requestDeviceState(callback: callback)
        case .klap:
            klapProtocol?.requestDeviceInfo()
            // For KLAP, the device info includes the state
            // The callback will be called when we receive the response
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                callback()
            }
        }
    }

    func changeDeviceState(_ state: KasaDeviceState) {
        print(" ---> Kasa: Changing \(deviceName ?? location()) to \(state == .on ? "ON" : "OFF")")
        switch protocolType {
        case .legacy:
            legacyProtocol?.setRelayState(state)
        case .klap:
            klapProtocol?.setDeviceState(state)
        }
    }

    // MARK: - Serialization

    func toDictionary() -> [String: Any] {
        return [
            "ipaddress": ipAddress,
            "port": port,
            "protocolType": protocolType.rawValue,
            "name": deviceName ?? "",
            "deviceId": deviceId ?? "",
            "macAddress": macAddress ?? ""
        ]
    }

    static func fromDictionary(_ dict: [String: Any]) -> TTModeKasaDevice? {
        guard let ipAddress = dict["ipaddress"] as? String else {
            return nil
        }

        let port: UInt16
        if let portUInt16 = dict["port"] as? UInt16 {
            port = portUInt16
        } else if let portInt = dict["port"] as? Int {
            port = UInt16(portInt)
        } else {
            return nil
        }

        let protocolTypeString = dict["protocolType"] as? String ?? "legacy"
        let protocolType = KasaProtocolType(rawValue: protocolTypeString) ?? .legacy

        let device = TTModeKasaDevice(
            ipAddress: ipAddress,
            port: port,
            protocolType: protocolType
        )
        device.deviceName = dict["name"] as? String
        device.deviceId = dict["deviceId"] as? String
        device.macAddress = dict["macAddress"] as? String

        return device
    }
}

// MARK: - Legacy Protocol Delegate

extension TTModeKasaDevice: TTModeKasaLegacyProtocolDelegate {

    func legacyProtocolDidReceiveDeviceInfo(_ sysinfo: KasaSysinfo) {
        deviceName = sysinfo.alias ?? "Kasa Device"
        deviceId = sysinfo.deviceId
        macAddress = sysinfo.mac

        if let relayState = sysinfo.relayState {
            deviceState = (relayState == 1 || relayState == 8) ? .on : .off
        }

        print(" ---> Kasa Legacy: Device info received for \(self)")
        DispatchQueue.main.async {
            self.delegate?.deviceReady(self)
        }
    }

    func legacyProtocolDidReceiveState(_ state: KasaDeviceState) {
        deviceState = state
    }

    func legacyProtocolDidChangeState(_ success: Bool) {
        if success {
            print(" ---> Kasa Legacy: State changed successfully")
        } else {
            print(" ---> Kasa Legacy: State change failed")
        }
    }

    func legacyProtocolDidFail(_ error: Error?) {
        print(" ---> Kasa Legacy: Protocol failed - \(error?.localizedDescription ?? "unknown error")")
        DispatchQueue.main.async {
            self.delegate?.deviceFailed(self)
        }
    }
}

// MARK: - KLAP Protocol Delegate

extension TTModeKasaDevice: TTModeKasaKLAPProtocolDelegate {

    func klapProtocolDidReceiveDeviceInfo(_ info: KasaKLAPDeviceInfo) {
        deviceName = info.nickname ?? info.model ?? "Kasa Device"
        deviceId = info.deviceId
        macAddress = info.mac

        if let deviceOn = info.deviceOn {
            deviceState = deviceOn ? .on : .off
        }

        isAuthenticated = true
        needsAuthentication = false

        print(" ---> Kasa KLAP: Device info received for \(self)")
        DispatchQueue.main.async {
            self.delegate?.deviceReady(self)
        }
    }

    func klapProtocolDidReceiveState(_ state: KasaDeviceState) {
        deviceState = state
    }

    func klapProtocolDidChangeState(_ success: Bool) {
        if success {
            print(" ---> Kasa KLAP: State changed successfully")
        } else {
            print(" ---> Kasa KLAP: State change failed")
        }
    }

    func klapProtocolDidFail(_ error: Error?) {
        print(" ---> Kasa KLAP: Protocol failed - \(error?.localizedDescription ?? "unknown error")")
        DispatchQueue.main.async {
            self.delegate?.deviceFailed(self)
        }
    }

    func klapProtocolNeedsAuthentication() {
        needsAuthentication = true
        isAuthenticated = false
        print(" ---> Kasa KLAP: Device needs authentication")
        DispatchQueue.main.async {
            self.delegate?.deviceNeedsAuthentication(self)
        }
    }
}
