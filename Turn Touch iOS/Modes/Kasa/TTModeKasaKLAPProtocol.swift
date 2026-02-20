//
//  TTModeKasaKLAPProtocol.swift
//  Turn Touch iOS
//
//  Created by Samuel Clay on 12/30/25.
//  Copyright © 2025 Turn Touch. All rights reserved.
//

import Foundation
import CommonCrypto
import CryptoKit

protocol TTModeKasaKLAPProtocolDelegate: AnyObject {
    func klapProtocolDidReceiveDeviceInfo(_ info: KasaKLAPDeviceInfo)
    func klapProtocolDidReceiveState(_ state: KasaDeviceState)
    func klapProtocolDidChangeState(_ success: Bool)
    func klapProtocolDidFail(_ error: Error?)
    func klapProtocolNeedsAuthentication()
}

enum KLAPError: Error {
    case noCredentials
    case handshakeFailed
    case authenticationFailed
    case encryptionFailed
    case decryptionFailed
    case networkError(Error)
    case invalidResponse
}

class TTModeKasaKLAPProtocol: NSObject {

    weak var delegate: TTModeKasaKLAPProtocolDelegate?

    private var ipAddress: String
    private var port: UInt16
    private var username: String?
    private var password: String?

    // Session state
    private var sessionCookie: String?
    private var localSeed: Data?
    private var remoteSeed: Data?
    private var authHash: Data?

    // Derived keys
    private var encryptionKey: Data?
    private var ivBase: Data?
    private var signatureKey: Data?
    private var sequenceNumber: Int32 = 0

    private var isAuthenticated = false
    private var urlSession: URLSession

    // MARK: - Initialization

    init(ipAddress: String, port: UInt16 = KasaConstants.klapHttpPort) {
        self.ipAddress = ipAddress
        self.port = port

        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 10
        config.httpCookieStorage = HTTPCookieStorage.shared
        self.urlSession = URLSession(configuration: config)

        super.init()
    }

    func setCredentials(username: String, password: String) {
        self.username = username
        self.password = password
        self.authHash = computeAuthHash(username: username, password: password)
    }

    // MARK: - Authentication Hash

    /// Compute auth hash: MD5(MD5(username) + MD5(password))
    private func computeAuthHash(username: String, password: String) -> Data {
        let usernameData = username.data(using: .utf8) ?? Data()
        let passwordData = password.data(using: .utf8) ?? Data()

        let md5Username = md5(usernameData)
        let md5Password = md5(passwordData)

        var combined = Data()
        combined.append(md5Username)
        combined.append(md5Password)

        return md5(combined)
    }

    // MARK: - Handshake

    func performHandshake(completion: @escaping (Result<Void, KLAPError>) -> Void) {
        guard authHash != nil else {
            delegate?.klapProtocolNeedsAuthentication()
            completion(.failure(.noCredentials))
            return
        }

        // Generate 16-byte random local seed
        localSeed = generateRandomBytes(16)

        guard let localSeed = localSeed else {
            completion(.failure(.handshakeFailed))
            return
        }

        // Handshake 1
        let url = URL(string: "http://\(ipAddress):\(port)/app/handshake1")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = localSeed
        request.setValue("application/octet-stream", forHTTPHeaderField: "Content-Type")

        let task = urlSession.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }

            if let error = error {
                print(" ---> Kasa KLAP: Handshake1 network error: \(error)")
                completion(.failure(.networkError(error)))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(.handshakeFailed))
                return
            }

            // Extract session cookie
            if let cookies = HTTPCookieStorage.shared.cookies(for: url) {
                for cookie in cookies {
                    if cookie.name == "TP_SESSIONID" {
                        self.sessionCookie = cookie.value
                        print(" ---> Kasa KLAP: Got session cookie: \(cookie.value)")
                    }
                }
            }

            guard httpResponse.statusCode == 200, let data = data, data.count >= 48 else {
                print(" ---> Kasa KLAP: Handshake1 failed with status \(httpResponse.statusCode)")
                if httpResponse.statusCode == 401 || httpResponse.statusCode == 403 {
                    self.delegate?.klapProtocolNeedsAuthentication()
                    completion(.failure(.authenticationFailed))
                } else {
                    completion(.failure(.handshakeFailed))
                }
                return
            }

            // Response: 16 bytes remote_seed + 32 bytes server_hash
            self.remoteSeed = data.prefix(16)
            let serverHash = data.suffix(32)

            // Verify server hash = SHA256(local_seed + auth_hash)
            guard let authHash = self.authHash else {
                completion(.failure(.noCredentials))
                return
            }

            var expectedHashInput = Data()
            expectedHashInput.append(localSeed)
            expectedHashInput.append(authHash)
            let expectedHash = self.sha256(expectedHashInput)

            if serverHash != expectedHash {
                print(" ---> Kasa KLAP: Server hash verification failed")
                self.delegate?.klapProtocolNeedsAuthentication()
                completion(.failure(.authenticationFailed))
                return
            }

            print(" ---> Kasa KLAP: Handshake1 successful")

            // Proceed to handshake 2
            self.performHandshake2(completion: completion)
        }
        task.resume()
    }

    private func performHandshake2(completion: @escaping (Result<Void, KLAPError>) -> Void) {
        guard let remoteSeed = remoteSeed, let authHash = authHash else {
            completion(.failure(.handshakeFailed))
            return
        }

        // Send SHA256(remote_seed + auth_hash)
        var hashInput = Data()
        hashInput.append(remoteSeed)
        hashInput.append(authHash)
        let clientHash = sha256(hashInput)

        let url = URL(string: "http://\(ipAddress):\(port)/app/handshake2")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = clientHash
        request.setValue("application/octet-stream", forHTTPHeaderField: "Content-Type")

        // Include session cookie
        if let cookie = sessionCookie {
            request.setValue("TP_SESSIONID=\(cookie)", forHTTPHeaderField: "Cookie")
        }

        let task = urlSession.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }

            if let error = error {
                print(" ---> Kasa KLAP: Handshake2 network error: \(error)")
                completion(.failure(.networkError(error)))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                let status = (response as? HTTPURLResponse)?.statusCode ?? -1
                print(" ---> Kasa KLAP: Handshake2 failed with status \(status)")
                if status == 401 || status == 403 {
                    self.delegate?.klapProtocolNeedsAuthentication()
                    completion(.failure(.authenticationFailed))
                } else {
                    completion(.failure(.handshakeFailed))
                }
                return
            }

            print(" ---> Kasa KLAP: Handshake2 successful")

            // Derive keys
            self.deriveKeys()
            self.isAuthenticated = true
            completion(.success(()))
        }
        task.resume()
    }

    // MARK: - Key Derivation

    private func deriveKeys() {
        guard let localSeed = localSeed, let remoteSeed = remoteSeed, let authHash = authHash else {
            return
        }

        // Encryption key: SHA256("lsk" + local_seed + remote_seed + auth_hash)[:16]
        var encKeyInput = Data()
        encKeyInput.append("lsk".data(using: .utf8)!)
        encKeyInput.append(localSeed)
        encKeyInput.append(remoteSeed)
        encKeyInput.append(authHash)
        encryptionKey = sha256(encKeyInput).prefix(16)

        // IV base: SHA256("iv" + local_seed + remote_seed + auth_hash)[:12]
        // Last 4 bytes of full hash are initial sequence number
        var ivInput = Data()
        ivInput.append("iv".data(using: .utf8)!)
        ivInput.append(localSeed)
        ivInput.append(remoteSeed)
        ivInput.append(authHash)
        let fullIvHash = sha256(ivInput)
        ivBase = fullIvHash.prefix(12)

        // Extract sequence number from last 4 bytes
        let seqBytes = fullIvHash.suffix(4)
        sequenceNumber = seqBytes.withUnsafeBytes { $0.load(as: Int32.self).bigEndian }

        // Signature key: SHA256("ldk" + local_seed + remote_seed + auth_hash)[:28]
        var sigInput = Data()
        sigInput.append("ldk".data(using: .utf8)!)
        sigInput.append(localSeed)
        sigInput.append(remoteSeed)
        sigInput.append(authHash)
        signatureKey = sha256(sigInput).prefix(28)

        print(" ---> Kasa KLAP: Keys derived, initial sequence: \(sequenceNumber)")
    }

    // MARK: - Encryption/Decryption

    private func encrypt(_ plaintext: Data) -> Data? {
        guard let encryptionKey = encryptionKey,
              let ivBase = ivBase,
              let signatureKey = signatureKey else {
            return nil
        }

        // Build IV: ivBase (12 bytes) + seq (4 bytes big-endian)
        sequenceNumber += 1
        var iv = Data(ivBase)
        var seqBigEndian = sequenceNumber.bigEndian
        iv.append(Data(bytes: &seqBigEndian, count: 4))

        // PKCS7 pad the plaintext
        let paddedPlaintext = pkcs7Pad(plaintext, blockSize: kCCBlockSizeAES128)

        // AES-128-CBC encrypt
        guard let ciphertext = aes128CBCEncrypt(paddedPlaintext, key: encryptionKey, iv: iv) else {
            return nil
        }

        // Signature: SHA256(sigKey + seq_bytes + ciphertext)
        var sigInput = Data(signatureKey)
        sigInput.append(Data(bytes: &seqBigEndian, count: 4))
        sigInput.append(ciphertext)
        let signature = sha256(sigInput)

        // Result: signature (32 bytes) + ciphertext
        var result = signature
        result.append(ciphertext)
        return result
    }

    private func decrypt(_ encryptedData: Data) -> Data? {
        guard encryptedData.count > 32,
              let encryptionKey = encryptionKey,
              let ivBase = ivBase else {
            return nil
        }

        // Extract signature and ciphertext
        let _ = encryptedData.prefix(32) // signature (unused, verified by device)
        let ciphertext = encryptedData.suffix(from: 32)

        // Build IV with current sequence (response uses same seq as request)
        var iv = Data(ivBase)
        var seqBigEndian = sequenceNumber.bigEndian
        iv.append(Data(bytes: &seqBigEndian, count: 4))

        // AES-128-CBC decrypt
        guard let paddedPlaintext = aes128CBCDecrypt(Data(ciphertext), key: encryptionKey, iv: iv) else {
            return nil
        }

        // Remove PKCS7 padding
        return pkcs7Unpad(paddedPlaintext)
    }

    // MARK: - Commands

    func requestDeviceInfo() {
        let command = "{\"method\":\"get_device_info\"}"
        sendCommand(command) { [weak self] result in
            switch result {
            case .success(let data):
                self?.parseDeviceInfoResponse(data)
            case .failure(let error):
                self?.delegate?.klapProtocolDidFail(error)
            }
        }
    }

    func setDeviceState(_ state: KasaDeviceState) {
        let on = state == .on
        let command = "{\"method\":\"set_device_info\",\"params\":{\"device_on\":\(on)}}"
        sendCommand(command) { [weak self] result in
            switch result {
            case .success:
                self?.delegate?.klapProtocolDidChangeState(true)
            case .failure(let error):
                self?.delegate?.klapProtocolDidFail(error)
            }
        }
    }

    private func sendCommand(_ command: String, completion: @escaping (Result<Data, KLAPError>) -> Void) {
        if !isAuthenticated {
            performHandshake { [weak self] result in
                switch result {
                case .success:
                    self?.sendCommand(command, completion: completion)
                case .failure(let error):
                    completion(.failure(error))
                }
            }
            return
        }

        guard let commandData = command.data(using: .utf8),
              let encryptedData = encrypt(commandData) else {
            completion(.failure(.encryptionFailed))
            return
        }

        let url = URL(string: "http://\(ipAddress):\(port)/app/request?seq=\(sequenceNumber)")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = encryptedData
        request.setValue("application/octet-stream", forHTTPHeaderField: "Content-Type")

        if let cookie = sessionCookie {
            request.setValue("TP_SESSIONID=\(cookie)", forHTTPHeaderField: "Cookie")
        }

        let task = urlSession.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }

            if let error = error {
                completion(.failure(.networkError(error)))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(.invalidResponse))
                return
            }

            if httpResponse.statusCode == 403 {
                // Session expired, need to re-authenticate
                self.isAuthenticated = false
                self.performHandshake { result in
                    switch result {
                    case .success:
                        self.sendCommand(command, completion: completion)
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
                return
            }

            guard httpResponse.statusCode == 200, let data = data else {
                completion(.failure(.invalidResponse))
                return
            }

            guard let decryptedData = self.decrypt(data) else {
                completion(.failure(.decryptionFailed))
                return
            }

            completion(.success(decryptedData))
        }
        task.resume()
    }

    // MARK: - Response Parsing

    private func parseDeviceInfoResponse(_ data: Data) {
        do {
            let decoder = JSONDecoder()
            let response = try decoder.decode(KasaKLAPDeviceInfoResponse.self, from: data)

            if let info = response.result {
                delegate?.klapProtocolDidReceiveDeviceInfo(info)

                if let deviceOn = info.deviceOn {
                    delegate?.klapProtocolDidReceiveState(deviceOn ? .on : .off)
                }
            }
        } catch {
            print(" ---> Kasa KLAP: Failed to parse device info: \(error)")
            delegate?.klapProtocolDidFail(error)
        }
    }

    // MARK: - Crypto Utilities

    private func md5(_ data: Data) -> Data {
        let digest = Insecure.MD5.hash(data: data)
        return Data(digest)
    }

    private func sha256(_ data: Data) -> Data {
        var digest = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        data.withUnsafeBytes { buffer in
            _ = CC_SHA256(buffer.baseAddress, CC_LONG(data.count), &digest)
        }
        return Data(digest)
    }

    private func generateRandomBytes(_ count: Int) -> Data? {
        var bytes = [UInt8](repeating: 0, count: count)
        let result = SecRandomCopyBytes(kSecRandomDefault, count, &bytes)
        guard result == errSecSuccess else { return nil }
        return Data(bytes)
    }

    private func pkcs7Pad(_ data: Data, blockSize: Int) -> Data {
        let paddingLength = blockSize - (data.count % blockSize)
        var padded = data
        padded.append(contentsOf: [UInt8](repeating: UInt8(paddingLength), count: paddingLength))
        return padded
    }

    private func pkcs7Unpad(_ data: Data) -> Data? {
        guard let lastByte = data.last else { return nil }
        let paddingLength = Int(lastByte)
        guard paddingLength > 0, paddingLength <= 16, data.count >= paddingLength else {
            return nil
        }
        return data.prefix(data.count - paddingLength)
    }

    private func aes128CBCEncrypt(_ data: Data, key: Data, iv: Data) -> Data? {
        var outLength = 0
        let bufferSize = data.count + kCCBlockSizeAES128
        var outData = Data(count: bufferSize)

        let status = outData.withUnsafeMutableBytes { outBytes in
            data.withUnsafeBytes { dataBytes in
                key.withUnsafeBytes { keyBytes in
                    iv.withUnsafeBytes { ivBytes in
                        CCCrypt(
                            CCOperation(kCCEncrypt),
                            CCAlgorithm(kCCAlgorithmAES),
                            CCOptions(0), // No padding, we handle PKCS7 manually
                            keyBytes.baseAddress, key.count,
                            ivBytes.baseAddress,
                            dataBytes.baseAddress, data.count,
                            outBytes.baseAddress, bufferSize,
                            &outLength
                        )
                    }
                }
            }
        }

        guard status == kCCSuccess else { return nil }
        outData.count = outLength
        return outData
    }

    private func aes128CBCDecrypt(_ data: Data, key: Data, iv: Data) -> Data? {
        var outLength = 0
        let bufferSize = data.count + kCCBlockSizeAES128
        var outData = Data(count: bufferSize)

        let status = outData.withUnsafeMutableBytes { outBytes in
            data.withUnsafeBytes { dataBytes in
                key.withUnsafeBytes { keyBytes in
                    iv.withUnsafeBytes { ivBytes in
                        CCCrypt(
                            CCOperation(kCCDecrypt),
                            CCAlgorithm(kCCAlgorithmAES),
                            CCOptions(0), // No padding, we handle PKCS7 manually
                            keyBytes.baseAddress, key.count,
                            ivBytes.baseAddress,
                            dataBytes.baseAddress, data.count,
                            outBytes.baseAddress, bufferSize,
                            &outLength
                        )
                    }
                }
            }
        }

        guard status == kCCSuccess else { return nil }
        outData.count = outLength
        return outData
    }
}
