//
//  HueBridgeAuthenticator.swift
//  Turn Touch iOS
//
//  Pushlink authentication flow for Hue Bridge
//

import Foundation
import UIKit

/// Authentication result
struct HueAuthResult {
    let bridgeIP: String
    let bridgeId: String
    let applicationKey: String  // The "username" we get from the bridge
    let clientKey: String?      // Optional entertainment client key
}

/// Errors that can occur during authentication
enum HueBridgeAuthenticatorError: Error, LocalizedError {
    case networkError(Error)
    case invalidResponse
    case linkButtonNotPressed
    case timeout
    case cancelled
    case authenticationFailed(String)

    var errorDescription: String? {
        switch self {
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .invalidResponse:
            return "Invalid response from bridge"
        case .linkButtonNotPressed:
            return "Link button not pressed"
        case .timeout:
            return "Authentication timed out"
        case .cancelled:
            return "Authentication was cancelled"
        case .authenticationFailed(let message):
            return "Authentication failed: \(message)"
        }
    }
}

/// Protocol for receiving authentication updates
protocol HueBridgeAuthenticatorDelegate: AnyObject {
    func authenticationStarted()
    func authenticationProgress(remainingSeconds: Int)
    func authenticationSucceeded(result: HueAuthResult)
    func authenticationFailed(error: HueBridgeAuthenticatorError)
}

/// Handles the pushlink authentication flow with a Hue Bridge
class HueBridgeAuthenticator {
    private let timeoutSeconds: Int = 30
    private let pollingInterval: TimeInterval = 1.0
    private var authTask: Task<HueAuthResult, Error>?
    private var isCancelled = false

    weak var delegate: HueBridgeAuthenticatorDelegate?

    private let sessionDelegate = HueURLSessionDelegate()
    private lazy var session: URLSession = {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 10
        return URLSession(configuration: config, delegate: sessionDelegate, delegateQueue: nil)
    }()

    /// Device type identifier for the Hue Bridge
    private var deviceType: String {
        let deviceName = UIDevice.current.name
            .replacingOccurrences(of: " ", with: "_")
            .prefix(19)
        return "TurnTouch#\(deviceName)"
    }

    /// Start the authentication process
    func startAuthentication(bridgeIP: String, bridgeId: String) {
        isCancelled = false
        delegate?.authenticationStarted()

        authTask = Task {
            do {
                let result = try await performAuthentication(bridgeIP: bridgeIP, bridgeId: bridgeId)
                await MainActor.run {
                    self.delegate?.authenticationSucceeded(result: result)
                }
                return result
            } catch {
                await MainActor.run {
                    if let authError = error as? HueBridgeAuthenticatorError {
                        self.delegate?.authenticationFailed(error: authError)
                    } else {
                        self.delegate?.authenticationFailed(error: .networkError(error))
                    }
                }
                throw error
            }
        }
    }

    /// Cancel the authentication process
    func cancelAuthentication() {
        isCancelled = true
        authTask?.cancel()
        authTask = nil
    }

    /// Perform authentication (polling until success or timeout)
    func authenticate(bridgeIP: String, bridgeId: String) async throws -> HueAuthResult {
        return try await performAuthentication(bridgeIP: bridgeIP, bridgeId: bridgeId)
    }

    private func performAuthentication(bridgeIP: String, bridgeId: String) async throws -> HueAuthResult {
        let startTime = Date()
        var remainingSeconds = timeoutSeconds

        while !isCancelled {
            // Check for timeout
            let elapsed = Date().timeIntervalSince(startTime)
            remainingSeconds = timeoutSeconds - Int(elapsed)

            if remainingSeconds <= 0 {
                throw HueBridgeAuthenticatorError.timeout
            }

            // Notify delegate of progress
            let currentRemaining = remainingSeconds
            await MainActor.run {
                self.delegate?.authenticationProgress(remainingSeconds: currentRemaining)
            }

            // Attempt to authenticate
            do {
                let result = try await attemptAuthentication(bridgeIP: bridgeIP, bridgeId: bridgeId)
                return result
            } catch HueBridgeAuthenticatorError.linkButtonNotPressed {
                // Expected - button hasn't been pressed yet, keep polling
            } catch {
                // Real error - propagate it
                throw error
            }

            // Wait before next attempt
            try await Task.sleep(nanoseconds: UInt64(pollingInterval * 1_000_000_000))
        }

        throw HueBridgeAuthenticatorError.cancelled
    }

    private func attemptAuthentication(bridgeIP: String, bridgeId: String) async throws -> HueAuthResult {
        let url = URL(string: "https://\(bridgeIP)/api")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // Request body - ask for an entertainment client key as well
        let body: [String: Any] = [
            "devicetype": deviceType,
            "generateclientkey": true
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await session.data(for: request)

        guard response is HTTPURLResponse else {
            throw HueBridgeAuthenticatorError.invalidResponse
        }

        // Parse the response
        guard let jsonArray = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]],
              let firstItem = jsonArray.first else {
            if let dataString = String(data: data, encoding: .utf8) {
                print("[HueBridgeAuthenticator] Unexpected response: \(dataString)")
            }
            throw HueBridgeAuthenticatorError.invalidResponse
        }

        // Check for success
        if let success = firstItem["success"] as? [String: Any],
           let username = success["username"] as? String {
            let clientKey = success["clientkey"] as? String
            return HueAuthResult(
                bridgeIP: bridgeIP,
                bridgeId: bridgeId,
                applicationKey: username,
                clientKey: clientKey
            )
        }

        // Check for error
        if let error = firstItem["error"] as? [String: Any],
           let type = error["type"] as? Int {
            switch type {
            case 101:
                // Link button not pressed
                throw HueBridgeAuthenticatorError.linkButtonNotPressed
            default:
                let description = error["description"] as? String ?? "Unknown error"
                throw HueBridgeAuthenticatorError.authenticationFailed(description)
            }
        }

        throw HueBridgeAuthenticatorError.invalidResponse
    }
}

// MARK: - Credential Storage

extension HueBridgeAuthenticator {
    private static let savedBridgesKey = "TT:savedHueBridges"

    /// Save authentication result to UserDefaults
    static func saveCredentials(_ result: HueAuthResult) {
        var savedBridges = loadAllCredentials()
        savedBridges[result.bridgeId] = [
            "ip": result.bridgeIP,
            "bridgeId": result.bridgeId,
            "username": result.applicationKey,
            "clientKey": result.clientKey ?? ""
        ]
        UserDefaults.standard.set(savedBridges, forKey: savedBridgesKey)
    }

    /// Load saved credentials for a specific bridge
    static func loadCredentials(forBridgeId bridgeId: String) -> HueAuthResult? {
        let savedBridges = loadAllCredentials()
        guard let bridgeData = savedBridges[bridgeId] as? [String: String],
              let ip = bridgeData["ip"],
              let username = bridgeData["username"] else {
            return nil
        }

        return HueAuthResult(
            bridgeIP: ip,
            bridgeId: bridgeId,
            applicationKey: username,
            clientKey: bridgeData["clientKey"]
        )
    }

    /// Load all saved bridge credentials
    static func loadAllCredentials() -> [String: Any] {
        return UserDefaults.standard.dictionary(forKey: savedBridgesKey) ?? [:]
    }

    /// Remove saved credentials for a bridge
    static func removeCredentials(forBridgeId bridgeId: String) {
        var savedBridges = loadAllCredentials()
        savedBridges.removeValue(forKey: bridgeId)
        UserDefaults.standard.set(savedBridges, forKey: savedBridgesKey)
    }

    /// Update the IP address for a saved bridge (in case it changed)
    static func updateBridgeIP(_ newIP: String, forBridgeId bridgeId: String) {
        var savedBridges = loadAllCredentials()
        if var bridgeData = savedBridges[bridgeId] as? [String: String] {
            bridgeData["ip"] = newIP
            savedBridges[bridgeId] = bridgeData
            UserDefaults.standard.set(savedBridges, forKey: savedBridgesKey)
        }
    }

    /// Get the most recently used bridge ID
    static var recentBridgeId: String? {
        get {
            UserDefaults.standard.string(forKey: "TT:recentHueBridgeId")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "TT:recentHueBridgeId")
        }
    }

    /// Get the most recently used bridge IP
    static var recentBridgeIP: String? {
        get {
            UserDefaults.standard.string(forKey: "TT:recentHueBridgeIP")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "TT:recentHueBridgeIP")
        }
    }

    /// Save the recently used bridge info
    static func saveRecentBridge(id: String, ip: String) {
        recentBridgeId = id
        recentBridgeIP = ip
    }
}

// MARK: - Legacy Compatibility

extension HueBridgeAuthenticator {
    /// Convert to legacy format for compatibility with existing TTModeHue code
    func convertToLegacyFormat(_ result: HueAuthResult) -> [String: Any] {
        return [
            "ip": result.bridgeIP,
            "bridgeId": result.bridgeId,
            "username": result.applicationKey,
            "clientKey": result.clientKey ?? ""
        ]
    }
}
