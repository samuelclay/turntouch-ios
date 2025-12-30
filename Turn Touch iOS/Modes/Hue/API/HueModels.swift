//
//  HueModels.swift
//  Turn Touch iOS
//
//  Codable data models for Hue CLIP API v2
//

import Foundation
import CoreGraphics

// MARK: - Bridge Discovery

/// Represents a discovered Hue bridge from discovery.meethue.com
struct DiscoveredBridge: Codable {
    let id: String
    let internalipaddress: String
    let port: Int?

    /// Display-friendly name (derived from id or IP)
    var friendlyName: String? {
        return "Hue Bridge \(id.prefix(4))"
    }

    /// Model name for display
    var modelName: String {
        return "Philips Hue Bridge"
    }
}

// MARK: - Connection Configuration

struct HueBridgeAccessConfig {
    let bridgeIP: String
    let bridgeId: String
    let applicationKey: String  // "username" in v1

    var baseURL: URL {
        URL(string: "https://\(bridgeIP)/clip/v2/resource")!
    }
}

// MARK: - API Response Wrapper

struct HueAPIResponse<T: Codable>: Codable {
    let data: [T]
    let errors: [HueAPIError]?
}

struct HueAPIError: Codable, Error {
    let description: String
}

// MARK: - Authentication Response

struct HueAuthResponse: Codable {
    let success: HueAuthSuccess?
    let error: HueAuthError?
}

struct HueAuthSuccess: Codable {
    let username: String
    let clientkey: String?
}

struct HueAuthError: Codable {
    let type: Int
    let address: String
    let description: String
}

// MARK: - Resource Link (API v2 uses references between resources)

struct HueResourceLink: Codable, Hashable {
    let rid: String             // Resource ID (UUID)
    let rtype: String           // Resource type ("light", "room", "device", etc.)
}

// MARK: - Light

struct HueLight: Codable, Identifiable {
    let id: String              // UUID
    let idV1: String?           // Legacy v1 ID (e.g., "/lights/1")
    let owner: HueResourceLink?
    let metadata: HueLightMetadata?
    let on: HueOnState?
    let dimming: HueDimming?
    let colorTemperature: HueColorTemperature?
    let color: HueColor?
    let dynamics: HueDynamics?
    let effects: HueEffects?
    let mode: String?
    let type: String?

    enum CodingKeys: String, CodingKey {
        case id
        case idV1 = "id_v1"
        case owner, metadata, on, dimming
        case colorTemperature = "color_temperature"
        case color, dynamics, effects, mode, type
    }
}

struct HueLightMetadata: Codable {
    let name: String
    let archetype: String?
    let fixedMired: Int?

    enum CodingKeys: String, CodingKey {
        case name, archetype
        case fixedMired = "fixed_mired"
    }
}

struct HueOnState: Codable {
    let on: Bool
}

struct HueDimming: Codable {
    let brightness: Double      // 0.0-100.0 (not 0-254!)
    let minDimLevel: Double?

    enum CodingKeys: String, CodingKey {
        case brightness
        case minDimLevel = "min_dim_level"
    }
}

struct HueColorTemperature: Codable {
    let mirek: Int?
    let mirekValid: Bool?
    let mirekSchema: HueMirekSchema?

    enum CodingKeys: String, CodingKey {
        case mirek
        case mirekValid = "mirek_valid"
        case mirekSchema = "mirek_schema"
    }
}

struct HueMirekSchema: Codable {
    let mirekMinimum: Int
    let mirekMaximum: Int

    enum CodingKeys: String, CodingKey {
        case mirekMinimum = "mirek_minimum"
        case mirekMaximum = "mirek_maximum"
    }
}

struct HueColor: Codable {
    let xy: HueXY?
    let gamut: HueGamut?
    let gamutType: String?

    enum CodingKeys: String, CodingKey {
        case xy, gamut
        case gamutType = "gamut_type"
    }
}

struct HueXY: Codable {
    let x: Double
    let y: Double

    var cgPoint: CGPoint {
        CGPoint(x: x, y: y)
    }

    init(x: Double, y: Double) {
        self.x = x
        self.y = y
    }

    init(point: CGPoint) {
        self.x = Double(point.x)
        self.y = Double(point.y)
    }
}

struct HueGamut: Codable {
    let red: HueXY
    let green: HueXY
    let blue: HueXY
}

struct HueDynamics: Codable {
    let duration: Int?          // Transition time in milliseconds
    let speed: Double?
    let speedValid: Bool?
    let status: String?
    let statusValues: [String]?

    enum CodingKeys: String, CodingKey {
        case duration, speed
        case speedValid = "speed_valid"
        case status
        case statusValues = "status_values"
    }
}

struct HueEffects: Codable {
    let effect: String?         // "no_effect", "color_loop", etc.
    let effectValues: [String]?
    let status: String?
    let statusValues: [String]?

    enum CodingKeys: String, CodingKey {
        case effect
        case effectValues = "effect_values"
        case status
        case statusValues = "status_values"
    }
}

// MARK: - Room

struct HueRoom: Codable, Identifiable {
    let id: String              // UUID
    let idV1: String?           // Legacy v1 ID (e.g., "/groups/1")
    let metadata: HueRoomMetadata
    let children: [HueResourceLink]  // Links to devices/lights
    let services: [HueResourceLink]?  // Links to grouped_light, etc.
    let type: String?

    enum CodingKeys: String, CodingKey {
        case id
        case idV1 = "id_v1"
        case metadata, children, services, type
    }

    // Helper to get grouped_light service ID for controlling all lights in room
    var groupedLightId: String? {
        services?.first { $0.rtype == "grouped_light" }?.rid
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        idV1 = try container.decodeIfPresent(String.self, forKey: .idV1)
        metadata = try container.decodeIfPresent(HueRoomMetadata.self, forKey: .metadata) ?? HueRoomMetadata(name: "Room", archetype: nil)
        children = try container.decodeIfPresent([HueResourceLink].self, forKey: .children) ?? []
        services = try container.decodeIfPresent([HueResourceLink].self, forKey: .services)
        type = try container.decodeIfPresent(String.self, forKey: .type)
    }
}

struct HueRoomMetadata: Codable {
    let name: String
    let archetype: String?
}

// MARK: - Grouped Light (for controlling all lights in a room)

struct HueGroupedLight: Codable, Identifiable {
    let id: String
    let idV1: String?
    let owner: HueResourceLink?
    let on: HueOnState?
    let dimming: HueDimming?
    let alert: HueAlert?
    let type: String?

    enum CodingKeys: String, CodingKey {
        case id
        case idV1 = "id_v1"
        case owner, on, dimming, alert, type
    }
}

struct HueAlert: Codable {
    let actionValues: [String]?

    enum CodingKeys: String, CodingKey {
        case actionValues = "action_values"
    }
}

// MARK: - Scene

struct HueScene: Codable, Identifiable {
    let id: String              // UUID
    let idV1: String?           // Legacy v1 ID
    let metadata: HueSceneMetadata
    let group: HueResourceLink  // Room this scene belongs to
    let actions: [HueSceneAction]?
    let palette: HueScenePalette?
    let speed: Double?
    let autoDynamic: Bool?
    let status: HueSceneStatus?
    let type: String?

    enum CodingKeys: String, CodingKey {
        case id
        case idV1 = "id_v1"
        case metadata, group, actions, palette, speed
        case autoDynamic = "auto_dynamic"
        case status, type
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        idV1 = try container.decodeIfPresent(String.self, forKey: .idV1)
        metadata = try container.decodeIfPresent(HueSceneMetadata.self, forKey: .metadata) ?? HueSceneMetadata(name: "Scene", image: nil, appdata: nil)
        group = try container.decodeIfPresent(HueResourceLink.self, forKey: .group) ?? HueResourceLink(rid: "", rtype: "room")
        actions = try container.decodeIfPresent([HueSceneAction].self, forKey: .actions)
        palette = try container.decodeIfPresent(HueScenePalette.self, forKey: .palette)
        speed = try container.decodeIfPresent(Double.self, forKey: .speed)
        autoDynamic = try container.decodeIfPresent(Bool.self, forKey: .autoDynamic)
        status = try container.decodeIfPresent(HueSceneStatus.self, forKey: .status)
        type = try container.decodeIfPresent(String.self, forKey: .type)
    }
}

struct HueSceneMetadata: Codable {
    let name: String
    let image: HueResourceLink?
    let appdata: String?
}

struct HueSceneAction: Codable {
    let target: HueResourceLink
    let action: HueSceneActionState
}

struct HueSceneActionState: Codable {
    let on: HueOnState?
    let dimming: HueDimming?
    let color: HueColor?
    let colorTemperature: HueColorTemperature?
    let effects: HueEffects?
    let dynamics: HueDynamics?

    enum CodingKeys: String, CodingKey {
        case on, dimming, color
        case colorTemperature = "color_temperature"
        case effects, dynamics
    }
}

struct HueScenePalette: Codable {
    let color: [HueScenePaletteColor]?
    let dimming: [HueDimming]?
    let colorTemperature: [HueColorTemperature]?
    let effects: [HueEffects]?

    enum CodingKeys: String, CodingKey {
        case color, dimming
        case colorTemperature = "color_temperature"
        case effects
    }
}

struct HueScenePaletteColor: Codable {
    let color: HueColor
    let dimming: HueDimming?
}

struct HueSceneStatus: Codable {
    let active: String?         // "inactive", "static", "dynamic_palette"
}

// MARK: - Bridge Configuration

struct HueBridge: Codable, Identifiable {
    let id: String
    let idV1: String?
    let bridgeId: String?
    let owner: HueResourceLink?
    let timeZone: HueTimeZone?
    let type: String?

    enum CodingKeys: String, CodingKey {
        case id
        case idV1 = "id_v1"
        case bridgeId = "bridge_id"
        case owner
        case timeZone = "time_zone"
        case type
    }
}

struct HueTimeZone: Codable {
    let timeZone: String?

    enum CodingKeys: String, CodingKey {
        case timeZone = "time_zone"
    }
}

// MARK: - Device (for getting light model info)

struct HueDevice: Codable, Identifiable {
    let id: String
    let idV1: String?
    let productData: HueProductData?
    let metadata: HueDeviceMetadata?
    let services: [HueResourceLink]?
    let type: String?

    enum CodingKeys: String, CodingKey {
        case id
        case idV1 = "id_v1"
        case productData = "product_data"
        case metadata, services, type
    }

    // Helper to get light service ID
    var lightId: String? {
        services?.first { $0.rtype == "light" }?.rid
    }
}

struct HueProductData: Codable {
    let modelId: String?
    let manufacturerName: String?
    let productName: String?
    let productArchetype: String?
    let certified: Bool?
    let softwareVersion: String?
    let hardwarePlatformType: String?

    enum CodingKeys: String, CodingKey {
        case modelId = "model_id"
        case manufacturerName = "manufacturer_name"
        case productName = "product_name"
        case productArchetype = "product_archetype"
        case certified
        case softwareVersion = "software_version"
        case hardwarePlatformType = "hardware_platform_type"
    }
}

struct HueDeviceMetadata: Codable {
    let name: String
    let archetype: String?
}

// MARK: - Resource Cache

class HueResourceCache {
    var lights: [String: HueLight] = [:]
    var rooms: [String: HueRoom] = [:]
    var groupedLights: [String: HueGroupedLight] = [:]
    var scenes: [String: HueScene] = [:]
    var devices: [String: HueDevice] = [:]
    var bridge: HueBridge?

    func clear() {
        lights.removeAll()
        rooms.removeAll()
        groupedLights.removeAll()
        scenes.removeAll()
        devices.removeAll()
        bridge = nil
    }

    // Get model ID for a light (needed for color gamut calculation)
    func modelId(forLightId lightId: String) -> String? {
        // Find the device that owns this light
        for device in devices.values {
            if device.lightId == lightId {
                return device.productData?.modelId
            }
        }
        return nil
    }
}

// MARK: - Request Bodies for PUT/POST

struct HueLightStateUpdate: Codable {
    var on: HueOnState?
    var dimming: HueDimmingUpdate?
    var color: HueColorUpdate?
    var colorTemperature: HueColorTemperatureUpdate?
    var dynamics: HueDynamicsUpdate?
    var effects: HueEffectsUpdate?

    enum CodingKeys: String, CodingKey {
        case on, dimming, color
        case colorTemperature = "color_temperature"
        case dynamics, effects
    }
}

struct HueDimmingUpdate: Codable {
    let brightness: Double
}

struct HueColorUpdate: Codable {
    let xy: HueXY
}

struct HueColorTemperatureUpdate: Codable {
    let mirek: Int
}

struct HueDynamicsUpdate: Codable {
    let duration: Int           // Transition time in milliseconds
}

struct HueEffectsUpdate: Codable {
    let effect: String          // "no_effect", "color_loop"
}

struct HueSceneRecall: Codable {
    let recall: HueSceneRecallAction
}

struct HueSceneRecallAction: Codable {
    let action: String          // "active"
    let duration: Int?
    let dimming: HueDimmingUpdate?
}

struct HueSceneCreate: Codable {
    let metadata: HueSceneMetadata
    let group: HueResourceLink
    let actions: [HueSceneAction]
    let type: String = "scene"
}

// MARK: - SSE Event Types

struct HueSSEEvent: Codable {
    let creationtime: String?
    let id: String?
    let type: String            // "update", "add", "delete"
    let data: [HueSSEEventData]
}

struct HueSSEEventData: Codable {
    let id: String
    let idV1: String?
    let type: String            // "light", "room", "scene", etc.
    let on: HueOnState?
    let dimming: HueDimming?
    let color: HueColor?
    let colorTemperature: HueColorTemperature?
    let dynamics: HueDynamics?
    let effects: HueEffects?
    let metadata: HueLightMetadata?
    let owner: HueResourceLink?

    enum CodingKeys: String, CodingKey {
        case id
        case idV1 = "id_v1"
        case type, on, dimming, color
        case colorTemperature = "color_temperature"
        case dynamics, effects, metadata, owner
    }
}
