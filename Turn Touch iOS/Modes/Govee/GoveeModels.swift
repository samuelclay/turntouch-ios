//
//  GoveeModels.swift
//  Turn Touch iOS
//
//  Created by Samuel Clay on 2/20/26.
//  Copyright © 2026 Turn Touch. All rights reserved.
//

import Foundation

// MARK: - Device State

enum GoveeDeviceState {
    case on
    case off
}

// MARK: - API Responses

struct GoveeDeviceListResponse: Codable {
    let code: Int?
    let message: String?
    let data: [GoveeDeviceData]?
}

struct GoveeDeviceData: Codable {
    let sku: String?
    let device: String?
    let deviceName: String?
    let type: String?
    let capabilities: [GoveeCapability]?
}

struct GoveeCapability: Codable {
    let type: String?
    let instance: String?
    let parameters: GoveeCapabilityParameters?
}

struct GoveeCapabilityParameters: Codable {
    let dataType: String?
    let options: [GoveeCapabilityOption]?
    let range: GoveeCapabilityRange?

    enum CodingKeys: String, CodingKey {
        case dataType
        case options
        case range
    }
}

struct GoveeCapabilityOption: Codable {
    let name: String?
    let value: Int?
}

struct GoveeCapabilityRange: Codable {
    let min: Int?
    let max: Int?
    let precision: Int?
}

// MARK: - Control Request

struct GoveeControlRequest: Codable {
    let requestId: String
    let payload: GoveeControlPayload
}

struct GoveeControlPayload: Codable {
    let sku: String
    let device: String
    let capability: GoveeControlCapability
}

struct GoveeControlCapability: Codable {
    let type: String
    let instance: String
    let value: Int
}

// MARK: - Device State Request

struct GoveeDeviceStateRequest: Codable {
    let requestId: String
    let payload: GoveeDeviceStatePayload
}

struct GoveeDeviceStatePayload: Codable {
    let sku: String
    let device: String
}

// MARK: - Device State Response

struct GoveeDeviceStateResponse: Codable {
    let code: Int?
    let message: String?
    let payload: GoveeDeviceStateResponsePayload?
}

struct GoveeDeviceStateResponsePayload: Codable {
    let sku: String?
    let device: String?
    let capabilities: [GoveeStateCapability]?
}

struct GoveeStateCapability: Codable {
    let type: String?
    let instance: String?
    let state: GoveeStateValue?
}

struct GoveeStateValue: Codable {
    let value: GoveeStateValueType?
}

enum GoveeStateValueType: Codable {
    case int(Int)
    case string(String)
    case bool(Bool)

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let intVal = try? container.decode(Int.self) {
            self = .int(intVal)
        } else if let strVal = try? container.decode(String.self) {
            self = .string(strVal)
        } else if let boolVal = try? container.decode(Bool.self) {
            self = .bool(boolVal)
        } else {
            self = .int(0)
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .int(let val):
            try container.encode(val)
        case .string(let val):
            try container.encode(val)
        case .bool(let val):
            try container.encode(val)
        }
    }

    var intValue: Int? {
        switch self {
        case .int(let val): return val
        case .bool(let val): return val ? 1 : 0
        case .string(_): return nil
        }
    }
}

// MARK: - Control Response

struct GoveeControlResponse: Codable {
    let code: Int?
    let message: String?
}

// MARK: - Local Device Model

class GoveeDevice: NSObject {
    var deviceId: String
    var sku: String
    var deviceName: String
    var deviceState: GoveeDeviceState = .off
    var brightness: Int = 100
    var capabilities: [GoveeCapability] = []

    init(deviceId: String, sku: String, deviceName: String) {
        self.deviceId = deviceId
        self.sku = sku
        self.deviceName = deviceName
        super.init()
    }

    var supportsBrightness: Bool {
        return capabilities.contains { $0.type == "devices.capabilities.range" && $0.instance == "brightness" }
    }

    var supportsOnOff: Bool {
        return capabilities.contains { $0.type == "devices.capabilities.on_off" && $0.instance == "powerSwitch" }
    }

    func toDictionary() -> [String: Any] {
        return [
            "deviceId": deviceId,
            "sku": sku,
            "deviceName": deviceName
        ]
    }

    static func fromDictionary(_ dict: [String: Any]) -> GoveeDevice? {
        guard let deviceId = dict["deviceId"] as? String,
              let sku = dict["sku"] as? String,
              let deviceName = dict["deviceName"] as? String else {
            return nil
        }
        return GoveeDevice(deviceId: deviceId, sku: sku, deviceName: deviceName)
    }
}

// MARK: - Constants

struct GoveeConstants {
    static let kGoveeFoundDevices = "goveeFoundDevicesV1"
    static let kGoveeSelectedDevices = "goveeSelectedDevices"
    static let baseURL = "https://openapi.api.govee.com"
    static let devicesEndpoint = "/router/api/v1/user/devices"
    static let controlEndpoint = "/router/api/v1/device/control"
    static let stateEndpoint = "/router/api/v1/device/state"
    static let brightnessStep = 25
}
