//
//  TTModeNanoleaf.swift
//  Turn Touch iOS
//
//  Created by Samuel Clay on 2/20/26.
//  Copyright © 2026 Turn Touch. All rights reserved.
//

import UIKit
import Network

enum TTNanoleafState: Int {
    case notConnected
    case connecting
    case pushlink
    case connected
}

enum NanoleafError: Error {
    case notConnected
    case invalidResponse
    case authFailed
}

protocol TTModeNanoleafDelegate {
    func changeState(_ state: TTNanoleafState, mode: TTModeNanoleaf, message: Any?)
}

@objcMembers
class TTModeNanoleaf: TTMode {

    static var nanoleafState: TTNanoleafState = .notConnected
    static var delegates: MulticastDelegate<TTModeNanoleafDelegate?> = MulticastDelegate<TTModeNanoleafDelegate?>()
    static var deviceIp: String?
    static var deviceName: String?
    static var authToken: String?
    static var cachedEffects: [String] = []
    static var currentBrightness: Int = 50
    static var currentPowerState: Bool = false

    static var browser: NWBrowser?
    static var discoveredDevices: [(name: String, ip: String)] = []
    static var authTimer: Timer?
    static var authAttempts: Int = 0
    static let maxAuthAttempts: Int = 30

    required init() {
        super.init()
    }

    override func activate() {
        if TTModeNanoleaf.nanoleafState == .notConnected {
            self.connectToDevice(reset: true)
        }
    }

    override func deactivate() {
    }

    // MARK: Mode

    override class func title() -> String {
        return "Nanoleaf"
    }

    override class func subtitle() -> String {
        return "Light panels and effects"
    }

    override class func imageName() -> String {
        return "mode_nanoleaf.png"
    }

    // MARK: Actions

    override class func actions() -> [String] {
        return [
            "TTModeNanoleafToggle",
            "TTModeNanoleafSceneCustom",
            "TTModeNanoleafRaiseBrightness",
            "TTModeNanoleafLowerBrightness",
            "TTModeNanoleafSleep",
        ]
    }

    override func shouldUseModeOptionsFor(_ action: String) -> Bool {
        return TTModeNanoleaf.nanoleafState != .connected
    }

    // MARK: Action titles

    func titleTTModeNanoleafToggle() -> String {
        return "Toggle on/off"
    }

    func titleTTModeNanoleafSceneCustom() -> String {
        return self.titleTTModeNanoleafSceneCustom(direction: NSNumber(integerLiteral: TTModeDirection.no_DIRECTION.rawValue))
    }

    func titleTTModeNanoleafSceneCustom(direction: NSNumber) -> String {
        let direction = TTModeDirection(rawValue: direction.intValue)!
        if direction != .no_DIRECTION {
            let actionName = self.actionNameInDirection(direction)
            if let effectName = self.actionOptionValue(TTModeNanoleafConstants.kNanoleafScene,
                                                       actionName: actionName, direction: direction) as? String {
                return effectName
            }
        }
        return "Trigger effect"
    }

    func doubleTitleTTModeNanoleafSceneCustom() -> String {
        return "Effect 2"
    }

    func titleTTModeNanoleafRaiseBrightness() -> String {
        return "Raise brightness"
    }

    func titleTTModeNanoleafLowerBrightness() -> String {
        return "Lower brightness"
    }

    func titleTTModeNanoleafSleep() -> String {
        return "Sleep"
    }

    func doubleTitleTTModeNanoleafSleep() -> String {
        return "Sleep fast"
    }

    // MARK: Action images

    func imageTTModeNanoleafToggle() -> String {
        return "nanoleaf_toggle.png"
    }

    func imageTTModeNanoleafSceneCustom() -> String {
        return "nanoleaf_scene.png"
    }

    func imageTTModeNanoleafRaiseBrightness() -> String {
        return "nanoleaf_brightness_up.png"
    }

    func imageTTModeNanoleafLowerBrightness() -> String {
        return "nanoleaf_brightness_down.png"
    }

    func imageTTModeNanoleafSleep() -> String {
        return "nanoleaf_sleep.png"
    }

    // MARK: Defaults

    override func defaultNorth() -> String {
        return "TTModeNanoleafToggle"
    }

    override func defaultEast() -> String {
        return "TTModeNanoleafRaiseBrightness"
    }

    override func defaultWest() -> String {
        return "TTModeNanoleafLowerBrightness"
    }

    override func defaultSouth() -> String {
        return "TTModeNanoleafSleep"
    }

    // MARK: Action methods

    func runTTModeNanoleafToggle() {
        Task {
            do {
                let info = try await fetchDeviceInfo()
                if let state = info["state"] as? [String: Any],
                   let on = state["on"] as? [String: Any],
                   let currentlyOn = on["value"] as? Bool {
                    try await setPower(on: !currentlyOn)
                    print(" ---> Nanoleaf toggled to \(!currentlyOn)")
                }
            } catch {
                print(" ---> Nanoleaf toggle error: \(error)")
            }
        }
    }

    func runTTModeNanoleafSceneCustom() {
        guard let effectName = self.action.optionValue(TTModeNanoleafConstants.kNanoleafScene) as? String else {
            print(" ---> No Nanoleaf effect selected")
            return
        }
        Task {
            do {
                try await setPower(on: true)
                try await setEffect(effectName)
                print(" ---> Nanoleaf effect: \(effectName)")
            } catch {
                print(" ---> Nanoleaf scene error: \(error)")
            }
        }
    }

    func doubleRunTTModeNanoleafSceneCustom() {
        guard let effectName = self.action.optionValue(TTModeNanoleafConstants.kDoubleTapNanoleafScene) as? String else {
            print(" ---> No Nanoleaf double-tap effect selected")
            return
        }
        Task {
            do {
                try await setPower(on: true)
                try await setEffect(effectName)
                print(" ---> Nanoleaf double effect: \(effectName)")
            } catch {
                print(" ---> Nanoleaf double scene error: \(error)")
            }
        }
    }

    func runTTModeNanoleafRaiseBrightness() {
        self.changeBrightness(amount: TTModeNanoleafConstants.kNanoleafBrightnessStep)
    }

    func doubleRunTTModeNanoleafRaiseBrightness() {
        self.changeBrightness(amount: TTModeNanoleafConstants.kNanoleafBrightnessStep * 2)
    }

    func runTTModeNanoleafLowerBrightness() {
        self.changeBrightness(amount: -TTModeNanoleafConstants.kNanoleafBrightnessStep)
    }

    func doubleRunTTModeNanoleafLowerBrightness() {
        self.changeBrightness(amount: -TTModeNanoleafConstants.kNanoleafBrightnessStep * 2)
    }

    func changeBrightness(amount: Int) {
        Task {
            do {
                let info = try await fetchDeviceInfo()
                if let state = info["state"] as? [String: Any],
                   let bri = state["brightness"] as? [String: Any],
                   let currentBri = bri["value"] as? Int {
                    let newBri = max(0, min(100, currentBri + amount))
                    if newBri > 0 {
                        try await setPower(on: true)
                    }
                    try await setBrightness(newBri)
                    print(" ---> Nanoleaf brightness: \(currentBri) -> \(newBri)")
                }
            } catch {
                print(" ---> Nanoleaf brightness error: \(error)")
            }
        }
    }

    func runTTModeNanoleafSleep() {
        let duration: Int = self.action.optionValue(TTModeNanoleafConstants.kNanoleafDuration) as? Int ?? 30
        self.runSleep(duration: duration)
    }

    func doubleRunTTModeNanoleafSleep() {
        let duration: Int = self.action.optionValue(TTModeNanoleafConstants.kNanoleafDoubleTapDuration) as? Int ?? 2
        self.runSleep(duration: duration)
    }

    func runSleep(duration: Int) {
        Task {
            do {
                // transTime is in 1/10th seconds for the Nanoleaf API
                try await setBrightness(0, duration: duration * 10)
                print(" ---> Nanoleaf sleeping over \(duration)s")
                // After the transition completes, turn off
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(duration + 1)) {
                    Task { try? await self.setPower(on: false) }
                }
            } catch {
                print(" ---> Nanoleaf sleep error: \(error)")
            }
        }
    }

    // MARK: Connection

    func connectToDevice(reset: Bool = false) {
        if reset {
            TTModeNanoleaf.nanoleafState = .notConnected
        }

        // Try saved device first
        let prefs = UserDefaults.standard
        if let savedDevices = prefs.array(forKey: TTModeNanoleafConstants.kNanoleafSavedDevices) as? [[String: String]],
           let saved = savedDevices.first,
           let ip = saved["ip"],
           let token = saved["token"] {
            TTModeNanoleaf.deviceIp = ip
            TTModeNanoleaf.authToken = token
            TTModeNanoleaf.deviceName = saved["name"]

            // Verify the saved device is reachable
            TTModeNanoleaf.nanoleafState = .connecting
            TTModeNanoleaf.delegates.invoke { delegate in
                delegate?.changeState(.connecting, mode: self, message: "Connecting to \(saved["name"] ?? "Nanoleaf")...")
            }

            Task {
                do {
                    let info = try await fetchDeviceInfo()
                    let name = info["name"] as? String ?? saved["name"] ?? "Nanoleaf"
                    let effects = try await fetchEffects()
                    await MainActor.run {
                        TTModeNanoleaf.deviceName = name
                        TTModeNanoleaf.cachedEffects = effects
                        TTModeNanoleaf.nanoleafState = .connected
                        TTModeNanoleaf.delegates.invoke { delegate in
                            delegate?.changeState(.connected, mode: self, message: nil)
                        }
                        print(" ---> Nanoleaf connected: \(name) with \(effects.count) effects")
                    }
                } catch {
                    await MainActor.run {
                        print(" ---> Saved Nanoleaf unreachable, discovering: \(error)")
                        self.findDevices()
                    }
                }
            }
            return
        }

        self.findDevices()
    }

    func findDevices() {
        TTModeNanoleaf.nanoleafState = .connecting
        TTModeNanoleaf.delegates.invoke { delegate in
            delegate?.changeState(.connecting, mode: self, message: "Searching for Nanoleaf...")
        }

        TTModeNanoleaf.discoveredDevices = []
        TTModeNanoleaf.browser?.cancel()

        let params = NWParameters()
        params.includePeerToPeer = true
        TTModeNanoleaf.browser = NWBrowser(for: .bonjour(type: "_nanoleafapi._tcp", domain: nil), using: params)

        TTModeNanoleaf.browser?.browseResultsChangedHandler = { results, changes in
            for result in results {
                if case .service(let name, _, _, _) = result.endpoint {
                    // Check if we already resolved this device
                    let alreadyFound = TTModeNanoleaf.discoveredDevices.contains { $0.name == name }
                    if alreadyFound { continue }

                    // Resolve the endpoint to get the host address
                    let connection = NWConnection(to: result.endpoint, using: .tcp)
                    connection.stateUpdateHandler = { state in
                        if case .ready = state {
                            if let innerEndpoint = connection.currentPath?.remoteEndpoint,
                               case .hostPort(let host, _) = innerEndpoint {
                                let rawHost = "\(host)"
                                // Determine the best host string for HTTP URLs
                                let resolvedHost: String
                                if rawHost.contains(":") {
                                    // IPv6 address — use .local hostname instead,
                                    // which URLSession resolves via mDNS to IPv4
                                    resolvedHost = TTModeNanoleaf.mdnsHostname(from: name)
                                } else {
                                    resolvedHost = rawHost
                                }
                                DispatchQueue.main.async {
                                    TTModeNanoleaf.discoveredDevices.append((name: name, ip: resolvedHost))
                                    print(" ---> Nanoleaf discovered: \(name) at \(resolvedHost) (raw: \(rawHost))")
                                }
                            }
                            connection.cancel()
                        } else if case .failed = state {
                            // Connection failed, try using hostname directly
                            let hostname = TTModeNanoleaf.mdnsHostname(from: name)
                            DispatchQueue.main.async {
                                TTModeNanoleaf.discoveredDevices.append((name: name, ip: hostname))
                                print(" ---> Nanoleaf discovered (via hostname): \(name) at \(hostname)")
                            }
                            connection.cancel()
                        }
                    }
                    connection.start(queue: .global())
                }
            }
        }

        TTModeNanoleaf.browser?.start(queue: .global())

        // Timeout after 10 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 10) { [weak self] in
            guard let self = self else { return }
            TTModeNanoleaf.browser?.cancel()

            if TTModeNanoleaf.discoveredDevices.isEmpty {
                TTModeNanoleaf.nanoleafState = .notConnected
                TTModeNanoleaf.delegates.invoke { delegate in
                    delegate?.changeState(.notConnected, mode: self, message: "No Nanoleaf devices found")
                }
            } else if TTModeNanoleaf.discoveredDevices.count == 1 {
                // Auto-select single device
                self.deviceSelected(TTModeNanoleaf.discoveredDevices[0])
            } else {
                // For now, auto-select the first device
                self.deviceSelected(TTModeNanoleaf.discoveredDevices[0])
            }
        }
    }

    /// Construct the .local mDNS hostname from a Bonjour service name.
    /// e.g. "Light Panels 50:A1:5A" → "Light-Panels-50-A1-5A.local"
    static func mdnsHostname(from serviceName: String) -> String {
        return serviceName
            .replacingOccurrences(of: " ", with: "-")
            .replacingOccurrences(of: ":", with: "-")
            + ".local"
    }

    func deviceSelected(_ device: (name: String, ip: String)) {
        TTModeNanoleaf.deviceIp = device.ip
        TTModeNanoleaf.deviceName = device.name

        // Check if we have a saved token for this IP
        let prefs = UserDefaults.standard
        if let savedDevices = prefs.array(forKey: TTModeNanoleafConstants.kNanoleafSavedDevices) as? [[String: String]] {
            for saved in savedDevices {
                if saved["ip"] == device.ip, let token = saved["token"] {
                    TTModeNanoleaf.authToken = token
                    self.authenticateDevice()
                    return
                }
            }
        }

        // No saved token, start auth flow
        self.startAuthentication(ip: device.ip)
    }

    func startAuthentication(ip: String) {
        TTModeNanoleaf.nanoleafState = .pushlink
        TTModeNanoleaf.authAttempts = 0
        TTModeNanoleaf.delegates.invoke { delegate in
            delegate?.changeState(.pushlink, mode: self, message: 100)
        }

        TTModeNanoleaf.authTimer?.invalidate()
        TTModeNanoleaf.authTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
            guard let self = self else {
                timer.invalidate()
                return
            }
            TTModeNanoleaf.authAttempts += 1
            let remaining = TTModeNanoleaf.maxAuthAttempts - TTModeNanoleaf.authAttempts

            if remaining <= 0 {
                timer.invalidate()
                TTModeNanoleaf.nanoleafState = .notConnected
                TTModeNanoleaf.delegates.invoke { delegate in
                    delegate?.changeState(.notConnected, mode: self, message: "Authentication timed out")
                }
                return
            }

            let progress = Int(Float(remaining) / Float(TTModeNanoleaf.maxAuthAttempts) * 100)
            TTModeNanoleaf.delegates.invoke { delegate in
                delegate?.changeState(.pushlink, mode: self, message: progress)
            }

            self.attemptAuth(ip: ip)
        }
    }

    func attemptAuth(ip: String) {
        let host = TTModeNanoleaf.formatHostForURL(ip)
        guard let url = URL(string: "http://\(host):\(TTModeNanoleafConstants.kNanoleafApiPort)/api/v1/new") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.timeoutInterval = 2

        Task {
            do {
                let (data, response) = try await URLSession.shared.data(for: request)
                guard let httpResponse = response as? HTTPURLResponse,
                      httpResponse.statusCode == 200,
                      let json = try? JSONSerialization.jsonObject(with: data) as? [String: String],
                      let token = json["auth_token"] else { return }

                await MainActor.run {
                    TTModeNanoleaf.authTimer?.invalidate()
                    TTModeNanoleaf.authToken = token
                    self.saveDevice(ip: ip, token: token, name: TTModeNanoleaf.deviceName)
                    self.authenticateDevice()
                    print(" ---> Nanoleaf auth token received: \(token.prefix(8))...")
                }
            } catch {
                // Expected - button not pressed yet, silently continue
            }
        }
    }

    func authenticateDevice() {
        TTModeNanoleaf.nanoleafState = .connecting
        TTModeNanoleaf.delegates.invoke { delegate in
            delegate?.changeState(.connecting, mode: self, message: "Loading effects...")
        }

        Task {
            do {
                let info = try await fetchDeviceInfo()
                let name = info["name"] as? String ?? TTModeNanoleaf.deviceName ?? "Nanoleaf"
                let effects = try await fetchEffects()

                await MainActor.run {
                    TTModeNanoleaf.deviceName = name
                    TTModeNanoleaf.cachedEffects = effects
                    TTModeNanoleaf.nanoleafState = .connected
                    // Update saved name
                    if let ip = TTModeNanoleaf.deviceIp, let token = TTModeNanoleaf.authToken {
                        self.saveDevice(ip: ip, token: token, name: name)
                    }
                    TTModeNanoleaf.delegates.invoke { delegate in
                        delegate?.changeState(.connected, mode: self, message: nil)
                    }
                    print(" ---> Nanoleaf connected: \(name), \(effects.count) effects")
                }
            } catch {
                await MainActor.run {
                    TTModeNanoleaf.nanoleafState = .notConnected
                    TTModeNanoleaf.delegates.invoke { delegate in
                        delegate?.changeState(.notConnected, mode: self, message: "Connection failed: \(error.localizedDescription)")
                    }
                }
            }
        }
    }

    // MARK: API Client

    /// Format a host string for use in HTTP URLs.
    /// IPv6 addresses get wrapped in brackets with URL-encoded scope IDs.
    /// Hostnames and IPv4 addresses pass through unchanged.
    static func formatHostForURL(_ host: String) -> String {
        guard host.contains(":") && !host.contains(".local") else { return host }
        // IPv6 address — wrap in brackets, URL-encode % as %25 for scope ID
        let encoded = host.replacingOccurrences(of: "%", with: "%25")
        return "[\(encoded)]"
    }

    func baseURL() -> String? {
        guard let ip = TTModeNanoleaf.deviceIp,
              let token = TTModeNanoleaf.authToken else { return nil }
        let host = TTModeNanoleaf.formatHostForURL(ip)
        return "http://\(host):\(TTModeNanoleafConstants.kNanoleafApiPort)/api/v1/\(token)"
    }

    func fetchDeviceInfo() async throws -> [String: Any] {
        guard let base = baseURL(),
              let url = URL(string: base) else { throw NanoleafError.notConnected }
        let (data, response) = try await URLSession.shared.data(from: url)
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw NanoleafError.invalidResponse
        }
        return try JSONSerialization.jsonObject(with: data) as? [String: Any] ?? [:]
    }

    func fetchEffects() async throws -> [String] {
        guard let base = baseURL(),
              let url = URL(string: "\(base)/effects/effectsList") else { throw NanoleafError.notConnected }
        let (data, response) = try await URLSession.shared.data(from: url)
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw NanoleafError.invalidResponse
        }
        return try JSONSerialization.jsonObject(with: data) as? [String] ?? []
    }

    func setPower(on: Bool) async throws {
        guard let base = baseURL(),
              let url = URL(string: "\(base)/state") else { throw NanoleafError.notConnected }
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: ["on": ["value": on]])
        let (_, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 204 || httpResponse.statusCode == 200 else {
            throw NanoleafError.invalidResponse
        }
    }

    func setBrightness(_ value: Int, duration: Int = 0) async throws {
        guard let base = baseURL(),
              let url = URL(string: "\(base)/state") else { throw NanoleafError.notConnected }
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        var briDict: [String: Any] = ["value": max(0, min(100, value))]
        if duration > 0 {
            briDict["duration"] = duration
        }
        request.httpBody = try JSONSerialization.data(withJSONObject: ["brightness": briDict])
        let (_, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 204 || httpResponse.statusCode == 200 else {
            throw NanoleafError.invalidResponse
        }
    }

    func setEffect(_ effectName: String) async throws {
        guard let base = baseURL(),
              let url = URL(string: "\(base)/effects") else { throw NanoleafError.notConnected }
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: ["select": effectName])
        let (_, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 204 || httpResponse.statusCode == 200 else {
            throw NanoleafError.invalidResponse
        }
    }

    // MARK: Device persistence

    func saveDevice(ip: String, token: String, name: String? = nil) {
        let prefs = UserDefaults.standard
        var savedDevices = prefs.array(forKey: TTModeNanoleafConstants.kNanoleafSavedDevices) as? [[String: String]] ?? []

        // Remove existing entry for this IP
        savedDevices.removeAll { $0["ip"] == ip }

        let device: [String: String] = [
            "ip": ip,
            "token": token,
            "name": name ?? TTModeNanoleaf.deviceName ?? "Nanoleaf"
        ]
        savedDevices.insert(device, at: 0)

        prefs.set(savedDevices, forKey: TTModeNanoleafConstants.kNanoleafSavedDevices)
        prefs.synchronize()
    }
}
