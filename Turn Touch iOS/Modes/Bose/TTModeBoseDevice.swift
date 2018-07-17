//
//  TTModeBoseDevice.swift
//  Turn Touch iOS
//
//  Created by Samuel Clay on 6/27/16.
//  Copyright © 2016 Turn Touch. All rights reserved.
//

import UIKit
import CoreFoundation
import SWXMLHash

enum TTModeBoseButton: String {
    case play = "PLAY"
    case pause = "PAUSE"
    case play_pause = "PLAY_PAUSE"
    case next_track = "NEXT_TRACK"
    case previous_track = "PREV_TRACK"
    case mute = "MUTE"
    case shuffle_on = "SHUFFLE_ON"
    case shuffle_off = "SHUFFLE_OFF"
    case bookmark = "BOOKMARK"
}

protocol TTModeBoseDeviceDelegate {
    func deviceReady(_ device: TTModeBoseDevice)
    func deviceFailed(_ device: TTModeBoseDevice)
}

class TTModeBoseDevice: NSObject {
    var deviceName: String?
    var serialNumber: String?
    var macAddress: String?
    var ipAddress: String
    var port: Int
    var setupUrl: String
//    var deviceState: TTModeBoseDeviceState!
    var delegate: TTModeBoseDeviceDelegate!
    
    init(ipAddress: String, port: Int, setupUrl: String) {
        self.ipAddress = ipAddress
        self.port = port
        self.setupUrl = setupUrl
    }
    
    override var description: String {
        return "\(deviceName ?? "") (\(self.location())/\(serialNumber ?? ""))"
    }
    
    func isEqualToDevice(_ device: TTModeBoseDevice) -> Bool {
        return serialNumber == device.serialNumber
    }
    
    func isSameAddress(_ device: TTModeBoseDevice) -> Bool {
        let sameAddress = ipAddress == device.ipAddress
        let samePort = port == device.port
        
        return sameAddress && samePort
    }
    
    func isSameDeviceDifferentLocation(_ device: TTModeBoseDevice) -> Bool {
        let same = self.isEqualToDevice(device) && !self.isSameAddress(device)
        print(" ---> Comparing Bose devices: \(self) vs \(device): \(same)")
        
        return same
    }
    
    func location() -> String {
        return "\(ipAddress):8090"
//        return url
    }
    
    func requestDeviceInfo(_ attemptsLeft: Int = 5) {
        if attemptsLeft == 0 {
            print(" ---> Bose Error, could not find Bose setup.xml: \(self)")
            return
        }
        
        let attemptsLeft = attemptsLeft - 1
        let url = URL(string: "\(self.setupUrl)")
        var request = URLRequest(url: url!)
        let session = URLSession.shared
        request.httpMethod = "GET"

        let task = session.dataTask(with: request) { (data, response, connectionError) in
            if connectionError == nil {
                if let httpResponse = response as? HTTPURLResponse {
                    if httpResponse.statusCode == 200 {
                        if let responseData = data {
                            print(" ---> Parsing Bose setup.xml for \(self)...")
                            self.parseSetupXml(responseData)
                        } else {
                            print(" ---> Retrying Bose setup.xml fetch...")
                            self.requestDeviceInfo(attemptsLeft)
                        }
                    } else {
                        print(" ---> Bose \(self) setup.xml error: \(httpResponse.statusCode)")
                    }
                }
            } else {
                print(" ---> Bose REST error: \(String(describing: connectionError))")
                
                self.delegate.deviceFailed(self)
            }
        }
        task.resume()
    }
    
    func parseSetupXml(_ xmlData: Data) {
        let doc = SWXMLHash.parse(xmlData)
//        print(" ---> Bose data: \(String(data: xmlData, encoding: .utf8))")
        deviceName = doc["root"]["device"]["friendlyName"].element?.text

        if let serial = doc["root"]["device"]["serialNumber"].element?.text {
            serialNumber = serial
        }
        if let mac = doc["root"]["device"]["UDN"].element?.text {
            macAddress = mac
        }

        if deviceName != nil {
            print(" ---> Found Bose: \(self)")
        } else {
            print(" ---> Error: could not find friendlyName for Bose")
            deviceName = "Bose device (\(self.location()))"
        }
        
        DispatchQueue.main.async {
            self.delegate.deviceReady(self)
        }
    }
    
    func requestDeviceState(_ callback: @escaping () -> Void) {
        self.requestDeviceState(5, callback)
    }
    
    func requestDeviceState(_ attemptsLeft: Int, _ callback: @escaping () -> Void) {
        if attemptsLeft == 0 {
            print(" ---> Error: could not find Bose state: \(self.location())")
            return
        }
        
        let attemptsLeft = attemptsLeft - 1
        let url = URL(string: "http://\(self.location())/upnp/control/basicevent1")
        let body = ["<?xml version=\"1.0\" encoding=\"utf-8\"?>",
                    "<s:Envelope xmlns:s=\"http://schemas.xmlsoap.org/soap/envelope/\" s:encodingStyle=\"http://schemas.xmlsoap.org/soap/encoding/\">",
                    "<s:Body>",
                    "<u:GetBinaryState xmlns:u=\"urn:Belkin:service:basicevent:1\">",
                    "</u:GetBinaryState>",
                    "</s:Body>",
                    "</s:Envelope>"].joined(separator: "\r\n").data(using: String.Encoding.utf8)
        var request = URLRequest(url: url!)
        let session = URLSession.shared
        request.httpMethod = "POST"
        request.setValue("\"urn:Belkin:service:basicevent:1#GetBinaryState\"", forHTTPHeaderField: "SOAPACTION")
        request.setValue("text/xml", forHTTPHeaderField: "Content-Type")
        request.httpBody = body
        
        let task = session.dataTask(with: request) { (data, response, connectionError) in
            if connectionError == nil {
                if let httpResponse = response as? HTTPURLResponse {
                    if httpResponse.statusCode == 200 {
                        if let responseData = data {
                            self.parseBasicEventXml(responseData, callback)
                        } else {
                            print(" ---> Retrying basicevent.xml fetch...")
                            self.requestDeviceState(attemptsLeft, callback)
                        }
                    }
                }
            } else {
                print(" ---> Bose REST error: \(String(describing: connectionError))\n")
                
                self.delegate.deviceFailed(self)
            }
        }
        task.resume()
    }
    
    func parseBasicEventXml(_ data: Data, _ callback: () -> Void) {
        _ = SWXMLHash.parse(data)
//        let results = doc["root"]["device"]["friendlyName"].element?.text
//        if let stateString = doc["s:Envelope"]["s:Body"]["u:GetBinaryStateResponse"]["BinaryState"].element?.text {
//            if stateString == "1" || stateString == "8" {
//                deviceState = .on
//            } else if stateString == "0" {
//                deviceState = .off
//            }
//            print(" ---> Bose state: \(deviceName!) \(stateString)/\(deviceState!)")
//            callback()
//        } else {
//            print(" ---> Error: could not get binary state for Bose")
//            deviceName = "Bose device (\(self.location()))"
//        }
    }
    
    func pressSpeakerButton(_ button: TTModeBoseButton) {
        let url = URL(string: "http://\(self.location())/key")
        let body = ["<?xml version=\"1.0\" ?>",
            "<key state=\"press\" sender=\"Gabbo\">",
            "\(button.rawValue)",
            "</key>"].joined(separator: "")
        let bodyData = body.data(using: String.Encoding.utf8)
        var request = URLRequest(url: url!)
        let session = URLSession.shared
        request.httpMethod = "POST"
//        request.setValue("\"urn:Belkin:service:basicevent:1#SetBinaryState\"", forHTTPHeaderField: "SOAPACTION")
//        request.setValue("text/xml", forHTTPHeaderField: "Content-Type")
        request.httpBody = bodyData
        
        let task = session.dataTask(with: request) { (data, response, connectionError) in
            if connectionError == nil {
                if let httpResponse = response as? HTTPURLResponse {
                    if httpResponse.statusCode == 200 {
                        if data != nil {
                            print(" ---> Bose basicevent: \(String(describing: data))")
                        }
                    } else {
                        print(" ---> Bose REST status code error: \(httpResponse.statusCode)\n")
                        
                        self.delegate.deviceFailed(self)
                    }
                }
            } else {
                print(" ---> Bose REST error: \(String(describing: connectionError))\n")
                
                self.delegate.deviceFailed(self)
            }
        }
        task.resume()
    }
}
