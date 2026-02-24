//
//  TTModeKasaDiscovery.swift
//  Turn Touch iOS
//
//  Created by Samuel Clay on 12/30/25.
//  Copyright © 2025 Turn Touch. All rights reserved.
//

import Foundation
import CocoaAsyncSocket
import Darwin

protocol TTModeKasaDiscoveryDelegate: AnyObject {
    func discoveryFoundDevice(ipAddress: String, port: UInt16, protocolType: KasaProtocolType,
                              name: String?, deviceId: String?, macAddress: String?) -> TTModeKasaDevice
    func discoveryFinishedScanning()
    func discoveryStatusUpdate(_ status: String)
}

class TTModeKasaDiscovery: NSObject, GCDAsyncUdpSocketDelegate, GCDAsyncSocketDelegate {

    weak var delegate: TTModeKasaDiscoveryDelegate?

    private var legacySocket: GCDAsyncUdpSocket?
    private var klapSocket: GCDAsyncUdpSocket?
    private var attemptsLeft: Int = 0
    private var discoveredIPs: Set<String> = []

    // TCP scan for fallback
    private var tcpSockets: [String: GCDAsyncSocket] = [:]
    private var pendingScans: Int = 0
    private var scanQueue: DispatchQueue = DispatchQueue(label: "com.turntouch.kasa.scan", attributes: .concurrent)

    // Fixed ports for receiving responses (like Wemo uses 7700)
    private let legacyReceivePort: UInt16 = 7701
    private let klapReceivePort: UInt16 = 7702

    // MARK: - Discovery Control

    func beginDiscovery() {
        NSLog(" ---> Kasa Discovery: BEGIN DISCOVERY CALLED, delegate = \(String(describing: delegate))")
        attemptsLeft = 5
        discoveredIPs = []

        delegate?.discoveryStatusUpdate("Creating sockets...")
        createSockets()

        NSLog(" ---> Kasa Discovery: legacySocket = \(String(describing: legacySocket)), klapSocket = \(String(describing: klapSocket))")

        delegate?.discoveryStatusUpdate("Sending broadcasts...")
        sendDiscoveryBroadcasts()

        // Also start TCP scan as fallback (more reliable on iOS)
        startTCPScan()
    }

    func stopDiscovery() {
        attemptsLeft = 0
        closeSockets()
        closeAllTCPSockets()
    }

    func deactivate() {
        stopDiscovery()
    }

    deinit {
        deactivate()
    }

    // MARK: - Socket Setup

    private func createSockets() {
        // Legacy socket for port 9999
        if legacySocket == nil {
            legacySocket = GCDAsyncUdpSocket(delegate: self, delegateQueue: DispatchQueue.main)
            legacySocket?.setIPv4Enabled(true)
            legacySocket?.setIPv6Enabled(false)

            do {
                try legacySocket?.enableBroadcast(true)
                try legacySocket?.bind(toPort: legacyReceivePort) // Use fixed port for iOS
                try legacySocket?.beginReceiving()
                NSLog(" ---> Kasa Discovery: Legacy socket ready on port \(legacyReceivePort)")
                delegate?.discoveryStatusUpdate("Legacy socket ready (port \(legacyReceivePort))")
            } catch {
                NSLog(" ---> Kasa Discovery: Legacy socket error: \(error)")
                delegate?.discoveryStatusUpdate("Legacy socket ERROR: \(error.localizedDescription)")
            }
        }

        // KLAP socket for port 20002
        if klapSocket == nil {
            klapSocket = GCDAsyncUdpSocket(delegate: self, delegateQueue: DispatchQueue.main)
            klapSocket?.setIPv4Enabled(true)
            klapSocket?.setIPv6Enabled(false)

            do {
                try klapSocket?.enableBroadcast(true)
                try klapSocket?.bind(toPort: klapReceivePort) // Use fixed port for iOS
                try klapSocket?.beginReceiving()
                NSLog(" ---> Kasa Discovery: KLAP socket ready on port \(klapReceivePort)")
                delegate?.discoveryStatusUpdate("KLAP socket ready (port \(klapReceivePort))")
            } catch {
                NSLog(" ---> Kasa Discovery: KLAP socket error: \(error)")
                delegate?.discoveryStatusUpdate("KLAP socket ERROR: \(error.localizedDescription)")
            }
        }
    }

    // MARK: - Network Helpers

    /// Get broadcast addresses to try (subnet broadcast + global broadcast)
    private func getBroadcastAddresses() -> [String] {
        var addresses: [String] = []

        // Get local IP and compute subnet broadcast
        if let localIP = getWiFiAddress() {
            let components = localIP.split(separator: ".")
            if components.count == 4 {
                // Assume /24 subnet (most common for home networks)
                let subnetBroadcast = "\(components[0]).\(components[1]).\(components[2]).255"
                addresses.append(subnetBroadcast)
                NSLog(" ---> Kasa Discovery: Using subnet broadcast: \(subnetBroadcast)")
                delegate?.discoveryStatusUpdate("Subnet: \(subnetBroadcast)")
            }
        }

        // Always include global broadcast as fallback
        addresses.append("255.255.255.255")

        return addresses
    }

    /// Get the subnet prefix for TCP scanning
    private func getSubnetPrefix() -> String? {
        if let localIP = getWiFiAddress() {
            let components = localIP.split(separator: ".")
            if components.count == 4 {
                return "\(components[0]).\(components[1]).\(components[2])"
            }
        }
        return nil
    }

    /// Get the device's WiFi IP address
    private func getWiFiAddress() -> String? {
        var address: String?
        var ifaddr: UnsafeMutablePointer<ifaddrs>?

        guard getifaddrs(&ifaddr) == 0, let firstAddr = ifaddr else {
            return nil
        }

        defer { freeifaddrs(ifaddr) }

        for ptr in sequence(first: firstAddr, next: { $0.pointee.ifa_next }) {
            let interface = ptr.pointee
            let addrFamily = interface.ifa_addr.pointee.sa_family

            if addrFamily == UInt8(AF_INET) {
                let name = String(cString: interface.ifa_name)
                if name == "en0" { // WiFi interface
                    var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                    getnameinfo(interface.ifa_addr, socklen_t(interface.ifa_addr.pointee.sa_len),
                               &hostname, socklen_t(hostname.count),
                               nil, socklen_t(0), NI_NUMERICHOST)
                    address = String(cString: hostname)
                }
            }
        }

        return address
    }

    private func closeSockets() {
        legacySocket?.close()
        legacySocket = nil

        klapSocket?.close()
        klapSocket = nil
    }

    private func closeAllTCPSockets() {
        for (_, socket) in tcpSockets {
            socket.disconnect()
        }
        tcpSockets.removeAll()
    }

    // MARK: - Discovery Broadcasts

    private func sendDiscoveryBroadcasts() {
        // Send legacy discovery (encrypted get_sysinfo)
        sendLegacyDiscovery()

        // Send KLAP discovery (different packet format)
        sendKLAPDiscovery()

        // Schedule retry
        let retryTime = DispatchTime.now() + .seconds(3)
        DispatchQueue.main.asyncAfter(deadline: retryTime) { [weak self] in
            guard let self = self else { return }

            if self.attemptsLeft == 0 {
                self.delegate?.discoveryStatusUpdate("Discovery complete. Found \(self.discoveredIPs.count) devices.")
                self.delegate?.discoveryFinishedScanning()
                return
            }

            self.attemptsLeft -= 1
            NSLog(" ---> Kasa Discovery: \(self.attemptsLeft) attempts remaining...")
            self.delegate?.discoveryStatusUpdate("Scanning... \(self.attemptsLeft) retries left, \(self.discoveredIPs.count) found")
            self.sendDiscoveryBroadcasts()
        }
    }

    private func sendLegacyDiscovery() {
        let command = "{\"system\":{\"get_sysinfo\":{}}}"
        guard let commandData = command.data(using: .utf8) else { return }

        // Encrypt with XOR (just like for TCP, but no length header for UDP)
        let encryptedData = TTModeKasaLegacyProtocol.encrypt(commandData)

        NSLog(" ---> Kasa Discovery: Encrypted data (\(encryptedData.count) bytes): \(encryptedData.map { String(format: "%02x", $0) }.prefix(20).joined())")

        // Send to all broadcast addresses (subnet first, then global)
        for broadcastAddr in getBroadcastAddresses() {
            legacySocket?.send(encryptedData,
                              toHost: broadcastAddr,
                              port: KasaConstants.legacyPort,
                              withTimeout: 3,
                              tag: 0)
            NSLog(" ---> Kasa Discovery: Sent legacy broadcast to \(broadcastAddr):\(KasaConstants.legacyPort)")
        }
    }

    private func sendKLAPDiscovery() {
        // KLAP discovery uses a simpler packet - just empty or minimal JSON
        // The actual discovery response tells us the device supports KLAP
        let discoveryPacket = Data([0x02, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00,
                                    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00])

        // Send to all broadcast addresses (subnet first, then global)
        for broadcastAddr in getBroadcastAddresses() {
            klapSocket?.send(discoveryPacket,
                            toHost: broadcastAddr,
                            port: KasaConstants.klapDiscoveryPort,
                            withTimeout: 3,
                            tag: 1)
            NSLog(" ---> Kasa Discovery: Sent KLAP broadcast to \(broadcastAddr):\(KasaConstants.klapDiscoveryPort)")
        }
    }

    // MARK: - TCP Network Scan (Fallback for iOS)

    private func startTCPScan() {
        guard let subnetPrefix = getSubnetPrefix() else {
            NSLog(" ---> Kasa Discovery: Could not get subnet prefix for TCP scan")
            return
        }

        NSLog(" ---> Kasa Discovery: Starting TCP scan on \(subnetPrefix).x")
        delegate?.discoveryStatusUpdate("TCP scanning \(subnetPrefix).x...")

        // Scan common device IPs (skip .0 and .255)
        // Start with a quick scan of likely IPs, then do full range
        let priorityIPs = [1, 2, 100, 101, 102, 103, 104, 105, 106, 107, 108, 109, 110,
                          150, 151, 152, 153, 154, 155, 200, 201, 202, 203, 204, 205]

        // First scan priority IPs on both ports
        for lastOctet in priorityIPs {
            let ip = "\(subnetPrefix).\(lastOctet)"
            scanIP(ip, port: KasaConstants.legacyPort) // Port 9999 for legacy
            scanIP(ip, port: 80) // Port 80 for KLAP HTTP
        }

        // Then scan the rest with small delays to avoid overwhelming the network
        scanQueue.async { [weak self] in
            for lastOctet in 1..<255 {
                guard let self = self, self.attemptsLeft >= 0 else { return }

                if priorityIPs.contains(lastOctet) { continue }

                let ip = "\(subnetPrefix).\(lastOctet)"

                DispatchQueue.main.async {
                    self.scanIP(ip, port: KasaConstants.legacyPort)
                }

                // Also scan port 80 for KLAP devices
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                    self.scanIP(ip, port: 80)
                }

                // Small delay between scans
                Thread.sleep(forTimeInterval: 0.03)
            }
        }
    }

    private func scanIP(_ ip: String, port: UInt16 = KasaConstants.legacyPort) {
        // Skip already discovered IPs
        if discoveredIPs.contains(ip) { return }

        let socketKey = "\(ip):\(port)"
        if tcpSockets[socketKey] != nil { return }

        let socket = GCDAsyncSocket(delegate: self, delegateQueue: DispatchQueue.main)
        socket.userData = ["ip": ip, "port": port] as NSDictionary
        tcpSockets[socketKey] = socket
        pendingScans += 1

        do {
            try socket.connect(toHost: ip, onPort: port, withTimeout: 2.0)
        } catch {
            // Connection failed immediately - not a Kasa device
            tcpSockets.removeValue(forKey: socketKey)
            pendingScans -= 1
        }
    }

    // MARK: - GCDAsyncSocketDelegate (TCP)

    func socket(_ sock: GCDAsyncSocket, didConnectToHost host: String, port: UInt16) {
        NSLog(" ---> Kasa Discovery: TCP connected to \(host):\(port)")
        delegate?.discoveryStatusUpdate("Connected to \(host):\(port)")

        if port == 80 {
            // KLAP device - send HTTP POST to /app endpoint to check
            let httpRequest = "POST /app HTTP/1.1\r\nHost: \(host)\r\nContent-Type: application/json\r\nContent-Length: 2\r\n\r\n{}"
            if let data = httpRequest.data(using: .utf8) {
                sock.write(data, withTimeout: 3, tag: 80)
                sock.readData(withTimeout: 3, tag: 80)
            }
        } else {
            // Legacy device - send get_sysinfo command
            let command = "{\"system\":{\"get_sysinfo\":{}}}"
            guard let commandData = command.data(using: .utf8) else { return }

            // Encrypt with length header for TCP
            let encryptedData = TTModeKasaLegacyProtocol.encryptWithHeader(commandData)

            sock.write(encryptedData, withTimeout: 3, tag: 0)
            sock.readData(withTimeout: 3, tag: 0)
        }
    }

    func socket(_ sock: GCDAsyncSocket, didRead data: Data, withTag tag: Int) {
        guard let host = sock.connectedHost else { return }
        let port = sock.connectedPort

        NSLog(" ---> Kasa Discovery: TCP received \(data.count) bytes from \(host):\(port)")

        if tag == 80 || port == 80 {
            // KLAP HTTP response - check if it looks like a Kasa device
            handleHTTPResponse(data, host: host, sock: sock)
        } else {
            // Legacy response
            handleLegacyTCPResponse(data, host: host, sock: sock)
        }
    }

    private func handleHTTPResponse(_ data: Data, host: String, sock: GCDAsyncSocket) {
        guard let response = String(data: data, encoding: .utf8) else {
            sock.disconnect()
            return
        }

        NSLog(" ---> Kasa Discovery: HTTP response from \(host): \(response.prefix(200))")

        // Check if this looks like a Kasa device (has specific headers or response)
        if response.contains("TP-Link") || response.contains("Tapo") ||
           response.contains("application/json") || response.contains("error_code") {
            // This is likely a KLAP device
            discoveredIPs.insert(host)

            let device = delegate?.discoveryFoundDevice(
                ipAddress: host,
                port: 80,
                protocolType: .klap,
                name: nil, // KLAP requires authentication to get name
                deviceId: nil,
                macAddress: nil
            )

            NSLog(" ---> Kasa Discovery: Found KLAP device via HTTP: \(device?.description ?? "unknown")")
            delegate?.discoveryStatusUpdate("Found KLAP: \(host)")
        }

        // Clean up
        sock.disconnect()
        let socketKey = "\(host):80"
        tcpSockets.removeValue(forKey: socketKey)
        pendingScans -= 1
    }

    private func handleLegacyTCPResponse(_ data: Data, host: String, sock: GCDAsyncSocket) {
        // Skip 4-byte length header
        guard data.count > 4 else {
            sock.disconnect()
            return
        }
        let payloadData = data.subdata(in: 4..<data.count)

        // Decrypt the response
        let decryptedData = TTModeKasaLegacyProtocol.decrypt(payloadData)

        guard let jsonString = String(data: decryptedData, encoding: .utf8) else {
            NSLog(" ---> Kasa Discovery: Could not decode TCP response from \(host)")
            sock.disconnect()
            return
        }

        NSLog(" ---> Kasa Discovery: TCP response from \(host): \(jsonString.prefix(200))")

        // Parse the JSON
        do {
            let decoder = JSONDecoder()
            let response = try decoder.decode(KasaSystemResponse.self, from: decryptedData)

            if let sysinfo = response.system.getSysinfo {
                discoveredIPs.insert(host)

                let device = delegate?.discoveryFoundDevice(
                    ipAddress: host,
                    port: KasaConstants.legacyPort,
                    protocolType: .legacy,
                    name: sysinfo.alias,
                    deviceId: sysinfo.deviceId,
                    macAddress: sysinfo.mac
                )

                NSLog(" ---> Kasa Discovery: Found device via TCP: \(device?.description ?? "unknown")")
                delegate?.discoveryStatusUpdate("Found: \(sysinfo.alias ?? host)")
            }
        } catch {
            NSLog(" ---> Kasa Discovery: Failed to parse TCP response: \(error)")
        }

        // Clean up
        sock.disconnect()
        let socketKey = "\(host):\(KasaConstants.legacyPort)"
        tcpSockets.removeValue(forKey: socketKey)
        pendingScans -= 1
    }

    func socketDidDisconnect(_ sock: GCDAsyncSocket, withError err: Error?) {
        if let userData = sock.userData as? NSDictionary,
           let ip = userData["ip"] as? String,
           let port = userData["port"] as? UInt16 {
            let socketKey = "\(ip):\(port)"
            tcpSockets.removeValue(forKey: socketKey)
        }
        pendingScans = max(0, pendingScans - 1)
    }

    // MARK: - GCDAsyncUdpSocketDelegate

    func udpSocket(_ sock: GCDAsyncUdpSocket, didReceive data: Data, fromAddress address: Data, withFilterContext filterContext: Any?) {
        guard let host = GCDAsyncUdpSocket.host(fromAddress: address) else {
            NSLog(" ---> Kasa Discovery: Could not get host from address")
            delegate?.discoveryStatusUpdate("Error: Could not parse address")
            return
        }
        let port = GCDAsyncUdpSocket.port(fromAddress: address)

        NSLog(" ---> Kasa Discovery: RAW RESPONSE from \(host):\(port) (\(data.count) bytes)")
        delegate?.discoveryStatusUpdate("Response from \(host):\(port)")

        // Skip if we've already processed this IP
        if discoveredIPs.contains(host) {
            NSLog(" ---> Kasa Discovery: Already processed \(host), skipping")
            return
        }

        NSLog(" ---> Kasa Discovery: Processing response from \(host):\(port)")

        if sock === legacySocket {
            handleLegacyResponse(data, host: host, port: port)
        } else if sock === klapSocket {
            handleKLAPResponse(data, host: host, port: port)
        }
    }

    @nonobjc func udpSocketDidClose(_ sock: GCDAsyncUdpSocket, withError error: Error?) {
        NSLog(" ---> Kasa Discovery: Socket closed")
    }

    // MARK: - Response Handling

    private func handleLegacyResponse(_ data: Data, host: String, port: UInt16) {
        // Decrypt the response
        let decryptedData = TTModeKasaLegacyProtocol.decrypt(data)

        guard let jsonString = String(data: decryptedData, encoding: .utf8) else {
            NSLog(" ---> Kasa Discovery: Could not decode legacy response")
            return
        }

        NSLog(" ---> Kasa Discovery: Legacy response: \(jsonString)")

        // Parse the JSON
        do {
            let decoder = JSONDecoder()
            let response = try decoder.decode(KasaSystemResponse.self, from: decryptedData)

            if let sysinfo = response.system.getSysinfo {
                discoveredIPs.insert(host)

                let device = delegate?.discoveryFoundDevice(
                    ipAddress: host,
                    port: KasaConstants.legacyPort,
                    protocolType: .legacy,
                    name: sysinfo.alias,
                    deviceId: sysinfo.deviceId,
                    macAddress: sysinfo.mac
                )

                NSLog(" ---> Kasa Discovery: Found legacy device: \(device?.description ?? "unknown")")
            }
        } catch {
            NSLog(" ---> Kasa Discovery: Failed to parse legacy response: \(error)")
        }
    }

    private func handleKLAPResponse(_ data: Data, host: String, port: UInt16) {
        // KLAP discovery responses are JSON with device info
        guard data.count > 16 else {
            NSLog(" ---> Kasa Discovery: KLAP response too short")
            return
        }

        // Skip the first 16 bytes (header)
        let jsonData = data.suffix(from: 16)

        guard let jsonString = String(data: jsonData, encoding: .utf8) else {
            NSLog(" ---> Kasa Discovery: Could not decode KLAP response")
            return
        }

        NSLog(" ---> Kasa Discovery: KLAP response: \(jsonString)")

        do {
            let decoder = JSONDecoder()
            let response = try decoder.decode(KasaDiscoveryResponse.self, from: jsonData)

            if let result = response.result {
                discoveredIPs.insert(host)

                let device = delegate?.discoveryFoundDevice(
                    ipAddress: host,
                    port: KasaConstants.klapDiscoveryPort,
                    protocolType: .klap,
                    name: nil, // KLAP discovery doesn't include the name
                    deviceId: result.deviceId,
                    macAddress: result.mac
                )

                NSLog(" ---> Kasa Discovery: Found KLAP device: \(device?.description ?? "unknown")")
            }
        } catch {
            NSLog(" ---> Kasa Discovery: Failed to parse KLAP response: \(error)")
        }
    }
}
