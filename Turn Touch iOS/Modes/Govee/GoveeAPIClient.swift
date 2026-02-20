//
//  GoveeAPIClient.swift
//  Turn Touch iOS
//
//  Created by Samuel Clay on 2/20/26.
//  Copyright © 2026 Turn Touch. All rights reserved.
//

import Foundation

protocol GoveeAPIClientDelegate: AnyObject {
    func apiClientDidFetchDevices(_ devices: [GoveeDevice])
    func apiClientDidFailWithError(_ error: String)
    func apiClientDidControlDevice(success: Bool, error: String?)
    func apiClientDidFetchDeviceState(_ device: GoveeDevice, powerState: GoveeDeviceState?, brightness: Int?)
}

class GoveeAPIClient {

    weak var delegate: GoveeAPIClientDelegate?

    private var apiKey: String?
    private let session = URLSession.shared

    init(apiKey: String? = nil) {
        self.apiKey = apiKey
    }

    func setApiKey(_ key: String) {
        self.apiKey = key
    }

    // MARK: - List Devices

    func fetchDevices() {
        guard let apiKey = apiKey, !apiKey.isEmpty else {
            delegate?.apiClientDidFailWithError("No API key configured")
            return
        }

        guard let url = URL(string: GoveeConstants.baseURL + GoveeConstants.devicesEndpoint) else {
            delegate?.apiClientDidFailWithError("Invalid URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(apiKey, forHTTPHeaderField: "Govee-API-Key")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        NSLog(" ---> Govee API: Fetching devices...")

        session.dataTask(with: request) { [weak self] data, response, error in
            if let error = error {
                NSLog(" ---> Govee API: Network error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self?.delegate?.apiClientDidFailWithError("Network error: \(error.localizedDescription)")
                }
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                DispatchQueue.main.async {
                    self?.delegate?.apiClientDidFailWithError("Invalid response")
                }
                return
            }

            if httpResponse.statusCode == 401 {
                DispatchQueue.main.async {
                    self?.delegate?.apiClientDidFailWithError("Invalid API key")
                }
                return
            }

            if httpResponse.statusCode == 429 {
                DispatchQueue.main.async {
                    self?.delegate?.apiClientDidFailWithError("Rate limit exceeded. Try again later.")
                }
                return
            }

            guard let data = data else {
                DispatchQueue.main.async {
                    self?.delegate?.apiClientDidFailWithError("No data received")
                }
                return
            }

            do {
                let deviceListResponse = try JSONDecoder().decode(GoveeDeviceListResponse.self, from: data)

                if let code = deviceListResponse.code, code != 200 {
                    let msg = deviceListResponse.message ?? "Unknown error"
                    NSLog(" ---> Govee API: Error response: \(msg)")
                    DispatchQueue.main.async {
                        self?.delegate?.apiClientDidFailWithError(msg)
                    }
                    return
                }

                var devices: [GoveeDevice] = []
                if let deviceDataList = deviceListResponse.data {
                    for deviceData in deviceDataList {
                        guard let deviceId = deviceData.device,
                              let sku = deviceData.sku else {
                            continue
                        }
                        let name = deviceData.deviceName ?? "Govee Device"
                        let device = GoveeDevice(deviceId: deviceId, sku: sku, deviceName: name)
                        device.capabilities = deviceData.capabilities ?? []
                        devices.append(device)
                    }
                }

                NSLog(" ---> Govee API: Found \(devices.count) devices")
                DispatchQueue.main.async {
                    self?.delegate?.apiClientDidFetchDevices(devices)
                }
            } catch {
                NSLog(" ---> Govee API: JSON parse error: \(error)")
                DispatchQueue.main.async {
                    self?.delegate?.apiClientDidFailWithError("Failed to parse response: \(error.localizedDescription)")
                }
            }
        }.resume()
    }

    // MARK: - Control Device

    func controlDevice(_ device: GoveeDevice, turnOn: Bool) {
        sendControlCommand(device: device, capabilityType: "devices.capabilities.on_off",
                          instance: "powerSwitch", value: turnOn ? 1 : 0)
    }

    func setBrightness(_ device: GoveeDevice, brightness: Int) {
        let clampedBrightness = max(1, min(100, brightness))
        sendControlCommand(device: device, capabilityType: "devices.capabilities.range",
                          instance: "brightness", value: clampedBrightness)
    }

    // MARK: - Get Device State

    func fetchDeviceState(_ device: GoveeDevice) {
        guard let apiKey = apiKey, !apiKey.isEmpty else {
            delegate?.apiClientDidFailWithError("No API key configured")
            return
        }

        guard let url = URL(string: GoveeConstants.baseURL + GoveeConstants.stateEndpoint) else {
            delegate?.apiClientDidFailWithError("Invalid URL")
            return
        }

        let stateRequest = GoveeDeviceStateRequest(
            requestId: UUID().uuidString,
            payload: GoveeDeviceStatePayload(sku: device.sku, device: device.deviceId)
        )

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(apiKey, forHTTPHeaderField: "Govee-API-Key")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            request.httpBody = try JSONEncoder().encode(stateRequest)
        } catch {
            delegate?.apiClientDidFailWithError("Failed to encode request")
            return
        }

        NSLog(" ---> Govee API: Fetching state for \(device.deviceName)...")

        session.dataTask(with: request) { [weak self] data, response, error in
            if let error = error {
                NSLog(" ---> Govee API: State fetch error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self?.delegate?.apiClientDidFetchDeviceState(device, powerState: nil, brightness: nil)
                }
                return
            }

            guard let data = data else {
                DispatchQueue.main.async {
                    self?.delegate?.apiClientDidFetchDeviceState(device, powerState: nil, brightness: nil)
                }
                return
            }

            do {
                let stateResponse = try JSONDecoder().decode(GoveeDeviceStateResponse.self, from: data)
                var powerState: GoveeDeviceState?
                var brightness: Int?

                if let capabilities = stateResponse.payload?.capabilities {
                    for cap in capabilities {
                        if cap.instance == "powerSwitch", let val = cap.state?.value?.intValue {
                            powerState = val == 1 ? .on : .off
                        }
                        if cap.instance == "brightness", let val = cap.state?.value?.intValue {
                            brightness = val
                        }
                    }
                }

                NSLog(" ---> Govee API: State for \(device.deviceName): power=\(String(describing: powerState)), brightness=\(String(describing: brightness))")

                DispatchQueue.main.async {
                    self?.delegate?.apiClientDidFetchDeviceState(device, powerState: powerState, brightness: brightness)
                }
            } catch {
                NSLog(" ---> Govee API: State parse error: \(error)")
                DispatchQueue.main.async {
                    self?.delegate?.apiClientDidFetchDeviceState(device, powerState: nil, brightness: nil)
                }
            }
        }.resume()
    }

    // MARK: - Private

    private func sendControlCommand(device: GoveeDevice, capabilityType: String, instance: String, value: Int) {
        guard let apiKey = apiKey, !apiKey.isEmpty else {
            delegate?.apiClientDidFailWithError("No API key configured")
            return
        }

        guard let url = URL(string: GoveeConstants.baseURL + GoveeConstants.controlEndpoint) else {
            delegate?.apiClientDidFailWithError("Invalid URL")
            return
        }

        let controlRequest = GoveeControlRequest(
            requestId: UUID().uuidString,
            payload: GoveeControlPayload(
                sku: device.sku,
                device: device.deviceId,
                capability: GoveeControlCapability(
                    type: capabilityType,
                    instance: instance,
                    value: value
                )
            )
        )

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(apiKey, forHTTPHeaderField: "Govee-API-Key")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            request.httpBody = try JSONEncoder().encode(controlRequest)
        } catch {
            delegate?.apiClientDidFailWithError("Failed to encode request")
            return
        }

        NSLog(" ---> Govee API: Sending \(instance)=\(value) to \(device.deviceName)...")

        session.dataTask(with: request) { [weak self] data, response, error in
            if let error = error {
                NSLog(" ---> Govee API: Control error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self?.delegate?.apiClientDidControlDevice(success: false, error: error.localizedDescription)
                }
                return
            }

            guard let data = data else {
                DispatchQueue.main.async {
                    self?.delegate?.apiClientDidControlDevice(success: false, error: "No response data")
                }
                return
            }

            do {
                let controlResponse = try JSONDecoder().decode(GoveeControlResponse.self, from: data)
                let success = controlResponse.code == 200
                let errorMsg = success ? nil : (controlResponse.message ?? "Unknown error")

                NSLog(" ---> Govee API: Control response: success=\(success), message=\(controlResponse.message ?? "none")")

                DispatchQueue.main.async {
                    self?.delegate?.apiClientDidControlDevice(success: success, error: errorMsg)
                }
            } catch {
                NSLog(" ---> Govee API: Control response parse error: \(error)")
                DispatchQueue.main.async {
                    self?.delegate?.apiClientDidControlDevice(success: true, error: nil)
                }
            }
        }.resume()
    }
}
