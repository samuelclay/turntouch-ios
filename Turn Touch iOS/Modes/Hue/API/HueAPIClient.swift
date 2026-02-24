//
//  HueAPIClient.swift
//  Turn Touch iOS
//
//  async/await REST client for Hue CLIP API v2
//

import Foundation

/// Errors that can occur when communicating with the Hue Bridge
enum HueAPIClientError: Error, LocalizedError {
    case invalidURL
    case notAuthenticated
    case networkError(Error)
    case invalidResponse
    case httpError(statusCode: Int, message: String?)
    case decodingError(Error)
    case apiError([HueAPIError])

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid Hue Bridge URL"
        case .notAuthenticated:
            return "Not authenticated with Hue Bridge"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .invalidResponse:
            return "Invalid response from Hue Bridge"
        case .httpError(let statusCode, let message):
            return "HTTP error \(statusCode): \(message ?? "Unknown error")"
        case .decodingError(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        case .apiError(let errors):
            return "API error: \(errors.map { $0.description }.joined(separator: ", "))"
        }
    }
}

/// URLSession delegate that trusts the Hue Bridge's self-signed certificate
class HueURLSessionDelegate: NSObject, URLSessionDelegate {
    func urlSession(
        _ session: URLSession,
        didReceive challenge: URLAuthenticationChallenge,
        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
    ) {
        if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust,
           let serverTrust = challenge.protectionSpace.serverTrust {
            let credential = URLCredential(trust: serverTrust)
            completionHandler(.useCredential, credential)
        } else {
            completionHandler(.performDefaultHandling, nil)
        }
    }
}

/// REST API client for Hue CLIP API v2
actor HueAPIClient {
    let bridgeIP: String
    let applicationKey: String
    private let sessionDelegate = HueURLSessionDelegate()
    private lazy var session: URLSession = {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 60
        return URLSession(configuration: config, delegate: sessionDelegate, delegateQueue: nil)
    }()

    private let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        return decoder
    }()

    private let encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        return encoder
    }()

    /// Base URL for CLIP API v2
    var baseURL: URL {
        URL(string: "https://\(bridgeIP)/clip/v2/resource")!
    }

    init(bridgeIP: String, applicationKey: String) {
        self.bridgeIP = bridgeIP
        self.applicationKey = applicationKey
    }

    // MARK: - Resource Fetching

    /// Fetch all lights
    func fetchLights() async throws -> [HueLight] {
        let response: HueAPIResponse<HueLight> = try await get(path: "/light")
        if let errors = response.errors, !errors.isEmpty {
            throw HueAPIClientError.apiError(errors)
        }
        return response.data
    }

    /// Fetch all rooms
    func fetchRooms() async throws -> [HueRoom] {
        let response: HueAPIResponse<HueRoom> = try await get(path: "/room")
        if let errors = response.errors, !errors.isEmpty {
            throw HueAPIClientError.apiError(errors)
        }
        return response.data
    }

    /// Fetch all grouped lights (for room control)
    func fetchGroupedLights() async throws -> [HueGroupedLight] {
        let response: HueAPIResponse<HueGroupedLight> = try await get(path: "/grouped_light")
        if let errors = response.errors, !errors.isEmpty {
            throw HueAPIClientError.apiError(errors)
        }
        return response.data
    }

    /// Fetch all scenes
    func fetchScenes() async throws -> [HueScene] {
        let response: HueAPIResponse<HueScene> = try await get(path: "/scene")
        if let errors = response.errors, !errors.isEmpty {
            throw HueAPIClientError.apiError(errors)
        }
        return response.data
    }

    /// Fetch all devices (for getting light model info)
    func fetchDevices() async throws -> [HueDevice] {
        let response: HueAPIResponse<HueDevice> = try await get(path: "/device")
        if let errors = response.errors, !errors.isEmpty {
            throw HueAPIClientError.apiError(errors)
        }
        return response.data
    }

    /// Fetch bridge configuration
    func fetchBridge() async throws -> [HueBridge] {
        let response: HueAPIResponse<HueBridge> = try await get(path: "/bridge")
        if let errors = response.errors, !errors.isEmpty {
            throw HueAPIClientError.apiError(errors)
        }
        return response.data
    }

    // MARK: - Light Control

    /// Update a single light's state
    func updateLight(
        _ lightId: String,
        on: Bool? = nil,
        brightness: Double? = nil,
        xy: (x: Double, y: Double)? = nil,
        colorTemperature: Int? = nil,
        transitionMs: Int? = nil,
        effect: String? = nil
    ) async throws {
        var update = HueLightStateUpdate()

        if let on = on {
            update.on = HueOnState(on: on)
        }
        if let brightness = brightness {
            update.dimming = HueDimmingUpdate(brightness: max(0.0, min(100.0, brightness)))
        }
        if let xy = xy {
            update.color = HueColorUpdate(xy: HueXY(x: xy.x, y: xy.y))
        }
        if let mirek = colorTemperature {
            update.colorTemperature = HueColorTemperatureUpdate(mirek: mirek)
        }
        if let duration = transitionMs {
            update.dynamics = HueDynamicsUpdate(duration: duration)
        }
        if let effect = effect {
            update.effects = HueEffectsUpdate(effect: effect)
        }

        try await put(path: "/light/\(lightId)", body: update)
    }

    /// Update a grouped light (all lights in a room)
    func updateGroupedLight(
        _ groupedLightId: String,
        on: Bool? = nil,
        brightness: Double? = nil
    ) async throws {
        var update = HueLightStateUpdate()

        if let on = on {
            update.on = HueOnState(on: on)
        }
        if let brightness = brightness {
            update.dimming = HueDimmingUpdate(brightness: max(0.0, min(100.0, brightness)))
        }

        try await put(path: "/grouped_light/\(groupedLightId)", body: update)
    }

    // MARK: - Scene Control

    /// Recall (activate) a scene
    func recallScene(_ sceneId: String, duration: Int? = nil, brightness: Double? = nil) async throws {
        let action = HueSceneRecallAction(
            action: "active",
            duration: duration,
            dimming: brightness.map { HueDimmingUpdate(brightness: $0) }
        )
        let recall = HueSceneRecall(recall: action)
        try await put(path: "/scene/\(sceneId)", body: recall)
    }

    /// Create a new scene
    func createScene(
        name: String,
        roomId: String,
        actions: [HueSceneAction]
    ) async throws -> String {
        let metadata = HueSceneMetadata(name: name, image: nil, appdata: "TurnTouch")
        let group = HueResourceLink(rid: roomId, rtype: "room")
        let scene = HueSceneCreate(metadata: metadata, group: group, actions: actions)

        let response: HueAPIResponse<HueResourceLink> = try await post(path: "/scene", body: scene)
        if let errors = response.errors, !errors.isEmpty {
            throw HueAPIClientError.apiError(errors)
        }

        guard let createdScene = response.data.first else {
            throw HueAPIClientError.invalidResponse
        }

        return createdScene.rid
    }

    /// Delete a scene
    func deleteScene(_ sceneId: String) async throws {
        try await delete(path: "/scene/\(sceneId)")
    }

    /// Update a scene's actions (light states)
    func updateScene(_ sceneId: String, actions: [HueSceneAction]) async throws {
        struct SceneUpdate: Codable {
            let actions: [HueSceneAction]
        }
        let update = SceneUpdate(actions: actions)
        try await put(path: "/scene/\(sceneId)", body: update)
    }

    // MARK: - HTTP Methods

    private func get<T: Codable>(path: String) async throws -> T {
        let url = baseURL.appendingPathComponent(path)
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(applicationKey, forHTTPHeaderField: "hue-application-key")
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        return try await performRequest(request)
    }

    private func put<Body: Encodable>(path: String, body: Body) async throws {
        let url = baseURL.appendingPathComponent(path)
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue(applicationKey, forHTTPHeaderField: "hue-application-key")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try encoder.encode(body)

        let _: EmptyResponse = try await performRequest(request)
    }

    private func post<Body: Encodable, T: Codable>(path: String, body: Body) async throws -> T {
        let url = baseURL.appendingPathComponent(path)
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(applicationKey, forHTTPHeaderField: "hue-application-key")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try encoder.encode(body)

        return try await performRequest(request)
    }

    private func delete(path: String) async throws {
        let url = baseURL.appendingPathComponent(path)
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue(applicationKey, forHTTPHeaderField: "hue-application-key")

        let _: EmptyResponse = try await performRequest(request)
    }

    private func performRequest<T: Codable>(_ request: URLRequest) async throws -> T {
        do {
            let (data, response) = try await session.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw HueAPIClientError.invalidResponse
            }

            guard (200...299).contains(httpResponse.statusCode) else {
                let message = String(data: data, encoding: .utf8)
                throw HueAPIClientError.httpError(statusCode: httpResponse.statusCode, message: message)
            }

            // Handle empty response for PUT/DELETE
            if T.self == EmptyResponse.self {
                return EmptyResponse() as! T
            }

            do {
                return try decoder.decode(T.self, from: data)
            } catch {
                throw HueAPIClientError.decodingError(error)
            }
        } catch let error as HueAPIClientError {
            throw error
        } catch {
            throw HueAPIClientError.networkError(error)
        }
    }
}

/// Placeholder for responses we don't need to parse
private struct EmptyResponse: Codable {}

// MARK: - Convenience Extensions

extension HueAPIClient {
    /// Fetch all resources and populate a cache
    func fetchAllResources() async throws -> HueResourceCache {
        let cache = HueResourceCache()

        async let lightsTask = fetchLights()
        async let roomsTask = fetchRooms()
        async let groupedLightsTask = fetchGroupedLights()
        async let scenesTask = fetchScenes()
        async let devicesTask = fetchDevices()

        let (lights, rooms, groupedLights, scenes, devices) = try await (
            lightsTask, roomsTask, groupedLightsTask, scenesTask, devicesTask
        )

        for light in lights {
            cache.lights[light.id] = light
        }
        for room in rooms {
            cache.rooms[room.id] = room
        }
        for groupedLight in groupedLights {
            cache.groupedLights[groupedLight.id] = groupedLight
        }
        for scene in scenes {
            cache.scenes[scene.id] = scene
        }
        for device in devices {
            cache.devices[device.id] = device
        }

        return cache
    }

    /// Create a scene action for a light with specific settings
    static func createSceneAction(
        lightId: String,
        on: Bool,
        brightness: Double? = nil,
        xy: (x: Double, y: Double)? = nil
    ) -> HueSceneAction {
        let actionState = HueSceneActionState(
            on: HueOnState(on: on),
            dimming: brightness.map { HueDimming(brightness: $0, minDimLevel: nil) },
            color: xy.map { HueColor(xy: HueXY(x: $0.x, y: $0.y), gamut: nil, gamutType: nil) },
            colorTemperature: nil,
            effects: nil,
            dynamics: nil
        )

        return HueSceneAction(
            target: HueResourceLink(rid: lightId, rtype: "light"),
            action: actionState
        )
    }
}
