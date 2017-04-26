//
//  TTModeWemoDevice.swift
//  Turn Touch iOS
//
//  Created by Samuel Clay on 6/27/16.
//  Copyright © 2016 Turn Touch. All rights reserved.
//

import UIKit
import SWXMLHash

enum TTModeWemoDeviceState {
    case on
    case off
}

protocol TTModeWemoDeviceDelegate {
    func deviceReady(_ device: TTModeWemoDevice)
}

class TTModeWemoDevice: NSObject {
    var deviceName: String!
    var ipAddress: String
    var port: Int
    var deviceState: TTModeWemoDeviceState!
    var delegate: TTModeWemoDeviceDelegate!
    
    init(ipAddress: String, port: Int) {
        self.ipAddress = ipAddress
        self.port = port
    }
    
    func isEqualToDevice(_ device: TTModeWemoDevice) -> Bool {
        let sameAddress = ipAddress == device.ipAddress
        let samePort = port == device.port
        
        return sameAddress && samePort
    }
    
    func location() -> String {
        return "\(ipAddress):\(port)"
    }
    
    func requestDeviceInfo(_ attemptsLeft: Int = 5) {
        if attemptsLeft == 0 {
            print(" ---> Error, could not find wemo setup.xml: \(self.location())")
        }
        
        let attemptsLeft = attemptsLeft - 1
        let url = URL(string: "http://\(self.location())/setup.xml")
        var request = URLRequest(url: url!)
        let session = URLSession.shared
        request.httpMethod = "GET"
        
        let task = session.dataTask(with: request) { (data, response, connectionError) in
            if connectionError == nil {
                if let httpResponse = response as? HTTPURLResponse {
                    if httpResponse.statusCode == 200 {
                        if let responseData = data {
                            self.parseSetupXml(responseData)
                        } else {
                            print(" ---> Retrying setup.xml fetch...")
                            self.requestDeviceInfo(attemptsLeft)
                        }
                    }
                }
            } else {
                print(" ---> Wemo REST error: \(String(describing: connectionError))")
            }
        }
        task.resume()
    }
    
    func parseSetupXml(_ xmlData: Data) {
        let doc = SWXMLHash.parse(xmlData)
//        print(" ---> Wemo data: \(String(data: xmlData, encoding: .utf8))")
        deviceName = doc["root"]["device"]["friendlyName"].element?.text

        if deviceName != nil {
            print(" ---> Found wemo: \(deviceName ?? "[no device name]") (\(self.location()))")
        } else {
            print(" ---> Error: could not find friendlyName for Wemo")
            deviceName = "Wemo device (\(self.location()))"
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
            print(" ---> Error: could not find wemo state: \(self.location())")
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
                print(" ---> Wemo REST error: \(String(describing: connectionError))")
            }
        }
        task.resume()
    }
    
    func parseBasicEventXml(_ data: Data, _ callback: () -> Void) {
        let doc = SWXMLHash.parse(data)
//        let results = doc["root"]["device"]["friendlyName"].element?.text
        if let stateString = doc["s:Envelope"]["s:Body"]["u:GetBinaryStateResponse"]["BinaryState"].element?.text {
            if stateString == "1" || stateString == "8" {
                deviceState = .on
            } else if stateString == "0" {
                deviceState = .off
            }
            print(" ---> Wemo state: \(deviceName!) \(stateString)/\(deviceState!)")
            callback()
        } else {
            print(" ---> Error: could not get binary state for wemo")
            deviceName = "Wemo device (\(self.location()))"
        }
    }
    
    func changeDeviceState(_ state: TTModeWemoDeviceState) {
        let url = URL(string: "http://\(self.location())/upnp/control/basicevent1")
        let body = ["<?xml version=\"1.0\" encoding=\"utf-8\"?>",
            "<s:Envelope xmlns:s=\"http://schemas.xmlsoap.org/soap/envelope/\" s:encodingStyle=\"http://schemas.xmlsoap.org/soap/encoding/\">",
            "<s:Body>",
            "<u:SetBinaryState xmlns:u=\"urn:Belkin:service:basicevent:1\">",
            "<BinaryState>\(state == .off ? "0" : "1")</BinaryState>",
            "</u:SetBinaryState>",
            "</s:Body>",
            "</s:Envelope>"].joined(separator: "\r\n").data(using: String.Encoding.utf8)
        var request = URLRequest(url: url!)
        let session = URLSession.shared
        request.httpMethod = "POST"
        request.setValue("\"urn:Belkin:service:basicevent:1#SetBinaryState\"", forHTTPHeaderField: "SOAPACTION")
        request.setValue("text/xml", forHTTPHeaderField: "Content-Type")
        request.httpBody = body
        
        let task = session.dataTask(with: request) { (data, response, connectionError) in
            if connectionError == nil {
                if let httpResponse = response as? HTTPURLResponse {
                    if httpResponse.statusCode == 200 {
                        if data != nil {
//                            print(" ---> Wemo basicevent: \(responseData)")
                        }
                    }
                }
            } else {
                print(" ---> Wemo REST error: \(String(describing: connectionError))")
            }
        }
        task.resume()
    }
}
