//
//  TTModeWemoDevice.swift
//  Turn Touch iOS
//
//  Created by Samuel Clay on 6/27/16.
//  Copyright © 2016 Turn Touch. All rights reserved.
//

import UIKit

enum TTModeWemoDeviceState {
    case On
    case Off
}

protocol TTModeWemoDeviceDelegate {
    func deviceReady(device: TTModeWemoDevice)
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
    
    func isEqualToDevice(device: TTModeWemoDevice) -> Bool {
        let sameAddress = ipAddress == device.ipAddress
        let samePort = port == device.port
        
        return sameAddress && samePort
    }
    
    func location() -> String {
        return "\(ipAddress):\(port)"
    }
    
    func requestDeviceInfo(attemptsLeft: Int = 5) {
        if attemptsLeft == 0 {
            print(" ---> Error, could not find wemo setup.xml: \(self.location())")
        }
        
        let attemptsLeft = attemptsLeft - 1
        let url = NSURL(string: "http://\(self.location())/setup.xml")
        let request = NSMutableURLRequest(URL: url!)
        let session = NSURLSession.sharedSession()
        request.HTTPMethod = "GET"
        
        session.dataTaskWithRequest(request) { (data, response, connectionError) in
            if connectionError == nil {
                if let httpResponse = response as? NSHTTPURLResponse {
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
                print(" ---> Wemo REST error: \(connectionError)")
            }
        }
    }
    
    func parseSetupXml(data: NSData) {
        let results = PerformXMLXPathQuery(data, "/wemo:root/wemo:device/wemo:friendlyName",
                                           UnsafeMutablePointer<Int8>("wemo".cStringUsingEncoding(NSUTF8StringEncoding)),
                                           UnsafeMutablePointer<Int8>("urn:Belkin:device-1-0".cStringUsingEncoding(NSUTF8StringEncoding)))
        if results.count == 0 {
            print(" ---> Error: could not find friendlyName for Wemo")
            deviceName = "Wemo device (\(self.location()))"
        } else {
            let device: [String: String] = results[0] as! [String: String]
            deviceName = device["nodeContent"]
//            deviceName = results[0]["nodeContent"] // kills syntax highlighting
            print(" ---> Found wemo: \(deviceName) (\(self.location()))")
        }

        delegate.deviceReady(self)
    }
    
    func requestDeviceState(callback: () -> Void) {
        self.requestDeviceState(5, callback)
    }
    
    func requestDeviceState(attemptsLeft: Int, _ callback: () -> Void) {
        if attemptsLeft == 0 {
            print(" ---> Error: could not find wemo state: \(self.location())")
            return
        }
        
        let attemptsLeft = attemptsLeft - 1
        let url = NSURL(string: "http://\(self.location())/upnp/control/basicevent1")
        let body = ["<?xml version=\"1.0\" encoding=\"utf-8\"?>",
                    "<s:Envelope xmlns:s=\"http://schemas.xmlsoap.org/soap/envelope/\" s:encodingStyle=\"http://schemas.xmlsoap.org/soap/encoding/\">",
                    "<s:Body>",
                    "<u:GetBinaryState xmlns:u=\"urn:Belkin:service:basicevent:1\">",
                    "</u:GetBinaryState>",
                    "</s:Body>",
                    "</s:Envelope>"].joinWithSeparator("\r\n").dataUsingEncoding(NSUTF8StringEncoding)
        let request = NSMutableURLRequest(URL: url!)
        let session = NSURLSession.sharedSession()
        request.HTTPMethod = "POST"
        request.setValue("urn:Belkin:service:basicevent:1#GetBinaryState", forHTTPHeaderField: "SOAPACTION")
        request.setValue("text/xml", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = body
        
        session.dataTaskWithRequest(request) { (data, response, connectionError) in
            if connectionError == nil {
                if let httpResponse = response as? NSHTTPURLResponse {
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
                print(" ---> Wemo REST error: \(connectionError)")
            }
        }
    }
    
    func parseBasicEventXml(data: NSData, _ callback: () -> Void) {
        let results = PerformXMLXPathQuery(data, "/*/*/u:GetBinaryStateResponse/BinaryState",
                                           UnsafeMutablePointer<Int8>("u".cStringUsingEncoding(NSUTF8StringEncoding)),
                                           UnsafeMutablePointer<Int8>("urn:Belkin:service:basicevent:1".cStringUsingEncoding(NSUTF8StringEncoding)))
        if results.count == 0 {
            print(" ---> Error: could get binary state for wemo")
            deviceName = "Wemo device (\(self.location()))"
        } else {
            let device: [String: String] = results[0] as! [String: String]
            let state = device["nodeContent"]
            if state == "1" || state == "8" {
                deviceState = .On
            } else if state == "0" {
                deviceState = .Off
            }
            print(" ---> Wemo state: \(deviceName) \(state)/\(deviceState)")
            callback()
        }
    }
    
    func changeDeviceState(state: TTModeWemoDeviceState) {
        let url = NSURL(string: "http://\(self.location())/upnp/control/basicevent1")
        let body = ["<?xml version=\"1.0\" encoding=\"utf-8\"?>",
            "<s:Envelope xmlns:s=\"http://schemas.xmlsoap.org/soap/envelope/\" s:encodingStyle=\"http://schemas.xmlsoap.org/soap/encoding/\">",
            "<s:Body>",
            "<u:SetBinaryState xmlns:u=\"urn:Belkin:service:basicevent:1\">",
            "<BinaryState>\(state == .Off ? "0" : "1")</BinaryState>",
            "</u:SetBinaryState>",
            "</s:Body>",
            "</s:Envelope>"].joinWithSeparator("\r\n").dataUsingEncoding(NSUTF8StringEncoding)
        let request = NSMutableURLRequest(URL: url!)
        let session = NSURLSession.sharedSession()
        request.HTTPMethod = "POST"
        request.setValue("urn:Belkin:service:basicevent:1#SetBinaryState", forHTTPHeaderField: "SOAPACTION")
        request.setValue("text/xml", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = body
        
        session.dataTaskWithRequest(request) { (data, response, connectionError) in
            if connectionError == nil {
                if let httpResponse = response as? NSHTTPURLResponse {
                    if httpResponse.statusCode == 200 {
                        if let responseData = data {
                            print(" ---> Wemo basicevent: \(responseData)")
                        } else {
                            print(" ---> Wemo REST 200 error: \(connectionError)")
                        }
                    }
                }
            } else {
                print(" ---> Wemo REST error: \(connectionError)")
            }
        }
    }
}
