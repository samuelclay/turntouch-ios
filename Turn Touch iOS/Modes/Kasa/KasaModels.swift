//
//  KasaModels.swift
//  Turn Touch iOS
//
//  Created by Samuel Clay on 12/30/25.
//  Copyright © 2025 Turn Touch. All rights reserved.
//

import Foundation

// MARK: - Protocol Types

enum KasaProtocolType: String, Codable {
    case legacy     // Port 9999, XOR encryption
    case klap       // Port 20002/80, AES encryption
}

enum KasaDeviceState {
    case on
    case off
}

// MARK: - Device Info Response

struct KasaSystemResponse: Codable {
    let system: KasaSystemInfo
}

struct KasaSystemInfo: Codable {
    let getSysinfo: KasaSysinfo?
    let setRelayState: KasaRelayStateResponse?

    enum CodingKeys: String, CodingKey {
        case getSysinfo = "get_sysinfo"
        case setRelayState = "set_relay_state"
    }
}

struct KasaSysinfo: Codable {
    let alias: String?
    let model: String?
    let mac: String?
    let deviceId: String?
    let hwId: String?
    let fwId: String?
    let oemId: String?
    let relayState: Int?
    let errCode: Int?
    let feature: String?
    let type: String?
    let swVer: String?
    let hwVer: String?

    enum CodingKeys: String, CodingKey {
        case alias
        case model
        case mac
        case deviceId
        case hwId = "hw_id"
        case fwId = "fw_id"
        case oemId = "oem_id"
        case relayState = "relay_state"
        case errCode = "err_code"
        case feature
        case type
        case swVer = "sw_ver"
        case hwVer = "hw_ver"
    }
}

struct KasaRelayStateResponse: Codable {
    let errCode: Int?

    enum CodingKeys: String, CodingKey {
        case errCode = "err_code"
    }
}

// MARK: - Discovery Response (for KLAP devices on port 20002)

struct KasaDiscoveryResponse: Codable {
    let result: KasaDiscoveryResult?
    let errorCode: Int?

    enum CodingKeys: String, CodingKey {
        case result
        case errorCode = "error_code"
    }
}

struct KasaDiscoveryResult: Codable {
    let deviceId: String?
    let owner: String?
    let deviceType: String?
    let deviceModel: String?
    let ip: String?
    let mac: String?
    let isSuportIot: Bool?
    let obdSrc: String?
    let factoryDefault: Bool?
    let mgtEncryptSchm: KasaEncryptionScheme?

    enum CodingKeys: String, CodingKey {
        case deviceId = "device_id"
        case owner
        case deviceType = "device_type"
        case deviceModel = "device_model"
        case ip
        case mac
        case isSuportIot = "is_suport_iot"
        case obdSrc = "obd_src"
        case factoryDefault = "factory_default"
        case mgtEncryptSchm = "mgt_encrypt_schm"
    }
}

struct KasaEncryptionScheme: Codable {
    let isSuportHttps: Bool?
    let encryptType: String?
    let httpPort: Int?
    let lv: Int?

    enum CodingKeys: String, CodingKey {
        case isSuportHttps = "is_suport_https"
        case encryptType = "encrypt_type"
        case httpPort = "http_port"
        case lv
    }
}

// MARK: - KLAP Encrypted Request/Response

struct KasaKLAPRequest: Codable {
    let method: String
    let params: [String: Any]?
    let requestTimeMils: Int64?
    let terminalUUID: String?

    enum CodingKeys: String, CodingKey {
        case method
        case params
        case requestTimeMils
        case terminalUUID
    }

    // Custom encoding since params is [String: Any]
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(method, forKey: .method)
        try container.encodeIfPresent(requestTimeMils, forKey: .requestTimeMils)
        try container.encodeIfPresent(terminalUUID, forKey: .terminalUUID)
        // Skip params for now - will encode manually
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        method = try container.decode(String.self, forKey: .method)
        requestTimeMils = try container.decodeIfPresent(Int64.self, forKey: .requestTimeMils)
        terminalUUID = try container.decodeIfPresent(String.self, forKey: .terminalUUID)
        params = nil
    }

    init(method: String, params: [String: Any]? = nil, requestTimeMils: Int64? = nil, terminalUUID: String? = nil) {
        self.method = method
        self.params = params
        self.requestTimeMils = requestTimeMils
        self.terminalUUID = terminalUUID
    }
}

// MARK: - KLAP Commands

struct KasaKLAPDeviceInfoRequest: Codable {
    let method = "get_device_info"
}

struct KasaKLAPDeviceInfoResponse: Codable {
    let errorCode: Int?
    let result: KasaKLAPDeviceInfo?

    enum CodingKeys: String, CodingKey {
        case errorCode = "error_code"
        case result
    }
}

struct KasaKLAPDeviceInfo: Codable {
    let deviceId: String?
    let fwVer: String?
    let hwVer: String?
    let type: String?
    let model: String?
    let mac: String?
    let hwId: String?
    let fwId: String?
    let oemId: String?
    let ip: String?
    let timeDiff: Int?
    let ssid: String?
    let rssi: Int?
    let signalLevel: Int?
    let latitude: Int?
    let longitude: Int?
    let lang: String?
    let avatar: String?
    let region: String?
    let specs: String?
    let nickname: String?
    let hasSetLocationInfo: Bool?
    let deviceOn: Bool?
    let onTime: Int?
    let defaultStates: KasaDefaultStates?
    let overheated: Bool?

    enum CodingKeys: String, CodingKey {
        case deviceId = "device_id"
        case fwVer = "fw_ver"
        case hwVer = "hw_ver"
        case type
        case model
        case mac
        case hwId = "hw_id"
        case fwId = "fw_id"
        case oemId = "oem_id"
        case ip
        case timeDiff = "time_diff"
        case ssid
        case rssi
        case signalLevel = "signal_level"
        case latitude
        case longitude
        case lang
        case avatar
        case region
        case specs
        case nickname
        case hasSetLocationInfo = "has_set_location_info"
        case deviceOn = "device_on"
        case onTime = "on_time"
        case defaultStates = "default_states"
        case overheated
    }
}

struct KasaDefaultStates: Codable {
    let type: String?
    let state: KasaDeviceOnOffState?
}

struct KasaDeviceOnOffState: Codable {
    let on: Bool?
}

// MARK: - Constants

struct KasaConstants {
    static let kKasaSelectedSerials = "kasaSelectedSerials"
    static let kKasaFoundDevices = "kasaFoundDevicesV1"
    static let kKasaSeenDevices = "kasaSeenDevicesV1"
    static let kKasaUsername = "kasaUsername"
    static let kKasaPassword = "kasaPassword"

    // Ports
    static let legacyPort: UInt16 = 9999
    static let klapDiscoveryPort: UInt16 = 20002
    static let klapHttpPort: UInt16 = 80

    // XOR encryption key
    static let xorInitialKey: UInt8 = 171
}
