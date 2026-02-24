//
//  TTModeKasaLegacyProtocol.swift
//  Turn Touch iOS
//
//  Created by Samuel Clay on 12/30/25.
//  Copyright © 2025 Turn Touch. All rights reserved.
//

import Foundation
import CocoaAsyncSocket

protocol TTModeKasaLegacyProtocolDelegate: AnyObject {
    func legacyProtocolDidReceiveDeviceInfo(_ sysinfo: KasaSysinfo)
    func legacyProtocolDidReceiveState(_ state: KasaDeviceState)
    func legacyProtocolDidChangeState(_ success: Bool)
    func legacyProtocolDidFail(_ error: Error?)
}

class TTModeKasaLegacyProtocol: NSObject, GCDAsyncSocketDelegate {

    weak var delegate: TTModeKasaLegacyProtocolDelegate?

    private var socket: GCDAsyncSocket?
    private var ipAddress: String
    private var port: UInt16
    private var pendingCallback: (() -> Void)?
    private var responseData = Data()

    private enum SocketTag: Int {
        case header = 1
        case body = 2
    }

    // MARK: - Initialization

    init(ipAddress: String, port: UInt16 = KasaConstants.legacyPort) {
        self.ipAddress = ipAddress
        self.port = port
        super.init()
    }

    // MARK: - XOR Encryption/Decryption

    /// XOR cipher encryption - key updates to ciphertext (encrypted) byte after each XOR
    static func encrypt(_ plaintext: Data) -> Data {
        var key: UInt8 = KasaConstants.xorInitialKey
        var result = Data()
        for byte in plaintext {
            let encrypted = key ^ byte
            result.append(encrypted)
            key = encrypted  // Key advances with ciphertext
        }
        return result
    }

    /// XOR cipher decryption - key updates to ciphertext byte after each XOR
    static func decrypt(_ ciphertext: Data) -> Data {
        var key: UInt8 = KasaConstants.xorInitialKey
        var result = Data()
        for byte in ciphertext {
            let decrypted = key ^ byte
            result.append(decrypted)
            key = byte  // Key advances with ciphertext (input)
        }
        return result
    }

    /// Encrypt with 4-byte big-endian length header for TCP communication
    static func encryptWithHeader(_ plaintext: Data) -> Data {
        let encryptedData = encrypt(plaintext)

        // 4-byte big-endian length header
        var length = UInt32(encryptedData.count).bigEndian
        var packet = Data(bytes: &length, count: 4)
        packet.append(encryptedData)

        return packet
    }

    // MARK: - Packet Building

    /// Build a TCP packet with 4-byte big-endian length header + encrypted payload
    private func buildPacket(_ json: String) -> Data {
        guard let jsonData = json.data(using: .utf8) else {
            return Data()
        }

        let encryptedData = TTModeKasaLegacyProtocol.encrypt(jsonData)

        // 4-byte big-endian length header
        var length = UInt32(encryptedData.count).bigEndian
        var packet = Data(bytes: &length, count: 4)
        packet.append(encryptedData)

        return packet
    }

    // MARK: - Commands

    func requestDeviceInfo() {
        let command = "{\"system\":{\"get_sysinfo\":{}}}"
        sendCommand(command)
    }

    func requestDeviceState(callback: @escaping () -> Void) {
        pendingCallback = callback
        requestDeviceInfo()
    }

    func setRelayState(_ state: KasaDeviceState) {
        let stateValue = state == .on ? 1 : 0
        let command = "{\"system\":{\"set_relay_state\":{\"state\":\(stateValue)}}}"
        sendCommand(command)
    }

    // MARK: - TCP Communication

    private func sendCommand(_ command: String) {
        responseData = Data()

        socket = GCDAsyncSocket(delegate: self, delegateQueue: DispatchQueue.main)

        do {
            try socket?.connect(toHost: ipAddress, onPort: port, withTimeout: 10)
        } catch {
            print(" ---> Kasa Legacy: Failed to connect to \(ipAddress):\(port) - \(error)")
            delegate?.legacyProtocolDidFail(error)
        }

        let packet = buildPacket(command)

        socket?.write(packet, withTimeout: 10, tag: 0)
        socket?.readData(toLength: 4, withTimeout: 10, tag: SocketTag.header.rawValue)
    }

    private func disconnect() {
        socket?.disconnect()
        socket = nil
    }

    // MARK: - GCDAsyncSocketDelegate

    func socket(_ sock: GCDAsyncSocket, didConnectToHost host: String, port: UInt16) {
        print(" ---> Kasa Legacy: Connected to \(host):\(port)")
    }

    func socket(_ sock: GCDAsyncSocket, didRead data: Data, withTag tag: Int) {
        switch SocketTag(rawValue: tag) {
        case .header:
            // Parse 4-byte length header
            guard data.count >= 4 else {
                print(" ---> Kasa Legacy: Invalid header length")
                delegate?.legacyProtocolDidFail(nil)
                disconnect()
                return
            }

            let length = data.withUnsafeBytes { $0.load(as: UInt32.self).bigEndian }
            print(" ---> Kasa Legacy: Expecting \(length) bytes of payload")

            // Read the body
            socket?.readData(toLength: UInt(length), withTimeout: 10, tag: SocketTag.body.rawValue)

        case .body:
            // Decrypt the payload
            let decryptedData = TTModeKasaLegacyProtocol.decrypt(data)

            if let jsonString = String(data: decryptedData, encoding: .utf8) {
                print(" ---> Kasa Legacy: Received response: \(jsonString)")
                parseResponse(decryptedData)
            } else {
                print(" ---> Kasa Legacy: Failed to decode response")
                delegate?.legacyProtocolDidFail(nil)
            }

            disconnect()

        default:
            break
        }
    }

    func socketDidDisconnect(_ sock: GCDAsyncSocket, withError err: Error?) {
        if let error = err {
            print(" ---> Kasa Legacy: Disconnected with error: \(error)")
            delegate?.legacyProtocolDidFail(error)
        } else {
            print(" ---> Kasa Legacy: Disconnected")
        }
    }

    // MARK: - Response Parsing

    private func parseResponse(_ data: Data) {
        do {
            let decoder = JSONDecoder()
            let response = try decoder.decode(KasaSystemResponse.self, from: data)

            if let sysinfo = response.system.getSysinfo {
                // Handle get_sysinfo response
                if let relayState = sysinfo.relayState {
                    let state: KasaDeviceState = (relayState == 1 || relayState == 8) ? .on : .off
                    delegate?.legacyProtocolDidReceiveState(state)
                }

                delegate?.legacyProtocolDidReceiveDeviceInfo(sysinfo)
                pendingCallback?()
                pendingCallback = nil
            } else if let relayResponse = response.system.setRelayState {
                // Handle set_relay_state response
                let success = (relayResponse.errCode ?? 0) == 0
                delegate?.legacyProtocolDidChangeState(success)
            }
        } catch {
            print(" ---> Kasa Legacy: Failed to parse response: \(error)")
            delegate?.legacyProtocolDidFail(error)
        }
    }
}
