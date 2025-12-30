//
//  HueBridgeDiscovery.swift
//  Turn Touch iOS
//
//  Bridge discovery via discovery.meethue.com (NUPNP)
//

import Foundation

// Note: DiscoveredBridge struct is defined in HueModels.swift

/// Errors that can occur during bridge discovery
enum HueBridgeDiscoveryError: Error, LocalizedError {
    case networkError(Error)
    case invalidResponse
    case noBridgesFound
    case cancelled

    var errorDescription: String? {
        switch self {
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .invalidResponse:
            return "Invalid response from discovery service"
        case .noBridgesFound:
            return "No Hue Bridges found on the network"
        case .cancelled:
            return "Discovery was cancelled"
        }
    }
}

/// Protocol for receiving bridge discovery updates
protocol HueBridgeDiscoveryDelegate: AnyObject {
    func bridgeDiscoveryStarted()
    func bridgeDiscoveryFinished(bridges: [DiscoveredBridge])
    func bridgeDiscoveryError(_ error: HueBridgeDiscoveryError)
}

/// Discovers Hue Bridges on the local network using Philips' NUPNP discovery service
class HueBridgeDiscovery {
    private let discoveryURL = URL(string: "https://discovery.meethue.com")!
    private var discoveryTask: Task<[DiscoveredBridge], Error>?

    weak var delegate: HueBridgeDiscoveryDelegate?

    /// Discover Hue Bridges using the NUPNP discovery service
    func discoverBridges() async throws -> [DiscoveredBridge] {
        delegate?.bridgeDiscoveryStarted()

        do {
            let bridges = try await performDiscovery()

            if bridges.isEmpty {
                let error = HueBridgeDiscoveryError.noBridgesFound
                delegate?.bridgeDiscoveryError(error)
                throw error
            }

            delegate?.bridgeDiscoveryFinished(bridges: bridges)
            return bridges
        } catch {
            if error is HueBridgeDiscoveryError {
                delegate?.bridgeDiscoveryError(error as! HueBridgeDiscoveryError)
                throw error
            } else {
                let wrappedError = HueBridgeDiscoveryError.networkError(error)
                delegate?.bridgeDiscoveryError(wrappedError)
                throw wrappedError
            }
        }
    }

    /// Start discovery in the background
    func startDiscovery() {
        discoveryTask = Task {
            try await discoverBridges()
        }
    }

    /// Cancel ongoing discovery
    func cancelDiscovery() {
        discoveryTask?.cancel()
        discoveryTask = nil
    }

    private func performDiscovery() async throws -> [DiscoveredBridge] {
        var request = URLRequest(url: discoveryURL)
        request.httpMethod = "GET"
        request.timeoutInterval = 10

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw HueBridgeDiscoveryError.invalidResponse
        }

        // Parse the JSON response
        let decoder = JSONDecoder()
        do {
            let bridges = try decoder.decode([DiscoveredBridge].self, from: data)
            return bridges
        } catch {
            print("[HueBridgeDiscovery] Failed to decode response: \(error)")
            if let dataString = String(data: data, encoding: .utf8) {
                print("[HueBridgeDiscovery] Response data: \(dataString)")
            }
            throw HueBridgeDiscoveryError.invalidResponse
        }
    }

    /// Validate that a bridge is reachable at the given IP
    func validateBridge(ip: String) async -> Bool {
        let url = URL(string: "https://\(ip)/api/0/config")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = 5

        // Use a session that trusts self-signed certificates
        let sessionDelegate = HueURLSessionDelegate()
        let session = URLSession(
            configuration: .default,
            delegate: sessionDelegate,
            delegateQueue: nil
        )

        do {
            let (data, response) = try await session.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                return false
            }
            // If we got a valid JSON response, the bridge is reachable
            return true
        } catch {
            print("[HueBridgeDiscovery] Bridge validation failed for \(ip): \(error)")
            return false
        }
    }

    /// Get bridge name/info by querying its API
    func getBridgeInfo(ip: String) async -> (name: String, bridgeId: String)? {
        let url = URL(string: "https://\(ip)/api/0/config")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = 5

        let sessionDelegate = HueURLSessionDelegate()
        let session = URLSession(
            configuration: .default,
            delegate: sessionDelegate,
            delegateQueue: nil
        )

        struct BridgeConfig: Codable {
            let name: String?
            let bridgeid: String?
            let modelid: String?
        }

        do {
            let (data, response) = try await session.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                return nil
            }

            let config = try JSONDecoder().decode(BridgeConfig.self, from: data)
            let name = config.name ?? "Hue Bridge"
            let bridgeId = config.bridgeid ?? ""
            return (name, bridgeId)
        } catch {
            print("[HueBridgeDiscovery] Failed to get bridge info for \(ip): \(error)")
            return nil
        }
    }
}

// MARK: - Legacy Compatibility

extension HueBridgeDiscovery {
    /// Convert to the old SwiftyHue bridge format for compatibility
    func convertToLegacyBridges(_ bridges: [DiscoveredBridge]) -> [[String: Any]] {
        return bridges.map { bridge in
            [
                "ip": bridge.internalipaddress,
                "deviceType": "Hue Bridge",
                "friendlyName": bridge.friendlyName ?? "Hue Bridge",
                "modelDescription": "Philips Hue Bridge",
                "modelName": bridge.modelName,
                "serialNumber": bridge.id,
                "UDN": "uuid:\(bridge.id)"
            ]
        }
    }
}
