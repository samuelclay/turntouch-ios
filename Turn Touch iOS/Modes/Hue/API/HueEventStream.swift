//
//  HueEventStream.swift
//  Turn Touch iOS
//
//  Server-Sent Events (SSE) for real-time Hue resource updates
//

import Foundation

/// Protocol for receiving SSE event updates
protocol HueEventStreamDelegate: AnyObject {
    func eventStreamConnected()
    func eventStreamDisconnected(error: Error?)
    func eventStreamReceivedUpdate(lights: [HueLight])
    func eventStreamReceivedUpdate(scenes: [HueScene])
    func eventStreamReceivedUpdate(rooms: [HueRoom])
}

/// Manages a Server-Sent Events connection to the Hue Bridge for real-time updates
class HueEventStream: NSObject {
    private var bridgeIP: String
    private var applicationKey: String
    private var dataTask: URLSessionDataTask?
    private var session: URLSession?
    private var buffer = Data()

    weak var delegate: HueEventStreamDelegate?

    private var isConnected = false
    private var reconnectAttempts = 0
    private let maxReconnectAttempts = 5
    private var reconnectDelay: TimeInterval = 1.0

    // Polling fallback
    private var pollTimer: Timer?
    private var pollClient: HueAPIClient?
    private var usePollingFallback = false

    init(bridgeIP: String, applicationKey: String) {
        self.bridgeIP = bridgeIP
        self.applicationKey = applicationKey
        super.init()
    }

    deinit {
        disconnect()
    }

    // MARK: - Connection Management

    /// Connect to the SSE event stream
    func connect() {
        guard !isConnected else { return }

        let url = URL(string: "https://\(bridgeIP)/eventstream/clip/v2")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(applicationKey, forHTTPHeaderField: "hue-application-key")
        request.setValue("text/event-stream", forHTTPHeaderField: "Accept")
        request.timeoutInterval = TimeInterval.infinity  // Keep alive

        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = TimeInterval.infinity
        config.timeoutIntervalForResource = TimeInterval.infinity

        session = URLSession(
            configuration: config,
            delegate: self,
            delegateQueue: OperationQueue.main
        )

        dataTask = session?.dataTask(with: request)
        dataTask?.resume()

        print("[HueEventStream] Connecting to SSE stream...")
    }

    /// Disconnect from the SSE event stream
    func disconnect() {
        isConnected = false
        dataTask?.cancel()
        dataTask = nil
        session?.invalidateAndCancel()
        session = nil
        buffer.removeAll()
        stopPolling()
        print("[HueEventStream] Disconnected")
    }

    /// Reconnect after a disconnection
    private func attemptReconnect() {
        guard reconnectAttempts < maxReconnectAttempts else {
            print("[HueEventStream] Max reconnect attempts reached, falling back to polling")
            startPollingFallback()
            return
        }

        reconnectAttempts += 1
        let delay = reconnectDelay * Double(reconnectAttempts)

        print("[HueEventStream] Attempting reconnect in \(delay)s (attempt \(reconnectAttempts))")

        DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
            self?.connect()
        }
    }

    // MARK: - Polling Fallback

    private func startPollingFallback() {
        usePollingFallback = true
        pollClient = HueAPIClient(bridgeIP: bridgeIP, applicationKey: applicationKey)

        pollTimer = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: true) { [weak self] _ in
            self?.pollForUpdates()
        }
        pollTimer?.fire()  // Immediate first poll

        print("[HueEventStream] Started polling fallback (every 10s)")
    }

    private func stopPolling() {
        pollTimer?.invalidate()
        pollTimer = nil
        pollClient = nil
        usePollingFallback = false
    }

    private func pollForUpdates() {
        guard let client = pollClient else { return }

        Task {
            do {
                let lights = try await client.fetchLights()
                await MainActor.run {
                    self.delegate?.eventStreamReceivedUpdate(lights: lights)
                }
            } catch {
                print("[HueEventStream] Polling error: \(error)")
            }
        }
    }

    // MARK: - Event Parsing

    private func processBuffer() {
        // SSE format: each event is separated by double newlines
        // Events start with "data: " followed by JSON

        guard let text = String(data: buffer, encoding: .utf8) else { return }

        // Split by double newlines
        let events = text.components(separatedBy: "\n\n")

        // Keep the last incomplete event in the buffer
        if !text.hasSuffix("\n\n") {
            if let lastEvent = events.last, !lastEvent.isEmpty {
                buffer = lastEvent.data(using: .utf8) ?? Data()
            } else {
                buffer.removeAll()
            }
        } else {
            buffer.removeAll()
        }

        // Process complete events
        for event in events.dropLast(text.hasSuffix("\n\n") ? 0 : 1) {
            if event.isEmpty { continue }

            // Parse the event data
            let lines = event.components(separatedBy: "\n")
            var eventData = ""

            for line in lines {
                if line.hasPrefix("data: ") {
                    eventData = String(line.dropFirst(6))
                } else if line.hasPrefix(": ") || line == ":" {
                    // Comment or heartbeat - ignore
                    continue
                }
            }

            if !eventData.isEmpty {
                parseEventData(eventData)
            }
        }
    }

    private func parseEventData(_ jsonString: String) {
        guard let data = jsonString.data(using: .utf8) else { return }

        do {
            let events = try JSONDecoder().decode([HueSSEEvent].self, from: data)

            for event in events {
                processEvent(event)
            }
        } catch {
            print("[HueEventStream] Failed to parse event: \(error)")
            print("[HueEventStream] Raw data: \(jsonString.prefix(500))")
        }
    }

    private func processEvent(_ event: HueSSEEvent) {
        guard event.type == "update" || event.type == "add" else { return }

        var lights: [HueLight] = []
        var scenes: [HueScene] = []
        var rooms: [HueRoom] = []

        for eventData in event.data {
            switch eventData.type {
            case "light":
                // Convert SSE event data to HueLight
                if let light = convertToLight(eventData) {
                    lights.append(light)
                }
            case "scene":
                // Scene updates are less frequent, just notify
                break
            case "room":
                // Room updates are less frequent, just notify
                break
            case "grouped_light":
                // Grouped light updates - could be used for room brightness
                break
            default:
                break
            }
        }

        if !lights.isEmpty {
            delegate?.eventStreamReceivedUpdate(lights: lights)
        }
        if !scenes.isEmpty {
            delegate?.eventStreamReceivedUpdate(scenes: scenes)
        }
        if !rooms.isEmpty {
            delegate?.eventStreamReceivedUpdate(rooms: rooms)
        }
    }

    private func convertToLight(_ eventData: HueSSEEventData) -> HueLight? {
        // Create a partial HueLight from the event data
        return HueLight(
            id: eventData.id,
            idV1: eventData.idV1,
            owner: eventData.owner,
            metadata: eventData.metadata,
            on: eventData.on,
            dimming: eventData.dimming,
            colorTemperature: eventData.colorTemperature,
            color: eventData.color,
            dynamics: eventData.dynamics,
            effects: eventData.effects,
            mode: nil,
            type: eventData.type
        )
    }
}

// MARK: - URLSessionDataDelegate

extension HueEventStream: URLSessionDataDelegate {
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        buffer.append(data)
        processBuffer()
    }

    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        if let httpResponse = response as? HTTPURLResponse {
            print("[HueEventStream] Received response: \(httpResponse.statusCode)")

            if httpResponse.statusCode == 200 {
                isConnected = true
                reconnectAttempts = 0
                delegate?.eventStreamConnected()
            }
        }
        completionHandler(.allow)
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        isConnected = false

        if let error = error as NSError?, error.code == NSURLErrorCancelled {
            // Intentional cancellation
            return
        }

        print("[HueEventStream] Connection ended: \(error?.localizedDescription ?? "unknown")")
        delegate?.eventStreamDisconnected(error: error)

        // Attempt to reconnect
        if !usePollingFallback {
            attemptReconnect()
        }
    }
}

// MARK: - URLSessionDelegate (SSL)

extension HueEventStream: URLSessionDelegate {
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust,
           let serverTrust = challenge.protectionSpace.serverTrust {
            let credential = URLCredential(trust: serverTrust)
            completionHandler(.useCredential, credential)
        } else {
            completionHandler(.performDefaultHandling, nil)
        }
    }
}

// MARK: - Notifications

extension HueEventStream {
    /// Notification names matching SwiftyHue's ResourceCacheUpdateNotification
    struct Notifications {
        static let lightsUpdated = Notification.Name("HueEventStream.lightsUpdated")
        static let scenesUpdated = Notification.Name("HueEventStream.scenesUpdated")
        static let roomsUpdated = Notification.Name("HueEventStream.roomsUpdated")
        static let groupsUpdated = Notification.Name("HueEventStream.groupsUpdated")
        static let configUpdated = Notification.Name("HueEventStream.configUpdated")
    }

    /// Post a notification when resources are updated
    func postUpdateNotification(lights: [HueLight]) {
        NotificationCenter.default.post(
            name: Notifications.lightsUpdated,
            object: self,
            userInfo: ["lights": lights]
        )
    }
}
