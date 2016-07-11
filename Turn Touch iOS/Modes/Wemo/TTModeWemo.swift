//
//  TTModeWemo.swift
//  Turn Touch iOS
//
//  Created by Samuel Clay on 6/27/16.
//  Copyright © 2016 Turn Touch. All rights reserved.
//

import UIKit
import CoreFoundation

struct TTModeWemoConstants {
    static let kWemoDeviceLocation = "wemoDeviceLocation"
    static let kWemoFoundDevices = "wemoFoundDevices"
}

enum TTWemoState {
    case Disconnected
    case Connecting
    case Connected
}

protocol TTModeWemoDelegate {
    func changeState(state: TTWemoState, mode: TTModeWemo)
}

class TTModeWemo: TTMode, TTModeWemoMulticastDelegate, TTModeWemoDeviceDelegate {
    
    var delegate: TTModeWemoDelegate!
    var wemoState = TTWemoState.Disconnected
    static var multicastServer = TTModeWemoMulticastServer()
    static var foundDevices: [TTModeWemoDevice] = []
    
    required init() {
        super.init()
        
        TTModeWemo.multicastServer.delegate = self
        
        self.assembleFoundDevices()
        
        if TTModeWemo.foundDevices.count == 0 {
            wemoState = .Connecting
//            self.beginConnectingToWemo()
        } else {
            wemoState = .Connected
        }
        delegate?.changeState(wemoState, mode: self)
    }
    
    func resetKnownDevices() {
        let prefs = NSUserDefaults.standardUserDefaults()
        prefs.removeObjectForKey(TTModeWemoConstants.kWemoFoundDevices)
        prefs.synchronize()
    }
    
    func assembleFoundDevices() {
        let prefs = NSUserDefaults.standardUserDefaults()
        TTModeWemo.foundDevices = []

        if let foundDevices = prefs.arrayForKey(TTModeWemoConstants.kWemoFoundDevices) as? [[String: AnyObject]] {
            for device in foundDevices {
                let newDevice = self.foundDevice([:], host: device["ipaddress"] as! String, port: device["port"] as! Int, name: device["name"] as! String?, live: false)
                print(" ---> Loading wemo: \(newDevice.deviceName) (\(newDevice.location()))")
            }
        }
    }
    
    override class func title() -> String {
        return "Wemo"
    }
    
    override class func subtitle() -> String {
        return "Smart power meter and outlet"
    }
    
    override class func imageName() -> String {
        return "mode_wemo.png"
    }
    
    // MARK: Actions
    
    override class func actions() -> [String] {
        return ["TTModeWemoDeviceOn",
                "TTModeWemoDeviceOff",
                "TTModeWemoDeviceToggle"]
    }
    
    // MARK: Action titles
    
    func titleTTModeWemoDeviceOn() -> String {
        return "Turn on"
    }
    
    func titleTTModeWemoDeviceOff() -> String {
        return "Turn off"
    }
    
    func titleTTModeWemoDeviceToggle() -> String {
        return "Toggle device"
    }
    
    // MARK: Action images
    
    func imageTTModeWemoDeviceOn() -> String {
        return "next_story.png"
    }
    
    func imageTTModeWemoDeviceOff() -> String {
        return "next_site.png"
    }
    
    func imageTTModeWemoDeviceToggle() -> String {
        return "previous_story.png"
    }
    
    
    // MARK: Defaults
    
    override func defaultNorth() -> String {
        return "TTModeWemoDeviceOn"
    }
    
    override func defaultEast() -> String {
        return "TTModeWemoDeviceToggle"
    }
    
    override func defaultWest() -> String {
        return "TTModeWemoDeviceToggle"
    }
    
    override func defaultSouth() -> String {
        return "TTModeWemoDeviceOff"
    }
    
    // MARK: Action methods
    
    override func activate() {
        delegate?.changeState(wemoState, mode: self)
    }
    
    override func deactivate() {
        TTModeWemo.multicastServer.deactivate()
    }
    
    func runTTModeWemoDeviceOn(direction: NSNumber) {
        if let device = self.selectedDevice(TTModeDirection(rawValue: direction.integerValue)!) {
            device.changeDeviceState(.On)
        }
    }
    
    func runTTModeWemoDeviceOff(direction: NSNumber) {
        if let device = self.selectedDevice(TTModeDirection(rawValue: direction.integerValue)!) {
            device.changeDeviceState(.Off)
        }
    }
    
    func runTTModeWemoDeviceToggle(direction: NSNumber) {
        if let device = self.selectedDevice(TTModeDirection(rawValue: direction.integerValue)!) {
            device.requestDeviceState {
                if device.deviceState == TTModeWemoDeviceState.On {
                    device.changeDeviceState(.Off)
                } else {
                    device.changeDeviceState(.On)
                }
            }
        }
    }
    
    // MARK: Wemo devices
    
    func selectedDevice(direction: TTModeDirection) -> TTModeWemoDevice? {
        if TTModeWemo.foundDevices.count == 0 {
            return nil
        }
        
        if let deviceLocation = self.action.optionValue(TTModeWemoConstants.kWemoDeviceLocation, direction: direction) as! String? {
            for foundDevice in TTModeWemo.foundDevices {
                if foundDevice.location() == deviceLocation {
                    return foundDevice
                }
            }
        }
        
        let wemoDevice = TTModeWemo.foundDevices[0]
        
        // Store the chosen wemo device so that it is used consistently
        self.action.changeActionOption(TTModeWemoConstants.kWemoDeviceLocation, to: wemoDevice.location())
        
        return wemoDevice
    }
    
    func beginConnectingToWemo() {
        wemoState = .Connecting
        delegate?.changeState(wemoState, mode: self)
        
        TTModeWemo.multicastServer.beginBroadcast()
    }
    
    func cancelConnectingToWemo() {
        wemoState = .Disconnected
        delegate?.changeState(wemoState, mode: self)
    }
    
    // MARK: Multicast delegate
    
    func foundDevice(headers: [String: String], host ipAddress: String, port: Int, name: String?, live: Bool) -> TTModeWemoDevice {
        let newDevice = TTModeWemoDevice(ipAddress: ipAddress, port: port)
        newDevice.delegate = self
        if name != nil {
            newDevice.deviceName = name!
        }
        
        for device in TTModeWemo.foundDevices {
            if device.isEqualToDevice(newDevice) {
                // Already found
                return device
            }
        }
        
        TTModeWemo.foundDevices.append(newDevice)

        newDevice.requestDeviceInfo()
        
        return newDevice
    }
    
    // MARK: Device delegate
    
    func deviceReady(device: TTModeWemoDevice) {
        let prefs = NSUserDefaults.standardUserDefaults()

        TTModeWemo.foundDevices = TTModeWemo.foundDevices.sort {
            (a, b) -> Bool in
            return a.deviceName?.lowercaseString < b.deviceName?.lowercaseString
        }
        
        var foundDevices: [[String: AnyObject]] = []
        for device in TTModeWemo.foundDevices {
            foundDevices.append(["ipaddress": device.ipAddress, "port": device.port, "name": device.deviceName])
        }
        prefs.setObject(foundDevices, forKey: TTModeWemoConstants.kWemoFoundDevices)
        prefs.synchronize()

        wemoState = .Connected
        delegate?.changeState(wemoState, mode: self)
    }
}
